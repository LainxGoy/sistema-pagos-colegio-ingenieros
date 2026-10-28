import test from 'node:test';
import assert from 'node:assert/strict';
import { initialData, habilitacion, resolverPago } from '../src/domain.mjs';

const fresh = () => structuredClone(initialData);
test('sin cuotas no hay información suficiente', () => assert.equal(habilitacion([], '2026-10-28'), 'Sin información suficiente'));
test('cuota pagada no bloquea la habilitación', () => assert.equal(habilitacion([{ estado: 'pagada', vencimiento: '2026-10-01' }], '2026-10-28'), 'Habilitado'));
test('cuota pendiente vencida bloquea la habilitación', () => assert.equal(habilitacion(fresh().cuotas, '2026-10-28'), 'No habilitado'));
test('cuota pendiente futura mantiene la habilitación', () => assert.equal(habilitacion(fresh().cuotas, '2026-10-01'), 'Habilitado'));
test('aprobar marca solo la cuota vinculada como pagada', () => {
  const result = resolverPago(fresh(), 'aprobado');
  assert.equal(result.pago.estado, 'aprobado');
  assert.deepEqual(result.cuotas.map(c => c.estado), ['pagada', 'pagada']);
});
test('rechazar conserva la deuda', () => {
  const result = resolverPago(fresh(), 'rechazado');
  assert.equal(result.pago.estado, 'rechazado');
  assert.equal(result.cuotas[1].estado, 'pendiente');
});
test('no se puede resolver dos veces', () => assert.throws(() => resolverPago(resolverPago(fresh(), 'aprobado'), 'rechazado'), /ya fue revisado/));
test('rechaza decisiones inválidas', () => assert.throws(() => resolverPago(fresh(), 'otro'), /inválida/));
test('rechaza cuotas inexistentes', () => { const d = fresh(); d.pago.cuotaId = 99; assert.throws(() => resolverPago(d, 'aprobado'), /no encontrada/); });
test('los datos originales no cambian', () => { const d = fresh(); resolverPago(d, 'aprobado'); assert.equal(d.cuotas[1].estado, 'pendiente'); });
