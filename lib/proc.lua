package.cpath = '../lib/?/?.so;' .. package.cpath
package.path = '../lib/?/?.lua;' .. package.path

require ('utils')

proc = {
    os = {},
    io = {},
}

function proc.command ()
    return 'ps fauxn | grep unicorn_rails | grep -v grep'
end

function proc.trim (line)
  return (line:gsub("^%s*(.-)%s*$", "%1"))
end

function proc.os.capture (cmd)
    local lines = {}
    local fh = assert(io.popen(cmd, 'r'))

    while true do
        line = fh:read('*line')
        if line == nil then
            break
        else
            table.insert(lines, proc.trim(line))
        end
    end

    fh:close()

    return lines
end

function proc.f_exists (f)
    local handler = io.open(f)
    if handler == nil then
        return false
    end
    io.close (handler)
    return true
end

function proc.get_users (lines)
    local users = {}
    for i, line in ipairs(lines) do
        for user,pid in line:gmatch("(%d+)%s+(%d+).*") do
            table.insert(users, {user = user, pid = pid})
        end
    end

    return users
end

function proc.check_pid_status (pid)
    local found = false
    local timeout = 10
    repeat
        if proc.f_exists('/proc/' .. pid .. '/status') then
            found = true
        end
        utils.usleep(1000)
        timeout = timeout - 1
    until found or timeout == 0

    return found
end

function proc.io.read_lines (file)
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
            table.insert(lines, proc.trim(line))
        end
    end

    fh:close()

    return lines
end

function proc.read_status_file (pid)
    local lines = proc.io.read_lines('/proc/' .. pid .. '/status')
    return lines
end

function proc.build_ptable (...)
    local users = ...
    if users == nil then
        users = proc.get_users(proc.os.capture(proc.command()))
    end
    local ptable = {}
    for i, pair in ipairs(users) do
        local content = proc.read_status_file(pair.pid)
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

return proc
