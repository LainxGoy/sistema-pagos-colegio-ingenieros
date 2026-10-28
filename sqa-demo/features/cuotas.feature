# Escenarios de aceptación BDD para el prototipo SQA.
# Se redactaron después del prototipo y se corresponden con los recorridos
# automatizados en cypress/e2e/cuotas.cy.js y selenium/test_cuotas.py.
# Este archivo no usa un ejecutor Gherkin/Cucumber independiente.

Característica: Revisión de cuotas de una afiliada
  Como responsable de calidad del prototipo
  Quiero verificar las decisiones de revisión de pagos
  Para conocer el estado de la cuota y la habilitación

  Antecedentes:
    Dado que el ejemplo de Ana Pérez se ha reiniciado
    Y septiembre de 2026 está pagado
    Y octubre de 2026 está pendiente con una solicitud en revisión

  Escenario: Aprobar la solicitud pendiente
    Cuando el administrador aprueba la solicitud de octubre
    Entonces la cuota de octubre queda pagada
    Y la solicitud queda aprobada
    Y la afiliada aparece habilitada

  Escenario: Rechazar la solicitud pendiente
    Cuando el administrador rechaza la solicitud de octubre
    Entonces la cuota de octubre permanece pendiente
    Y la solicitud queda rechazada
    Y la afiliada aparece no habilitada

  Escenario: Agregar cuota y solicitar su revisión
    Cuando el administrador agrega noviembre de 2026 por Bs 120 con vencimiento 20/11/2026
    Y la afiliada solicita revisión de la cuota de noviembre
    Entonces aparece la cuota de noviembre como pendiente
    Y aparece una solicitud de noviembre pendiente de revisión
