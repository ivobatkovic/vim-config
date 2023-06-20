nnoremap <SPACE> <Nop>
let mapleader="\<Space>"

syntax on
set number relativenumber
set noswapfile
set hlsearch
set ignorecase
set incsearch
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set noautochdir

" Copy to clipboard
vnoremap <leader>y "+y

" Source the current file quickly
nnoremap <silent> <leader>src :w<CR>:so %<CR>
nnoremap <silent> <leader>vimrc :e $MYVIMRC<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <silent> <leader>hl :let @/='\<'.expand('<cword>').'\>'\|set hlsearch<C-M>
vnoremap <silent> <leader>hl y:let @/='<C-R>"'\|set hlsearch<CR>
" Copy file path to clipboard
nnoremap <leader>c :let @+=expand('%')<CR>


" Plugins
call plug#begin('~/.local/share/nvim/site/plugged')

Plug 'voldikss/vim-floaterm'
Plug 'preservim/nerdtree'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'morhetz/gruvbox'
Plug 'preservim/nerdcommenter'
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'SirVer/ultisnips'
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
Plug 'kkoomen/vim-doge', { 'do': { -> doge#install() } }
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'
Plug 'rafamadriz/friendly-snippets'
Plug 'puremourning/vimspector'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'simeji/winresizer'

call plug#end()


colorscheme gruvbox
set background=dark

" Debug settings
nnoremap <leader>dd :call vimspector#Launch()<CR>
nnoremap <leader>dr :call vimspector#Reset()<CR>
nnoremap <leader>dc :call vimspector#Continue()<CR>

nnoremap <leader>db :call vimspector#ToggleBreakpoint()<CR>
nnoremap <buffer> <leader>df :call vimspector#AddFunctionBreakpoint(input("Function name: "))<CR>
nnoremap <leader>dB :call vimspector#ClearBreakpoints()<CR>


" NERDTree settings
let g:NERDTreeShowHidden=1
let g:NERDTreeChDirMode=0
nnoremap <leader><TAB> :NERDTreeToggle<CR>
nnoremap <leader>r :NERDTreeFind<CR>

" Floaterm
nnoremap <silent> <C-t> :FloatermToggle<CR>
tnoremap <silent> <C-t> <C-\><C-n>:FloatermToggle<CR>
"nnoremap <silent> <leader>tt :FloatermNew<CR>
"tnoremap <silent> <C-L> <C-\><C-n>:FloatermNext<CR>
"tnoremap <silent> <C-H> <C-\><C-n>:FloatermPrev<CR>
let g:floaterm_width = 0.8

" Airline
let g:airline_powerline_fonts = 1

" Telescope
nnoremap <leader>p :Telescope find_files<CR>
" Resizeer
let g:winresizer_start_key="<C-A-e>"

" Set grep to automatically open the new buffer with the matches
set grepprg=rg\ --vimgrep

function! Grep(...)
	return system(join([&grepprg] + [expandcmd(join(a:000, ' '))], ' '))
endfunction

command! -nargs=+ -complete=file_in_path -bar Grep  cgetexpr Grep(<f-args>)
command! -nargs=+ -complete=file_in_path -bar LGrep lgetexpr Grep(<f-args>)

cnoreabbrev <expr> grep  (getcmdtype() ==# ':' && getcmdline() ==# 'grep')  ? 'Grep'  : 'grep'
cnoreabbrev <expr> lgrep (getcmdtype() ==# ':' && getcmdline() ==# 'lgrep') ? 'LGrep' : 'lgrep'

augroup quickfix
	autocmd!
	autocmd QuickFixCmdPost cgetexpr cwindow
	autocmd QuickFixCmdPost lgetexpr lwindow
augroup END



" Shortcut to toggle the commenting with the nerdcommenter
map <C-_> <Plug>NERDCommenterToggle
let g:NERDDefaultAlign = 'left'

function! CloseBuffers(n_keep)
    let l:buffer_info = getbufinfo({'buflisted':1})
    eval l:buffer_info->sort({a, b -> b.lastused - a.lastused})
    for buffer in l:buffer_info[a:n_keep:]
        exec "bd" buffer.bufnr
    endfor
endfunction

nnoremap <silent> <leader>cb :<C-U>call CloseBuffers(v:count == 0 ? 10 : v:count)<CR>

"augroup clear_trailing_whitespace
"    au!
"    autocmd BufWritePre *\(\.md\)\@<! execute 'norm m`' | %s/\s\+$//eg | norm g``
"augroup END

function! ClangFormat() abort
    let l:src_root = trim(system('git rev-parse --show-toplevel'))
    if match(l:src_root, '.*/src$') == -1
        return
    endif
    if stridx(expand('%:p'), l:src_root) == 0
        :!clang-format -i -style=file %
    endif
endfunction

augroup clangformat
    au!
    if (executable('clang-format'))
        autocmd BufWritePost *.cpp,*.h,*.hpp :silent call ClangFormat()
    endif
augroup end

function! s:openInNormalWindow() abort
    const l:file = findfile(expand('<cfile>'))
    if !empty(l:file)
        FloatermHide
        execute 'e ' .. l:file
    endif
endfunction

function! s:openInNormalWindowGoToLine() abort
    const l:candidate_file = expand(expand('<cWORD>'))
    const [l:file_name, _, l:file_end] = matchstrpos(l:candidate_file, '\f\+')
    const l:file = findfile(l:file_name)
    if !empty(l:file)
        FloatermHide
        exec 'e ' .. l:file_name
    else
        return
    endif

    const [l:line_number, __, l:line_number_end] = matchstrpos(l:candidate_file, '\d\+', l:file_end + 1)

    if l:line_number == ''
        return
    endif

    const l:column_number = matchstr(l:candidate_file, '\d\+', l:line_number_end + 1)
    call cursor(l:line_number, l:column_number ? l:column_number : 0)
endfunction

augroup floaterm
    au!
    autocmd FileType floaterm nnoremap <silent> <buffer> gf :call <SID>openInNormalWindow()<CR>
    autocmd FileType floaterm nnoremap <buffer> <silent> gF :call <SID>openInNormalWindowGoToLine()<CR>
augroup END

"Language servers"
lua << EOF

local nvim_lsp = require('lspconfig')
local util = require('lspconfig/util')
local cmp = require('cmp')

cmp.setup({
    completion = {
        completeopt = 'menu,menuone,noinsert'
    },
    snippet = {
        expand = function(args)
        --vim.fn["vsnip#anonymous"](args.body)
        vim.fn["UltiSnips#Anon"](args.body)
    end,
    },
    mapping = {
        ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
        ['<M-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        ['<C-n>'] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end,
        ['<C-p>'] = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end,
        ['<TAB>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },
    sources = cmp.config.sources(
        {
            { name = 'nvim_lsp_signature_help' },
            { name = 'nvim_lsp' },
            { name = 'ultisnips' },
        },
        {
            { name = 'buffer' },
        }
    ),
    experimental = {
        ghost_text = true
    }
})

local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    local opts = { noremap=true, silent=true }

    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-Space>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('i', '<C-Space>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
end

local servers = {
    pyright = {
        settings = {
            python = {
                analysis = {
                    autoImportCompletions = "off",
                    typeCheckingMode = "off",
                    }
                }
            },
        root_dir = function(fname)
            local root_files = {
                'pyproject.toml',
                'setup.py',
                'setup.cfg',
                'requirements.txt',
                'Pipfile',
                'pyrightconfig.json',
                'venv',
                '.venv',
                }
            return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname) or util.path.dirname(fname)
        end
    },
    ccls = {
        init_options = {
            completion = {
                placeholder = false;
            }
        },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_dir = util.root_pattern(".git"),
        clang = {
            excludeArgs = { "-pedantic-errors" },
        },
    },
    gopls = {},
}

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

for server_name, configuration in pairs(servers) do
    configuration.on_attach = on_attach
    configuration.capabilities = capabilities
    nvim_lsp[server_name].setup(configuration)
end

EOF
