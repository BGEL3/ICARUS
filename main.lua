local Game=require('src.game')
local Render=require('src.render')
local UI=require('src.ui')
local mode='menu';local choice=1;local game;local menu;local gallery={};local artIndex=1;local fullscreen=false
local function start() game=Game.new();mode='game' end
function love.load()
 love.graphics.setDefaultFilter('nearest','nearest');love.keyboard.setKeyRepeat(false)
 love.graphics.setFont(love.graphics.newFont(17))
 Render.load();UI.load()
 menu=love.graphics.newImage('assets/menu_reference.png');menu:setFilter('nearest','nearest')
 for _,path in ipairs({'gameplay_reference','characters_reference','items_reference','blessings_reference'}) do
  local im=love.graphics.newImage('assets/concept/'..path..'.png');im:setFilter('nearest','nearest');gallery[#gallery+1]=im
 end
end
function love.keypressed(key)
 if key=='f11' then fullscreen=not fullscreen;love.window.setFullscreen(fullscreen);return end
 if mode=='menu' then
  if key=='w' or key=='up' or key=='s' or key=='down' then choice=3-choice end
  if key=='return' or key=='kpenter' or key=='space' then if choice==1 then start() else mode='settings' end end
  if key=='g' then mode='gallery' end
 elseif mode=='gallery' then
  if key=='escape' then mode='menu' end
  if key=='a' or key=='left' then artIndex=(artIndex-2+#gallery)%#gallery+1 end
  if key=='d' or key=='right' then artIndex=artIndex%#gallery+1 end
 elseif mode=='settings' then
  if key=='escape' or key=='return' or key=='backspace' then mode='menu' end
 elseif mode=='game' then
  if key=='escape' then mode='menu';return end
  if game.state=='reward' then
   if key=='j' then game:moveSelection(-1) end
   if key=='k' then game:moveSelection(1) end
   if key=='l' or key=='space' then game:pick() end
  elseif game.state=='clear' then
   if key=='e' or key=='return' then game:nextRoom() end
  elseif game.state=='dead' or game.state=='victory' then
   if key=='return' then start() end
  elseif game.state=='fight' then
   if key=='j' then game:shoot() end
   if key=='k' then game:flame() end
   if key=='i' then game:incinerate() end
   if key=='l' then game:cycleLock() end
   if key=='o' then game:toggleFocus() end
   if key=='h' then game:parry() end
   if key=='space' or key=='lshift' or key=='rshift' then game:dash() end
  end
 end
end
function love.update(dt)
 if mode=='game' and game then game:update(dt) end
end
local function fit(img,w,h)
 local sx,sy=w/img:getWidth(),h/img:getHeight();local s=math.min(sx,sy)
 local x=(w-img:getWidth()*s)/2;local y=(h-img:getHeight()*s)/2
 love.graphics.setColor(1,1,1);love.graphics.draw(img,x,y,0,s,s)
end
function love.draw()
 local w,h=love.graphics.getDimensions()
 Render.background(w,h,love.timer.getTime())
 if mode=='menu' then
  fit(menu,w,h)
  local yy=(choice==1 and .545 or .743)*h
  love.graphics.setColor(1,.72,.24);love.graphics.polygon('fill',w*.028,yy,w*.047,yy-10,w*.047,yy+10)
  love.graphics.setColor(.025,.02,.045,.90);love.graphics.rectangle('fill',0,h-51,w,51)
  love.graphics.setColor(1,.81,.54);love.graphics.print('W/S: elegir   ENTER: confirmar   G: galeria visual   F11: pantalla completa',25,h-36)
 elseif mode=='settings' then
  local lines={'CONTROLES — SOLO TECLADO','WASD mover y definir dirección si no hay objetivo','J: pluma ígnea   K: llamarada en área','I: pagar 1 HP; fuego x2 durante 6 s; recarga 12 s','O: autoenfoque   L: fijar/rotar enemigo','H: parry breve   SHIFT / ESPACIO: esquivar','E: ascender   RELIQUIAS: J/K cambiar; L elegir','ESC: título    F11: pantalla completa   ENTER: volver'}
  for i,s in ipairs(lines) do love.graphics.setColor(1,.77,.53);love.graphics.print(s,90,70+(i-1)*55,0,i==1 and 1.7 or 1.05,i==1 and 1.7 or 1.05) end
 elseif mode=='gallery' then
  fit(gallery[artIndex],w,h-42)
  love.graphics.setColor(.025,.02,.04,.92);love.graphics.rectangle('fill',0,h-42,w,42)
  love.graphics.setColor(1,.82,.57);love.graphics.print('GALERIA '..artIndex..' / '..#gallery..'   A/D: cambiar imagen    ESC: titulo',28,h-30)
 elseif game then
  Render.drawWorld(game,w,h);UI.draw(game,w,h)
 end
end
