import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }
  runApp(const AparajitaApp());
}

class AparajitaApp extends StatelessWidget {
  const AparajitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'অপরাজিতা অ্যাপস',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFDEEF4),
        primaryColor: const Color(0xFF800040),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

// ---------------- WATERMARK WRAPPER ----------------
Widget buildWatermarkWrapper({required Widget child}) {
  return Stack(
    children: [
      Center(
        child: Opacity(
          opacity: 0.05,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.woman_rounded, size: 140, color: Color(0xFF800040)),
              SizedBox(height: 8),
              Text(
                'অপরাজিতা অ্যাপস',
                style: TextStyle(
                  fontSize: 26,
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

    if (enteredPhone.isEmpty || enteredPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ফোন নম্বর এবং পাসওয়ার্ড দিন।')),
      );
      return;
    }

    if (savedPhone == null || savedPass == null) {
      await prefs.setString('saved_phone', enteredPhone);
      await prefs.setString('saved_pass', enteredPass);
      await prefs.setString('user_role', 'entrepreneur');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('লগইন - অপরাজিতা অ্যাপস', style: TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF800040),
        foregroundColor: Colors.white,
      ),
      body: buildWatermarkWrapper(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(Icons.woman_rounded, size: 60, color: Color(0xFF800040)),
                  const SizedBox(height: 5),
                  const Text('অপরাজিতা অ্যাপস', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF800040))),
                  const SizedBox(height: 15),
                  _buildInput('মোবাইল নম্বর', _phoneController, isPhone: true),
                  _buildInput('পাসওয়ার্ড', _passController, isPass: true),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800040)),
                      onPressed: _handleLogin,
                      child: const Text('লগইন করুন', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      'নতুন অ্যাকাউন্ট তৈরি করবেন? সাইন আপ করুন',
                      style: TextStyle(color: Color(0xFF800040), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        style: const TextStyle(fontSize: 14),
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          fillColor: Colors.white.withOpacity(0.9),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
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
  String _selectedRole = 'entrepreneur';

  Future<void> _handleSignUp() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String pass = _passController.text.trim();

    if (name.isEmpty || phone.length < 11 || pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সঠিক তথ্য প্রদান করুন।')));
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_phone', phone);
    await prefs.setString('saved_pass', pass);
    await prefs.setString('saved_name', name);
    await prefs.setString('user_role', _selectedRole);

    try {
      if (Firebase.apps.isNotEmpty) {
        FirebaseFirestore.instance.collection('users').doc(phone).set({
          'name': name,
          'phone': phone,
          'role': _selectedRole,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সাইন আপ সফল হয়েছে!')));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সাইন আপ - অপরাজিতা অ্যাপস', style: TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF800040),
        foregroundColor: Colors.white,
      ),
      body: buildWatermarkWrapper(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(Icons.person_add, size: 50, color: Color(0xFF800040)),
                  const SizedBox(height: 10),
                  _buildInput('নাম (Name)', _nameController),
                  _buildInput('মোবাইল নম্বর', _phoneController, isPhone: true),
                  _buildInput('পাসওয়ার্ড', _passController, isPass: true),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('উদ্যোক্তা', style: TextStyle(fontSize: 12)),
                        selected: _selectedRole == 'entrepreneur',
                        onSelected: (val) => setState(() => _selectedRole = 'entrepreneur'),
                        selectedColor: const Color(0xFF800040),
                        labelStyle: TextStyle(color: _selectedRole == 'entrepreneur' ? Colors.white : Colors.black),
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('রাইডার', style: TextStyle(fontSize: 12)),
                        selected: _selectedRole == 'rider',
                        onSelected: (val) => setState(() => _selectedRole = 'rider'),
                        selectedColor: const Color(0xFF800040),
                        labelStyle: TextStyle(color: _selectedRole == 'rider' ? Colors.white : Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800040)),
                      onPressed: _handleSignUp,
                      child: const Text('সাইন আপ করুন', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ইতিমধ্যে অ্যাকাউন্ট আছে? লগইন করুন', style: TextStyle(color: Color(0xFF800040), fontSize: 12)),
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
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        style: const TextStyle(fontSize: 14),
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          fillColor: Colors.white.withOpacity(0.9),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
  DateTime _selectedDate = DateTime.now();
  String _userRole = 'entrepreneur';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('user_role') ?? 'entrepreneur';
    });
  }

  String get _formattedDate => DateFormat('dd MMMM, yyyy').format(_selectedDate);
  String get _dateKey => DateFormat('yyyy-MM-dd').format(_selectedDate);

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFirebaseReady = Firebase.apps.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('অপরাজিতা অ্যাপস', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF800040),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: buildWatermarkWrapper(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: isFirebaseReady
                    ? FirebaseFirestore.instance.collection('schedules').where('dateKey', isEqualTo: _dateKey).snapshots()
                    : null,
                builder: (context, snapshot) {
                  int total = snapshot.hasData ? snapshot.data!.docs.length : 0;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF800040).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('মোট শিডিউল (আজ):', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF800040))),
                        Text('$total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF800040))),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800040),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.folder, color: Colors.white, size: 18),
                  label: const Text('রাইডার ফোল্ডার (সকল রাইডার ও শিডিউল)', style: TextStyle(color: Colors.white, fontSize: 13)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RiderFolderScreen()));
                  },
                ),
              ),
              const SizedBox(height: 6),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 38),
                  side: const BorderSide(color: Color(0xFF800040)),
                  backgroundColor: Colors.white.withOpacity(0.7),
                ),
                icon: const Icon(Icons.calendar_today, size: 16, color: Color(0xFF800040)),
                label: Text('তারিখ: $_formattedDate (পরিবর্তন করুন)', style: const TextStyle(color: Color(0xFF800040), fontSize: 12)),
                onPressed: _pickDate,
              ),
              const SizedBox(height: 6),

              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800040),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddEditScheduleScreen()),
                    );
                  },
                  child: const Text('+  শিডিউল জমা দিন', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),

              const Text('জমা দেওয়া শিডিউলসমূহ:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF800040))),
              const SizedBox(height: 6),

              Expanded(
                child: isFirebaseReady
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('schedules')
                            .where('dateKey', isEqualTo: _dateKey)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: Color(0xFF800040)));
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('এই তারিখে কোনো শিডিউল জমা দেওয়া হয়নি।', style: TextStyle(fontSize: 12, color: Colors.grey)));
                          }

                          final docs = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              return ScheduleCard(
                                docId: doc.id,
                                serialNo: index + 1,
                                data: data,
                                userRole: _userRole,
                              );
                            },
                          );
                        },
                      )
                    : const Center(child: Text('কোনো শিডিউল তথ্য নেই।', style: TextStyle(fontSize: 12, color: Colors.grey))),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- SCHEDULE CARD COMPONENT ----------------
