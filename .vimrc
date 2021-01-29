"Set up Plug and Autoinstall
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Reference plugins...
call plug#begin()
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'sickill/vim-monokai'
Plug 'christoomey/vim-system-copy'
Plug 'vim-python/python-syntax'
Plug 'tpope/vim-fugitive'
Plug 'hashivim/vim-terraform'
Plug 'glench/vim-jinja2-syntax'
Plug 'stephpy/vim-yaml'
Plug 'pearofducks/ansible-vim'
call plug#end()

"""Plugin configs
""Terraform Plug Configs
filetype plugin indent on    " required
let g:terraform_fmt_on_save=1
let g:terraform_align=1

""Airline/Powerline
let g:airline_theme='deus'
let g:airline_powerline_fonts = 1
let g:Powerline_symbols = 'fancy'

""Python
let g:python_highlight_all = 1

""""Colors/Themes
colorscheme monokai
set background=dark
set t_Co=256

"""General VIM settings
syntax on
set number
set rnu
set backspace=2
set cursorline
set cursorcolumn
set expandtab
set laststatus=2
set shiftwidth=2
map <C-t><up> :tabr<cr>
map <C-t><down> :tabl<cr>
map <C-t><left> :tabp<cr>
map <C-t><right> :tabn<cr>
