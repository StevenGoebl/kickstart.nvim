-- ==========================================
-- AUTOCOMPLETION
-- ==========================================
return {

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load({ exclude = { "tex" } })
            end,
          },
        },
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-omni',
    },

    config = function()
      local cmp     = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      -- ----------------------------------------
      -- Custom LaTeX Snippets
      -- ----------------------------------------
      luasnip.add_snippets("tex", {
        luasnip.snippet("beq", {
          luasnip.text_node({ "\\begin{equation}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{equation}" }),
        }),
        luasnip.snippet("bth", {
          luasnip.text_node({ "\\begin{theorem}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{theorem}" }),
        }),
        luasnip.snippet("ble", {
          luasnip.text_node({ "\\begin{lemma}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{lemma}" }),
        }),
        luasnip.snippet("bpf", {
          luasnip.text_node({ "\\begin{proof}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{proof}" }),
        }),
        luasnip.snippet("im", {
          luasnip.text_node("\\( "),
          luasnip.insert_node(1),
          luasnip.text_node(" \\)"),
        }),
        luasnip.snippet("dm", {
          luasnip.text_node({ "\\[", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\]" }),
        }),
        luasnip.snippet("bit", {
          luasnip.text_node({ "\\begin{itemize}", "\t\\item " }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{itemize}" }),
        }),
        luasnip.snippet("frac", {
          luasnip.text_node("\\frac{"),
          luasnip.insert_node(1),
          luasnip.text_node("}{"),
          luasnip.insert_node(2),
          luasnip.text_node("}"),
        }),
        luasnip.snippet("bpr", {
          luasnip.text_node({ "\\begin{proposition}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{proposition}" }),
        }),
        luasnip.snippet("bco", {
          luasnip.text_node({ "\\begin{corollary}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{corollary}" }),
        }),
        luasnip.snippet("bde", {
          luasnip.text_node({ "\\begin{definition}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{definition}" }),
        }),
        luasnip.snippet("bal", {
          luasnip.text_node({ "\\begin{align*}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{align*}" }),
        }),
        luasnip.snippet("EE", {
          luasnip.text_node("\\mathbb{E}\\left["),
          luasnip.insert_node(1),
          luasnip.text_node("\\right]"),
        }),
        luasnip.snippet("PP", {
          luasnip.text_node("\\mathbb{P}\\left("),
          luasnip.insert_node(1),
          luasnip.text_node("\\right)"),
        }),
        luasnip.snippet("VV", {
          luasnip.text_node("\\text{Var}\\left["),
          luasnip.insert_node(1),
          luasnip.text_node("\\right]"),
        }),
        luasnip.snippet("iid", {
          luasnip.text_node("\\overset{\\text{iid}}{\\sim}"),
        }),
        -- FIX: renamed trigger from "sum" to "sumx" to avoid firing on the
        --      common English word "sum" in prose or comments.
        luasnip.snippet("sumx", {
          luasnip.text_node("\\sum_{"),
          luasnip.insert_node(1, "i=1"),
          luasnip.text_node("}^{"),
          luasnip.insert_node(2, "n"),
          luasnip.text_node("}"),
        }),
      })
      -- ----------------------------------------

      cmp.setup {
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>']     = cmp.mapping.select_next_item(),
          ['<C-p>']     = cmp.mapping.select_prev_item(),
          ['<C-b>']     = cmp.mapping.scroll_docs(-4),
          ['<C-f>']     = cmp.mapping.scroll_docs(4),
          ['<C-y>']     = cmp.mapping.confirm { select = true },
          ['<CR>']      = cmp.mapping.confirm { select = true },
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<C-e>']     = cmp.mapping.abort(),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'nvim_lsp', priority = 1000 },
          { name = 'luasnip',  priority = 750  },
          { name = 'path',     priority = 250  },
        },
        formatting = {
          format = function(entry, vim_item)
            vim_item.menu = ({
              nvim_lsp = '[LSP]',
              luasnip  = '[Snip]',
              path     = '[Path]',
              omni     = '[VimTeX]',
            })[entry.source.name]
            return vim_item
          end,
        },
      }

      -- LaTeX: prioritise VimTeX omni-completion
      cmp.setup.filetype({ "tex" }, {
        sources = {
          { name = 'omni',     priority = 1000 },
          { name = 'luasnip',  priority = 900  },
          { name = 'nvim_lsp', priority = 750  },
          { name = 'path',     priority = 250  },
        },
      })
    end,
  },

}
