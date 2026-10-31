import 'dart:io';
import 'package:flutter/material.dart';
import 'package:winery_finder/data/auth_repository.dart';
import 'package:winery_finder/data/wine_repository.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/features/map/edit_wine_dialog.dart';
import 'package:winery_finder/features/map/register_wine_dialog.dart';

/// Painel de gestão de produtos para a vinícola criadora (permite cadastrar, ver, editar, inativar, alterar preços e excluir).
class WineryProductsPanel extends StatelessWidget {
  const WineryProductsPanel({required this.winery, super.key});

  final Winery winery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserEmail = AuthRepository.instance.currentUser?.email;
    final bool canModify = currentUserEmail == winery.creatorEmail || currentUserEmail == 'admin@winery.com';

    if (!canModify) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acesso Restrito')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Apenas a vinícola criadora responsável pode gerenciar seus produtos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Painel de Produtos - ${winery.name}'),
      ),
      body: AnimatedBuilder(
        animation: WineRepository.instance,
        builder: (context, _) {
          final wines = WineRepository.instance.getWinesForWinery(winery.id, includeInactive: true);

          if (wines.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wine_bar, size: 64, color: Color(0xFF722F37)),
                  const SizedBox(height: 16),
                  const Text('Nenhum vinho cadastrado nesta vinícola.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => RegisterWineDialog(winery: winery),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Cadastrar Primeiro Vinho'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wines.length,
            itemBuilder: (context, index) {
              final wine = wines[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Foto do produto
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: wine.imageUrl.isNotEmpty
                                ? (wine.imageUrl.startsWith('http')
                                    ? Image.network(
                                        wine.imageUrl,
                                        width: 65,
                                        height: 65,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) => Container(
                                          width: 65,
                                          height: 65,
                                          color: const Color(0xFF722F37),
                                          child: const Icon(Icons.wine_bar, color: Colors.white),
                                        ),
                                      )
                                    : Image.file(
                                        File(wine.imageUrl),
                                        width: 65,
                                        height: 65,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) => Container(
                                          width: 65,
                                          height: 65,
                                          color: const Color(0xFF722F37),
                                          child: const Icon(Icons.wine_bar, color: Colors.white),
                                        ),
                                      ))
                                : Container(
                                    width: 65,
                                    height: 65,
                                    color: const Color(0xFF722F37),
                                    child: const Icon(Icons.wine_bar, color: Colors.white),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        wine.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    // Badge de status Ativo/Inativo
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: wine.isActive ? Colors.green.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        wine.isActive ? 'Ativo' : 'Inativo',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: wine.isActive ? Colors.green : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${wine.type.label} • Safra: ${wine.vintage}${wine.grape.isNotEmpty ? " • Uva: ${wine.grape}" : ""}',
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Preço: R\$ ${wine.price.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF722F37)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      // Botões de Ações (Editar, Inativar/Ativar, Excluir)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              WineRepository.instance.toggleActiveStatus(wine.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    wine.isActive
                                        ? 'Vinho "${wine.name}" foi inativado.'
                                        : 'Vinho "${wine.name}" foi ativado.',
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              wine.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 18,
                            ),
                            label: Text(wine.isActive ? 'Inativar' : 'Ativar'),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (_) => EditWineDialog(wine: wine),
                              );
                            },
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Editar / Preço'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            tooltip: 'Excluir Produto',
                            onPressed: () {
                              WineRepository.instance.deleteWine(wine.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Vinho "${wine.name}" excluído.')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (_) => RegisterWineDialog(winery: winery),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Cadastrar Produto'),
      ),
    );
  }
}
