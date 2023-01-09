require'nvim-treesitter.configs'.setup { highlight = { enable = true } }

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
require'lspconfig'.cssls.setup {
	  capabilities = capabilities,
}

require('nvim_comment').setup()
