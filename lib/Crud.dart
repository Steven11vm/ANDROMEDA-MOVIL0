import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CrudScreen extends StatefulWidget {
  @override
  _CrudScreenState createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  List<Map<String, dynamic>> _data = [];
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

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    try {
      final response = await http.delete(
          Uri.parse('http://localhost:5179/api/Exportacion/${item['id']}'));
      if (response.statusCode == 200) {
        // Eliminación exitosa
        setState(() {
          _data.removeWhere((element) => element['id'] == item['id']);
        });
      } else {
        throw Exception('Fallo en eliminar');
      }
    } catch (error) {
      print('Error al eliminar: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Se produjo un error al eliminar el elemento.'),
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

  void _eliminarItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de eliminar ${item['nombreProducto']}?'),
          actions: [
            TextButton(
              onPressed: () {
                _deleteItem(item); // Eliminar el elemento
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
                                onPressed: () {
                                  _eliminarItem(item);
                                },
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
    // Define controladores para cada campo del formulario
    TextEditingController nombreController =
        TextEditingController(text: item['nombreProducto']);
    TextEditingController precioController =
        TextEditingController(text: item['precioActualDolar'].toString());
    TextEditingController kiloController =
        TextEditingController(text: item['kilos'].toString());
    TextEditingController fechaController =
        TextEditingController(text: item['fechaRegistrada'].toString());

    // Muestra un diálogo con un formulario de edición
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Elemento'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: precioController,
                  decoration: InputDecoration(labelText: 'Precio-Dolar'),
                ),
                TextField(
                  controller: kiloController,
                  decoration: InputDecoration(labelText: 'Kilo'),
                ),
                TextField(
                  controller: fechaController,
                  decoration: InputDecoration(labelText: 'Fecha'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Aquí debes enviar los datos actualizados al servidor
                // Puedes llamar a un método para enviar la solicitud HTTP PUT/PATCH a la API
                // No olvides manejar los errores y actualizar la lista después de editar el elemento
                // Ejemplo: _enviarDatosEdicion(item['id'], nombreController.text, precioController.text, kiloController.text, fechaController.text);
                // Después de enviar los datos, cierra el diálogo
                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _registrarItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registrar Nuevo Elemento'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Nombre'),
                  onChanged: (value) {
                    // Actualiza el nombre del nuevo elemento
                    // Puedes ignorar esto si ya tienes el controlador en la API
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Precio-Dolar'),
                  onChanged: (value) {
                    // Actualiza el precio del nuevo elemento
                    // Puedes ignorar esto si ya tienes el controlador en la API
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Kilo'),
                  onChanged: (value) {
                    // Actualiza el kilo del nuevo elemento
                    // Puedes ignorar esto si ya tienes el controlador en la API
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Fecha'),
                  onChanged: (value) {
                    // Actualiza la fecha del nuevo elemento
                    // Puedes ignorar esto si ya tienes el controlador en la API
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Aquí se debe enviar los datos al servidor
                // Puedes llamar a un método para enviar la solicitud HTTP POST a la API
                // No olvides manejar los errores y actualizar la lista después de registrar el nuevo elemento
                // Ejemplo: _enviarDatosRegistro();
                // Después de enviar los datos, cierra el diálogo
                Navigator.of(context).pop();
              },
              child: Text('Registrar'),
            ),
          ],
        );
      },
    );
  }
}
