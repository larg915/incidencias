import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:incidencias_app/configuracion/configuracion_api.dart';

class ServicioIncidencias {

  Future<List<Map<String, dynamic>>> listarPropias(String token) async {
    final respuesta = await http
        .get(
          Uri.parse('${ConfiguracionApi.urlBase}/api/incidencias'),
          headers: _encabezados(token),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificarRespuesta(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }

    return _convertirLista(
      datos,
      'El servidor no devolvió una lista de incidencias.',
    );
  }

  Future<List<Map<String, dynamic>>> listarAdministracion(
    String token, {
    String? estado,
    String? categoriaId,
  }) async {
    final parametros = <String, String>{};

    if (estado != null && estado.isNotEmpty) {
      parametros['estado'] = estado;
    }
    if (categoriaId != null && categoriaId.isNotEmpty) {
      parametros['categoriaId'] = categoriaId;
    }

    final uriBase = Uri.parse('${ConfiguracionApi.urlBase}/api/incidencias/administracion');
    final uri = parametros.isEmpty
        ? uriBase
        : uriBase.replace(queryParameters: parametros);

    final respuesta = await http
        .get(
          uri,
          headers: _encabezados(token),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificarRespuesta(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }

    return _convertirLista(
      datos,
      'El servidor no devolvió la lista administrativa de incidencias.',
    );
  }

  Future<Map<String, dynamic>> cambiarEstado({
    required String token,
    required String incidenciaId,
    required String estado,
  }) async {
    final respuesta = await http
        .put(
          Uri.parse('${ConfiguracionApi.urlBase}/api/incidencias/$incidenciaId/estado'),
          headers: _encabezados(token),
          body: jsonEncode({'estado': estado}),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificarRespuesta(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }

    if (datos is! Map) {
      throw Exception('El servidor no devolvió la incidencia actualizada.');
    }

    return Map<String, dynamic>.from(datos);
  }

  Future<Map<String, dynamic>> buscarDetalle({
    required String token,
    required String incidenciaId,
  }) async {
    final respuesta = await http
        .get(
          Uri.parse('${ConfiguracionApi.urlBase}/api/incidencias/$incidenciaId'),
          headers: _encabezados(token),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificarRespuesta(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }

    if (datos is! Map) {
      throw Exception('El servidor no devolvió el detalle de la incidencia.');
    }

    return Map<String, dynamic>.from(datos);
  }

  Future<List<Map<String, dynamic>>> listarCategorias(String token) async {
    final respuesta = await http
        .get(
          Uri.parse('${ConfiguracionApi.urlBase}/api/categorias'),
          headers: _encabezados(token),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificarRespuesta(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }

    return _convertirLista(
      datos,
      'El servidor no devolvió una lista de categorías.',
    ).where((categoria) => categoria['activa'] != false).toList();
  }

  Future<Map<String, dynamic>> crearIncidencia({
    required String token,
    required String categoriaId,
    required String titulo,
    required String descripcion,
    required String ubicacion,
  }) async {
    final respuesta = await http
        .post(
          Uri.parse('${ConfiguracionApi.urlBase}/api/incidencias'),
          headers: _encabezados(token),
          body: jsonEncode({
            'categoriaId': categoriaId,
            'titulo': titulo,
            'descripcion': descripcion,
            'ubicacion': ubicacion,
          }),
        )
        .timeout(ConfiguracionApi.tiempoEspera);

    final datos = _decodificarRespuesta(respuesta);

    if (respuesta.statusCode != 201 && respuesta.statusCode != 200) {
      throw Exception(_mensajeError(datos, respuesta.statusCode));
    }

    if (datos is! Map) {
      throw Exception('El servidor no devolvió la incidencia creada.');
    }

    return Map<String, dynamic>.from(datos);
  }

  List<Map<String, dynamic>> _convertirLista(
    dynamic datos,
    String mensaje,
  ) {
    if (datos is! List) {
      throw Exception(mensaje);
    }

    return datos
        .map((elemento) => Map<String, dynamic>.from(elemento as Map))
        .toList();
  }

  Map<String, String> _encabezados(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  dynamic _decodificarRespuesta(http.Response respuesta) {
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