package.cpath = '../lib/?/?.so;' .. package.cpath
package.path = '../lib/?/?.lua;' .. package.path

module (..., package.seeall)

local function command ()
    return 'ps fauxn | grep unicorn_rails | grep -v grep'
end

local function trim (line)
  return (line:gsub("^%s*(.-)%s*$", "%1"))
end

local function capture (cmd)
    local lines = {}
    local fh = io.popen(cmd, 'r')

    while true do
        line = fh:read('*line')
        if line == nil then
            break
        else
            table.insert(lines, trim(line))
        end
    end

    fh:close()

    return lines
end

local function f_exists (f)
    local handler = io.open(f)
    if handler == nil then
        return false
    end
    io.close (handler)
    return true
end

local function get_users (lines)
    local users = {}
    for i, line in ipairs(lines) do
        for user,pid in line:gmatch("(%d+)%s+(%d+).*") do
            table.insert(users, {user = user, pid = pid})
        end
    end

    return users
end

local function check_pid_status (pid)
    local found = false
    local timeout = 10
    local file = '/proc/' .. pid .. '/status'

    if f_exists(file) then
        found = true
    else
        while not found or timeout > 0 do
            if f_exists(file) then
                found = true
            end
            utils.usleep(1000)
            timeout = timeout - 1
        end
    end

    return found
end

local function read_lines (file)
    local fh = io.open(file)
    local lines = {}
    if fh == nil then
        return false
    end

    while true do
        line = fh:read('*line')
        if line == nil then
            break
        else
            table.insert(lines, trim(line))
        end
    end

    fh:close()

    return lines
end

local function read_status_file (pid)
    if check_pid_status(pid) then
        local lines = read_lines('/proc/' .. pid .. '/status')
        return lines
    else
        return nil
    end
end

function build_ptable (...)
    local users = ...
    if users == nil then
        users = get_users(capture(command()))
    end
    local ptable = {}
    for _, pair in ipairs(users) do
        local content = read_status_file(pair.pid)

        if content == nil then
            return nil
        end

        if ptable[pair.user] == nil then
            ptable[pair.user] = {}
        end

        for i = 1, #content do
            local line = content[i]
            local ppid = line:match('PPid:%s+(%d+)')
            if ppid ~= nil then
                if ptable[pair.user][ppid] == nil then
                    ptable[pair.user][ppid] = {}
                end
                table.insert(ptable[pair.user][ppid], pair.pid)
            end
        end

        -- remove all pids that have children with top level pids
        -- resulting in removing the parent pids of the unicorn masters
        for ppid, children in pairs(ptable[pair.user]) do
            for i = 1, #children do
                if ptable[pair.user][children[i]] ~= nil then
                    ptable[pair.user][ppid] = nil
                end
            end
        end
    end

    return ptable
end

