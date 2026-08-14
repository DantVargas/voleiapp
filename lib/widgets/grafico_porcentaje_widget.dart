import 'package:flutter/material.dart';

class SegmentoGrafico {
  final String label;
  final int valor;
  final Color color;
  const SegmentoGrafico({required this.label, required this.valor, required this.color});
}

/// Barra apilada al 100% + leyenda con porcentajes directos.
/// Forma recomendada para "parte de un todo" con pocas categorías con nombre.
class GraficoPorcentaje extends StatelessWidget {
  final List<SegmentoGrafico> segmentos;
  final String? textoVacio;

  const GraficoPorcentaje({super.key, required this.segmentos, this.textoVacio});

  @override
  Widget build(BuildContext context) {
    final visibles = segmentos.where((s) => s.valor > 0).toList();
    final total = visibles.fold<int>(0, (s, e) => s + e.valor);

    if (total == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          textoVacio ?? "Sin datos todavía",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 18,
            child: Row(
              children: [
                for (int i = 0; i < visibles.length; i++) ...[
                  if (i > 0) Container(width: 2, color: Colors.white),
                  Expanded(
                    flex: visibles[i].valor,
                    child: Container(color: visibles[i].color),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: visibles.map((s) {
            final pct = (s.valor / total * 100).round();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(
                  "${s.label}  $pct%",
                  style: const TextStyle(fontSize: 11, color: Color(0xFF52514E), fontWeight: FontWeight.w600),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
