# Guía artística — ICARUS v0.2

- Referencias: `assets/concept/` con cuatro imágenes de la conversación. No extraer automáticamente sprites finales de escenas compuestas.
- Proyección de mundo: `screenX=(worldX-worldY)*0.72`, `screenY=(worldX+worldY)*0.40`, ratio aproximado 2:1.
- Estética objetivo: pixel art auténtico, sin antialiasing ni gradientes suaves; piedra azul/púrpura, bronce envejecido, luz ámbar, magia verde.
- Texturas actuales: atlas de suelo de 4 variaciones, celdas 64×32 PNG; NPCs 48×56, 8 columnas (direcciones), 4 filas (frames temporales). Animación 12 FPS.
- Dirección de luz dominante: noroeste; sombras discretas.
- Punto de anclaje: pies del personaje, entorno a (24,51) en el frame 48×56.
- Capas objetivo: cielo/vacío → baldosas → inscripción CODEX → props bajos → personajes/obstáculos ordenados → VFX → UI.
- La ilustración de Bodoque se usa exclusivamente como retrato de referencia para el tutorial. Falta el spritesheet con las animaciones solicitadas en el documento del usuario.
- Calidad: no confundir los cinco sprites provisionales con recursos finales profesionales.
