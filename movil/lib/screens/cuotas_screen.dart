import 'package:flutter/material.dart';
import '../models/cuota.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/status_badge.dart';

class CuotasScreen extends StatefulWidget {
  const CuotasScreen({super.key});

  @override
  State<CuotasScreen> createState() => _CuotasScreenState();
}

class _CuotasScreenState extends State<CuotasScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  List<Cuota> _cuotas = [];
  Usuario? _usuario;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userFuture = _authService.getUser();
      final cuotasFuture = _apiService.getCuotas();

      final results = await Future.wait([userFuture, cuotasFuture]);

      if (mounted) {
        setState(() {
          _usuario = results[0] as Usuario?;
          _cuotas = results[1] as List<Cuota>;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Ocurrió un error al cargar las cuotas. Intente nuevamente.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final habilitado = _usuario?.estadoHabilitacion ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Mis Cuotas y Aportes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2B48),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Banner: Estado General de Habilitación
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (habilitado ? const Color(0xFF1B873F) : const Color(0xFFC62828))
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      habilitado ? Icons.verified_user_rounded : Icons.warning_amber_rounded,
                      color: habilitado ? const Color(0xFF1B873F) : const Color(0xFFC62828),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estado Profesional:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          habilitado ? 'Habilitado para el ejercicio' : 'Inhabilitado por mora',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: habilitado ? const Color(0xFF1B873F) : const Color(0xFFC62828),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge.habilitacion(
                    habilitado: habilitado,
                    isLarge: false,
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F2B48),
        icon: const Icon(Icons.add_card_rounded, color: Colors.white),
        label: const Text(
          'Registrar Pago',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/registrar-pago');
          if (result == true) {
            _fetchData();
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F2B48)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 56, color: Color(0xFFC62828)),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F2B48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _fetchData,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text('Reintentar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_cuotas.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchData,
        color: const Color(0xFF0F2B48),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No tiene cuotas registradas',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: const Color(0xFF0F2B48),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _cuotas.length,
        itemBuilder: (context, index) {
          final cuota = _cuotas[index];
          return _CuotaListItemCard(
            cuota: cuota,
            onPayPressed: cuota.isPendiente
                ? () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/registrar-pago',
                      arguments: cuota,
                    );
                    if (result == true) {
                      _fetchData();
                    }
                  }
                : null,
          );
        },
      ),
    );
  }
}

class _CuotaListItemCard extends StatelessWidget {
  final Cuota cuota;
  final VoidCallback? onPayPressed;

  const _CuotaListItemCard({
    required this.cuota,
    this.onPayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isPagada = cuota.isPagada;
    final revision = cuota.estadoRevisionPago;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPagada ? const Color(0xFFE2E8F0) : const Color(0xFFFFCCBC).withValues(alpha: 0.6),
          width: isPagada ? 1 : 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Period / Year & Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2B48).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Color(0xFF0F2B48),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${cuota.periodo} ${cuota.gestion}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (cuota.fechaVencimiento.isNotEmpty)
                          Text(
                            'Vence: ${cuota.fechaVencimiento}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                StatusBadge.cuota(estado: cuota.estado),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 12),

            // Amount & Review Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monto a pagar',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bs. ${cuota.monto.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isPagada ? const Color(0xFF2E7D32) : const Color(0xFF0F2B48),
                      ),
                    ),
                  ],
                ),

                // Review Status badge if exists
                if (revision != null && revision.isNotEmpty) ...[
                  StatusBadge.pagoRevision(estadoRevision: revision),
                ] else if (!isPagada && onPayPressed != null) ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2B48),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: onPayPressed,
                    icon: const Icon(Icons.payment_rounded, size: 16),
                    label: const Text(
                      'Pagar',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
