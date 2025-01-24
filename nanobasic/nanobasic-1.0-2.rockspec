package = "nanobasic"
version = "1.0-2"
source = {
    url = "git+https://github.com/joe7575/nanobasic.git"
}

description = {
    summary = "A small BASIC compiler with virtual machine for Luanti",
    detailed = [[
        tbd.
    ]],
    homepage = "https://github.com/joe7575/nanobasic",
    license = "MIT"
}

dependencies = {
   "lua == 5.1"
}

build = {
    type = "builtin",
    modules = {
        nanobasiclib = {
            sources = {
                "./src/nb_lua.c",
                "./src/nb_scanner.c",
                "./src/nb_compiler.c",
                "./src/nb_runtime.c",
                "./src/nb_memory.c"
            },
            defines = {"cfg_LINE_NUMBERS"}
        }
    }
}
