import 'dart:io';
import 'package:flutter/material.dart';
import 'package:winery_finder/data/auth_repository.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/winery_filter.dart';
import 'package:winery_finder/features/admin/edit_user_dialog.dart';

/// Painel do Administrador (exclusivo para admin@winery.com): alterar cadastro, bloquear ou excluir usuários.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserEmail = AuthRepository.instance.currentUser?.email;

    // Acesso estritamente restrito ao administrador admin@winery.com
    if (currentUserEmail != 'admin@winery.com') {
      return Scaffold(
        appBar: AppBar(title: const Text('Acesso Restrito')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  'Acesso Negado',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Apenas o usuário administrador (admin@winery.com) pode acessar este painel.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Painel do Administrador'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people_outline), text: 'Usuários Cadastrados'),
              Tab(icon: Icon(Icons.wine_bar_outlined), text: 'Todas Contribuições'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Aba 1: Usuários Cadastrados (Editar, Bloquear/Desbloquear e Excluir)
            AnimatedBuilder(
              animation: AuthRepository.instance,
              builder: (context, _) {
                final users = AuthRepository.instance.registeredUsers;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: user.photoUrl.isNotEmpty
                              ? (user.photoUrl.startsWith('http')
                                  ? NetworkImage(user.photoUrl) as ImageProvider
                                  : FileImage(File(user.photoUrl)))
                              : null,
                          child: user.photoUrl.isEmpty
                              ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U')
                              : null,
                        ),
                        title: Row(
                          children: [
                            Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            if (user.isBlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Bloqueado',
                                  style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              )
                            else if (user.email == 'admin@winery.com')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Admin',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${user.email}\nCPF: ${user.cpf.isNotEmpty ? user.cpf : "Não informado"} | Tel: ${user.phone.isNotEmpty ? user.phone : "Não informado"}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Alterar Cadastro',
                              onPressed: () {
                                showDialog<void>(
                                  context: context,
                                  builder: (_) => EditUserDialog(user: user),
                                );
                              },
                            ),
                            if (user.email != 'admin@winery.com') ...[
                              IconButton(
                                icon: Icon(
                                  user.isBlocked ? Icons.lock_open_outlined : Icons.block_outlined,
                                  color: user.isBlocked ? Colors.green : Colors.orangeAccent,
                                ),
                                tooltip: user.isBlocked ? 'Desbloquear Usuário' : 'Bloquear Usuário',
                                onPressed: () {
                                  AuthRepository.instance.toggleUserBlockStatus(user.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        user.isBlocked
                                            ? 'Usuário "${user.name}" foi desbloqueado.'
                                            : 'Usuário "${user.name}" foi bloqueado pelo administrador.',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                tooltip: 'Excluir Cadastro',
                                onPressed: () {
                                  AuthRepository.instance.deleteUser(user.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Usuário "${user.name}" foi excluído.')),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            // Aba 2: Contribuições (Vinícolas)
            AnimatedBuilder(
              animation: WineryRepository.instance,
              builder: (context, _) {
                final wineries = WineryRepository.instance.wineries;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: wineries.length,
                  itemBuilder: (context, index) {
                    final winery = wineries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: const Icon(Icons.wine_bar),
                        ),
                        title: Text(winery.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('${winery.city} • ${WineryFilter.formatDistance(winery.distanceKm)}'),
                            const SizedBox(height: 4),
                            Text(
                              'Criado por: ${winery.creatorEmail}',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(winery.rating.toStringAsFixed(1)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
