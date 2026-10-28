export const initialData = {
  cuotas: [
    { id: 1, periodo: 'septiembre 2026', importe: 100, vencimiento: '2026-09-30', estado: 'pagada' },
    { id: 2, periodo: 'octubre 2026', importe: 100, vencimiento: '2026-10-20', estado: 'pendiente' }
  ],
  pagos: [{ id: 1, cuotaId: 2, estado: 'pendiente' }]
};

export function habilitacion(cuotas, hoy) {
  if (!Array.isArray(cuotas) || cuotas.length === 0) return 'Sin información suficiente';
  return cuotas.some(c => c.estado !== 'pagada' && c.vencimiento < hoy)
    ? 'No habilitado' : 'Habilitado';
}

export function asignarCuota(datos, periodo, importe, vencimiento) {
  const nombre = String(periodo).trim();
  const monto = Number(importe);
  if (!nombre || !Number.isFinite(monto) || monto <= 0 || !/^\d{4}-\d{2}-\d{2}$/.test(vencimiento)) {
    throw new Error('Complete período, importe positivo y vencimiento válido');
  }
  if (datos.cuotas.some(c => c.periodo.toLowerCase() === nombre.toLowerCase())) {
    throw new Error('Ya existe una cuota para ese período');
  }
  const id = Math.max(0, ...datos.cuotas.map(c => c.id)) + 1;
  return {
    cuotas: [...datos.cuotas.map(c => ({ ...c })), { id, periodo: nombre, importe: monto, vencimiento, estado: 'pendiente' }],
    pagos: datos.pagos.map(p => ({ ...p }))
  };
}

export function solicitarPago(datos, cuotaId) {
  const cuota = datos.cuotas.find(c => c.id === cuotaId);
  if (!cuota || cuota.estado !== 'pendiente') throw new Error('La cuota no está pendiente');
  if (datos.pagos.some(p => p.cuotaId === cuotaId && p.estado === 'pendiente')) {
    throw new Error('Ya hay una solicitud pendiente para esta cuota');
  }
  const id = Math.max(0, ...datos.pagos.map(p => p.id)) + 1;
  return {
    cuotas: datos.cuotas.map(c => ({ ...c })),
    pagos: [...datos.pagos.map(p => ({ ...p })), { id, cuotaId, estado: 'pendiente' }]
  };
}

export function resolverPago(datos, pagoId, decision) {
  if (!['aprobado', 'rechazado'].includes(decision)) throw new Error('Decisión inválida');
  const pago = datos.pagos.find(p => p.id === pagoId);
  if (!pago) throw new Error('Solicitud no encontrada');
  if (pago.estado !== 'pendiente') throw new Error('El pago ya fue revisado');
  const cuota = datos.cuotas.find(c => c.id === pago.cuotaId);
  if (!cuota) throw new Error('Cuota no encontrada');
  if (cuota.estado === 'pagada') throw new Error('La cuota ya está pagada');
  return {
    cuotas: datos.cuotas.map(c => c.id === cuota.id && decision === 'aprobado' ? { ...c, estado: 'pagada' } : { ...c }),
    pagos: datos.pagos.map(p => p.id === pagoId ? { ...p, estado: decision } : { ...p })
  };
}

