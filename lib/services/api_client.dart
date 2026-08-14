import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

/// Cliente HTTP del backend (Node + Prisma en Vercel). Reemplaza a
/// `DBManager`: antes cada partido se guardaba con ~10-30 llamadas
/// secuenciales a SQLite; acá se junta todo en pocas llamadas de red,
/// una de ellas transaccional en el servidor (ver backend/api/partidos).
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const _headers = {'Content-Type': 'application/json'};

  Uri _uri(String path) => Uri.parse('$kApiBaseUrl$path');

  void _verificar(http.Response res, int esperado) {
    if (res.statusCode != esperado) {
      throw Exception('Error de red (${res.statusCode}): ${res.body}');
    }
  }

  // -------------------------------------------------------
  // PARTIDOS
  // -------------------------------------------------------

  /// Guarda el partido completo (equipos, notas, sets, puntos detallados de
  /// Modo Pro y estadísticas por jugador) en una sola llamada. Devuelve el
  /// id del partido creado.
  Future<int> guardarPartido({
    required String nombreEquipoA,
    required String nombreEquipoB,
    String notas = '',
    required int setsA,
    required int setsB,
    required List<Map<String, dynamic>> sets,
    required List<Map<String, dynamic>> puntos,
    required List<Map<String, dynamic>> estadisticas,
  }) async {
    final res = await http.post(
      _uri('/api/partidos'),
      headers: _headers,
      body: jsonEncode({
        'nombre_equipo_a': nombreEquipoA,
        'nombre_equipo_b': nombreEquipoB,
        'notas': notas.isNotEmpty ? notas : null,
        'sets_a': setsA,
        'sets_b': setsB,
        'sets': sets,
        'puntos': puntos,
        'estadisticas': estadisticas,
      }),
    );
    _verificar(res, 201);
    return (jsonDecode(res.body) as Map<String, dynamic>)['id'] as int;
  }

  Future<List<Map<String, dynamic>>> obtenerPartidos() async {
    final res = await http.get(_uri('/api/partidos'));
    _verificar(res, 200);
    return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
  }

  /// Detalle completo de un partido guardado: datos básicos + `sets` +
  /// `estadisticas` anidados en la misma respuesta (evita 3 llamadas).
  Future<Map<String, dynamic>?> obtenerPartidoDetalle(int id) async {
    final res = await http.get(_uri('/api/partidos/$id'));
    if (res.statusCode == 404) return null;
    _verificar(res, 200);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> actualizarPartido(int id, Map<String, dynamic> data) async {
    final res = await http.patch(_uri('/api/partidos/$id'), headers: _headers, body: jsonEncode(data));
    _verificar(res, 200);
  }

  Future<void> eliminarPartido(int id) async {
    final res = await http.delete(_uri('/api/partidos/$id'));
    _verificar(res, 204);
  }

  // -------------------------------------------------------
  // SETS
  // -------------------------------------------------------

  Future<void> actualizarPuntosSet(int setId, int puntosA, int puntosB) async {
    final res = await http.patch(
      _uri('/api/sets/$setId'),
      headers: _headers,
      body: jsonEncode({'puntos_a': puntosA, 'puntos_b': puntosB}),
    );
    _verificar(res, 200);
  }

  // -------------------------------------------------------
  // ESTADÍSTICAS
  // -------------------------------------------------------

  Future<void> agregarEstadistica(int partidoId, Map<String, dynamic> row) async {
    final res = await http.post(
      _uri('/api/partidos/$partidoId/estadisticas'),
      headers: _headers,
      body: jsonEncode(row),
    );
    _verificar(res, 201);
  }

  Future<void> actualizarEstadistica(int id, Map<String, dynamic> data) async {
    final res = await http.patch(_uri('/api/estadisticas/$id'), headers: _headers, body: jsonEncode(data));
    _verificar(res, 200);
  }

  Future<void> eliminarEstadistica(int id) async {
    final res = await http.delete(_uri('/api/estadisticas/$id'));
    _verificar(res, 204);
  }
}
