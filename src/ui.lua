local UI={}
local Items=require('src.items')
local iconFiles={
 twin='wing_charm.png',ember='phoenix_ember.png',pierce='sun_feather.png',haste='laurel.png',
 damage='obsidian_mirror.png',rate='sunstone.png',vitality='laurel.png',frost='wind_talisman.png',
 echo='hourglass.png',dash='wing_charm.png',solar='sunstone.png',blood='obsidian_mirror.png',
}
local icons={}
local frames={}
local function txt(t,x,y,s,r,g,b)
 love.graphics.setColor(r or .96,g or .86,b or .73)
 love.graphics.print(t,x,y,0,s or 1,s or 1)
end
local function frame(x,y,w,h)
 love.graphics.setColor(.055,.045,.10,.94);love.graphics.rectangle('fill',x,y,w,h,9)
 love.graphics.setColor(.72,.43,.25,.85);love.graphics.setLineWidth(2)
 love.graphics.rectangle('line',x,y,w,h,9)
end
function UI.load()
 for id,file in pairs(iconFiles) do
  local ok,img=pcall(love.graphics.newImage,'assets/effects/relics/individual/'..file)
  if ok then img:setFilter('nearest','nearest');icons[id]=img end
 end
 for id,file in pairs({room='room_panel.png',stamina='health_bar.png',portrait='portrait_frame.png'}) do
  local ok,img=pcall(love.graphics.newImage,'assets/ui/hud/frames/'..file)
  if ok then img:setFilter('nearest','nearest');frames[id]=img end
 end
end
local function relicIcon(id,x,y,size)
 local img=icons[id]
 if img then
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(img,x,y,0,size/img:getWidth(),size/img:getHeight())
 else
  love.graphics.setColor(.15,.10,.17,1);love.graphics.rectangle('fill',x,y,size,size,4)
  love.graphics.setColor(1,.68,.28,1);love.graphics.rectangle('line',x,y,size,size,4)
 end
end
function UI.hud(g,w,h)
 local p=g.player
 if frames.portrait then
  love.graphics.setColor(1,1,1,1);love.graphics.draw(frames.portrait,18,16,0,96/frames.portrait:getWidth(),96/frames.portrait:getHeight())
 end
 frame(117,18,269,69)
 txt('ICARO  /  TORRE DEL OCASO',130,27,1.02)
 txt('VIDA  '..p.hp..' / '..p.maxHp,130,52,.76,1,.73,.61)
 for i=1,p.maxHp do
  local col=i<=p.hp and {.92,.17,.25} or {.20,.15,.22}
  love.graphics.setColor(col);love.graphics.circle('fill',205+(i-1)*20,59,6)
 end
 if frames.stamina then
  love.graphics.setColor(1,1,1,1);love.graphics.draw(frames.stamina,116,90,0,270/frames.stamina:getWidth(),51/frames.stamina:getHeight())
 end
 txt('RESISTENCIA',129,91,.68,.78,.69,.62)
 love.graphics.setColor(.10,.065,.075,1);love.graphics.rectangle('fill',130,119,227,10)
 love.graphics.setColor(.83,.52,.23,1);love.graphics.rectangle('fill',130,119,227*(p.stamina/p.maxStamina),10)
 if frames.room then love.graphics.setColor(1,1,1,1);love.graphics.draw(frames.room,w-267,7,0,248/frames.room:getWidth(),136/frames.room:getHeight())
 else frame(w-267,18,248,99) end
 txt('PISO '..g.room.floor..'  |  SALA '..g.roomIndex..'/9',w-174,28,.92)
 txt(g.room.name,w-174,58,.82)
 txt('MONEDAS  '..(p.coins or 0),w-174,88,.75,1,.73,.36)
 frame(18,h-100,530,77)
 txt('WASD mover   FLECHAS disparar',33,h-85)
 txt('SHIFT esquivar   ESPACIO poder   E hablar / puerta',33,h-58)
 frame(w-311,h-151,292,128)
 txt('PODER SOLAR  '..p.charge..'/'..p.maxCharge,w-292,h-137,.9,1,.72,.34)
 local owned={}
 for _,item in ipairs(Items.catalog) do
  if p.items[item.id] and #owned<3 then owned[#owned+1]={id=item.id,count=p.items[item.id]} end
 end
 for i=1,3 do
  local x=w-293+(i-1)*85;local y=h-105
  love.graphics.setColor(.09,.065,.10,1);love.graphics.rectangle('fill',x,y,46,46,4)
  love.graphics.setColor(.67,.43,.27,1);love.graphics.rectangle('line',x,y,46,46,4)
  if owned[i] then
   relicIcon(owned[i].id,x+4,y+4,38)
   if owned[i].count>1 then txt('x'..owned[i].count,x+27,y+30,.62,1,.92,.68) end
  else
   love.graphics.setColor(.44,.36,.35,1);love.graphics.rectangle('line',x+12,y+12,22,22,3)
  end
 end
 txt('I inventario   ESC pausa',w-292,h-48,.77)
