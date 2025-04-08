import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscar Usuário',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const UserSearchPage(),
    );
  }
}

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _userData;
  String? _errorMessage;
  bool _loading = false;

  Future<void> _fetchUser() async {
    final id = int.tryParse(_controller.text);
    if (id == null || id < 1 || id > 12) {
      setState(() {
        _errorMessage = 'Digite um ID entre 1 e 12.';
        _userData = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _userData = null;
    });

    try {
      final response = await http.get(Uri.parse('https://reqres.in/api/users/$id'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          _userData = json['data'];
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Usuário não encontrado!';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro na conexão. Tente novamente.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildUserInfo() {
    if (_loading) {
      return const CircularProgressIndicator();
    } else if (_errorMessage != null) {
      return Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red, fontSize: 18),
      );
    } else if (_userData != null) {
      return Column(
        children: [
          Image.network(_userData!['avatar'], width: 100),
          const SizedBox(height: 10),
          Text('${_userData!['first_name']} ${_userData!['last_name']}',
              style: const TextStyle(fontSize: 20)),
          Text(_userData!['email'], style: const TextStyle(fontSize: 16)),
        ],
      );
    } else {
      return const Text('Digite um ID para buscar um usuário.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Digite o ID (1-12)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchUser,
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 20),
            _buildUserInfo(),
          ],
        ),
      ),
    );
  }
}
