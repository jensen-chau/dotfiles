local dap = require('dap')
local dapui = require('dapui')

-- DAP UI 配置
dapui.setup({
  icons = { expanded = '▾', collapsed = '▸', current_frame = '▸' },
  mappings = {
    expand = { '<CR>', '<2-LeftMouse>' },
    open = 'o',
    remove = 'd',
    edit = 'e',
    repl = 'r',
    toggle = 't',
  },
  layouts = {
    {
      elements = {
        { id = 'scopes', size = 0.25 },
        { id = 'breakpoints', size = 0.25 },
        { id = 'stacks', size = 0.25 },
        { id = 'watches', size = 0.25 },
      },
      size = 40,
      position = 'left',
    },
    {
      elements = {
        { id = 'repl', size = 0.5 },
        { id = 'console', size = 0.5 },
      },
      size = 10,
      position = 'bottom',
    },
  },
})

-- Virtual Text 配置
require("nvim-dap-virtual-text").setup({
    enable = true,
    enabled_commands = true,
    highlight_changed_variables = true,
    highlight_new_as_changed = false,
    show_stop_reason = true,
    commented = false,
    only_first_definition = true,
    all_references = false,
    filter_references_pattern = '<module',
    error = { "virtual_text", "#ff0000" },
    rejected = { "virtual_text", "#c0c0c0" },
    stopped = { "virtual_text", "#ff0000" },
})

-- 自动打开/关闭 DAP UI
dap.listeners.after.event_initialized['dapui_config'] = function()
  dapui.open()
end
dap.listeners.before.event_terminated['dapui_config'] = function()
  dapui.close()
end
dap.listeners.before.event_exited['dapui_config'] = function()
  dapui.close()
end

-- 在断点处自动更新变量
dap.listeners.after.event_stopped['dapui_config'] = function()
  dapui.open({})
end

-- Codelldb 适配器（通过 Mason 安装）
dap.adapters.codelldb = {
  type = 'server',
  port = "${port}",
  executable = {
    command = vim.fn.exepath('codelldb'),
    args = { '--port', '${port}' },
  }
}

-- C/C++ 配置
dap.configurations.cpp = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
    -- 确保显示变量
    setupCommands = {
      {
        text = '-enable-pretty-printing',
        ignoreFailures = false,
      },
    },
  },
  {
    name = "Attach to process",
    type = "codelldb",
    request = "attach",
    pid = function()
      return require('dap.utils').pick_process()
    end,
    cwd = '${workspaceFolder}',
  },
}

-- C 配置（使用与 C++ 相同的配置）
dap.configurations.c = dap.configurations.cpp

-- Rust 配置
dap.configurations.rust = {
  {
    name = 'Launch file',
    type = 'codelldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    -- 确保显示变量
    setupCommands = {
      {
        text = '-enable-pretty-printing',
        ignoreFailures = false,
      },
    },
  },
}

-- 按键映射
local opts = { noremap = true, silent = true, desc = 'Debug: ' }
vim.keymap.set('n', '<F5>', dap.continue, vim.tbl_extend('force', opts, { desc = 'Start/Continue' }))
vim.keymap.set('n', '<F1>', dap.step_over, vim.tbl_extend('force', opts, { desc = 'Step Over' }))
vim.keymap.set('n', '<F2>', dap.step_into, vim.tbl_extend('force', opts, { desc = 'Step Into' }))
vim.keymap.set('n', '<F3>', dap.step_out, vim.tbl_extend('force', opts, { desc = 'Step Out' }))
vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, vim.tbl_extend('force', opts, { desc = 'Toggle Breakpoint' }))
vim.keymap.set('n', '<space>B', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, vim.tbl_extend('force', opts, { desc = 'Set Conditional Breakpoint' }))
vim.keymap.set('n', '<space>lp', function()
  dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
end, vim.tbl_extend('force', opts, { desc = 'Set Log Point' }))
vim.keymap.set('n', '<space>dr', dap.repl.open, vim.tbl_extend('force', opts, { desc = 'Open REPL' }))
vim.keymap.set('n', '<space>dl', dap.run_last, vim.tbl_extend('force', opts, { desc = 'Run Last' }))
vim.keymap.set('n', '<space>du', dapui.toggle, vim.tbl_extend('force', opts, { desc = 'Toggle UI' }))
