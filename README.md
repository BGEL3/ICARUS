# ICARUS — La Torre de Helios

Prototipo roguelike de acción para **LÖVE 2D 11.x**, creado en Lua para PC y jugable solo con teclado. Ícaro asciende por seis cámaras de una torre griega, combina fuego con reliquias y enfrenta guardianes en las salas 3 y 6.

## Ejecutar

1. Instala LÖVE 11.x desde [love2d.org](https://love2d.org/).
2. Extrae el repositorio y abre una terminal dentro de esta carpeta, junto a `main.lua` y `conf.lua`.
3. Ejecuta `love .`.

También puedes arrastrar la carpeta del proyecto sobre la aplicación LÖVE. Para empaquetarlo como `.love`, comprime el contenido de esta carpeta —incluidos `main.lua`, `conf.lua`, `src/` y `assets/`— y cambia la extensión del ZIP a `.love`.

Este repositorio usa la distribución modular del proyecto LÖVE. `index.html` no es el juego y no forma parte de la ejecución.

## Controles

- **WASD:** moverse; la última dirección orienta las plumas cuando no hay objetivo.
- **J:** lanzar una pluma ígnea. Con autoenfoque activo apunta al enemigo vivo más cercano; una fijación manual tiene prioridad. Cada impacto aplica quemadura.
- **K:** llamarada radial. Enfriamiento base de 6 s. Desde el inicio, inflige daño extra a enemigos que ya estén ardiendo y consume su quemadura; conviene preparar con J y rematar con K.
- **I:** consumir 1 punto de los 100 HP para multiplicar el daño de fuego por 2 durante 6 s; enfriamiento de 12 s.
- **O:** activar o desactivar autoenfoque. Está activo al comenzar.
- **L:** fijar el enemigo más cercano y seguir rotando por cercanía; el objetivo se marca con un punto.
- **H:** iniciar parry. La ventana base dura 0,20 s y tiene 1,35 s de enfriamiento.
- **Espacio o Shift:** esquivar en la última dirección; el movimiento se ejecuta incluso si no mantienes WASD.
- **E:** entrar a la siguiente cámara cuando la actual esté despejada.
- **En bendiciones:** J/K cambian la selección; L o Espacio confirma.
- **Menú:** W/S navega; Enter/Espacio confirma; G abre la galería; Esc vuelve; F11 alterna pantalla completa.

## Mecánicas y recorrido

- Todas las habilidades están disponibles desde el comienzo. Las reliquias modifican sus reglas y no son desbloqueos necesarios para usar el kit base.
- La partida dura seis cámaras, organizadas en tres pisos. Los encuentros de jefe provisionales ocurren en las salas 3 y 6.
- Al limpiar una cámara aparece una selección de tres reliquias de un pool de quince, sin repetir una reliquia ya recogida durante la partida. Una elección permite entrar a la siguiente sala.
- Los hoplitas y brutos presionan de cerca; las arpías y guardianes telegrafían sus ataques a distancia. Los guardianes alternan abanicos de cinco y siete proyectiles con un anillo de ocho, y llevan enemigos de apoyo.
- La dificultad sube por piso: más vida y velocidad para los enemigos y proyectiles más dañinos. El kit de fuego y las reliquias están disponibles desde el primer combate para una demo corta.
- Cada cámara contiene un completo italiano que cura 5 HP al acercarse. La quinta sala muestra «QUEDA UNA PURA SALA». La arena incluye el detalle 23 y la inscripción CODEX; el tutorial usa el retrato de Bodoque incluido en el ZIP.
- No hay metaprogresión entre partidas: al morir, Enter inicia un intento nuevo.

## Reliquias

| Reliquia | Efecto |
|---|---|
| Plumas de Asclepio | J hace 30% más daño y quema durante 1 s adicional. |
| Brasa Persistente | La duración de la quemadura aumenta 60%. |
| Anillo Ardiente | K hace 35% más daño. |
| Llamarada Amplia | K aumenta su radio 25%. |
| Hoguera Solar | K e I recuperan su carga 20% antes. |
| Corazón de Brasa | I dura 3 s más y aumenta el multiplicador de fuego de x2 a x2,5. |
| Favor de Deméter | Cura 20 HP al recogerlo, hasta el máximo de 100. |
| Sandalias del Viento | El enfriamiento de esquiva baja a 0,85 s. |
| Alas Ligeras | Movimiento 15% más rápido. |
| Aguja Solar | La pluma atraviesa un enemigo adicional. |
| Pluma Gemela | J lanza dos plumas en abanico. |
| Chispas del Destino | Todo daño de fuego aumenta 25%. |
| Ceniza Hambrienta | Matar a un enemigo quemado reduce 1 s del enfriamiento de K. |
| Pulso de Hestia | K aumenta el daño de las detonaciones y propaga la ignición a los enemigos cercanos. |
| Espejo de Atenea | Parry dura 0,30 s, recarga en 0,95 s y contraataca con 50% más daño. |

### Sinergias implementadas

- **Ceniza Hambrienta + Plumas de Asclepio:** una baja por quemadura genera una pequeña explosión que daña y quema a enemigos cercanos; también devuelve 1 s de K.
- **Pulso de Hestia + Plumas de Asclepio:** las detonaciones de K se propagan más lejos, hacen más daño y dejan una quemadura más larga.
- **Espejo de Atenea + Corazón de Brasa:** durante la autoincineración, el parry añade daño al contraataque.

## Estructura del proyecto

- `main.lua`: menú, navegación, modos y entrada de teclado.
- `conf.lua`: configuración de ventana e identidad de guardado de LÖVE.
- `src/game.lua`: estado de partida, movimiento, enemigos, habilidades, daño, fijación, recompensas y sinergias.
- `src/items.lua`: pool de reliquias, efectos de recogida y selección sin duplicados.
- `src/rooms.lua`: seis cámaras, pisos y encuentros de jefe.
- `src/render.lua`: escena isométrica, atlas de suelo, sprites, objetivo, quemaduras y efectos.
- `src/ui.lua`: HUD, tutorial, recompensas y estados de victoria/muerte.
- `assets/sprites/`: sprites provisionales y atlas de suelo.
- `assets/concept/`: referencias de menú, personajes, juego, reliquias y diálogo.
- `RETOMAR.md`: contexto detallado y decisiones para retomar el trabajo.

## Arte y créditos

Se conservaron los recursos incluidos en `ICARUS_LOVE2D_v0_2 (1).zip`, entregado por el equipo, y la dirección de pixel art isométrico que documenta `ART_GUIDE.md`. Los sprites actuales son provisionales; las ilustraciones conceptuales no reemplazan sprites de producción. El ZIP no incluye una lista completa de autoría ni licencias de cada recurso. Antes de una entrega pública, confirmar esos créditos y añadir la licencia del código compatible con los recursos.

## Procedencia de esta versión

La estructura LÖVE, el menú, el mundo isométrico, las seis cámaras, el pool base de objetos y los assets ya existían en el ZIP v0.2. En esta rama se incorporan autoenfoque y fijación con marcador puntual, parry con contraataque, esquiva direccional, progresión de dificultad, reliquias/sinergias adicionales y una interacción base de combate: K detona desde el primer minuto a enemigos preparados con la quemadura de J.

## Estado

El ZIP v0.2 es la base del proyecto. Esta rama agrega autofoco con O, punto de objetivo y fijación con L, parry con H, habilidades/objetos de fuego integrados y sinergias. La auditoría visual final debe hacerse ejecutando el juego en LÖVE 11.x; este entorno de trabajo no trae el ejecutable `love` instalado.
