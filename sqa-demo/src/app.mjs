import { initialData, habilitacion, asignarCuota, solicitarPago, resolverPago } from './domain.mjs?v=2';

const key = 'sqa-cuotas-demo-v2';
function readData() {
  try {
    const value = JSON.parse(localStorage.getItem(key));
    if (value && Array.isArray(value.cuotas) && Array.isArray(value.pagos)) return value;
  } catch { /* Se restablecen datos de ejemplo corruptos. */ }
  return structuredClone(initialData);
}
let datos = readData();
const cuotasEl = document.querySelector('#cuotas');
const pagosEl = document.querySelector('#pagos');
const habilitacionEl = document.querySelector('#habilitacion');
const mensajeEl = document.querySelector('#mensaje');

function cell(row, value) {
  const td = document.createElement('td');
  td.textContent = value;
  row.append(td);
  return td;
}
function button(label, action, secondary = false) {
  const b = document.createElement('button');
  b.type = 'button'; b.textContent = label;
  if (secondary) b.className = 'secondary';
  b.addEventListener('click', action);
  return b;
}
function saveAndRender(message) {
  localStorage.setItem(key, JSON.stringify(datos));
  mensajeEl.textContent = message;
  render();
}
function run(action) {
  try { action(); } catch (error) { mensajeEl.textContent = error.message; }
}
function render() {
  cuotasEl.replaceChildren();
  pagosEl.replaceChildren();
  for (const cuota of datos.cuotas) {
    const tr = document.createElement('tr');
    for (const value of [cuota.periodo, `Bs ${cuota.importe.toFixed(2)}`, cuota.vencimiento, cuota.estado]) cell(tr, value);
    const action = cell(tr, '');
    const activa = datos.pagos.some(p => p.cuotaId === cuota.id && p.estado === 'pendiente');
    if (cuota.estado === 'pendiente' && !activa) action.append(button('Solicitar revisión', () => run(() => {
      datos = solicitarPago(datos, cuota.id);
      saveAndRender('Solicitud enviada a revisión.');
    })));
    else action.textContent = activa ? 'Solicitud pendiente' : '—';
    cuotasEl.append(tr);
  }
  const estado = habilitacion(datos.cuotas, '2026-10-28');
  habilitacionEl.textContent = estado;
  habilitacionEl.className = `badge ${estado === 'Habilitado' ? 'ok' : 'bad'}`;
  for (const pago of datos.pagos) {
    const cuota = datos.cuotas.find(c => c.id === pago.cuotaId);
    const tr = document.createElement('tr');
    cell(tr, cuota?.periodo ?? 'Cuota desconocida');
    cell(tr, pago.estado);
    const action = cell(tr, '');
    if (pago.estado === 'pendiente') {
      for (const [label, decision] of [['Aprobar', 'aprobado'], ['Rechazar', 'rechazado']]) {
        action.append(button(label, () => run(() => {
          datos = resolverPago(datos, pago.id, decision);
          saveAndRender(`Solicitud ${decision === 'aprobado' ? 'aprobada' : 'rechazada'}.`);
        }), decision === 'rechazado'));
      }
    } else action.textContent = 'Revisada';
    pagosEl.append(tr);
  }
}
document.querySelector('#form-cuota').addEventListener('submit', event => {
  event.preventDefault();
  run(() => {
    const form = event.currentTarget;
    datos = asignarCuota(datos,
      form.elements.namedItem('periodo').value,
      form.elements.namedItem('importe').value,
      form.elements.namedItem('vencimiento').value);
    form.reset();
    saveAndRender('Cuota agregada.');
  });
});
document.querySelector('#reiniciar').addEventListener('click', () => {
  datos = structuredClone(initialData);
  localStorage.removeItem(key);
  mensajeEl.textContent = 'Ejemplo reiniciado.';
  render();
});
render();

