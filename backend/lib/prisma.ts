import { PrismaClient } from '@prisma/client';

// Reutiliza la instancia entre invocaciones serverless (y en `vercel dev`,
// que recarga módulos) para no agotar el pool de conexiones a Postgres.
const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const prisma = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}
