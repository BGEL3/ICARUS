local Items=require('src.items')
local Rooms=require('src.rooms')
local Arena=require('src.collision.arena')
local Iso=require('src.isometric')
local Game={}
Game.__index=Game
local pi,cos,sin,sqrt=math.pi,math.cos,math.sin,math.sqrt
local function len(x,y) return sqrt(x*x+y*y) end
local function norm(x,y) local d=len(x,y); if d<0.001 then return 0,-1 end; return x/d,y/d end
local function dist(a,b) return len(a.x-b.x,a.y-b.y) end
local function addFx(g,x,y,color,size,time) g.effects[#g.effects+1]={x=x,y=y,c=color,size=size or 9,t=time or .28,max=time or .28} end
function Game.new()
 local g=setmetatable({},Game)
 g.player={x=0,y=0,r=17,hp=6,maxHp=6,speed=245,faceX=0,faceY=-1,facing='north',
   items={},attackCd=0,attackAnimTime=0,attackDir='north',dashCd=0,dashTime=0,invul=0,
   charge=3,maxCharge=3,stamina=100,maxStamina=100,coins=0,moving=false}
 g.roomIndex=1;g.elapsed=0;g.kills=0;g.shots={};g.enemies={};g.effects={};g.options={};g.rewarded={};g.state='fight'
 g:loadRoom(1)
 return g
end
function Game:loadRoom(index)
 self.roomIndex=index;self.room=Rooms.describe(index)
 self.state='fight';self.enemies={};self.shots={};self.effects={};self.options={}
 self.player.x,self.player.y=Arena.nearestFree(0,170,self.player.r);self.player.invul=0.85
 self.player.charge=math.min(self.player.maxCharge,self.player.charge+1)
 local count=self.room.enemyCount
 for i=1,count do
  local t=(i/count)*pi*2
  local x=cos(t)*love.math.random(195,400)
  local y=sin(t)*love.math.random(110,210)-45
  local kind=self.room.boss and 'boss' or ((i+self.roomIndex)%4==0 and 'archer' or 'shade')
  local hp=kind=='boss' and (18+self.room.floor*9) or (kind=='archer' and 3+self.room.floor or 4+self.room.floor)
  x,y=Arena.nearestFree(x,y,kind=='boss' and 34 or 20)
  self.enemies[#self.enemies+1]={x=x,y=y,r=kind=='boss' and 34 or 20,hp=hp,maxHp=hp,
    kind=kind,speed=kind=='boss' and 74 or kind=='archer' and 98 or 110,
    cd=love.math.random()*1.3,phase=love.math.random()*6.2,burn=0,slow=0,flash=0}
 end
end
function Game:move(dx,dy,dt)
 local p=self.player
 if p.dashTime>0 then dt=dt*2.7 end
 p.x,p.y=Arena.resolve(p.x+dx*dt,p.y+dy*dt,p.r)
end
function Game:dash()
 local p=self.player
 if self.state~='fight' or p.dashCd>0 or p.stamina<34 then return end
 p.stamina=p.stamina-34
 p.dashTime=.17;p.dashCd=Items.has(p,'dash') and 1.0 or 1.7;p.invul=.23
 addFx(self,p.x,p.y,{.95,.65,.25},28,.4)
end
function Game:shoot()
 if self.state~='fight' then return end
 local p=self.player
 local rate=Items.has(p,'rate') and 1.25 or 1
 if p.attackCd>0 then return end
 p.attackCd=.31/rate
 p.attackAnimTime=8/12;p.attackDir=p.facing
 local amount=Items.has(p,'twin') and 2 or 1
 if Items.has(p,'echo') and love.math.random()<.28 then amount=amount+1 end
 local angle=math.atan2(p.faceY,p.faceX)
 for i=1,amount do
  local a=angle+(i-(amount+1)/2)*.20
  local dx,dy=cos(a),sin(a)
  self.shots[#self.shots+1]={x=p.x+dx*21,y=p.y+dy*21,dx=dx,dy=dy,speed=650,r=8,
    damage=1.0*(Items.has(p,'damage') and 1.30 or 1)*(Items.has(p,'blood') and 1.5 or 1),
    ttl=1.35,enemy=false,pierce=Items.has(p,'pierce') and 1 or 0,hit={}}
 end
 addFx(self,p.x+p.faceX*18,p.y+p.faceY*18,{1,.76,.35},12,.12)
end
function Game:active()
 local p=self.player
 if self.state~='fight' or p.charge<p.maxCharge then return end
 p.charge=0
 addFx(self,p.x,p.y,{1,.55,.12},155,.48)
 for _,e in ipairs(self.enemies) do
  if e.hp>0 and dist(p,e)<245 then
   e.hp=e.hp-(Items.has(p,'solar') and 7 or 4)
   e.flash=.23
  end
 end
end
function Game:damagePlayer(amount)
 local p=self.player
 if p.invul>0 then return end
 p.hp=p.hp-amount;p.invul=.9
 addFx(self,p.x,p.y,{1,.2,.22},65,.35)
 if p.hp<=0 then p.hp=0;self.state='dead' end
end
function Game:update(dt)
 dt=math.min(dt,.045);self.elapsed=self.elapsed+dt
 local p=self.player
 p.attackCd=math.max(0,p.attackCd-dt);p.dashCd=math.max(0,p.dashCd-dt)
 p.attackAnimTime=math.max(0,p.attackAnimTime-dt)
 p.dashTime=math.max(0,p.dashTime-dt);p.invul=math.max(0,p.invul-dt)
 p.stamina=math.min(p.maxStamina,p.stamina+dt*24)
 for i=#self.effects,1,-1 do local fx=self.effects[i];fx.t=fx.t-dt;if fx.t<=0 then table.remove(self.effects,i) end end
 if self.state~='fight' then return end
 local mx=(love.keyboard.isDown('d') and 1 or 0)-(love.keyboard.isDown('a') and 1 or 0)
 local my=(love.keyboard.isDown('s') and 1 or 0)-(love.keyboard.isDown('w') and 1 or 0)
 p.moving=(mx~=0 or my~=0)
 if mx~=0 or my~=0 then
  local nx,ny=norm(mx,my);local speed=p.speed*(Items.has(p,'haste') and 1.22 or 1)
  p.facing=Iso.direction(nx,ny)
  p.faceX,p.faceY=Iso.vector(p.facing)
  self:move(nx*speed,ny*speed,dt)
 end
 local ax=(love.keyboard.isDown('right') and 1 or 0)-(love.keyboard.isDown('left') and 1 or 0)
 local ay=(love.keyboard.isDown('down') and 1 or 0)-(love.keyboard.isDown('up') and 1 or 0)
 if ax~=0 or ay~=0 then
  if math.abs(ax)>math.abs(ay) then p.faceX,p.faceY=(ax>0 and 1 or -1),0
  else p.faceX,p.faceY=0,(ay>0 and 1 or -1) end
  p.facing=Iso.direction(p.faceX,p.faceY)
  self:shoot()
 end
 for i=#self.shots,1,-1 do
  local s=self.shots[i]
  s.x=s.x+s.dx*s.speed*dt;s.y=s.y+s.dy*s.speed*dt;s.ttl=s.ttl-dt
  local remove=s.ttl<=0 or not Arena.isInside(s.x,s.y,s.r or 0)
  if not remove then
   if s.enemy then
    if len(s.x-p.x,s.y-p.y)<s.r+p.r then self:damagePlayer(s.damage);remove=true end
   else
    for _,e in ipairs(self.enemies) do
     if e.hp>0 and not s.hit[e] and len(s.x-e.x,s.y-e.y)<s.r+e.r then
      s.hit[e]=true;e.hp=e.hp-s.damage;e.flash=.12
      if Items.has(p,'ember') then e.burn=2 end
      if Items.has(p,'frost') then e.slow=1.6 end
      addFx(self,e.x,e.y,{1,.72,.26},21,.14)
      if s.pierce>0 then s.pierce=s.pierce-1 else remove=true;break end
     end
    end
   end
  end
  if remove then table.remove(self.shots,i) end
 end
 for i=#self.enemies,1,-1 do
  local e=self.enemies[i]
  e.flash=math.max(0,e.flash-dt);e.cd=e.cd-dt;e.slow=math.max(0,e.slow-dt)
  if e.burn>0 then e.burn=e.burn-dt;e.hp=e.hp-.9*dt end
  if e.hp<=0 then
   addFx(self,e.x,e.y,{1,.45,.18},47,.34);table.remove(self.enemies,i);self.kills=self.kills+1
   self.player.coins=self.player.coins+love.math.random(1,3)
  else
   local vx,vy=norm(p.x-e.x,p.y-e.y)
   local dd=len(p.x-e.x,p.y-e.y)
   local speed=e.speed*(e.slow>0 and .48 or 1)
   if e.kind=='archer' then
    if dd<230 then e.x=e.x-vx*speed*dt*.6;e.y=e.y-vy*speed*dt*.6
    elseif dd>335 then e.x=e.x+vx*speed*dt*.5;e.y=e.y+vy*speed*dt*.5 end
   elseif dd>42 then e.x=e.x+vx*speed*dt;e.y=e.y+vy*speed*dt end
   e.x,e.y=Arena.resolve(e.x,e.y,e.r)
   if (e.kind=='archer' or e.kind=='boss') and e.cd<=0 and dd<550 then
    local bullets=e.kind=='boss' and 5 or 1
    local base=math.atan2(vy,vx)
    for j=1,bullets do
     local a=base+(j-(bullets+1)/2)*.20
     self.shots[#self.shots+1]={x=e.x,y=e.y,dx=cos(a),dy=sin(a),speed=e.kind=='boss' and 290 or 340,
       ttl=2.2,enemy=true,r=e.kind=='boss' and 12 or 9,damage=1}
    end
    e.cd=e.kind=='boss' and 1.65 or 1.9
   end
   if dd<e.r+p.r then self:damagePlayer(1) end
  end
 end
 if #self.enemies==0 and self.state=='fight' then
  self.player.charge=math.min(p.maxCharge,p.charge+1)
  if not self.rewarded[self.roomIndex] then
   self.rewarded[self.roomIndex]=true
   self.options=Items.choose(Items.catalog,p.items,3)
   self.state=#self.options>0 and 'reward' or 'clear'
  else self.state='clear' end
 end
end
function Game:pick(n)
 if self.state~='reward' then return end
 local item=self.options[n];if not item then return end
 Items.apply(self.player,item)
 self.lastItem=item.name;self.state='clear'
end
function Game:nextRoom()
 if self.state~='clear' then return end
 if self.roomIndex>=Rooms.total then self.state='victory';return end
 self:loadRoom(self.roomIndex+1)
end
function Game:nearBodoque()
 local npc=Arena.map.bodoque
 local dx,dy=self.player.x-npc.x,self.player.y-npc.y
 return dx*dx+dy*dy<=(npc.radius+44)^2
end
return Game
