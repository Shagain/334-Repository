/// Minimal KEY=value parser (ASCII-friendly). Avoids flutter_dotenv quirks with
/// Unicode punctuation in comments or odd encodings on web.
Map<String, String> parseDotEnvManual(String raw) {
  final out = <String, String>{};
  for (var line in raw.split(RegExp(r'\r?\n'))) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final eq = line.indexOf('=');
    if (eq <= 0) continue;
    final key = line.substring(0, eq).trim();
    var value = line.substring(eq + 1).trim();
    if (key.isEmpty) continue;
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.substring(1, value.length - 1);
    }
    out[key] = value;
  }
  return out;
}

String normalizeEnvText(String raw) {
  var s = raw;
  if (s.isNotEmpty && s.codeUnitAt(0) == 0xFEFF) {
    s = s.substring(1);
  }
  return s.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
}
