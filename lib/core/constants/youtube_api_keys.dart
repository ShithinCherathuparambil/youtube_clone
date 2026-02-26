import 'package:flutter_dotenv/flutter_dotenv.dart';

class YouTubeApiKeys {
  static String get apiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';
}
