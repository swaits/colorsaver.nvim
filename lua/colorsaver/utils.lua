--- Utility functions for debouncing and validating colorschemes.
-- @module util
local M = {}

--- Debounces a function call. This is useful to prevent a function from
-- being called too frequently, delaying its execution until after a certain
-- amount of time has elapsed since the last time it was invoked.
-- @param func function The function to debounce.
-- @param delay number The time delay in milliseconds.
-- @return function A new debounced function.
function M.debounce(func, delay)
  assert(type(func) == "function", "Invalid argument 'func': function expected")
  assert(type(delay) == "number", "Invalid argument 'delay': number expected")

  local timer = nil
  return function(...)
    local args = { ... } -- Capture any arguments passed to the function.

    if timer then
      timer:stop() -- Stop any existing timer.
      timer:close() -- Clean up the timer resources.
    end

    -- Create a new timer.
    local uv = vim.uv or vim.loop
    timer = uv.new_timer()

    -- Start the timer with the specified delay.
    timer:start(
      delay,
      0,
      vim.schedule_wrap(function()
        func(unpack(args)) -- Call the original function with the captured arguments.
        timer:stop() -- Stop the timer.
        timer:close() -- Clean up the timer resources.
        timer = nil -- Clear the timer variable.
      end)
    )
  end
end

--- Validates whether the provided colorscheme name is available in Neovim.
-- This function checks against the list of valid colorschemes that Neovim knows about.
-- @param colorscheme string The colorscheme name to validate.
-- @return boolean True if the colorscheme is valid, false otherwise.
function M.is_colorscheme_valid(colorscheme)
  assert(type(colorscheme) == "string", "Invalid argument 'colorscheme': string expected")

  -- Check if the colorscheme exists in the list of completions for "color".
  return vim.tbl_contains(vim.fn.getcompletion("", "color"), colorscheme)
end

return M
