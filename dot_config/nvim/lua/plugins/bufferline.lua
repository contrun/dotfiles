require('bufferline')

-- format as "<id>. <file-name>"
local tabname_format =
function(opts) return string.format('%s.', opts.ordinal) end

require('bufferline').setup({
  options = {
    always_show_bufferline = false,
    numbers = tabname_format,
    show_buffer_icons = true,
    separator_style = 'slant',
    -- Don't show bufferline over vertical, unmodifiable buffers
    offsets = {
      {
        filetype = 'NvimTree',
        text = 'File Explorer',
        highlight = 'Directory'
      }
    }
  },
  custom_areas = {
    right = function()
      local result = { { text = "Buffers", guifg = "#ffffff" } }
      return result
    end
  },
  -- Don't use italic on current buffer
  highlights = { buffer_selected = { gui = "bold" } }
})
