import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'provider/partido_provider.dart';
import 'provider/ajustes_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PartidoProvider()),
          ChangeNotifierProvider(create: (_) => AjustesProvider()),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MainNavigationScreen(),
        ),
      ),
    );
  });
}
