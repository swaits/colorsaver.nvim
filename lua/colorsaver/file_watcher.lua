-- file_watcher.lua
--- FileWatcher module for watching file system events.
-- This module provides the ability to watch for changes in a specified file and execute a callback when changes occur.
local FileWatcher = {}
FileWatcher.__index = FileWatcher

--- Constructor for the FileWatcher object.
-- @param path string The file system path to watch.
-- @param callback function The callback function to execute when a change is detected.
-- @return table The constructed FileWatcher object.
function FileWatcher.new(path, callback)
  -- Validate the input parameters to ensure correct types.
  assert(type(path) == "string", "Path must be a string")
  assert(type(callback) == "function", "Callback must be a function")

  -- Set up the FileWatcher object.
  local self = setmetatable({}, FileWatcher)
  self.path = path
  self.callback = callback
  -- Initialize the file system watcher with libuv.
  local uv = vim.uv or vim.loop
  self.fs_watcher = uv.new_fs_event()
  return self
end

--- Starts watching the file system event.
-- This method activates the file watcher, which will invoke the callback on file changes.
function FileWatcher:start()
  -- Ensure the file system watcher starts monitoring for changes.
  -- Empty options table and vim.schedule_wrap to ensure the callback is called in the main loop.
  self.fs_watcher:start(self.path, {}, vim.schedule_wrap(self.callback))
end

--- Stops watching the file system event.
-- This method deactivates the file watcher, preventing the callback from being invoked.
function FileWatcher:stop()
  -- If the watcher is active, stop it.
  if self.fs_watcher then
    self.fs_watcher:stop()
  end
end

--- Restarts watching the file system event.
-- This method stops and then restarts the file watcher.
function FileWatcher:restart()
  -- Stop and then start the watcher to refresh the monitoring.
  self:stop()
  self:start()
end

return FileWatcher
