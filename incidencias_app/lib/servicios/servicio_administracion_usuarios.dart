import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:incidencias_app/configuracion/configuracion_api.dart';

class ServicioAdministracionUsuarios {

  Future<List<Map<String, dynamic>>> listar(String token) async {
    final respuesta = await http
        .get(
          Uri.parse('${ConfiguracionApi.urlBase}/api/usuarios/administracion'),
          headers: _encabezados(token),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificar(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }

    if (datos is! List) {
      throw Exception('El servidor no devolvió una lista de usuarios.');
    }

    return datos
        .map((elemento) => Map<String, dynamic>.from(elemento as Map))
        .toList();
  }

  Future<Map<String, dynamic>> cambiarEstado({
    required String token,
    required String usuarioId,
    required bool activo,
  }) async {
    final respuesta = await http
        .put(
          Uri.parse('${ConfiguracionApi.urlBase}/api/usuarios/$usuarioId/estado'),
          headers: _encabezados(token),
          body: jsonEncode({'activo': activo}),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    return _validarObjeto(respuesta, 'No se pudo cambiar el estado del usuario.');
  }

  Future<Map<String, dynamic>> cambiarRol({
    required String token,
    required String usuarioId,
    required String rol,
  }) async {
    final respuesta = await http
        .put(
          Uri.parse('${ConfiguracionApi.urlBase}/api/usuarios/$usuarioId/rol'),
          headers: _encabezados(token),
          body: jsonEncode({'rol': rol}),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    return _validarObjeto(respuesta, 'No se pudo cambiar el rol del usuario.');
  }

  Map<String, dynamic> _validarObjeto(
    http.Response respuesta,
    String mensajePredeterminado,
  ) {
    final datos = _decodificar(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(
        _mensajeError(datos, respuesta.statusCode, mensajePredeterminado),
      );
    }

    if (datos is! Map) {
      throw Exception('El servidor no devolvió el usuario actualizado.');
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

  String _mensajeError(
    dynamic datos,
    int codigo, [
    String? predeterminado,
  ]) {
    if (datos is Map) {
      return (datos['message'] ??
              datos['mensaje'] ??
              predeterminado ??
              'Error del servidor (HTTP $codigo).')
          .toString();
    }

    return predeterminado ?? 'Error del servidor (HTTP $codigo).';
  }
}