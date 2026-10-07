import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/cuota.dart';
import '../models/pago.dart';
import '../models/usuario.dart';
import 'auth_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class ApiService {
  // Base configuration
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const bool useMockData = true; // Toggle between Mock and Real Laravel REST API
  static const Duration requestTimeout = Duration(seconds: 15);

  final AuthService _authService = AuthService();

  // In-memory mock state for seamless testing
  static List<Cuota> _mockCuotas = [
    const Cuota(
      id: 1,
      periodo: 'Enero',
      gestion: 2026,
      monto: 150.00,
      estado: 'PAGADA',
      fechaVencimiento: '31/01/2026',
      estadoRevisionPago: 'APROBADO',
    ),
    const Cuota(
      id: 2,
      periodo: 'Febrero',
      gestion: 2026,
      monto: 150.00,
      estado: 'PAGADA',
      fechaVencimiento: '28/02/2026',
      estadoRevisionPago: 'APROBADO',
    ),
    const Cuota(
      id: 3,
      periodo: 'Marzo',
      gestion: 2026,
      monto: 150.00,
      estado: 'PENDIENTE',
      fechaVencimiento: '31/03/2026',
      estadoRevisionPago: null,
    ),
    const Cuota(
      id: 4,
      periodo: 'Abril',
      gestion: 2026,
      monto: 150.00,
      estado: 'PENDIENTE',
      fechaVencimiento: '30/04/2026',
      estadoRevisionPago: null,
    ),
  ];

  static final List<Pago> _mockPagos = [];

  // ==========================================
  // 1. LOGIN (POST /login)
  // ==========================================
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 900));

      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw ApiException('Por favor complete todos los campos.', statusCode: 422);
      }

      // Allow testing with common credentials or any valid email
      if (password == '123456' || password.length >= 6) {
        final mockUsuario = Usuario(
          id: 101,
          nombre: 'Ing. Carlos Mendoza R.',
          email: email.trim(),
          token: 'mock_jwt_token_ci_bolivia_2026_xyz',
          estadoHabilitacion: true,
          montoCuotaActual: 150.00,
        );

        return {
          'token': mockUsuario.token,
          'usuario': mockUsuario,
        };
      } else {
        throw ApiException('Credenciales incorrectas. Verifique su correo o contraseña.', statusCode: 401);
      }
    }

    try {
      final url = Uri.parse('$baseUrl/login');
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(requestTimeout);

      final Map<String, dynamic> result = _handleResponse(response, (body) {
        final token = body['token']?.toString() ?? body['access_token']?.toString() ?? '';
        final userData = body['user'] ?? body['usuario'] ?? body['data'] ?? body;
        final usuario = Usuario.fromJson(Map<String, dynamic>.from(userData)).copyWith(token: token);

        return {
          'token': token,
          'usuario': usuario,
        };
      });
      return result;
    } on SocketException {
      throw ApiException('No se pudo conectar con el servidor. Verifique su conexión a internet.');
    } on TimeoutException {
      throw ApiException('El servidor tardó demasiado en responder. Intente nuevamente.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado durante la autenticación: ${e.toString()}');
    }
  }

  // ==========================================
  // 2. GET CUOTAS (GET /cuotas)
  // ==========================================
  Future<List<Cuota>> getCuotas() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 700));
      return List<Cuota>.from(_mockCuotas);
    }

    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        throw ApiException('Sesión expirada. Por favor inicie sesión nuevamente.', statusCode: 401);
      }

      final url = Uri.parse('$baseUrl/cuotas');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(requestTimeout);

      final List<Cuota> list = _handleResponse(response, (body) {
        final dynamic rawList = body is List ? body : (body['data'] ?? body['cuotas'] ?? []);
        if (rawList is List) {
          return rawList.map((item) => Cuota.fromJson(Map<String, dynamic>.from(item))).toList();
        }
        return <Cuota>[];
      });
      return list;
    } on SocketException {
      throw ApiException('No se pudo conectar con el servidor. Verifique su conexión.');
    } on TimeoutException {
      throw ApiException('Tiempo de espera agotado al consultar cuotas.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error al obtener la lista de cuotas: ${e.toString()}');
    }
  }

  // ==========================================
  // 3. REGISTRAR PAGO (POST /pagos Multipart)
  // ==========================================
  Future<Pago> registrarPago({
    required int cuotaId,
    required double monto,
    required String fecha,
    required PlatformFile comprobante,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 1400));

      // Create new mock pago
      final nuevoPago = Pago(
        id: _mockPagos.length + 1,
        cuotaId: cuotaId,
        monto: monto,
        fecha: fecha,
        comprobantePath: comprobante.name,
        estadoRevision: 'PENDIENTE',
      );
      _mockPagos.add(nuevoPago);

      // Update in-memory cuota state
      _mockCuotas = _mockCuotas.map((c) {
        if (c.id == cuotaId) {
          return c.copyWith(
            estadoRevisionPago: 'PENDIENTE',
          );
        }
        return c;
      }).toList();

      return nuevoPago;
    }

    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        throw ApiException('Sesión expirada. Por favor inicie sesión nuevamente.', statusCode: 401);
      }

      final url = Uri.parse('$baseUrl/pagos');
      final request = http.MultipartRequest('POST', url);

      // Headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Form text fields
      request.fields['cuota_id'] = cuotaId.toString();
      request.fields['monto'] = monto.toStringAsFixed(2);
      request.fields['fecha'] = fecha;

      // Determine MIME type
      MediaType? contentType;
      final ext = comprobante.extension?.toLowerCase() ?? '';
      if (ext == 'pdf') {
        contentType = MediaType('application', 'pdf');
      } else if (ext == 'png') {
        contentType = MediaType('image', 'png');
      } else if (ext == 'jpg' || ext == 'jpeg') {
        contentType = MediaType('image', 'jpeg');
      }

      // Attach file (supports both bytes & path)
      if (comprobante.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'comprobante',
            comprobante.bytes!,
            filename: comprobante.name,
            contentType: contentType,
          ),
        );
      } else if (comprobante.path != null && comprobante.path!.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'comprobante',
            comprobante.path!,
            filename: comprobante.name,
            contentType: contentType,
          ),
        );
      } else {
        throw ApiException('El archivo del comprobante no es válido o no contiene datos.');
      }

      final streamedResponse = await request.send().timeout(requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      final Pago nuevoPago = _handleResponse(response, (body) {
        final pagoData = body['pago'] ?? body['data'] ?? body;
        return Pago.fromJson(Map<String, dynamic>.from(pagoData));
      });
      return nuevoPago;
    } on SocketException {
      throw ApiException('No se pudo conectar con el servidor para registrar el pago.');
    } on TimeoutException {
      throw ApiException('Tiempo de espera agotado al subir el comprobante de pago.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error al registrar el pago: ${e.toString()}');
    }
  }

  // ==========================================
  // HTTP RESPONSE HANDLER & ERROR PARSING
  // ==========================================
  T _handleResponse<T>(http.Response response, T Function(dynamic body) onSuccess) {
    final statusCode = response.statusCode;
    dynamic decodedBody;

    try {
      if (response.body.isNotEmpty) {
        decodedBody = jsonDecode(response.body);
      }
    } catch (_) {
      decodedBody = null;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return onSuccess(decodedBody);
    }

    // Extract message from standard Laravel response formats
    String errorMessage = 'Error en el servidor ($statusCode).';
    dynamic errorsList;

    if (decodedBody is Map) {
      if (decodedBody['message'] != null) {
        errorMessage = decodedBody['message'].toString();
      } else if (decodedBody['error'] != null) {
        errorMessage = decodedBody['error'].toString();
      }
      errorsList = decodedBody['errors'];
    }

    switch (statusCode) {
      case 401:
        throw ApiException(
          errorMessage.isNotEmpty ? errorMessage : 'No autorizado. Verifique sus credenciales.',
          statusCode: 401,
        );
      case 422:
        // Validation errors from Laravel
        String formattedErrors = errorMessage;
        if (errorsList is Map) {
          final firstErrors = errorsList.values.map((v) => (v is List && v.isNotEmpty) ? v.first : v.toString()).join('\n');
          if (firstErrors.isNotEmpty) {
            formattedErrors = firstErrors;
          }
        }
        throw ApiException(formattedErrors, statusCode: 422, errors: errorsList);
      case 404:
        throw ApiException('El recurso solicitado no fue encontrado (404).', statusCode: 404);
      case 500:
        throw ApiException('Error interno en el servidor (500). Intente más tarde.', statusCode: 500);
      default:
        throw ApiException(errorMessage, statusCode: statusCode, errors: errorsList);
    }
  }
}
