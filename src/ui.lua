local Items=require('src.items')
local UI={}
local function text(s,x,y,size,c)
 local lg=love.graphics;c=c or {1,.88,.74};lg.setColor(c);lg.print(s,x,y,0,size or 1,size or 1)
end
local function frame(x,y,w,h,highlight)
 local lg=love.graphics;lg.setColor(.055,.038,.105,.94);lg.rectangle('fill',x,y,w,h,5)
 lg.setColor(highlight and 1 or .68,highlight and .63 or .4,.25);lg.setLineWidth(highlight and 3 or 2);lg.rectangle('line',x,y,w,h,5)
end
local portrait
function UI.load()
 local path='assets/concept/bodoque_dialogue_reference.png'
 if love.filesystem.getInfo(path) then portrait=love.graphics.newImage(path);portrait:setFilter('nearest','nearest') end
end
function UI.hud(g,w,h)
 local p=g.player
 frame(16,15,365,106)
 text('ICARO  |  VIDA '..math.ceil(p.hp)..' / 100',29,25,1.09)
 love.graphics.setColor(.22,.09,.16);love.graphics.rectangle('fill',29,61,288,19)
 love.graphics.setColor(.95,.22,.23);love.graphics.rectangle('fill',29,61,288*p.hp/100,19)
 text('J PLUMA   K '..string.format('%.1f',p.flameCd)..'s   I '..string.format('%.1f',p.incinerateCd)..'s',28,88,.78)
 text('H PARRY '..(p.parryCd<=0 and 'LISTO' or string.format('%.1f',p.parryCd)..'s'),28,105,.75,p.parryCd<=0 and {1,.75,.38} or {1,.58,.45})
 frame(w-268,16,248,94)
 text('PISO '..g.room.floor..'/3   SALA '..g.roomIndex..'/6',w-253,29,1.02)
 text(g.room.name,w-253,65,.83)
 frame(16,h-78,760,61)
 text('WASD mover   J pluma   K llamarada   I incinerar',27,h-66,.90)
 text('O autoenfoque: '..(g.focusEnabled and 'ON' or 'OFF')..'   L fijar   H parry   Shift/Espacio esquivar   E ascender',27,h-41,.82)
 if p.incinerateTime>0 then frame(w/2-150,18,300,45,true);text('FUEGO x'..(Items.has(p,'sacrifice') and '2,5' or '2')..'  '..string.format('%.1f',p.incinerateTime)..' s',w/2-114,30,1.12,{1,.64,.22}) end
 if g.roomIndex==5 then frame(w/2-150,65,300,45,true);text('QUEDA UNA PURA SALA',w/2-128,79,1.02,{1,.77,.4}) end
end
function UI.centerPanel(w,h,title,lines)
 local wide=math.min(760,w-70);local tall=145+#lines*34;local x,y=(w-wide)/2,(h-tall)/2
 frame(x,y,wide,tall,true);text(title,x+27,y+18,1.52,{1,.65,.28})
 for i,line in ipairs(lines) do text(line,x+27,y+68+(i-1)*34,.95) end
end
function UI.draw(g,w,h)
 UI.hud(g,w,h)
 if g.intro>0 then
  frame(20,h-330,560,246,true)
  if portrait then love.graphics.setColor(1,1,1);love.graphics.draw(portrait,34,h-298,0,.8,.8) end
  text('BODOQUE  |  TUTORIAL',170,h-295,1.05,{1,.67,.28})
  text('WASD: moverte y orientar el ataque',170,h-263,.9)
  text('J: pluma  /  K: llamarada radial',170,h-235,.9)
  text('I: pagar 1 HP; fuego x2 durante 6 s',170,h-207,.9)
  text('O: autoenfoque  /  L: fijar objetivo',170,h-179,.88)
  text('H: parry  /  SHIFT o ESPACIO: esquiva',170,h-151,.88)
  text('Desaparezco en '..math.ceil(g.intro)..' s',170,h-123,.89,{1,.74,.4})
 end
 if g.state=='reward' then
  local bw=math.min(w-90,990);local x=(w-bw)/2;local y=(h-355)/2
  frame(x,y,bw,355)
  text('ELIGE UNA RELIQUIA',x+24,y+16,1.5,{1,.72,.29})
  local cw=(bw-64)/3
  for i,it in ipairs(g.options) do
   local xx=x+16+(i-1)*(cw+16);frame(xx,y+76,cw,220,g.selected==i)
   text((g.selected==i and '> ' or '')..it.name,xx+11,y+107,.95,{1,.74,.40})
   text(it.rarity:upper(),xx+12,y+148,.85)
   local line,yy='',0
   for word in it.desc:gmatch('%S+') do
    if #line+#word>25 then text(line,xx+12,y+183+yy*25,.84);line=word;yy=yy+1 else line=line..(line=='' and '' or ' ')..word end
   end
   text(line,xx+12,y+183+yy*25,.84)
  end
  text('J/K: cambiar    L o ESPACIO: confirmar',x+25,y+316,1.0)
 elseif g.state=='clear' then
  UI.centerPanel(w,h,'CAMARA DESPEJADA',{'Reliquia: '..g.lastItem,'E: ascender a la siguiente sala'})
 elseif g.state=='dead' then
  UI.centerPanel(w,h,'LAS ALAS SE CONSUMIERON',{'ENTER: nuevo intento     ESC: titulo'})
 elseif g.state=='victory' then
  UI.centerPanel(w,h,'EL SOL TE ESPERA',{'Has superado los 3 pisos y las 6 salas.','ENTER: volver a intentar     ESC: titulo'})
 end
 if g.toastTime>0 and g.toast~='' then
  frame(w/2-210,h-130,420,38,true);text(g.toast,w/2-190,h-120,.85,{1,.75,.38})
 end
end
return UI
