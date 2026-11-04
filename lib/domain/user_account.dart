/// Tipos de Perfil de Usuário no sistema.
enum UserRole {
  admirer('Admirador de Vinhos'),
  sommelier('Sommelier Profissional'),
  winery('Vinícola / Produtor'),
  admin('Administrador');

  const UserRole(this.label);
  final String label;
}

/// Modelo de usuário com dados pessoais, papel/perfil e histórico do sommelier.
class UserAccount {
  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = UserRole.admirer,
    this.photoUrl = '',
    this.cpf = '',
    this.phone = '',
    this.address = '',
    this.isBlocked = false,
    this.professionalHistory = '',
    this.education = '',
    this.contactInfo = '',
  });

  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String photoUrl;
  final String cpf;
  final String phone;
  final String address;
  final bool isBlocked;

  // Campos específicos do Sommelier
  final String professionalHistory;
  final String education; // Formação profissional (ex: WSET Level 3, ABS)
  final String contactInfo;

  UserAccount copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    String? photoUrl,
    String? cpf,
    String? phone,
    String? address,
    bool? isBlocked,
    String? professionalHistory,
    String? education,
    String? contactInfo,
  }) {
    return UserAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isBlocked: isBlocked ?? this.isBlocked,
      professionalHistory: professionalHistory ?? this.professionalHistory,
      education: education ?? this.education,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }
}
