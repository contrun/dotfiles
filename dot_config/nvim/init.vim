if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
    silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')
" Make sure you use single quotes

" Plug 'autozimu/LanguageClient-neovim', {
"             \ 'branch': 'next',
"             \ 'do': 'bash install.sh',
"             \ }
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'blindFS/vim-taskwarrior'
Plug 'tpope/vim-surround'
" Plug 'cohama/lexima'
Plug 'farmergreg/vim-lastplace'
" Plug 'ajh17/VimCompletesMe'
Plug 'christoomey/vim-sort-motion'
Plug 'FooSoft/vim-argwrap'
Plug 'tommcdo/vim-exchange'
Plug 'AndrewRadev/sideways.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'editorconfig/editorconfig-vim'
Plug 'machakann/vim-swap'
Plug 'mhinz/vim-signify'
" Plug 'ervandew/supertab'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-repeat'
Plug 'majutsushi/tagbar'
Plug 'wolfgangmehner/lua-support'
Plug 'idris-hackers/idris-vim'
" Plug 'airblade/vim-gitgutter'
Plug 'ryvnf/readline.vim'
" Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'godoctor/godoctor.vim'
Plug 'sebdah/vim-delve'
" Plug 'ludovicchabant/vim-gutentags'
" Plug 'skywind3000/gutentags_plus'
Plug 'skywind3000/asyncrun.vim'
Plug 'tpope/vim-dispatch'
" Plug 'scrooloose/syntastic'
Plug 'plasticboy/vim-markdown'
" Plug 'ctrlpvim/ctrlp.vim'
" Plug 'vim-ctrlspace/vim-ctrlspace'
Plug 'vim-scripts/bufexplorer.zip'
Plug 'vim-scripts/bash-support.vim'
Plug 'mileszs/ack.vim'
Plug 'junegunn/vim-github-dashboard'
Plug 'michaeljsmith/vim-indent-object'
Plug 'cespare/vim-toml'
Plug 'vim-pandoc/vim-pandoc'
" Plug 'jmcantrell/vim-virtualenv'
" Plug 'hynek/vim-python-pep8-indent'
Plug 'vim-scripts/grep.vim'
Plug 'junegunn/goyo.vim'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'lervag/vimtex'
Plug 'shougo/neomru.vim'
" Plug 'parsonsmatt/intero-neovim'
" Plug 'shougo/neoyank.vim'
Plug 'Shougo/denite.nvim'
" Plug 'python-mode/python-mode', {'branch': 'develop'}
Plug 'Chiel92/vim-autoformat'
Plug 'elixir-lang/vim-elixir'
Plug 'benmills/vimux'
" Plug 'Valloric/YouCompleteMe'
Plug 'davidhalter/jedi-vim'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-fugitive'
" Plug 'rking/ag.vim'
Plug 'dyng/ctrlsf.vim'
Plug 'plasticboy/vim-markdown'
Plug 'mileszs/ack.vim'
Plug 'MarcWeber/vim-addon-mw-utils'
" Plug 'tomtom/tlib_vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'fszymanski/fzf-gitignore', {'do': ':UpdateRemotePlugins'}
Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-commentary'
" Plug 'maralla/completor.vim'
Plug 'tpope/vim-repeat'
Plug 'mattn/emmet-vim'
Plug 'wincent/command-t'
Plug 'jeetsukumaran/vim-pythonsense'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'w0rp/ale'
Plug 'terryma/vim-expand-region'
Plug 'terryma/vim-multiple-cursors'
" Plug 'maxbrunsfeld/vim-yankstack'
Plug 'tpope/vim-fugitive'
Plug 'amix/open_file_under_cursor.vim'
" Plug 'ambv/black'
" Plug 'garbas/vim-snipmate'
" Plug 'SirVer/ultisnips'
" Plug 'honza/vim-snippets'
" Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
" Plug 'vim-scripts/mru.vim'
Plug 'amix/vim-zenroom2'
Plug 'wellle/targets.vim'
Plug 'jodosha/vim-godebug'
Plug 'AndrewRadev/splitjoin.vim'
" Plug 'ensime/ensime-vim', { 'do': ':UpdateRemotePlugins' }
" Plug 'roxma/vim-scala'
Plug 'cloudhead/neovim-fuzzy'
Plug 'tmhedberg/SimpylFold'
Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim'
" Plug 'neomake/neomake'

" themes
" Plug 'itchyny/lightline.vim'
" Plug 'chriskempson/base16-vim'
" Plug 'daviesjamie/vim-base16-lightline'
" Plug 'kyuhi/vim-emoji-complete'
" Plug 'mhartington/oceanic-next'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ajmwagar/vim-deus'
Plug 'AlessandroYorba/Alduin'
Plug 'AlessandroYorba/Sierra'
Plug 'andreasvc/vim-256noir'
Plug 'arcticicestudio/nord-vim'
Plug 'Badacadabra/vim-archery'
Plug 'challenger-deep-theme/vim'
Plug 'chase/focuspoint-vim'
Plug 'christophermca/meta5'
Plug 'cocopon/iceberg.vim'
Plug 'cseelus/vim-colors-lucid'
Plug 'danilo-augusto/vim-afterglow'
Plug 'dikiaap/minimalist'
Plug 'endel/vim-github-colorscheme'
Plug 'fcpg/vim-orbital'
Plug 'fmoralesc/molokayo'
Plug 'gilgigilgil/anderson.vim'
Plug 'gregsexton/Atom'
Plug 'jacoborus/tender.vim'
Plug 'jdsimcoe/abstract.vim'
" Plug 'jonathanfilip/vim-lucius'
Plug 'joshdick/onedark.vim'
Plug 'junegunn/seoul256.vim'
" Plug 'keith/parsec.vim'
Plug 'kristijanhusak/vim-hybrid-material'
" Plug 'lifepillar/vim-solarized8'
Plug 'liuchengxu/space-vim-dark'
Plug 'marcopaganini/termschool-vim-theme'
" Plug 'mkarmona/colorsbox'
Plug 'mkarmona/materialbox'
Plug 'morhetz/gruvbox'
" Plug 'mswift42/vim-themes'
Plug 'nanotech/jellybeans.vim'
" Plug 'nightsense/carbonized'
" Plug 'nightsense/vimspectr'
" Plug 'NLKNguyen/papercolor-theme'
Plug 'owickstrom/vim-colors-paramount'
" Plug 'rakr/vim-colors-rakr'
" Plug 'rakr/vim-one'
" Plug 'rakr/vim-two-firewatch'
Plug 'romainl/Apprentice'
" Plug 'romainl/flattened'
Plug 'scheakur/vim-scheakur'
Plug 'sts10/vim-pink-moon'
Plug 'tomasr/molokai'
Plug 'tyrannicaltoucan/vim-deep-space'
Plug 'vim-scripts/pyte'
Plug 'vim-scripts/rdark-terminal2.vim'
Plug 'vim-scripts/twilight256.vim'
Plug 'vim-scripts/wombat256.vim'
Plug 'w0ng/vim-hybrid'
Plug 'whatyouhide/vim-gotham'
Plug 'wimstefan/Lightning'
Plug 'yorickpeterse/happy_hacking.vim'
Plug 'zacanger/angr.vim'
" Plug 'reedes/vim-thematic'
" Plug 'nightsense/snow'
" Plug 'xolox/vim-colorscheme-switcher'
" Plug 'zefei/vim-wintabs'
" Plug 'zefei/vim-wintabs-powerline'

" Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}

Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-tmux'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-tern'
Plug 'ncm2/ncm2-go'
" Plug 'ncm2/ncm2-ultisnips'
Plug 'ncm2/ncm2-vim'
Plug 'ncm2/ncm2-match-highlight'
" Plug 'mhartington/nvim-typescript'
" Plug 'ncm2/ncm2-pyclang'
Plug 'ncm2/ncm2-tern'
Plug 'ncm2/ncm2-cssomni'
Plug 'ncm2/ncm2-tmux'
Plug 'ncm2/ncm2-jedi'
" Plug 'ncm2/ncm2-racer'
Plug 'fgrsnau/ncm2-otherbuf'
" Plug 'fgrsnau/ncm2-aspell'
" if has('nvim')
"     Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" else
"     Plug 'Shougo/deoplete.nvim'
"     Plug 'roxma/nvim-yarp'
"     Plug 'roxma/vim-hug-neovim-rpc'
" endif
Plug 'Shougo/neco-syntax'
Plug 'Shougo/neco-vim'
" Plug 'zchee/deoplete-zsh'
" Plug 'lionawurscht/deoplete-biblatex'
Plug 'honza/vim-snippets'
Plug 'ternjs/tern_for_vim', { 'for': ['javascript', 'javascript.jsx'] }
" Plug 'carlitux/deoplete-ternjs', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'othree/jspc.vim', { 'for': ['javascript', 'javascript.jsx'] }
" Plug 'thalesmello/webcomplete.vim'
Plug 'wellle/tmux-complete.vim'
" Plug 'carlitux/deoplete-ternjs'
" Plug 'zchee/deoplete-jedi'
" Plug 'racer-rust/vim-racer'
Plug 'eagletmt/neco-ghc'
" Plug 'zchee/deoplete-go', { 'do': 'make'}
" Plug 'JBakamovic/yavide', { 'do': 'install.sh'}
" Plug 'zchee/deoplete-clang'
Plug 'slashmili/alchemist.vim'
" Plug 'pbogut/deoplete-elm'
Plug 'bfrg/vim-cpp-modern'
Plug 'octol/vim-cpp-enhanced-highlight'

call plug#end()

function! UpdateVimPlug() abort
  " Run PlugUpdate every week automatically when entering Vim.
  if exists('g:plug_home')
    let l:filename = printf('%s/.vim_plug_update', g:plug_home)
    if filereadable(l:filename) == 0
      call writefile([], l:filename)
    endif

    let l:this_week = strftime('%Y_%V')
    let l:contents = readfile(l:filename)
    if index(l:contents, l:this_week) < 0
      call execute('PlugUpdate')
      call writefile([l:this_week], l:filename, 'a')
    endif
  endif
endfunction

" autocmd VimEnter * call UpdateVimPlug()

"#### vim-gutentags
" let g:gutentags_project_root = ['.gosrcroot']
" let g:gutentags_ctags_tagfile = '.tags'

" let s:vim_tags = expand('~/.cache/tags')
" let g:gutentags_cache_dir = s:vim_tags
" if !isdirectory(s:vim_tags)
"     silent! call mkdir(s:vim_tags, 'p')
" endif
" set tags=./.tags;,.tags

" " enable gtags module
" let g:gutentags_modules = ['ctags', 'gtags_cscope']

" " config project root markers.
" let g:gutentags_project_root = ['.root']

" " generate datebases in my cache directory, prevent gtags files polluting my project
" let g:gutentags_cache_dir = expand('~/.cache/tags')

" " forbid gutentags adding gtags databases
" let g:gutentags_auto_add_gtags_cscope = 0

" let g:gutentags_ctags_executable = system('which ctags')


" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()
" IMPORTANT: :help Ncm2PopupOpen for more information
let g:ncm2#match_highlight = 'bold'
let g:ncm2#match_highlight = 'sans-serif'
let g:ncm2#match_highlight = 'sans-serif-bold'
let g:ncm2#match_highlight = 'mono-space'

let g:ncm2#match_highlight = 'double-struck'
autocmd BufEnter * call ncm2#enable_for_buffer()
set completeopt=noinsert,menuone,noselect,preview
au User Ncm2PopupOpen set completeopt=noinsert,menuone,noselect,preview
au User Ncm2PopupClose set completeopt=menuone

" suppress the annoying 'match x of y', 'The only match' and 'Pattern not
" found' messages
set shortmess+=c

" CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
inoremap <c-c> <ESC>

" When the <Enter> key is pressed while the popup menu is visible, it only
" hides the menu. Use this mapping to close the menu and also start a new
" line.
" inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

" Use <TAB> to select the popup menu:
" inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" wrap existing omnifunc
" Note that omnifunc does not run in background and may probably block the
" editor. If you don't want to be blocked by omnifunc too often, you could
" add 180ms delay before the omni wrapper:
"  'on_complete': ['ncm2#on_complete#delay', 180,
"               \ 'ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
au User Ncm2Plugin call ncm2#register_source({
        \ 'name' : 'css',
        \ 'priority': 9,
        \ 'subscope_enable': 1,
        \ 'scope': ['css','scss'],
        \ 'mark': 'css',
        \ 'word_pattern': '[\w\-]+',
        \ 'complete_pattern': ':\s*',
        \ 'on_complete': ['ncm2#on_complete#delay', 180,
        \                 'ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
        \ })
" let g:deoplete#enable_at_startup = 1
" let g:deoplete#sources={}
" let g:deoplete#sources._=['buffer', 'member', 'tag', 'file', 'omni', 'ultisnips', 'dictionary', 'neco-syntax']
" let g:deoplete#omni#input_patterns={}
" let g:deoplete#omni#input_patterns.scala='[^. *\t]\.\w*'

" call deoplete#custom#option('num_processes', 1)
" let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']
" let g:deoplete#sources#go#package_dot = 1
" let g:deoplete#sources#go#pointer = 1
" let g:deoplete#sources#go#cgo =  1
" let g:deoplete#sources#go#auto_goos = 1

" if !exists('g:deoplete#omni#input_patterns')
    " let g:deoplete#omni#input_patterns = {}
" endif
" let g:deoplete#omni#input_patterns.tex = g:vimtex#re#deoplete

" let g:python_host_prog = system('which python2')
" let g:python3_host_prog = system('which python3')
" let g:python3_host_skip_check = 1

"Linting with neomake
" let g:neomake_sbt_maker = {
"       \ 'exe': 'sbt',
"       \ 'args': ['-Dsbt.log.noformat=true', 'compile'],
"       \ 'append_file': 0,
"       \ 'auto_enabled': 1,
"       \ 'output_stream': 'stdout',
"       \ 'errorformat':
"           \ '%E[%trror]\ %f:%l:\ %m,' .
"             \ '%-Z[error]\ %p^,' .
"             \ '%-C%.%#,' .
"             \ '%-G%.%#'
"      \ }

" let g:neomake_enabled_makers = ['sbt']
" let g:neomake_verbose=3

" Neomake on text change
" autocmd InsertLeave,TextChanged * update | Neomake! sbt

""""""""""""""""""""""
"      Settings      "
""""""""""""""""""""""

filetype indent on
set title
set titlestring=%{v:servername}\ -\ %t\ %m\ (%{expand('%:p:h')})
set whichwrap+=<,>,h,l,[,]
set expandtab
set shiftwidth=4
set softtabstop=4
set ttimeoutlen=50
set autoindent
set smartindent
set wildmode=longest,list,full
set wrap
set linebreak
set nolist                     " list disables linebreak
set showbreak=…
set encoding=utf-8              " Set default encoding to UTF-8
set fileencodings=utf-8,ucs-bom,gbk,gb2312,gb18030,default
set formatoptions+=tcroqw       "
set splitright                  " Split vertical windows right to the current windows
set splitbelow                  " Split horizontal windows below to the current windows

