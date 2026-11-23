local Animation=require('src.animation')
local Iso=require('src.isometric')
local Map=require('assets.maps.arena.map')
local Render={}

local colors={bg={.055,.038,.11},gold={1,.68,.28},orange={1,.38,.13},pale={.94,.86,.74},red={.85,.20,.27}}
local function C(t,a) love.graphics.setColor(t[1],t[2],t[3],a or 1) end
local function image(path)
  local ok,result=pcall(love.graphics.newImage,path)
  if not ok then return nil end
  result:setFilter('nearest','nearest')
  return result
end
local function loadAnimation(path,columns,rows,loop,width,height)
  local source=image(path)
  if not source then return nil end
  return Animation.new(source,columns,rows,12,loop,width,height)
end

function Render.load()
  Render.room=image('assets/environments/arena/main_room.png')
  local player='assets/characters/player/icarus/'
  Render.run=loadAnimation(player..'run.png',8,4,true,320,320)
  Render.idle=loadAnimation(player..'idle.png',6,4,true,320,320)
  Render.attacks={}
  for _,direction in ipairs({'north','east','south','west'}) do
    Render.attacks[direction]=loadAnimation(player..'wind_attack_'..direction..'.png',4,2,false,384,384)
  end
  Render.enemyImages={
    shade=image('assets/characters/concepts/ash_wraith.png'),
    archer=image('assets/characters/concepts/crimson_archer.png'),
    harpy=image('assets/characters/concepts/harpy_queen.png'),
    sentinel=image('assets/characters/concepts/sun_sentinel.png'),
  }
  Render.bodoque=loadAnimation('assets/characters/npc/bodoque/poses.png',3,2,true,512,512)
  Render.bodoquePanel=image('assets/ui/dialogue/bodoque_dialogue_box.png')
  Render.menuTitle=loadAnimation('assets/ui/menu/spritesheet-transparent.png',3,2,true,512,384)
  Render.menuPlay=loadAnimation('assets/ui/menu/play.png',3,2,true,512,384)
  Render.menuSettings=loadAnimation('assets/ui/menu/settings.png',3,2,true,512,384)
  Render.tiles=image('assets/environments/tiles/floor_tiles.png')
  Render.decorations=image('assets/environments/decorations/props.png')
  Render.relicSheet=image('assets/effects/relics/relics_effects.png')
end

function Render.update(dt)
  for _,animation in pairs({Render.run,Render.idle,Render.bodoque,Render.menuTitle,Render.menuPlay,Render.menuSettings}) do
    if animation then animation:update(dt) end
  end
end

function Render.background(w,h,t)
  love.graphics.clear(colors.bg)
  for i=1,12 do
    local a=i*.9
    love.graphics.setColor(.18,.11,.26,.1)
    love.graphics.ellipse('fill',w*.5+math.cos(a)*w*.58,h*.67+math.sin(a*2+t*.035)*h*.22,190,60)
  end
end

function Render.drawMenu(background,w,h,choice,t)
  local lg=love.graphics
  if background then
    lg.setColor(1,1,1,1)
    lg.draw(background,0,0,0,w/background:getWidth(),h/background:getHeight())
  end
  local scale=math.min(w/1280,h/720)
  if Render.menuTitle then Render.menuTitle:draw(w*.5,h*.25,.72*scale,256,190,1) end
  local buttonScale=.59*scale
  if Render.menuPlay then
    local y=h*.57+(choice==1 and -5 or 0)
    lg.setColor(1,1,1,choice==1 and 1 or .78)
    Render.menuPlay:draw(w*.5,y,buttonScale,256,192,1)
  end
  if Render.menuSettings then
    local y=h*.77+(choice==2 and -5 or 0)
    lg.setColor(1,1,1,choice==2 and 1 or .78)
    Render.menuSettings:draw(w*.5,y,buttonScale,256,192,1)
  end
  lg.setColor(1,.86,.65,.9)
  lg.printf('W / S o FLECHAS: seleccionar    ENTER: confirmar    F11: pantalla completa',
    0,h-34,w,'center')
