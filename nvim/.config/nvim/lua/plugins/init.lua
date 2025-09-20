local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        '--branch=stable',
        lazyrepo,
        lazypath,
    })
    if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
    require('plugins.nerdtree'),

    require('plugins.tokyonight'),
    require('plugins.lualine'),

    -- require('plugins.telescope'),
    require('plugins.fzf-lua'),
    require('plugins.harpoon'),
    require('plugins.treesitter'),

    require('plugins.lsp'),
    require('plugins.cmp'),
    require('plugins.format'),

    require('plugins.indent-blankline'),

    require('plugins.which-key'),

    {
        'ThePrimeagen/vim-be-good',
    },

    require('plugins.render-markdown'),
    require('plugins.colorizer'),

    {
        'chomosuke/typst-preview.nvim',
        ft = 'typst',
        version = '1.*',
        opts = {}, -- lazy.nvim will implicitly calls `setup {}`
    },
})

-- require('plugins.rose-pine')
-- require('plugins.vim-airline')
