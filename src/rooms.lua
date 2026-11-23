local Rooms={}
Rooms.total=6
Rooms.w,Rooms.h=1080,620
local names={'Atrio de la ceniza','Galeria de los juramentos','Guardian del umbral','Claustro del ocaso','Antesala de la ultima llama','Custodio de la cima'}
function Rooms.describe(n)
 local floor=math.ceil(n/2)
 local boss=n==3 or n==6
 return {
  index=n,floor=floor,boss=boss,name=names[n],
  enemyCount=2+floor,supportCount=boss and floor or 0,
  palette=floor==1 and 'violet' or floor==2 and 'slate' or 'ember'
 }
end
return Rooms
