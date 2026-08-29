import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase not configured via options yet: $e");
  }
  runApp(const AparajitaApp());
}

class AparajitaApp extends StatelessWidget {
  const AparajitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'আমরা অপরাজিতা',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFDEEF4),
        primaryColor: const Color(0xFF800040),
        useMaterial3: true,
      ),
      home: const SignUpScreen(),
    );
  }
}

// Watermark Wrapper Component
Widget buildWatermarkWrapper({required Widget child}) {
  return Stack(
    children: [
      Center(
        child: Opacity(
          opacity: 0.07,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.woman_rounded, size: 180, color: Color(0xFF800040)),
              SizedBox(height: 10),
              Text(
                'আমরা অপরাজিতা',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800040),
                ),
              ),
            ],
          ),
        ),
      ),
      child,
    ],
  );
}

// ---------------- SIGN UP SCREEN ----------------
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();

  Future<void> _handleSignUp() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String pass = _passController.text.trim();

    if (name.isEmpty) {
      _showMsg('অনুগ্রহ করে আপনার নাম লিখুন।');
      return;
    }
    if (phone.length < 11) {
      _showMsg('সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন।');
      return;
    }
    if (pass.length < 6) {
      _showMsg('পাসওয়ার্ড অন্তত ৬ অক্ষরের হতে হবে।');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_phone', phone);
    await prefs.setString('saved_pass', pass);
    await prefs.setString('saved_name', name);

    try {
      FirebaseFirestore.instance.collection('users').doc(phone).set({
        'name': name,
        'phone': phone,
        'role': 'entrepreneur',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}

    _showMsg('সাইন আপ সফল হয়েছে!');

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সাইন আপ - আমরা অপরাজিতা'),
        backgroundColor: const Color(0xFF800040),
        foregroundColor: Colors.white,
      ),
      body: buildWatermarkWrapper(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(Icons.woman_rounded, size: 80, color: Color(0xFF800040)),
                  const Text('আমরা অপরাজিতা', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF800040))),
                  const SizedBox(height: 20),
                  _buildInput('নাম (Name)', _nameController),
                  _buildInput('মোবাইল নম্বর (১১ ডিজিট)', _phoneController, isPhone: true),
                  _buildInput('পাসওয়ার্ড (কমপক্ষে ৬ অক্ষর)', _passController, isPass: true),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800040)),
                      onPressed: _handleSignUp,
                      child: const Text('সাইন আপ করুন', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text('ইতিমধ্যে অ্যাকাউন্ট আছে? লগইন করুন', style: TextStyle(color: Color(0xFF800040))),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {bool isPhone = false, bool isPass = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          fillColor: Colors.white.withOpacity(0.8),
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

// ---------------- LOGIN SCREEN ----------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString('saved_phone');
    String? pass = prefs.getString('saved_pass');

    if (phone != null && pass != null) {
      setState(() {
        _phoneController.text = phone;
        _passController.text = pass;
      });
    }
  }

  Future<void> _handleLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPhone = prefs.getString('saved_phone');
    String? savedPass = prefs.getString('saved_pass');

    String enteredPhone = _phoneController.text.trim();
    String enteredPass = _passController.text.trim();

    if (savedPhone == null || savedPass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কোনো অ্যাকাউন্ট পাওয়া যায়নি। প্রথমে সাইন আপ করুন।')),
      );
      return;
    }

    if (enteredPhone == savedPhone && enteredPass == savedPass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('মোবাইল নম্বর বা পাসওয়ার্ড ভুল হয়েছে!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('লগইন - আমরা অপরাজিতা'),
        backgroundColor: const Color(0xFF800040),
        foregroundColor: Colors.white,
      ),
      body: buildWatermarkWrapper(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(Icons.woman_rounded, size: 80, color: Color(0xFF800040)),
                  const Text('আমরা অপরাজিতা', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF800040))),
                  const SizedBox(height: 20),
                  _buildInput('মোবাইল নম্বর', _phoneController, isPhone: true),
                  _buildInput('পাসওয়ার্ড', _passController, isPass: true),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800040)),
                      onPressed: _handleLogin,
                      child: const Text('লগইন করুন', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {bool isPhone = false, bool isPass = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          fillColor: Colors.white.withOpacity(0.8),
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

// ---------------- DASHBOARD SCREEN ----------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ড্যাশবোর্ড - আমরা অপরাজিতা'),
        backgroundColor: const Color(0xFF800040),
        foregroundColor: Colors.white,
      ),
      body: buildWatermarkWrapper(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('schedules').snapshots(),
                builder: (context, snapshot) {
                  int totalCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('মোট শিডিউল:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF800040))),
                        Text('$totalCount', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF800040))),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800040),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.folder, color: Colors.white),
                  label: const Text('রাইডার ফোল্ডার (সকল রাইডার ও শিডিউল দেখুন)', style: TextStyle(color: Colors.white, fontSize: 14)),
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                  side: const BorderSide(color: Color(0xFF800040)),
                  backgroundColor: Colors.white.withOpacity(0.5),
                ),
                icon: const Icon(Icons.calendar_today, size: 18, color: Color(0xFF800040)),
                label: const Text('তারিখ: 30 August, 2026 (পরিবর্তন করুন)', style: TextStyle(color: Color(0xFF800040))),
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800040),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('+  শিডিউল দিন', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddScheduleScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text('জমা দেওয়া শিডিউলসমূহ (লাইভ):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A002A))),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('schedules').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF800040)));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('কোনো শিডিউল জমা দেওয়া হয়নি।', style: TextStyle(color: Colors.grey)));
                    }
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return Card(
                          color: Colors.white.withOpacity(0.9),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text('${data['customerName'] ?? ''} (${data['bill'] ?? ''})', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('উদ্যোক্তা: ${data['entrepreneurName'] ?? ''}\nপিকআপ: ${data['pickupTime'] ?? ''} | ডেলিভারি: ${data['deliveryTime'] ?? ''}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- ADD SCHEDULE SCREEN ----------------
class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  String scheduleType = 'সাধারণ শিডিউল';

  final _entNameController = TextEditingController(text: 'Nishat');
  final _entAddressController = TextEditingController();
  final _entPhoneController = TextEditingController();

  final _custNameController = TextEditingController();
  final _custPhoneController = TextEditingController();
  final _custAddressController = TextEditingController();

  final _billController = TextEditingController();
  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _dateController = TextEditingController(text: '30 August, 2026');
  final _noteController = TextEditingController();

  Future<void> _saveSchedule() async {
    try {
      await FirebaseFirestore.instance.collection('schedules').add({
        'type': scheduleType,
        'entrepreneurName': _entNameController.text,
        'entrepreneurAddress': _entAddressController.text,
        'entrepreneurPhone': _entPhoneController.text,
        'customerName': _custNameController.text,
        'customerPhone': _custPhoneController.text,
        'customerAddress': _custAddressController.text,
        'bill': _billController.text,
        'pickupTime': _pickupController.text,
        'deliveryTime': _deliveryController.text,
        'deliveryDate': _dateController.text,
        'note': _noteController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('শিডিউল সফলভাবে ক্লাউডে সেভ হয়েছে!')));
    } catch (e) {
      debugPrint("Database Save Error: $e");
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('নতুন শিডিউল তৈরি করুন'),
        backgroundColor: const Color(0xFF800040),
        foregroundColor: Colors.white,
      ),
      body: buildWatermarkWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('শিডিউলের ধরন:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF800040))),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('সাধারণ শিডিউল'),
                    selected: scheduleType == 'সাধারণ শিডিউল',
                    selectedColor: const Color(0xFFF0D0E0),
                    onSelected: (val) => setState(() => scheduleType = 'সাধারণ শিডিউল'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('অফার শিডিউল'),
                    selected: scheduleType == 'অফার শিডিউল',
                    selectedColor: const Color(0xFFF0D0E0),
                    onSelected: (val) => setState(() => scheduleType = 'অফার শিডিউল'),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Text('উদ্যোক্তার তথ্য', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF800040))),
              _buildField('উদ্যোক্তার নাম', _entNameController),
              _buildField('উদ্যোক্তার ঠিকানা', _entAddressController),
              _buildField('উদ্যোক্তার ফোন নম্বর', _entPhoneController, icon: Icons.phone),
              const SizedBox(height: 15),
              const Text('কাস্টমার তথ্য', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF800040))),
              _buildField('কাস্টমার নাম', _custNameController),
              _buildField('কাস্টমার ফোন নম্বর', _custPhoneController, icon: Icons.phone),
              _buildField('কাস্টমার ঠিকানা', _custAddressController),
              _buildField('বিল + ডেলিভারি চার্জ', _billController),
              _buildField('পিকআপ সময়', _pickupController),
              _buildField('ডেলিভারি সময়', _deliveryController),
              _buildField('ডেলিভারি তারিখ', _dateController),
              _buildField('নোট', _noteController, maxLines: 2),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800040),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: _saveSchedule,
                  child: const Text('সংরক্ষণ করুন', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController controller, {IconData? icon, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF800040), size: 20) : null,
          fillColor: Colors.white.withOpacity(0.7),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
