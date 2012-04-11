package.cpath = '../lib/?/?.so;' .. package.cpath
package.path = '../lib/?/?.lua;' .. package.path

module (..., package.seeall)

require ('utils')
require ('proc')
require ('dumper')

username = nil
group = nil
config = nil
uid = nil
ptable = nil

local sig = {
    USR2  = 12,
    WINCH = 28,
    QUIT  = 3,
    TTIN  = 21,
    TTOU  = 22,
    HUP   = 1,
}

function cli:new (obj)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self

    self.ptable = proc.build_ptable()

    if obj.username == nil then
        self.username = 'nobody'
    else
        self.username = obj.username
    end

    if obj.group == nil then
        self.group = self.username
    end

    if obj.config == nil then
        self.config = 'unicorn.rb'
    end

    self.uid = utils.getuid(self.username)

    return obj
end

function cli:show ()
    local ptable = self.ptable

    for uid, unicorns in pairs(ptable) do
        print (uid)
        for master, workers in pairs(unicorns) do
            print (' >> ' .. master)
            for _, pid in ipairs(workers) do
                print ('   > ' .. pid)
            end
        end
    end

    return true
end

function cli:start ()
    --[[
    local pid = utils.fork()

    if pid == 0 then
        print ('in the child')
        utils.usleep(1000)
        print ('bye from child')

        os.exit(0)
    else
        print ('in the parent. child spawned with pid: ' .. pid)
        print ('parent moves on')
    end
    ]]--
    local lines = {}
    local fh = io.popen('uc.pl start -c /home/mak/programming/rails/test_unicorn/unicorn.rb', 'r')

    while true do
        line = fh:read('*line')
        if line == nil then
            break
        else
            table.insert(lines, trim(line))
        end
    end

    fh:close()

    utils.usleep(1000) -- wait for unicorns to start

    self:refresh()

    return lines
end

function cli:restart ()

    self:stop()
    utils.usleep(2000)
    self:start()

    return true
end

function cli:reload ()
    if self:master_exists() == false then
        return false
    end

    for master_pid, _ in pairs(self.ptable[self.uid .. '']) do
        if master_pid ~= nil then
            utils.kill(master_pid, sig['HUP'])
        end
    end

    utils.usleep(1000) -- wait for new workers to spawn
    self:refresh()

    return true
end

function cli:stop ()
    if self:master_exists() == false then
        return false
    end

    for master_pid, _ in pairs(self.ptable[self.uid .. '']) do
        if master_pid ~= nil then
            utils.kill(master_pid, sig['QUIT'])
        end
    end

    self:refresh()

    return true
end

function cli:add_worker (num)
    num = num or 1

    if num < 0 or self:master_exists() == false then
        return false
    end

    for pid, _ in pairs(self.ptable[self.uid .. '']) do
        for i = 1, num do
            utils.kill(pid, sig['TTIN'])
            utils.usleep(500)
        end
    end

    utils.usleep(1000) -- wait for new workers to spawn
    self:refresh()

    return true
end

function cli:remove_worker (num)
    num = num or 1

    if num < 0 or self:master_exists() == false then
        return false
    end

    for pid, workers in pairs(self.ptable[self.uid .. '']) do
        local num_workers = #workers
        if num > num_workers then
            num = num_workers - 1
        end

        if num <= 0 then
            return true
        end

        for i = 1, num do
            utils.kill(pid, sig['TTOU'])
            utils.usleep(500)
        end
    end

    utils.usleep(200) -- wait for workers to quit
    self:refresh()

    return true
end

function cli:refresh ()
    self.ptable = proc.build_ptable()
end

function cli:master_exists ()
    local retval = true
    if (self.ptable[self.uid .. ''] == nil) then
        retval = false
    end

    return retval
end

function trim (line)
  return (line:gsub("^%s*(.-)%s*$", "%1"))
end


