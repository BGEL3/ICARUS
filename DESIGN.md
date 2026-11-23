# Diseño de juego — ICARUS: La Torre de Helios

## Fantasía y promesa

Ícaro asciende por una torre mitológica donde el fuego es a la vez herramienta de combate y riesgo personal. El combate se centra en plumas ígneas a distancia, llamaradas y autoincineración; en diez minutos, el jugador debe aprender a preparar enemigos con quemaduras y detonarlos con K, mientras decide qué reliquias mejoran ese ciclo.

## Pilares

1. **Combate de fuego rápido y legible:** plumas que aplican quemadura, llamarada radial que detona enemigos preparados, y señales visibles para esquivar.
2. **Construcción del intento:** cada reliquia mejora una parte del ciclo de fuego, su alcance, duración, daño, propagación o recarga.
3. **Fuego con costo:** I consume 1 punto de 100 HP para amplificar el daño durante una ventana limitada.
4. **Control de objetivo:** autoenfoque con O, rotación manual con L, marcador puntual y parry con H.
5. **Ascenso corto:** seis cámaras en tres pisos, recompensa por cámara y guardianes en las salas 3 y 6.

## Referencias

- *The Binding of Isaac*: objetos y combinaciones que cambian el kit durante un intento; se prioriza el pool y las sinergias.
- *Hades*: progresión por cámaras, salas de jefe y ritmo de ascenso.
- *Hotline Miami*: impacto, velocidad, legibilidad y control inmediato.
- Mitología griega de Ícaro, Helios, Atenea, Hestia, Deméter y Prometeo.

## Cámara y arte

El ZIP fija una vista isométrica 2:1, salas abiertas y cámara elevada. Conservar `ART_GUIDE.md`, el atlas de baldosas, los sprites y el menú que ya incluye el proyecto. El mundo usa piedra azul/violeta, bronce, luz ámbar y magia verde. Los recursos del ZIP son provisionales y no deben confundirse con arte final.

## Criterios de aceptación

- Arranca como proyecto estándar LÖVE 11.x desde `main.lua`/`conf.lua` y carpetas `src/` y `assets/`.
- Se completa con teclado únicamente.
- J usa el objetivo fijado o automático; sin objetivo usa la última dirección WASD.
- J aplica quemadura y K la detona con daño extra desde el primer combate; Pulso de Hestia amplifica y propaga la detonación.
- O activa/desactiva el autoenfoque; L fija y rota enemigos; el objetivo es visible como un punto.
- H abre una ventana de parry; al impactar un proyectil se daña/quema al emisor y se reduce la recarga de K.
- K y I se benefician de las reliquias y sus cooldowns son visibles.
- Cada recompensa aplica un cambio real a estadísticas o reglas; el pool evita duplicados dentro de la partida.
- Se puede morir, reiniciar y completar las seis cámaras hasta victoria.
- Los ingredientes de hackathon integrados se mantienen explicados en `RETOMAR.md`.
