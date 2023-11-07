local M = {}

-- load modules
local autocommands = require("colorsaver.autocommands")
local config = require("colorsaver.config")
local file_watcher = require("colorsaver.file_watcher")
local logger = require("colorsaver.logger")
local utils = require("colorsaver.utils")

-- our module local data (and these are just placeholder values, they're overwritten below)
local autocmd_group = nil
local color_file_path = vim.fn.stdpath("data") .. "/colorsaver"
local colorfile_watcher = nil
local log = logger.new("warn", "colorsaver")

--- save_colorscheme(new_scheme)
--
-- This function saves a new colorscheme to a file. If no new_scheme is provided, it saves the default colorscheme.
--
-- Parameters:
-- - new_scheme (string): The name of the new colorscheme to save.
--
-- Returns:
-- - success (boolean): true if the colorscheme was saved successfully, false otherwise.
--
-- Raises:
-- - None
--
-- Example usage:
-- save_colorscheme("my_colorscheme")
--
local function save_colorscheme(new_scheme)
  local colorscheme_name = new_scheme
  if not vim.tbl_contains(vim.fn.getcompletion("", "color"), colorscheme_name) then
    log:warn("Didn't find " .. colorscheme_name .. " in the list of colorschemes")
    return false
  end

  local file, err = io.open(color_file_path, "w")
  if not file then
    log:error("Failed to open " .. color_file_path .. " for writing: " .. err)
    return false
  end

  local success, write_err = pcall(function()
    file:write(colorscheme_name)
  end)

  local close_ok, close_err = pcall(function()
    file:close()
  end)

  if not success then
    log:error("Failed to write colorscheme to " .. color_file_path .. ": " .. write_err)
    return false
  elseif not close_ok then
    log:error("Failed to close the file " .. color_file_path .. ": " .. close_err)
    return false
  end

  return true
end

--- load_colorscheme()
--
-- This function loads a colorscheme for the current session in Neovim. It first
-- attempts to read the colorscheme from a specified file path. If the file exists
-- and is not empty, the content of the file is used as the colorscheme.
--
-- Parameters:
-- None
--
-- Returns:
-- success (boolean): true if the colorscheme was loaded successfully, false otherwise.
--
-- Raises:
-- None
--
-- Example usage:
-- load_colorscheme()
--
local function load_colorscheme()
  local colorscheme = M.default -- Fallback to default colorscheme

  local file, err = io.open(color_file_path, "r")
  if not file then
    log:warn("Failed to open " .. color_file_path .. " for reading: " .. err)
    return false
  end

  local content, read_err = file:read("*a")
  if read_err then
    log:error("Failed to read from " .. color_file_path .. ": " .. read_err)
    file:close()
    return false
  end

  local close_ok, close_err = file:close()
  if not close_ok then
    log:error("Failed to close " .. color_file_path .. ": " .. close_err)
    return false
  end

  colorscheme = content ~= "" and content or colorscheme

  if not (colorscheme and colorscheme ~= "") then
    log:error("Invalid colorscheme name found in " .. color_file_path .. ".")
    return false
  end

  -- disable ColorScheme autocmd so we don't get into a bad loop; this is
  -- because we're about to call `colorscheme` which will trigger ColorScheme
  -- and cause us to write the file again, thus retriggering the
  -- load_colorscheme function since the file changed... bad loop
  if autocmd_group then
    autocmd_group:clear()
  end

  log:info("Switching to '" .. colorscheme .. "'")
  local ok, cmd_err = pcall(vim.api.nvim_command, "colorscheme " .. colorscheme)
  if not ok then
    log:error("Failed to apply colorscheme '" .. colorscheme .. "': " .. cmd_err)
    return false
  end

  -- and re-enable the autocommands
  if autocmd_group then
    autocmd_group:restore()
  end

  return true
end

--- Callback function for file change events.
--
-- This function is called when a file change event is triggered. It handles
-- the event by reloading the colorscheme from the updated file. If there is an
-- error, it logs the error message and stops the event.
--
-- Parameters:
-- - err (string|nil) The error message, if any. If there is no error, this parameter is nil.
-- - filename (string) The name of the file that triggered the event.
-- - events (table) A table containing information about the events that occurred.
--
-- Returns:
-- None
--
-- Raises:
-- None
--
local function on_change(err, filename)
  vim.schedule(function()
    if err then
      -- If there's an error, notify and stop the event
      log:error("Error watching file " .. tostring(filename) .. ": " .. tostring(err))
      return
    end

    -- Reload the colorscheme from the updated file
    load_colorscheme()
  end)
end

--- Sets up the ColorSaver module with the provided options.
--
-- Parameters:
-- - opts (table): A table containing the options for configuring the ColorSaver module. The following keys are supported:
--   - filename (string): The name of the file where the colorscheme will be saved.
--   - log_level (string): The log level for the ColorSaver module.
--   - debounce_ms (number): The debounce time in milliseconds for saving the colorscheme.
--   - auto_load (boolean): Whether to enable autoloading of the colorscheme file.
--
-- Returns:
-- None
--
-- Raises:
-- None
--
-- This function sets up the ColorSaver module by performing the following steps:
-- 1. Extracts and validates the options provided.
-- 2. Sets up local data, including the file path for saving the colorscheme and a logger instance.
-- 3. Loads the colorscheme at startup.
-- 4. Captures the new colorscheme and saves it on the "ColorScheme" event.
-- 5. Sets up autoloading of the colorscheme file if enabled.
--
function M.setup(opts)
  -- Extract options and validate them
  M.config = config.setup(opts, log)

  -- Set up some local data
  color_file_path = vim.fn.stdpath("data") .. "/" .. M.config.filename
  log = logger.new(M.config.log_level, "colorsaver")

  -- Load the colorscheme at startup.
  load_colorscheme()

  -- Capture the new colorscheme and save it on the ColorScheme event.
  local debounced_save_colorscheme = utils.debounce(save_colorscheme, M.config.debounce_ms)
  autocmd_group = autocommands.new("ColorSaverGroup", {
    {
      events = { "ColorScheme" },
      patterns = { "*" },
      callback = function(info)
        vim.schedule(function()
          debounced_save_colorscheme(info.match) -- info.match is the colorscheme parameter (i.e. name)
        end)
      end,
    },
  })

  -- Setup autoloading if enabled
  if M.config.auto_load then
    local debounced_on_change = utils.debounce(on_change, M.config.debounce_ms)
    colorfile_watcher = file_watcher.new(color_file_path, debounced_on_change)
    colorfile_watcher:start()
  end
end

return M
