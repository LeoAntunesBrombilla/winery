import 'package:flutter/foundation.dart';
import 'package:winery_finder/domain/winery.dart';

/// Repositório em memória com catálogo completo e enriquecido de vinícolas do Brasil e do mundo,
/// contendo logotipos, fotos, endereços, responsáveis, sommeliers e uvas cultivadas.
class WineryRepository extends ChangeNotifier {
  WineryRepository._();
  static final WineryRepository instance = WineryRepository._();

  final List<Winery> _wineries = <Winery>[
    // ==========================================
    // --- BRASIL: SERRA GAÚCHA & VALE DOS VINHEDOS (RS) ---
    // ==========================================
    Winery(
      id: 'br_1',
      name: 'Vinícola Miolo',
      city: 'Bento Gonçalves (Vale dos Vinhedos - RS)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco, WineType.espumante},
      distanceKm: 4.5,
      rating: 4.8,
      latitude: -29.2010,
      longitude: -51.5450,
      address: 'RS-444, Km 21 - Vale dos Vinhedos, Bento Gonçalves - RS',
      logoUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
        'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      ],
      responsibleName: 'Adriano Miolo',
      sommelierName: 'Fabiano Ruiz',
      cultivatedGrapes: <String>['Merlot', 'Cabernet Sauvignon', 'Chardonnay', 'Riesling'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_2',
      name: 'Casa Valduga',
      city: 'Bento Gonçalves (Vale dos Vinhedos - RS)',
      wineTypes: <WineType>{WineType.tinto, WineType.espumante},
      distanceKm: 6.2,
      rating: 4.9,
      latitude: -29.2150,
      longitude: -51.5300,
      address: 'Via Vinhedos, 31 - Vale dos Vinhedos, Bento Gonçalves - RS',
      logoUrl: 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
        'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      ],
      responsibleName: 'Jú Tognon Valduga',
      sommelierName: 'Renato Valduga',
      cultivatedGrapes: <String>['Merlot', 'Chardonnay', 'Pinot Noir', 'Cabernet Franc'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_3',
      name: 'Vinícola Salton',
      city: 'Bento Gonçalves (RS)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco, WineType.espumante, WineType.rose},
      distanceKm: 2.1,
      rating: 4.7,
      latitude: -29.1720,
      longitude: -51.5100,
      address: 'Rua Vinícola Salton, 300 - Tuiuty, Bento Gonçalves - RS',
      logoUrl: 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      ],
      responsibleName: 'Maurício Salton',
      sommelierName: 'Luciano Salton',
      cultivatedGrapes: <String>['Chardonnay', 'Prosecco (Glera)', 'Cabernet Sauvignon', 'Merlot'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_4',
      name: 'Pizzato Vinhas e Vinhos',
      city: 'Bento Gonçalves (Vale dos Vinhedos - RS)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco},
      distanceKm: 5.0,
      rating: 4.8,
      latitude: -29.1950,
      longitude: -51.5380,
      address: 'RS-444, Km 18,8 - Vale dos Vinhedos, Bento Gonçalves - RS',
      logoUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      ],
      responsibleName: 'Flávio Pizzato',
      sommelierName: 'Mariana Pizzato',
      cultivatedGrapes: <String>['Merlot', 'Tannat', 'Cabernet Sauvignon', 'Chardonnay'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_5',
      name: 'Cave Geisse',
      city: 'Pinto Bandeira (RS)',
      wineTypes: <WineType>{WineType.espumante},
      distanceKm: 12.8,
      rating: 4.9,
      latitude: -29.1050,
      longitude: -51.4600,
      address: 'Linha Amaro Carneiro, s/n - Pinto Bandeira - RS',
      logoUrl: 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      ],
      responsibleName: 'Mário Geisse',
      sommelierName: 'Carlos Geisse',
      cultivatedGrapes: <String>['Chardonnay', 'Pinot Noir'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_6',
      name: 'Vinícola Aurora',
      city: 'Bento Gonçalves (RS)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco, WineType.espumante, WineType.rose},
      distanceKm: 3.5,
      rating: 4.6,
      latitude: -29.1680,
      longitude: -51.5150,
      address: 'Rua Henry Hugo Dreher, 48 - Centro, Bento Gonçalves - RS',
      logoUrl: 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      ],
      responsibleName: 'Hermindo Bacca',
      sommelierName: 'Flávio Zilio',
      cultivatedGrapes: <String>['Merlot', 'Cabernet Sauvignon', 'Tannat', 'Chardonnay', 'Moscato'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_7',
      name: 'Don Giovanni',
      city: 'Garibaldi (RS)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco, WineType.espumante},
      distanceKm: 14.2,
      rating: 4.8,
      latitude: -29.2350,
      longitude: -51.5120,
      address: 'Linha São José, 722 - Garibaldi - RS',
      logoUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      ],
      responsibleName: 'Daniel Panizzi',
      sommelierName: 'Beatriz Panizzi',
      cultivatedGrapes: <String>['Chardonnay', 'Pinot Noir', 'Merlot', 'Cabernet Sauvignon'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_8',
      name: 'Chandon Brasil',
      city: 'Garibaldi (RS)',
      wineTypes: <WineType>{WineType.espumante, WineType.rose},
      distanceKm: 15.0,
      rating: 4.8,
      latitude: -29.2450,
      longitude: -51.5200,
      address: 'RS-453, Km 21 - Garibaldi - RS',
      logoUrl: 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      ],
      responsibleName: 'Philippe Mével',
      sommelierName: 'Henrique Salton',
      cultivatedGrapes: <String>['Chardonnay', 'Pinot Noir', 'Riesling Itálico'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_9',
      name: 'Casa Perini',
      city: 'Farroupilha (RS)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco, WineType.espumante, WineType.rose},
      distanceKm: 18.5,
      rating: 4.7,
      latitude: -29.2280,
      longitude: -51.3850,
      address: 'Rua Julio Perini, 845 - Distrito de Fazenda Souza, Farroupilha - RS',
      logoUrl: 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      ],
      responsibleName: 'Franco Perini',
      sommelierName: 'Jonas Perini',
      cultivatedGrapes: <String>['Muscat', 'Merlot', 'Cabernet Sauvignon', 'Chardonnay'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_10',
      name: 'Almaúnica',
      city: 'Bento Gonçalves (Vale dos Vinhedos - RS)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco, WineType.espumante},
      distanceKm: 5.8,
      rating: 4.8,
      latitude: -29.2080,
      longitude: -51.5420,
      address: 'Via Vale dos Vinhedos, s/n - Bento Gonçalves - RS',
      logoUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      ],
      responsibleName: 'Márcio Brandelli',
      sommelierName: 'Luiz Brandelli',
      cultivatedGrapes: <String>['Syrah', 'Merlot', 'Cabernet Franc', 'Chardonnay'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_11',
      name: 'Larentis',
      city: 'Bento Gonçalves (Vale dos Vinhedos - RS)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco},
      distanceKm: 4.9,
      rating: 4.7,
      latitude: -29.1980,
      longitude: -51.5350,
      address: 'Caminho Vindima, Via Vale dos Vinhedos - Bento Gonçalves - RS',
      logoUrl: 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      ],
      responsibleName: 'André Larentis',
      sommelierName: 'Cezar Larentis',
      cultivatedGrapes: <String>['Marselan', 'Merlot', 'Tannat', 'Trebbiano'],
      creatorEmail: 'admin@winery.com',
    ),

    // ==========================================
    // --- BRASIL: CAMPANHA GAÚCHA & FRONTEIRA (RS) ---
    // ==========================================
    Winery(
      id: 'br_12',
      name: 'Guatambu Estância do Vinho',
      city: 'Dom Pedrito (Campanha Gaúcha - RS)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco, WineType.espumante, WineType.rose},
      distanceKm: 340.0,
      rating: 4.9,
      latitude: -30.9820,
      longitude: -54.6730,
      address: 'Rodovia BR-293, Km 265 - Dom Pedrito - RS',
      logoUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      ],
      responsibleName: 'Valter Pötter',
      sommelierName: 'Gabriela Pötter',
      cultivatedGrapes: <String>['Tannat', 'Tempranillo', 'Sauvignon Blanc', 'Chardonnay', 'Cabernet Sauvignon'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_13',
      name: 'Vinícola Batalha',
      city: 'Candiota (Campanha Gaúcha - RS)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco, WineType.espumante},
      distanceKm: 380.0,
      rating: 4.7,
      latitude: -31.5780,
      longitude: -53.7120,
      address: 'Rodovia BR-293, Km 138 - Candiota - RS',
      logoUrl: 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      ],
      responsibleName: 'Luiz Batalha',
      sommelierName: 'Marcos Batalha',
      cultivatedGrapes: <String>['Touriga Nacional', 'Tempranillo', 'Sauvignon Blanc', 'Chardonnay'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_14',
      name: 'Cordilheira de Santana',
      city: 'Santana do Livramento (RS)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco},
      distanceKm: 420.0,
      rating: 4.8,
      latitude: -30.8880,
      longitude: -55.5310,
      address: 'Estrada do Cerro da Vigia, s/n - Santana do Livramento - RS',
      logoUrl: 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      ],
      responsibleName: 'Rossana Vigano',
      sommelierName: 'João Vigano',
      cultivatedGrapes: <String>['Cabernet Sauvignon', 'Merlot', 'Tannat', 'Chardonnay'],
      creatorEmail: 'admin@winery.com',
    ),

    // ==========================================
    // --- BRASIL: SANTA CATARINA (ALTO SERRANO) ---
    // ==========================================
    Winery(
      id: 'br_15',
      name: 'Villa Francioni',
      city: 'São Joaquim (SC)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco, WineType.rose, WineType.espumante},
      distanceKm: 280.0,
      rating: 4.9,
      latitude: -28.2910,
      longitude: -49.9320,
      address: 'Avenida Vinte e Sete de Julho, 5890 - São Joaquim - SC',
      logoUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      ],
      responsibleName: 'Dilermando D\'Wolf',
      sommelierName: 'Nei Rasche',
      cultivatedGrapes: <String>['Cabernet Sauvignon', 'Merlot', 'Cabernet Franc', 'Chardonnay', 'Pinot Noir', 'Sangiovese'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_16',
      name: 'Quinta da Neve',
      city: 'São Joaquim (SC)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco},
      distanceKm: 285.0,
      rating: 4.7,
      latitude: -28.3150,
      longitude: -49.9120,
      address: 'Rodovia SC-110, Km 396 - São Joaquim - SC',
      logoUrl: 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      ],
      responsibleName: 'Renato Borges',
      sommelierName: 'Rodrigo Borges',
      cultivatedGrapes: <String>['Pinot Noir', 'Cabernet Sauvignon', 'Sauvignon Blanc', 'Merlot'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_17',
      name: 'Vinícola Thera',
      city: 'Urupema (SC)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco, WineType.rose},
      distanceKm: 310.0,
      rating: 4.8,
      latitude: -27.9650,
      longitude: -49.9610,
      address: 'Fazenda Bom Retiro, s/n - Urupema - SC',
      logoUrl: 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      ],
      responsibleName: 'João Paulo Tavares',
      sommelierName: 'Diego Arrebola',
      cultivatedGrapes: <String>['Sauvignon Blanc', 'Syrah', 'Cabernet Franc', 'Merlot'],
      creatorEmail: 'admin@winery.com',
    ),

