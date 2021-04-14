# nvim-echo-diagnostics

This plugin uses nvim-lspconfig, and provides functions to echo the entire message.

## Installation

### packer.nvim
```Lua
use 'seblj/nvim-echo-diagnostics'
use 'neovim/nvim-lspconfig'
```

### vim-plug
```Vim
call plug#begin()

Plug 'seblj/nvim-echo-diagnostics'
Plug 'neovim/nvim-lspconfig'

call plug#end()
```

## Setup
```Lua
require("echo-diagnostics").setup{
    show_diagnostic_number = true
}
```

## Usage
You can now utilize the functions to echo the entire message or a message that fits in the commandline based on `set cmdheight`

```Vim
" NOTE: You should consider setting updatetime to less than default.
" This could be set with `set updatetime=300`
" This will echo the diagnostics on CursorHold, and will also consider cmdheight
autocmd CursorHold * lua require('echo-diagnostics').echo_line_diagnostic()

" This will echo the entire diagnostic message. 
" Should prompt you with Press ENTER or type command to continue.

nnoremap <leader>cd <cmd>lua require("echo-diagnostics").echo_entire_diagnostic()<CR>
```
