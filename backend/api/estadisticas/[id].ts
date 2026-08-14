import type { VercelRequest, VercelResponse } from '@vercel/node';
import { prisma } from '../../lib/prisma';
import { serializeEstadistica } from '../../lib/serialize';
import { withCors } from '../../lib/cors';

// PATCH  /api/estadisticas/:id -> editar contadores de un jugador (_editarStats)
// DELETE /api/estadisticas/:id -> quitar un jugador del historial (_editarStats)
export default withCors(async function handler(req: VercelRequest, res: VercelResponse) {
  const id = Number(req.query.id);
  if (!Number.isInteger(id)) return res.status(400).json({ error: 'id inválido' });

  if (req.method === 'PATCH') {
    const body = req.body ?? {};
    const campoMap: Record<string, string> = {
      aces: 'aces',
      errores_saque: 'erroresSaque',
      ataques: 'ataques',
      errores_ataque: 'erroresAtaque',
      bloqueos: 'bloqueos',
      recepciones: 'recepciones',
      errores_recepcion: 'erroresRecepcion',
    };
    const data: Record<string, unknown> = {};
    for (const [key, prismaField] of Object.entries(campoMap)) {
      if (body[key] !== undefined) data[prismaField] = body[key];
    }

    const actualizada = await prisma.estadistica.update({ where: { id }, data });
    return res.status(200).json(serializeEstadistica(actualizada));
  }

  if (req.method === 'DELETE') {
    await prisma.estadistica.delete({ where: { id } });
    return res.status(204).end();
  }

  res.setHeader('Allow', 'PATCH, DELETE');
  return res.status(405).json({ error: 'Método no permitido' });
});
