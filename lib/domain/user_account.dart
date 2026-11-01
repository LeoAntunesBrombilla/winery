/// Modelo de usuário com dados pessoais completos e status de bloqueio.
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
    this.isBlocked = false,
  });

  final String id;
  final String name;
  final String email;
  final String password;
  final String photoUrl;
  final String cpf;
  final String phone;
  final String address;
  final bool isBlocked;

  UserAccount copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? photoUrl,
    String? cpf,
    String? phone,
    String? address,
    bool? isBlocked,
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
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
