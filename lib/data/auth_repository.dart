import 'package:flutter/foundation.dart';
import 'package:winery_finder/domain/user_account.dart';

/// Repositório de autenticação de usuários (suporta cadastro, edição pelo admin, bloqueio/desbloqueio e sessão).
class AuthRepository extends ChangeNotifier {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final List<UserAccount> _registeredUsers = <UserAccount>[
    // Usuário administrador padrão
    UserAccount(
      id: '1',
      name: 'Admin Winery',
      email: 'admin@winery.com',
      password: 'Winery123@@@!!!',
      cpf: '000.000.000-00',
      phone: '(54) 99999-9999',
      address: 'Bento Gonçalves, RS',
    ),
  ];

  UserAccount? _currentUser;

  UserAccount? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  List<UserAccount> get registeredUsers => List<UserAccount>.unmodifiable(_registeredUsers);

  /// Cadastra um novo usuário no sistema com dados pessoais completos e foto de perfil.
  bool signup({
    required String name,
    required String email,
    required String password,
    String photoUrl = '',
    String cpf = '',
    String phone = '',
    String address = '',
  }) {
    // Verifica se email já existe
    final exists = _registeredUsers.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (exists) return false;

    final newUser = UserAccount(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: email.trim(),
      password: password,
      photoUrl: photoUrl,
      cpf: cpf.trim(),
      phone: phone.trim(),
      address: address.trim(),
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
        _currentUser = null; // Desloga usuário se for bloqueado
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

  /// Realiza o login com email e senha (impede login se o usuário estiver bloqueado).
  bool login({
    required String email,
    required String password,
  }) {
    try {
      final user = _registeredUsers.firstWhere(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase() && u.password == password,
      );
      if (user.isBlocked) return false; // Bloqueado
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
