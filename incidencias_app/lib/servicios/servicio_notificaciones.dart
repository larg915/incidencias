import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:incidencias_app/configuracion/configuracion_api.dart';

class ServicioNotificaciones {

  Future<List<Map<String, dynamic>>> listarPropias(String token) async {
    final respuesta = await http
        .get(
          Uri.parse('${ConfiguracionApi.urlBase}/api/notificaciones'),
          headers: _encabezados(token),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificar(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }

    if (datos is! List) {
      throw Exception('El servidor no devolvió una lista de notificaciones.');
    }

    return datos
        .map((elemento) => Map<String, dynamic>.from(elemento as Map))
        .toList();
  }

  Future<Map<String, dynamic>> marcarComoLeida({
    required String token,
    required String notificacionId,
  }) async {
    final respuesta = await http
        .put(
          Uri.parse('${ConfiguracionApi.urlBase}/api/notificaciones/$notificacionId/leida'),
          headers: _encabezados(token),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificar(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }

    if (datos is! Map) {
      throw Exception('El servidor no devolvió la notificación actualizada.');
    }

    return Map<String, dynamic>.from(datos);
  }

  Map<String, String> _encabezados(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
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