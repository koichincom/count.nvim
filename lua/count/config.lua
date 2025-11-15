local M = {}

M.table = {}

M.bool = function(value)
    return type(value) == "boolean"
end

return M
