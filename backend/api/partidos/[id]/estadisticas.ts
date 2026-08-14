import type { VercelRequest, VercelResponse } from '@vercel/node';
import { prisma } from '../../../lib/prisma';
import { serializeEstadistica } from '../../../lib/serialize';
import { withCors } from '../../../lib/cors';

// POST /api/partidos/:id/estadisticas -> agrega un jugador al historial
// de un partido guardado (PartidoDetalleScreen._agregarJugador)
export default withCors(async function handler(req: VercelRequest, res: VercelResponse) {
  const partidoId = Number(req.query.id);
  if (!Number.isInteger(partidoId)) return res.status(400).json({ error: 'id inválido' });

  if (req.method === 'POST') {
    const body = req.body ?? {};
    if (!body.jugador_nombre || body.equipo_id === undefined) {
      return res.status(400).json({ error: 'jugador_nombre y equipo_id son requeridos' });
    }

    const creada = await prisma.estadistica.create({
      data: {
        partidoId,
        jugadorNombre: body.jugador_nombre,
        dorsal: body.dorsal ?? 0,
        equipoId: body.equipo_id,
        aces: body.aces ?? 0,
        erroresSaque: body.errores_saque ?? 0,
        ataques: body.ataques ?? 0,
        erroresAtaque: body.errores_ataque ?? 0,
        bloqueos: body.bloqueos ?? 0,
        recepciones: body.recepciones ?? 0,
        erroresRecepcion: body.errores_recepcion ?? 0,
      },
    });
    return res.status(201).json(serializeEstadistica(creada));
  }

  res.setHeader('Allow', 'POST');
  return res.status(405).json({ error: 'Método no permitido' });
});
