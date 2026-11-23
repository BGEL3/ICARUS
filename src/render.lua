local Rooms=require('src.rooms')
local Render={}
local cache={}
local function color(c,a) love.graphics.setColor(c[1],c[2],c[3],a or 1) end
local function iso(x,y) return (x-y)*.72,(x+y)*.40 end
Render.iso=iso
function Render.load()
 local list={'player','hoplite','harpy','brute','boss','floor_tiles','completo','skull_23'}
 for _,name in ipairs(list) do
  local path='assets/sprites/'..name..'.png'
  if love.filesystem.getInfo(path) then
   local im=love.graphics.newImage(path);im:setFilter('nearest','nearest');cache[name]=im
  end
 end
 if cache.floor_tiles then
  cache.tiles={}
  for i=0,3 do cache.tiles[i+1]=love.graphics.newQuad(i*64,0,64,32,256,32) end
 end
 for _,name in ipairs({'player','hoplite','harpy','brute','boss'}) do
  local im=cache[name];if im then
   cache[name..'_quads']={}
   for row=0,3 do for d=0,7 do cache[name..'_quads'][row*8+d+1]=love.graphics.newQuad(d*48,row*56,48,56,384,224) end end
  end
 end
end
local function quad(x,y,w,h)
 local a,b=iso(x,y);local c,d=iso(x+w,y);local e,f=iso(x+w,y+h);local g,k=iso(x,y+h)
 return {a,b,c,d,e,f,g,k}
end
local function prism(x,y,w,h,depth,tint)
 local lg=love.graphics;local p=quad(x,y,w,h)
 color(tint);lg.polygon('fill',p)
 lg.setColor(.08,.07,.12);lg.polygon('fill',{p[7],p[8],p[5],p[6],p[5],p[6]+depth,p[7],p[8]+depth})
 lg.setColor(.14,.12,.19);lg.polygon('fill',{p[3],p[4],p[5],p[6],p[5],p[6]+depth,p[3],p[4]+depth})
 lg.setColor(.46,.35,.44,.6);lg.setLineWidth(2);lg.polygon('line',p)
end
local function character(name,x,y,g,dir,opacity,scale)
 local im=cache[name];local lg=love.graphics
 if not im then return end
 local sx,sy=iso(x,y)
 lg.setColor(0,0,0,.37);lg.ellipse('fill',sx,sy+4,18,8)
 local frame=(math.floor(g.time*12)%4)
 local idx=frame*8+(dir or 0)+1
 lg.setColor(1,1,1,opacity or 1)
 lg.draw(im,cache[name..'_quads'][idx],sx,sy+11,0,scale or 1.12,scale or 1.12,24,51)
