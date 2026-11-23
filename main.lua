-- ICARUS: Torre del Sol - prototipo jugable para LÖVE 11.x
local W,H=480,720
local player,enemies,shots,enemyShots,particles,items
local mode='title'; local time=0; local room=1; local kills=0; local hp=5; local maxhp=5
local dash=0; local swing=0; local pulseFlash=0; local targetLock=nil; local activeTarget=nil; local focusEnabled=true; local parryTimer=0; local parryCd=0; local parries=0; local selfBurn=0; local selfBurnCd=0; local fireCd=0; local invuln=0; local shake=0; local flash=0; local choice=1; local aimX,aimY=0,-1; local pulseCd=0; local toastMsg=''; local toastTime=0; local itemsOwned={}; local rewardOptions={}
local itemPool={
 {id='plume',name='PLUMAS DE ASCLEPIO',desc='Plumas +1 daño y +1 s de quemadura.',icon='↗',apply=function() player.damage=player.damage+1;player.burnDuration=player.burnDuration+1 end},
 {id='heart',name='CORAZÓN DE BRASA',desc='I dura +2 s y potencia más el fuego.',icon='♥',apply=function() player.selfBurnDuration=player.selfBurnDuration+2;player.selfBurnMultiplier=player.selfBurnMultiplier+.5 end},
 {id='hearth',name='HOGUERA SOLAR',desc='K recupera su carga un 25% antes.',icon='✦',apply=function() player.spellCooldown=math.max(1.5,player.spellCooldown*.75) end},
 {id='ash',name='CENIZA HAMBRIENTA',desc='Matar a un quemado recupera 1 s de K.',icon='·',apply=function() end},
 {id='pulse',name='PULSO DE HESTIA',desc='K detona quemaduras para infligir daño extra.',icon='◎',apply=function() end},
 {id='mirror',name='ESPEJO DE ATENEA',desc='Parry más amplio; prende al atacante.',icon='◉',apply=function() player.parryWindow=.3;player.parryCooldown=.95 end}}
