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
                  _getData(); // Llama a _getData después de cerrar el cuadro de diálogo
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
        throw Exception('Correcta eliminación');
      }
    } catch (error) {
      print('Se eliminó con éxito: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Éxito'),
            content: Text('Se produjo la eliminación correcta.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _getData(); // Llama a _getData después de cerrar el cuadro de diálogo
                },
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
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
              Text('Precio-Dólar: ${item['precioActualDolar']}'),
              Text('Kilos: ${item['kilos']}'),
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
                  decoration: InputDecoration(labelText: 'Precio-Dólar'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: kiloController,
                  decoration: InputDecoration(labelText: 'Kilos'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: fechaController,
                  decoration: InputDecoration(labelText: 'Fecha (yyyy-MM-dd)'),
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
                // Validar los datos antes de enviarlos
                String nombre = nombreController.text;
                double? precio = double.tryParse(precioController.text);
                int? kilos = int.tryParse(kiloController.text);
                String fecha = fechaController.text;

                if (nombre.isEmpty ||
                    precio == null ||
                    kilos == null ||
                    fecha.isEmpty) {
                  // Mostrar un mensaje de error si los datos no son válidos
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Por favor, ingresa datos válidos.'),
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
                } else {
                  // Enviar los datos editados al servidor
                  _enviarDatosEdicion(
                    item['id'],
                    nombre,
                    precio,
                    kilos,
                    fecha,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _enviarDatosEdicion(
      int id, String nombre, double precio, int kilos, String fecha) async {
    final editedItem = {
      "id": id,
      "nombreProducto": nombre,
      "precioActualDolar": precio,
      "kilos": kilos,
      "fechaRegistrada": fecha,
      "exportacion": true // Suponiendo que necesitas este campo
    };

    print('Enviando datos editados: $editedItem');

    try {
      final response = await http.put(
        Uri.parse('http://localhost:5179/api/Exportacion/$id'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(editedItem),
      );

      if (response.statusCode == 204) {
        // Edición exitosa (status 204)
        _getData();
      } else {
        print('Error en la edición: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Error al editar');
      }
    } catch (error) {
      print('Error: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Se produjo un error al editar el elemento.'),
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
                // Envía una solicitud DELETE a la API para eliminar el elemento
                _deleteItem(id);
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
    TextEditingController nombreController = TextEditingController();
    TextEditingController precioController = TextEditingController();
    TextEditingController kiloController = TextEditingController();
    TextEditingController fechaController = TextEditingController();

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
                  controller: nombreController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: precioController,
                  decoration: InputDecoration(labelText: 'Precio-Dólar'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: kiloController,
                  decoration: InputDecoration(labelText: 'Kilos'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: fechaController,
                  decoration: InputDecoration(labelText: 'Fecha (yyyy-MM-dd)'),
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
                // Validar y formatear la fecha
                String formattedDate = fechaController.text;
                // Aquí podrías agregar validaciones adicionales si es necesario
                _enviarDatosRegistro(
                  nombreController.text,
                  double.parse(precioController.text),
                  int.parse(kiloController.text),
                  formattedDate,
                );
                Navigator.of(context).pop();
              },
              child: Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _enviarDatosRegistro(
      String nombre, double precio, int kilos, String fecha) async {
    final nuevoItem = {
      "nombreProducto": nombre,
      "precioActualDolar": precio,
      "kilos": kilos,
      "fechaRegistrada": fecha,
      "exportacion": true // Suponiendo que necesitas este campo
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5179/api/Exportacion'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(nuevoItem),
      );

      if (response.statusCode == 201) {
        // Registro exitoso
        _getData();
      } else {
        print('Error en el registro: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Error al registrar');
      }
    } catch (error) {
      print('Error: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content:
                Text('Se produjo un error al registrar el nuevo elemento.'),
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
//

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
                  const SizedBox(height: 20.0),
                  const Text(
                    'Exportaciones',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.0),
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
                          label: Text('Precio-Dólar',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black))),
                      DataColumn(
                          label: Text('Kilos',
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
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _registrarItem,
                    child: Text('Registrar'),
                  ),
                  ElevatedButton(
                    onPressed:
                        _getData, // Agregar este botón para actualizar la página
                    child: Text('Actualizar Tabla'),
                  ),
                ],
              ),
            ),
    );
  }
}
