function randomBetween()
    local min = 1
    local max = 5
    local rand = math.random(min,max)
    return rand
end
-- materialColors = {
--     ["1"] = Color.cyan,
--     ["2"] = Color.red,
--     ["3"] = Color.yellow,
--     ["4"] = Color.blue,
--     ["5"] = Color.white,
-- }
-- local mt_materialColors = {
--     __len = function(tbl)
--         local count = 0
--         for _ in pairs(tbl) do
--             count += 1
--         end
--         return count
--     end
-- }
-- setmetatable(materialColors, mt_materialColors)
