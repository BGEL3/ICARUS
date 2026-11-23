# Registro de cambios

## 2026-11-23 — Prototipo inicial de hackathon

- Se creó el juego base en LÖVE 2D, ambientado en una torre inspirada en el mito de Ícaro.
- Se añadieron salas de combate, movimiento en ocho direcciones, enemigos que persiguen y atacan, vida, esquiva y un jefe de prueba cada tres salas.
- Se agregó una vista previa interactiva para navegador, de modo que el combate pueda probarse sin instalar LÖVE.
- Se incorporaron recompensas entre salas con bendiciones seleccionables.
- Se pasó a controles solo de teclado: WASD para movimiento, J/K para acciones y Espacio o Shift para esquivar.
- Se agregaron límites de cámara para jugador y enemigos y la opción de fijar/rotar objetivo con L.
- Se aumentó la vida de enemigos y jefe y se añadieron barras para hacer los combates más legibles.
- Se enfocó la identidad de combate en fuego: plumas ígneas como ataque básico, quemadura al impactar, llamarada en área y auto-incineración que consume vida para duplicar temporalmente el daño de fuego.
- Se ajustó el apuntado: sin objetivo fijado, WASD conserva la dirección del ataque; con objetivo fijado, el ataque se orienta hacia el enemigo marcado.
- Se definieron bendiciones iniciales que mejoran las plumas, la auto-incineración o la recarga de la llamarada.
- Se documentaron controles, bucle actual y próximos jefes placeholder en el README.

## Decisiones de diseño pendientes

- Explorar más adelante una rama de ataque de plumas con comportamientos alternativos.
- Cambiar el jefe placeholder por encuentros propios para Minotauro, Helios o Apolo.
- Revisar la dirección visual cuando el equipo comparta referencias de arte.
