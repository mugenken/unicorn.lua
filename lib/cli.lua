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

function cli:start ()

    return true
end

function cli:restart ()
    return true
end

function cli:reload ()
    if self.ptable[self.uid .. ''] ~= nil then
        for master_pid, _ in pairs(self.ptable[self.uid .. '']) do
            if master_pid ~= nil then
                utils.kill(master_pid, sig['HUP'])
            end
        end
    end

    return true
end

function cli:stop ()
    if self.ptable[self.uid .. ''] ~= nil then
        for master_pid, _ in pairs(self.ptable[self.uid .. '']) do
            if master_pid ~= nil then
                utils.kill(master_pid, sig['QUIT'])
            end
        end
    end

    return true
end

function cli:add_worker (num)
    num = num or 1

    if num < 0 then
        return false
    end

    for pid, _ in pairs(self.ptable[self.uid .. '']) do
        for i = 1, num do
            utils.kill(pid, sig['TTIN'])
            utils.usleep(500)
        end
    end

end

function cli:remove_worker (num)
    num = num or 1

    if num < 0 then
        return false
    end

    for pid, children in pairs(self.ptable[self.uid .. '']) do
        local num_workers = #children
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

        return true
    end

end

function cli:refresh ()
    self.ptable = proc.build_ptable()
end