local roomSpawn
local function hasItem(id) for _,v in ipairs(itemsOwned) do if v==id then return true end end;return false end
local function makeRewards() local pool={};for i,v in ipairs(itemPool) do pool[i]=v end;for i=#pool,2,-1 do local j=math.random(i);pool[i],pool[j]=pool[j],pool[i] end;rewardOptions={pool[1],pool[2],pool[3]};choice=1;mode='upgrade' end
local function takeReward() local item=rewardOptions[choice];if not item then return end;item.apply();itemsOwned[#itemsOwned+1]=item.id;toastMsg='OBJETO ADQUIRIDO';if hasItem('ash') and hasItem('plume') then toastMsg='SINERGIA: CENIZA EN CADENA' elseif hasItem('pulse') and hasItem('plume') then toastMsg='SINERGIA: LLAMARADA DE PLUMAS' elseif hasItem('mirror') and hasItem('heart') then toastMsg='SINERGIA: CONTRAATAQUE INCANDESCENTE' end;toastTime=2.5;room=room+1;hp=math.min(maxhp,hp+1);roomSpawn();mode='play' end
local colors={bg={.035,.045,.075},floor={.12,.12,.16},stone={.19,.19,.24},edge={.34,.31,.38},gold={.96,.49,.2},cream={.9,.82,.7},muted={.48,.48,.58},red={.72,.24,.27},teal={.25,.67,.58},shadow={.025,.03,.06},violet={.12,.12,.2},moss={.18,.27,.2},portal={.17,.84,.52},ember={1,.3,.1}}
local function rect(c,x,y,w,h) love.graphics.setColor(c); love.graphics.rectangle('fill',x,y,w,h) end
local function poly(c,...) love.graphics.setColor(c);love.graphics.polygon('fill',...) end
local function line(c,w,...) love.graphics.setColor(c);love.graphics.setLineWidth(w);love.graphics.line(...);love.graphics.setLineWidth(1) end
local function text(s,x,y,size,c,font) love.graphics.setColor(c or colors.cream); love.graphics.setFont(font or love.graphics.newFont(size)); love.graphics.print(s,x,y) end
local function center(s,y,size,c,font) local f=font or love.graphics.newFont(size); love.graphics.setFont(f); love.graphics.setColor(c or colors.cream); love.graphics.printf(s,0,y,W,'center') end
roomSpawn=function()
 enemies={}; shots={}; enemyShots={}; items={}; local n=math.min(3+room,9)
 for i=1,n do local x=70+((i*83+room*37)%340); local y=125+((i*107+room*59)%440); enemies[#enemies+1]={x=x,y=y,hp= i%4==0 and 16 or 12,kind=i%4==0 and 'brute' or 'shade',speed=35+(i%3)*9,cd=.4+i*.2,burn=0,burnTick=0} end
 if room%3==0 then enemies[#enemies+1]={x=W/2,y=160,hp=120,kind='boss',speed=28,cd=.6,burn=0,burnTick=0}; end
end
local function reset() player={x=W/2,y=H-120,speed=190,rate=.42,damage=1,burnDuration=2.4,selfBurnDuration=6,selfBurnMultiplier=2,spellCooldown=3,parryWindow=.2,parryCooldown=1.35,pierce=false,aimx=0,aimy=-1}; hp=5;maxhp=5;room=1;kills=0;time=0;mode='play';dash=0;invuln=0;targetLock=nil;activeTarget=nil;focusEnabled=true;parryTimer=0;parryCd=0;parries=0;itemsOwned={};rewardOptions={};pulseCd=0;selfBurn=0;selfBurnCd=0;roomSpawn() end
function love.load() love.window.setMode(W,H,{resizable=true,vsync=1}); love.window.setTitle('ICARUS — Torre del Sol'); love.graphics.setDefaultFilter('nearest','nearest'); math.randomseed(os.time()) end
local function moveAxis() local x,y=0,0; if love.keyboard.isDown('a','left') then x=x-1 end;if love.keyboard.isDown('d','right') then x=x+1 end;if love.keyboard.isDown('w','up') then y=y-1 end;if love.keyboard.isDown('s','down') then y=y+1 end; local l=math.sqrt(x*x+y*y);if l>0 then x=x/l;y=y/l end;return x,y end
function love.keypressed(k)
 if mode=='title' and (k=='space' or k=='return') then reset()
 elseif mode=='dead' and (k=='space' or k=='return') then reset()
 elseif mode=='upgrade' then
  if k=='j' or k=='left' then choice=(choice+1)%3+1 elseif k=='k' or k=='right' then choice=choice%3+1 elseif k=='l' or k=='space' or k=='return' then takeReward() end
 elseif mode=='play' then
  if k=='space' or k=='lshift' then if dash<=0 then dash=.18;invuln=.32 end
  elseif k=='i' and selfBurnCd<=0 and hp>1 then hp=hp-1;selfBurn=player.selfBurnDuration;selfBurnCd=12
  elseif k=='o' then focusEnabled=not focusEnabled;targetLock=nil;toastMsg=focusEnabled and 'AUTOENFOQUE ACTIVADO' or 'AUTOENFOQUE DESACTIVADO';toastTime=1.2
  elseif k=='h' and parryCd<=0 then parryTimer=player.parryWindow;parryCd=player.parryCooldown
  elseif k=='l' then local ordered={};for _,e in ipairs(enemies) do ordered[#ordered+1]=e end;table.sort(ordered,function(a,b)local ax,ay=a.x-player.x,a.y-player.y;local bx,by=b.x-player.x,b.y-player.y;return ax*ax+ay*ay<bx*bx+by*by end);if #ordered>0 then local idx=0;for i,e in ipairs(ordered) do if e==targetLock then idx=i end end;targetLock=ordered[idx%#ordered+1] end
  elseif k=='k' and pulseCd<=0 then pulseCd=player.spellCooldown; pulseFlash=.22;enemyShots={};for i=#enemies,1,-1 do local e=enemies[i];local dx,dy=e.x-player.x,e.y-player.y;if dx*dx+dy*dy<105^2 then local wasBurning=e.burn and e.burn>0;local bonus=hasItem('pulse') and wasBurning and 5 or 0;e.hp=e.hp-((selfBurn>0 and 8 or 5)+bonus);if bonus>0 then e.burn=0;toastMsg='SINERGIA: QUEMADURA DETONADA';toastTime=1.1 else e.burn=math.max(e.burn or 0,player.burnDuration);e.burnTick=0 end;if e.hp<=0 then if wasBurning and hasItem('ash') then pulseCd=math.max(0,pulseCd-1) end;table.remove(enemies,i);kills=kills+1 end end end end
 end
end
function love.update(dt)
 if love.keyboard.isDown('escape') then if mode=='play' then mode='title' end end
 if mode=='title' then time=time+dt;return end;if mode~='play' then time=time+dt;return end
 time=time+dt;fireCd=math.max(0,fireCd-dt);swing=math.max(0,swing-dt);selfBurn=math.max(0,selfBurn-dt);selfBurnCd=math.max(0,selfBurnCd-dt);pulseFlash=math.max(0,pulseFlash-dt);parryTimer=math.max(0,parryTimer-dt);parryCd=math.max(0,parryCd-dt);toastTime=math.max(0,toastTime-dt);dash=math.max(0,dash-dt);invuln=math.max(0,invuln-dt);shake=math.max(0,shake-dt*22);flash=math.max(0,flash-dt)
 local mx,my=moveAxis(); local speed=player.speed*(dash>0 and 3.1 or 1);player.x=math.max(30,math.min(W-30,player.x+mx*speed*dt));player.y=math.max(102,math.min(H-62,player.y+my*speed*dt))
 pulseCd=math.max(0,pulseCd-dt);local target=targetLock;local valid=false;if targetLock then for _,e in ipairs(enemies) do if e==targetLock then valid=true end end end;if not valid then targetLock=nil;target=nil end;if not target and focusEnabled then local best=math.huge;for _,e in ipairs(enemies) do local dx,dy=e.x-player.x,e.y-player.y;local d=dx*dx+dy*dy;if d<best then best=d;target=e end end end;activeTarget=target;if target then local ax,ay=target.x-player.x,target.y-player.y;local l=math.sqrt(ax*ax+ay*ay);if l>0 then player.aimx=ax/l;player.aimy=ay/l end elseif mx~=0 or my~=0 then player.aimx=mx;player.aimy=my end
 if love.keyboard.isDown('j') and fireCd<=0 then fireCd=player.rate;shots[#shots+1]={x=player.x+player.aimx*12,y=player.y+player.aimy*12,vx=player.aimx*470,vy=player.aimy*470,life=1.1,damage=player.damage*(selfBurn>0 and player.selfBurnMultiplier or 1)} end
 for i=#shots,1,-1 do local b=shots[i];b.x=b.x+b.vx*dt;b.y=b.y+b.vy*dt;b.life=b.life-dt;local hit=false;for j=#enemies,1,-1 do local e=enemies[j];local dx,dy=b.x-e.x,b.y-e.y;if dx*dx+dy*dy<(e.kind=='boss' and 26 or 18)^2 then e.hp=e.hp-b.damage;e.burn=math.max(e.burn or 0,player.burnDuration);e.burnTick=0;hit=true;if e.hp<=0 then if e.burn>0 and hasItem('ash') then pulseCd=math.max(0,pulseCd-1) end;table.remove(enemies,j);kills=kills+1 end;break end end;if hit or b.life<=0 or b.x<0 or b.x>W or b.y<70 or b.y>H-30 then table.remove(shots,i) end end;for i=#enemies,1,-1 do local e=enemies[i];if e.burn and e.burn>0 then e.burn=e.burn-dt;e.burnTick=e.burnTick-dt;if e.burnTick<=0 then e.burnTick=.6;e.hp=e.hp-1;if e.hp<=0 then if hasItem('ash') then pulseCd=math.max(0,pulseCd-1) end;table.remove(enemies,i);kills=kills+1 end end end end;for _,e in ipairs(enemies) do local dx,dy=player.x-e.x,player.y-e.y;local d=math.sqrt(dx*dx+dy*dy);if d>0 then if e.kind=='boss' and d<230 then e.x=e.x-dx/d*e.speed*dt*.6;e.y=e.y-dy/d*e.speed*dt*.6 else e.x=e.x+dx/d*e.speed*dt;e.y=e.y+dy/d*e.speed*dt end;e.x=math.max(e.kind=='boss' and 42 or 30,math.min(e.kind=='boss' and W-42 or W-30,e.x));e.y=math.max(e.kind=='boss' and 112 or 96,math.min(e.kind=='boss' and H-68 or H-50,e.y)) end;e.cd=e.cd-dt;if e.cd<=0 then e.cd=e.kind=='boss' and .75 or 1.5; local vx,vy=player.x-e.x,player.y-e.y;local l=math.sqrt(vx*vx+vy*vy);enemyShots[#enemyShots+1]={x=e.x,y=e.y,vx=vx/l*(e.kind=='boss' and 185 or 135),vy=vy/l*(e.kind=='boss' and 185 or 135),r=e.kind=='boss' and 6 or 4,source=e} end end
 
 for i=#enemyShots,1,-1 do local s=enemyShots[i];s.x=s.x+s.vx*dt;s.y=s.y+s.vy*dt;if (s.x-player.x)^2+(s.y-player.y)^2<17^2 then if parryTimer>0 then local e=s.source;if e then e.hp=e.hp-( (hasItem('mirror') and 5 or 3) + (hasItem('heart') and selfBurn>0 and 4 or 0) );e.burn=math.max(e.burn or 0,player.burnDuration);e.burnTick=0;if e.hp<=0 then for j=#enemies,1,-1 do if enemies[j]==e then table.remove(enemies,j);break end end;kills=kills+1 end end;parries=parries+1;pulseCd=math.max(0,pulseCd-1);toastMsg=(hasItem('mirror') and hasItem('heart') and selfBurn>0) and 'SINERGIA: CONTRAATAQUE INCANDESCENTE' or (hasItem('mirror') and 'PARRY ÍGNEO' or 'PARRY');toastTime=1;table.remove(enemyShots,i) elseif invuln<=0 then hp=hp-1;invuln=.8;shake=.3;table.remove(enemyShots,i);if hp<=0 then mode='dead' end end elseif s.x<-10 or s.x>W+10 or s.y<-10 or s.y>H+10 then table.remove(enemyShots,i) end end
 for i=#items,1,-1 do local q=items[i];if (q.x-player.x)^2+(q.y-player.y)^2<25^2 then table.remove(items,i);hp=math.min(maxhp,hp+1) end end
 for i=#particles,1,-1 do local p=particles[i];p.x=p.x+p.vx*dt;p.y=p.y+p.vy*dt;p.life=p.life-dt;if p.life<=0 then table.remove(particles,i) end end
 if #enemies==0 then makeRewards();if room%3==0 then hp=math.min(maxhp,hp+1) end end
end
local function drawTorch(x,y)
 love.graphics.setColor(colors.ember[1],colors.ember[2],colors.ember[3],.10);love.graphics.circle('fill',x,y,31)
 love.graphics.setColor(colors.gold[1],colors.gold[2],colors.gold[3],.16);love.graphics.circle('fill',x,y,18)
 rect({.24,.22,.23},x-9,y+3,18,8);rect({.42,.35,.28},x-7,y,14,4);poly(colors.ember,x-4,y,x,y-10,x+3,y-2,x+6,y-8,x+6,y+1);poly(colors.gold,x-2,y,x,y-6,x+2,y)
end
local function drawColumn(x,y)
 rect(colors.shadow,x-15,y+19,30,7);rect(colors.edge,x-14,y+12,28,8);rect({.24,.23,.28},x-10,y-15,20,27);rect({.34,.31,.34},x-13,y-18,26,5);rect({.25,.24,.28},x-12,y-15,4,26);rect({.25,.24,.28},x+8,y-15,4,26);rect(colors.edge,x-15,y+10,30,5);rect(colors.edge,x-17,y-22,34,5);rect({.42,.34,.3},x-13,y-24,26,3)
end
local function drawRoom()
 rect(colors.bg,0,0,W,H);poly(colors.violet,0,70,88,70,120,H-30,0,H-30);poly({.075,.08,.13},W,70,W-88,70,W-120,H-30,W,H-30)
 -- Piso de losas en rombos, con perspectiva de cámara elevada.
 poly({.115,.12,.16},18,78,W-18,78,W-18,H-30,18,H-30)
 for row=0,27 do local cy=84+row*23;local off=row%2==0 and 0 or 24
  for col=-1,10 do local cx=off+col*48;local shade=((row*7+col*3)%5)*.008
   poly({.14+shade,.14+shade,.18+shade},cx,cy-12,cx+24,cy,cx,cy+12,cx-24,cy)
   line({.27,.25,.29},1,cx,cy-12,cx+24,cy,cx,cy+12,cx-24,cy,cx,cy-12)
  end
 end
 -- Borde de piedra y ruinas laterales.
 rect(colors.edge,14,75,W-28,7);rect({.09,.09,.14},14,82,8,H-113);rect({.09,.09,.14},W-22,82,8,H-113);rect(colors.edge,14,H-34,W-28,6)
 for i=0,6 do local yy=112+i*86;drawColumn(27,yy);drawColumn(W-27,yy);if i%2==0 then drawTorch(50,yy+23);drawTorch(W-50,yy+23) end end
 -- Portal verde al final de la cámara y escalinata central.
 love.graphics.setColor(colors.portal[1],colors.portal[2],colors.portal[3],.08);love.graphics.circle('fill',W/2,96,55)
 rect({.16,.17,.18},W/2-36,78,72,54);rect({.35,.31,.29},W/2-31,80,5,48);rect({.35,.31,.29},W/2+26,80,5,48);rect({.26,.24,.25},W/2-36,78,72,5)
 love.graphics.setColor(colors.portal[1],colors.portal[2],colors.portal[3],.27);love.graphics.ellipse('fill',W/2,104,21,26);love.graphics.setColor(colors.portal);love.graphics.ellipse('line',W/2,104,21,26);line({.5,.9,.62},2,W/2-12,122,W/2+12,122)
 for i=1,4 do local y=H-101+i*8;rect({.24,.22,.23},W/2-22-i*5,y,44+i*10,5);rect(colors.edge,W/2-22-i*5,y,44+i*10,2) end
 -- Medallón solar grabado en las losas.
 love.graphics.setColor(colors.gold[1],colors.gold[2],colors.gold[3],.18);love.graphics.circle('line',W/2,H/2+5,43);love.graphics.circle('line',W/2,H/2+5,32);for i=0,7 do local a=i*math.pi/4;line({.57,.34,.22},2,W/2+math.cos(a)*34,H/2+5+math.sin(a)*34,W/2+math.cos(a)*42,H/2+5+math.sin(a)*42) end
end
local function drawActor(x,y,kind)
 rect(colors.shadow,x-14,y+13,28,6)
 if kind=='player' then
  -- Ícaro: túnica coral, cinturón dorado y alas de pluma claras.
  poly({.72,.65,.54},x-7,y-5,x-22,y-17,x-25,y-10,x-11,y+2);poly(colors.cream,x-8,y-7,x-20,y-21,x-17,y-11,x-10,y+1)
  poly({.72,.65,.54},x+7,y-5,x+22,y-17,x+25,y-10,x+11,y+2);poly(colors.cream,x+8,y-7,x+20,y-21,x+17,y-11,x+10,y+1)
  poly(colors.red,x-7,y-7,x+7,y-7,x+9,y+9,x-8,y+9);rect(colors.gold,x-8,y+1,16,3);rect({.69,.38,.25},x-5,y-12,10,7);rect(colors.gold,x-5,y-15,10,4);rect({.16,.12,.14},x-3,y-9,2,2);rect({.16,.12,.14},x+2,y-9,2,2);rect({.68,.44,.28},x-6,y+9,4,6);rect({.68,.44,.28},x+2,y+9,4,6);rect(colors.cream,x-6,y+14,6,2);rect(colors.cream,x+1,y+14,6,2)
 elseif kind=='boss' then
  -- Guardián minotauro provisional: masa de piedra volcánica, cuernos y brasa.
  poly({.31,.20,.19},x-24,y-17,x-18,y-27,x-8,y-21,x+8,y-21,x+18,y-27,x+24,y-17,x+22,y+14,x-22,y+14);poly({.48,.27,.19},x-16,y-17,x+16,y-17,x+18,y+14,x-18,y+14);poly(colors.edge,x-18,y-16,x-30,y-31,x-27,y-12,x-20,y-8);poly(colors.edge,x+18,y-16,x+30,y-31,x+27,y-12,x+20,y-8);rect(colors.ember,x-12,y-5,7,3);rect(colors.ember,x+5,y-5,7,3);rect({.14,.1,.12},x-7,y+4,14,5);rect(colors.gold,x-3,y+4,6,2);rect({.21,.17,.19},x-23,y+11,46,9);rect(colors.red,x-17,y+16,12,7);rect(colors.red,x+5,y+16,12,7)
 elseif kind=='brute' then
  poly({.33,.24,.23},x-16,y-12,x-11,y-19,x+11,y-19,x+16,y-12,x+14,y+12,x-14,y+12);rect({.55,.28,.22},x-11,y-15,22,8);rect(colors.gold,x-9,y-3,5,3);rect(colors.gold,x+4,y-3,5,3);rect({.24,.2,.2},x-17,y+6,34,9)
 else
  poly({.24,.31,.36},x-12,y-12,x-8,y-17,x+8,y-17,x+12,y-12,x+9,y+11,x-9,y+11);poly({.35,.25,.38},x-8,y-16,x,y-21,x+8,y-16,x+10,y-8,x-10,y-8);rect(colors.gold,x-7,y-4,4,3);rect(colors.gold,x+3,y-4,4,3);poly({.22,.58,.53},x-15,y-4,x-21,y-14,x-17,y-7,x-12,y+2);poly({.22,.58,.53},x+15,y-4,x+21,y-14,x+17,y-7,x+12,y+2)
 end
end
function love.draw()
 local sx,sy=love.graphics.getDimensions();love.graphics.push();love.graphics.scale(sx/W,sy/H);love.graphics.translate(math.random(-shake,shake),math.random(-shake,shake));drawRoom()
 if mode=='title' then center('ICARUS',165,48,colors.cream);center('TORRE DEL SOL',218,13,colors.gold);rect(colors.gold,W/2-32,251,64,2);center('El sol no perdona a quien asciende.',278,13,colors.muted);center('Pero la torre sí ofrece otra oportunidad.',300,13,colors.muted);drawActor(W/2,H-180,'player');center('PULSA ESPACIO PARA ASCENDER',H-112,12,colors.cream);center('WASD apuntar · J pluma · K llamarada · I incinerarse · O auto foco · H parry',H-82,9,colors.muted);love.graphics.pop();return end
 -- top UI
 rect({.035,.04,.05},0,0,W,58);text('ICARUS',18,12,15,colors.cream);text('ASCENSO  '..string.format('%02d',room),W/2-48,15,11,colors.gold);text('✦  '..kills, W-88,15,12,colors.cream);text('OBJ '..#itemsOwned, W-116,23,9,colors.cream);text('O AUTO '..(focusEnabled and 'ON' or 'OFF'),W-116,35,9,focusEnabled and colors.gold or colors.muted);text('H PARRY '..(parryCd<=0 and 'LISTO' or string.format('%.1fs',parryCd)),W-116,47,9,parryCd<=0 and colors.gold or colors.muted)
 for i=1,maxhp do rect(i<=hp and colors.red or { .24,.2,.18},18+(i-1)*19,42,13,7) end
 center(room%3==0 and 'EL GUARDIÁN DESPIERTA' or 'LIMPIA LA CÁMARA PARA ASCENDER',67,9,colors.muted)
 for _,q in ipairs(items) do rect(colors.gold,q.x-6,q.y-6,12,12);rect(colors.cream,q.x-2,q.y-2,4,4) end
 for _,s in ipairs(shots) do love.graphics.setColor(colors.gold);love.graphics.push();love.graphics.translate(s.x,s.y);love.graphics.rotate(math.atan2(s.vy,s.vx));love.graphics.polygon('fill',-8,-2,5,-2,10,0,5,2,-8,2);love.graphics.pop() end
 for _,s in ipairs(enemyShots) do rect(colors.red,s.x-s.r/2,s.y-s.r/2,s.r,s.r) end
 for _,e in ipairs(enemies) do drawActor(e.x,e.y,e.kind);if e==activeTarget then love.graphics.setColor(colors.gold);love.graphics.circle('fill',e.x,e.y,4);love.graphics.setColor(colors.cream);love.graphics.circle('line',e.x,e.y,8);love.graphics.setColor(1,1,1,1) end;if e.kind=='boss' then rect({.2,.1,.09},W/2-76,104,152,6);rect(colors.red,W/2-76,104,152*e.hp/120,6) else rect({.2,.13,.12},e.x-10,e.y-21,20,2);rect(colors.gold,e.x-10,e.y-21,20*e.hp/(e.kind=='brute' and 16 or 12),2) end end
 for _,p in ipairs(particles) do rect(colors.gold,p.x-2,p.y-2,4,4) end
 if invuln>0 and math.floor(time*16)%2==0 then love.graphics.setColor(.8,1,1,.5) else love.graphics.setColor(1,1,1,1) end;drawActor(player.x,player.y,'player');love.graphics.setColor(1,1,1,1);if pulseFlash>0 then love.graphics.setColor(colors.gold);love.graphics.setLineWidth(3);love.graphics.circle('line',player.x,player.y,105*(1-pulseFlash/.22));love.graphics.setLineWidth(1);love.graphics.setColor(1,1,1,1) end;if selfBurn>0 then love.graphics.setColor(colors.red);love.graphics.circle('line',player.x,player.y,20+math.sin(time*18)*3);love.graphics.setColor(1,1,1,1) end;if parryTimer>0 then love.graphics.setColor(colors.cream);love.graphics.setLineWidth(3);love.graphics.circle('line',player.x,player.y,24);love.graphics.setLineWidth(1);love.graphics.setColor(1,1,1,1) end;if swing>0 then love.graphics.setColor(colors.cream);love.graphics.setLineWidth(4);love.graphics.push();love.graphics.translate(player.x,player.y);love.graphics.rotate(math.atan2(player.aimy,player.aimx));love.graphics.arc('line','open',28,0,30,-1.05,1.05);love.graphics.pop();love.graphics.setLineWidth(1) end
 if mode=='upgrade' then rect({.025,.03,.04,.9},0,0,W,H);center('LA TORRE TE PONE A PRUEBA',185,11,colors.gold);center('ELIGE UN OBJETO PASIVO',211,22,colors.cream);rect(colors.gold,46,280,388,118);rect({.07,.075,.08},49,283,382,112);local chosen=rewardOptions[choice];text(chosen.icon,70,310,28,colors.gold);text(chosen.name,117,305,14,colors.cream);text(chosen.desc,117,335,11,colors.muted);center('J / K CAMBIAR · L O ESPACIO ELEGIR',430,10,colors.cream);center('Inventario '..#itemsOwned..' · H parry · O autoenfoque',462,10,colors.muted)
 elseif mode=='dead' then rect({.02,.025,.035,.88},0,0,W,H);center('EL SOL TE ALCANZÓ',264,25,colors.cream);center('Ascenso '..room..'   ·   Almas '..kills,309,12,colors.gold);center('ESPACIO PARA VOLVER A INTENTARLO',367,10,colors.muted) end
 if toastTime>0 then center(toastMsg,650,10,colors.gold) end
 love.graphics.pop()
end
