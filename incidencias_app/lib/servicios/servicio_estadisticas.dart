import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:incidencias_app/configuracion/configuracion_api.dart';

class ServicioEstadisticas {

  Future<Map<String, dynamic>> obtenerEstadisticas(String token) async {
    final respuesta = await http
        .get(
          Uri.parse('${ConfiguracionApi.urlBase}/api/estadisticas/incidencias'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    dynamic datos;

    try {
      datos = respuesta.body.isEmpty ? null : jsonDecode(respuesta.body);
    } on FormatException {
      datos = respuesta.body;
    }

    if (respuesta.statusCode != 200) {
      String mensaje = 'Error del servidor (HTTP ${respuesta.statusCode}).';

      if (datos is Map) {
        mensaje = (datos['message'] ?? datos['mensaje'] ?? mensaje).toString();
      }

      throw Exception(mensaje);
    }

    if (datos is! Map) {
      throw Exception('El servidor no devolvió las estadísticas.');
    }

    return Map<String, dynamic>.from(datos);
  }
}