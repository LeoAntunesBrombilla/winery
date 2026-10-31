# Winery Finder — app Flutter

Esqueleto do aplicativo descrito no [README da raiz](../README.md). Por enquanto
tem a casca de navegação (Mapa, Favoritos, Recentes), o modelo de domínio de
vinícola e as regras de busca/filtro, sem Firebase ainda.

## Requisitos

- Flutter 3.47 (canal `stable`) — `flutter --version`
- Xcode para iOS, Android Studio para Android

## Comandos

```sh
flutter pub get                                   # dependências
flutter run                                       # roda no dispositivo/simulador
dart format --output=none --set-exit-if-changed . # checa formatação
flutter analyze --fatal-infos                     # lint (mesmo comando do CI)
flutter test                                      # testes
flutter test --coverage                           # testes + coverage/lcov.info
```

## Estrutura

```
lib/
  main.dart                  Ponto de entrada
  app.dart                   MaterialApp e tema
  domain/                    Modelos e regras puras (sem Flutter/Firebase)
    winery.dart
    winery_filter.dart
  features/
    home/home_shell.dart     Navegação inferior entre as abas
    map/                     Aba Mapa
    favorites/               Aba Favoritos
    recents/                 Aba Recentes
  widgets/                   Componentes compartilhados
test/
  domain/                    Testes unitários
  features/                  Testes de widget
```

## Lint

As regras ficam em `analysis_options.yaml`: `flutter_lints` como base, modo
estrito do analisador (`strict-casts`, `strict-inference`, `strict-raw-types`)
e alguns avisos promovidos a erro. O CI roda com `--fatal-infos`, então
qualquer aviso derruba a pipeline.
