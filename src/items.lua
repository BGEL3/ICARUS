local Items = {}
Items.catalog = {
  {id='twin', name='Plumas gemelas', desc='Disparas dos plumas en abanico.', rarity='comun'},
  {id='ember', name='Brasa de Prometeo', desc='Tus impactos queman al enemigo.', rarity='comun'},
  {id='pierce', name='Aguja de Atenea', desc='Las plumas atraviesan un enemigo.', rarity='raro'},
  {id='haste', name='Sandalias de Hermes', desc='+22% velocidad de movimiento.', rarity='comun'},
  {id='damage', name='Ira de Ares', desc='+30% dano de ataque.', rarity='comun'},
  {id='rate', name='Pulso de Apolo', desc='+25% cadencia de disparo.', rarity='comun'},
  {id='vitality', name='Favor de Hera', desc='+2 vida maxima y recuperas 2.', rarity='raro'},
  {id='frost', name='Viento del Egeo', desc='Los impactos ralentizan enemigos.', rarity='raro'},
  {id='echo', name='Eco de Dedalo', desc='Probabilidad de otra pluma en el disparo.', rarity='raro'},
  {id='dash', name='Alas reforzadas', desc='Menor enfriamiento de esquiva.', rarity='comun'},
  {id='solar', name='Corona solar', desc='La habilidad activa inflige mas dano.', rarity='raro'},
  {id='blood', name='Pacto de ceniza', desc='+50% dano, -1 vida maxima.', rarity='maldito'},
}
local function has(player,id) return (player.items[id] or 0)>0 end
Items.has=has
function Items.apply(player,item)
  local id = item.id
  player.items[id]=(player.items[id] or 0)+1
  if id=='vitality' then player.maxHp=player.maxHp+2; player.hp=math.min(player.maxHp,player.hp+2) end
  if id=='blood' then player.maxHp=math.max(2,player.maxHp-1); player.hp=math.min(player.hp,player.maxHp) end
end
function Items.choose(pool,owned,count)
  local options, candidates = {}, {}
  for _,item in ipairs(pool) do if not owned[item.id] then candidates[#candidates+1]=item end end
  for i=#candidates,2,-1 do local j=love.math.random(i); candidates[i],candidates[j]=candidates[j],candidates[i] end
  for i=1,math.min(count,#candidates) do options[#options+1]=candidates[i] end
  return options
end
return Items
