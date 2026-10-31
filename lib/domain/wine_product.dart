import 'package:winery_finder/domain/winery.dart';

/// Produto de vinho postado por uma vinícola para venda com preço, fotos, status de atratividade/ativação e link de pagamento.
class WineProduct {
  const WineProduct({
    required this.id,
    required this.wineryId,
    required this.name,
    required this.type,
    required this.vintage,
    required this.price,
    this.grape = '',
    this.description = '',
    this.imageUrl = '',
    this.photoUrls = const <String>[],
    this.paymentLink = '',
    this.isActive = true,
    this.creatorEmail = 'admin@winery.com',
  });

  final String id;
  final String wineryId;
  final String name;
  final WineType type;
  final String vintage; // Safra (ex: 2021, NV)
  final double price;
  final String grape; // Uva utilizada (ex: Merlot, Cabernet Sauvignon)
  final String description;
  final String imageUrl; // Foto principal do produto
  final List<String> photoUrls; // Galeria de fotos do produto
  final String paymentLink; // Link para pagamento (ex: MercadoPago, WhatsApp, Loja)
  final bool isActive; // Status do produto (Ativo/Inativo)
  final String creatorEmail; // E-mail do criador / vinícola responsável

  WineProduct copyWith({
    String? id,
    String? wineryId,
    String? name,
    WineType? type,
    String? vintage,
    double? price,
    String? grape,
    String? description,
    String? imageUrl,
    List<String>? photoUrls,
    String? paymentLink,
    bool? isActive,
    String? creatorEmail,
  }) {
    return WineProduct(
      id: id ?? this.id,
      wineryId: wineryId ?? this.wineryId,
      name: name ?? this.name,
      type: type ?? this.type,
      vintage: vintage ?? this.vintage,
      price: price ?? this.price,
      grape: grape ?? this.grape,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      photoUrls: photoUrls ?? this.photoUrls,
      paymentLink: paymentLink ?? this.paymentLink,
      isActive: isActive ?? this.isActive,
      creatorEmail: creatorEmail ?? this.creatorEmail,
    );
  }
}
