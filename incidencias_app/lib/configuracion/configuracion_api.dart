/// Configuración central de la conexión con el backend.
///
/// La URL se puede cambiar al compilar sin tocar el código:
///   flutter run --dart-define=API_URL=https://mi-api.onrender.com
class ConfiguracionApi {
  ConfiguracionApi._();

  static const String urlBase = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const Duration tiempoEspera = Duration(seconds: 60);
}
