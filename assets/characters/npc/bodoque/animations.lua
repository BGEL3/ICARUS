return {
  file = 'assets/characters/npc/bodoque/poses.png',
  frameWidth = 512, frameHeight = 512, columns = 3, rows = 2,
  origin = { x = 256, y = 466 },
  fps = 12,
  poses = {
    idle = { column = 1, row = 1 },
    talking = { column = 2, row = 1 },
    gesturing = { column = 3, row = 1 },
    surprised = { column = 1, row = 2 },
    interaction = { column = 2, row = 2 },
    thoughtful = { column = 3, row = 2 },
  },
  note = 'Expression poses are a first pass; they are not a per-frame talking loop yet.',
}
