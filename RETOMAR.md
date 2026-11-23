# ICARUS — contexto para retomar

Este documento reúne el contexto de diseño y el estado técnico para continuar la conversación sin volver a reconstruir decisiones previas. Leerlo junto con `README.md` antes de proponer cambios.

## Fuente de verdad

- **Motor y lenguaje:** LÖVE 2D 11.x y Lua.
- **Base elegida:** el proyecto `ICARUS_LOVE2D_v0_2 (1).zip` que compartió Lucas. Conservar su estructura modular y sus assets.
- **Proyecto ejecutable:** esta carpeta, donde están `main.lua`, `conf.lua`, `src/` y `assets/`. Iniciar con `love .` desde aquí.
- El prototipo HTML previo no es el juego ni debe reemplazar el proyecto LÖVE. El archivo HTML anterior se quitó de la rama del repositorio para evitar confundirlo con el juego ejecutable.
- Rama de trabajo acordada: `prototipo-inicial`. `main` no se integra hasta que el usuario lo revise.

## Concepto

Un roguelike de acción de 10–12 minutos inspirado en Ícaro ascendiendo una torre hacia Helios. Combina combates rápidos, salas isométricas y jefes con un kit de fuego y reliquias que cambian las reglas del combate.

Referencias de diseño conversadas: variedad de builds y combinaciones de objetos al estilo *The Binding of Isaac*; ritmo de salas y jefes de *Hades*; contundencia y velocidad de *Hotline Miami*. Son referencias de intención, no permiso para copiar arte o contenido.

La dirección artística está descrita en `ART_GUIDE.md`: pixel art isométrico 2:1, piedra azul/violeta, bronce envejecido, iluminación ámbar y magia verde. El ZIP ya incluye menú, spritesheets provisionales, atlas de suelo, retrato de Bodoque y material conceptual. No reemplazar esos recursos por geometría o un HTML inventado sin pedirlo. Los pixel art finales se integrarán cuando el usuario los entregue.

## Bucle de la partida

1. Menú de teclado; la galería de arte abre con G.
2. Se recorren seis cámaras en tres pisos; los jefes provisionales aparecen en las salas 3 y 6.
3. Se combate, recoge automáticamente el completo italiano (+5 HP) y se eliminan las amenazas.
4. Al limpiar una sala se elige una de tres reliquias sin duplicar objetos ya adquiridos en el intento.
5. E confirma la entrada a la sala siguiente. Tras la sexta, victoria; al morir, Enter reinicia.

No existe metaprogresión. Las habilidades están disponibles desde el inicio para que el jurado vea el núcleo en una demo corta.

## Kit y controles implementados

| Entrada | Acción y regla |
|---|---|
| WASD | Movimiento en ocho direcciones. Guarda la última dirección para disparar si no hay objetivo. |
| J | Pluma ígnea de un disparo por pulsación; enfriamiento corto de 0,27 s, daño base 12 y quemadura base de 2,5 s. El autoenfoque orienta el disparo, y la quemadura prepara al enemigo para K. |
| O | Alterna autoenfoque, activo por defecto. Elige al enemigo vivo más cercano. |
| L | Fija el objetivo más cercano y rota por cercanía en pulsaciones sucesivas. La fijación manual prevalece sobre el autoenfoque. |
| K | Llamarada radial: daño base 25, radio 175 y recarga de 6 s. Desde el primer combate, detona enemigos quemados y añade daño según el tiempo de quemadura restante; Pulso de Hestia aumenta el daño y propaga la detonación. |
| I | Consume 1 punto de 100 HP; multiplica daño de fuego por 2 durante 6 s; recarga 12 s. Con Corazón de Brasa, x2,5 durante 9 s. No se puede usar si queda 1 HP. |
| H | Inicia parry; ventana base 0,20 s, recarga 1,35 s. Al contactar un proyectil lo elimina, contraataca a su fuente, aplica quemadura y reduce K en 1 s. |
| Espacio / Shift | Esquiva en la última dirección; 0,17 s de impulso, 0,26 s de invulnerabilidad, recarga 1,45 s. También avanza sin WASD. |
| E | Avanza después de despejar la cámara y escoger la recompensa. |
| J/K y L/Espacio en recompensa | Mover selección y confirmar reliquia. |

El marcador de objetivo es un punto en el enemigo. No volver al cuadro o retícula recargada que se usaba en una versión anterior.

## Reliquias y efectos

Hay quince reliquias únicas. El pool conserva los objetos del ZIP y añade los seis conceptos discutidos previamente, combinándolos cuando cumplen una función equivalente.

