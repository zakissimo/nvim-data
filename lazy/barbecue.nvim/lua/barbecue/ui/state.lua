local VAR_WAS_AFFECTED = "barbecue_was_affected"
local VAR_LAST_WINBAR = "barbecue_last_winbar"
local VAR_ENTRIES = "barbecue_entries"

---@class barbecue.State
---@field private winnr number Window to figure out current state from.
---@field private bufnr number Buffer to store the state in.
local State = {}
State.__index = State

---Creates a new State.
---
---@param winnr number Window to attach to.
---@return barbecue.State
function State.new(winnr)
  local instance = setmetatable({}, State)

  instance.winnr = winnr
  instance.bufnr = vim.api.nvim_win_get_buf(winnr)

  return instance
end

---Get the last unaffected winbar value.
---
---@return string|nil
function State:get_last_winbar()
  local was_affected_ok, was_affected =
    pcall(vim.api.nvim_buf_get_var, self.bufnr, VAR_WAS_AFFECTED)
  if not was_affected_ok or not was_affected then return nil end

  local last_winbar_ok, last_winbar =
    pcall(vim.api.nvim_buf_get_var, self.bufnr, VAR_LAST_WINBAR)

  return last_winbar_ok and last_winbar or nil
end

---Get the latest generated entries.
---
---@return barbecue.Entry[]|nil
function State:get_entries()
  local serialized_entries_ok, serialized_entries =
    pcall(vim.api.nvim_buf_get_var, self.bufnr, VAR_ENTRIES)
  if not serialized_entries_ok then return nil end

  return vim.json.decode(serialized_entries)
end

---Clear unnecessary variables.
function State:clear()
  local was_affected_ok, was_affected =
    pcall(vim.api.nvim_buf_get_var, self.bufnr, VAR_WAS_AFFECTED)

  if was_affected_ok and was_affected then
    vim.api.nvim_buf_del_var(self.bufnr, VAR_WAS_AFFECTED)
  end
end

---Save the current state.
---
---@param entries barbecue.Entry[] Entries to be saved.
function State:save(entries)
  local was_affected_ok, was_affected =
    pcall(vim.api.nvim_buf_get_var, self.bufnr, VAR_WAS_AFFECTED)

  if not was_affected_ok or not was_affected then
    vim.api.nvim_buf_set_var(self.bufnr, VAR_WAS_AFFECTED, true)
    vim.api.nvim_buf_set_var(
      self.bufnr,
      VAR_LAST_WINBAR,
      vim.wo[self.winnr].winbar
    )
  end

  local serialized_entries = vim.json.encode(vim.tbl_map(function(entry)
    local clone = vim.deepcopy(entry)
    return setmetatable(clone, nil)
  end, entries))
  vim.api.nvim_buf_set_var(self.bufnr, VAR_ENTRIES, serialized_entries)
end

return State
