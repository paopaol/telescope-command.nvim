local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

function M.command(opts)
  print(vim.inspect(opts))
  local default_action = function(selection)
    print(selection)
  end
  local default_opts = {
    entry_maker = function(entry)
      return {
        value = entry,
        display = function(display_entry)
          return display_entry.value
        end,
        ordinal = entry,
      }
    end,
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        opts.selected_action(selection)
      end)
      return true
    end,
  }
  opts.entry_maker = opts.entry_maker or default_opts.entry_maker
  if not opts.cmd then
    vim.notify('command must set, like opts.cmd = {\'fd\', \'-e\', \'cpp\'}', vim.log.levels.ERROR)
    return
  end
  opts.selected_action = opts.selected_action or default_action
  opts.attach_mappings = opts.attach_mappings or default_opts.attach_mappings

  pickers.new(opts, {
    prompt_title = "Command",
    finder = finders.new_oneshot_job(opts.cmd, opts),
    previewer = conf.grep_previewer(opts),
    sorter = conf.file_sorter(opts),
  }):find()
end

return require("telescope").register_extension({
  exports = {
    command = M.command,
  },
})
