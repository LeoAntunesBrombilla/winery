import 'package:winery_finder/catalog/catalog_sheet.dart';

/// Monta uma planilha CSV de teste com o cabeçalho padrão.
String sheet(List<String> rows) =>
    <String>[CatalogSheet.columns.join(','), ...rows].join('\n');

/// Linha válida; `id` muda para gerar várias vinícolas distintas.
String validRow({
  String id = 'casa-valduga',
  String price = '85,00',
  String reservation = 'sim',
  String weekdays = '09:00-18:00',
}) =>
    '$id,Casa Valduga,Bento Gonçalves,"Via Trento, 2355",-29.1756,-51.5577,'
    'tinto;espumante,$weekdays,$weekdays,$weekdays,$weekdays,$weekdays,'
    '09:00-17:00,fechado,"$price",$reservation,(54) 2105-3122,'
    'https://casavalduga.com.br,4.7,site,20/10/2026';

/// [count] linhas válidas com ids distintos.
List<String> validRows(int count) => <String>[
  for (int i = 1; i <= count; i++) validRow(id: 'vinicola-$i'),
];
