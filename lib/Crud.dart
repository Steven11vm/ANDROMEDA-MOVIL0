import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CrudScreen extends StatefulWidget {
  @override
  _CrudScreenState createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  late List<Map<String, dynamic>> _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:5179/api/Exportacion'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _data = jsonData.map((item) => item as Map<String, dynamic>).toList();
          _loading = false;
        });
      } else {
        throw Exception('Fallo en cargar');
      }
    } catch (error) {
      print('Error: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Se produjo un error al cargar los datos.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text(
                    'Exportaciones',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  DataTable(
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.black),
                    dataRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.white),
                    columns: const <DataColumn>[
                      DataColumn(
                          label: Text('Nombre',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black))),
                      DataColumn(
                          label: Text('Precio-Dolar',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black))),
                      DataColumn(
                          label: Text('Kilo',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black))),
                      DataColumn(
                          label: Text('Fecha',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black))),
                      DataColumn(
                          label: Text('Actions',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black))),
                    ],
                    rows: _data.map((item) {
                      return DataRow(cells: [
                        DataCell(Text(item['nombreProducto'].toString(),
                            style: TextStyle(color: Colors.black))),
                        DataCell(Text(item['precioActualDolar'].toString(),
                            style: TextStyle(color: Colors.black))),
                        DataCell(Text(item['kilos'].toString(),
                            style: TextStyle(color: Colors.black))),
                        DataCell(Text(item['fechaRegistrada'].toString(),
                            style: TextStyle(color: Colors.black))),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    Icon(Icons.visibility, color: Colors.black),
                                onPressed: () => _verItem(item),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.green),
                                onPressed: () => _editarItem(item),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _eliminarItem(item),
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  ElevatedButton(
                    onPressed: _registrarItem,
                    child: Text('Registrar'),
                  ),
                ],
              ),
            ),
    );
  }

  void _verItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles del Elemento'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nombre: ${item['nombreProducto']}'),
              Text('Precio-Dolar: ${item['precioActualDolar']}'),
              Text('Kilo: ${item['kilos']}'),
              Text('Fecha: ${item['fechaRegistrada']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _editarItem(Map<String, dynamic> item) {
    // Implementa la lógica para editar el item
    // Abre un formulario de edición y envía los datos a la API para actualizarlos
  }

  void _eliminarItem(Map<String, dynamic> id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de eliminar ${id['nombreProducto']}?'),
          actions: [
            TextButton(
              onPressed: () {
                // Implementa la lógica para eliminar el item
                // Haz una solicitud a la API para eliminar el elemento
                Navigator.of(context).pop();
              },
              child: Text('Eliminar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _registrarItem() {
    // Implementa la lógica para registrar un nuevo item
    // Abre un formulario de registro y envía los datos a la API para registrarlos
  }
}
