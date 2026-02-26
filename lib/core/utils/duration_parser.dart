class DurationParser {
  /// Parses ISO 8601 duration string (e.g., PT15M33S or PT1H2M3S) into a [Duration].
  static Duration parseDuration(String input) {
    if (!RegExp(r'^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$').hasMatch(input)) {
      return Duration.zero;
    }

    final match = RegExp(
      r'^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$',
    ).firstMatch(input);

    if (match == null) return Duration.zero;

    final hours = match.group(1) != null ? int.parse(match.group(1)!) : 0;
    final minutes = match.group(2) != null ? int.parse(match.group(2)!) : 0;
    final seconds = match.group(3) != null ? int.parse(match.group(3)!) : 0;

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }
}
