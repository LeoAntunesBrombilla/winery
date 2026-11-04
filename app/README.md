# Winery Finder — app Flutter

Esqueleto do aplicativo descrito no [README da raiz](../README.md). Por enquanto
tem a casca de navegação (Mapa, Favoritos, Recentes), o modelo de domínio de
vinícola, as regras de busca/filtro, o Firebase (Firestore, Storage e Auth) e o
spike de mapa e rota.

## Requisitos

- Flutter 3.47 (canal `stable`) — `flutter --version`
- Xcode para iOS, Android Studio para Android

## Setup (primeira vez em cada máquina)

Os arquivos de configuração do Firebase e a chave do Google Maps **não são
versionados**. Cada membro gera os seus seguindo os passos abaixo.

### 1. Firebase (Firestore, Storage e Auth)

1. Peça acesso ao projeto Firebase da equipe.
2. Instale as ferramentas:
   ```sh
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   firebase login
   ```
3. Dentro de `app/`, rode e escolha o projeto da equipe, marcando **android** e
   **ios**:
   ```sh
   flutterfire configure
   ```
   Isso gera `android/app/google-services.json`,
   `ios/Runner/GoogleService-Info.plist`, `lib/firebase_options.dart` e
   `firebase.json` (todos no `.gitignore`) e aplica o plugin do Google
   Services no Gradle.

Sem esse passo o app abre normalmente, mas sem Firebase (`initFirebase` só
registra o erro no console).

### 2. Chave do Google Maps

A chave fica no projeto do Google Cloud ligado ao Firebase, em
**APIs e serviços → Credenciais**, com as APIs *Maps SDK for Android* e
*Maps SDK for iOS* ativadas e **restrita ao app**:

- Android: pacote `com.winery.winery_finder` + SHA-1 do seu certificado de
  debug (`keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android`).
- iOS: bundle ID `com.winery.wineryFinder`.

Depois coloque a chave nos dois arquivos locais (nunca faça commit deles):

- Android — em `android/local.properties`, adicione `MAPS_API_KEY=<sua chave>`.
- iOS — copie `ios/Flutter/Secrets.xcconfig.example` para
  `ios/Flutter/Secrets.xcconfig` e troque o valor de `MAPS_API_KEY`.

### 3. Spike de mapa e rota

```sh
flutter run -t lib/main_spike.dart
```

Deve aparecer o mapa com um pin na Casa Valduga; **Traçar rota** abre o Google
Maps (Android) ou o Apple Maps (iOS). Mapa cinza = chave ausente ou sem
restrição correta.

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
  main.dart                  Ponto de entrada (inicializa o Firebase)
  main_spike.dart            Ponto de entrada do spike de mapa e rota
  bootstrap.dart             Inicialização do Firebase
  app.dart                   MaterialApp e tema
  catalog/                   Leitura/validação da planilha da carga inicial (US32)
  domain/                    Modelos e regras puras (sem Flutter/Firebase)
    winery.dart
    winery_filter.dart
  features/
    home/home_shell.dart     Navegação inferior entre as abas
    map/                     Aba Mapa
    favorites/               Aba Favoritos
    recents/                 Aba Recentes
    spike/                   Spike de mapa + link de rota (TT01)
  widgets/                   Componentes compartilhados
tool/
  import_wineries.dart       Carga inicial no Firestore — veja tool/catalog/README.md
  catalog/vinicolas.csv      Planilha padrão das vinícolas
test/
  catalog/                   Testes da carga inicial
  domain/                    Testes unitários
  features/                  Testes de widget
```

## Lint

As regras ficam em `analysis_options.yaml`: `flutter_lints` como base, modo
estrito do analisador (`strict-casts`, `strict-inference`, `strict-raw-types`)
e alguns avisos promovidos a erro. O CI roda com `--fatal-infos`, então
qualquer aviso derruba a pipeline.
