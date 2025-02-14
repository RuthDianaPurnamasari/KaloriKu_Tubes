import 'package:flutter/material.dart';
import 'package:kaloriku/model/food_model.dart';
import 'package:kaloriku/services/api_services.dart';
import 'package:kaloriku/services/auth_manager.dart';
import 'package:kaloriku/view/screen/login_page.dart';
import 'package:kaloriku/view/widget/food_card.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _ingredientsCtl = TextEditingController();
  final _descriptionCtl = TextEditingController();
  final _caloriesCtl = TextEditingController();
  final _categoryCtl = TextEditingController();
  final ApiServices _dataService = ApiServices();
  List<FoodsModel> _foodList = [];
  FoodResponse? foodResponse;
  bool isEdit = false;
  String foodId = '';

  late SharedPreferences loginData;
  String username = '';
  String token = '';

  @override
    void initState() {
      super.initState();
      inital();
    }
    void inital() async {
      loginData = await SharedPreferences.getInstance();
      setState(() {
        username = loginData.getString('username').toString();
        token = loginData.getString('token').toString();
      });
    }

  @override
  void dispose() {
    _nameCtl.dispose();
    _ingredientsCtl.dispose();
    _descriptionCtl.dispose();
    _caloriesCtl.dispose();
    _categoryCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KaloriKu - Home'),
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Card(),
              const SizedBox(height: 20.0),
              foodForm(),
              actionButtons(),
              foodResponseCard(),
              const SizedBox(height: 8.0),
              const Text(
                'List Makanan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: _foodList.isEmpty
                    ? const Center(child: Text('Tidak ada data makanan'))
                    : foodListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget userCard() {
    return Card(
      elevation: 4,
      color: Colors.tealAccent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.account_circle_rounded),
                const SizedBox(width: 8.0),
                Text(
                  'Login sebagai: $username',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.key),
                const SizedBox(width: 8.0),
                Text(
                  'Token: $token',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget foodForm() {
    return Column(
      children: [
        textField(_nameCtl, 'Nama Makanan'),
        textField(_ingredientsCtl, 'Bahan-bahan'),
        textField(_descriptionCtl, 'Deskripsi'),
        textField(_caloriesCtl, 'Kalori', isNumber: true),
        textField(_categoryCtl, 'Kategori'),
      ],
    );
  }

  Widget textField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
          suffixIcon: IconButton(
            onPressed: controller.clear,
            icon: const Icon(Icons.clear),
          ),
        ),
      ),
    );
  }

  Widget actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final foodInput = FoodInput(
                name: _nameCtl.text,
                ingredients: _ingredientsCtl.text,
                description: _descriptionCtl.text,
                calories: double.parse(_caloriesCtl.text),
                category: _categoryCtl.text,
              );

              FoodResponse? res;
              if (isEdit) {
                res = await _dataService.updateFood(foodId, foodInput);
              } else {
                res = await _dataService.addFood(foodInput);
              }

              setState(() {
                foodResponse = res;
                isEdit = false;
              });

              clearFields();
              await refreshFoodList();
            }
          },
          child: Text(isEdit ? 'UPDATE' : 'TAMBAH'),
        ),
        const SizedBox(width: 8.0),
        if (isEdit)
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              clearFields();
              setState(() => isEdit = false);
            },
            child: const Text('BATAL'),
          ),
      ],
    );
  }

  Widget foodResponseCard() {
    return foodResponse != null
        ? FoodCard(
            response: foodResponse!,
            onDismissed: () {
              setState(() {
                foodResponse = null;
              });
            }, food: FoodsModel(name: '', ingredients: '', description: '', calories: 0, category: '', id: ''),
          )
        : const SizedBox.shrink();
  }

  Widget foodListView() {
    return ListView.builder(
      itemCount: _foodList.length,
      itemBuilder: (context, index) {
        final food = _foodList[index];
        return ListTile(
          title: Text(food.name),
          subtitle: Text(food.category),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _nameCtl.text = food.name;
                    _ingredientsCtl.text = food.ingredients;
                    _descriptionCtl.text = food.description;
                    _caloriesCtl.text = food.calories.toString();
                    _categoryCtl.text = food.category;
                    isEdit = true;
                    foodId = food.id;
                  });
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  _dataService.deleteFood(food.id);
                  refreshFoodList();
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> refreshFoodList() async {
    final foods = await _dataService.getAllMenuItem();
    setState(() {
      _foodList = foods?.toList() ?? [];
    });
  }

  void clearFields() {
    _nameCtl.clear();
    _ingredientsCtl.clear();
    _descriptionCtl.clear();
    _caloriesCtl.clear();
    _categoryCtl.clear();
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () async {
                await AuthManager.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }


  // Future<void> refreshContactList() async {
  //   final users = await _dataService.getAllContact();
  //   setState(() {
  //     // Bersihkan daftar kontak jika tidak kosong
  //     if (_nameCtl.isNotEmpty) _contactMdl.clear();

  //     // Tambahkan data baru jika tersedia
  //     if (users != null) {
  //       // Konversi Iterable ke List, kemudian gunakan reversed
  //       _contactMdl.addAll(users.toList().reversed);
  //     }
  //   });
  }

 // ignore: unused_element
 String? _validateName(String? value) {
  if (value == null || value.length < 4) {
    return 'Masukkan minimal 4 karakter';
  }
  return null;
}

// ignore: unused_element
String? _validatePhoneNumber(String? value) {
  if (value == null || !RegExp(r'^[0-9]+$').hasMatch(value)) {
    return 'Nomor HP harus berisi angka';
  }
  return null;
}

  dynamic displaySnackbar(BuildContext context, String msg) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
}
