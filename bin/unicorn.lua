package.cpath = './lib/?/?.so;../lib/?/?.so;' .. package.cpath
package.path = './lib/?.lua;./lib/?/?.lua;../lib/?.lua;../lib/?/?.lua;' .. package.path

require ('cli')
require ('dumper')

local unicorn = cli:new({
    username = 'mak',
})

