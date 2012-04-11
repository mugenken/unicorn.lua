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
unicorn:show()

unicorn:add_worker(4)
unicorn:show()

unicorn:remove_worker(4)
unicorn:show()

unicorn:reload()
unicorn:show()

unicorn:restart()
unicorn:show()

unicorn:stop()

