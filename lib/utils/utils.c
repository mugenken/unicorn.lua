#include <stdlib.h>
#include <unistd.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <signal.h>
#include <sys/types.h>
#include <pwd.h>

static int lua_usleep (lua_State *L){
    int m = luaL_checknumber(L,1);
    usleep(m * 1000);

    return 0;
}

static int lua_kill (lua_State *L){
    int pid = (pid_t) luaL_checknumber(L, 1);
    int sig = (int) luaL_checknumber(L, 2);

    return kill (pid, sig);
}

static int lua_getuid (lua_State *L){
    const char * username = luaL_checkstring(L, 1);
    struct passwd *p = getpwnam(username);
    lua_pushinteger(L, (int) p->pw_uid);
    return 1;
}

static const struct luaL_Reg utils [] = {
    {"getuid", lua_getuid},
    {"usleep", lua_usleep},
    {"kill", lua_kill},
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