end
function UI.centerPanel(w,h,title,lines)
 local width,height=math.min(750,w-80),160+#lines*38
 local x,y=(w-width)/2,(h-height)/2
 frame(x,y,width,height)
 txt(title,x+34,y+20,1.55,1,.68,.29)
 for i,line in ipairs(lines) do txt(line,x+34,y+78+(i-1)*38,1.0) end
end
function UI.draw(g,w,h)
 UI.hud(g,w,h)
 if g.state=='reward' then
  local bw=math.min(950,w-80);local x,y=(w-bw)/2,(h-410)/2
  frame(x,y,bw,410);txt('RELIQUIAS DEL ASCENSO  -  ELIGE UNA',x+30,y+22,1.4,1,.7,.28)
  txt('Las reliquias se conservan durante esta partida.',x+30,y+63,1)
  local gap=14;local width=(bw-60-2*gap)/3
  for i,item in ipairs(g.options) do
   local xx=x+30+(i-1)*(width+gap)
   frame(xx,y+118,width,230)
   txt('['..i..']',xx+16,y+135,1.6,1,.65,.30)
   relicIcon(item.id,xx+width-88,y+134,68)
   txt(item.name,xx+16,y+190,1.0)
   txt(item.rarity:upper(),xx+16,y+220,.85,.75,.51,.92)
   local desc=item.desc
   local words={};for word in desc:gmatch('%S+') do words[#words+1]=word end
   local line,row='',0
   for _,word in ipairs(words) do
    if #line+#word>23 then txt(line,xx+16,y+253+row*21,.85);line=word;row=row+1 else line=line..(line=='' and '' or ' ')..word end
   end
   txt(line,xx+16,y+253+row*21,.85)
  end
  txt('Pulsa 1, 2 o 3 para escoger.',x+30,y+369,1.03)
 elseif g.state=='clear' then
  UI.centerPanel(w,h,'CAMARA SUPERADA',{'Reliquia obtenida: '..(g.lastItem or 'sin recompensa'),
    g.roomIndex==9 and 'E: llegar al final de la torre' or 'E: ascender a la siguiente camara'})
 elseif g.state=='dead' then
  UI.centerPanel(w,h,'LAS ALAS SE CONSUMIERON',{'El ascenso ha terminado.',
   'ENTER: intentar de nuevo  |  ESC: menu principal'})
 elseif g.state=='victory' then
  UI.centerPanel(w,h,'HAS LLEGADO AL OCASO',{'Has superado las nueve camaras del prototipo.',
   'El destino de Icaro todavia no esta escrito.', 'ENTER: otra partida  |  ESC: menu principal'})
 end
end
function UI.inventory(g,w,h)
 local lines={}
 local items={}
 for _,item in ipairs(Items.catalog) do
  if g.player.items[item.id] then items[#items+1]=item end
 end
 if #items==0 then lines[1]='No has encontrado reliquias todavia.' end
 lines[#lines+1]='Monedas: '..(g.player.coins or 0)
 lines[#lines+1]='I o ESC: regresar'
 UI.centerPanel(w,h,'INVENTARIO DE RELIQUIAS',lines)
 local width=math.min(650,w-120);local x=(w-width)/2+26;local y=(h-(160+#lines*38))/2+84
 for i,item in ipairs(items) do
  relicIcon(item.id,x,y+(i-1)*38,30)
  txt(item.name..' x'..g.player.items[item.id],x+42,y+(i-1)*38+6,.9)
 end
end
return UI
