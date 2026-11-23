local Iso = {}

-- World X/Y axes project onto the four visible directions of the isometric diamond.
Iso.xRatio, Iso.yRatio = 0.72, 0.40

function Iso.toScreen(x, y)
  return (x - y) * Iso.xRatio, (x + y) * Iso.yRatio
end

function Iso.depth(x, y)
  return x + y
end

function Iso.direction(x, y)
  if math.abs(x) > math.abs(y) then
    return x >= 0 and 'east' or 'west'
  end
  return y < 0 and 'north' or 'south'
end

function Iso.vector(direction)
  if direction == 'east' then return 1, 0 end
  if direction == 'south' then return 0, 1 end
  if direction == 'west' then return -1, 0 end
  return 0, -1
end

return Iso
