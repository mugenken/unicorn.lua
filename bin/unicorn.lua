#!/usr/bin/luajit-2

package.cpath = './lib/?/?.so;../lib/?/?.so;' .. package.cpath
package.path = './lib/?.lua;./lib/?/?.lua;../lib/?.lua;../lib/?/?.lua;' .. package.path

require ('cli')
require ('dumper')
require ('utils')

local unicorn = cli:new({
    username = 'mak',
})

unicorn:start()

print (DataDumper(unicorn.ptable))

unicorn:add_worker(4)
unicorn:refresh()

print (DataDumper(unicorn.ptable))

unicorn:remove_worker(4)
unicorn:refresh()

print (DataDumper(unicorn.ptable))

unicorn:reload()
utils.usleep(1000)
unicorn:refresh()

print (DataDumper(unicorn.ptable))

