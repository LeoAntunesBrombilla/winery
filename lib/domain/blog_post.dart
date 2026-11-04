import 'package:winery_finder/domain/user_account.dart';

/// Comentário no Blog Coletivo
class BlogComment {
  const BlogComment({
    required this.id,
    required this.authorName,
    required this.authorEmail,
    required this.authorRole,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String authorName;
  final String authorEmail;
  final UserRole authorRole;
  final String text;
  final DateTime createdAt;
}

/// Postagem de Sommelier no Blog Coletivo
class BlogPost {
  const BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorEmail,
    required this.authorRole,
    this.photoUrl = '',
    required this.createdAt,
    this.comments = const <BlogComment>[],
  });

  final String id;
  final String title;
  final String content;
  final String authorName;
  final String authorEmail;
  final UserRole authorRole;
  final String photoUrl;
  final DateTime createdAt;
  final List<BlogComment> comments;

  BlogPost copyWith({
    String? id,
    String? title,
    String? content,
    String? authorName,
    String? authorEmail,
    UserRole? authorRole,
    String? photoUrl,
    DateTime? createdAt,
    List<BlogComment>? comments,
  }) {
    return BlogPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      authorRole: authorRole ?? this.authorRole,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
    );
  }
}
