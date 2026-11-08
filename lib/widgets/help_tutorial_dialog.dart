import 'package:flutter/material.dart';
import 'package:winery_finder/widgets/winery_logo.dart';

/// Diálogo de Ajuda com Guia Completo das Telas do Sistema (Rolável Passo a Passo na Mesma Tela).
class HelpTutorialDialog extends StatefulWidget {
  const HelpTutorialDialog({super.key});

  @override
  State<HelpTutorialDialog> createState() => _HelpTutorialDialogState();
}

class _HelpTutorialDialogState extends State<HelpTutorialDialog> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _steps = [
    {
      'id': 'step_1',
      'stepNum': '1',
      'title': 'Tela de Cadastro & Perfil de Usuário',
      'icon': Icons.badge_outlined,
      'image': 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      'subtitle': 'Cadastro com foto, redefinição de senha e seleção do tipo de perfil',
      'details': [
        '📷 Foto de Perfil Pessoal: Envie uma foto do seu computador ou galeria para identificar sua conta.',
        '👤 Tipos de Perfil:\n'
            '   • Admirador de Vinhos (Consumidor): Explora o mapa, visualiza vinhos, compra vinhos direct e salva favoritos.\n'
            '   • Sommelier Profissional: Cadastra formação/certificações (ex: WSET Level 3, ABS, FISAR), histórico de carreira e publica no Blog Coletivo.\n'
            '   • Vinícola / Produtor: Cadastra o estabelecimento e gerencia produtos/preços para venda.',
        '🔑 Redefinição de Senha: Na tela de login, o botão "Esqueceu a senha?" valida seu e-mail cadastrado e permite registrar uma nova senha na hora.',
      ],
    },
    {
      'id': 'step_2',
      'stepNum': '2',
      'title': 'Tela de Mapa Interativo & Busca',
      'icon': Icons.map_outlined,
      'image': 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      'subtitle': 'Mapa livre no topo, busca por cidade e salvamento de favoritos',
      'details': [
        '🗺️ Visão do Mapa Desobstruída: O mapa fica posicionado no topo da tela, 100% livre para navegação.',
        '🔍 Busca por Cidade ou Vinícola: Digite no campo de pesquisa para filtrar os estabelecimentos do Brasil e do mundo em tempo real.',
        '🍷 Chips de Tipos de Vinho: Selecione os chips para filtrar vinícolas por vinho Tinto, Branco, Espumante ou Rosé.',
        '❤️ Favoritos Independentes: Clique no ícone de Coração para salvar vinícolas. A lista de favoritos é salva de forma 100% independente na sua conta.',
      ],
    },
    {
      'id': 'step_3',
      'stepNum': '3',
      'title': 'Tela de Trajeto Real & GPS no Google Maps',
      'icon': Icons.alt_route_outlined,
      'image': 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      'subtitle': 'Mapeamento pelas ruas do seu endereço e navegação GPS por voz',
      'details': [
        '🚗 Resposta Instantânea (0ms): Ao clicar em "Trajeto Real no Mapa", a rota é desenhada na hora sem travamentos.',
        '📍 Origem do Seu Endereço: O aplicativo geolocaliza seu endereço cadastrado no perfil e traça as curvas das ruas e rodovias.',
        '🌟 Destaque Duplo no Mapa: A rota é exibida com borda dourada/amarela neon e linha interna na cor vinho.',
        '🛣️ Itinerário das Vias: O painel abaixo do mapa exibe o nome de cada rua, avenida e rodovia do itinerário.',
        '📲 Seguir Rota com GPS: Clique no botão "Seguir Rota com GPS" para abrir a navegação curva a curva no Google Maps.',
      ],
    },
    {
      'id': 'step_4',
      'stepNum': '4',
      'title': 'Tela de Cadastro de Vinícola & Venda de Vinhos',
      'icon': Icons.storefront_outlined,
      'image': 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      'subtitle': 'Ordem do formulário, galeria de fotos e painel de produtos direct',
      'details': [
        '📋 Ordem do Formulário: No cadastro de vinícola, o Logo fica em 1º lugar e o Nome do Proprietário/Responsável em 2º lugar.',
        '📸 Galeria do Estabelecimento: Adicione fotos, sommelier e uvas cultivadas pela vinícola.',
        '🍷 Painel de Produtos Direct: A vinícola criadora acessa o painel de produtos para cadastrar vinhos, alterar preços em R\$, ativar/inativar rótulos e inserir o link de Pagamento Direct (MercadoPago/WhatsApp).',
        '✏️ Permissão Exclusiva: Apenas o usuário que cadastrou a vinícola tem permissão para editar ou excluir.',
      ],
    },
    {
      'id': 'step_5',
      'stepNum': '5',
      'title': 'Tela do Blog Coletivo & Diretório de Sommeliers',
      'icon': Icons.article_outlined,
      'image': 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      'subtitle': 'Mural de matérias, comentários e currículo de sommeliers',
      'details': [
        '📝 Publicação por Sommeliers: Sommeliers Profissionais publicam matérias sobre análises de safras, degustação e harmonização.',
        '💬 Comentários Interativos: Admiradores e Vinícolas enviam comentários, tirando dúvidas e interagindo com o autor.',
        '🎓 Diretório Profissional: Apresenta a foto, certificações (WSET, ABS, FISAR), histórico de carreira e contatos dos Sommeliers.',
      ],
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const WineryLogo(size: 36),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Guia Completo das Telas do Sistema',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            // Atalhos rápidos de navegação no topo da caixa
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_steps.length, (idx) {
                  final step = _steps[idx];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ActionChip(
                      avatar: CircleAvatar(
                        radius: 10,
                        backgroundColor: const Color(0xFF722F37),
                        child: Text(
                          step['stepNum'] as String,
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      label: Text(
                        (step['title'] as String).split('&')[0].replaceAll('Tela de ', '').trim(),
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () {
                        _scrollController.animateTo(
                          idx * 340.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
            const Divider(height: 16),
            // Conteúdo Completo Passo a Passo na Mesma Tela (Rolável)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _steps.length,
                itemBuilder: (context, idx) {
                  final step = _steps[idx];
                  final details = step['details'] as List<String>;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFF722F37),
                                child: Text(
                                  step['stepNum'] as String,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  step['title'] as String,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step['subtitle'] as String,
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              step['image'] as String,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Container(
                                height: 120,
                                color: theme.colorScheme.primaryContainer,
                                child: Icon(step['icon'] as IconData, size: 40, color: theme.colorScheme.primary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...details.map(
                            (detailText) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                detailText,
                                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Entendi! Fechar Guia'),
        ),
      ],
    );
  }
}
