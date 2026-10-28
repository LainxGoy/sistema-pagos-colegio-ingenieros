# Prototipo web de control de cuotas

Demostración acotada para el Test Plan SQA del sistema de pagos del Colegio de Ingenieros. Permite consultar cuotas de una afiliada ficticia, asignar nuevas cuotas, crear solicitudes de revisión y aprobarlas o rechazarlas. Calcula la habilitación según las cuotas vencidas. Los datos se guardan solo en `localStorage` del navegador. No hay autenticación, carga de archivos, API ni pagos reales.

## Ejecutar

Desde esta carpeta, iniciar un servidor HTTP estático (`python -m http.server 8000`) y abrir `http://localhost:8000`. Si el puerto está ocupado, se puede elegir otro, por ejemplo `python -m http.server 8765` y `http://localhost:8765`. Reiniciar ejemplo devuelve los datos iniciales.

## Pruebas

`node --test tests/*.test.mjs` ejecuta 17 pruebas unitarias sin dependencias.

La carpeta `cypress/` contiene tres escenarios de navegador. Para ejecutarlos: iniciar el servidor en el puerto 8000, instalar Cypress en un entorno de Node y correr `npx cypress run` desde esta carpeta.

La carpeta `selenium/` contiene tres escenarios equivalentes. Para ejecutarlos: iniciar el servidor en el puerto 8000, instalar `selenium` para Python y correr `python selenium/test_cuotas.py` con Chrome disponible.

Los escenarios de aceptación comprueban: aprobar una solicitud y habilitar a la afiliada; rechazarla y conservar la deuda; agregar una cuota y crear su solicitud. La ejecución automatizada se publica en GitHub Actions al actualizar el PR.

