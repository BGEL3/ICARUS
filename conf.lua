function love.conf(t)
  t.identity = 'icaro_torre_ocaso'
  t.window.title = 'ICARUS | La Torre del Ocaso — Prototipo 0.1'
  t.window.width, t.window.height = 1280, 720
  t.window.resizable = true
  t.window.minwidth, t.window.minheight = 960, 540
  t.window.vsync = 1
  t.modules.physics = false
end
