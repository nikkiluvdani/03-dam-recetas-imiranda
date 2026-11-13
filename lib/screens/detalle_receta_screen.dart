import 'package:flutter/material.dart';
import 'package:recetasapp/models/receta.dart';
import 'package:recetasapp/models/resena.dart';
import 'package:recetasapp/services/resena_service.dart';

class DetalleRecetaScreen extends StatefulWidget {
  final Receta receta;

  const DetalleRecetaScreen({super.key, required this.receta});

  @override
  State<DetalleRecetaScreen> createState() => _DetalleRecetaScreenState();
}

class _DetalleRecetaScreenState extends State<DetalleRecetaScreen> {
  final ResenaService _resenaService = ResenaService.instance;

  final TextEditingController _nombreController = TextEditingController();

  final TextEditingController _comentarioController = TextEditingController();

  List<Resena> resenas = [];

  int calificacionSeleccionada = 0;

  @override
  void initState() {
    super.initState();
    cargarResenas();
  }

  Future<void> cargarResenas() async {
    final resultado = await _resenaService.obtenerResenas(widget.receta.id);

    if (!mounted) return;

    setState(() {
      resenas = resultado;
    });
  }

  Future<void> guardarResena() async {
    final nombre = _nombreController.text.trim();
    final comentario = _comentarioController.text.trim();

    if (nombre.isEmpty || comentario.isEmpty || calificacionSeleccionada == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    try {
      final nuevaResena = Resena(
        recetaId: widget.receta.id,
        nombre: nombre,
        comentario: comentario,
        calificacion: calificacionSeleccionada,
        fecha: DateTime.now().toIso8601String(),
      );

      // Guardar en SQLite
      await _resenaService.guardarResena(nuevaResena);

      // Consultar nuevamente las reseñas guardadas
      await cargarResenas();

      if (!mounted) return;

      _nombreController.clear();
      _comentarioController.clear();

      setState(() {
        calificacionSeleccionada = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reseña guardada correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      debugPrint('Reseña guardada para receta ID: ${widget.receta.id}');
      debugPrint('Total de reseñas: ${resenas.length}');
    } catch (e) {
      debugPrint('ERROR AL GUARDAR RESEÑA: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget construirEstrellas({
    required int cantidad,
    required bool seleccionable,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final numeroEstrella = index + 1;

        return IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: seleccionable
              ? () {
                  setState(() {
                    calificacionSeleccionada = numeroEstrella;
                  });
                }
              : null,
          icon: Icon(
            numeroEstrella <= cantidad ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 27,
          ),
        );
      }),
    );
  }

  Widget construirFormulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),

        TextField(
          controller: _nombreController,
          decoration: const InputDecoration(
            hintText: 'Tu nombre',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 15),

        TextField(
          controller: _comentarioController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Escribe tu reseña',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            const Text('Calificación:', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            construirEstrellas(
              cantidad: calificacionSeleccionada,
              seleccionable: true,
            ),
          ],
        ),

        const SizedBox(height: 10),

        ElevatedButton.icon(
          onPressed: guardarResena,
          label: const Text('Guardar reseña'),
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color(0xFF66518E),
            backgroundColor: const Color(0xFFF1EDF7),
          ),
        ),
      ],
    );
  }

  Widget construirListaResenas() {
    if (resenas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Text(
          'Todavía no hay reseñas.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: resenas.map((resena) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resena.nombre,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                construirEstrellas(
                  cantidad: resena.calificacion,
                  seleccionable: false,
                ),

                const SizedBox(height: 5),

                Text(resena.comentario, style: const TextStyle(fontSize: 15)),

                const SizedBox(height: 5),

                Text(
                  resena.fecha.substring(0, 10),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receta = widget.receta;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la receta')),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              receta.imagenUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Image.asset(
                'assets/images/plato-placeholder.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            receta.nombre,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            children: [
              Chip(label: Text('${receta.tiempoTotal} min')),
              Chip(label: Text(receta.dificultad)),
              Chip(label: Text(receta.cocina)),
              Chip(label: Text('${receta.calorias} kcal')),
            ],
          ),

          const SizedBox(height: 15),

          const Text(
            'Ingredientes:',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          ...receta.ingredientes.map(
            (ingrediente) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 6,
                    color: Color.fromARGB(255, 238, 189, 218),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ingrediente)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Preparación:',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          ...receta.instrucciones.asMap().entries.map(
            (entrada) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color.fromARGB(255, 234, 202, 193),
                    child: Text(
                      '${entrada.key + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entrada.value)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            'Reseñas',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),

          construirFormulario(),

          const SizedBox(height: 25),

          construirListaResenas(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }
}
