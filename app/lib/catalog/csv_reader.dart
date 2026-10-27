/// Leitor mínimo de CSV (RFC 4180): vírgula como separador, aspas duplas
/// para campos com vírgula, quebra de linha ou aspas (`""` escapa `"`).
abstract final class CsvReader {
  static List<List<String>> parse(String input) {
    final List<List<String>> rows = <List<String>>[];
    List<String> row = <String>[];
    final StringBuffer field = StringBuffer();
    bool quoted = false;

    void endField() {
      row.add(field.toString());
      field.clear();
    }

    void endRow() {
      endField();
      if (row.length > 1 || row.single.trim().isNotEmpty) {
        rows.add(row);
      }
      row = <String>[];
    }

    final String text = input.startsWith('﻿') ? input.substring(1) : input;
    for (int i = 0; i < text.length; i++) {
      final String char = text[i];
      if (quoted) {
        if (char == '"') {
          if (i + 1 < text.length && text[i + 1] == '"') {
            field.write('"');
            i++;
          } else {
            quoted = false;
          }
        } else {
          field.write(char);
        }
      } else if (char == '"') {
        quoted = true;
      } else if (char == ',') {
        endField();
      } else if (char == '\n') {
        endRow();
      } else if (char != '\r') {
        field.write(char);
      }
    }
    if (field.isNotEmpty || row.isNotEmpty) {
      endRow();
    }
    return rows;
  }
}
