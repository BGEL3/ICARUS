local Map = require('assets.maps.arena.map')
local Arena = {}

local function clampToDiamond(x, y, radius)
  local halfWidth = Map.walkableDiamond.halfWidth - radius
  local halfHeight = Map.walkableDiamond.halfHeight - radius
  local amount = math.abs(x) / halfWidth + math.abs(y) / halfHeight
  if amount > 1 then x, y = x / amount, y / amount end
  return x, y
end

function Arena.resolve(x, y, radius)
  radius = radius or 0
  x, y = clampToDiamond(x, y, radius)
  for _ = 1, 2 do
    for _, solid in ipairs(Map.solids) do
      local dx, dy = x - solid.x, y - solid.y
      local distance = math.sqrt(dx * dx + dy * dy)
      local minimum = radius + solid.radius
      if distance < minimum then
        if distance < 0.001 then dx, dy, distance = 1, 0, 1 end
        local push = (minimum - distance) / distance
        x, y = x + dx * push, y + dy * push
        x, y = clampToDiamond(x, y, radius)
      end
    end
  end
  return x, y
end

function Arena.isInside(x, y, radius)
  radius = radius or 0
  local w = Map.walkableDiamond.halfWidth - radius
  local h = Map.walkableDiamond.halfHeight - radius
  if math.abs(x) / w + math.abs(y) / h > 1 then return false end
  for _, solid in ipairs(Map.solids) do
    local dx, dy = x - solid.x, y - solid.y
    if dx * dx + dy * dy < (radius + solid.radius) ^ 2 then return false end
  end
  return true
end

function Arena.nearestFree(x, y, radius)
  return Arena.resolve(x, y, radius)
end

Arena.map = Map
return Arena
