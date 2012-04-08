/* lua */
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <pwd.h>
#include <errno.h>
#include <string.h>

static int result(lua_State * L, int i, const char *message) {
    if (i == -1) {
        lua_pushnil(L);

        if (message == NULL) {
            lua_pushstring(L, strerror(errno));
        } else {
            lua_pushfstring(L, "%s => %s", message, strerror(errno));
        }

        lua_pushinteger(L, errno);

        return 3;
    }

    lua_pushinteger(L, i);

    return 1;
}

static int lua_usleep(lua_State * L) {
    int m = luaL_checknumber(L, 1);

    return result(L, usleep(m * 1000), NULL);
}

static int lua_kill(lua_State * L) {
    int pid = (pid_t) luaL_checknumber(L, 1);
    int sig = (int) luaL_checknumber(L, 2);

    return result(L, kill(pid, sig), NULL);
}

static int lua_fork(lua_State * L) {
    return result(L, fork(), NULL);
}

static int lua_getuid(lua_State * L) {
    const char *username = luaL_checkstring(L, 1);
    struct passwd *p = getpwnam(username);
    return result(L, p == NULL ? -1 : (int) p->pw_uid, NULL);
}

static const struct luaL_Reg utils[] = {
    {"getuid", lua_getuid},
    {"usleep", lua_usleep},
    {"kill", lua_kill},
    {"fork", lua_fork},
    {NULL, NULL}
};

int luaopen_utils(lua_State * L) {
    luaL_register(L, "utils", utils);
    return 1;
}

int main(int argc, const char *argv[]) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    luaopen_utils(L);

    return 0;
}
