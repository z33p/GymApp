import 'package:flutter/material.dart';

class PublishScreen extends StatelessWidget {
  const PublishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Publicação'),
      ),
      body: const Center(
        child: Text('Tela de Publicação'),
      ),
    );
  }
}
