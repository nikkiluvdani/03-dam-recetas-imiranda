
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/receta.dart';

class RecipeService {
  static const String _baseUrl =
      'https://dummyjson.com/recipes';

  Future<List<Receta>> obtenerRecetas() async {
    try {
      final Uri url = Uri.parse(_baseUrl);

      final respuesta = await http.get(url);

      print('ESTADO HTTP: ${respuesta.statusCode}');
      print('RESPUESTA API: ${respuesta.body}');

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);

        final List<dynamic> listaRecetas = datos['recipes'];

        return listaRecetas
            .map((json) => Receta.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Error HTTP: ${respuesta.statusCode}',
        );
      }
    } catch (e) {
      print('ERROR COMPLETO: $e');
      rethrow;
    }
  }
}
