extension ImagePathExtension on String {
  String get images => 'assets/images/$this';
  String get webpImages => 'assets/images/$this.webp';
  String get pngImages => 'assets/images/$this.png';
}
