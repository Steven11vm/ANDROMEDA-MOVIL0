import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';

// User Model
class User {
  final int id;
  final String? name;

  User({
    required this.id,
    this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
    );
  }
}

// Product Model
class Product {
  final int id;
  final String productName;
  final double price;
  final int categoryId;

  Product({
    required this.id,
    required this.productName,
    required this.price,
    required this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      productName: json['Product_Name'],
      price: double.parse(json['Price']),
      categoryId: json['Category_Id'],
    );
  }
}

// Service Model
class Service {
  final int? id;
  final String? name;

  Service({
    this.id,
    this.name,
  });

  factory Service.fromJson(Map<String, dynamic>? json) {
    return Service(
      id: json?['id'],
      name: json?['name'],
    );
  }
}

// Employee Model
class Employee {
  final int? id;
  final String? name;

  Employee({
    this.id,
    this.name,
  });

  factory Employee.fromJson(Map<String, dynamic>? json) {
    return Employee(
      id: json?['id'],
      name: json?['name'],
    );
  }
}

// Sale Detail Model
class SaleDetail {
  final int id;
  final int quantity;
  final double? unitPrice;
  final double totalPrice;
  final int productId;
  final Service? service;
  final Employee? employee;

  SaleDetail({
    required this.id,
    required this.quantity,
    this.unitPrice,
    required this.totalPrice,
    required this.productId,
    this.service,
    this.employee,
  });

  factory SaleDetail.fromJson(Map<String, dynamic> json) {
    return SaleDetail(
      id: json['id'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'] != null ? json['unitPrice'].toDouble() : null,
      totalPrice: json['total_price'].toDouble(),
      productId: json['id_producto'],
      service: json['serviceId'] != null ? Service(id: json['serviceId'], name: 'Servicio #${json['serviceId']}') : null,
      employee: json['empleadoId'] != null ? Employee(id: json['empleadoId'], name: 'Empleado #${json['empleadoId']}') : null,
    );
  }
}

// Sale Model
class Sale {
  final int id;
  final String? billNumber;
  final String? saleDate;
  final String? registrationDate;
  final double totalPrice;
  final String? status;
  final User? user;
  final List<SaleDetail> saleDetails;

  Sale({
    required this.id,
    this.billNumber,
    this.saleDate,
    this.registrationDate,
    required this.totalPrice,
    this.status,
    this.user,
    required this.saleDetails,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      billNumber: json['Billnumber'],
      saleDate: json['SaleDate'],
      registrationDate: json['registrationDate'],
      totalPrice: json['total_price'].toDouble(),
      status: json['status'],
      user: json['id_usuario'] != null ? User(id: json['id_usuario'], name: 'Usuario #${json['id_usuario']}') : null,
      saleDetails: (json['SaleDetails'] as List?)
          ?.map((detail) => SaleDetail.fromJson(detail))
          .toList() ?? [],
    );
  }
}

class SalesPage extends StatefulWidget {
  const SalesPage({Key? key}) : super(key: key);

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<Sale> sales = [];
  Map<int, Product> products = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSalesAndProducts();
  }

  Future<void> fetchSalesAndProducts() async {
    try {
      final salesResponse = await http.get(Uri.parse('http://localhost:1056/api/sales'));
      final productsResponse = await http.get(Uri.parse('http://localhost:1056/api/products'));
      
      if (salesResponse.statusCode == 200 && productsResponse.statusCode == 200) {
        final List<dynamic> salesData = json.decode(salesResponse.body);
        final List<dynamic> productsData = json.decode(productsResponse.body);
        
        setState(() {
          sales = salesData.map((json) => Sale.fromJson(json)).toList();
          products = {for (var product in productsData) product['id']: Product.fromJson(product)};
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load sales or products');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.amber[700],
                      ),
                    )
                  : _buildSalesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A),
            const Color.fromARGB(255, 2, 2, 2).withOpacity(0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.amber[700],
                  size: 24,
                ),
                onPressed: () => Navigator.of(context).pushReplacementNamed('/Home'),
              ),
              Text(
                'Ventas',
                style: GoogleFonts.playfairDisplay(
                  textStyle: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sales.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 600),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildSaleCard(sales[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSaleCard(Sale sale) {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2A2A),
            Color(0xFF1A1A1A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.amber.shade700.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Factura #${sale.billNumber ?? 'N/A'}',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (sale.status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(sale.status!).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(sale.status!),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          sale.status!,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: _getStatusColor(sale.status!),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (sale.saleDate != null)
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(sale.saleDate!),
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Text(
                  'Detalles de la venta:',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.amber[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...sale.saleDetails.map((detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${detail.quantity}x ${products[detail.productId]?.productName ?? 'Producto desconocido'}',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        formatter.format(detail.totalPrice),
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                const Divider(color: Colors.grey),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      formatter.format(sale.totalPrice),
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Colors.amber[700],
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completado':
      case 'completada':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'cancelado':
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }
}