command! -nargs=* Wrap set wrap linebreak nolist
map <leader>sa ggvG$
vmap <D-j> gj
vmap <D-k> gk
vmap <D-4> g$
vmap <D-6> g^
vmap <D-0> g^
nmap <D-j> gj
nmap <D-k> gk
nmap <D-4> g$
nmap <D-6> g^
nmap <D-0> g^
if has("gui_running")
    set antialias
    set guicursor+=a:blinkon0  " disable cursor blink
    set guioptions-=r          " kill right scrollbar
    set guioptions-=l          " kill left scrollbar
    set guioptions-=L          " kill left scrollbar multiple buffers
    set guioptions-=T          " kill toolbar
    set fuoptions=maxvert,maxhorz
    au GUIEnter * set fullscreen
endif
set nocompatible               " Enables us Vim specific features
filetype off                   " Reset filetype detection first ...
filetype plugin indent on      " ... and enable filetype detection
set ttyfast                    " Indicate fast terminal conn for faster redraw
" set ttymouse=xterm2             " Indicate terminal type for mouse codes
" set ttyscroll=3                 " Speedup scrolling
set laststatus=2               " Show status line always
set autoread                   " Automatically read changed files
" Triger `autoread` when files changes on disk
" https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
" https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
" Notification after file change
" https://vi.stackexchange.com/questions/13091/autocmd-event-for-autoread
autocmd FileChangedShellPost *
            \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None
set backspace=indent,eol,start " Makes backspace key more powerful.
set incsearch                  " Shows the match while typing
set hlsearch                   " Highlight found searches
set nofoldenable               " disable folding
" Enable folding
set foldmethod=indent
set foldlevel=99
set noerrorbells               " No beeps
" set number                    " Show line numbers
set number
set relativenumber
set showcmd                    " Show me what I'm typing
set noswapfile                 " Don't use swapfile
set nobackup                   " Don't create annoying backup files
set splitright                 " Vertical windows should be split to right
set splitbelow                 " Horizontal windows should split to bottom
set autowrite                  " Automatically save before :next, :make etc.
set hidden                     " Buffer should still exist if window is closed
set fileformats=unix,dos,mac   " Prefer Unix over Windows over OS 9 formats
set noshowmatch                " Do not show matching brackets by flickering
set noshowmode                 " We show the mode with airline or lightline
set ignorecase                 " Search case insensitive...
set smartcase                  " ... but not it begins with upper case
" set completeopt=menu,menuone   " Show popup menu, even if there is one entry
set pumheight=10               " Completion window max size
set nocursorcolumn             " Do not highlight column (speeds up highlighting)
set nocursorline               " Do not highlight cursor (speeds up highlighting)
set lazyredraw                 " Wait to redraw
set splitbelow
set splitright
set omnifunc=syntaxcomplete#Complete
set background=dark
set mouse=a
" colorscheme snow

" Enable to copy to clipboard for operations like yank, delete, change and put
" http://stackoverflow.com/questions/20186975/vim-mac-how-to-copy-to-clipboard-without-pbcopy
if has('unnamedplus')
    set clipboard^=unnamed
    set clipboard^=unnamedplus
endif

" This enables us to undo files even if you exit Vim.
if has('persistent_undo')
    set undofile
    set undodir=~/Ftemp/vim/undo//
endif

" Colorscheme
syntax enable
set t_Co=256
" let g:rehash256 = 1
" let g:molokai_original = 1
" colorscheme molokai

""""""""""""""""""""""
"      Mappings      "
""""""""""""""""""""""

" vim/nvim compatible alt key binding
" https://github.com/neovim/neovim/issues/5576
if has('nvim')
    " map <A-n> :bnext<CR>
    function! s:alt_key(key)
        return "<A-". a:key . ">"
    endfun
else
    " map <Esc>n :bnext<CR>
    function! s:alt_key(key)
        return "<Esc>". a:key
    endfun
endif

function! s:amap_alt(key, action)
    exec "noremap " . s:alt_key(a:key). " " a:action
    exec "inoremap " . s:alt_key(a:key). " <Esc>" a:action."<Up>"
endfun

function! s:map_alt(key, action)
    exec "map " . s:alt_key(a:key). " " a:action
endfun

function! s:imap_alt(key, action)
    exec "imap " . s:alt_key(a:key). " " a:action
endfun


" call s:map_alt("n", ":bnext<CR>")
" call s:map_alt("n", ":bnext<CR>")
" call s:map_alt("p", ":bprevious<CR>")
" call s:map_alt("l", ":ls<CR>")
call s:map_alt("1", ":buffer 1<CR>")
call s:map_alt("2", ":buffer 2<CR>")
call s:map_alt("3", ":buffer 3<CR>")
call s:map_alt("4", ":buffer 4<CR>")
call s:map_alt("5", ":buffer 5<CR>")
call s:map_alt("6", ":buffer 6<CR>")
call s:map_alt("7", ":buffer 7<CR>")
call s:map_alt("8", ":buffer 8<CR>")
call s:map_alt("9", ":buffer 9<CR>")
call s:map_alt("0", ":buffer 10<CR>")
call s:map_alt("u", ":bunload<CR>")
call s:map_alt("e", ":e <C-d>")
call s:amap_alt(",", ":bnext<CR>")
call s:amap_alt(".", ":bprevious<CR>")
call s:amap_alt("/", ":ALEFixSuggest<CR>")
call s:amap_alt("[", ":ALENextWrap<CR>")
call s:amap_alt("]", ":ALEPreviousWrap<CR>")
call s:amap_alt("t", ":TagbarToggle<CR><C-w><C-w>")
" call s:amap_alt("h", "<C-w><C-h>")
" call s:amap_alt("j", "<C-w><C-j>")
" call s:amap_alt("k", "<C-w><C-k>")
" call s:amap_alt("l", "<C-w><C-l>")
call s:amap_alt("z", "<C-w><C-q>")
call s:amap_alt("m", ":only<CR>")
call s:amap_alt("d", "<C-w><C-w>")
call s:amap_alt("c", ":bd<CR>")
call s:amap_alt("q", "<C-w><C-o>")
call s:amap_alt("<Tab>", "<C-w><C-w>")
call s:amap_alt("s", ":split<CR>")
call s:amap_alt("v", ":vsplit<CR>")
" call s:amap_alt("x", ":CtrlP<CR>")
call s:amap_alt("T", ":RandomColorScheme<CR>")
call s:amap_alt("F", ":ToggleAutoformat<CR>")
call s:amap_alt("r", ":Rg<CR>")
call s:amap_alt("R", ":Ranger<CR>")
" call s:amap_alt("r", ":<C-u>Denite -resume -refresh<CR>")
call s:amap_alt("b", ":<C-u>Denite buffer file/rec file_mru<CR>")
" call s:amap_alt("f", ":<C-u>Denite file/rec:~/<CR>")
call s:amap_alt("f", ":DeniteProjectDir -buffer-name=git file/rec/git<CR>")
call s:amap_alt("x", ":<C-u>Denite command_history command<CR>")
call s:amap_alt("g", ":<C-u>DeniteCursorWord -default-action=tabopen -mode=normal grep:.<CR>")
" call s:amap_alt("y", ":<C-u>Denite -default-action=append -mode=normal neoyank<CR>")
" call s:amap_alt("a", ":<C-u>DeniteProjectDir -default-action=tabopen file/rec<CR>")
call s:amap_alt("a", ":DeniteProjectDir -buffer-name=grep grep:::<CR>")
call s:amap_alt("w", ":w<CR>")
call s:amap_alt("W", ":w!<CR>")
call s:amap_alt(";", ":Commentary<CR>")

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['eslint'],
\   'shell': ['shellcheck'],
\}

