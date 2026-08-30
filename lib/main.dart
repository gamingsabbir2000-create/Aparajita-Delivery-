import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'admin_login_page.dart'; // নতুন ফাইলটি এখানে ইমপোর্ট করা হলো

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aparajita Delivery Admin',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const AdminLoginPage(), // অ্যাপ চালু হলে সরাসরি অ্যাডমিন লগইন পেজ আসবে
    );
  }
}
