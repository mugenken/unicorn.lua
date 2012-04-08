#!/usr/bin/luajit-2

package.cpath = './lib/?/?.so;../lib/?/?.so;' .. package.cpath
package.path = './lib/?.lua;./lib/?/?.lua;../lib/?.lua;../lib/?/?.lua;' .. package.path

require ('cli')
require ('dumper')
require ('utils')

local unicorn = cli:new({
    username = 'mak',
})

print (DataDumper(unicorn.ptable))

unicorn:reload()
utils.usleep(500)
unicorn:refresh()

print (DataDumper(unicorn.ptable))

