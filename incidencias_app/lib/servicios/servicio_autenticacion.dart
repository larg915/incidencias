import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:incidencias_app/configuracion/configuracion_api.dart';

class ServicioAutenticacion {

  Future<Map<String, dynamic>> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    final respuesta = await http
        .post(
          Uri.parse('${ConfiguracionApi.urlBase}/api/usuarios/login'),
          headers: _encabezados(),
          body: jsonEncode({
            'correo': correo,
            'contrasena': contrasena,
          }),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificar(respuesta);

    if (respuesta.statusCode == 200 &&
        datos is Map &&
        datos['token'] is String &&
        (datos['token'] as String).isNotEmpty) {
      return Map<String, dynamic>.from(datos);
    }

    throw Exception(_mensajeError(datos, respuesta.statusCode));
  }

  Future<Map<String, dynamic>> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    final respuesta = await http
        .post(
          Uri.parse('${ConfiguracionApi.urlBase}/api/usuarios/registro'),
          headers: _encabezados(),
          body: jsonEncode({
            'nombre': nombre,
            'correo': correo,
            'contrasena': contrasena,
          }),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificar(respuesta);

    if ((respuesta.statusCode == 201 || respuesta.statusCode == 200) &&
        datos is Map) {
      return Map<String, dynamic>.from(datos);
    }

    throw Exception(_mensajeError(datos, respuesta.statusCode));
  }

  Map<String, String> _encabezados() {
    return const {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
  }

  dynamic _decodificar(http.Response respuesta) {
    if (respuesta.body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(respuesta.body);
    } on FormatException {
      return respuesta.body;
    }
  }

  String _mensajeError(dynamic datos, int codigo) {
    if (datos is Map) {
      return (datos['message'] ??
              datos['mensaje'] ??
              'Error del servidor (HTTP $codigo).')
          .toString();
    }

    return 'Error del servidor (HTTP $codigo).';
  }
}