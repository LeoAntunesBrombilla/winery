import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:winery_finder/data/auth_repository.dart';
import 'package:winery_finder/domain/user_account.dart';
import 'package:winery_finder/widgets/vineyard_background.dart';
import 'package:winery_finder/widgets/winery_logo.dart';

/// Tela de Cadastro de novo usuário com dados pessoais, seleção de Perfil (Vinícola, Sommelier, Admirador) e foto.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Campos específicos do Sommelier
  final TextEditingController _historyController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();

  UserRole _selectedRole = UserRole.admirer;
  bool _obscurePassword = true;

  final ImagePicker _picker = ImagePicker();
  String? _photoPath;
  Uint8List? _photoBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _historyController.dispose();
    _educationController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _photoPath = image.path;
        _photoBytes = bytes;
      });
    }
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }

    final success = AuthRepository.instance.signup(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: _selectedRole,
      photoUrl: _photoPath ?? '',
      cpf: _cpfController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      professionalHistory: _historyController.text,
      education: _educationController.text,
      contactInfo: _contactInfoController.text,
    );

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conta de ${_selectedRole.label} criada com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este e-mail já está cadastrado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Usuário')),
      body: VineyardBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 8,
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const WineryLogo(size: 70),
                        const SizedBox(height: 16),
                        Text(
                          'Criar Conta no Winery Finder',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // Seleção do Perfil
                        DropdownButtonFormField<UserRole>(
                          initialValue: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Perfil de Usuário *',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: UserRole.admirer,
                              child: Text('Admirador de Vinhos (Consumidor)'),
                            ),
                            DropdownMenuItem(
                              value: UserRole.sommelier,
                              child: Text('Sommelier Profissional'),
                            ),
                            DropdownMenuItem(
                              value: UserRole.winery,
                              child: Text('Vinícola / Produtor'),
                            ),
                          ],
                          onChanged: (role) {
                            if (role != null) setState(() => _selectedRole = role);
                          },
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _pickProfilePhoto,
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            backgroundImage: _photoBytes != null ? MemoryImage(_photoBytes!) : null,
                            child: _photoBytes == null
                                ? const Icon(Icons.add_a_photo, size: 32)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _pickProfilePhoto,
                          icon: const Icon(Icons.photo_camera, size: 18),
                          label: const Text('Adicionar Foto Pessoal'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome Completo *',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Informe seu nome' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cpfController,
                                decoration: const InputDecoration(
                                  labelText: 'CPF',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Telefone / Celular',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Endereço Completo',
                            prefixIcon: Icon(Icons.home_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        // Campos Específicos do Sommelier
                        if (_selectedRole == UserRole.sommelier) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.school, color: Color(0xFF722F37)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Perfil do Sommelier Profissional',
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _educationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Formação Profissional / Certificações (ex: WSET, ABS) *',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (val) => _selectedRole == UserRole.sommelier && (val == null || val.trim().isEmpty)
                                      ? 'Informe a formação profissional'
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _historyController,
                                  maxLines: 2,
                                  decoration: const InputDecoration(
                                    labelText: 'Histórico e Experiência Profissional *',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (val) => _selectedRole == UserRole.sommelier && (val == null || val.trim().isEmpty)
                                      ? 'Informe o histórico profissional'
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _contactInfoController,
                                  decoration: const InputDecoration(
                                    labelText: 'Contatos / Redes Sociais',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-mail *',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Informe seu e-mail' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Senha *',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.length < 3 ? 'A senha deve ter pelo menos 3 caracteres' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscurePassword,
                          decoration: const InputDecoration(
                            labelText: 'Confirmar Senha *',
                            prefixIcon: Icon(Icons.lock_reset),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.isEmpty ? 'Confirme sua senha' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: _handleRegister,
                            child: const Text('Cadastrar Conta', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
