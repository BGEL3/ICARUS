# ICARUS — Torre del Sol

Prototipo de hackathon: roguelike de acción cenital en una torre inspirada en el mito de Ícaro. Combate rápido, cámaras de enemigos y bendiciones entre ascensos.

## Jugar la vista previa

Abre `index.html` en un navegador para ver la dirección visual y probar la interacción de bendición.

## Ejecutar el juego LÖVE

Instala [LÖVE 11.x](https://love2d.org/) y, desde este directorio, ejecuta:

```sh
love .
```

## Controles

- WASD: moverse
- J: lanza una pluma ígnea en la dirección WASD o hacia el objetivo fijado
- K: llamarada en área con enfriamiento
- I: incinerarse, pagar 1 vida y duplicar el daño de fuego durante 6 segundos (12 s de enfriamiento)
- Espacio o Shift: esquivar
- L: fijar el enemigo más cercano; vuelve a pulsar para rotar al siguiente. El objetivo queda marcado y la pluma ígnea se dirige hacia él. Sin fijar objetivo, WASD controla la dirección del ataque.
- En la bendición: J/K cambian la elección; L o Espacio confirma
- Escape: volver al título

La demo muestra desde el inicio el ciclo de pluma ígnea, llamarada y auto-incineración; las bendiciones pueden cambiar su daño, duración o recarga.

## Bucle actual

Limpia cada cámara. Las plumas ígneas aplican quemadura. K lanza una llamarada con cooldown; I consume vida para duplicar el daño de fuego durante 6 segundos. Cada tercera cámara aparece un jefe de prueba; al vencerlo, elige una bendición relacionada con plumas, auto-incineración o recarga. La partida termina al perder toda la vida y puedes ascender de nuevo.

Los nombres de Minotauro, Helios y Apolo quedan como próximos jefes con identidad propia; el jefe actual es un guardián placeholder para validar primero sensación, ritmo y legibilidad.
