-- Gameplay geometry is deliberately separate from the painted room backdrop.
return {
  width = 1080,
  height = 620,
  walkableDiamond = { halfWidth = 520, halfHeight = 292 },
  solids = {
    { x = -365, y = 102, radius = 42, kind = 'broken_column' },
    { x = 340, y = 125, radius = 38, kind = 'broken_column' },
    { x = -438, y = -154, radius = 32, kind = 'crate' },
    { x = 426, y = -97, radius = 34, kind = 'crate' },
    { x = 350, y = 0, radius = 26, kind = 'bodoque' },
  },
  exits = { { x = -100, y = -180, radius = 42, kind = 'ascending_gate' } },
  bodoque = { x = 350, y = 0, radius = 46 },
}