" Set leader shortcut to a comma 'space'. By default it's the backslash
map <Space> <localleader>
map "," <leader>
" noremap "," <leader>
" nnoremap <SPACE> <Nop>
" let mapleader = ","
" let maplocalleader = "\<Space>"

nnor <leader>cf :let @*=expand("%:p")<CR>    " Mnemonic: Copy File path
nnor <leader>yf :let @"=expand("%:p")<CR>    " Mnemonic: Yank File path
nnor <leader>fn :let @"=expand("%")<CR>      " Mnemonic: yank File Name


" Visual linewise up and down by default (and use gj gk to go quicker)
noremap <Up> gk
noremap <Down> gj
noremap j gj
noremap k gk

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv

" Act like D and C
nnoremap Y y$

" quickfix

map <leader>j :cnext<CR>
map <leader>k :cprevious<CR>
nnoremap <leader>c :cclose<CR>

" Enter automatically into the files directory
autocmd BufEnter * silent! lcd %:p:h


"""""""""""""""""""""
"      Plugins      "
"""""""""""""""""""""

" ctrlp {{{
" let g:ctrlp_map = '<M-x>'
" let g:ctrlp_cmd = 'CtrlP'
" let g:ctrlp_working_path_mode = 'ra'
" set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " Linux/MacOSX
" set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe  " Windows
" let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
" let g:ctrlp_custom_ignore = {
"   \ 'dir':  '\v[\/]\.(git|hg|svn)$',
"   \ 'file': '\v\.(exe|so|dll)$',
"   \ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
"   \ }
" let g:ctrlp_user_command = {
"   \ 'types': {
"       \ 1: ['.git', 'cd %s && git ls-files'],
"       \ 2: ['.hg', 'hg --cwd %s locate -I .'],
"       \ },
"   \ 'fallback': 'find %s -type f'
"   \ }
" }}}

" Denite options
" Define mappings
autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> d
  \ denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p
  \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> q
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> i
  \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <Space>
  \ denite#do_map('toggle_select').'j'
endfunction

autocmd FileType denite-filter call s:denite_filter_my_settings()
function! s:denite_filter_my_settings() abort
  imap <silent><buffer> <C-o> <Plug>(denite_filter_quit)
endfunction

" Change file/rec command.
call denite#custom#var('file/rec', 'command',
\ ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])
" " For ripgrep
" " Note: It is slower than ag
" call denite#custom#var('file/rec', 'command',
" \ ['rg', '--files', '--glob', '!.git'])
" " For Pt(the platinum searcher)
" " NOTE: It also supports windows.
" call denite#custom#var('file/rec', 'command',
" \ ['pt', '--follow', '--nocolor', '--nogroup',
" \  (has('win32') ? '-g:' : '-g='), ''])
" " For python script scantree.py
" " Read bellow on this file to learn more about scantree.py
" call denite#custom#var('file/rec', 'command', ['scantree.py'])

" Change matchers.
call denite#custom#source(
\ 'file_mru', 'matchers', ['matcher/fuzzy', 'matcher/project_files'])
" call denite#custom#source(
" \ 'file/rec', 'matchers', ['matcher/cpsm'])

" Change sorters.
call denite#custom#source(
\ 'file/rec', 'sorters', ['sorter/sublime'])

" Change default action.
call denite#custom#kind('file', 'default_action', 'open')

" Add custom menus
let s:menus = {}

let s:menus.zsh = {
        \ 'description': 'Edit your import zsh configuration'
        \ }
let s:menus.zsh.file_candidates = [
        \ ['zshrc', '~/.config/zsh/.zshrc'],
        \ ['zshenv', '~/.zshenv'],
        \ ]

let s:menus.my_commands = {
        \ 'description': 'Example commands'
        \ }
let s:menus.my_commands.command_candidates = [
        \ ['Split the window', 'vnew'],
        \ ['Open zsh menu', 'Denite menu:zsh'],
        \ ['Format code', 'FormatCode', 'go,python'],
        \ ]

call denite#custom#var('menu', 'menus', s:menus)

" Ag command on grep source
call denite#custom#var('grep', 'command', ['ag'])
call denite#custom#var('grep', 'default_opts',
                \ ['-i', '--vimgrep'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', [])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

" Ack command on grep source
call denite#custom#var('grep', 'command', ['ack'])
call denite#custom#var('grep', 'default_opts',
                \ ['--ackrc', $HOME.'/.ackrc', '-H', '-i',
                \  '--nopager', '--nocolor', '--nogroup', '--column'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', ['--match'])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

" " Ripgrep command on grep source
" call denite#custom#var('grep', 'command', ['rg'])
" call denite#custom#var('grep', 'default_opts',
"               \ ['-i', '--vimgrep', '--no-heading'])
" call denite#custom#var('grep', 'recursive_opts', [])
" call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
" call denite#custom#var('grep', 'separator', ['--'])
" call denite#custom#var('grep', 'final_opts', [])

" " Pt command on grep source
" call denite#custom#var('grep', 'command', ['pt'])
" call denite#custom#var('grep', 'default_opts',
"               \ ['-i', '--nogroup', '--nocolor', '--smart-case'])
" call denite#custom#var('grep', 'recursive_opts', [])
" call denite#custom#var('grep', 'pattern_opt', [])
" call denite#custom#var('grep', 'separator', ['--'])
" call denite#custom#var('grep', 'final_opts', [])

" " jvgrep command on grep source
" call denite#custom#var('grep', 'command', ['jvgrep'])
" call denite#custom#var('grep', 'default_opts', ['-i'])
" call denite#custom#var('grep', 'recursive_opts', ['-R'])
" call denite#custom#var('grep', 'pattern_opt', [])
" call denite#custom#var('grep', 'separator', [])
" call denite#custom#var('grep', 'final_opts', [])

" Specify multiple paths in grep source
"call denite#start([{'name': 'grep',
"      \ 'args': [['a.vim', 'b.vim'], '', 'pattern']}])

" Define alias
call denite#custom#alias('source', 'file/rec/git', 'file/rec')
call denite#custom#var('file/rec/git', 'command',
      \ ['git', 'ls-files', '-co', '--exclude-standard'])

call denite#custom#alias('source', 'file/rec/py', 'file/rec')
call denite#custom#var('file/rec/py', 'command',['scantree.py'])

" Change ignore_globs
call denite#custom#filter('matcher/ignore_globs', 'ignore_globs',
      \ [ '.git/', '.ropeproject/', '__pycache__/',
      \   'venv/', 'images/', '*.min.*', 'img/', 'fonts/'])

" Custom action
" Note: lambda function is not supported in Vim8.
call denite#custom#action('file', 'test',
      \ {context -> execute('let g:foo = 1')})
call denite#custom#action('file', 'test2',
      \ {context -> denite#do_action(
      \  context, 'open', context['targets'])})
call denite#custom#option('_', {
            \ 'prompt': '❯',
            \ 'empty': 0,
            \ 'winheight': 16,
            \ 'short_source_names': 1,
            \ 'vertical_preview': 1,
            \ 'direction': 'dynamicbottom',
            \ })

