import 'package:flutter/material.dart';
import 'package:kaloriku/services/auth_manager.dart';
import 'package:kaloriku/view/screen/menu_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selamat Datang di KaloriKu!',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromARGB(255, 123, 173, 230),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: constraints.maxWidth > 600 ? 350 : 250,
                      decoration: BoxDecoration(
                        // image: const DecorationImage(
                        //   image: AssetImage("assets/images/KaloriKu.png"),
                        //   fit: BoxFit.cover,
                        // ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: constraints.maxWidth > 600 ? 350 : 250,
                      color: Colors.black.withOpacity(0.4),
                      alignment: Alignment.center,
                      child: const Text(
                        "KaloriKu membantu Anda dalam memilih makanan sehat, menghitung kalori. dan mendapatkan rekomendasi menu sesuai kebutuhan gizi Anda. ",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 4.0,
                              color: Colors.black26,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    color: Colors.white,
                    shadowColor: const Color.fromARGB(255, 63, 76, 160),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Apa Itu KaloriKu?",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 129, 135, 199),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "KaloriKu adalah aplikasi catering sehat yang dirancang untuk membantu pengguna dalam memilih makanan sehat, menghitung kalori, dan mendapatkan rekomendasi menu sesuai dengan kebutuhan gizi mereka. Dengan fitur unggulan, KaloriKu menawarkan solusi praktis untuk hidup lebih sehat dan teratur.",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                );
                              },
                              child: const Text('Login'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 199, 202, 214),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 12),
                                textStyle: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}