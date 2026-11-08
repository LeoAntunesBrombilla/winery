import 'package:flutter/material.dart';
import 'package:winery_finder/widgets/winery_logo.dart';

/// Diálogo de Ajuda e Tutorial Passo a Passo com orientações enriquecidas e detalhadas de uso do sistema.
class HelpTutorialDialog extends StatefulWidget {
  const HelpTutorialDialog({super.key});

  @override
  State<HelpTutorialDialog> createState() => _HelpTutorialDialogState();
}

class _HelpTutorialDialogState extends State<HelpTutorialDialog> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': '1. Cadastro de Conta & Escolha de Perfil',
      'icon': Icons.badge_outlined,
      'image': 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      'subtitle': 'Acesso personalizado para Admiradores, Sommeliers e Vinícolas',
      'description':
          '• Cadastro com Foto: Na tela de cadastro, envie sua foto de perfil pessoal.\n'
          '• Escolha de Perfil:\n'
          '   🍷 Admirador de Vinhos: Explora vinícolas, faz compras direct e salva favoritos.\n'
          '   🎓 Sommelier Profissional: Cadastra formação/certificações (WSET, ABS) e publica matérias no Blog Coletivo.\n'
          '   🏢 Vinícola / Produtor: Cadastra a vinícola e gerencia vinhos e preços à venda.\n\n'
          '🔑 Esqueceu a Senha? Na tela de login, clique em "Esqueceu a senha?" para receber o link de redefinição por e-mail e cadastrar uma nova senha imediatamente.',
    },
    {
      'title': '2. Explorando o Mapa Interativo & Filtros',
      'icon': Icons.map_outlined,
      'image': 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      'subtitle': 'Busca por cidade, tipo de vinho e favoritos independentes',
      'description':
          '• Mapa Desobstruído: O mapa fica no topo da tela (nunca coberto por popups) para você visualizar a região.\n'
          '• Busca & Filtros: Digite o nome da vinícola ou cidade e selecione os chips de tipo de vinho (Tinto, Branco, Espumante, Rosé).\n'
          '• Favoritos com Um Toque: Clique no ícone de Coração em qualquer vinícola. Seus favoritos são salvos de forma 100% independente na sua conta de usuário.',
    },
    {
      'title': '3. Trajeto Real pelas Ruas & GPS no Google Maps',
      'icon': Icons.alt_route_outlined,
      'image': 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      'subtitle': 'Mapeamento automático pelas ruas do seu endereço e navegação GPS',
      'description':
          '• Mapeamento de Rota em 0ms: Clique no botão "Trajeto Real no Mapa" ao lado da vinícola.\n'
          '• Origem pelo Seu Endereço: O aplicativo geolocaliza o seu endereço cadastrado no perfil e traça a linha curva real pelas ruas e rodovias.\n'
          '• Passo a Passo das Vias: O painel abaixo do mapa lista o nome de cada rua, avenida e rodovia do itinerário.\n'
          '• Seguir no Google Maps: Clique no botão "Seguir Rota com GPS" para abrir a navegação por voz no Google Maps.',
    },
    {
      'title': '4. Cadastro de Vinícolas & Gestão de Vinhos',
      'icon': Icons.storefront_outlined,
      'image': 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      'subtitle': 'Publicação de produtos, preços e links de pagamento direct',
      'description':
          '• Formulário Organizado: Envie o Logo da Vinícola (em 1º lugar) e o Nome do Proprietário/Responsável (em 2º lugar).\n'
          '• Informações Completas: Informe cidade, endereço, sommelier, uvas cultivadas e galeria de fotos.\n'
          '• Painel de Produtos: A vinícola criadora pode cadastrar vinhos, alterar preços, fotos, inativar/ativar itens e disponibilizar o link de pagamento direct (MercadoPago/WhatsApp).',
    },
    {
      'title': '5. Blog Coletivo & Diretório de Sommeliers',
      'icon': Icons.article_outlined,
      'image': 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      'subtitle': 'Espaço de conteúdo, harmonização e consulta profissional',
      'description':
          '• Blog Coletivo: Sommeliers publicam avaliações de safras, notas de degustação e dicas de harmonização. Admiradores e Vinícolas podem enviar comentários e dúvidas.\n'
          '• Diretório de Sommeliers: Consulte os perfis profissionais dos Sommeliers cadastrados, com formação (ex: WSET Level 3, ABS, FISAR), histórico de carreira e contatos.',
    },
    {
      'title': '6. Painel do Administrador Master',
      'icon': Icons.admin_panel_settings_outlined,
      'image': 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      'subtitle': 'Gestão centralizada exclusiva para admin@winery.com',
      'description':
          '• Gestão de Usuários: Permite ao administrador editar dados cadastrais, alternar status de Bloquear/Desbloquear contas ou excluir cadastros.\n'
          '• Moderação do Blog: O administrador é o único com permissão para excluir matérias ou comentários inadequados no Blog Coletivo.',
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
              'Guia de Uso & Tutorial do Sistema',
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
              // Banner Ilustrativo
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
              const SizedBox(height: 14),
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
              const SizedBox(height: 2),
              Text(
                step['subtitle'] as String,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 16),
              Text(
                step['description'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 16),
              // Indicador Visual de Progresso do Tutorial (Passos)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (idx) {
                  final isActive = idx == _currentStep;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 22 : 8,
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
            child: const Text('Entendi! Fechar Guia'),
          ),
      ],
    );
  }
}
