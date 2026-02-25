import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'injection_container.dart' as di;
import 'presentation/app/youtube_clone_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await di.init();
  runApp(const YoutubeCloneApp());
}
