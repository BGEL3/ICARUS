-- ICARUS: Torre del Sol - prototipo jugable para LÖVE 11.x
local W,H=480,720
local player,enemies,shots,enemyShots,particles,items
local mode='title'; local time=0; local room=1; local kills=0; local hp=5; local maxhp=5
local dash=0; local swing=0; local pulseFlash=0; local targetLock=nil; local selfBurn=0; local selfBurnCd=0; local fireCd=0; local invuln=0; local shake=0; local flash=0; local choice=1; local upgrade=nil; local aimX,aimY=0,-1; local pulseCd=0
local upgrades={
 {name='PLUMAS DE ASCLEPIO',desc='Las plumas hacen más daño y queman más.',icon='↗',apply=function() player.damage=player.damage+1;player.burnDuration=player.burnDuration+1 end},
 {name='CORAZÓN DE BRASA',desc='La auto-incineración dura más y potencia más.',icon='»',apply=function() player.selfBurnDuration=player.selfBurnDuration+2;player.selfBurnMultiplier=player.selfBurnMultiplier+.5 end},
 {name='HOGUERA SOLAR',desc='La llamarada recupera su carga antes.',icon='✦',apply=function() player.spellCooldown=math.max(1.5,player.spellCooldown*.7) end}}
local colors={bg={.055,.063,.08},floor={.11,.12,.13},stone={.19,.19,.18},edge={.34,.31,.25},gold={.83,.62,.29},cream={.88,.83,.69},muted={.48,.46,.4},red={.78,.27,.22},teal={.29,.56,.51},shadow={.025,.03,.04}}
local function rect(c,x,y,w,h) love.graphics.setColor(c); love.graphics.rectangle('fill',x,y,w,h) end
local function text(s,x,y,size,c,font) love.graphics.setColor(c or colors.cream); love.graphics.setFont(font or love.graphics.newFont(size)); love.graphics.print(s,x,y) end
local function center(s,y,size,c,font) local f=font or love.graphics.newFont(size); love.graphics.setFont(f); love.graphics.setColor(c or colors.cream); love.graphics.printf(s,0,y,W,'center') end
local function roomSpawn()
 enemies={}; shots={}; enemyShots={}; items={}; local n=math.min(3+room,9)
 for i=1,n do local x=70+((i*83+room*37)%340); local y=125+((i*107+room*59)%440); enemies[#enemies+1]={x=x,y=y,hp= i%4==0 and 16 or 12,kind=i%4==0 and 'brute' or 'shade',speed=35+(i%3)*9,cd=.4+i*.2} end
 if room%3==0 then enemies[#enemies+1]={x=W/2,y=160,hp=120,kind='boss',speed=28,cd=.6}; end
end
local function reset() player={x=W/2,y=H-120,speed=190,rate=.42,damage=1,burnDuration=2.4,selfBurnDuration=6,selfBurnMultiplier=2,spellCooldown=3,pierce=false,aimx=0,aimy=-1}; hp=5;maxhp=5;room=1;kills=0;time=0;mode='play';dash=0;invuln=0;targetLock=nil;roomSpawn() end
function love.load() love.window.setMode(W,H,{resizable=true,vsync=1}); love.window.setTitle('ICARUS — Torre del Sol'); love.graphics.setDefaultFilter('nearest','nearest'); math.randomseed(os.time()) end
local function moveAxis() local x,y=0,0; if love.keyboard.isDown('a','left') then x=x-1 end;if love.keyboard.isDown('d','right') then x=x+1 end;if love.keyboard.isDown('w','up') then y=y-1 end;if love.keyboard.isDown('s','down') then y=y+1 end; local l=math.sqrt(x*x+y*y);if l>0 then x=x/l;y=y/l end;return x,y end
function love.keypressed(k)
 if mode=='title' and (k=='space' or k=='return') then reset() elseif mode=='dead' and (k=='space' or k=='return') then reset() elseif mode=='upgrade' then if k=='j' or k=='left' then choice=(choice+1)%3+1 elseif k=='k' or k=='right' then choice=choice%3+1 elseif k=='l' or k=='space' or k=='return' then upgrade=upgrades[choice];upgrade.apply();room=room+1;mode='play';roomSpawn() end
 elseif mode=='play' and (k=='space' or k=='lshift') and dash<=0 then dash=.18;invuln=.32 elseif mode=='play' and k=='i' and selfBurnCd<=0 and hp>1 then hp=hp-1;selfBurn=player.selfBurnDuration;selfBurnCd=12 elseif mode=='play' and k=='l' then local ordered={};for _,e in ipairs(enemies) do ordered[#ordered+1]=e end;table.sort(ordered,function(a,b)local ax,ay=a.x-player.x,a.y-player.y;local bx,by=b.x-player.x,b.y-player.y;return ax*ax+ay*ay<bx*bx+by*by end);if #ordered>0 then local idx=0;for i,e in ipairs(ordered) do if e==targetLock then idx=i end end;targetLock=ordered[idx%#ordered+1] end elseif mode=='play' and k=='k' and pulseCd<=0 then pulseCd=player.spellCooldown;pulseFlash=.22;enemyShots={};for i=#enemies,1,-1 do local e=enemies[i];local dx,dy=e.x-player.x,e.y-player.y;if dx*dx+dy*dy<105^2 then e.hp=e.hp-(selfBurn>0 and 8 or 5);e.burn=math.max(e.burn or 0,player.burnDuration);e.burnTick=0;if e.hp<=0 then table.remove(enemies,i);kills=kills+1 end end end end end
function love.update(dt)
 if love.keyboard.isDown('escape') then if mode=='play' then mode='title' end end
 if mode=='title' then time=time+dt;return end;if mode~='play' then time=time+dt;return end
 time=time+dt;fireCd=math.max(0,fireCd-dt);swing=math.max(0,swing-dt);selfBurn=math.max(0,selfBurn-dt);selfBurnCd=math.max(0,selfBurnCd-dt);pulseFlash=math.max(0,pulseFlash-dt);dash=math.max(0,dash-dt);invuln=math.max(0,invuln-dt);shake=math.max(0,shake-dt*22);flash=math.max(0,flash-dt)
 local mx,my=moveAxis(); local speed=player.speed*(dash>0 and 3.1 or 1);player.x=math.max(30,math.min(W-30,player.x+mx*speed*dt));player.y=math.max(102,math.min(H-62,player.y+my*speed*dt))
 pulseCd=math.max(0,pulseCd-dt);local target=targetLock;local valid=false;if targetLock then for _,e in ipairs(enemies) do if e==targetLock then valid=true end end end;if not valid then targetLock=nil;target=nil end;if target then local ax,ay=target.x-player.x,target.y-player.y;local l=math.sqrt(ax*ax+ay*ay);if l>0 then player.aimx=ax/l;player.aimy=ay/l elseif mx~=0 or my~=0 then player.aimx=mx;player.aimy=my end elseif mx~=0 or my~=0 then player.aimx=mx;player.aimy=my end
 if love.keyboard.isDown('j') and fireCd<=0 then fireCd=player.rate;shots[#shots+1]={x=player.x+player.aimx*12,y=player.y+player.aimy*12,vx=player.aimx*470,vy=player.aimy*470,life=1.1,damage=player.damage*(selfBurn>0 and player.selfBurnMultiplier or 1)} end
 for i=#shots,1,-1 do local b=shots[i];b.x=b.x+b.vx*dt;b.y=b.y+b.vy*dt;b.life=b.life-dt;local hit=false;for j=#enemies,1,-1 do local e=enemies[j];local dx,dy=b.x-e.x,b.y-e.y;if dx*dx+dy*dy<(e.kind=='boss' and 26 or 18)^2 then e.hp=e.hp-b.damage;e.burn=math.max(e.burn or 0,player.burnDuration);e.burnTick=0;hit=true;if e.hp<=0 then table.remove(enemies,j);kills=kills+1 end;break end end;if hit or b.life<=0 or b.x<0 or b.x>W or b.y<70 or b.y>H-30 then table.remove(shots,i) end end;for i=#enemies,1,-1 do local e=enemies[i];if e.burn and e.burn>0 then e.burn=e.burn-dt;e.burnTick=e.burnTick-dt;if e.burnTick<=0 then e.burnTick=.6;e.hp=e.hp-1;if e.hp<=0 then table.remove(enemies,i);kills=kills+1 end end end end;for _,e in ipairs(enemies) do local dx,dy=player.x-e.x,player.y-e.y;local d=math.sqrt(dx*dx+dy*dy);if d>0 then if e.kind=='boss' and d<230 then e.x=e.x-dx/d*e.speed*dt*.6;e.y=e.y-dy/d*e.speed*dt*.6 else e.x=e.x+dx/d*e.speed*dt;e.y=e.y+dy/d*e.speed*dt end;e.x=math.max(e.kind=='boss' and 42 or 30,math.min(e.kind=='boss' and W-42 or W-30,e.x));e.y=math.max(e.kind=='boss' and 112 or 96,math.min(e.kind=='boss' and H-68 or H-50,e.y)) end;e.cd=e.cd-dt;if e.cd<=0 then e.cd=e.kind=='boss' and .75 or 1.5; local vx,vy=player.x-e.x,player.y-e.y;local l=math.sqrt(vx*vx+vy*vy);enemyShots[#enemyShots+1]={x=e.x,y=e.y,vx=vx/l*(e.kind=='boss' and 185 or 135),vy=vy/l*(e.kind=='boss' and 185 or 135),r=e.kind=='boss' and 6 or 4} end end
 
 for i=#enemyShots,1,-1 do local s=enemyShots[i];s.x=s.x+s.vx*dt;s.y=s.y+s.vy*dt;if (s.x-player.x)^2+(s.y-player.y)^2<17^2 and invuln<=0 then hp=hp-1;invuln=.8;shake=.3;table.remove(enemyShots,i);if hp<=0 then mode='dead' end elseif s.x<-10 or s.x>W+10 or s.y<-10 or s.y>H+10 then table.remove(enemyShots,i) end end
 for i=#items,1,-1 do local q=items[i];if (q.x-player.x)^2+(q.y-player.y)^2<25^2 then table.remove(items,i);hp=math.min(maxhp,hp+1) end end
 for i=#particles,1,-1 do local p=particles[i];p.x=p.x+p.vx*dt;p.y=p.y+p.vy*dt;p.life=p.life-dt;if p.life<=0 then table.remove(particles,i) end end
 if #enemies==0 then mode='upgrade';upgrade=upgrades[1];choice=1;if room%3==0 then hp=math.min(maxhp,hp+1) end end
end
local function drawRoom()
 rect(colors.bg,0,0,W,H); for x=16,W-16,32 do rect({.09,.095,.1},x,68,1,H-108) end
 for y=92,H-32,32 do rect({.09,.095,.1},16,y,W-32,1) end
 rect(colors.edge,18,70,W-36,2);rect(colors.edge,18,H-30,W-36,2);rect(colors.edge,18,70,2,H-100);rect(colors.edge,W-20,70,2,H-100)
 for i=1,8 do local yy=85+i*70;rect({.14,.135,.12},18,yy,W-36,2);rect(colors.gold,18,yy,6,2);rect(colors.gold,W-24,yy,6,2) end
 -- stairs and central shaft motif
 rect({.08,.085,.09},W/2-27,90,54,H-120);for y=100,H-50,20 do rect({.15,.145,.13},W/2-30,y,60,2) end
 rect({.25,.22,.16},W/2-10,H-92,20,8);rect({.83,.61,.27},W/2-2,H-90,4,5)
end
local function drawActor(x,y,kind)
 if kind=='player' then rect(colors.shadow,x-9,y+9,18,4);rect(colors.cream,x-6,y-9,12,18);rect(colors.teal,x-7,y-3,14,8);rect(colors.gold,x-4,y-12,8,4);rect(colors.shadow,x-3,y-5,2,2);rect(colors.shadow,x+2,y-5,2,2)
 elseif kind=='boss' then rect(colors.shadow,x-24,y+20,48,8);rect({.44,.25,.18},x-22,y-20,44,40);rect(colors.red,x-17,y-27,34,12);rect(colors.gold,x-16,y-12,32,6);rect(colors.cream,x-12,y-2,7,4);rect(colors.cream,x+5,y-2,7,4);rect(colors.gold,x-28,y-30,8,18);rect(colors.gold,x+20,y-30,8,18)
 elseif kind=='brute' then rect(colors.shadow,x-13,y+11,26,5);rect({.4,.3,.25},x-11,y-12,22,24);rect(colors.red,x-9,y-17,18,8);rect(colors.gold,x-7,y-2,4,3);rect(colors.gold,x+3,y-2,4,3)
 else rect(colors.shadow,x-10,y+9,20,4);rect({.34,.41,.39},x-7,y-10,14,20);rect(colors.teal,x-8,y-13,16,7);rect(colors.gold,x-4,y-4,3,3);rect(colors.gold,x+2,y-4,3,3) end
end
function love.draw()
 local sx,sy=love.graphics.getDimensions();love.graphics.push();love.graphics.scale(sx/W,sy/H);love.graphics.translate(math.random(-shake,shake),math.random(-shake,shake));drawRoom()
 if mode=='title' then center('ICARUS',165,48,colors.cream);center('TORRE DEL SOL',218,13,colors.gold);rect(colors.gold,W/2-32,251,64,2);center('El sol no perdona a quien asciende.',278,13,colors.muted);center('Pero la torre sí ofrece otra oportunidad.',300,13,colors.muted);drawActor(W/2,H-180,'player');center('PULSA ESPACIO PARA ASCENDER',H-112,12,colors.cream);center('WASD apuntar · J pluma ígnea · K llamarada · I incinerarse · L fijar objetivo',H-82,9,colors.muted);love.graphics.pop();return end
 -- top UI
 rect({.035,.04,.05},0,0,W,58);text('ICARUS',18,12,15,colors.cream);text('ASCENSO  '..string.format('%02d',room),W/2-48,15,11,colors.gold);text('✦  '..kills, W-88,15,12,colors.cream)
 for i=1,maxhp do rect(i<=hp and colors.red or { .24,.2,.18},18+(i-1)*19,42,13,7) end
 center(room%3==0 and 'EL GUARDIÁN DESPIERTA' or 'LIMPIA LA CÁMARA PARA ASCENDER',67,9,colors.muted)
 for _,q in ipairs(items) do rect(colors.gold,q.x-6,q.y-6,12,12);rect(colors.cream,q.x-2,q.y-2,4,4) end
 for _,s in ipairs(shots) do love.graphics.setColor(colors.gold);love.graphics.push();love.graphics.translate(s.x,s.y);love.graphics.rotate(math.atan2(s.vy,s.vx));love.graphics.polygon('fill',-8,-2,5,-2,10,0,5,2,-8,2);love.graphics.pop() end
 for _,s in ipairs(enemyShots) do rect(colors.red,s.x-s.r/2,s.y-s.r/2,s.r,s.r) end
 for _,e in ipairs(enemies) do drawActor(e.x,e.y,e.kind);if e==targetLock then love.graphics.setColor(colors.gold);love.graphics.setLineWidth(2);love.graphics.rectangle('line',e.x-17,e.y-20,34,40);love.graphics.setLineWidth(1);love.graphics.setColor(1,1,1,1) end;if e.kind=='boss' then rect({.2,.1,.09},W/2-76,104,152,6);rect(colors.red,W/2-76,104,152*e.hp/120,6) else rect({.2,.13,.12},e.x-10,e.y-21,20,2);rect(colors.gold,e.x-10,e.y-21,20*e.hp/(e.kind=='brute' and 16 or 12),2) end end
 for _,p in ipairs(particles) do rect(colors.gold,p.x-2,p.y-2,4,4) end
 if invuln>0 and math.floor(time*16)%2==0 then love.graphics.setColor(.8,1,1,.5) else love.graphics.setColor(1,1,1,1) end;drawActor(player.x,player.y,'player');love.graphics.setColor(1,1,1,1);if pulseFlash>0 then love.graphics.setColor(colors.gold);love.graphics.setLineWidth(3);love.graphics.circle('line',player.x,player.y,105*(1-pulseFlash/.22));love.graphics.setLineWidth(1);love.graphics.setColor(1,1,1,1) end;if selfBurn>0 then love.graphics.setColor(colors.red);love.graphics.circle('line',player.x,player.y,20+math.sin(time*18)*3);love.graphics.setColor(1,1,1,1) end;if swing>0 then love.graphics.setColor(colors.cream);love.graphics.setLineWidth(4);love.graphics.push();love.graphics.translate(player.x,player.y);love.graphics.rotate(math.atan2(player.aimy,player.aimx));love.graphics.arc('line','open',28,0,30,-1.05,1.05);love.graphics.pop();love.graphics.setLineWidth(1) end
 if mode=='upgrade' then rect({.025,.03,.04,.9},0,0,W,H);center('LA TORRE TE PONE A PRUEBA',185,11,colors.gold);center('ELIGE UNA BENDICIÓN',211,22,colors.cream);rect(colors.gold,46,280,388,118);rect({.07,.075,.08},49,283,382,112);local chosen=upgrades[choice];text(chosen.icon,70,310,28,colors.gold);text(chosen.name,117,305,14,colors.cream);text(chosen.desc,117,335,11,colors.muted);center('J / K CAMBIAR · L O ESPACIO ELEGIR',430,10,colors.cream);center('La vida se restaura al subir.',462,10,colors.muted)
 elseif mode=='dead' then rect({.02,.025,.035,.88},0,0,W,H);center('EL SOL TE ALCANZÓ',264,25,colors.cream);center('Ascenso '..room..'   ·   Almas '..kills,309,12,colors.gold);center('ESPACIO PARA VOLVER A INTENTARLO',367,10,colors.muted) end
 love.graphics.pop()
end
