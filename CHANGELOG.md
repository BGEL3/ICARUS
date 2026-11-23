# Registro de cambios

## Proyecto base importado

- Se eligió `ICARUS_LOVE2D_v0_2 (1).zip` como nueva base de trabajo.
- Se conservaron su distribución LÖVE 2D/Lua, módulos `src/`, configuración `conf.lua`, sprites, atlas de baldosas y referencias.
- Se retiró del repositorio `index.html`, una vista HTML antigua que no representaba la ejecución real en LÖVE.

## Mecánicas añadidas sobre v0.2

- Autofoco con O, activado por defecto. L fija y rota por cercanía; el autoenfoque respeta la fijación. Un punto sobre el enemigo muestra el objetivo.
- Parry H con ventana de 0,20 s y recarga de 1,35 s. Un impacto bloqueado contraataca, aplica quemadura y reduce 1 s del cooldown de K.
- Espejo de Atenea extiende el parry a 0,30 s, baja su recarga a 0,95 s y aumenta el contraataque.
- La esquiva ahora avanza usando la última dirección aunque no se mantenga WASD.
- Se añadieron efectos concretos y descripciones coherentes para el pool de reliquias, con quince elecciones únicas posibles por intento.
- Se implementaron tres sinergias: Ceniza en cadena, Llamarada de plumas y Contraataque incandescente.
- La dificultad escala en los tres pisos: enemigos con más vida/velocidad, proyectiles más dañinos y guardianes con ataques anticipados de varios patrones y escolta.
- K ahora detona desde el inicio a los enemigos previamente quemados por J, con daño extra según la quemadura restante. Pulso de Hestia refuerza esa interacción y, junto a Plumas de Asclepio, propaga el fuego.
- Se ampliaron tutorial, HUD y controles para mostrar autofoco, parry y cooldowns.
- Se reescribieron README, DESIGN y `RETOMAR.md` con controles, reglas, objetos, estructura y requisitos pendientes.

## Pendiente de validación

- Este entorno no tiene `love`, `lua` ni `texlua` disponibles, así que falta abrir el proyecto con LÖVE 11.x y probar el recorrido real.
- Revisar que las animaciones, el marcador de objetivo, la ventana de parry y las sinergias se lean bien en pantalla.
- Confirmar los créditos y licencias de los recursos incluidos en el ZIP.
