import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:incidencias_app/configuracion/configuracion_api.dart';

class ServicioSolicitudesServicio {

  Future<List<Map<String, dynamic>>> listarPorIncidencia({
    required String token,
    required String incidenciaId,
  }) async {
    final respuesta = await http
        .get(
          Uri.parse(
            '${ConfiguracionApi.urlBase}/api/incidencias/$incidenciaId/solicitudes-servicio',
          ),
          headers: _encabezados(token),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificar(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }

    if (datos is! List) {
      throw Exception(
        'El servidor no devolvió una lista de solicitudes de servicio.',
      );
    }

    return datos
        .map((elemento) => Map<String, dynamic>.from(elemento as Map))
        .toList();
  }

  Future<Map<String, dynamic>> crear({
    required String token,
    required String incidenciaId,
    required String tipoServicio,
    required String descripcion,
  }) async {
    final respuesta = await http
        .post(
          Uri.parse(
            '${ConfiguracionApi.urlBase}/api/incidencias/$incidenciaId/solicitudes-servicio',
          ),
          headers: _encabezados(token),
          body: jsonEncode({
            'tipoServicio': tipoServicio,
            'descripcion': descripcion,
          }),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificar(respuesta);

    if (respuesta.statusCode != 201 && respuesta.statusCode != 200) {
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }

    if (datos is! Map) {
      throw Exception('El servidor no devolvió la solicitud creada.');
    }

    return Map<String, dynamic>.from(datos);
  }

  Future<Map<String, dynamic>> cambiarEstado({
    required String token,
    required String incidenciaId,
    required String solicitudId,
    required String estado,
  }) async {
    final respuesta = await http
        .put(
          Uri.parse(
            '${ConfiguracionApi.urlBase}/api/incidencias/$incidenciaId/'
            'solicitudes-servicio/$solicitudId/estado',
          ),
          headers: _encabezados(token),
          body: jsonEncode({'estado': estado}),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificar(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }

    if (datos is! Map) {
      throw Exception('El servidor no devolvió la solicitud actualizada.');
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