import 'package:flutter/material.dart';
import 'package:winery_finder/data/auth_repository.dart';
import 'package:winery_finder/data/blog_repository.dart';
import 'package:winery_finder/domain/blog_post.dart';
import 'package:winery_finder/domain/user_account.dart';

/// Tela do Blog Coletivo com publicações de Sommeliers e comentários de Vinícolas e Admiradores.
class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showNewPostDialog() {
    final user = AuthRepository.instance.currentUser;
    if (user == null) return;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Publicação no Blog Coletivo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título da Matéria *'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Conteúdo / Avaliação / Dica de Harmonização *',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) return;

                final newPost = BlogPost(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text.trim(),
                  content: _contentController.text.trim(),
                  authorName: user.name,
                  authorEmail: user.email,
                  authorRole: user.role,
                  createdAt: DateTime.now(),
                );

                BlogRepository.instance.addPost(newPost);
                _titleController.clear();
                _contentController.clear();
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Artigo publicado no Blog Coletivo com sucesso!')),
                );
              },
              child: const Text('Publicar Artigo'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCommentDialog(BlogPost post) {
    final user = AuthRepository.instance.currentUser;
    if (user == null) return;

    final commentController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Comentar em "${post.title}"'),
          content: TextFormField(
            controller: commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Seu comentário ou dúvida...',
              alignLabelWithHint: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (commentController.text.trim().isEmpty) return;

                final comment = BlogComment(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  authorName: user.name,
                  authorEmail: user.email,
                  authorRole: user.role,
                  text: commentController.text.trim(),
                  createdAt: DateTime.now(),
                );

                BlogRepository.instance.addComment(post.id, comment);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comentário publicado no blog!')),
                );
              },
              child: const Text('Comentar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = AuthRepository.instance.currentUser;
    final isSommelierOrAdmin = currentUser?.role == UserRole.sommelier || currentUser?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Coletivo de Sommeliers'),
      ),
      body: AnimatedBuilder(
        animation: BlogRepository.instance,
        builder: (context, _) {
          final posts = BlogRepository.instance.posts;

          if (posts.isEmpty) {
            return const Center(
              child: Text('Nenhuma publicação no blog coletivo ainda.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: const Icon(Icons.rate_review),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.authorName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    post.authorRole.label,
                                    style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        post.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(post.content, style: theme.textTheme.bodyMedium),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Comentários (${post.comments.length})',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: () => _showAddCommentDialog(post),
                            icon: const Icon(Icons.comment, size: 18),
                            label: const Text('Comentar'),
                          ),
                        ],
                      ),
                      if (post.comments.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: post.comments.length,
                          itemBuilder: (context, cIdx) {
                            final comment = post.comments[cIdx];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment.authorName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '(${comment.authorRole.label})',
                                        style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(comment.text, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
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
      floatingActionButton: isSommelierOrAdmin
          ? FloatingActionButton.extended(
              onPressed: _showNewPostDialog,
              icon: const Icon(Icons.edit_note),
              label: const Text('Publicar no Blog'),
            )
          : null,
    );
  }
}
