/// URL base del backend (Node + Prisma en Vercel). Se pisa en build/run time
/// con `--dart-define=API_BASE_URL=https://tu-app.vercel.app`, así el mismo
/// código sirve para desarrollo local y producción, en web y celular.
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);
