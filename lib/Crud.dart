import 'package:flutter/material.dart';

class CrudScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD Operations'),
      ),
      body: Center(
        child: Text('Welcome to the CRUD screen!'),
      ),
    );
  }
}
