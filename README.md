# 🍇 Winery Finder — Documentação Detalhada do Projeto

O **Winery Finder** é uma plataforma desenvolvida em Flutter projetada para conectar apreciadores de vinho a vinícolas do Brasil e do mundo, oferecendo navegação por mapa interativo, catálogo completo de vinhos, sistema de vendas com pagamento direto, controle de favoritos e um painel de administração e gestão com controle rígido de acesso.

---

## 📋 Sumário
1. [Visão Geral e Objetivos](#-visão-geral-e-objetivos)
2. [Arquitetura e Módulos do Sistema](#-arquitetura-e-módulos-do-sistema)
3. [Regras de Negócio e Permissões de Acesso](#-regras-de-negócio-e-permissões-de-acesso)
4. [Funcionalidades Detalhadas](#-funcionalidades-detalhadas)
   - [A. Autenticação e Dados Pessoais](#a-autenticação-e-dados-pessoais)
   - [B. Mapa Interativo e Filtros por Vinho](#b-mapa-interativo-e-filtros-por-vinho)
   - [C. Cadastro de Vinícolas e Referência de Criador](#c-cadastro-de-vinícolas-e-referência-de-criador)
   - [D. Painel de Gestão de Produtos (Vinhos à Venda)](#d-painel-de-gestão-de-produtos-vinhos-à-venda)
   - [E. Painel do Administrador](#e-painel-do-administrador)
   - [F. Identidade Visual e Logotipo](#f-identidade-visual-e-logotipo)
5. [Modelagem de Dados (Domain)](#-modelagem-de-dados-domain)
6. [Qualidade e Testes Automatizados](#-qualidade-e-testes-automatizados)
7. [Como Executar e Subir para o GitHub](#-como-executar-e-subir-para-o-github)

---

## 🎯 Visão Geral e Objetivos

O projeto tem como objetivo proporcionar uma experiência rica e fluida para:
- **Consumidores / Turistas**: Localizarem vinícolas próximas através de um mapa interativo, filtrarem por tipos de vinho (*Tinto, Branco, Espumante, Rosé*), salvarem vinícolas favoritas e comprarem vinhos diretamente com a vinícola.
- **Produtores / Vinícolas**: Cadastrarem suas vinícolas com fotos do computador, logotipo, uvas cultivadas, sommelier e gerenciarem seus vinhos à venda (preços, status de ativação/inativação, fotos e links de pagamento).
- **Administrador**: Gerenciar de forma centralizada todos os usuários e contribuições cadastradas no sistema.

---

## 🏗️ Arquitetura e Módulos do Sistema

O projeto segue os princípios de separação de responsabilidades e arquitetura modular:

```
lib/
├── main.dart                      # Ponto de entrada da aplicação
├── app.dart                       # Configuração do MaterialApp, tema em cor vinho e controle de sessão
├── domain/                        # Regras de negócio e modelos de dados
│   ├── user_account.dart          # Modelo de usuário (Nome, CPF, Tel, Endereço, Foto, Senha)
│   ├── winery.dart                # Modelo de vinícola (Nome, Responsável, Sommelier, Uvas, Fotos, Coordenadas)
│   ├── wine_product.dart          # Modelo de vinho à venda (Preço, Uva, Safra, Link de Pagamento, Status Ativo)
│   └── winery_filter.dart         # Lógica pura de busca, ordenação por distância e filtros
├── data/                          # Repositórios de dados e estado reativo
│   ├── auth_repository.dart       # Gestão de usuários, login, cadastro e controle de sessão
│   ├── winery_repository.dart     # Catálogo completo de vinícolas do Brasil e do mundo
│   ├── wine_repository.dart       # Gestão de produtos, adição, alteração de preço e inativação
│   └── favorites_repository.dart  # Controle da lista de favoritos do usuário
├── features/                      # Telas e fluxos de interface do usuário (UI)
│   ├── auth/                      # Telas de Login (LoginScreen) e Cadastro (RegisterScreen)
│   ├── admin/                     # Painel do Administrador (AdminDashboardScreen) e Diálogo de Edição
│   ├── map/                       # Mapa (MapScreen), Cadastro de Vinícola, Painel de Produtos e Edição
│   ├── favorites/                 # Tela de Vinícolas Favoritas (FavoritesScreen)
│   ├── recents/                   # Tela de Histórico Recente
│   └── home/                      # Casca de navegação inferior (HomeShell)
└── widgets/                       # Componentes visuais customizados
    ├── winery_logo.dart           # Logotipo vetorial em formato de cacho de uvas
    ├── vineyard_background.dart   # Fundo decorativo de videira com transparência vinho
    └── placeholder_screen.dart    # Componente de telas padrão
```

---

## 🔒 Regras de Negócio e Permissões de Acesso

1. **Acesso por Usuário e Senha**:
   - Todo usuário deve possuir uma conta própria para entrar no aplicativo.
   - Os dados cadastrados são mantidos de forma independente por usuário.
2. **Isolamento de Alteração de Postagens**:
   - **Apenas o usuário que cadastrou a vinícola** (e o administrador) possui permissão para editar informações ou postar/gerenciar os vinhos à venda dessa vinícola.
   - Para qualquer outro usuário, as opções de alteração, postagem, edição de preço, inativação ou exclusão são **estritamente proibidas e ocultadas**.
3. **Restrição do Painel do Administrador**:
   - O **Painel do Administrador** é exclusivo do usuário `admin@winery.com`. Se qualquer outro usuário tentar acessar a tela, receberá uma mensagem de **Acesso Restrito/Negado**.

---

## ✨ Funcionalidades Detalhadas

### A. Autenticação e Dados Pessoais
- **Cadastro Completo**: O formulário de criação de conta coleta:
  - Foto de Perfil Pessoal (carregada do computador/dispositivo com pré-visualização).
  - Nome Completo, CPF, Telefone/Celular e Endereço Completo.
  - E-mail e Senha.
- **Login Seguro**: Entrada por e-mail e senha com opção de mostrar/ocultar senha e botão de logout.

### B. Mapa Interativo e Filtros por Vinho
- **Renderização de Mapa**: Utiliza `flutter_map` e OpenStreetMap com centralização inicial no Vale dos Vinhedos (Bento Gonçalves, RS).
- **Busca em Tempo Real**: Filtro por texto (nome da vinícola ou cidade).
- **Chips de Seleção de Vinhos**: Filtre simultaneamente por tipos (*Tinto, Branco, Espumante, Rosé*).
- **Marcadores Interativos**: Ao tocar no marcador do mapa, o mapa foca na vinícola e abre o painel de detalhes.

### C. Cadastro de Vinícolas e Referência de Criador
- **Ordem do Formulário de Cadastro (`RegisterWineryDialog`)**:
  1. **Logo da Vinícola (em 1º lugar)**: Botão para carregar arquivo direto do computador com pré-visualização em miniatura.
  2. **Nome do Proprietário / Responsável (em 2º lugar)**.
  3. Nome da Vinícola, Cidade, Endereço Completo, Distância, Avaliação, Sommelier e Uvas Cultivadas.
  4. Galeria de Fotos do estabelecimento.
- **Referência do Criador**: O e-mail do usuário criador é registrado na propriedade `creatorEmail` e exibido na ficha pública.

### D. Painel de Gestão de Produtos (Vinhos à Venda)
- **Painel da Vinícola (`WineryProductsPanel`)**: Acessível pelo botão "Painel de Produtos" na ficha da vinícola (restrito ao criador/admin).
- **Recursos**:
  - **Postar Novo Vinho**: Nome, tipo, uva utilizada, safra, preço (R$), link de pagamento e foto do produto.
  - **Alterar Preços e Fotos**: Formulário de edição rápida (`EditWineDialog`).
  - **Inativar / Ativar**: Alternância de disponibilidade com badge visual (*Ativo = Verde / Inativo = Cinza*).
  - **Excluir Produto**: Remoção de itens do catálogo.
  - **Link de Pagamento Direct**: Botão "Comprar / Pagamento Direct" que direciona o comprador para o link de checkout do vendedor.

### E. Painel do Administrador
- **Acesso Exclusivo (`admin@winery.com`)**:
  - **Aba Usuários Cadastrados**: Lista todos os usuários, suas fotos de perfil, CPF, telefone e permite ao admin editar dados ou remover usuários.
  - **Aba Todas Contribuições**: Lista todas as vinícolas cadastradas na plataforma com a indicação de quem as criou.

### F. Identidade Visual e Logotipo
- **Tema Vinho (Burgundy `#722F37`)**: Paleta de cores em conformidade com o Material 3.
- **Logotipo Cacho de Uvas (`WineryLogo`)**: Desenhado com bagas circulares, cabinho e folha de parreira em verde sutil.
- **Fundo de Videira (`VineyardBackground`)**: Imagem de fundo de vinhedo com sobreposição escura em gradiente vinho.

---

## 📊 Modelagem de Dados (Domain)

```dart
// Vinícola
class Winery {
  final String id;
  final String name;
  final String city;
  final Set<WineType> wineTypes;
  final double distanceKm;
  final double rating;
  final double latitude;
  final double longitude;
  final String address;
  final String logoUrl;
  final List<String> photoUrls;
  final String responsibleName;
  final String sommelierName;
  final List<String> cultivatedGrapes;
  final String creatorEmail;
}

// Vinho / Produto
class WineProduct {
  final String id;
  final String wineryId;
  final String name;
  final WineType type;
  final String vintage;
  final double price;
  final String grape;
  final String description;
  final String imageUrl;
  final List<String> photoUrls;
  final String paymentLink;
  final bool isActive;
  final String creatorEmail;
}

// Usuário
class UserAccount {
  final String id;
  final String name;
  final String email;
  final String password;
  final String photoUrl;
  final String cpf;
  final String phone;
  final String address;
}
```

---

## 🧪 Qualidade e Testes Automatizados

O projeto conta com suíte de testes unitários e de widgets com cobertura das principais funcionalidades:
- **Testes de Filtro (`winery_filter_test.dart`)**: Testam ordenação por distância, busca textual insensível a maiúsculas/minúsculas, múltiplos tipos de vinho e formatação de metros/quilômetros.
- **Testes de Widget (`home_shell_test.dart`)**: Testam autenticação e navegação entre abas.
- **Analisador Estático**: 0 avisos e 0 erros com `flutter analyze`.

---

## 📤 Como Executar e Subir para o GitHub

### Executando Localmente
```bash
flutter pub get
flutter test
flutter analyze
flutter run
```

### Credenciais Padrão do Administrador
- **E-mail**: `admin@winery.com`
- **Senha**: `Winery123@@@!!!`

### Subindo para o GitHub (`robsonsp29`)
1. Crie um repositório no seu GitHub: [https://github.com/new](https://github.com/new) com o nome `winery`.
2. No terminal do Android Studio, execute:
```bash
git remote set-url origin https://github.com/robsonsp29/winery.git
git push -u origin main --force
```
