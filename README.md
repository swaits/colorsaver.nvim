# colorsaver.nvim

colorsaver.nvim is a Neovim plugin designed to save and load your preferred
colorscheme persistently across sessions. With colorsaver, you can ensure your
aesthetic preferences are maintained automatically. Additionally, it can
automatically load colorscheme changes across all running instances of Neovim,
providing a consistent user experience.

## Features

- **Persistent Colorscheme**: Save your selected colorscheme and have it load
automatically on startup.
- **Automatic Updates**: Watch for changes and automatically apply them across
instances of Neovim.

## Installation

Install colorsaver using your favorite package manager.

### [lazy](https://github.com/folke/lazy.nvim) (recommended)

```lua
{
  "https://git.sr.ht/~swaits/colorsaver.nvim",
  lazy = true,
  event = "VimEnter",
  opts = { 
    -- your options here
  },
}
```

Or, using [LazyVim](https://www.lazyvim.org/), which is built on top of
[lazy](https://github.com/folke/lazy.nvim), one example configuration might
look like this:

```lua
  {
    -- tell LazyVim to stop messing with colorschemes
    { "catppuccin/nvim", name = "catppuccin", enabled = false },
    { "folke/tokyonight.nvim", enabled = false },
    {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = "default", -- just some random built-in scheme
      },
    },


    -- load/save our last used colorscheme automatically
    {
      "https://git.sr.ht/~swaits/colorsaver.nvim",
      event = "VimEnter",
      opts = {},
      dependencies = {
        -- load colorschemes as a dependency of colorsaver
        { "AlexvZyl/nordic.nvim" },
        { "EdenEast/nightfox.nvim" },
        { "Shatur/neovim-ayu" },
        { "rebelot/kanagawa.nvim" },
      },
    },
  }

```

### [pckr](https://github.com/lewis6991/pckr.nvim)

```lua
{
  "https://git.sr.ht/~swaits/colorsaver.nvim",
  config = function()
    require("colorsaver").setup({ 
      -- your options here
    })
  end
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'https://git.sr.ht/~swaits/colorsaver.nvim'
lua require("colorsaver").setup({ 
    -- your options here
})
```

## Configuration

To configure colorsaver, pass a table with your preferred settings to the
`setup` function. Here is the default configuration:

```lua
{
  -- log_level: Sets the logging level for the module's output.
  -- Acceptable values are "debug", "info", "warn", "error".
  log_level = "warn",

  -- debounce_ms: Sets the debounce time in milliseconds for file watching.
  -- Accepts any integer greater than or equal to 50. If experiencing issues,
  -- consider increasing this value.
  debounce_ms = 100,

  -- filename: The name of the file where the colorscheme will be saved.
  -- Note that the file is always stored in the "data" directory, which is
  -- usually ~/.local/share/nvim/
  filename = "colorsaver",

  -- auto_load: If true, any colorscheme changes from one instance of nvim
  -- will be automatically loaded by all other instances of nvim.
  auto_load = true,
}
```

### File Watching

If `auto_load` is enabled, colorsaver will watch for changes in the saved
colorscheme file and apply them to all running instances of Neovim.

### Logging

colorsaver features an integrated logging system. You can specify the log level
in the configuration options. For troubleshooting, set the `log_level` to
`"debug"` to receive verbose output.

## Usage

Once colorsaver is installed and configured, it works automatically. Your
current colorscheme will be saved upon change and reloaded when Neovim starts
or when any Neovim instance changes it (when `auto_load` is `true`).

## Similar Projects

Before creating this, I used
[last-color.nvim](https://github.com/raddari/last-color.nvim). It's fantastic.

But I wanted to take it a step further. Specifically, I often run multiple nvim
instances in my terminal multiplexer. When I change colors in one, I wanted all
the others to change too. That was my main goal here.

It also adds some other niceties, like debouncing to avoid problems when
switching colorschemes too quickly (as is easy to do when browsing through
schemes with Telescope).

That said, they both work. Use what works best for you!

## Contributing

Contributions to colorsaver are welcome! Please feel free to fork the
repository, make your changes, and submit a pull request.

## MIT License

Copyright © 2023 [Stephen Waits](https://swaits.com/) <steve@waits.net>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
