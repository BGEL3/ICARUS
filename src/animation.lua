local Animation = {}
Animation.__index = Animation

function Animation.new(image, columns, rows, fps, loop, frameWidth, frameHeight)
  local self = setmetatable({}, Animation)
  self.image = image
  self.columns, self.rows = columns, rows
  self.fps, self.loop = fps or 12, loop ~= false
  self.frameWidth = frameWidth or image:getWidth() / columns
  self.frameHeight = frameHeight or image:getHeight() / rows
  self.frames, self.elapsed, self.finished = columns * rows, 0, false
  self.quads = {}
  for row = 1, rows do
    self.quads[row] = {}
    for column = 1, columns do
      self.quads[row][column] = love.graphics.newQuad(
        (column - 1) * self.frameWidth, (row - 1) * self.frameHeight,
        self.frameWidth, self.frameHeight, image:getDimensions())
    end
  end
  return self
end

function Animation:update(dt)
  if not self.loop and self.finished then return end
  self.elapsed = self.elapsed + dt
  if not self.loop and self.elapsed >= self.frames / self.fps then
    self.elapsed = self.frames / self.fps
    self.finished = true
  end
end

function Animation:reset()
  self.elapsed, self.finished = 0, false
end

function Animation:frame()
  local frame = math.floor(self.elapsed * self.fps) + 1
  return math.max(1, math.min(frame, self.frames))
end

function Animation:draw(x, y, scale, originX, originY, row, frame)
  local column
  if frame then
    local index = math.max(1, math.min(frame, self.frames)) - 1
    row, column = math.floor(index / self.columns) + 1, index % self.columns + 1
  else
    row = math.max(1, math.min(row or 1, self.rows))
    column = (self:frame() - 1) % self.columns + 1
  end
  love.graphics.draw(self.image, self.quads[row][column], x, y, 0,
    scale or 1, scale or 1, originX or self.frameWidth / 2, originY or self.frameHeight / 2)
end

return Animation