end
function Render.drawWorld(g,w,h)
 local lg=love.graphics;local scale=math.min(w/1320,h/820)
 lg.push();lg.translate(w/2,h*.54);lg.scale(scale,scale)
 local base=g.room.palette=='violet' and {.20,.16,.27} or g.room.palette=='slate' and {.16,.19,.25} or {.26,.15,.20}
 prism(-Rooms.w/2,-Rooms.h/2,Rooms.w,Rooms.h,95,base)
 -- Sharp 2:1 isometric pixel tiles, rendered with nearest-neighbour sampling.
 if cache.floor_tiles then
  for ix=0,12 do for iy=0,7 do
   local x=-Rooms.w/2+ix*84+42;local y=-Rooms.h/2+iy*84+42
   local sx,sy=iso(x,y)
   lg.setColor(1,1,1,.86);lg.draw(cache.floor_tiles,cache.tiles[((ix*3+iy*7)%4)+1],sx,sy,0,1.89,2.1,32,16)
  end end
 end
 -- Engraved Codex word mark, dim and subject to isometric plane perspective.
 lg.push();local sx,sy=iso(-120,-55);lg.translate(sx,sy);lg.rotate(.48);lg.scale(1.85,.72)
 lg.setColor(.10,.075,.14,.50);lg.print('CODEX',2,3)
 lg.setColor(.68,.47,.43,.23);lg.print('CODEX',0,0)
 lg.pop()
 -- Skull with 23 pendant, on elevated plinth.
 prism(-445,-100,82,82,23,{.24,.21,.31})
 local skx,sky=iso(-403,-58)
 if cache.skull_23 then lg.setColor(1,1,1);lg.draw(cache.skull_23,skx-26,sky-81,0,1.15,1.15) end
 lg.setColor(.99,.71,.34);lg.print('23',skx-12,sky-37,0,.8,.8)
 -- Decorative corners and portal. Collision follows room limits, decorations are currently non-solid.
 for _,p in ipairs({{-475,-240},{397,-240},{-475,184},{397,184}}) do
  prism(p[1],p[2],75,75,115,{.33,.26,.37})
  local bx,by=iso(p[1]+37,p[2]+37)
  lg.setColor(.99,.35,.08,.34);lg.circle('fill',bx,by-24,26)
  lg.setColor(1,.49,.13);lg.circle('fill',bx,by-24,12)
  lg.setColor(1,.74,.26);lg.circle('fill',bx,by-31,6)
 end
 local ex,ey=iso(0,-Rooms.h/2+53)
 lg.setColor(g.state=='clear' and 1 or .39,g.state=='clear' and .65 or .35,.17);lg.setLineWidth(7);lg.ellipse('line',ex,ey,48,23)
 for _,item in ipairs(g.food) do if not item.used then
  local x,y=iso(item.x,item.y)
  if cache.completo then lg.setColor(1,1,1);lg.draw(cache.completo,x,y-22+math.sin(g.time*3)*3,0,1.15,1.15,32,22) end
 end end
 -- Depth order by projected vertical axis.
 local actors={}
 for _,e in ipairs(g.enemies) do actors[#actors+1]={kind=e.kind,obj=e,sort=e.x+e.y} end
 actors[#actors+1]={kind='player',obj=g.player,sort=g.player.x+g.player.y}
 table.sort(actors,function(a,b) return a.sort<b.sort end)
 for _,a in ipairs(actors) do
  local e=a.obj
  if a.kind=='player' then
   local direction=math.floor((math.atan2(e.faceY,e.faceX)+math.pi)*4/math.pi+.5)%8
   character('player',e.x,e.y,g,direction,(e.invul>0 and math.floor(g.time*14)%2==0) and .5 or 1)
   if e.incinerateTime>0 then
    local x,y=iso(e.x,e.y);lg.setColor(1,.35,.08,.55);lg.circle('line',x,y-16,33+math.sin(g.time*12)*3)
   end
   if e.parryTime>0 then
    local x,y=iso(e.x,e.y);local pulse=35+math.sin(g.time*40)*3
    lg.setColor(.72,.9,1,.85);lg.setLineWidth(3);lg.circle('line',x,y-15,pulse);lg.setLineWidth(1)
   end
  else
   character(a.kind,e.x,e.y,g,0,e.flash>0 and .52 or 1,a.kind=='boss' and 1.55 or a.kind=='brute' and 1.25 or 1.05)
   local x,y=iso(e.x,e.y)
   if e.windup and e.windup>0 then
    local tx,ty=iso(e.x+e.aimX*490,e.y+e.aimY*490)
    local alpha=.22+.38*(1-e.windup/(e.kind=='boss' and .48 or .38))
    lg.setColor(1,.16,.12,alpha);lg.setLineWidth(e.kind=='boss' and 3 or 2)
    lg.line(x,y-15,tx,ty-15);lg.setLineWidth(1)
    lg.setColor(1,.28,.18,alpha);lg.circle('line',tx,ty-15,e.kind=='boss' and 10 or 6)
   end
   if e.burn>0 then
    lg.setColor(1,.34,.08,.65);lg.setLineWidth(2);lg.circle('line',x,y-15,18+math.sin(g.time*18)*2);lg.setLineWidth(1)
   end
   lg.setColor(.08,.04,.12);lg.rectangle('fill',x-33,y-55,66,6)
   lg.setColor(.93,.24,.25);lg.rectangle('fill',x-33,y-55,66*math.max(0,e.hp/e.maxHp),6)
   if g.target==e then
    -- Punto central para autoenfoque y fijación manual.
    lg.setColor(1,.78,.24,.35);lg.circle('fill',x,y-16,8)
    lg.setColor(1,.78,.24);lg.circle('fill',x,y-16,3)
    if g.lock==e then lg.setLineWidth(1.5);lg.circle('line',x,y-16,11);lg.setLineWidth(1) end
   end
  end
 end
 for _,s in ipairs(g.shots) do
  local x,y=iso(s.x,s.y)
  lg.setColor(s.enemy and .91 or 1,s.enemy and .17 or .52,.12,.3);lg.circle('fill',x,y-15,s.r*2)
  lg.setColor(s.enemy and 1 or 1,s.enemy and .34 or .85,.28);lg.circle('fill',x,y-15,s.r*.9)
 end
 for _,e in ipairs(g.effects) do
  local x,y=iso(e.x,e.y);color(e.color,e.t/e.max*.72);lg.setLineWidth(3);lg.circle('line',x,y,e.size*(1-e.t/e.max)*1.1)
 end
 lg.pop()
end
function Render.background(w,h,t)
 love.graphics.clear(.045,.035,.08)
 local lg=love.graphics
 for i=1,10 do
  lg.setColor(.20,.12,.28,.12)
  lg.ellipse('fill',w*.5+math.cos(i*.8)*w*.6,h*.70+math.sin(i+t*.035)*h*.23,160,48)
 end
end
return Render
