local Rooms=require('src.rooms')
local Items=require('src.items')
local Game={};Game.__index=Game
local cos,sin,sqrt=math.cos,math.sin,math.sqrt

local function length(x,y) return sqrt(x*x+y*y) end
local function norm(x,y) local d=length(x,y);if d<.0001 then return 0,-1 end;return x/d,y/d end
local function clamp(v,a,b) return math.max(a,math.min(b,v)) end
local function distance(a,b) return length(a.x-b.x,a.y-b.y) end
local function fx(g,x,y,r,col,ttl)
 g.effects[#g.effects+1]={x=x,y=y,size=r,color=col,t=ttl or .3,max=ttl or .3}
end

function Game.new()
 local g=setmetatable({},Game)
 g.player={
  x=0,y=170,r=17,hp=100,maxHp=100,speed=250,faceX=0,faceY=-1,
  items={},attackCd=0,flameCd=0,incinerateCd=0,incinerateTime=0,
  dashCd=0,dashTime=0,invul=0,parryTime=0,parryCd=0,parryCount=0
 }
 g.roomIndex=1;g.time=0;g.intro=5;g.kills=0
 g.shots={};g.enemies={};g.effects={};g.options={};g.rewarded={};g.food={}
 g.selected=1;g.lock=nil;g.target=nil;g.focusEnabled=true;g.state='fight';g.lastItem=''
 g.toast='';g.toastTime=0
 g:loadRoom(1)
 return g
end

function Game:loadRoom(index)
 self.roomIndex=index;self.room=Rooms.describe(index)
 self.state='fight';self.enemies={};self.shots={};self.effects={};self.options={};self.food={}
 self.lock=nil;self.target=nil
 self.player.x=0;self.player.y=155;self.player.invul=.8;self.player.parryTime=0
 local floorScale=1+.17*(self.room.floor-1)
 local speedScale=1+.07*(self.room.floor-1)
 local function spawn(kind,x,y)
  local baseHp=kind=='boss' and (95+self.room.floor*28) or kind=='brute' and 38 or kind=='harpy' and 20 or 26
  local baseSpeed=kind=='brute' and 65 or kind=='boss' and 80 or 103
  local hp=kind=='boss' and baseHp or math.floor(baseHp*floorScale)
  self.enemies[#self.enemies+1]={
   x=x,y=y,r=kind=='boss' and 33 or kind=='brute' and 28 or 19,
   hp=hp,maxHp=hp,kind=kind,speed=baseSpeed*speedScale,
   cd=.8+love.math.random()*.7,windup=0,attackCount=0,aimX=0,aimY=-1,
   burn=0,flash=0,slow=0
  }
 end
 if self.room.boss then
  spawn('boss',0,-165)
  -- The guardian brings floor-scaled support to test target selection and crowd control.
  for i=1,self.room.supportCount do
   local kind=i%3==0 and 'brute' or i%2==0 and 'harpy' or 'hoplite'
   local angle=(i/self.room.supportCount)*math.pi*2
   spawn(kind,cos(angle)*315,sin(angle)*150-20)
  end
 else
  local count=self.room.enemyCount
  for i=1,count do
   local t=(i/count)*math.pi*2
   local kind=(i+index)%4==0 and 'harpy' or (i+index)%3==0 and 'brute' or 'hoplite'
   spawn(kind,cos(t)*love.math.random(170,350),sin(t)*love.math.random(100,195)-45)
  end
 end
 self.food[1]={x=-260,y=110,used=false}
 self:resolveTarget()
end

function Game:toastMessage(message,duration)
 self.toast=message;self.toastTime=duration or 1.4
end

function Game:nearestList()
 local enemies={}
 for _,e in ipairs(self.enemies) do if e.hp>0 then enemies[#enemies+1]=e end end
 table.sort(enemies,function(a,b) return distance(a,self.player)<distance(b,self.player) end)
 return enemies
end

function Game:resolveTarget()
 if self.lock and self.lock.hp>0 then self.target=self.lock;return self.target end
 self.lock=nil;self.target=nil
 if self.focusEnabled then self.target=self:nearestList()[1] end
 return self.target
end

function Game:cycleLock()
 local enemies=self:nearestList()
 if #enemies==0 then self.lock=nil;self.target=nil;return end
 local at=0
 for i,e in ipairs(enemies) do if e==self.lock then at=i;break end end
 self.lock=enemies[(at%#enemies)+1]
 self.target=self.lock
 fx(self,self.lock.x,self.lock.y,32,{1,.65,.16},.3)
 self:toastMessage('OBJETIVO FIJADO',.8)
end

function Game:toggleFocus()
 self.focusEnabled=not self.focusEnabled
 self:resolveTarget()
 self:toastMessage(self.focusEnabled and 'AUTOENFOQUE ACTIVADO' or 'AUTOENFOQUE DESACTIVADO',1.1)
end

function Game:dash()
 local p=self.player
 if self.state~='fight' or p.dashCd>0 then return end
 p.dashTime=.17;p.dashCd=Items.has(p,'dash') and .85 or 1.45;p.invul=.26
 p.dashDirX,p.dashDirY=p.faceX,p.faceY
 fx(self,p.x,p.y,32,{1,.72,.26},.32)
end

function Game:burnDuration()
 local duration=2.5
 if Items.has(self.player,'burn') then duration=duration*1.6 end
 if Items.has(self.player,'feather') then duration=duration+1 end
 return duration
end

function Game:fireMultiplier()
 local p=self.player
 local incinerationMultiplier=Items.has(p,'sacrifice') and 2.5 or 2
 return (p.incinerateTime>0 and incinerationMultiplier or 1)*(Items.has(p,'embers') and 1.25 or 1)
end

function Game:enemyAttack(enemy)
 local floor=self.room.floor
 local speedScale=1+.08*(floor-1)
 local pattern=enemy.attackCount%3
 enemy.attackCount=enemy.attackCount+1
 local shots={}
 if enemy.kind=='boss' and pattern==2 then
  -- The alternating ring asks the player to reposition; its gaps stay dodgeable.
  for i=0,7 do local a=i*math.pi/4+enemy.attackCount*.08;shots[#shots+1]={cos(a),sin(a)} end
 else
  local n=enemy.kind=='boss' and (pattern==1 and 7 or 5) or 1
  local spread=enemy.kind=='boss' and (pattern==1 and .52 or .34) or 0
  local a=math.atan2(enemy.aimY,enemy.aimX)
  for i=1,n do local angle=a+(i-(n+1)/2)*spread/math.max(1,n-1);shots[#shots+1]={cos(angle),sin(angle)} end
 end
 for _,direction in ipairs(shots) do
  self.shots[#self.shots+1]={
   x=enemy.x,y=enemy.y,dx=direction[1],dy=direction[2],
   speed=(enemy.kind=='boss' and 270 or 320)*speedScale,ttl=2.3,enemy=true,
   r=10,damage=(enemy.kind=='boss' and 14 or 7)*(1+.20*(floor-1)),source=enemy
  }
 end
 local interval=enemy.kind=='boss' and 1.85 or 2.15
 enemy.cd=interval/(1+.16*(floor-1))
end

function Game:applyBurn(enemy,duration)
 enemy.burn=math.max(enemy.burn or 0,duration or self:burnDuration())
end

function Game:shoot()
 local p=self.player
 if self.state~='fight' or p.attackCd>0 then return end
 p.attackCd=.27
 local target=self:resolveTarget()
 local dx,dy=p.faceX,p.faceY
 if target and target.hp>0 then dx,dy=norm(target.x-p.x,target.y-p.y) end
 local many=Items.has(p,'twin') and 2 or 1
 for i=1,many do
  local a=math.atan2(dy,dx)+(i-(many+1)/2)*.13
  self.shots[#self.shots+1]={
   x=p.x,y=p.y,dx=cos(a),dy=sin(a),speed=580,r=9,ttl=1.5,enemy=false,
   damage=12*(Items.has(p,'feather') and 1.30 or 1)*self:fireMultiplier(),
   pierce=Items.has(p,'pierce') and 1 or 0,hit={}
  }
 end
 fx(self,p.x+dx*25,p.y+dy*25,17,{1,.51,.18},.15)
end

function Game:flame()
 local p=self.player
 if self.state~='fight' or p.flameCd>0 then return end
 p.flameCd=Items.has(p,'cooldown') and 4.8 or 6
 local radius=Items.has(p,'flare') and 220 or 175
 fx(self,p.x,p.y,radius,{1,.38,.1},.48)
 local detonations=0
 for _,e in ipairs(self.enemies) do
  if e.hp>0 and distance(p,e)<=radius then
   local damage=25
   if e.burn>0 then
    -- K always rewards setting enemies alight first; Hestia makes the detonation stronger
    -- and lets it jump to nearby targets, so the core loop works before any item drops.
    local bonus=math.min(24,6+e.burn*6)
    if Items.has(p,'pulse') then bonus=bonus*1.5 end
    damage=damage+bonus;e.burn=0;e.pulseDetonated=true;detonations=detonations+1
    fx(self,e.x,e.y,54,{1,.57,.13},.32)
   else
    self:applyBurn(e)
   end
   damage=damage*self:fireMultiplier()*(Items.has(p,'flame') and 1.35 or 1)
   e.hp=e.hp-damage;e.flash=.2
  end
 end
 if Items.has(p,'pulse') and detonations>0 then
  local featherSynergy=Items.has(p,'feather')
  local spreadRadius=featherSynergy and 140 or 115
  local spreadDamage=featherSynergy and 9 or 6
  for _,source in ipairs(self.enemies) do
   if source.pulseDetonated then
   for _,e in ipairs(self.enemies) do
     if e~=source and e.hp>0 and distance(e,source)<spreadRadius then
      self:applyBurn(e,featherSynergy and 2.5 or 1.5);e.hp=e.hp-spreadDamage*self:fireMultiplier();fx(self,e.x,e.y,18,{1,.48,.12},.18)
     end
   end
   end
  end
  self:toastMessage(featherSynergy and 'SINERGIA: LLAMARADA DE PLUMAS' or 'PULSO DE HESTIA · FUEGO PROPAGADO',1.2)
 elseif detonations>0 then
  self:toastMessage(detonations==1 and 'COMBUSTIÓN · DAÑO EXTRA' or 'COMBUSTIÓN EN CADENA · '..detonations..' DETONACIONES',1.2)
 end
 for _,e in ipairs(self.enemies) do e.pulseDetonated=nil end
end

function Game:incinerate()
 local p=self.player
 if self.state~='fight' or p.incinerateCd>0 or p.hp<=1 then return end
 p.hp=p.hp-1
 p.incinerateCd=Items.has(p,'cooldown') and 9.6 or 12
 p.incinerateTime=6+(Items.has(p,'sacrifice') and 3 or 0)
 fx(self,p.x,p.y,90,{1,.27,.06},.55)
 self:toastMessage('FUEGO POTENCIADO · -1 VIDA',1.1)
end

function Game:parry()
 local p=self.player
 if self.state~='fight' or p.parryCd>0 then return end
 p.parryTime=Items.has(p,'mirror') and .30 or .20
 p.parryCd=Items.has(p,'mirror') and .95 or 1.35
 fx(self,p.x,p.y,38,{.8,.9,1},.22)
end

function Game:resolveParry(enemy)
 local p=self.player
 p.parryTime=0;p.parryCount=p.parryCount+1
 p.invul=math.max(p.invul,.22)
 p.flameCd=math.max(0,p.flameCd-1)
 if enemy and enemy.hp>0 then
  local damage=14*self:fireMultiplier()*(Items.has(p,'mirror') and 1.5 or 1)
  local emberSynergy=Items.has(p,'mirror') and Items.has(p,'sacrifice') and p.incinerateTime>0
  if emberSynergy then damage=damage+12 end
  enemy.hp=enemy.hp-damage;enemy.flash=.2;self:applyBurn(enemy)
  fx(self,enemy.x,enemy.y,32,{.8,.92,1},.3)
  if emberSynergy then self:toastMessage('SINERGIA: CONTRAATAQUE INCANDESCENTE',1.4)
  elseif Items.has(p,'mirror') then self:toastMessage('ESPEJO DE ATENEA · CONTRAATAQUE',1.2)
  else self:toastMessage('PARRY ÍGNEO · K RECARGA',1.0) end
 else self:toastMessage('PROYECTIL DESVIADO',.8) end
end

function Game:damagePlayer(n)
 local p=self.player
 if p.invul>0 then return end
 p.hp=math.max(0,p.hp-n);p.invul=.72
 fx(self,p.x,p.y,55,{1,.1,.13},.3)
 if p.hp<=0 then self.state='dead' end
end

function Game:move(dx,dy,dt)
 local p=self.player;local multiplier=p.dashTime>0 and 2.7 or 1
 p.x=clamp(p.x+dx*dt*multiplier,-Rooms.w/2+42,Rooms.w/2-42)
 p.y=clamp(p.y+dy*dt*multiplier,-Rooms.h/2+40,Rooms.h/2-40)
end

function Game:killEnemyAt(index,enemy)
 local burned=(enemy.burn or 0)>0 or enemy.pulseDetonated or enemy.burnDamage
 if self.lock==enemy then self.lock=nil end
 if self.target==enemy then self.target=nil end
 table.remove(self.enemies,index);self.kills=self.kills+1
 fx(self,enemy.x,enemy.y,42,{1,.48,.15},.36)
 if burned and Items.has(self.player,'ash') then
  self.player.flameCd=math.max(0,self.player.flameCd-1)
  if Items.has(self.player,'feather') then
   for _,other in ipairs(self.enemies) do
    if other.hp>0 and distance(enemy,other)<92 then
     other.hp=other.hp-10*self:fireMultiplier();self:applyBurn(other,1.2)
     fx(self,other.x,other.y,22,{1,.42,.12},.22)
    end
   end
   self:toastMessage('SINERGIA: CENIZA EN CADENA',1.2)
  else self:toastMessage('CENIZA HAMBRIENTA · K RECARGA',1.0) end
 end
end

function Game:update(dt)
 dt=math.min(dt,.05);self.time=self.time+dt
 self.intro=math.max(0,self.intro-dt);self.toastTime=math.max(0,self.toastTime-dt)
 local p=self.player
 for _,field in ipairs({'attackCd','flameCd','incinerateCd','incinerateTime','dashCd','dashTime','invul','parryTime','parryCd'}) do
  p[field]=math.max(0,p[field]-dt)
 end
 for i=#self.effects,1,-1 do local e=self.effects[i];e.t=e.t-dt;if e.t<=0 then table.remove(self.effects,i) end end
 if self.state~='fight' then return end

 local dx=(love.keyboard.isDown('d') and 1 or 0)-(love.keyboard.isDown('a') and 1 or 0)
 local dy=(love.keyboard.isDown('s') and 1 or 0)-(love.keyboard.isDown('w') and 1 or 0)
 local moving=dx~=0 or dy~=0
 if moving then dx,dy=norm(dx,dy);p.faceX,p.faceY=dx,dy
 elseif p.dashTime>0 then dx,dy=p.dashDirX or p.faceX,p.dashDirY or p.faceY end
 if dx~=0 or dy~=0 then
  local speed=p.speed*(Items.has(p,'speed') and 1.15 or 1)
  self:move(dx*speed,dy*speed,dt)
 end
 self:resolveTarget()

 for _,pickup in ipairs(self.food) do
  if not pickup.used and distance(p,pickup)<46 then
   pickup.used=true;p.hp=math.min(p.maxHp,p.hp+5);fx(self,p.x,p.y,49,{.65,1,.30},.38)
   self:toastMessage('COMPLETO ITALIANO · +5 VIDA',1.1)
  end
 end

 for i=#self.shots,1,-1 do
  local s=self.shots[i];s.x=s.x+s.dx*s.speed*dt;s.y=s.y+s.dy*s.speed*dt;s.ttl=s.ttl-dt
  local remove=s.ttl<=0 or math.abs(s.x)>Rooms.w/2 or math.abs(s.y)>Rooms.h/2
  if not remove then
   if s.enemy then
    if distance(s,p)<s.r+p.r then
     if p.parryTime>0 then self:resolveParry(s.source)
     else self:damagePlayer(s.damage) end
     remove=true
    end
   else
    for _,e in ipairs(self.enemies) do
     if e.hp>0 and not s.hit[e] and distance(s,e)<s.r+e.r then
      s.hit[e]=true;e.hp=e.hp-s.damage;e.flash=.12;self:applyBurn(e)
      fx(self,e.x,e.y,22,{1,.52,.10},.19)
      if s.pierce>0 then s.pierce=s.pierce-1 else remove=true;break end
     end
    end
   end
  end
  if remove then table.remove(self.shots,i) end
 end

 for i=#self.enemies,1,-1 do
  local e=self.enemies[i]
  e.cd=e.cd-dt;e.flash=math.max(0,e.flash-dt)
  e.burnDamage=false
  if e.burn>0 then e.burnDamage=true;e.burn=math.max(0,e.burn-dt);e.hp=e.hp-3*self:fireMultiplier()*dt end
  if e.hp<=0 then self:killEnemyAt(i,e)
  else
   local vx,vy=norm(p.x-e.x,p.y-e.y);local dis=distance(p,e)
   if e.kind=='harpy' then
    if dis<220 then e.x=e.x-vx*e.speed*.55*dt;e.y=e.y-vy*e.speed*.55*dt
    elseif dis>320 then e.x=e.x+vx*e.speed*.6*dt;e.y=e.y+vy*e.speed*.6*dt end
   elseif dis>e.r+p.r+10 then e.x=e.x+vx*e.speed*dt;e.y=e.y+vy*e.speed*dt end
   e.x=clamp(e.x,-Rooms.w/2+38,Rooms.w/2-38);e.y=clamp(e.y,-Rooms.h/2+38,Rooms.h/2-38)
   if e.kind=='harpy' or e.kind=='boss' then
    if e.windup>0 then
     e.windup=math.max(0,e.windup-dt)
     if e.windup<=0 then self:enemyAttack(e) end
    elseif e.cd<=0 and dis<530 then
     e.aimX,e.aimY=norm(p.x-e.x,p.y-e.y)
     e.windup=e.kind=='boss' and .48 or .38
    end
   end
   if dis<e.r+p.r then self:damagePlayer(e.kind=='boss' and 18 or e.kind=='brute' and 12 or 8) end
  end
 end

 for _,e in ipairs(self.enemies) do e.pulseDetonated=nil;e.burnDamage=nil end
 self:resolveTarget()
 if #self.enemies==0 then
  if not self.rewarded[self.roomIndex] then
   self.rewarded[self.roomIndex]=true;self.options=Items.choose(Items.catalog,p.items,3)
   self.selected=1;self.state=#self.options>0 and 'reward' or 'clear'
  else self.state='clear' end
 end
end

function Game:pick()
 if self.state~='reward' then return end
 local it=self.options[self.selected];if not it then return end
 Items.apply(self.player,it);self.lastItem=it.name;self.state='clear'
 self:toastMessage('OBJETO: '..it.name,1.5)
end
function Game:moveSelection(d)
 if self.state=='reward' and #self.options>0 then self.selected=((self.selected-1+d)%#self.options)+1 end
end
function Game:nextRoom()
 if self.state~='clear' then return end
 if self.roomIndex>=Rooms.total then self.state='victory';return end
 self:loadRoom(self.roomIndex+1)
end
return Game
