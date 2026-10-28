import test from 'node:test';
import assert from 'node:assert/strict';
import { initialData, habilitacion, asignarCuota, solicitarPago, resolverPago } from '../src/domain.mjs';

const fresh = () => structuredClone(initialData);
test('sin cuotas no hay información suficiente', () => assert.equal(habilitacion([], '2026-10-28'), 'Sin información suficiente'));
test('cuota pagada no bloquea la habilitación', () => assert.equal(habilitacion([{ estado: 'pagada', vencimiento: '2026-10-01' }], '2026-10-28'), 'Habilitado'));
test('cuota pendiente vencida bloquea la habilitación', () => assert.equal(habilitacion(fresh().cuotas, '2026-10-28'), 'No habilitado'));
test('cuota pendiente futura mantiene la habilitación', () => assert.equal(habilitacion(fresh().cuotas, '2026-10-01'), 'Habilitado'));
test('agregar cuota pendiente conserva las existentes', () => {
  const d = asignarCuota(fresh(), 'noviembre 2026', 120, '2026-11-20');
  assert.equal(d.cuotas.length, 3);
  assert.equal(d.cuotas[2].estado, 'pendiente');
  assert.equal(d.cuotas[0].estado, 'pagada');
});
test('no se duplica el período', () => assert.throws(() => asignarCuota(fresh(), 'OCTUBRE 2026', 100, '2026-11-20'), /Ya existe/));
test('rechaza importe no positivo', () => assert.throws(() => asignarCuota(fresh(), 'noviembre 2026', 0, '2026-11-20'), /importe positivo/));
test('rechaza vencimiento inválido', () => assert.throws(() => asignarCuota(fresh(), 'noviembre 2026', 100, 'mañana'), /vencimiento válido/));
test('solicita revisión de cuota pendiente sin solicitud activa', () => {
  const d = asignarCuota(fresh(), 'noviembre 2026', 120, '2026-11-20');
  const r = solicitarPago(d, 3);
  assert.equal(r.pagos.length, 2);
  assert.deepEqual(r.pagos[1], { id: 2, cuotaId: 3, estado: 'pendiente' });
});
test('no permite solicitud duplicada', () => assert.throws(() => solicitarPago(fresh(), 2), /Ya hay una solicitud/));
test('no permite solicitar pago de cuota pagada', () => assert.throws(() => solicitarPago(fresh(), 1), /no está pendiente/));
test('aprobar marca solo la cuota vinculada como pagada', () => {
  const result = resolverPago(fresh(), 1, 'aprobado');
  assert.equal(result.pagos[0].estado, 'aprobado');
  assert.deepEqual(result.cuotas.map(c => c.estado), ['pagada', 'pagada']);
});
test('rechazar conserva la deuda', () => {
  const result = resolverPago(fresh(), 1, 'rechazado');
  assert.equal(result.pagos[0].estado, 'rechazado');
  assert.equal(result.cuotas[1].estado, 'pendiente');
});
test('no se puede resolver dos veces', () => assert.throws(() => resolverPago(resolverPago(fresh(), 1, 'aprobado'), 1, 'rechazado'), /ya fue revisado/));
test('rechaza decisiones inválidas', () => assert.throws(() => resolverPago(fresh(), 1, 'otro'), /inválida/));
test('rechaza cuotas inexistentes', () => { const d = fresh(); d.pagos[0].cuotaId = 99; assert.throws(() => resolverPago(d, 1, 'aprobado'), /no encontrada/); });
test('los datos originales no cambian', () => { const d = fresh(); resolverPago(d, 1, 'aprobado'); assert.equal(d.cuotas[1].estado, 'pendiente'); });

