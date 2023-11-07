--- Logger module for neovim that provides a simple logging interface.
-- @module Logger
local Logger = {}
Logger.__index = Logger

--- Log levels with corresponding neovim's vim.log.levels.
local log_levels = {
  debug = vim.log.levels.DEBUG,
  info = vim.log.levels.INFO,
  warn = vim.log.levels.WARN,
  error = vim.log.levels.ERROR,
}

--- Constructor for Logger object.
-- @param min_level The minimum log level to output messages for.
-- @param prefix A prefix to prepend to all log messages.
-- @return A new Logger instance with specified level and prefix.
function Logger.new(min_level, prefix)
  local self = setmetatable({}, Logger)
  self.min_level = log_levels[min_level] or log_levels.info -- Fallback to info level if unspecified
  self.prefix = prefix or "Logger" -- Default prefix if none provided
  return self
end

--- Sets the minimum log level.
-- Only log messages at this level or higher will be output.
-- @param min_level The minimum log level string ("debug", "info", "warn", "error").
function Logger:set_level(min_level)
  self.min_level = log_levels[min_level] or self.min_level -- Keep current level if the new level is invalid
end

--- Internal function to process the log message.
-- @param level The log level of the message.
-- @param message The log message.
function Logger:_log(level, message)
  if level >= self.min_level then
    vim.notify(self.prefix .. ": " .. message, level)
  end
end

--- Logs a message at DEBUG level.
-- @param message The message to log.
function Logger:debug(message)
  self:_log(log_levels.debug, "DEBUG: " .. message)
end

--- Logs a message at INFO level.
-- @param message The message to log.
function Logger:info(message)
  self:_log(log_levels.info, "INFO: " .. message)
end

--- Logs a message at WARN level.
-- @param message The message to log.
function Logger:warn(message)
  self:_log(log_levels.warn, "WARN: " .. message)
end

--- Logs a message at ERROR level.
-- @param message The message to log.
function Logger:error(message)
  self:_log(log_levels.error, "ERROR: " .. message)
end

return Logger
