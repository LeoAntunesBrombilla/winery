import 'package:flutter/material.dart';
import 'package:winery_finder/data/auth_repository.dart';
import 'package:winery_finder/features/auth/register_screen.dart';
import 'package:winery_finder/widgets/vineyard_background.dart';
import 'package:winery_finder/widgets/winery_logo.dart';

/// Tela de Login para acesso ao sistema com suporte a "Esqueceu a senha?".
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    final success = AuthRepository.instance.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail ou senha incorretos ou usuário bloqueado.')),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final emailResetController = TextEditingController(text: _emailController.text.trim());

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Esqueceu a senha?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informe o seu e-mail cadastrado no sistema para receber o link e redefinir sua senha.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailResetController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail Cadastrado *',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final email = emailResetController.text.trim();
                if (email.isEmpty) return;

                final exists = AuthRepository.instance.sendPasswordResetEmail(email);
                Navigator.of(context).pop();

                if (exists) {
                  _showResetPasswordDialog(email);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('O e-mail "$email" não está cadastrado na base de dados.')),
                  );
                }
              },
              child: const Text('Enviar Link de Redefinição'),
            ),
          ],
        );
      },
    );
  }

  void _showResetPasswordDialog(String email) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Nova Senha'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Link de redefinição enviado com sucesso para $email!\n\nVocê também pode cadastrar sua nova senha diretamente abaixo:',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nova Senha *',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Nova Senha *',
                    prefixIcon: Icon(Icons.lock_reset),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (newPasswordController.text.length < 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('A senha deve ter pelo menos 3 caracteres.')),
                  );
                  return;
                }
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('As senhas não coincidem.')),
                  );
                  return;
                }

                AuthRepository.instance.resetPassword(
                  email: email,
                  newPassword: newPasswordController.text,
                );

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nova senha cadastrada com sucesso! Faça login com a nova senha.')),
                );
              },
              child: const Text('Salvar Nova Senha'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: VineyardBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
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
                        const WineryLogo(size: 80),
                        const SizedBox(height: 16),
                        Text(
                          'Winery Finder',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Faça login para gerenciar e explorar vinícolas',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Informe o e-mail' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.isEmpty ? 'Informe a senha' : null,
                        ),
                        const SizedBox(height: 8),
                        // Botão Esqueci Minha Senha
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordDialog,
                            child: const Text('Esqueceu a senha?'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: _handleLogin,
                            child: const Text('Entrar', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: const Text('Não tem uma conta? Cadastre-se'),
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