" let insert_mode_mappings = [
"             \  ['jj', '<denite:enter_mode:normal>', 'noremap'],
"             \  ['qq', '<denite:quit>', 'noremap'],
"             \  ['<Esc>', '<denite:enter_mode:normal>', 'noremap'],
"             \  ['<C-N>', '<denite:assign_next_matched_text>', 'noremap'],
"             \  ['<C-P>', '<denite:assign_previous_matched_text>', 'noremap'],
"             \  ['<C-Y>', '<denite:redraw>', 'noremap'],
"             \  ['<C-J>', '<denite:move_to_next_line>', 'noremap'],
"             \  ['<C-K>', '<denite:move_to_previous_line>', 'noremap'],
"             \  ['<C-G>', '<denite:insert_digraph>', 'noremap'],
"             \  ['<C-T>', '<denite:input_command_line>', 'noremap'],
"             \ ]

" let normal_mode_mappings = [
"             \   ["'", '<denite:toggle_select_down>', 'noremap'],
"             \   ['<C-n>', '<denite:jump_to_next_source>', 'noremap'],
"             \   ['<C-p>', '<denite:jump_to_previous_source>', 'noremap'],
"             \   ['v', '<denite:do_action:vsplit>', 'noremap'],
"             \   ['s', '<denite:do_action:split>', 'noremap'],
"             \ ]

" for m in insert_mode_mappings
"     call denite#custom#map('insert', m[0], m[1], m[2])
" endfor
" for m in normal_mode_mappings
"     call denite#custom#map('normal', m[0], m[1], m[2])
" endfor

" " -u flag to unrestrict (see ag docs)
" call denite#custom#var('file/rec', 'command',
"             \ ['ag', '--follow', '--nocolor', '--nogroup', '-u', '-g', ''])

" call denite#custom#alias('source', 'file/rec/git', 'file/rec')
" call denite#custom#var('file/rec/git', 'command',
"             \ ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])

" call denite#custom#source(
"             \ 'grep', 'matchers', ['matcher_regexp'])

" " use ag for content search
" call denite#custom#var('grep', 'command', ['ag'])
" call denite#custom#var('grep', 'default_opts',
"             \ ['-i', '--vimgrep'])
" call denite#custom#var('grep', 'recursive_opts', [])
" call denite#custom#var('grep', 'pattern_opt', [])
" call denite#custom#var('grep', 'separator', ['--'])
" call denite#custom#var('grep', 'final_opts', [])

" tagbar
let g:tagbar_ctags_bin = system('which ctags')

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

let g:coc_global_extensions = [
      \'coc-pairs',
      \'coc-json',
      \'coc-html',
      \'coc-tsserver',
      \'coc-eslint',
      \'coc-prettier',
      \'coc-highlight',
      \'coc-dictionary',
      \'coc-tag',
      \'coc-texlab',
      \'coc-snippets',
      \'coc-lists',
      \'coc-yank',
      \'coc-yaml',
      \'coc-syntax',
      \'coc-git',
      \'coc-emoji',
      \'coc-calc',
      \'coc-xml',
      \'coc-rls',
      \'coc-rust-analyzer',
      \'coc-java',
      \'coc-metals',
      \'coc-python',
      \'coc-marketplace',
      \'coc-webpack',
      \'coc-word',
      \'coc-lines',
      \'coc-markdownlint',
      \'coc-vimlsp',
      \'coc-ecdict'
      \]

nmap <silent> gd <Plug>(coc-definition)
" nmap <silent> gD <Plug>(coc-declaration)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gn <Plug>(coc-rename)
nmap <silent> ge <Plug>(coc-diagnostic-next)
nmap <silent> ga <Plug>(coc-codeaction)
nmap <silent> gl <Plug>(coc-codelens-action)
nmap <silent> gs <Plug>(coc-git-chunkinfo)
nmap <silent> gm <Plug>(coc-git-commit)
omap <silent> ig <Plug>(coc-git-chunk-inner)
xmap <silent> ig <Plug>(coc-git-chunk-inner)

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" nmap <silent> gD <Plug>(coc-documentation)
nmap <silent> <expr> [c &diff ? '[c' : '<Plug>(coc-git-prevchunk)'
nmap <silent> <expr> ]c &diff ? ']c' : '<Plug>(coc-git-nextchunk)'
nmap <silent> <expr> <C-d> <SID>select_current_word()
nmap <silent> <C-c> <Plug>(coc-cursors-position)
xmap <silent> <C-d> <Plug>(coc-cursors-range)

nmap <localleader>lx  <Plug>(coc-cursors-operator)
nmap <localleader>lr <Plug>(coc-refactor)
xmap <localleader>lf  <Plug>(coc-format-selected)
nmap <localleader>lf  <Plug>(coc-format-selected)
xmap <localleader>la  <Plug>(coc-codeaction-selected)
nmap <localleader>la  <Plug>(coc-codeaction-selected)
" Introduce function text object
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" inoremap <silent><expr> <down> coc#util#has_float() ? FloatScroll(1) : "\<down>"
" inoremap <silent><expr>  <up>  coc#util#has_float() ? FloatScroll(0) :  "\<up>"
" inoremap <silent><expr> <CR> pumvisible() ? coc#_select_confirm()
"       \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" inoremap <silent><expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" inoremap <silent><expr> <c-space> coc#refresh()
" inoremap <silent><expr> <TAB>
"       \ pumvisible() ? "\<C-n>" :
"       \ <SID>check_back_space() ? "\<TAB>" :
"       \ coc#refresh()

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

nnoremap <silent> K :call <SID>show_documentation()<CR>
nnoremap <silent> <localleader>lo  :<C-u>CocList -A outline -kind<CR>
nnoremap <silent> <localleader>la  :<C-u>CocList diagnostics<CR>
nnoremap <silent> <localleader>lf  :<C-u>CocList files<CR>
nnoremap <silent> <localleader>ll  :<C-u>CocList lines<CR>
nnoremap <silent> <localleader>lq  :<C-u>CocList quickfix<CR>
nnoremap <silent> <localleader>lw  :<C-u>CocList -I -N symbols<CR>
nnoremap <silent> <localleader>ly  :<C-u>CocList -A --normal yank<CR>
nnoremap <silent> <localleader>lm  :<C-u>CocList -A -N mru<CR>
nnoremap <silent> <localleader>lb  :<C-u>CocList -A -N --normal buffers<CR>
nnoremap <silent> <localleader>lj  :<C-u>CocNext<CR>
nnoremap <silent> <localleader>lk  :<C-u>CocPrev<CR>
nnoremap <silent> <localleader>ls  :exe 'CocList -A -I --normal --input='.expand('<cword>').' words'<CR>
nnoremap <silent> <localleader>lS  :exe 'CocList -A --normal grep '.expand('<cword>').''<CR>
nnoremap <silent> <localleader>ld  :call CocAction('jumpDefinition', v:false)<CR>

imap <C-k> <Plug>(coc-snippets-expand)
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

" call coc#add_command('tree', 'Vexplore', 'open netrw explorer')
" }} coc.nvim "

" nvim-lsp {{ "
" call lsp#set_log_level("debug")
" call nvim_lsp#setup("rust_analyzer", {})
" }} nvim-lsp "

" vim: set sw=2 ts=2 sts=2 et tw=78 foldmarker={{,}} foldmethod=marker foldlevel=0:
" languageclient-neovim
" Required for operations modifying multiple buffers like rename.

" let g:LanguageClient_devel = 1 " Use rust debug build DEBUG
" let g:LanguageClient_loggingLevel = 'DEBUG' " Use highest logging level Debug 
" let $LANGUAGECLIENT_DEBUG=1 "DEBUG
" let g:LanguageClient_autoStart=0 "DEBUG

