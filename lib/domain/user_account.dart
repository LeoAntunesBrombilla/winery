/// Modelo de usuário com dados pessoais completos para o sistema de autenticação.
class UserAccount {
  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.photoUrl = '',
    this.cpf = '',
    this.phone = '',
    this.address = '',
  });

  final String id;
  final String name;
  final String email;
  final String password;
  final String photoUrl;
  final String cpf;
  final String phone;
  final String address;

  UserAccount copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? photoUrl,
    String? cpf,
    String? phone,
    String? address,
  }) {
    return UserAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      photoUrl: photoUrl ?? this.photoUrl,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
