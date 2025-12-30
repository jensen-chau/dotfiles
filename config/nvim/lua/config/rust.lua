-- 文件: ~/.config/nvim/lua/config/rust.lua

local function setup_rust()

  -- 配置 rust-tools
  local rt = require("rust-tools")
  
  local rust_analyzer_path = '/usr/bin/rust-analyzer'

  rt.setup({
    server = {
      cmd = { rust_analyzer_path },
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = {
            command = "clippy",
            extraArgs = { "--", "-D", "warnings" }
          },
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
          },
          procMacro = {
            enable = true
          },
          lens = {
            enable = true,
            run = { enable = true },
            debug = { enable = true },
            implementations = { enable = true },
            references = { enable = true },
          },
          diagnostics = {
            enable = true,
            experimental = { enable = true },
          },
        }
      },
      on_attach = function(client, bufnr)
        -- 设置快捷键
        local opts = { buffer = bufnr, remap = false }
        
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("n", "<leader>d", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
        vim.keymap.set("n", "<leader>q", function() vim.diagnostic.setloclist() end, opts)
        
        -- Rust 专用快捷键
        vim.keymap.set("n", "<leader>rr", rt.hover_actions.hover_actions, opts)
        vim.keymap.set("n", "<leader>ra", rt.code_action_group.code_action_group, opts)
      end,
    },
    tools = {
      -- rust-tools 配置
      inlay_hints = {
        auto = true,
        show_parameter_hints = true,
        parameter_hints_prefix = " ← ",
        other_hints_prefix = " → ",
      },
      hover_actions = {
        auto_focus = true,
      },
    },
    dap = {
      adapter = {
        type = "executable",
        command = "lldb-vscode",
        name = "rt_lldb",
      },
    },
  })
  
  -- 配置 DAP UI
  local dap = require('dap')
  local dapui = require('dapui')
  
  dapui.setup()
  dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated['dapui_config'] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited['dapui_config'] = function()
    dapui.close()
  end
  
  -- Rust 调试配置
  dap.configurations.rust = {
    {
      name = "Launch",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
    },
  }
  
  -- 设置调试快捷键
  vim.keymap.set('n', '<F5>', dap.continue)
  vim.keymap.set('n', '<F10>', dap.step_over)
  vim.keymap.set('n', '<F11>', dap.step_into)
  vim.keymap.set('n', '<F12>', dap.step_out)
  vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint)
  vim.keymap.set('n', '<leader>B', function()
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
  end)
end

return {
  setup = setup_rust
}
