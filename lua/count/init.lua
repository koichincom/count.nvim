local M = {}

M.setup = function(options)
    local bytes_default = {}
end

M.bytes = function(options)
    bytes_default = {
        object = 0,
        visual = false,
        cursor = {
            direction = false,
            unit = "byte",
            include_cursor = false,
        },
        filetype = false,
        ignore = {},
        custom_ignore = {},
    }
    for key, value in pairs(default) do
        if options[key] == nil then
            options[key] = value
        end
    end
end

M.chars = function(options) end
M.words = function(options) end
M.lines = function(options) end
M.sentences = function(options) end
M.paragraphs = function(options) end
M.read = function(options) end
M.custom = function(options) end

-- Each functiont take some of the keys from the below
local example = {
    object = 0, -- 0, specific bufnr, or specific text
    visual = { "all" }, -- select from "all", "char", "line", "block", or false.
    -- "all" or false will override other values, and false is stronger
    cursor = {
        direction = false, -- "forward" or "backward" or false
        unit = "char", -- "char", "word", "line", or "sentence"
        include_cursor = false, -- whether to include the unit under the cursor
    },
    filetype = nil, -- specific filetype or nil for auto detect
    ignore = {}, -- charactristics to ignore by overriding the defaults
    -- "frontmatter", "code-comments", ""
    custom_ignore = {}, -- custom strings to ignore
    -- TODO: Comprehensive ignore options
    -- TODO: Language could be mixed
}

return M
