import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import './catalog_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool isRegister;
  const AuthScreen({super.key, required this.isRegister});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (widget.isRegister) {
        await _auth.register(_email.text.trim(), _password.text.trim());
      } else {
        await _auth.login(_email.text.trim(), _password.text.trim());
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CatalogScreen()),
      );
    } catch (e) {
      final msg = e.toString();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $msg')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleAuthMode() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AuthScreen(isRegister: !widget.isRegister),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isRegister ? 'Registro' : 'Iniciar sesión';
    final toggleText = widget.isRegister
        ? '¿Ya tienes una cuenta? Inicia sesión'
        : '¿No tienes cuenta? Regístrate';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Email inválido',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) =>
                    v != null && v.length >= 6 ? null : 'Mínimo 6 caracteres',
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text(title),
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _toggleAuthMode,
                child: Text(toggleText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}