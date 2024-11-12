import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';

// Purchase Detail Model
class PurchaseDetail {
  final int id;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final int productId;
  final int purchaseId;
  final String createdAt;
  final String updatedAt;

  PurchaseDetail({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.productId,
    required this.purchaseId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseDetail(
      id: json['id'],
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      productId: json['product_id'] ?? 0,
      purchaseId: json['shopping_id'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

// Purchase Model
class Purchase {
  final int id;
  final String code;
  final String purchaseDate;
  final String? registrationDate;
  final double totalPrice;
  final String status;
  final int supplierId;
  final String createdAt;
  final String updatedAt;
  final List<PurchaseDetail> purchaseDetails;

  Purchase({
    required this.id,
    required this.code,
    required this.purchaseDate,
    this.registrationDate,
    required this.totalPrice,
    required this.status,
    required this.supplierId,
    required this.createdAt,
    required this.updatedAt,
    required this.purchaseDetails,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      code: json['code'],
      purchaseDate: json['purchaseDate'],
      registrationDate: json['registrationDate'],
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: json['status'],
      supplierId: json['supplierId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      purchaseDetails: (json['ShoppingDetails'] as List? ?? [])
          .map((detail) => PurchaseDetail.fromJson(detail))
          .toList(),
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

// Supplier Model
class Supplier {
  final int id;
  final String supplierName;
  final String phoneNumber;
  final String email;
  final String address;
  final String status;

  Supplier({
    required this.id,
    required this.supplierName,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.status,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      supplierName: json['Supplier_Name'],
      phoneNumber: json['Phone_Number'],
      email: json['Email'],
      address: json['Address'],
      status: json['status'],
    );
  }
}

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({Key? key}) : super(key: key);

  @override
  _PurchasesPageState createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  List<Purchase> purchases = [];
  Map<int, Product> products = {};
  Map<int, Supplier> suppliers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      await Future.wait([
        fetchPurchases(),
        fetchProducts(),
        fetchSuppliers(),
      ]);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> fetchPurchases() async {
    final response = await http.get(Uri.parse('http://localhost:1056/api/shopping'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      purchases = data.map((json) => Purchase.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load purchases');
    }
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('http://localhost:1056/api/products'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      products = Map.fromIterable(
        data.map((json) => Product.fromJson(json)),
        key: (product) => product.id,
        value: (product) => product,
      );
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> fetchSuppliers() async {
    final response = await http.get(Uri.parse('http://localhost:1056/api/suppliers'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      suppliers = Map.fromIterable(
        data.map((json) => Supplier.fromJson(json)),
        key: (supplier) => supplier.id,
        value: (supplier) => supplier,
      );
    } else {
      throw Exception('Failed to load suppliers');
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
                  : _buildPurchasesList(),
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
                'Compras',
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

  Widget _buildPurchasesList() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: purchases.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 600),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildPurchaseCard(purchases[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPurchaseCard(Purchase purchase) {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final supplier = suppliers[purchase.supplierId];
    
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
                      'Orden #${purchase.code}',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(purchase.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(purchase.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        purchase.status,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: _getStatusColor(purchase.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(purchase.purchaseDate),
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      supplier != null ? supplier.supplierName : 'Proveedor desconocido',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                if (purchase.purchaseDetails.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Detalles de la compra:',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: Colors.amber[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...purchase.purchaseDetails.map((detail) {
                    final product = products[detail.productId];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${detail.quantity}x ${product != null ? product.productName : 'Producto #${detail.productId}'}',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
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
                    );
                  }).toList(),
                ],
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
                      formatter.format(purchase.totalPrice),
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
      case 'completada':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'cancelada':
      case 'anulada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String date) {
    if (date == "0000-00-00") return "Fecha no disponible";
    try {
      final DateTime dateTime = DateTime.parse(date);
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      return "Fecha inválida";
    }
  }
}