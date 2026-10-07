import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/cuota.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';

class RegistrarPagoScreen extends StatefulWidget {
  const RegistrarPagoScreen({super.key});

  @override
  State<RegistrarPagoScreen> createState() => _RegistrarPagoScreenState();
}

class _RegistrarPagoScreenState extends State<RegistrarPagoScreen> {
  final ApiService _apiService = ApiService();

  List<Cuota> _cuotasPendientes = [];
  Cuota? _cuotaSeleccionada;
  PlatformFile? _comprobanteSeleccionado;

  bool _isLoadingCuotas = true;
  bool _isSubmitting = false;
  late final String _fechaActual;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fechaActual = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoadingCuotas) {
      _loadPendientes();
    }
  }

  Future<void> _loadPendientes() async {
    final arg = ModalRoute.of(context)?.settings.arguments;

    try {
      final todas = await _apiService.getCuotas();
      final pendientes = todas.where((c) => c.isPendiente).toList();

      // Check if a specific cuota was passed as an argument from another screen
      Cuota? preselected;
      if (arg is Cuota) {
        preselected = pendientes.firstWhere(
          (c) => c.id == arg.id,
          orElse: () => pendientes.isNotEmpty ? pendientes.first : arg,
        );
      } else if (pendientes.isNotEmpty) {
        preselected = pendientes.first;
      }

      if (mounted) {
        setState(() {
          _cuotasPendientes = pendientes;
          _cuotaSeleccionada = preselected;
          _isLoadingCuotas = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCuotas = false;
        });
        _showErrorSnackBar('No se pudieron cargar las cuotas pendientes: $e');
      }
    }
  }

  Future<void> _seleccionarComprobante() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
        withData: true, // Needed for web/multiplatform byte support
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _comprobanteSeleccionado = result.files.first;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error al seleccionar el archivo: $e');
    }
  }

  void _eliminarComprobante() {
    setState(() {
      _comprobanteSeleccionado = null;
    });
  }

  Future<void> _handleRegistrarPago() async {
    if (_cuotaSeleccionada == null) {
      _showErrorSnackBar('Por favor seleccione una cuota para realizar el pago.');
      return;
    }

    if (_comprobanteSeleccionado == null) {
      _showErrorSnackBar('Debe adjuntar una imagen o PDF del comprobante de pago.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _apiService.registrarPago(
        cuotaId: _cuotaSeleccionada!.id,
        monto: _cuotaSeleccionada!.monto,
        fecha: _fechaActual,
        comprobante: _comprobanteSeleccionado!,
      );

      if (!mounted) return;

      // Show confirmation dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF1B873F),
                  size: 52,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pago Registrado',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Su comprobante para la cuota de ${_cuotaSeleccionada!.periodo} ${_cuotaSeleccionada!.gestion} ha sido enviado con éxito.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_top_rounded, size: 14, color: Color(0xFFE65100)),
                    SizedBox(width: 6),
                    Text(
                      'Queda pendiente de revisión',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              CustomButton(
                text: 'Continuar a Cuotas',
                backgroundColor: const Color(0xFF0F2B48),
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  // Pop back or redirect to /cuotas
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context, true);
                  } else {
                    Navigator.pushReplacementNamed(context, '/cuotas');
                  }
                },
              ),
            ],
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.message);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('No se pudo completar el registro del pago: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFC62828),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Registrar Pago de Cuota',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2B48),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoadingCuotas
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F2B48)),
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Information card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Color(0xFF0369A1), size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Seleccione la cuota a cancelar y adjunte el comprobante de transferencia bancaria o depósito.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF0369A1), height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Main Form Card
                    Container(
                      padding: const EdgeInsets.all(22.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Selector de Cuotas
                          const Text(
                            '1. Cuota Pendiente',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (_cuotasPendientes.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '¡Excelente! No tiene cuotas pendientes de pago.',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Cuota>(
                                  isExpanded: true,
                                  value: _cuotaSeleccionada,
                                  hint: const Text('Seleccione una cuota'),
                                  items: _cuotasPendientes.map((cuota) {
                                    return DropdownMenuItem<Cuota>(
                                      value: cuota,
                                      child: Text(
                                        '${cuota.periodo} ${cuota.gestion} (Bs. ${cuota.monto.toStringAsFixed(2)})',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (nueva) {
                                    setState(() {
                                      _cuotaSeleccionada = nueva;
                                    });
                                  },
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),

                          // 2. Monto a Pagar (Solo Lectura / Automático)
                          const Text(
                            '2. Monto a Pagar (Bs.)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            key: ValueKey(_cuotaSeleccionada?.monto ?? 0),
                            initialValue: _cuotaSeleccionada != null
                                ? 'Bs. ${_cuotaSeleccionada!.monto.toStringAsFixed(2)}'
                                : 'Bs. 0.00',
                            readOnly: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.monetization_on_outlined, color: Color(0xFF64748B)),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 3. Fecha de Registro (Automática)
                          const Text(
                            '3. Fecha de Registro',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: _fechaActual,
                            readOnly: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.event_note_rounded, color: Color(0xFF64748B)),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // 4. Selector de Comprobante
                          const Text(
                            '4. Comprobante de Pago',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Formatos permitidos: JPG, PNG o PDF (Máx. 5MB)',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 12),

                          if (_comprobanteSeleccionado == null)
                            InkWell(
                              onTap: _seleccionarComprobante,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF94A3B8),
                                    style: BorderStyle.solid,
                                    width: 1.2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F2B48).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.cloud_upload_outlined,
                                        size: 32,
                                        color: Color(0xFF0F2B48),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Presione para adjuntar comprobante',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F2B48),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Haga clic para buscar en su dispositivo',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: (_comprobanteSeleccionado!.extension?.toLowerCase() == 'pdf')
                                          ? const Color(0xFFFFEBEE)
                                          : const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      (_comprobanteSeleccionado!.extension?.toLowerCase() == 'pdf')
                                          ? Icons.picture_as_pdf_rounded
                                          : Icons.image_rounded,
                                      color: (_comprobanteSeleccionado!.extension?.toLowerCase() == 'pdf')
                                          ? const Color(0xFFC62828)
                                          : const Color(0xFF1B873F),
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _comprobanteSeleccionado!.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatFileSize(_comprobanteSeleccionado!.size),
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Cambiar archivo',
                                    icon: const Icon(Icons.sync_rounded, color: Color(0xFF0F2B48)),
                                    onPressed: _seleccionarComprobante,
                                  ),
                                  IconButton(
                                    tooltip: 'Eliminar',
                                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFC62828)),
                                    onPressed: _eliminarComprobante,
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 30),

                          // Submit Button
                          CustomButton(
                            text: 'ENVIAR COMPROBANTE',
                            icon: Icons.send_rounded,
                            isLoading: _isSubmitting,
                            backgroundColor: const Color(0xFF0F2B48),
                            onPressed: (_cuotasPendientes.isEmpty || _isSubmitting)
                                ? null
                                : _handleRegistrarPago,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
