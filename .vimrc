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
Plug 'christoomey/vim-system-copy'
Plug 'vim-python/python-syntax'
Plug 'tpope/vim-fugitive'
Plug 'hashivim/vim-terraform'
Plug 'glench/vim-jinja2-syntax'
Plug 'pearofducks/ansible-vim'
Plug 'yggdroot/indentLine'
Plug 'sainnhe/sonokai'
Plug 'preservim/nerdcommenter'
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
if has('termguicolors')
      set termguicolors
    endif

let g:sonokai_style = 'andromeda'
let g:sonokai_better_performance = 1
colorscheme sonokai

"""Ansible
let g:ansible_attribute_highlight = "ab"
let g:ansible_unindent_after_newline = 1
let g:ansible_name_highlight = 'b'
let g:ansible_extra_keywords_highlight = 1
let g:ansible_normal_keywords_highlight = 'Constant'
let g:ansible_with_keywords_highlight = 'Constant'


"""General VIM settings
syntax on
autocmd BufNewFile,BufRead Jenkinsfile set syntax=groovy
autocmd FileType yaml,yml setlocal ts=2 sts=2 sw=2 expandtab
set number
set rnu
set backspace=2
set cursorline
set cursorcolumn
set laststatus=2
set shiftwidth=2
map <C-t><up> :tabr<cr>
map <C-t><down> :tabl<cr>
map <C-t><left> :tabp<cr>
map <C-t><right> :tabn<cr>
