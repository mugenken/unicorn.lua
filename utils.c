/*
 * =====================================================================================
 *
 *       Filename:  utils.c
 *
 *    Description:  lua helper functions
 *
 *        Version:  1.0
 *        Created:  08.04.2012 12:42:57
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Mugen Kenichi
 *
 * =====================================================================================
 */

#include <stdlib.h>
#include <unistd.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

static int lua_usleep (lua_State *L){
    int m = luaL_checknumber(L,1);
    usleep(m * 1000);

    return 0;
}

static const struct luaL_Reg utils [] = {
    {"usleep", lua_usleep},
    {NULL, NULL}
};

int luaopen_utils (lua_State *L){
    luaL_register(L, "utils", utils);
    return 1;
}

int main(int argc, const char *argv[])
{
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    luaopen_utils(L);
    return 0;
}

