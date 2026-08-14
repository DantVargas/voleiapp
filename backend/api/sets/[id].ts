import type { VercelRequest, VercelResponse } from '@vercel/node';
import { prisma } from '../../lib/prisma';
import { serializeSet } from '../../lib/serialize';
import { withCors } from '../../lib/cors';

// PATCH /api/sets/:id -> editar el resultado de un set (_editarSet)
export default withCors(async function handler(req: VercelRequest, res: VercelResponse) {
  const id = Number(req.query.id);
  if (!Number.isInteger(id)) return res.status(400).json({ error: 'id inválido' });

  if (req.method === 'PATCH') {
    const body = req.body ?? {};
    const data: Record<string, unknown> = {};
    if (body.puntos_a !== undefined) data.puntosA = body.puntos_a;
    if (body.puntos_b !== undefined) data.puntosB = body.puntos_b;

    const actualizado = await prisma.setPartido.update({ where: { id }, data });
    return res.status(200).json(serializeSet(actualizado));
  }

  res.setHeader('Allow', 'PATCH');
  return res.status(405).json({ error: 'Método no permitido' });
});
