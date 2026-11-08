import 'package:flutter/material.dart';
import 'package:winery_finder/widgets/winery_logo.dart';

/// Diálogo de Ajuda e Tutorial Passo a Passo com ilustrações e orientações detalhadas de uso do sistema.
class HelpTutorialDialog extends StatefulWidget {
  const HelpTutorialDialog({super.key});

  @override
  State<HelpTutorialDialog> createState() => _HelpTutorialDialogState();
}

class _HelpTutorialDialogState extends State<HelpTutorialDialog> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': '1. Perfis de Usuário & Autenticação',
      'icon': Icons.badge_outlined,
      'image': 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      'description':
          'O sistema possui 3 perfis de usuário:\n\n'
          '• Admirador de Vinhos: Explora vinícolas, traça rotas e compra vinhos.\n'
          '• Sommelier Profissional: Mantém formação/certificações (WSET, ABS) e publica no Blog Coletivo.\n'
          '• Vinícola / Produtor: Cadastra sua vinícola e gerencia vinhos à venda com link direct.\n\n'
          '💡 Esqueceu a senha? Na tela de login, clique em "Esqueceu a senha?" para redefinir via e-mail!',
    },
    {
      'title': '2. Mapa Interativo & Filtros por Vinho',
      'icon': Icons.map_outlined,
      'image': 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      'description':
          'No Mapa Interativo (OpenStreetMap):\n\n'
          '• Pesquise vinícolas ou cidades na barra de busca superior.\n'
          '• Filtre por tipos de vinho (Tinto, Branco, Espumante, Rosé).\n'
          '• Toque no ícone de Coração em qualquer vinícola para salvá-la nos seus Favoritos!',
    },
    {
      'title': '3. Trajeto Real pelas Ruas & Google Maps GPS',
      'icon': Icons.alt_route_outlined,
      'image': 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      'description':
          'Para traçar a rota até a vinícola:\n\n'
          '• Clique no botão "Trajeto Real no Mapa" ao lado da vinícola.\n'
          '• O aplicativo geolocaliza seu endereço cadastrado e desenha o trajeto curvo pelas ruas destacados em dourado e vinho.\n'
          '• Clique no botão "Seguir Rota com GPS" para abrir a navegação por voz no Google Maps!',
    },
    {
      'title': '4. Cadastro de Vinícolas & Venda de Vinhos',
      'icon': Icons.storefront_outlined,
      'image': 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      'description':
          'Para produtores de vinícolas:\n\n'
          '• No formulário de cadastro, envie o Logo da Vinícola (em 1º lugar) e o Nome do Proprietário (em 2º lugar).\n'
          '• Acesse o "Painel de Produtos" da sua vinícola para postar vinhos, alterar preços, ativar/inativar ou inserir o link de pagamento direct (MercadoPago/WhatsApp).',
    },
    {
      'title': '5. Blog Coletivo & Diretório de Sommeliers',
      'icon': Icons.article_outlined,
      'image': 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      'description':
          'Acesse as abas do menu inferior:\n\n'
          '• Blog Coletivo: Matérias sobre harmonizações e degustação escritas por Sommeliers. Todos os usuários podem comentar!\n'
          '• Sommeliers: Consulte os perfis profissionais, currículo e contatos dos Sommeliers certificados.',
    },
    {
      'title': '6. Painel do Administrador Master',
      'icon': Icons.admin_panel_settings_outlined,
      'image': 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      'description':
          'Exclusivo para o e-mail admin@winery.com:\n\n'
          '• Permite editar dados de qualquer usuário cadastrado.\n'
          '• Permite Bloquear / Desbloquear usuários ou excluir contas.\n'
          '• Moderar e excluir postagens e comentários no Blog Coletivo.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = _steps[_currentStep];

    return AlertDialog(
      title: Row(
        children: [
          const WineryLogo(size: 36),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Guia de Uso & Tutorial Passo a Passo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem ilustrativa do passo
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  step['image'] as String,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 140,
                    color: theme.colorScheme.primaryContainer,
                    child: Icon(step['icon'] as IconData, size: 48, color: theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(step['icon'] as IconData, color: const Color(0xFF722F37), size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step['title'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Text(
                step['description'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 16),
              // Indicador de Passos (Dots)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (idx) {
                  final isActive = idx == _currentStep;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF722F37) : Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (_currentStep > 0)
          TextButton(
            onPressed: () => setState(() => _currentStep--),
            child: const Text('Anterior'),
          ),
        if (_currentStep < _steps.length - 1)
          FilledButton(
            onPressed: () => setState(() => _currentStep++),
            child: const Text('Próximo Passo'),
          )
        else
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi! Fechar Tutorial'),
          ),
      ],
    );
  }
}
