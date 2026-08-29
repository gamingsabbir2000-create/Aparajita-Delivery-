import 'package:flutter/material.dart';

void main() {
  runApp(const AparajitaApp());
}

// ---------------- MAIN APP ----------------
class AparajitaApp extends StatelessWidget {
  const AparajitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'আমরা অপরাজিতা',
      theme: ThemeData(
        primaryColor: const Color(0xFF6B003B),
        useMaterial3: true,
      ),
      home: const SignUpScreen(),
    );
  }
}

// Global Schedule Model
class ScheduleModel {
  String id;
  String entrepreneurName;
  String address;
  String phone;
  String customerName;
  String bill;
  String pickupTime;
  String deliveryTime;
  String note;
  String assignedRider;
  String status;

  ScheduleModel({
    required this.id,
    required this.entrepreneurName,
    required this.address,
    required this.phone,
    required this.customerName,
    required this.bill,
    required this.pickupTime,
    required this.deliveryTime,
    this.note = '',
    this.assignedRider = 'Unassigned',
    this.status = 'Active',
  });
}

List<ScheduleModel> globalSchedules = [];

// Custom Branding Background & Logo Widget
Widget buildBrandingHeader() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.15),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(
          Icons.woman_rounded, // Visual representation of Aparajita Icon
          size: 65,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 10),
      const Text(
        'আমরা অপরাজিতা',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    ],
  );
}

BoxDecoration brandingBackground() {
  return const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF3B0020), Color(0xFF6B003B), Color(0xFF8B004B)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );
}

// ---------------- SIGN UP SCREEN ----------------
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String selectedRole = 'উদ্যোক্তা';
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: brandingBackground(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildBrandingHeader(),
                    const SizedBox(height: 20),
                    const Text('অ্যাকাউন্ট সাইন আপ করুন',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6B003B))),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'রোল সিলেক্ট করুন',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['উদ্যোক্তা', 'রাইডার']
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedRole = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'নাম (Name)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'মোবাইল নম্বর',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'পাসওয়ার্ড',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B003B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('সাইন আপ সফল হয়েছে! এখন লগইন করুন।')),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text('সাইন আপ করুন', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text('ইতিমধ্যে অ্যাকাউন্ট আছে? লগইন করুন'),
                    )
                  ],
                ),
              ),
            ),
          ),
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
  String selectedRole = 'উদ্যোক্তা';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: brandingBackground(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildBrandingHeader(),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'লগইন রোল',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['উদ্যোক্তা', 'রাইডার']
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedRole = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'মোবাইল নম্বর',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'পাসওয়ার্ড',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B003B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DashboardScreen(userRole: selectedRole),
                            ),
                          );
                        },
                        child: const Text('লগইন করুন', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- DASHBOARD SCREEN ----------------
class DashboardScreen extends StatelessWidget {
  final String userRole;
  const DashboardScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('আমরা অপরাজিতা ($userRole)'),
        backgroundColor: const Color(0xFF6B003B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            if (userRole == 'উদ্যোক্তা')
              _buildFolderCard(
                context,
                title: 'শিডিউল সাবমিট করুন',
                icon: Icons.note_add_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScheduleSubmitScreen()),
                  );
                },
              ),
            _buildFolderCard(
              context,
              title: 'সকল শিডিউল ফোল্ডার (${globalSchedules.length})',
              icon: Icons.folder_special_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllSchedulesScreen(userRole: userRole)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF6B003B).withOpacity(0.08),
          border: Border.all(color: const Color(0xFF6B003B), width: 1.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: const Color(0xFF6B003B)),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B003B))),
          ],
        ),
      ),
    );
  }
}

// ---------------- SCHEDULE FORM SCREEN ----------------
class ScheduleSubmitScreen extends StatefulWidget {
  final ScheduleModel? scheduleToEdit;
  const ScheduleSubmitScreen({super.key, this.scheduleToEdit});

  @override
  State<ScheduleSubmitScreen> createState() => _ScheduleSubmitScreenState();
}

