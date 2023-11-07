-- config.lua
--- Configuration module for handling user settings and defaults.
-- This module provides validation and fallbacks for user-specified configuration.
local M = {}

--- Define default configuration values with inline documentation.
-- These defaults are used as a fallback if the user does not provide these settings or if they are invalid.
local defaults = {
  --- log_level: Sets the logging level for the module's output.
  -- @field log_level Acceptable values are "debug", "info", "warn", "error".
  log_level = "warn",

  --- debounce_ms: Sets the debounce time in milliseconds for file watching.
  -- @field debounce_ms Accepts any integer greater than or equal to 50. If experiencing issues, consider increasing this value.
  debounce_ms = 100,

  --- filename: The name of the file where the colorscheme will be saved.
  -- @field filename Note that the file is always stored in the "data" directory, which is usually ~/.local/share/nvim/
  filename = "colorsaver",

  --- auto_load: If true, any colorscheme changes from one instance of nvim will be automatically loaded by all other instances of nvim.
  -- @field auto_load
  auto_load = true,
}

--- Validates the logging level.
-- @param level string The log level to validate.
-- @return boolean Whether the log level is valid.
local function is_log_level_valid(level)
  local valid_levels = { debug = true, info = true, warn = true, error = true }
  return valid_levels[level:lower()] ~= nil
end

--- Validates the debounce time.
-- @param ms number The debounce time in milliseconds to validate.
-- @return boolean Whether the debounce time is valid.
local function is_debounce_ms_valid(ms)
  return type(ms) == "number" and ms >= 50
end

--- Validates the filename.
-- @param name string The filename to validate.
-- @return boolean Whether the filename is valid.
local function is_filename_valid(name)
  return type(name) == "string" and name ~= ""
end

--- Validates the auto_load value.
-- @param value boolean The auto_load value to validate.
-- @return boolean Whether the auto_load is valid.
local function is_auto_load_valid(value)
  return type(value) == "boolean"
end

--- Checks for invalid keys in the user configuration and logs a warning for each.
-- @param user_config table The user configuration to check.
local function check_for_invalid_keys(user_config)
  for key, _ in pairs(user_config) do
    if defaults[key] == nil then
      log:warn("Ignoring invalid configuration key '" .. key .. "'.")
      user_config[key] = nil
    end
  end
end

--- Merges user configuration with defaults and validates the result.
-- @param user_config table The user-specified configuration.
-- @param logger table The logger instance to be used for logging messages.
-- @return table The validated and merged configuration.
function M.setup(user_config, logger)
  -- Store the logger after ensuring it's provided.
  assert(logger, "Logger instance must be provided for configuration setup.")
  log = logger

  -- Check if the provided user_config is a table.
  if user_config ~= nil and type(user_config) ~= "table" then
    log:error("Provided user_config must be a table")
    return
  end

  -- Remove invalid keys from the user configuration.
  check_for_invalid_keys(user_config or {})

  -- Deeply merge the defaults with the user configuration, prioritizing user settings.
  local config = vim.tbl_deep_extend("force", {}, defaults, user_config or {})

  -- Validate and apply individual configuration settings.
  config.log_level = is_log_level_valid(config.log_level) and config.log_level or defaults.log_level
  config.debounce_ms = is_debounce_ms_valid(config.debounce_ms) and config.debounce_ms
    or defaults.debounce_ms
  config.filename = is_filename_valid(config.filename) and config.filename or defaults.filename
  config.auto_load = is_auto_load_valid(config.auto_load) and config.auto_load or defaults.auto_load

  -- Return the validated and potentially corrected configuration.
  return config
end

return M
