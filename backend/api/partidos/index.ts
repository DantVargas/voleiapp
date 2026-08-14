import type { VercelRequest, VercelResponse } from '@vercel/node';
import { prisma } from '../../lib/prisma';
import { serializePartido } from '../../lib/serialize';
import { withCors } from '../../lib/cors';

// GET  /api/partidos  -> historial (HistorialScreen)
// POST /api/partidos  -> guarda un partido completo en una sola transacción
//                        (reemplaza la secuencia de PartidoProvider.guardarPartido)
export default withCors(async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method === 'GET') {
    const partidos = await prisma.partido.findMany({ orderBy: { fecha: 'desc' } });
    return res.status(200).json(partidos.map(serializePartido));
  }

  if (req.method === 'POST') {
    const body = req.body ?? {};
    const {
      nombre_equipo_a,
      nombre_equipo_b,
      notas,
      sets_a = 0,
      sets_b = 0,
      sets = [],
      puntos = [],
      estadisticas = [],
    } = body;

    if (!nombre_equipo_a || !nombre_equipo_b) {
      return res.status(400).json({ error: 'nombre_equipo_a y nombre_equipo_b son requeridos' });
    }

    const partido = await prisma.$transaction(async (tx) => {
      const creado = await tx.partido.create({
        data: {
          nombreEquipoA: nombre_equipo_a,
          nombreEquipoB: nombre_equipo_b,
          notas: notas || null,
          setsA: sets_a,
          setsB: sets_b,
          estado: 'finalizado',
        },
      });

      if (sets.length) {
        await tx.setPartido.createMany({
          data: sets.map((s: any) => ({
            partidoId: creado.id,
            numeroSet: s.numero_set,
            puntosA: s.puntos_a,
            puntosB: s.puntos_b,
          })),
        });
      }

      if (puntos.length) {
        await tx.puntoPro.createMany({
          data: puntos.map((p: any) => ({
            partidoId: creado.id,
            numeroSet: p.numero_set,
            equipoId: p.equipo_id,
            tipo: p.tipo,
            jugadorDorsal: p.jugador_dorsal ?? null,
            jugadorNombre: p.jugador_nombre ?? null,
            jugadorEquipoId: p.jugador_equipo_id ?? null,
            complejo: p.complejo ?? null,
            marcador: p.marcador,
          })),
        });
      }

      if (estadisticas.length) {
        await tx.estadistica.createMany({
          data: estadisticas.map((e: any) => ({
            partidoId: creado.id,
            jugadorNombre: e.jugador_nombre,
            dorsal: e.dorsal ?? 0,
            equipoId: e.equipo_id,
            aces: e.aces ?? 0,
            erroresSaque: e.errores_saque ?? 0,
            ataques: e.ataques ?? 0,
            erroresAtaque: e.errores_ataque ?? 0,
            bloqueos: e.bloqueos ?? 0,
            recepciones: e.recepciones ?? 0,
            erroresRecepcion: e.errores_recepcion ?? 0,
          })),
        });
      }

      return creado;
    });

    return res.status(201).json(serializePartido(partido));
  }

  res.setHeader('Allow', 'GET, POST');
  return res.status(405).json({ error: 'Método no permitido' });
});
