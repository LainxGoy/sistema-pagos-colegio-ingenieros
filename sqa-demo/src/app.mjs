import { initialData, habilitacion, resolverPago } from './domain.mjs';

const key = 'sqa-cuotas-demo-v1';
function readData() {
  try {
    const value = JSON.parse(localStorage.getItem(key));
    if (value && Array.isArray(value.cuotas) && value.pago) return value;
  } catch { /* Se restablecen datos de ejemplo corruptos. */ }
  return structuredClone(initialData);
}
let datos = readData();
const cuotasEl = document.querySelector('#cuotas');
const habilitacionEl = document.querySelector('#habilitacion');
const pagoEl = document.querySelector('#pago');
const mensajeEl = document.querySelector('#mensaje');

function render() {
  cuotasEl.replaceChildren();
  for (const cuota of datos.cuotas) {
    const tr = document.createElement('tr');
    for (const value of [cuota.periodo, `Bs ${cuota.importe}`, cuota.vencimiento, cuota.estado]) {
      const td = document.createElement('td'); td.textContent = value; tr.append(td);
    }
    cuotasEl.append(tr);
  }
  const estado = habilitacion(datos.cuotas, '2026-10-28');
  habilitacionEl.textContent = estado;
  habilitacionEl.className = `badge ${estado === 'Habilitado' ? 'ok' : 'bad'}`;
  pagoEl.textContent = datos.pago.estado;
  document.querySelector('#aprobar').disabled = datos.pago.estado !== 'pendiente';
  document.querySelector('#rechazar').disabled = datos.pago.estado !== 'pendiente';
}
function decide(decision) {
  try {
    datos = resolverPago(datos, decision);
    localStorage.setItem(key, JSON.stringify(datos));
    mensajeEl.textContent = `Solicitud ${decision}.`;
    render();
  } catch (error) { mensajeEl.textContent = error.message; }
}
document.querySelector('#aprobar').addEventListener('click', () => decide('aprobado'));
document.querySelector('#rechazar').addEventListener('click', () => decide('rechazado'));
document.querySelector('#reiniciar').addEventListener('click', () => {
  datos = structuredClone(initialData);
  localStorage.removeItem(key);
  mensajeEl.textContent = 'Ejemplo reiniciado.';
  render();
});
render();
