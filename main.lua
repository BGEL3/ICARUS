local Game=require('src.game')
local Render=require('src.render')
local UI=require('src.ui')
local Dialogue=require('src.dialogue')
local mode='menu'
local choice=1
local game
local dialogue
local image
local musicEnabled=true
local fullscreen=false
local fonts={}
local function begin() game=Game.new();dialogue=Dialogue.new();mode='game' end
function love.load()
 love.graphics.setDefaultFilter('nearest','nearest')
 fonts.base=love.graphics.newFont(17)
 love.graphics.setFont(fonts.base)
 local ok,result=pcall(love.graphics.newImage,'assets/ui/menu/background.png')
 if ok then image=result;image:setFilter('nearest','nearest') end
 Render.load();UI.load()
 love.keyboard.setKeyRepeat(false)
end
function love.resize() end
function love.keypressed(key)
 if key=='f11' then fullscreen=not fullscreen;love.window.setFullscreen(fullscreen);return end
 if mode=='menu' then
  if key=='up' or key=='w' or key=='down' or key=='s' then choice=3-choice end
  if key=='return' or key=='kpenter' or key=='space' then
   if choice==1 then begin() else mode='settings' end
  end
 elseif mode=='settings' then
  if key=='escape' or key=='return' or key=='backspace' then mode='menu' end
  if key=='m' then musicEnabled=not musicEnabled end
 elseif mode=='pause' then
  if key=='escape' or key=='p' or key=='return' then mode='game' end
  if key=='backspace' then mode='menu' end
 elseif mode=='inventory' then
  if key=='i' or key=='escape' then mode='game' end
 elseif mode=='game' then
  if dialogue and dialogue.active then
   if key=='e' or key=='return' or key=='space' then dialogue:advance();game.bodoqueTalking=dialogue.active end
   return
  end
  if (game.state=='dead' or game.state=='victory') and key=='escape' then mode='menu';return end
  if key=='escape' or key=='p' then mode='pause';return end
  if key=='i' then mode='inventory';return end
  if key=='e' and game:nearBodoque() and game.state~='reward' and game.state~='dead' and game.state~='victory' then
   dialogue:start(game.roomIndex);game.bodoqueTalking=true;return
  end
  if game.state=='reward' then
   if key=='1' or key=='2' or key=='3' then game:pick(tonumber(key)) end
  elseif game.state=='clear' and key=='e' then game:nextRoom()
  elseif game.state=='dead' or game.state=='victory' then
   if key=='return' then begin() elseif key=='escape' then mode='menu' end
  elseif game.state=='fight' then
   if key=='lshift' or key=='rshift' then game:dash() end
   if key=='space' then game:active() end
  end
 end
end
function love.update(dt)
 Render.update(dt)
 if mode=='game' and game then
  if dialogue and dialogue.active then dialogue:update(dt)
  else game:update(dt) end
 end
end
function love.draw()
 local w,h=love.graphics.getDimensions()
 Render.background(w,h,love.timer.getTime())
 if mode=='menu' then
  Render.drawMenu(image,w,h,choice,love.timer.getTime())
 elseif mode=='settings' then
  Render.text(110,90,'AJUSTES',2,{1,.7,.28})
  Render.text(110,167,'El juego se controla completamente con teclado.',1.1)
  Render.text(110,212,'WASD: movimiento    FLECHAS: disparar en 4 ejes iso',1.1)
  Render.text(110,257,'SHIFT: esquiva       ESPACIO: pulso solar',1.1)
  Render.text(110,302,'E: hablar / ascender    1 / 2 / 3: elegir reliquias',1.1)
  Render.text(110,347,'I: inventario       ESC / P: pausa',1.1)
  Render.text(110,392,'F11: pantalla completa',1.1)
  Render.text(110,458,'M: sonido ['..(musicEnabled and 'SI' or 'NO')..'] (audio aun no implementado)',.95)
  Render.text(110,510,'ENTER o ESC: volver al menu',1.05,{1,.7,.28})
 elseif game then
  Render.drawWorld(game,w,h)
  UI.draw(game,w,h)
  if dialogue then Render.drawDialogue(w,h,dialogue) end
  if mode=='pause' or mode=='inventory' then
   love.graphics.setColor(.04,.025,.07,.75);love.graphics.rectangle('fill',0,0,w,h)
   if mode=='inventory' then UI.inventory(game,w,h) else
    UI.centerPanel(w,h,'PAUSA',{'ESC o P: continuar', 'BACKSPACE: menu principal'})
   end
  end
 end
end
