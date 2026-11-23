local Rooms = {}
Rooms.total = 9
Rooms.w, Rooms.h = 1080, 620
function Rooms.describe(index)
  local floor=math.ceil(index/3)
  local boss=index%3==0
  local names={'Atrio de la ceniza','Galeria de las alas','Guardian del umbral',
    'Claustro de la tormenta','Santuario olvidado','Juez de bronce',
    'Trono de las nubes','Camino del ocaso','Centinela solar'}
  return {index=index, floor=floor, boss=boss, name=names[index] or 'Cima de la torre',
    enemyCount=(boss and 1 or (2+floor+((index-1)%3))),
    palette=floor==1 and 'violet' or floor==2 and 'slate' or 'ember'}
end
return Rooms
