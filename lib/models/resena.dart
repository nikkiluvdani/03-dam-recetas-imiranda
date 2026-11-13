

class Resena {
  final int? id;
  final int recetaId;
  final String nombre;
  final String comentario;
  final int calificacion;
  final String fecha;

  Resena({
    this.id,
    required this.recetaId,
    required this.nombre,
    required this.comentario,
    required this.calificacion,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'recetaId': recetaId,
      'nombre': nombre,
      'comentario': comentario,
      'calificacion': calificacion,
      'fecha': fecha,
    };
  }

  factory Resena.fromMap(Map<String, dynamic> map) {
    return Resena(
      id: map['id'] as int,
      recetaId: map['recetaId'] as int,
      nombre: map['nombre'] as String,
      comentario: map['comentario'] as String,
      calificacion: map['calificacion'] as int,
      fecha: map['fecha'] as String,
    );
  }
}