" let g:LanguageClient_serverCommands = {
"   \ 'rust': ['rust-analyzer'],
"   \ 'scala': ['metals-vim'],
"   \ 'c': ['ccls'],
"   \ 'c++': ['ccls'],
"   \ 'cpp': ['ccls'],
"   \ 'go': ['gopls'],
"   \ 'sh': ['bash-language-server', 'start'],
"   \ 'javascript': ['javascript-typescript-stdio'],
"   \ 'javascript.jsx': ['tcp://127.0.0.1:2089'],
"   \ 'python': ['pyls'],
"   \ 'haskell': ['hie-wrapper'],
"   \ 'ocaml': ['ocaml-language-server', '--stdio'],
"   \ }

" autocmd BufWritePre *.go :call LanguageClient#textDocument_formatting_sync()

" let g:LanguageClient_rootMarkers = ['*.cabal', 'stack.yaml', 'Cargo.toml']

" " Automatically call hover
" " https://github.com/autozimu/LanguageClient-neovim/issues/618
" function! LspMaybeHover(is_running) abort
"   if a:is_running.result && g:LanguageClient_autoHoverAndHighlightStatus
"     call LanguageClient_textDocument_hover()
"   endif
" endfunction

" function! LspMaybeHighlight(is_running) abort
"   if a:is_running.result && g:LanguageClient_autoHoverAndHighlightStatus
"     call LanguageClient#textDocument_documentHighlight()
"   endif
" endfunction

" augroup lsp_aucommands
"   au!
"   au CursorHold * call LanguageClient#isAlive(function('LspMaybeHover'))
"   au CursorMoved * call LanguageClient#isAlive(function('LspMaybeHighlight'))
" augroup END

" let g:LanguageClient_autoHoverAndHighlightStatus = 1

" function! ToggleLspAutoHoverAndHilight() abort
"   if g:LanguageClient_autoHoverAndHighlightStatus
"     let g:LanguageClient_autoHoverAndHighlightStatus = 0
"     call LanguageClient#clearDocumentHighlight()
"     echo ""
"   else
"     let g:LanguageClient_autoHoverAndHighlightStatus = 1
"   end
" endfunction

" This does actually not work. https://github.com/autozimu/LanguageClient-neovim/issues/603
" let g:LanguageClient_useVirtualText = "All"
" function! ToggleLspUseVirtualText() abort
"   if g:LanguageClient_useVirtualText
"     let g:LanguageClient_useVirtualText = "None"
"     redraw
"   else
"     let g:LanguageClient_useVirtualText = "All"
"     redraw
"   end
" endfunction

" nnoremap <LocalLeader>V :call ToggleLspUseVirtualText()<CR>
" nnoremap <LocalLeader>H :call ToggleLspAutoHoverAndHilight()<CR>
" nnoremap <LocalLeader>c :call LanguageClient_contextMenu()<CR>
" nnoremap <LocalLeader>h :call LanguageClient#textDocument_hover()<CR>
" nnoremap <LocalLeader>g :call LanguageClient#textDocument_definition()<CR>
" nnoremap <LocalLeader>r :call LanguageClient#textDocument_rename()<CR>
" nnoremap <LocalLeader>f :call LanguageClient#textDocument_formatting()<CR>
" nnoremap <LocalLeader>u :call LanguageClient#textDocument_references()<CR>
" nnoremap <LocalLeader>a :call LanguageClient#textDocument_codeAction()<CR>
" nnoremap <LocalLeader>s :call LanguageClient#textDocument_documentSymbol()<CR>

" nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
" nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
" nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

" denite content search
nnoremap <leader>da :DeniteProjectDir -buffer-name=grep -default-action=quickfix grep:::!<CR>
nnoremap <silent><leader>dP :DeniteProjectDir -buffer-name=git file/rec/git<CR>
nnoremap <silent><leader>dp :DeniteProjectDir -buffer-name=files file/rec<CR>
nnoremap <silent><leader>do :<C-u>Denite -buffer-name=outline -direction=botright -split=vertical -winwidth=45 outline<CR>
nnoremap <silent><leader>dr :<C-u>Denite -resume -refresh<CR>
nnoremap <silent><leader>df :<C-u>Denite -default-action=tabopen file/rec file_mru<CR>
nnoremap <silent><leader>dh :<C-u>Denite -default-action=tabopen file/rec:~/<CR>
nnoremap <silent><leader>dy :<C-u>Denite -default-action=append -mode=normal neoyank<CR>
nnoremap <silent><leader>dg :<C-u>DeniteCursorWord -default-action=tabopen -mode=normal grep:.<CR>
nnoremap <silent><leader>do :<C-u>Denite -buffer-name=outline -direction=botright -split=vertical -winwidth=45 outline<CR>
nnoremap <silent><leader>dc :<C-u>Denite command_history<CR>

function! Denite_vgrep(search_string)
    let l:escaped_str = substitute(a:search_string, " ", "\\\\\\\\s", "g")
    exec 'Unite -buffer-name=vgrep_auto -default-action=tabopen grep:.:-iHn:'.l:escaped_str
endfunction
vnoremap <silent><LocalLeader>v y:call Denite_vgrep('<C-R><C-R>"')<CR>

" autopairs

let g:AutoPairsShortcutToggle = '<leadaer>at'
let g:AutoPairsShortcutFastWrap = '<leadaer>aw'
let g:AutoPairsShortcutJump = '<leadaer>an'
let g:AutoPairsShortcutBackInsert = '<leadaer>ap'

" autoformat {{{

let s:autoformat_enabled = 0
function! s:autoformat(...)
    if ! s:autoformat_enabled
        return
    endif
    let blacklist = ['.stignore', 'go', 'md', 'markdown', 'sxhkdrc']
    if index(blacklist, a:0) >= 0
        return
    endif
    if index(blacklist, a:1) >= 0
        return
    endif
    exec "silent Autoformat"
    echo "auto formated"
endfun

function! ToggleAutoformat()
    if s:autoformat_enabled
        let s:autoformat_enabled = 0
        echo "autoformat disabled"
    else
        let s:autoformat_enabled = 1
        echo "autoformat enabled"
    endif
endfunction

command! ToggleAutoformat call ToggleAutoformat()

augroup autoformat
    autocmd!
    autocmd BufWritePre * :call s:autoformat(expand('%'), expand('%:e'))
augroup END

let g:autoformat_autoindent = 0
let g:autoformat_retab = 1
let g:autoformat_remove_trailing_spaces = 1
let g:formatdef_my_custom_sh = '"shfmt"'
let g:formatdef_my_custom_nix = '"nix-beautify"'
let g:formatters_cs = ['my_custom_sh']
" }}}

" {{{
let g:multi_cursor_use_default_mapping=0

" Default mapping
let g:multi_cursor_start_word_key      = '<C-n>'
let g:multi_cursor_select_all_word_key = '<A-n>'
let g:multi_cursor_start_key           = 'g<C-n>'
let g:multi_cursor_select_all_key      = 'g<A-n>'
let g:multi_cursor_next_key            = '<C-n>'
let g:multi_cursor_prev_key            = '<C-p>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'

" Default mapping
" let g:multi_cursor_start_word_key      = '<leader>mw'
" let g:multi_cursor_select_all_word_key = '<leader>ma'
" let g:multi_cursor_start_key           = '<leader>ms'
" let g:multi_cursor_select_all_key      = '<leader>me'
" let g:multi_cursor_next_key            = '<leader>mn'
" let g:multi_cursor_prev_key            = '<leader>mp'
" let g:multi_cursor_skip_key            = '<leader>ms'
" let g:multi_cursor_quit_key            = '<Esc>'

