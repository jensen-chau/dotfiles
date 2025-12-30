-- define common options
local opts = {
    noremap = true,      -- non-recursive
    silent = true,       -- do not show message
}

-----------------
-- Normal mode --
-----------------

-- Hint: see `:h vim.map.set()`
-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Resize with arrows
-- delta: 2 lines
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', opts)


-- nvim-tree keymap 
vim.keymap.set('n', '<C-m>', ':NvimTreeToggle<CR>', opts)

-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- bufferline
vim.keymap.set("n", "<A-h>", ":BufferLineCyclePrev<CR>", opt)
vim.keymap.set("n", "<A-l>", ":BufferLineCycleNext<CR>", opt)

vim.keymap.set("n", "<F7>", ":FloatermNew<CR>", opt)
vim.keymap.set("n", "<F8>", ":FloatermPrev<CR>", opt)
vim.keymap.set("n", "<F9>", ":FloatermNext<CR>", opt)
vim.keymap.set("n", "<F12>", ":FloatermToggle<CR>", opt)


