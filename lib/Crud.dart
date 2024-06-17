import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ExchangeScreen(),
        '/crud': (context) => CrudScreen(),
      },
    );
  }
}

class ExchangeScreen extends StatefulWidget {
  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  double? _exchangeRate;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _fetchExchangeRate();
  }

  Future<void> _fetchExchangeRate() async {
    final url = 'https://api.exchangerate-api.com/v4/latest/USD';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _exchangeRate = data['rates']['COP'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = true;
          _loading = false;
        });
        throw Exception('Failed to load exchange rate');
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        _error = true;
        _loading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to load exchange rate. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _fetchExchangeRate(); // Retry fetching the data
                },
                child: Text('Retry'),
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
        title: Text('USD to COP Exchange Rate'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _error
              ? Center(child: Text('Failed to load exchange rate.'))
              : Center(
                  child: Text(
                    '1 USD = $_exchangeRate COP',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/crud');
        },
        tooltip: 'CRUD',
        child: Icon(Icons.list),
      ),
    );
  }
}

class CrudScreen extends StatefulWidget {
  @override
  _CrudScreenState createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  List<Map<String, dynamic>> _data = [];
  bool _loading = true;
  double _exchangeRate = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchExchangeRate().then((_) => _getData());
  }

  Future<void> _fetchExchangeRate() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          _exchangeRate = jsonData['rates']['COP'];
        });
        print('Tasa de cambio USD a COP: $_exchangeRate');
      } else {
        throw Exception('Error al obtener la tasa de cambio');
      }
    } catch (error) {
      print('Error al obtener la tasa de cambio: $error');
    }
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
    final double priceInCOP = item['precioActualDolar'] * _exchangeRate;
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
              Text('Kilos: ${item['kilos']}'),
              Text('Fecha: ${item['fechaRegistrada']}'),
              Text('Valor del dólar: $_exchangeRate'),
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
                int? kilos = int.tryParse(kiloController.text);
                String fecha = fechaController.text;

                if (nombre.isEmpty || kilos == null || fecha.isEmpty) {
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
      int id, String nombre, int kilos, String fecha) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:5179/api/Exportacion/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'nombreProducto': nombre,
          'kilos': kilos,
          'fechaRegistrada': fecha,
        }),
      );
      if (response.statusCode == 200) {
        // Actualización exitosa
        _getData(); // Actualizar la lista después de la edición
      } else {
        throw Exception('Error al editar');
      }
    } catch (error) {
      print('Error al editar: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Exito'),
            content: Text('Exito al editar el elemento.'),
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

  void _registrarItem() {
    TextEditingController nombreController = TextEditingController();
    TextEditingController kiloController = TextEditingController();
    TextEditingController fechaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registrar nuevo elemento'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
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
                int? kilos = int.tryParse(kiloController.text);
                String fecha = fechaController.text;

                if (nombre.isEmpty || kilos == null || fecha.isEmpty) {
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
                  // Enviar los datos al servidor
                  _sendData(nombre, kilos, fecha);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendData(String nombre, int kilos, String fecha) async {
    final newItem = {
      "nombreProducto": nombre,
      "kilos": kilos,
      "fechaRegistrada": fecha,
      "exportacion": true // Suponiendo que necesitas este campo
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5179/api/Exportacion'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(newItem),
      );

      if (response.statusCode == 201) {
        _getData();
      } else {
        throw Exception('Error al registrar');
      }
    } catch (error) {
      print('Error: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Se produjo un error al registrar el elemento.'),
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
                  const SizedBox(height: 20.0),
                  const Text(
                    'Exportaciones',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.0),
                  DataTable(
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => const Color.fromARGB(255, 255, 255, 255)),
                    dataRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.white),
                    columns: const <DataColumn>[
                      DataColumn(
                          label: Text('Nombre',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black))),
                      DataColumn(
                          label: Text('Valor del dolar',
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
                          label: Text('Acciones',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black))),
                    ],
                    rows: _data.map((item) {
                      final double priceInCOP = _exchangeRate;
                      return DataRow(cells: [
                        DataCell(Text(item['nombreProducto'].toString(),
                            style: TextStyle(color: Colors.black))),
                        DataCell(Text(priceInCOP.toStringAsFixed(2),
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
                                  _deleteItem(item);
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