" }}}

" ctrlspace

if has("gui_running")
    " Settings for MacVim and Inconsolata font
    let g:CtrlSpaceSymbols = { "File": "◯", "CTab": "▣", "Tabs": "▢" }
endif
if executable("ag")
    let g:CtrlSpaceGlobCommand = 'ag -l --nocolor -g ""'
endif
let g:CtrlSpaceSearchTiming = 500

" sideways

nnoremap <leader><leader>h :SidewaysLeft<cr>
nnoremap <leader><leader>l :SidewaysRight<cr>
omap aa <Plug>SidewaysArgumentTextobjA
xmap aa <Plug>SidewaysArgumentTextobjA
omap ia <Plug>SidewaysArgumentTextobjI
xmap ia <Plug>SidewaysArgumentTextobjI

let g:lastplace_ignore = "gitcommit,gitrebase,svn,hgcommit"
let g:lastplace_ignore_buftype = "quickfix,nofile,help"

" golang vim-go
" let g:go_fmt_command = "goimports"
" let g:go_autodetect_gopath = 1
" let g:go_list_type = "quickfix"
" let g:go_highlight_functions = 1
" let g:go_highlight_methods = 1
" let g:go_highlight_fields = 1
" let g:go_highlight_types = 1
" let g:go_highlight_operators = 1
" let g:go_highlight_build_constraints = 1
" let g:go_highlight_function_calls = 1
" let g:go_highlight_extra_types = 1
" let g:go_highlight_generate_tags = 1

" augroup go
"     autocmd!
"     " Show by default 4 spaces for a tab
"     autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4

"     " :GoBuild and :GoTestCompile
"     autocmd FileType go nmap <localleader>b :<C-u>call <SID>build_go_files()<CR>

"     " :GoTest
"     autocmd FileType go nmap <localleader>t <Plug>(go-test)

"     " :GoRun
"     autocmd FileType go nmap <localleader>r <Plug>(go-run)

"     " :GoDoc
"     autocmd FileType go nmap <localleader>h <Plug>(go-doc)

"     " :GoCoverageToggle
"     autocmd FileType go nmap <localleader>c <Plug>(go-coverage-toggle)

"     " :GoInfo
"     autocmd FileType go nmap <localleader>f <Plug>(go-info)

"     " :GoImport
"     autocmd FileType go nmap <localleader>i :GoImport<Space>

"     " :GoMetaLinter
"     autocmd FileType go nmap <localleader>l <Plug>(go-metalinter)

"     " :GoDef but opens in a vertical split
"     autocmd FileType go nmap <localleader>v <Plug>(go-def-vertical)
"     " :GoDef but opens in a horizontal split
"     autocmd FileType go nmap <localleader>s <Plug>(go-def-split)

"     " :GoDef but opens in a horizontal split
"     autocmd FileType go nmap <localleader>u :GoReferrers<CR>

"     " :GoDef but opens in a horizontal split
"     autocmd FileType go nmap <localleader>g :GoDef<CR>

"     " Open :GoDeclsDir with <localleader>g
"     autocmd FileType go nmap <localleader>t :GoDeclsDir<CR>
"     " autocmd FileType go imap <localleader>t <esc>:<C-u>GoDeclsDir<cr>

"     " :GoAlternate  commands :A, :AV, :AS and :AT
"     autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
"     autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
"     autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
"     autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')
" augroup END

" let g:tagbar_type_go = {
"             \ 'ctagstype' : 'go',
"             \ 'kinds'     : [
"             \ 'p:package',
"             \ 'i:imports:1',
"             \ 'c:constants',
"             \ 'v:variables',
"             \ 't:types',
"             \ 'n:interfaces',
"             \ 'w:fields',
"             \ 'e:embedded',
"             \ 'm:methods',
"             \ 'r:constructor',
"             \ 'f:functions'
"             \ ],
"             \ 'sro' : '.',
"             \ 'kind2scope' : {
"             \ 't' : 'ctype',
"             \ 'n' : 'ntype'
"             \ },
"             \ 'scope2kind' : {
"             \ 'ctype' : 't',
"             \ 'ntype' : 'n'
"             \ },
"             \ 'ctagsbin'  : 'gotags',
"             \ 'ctagsargs' : '-sort -silent'
"             \ }
" let g:go_fmt_command = "goimports"

" build_go_files is a custom function that builds or compiles the test file.
" It calls :GoBuild if its a Go file, or :GoTestCompile if it's a test file
function! s:build_go_files()
    let l:file = expand('%')
    if l:file =~# '^\f\+_test\.go$'
        call go#test#Test(0, 1)
    elseif l:file =~# '^\f\+\.go$'
        call go#cmd#Build(0)
    endif
endfunction

" haskell

" augroup interoMaps
"   au!
"   " Maps for intero. Restrict to Haskell buffers so the bindings don't collide.

"   " Background process and window management
"   au FileType haskell nnoremap <silent> <LocalLeader>is :InteroStart<CR>
"   au FileType haskell nnoremap <silent> <LocalLeader>ik :InteroKill<CR>

"   " Open intero/GHCi split horizontally
"   au FileType haskell nnoremap <silent> <LocalLeader>io :InteroOpen<CR>
"   " Open intero/GHCi split vertically
"   au FileType haskell nnoremap <silent> <LocalLeader>iov :InteroOpen<CR><C-W>H
"   au FileType haskell nnoremap <silent> <LocalLeader>ih :InteroHide<CR>

"   " Reloading (pick one)
"   " Automatically reload on save
"   au BufWritePost *.hs InteroReload
"   " Manually save and reload
"   au FileType haskell nnoremap <silent> <LocalLeader>ir :w \| :InteroReload<CR>

"   " Load individual modules
"   au FileType haskell nnoremap <silent> <LocalLeader>il :InteroLoadCurrentModule<CR>
"   au FileType haskell nnoremap <silent> <LocalLeader>if :InteroLoadCurrentFile<CR>

"   " Type-related information
"   " Heads up! These next two differ from the rest.
"   au FileType haskell map <silent> <LocalLeader>igt <Plug>InteroGenericType
"   au FileType haskell map <silent> <LocalLeader>it <Plug>InteroType
"   au FileType haskell nnoremap <silent> <LocalLeader>ii :InteroTypeInsert<CR>

"   " Navigation
"   au FileType haskell nnoremap <silent> <LocalLeader>id :InteroGoToDef<CR>

"   " Managing targets
"   " Prompts you to enter targets (no silent):
"   au FileType haskell nnoremap <LocalLeader>ist :InteroSetTargets<SPACE>
" augroup END

" " Intero starts automatically. Set this if you'd like to prevent that.
" let g:intero_start_immediately = 0

" " Enable type information on hover (when holding cursor at point for ~1 second).
" let g:intero_type_on_hover = 1

" " Change the intero window size; default is 10.
" let g:intero_window_size = 15

" " Sets the intero window to split vertically; default is horizontal
" let g:intero_vertical_split = 1

" OPTIONAL: Make the update time shorter, so the type info will trigger faster.
set updatetime=1000

" Python
" au BufNewFile,BufRead *.py
"             \ set tabstop=4 |
"             \ set softtabstop=4 |
"             \ set shiftwidth=4 |
"             \ set textwidth=79 |
"             \ set expandtab |
"             \ set autoindent |
"             \ set fileformat=unix |

