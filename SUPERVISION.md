# Informe Supervisor — v0.2

## Verificado por revisión estática y pruebas automatizadas
- Motor de destino LÖVE2D 11.x, fuente Lua.
- Entrada por teclado; las acciones de ratón no se usan.
- `Rooms.total=6`, pisos calculados cada 2 salas.
- Vida inicial 100 y recuperación de completo +5.
- J pluma, K llamarada, I autoincineración, L lock-on y ESPACIO/SHIFT dash.
- Selección de bendición mediante J/K + L/Espacio.
- Referencias gráficas almacenadas; atlas y sprites provisionales PNG reales integrados en renderizado.
- Tutorial inicial con duración 5 s y retrato; frase «QUEDA UNA PURA SALA», grabado CODEX y número 23.

## Pendiente de aprobación
- No se ha ejecutado una sesión visual real del juego en la aplicación LÖVE2D en esta revisión.
- El render puede necesitar ajustes de tamaño, legibilidad y orden de capas.
- No se considera entregado arte profesional de ocho direcciones y múltiples estados: son placeholders.
- Colisiones de columnas, muros, portales y arquitectura isométrica detallada no están implementadas (únicamente límites del área).
- UI de stamina e inventario rápido no implementada: su existencia fue propuesta en el documento pero no confirmada como mecánica.
- Requiere pruebas reales de rendimiento, balance y bugs por el propietario.

## Pruebas ejecutadas
- Compilación de los siete archivos Lua con `loadfile()` mediante `texlua`: OK.
- Simulación de estados de combate: pluma, llamarada, autoincineración, fijación y esquiva: OK.
- Recorrido de seis cámaras con elección de bendiciones y pantalla de victoria: OK.
- Archivo ZIP: comprobación de integridad: OK.

**Resultado:** integración aprobada a nivel sintáctico y de lógica automatizada. Aprobación visual y de experiencia condicionada a prueba real en LÖVE2D y sustitución del arte provisional.

## Estado de la rama tras integrar el ZIP

El bloque anterior describe la revisión que acompañaba al ZIP v0.2. La rama actual añadió autofoco, rotación/fijación de objetivo, parry, una esquiva direccional sin mantener movimiento, y sinergias de reliquias. Estos cambios todavía requieren una ejecución real en LÖVE para validación visual y de combate. En el entorno actual no se encuentran los ejecutables `love`, `lua` ni `texlua` en PATH.
