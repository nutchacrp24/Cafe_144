import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cafe_144/page/add_product.dart';
import 'package:cafe_144/page/edit_product.dart';
import 'package:cafe_144/page/login.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Product {
  int id;
  String productName;
  int productType;
  int price;

  Product({
    required this.id,
    required this.productName,
    required this.productType,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        productName: json["product_name"],
        productType: json["product_type"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product_name": productName,
        "product_type": productType,
        "price": price,
      };
}

class ShowProduct extends StatefulWidget {
  const ShowProduct({super.key});

  @override
  State<ShowProduct> createState() => _ShowProductState();
}

class _ShowProductState extends State<ShowProduct> {
  String? userToken;
  String? username;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    getUserToken();
    getUserInfo();
    getList();
  }

  Future<void> getUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('userToken');
    });
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
  }

  Future<void> getList() async {
    products = [];
    var url = Uri.parse('https://642021144.pungpingcoding.online/api/product');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userToken = prefs.getString('userToken');

      var response = await http.get(url, headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $userToken',
      });

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        products = jsonString['payload']
            .map<Product>((json) => Product.fromJson(json))
            .toList();
      } else {
        // Handle other status codes
        print('Failed to load products: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แสดงรายการเมนู'),
        backgroundColor: Color.fromARGB(255, 238, 127, 16),
        actions: [
          Row(
            children: [
              const Text('บัญชีผู้ใช้ :  '),
              Text('$username',
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255))),
            ],
          ),
          IconButton(
            onPressed: () async {
              await logout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        children: [
          showButton(),
          showList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 77, 196, 81),
        onPressed: () async {
          // TODO: Navigate to Add Product Page
          await showDialog(
            context: context,
            builder: (context) {
              return const AddProductModal();
            },
          );

          // After adding a new product, refresh the list
          await getList();

          setState(() {
            // Trigger a rebuild to show the updated list
          });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget showButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          // Trigger a rebuild to show the updated list
          getList();
        });
      },
      child: const Text('แสดงรายการเมนู'),
    );
  }

  Widget showList() {
    return FutureBuilder(
      future: getList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                const Icon(
                  Icons.delete_outline_outlined,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('ข้อผิดพลาด: ${snapshot.error}'),
                ),
              ],
            ),
          );
        } else {
          return Column(
            children: products.map((item) {
              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProduct(productId: item.id),
                      ),
                    ).then((value) async {
                      setState(() {
                        getList();
                      });
                    });
                  },
                  title: Text(item.productName),
                  subtitle: Row(
                    children: [
                      Text(
                        'ราคา: ${item.price} บาท',
                        style: const TextStyle(
                            color: Color.fromARGB(255, 81, 38, 21)),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Set mainAxisSize to min
                    children: [
                      IconButton(
                        onPressed: () {
                          QuickAlert.show(
                            onCancelBtnTap: () {
                              Navigator.pop(context);
                            },
                            context: context,
                            type: QuickAlertType.confirm,
                            title: 'ต้องการลบ??',
                            text: 'หากลบข้อมูลแล้ว จะไม่สามารถกู้ได้',
                            titleAlignment: TextAlign.center,
                            textAlignment: TextAlign.center,
                            confirmBtnText: 'ตกลง',
                            cancelBtnText: 'ยกเลิก',
                            confirmBtnColor:
                                const Color.fromARGB(255, 185, 37, 37),
                            backgroundColor: Colors.white,
                            headerBackgroundColor: Colors.grey,
                            confirmBtnTextStyle: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                            ),
                            barrierColor: const Color.fromARGB(139, 46, 46, 46),
                            titleColor: const Color.fromARGB(255, 1, 1, 1),
                            textColor: const Color.fromARGB(255, 1, 1, 1),
                            cancelBtnTextStyle: const TextStyle(
                              color: Color.fromARGB(255, 33, 33, 33),
                              fontWeight: FontWeight.bold,
                            ),
                            onConfirmBtnTap: () async {
                              Navigator.pop(
                                  context); // Close the confirmation dialog
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                text: 'ลบข้อมูลสำเร็จ!',
                                showConfirmBtn: false,
                                autoCloseDuration: const Duration(seconds: 3),
                              ).then((value) async {
                                await deleteProduct(
                                    item.id); // Delete the product
                              });
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Future<void> deleteProduct(int id) async {
    var url =
        Uri.parse('https://642021144.pungpingcoding.online/api/product/$id');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userToken = prefs.getString('userToken');

      var response = await http.delete(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        // Product deleted successfully, refresh the list
        await getList();
        setState(() {
          // Trigger a rebuild to show the updated list
        });
        print('Product deleted successfully');
      } else {
        // Handle other status codes
        print('Failed to delete product: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting product: $error');
    }
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('userToken');

    var url = Uri.parse('https://642021144.pungpingcoding.online/api/logout');

    try {
      var response = await http.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        // Remove user-related information from SharedPreferences
        prefs.remove('user');
        prefs.remove('token');

        // Navigate to the LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );

        print("Logout success");
      } else {
        print("Logout failed. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during logout: $e");
    }
  }
}