end

local function enemyImage(g,e)
  if e.kind=='boss' then
    if g.room.floor==1 then return Render.enemyImages.sentinel end
    if g.room.floor==2 then return Render.enemyImages.harpy end
    return Render.enemyImages.shade
  end
  if e.kind=='archer' then return Render.enemyImages.archer end
  return Render.enemyImages.shade
end

local function drawPlayer(g,scale)
  local p=g.player
  local x,y=Iso.toScreen(p.x,p.y)
  local direction=p.attackAnimTime>0 and p.attackDir or p.facing
  local attack=Render.attacks[direction]
  local blink=p.invul>0 and math.floor(g.elapsed*16)%2==0
  love.graphics.setColor(1,1,1,blink and .78 or 1)
  if attack and p.attackAnimTime>0 then
    local elapsed=8/12-p.attackAnimTime
    local frame=math.min(8,math.floor(math.max(0,elapsed)*12)+1)
    attack:draw(x,y,.25*scale,192,352,1,frame)
  else
    local animation=p.moving and Render.run or Render.idle
    if animation then
      local rows={north=1,east=2,south=3,west=4}
      animation:draw(x,y,.25*scale,160,292,rows[p.facing] or 1)
    else
      love.graphics.setColor(.95,.73,.36)
      love.graphics.circle('fill',x,y-20,15)
    end
  end
  love.graphics.setColor(1,1,1,1)
end

local function drawEnemy(g,e,scale)
  local x,y=Iso.toScreen(e.x,e.y)
  local sprite=enemyImage(g,e)
  if sprite then
    local height=e.kind=='boss' and .37 or .28
    love.graphics.setColor(1,1,1,e.flash>0 and .75 or 1)
    love.graphics.draw(sprite,x,y,0,height*scale,height*scale,256,458)
  else
    love.graphics.setColor(.38,.36,.51,1);love.graphics.circle('fill',x,y-17,e.r)
  end
  love.graphics.setColor(.06,.035,.05,.92)
  love.graphics.rectangle('fill',x-25,y-72,50,6)
  love.graphics.setColor(.9,.2,.24,1)
  love.graphics.rectangle('fill',x-25,y-72,50*math.max(0,e.hp/e.maxHp),6)
end

local function drawBodoque(g,scale)
  local npc=Map.bodoque
  local x,y=Iso.toScreen(npc.x,npc.y)
  if Render.bodoque then
    local row=g.bodoqueTalking and 1 or 1
    local column=g.bodoqueTalking and 2 or 1
    Render.bodoque:draw(x,y,.18*scale,256,466,row,(row-1)*3+column)
  end
  if g:nearBodoque() then
    love.graphics.setColor(.05,.035,.08,.86)
    love.graphics.rectangle('fill',x-61,y-115,122,22,3)
    love.graphics.setColor(1,.78,.43,1)
    love.graphics.printf('E  HABLAR',x-59,y-111,118,'center')
  end
end

