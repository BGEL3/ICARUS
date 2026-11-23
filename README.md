# ICARUS — Torre del Sol

Prototipo roguelike de acción para LÖVE 11.x. Ícaro asciende por cámaras de una torre griega mientras combina plumas ígneas, hechizos y objetos pasivos.

## Ejecutar

Instala [LÖVE 11.x](https://love2d.org/) y ejecuta desde esta carpeta:

```sh
love .
```

`index.html` es la demo de navegador para revisar el bucle sin instalar LÖVE.

## Controles

- **WASD:** moverse y orientar las plumas si no hay un objetivo fijado.
- **J:** lanzar plumas ígneas; aplican quemadura.
- **K:** llamarada de área; consume enfriamiento y puede detonar quemaduras con el objeto Pulso de Hestia.
- **I:** pagar 1 vida para duplicar el daño de fuego por 6 segundos; vuelve a estar disponible tras 12 segundos.
- **H:** parry breve. Si desvía un proyectil, daña y quema a quien lo lanzó y reduce la carga de K.
- **O:** activar/desactivar autoenfoque; apunta al enemigo más cercano si está activo.
- **L:** fijar al siguiente enemigo por cercanía. El objetivo se señala con un punto; L vuelve a rotar.
- **Espacio o Shift:** esquivar.
- **En recompensa:** J/K cambian el objeto ofrecido; L o Espacio lo elige.
- **Escape:** volver al título.

## Bucle de la demo (10–12 minutos)

Todas las mecánicas base están disponibles al comenzar: plumas, llamarada, auto-incineración, esquiva, autoenfoque y parry. Cada cámara limpia ofrece tres objetos pasivos de un pool de seis. Los objetos modifican las habilidades y algunas parejas activan sinergias explícitas. Cada tercer ascenso aparece el jefe de prueba.

Objetos actuales: Plumas de Asclepio, Corazón de Brasa, Hoguera Solar, Ceniza Hambrienta, Pulso de Hestia y Espejo de Atenea.

## Dirección visual de referencia

Las referencias compartidas apuntan a ruinas griegas en perspectiva isométrica, piedra oscura azul-violeta, iluminación cálida naranja de antorchas y un portal verde como punto de contraste. Mantener siluetas de personajes y enemigos legibles sobre un suelo con mosaicos. El arte pixelado final se integrará cuando lleguen los sprites de referencia del equipo.

## Pendiente

- Sustituir el guardián placeholder por Minotauro, Helios o Apolo.
- Integrar el pixel art definitivo y adaptar la cámara/escenario a esos sprites.
- Ampliar los pools de objetos, salas y sinergias después de validar la demo corta.