" let g:formatter_yapf_style = 'pep8'
" let g:jedi#auto_initialization = 1
" let g:jedi#goto_command = "<localleader>d"
" let g:jedi#goto_command = "<localleader>g"
" let g:jedi#goto_definitions_command = "<localleader>d"
" let g:jedi#documentation_command = "<localleader>h"
" let g:jedi#call_signatures_command = "<localleader>s"
" let g:jedi#usages_command = "<localleader>n"
" " let g:jedi#completions_command = "<M-c>"
" let g:jedi#rename_command = "<localleader>r"
" " let g:jedi#use_splits_not_buffers = "left"
" let g:jedi#popup_on_dot = 1
" let g:jedi#popup_select_first = 1
" let g:jedi#show_call_signatures = 2
" " let g:jedi#completions_enabled = 1
" let g:jedi#smart_auto_mappings = 1

" function! FindDjangoSettings()
"     if strlen($VIRTUAL_ENV) && has('python')
"         let output  = system("find $VIRTUAL_ENV \\( -wholename '*/lib/*' -or -wholename '*/install/' \\) -or \\( -name 'settings.py' -print0 \\) | tr '\n' ' '")
"         let outarray= split(output, '[\/]\+')
"         let module  = outarray[-2] . '.' . 'settings'
"         let syspath = system("python -c 'import sys; print sys.path' | tr '\n' ' ' ")
"         " let curpath = '/' . join(outarray[:-2], '/')

"         execute 'python import sys, os'
"         " execute 'python sys.path.append("' . curpath . '")'
"         " execute 'python sys.path.append("' . syspath . '")'
"         execute 'python sys.path = ' . syspath
"         execute 'python os.environ.setdefault("DJANGO_SETTINGS_MODULE", "' . module . '")'
"     endif
" endfunction

" function! JediGotoSplit()
"     let g:jedi#use_splits_not_buffers = "right"
"     call jedi#goto()
"     let g:jedi#use_splits_not_buffers = ""
" endfunction

" function! JediGotoVsplit()
"     let g:jedi#use_splits_not_buffers = "bottom"
"     call jedi#goto()
"     let g:jedi#use_splits_not_buffers = ""
" endfunction

" augroup python
"     autocmd!

"     autocmd FileType python nnoremap <localleader>= :0,$!yapf<CR>
"     " autocmd FileType python call FindDjangoSettings()
"     autocmd FileType python nnoremap <localleader>i :!isort %<CR><CR>
"     autocmd FileType python nmap <localleader>s :call JediGotoSplit()<CR>
"     autocmd FileType python nmap <localleader>v :call JediGotoVsplit()<CR>

" augroup END

"python with virtualenv support
" py << EOF
" import os
" import sys
" if 'VIRTUAL_ENV' in os.environ:
"   project_base_dir = os.environ['VIRTUAL_ENV']
"   activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
"   execfile(activate_this, dict(__file__=activate_this))
" EOF

" html
au BufNewFile,BufRead *.js,*.html,*.css :
            \ set tabstop=2 |
            \ set softtabstop=2 |
            \ set shiftwidth=2 |

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

"""""""""""""""""""""
"    functions      "
"""""""""""""""""""""
function! DisplayColorSchemes()
    let l:paths = split(globpath(&rtp, 'colors/*vim'), '\n')
    for l:path in l:paths
        let l:color = fnamemodify(l:path, ':t:r')
        exec "colorscheme " . l:color
        exec "redraw!"
        echo "colorscheme = ". l:color
        sleep 1
    endfor
endfunction

function! Rand()
    return str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:])
endfunction

function! RandomColorScheme(...)
    let l:blacklist = ['blue', 'morning', 'evening', 'shine', 'parse'] " fuck it, I don't know which package provides this
    let l:paths = split(globpath(&rtp, 'colors/*vim'), '\n')
    let l:path = l:paths[Rand() % len(l:paths)]
    let l:color = fnamemodify(l:path, ':t:r')
    if (index(l:blacklist, l:color) >= 0)
        return RandomColorScheme()
    endif
    exec "colorscheme " . l:color
    exec "redraw!"
    if a:0
        echo "colorscheme = ". l:color
    endif
endfunction

command! RandomColorScheme call RandomColorScheme(1)

function! PathJoin(parent, child, ...) " {{{1
    " Join a directory pathname and filename into a single pathname.
    if type(a:parent) == type('') && type(a:child) == type('')
        " TODO Use xolox#misc#path#is_relative()?
        if has('win16') || has('win32') || has('win64')
            let parent = substitute(a:parent, '[\\/]\+$', '', '')
            let child = substitute(a:child, '^[\\/]\+', '', '')
            return parent . '\' . child
        else
            let parent = substitute(a:parent, '/\+$', '', '')
            let child = substitute(a:child, '^/\+', '', '')
            return parent . '/' . child
        endif
    endif
    return ''
endfunction

function! s:get_visual_selection()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - 2]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

function! TrimWhitespace()
    let l:save = winsaveview()
    %s/\s\+$//e
    call winrestview(l:save)
endfun

command! TrimWhitespace call TrimWhitespace()

" Quick run via <F5>
command! CompileAndRun call <SID>compile_and_run()
nnoremap <F5> :call <SID>compile_and_run()<CR>
inoremap <F5> <Esc> :call <SID>compile_and_run()<CR>

function! s:compile_and_run()
    exec 'w'
    if &filetype == 'c'
        exec "AsyncRun! gcc % -o %<; time ./%<"
    elseif &filetype == 'cpp'
        exec "AsyncRun! g++ -std=c++11 % -o %<; time ./%<"
    elseif &filetype == 'java'
        exec "AsyncRun! javac %; time java %<"
    elseif &filetype == 'vim'
        exec "silent source %"
    elseif &filetype == 'go'
        exec "AsyncRun! call s:build_go_files()"
    elseif &filetype == 'sh'
        exec "AsyncRun! time bash %"
    elseif &filetype == 'python'
        exec "AsyncRun! time python %"
    endif
endfunction

" Creates a session
function! MakeSession()
    let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
    if (filewritable(b:sessiondir) != 2)
        exe 'silent !mkdir -p ' b:sessiondir
        redraw!
    endif
    let b:sessionfile = b:sessiondir . '/session.vim'
    exe "mksession! " . b:sessionfile
endfunction

" Updates a session, BUT ONLY IF IT ALREADY EXISTS
function! UpdateSession()
    let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
    let b:sessionfile = b:sessiondir . "/session.vim"
    if (filereadable(b:sessionfile))
        exe "mksession! " . b:sessionfile
        echo "updating session"
    endif
endfunction

" Loads a session if it exists
function! LoadSession()
    if argc() == 0
        let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
        let b:sessionfile = b:sessiondir . "/session.vim"
        if (filereadable(b:sessionfile))
            exe 'source ' b:sessionfile
        else
            echo "No session loaded."
        endif
    else
        let b:sessionfile = ""
        let b:sessiondir = ""
    endif
endfunction

au VimEnter * nested :call LoadSession()
au VimLeave * :call UpdateSession()
map <leader>m :call MakeSession()<CR>

" augroup SPACEVIM_ASYNCRUN
"     autocmd!
"    " Automatically open the quickfix window
"     autocmd User AsyncRunStart call asyncrun#quickfix_toggle(15, 1)
" augroup END
"
" asyncrun now has an option for opening quickfix automatically
let g:asyncrun_open = 15

"""""""""""""""""""""
"      autocmd      "
"""""""""""""""""""""

" autocmd VimEnter * RandomColorScheme
call RandomColorScheme()
