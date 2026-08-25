import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/ajustes_provider.dart';

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
    final escala = context.watch<AjustesProvider>().escalaUI;
    final visibles = segmentos.where((s) => s.valor > 0).toList();
    final total = visibles.fold<int>(0, (s, e) => s + e.valor);

    if (total == 0) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6 * escala),
        child: Text(
          textoVacio ?? "Sin datos todavía",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12 * escala),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 18 * escala,
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
        SizedBox(height: 10 * escala),
        Wrap(
          spacing: 14 * escala,
          runSpacing: 6 * escala,
          children: visibles.map((s) {
            final pct = (s.valor / total * 100).round();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10 * escala,
                  height: 10 * escala,
                  decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                ),
                SizedBox(width: 5 * escala),
                Text(
                  "${s.label}  $pct%",
                  style: TextStyle(fontSize: 11 * escala, color: const Color(0xFF52514E), fontWeight: FontWeight.w600),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}