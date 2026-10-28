describe('Control de cuotas', () => {
  beforeEach(() => { cy.visit('/'); cy.contains('Reiniciar ejemplo').click(); });
  it('aprueba una solicitud y habilita a la afiliada', () => {
    cy.contains('No habilitado');
    cy.contains('Aprobar').click();
    cy.contains('Habilitado');
    cy.contains('Solicitud aprobada.');
  });
  it('rechaza una solicitud sin pagar la cuota', () => {
    cy.contains('Rechazar').click();
    cy.contains('No habilitado');
    cy.contains('Solicitud rechazada.');
  });
});