class _ScheduleSubmitScreenState extends State<ScheduleSubmitScreen> {
  final _nameController = TextEditingController(text: 'Nishat');
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _customerController = TextEditingController();
  final _billController = TextEditingController();
  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.scheduleToEdit != null) {
      _nameController.text = widget.scheduleToEdit!.entrepreneurName;
      _addressController.text = widget.scheduleToEdit!.address;
      _phoneController.text = widget.scheduleToEdit!.phone;
      _customerController.text = widget.scheduleToEdit!.customerName;
      _billController.text = widget.scheduleToEdit!.bill;
      _pickupController.text = widget.scheduleToEdit!.pickupTime;
      _deliveryController.text = widget.scheduleToEdit!.deliveryTime;
      _noteController.text = widget.scheduleToEdit!.note;
    }
  }

  void _saveSchedule() {
    if (widget.scheduleToEdit != null) {
      widget.scheduleToEdit!.entrepreneurName = _nameController.text;
      widget.scheduleToEdit!.address = _addressController.text;
      widget.scheduleToEdit!.phone = _phoneController.text;
      widget.scheduleToEdit!.customerName = _customerController.text;
      widget.scheduleToEdit!.bill = _billController.text;
      widget.scheduleToEdit!.pickupTime = _pickupController.text;
      widget.scheduleToEdit!.deliveryTime = _deliveryController.text;
      widget.scheduleToEdit!.note = _noteController.text;
    } else {
      globalSchedules.add(
        ScheduleModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          entrepreneurName: _nameController.text,
          address: _addressController.text,
          phone: _phoneController.text,
          customerName: _customerController.text,
          bill: _billController.text,
          pickupTime: _pickupController.text,
          deliveryTime: _deliveryController.text,
          note: _noteController.text,
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scheduleToEdit != null ? 'শিডিউল এডিট' : 'নতুন শিডিউল'),
        backgroundColor: const Color(0xFF6B003B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildField('উদ্যোক্তা নাম', _nameController),
            _buildField('ঠিকানা', _addressController),
            _buildField('ফোন নং', _phoneController, isPhone: true),
            _buildField('কাস্টমার', _customerController),
            _buildField('Bill', _billController),
            _buildField('Pickup time', _pickupController),
            _buildField('Delivery time', _deliveryController),
            _buildField('Note', _noteController, maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B003B)),
                onPressed: _saveSchedule,
                child: const Text('সাবমিট করুন', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {int maxLines = 1, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

// ---------------- ALL SCHEDULES SCREEN ----------------
class AllSchedulesScreen extends StatefulWidget {
  final String userRole;
  const AllSchedulesScreen({super.key, required this.userRole});

  @override
  State<AllSchedulesScreen> createState() => _AllSchedulesScreenState();
}

class _AllSchedulesScreenState extends State<AllSchedulesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('শিডিউল ফোল্ডার'),
        backgroundColor: const Color(0xFF6B003B),
        foregroundColor: Colors.white,
      ),
      body: globalSchedules.isEmpty
          ? const Center(child: Text('কোনো শিডিউল পাওয়া যায়নি।'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: globalSchedules.length,
              itemBuilder: (context, index) {
                final item = globalSchedules[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('উদ্যোক্তা নাম - ${item.entrepreneurName}'),
                        Text('ঠিকানা - ${item.address}'),
                        Text('ফোন নং - ${item.phone}'),
                        const SizedBox(height: 6),
                        Text('কাস্টমার: ${item.customerName}'),
                        Text('Bill: ${item.bill}'),
                        Text('Pickup time: ${item.pickupTime}'),
                        Text('Delivery time: ${item.deliveryTime}'),
                        Text('Note: ${item.note}'),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('রাইডার: ${item.assignedRider}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (widget.userRole == 'উদ্যোক্তা')
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ScheduleSubmitScreen(scheduleToEdit: item)),
                                  ).then((_) => setState(() {}));
                                },
                              )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
