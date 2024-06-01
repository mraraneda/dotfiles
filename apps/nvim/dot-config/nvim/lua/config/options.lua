-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

opt.number = true -- Print line number
opt.relativenumber = true -- Relative line numbers
opt.title = true
opt.autoindent = true
opt.backup = false
opt.showcmd = true
opt.formatoptions:append({ "r" }) -- Add asterisks in block comments

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])
