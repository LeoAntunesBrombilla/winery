import 'package:flutter/foundation.dart';
import 'package:winery_finder/domain/wine_product.dart';
import 'package:winery_finder/domain/winery.dart';

/// Repositório para gerenciamento completo de vinhos à venda (cadastro, alteração de preço, inativação, exclusão e fotos).
class WineRepository extends ChangeNotifier {
  WineRepository._();
  static final WineRepository instance = WineRepository._();

  final List<WineProduct> _wines = <WineProduct>[
    WineProduct(
      id: 'w1',
      wineryId: 'br_1', // Miolo
      name: 'Miolo Cuvée Tradition Brut',
      type: WineType.espumante,
      grape: 'Chardonnay & Pinot Noir',
      vintage: 'NV',
      price: 85.00,
      description: 'Espumante de cor amarela palha, perlage fina e persistente. Notas de frutas cítricas, brioche e toque floral.',
      imageUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      paymentLink: 'https://loja.miolo.com.br/espumante-cuvee-brut',
      isActive: true,
      creatorEmail: 'admin@winery.com',
    ),
    WineProduct(
      id: 'w2',
      wineryId: 'br_1', // Miolo
      name: 'Miolo Lote 43',
      type: WineType.tinto,
      grape: 'Merlot & Cabernet Sauvignon',
      vintage: '2020',
      price: 220.00,
      description: 'Vinho tinto ícone de cor rubi intensa, estagiou em barricas de carvalho francês. Aromas de ameixa e especiarias.',
      imageUrl: 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
      paymentLink: 'https://loja.miolo.com.br/lote-43',
      isActive: true,
      creatorEmail: 'admin@winery.com',
    ),
    WineProduct(
      id: 'w3',
      wineryId: 'br_2', // Casa Valduga
      name: 'Casa Valduga Gran Reserva 130',
      type: WineType.espumante,
      grape: 'Chardonnay',
      vintage: '2018',
      price: 190.00,
      description: 'Espumante pelo método tradicional, maturado 36 meses sobre borras. Aromas de amêndoas e pão torrado.',
      imageUrl: 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8',
      paymentLink: 'https://loja.casavalduga.com.br/gran-reserva-130',
      isActive: true,
      creatorEmail: 'admin@winery.com',
    ),
  ];

  /// Retorna os vinhos da vinícola. Por padrão, exibe apenas os ativos para o público.
  List<WineProduct> getWinesForWinery(String wineryId, {bool includeInactive = false}) {
    return _wines.where((w) => w.wineryId == wineryId && (includeInactive || w.isActive)).toList();
  }

  void addWine(WineProduct wine) {
    _wines.insert(0, wine);
    notifyListeners();
  }

  void updateWine(WineProduct wine) {
    final index = _wines.indexWhere((w) => w.id == wine.id);
    if (index != -1) {
      _wines[index] = wine;
      notifyListeners();
    }
  }

  void toggleActiveStatus(String wineId) {
    final index = _wines.indexWhere((w) => w.id == wineId);
    if (index != -1) {
      final current = _wines[index];
      _wines[index] = current.copyWith(isActive: !current.isActive);
      notifyListeners();
    }
  }

  void deleteWine(String wineId) {
    _wines.removeWhere((w) => w.id == wineId);
    notifyListeners();
  }
}
