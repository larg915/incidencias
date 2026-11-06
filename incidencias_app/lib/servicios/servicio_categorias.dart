import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:incidencias_app/configuracion/configuracion_api.dart';

class ServicioCategorias {

  Future<List<Map<String, dynamic>>> listar(String token) async {
    final respuesta = await http
        .get(
          Uri.parse('${ConfiguracionApi.urlBase}/api/categorias'),
          headers: _encabezados(token),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificar(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }

    if (datos is! List) {
      throw Exception('El servidor no devolvió una lista de categorías.');
    }

    return datos
        .map((elemento) => Map<String, dynamic>.from(elemento as Map))
        .toList();
  }

  Future<Map<String, dynamic>> crear({
    required String token,
    required String nombre,
    required String descripcion,
  }) async {
    final respuesta = await http
        .post(
          Uri.parse('${ConfiguracionApi.urlBase}/api/categorias'),
          headers: _encabezados(token),
          body: jsonEncode({
            'nombre': nombre,
            'descripcion': descripcion,
          }),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificar(respuesta);

    if (respuesta.statusCode != 201 && respuesta.statusCode != 200) {
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }

    if (datos is! Map) {
      throw Exception('El servidor no devolvió la categoría creada.');
    }

    return Map<String, dynamic>.from(datos);
  }

  Future<Map<String, dynamic>> actualizar({
    required String token,
    required String categoriaId,
    required String nombre,
    required String descripcion,
  }) async {
    final respuesta = await http
        .put(
          Uri.parse('${ConfiguracionApi.urlBase}/api/categorias/$categoriaId'),
          headers: _encabezados(token),
          body: jsonEncode({
            'nombre': nombre,
            'descripcion': descripcion,
          }),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificar(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }

    if (datos is! Map) {
      throw Exception('El servidor no devolvió la categoría actualizada.');
    }

    return Map<String, dynamic>.from(datos);
  }

  Future<void> desactivar({
    required String token,
    required String categoriaId,
  }) async {
    final respuesta = await http
        .delete(
          Uri.parse('${ConfiguracionApi.urlBase}/api/categorias/$categoriaId'),
          headers: _encabezados(token),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    if (respuesta.statusCode != 204 && respuesta.statusCode != 200) {
      final datos = _decodificar(respuesta);
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }
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