class ScheduleCard extends StatelessWidget {
  final String docId;
  final int serialNo;
  final Map<String, dynamic> data;
  final String userRole;

  const ScheduleCard({
    super.key,
    required this.docId,
    required this.serialNo,
    required this.data,
    required this.userRole,
  });

  void _togglePickup() {
    bool current = data['isPicked'] ?? false;
    FirebaseFirestore.instance.collection('schedules').doc(docId).update({'isPicked': !current});
  }

  void _togglePayment() {
    bool current = data['isPaid'] ?? false;
    bool wasChanged = data['isPaymentChanged'] ?? false;

    FirebaseFirestore.instance.collection('schedules').doc(docId).update({
      'isPaid': !current,
      'isPaymentChanged': true, // Payment status updated flag
    });
  }

  void _addReact(String emoji) {
    Map<String, dynamic> reacts = Map<String, dynamic>.from(data['reacts'] ?? {});
    reacts[emoji] = (reacts[emoji] ?? 0) + 1;
    FirebaseFirestore.instance.collection('schedules').doc(docId).update({'reacts': reacts});
  }

  @override
  Widget build(BuildContext context) {
    bool isPicked = data['isPicked'] ?? false;
    bool isPaid = data['isPaid'] ?? false;
    bool isPaymentChanged = data['isPaymentChanged'] ?? false;
    Map<String, dynamic> reacts = data['reacts'] ?? {};

    return Card(
      color: Colors.white.withOpacity(0.95),
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF800040), borderRadius: BorderRadius.circular(4)),
                  child: Text('সিরিয়াল #$serialNo', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                Row(
                  children: [
                    if (isPicked) const Padding(padding: EdgeInsets.only(right: 4), child: Text('✅ পিকআপ সম্পন্ন', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold))),
                    if (isPaid) const Text('🅿️ পেমেন্ট সম্পন্ন', style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16, color: Colors.grey),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditScheduleScreen(docId: docId, existingData: data)));
                      },
                    )
                  ],
                )
              ],
            ),
            if (isPaymentChanged)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4)),
                  child: const Text('⚠️ 🅿️ পেমেন্ট স্টেটাস আপডেট/পরিবর্তন করা হয়েছে', style: TextStyle(fontSize: 10, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                ),
              ),
            const Divider(height: 12),

            Text('ধরন: ${data['type'] ?? 'সাধারণ শিডিউল'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF800040))),
            const SizedBox(height: 4),
            Text('উদ্যোক্তা: ${data['entrepreneurName'] ?? ''} (${data['entrepreneurPhone'] ?? ''})', style: const TextStyle(fontSize: 12)),
            Text('ঠিকানা: ${data['entrepreneurAddress'] ?? ''}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
            const SizedBox(height: 6),
            Text('কাস্টমার: ${data['customerName'] ?? ''} (${data['customerPhone'] ?? ''})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text('ঠিকানা: ${data['customerAddress'] ?? ''}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('বিল: ${data['bill'] ?? '0'} ৳', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                Text('পিকআপ: ${data['pickupTime'] ?? ''} | ডেলিভারি: ${data['deliveryTime'] ?? ''}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
            if ((data['note'] ?? '').toString().isNotEmpty) Text('নোট: ${data['note']}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
            const Divider(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: BorderSide(color: isPicked ? Colors.green : Colors.grey),
                    ),
                    onPressed: _togglePickup,
                    child: Text(isPicked ? '✅ পিকআপ করা হয়েছে' : 'পিকআপ করুন (✅)', style: const TextStyle(fontSize: 10, color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: BorderSide(color: isPaid ? Colors.blue : Colors.grey),
                    ),
                    onPressed: _togglePayment,
                    child: Text(isPaid ? '🅿️ পেমেন্ট কমপ্লিট' : 'পেমেন্ট মার্জিন (🅿️)', style: const TextStyle(fontSize: 10, color: Colors.black)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['👍', '❤️', '😳', '☺️'].map((emoji) {
                int count = reacts[emoji] ?? 0;
                return InkWell(
                  onTap: () => _addReact(emoji),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: Text('$emoji $count', style: const TextStyle(fontSize: 12)),
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}

// ---------------- ADD / EDIT SCHEDULE SCREEN ----------------
class AddEditScheduleScreen extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;

  const AddEditScheduleScreen({super.key, this.docId, this.existingData});

  @override
  State<AddEditScheduleScreen> createState() => _AddEditScheduleScreenState();
}

class _AddEditScheduleScreenState extends State<AddEditScheduleScreen> {
  String scheduleType = 'সাধারণ শিডিউল';

  final _entNameController = TextEditingController();
  final _entAddressController = TextEditingController();
  final _entPhoneController = TextEditingController();

  final _custNameController = TextEditingController();
  final _custPhoneController = TextEditingController();
  final _custAddressController = TextEditingController();

  final _billController = TextEditingController();
  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _dateController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      final d = widget.existingData!;
      scheduleType = d['type'] ?? 'সাধারণ শিডিউল';
      _entNameController.text = d['entrepreneurName'] ?? '';
      _entAddressController.text = d['entrepreneurAddress'] ?? '';
      _entPhoneController.text = d['entrepreneurPhone'] ?? '';
      _custNameController.text = d['customerName'] ?? '';
      _custPhoneController.text = d['customerPhone'] ?? '';
      _custAddressController.text = d['customerAddress'] ?? '';
      _billController.text = d['bill'] ?? '';
      _pickupController.text = d['pickupTime'] ?? '';
      _deliveryController.text = d['deliveryTime'] ?? '';
      _dateController.text = d['deliveryDate'] ?? '';
      _noteController.text = d['note'] ?? '';
    } else {
      _dateController.text = DateFormat('dd MMMM, yyyy').format(DateTime.now());
    }
  }

  Future<void> _saveSchedule() async {
    String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    Map<String, dynamic> payload = {
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
      'dateKey': dateKey,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      if (Firebase.apps.isNotEmpty) {
        if (widget.docId != null) {
          await FirebaseFirestore.instance.collection('schedules').doc(widget.docId).update(payload);
        } else {
          payload['isPicked'] = false;
          payload['isPaid'] = false;
          payload['isPaymentChanged'] = false;
          payload['reacts'] = {};
          await FirebaseFirestore.instance.collection('schedules').add(payload);
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('শিডিউল সংরক্ষণ করা হয়েছে!')));
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Save error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docId == null ? 'নতুন শিডিউল তৈরি করুন' : 'শিডিউল এডিট করুন', style: const TextStyle(fontSize: 15)),
        backgroundColor: const Color(0xFF800040),
        foregroundColor: Colors.white,
      ),
      body: buildWatermarkWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('শিডিউলের ধরন:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF800040))),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('সাধারণ শিডিউল', style: TextStyle(fontSize: 12)),
                      value: 'সাধারণ শিডিউল',
                      groupValue: scheduleType,
                      onChanged: (val) => setState(() => scheduleType = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('অফার শিডিউল', style: TextStyle(fontSize: 12)),
                      value: 'অফার শিডিউল',
                      groupValue: scheduleType,
                      onChanged: (val) => setState(() => scheduleType = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              const Text('উদ্যোক্তার তথ্য', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF800040))),
              _buildField('উদ্যোক্তার নাম', _entNameController),
              _buildField('উদ্যোক্তার ঠিকানা', _entAddressController),
              _buildField('উদ্যোক্তার ফোন নম্বর', _entPhoneController, isPhone: true),

              const SizedBox(height: 10),
              const Text('কাস্টমার তথ্য', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF800040))),
              _buildField('কাস্টমার নাম', _custNameController),
              _buildField('কাস্টমার ফোন নম্বর', _custPhoneController, isPhone: true),
              _buildField('কাস্টমার ঠিকানা', _custAddressController),
              _buildField('বিল + ডেলিভারি চার্জ', _billController),
              _buildField('পিকআপ সময়', _pickupController),
              _buildField('ডেলিভারি সময়', _deliveryController),
              _buildField('ডেলিভারি তারিখ', _dateController),
              _buildField('নোট', _noteController, maxLines: 2),

              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800040)),
                  onPressed: _saveSchedule,
                  child: const Text('সংরক্ষণ করুন', style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController controller, {bool isPhone = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 13),
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12),
          fillColor: Colors.white.withOpacity(0.8),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}

// ---------------- RIDER FOLDER SCREEN ----------------
class RiderFolderScreen extends StatelessWidget {
  const RiderFolderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isFirebaseReady = Firebase.apps.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('রাইডার ফোল্ডার', style: TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF800040),
        foregroundColor: Colors.white,
      ),
      body: buildWatermarkWrapper(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: isFirebaseReady
              ? StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'rider').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('কোনো রাইডার নিবন্ধিত নেই।', style: TextStyle(fontSize: 12)));
                    }
                    final riders = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: riders.length,
                      itemBuilder: (context, index) {
                        final r = riders[index].data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const CircleAvatar(backgroundColor: Color(0xFF800040), child: Icon(Icons.two_wheeler, color: Colors.white, size: 20)),
                            title: Text(r['name'] ?? 'রাইডার', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            subtitle: Text('ফোন: ${r['phone'] ?? ''}', style: const TextStyle(fontSize: 12)),
                          ),
                        );
                      },
                    );
                  },
                )
              : const Center(child: Text('রাইডার তালিকা খালি।', style: TextStyle(fontSize: 12))),
        ),
      ),
    );
  }
}
