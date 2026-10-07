import 'package:flutter/material.dart';
import '../screens/cuotas_screen.dart';
import '../screens/inicio_screen.dart';
import '../screens/login_screen.dart';
import '../screens/registrar_pago_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String inicio = '/inicio';
  static const String cuotas = '/cuotas';
  static const String registrarPago = '/registrar-pago';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      inicio: (context) => const InicioScreen(),
      cuotas: (context) => const CuotasScreen(),
      registrarPago: (context) => const RegistrarPagoScreen(),
    };
  }
}
