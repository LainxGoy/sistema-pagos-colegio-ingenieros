# Tablero Kanban SQA — prototipo de cuotas

**Corte:** 28 de octubre de 2026 · **Responsable:** Diego · **Sprint:** 28 de octubre al 3 de noviembre de 2026

Este tablero conecta las tareas de calidad con el [plan de pruebas ágil](README.md), el [PR 11](https://github.com/LainxGoy/sistema-pagos-colegio-ingenieros/pull/11) y la [ejecución de CI](https://github.com/LainxGoy/sistema-pagos-colegio-ingenieros/actions/runs/40750375665). Se trabaja individualmente; la validación externa corresponde al docente o evaluador.

| Backlog | En progreso | En revisión | Hecho |
| --- | --- | --- | --- |
| [#14 Corregir fecha y persistencia](https://github.com/LainxGoy/sistema-pagos-colegio-ingenieros/issues/14) | — | [#12 Validar prototipo y pruebas](https://github.com/LainxGoy/sistema-pagos-colegio-ingenieros/issues/12) | [#13 Ejecutar Cypress y Selenium](https://github.com/LainxGoy/sistema-pagos-colegio-ingenieros/issues/13) |

## Reglas de flujo

1. Una tarea entra en **Backlog** con alcance y prioridad definidos.
2. Pasa a **En progreso** cuando comienza el trabajo. Límite de trabajo en curso: una tarea.
3. Pasa a **En revisión** cuando tiene código, criterio de aceptación y evidencia de pruebas enlazados.
4. Pasa a **Hecho** cuando se revisan los resultados y se cierra el issue. La aceptación externa del prototipo sigue pendiente en #12.
5. Toda corrección de una regla ejecuta de nuevo las pruebas unitarias y los escenarios de navegador en CI.

## Criterios verificables y evidencia

| Tarea | Historia / criterio | Evidencia | Próximo paso |
| --- | --- | --- | --- |
| #12 | HU-SQA-01 a 04: asignar cuota, consultar habilitación, solicitar revisión y aprobar o rechazar | [PR 11](https://github.com/LainxGoy/sistema-pagos-colegio-ingenieros/pull/11); [CI aprobado](https://github.com/LainxGoy/sistema-pagos-colegio-ingenieros/actions/runs/40750375665) | Revisión y aceptación externa |
| #13 | Automatizar tres recorridos de interfaz con dos herramientas | [Cypress](cypress/e2e/cuotas.cy.js); [Selenium](selenium/test_cuotas.py); [CI aprobado](https://github.com/LainxGoy/sistema-pagos-colegio-ingenieros/actions/runs/40750375665) | Cerrado |
| #14 | Reducir riesgos de fecha fija y almacenamiento local | [Auditoría y riesgos](https://github.com/LainxGoy/sistema-pagos-colegio-ingenieros/issues/14) | Planificar solo si se amplía el prototipo |

**Resultados al corte:** 17/17 unitarias, 3/3 Cypress y 3/3 Selenium aprobadas. El cierre de #12 depende de la revisión del evaluador.
