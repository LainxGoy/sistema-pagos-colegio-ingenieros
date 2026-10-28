export const initialData = {
  cuotas: [
    { id: 1, periodo: 'septiembre 2026', importe: 100, vencimiento: '2026-09-30', estado: 'pagada' },
    { id: 2, periodo: 'octubre 2026', importe: 100, vencimiento: '2026-10-20', estado: 'pendiente' }
  ],
  pago: { id: 1, cuotaId: 2, estado: 'pendiente' }
};

export function habilitacion(cuotas, hoy) {
  if (!Array.isArray(cuotas) || cuotas.length === 0) return 'Sin información suficiente';
  return cuotas.some(c => c.estado !== 'pagada' && c.vencimiento < hoy)
    ? 'No habilitado' : 'Habilitado';
}

export function resolverPago(datos, decision) {
  if (!['aprobado', 'rechazado'].includes(decision)) throw new Error('Decisión inválida');
  if (datos.pago.estado !== 'pendiente') throw new Error('El pago ya fue revisado');
  const cuota = datos.cuotas.find(c => c.id === datos.pago.cuotaId);
  if (!cuota) throw new Error('Cuota no encontrada');
  if (cuota.estado === 'pagada') throw new Error('La cuota ya está pagada');
  return {
    cuotas: datos.cuotas.map(c => c.id === cuota.id && decision === 'aprobado' ? { ...c, estado: 'pagada' } : { ...c }),
    pago: { ...datos.pago, estado: decision }
  };
}
