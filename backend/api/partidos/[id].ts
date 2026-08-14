import type { VercelRequest, VercelResponse } from '@vercel/node';
import { prisma } from '../../lib/prisma';
import { serializePartido, serializeSet, serializeEstadistica } from '../../lib/serialize';
import { withCors } from '../../lib/cors';

// GET    /api/partidos/:id -> detalle completo (partido + sets + estadísticas
//                              anidados) para PartidoDetalleScreen
// PATCH  /api/partidos/:id -> editar nombre/notas/estado (_editarCabecera)
// DELETE /api/partidos/:id -> eliminar (HistorialScreen)
export default withCors(async function handler(req: VercelRequest, res: VercelResponse) {
  const id = Number(req.query.id);
  if (!Number.isInteger(id)) return res.status(400).json({ error: 'id inválido' });

  if (req.method === 'GET') {
    const partido = await prisma.partido.findUnique({ where: { id } });
    if (!partido) return res.status(404).json({ error: 'No encontrado' });

    const [sets, estadisticas] = await Promise.all([
      prisma.setPartido.findMany({ where: { partidoId: id }, orderBy: { numeroSet: 'asc' } }),
      prisma.estadistica.findMany({
        where: { partidoId: id },
        orderBy: [{ equipoId: 'asc' }, { jugadorNombre: 'asc' }],
      }),
    ]);

    return res.status(200).json({
      ...serializePartido(partido),
      sets: sets.map(serializeSet),
      estadisticas: estadisticas.map(serializeEstadistica),
    });
  }

  if (req.method === 'PATCH') {
    const body = req.body ?? {};
    const data: Record<string, unknown> = {};
    if (body.nombre_equipo_a !== undefined) data.nombreEquipoA = body.nombre_equipo_a;
    if (body.nombre_equipo_b !== undefined) data.nombreEquipoB = body.nombre_equipo_b;
    if (body.notas !== undefined) data.notas = body.notas;
    if (body.sets_a !== undefined) data.setsA = body.sets_a;
    if (body.sets_b !== undefined) data.setsB = body.sets_b;
    if (body.estado !== undefined) data.estado = body.estado;

    const actualizado = await prisma.partido.update({ where: { id }, data });
    return res.status(200).json(serializePartido(actualizado));
  }

  if (req.method === 'DELETE') {
    await prisma.partido.delete({ where: { id } });
    return res.status(204).end();
  }

  res.setHeader('Allow', 'GET, PATCH, DELETE');
  return res.status(405).json({ error: 'Método no permitido' });
});
