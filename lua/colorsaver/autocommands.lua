-- autocommands.lua
--- AutocommandGroup module for managing groups of autocommands in Neovim.
-- This module encapsulates the creation and management of autocommand groups and their definitions.
local AutocommandGroup = {}
AutocommandGroup.__index = AutocommandGroup

--- Constructor for creating a new AutocommandGroup.
-- @param name string The name of the autocommand group.
-- @param definitions table A table of autocommand definitions.
-- @return table A new instance of AutocommandGroup.
function AutocommandGroup.new(name, definitions)
  -- Validate that 'name' is provided and is a string.
  assert(type(name) == "string", "Autocommand group name must be a string")

  -- Create an instance of AutocommandGroup and set its properties.
  local self = setmetatable({}, AutocommandGroup)
  self.name = name
  self.definitions = definitions or {}
  -- Create a new autocommand group in Neovim, clearing any existing autocommands in the group.
  self.group_id = vim.api.nvim_create_augroup(name, { clear = true })
  -- Set or update the autocommand definitions for the group.
  self:set_definitions(self.definitions)
  return self
end

--- Sets or updates the autocommand definitions for the group.
-- @param definitions table The autocommand definitions to set or update.
function AutocommandGroup:set_definitions(definitions)
  -- Validate that 'definitions' is a table.
  assert(type(definitions) == "table", "Autocommand definitions must be a table")

  -- Clear existing autocommands from the group to prepare for new definitions.
  vim.api.nvim_clear_autocmds({ group = self.group_id })

  -- Iterate over each definition and create an autocommand.
  for _, def in ipairs(definitions) do
    -- Perform checks to ensure the definition structure is valid.
    assert(def.events, "Autocommand definition is missing 'events' key")
    assert(
      type(def.events) == "string" or type(def.events) == "table",
      "'events' must be a string or a table"
    )
    assert(def.patterns, "Autocommand definition is missing 'patterns' key")
    assert(
      type(def.patterns) == "string" or type(def.patterns) == "table",
      "'patterns' must be a string or a table"
    )
    assert(
      def.callback or def.command,
      "Autocommand definition must have either 'callback' or 'command'"
    )

    -- Check for 'callback' and 'command' specifics and validate their types.
    if def.callback then
      assert(type(def.callback) == "function", "'callback' must be a function")
    end

    if def.command then
      assert(type(def.command) == "string", "'command' must be a string")
    end

    -- Validate optional keys if they are present.
    if def.once then
      assert(type(def.once) == "boolean", "'once' must be a boolean")
    end

    if def.nested then
      assert(type(def.nested) == "boolean", "'nested' must be a boolean")
    end

    -- Create the autocommand in Neovim with the provided definition.
    vim.api.nvim_create_autocmd(def.events, {
      group = self.group_id,
      pattern = def.patterns,
      callback = def.callback,
      command = def.command,
      once = def.once,
      nested = def.nested,
    })
  end

  -- Update the stored definitions.
  self.definitions = definitions
end

--- Clears the autocommand group, effectively disabling all its autocommands.
function AutocommandGroup:clear()
  -- Clear all autocommands associated with the group in Neovim.
  vim.api.nvim_clear_autocmds({ group = self.group_id })
end

--- Restores the autocommand group using the stored definitions.
function AutocommandGroup:restore()
  -- Reapply the stored autocommand definitions.
  self:set_definitions(self.definitions)
end

-- Module table for exporting the constructor.
local M = {
  new = AutocommandGroup.new,
}

return M
