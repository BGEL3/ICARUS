local Dialogue = {}
Dialogue.__index = Dialogue

local lines = {
  'Bienvenido al Atrio de la ceniza. La torre siempre cobra un precio por cada peldaño.',
  'Vi pasar a un guardián por el arco verde. No mires sus ojos cuando despierte.',
  'Esa reliquia tiene hambre de sol. Guárdala cerca, y no confíes en su brillo.',
  'Las piedras recuerdan a quienes suben. Las antorchas recuerdan a quienes caen.',
  'Las plumas no te llevarán hasta el sol, Ícaro. Tus pasos sí pueden hacerlo.',
  'Una puerta abierta no significa que la sala esté vacía. Escucha antes de cruzar.',
  'Más arriba, las sombras proyectan su propio amanecer. No es el tuyo.',
  'Ya casi puedes sentir el calor. Asegúrate de que sea el sol y no la torre.',
  'El último guardián protege algo más antiguo que la luz. Decide qué buscas.',
}

function Dialogue.new()
  return setmetatable({ active = false, text = '', visible = 0, index = 1, portrait = 'talking' }, Dialogue)
end

function Dialogue:start(roomIndex)
  self.text = lines[roomIndex] or lines[1]
  self.visible, self.active, self.index = 0, true, roomIndex
  self.portrait = roomIndex % 3 == 0 and 'surprised' or 'talking'
end

function Dialogue:update(dt)
  if self.active then
    self.visible = math.min(#self.text, self.visible + dt * 42)
    if self.visible >= #self.text then self.portrait='thoughtful' end
  end
end

function Dialogue:advance()
  if self.visible < #self.text then
    self.visible = #self.text
    return
  end
  self.active = false
end

return Dialogue
