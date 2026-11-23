local Items={}

-- Cada reliquia cambia una regla del kit base; ninguna habilidad depende de un drop.
Items.catalog={
 {id='feather',name='Plumas de Asclepio',desc='J: +30% daño y +1 s de quemadura.',rarity='común'},
 {id='burn',name='Brasa Persistente',desc='La quemadura dura un 60% más.',rarity='común'},
 {id='flame',name='Anillo Ardiente',desc='K: +35% daño de llamarada.',rarity='común'},
 {id='flare',name='Llamarada Amplia',desc='K: aumenta el radio un 25%.',rarity='raro'},
 {id='cooldown',name='Hoguera Solar',desc='K e I recargan un 20% antes.',rarity='raro'},
 {id='sacrifice',name='Corazón de Brasa',desc='I dura 3 s más; el fuego llega a x2,5.',rarity='raro'},
 {id='health',name='Favor de Deméter',desc='Recupera 20 de vida al recogerlo.',rarity='común'},
 {id='dash',name='Sandalias del Viento',desc='Esquiva: enfriamiento de 0,85 s.',rarity='común'},
 {id='speed',name='Alas Ligeras',desc='Movimiento +15%.',rarity='común'},
 {id='pierce',name='Aguja Solar',desc='J atraviesa a un enemigo.',rarity='raro'},
 {id='twin',name='Pluma Gemela',desc='J lanza dos plumas en abanico.',rarity='raro'},
 {id='embers',name='Chispas del Destino',desc='Todo el daño de fuego +25%.',rarity='raro'},
 {id='ash',name='Ceniza Hambrienta',desc='Matar a un enemigo quemado recarga 1 s de K.',rarity='raro'},
 {id='pulse',name='Pulso de Hestia',desc='K detona con más fuerza y propaga el fuego.',rarity='raro'},
 {id='mirror',name='Espejo de Atenea',desc='H: ventana mayor y contraataque ígneo.',rarity='raro'}
}

function Items.has(player,id)
 return (player.items[id] or 0)>0
end

function Items.apply(player,item)
 player.items[item.id]=(player.items[item.id] or 0)+1
 if item.id=='health' then player.hp=math.min(player.maxHp,player.hp+20) end
end

function Items.choose(pool,owned,count)
 local available={}
 for _,item in ipairs(pool) do
  if not owned[item.id] then available[#available+1]=item end
 end
 for i=#available,2,-1 do
  local j=love.math.random(i)
  available[i],available[j]=available[j],available[i]
 end
 local choices={}
 for i=1,math.min(count,#available) do choices[#choices+1]=available[i] end
 return choices
end

return Items
