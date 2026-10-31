/// Tipos de vinho usados nos filtros da aba Mapa.
enum WineType {
  tinto('Tinto'),
  branco('Branco'),
  espumante('Espumante'),
  rose('Rosé');

  const WineType(this.label);

  /// Nome exibido na interface.
  final String label;
}

/// Vinícola cadastrada por um usuário criador específico com detalhes completos.
class Winery {
  const Winery({
    required this.id,
    required this.name,
    required this.city,
    required this.wineTypes,
    required this.distanceKm,
    required this.rating,
    this.latitude = -29.1683,
    this.longitude = -51.5204,
    this.address = '',
    this.logoUrl = '',
    this.photoUrls = const <String>[],
    this.responsibleName = '',
    this.sommelierName = '',
    this.cultivatedGrapes = const <String>[],
    this.creatorEmail = 'admin@winery.com',
  });

  final String id;
  final String name;
  final String city;
  final Set<WineType> wineTypes;

  /// Distância até o usuário, em quilômetros.
  final double distanceKm;

  /// Avaliação média de 0 a 5.
  final double rating;

  /// Coordenadas geográficas para exibição no mapa.
  final double latitude;
  final double longitude;

  /// Endereço completo da vinícola.
  final String address;

  /// URL ou asset do logo da vinícola.
  final String logoUrl;

  /// URLs de fotos da vinícola.
  final List<String> photoUrls;

  /// Nome do responsável pela vinícola.
  final String responsibleName;

  /// Nome do sommelier responsável.
  final String sommelierName;

  /// Lista de uvas cultivadas (ex: Cabernet Sauvignon, Merlot, Chardonnay...).
  final List<String> cultivatedGrapes;

  /// E-mail do usuário criador desta vinícola e fotos.
  final String creatorEmail;

  Winery copyWith({
    String? id,
    String? name,
    String? city,
    Set<WineType>? wineTypes,
    double? distanceKm,
    double? rating,
    double? latitude,
    double? longitude,
    String? address,
    String? logoUrl,
    List<String>? photoUrls,
    String? responsibleName,
    String? sommelierName,
    List<String>? cultivatedGrapes,
    String? creatorEmail,
  }) {
    return Winery(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      wineTypes: wineTypes ?? this.wineTypes,
      distanceKm: distanceKm ?? this.distanceKm,
      rating: rating ?? this.rating,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      photoUrls: photoUrls ?? this.photoUrls,
      responsibleName: responsibleName ?? this.responsibleName,
      sommelierName: sommelierName ?? this.sommelierName,
      cultivatedGrapes: cultivatedGrapes ?? this.cultivatedGrapes,
      creatorEmail: creatorEmail ?? this.creatorEmail,
    );
  }
}
