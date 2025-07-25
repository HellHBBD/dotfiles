return {
  {
    "tpope/vim-fugitive",
  },

  {
    "preservim/nerdtree",
    keys = {
      { "<F2>", "<cmd>NERDTreeToggle<CR>", desc = "Toggle NERDTree" },
    },
  },

  {
    "ibhagwan/fzf-lua",
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "mfussenegger/nvim-dap",
  },
}
