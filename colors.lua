
function colors_from_base(...)
  local base = { ... }
  local result = { }
  for _, cname in pairs(base) do
    result[ cname ] = Color[Color[cname]]
  end
end

-- custom color aliases -- semantic names not allowed!
-- (semantic belongs to styles)
COLORS = colors_from_base("white", "blue", "red", "green", "yellow", "black" )
COLORS.cyan = { 0, 0.5, 0.5 }
COLORS.orange = { 1, 0.25, 0 }
COLORS.obsidian = { 0.1, 0.1, 0.1 }
COLORS.metallic = { 0.3, 0.3, 0.3 }
COLORS.mocha = { 0.15, 0.12, 0 }
COLORS.gold = { 0.90, 0.70, 0.10 }
COLORS.silver = { 0.75, 0.75, 0.75 }
COLORS.crimson = { 0.90, 0.22, 0.27 }
COLORS.ruby = { 0.76, 0.07, 0.12 }
COLORS.azure = {0.20, 0.45, 0.85}
COLORS.denim = {0.10, 0.25, 0.65}

