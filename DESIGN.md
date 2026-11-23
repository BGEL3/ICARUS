# Dirección del prototipo ICARUS

## Decisiones confirmadas

- Ícaro asciende una torre de fantasía oscura en salas de combate.
- El juego se renderiza en 2D con suelo isométrico y profundidad por coordenadas del mundo.
- Los sprites jugables usan la cruz isométrica de cuatro orientaciones: norte-arriba/derecha, este-abajo/derecha, sur-abajo/izquierda, oeste-arriba/izquierda.
- El arte mantiene agrupaciones de píxeles, piedra carbón-violeta, brasa naranja, oro envejecido y magia turquesa.
- LÖVE2D es el motor objetivo; teclado y ratón no son necesarios para jugar.
- El retrato de Juan Carlos Bodoque se basa en la foto aportada y usa los rasgos rojos, orejas largas, nariz naranja, boca amarilla y polera rayada.

## Prototipo de juego

- Nueve salas en tres pisos, con recompensas de reliquias y tres encuentros de jefe.
- WASD mueve; las flechas disparan por los cuatro ejes; Shift esquiva; Espacio usa el pulso solar.
- El mapa define un rombo transitable, obstáculos, puerta y NPC fuera del arte rasterizado.
- Un único fondo de sala está integrado por ahora; los tonos cambian según el piso.

## Alcance visual de la entrega

Ícaro tiene ciclos de correr e idle para cuatro direcciones y ataques de viento separados por cada eje, configurados a 12 FPS. Bodoque dispone de un tablero de seis poses y diálogo con texto progresivo. Los conceptos de enemigos son diseños estáticos de referencia. Escenarios por piso, animaciones completas de enemigos y Bodoque, efectos de sonido y una capa de oclusión para arquitectura aún requieren producción.

## Proyección

`src/isometric.lua` usa `screenX = (worldX - worldY) × 0.72` y `screenY = (worldX + worldY) × 0.40`. El orden de dibujo de jugadores, enemigos y Bodoque compara `worldX + worldY`. La sala es un PNG compuesto, por lo que las entidades no se pueden insertar detrás de sus columnas incrustadas hasta separar esa arquitectura en capas.
