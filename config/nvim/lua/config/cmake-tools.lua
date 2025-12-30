require("cmake-tools").setup({
    cmake_regenerate_on_save = true,
    cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
    cmake_compile_commands_options = {
        action = "soft_link",
        target = vim.loop.cwd()
    },
})
