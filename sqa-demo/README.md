# Prototipo web de control de cuotas

Demostración mínima para el Test Plan SQA del sistema de pagos del Colegio de Ingenieros. Muestra cuotas de una afiliada ficticia, calcula su habilitación y permite aprobar o rechazar una solicitud simulada. Los datos se guardan solo en `localStorage` del navegador. No hay autenticación, carga de archivos, API ni pagos reales.

## Ejecutar

Desde esta carpeta, iniciar un servidor HTTP estático (`python -m http.server 8000`) y abrir `http://localhost:8000`. Reiniciar ejemplo devuelve los datos iniciales.

## Pruebas

`node --test tests/*.test.mjs` ejecuta diez pruebas unitarias sin dependencias.

La carpeta `cypress/` contiene dos escenarios de navegador. Para ejecutarlos: iniciar el servidor, instalar Cypress en un entorno de Node y correr `npx cypress run` desde esta carpeta.

La carpeta `selenium/` contiene dos escenarios equivalentes. Para ejecutarlos: iniciar el servidor, instalar `selenium` para Python y correr `python selenium/test_cuotas.py` con Chrome disponible.

Los escenarios de aceptación para navegador son: al abrir, octubre aparece pendiente y la habilitación es No habilitado; al aprobar, octubre pasa a pagada y la habilitación es Habilitado; al reiniciar y rechazar, la cuota permanece pendiente. Cypress y Selenium están preparados como herramientas de automatización de navegador; el resultado verificado localmente corresponde a las pruebas unitarias.
