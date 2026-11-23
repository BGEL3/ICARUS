# ICARUS — La Torre del Ocaso

Prototipo Love2D de acción roguelike con cámara isométrica 2D, combate por salas, reliquias y progresión por una torre. El proyecto conserva su lógica de combate y ahora carga arte pixelado del escenario, Ícaro, enemigos, interfaz, menú y Bodoque.

## Ejecutar

Instala LÖVE 11.x y abre esta carpeta con `love ruta/a/icaro_love2d` o arrástrala al ejecutable de LÖVE. No requiere paquetes Lua externos. Se recomienda una resolución de 1280 × 720; la ventana se puede redimensionar.

## Controles

| Tecla | Acción |
|---|---|
| W A S D | Moverse en los ejes de la cuadrícula isométrica |
| Flechas | Disparar plumas en uno de los cuatro ejes isométricos |
| Shift | Esquivar; consume resistencia, que se recupera con el tiempo |
| Espacio | Pulso solar cuando hay cargas disponibles |
| E | Hablar con Bodoque cerca de él; avanzar al usar la puerta en una sala limpia |
| 1 / 2 / 3 | Elegir una reliquia al terminar una sala |
| I | Abrir el inventario |
| Esc / P | Pausar |
| F11 | Pantalla completa |

La animación tiene su propio reloj a 12 FPS; `love.update` mantiene la frecuencia normal del motor.

## Integración de arte

- La sala principal está en `assets/environments/arena/main_room.png`; contiene el escenario pixel art y la inscripción CODEX tallada en las baldosas.
- `assets/ui/menu/background.png` se usa como fondo limpio del menú; logo, Play y Settings se leen desde sus hojas animadas.
- Ícaro: `assets/characters/player/icarus/run.png` (8 cuadros × 4 direcciones, 320 × 320) e `idle.png` (6 × 4, 320 × 320).
- Ataque de viento: una hoja de 8 cuadros para cada dirección en `assets/characters/player/icarus/wind_attack_*.png` (384 × 384 por cuadro).
- `assets/characters/player/icarus/animations.lua` documenta orden de direcciones, pivotes y tasa de reproducción.
- Retratos de conceptos de criaturas y jefes están en `assets/characters/concepts/`; los iconos individuales de reliquias están en `assets/effects/relics/individual/`.
- Bodoque cuenta con seis poses en `assets/characters/npc/bodoque/poses.png`, seis recortes en `expressions/` y un marco de diálogo propio en `assets/ui/dialogue/bodoque_dialogue_box.png`.
- `assets/environments/tiles/` y `assets/environments/decorations/` incluyen hojas y recortes individuales para ampliar la sala.

## Mapa y colisiones

`assets/maps/arena/map.lua` separa los datos del mapa del PNG: rombo transitable, obstáculos circulares, puerta y posición de Bodoque. `src/collision/arena.lua` resuelve el borde isométrico y empuja al jugador y a los enemigos alrededor de cada obstáculo. `src/isometric.lua` centraliza conversión mundo/pantalla y profundidad; `src/animation.lua` ofrece quads y reproducción independiente a 12 FPS.

El PNG de la sala es una composición de fondo: las entidades se ordenan dinámicamente entre sí, mientras que la arquitectura dibujada dentro de esa imagen no puede ocluirlas por capas todavía. Las colisiones no dependen de los píxeles del fondo.

## Límites de esta iteración

- Las nueve cámaras jugables usan una sala ilustrada principal con cambios de tono por piso; faltan fondos únicos y rutas de colisión para cada cámara.
- Los enemigos usan arte estático de concepto; aún no tienen hojas de animación o ataques animados propios.
- Las cuatro filas direccionales de Ícaro se prepararon con dos vistas base reflejadas; se pueden diferenciar más en una futura pasada de píxel manual.
- Bodoque dispone de seis poses estáticas, no de ciclos completos de caminar, hablar e interactuar.
- El mapa usa un límite romboidal y obstáculos circulares independientes; las paredes, escaleras y decoraciones aún requieren formas ajustadas a cada pieza.
- La prueba de carga y render se realizó en LÖVE 11.5; el balance y la experiencia de una partida completa siguen pendientes.

Consulta [ART_DIRECTION.md](ART_DIRECTION.md), [ASSET_MANIFEST.md](ASSET_MANIFEST.md) y [SUPERVISION.md](SUPERVISION.md) para las decisiones de arte, estructura de assets y estado de comprobación.
