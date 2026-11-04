import 'package:flutter/foundation.dart';
import 'package:winery_finder/domain/blog_post.dart';
import 'package:winery_finder/domain/user_account.dart';

/// Repositório reativo para o Blog Coletivo de Sommeliers e Comentários.
class BlogRepository extends ChangeNotifier {
  BlogRepository._();
  static final BlogRepository instance = BlogRepository._();

  final List<BlogPost> _posts = <BlogPost>[
    BlogPost(
      id: 'post_1',
      title: 'Segredos da Harmonização de Vinhos Tintos da Serra Gaúcha',
      content: 'Os vinhos Merlot da Serra Gaúcha possuem corpo equilibrado, acidez bem marcada e taninos aveludados. Harmonizam perfeitamente com carnes assadas, massas com molhos encorpados e queijos curados.',
      authorName: 'Sommelier Marcelo Rossi',
      authorEmail: 'marcelo.sommelier@winery.com',
      authorRole: UserRole.sommelier,
      photoUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      comments: [
        BlogComment(
          id: 'c1',
          authorName: 'Vinícola Miolo',
          authorEmail: 'miolo@winery.com',
          authorRole: UserRole.winery,
          text: 'Excelente análise! Nossos vinhos Merlot safra 2020 refletem exatamente essas notas de degustação.',
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        BlogComment(
          id: 'c2',
          authorName: 'Ana Clara (Admiradora)',
          authorEmail: 'ana@gmail.com',
          authorRole: UserRole.admirer,
          text: 'Adorei a dica! Experimentei essa harmonização no fim de semana e ficou espetacular.',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ],
    ),
    BlogPost(
      id: 'post_2',
      title: 'Espumantes Brasileiros: O Sucesso do Método Tradicional no Vale dos Vinhedos',
      content: 'O terroir gaúcho e do Alto Serrano em SC é reconhecido mundialmente pela altíssima qualidade de seus espumantes Brut e Nature. As castas Chardonnay e Pinot Noir atingem acidez e frescor ímpares.',
      authorName: 'Sommellière Renata Valduga',
      authorEmail: 'renata.sommelier@winery.com',
      authorRole: UserRole.sommelier,
      photoUrl: 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      comments: [
        BlogComment(
          id: 'c3',
          authorName: 'Cave Geisse',
          authorEmail: 'geisse@winery.com',
          authorRole: UserRole.winery,
          text: 'O método Champenoise/Tradicional é a nossa grande paixão na serra gaúcha!',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
    ),
  ];

  List<BlogPost> get posts => List<BlogPost>.unmodifiable(_posts);

  /// Publica uma nova postagem no Blog Coletivo (Sommeliers / Admin)
  void addPost(BlogPost post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  /// Adiciona um comentário em uma publicação no Blog Coletivo
  void addComment(String postId, BlogComment comment) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final updatedComments = List<BlogComment>.from(_posts[index].comments)..add(comment);
      _posts[index] = _posts[index].copyWith(comments: updatedComments);
      notifyListeners();
    }
  }
}
