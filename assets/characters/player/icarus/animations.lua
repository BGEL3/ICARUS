return {
  frameWidth = 320,
  frameHeight = 320,
  fps = 12,
  origin = { x = 160, y = 292 },
  directionOrder = { 'north', 'east', 'south', 'west' },
  sourceRows = {
    run = { north = 'source row 1', east = 'mirrored source row 2',
      south = 'source row 2', west = 'mirrored source row 1' },
    idle = { north = 'source row 1', east = 'mirrored source row 3',
      south = 'source row 3', west = 'mirrored source row 1' },
  },
  directions = {
    north = { row = 1, screenAxis = 'upper-right' },
    east  = { row = 2, screenAxis = 'lower-right' },
    south = { row = 3, screenAxis = 'lower-left' },
    west  = { row = 4, screenAxis = 'upper-left' },
  },
  run = { file = 'assets/characters/player/icarus/run.png', columns = 8, rows = 4, loop = true },
  idle = { file = 'assets/characters/player/icarus/idle.png', columns = 6, rows = 4, loop = true },
  windAttack = {
    frameWidth = 384, frameHeight = 384, columns = 4, rows = 2, frames = 8, fps = 12,
    origin = { x = 192, y = 352 }, loop = false,
    files = {
      north = 'assets/characters/player/icarus/wind_attack_north.png',
      east = 'assets/characters/player/icarus/wind_attack_east.png',
      south = 'assets/characters/player/icarus/wind_attack_south.png',
      west = 'assets/characters/player/icarus/wind_attack_west.png',
    },
  },
}
