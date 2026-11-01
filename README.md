# 🍇 Winery Finder — Documentação Detalhada do Projeto

O **Winery Finder** é uma plataforma desenvolvida em Flutter projetada para conectar apreciadores de vinho a vinícolas do Brasil e do mundo, oferecendo navegação por mapa interativo, catálogo completo de vinhos, sistema de vendas com pagamento direto, controle de favoritos e um painel de administração e gestão com controle rígido de acesso.

---

## 📋 Sumário
1. [Visão Geral e Objetivos](#-visão-geral-e-objetivos)
2. [Arquitetura e Módulos do Sistema](#-arquitetura-e-módulos-do-sistema)
3. [Regras de Negócio e Permissões de Acesso](#-regras-de-negócio-e-permissões-de-acesso)
4. [📱 Detalhamento das Telas e Funcionalidades](#-detalhamento-das-telas-e-funcionalidades)
5. [📖 Tutorial Passo a Passo do Usuário](#-tutorial-passo-a-passo-do-usuário)
6. [Modelagem de Dados (Domain)](#-modelagem-de-dados-domain)
7. [Qualidade e Testes Automatizados](#-qualidade-e-testes-automatizados)
8. [Como Executar e Subir para o GitHub](#-como-executar-e-subir-para-o-github)

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

## 📱 Detalhamento das Telas e Funcionalidades

### 1. Tela de Login (`LoginScreen`)
- **Objetivo**: Garantir o acesso autenticado ao sistema.
- **Campos**: E-mail e Senha (com funcionalidade de alternar visibilidade de senha).
- **Design**: Sobreposição elegante sobre imagem de fundo de videira (`VineyardBackground`) e logotipo de cacho de uvas (`WineryLogo`).
- **Ações**: Botão "Entrar" e atalho "Não tem uma conta? Cadastre-se".

### 2. Tela de Cadastro de Usuário (`RegisterScreen`)
- **Objetivo**: Registrar um novo usuário com dados pessoais completos.
- **Campos**:
  - Foto de Perfil Pessoal (carregada do computador/dispositivo com pré-visualização circular).
  - Nome Completo, CPF, Telefone / Celular e Endereço Completo.
  - E-mail, Senha e Confirmação de Senha.
- **Validação**: Validação em tempo real de campos obrigatórios, confirmação de senha e e-mails duplicados.

### 3. Tela Principal & Mapa Interativo (`MapScreen`)
- **Objetivo**: Apresentar o mapa de vinícolas, busca, filtros e catálogo.
- **Recursos**:
  - **Renderização de Mapa**: Azulejos do OpenStreetMap com marcadores de vinícolas em tom vinho (`#722F37`).
  - **Barra de Pesquisa**: Filtro por texto em tempo real para nome da vinícola ou cidade.
  - **Chips de Tipos de Vinho**: Seleção múltipla para filtrar por *Tinto, Branco, Espumante, Rosé*.
  - **Lista Inferior de Vinícolas**: Exibe distância formatada (m/km), cidade, avaliação (1 a 5 estrelas) e logo.
  - **Botão de Coração**: Favoritar/desfavoritar vinícolas diretamente da lista ou no painel de detalhes.
  - **Ficha de Detalhes da Vinícola**: Desliza ao selecionar uma vinícola, exibindo endereço completo, responsável, sommelier, uvas cultivadas, fotos e e-mail do criador.
  - **Ações da Barra Superior (AppBar)**:
    - Botão "Cadastrar Vinícola" (abre o formulário de cadastro).
    - Ícone de escudo "Painel do Administrador" (visível estritamente para `admin@winery.com`).
    - Botão "Sair da Conta" (Logout).

### 4. Formulário de Cadastro de Vinícola (`RegisterWineryDialog`)
- **Objetivo**: Permitir o cadastro de novas vinícolas com informações completas.
- **Ordem dos Campos**:
  1. **Logo da Vinícola (em 1º lugar)**: Seleção de arquivo de logo do computador/dispositivo com visualização prévia.
  2. **Nome do Proprietário / Responsável (em 2º lugar)**: Campo obrigatório para identificação do gestor.
  3. Nome da Vinícola, Cidade/Região e Endereço Completo.
  4. Distância estimada (km) e Avaliação.
  5. Sommelier e Uvas Cultivadas (*separadas por vírgula*).
  6. **Fotos da Vinícola**: Seleção de múltiplas fotos diretamente do computador com carrossel de pré-visualização.
  7. Chips de Seleção dos Tipos de Vinho produzidos.
- **Associação**: Vincula automaticamente o e-mail do usuário logado na propriedade `creatorEmail`.

### 5. Painel de Gestão de Produtos da Vinícola (`WineryProductsPanel`)
- **Objetivo**: Gerenciar os vinhos e preços à venda por vinícola.
- **Controle de Acesso**: Exclusivo para a vinícola criadora responsável ou para o administrador master.
- **Recursos**:
  - **Postar Novo Vinho**: Abre o `RegisterWineDialog`.
  - **Inativar / Ativar**: Alternar visibilidade pública do vinho (*Ativo = Verde / Inativo = Cinza*).
  - **Editar / Alterar Preço**: Edição de dados e preços via `EditWineDialog`.
  - **Excluir Produto**: Remoção permanente do produto.

### 6. Diálogos de Postagem e Edição de Vinhos (`RegisterWineDialog` / `EditWineDialog`)
- **Objetivo**: Postar ou atualizar vinhos e preços.
- **Campos**:
  - Card em destaque com o nome da vinícola vinculada.
  - Nome do Vinho, Tipo de Vinho, Uva Utilizada e Safra.
  - **Preço de Venda (R\$)** e **Link de Pagamento Direct** (*MercadoPago, WhatsApp, Loja Online*).
  - Foto do Vinho (carregamento direto do computador/dispositivo).
  - Breve Descrição / Notas de Degustação.

### 7. Painel do Administrador (`AdminDashboardScreen`)
- **Objetivo**: Controle centralizado da plataforma (Exclusivo para `admin@winery.com`).
- **Abas**:
  - **Aba 1 (Usuários Cadastrados)**: Lista todos os usuários cadastrados, com suas fotos de perfil, CPF, telefone e e-mail. Permite ao admin abrir o `EditUserDialog` para alterar qualquer dado do usuário ou excluir contas.
  - **Aba 2 (Todas Contribuições)**: Lista unificada de todas as vinícolas cadastradas com indicação do criador.

### 8. Tela de Vinícolas Favoritas (`FavoritesScreen`)
- **Objetivo**: Exibir e gerenciar vinícolas favoritadas pelo usuário.
- **Recursos**: Lista todas as vinícolas marcadas com o ícone de coração vermelho, permitindo desfavoritar com um toque.

---

## 📖 Tutorial Passo a Passo do Usuário

### Passo 1: Criando uma Conta e Fazendo Login
1. Abra o aplicativo na tela de **Login**.
2. Caso ainda não possua conta, clique em **"Não tem uma conta? Cadastre-se"**.
3. Na tela de **Cadastro de Usuário**:
   - Toque no ícone de câmera para selecionar sua **Foto de Perfil** direto do computador ou galeria.
   - Preencha seu **Nome Completo**, **CPF**, **Telefone**, **Endereço Completo**, **E-mail** e **Senha**.
   - Clique no botão **"Cadastrar"**.
4. Retorne à tela de Login, insira seu e-mail e senha cadastrados e clique em **"Entrar"**.

### Passo 2: Explorando o Mapa e Vinícolas
1. Ao entrar, a tela principal abre na aba **Mapa**, exibindo o mapa de vinícolas e a lista de locais próximos.
2. Digite o nome de uma cidade ou vinícola na barra de pesquisa (ex: *Bento Gonçalves*, *Miolo*, *Valduga*).
3. Selecione os chips de filtro (*Tinto, Branco, Espumante, Rosé*) para filtrar as vinícolas no mapa em tempo real.
4. Toque no ícone de **Coração** de qualquer vinícola para adicioná-la aos seus **Favoritos**.

### Passo 3: Cadastrando uma Nova Vinícola
1. Toque no botão flutuante **"+ Cadastrar Vinícola"** (ou no ícone de localização no topo da tela).
2. No formulário:
   - Clique em **"Escolher Logo"** para selecionar o logo da vinícola direto do seu computador.
   - Digite o **Nome do Proprietário / Responsável** no campo logo abaixo.
   - Preencha o nome da vinícola, cidade, endereço, sommelier, uvas cultivadas e selecione fotos da vinícola.
3. Clique em **"Cadastrar"**. A vinícola aparecerá imediatamente no mapa vinculada ao seu e-mail de usuário!

### Passo 4: Postando e Gerenciando Vinhos para Venda
1. Toque na vinícola que você cadastrou para abrir o painel de detalhes.
2. Como você é o criador responsável, clique no botão **"Painel de Produtos"**.
3. No painel de gestão da vinícola:
   - Clique em **"Cadastrar Produto"** para postar um vinho à venda.
   - Informe o nome do vinho, uva utilizada, safra, preço em R\$, insira o **Link de Pagamento** (*MercadoPago/WhatsApp*) e selecione a **Foto do Vinho** do computador.
   - Clique em **"Postar Vinho"**.
4. No painel de gestão, você pode a qualquer momento **Alterar Preço**, **Inativar/Ativar** o produto para ocultá-lo do público ou **Excluir**.

### Passo 5: Acessando o Painel do Administrador (Exclusivo `admin@winery.com`)
1. Faça login utilizando a conta master de administrador (`admin@winery.com`).
2. Um ícone de escudo aparecerá no topo do mapa. Toque nele para abrir o **Painel do Administrador**.
3. Na **Aba Usuários Cadastrados**, visualize a foto, CPF, telefone e e-mail de todos os usuários, podendo editar seus dados ou excluir contas.
4. Na **Aba Todas Contribuições**, acompanhe todas as vinícolas cadastradas e quem as criou na plataforma.

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

### Subindo para o GitHub (`robsonsp29`)
1. Crie um repositório no seu GitHub: [https://github.com/new](https://github.com/new) com o nome `winery`.
2. No terminal do Android Studio, execute:
```bash
git remote set-url origin https://github.com/robsonsp29/winery.git
git push -u origin main --force
```