    // ==========================================
    // --- BRASIL: SÃO PAULO & MINAS GERAIS ---
    // ==========================================
    Winery(
      id: 'br_18',
      name: 'Vinícola Guaspari',
      city: 'Espírito Santo do Pinhal (SP)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco, WineType.rose},
      distanceKm: 450.0,
      rating: 4.9,
      latitude: -22.1930,
      longitude: -46.7450,
      address: 'Rua Pedro Ferrari, 300 - Centro, Espírito Santo do Pinhal - SP',
      logoUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      ],
      responsibleName: 'Nelson Guaspari',
      sommelierName: 'Alexandre Pereira',
      cultivatedGrapes: <String>['Syrah', 'Cabernet Sauvignon', 'Sauvignon Blanc', 'Viognier'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_19',
      name: 'Vinícola Luiz Porto',
      city: 'Caldas (MG)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco, WineType.espumante},
      distanceKm: 480.0,
      rating: 4.8,
      latitude: -21.9210,
      longitude: -46.3850,
      address: 'Fazenda Santana, s/n - Caldas - MG',
      logoUrl: 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      ],
      responsibleName: 'Luiz Porto',
      sommelierName: 'Carlos Porto',
      cultivatedGrapes: <String>['Syrah', 'Chardonnay', 'Sauvignon Blanc', 'Cabernet Franc'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'br_20',
      name: 'Casa Geraldo',
      city: 'Andradas (MG)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco, WineType.espumante, WineType.rose},
      distanceKm: 470.0,
      rating: 4.7,
      latitude: -22.0680,
      longitude: -46.5710,
      address: 'Av. Rodolfo Geraldo, 1557 - Andradas - MG',
      logoUrl: 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      ],
      responsibleName: 'Geraldo Bordignon',
      sommelierName: 'Patrícia Bordignon',
      cultivatedGrapes: <String>['Syrah', 'Moscato', 'Cabernet Sauvignon', 'Chardonnay'],
      creatorEmail: 'admin@winery.com',
    ),

    // ==========================================
    // --- BRASIL: VALE DO SÃO FRANCISCO (PE / BA) ---
    // ==========================================
    Winery(
      id: 'br_21',
      name: 'Vinícola Rio Sol',
      city: 'Lagoa Grande (Vale do São Francisco - PE)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco, WineType.espumante, WineType.rose},
      distanceKm: 1850.0,
      rating: 4.7,
      latitude: -8.9950,
      longitude: -40.1830,
      address: 'Fazenda Planaltina, Rodovia PE-574 - Lagoa Grande - PE',
      logoUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      ],
      responsibleName: 'Manoel Alves',
      sommelierName: 'Luciano Lima',
      cultivatedGrapes: <String>['Syrah', 'Chenin Blanc', 'Muscat', 'Tempranillo', 'Touriga Nacional'],
      creatorEmail: 'admin@winery.com',
    ),

    // ==========================================
    // --- PRINCIPAIS INTERNACIONAIS DE REFERÊNCIA ---
    // ==========================================
    Winery(
      id: 'fr_1',
      name: 'Château Margaux',
      city: 'Margaux, Bordeaux (França)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco},
      distanceKm: 8500.0,
      rating: 4.9,
      latitude: 45.0440,
      longitude: -0.6780,
      address: '33460 Margaux-Cantenac, França',
      logoUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      ],
      responsibleName: 'Corinne Mentzelopoulos',
      sommelierName: 'Philippe Bascaules',
      cultivatedGrapes: <String>['Cabernet Sauvignon', 'Merlot', 'Petit Verdot', 'Cabernet Franc'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'it_1',
      name: 'Antinori nel Chianti Classico',
      city: 'San Casciano, Toscana (Itália)',
      wineTypes: <WineType>{WineType.tinto},
      distanceKm: 9800.0,
      rating: 4.9,
      latitude: 43.5580,
      longitude: 11.2010,
      address: 'Via Cassia per Siena, 133, Itália',
      logoUrl: 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      ],
      responsibleName: 'Albiera Antinori',
      sommelierName: 'Renzo Cotarella',
      cultivatedGrapes: <String>['Sangiovese', 'Cabernet Sauvignon', 'Merlot'],
      creatorEmail: 'admin@winery.com',
    ),
    Winery(
      id: 'ar_1',
      name: 'Catena Zapata',
      city: 'Agrelo, Mendoza (Argentina)',
      wineTypes: <WineType>{WineType.tinto, WineType.branco},
      distanceKm: 2400.0,
      rating: 4.9,
      latitude: -33.0180,
      longitude: -68.8750,
      address: 'Cobos J. A., M5509 Luján de Cuyo, Mendoza, Argentina',
      logoUrl: 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      photoUrls: const <String>[
        'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      ],
      responsibleName: 'Laura Catena',
      sommelierName: 'Alejandro Vigil',
      cultivatedGrapes: <String>['Malbec', 'Cabernet Sauvignon', 'Chardonnay'],
      creatorEmail: 'admin@winery.com',
    ),
  ];

  List<Winery> get wineries => List<Winery>.unmodifiable(_wineries);

  void addWinery(Winery winery) {
    _wineries.insert(0, winery);
    notifyListeners();
  }

  void updateWinery(Winery winery) {
    final index = _wineries.indexWhere((w) => w.id == winery.id);
    if (index != -1) {
      _wineries[index] = winery;
      notifyListeners();
    }
  }

  void deleteWinery(String wineryId) {
    _wineries.removeWhere((w) => w.id == wineryId);
    notifyListeners();
  }
}
