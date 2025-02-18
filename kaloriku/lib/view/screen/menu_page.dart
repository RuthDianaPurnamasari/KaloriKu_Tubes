import 'package:flutter/material.dart';
import 'package:kaloriku/model/food_model.dart';
import 'package:kaloriku/services/api_services.dart';
import 'package:kaloriku/services/auth_manager.dart';
import 'package:kaloriku/view/screen/login_page.dart';
import 'package:kaloriku/view/widget/food_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _ingredientsCtl = TextEditingController();
  final _descriptionCtl = TextEditingController();
  final _caloriesCtl = TextEditingController();
  final ApiServices _dataService = ApiServices();
  List<FoodsModel> _foodList = [];
  FoodResponse? foodResponse;
  bool isEdit = false;
  String foodId = '';
  String? _selectedCategory;
  final List<String> _categories = ['Vegan', 'High Protein', 'Dessert', 'Drink'];

  late SharedPreferences loginData;
  String token = '';
  String username = '';
  final Dio dio = Dio();
  final String _baseUrl = 'https://ws-kaloriku-4cf736febaf0.herokuapp.com'; // Replace with your actual base URL

  @override
  void initState() {
    super.initState();
    inital();
    refreshFoodList();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('KaloriKu - Management Menu', style: TextStyle(color: Colors.white)),
      backgroundColor: const Color.fromARGB(255, 16, 81, 50),
      actions: [
        IconButton(
          onPressed: () {
            _showLogoutConfirmationDialog(context);
          },
          icon: const Icon(Icons.logout, color: Colors.white),
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userCard(),
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

              /// ✅ Gunakan SizedBox agar `ListView.builder()` memiliki tinggi tetap
              SizedBox(
                height: 400, // ✅ Tentukan tinggi untuk daftar makanan
                child: _foodList.isEmpty
                    ? const Center(child: Text('Tidak ada data makanan'))
                    : foodListView(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  Widget userCard() {
    return Card(
      elevation: 4,
      color: const Color.fromARGB(255, 201, 198, 165),
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
            // Row(
            //   children: [
            //     const Icon(Icons.key),
            //     const SizedBox(width: 8.0),
            //     Text(
            //       'Token: $token',
            //       style: const TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget foodForm() {
    return Column(
      children: [
        textField(_nameCtl, 'Nama Makanan', validator: _validateName),
        textField(_ingredientsCtl, 'Bahan-bahan',
            validator: _validateIngredients),
        textField(_descriptionCtl, 'Deskripsi',
            validator: _validateDescription),
        textField(_caloriesCtl, 'Kalori',
            isNumber: true, validator: _validateCalories),
        dropdownField('Kategori', validator: _validateCategory),
      ],
    );
  }

  Widget textField(TextEditingController controller, String label,
      {bool isNumber = false, String? Function(String?)? validator}) {
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
        validator: validator,
      ),
    );
  }

  Widget dropdownField(String label, {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        items: _categories.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCategory = newValue;
          });
        },
        validator: validator,
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
                calories: double.tryParse(
                        _caloriesCtl.text.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                    0, // ✅ Pastikan hanya angka
                category: _selectedCategory ?? '',
              );

              debugPrint('🔍 Mengirim data: ${foodInput.calories} gram');

              FoodResponse? res;
              if (isEdit) {
                res = await _dataService.putMenu(foodId, foodInput);
              } else {
                res = await _dataService.postMenu(foodInput);
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
      ? Container(
          padding: const EdgeInsets.all(15),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color.fromARGB(255, 41, 184, 105),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Response:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              if (foodResponse!.insertedId != null) 
              _buildResponseRow('ID', foodResponse!.insertedId!),
              _buildResponseRow('Message', foodResponse!.message),
              _buildResponseRow('Status', foodResponse!.status.toString()),
            ],
          ),
        )
      : const SizedBox.shrink();
}

Widget _buildResponseRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$label: ',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Expanded(
        child: Text(value),
      ),
    ],
  );
}


  Widget foodListView() {
    return ListView.builder(
      itemCount: _foodList.length,
      itemBuilder: (context, index) {
        final food = _foodList[index];
        debugPrint(
            '📝 Makanan ${index + 1}: ${food.name} - ${food.calories} kcal');
        return ListTile(
          title: Text(food.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kategori: ${food.category}'),
              Text('Kalori: ${food.calories} kcal'),
              Text('Komposisi: ${food.ingredients}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  _showEditConfirmationDialog(context, food);
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  _showDeleteConfirmationDialog(context, food.id);
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditConfirmationDialog(BuildContext context, FoodsModel food) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Edit'),
          content: const Text('Anda yakin ingin mengedit data ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _nameCtl.text = food.name;
                  _ingredientsCtl.text = food.ingredients;
                  _descriptionCtl.text = food.description;
                  _caloriesCtl.text = food.calories.toString();
                  _selectedCategory = food.category;
                  isEdit = true;
                  foodId = food.id;
                });
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String foodId) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              FoodResponse? response = await _dataService.deleteFood(foodId);

              if (response != null) {
                await refreshFoodList();
                setState(() {}); // Pastikan UI di-refresh

                // Tampilkan response API di dalam card
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Menu Dihapus'),
                      content: Text(response.message ?? '✅ Menu berhasil dihapus!'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Gagal menghapus menu!'))
                );
              }
            },
            child: const Text('Ya'),
          ),
        ],
      );
    },
  );
}


  Future<void> refreshFoodList() async {
    try {
      debugPrint('📡 Mengambil data makanan dari API...');
      final foods = await _dataService.getAllMenuItem();

      if (foods == null || foods.isEmpty) {
        debugPrint('Tidak ada makanan yang ditemukan dari API');
      } else {
        debugPrint('Jumlah makanan yang diterima: ${foods.length}');
      }

      setState(() {
        _foodList = foods?.toList() ?? [];
      });
    } catch (e) {
      debugPrint('Error saat mengambil data makanan: $e');
    }
  }

  void clearFields() {
    _nameCtl.clear();
    _ingredientsCtl.clear();
    _descriptionCtl.clear();
    _caloriesCtl.clear();
    _selectedCategory = null;
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

  Future<List<FoodsModel>?> getAllMenuItem() async {
    try {
      debugPrint('🔍 Fetching menu...');

      final response = await dio.get(
        '$_baseUrl/menu',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      debugPrint('✅ Response status: ${response.statusCode}');
      debugPrint('📦 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => FoodsModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('❌ Error fetching menu: $e');
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama Makanan tidak boleh kosong';
    } else if (value.length < 4) {
      return 'Masukkan minimal 4 karakter';
    }
    return null;
  }

  String? _validateIngredients(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bahan-bahan tidak boleh kosong';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Deskripsi tidak boleh kosong';
    }
    return null;
  }

  String? _validateCalories(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kalori tidak boleh kosong';
    } else if (double.tryParse(value) == null) {
      return 'Kalori harus berupa angka';
    }
    return null;
  }

  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kategori tidak boleh kosong';
    }
    return null;
  }

  dynamic displaySnackbar(BuildContext context, String msg) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}