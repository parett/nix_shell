{pkgs ? import <nixpkgs> {}}:

let
  d2-vim = pkgs.vimUtils.buildVimPlugin {
    name = "d2-vim";
	dontBuild = true;
	dontCheck = true;
    src = pkgs.fetchFromGitHub {
      owner = "terrastruct";
      repo = "d2-vim";
      rev = "ac58c07ba192d215cbbd2b2207f9def808a9283d";
      sha256 = "rXUhXVmva4K0PqUboSXUpTqNttwehjkjjsEgTCZbGKI=";
    };
  };
  neogen = pkgs.vimUtils.buildVimPlugin {
    name = "neogen";
	dontBuild = true;
	dontCheck = true;
    src = pkgs.fetchFromGitHub {
      owner = "danymat";
      repo = "neogen";
      rev = "f249a70ee598bdf8d015c10536c0dcd97c79b3aa";
      sha256 = "x2jpJ49G6fJhwE2I2FA4wZy/moZokvApJhzUav+fzqA=";
    };
  };
  neovim-with-my-packages =
    pkgs.neovim.override {
      configure = {
        customRC = ''
			set number
			set relativenumber
			set autoindent
			set tabstop=4
			set shiftwidth=4
			set smarttab
			set softtabstop=4
			set mouse=a
			set noerrorbells
			set visualbell
			set nowrap
			set nobackup
			set colorcolumn=80
			set ignorecase
			set smartcase

            sy on

			highlight ColorColumn ctermbg=0 guibg=lightgrey

			if &term =~ '256color'
			" Disable Background Color Erase (BCE) so that color schemes
			" work properly when Vim is used inside tmux and GNU screen.
				set t_ut=
			endif


          luafile ${./nix/compe-config.lua}
          luafile ${./nix/treesitter.lua}
          autocmd FileType java luafile ${./nix/java.lua}
         

          let g:db = "sqlite:db.sqlite3"


			colorscheme gruvbox
			set background=dark
			imap jj <Esc>
			nnoremap <SPACE> <Nop>
			let mapleader=" "

			" Telescope mapping
			nnoremap <leader>ff <cmd>Telescope find_files<cr>
			nnoremap <leader>fg <cmd>Telescope live_grep<cr>
			nnoremap <leader>fb <cmd>Telescope buffers<cr>
			nnoremap <leader>fh <cmd>Telescope help_tags<cr>
			nnoremap <leader>ft <cmd>Telescope treesitter<cr>
			nnoremap <leader>fr <cmd>Telescope lsp_references<cr>

			" LSP config (the mappings used in the default file don't quite work right)
			nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
			nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
			nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
			nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>

			nnoremap <leader>ca <cmd>lua vim.lsp.buf.code_action()<CR>
			nnoremap <leader>rr <cmd>lua vim.lsp.buf.rename()<CR>
			nnoremap <leader>rf <cmd>lua vim.lsp.buf.formatting()<CR>

			nnoremap <leader>ww <cmd>w<CR>
			nnoremap <leader>wq <cmd>wq<CR>
			nnoremap <leader>qq <cmd>q<CR>
			nnoremap <leader>wr <cmd>w <CR><bar> <cmd>silent ! ./debug.sh <CR><bar> <cmd>redraw!<CR>
			nnoremap <leader>ct <cmd>! mvn clean test<cr>

			nnoremap <leader>nn :NERDTreeFocus<CR>
			nnoremap <leader>nt :NERDTreeToggle<CR>
			nnoremap <leader>nf :NERDTreeFind<CR>

			imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
			smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'	
        '';
        packages.myVimPackage = with pkgs.vimPlugins; {
			start = [ 
				fugitive
				gruvbox
				plenary-nvim
				telescope-nvim
				vim-vsnip
				vim-vsnip-integ
				nvim-lspconfig
				nvim-treesitter
				vim-dadbod
				vim-dadbod-completion
				nvim-compe
				nerdtree
				vim-nix
                nvim-jdtls
                neogen
                nvim-comment
                d2-vim
			];
        }; 
      };     
    };
    java-lsp = pkgs.callPackage ./nix/jdtls.nix {};
in
pkgs.mkShell {
  name = "dev";
  buildInputs = with pkgs; [
    java-lsp
    maven
    less
	jdk17
    git
	procps
	# postgresql
    neovim-with-my-packages
    entr
    litecli
    sqlite
    nodePackages.vscode-langservers-extracted
    fd
  ];
}
