import 'package:flutter/material.dart';

/// Bottom sheet cuyo contenido siempre puede scrollear y nunca se desborda
/// de la pantalla — sin importar cuántos ítems tenga ni el tamaño/orientación
/// de la pantalla (celular en horizontal, tablet, web). Reemplaza el uso
/// directo de `showModalBottomSheet` en toda la app.
Future<T?> mostrarHojaInferior<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
        child: SingleChildScrollView(child: builder(ctx)),
      ),
    ),
  );
}