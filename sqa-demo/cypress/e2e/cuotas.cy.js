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
  it('agrega una cuota y crea una solicitud para revisarla', () => {
    cy.get('#periodo').type('noviembre 2026');
    cy.get('#importe').type('120');
    cy.get('#vencimiento').type('2026-11-20');
    cy.contains('Agregar cuota').click();
    cy.contains('noviembre 2026').should('exist');
    cy.contains('Solicitar revisión').click();
    cy.contains('Solicitud enviada a revisión.');
  });
});

