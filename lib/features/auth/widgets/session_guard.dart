import 'package:flutter/material.dart';
import '../services/session_manager.dart';
import '../services/auth_service.dart';

class SessionGuard extends StatefulWidget {
  final Widget child;
  final String? redirectRoute;

  const SessionGuard({
    Key? key,
    required this.child,
    this.redirectRoute = '/login',
  }) : super(key: key);

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> {
  final SessionManager _sessionManager = SessionManager();
  final AuthService _authService = AuthService();
  bool _isChecking = true;
  bool _isSessionValid = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      // Verificar si hay un usuario logueado
      final isLoggedIn = await _authService.isUserLoggedIn();
      
      if (!isLoggedIn) {
        setState(() {
          _isSessionValid = false;
          _isChecking = false;
        });
        _redirectToLogin();
        return;
      }

      // Verificar si la sesión es válida
      final isValid = await _sessionManager.isSessionValid();
      
      setState(() {
        _isSessionValid = isValid;
        _isChecking = false;
      });

      if (!isValid) {
        _redirectToLogin();
      }
    } catch (e) {
      setState(() {
        _isSessionValid = false;
        _isChecking = false;
      });
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          widget.redirectRoute ?? '/login',
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verificando sesión...'),
            ],
          ),
        ),
      );
    }

    if (!_isSessionValid) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Sesión expirada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Redirigiendo al login...'),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
