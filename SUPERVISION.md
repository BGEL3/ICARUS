# Revisión técnica v0.2

## Integrado

- Imagen de sala pixel art conectada al render de juego; fondo de menú limpio con logo y botones de piedra en hojas separadas.
- Hojas de correr e idle de Ícaro con cuatro filas isométricas; ataque de viento con una hoja por cada eje.
- Reproducción con quads a 12 FPS, independiente del tiempo de actualización del motor.
- Render ordenado por profundidad de Ícaro, enemigos y Bodoque.
- Límite transitable romboidal, obstáculos, puerta y NPC definidos en `assets/maps/arena/map.lua` y resueltos desde `src/collision/arena.lua`.
- Barra de vida, resistencia, monedas, ranuras de reliquias, carga solar, inventario dinámico y diálogo progresivo.

## Comprobaciones realizadas

- Se revisaron visualmente las hojas y recortes suministrados, la sala principal, el fondo del menú y el marco de diálogo.
- Los PNG del jugador están organizados por cuadros de tamaño fijo; los cuatro ataques tienen imagen propia por dirección.
- El mapa de colisiones está separado de la imagen decorativa.
- LÖVE 11.5 cargó el proyecto, las imágenes y los módulos; se renderizaron y revisaron capturas del menú, la sala y el diálogo.
- Smoke check lógico: animaciones a 12 FPS, empuje contra obstáculos, disparo/ataque y aparición progresiva del diálogo.

## Límites pendientes

- No se hizo una partida manual completa para balancear combate, cámara y recompensa.
- Las criaturas/jefes son conceptos estáticos. No se ha aprobado su lectura a escala de combate.
- El fondo de la sala está compuesto en una única imagen; los sprites no se pueden ocluir con columnas individuales todavía.
- La colisión actual usa un rombo y círculos de obstáculos, no polígonos específicos de cada muro o desnivel.
- Las cuatro filas de Ícaro se construyeron con dos vistas base y filas reflejadas; una pasada de pixel art manual puede dar a las cuatro orientaciones siluetas más distintas.

## Veredicto

**Prototipo integrado y renderizado en LÖVE 11.5.** Se recomienda una sesión de juego manual para ajustar el balance y expandir la oclusión y las animaciones.
