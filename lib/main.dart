import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Login.dart';
import 'home.dart';
import 'products.dart';
import 'sale.dart';
import 'shopping.dart';
import 'appointment.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(const MyApp());
}

// Servicio de autenticación simplificado
class AuthService {
  static const String baseUrl = 'http://localhost:1056/api/users';
  static String? _token;

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  bool isAuthenticated() {
    return _token != null;
  }

  void logout() {
    _token = null;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'inter',
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => LoginScreen(authService: authService),
        '/Home': (context) => const Home(),
        '/products': (context) => const ProductsPage(),
        '/sales': (context) => const SalesPage(),
        '/shopping': (context) => const PurchasesPage(),
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(255, 0, 0, 0),
          ]),
        ),
        child: Column(children: [
          const Padding(
            padding: EdgeInsets.only(top: 100.0),
            child: Image(
              image: AssetImage('assets/icons/logo.png'),
              width: 180,
            ),
          ),
          const SizedBox(height: 100),
          const Text(
            'BARBERIA ORION',
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/login');
            },
            child: Container(
              height: 53,
              width: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white),
              ),
              child: const Center(
                child: Text(
                  'INICIAR SESION',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}