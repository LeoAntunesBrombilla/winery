import 'package:flutter/material.dart';
import 'package:winery_finder/data/url_opener.dart';
import 'package:winery_finder/domain/contact_links.dart';

/// Botões Ligar e Site (US08). Cada botão só aparece quando o dado existe;
/// sem nenhum dos dois, a seção não ocupa espaço.
class ContactSection extends StatelessWidget {
  const ContactSection({
    required this.phone,
    required this.website,
    required this.openUrl,
    super.key,
  });

  final String? phone;
  final String? website;
  final UrlOpener openUrl;

  Future<void> _open(BuildContext context, Uri uri, String failure) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (!await openUrl(uri)) {
      messenger.showSnackBar(SnackBar(content: Text(failure)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Uri? phoneUri = ContactLinks.phone(phone);
    final Uri? siteUri = ContactLinks.website(website);
    if (phoneUri == null && siteUri == null) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        if (phoneUri != null)
          FilledButton.tonalIcon(
            onPressed: () =>
                _open(context, phoneUri, 'Não foi possível abrir o discador.'),
            icon: const Icon(Icons.call),
            label: const Text('Ligar'),
          ),
        if (siteUri != null)
          FilledButton.tonalIcon(
            onPressed: () =>
                _open(context, siteUri, 'Não foi possível abrir o navegador.'),
            icon: const Icon(Icons.language),
            label: const Text('Site'),
          ),
      ],
    );
  }
}
