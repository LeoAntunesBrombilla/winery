import 'dart:io';
import 'package:flutter/material.dart';
import 'package:winery_finder/data/auth_repository.dart';

/// Tela do Diretório de Sommeliers Profissionais Cadastrados no sistema.
class SommeliersScreen extends StatelessWidget {
  const SommeliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sommeliers Profissionais'),
      ),
      body: AnimatedBuilder(
        animation: AuthRepository.instance,
        builder: (context, _) {
          final sommeliers = AuthRepository.instance.registeredSommeliers;

          if (sommeliers.isEmpty) {
            return const Center(
              child: Text('Nenhum Sommelier cadastrado até o momento.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sommeliers.length,
            itemBuilder: (context, index) {
              final sommelier = sommeliers[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: sommelier.photoUrl.isNotEmpty
                                ? ClipOval(
                                    child: sommelier.photoUrl.startsWith('http')
                                        ? Image.network(
                                            sommelier.photoUrl,
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, stack) => const Icon(Icons.person, size: 32),
                                          )
                                        : Image.file(
                                            File(sommelier.photoUrl),
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, stack) => const Icon(Icons.person, size: 32),
                                          ),
                                  )
                                : const Icon(Icons.person, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sommelier.name,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Sommelier Profissional',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      if (sommelier.education.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.school_outlined, size: 20, color: Color(0xFF722F37)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Formação Profissional / Certificações:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(sommelier.education, style: theme.textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (sommelier.professionalHistory.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.history_edu_outlined, size: 20, color: Color(0xFF722F37)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Histórico Profissional:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(sommelier.professionalHistory, style: theme.textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (sommelier.contactInfo.isNotEmpty || sommelier.phone.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.contact_phone_outlined, size: 20, color: Color(0xFF722F37)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Informações de Contato:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(
                                    sommelier.contactInfo.isNotEmpty ? sommelier.contactInfo : '${sommelier.email} | ${sommelier.phone}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    );
  }
}
