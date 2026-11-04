import 'package:flutter/foundation.dart';
import 'package:winery_finder/domain/user_account.dart';

/// Repositório de autenticação de usuários (suporta perfis de Vinícola, Sommelier e Admirador).
class AuthRepository extends ChangeNotifier {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final List<UserAccount> _registeredUsers = <UserAccount>[
    // Administrador Master
    const UserAccount(
      id: '1',
      name: 'Admin Winery',
      email: 'admin@winery.com',
      password: 'Winery123@@@!!!',
      role: UserRole.admin,
      cpf: '000.000.000-00',
      phone: '(54) 99999-9999',
      address: 'Bento Gonçalves, RS',
    ),
    // Sommelier 1
    const UserAccount(
      id: 'som_1',
      name: 'Sommelier Marcelo Rossi',
      email: 'marcelo.sommelier@winery.com',
      password: '123',
      role: UserRole.sommelier,
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
      phone: '(54) 98877-6655',
      address: 'Bento Gonçalves, RS',
      professionalHistory: '12 anos de experiência em restaurantes renomados e consultoria para vinícolas no Vale dos Vinhedos.',
      education: 'WSET Level 3 Advanced, ABS-RS (Associação Brasileira de Sommeliers)',
      contactInfo: 'marcelo.sommelier@winery.com | Instagram: @marcelorossi_wine',
    ),
    // Sommelier 2
    const UserAccount(
      id: 'som_2',
      name: 'Sommellière Renata Valduga',
      email: 'renata.sommelier@winery.com',
      password: '123',
      role: UserRole.sommelier,
      photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
      phone: '(54) 97766-5544',
      address: 'Garibaldi, RS',
      professionalHistory: 'Especialista em espumantes e vinhos finos da Serra Gaúcha e terroir de altitude de Santa Catarina.',
      education: 'Sommelier Profissional FISAR (Itália) & ASI Diploma International',
      contactInfo: 'renata.sommelier@winery.com | Tel: (54) 97766-5544',
    ),
  ];

  UserAccount? _currentUser;

  UserAccount? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  List<UserAccount> get registeredUsers => List<UserAccount>.unmodifiable(_registeredUsers);

  /// Retorna apenas os usuários cadastrados como Sommeliers
  List<UserAccount> get registeredSommeliers =>
      _registeredUsers.where((u) => u.role == UserRole.sommelier).toList();

  /// Cadastra um novo usuário no sistema com perfil (Vinícola, Sommelier ou Admirador).
  bool signup({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.admirer,
    String photoUrl = '',
    String cpf = '',
    String phone = '',
    String address = '',
    String professionalHistory = '',
    String education = '',
    String contactInfo = '',
  }) {
    // Verifica se e-mail já existe
    final exists = _registeredUsers.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (exists) return false;

    final newUser = UserAccount(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: email.trim(),
      password: password,
      role: role,
      photoUrl: photoUrl,
      cpf: cpf.trim(),
      phone: phone.trim(),
      address: address.trim(),
      professionalHistory: professionalHistory.trim(),
      education: education.trim(),
      contactInfo: contactInfo.trim(),
    );

    _registeredUsers.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    return true;
  }

  /// Permite ao administrador atualizar dados de um usuário cadastrado.
  bool updateUser(UserAccount updatedUser) {
    final index = _registeredUsers.indexWhere((u) => u.id == updatedUser.id);
    if (index == -1) return false;
    _registeredUsers[index] = updatedUser;
    if (_currentUser?.id == updatedUser.id) {
      _currentUser = updatedUser;
    }
    notifyListeners();
    return true;
  }

  /// Alterna o status de bloqueio do usuário (Bloquear / Desbloquear).
  void toggleUserBlockStatus(String id) {
    final index = _registeredUsers.indexWhere((u) => u.id == id);
    if (index != -1 && _registeredUsers[index].email != 'admin@winery.com') {
      final user = _registeredUsers[index];
      _registeredUsers[index] = user.copyWith(isBlocked: !user.isBlocked);
      if (_currentUser?.id == id && _registeredUsers[index].isBlocked) {
        _currentUser = null;
      }
      notifyListeners();
    }
  }

  /// Permite ao administrador remover um usuário cadastrado.
  void deleteUser(String id) {
    _registeredUsers.removeWhere((u) => u.id == id && u.email != 'admin@winery.com');
    if (_currentUser?.id == id) {
      _currentUser = null;
    }
    notifyListeners();
  }

  /// Realiza o login com email e senha.
  bool login({
    required String email,
    required String password,
  }) {
    try {
      final user = _registeredUsers.firstWhere(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase() && u.password == password,
      );
      if (user.isBlocked) return false;
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Encerra a sessão atual.
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
