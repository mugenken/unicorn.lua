package.cpath = './lib/?/?.so;../lib/?/?.so;' .. package.cpath
package.path = './lib/?.lua;./lib/?/?.lua;../lib/?.lua;../lib/?/?.lua;' .. package.path

require ('proc')
require ('dumper')

local ptable = proc.build_ptable()

print (DataDumper(ptable))