1. **Plumas de Asclepio:** J +30% de daño y +1 s de quemadura.
2. **Brasa Persistente:** duración de quemadura +60%.
3. **Anillo Ardiente:** K +35% daño.
4. **Llamarada Amplia:** K +25% de radio.
5. **Hoguera Solar:** enfriamientos de K e I −20%.
6. **Corazón de Brasa:** I +3 s y multiplicador de fuego x2,5.
7. **Favor de Deméter:** cura 20 HP al elegirlo, sin superar 100.
8. **Sandalias del Viento:** recarga de esquiva 0,85 s.
9. **Alas Ligeras:** velocidad de movimiento +15%.
10. **Aguja Solar:** J atraviesa un enemigo adicional.
11. **Pluma Gemela:** J lanza dos plumas en abanico.
12. **Chispas del Destino:** daño de fuego +25%.
13. **Ceniza Hambrienta:** baja por quemadura devuelve 1 s a K.
14. **Pulso de Hestia:** mejora la detonación base de K y propaga la ignición a enemigos cercanos.
15. **Espejo de Atenea:** parry 0,30 s, recarga 0,95 s y contraataque +50%.

### Sinergias de reliquias

- **Ceniza Hambrienta + Plumas de Asclepio — Ceniza en cadena:** una baja quemada devuelve 1 s a K y salpica daño/quemadura a enemigos próximos.
- **Pulso de Hestia + Plumas de Asclepio — Llamarada de plumas:** las detonaciones de K se propagan más lejos, hacen más daño y dejan una quemadura más larga.
- **Espejo de Atenea + Corazón de Brasa — Contraataque incandescente:** parry durante I añade daño al contraataque.

El objetivo es que una reliquia altere una decisión de combate o una habilidad de forma visible. Evitar reliquias que solo sean texto o aumentos de estadística sin impacto legible.

## Enemigos y cámaras

- **Hoplita:** perseguidor de presión, 26 HP.
- **Bruto:** lento y resistente, 38 HP.
- **Arpía:** hostiga a distancia, 20 HP.
- **Guardián provisional:** jefe de cámaras 3 y 6; vida escala con el piso, alterna abanicos de 5/7 proyectiles y un anillo de 8 con anticipación visual, y lleva enemigos de apoyo. Reemplazar más adelante por encuentros propios (Minotauro, Helios o Apolo) tras acordar alcance.
- Hay 3, 4 o 5 enemigos en salas normales según el piso. Aumentan vida y velocidad por piso; los proyectiles suben 20% el daño por piso. Las cámaras se describen en `src/rooms.lua`.

## Ingredientes de la hackathon: estado a recordar

La página entregada por el usuario indica cinco ingredientes sorpresa y exige que al menos uno cambie cómo se juega. El ZIP ya implementa:

- Completo italiano: cura 5 HP al acercarse; efecto jugable.
- Guiño a 31 Minutos: retrato/tutorial de Bodoque tomado de la referencia. Falta sprite autónomo, así que se usa como retrato temporal.
- Frase «QUEDA UNA PURA»: aparece en la sala 5.
- Número 23: calavera/detalle en el pedestal de la arena.
- Codex: el ZIP tiene la palabra grabada en el suelo; verificar después si la organización exige el logo oficial y no basta el nombre.

Otras condiciones de entrega de esa página: repositorio público, licencia open source, pasos de ejecución, créditos/licencias de recursos y una línea en README separando lo previo de lo hecho durante la jornada. No declarar licencias de assets que el ZIP no documenta. El desarrollo cierra a las 16:00 Santiago según la página compartida; no modificar el proyecto una vez comience la evaluación.

## Reglas para continuar el trabajo

- Modificar primero la estructura del ZIP y los módulos Lua. No convertir la fuente principal en HTML.
- Mantener controles solo con teclado; no introducir mouse para jugar.
- Documentar mecánicas nuevas en `README.md`, `RETOMAR.md` y `CHANGELOG.md`.
- Mantener el balance visible: HP de Ícaro es una reserva de 100 puntos; I cuesta 1 HP, no una vida completa.
- No prometer que el juego fue probado visualmente si LÖVE no se ejecutó. En esta sesión `love`, `lua` y `texlua` no están disponibles en PATH.
- Antes de sustituir sprites, conservar el filtrado `nearest`, tamaños/frames que asume `src/render.lua` y el punto de anclaje descrito en `ART_GUIDE.md`.

## Próximas tareas sugeridas

1. Validar sintaxis y recorrido de salas en LÖVE 11.x instalado.
2. Ajustar autoenfoque, parry y economía de cooldowns con pruebas reales.
3. Confirmar con el equipo la interpretación de «pagar 1 vida» y la dirección del ataque básico si cambia la decisión de usar plumas a distancia.
4. Confirmar crédito/licencia de cada asset y elegir la licencia del código antes de una entrega pública.
5. Cambiar el texto CODEX por el logo oficial únicamente cuando el recurso correcto esté disponible.

## Historial reciente del flujo de trabajo

- El ZIP v0.2 se entregó como proyecto LÖVE real con arte y código modular.
- Una vista HTML previa anterior causó confusión y no era la distribución correcta. Se retiró `index.html` de la rama del juego; continuar desde esta carpeta LÖVE.
- La meta inmediata del usuario es probar y evaluar mecánicas dentro de LÖVE, conservar lo que ya aporta el pool de objetos y registrar decisiones para retomar sin perder contexto.
