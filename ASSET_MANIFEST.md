# Catálogo de assets

Todos los PNG se cargan con `love.graphics.newImage`; los sprites se filtran con `nearest`. Las hojas usan cuadros contiguos y configuración Lua cuando corresponde.

| Ruta | Contenido | Formato |
|---|---|---|
| `assets/ui/menu/background.png` | Fondo del menú sin texto | Imagen 1672 × 941 |
| `assets/ui/menu/spritesheet-transparent.png` | Logo ICARÚS en llamas | 3 × 2 cuadros, 512 × 384 |
| `assets/ui/menu/play.png` | Botón de piedra Play | 3 × 2 cuadros, 512 × 384 |
| `assets/ui/menu/settings.png` | Botón de piedra Settings | 3 × 2 cuadros, 512 × 384 |
| `assets/environments/arena/main_room.png` | Sala isométrica principal con CODEX grabado | Imagen 2048 × 1152 |
| `assets/environments/tiles/floor_tiles.png` | Baldosas y piezas del suelo | 4 × 2 cuadros, 384 × 384 |
| `assets/environments/decorations/props.png` | Columnas, brasero, arco, portal y vegetación | 4 × 2 cuadros, 384 × 384 |
| `assets/characters/player/icarus/run.png` | Correr en cuatro direcciones | 8 × 4 cuadros, 320 × 320, 12 FPS |
| `assets/characters/player/icarus/idle.png` | Idle en cuatro direcciones | 6 × 4 cuadros, 320 × 320, 12 FPS |
| `assets/characters/player/icarus/wind_attack_*.png` | Ataque de viento según eje | 8 cuadros, 384 × 384, 12 FPS |
| `assets/characters/concepts/` | Ícaro, dos jefes y tres criaturas | Seis láminas conceptuales recortadas |
| `assets/characters/npc/bodoque/poses.png` | Bodoque en seis poses | 3 × 2 cuadros, 512 × 512 |
| `assets/ui/dialogue/bodoque_dialogue_box.png` | Marco pixelado con retrato y espacio de diálogo | Imagen 1536 × 768 |
| `assets/effects/relics/individual/` | Reliquias y efectos asociados | PNG individuales |
| `assets/ui/hud/ui_kit.png` | Marcos y elementos de interfaz | Hoja 1536 × 1536 |
| `assets/ui/hud/frames/` | Recortes limpios para retrato, barra y panel de piso | PNG transparentes independientes |

Las hojas completas se conservan junto con recortes individuales para facilitar importación, edición y futura ampliación.
