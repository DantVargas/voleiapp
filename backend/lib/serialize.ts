import type { Partido, SetPartido, Estadistica, PuntoPro } from '@prisma/client';

// Convierte los objetos camelCase de Prisma al JSON snake_case que ya
// esperan los modelos Dart (fromMap/toMap en lib/models/*.dart), para no
// tener que tocar esos modelos.

export function serializePartido(p: Partido) {
  return {
    id: p.id,
    nombre_equipo_a: p.nombreEquipoA,
    nombre_equipo_b: p.nombreEquipoB,
    fecha: p.fecha.toISOString(),
    sets_a: p.setsA,
    sets_b: p.setsB,
    estado: p.estado,
    notas: p.notas,
  };
}

export function serializeSet(s: SetPartido) {
  return {
    id: s.id,
    partido_id: s.partidoId,
    numero_set: s.numeroSet,
    puntos_a: s.puntosA,
    puntos_b: s.puntosB,
  };
}

export function serializeEstadistica(e: Estadistica) {
  return {
    id: e.id,
    partido_id: e.partidoId,
    jugador_nombre: e.jugadorNombre,
    dorsal: e.dorsal,
    equipo_id: e.equipoId,
    aces: e.aces,
    errores_saque: e.erroresSaque,
    ataques: e.ataques,
    errores_ataque: e.erroresAtaque,
    bloqueos: e.bloqueos,
    recepciones: e.recepciones,
    errores_recepcion: e.erroresRecepcion,
  };
}

export function serializePunto(p: PuntoPro) {
  return {
    id: p.id,
    partido_id: p.partidoId,
    numero_set: p.numeroSet,
    equipo_id: p.equipoId,
    tipo: p.tipo,
    jugador_dorsal: p.jugadorDorsal,
    jugador_nombre: p.jugadorNombre,
    jugador_equipo_id: p.jugadorEquipoId,
    complejo: p.complejo,
    marcador: p.marcador,
  };
}
