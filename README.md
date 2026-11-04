# 🍇 Winery Finder — Documentação Detalhada do Projeto

O **Winery Finder** é uma plataforma desenvolvida em Flutter projetada para conectar apreciadores de vinho a vinícolas do Brasil e do mundo, oferecendo navegação por mapa interativo, catálogo completo de vinhos, sistema de vendas com pagamento direto, diretório de sommeliers profissionais, blog coletivo de harmonização e controle de favoritos.

---

## 📋 Sumário
1. [Visão Geral e Perfis de Usuário](#-visão-geral-e-perfis-de-usuário)
2. [Arquitetura e Módulos do Sistema](#-arquitetura-e-módulos-do-sistema)
3. [Regras de Negócio e Permissões por Perfil](#-regras-de-negócio-e-permissões-por-perfil)
4. [📱 Detalhamento das Telas e Funcionalidades](#-detalhamento-das-telas-e-funcionalidades)
5. [📖 Tutorial Passo a Passo do Usuário](#-tutorial-passo-a-passo-do-usuário)
6. [Modelagem de Dados (Domain)](#-modelagem-de-dados-domain)
7. [Qualidade e Testes Automatizados](#-qualidade-e-testes-automatizados)
8. [Como Executar e Subir para o GitHub](#-como-executar-e-subir-para-o-github)

---

## 🎯 Visão Geral e Perfis de Usuário

O projeto contempla **3 Perfis Principais de Usuário** e o **Administrador Master**:

1. **🏢 Perfil Vinícola / Produtor**:
   - Cadastra a vinícola (logo, fotos, endereço, proprietário, sommelier, uvas cultivadas).
   - Cadastra, ativa/inativa, altera preços e gerencia produtos (vinhos) à venda com link de pagamento direto (*MercadoPago, WhatsApp, Loja Online*).
   - Acessa o **Diretório de Sommeliers** e participa de comentários no **Blog Coletivo**.

2. **🎓 Perfil Sommelier Profissional**:
   - Mantém um **Histórico Profissional**, **Formação Profissional / Certificações** (ex: *WSET, ABS, FISAR*) e **Informações de Contato**.
   - Publica matérias, avaliações de safras e notas de degustação no **Blog Coletivo**.
   - Aparece em destaque no **Diretório de Sommeliers Profissionais**.

3. **🍷 Perfil Admirador de Vinhos (Consumidor)**:
   - Explora vinícolas pelo **Mapa Interativo (OpenStreetMap)** e filtra por tipos de vinho.
   - Salva vinícolas favoritas com um toque.
   - Consulta matérias publicadas pelos Sommeliers e comenta no **Blog Coletivo**.
   - Compra vinhos com direcionamento para link de pagamento direct.

4. **🛡️ Perfil Administrador (`admin@winery.com`)**:
   - Acesso exclusivo ao **Painel do Administrador** para editar cadastros, bloquear/desbloquear usuários ou excluir contas e gerenciar todas as contribuições da plataforma.

---

## 🏗️ Arquitetura e Módulos do Sistema

O projeto segue os princípios de separação de responsabilidades e arquitetura modular:

```
lib/
├── main.dart                      # Ponto de entrada da aplicação
├── app.dart                       # Configuração do MaterialApp, tema em cor vinho e controle de sessão
├── domain/                        # Regras de negócio e modelos de dados
│   ├── user_account.dart          # Modelo de usuário (Perfis: Vinícola, Sommelier, Admirador, Admin)
│   ├── winery.dart                # Modelo de vinícola (Nome, Responsável, Sommelier, Uvas, Fotos, Coordenadas)
│   ├── wine_product.dart          # Modelo de vinho à venda (Preço, Uva, Safra, Link de Pagamento, Status Ativo)
│   ├── blog_post.dart             # Modelo de publicações e comentários do Blog Coletivo
│   └── winery_filter.dart         # Lógica pura de busca, ordenação por distância e filtros
├── data/                          # Repositórios de dados e estado reativo
│   ├── auth_repository.dart       # Gestão de usuários, perfis, login, cadastro e controle de sessão
│   ├── winery_repository.dart     # Catálogo completo de vinícolas do Brasil e do mundo
│   ├── wine_repository.dart       # Gestão de produtos, adição, alteração de preço e inativação
│   ├── blog_repository.dart       # Repositório de postagens do Blog Coletivo e comentários
│   └── favorites_repository.dart  # Controle da lista de favoritos do usuário
├── features/                      # Telas e fluxos de interface do usuário (UI)
│   ├── auth/                      # Telas de Login (LoginScreen) e Cadastro (RegisterScreen)
│   ├── admin/                     # Painel do Administrador (AdminDashboardScreen) e Diálogo de Edição
│   ├── blog/                      # Blog Coletivo (BlogScreen) e Diretório de Sommeliers (SommeliersScreen)
│   ├── map/                       # Mapa (MapScreen), Cadastro de Vinícola, Painel de Produtos e Edição
│   ├── favorites/                 # Tela de Vinícolas Favoritas (FavoritesScreen)
│   └── home/                      # Casca de navegação inferior (HomeShell)
└── widgets/                       # Componentes visuais customizados
    ├── winery_logo.dart           # Logotipo vetorial realista em formato de cacho de uvas roxas
    └── vineyard_background.dart   # Fundo decorativo de videira com transparência vinho
```

---

## 🔒 Regras de Negócio e Permissões por Perfil

1. **Acesso Autenticado por Perfil**:
   - Todo usuário escolhe seu perfil (**Admirador**, **Sommelier** ou **Vinícola**) durante o cadastro.
2. **Gestão de Conteúdo e Vendas**:
   - **Apenas o usuário que cadastrou a vinícola** (ou o admin) pode alterar informações ou gerenciar vinhos à venda daquela vinícola.
   - **Sommeliers Profissionais** têm permissão exclusiva para publicar matérias no **Blog Coletivo**.
   - **Todos os cadastrados** (Admiradores, Vinícolas e Sommeliers) podem ler, comentar e interagir nas publicações do Blog Coletivo.
3. **Painel do Administrador**:
   - Exclusivo para `admin@winery.com` alterar cadastros, bloquear/desbloquear ou excluir usuários.

---

## 📱 Detalhamento das Telas e Funcionalidades

### 1. Tela de Login (`LoginScreen`)
- **Objetivo**: Acesso autenticado ao sistema.
- **Campos**: E-mail e Senha (com alternância de visibilidade).
- **Design**: Imagem decorativa de videira (`VineyardBackground`) e logotipo realista de cacho de uvas roxas (`WineryLogo`).

### 2. Tela de Cadastro de Usuário (`RegisterScreen`)
- **Objetivo**: Registrar um novo usuário selecionando o **Perfil do Usuário** (*Admirador*, *Sommelier*, *Vinícola*).
- **Campos Específicos para Sommelier**:
  - Formação Profissional / Certificações (ex: *WSET, ABS, FISAR*).
  - Histórico Profissional e Experiência.
  - Informações de Contato Profissional e Redes Sociais.

### 3. Tela Principal & Mapa Interativo (`MapScreen`)
- **Objetivo**: Apresentar o mapa de vinícolas, busca, filtros e rota **Como Chegar pelo Google Maps**.
- **Recursos**:
  - **Renderização de Mapa**: Azulejos do OpenStreetMap com marcadores de vinícolas.
  - **Botão "Como Chegar"**: Abre a navegação GPS curva a curva diretamente no aplicativo do **Google Maps** e traça a linha de rota na cor vinho no mapa interno.
  - **Chips de Tipos de Vinho**: Filtre por *Tinto, Branco, Espumante, Rosé*.

### 4. Blog Coletivo de Sommeliers (`BlogScreen`)
- **Objetivo**: Compartilhar conhecimentos, análises de safras e dicas de harmonização.
- **Funcionalidades**:
  - Leitura de matérias escritas por Sommeliers Profissionais.
  - **Aba de Comentários**: Espaço de debate interativo para Admiradores, Vinícolas e Sommeliers.
  - **Publicar no Blog**: Botão exclusivo para Sommeliers criarem novas postagens.

### 5. Diretório de Sommeliers Profissionais (`SommeliersScreen`)
- **Objetivo**: Apresentar o perfil profissional dos Sommeliers cadastrados.
- **Exibição**: Foto de perfil, Formação Profissional/Certificações, Histórico de Carreira e Dados de Contato.

### 6. Painel de Gestão de Produtos da Vinícola (`WineryProductsPanel`)
- **Objetivo**: Gerenciar os vinhos e preços à venda por vinícola.
- **Recursos**: Postar novo vinho, alterar preços e fotos, inativar/ativar produtos e botão de **Pagamento Direct**.

### 7. Painel do Administrador (`AdminDashboardScreen`)
- **Objetivo**: Controle centralizado exclusivo para `admin@winery.com`.
- **Ações**: Alterar cadastros, bloquear/desbloquear usuários e excluir contas.

---

## 📖 Tutorial Passo a Passo do Usuário

### Passo 1: Criando uma Conta por Perfil
1. Na tela de **Login**, clique em **"Não tem uma conta? Cadastre-se"**.
2. Escolha o seu **Tipo de Perfil de Usuário**:
   - **Admirador de Vinhos**: Para consultar vinícolas, vinhos, mapas e ler o blog.
   - **Sommelier Profissional**: Preencha também sua Formação Profissional (ex: *WSET Level 3*) e Histórico.
   - **Vinícola / Produtor**: Para cadastrar sua vinícola e gerenciar vinhos à venda.
3. Preencha seus dados pessoais e clique em **"Cadastrar Conta"**.

### Passo 2: Traçando Rota pelo Google Maps
1. No mapa ou na lista de vinícolas, clique no botão **"Como Chegar"**.
2. O aplicativo traçará a rota interna e abrirá o **Google Maps** com navegação GPS em tempo real.

### Passo 3: Participando do Blog Coletivo
1. Acesse a aba **Blog Coletivo** na navegação inferior.
2. Leia os artigos publicados pelos Sommeliers e clique em **"Comentar"** para enviar sua pergunta ou feedback.
3. Se você estiver logado como **Sommelier Profissional**, clique no botão **"+ Publicar no Blog"** para criar um novo artigo.

---

## 🧪 Qualidade e Testes Automatizados

- **Testes de Filtro (`winery_filter_test.dart`)**: Testam busca e ordenação por distância.
- **Testes de Widget (`home_shell_test.dart`)**: Testam navegação entre as 4 abas (*Mapa, Blog Coletivo, Sommeliers e Favoritos*).
- **Analisador Estático**: 0 avisos e 0 erros com `flutter analyze`.

---

## 📤 Como Executar e Subir para o GitHub

```bash
flutter pub get
flutter test
flutter analyze
flutter run
```

### Subindo para o GitHub (`robsonsp29`)
```bash
git remote set-url origin https://github.com/robsonsp29/winery.git
git push -u origin main --force
```