function Render.drawWorld(g,w,h)
  local lg=love.graphics
  if Render.room then
    lg.setColor(1,1,1,1)
    lg.draw(Render.room,0,0,0,w/Render.room:getWidth(),h/Render.room:getHeight())
    if g.room.floor==2 then
      lg.setColor(.12,.22,.28,.10);lg.rectangle('fill',0,0,w,h)
    elseif g.room.floor==3 then
      lg.setColor(1,.68,.39,.055);lg.rectangle('fill',0,0,w,h)
    end
  end
  local scale=math.min(w/1280,h/720)
  lg.push();lg.translate(w/2,h*.49);lg.scale(scale,scale)

  -- The portal is a world object; the static architecture remains in the room PNG.
  local gate=Map.exits[1]
  local gx,gy=Iso.toScreen(gate.x,gate.y)
  lg.setColor(.12,.82,.72,g.state=='clear' and .34 or .16)
  lg.ellipse('fill',gx,gy,55,19)
  lg.setColor(.34,1,.84,g.state=='clear' and .8 or .42)
  lg.setLineWidth(3);lg.ellipse('line',gx,gy,47,16)

  local sprites={}
  for _,e in ipairs(g.enemies) do sprites[#sprites+1]={obj=e,kind='enemy',depth=Iso.depth(e.x,e.y)} end
  sprites[#sprites+1]={obj=g.player,kind='player',depth=Iso.depth(g.player.x,g.player.y)}
  local npc=Map.bodoque
  sprites[#sprites+1]={obj=npc,kind='bodoque',depth=Iso.depth(npc.x,npc.y)}
  table.sort(sprites,function(a,b) return a.depth<b.depth end)
  for _,sprite in ipairs(sprites) do
    if sprite.kind=='enemy' then drawEnemy(g,sprite.obj,scale)
    elseif sprite.kind=='player' then drawPlayer(g,scale)
    else drawBodoque(g,scale) end
  end

  for _,shot in ipairs(g.shots) do
    local x,y=Iso.toScreen(shot.x,shot.y)
    love.graphics.setColor(shot.enemy and .95 or 1,shot.enemy and .25 or .74,shot.enemy and .28 or .38,.36)
    love.graphics.circle('fill',x,y-7,shot.r*1.6)
    love.graphics.setColor(shot.enemy and .98 or 1,shot.enemy and .51 or .91,shot.enemy and .26 or .57,1)
    love.graphics.circle('fill',x,y-7,shot.r*.72)
  end
  for _,fx in ipairs(g.effects) do
    local x,y=Iso.toScreen(fx.x,fx.y)
    love.graphics.setColor(fx.c[1],fx.c[2],fx.c[3],fx.t/fx.max*.62)
    love.graphics.setLineWidth(3);love.graphics.circle('line',x,y,fx.size*(1-fx.t/fx.max)*1.4)
  end
  lg.pop()
end

function Render.drawDialogue(w,h,dialogue)
  if not dialogue or not dialogue.active then return end
  local lg=love.graphics
  lg.setColor(.035,.025,.065,.7);lg.rectangle('fill',0,0,w,h)
  local panel=Render.bodoquePanel
  local pw=math.min(w-48,900);local ph=pw*(panel and panel:getHeight()/panel:getWidth() or .36)
  local x,y=(w-pw)/2,h-ph-24
  if panel then
    lg.setColor(1,1,1,1);lg.draw(panel,x,y,0,pw/panel:getWidth(),ph/panel:getHeight())
  else
    lg.setColor(.07,.045,.08,.98);lg.rectangle('fill',x,y,pw,ph,9)
    lg.setColor(.74,.47,.27,1);lg.rectangle('line',x,y,pw,ph,9)
  end
  if Render.bodoque then
    local pose=dialogue.portrait=='talking' and 2 or dialogue.portrait=='surprised' and 4 or 1
    local pwose=Render.bodoque
    local img=pwose.image
    local quad=pwose.quads[math.floor((pose-1)/3)+1][(pose-1)%3+1]
    lg.setColor(1,1,1,1)
    local portraitScale=math.min(pw*.24/512,ph*.61/512)
    lg.draw(img,quad,x+pw*.15,y+ph*.78,0,portraitScale,portraitScale,256,466)
  end
  lg.setColor(1,.76,.39,1);lg.print('JUAN CARLOS BODOQUE',x+pw*.29,y+ph*.24,0,1.05,1.05)
  lg.setColor(.96,.88,.77,1)
  local shown=dialogue.text:sub(1,math.floor(dialogue.visible))
  lg.printf(shown,x+pw*.29,y+ph*.43,pw*.64,'left')
  lg.setColor(1,.78,.42,1)
  lg.printf('E / ENTER  ·  CONTINUAR',x+pw*.29,y+ph*.78,pw*.62,'right')
end

function Render.text(x,y,text,scale,col)
  if col then C(col) else C(colors.pale) end
  love.graphics.print(text,x,y,0,scale or 1,scale or 1)
end

return Render
