# ICARUS — guía de arte v0.2

## Cámara y proyección

- Juego 2D con cámara elevada isométrica; proyección de suelo 2:1.
- Coordenadas de mundo separadas de pantalla y cámara.
- Los cuatro ejes de movimiento cruzan el rombo del suelo: norte se proyecta arriba-derecha, este abajo-derecha, sur abajo-izquierda y oeste arriba-izquierda.
- Las hojas del jugador usan esas cuatro direcciones. No incluyen orientaciones intercardinales.

## Pixel art y escala

- Canvas de referencia: 1280 × 720; assets de escena 2048 × 1152.
- Frames de Ícaro: 320 × 320 px; sprites de ataque: 384 × 384 px.
- Filtro de Love2D: `nearest` para minificación y magnificación.
- Pivote de personajes: centro de los pies, constante entre frames.
- Reproducción de animación: 12 FPS, independiente de `love.update`.

## Paleta y luz

- Basalto y muros: carbón, violeta apagado y azul pizarra.
- Luz principal: ámbar, brasa y oro envejecido.
- Magia: turquesa y verde portal, usados como acento.
- Ícaro: marfil, rojo oscuro, bronce y puntas de ala encendidas.
- Sombreado por grupos de píxeles definidos, contornos nítidos y sin suavizado.

## Reglas de composición

- Mantener los personajes en perspectiva isométrica 3/4; no mezclar vista lateral, cenital ni frontal plana.
- Efectos de ataque avanzan por un eje de la cuadrícula isométrica.
- La sala de juego se usa como fondo; colisiones, personajes y HUD se renderizan por separado.
- La interfaz se dibuja en espacio de pantalla para que barras, cantidades, inventario y diálogo puedan cambiar en tiempo real.

## Referencias usadas

- Sala pixel art entregada por el usuario: lenguaje de baldosas, perspectiva, arquitectura y luz cálida.
- Arena de ICARUS entregada por el usuario: enemigos, siluetas y color mágico.
- Foto de Juan Carlos Bodoque entregada por el usuario: rasgos del títere reinterpretados en pixel art.
