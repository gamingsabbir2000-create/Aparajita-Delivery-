import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AparajitaDeliveryApp());
}

// ---------------- MAIN APP ----------------
class AparajitaDeliveryApp extends StatelessWidget {
  const AparajitaDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aparajita Delivery',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// Global Shared Schedule Model
class ScheduleModel {
  String id;
  String entrepreneurName;
  String address;
  String customerName;
  String weight;
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
    required this.customerName,
    required this.weight,
    required this.bill,
    required this.pickupTime,
    required this.deliveryTime,
    this.note = '',
    this.assignedRider = 'Unassigned',
    this.status = 'Active',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'entrepreneurName': entrepreneurName,
        'address': address,
        'customerName': customerName,
        'weight': weight,
        'bill': bill,
        'pickupTime': pickupTime,
        'deliveryTime': deliveryTime,
        'note': note,
        'assignedRider': assignedRider,
        'status': status,
      };

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
        id: json['id'],
        entrepreneurName: json['entrepreneurName'],
        address: json['address'],
        customerName: json['customerName'],
        weight: json['weight'],
        bill: json['bill'],
        pickupTime: json['pickupTime'],
        deliveryTime: json['deliveryTime'],
        note: json['note'] ?? '',
        assignedRider: json['assignedRider'] ?? 'Unassigned',
        status: json['status'] ?? 'Active',
      );
}

// Persistence Handler to Save Data
class StorageService {
  static const String _key = 'aparajita_schedules_data';

  static Future<List<ScheduleModel>> loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString(_key);
    if (dataString == null) return [];
    List<dynamic> jsonList = jsonDecode(dataString);
    return jsonList.map((e) => ScheduleModel.fromJson(e)).toList();
  }

  static Future<void> saveSchedules(List<ScheduleModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    String dataString = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_key, dataString);
  }
}

List<ScheduleModel> globalSchedules = [];

// ---------------- LOGIN SCREEN ----------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = 'উদ্যোক্তা';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    globalSchedules = await StorageService.loadSchedules();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'অপরাজিতা ডেলিভারি',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'লগইন টাইপ সিলেক্ট করুন',
                        prefixIcon: const Icon(Icons.person_pin),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: ['উদ্যোক্তা', 'রাইডার']
                          .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'ফোন / ইমেইল',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'পাসওয়ার্ড',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DashboardScreen(userRole: selectedRole),
                            ),
                          );
                        },
                        child: const Text(
                          'লগইন করুন',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
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
class DashboardScreen extends StatefulWidget {
  final String userRole;
  const DashboardScreen({super.key, required this.userRole});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text('ড্যাশবোর্ড (${widget.userRole})'),
        backgroundColor: Colors.deepPurple,
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
        child: Column(
          children: [
            Card(
              color: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.deepPurple),
                title: const Text('ডেলিভারি তারিখ', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(formattedDate, style: const TextStyle(fontSize: 16, color: Colors.deepPurple)),
                trailing: ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('তারিখ পরিবর্তন'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  if (widget.userRole == 'উদ্যোক্তা')
                    _buildCard(
                      title: 'শিডিউল সাবমিট করুন',
                      icon: Icons.add_task,
                      color: Colors.deepPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScheduleSubmitScreen(),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                  _buildCard(
                    title: 'সকল শিডিউল (${globalSchedules.length})',
                    icon: Icons.list_alt,
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllSchedulesScreen(userRole: widget.userRole),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
                  _buildCard(
                    title: 'রাইডার তালিকা',
                    icon: Icons.two_wheeler,
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RiderListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- SCHEDULE SUBMIT FORM ----------------
class ScheduleSubmitScreen extends StatefulWidget {
  final ScheduleModel? scheduleToEdit;
  const ScheduleSubmitScreen({super.key, this.scheduleToEdit});

  @override
  State<ScheduleSubmitScreen> createState() => _ScheduleSubmitScreenState();
}

class _ScheduleSubmitScreenState extends State<ScheduleSubmitScreen> {
  final _nameController = TextEditingController(text: 'Nishat');
  final _addressController = TextEditingController();
  final _customerController = TextEditingController();
  final _weightController = TextEditingController(text: '1 pound');
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
      _customerController.text = widget.scheduleToEdit!.customerName;
      _weightController.text = widget.scheduleToEdit!.weight;
      _billController.text = widget.scheduleToEdit!.bill;
      _pickupController.text = widget.scheduleToEdit!.pickupTime;
      _deliveryController.text = widget.scheduleToEdit!.deliveryTime;
      _noteController.text = widget.scheduleToEdit!.note;
    }
  }

  Future<void> _saveSchedule() async {
    if (widget.scheduleToEdit != null) {
      widget.scheduleToEdit!.entrepreneurName = _nameController.text;
      widget.scheduleToEdit!.address = _addressController.text;
      widget.scheduleToEdit!.customerName = _customerController.text;
      widget.scheduleToEdit!.weight = _weightController.text;
      widget.scheduleToEdit!.bill = _billController.text;
      widget.scheduleToEdit!.pickupTime = _pickupController.text;
      widget.scheduleToEdit!.deliveryTime = _deliveryController.text;
      widget.scheduleToEdit!.note = _noteController.text;
    } else {
      final newSchedule = ScheduleModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entrepreneurName: _nameController.text,
        address: _addressController.text,
        customerName: _customerController.text,
        weight: _weightController.text,
        bill: _billController.text,
        pickupTime: _pickupController.text,
        deliveryTime: _deliveryController.text,
        note: _noteController.text,
      );
      globalSchedules.add(newSchedule);
    }

    await StorageService.saveSchedules(globalSchedules);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scheduleToEdit != null ? 'শিডিউল এডিট করুন' : 'শিডিউল সাবমিট করুন'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField('উদ্যোক্তার নাম (Name)', _nameController),
            _buildTextField('ঠিকানা (Address)', _addressController),
            _buildTextField('কাস্টমার (Customer)', _customerController),
            _buildTextField('ওজন (Weight)', _weightController),
            _buildTextField('বিল (Bill)', _billController),
            _buildTextField('পিকআপ সময় (Pickup Time)', _pickupController),
            _buildTextField('ডেলিভারি সময় (Delivery Time)', _deliveryController),
            _buildTextField('নোট (Note / Special Instructions)', _noteController, maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                onPressed: _saveSchedule,
                child: const Text('সাবমিট করুন', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
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
  final List<String> ridersList = ['রিয়া (Riya)', 'আরিফ (Arif)', 'সাকিব (Sakib)'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সকল শিডিউল গ্রুপ'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: globalSchedules.isEmpty
          ? const Center(child: Text('কোনো শিডিউল সাবমিট করা হয়নি।'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: globalSchedules.length,
              itemBuilder: (context, index) {
                final item = globalSchedules[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'শিডিউল #${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
                            ),
                            Chip(
                              label: Text(item.status),
                              backgroundColor: item.status == 'Active' ? Colors.green.shade100 : Colors.red.shade100,
                            )
                          ],
                        ),
                        const Divider(),
                        Text('উদ্যোক্তা নাম - ${item.entrepreneurName}'),
                        Text('ঠিকানা - ${item.address}'),
                        Text('কাস্টমার: ${item.customerName}'),
                        Text('ওজন: ${item.weight}'),
                        Text('Bill: ${item.bill}'),
                        Text('Pickup time: ${item.pickupTime}'),
                        Text('Delivery time: ${item.deliveryTime}'),
                        if (item.note.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('নোট: ${item.note}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          ),
                        const SizedBox(height: 8),
                        Text('অ্যাসাইন্ড রাইডার: ${item.assignedRider}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (widget.userRole == 'উদ্যোক্তা' && item.status == 'Active') ...[
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ScheduleSubmitScreen(scheduleToEdit: item),
                                    ),
                                  ).then((_) => setState(() {}));
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () async {
                                  setState(() {
                                    item.status = 'Cancelled';
                                  });
                                  await StorageService.saveSchedules(globalSchedules);
                                },
                              ),
                            ],
                            if (widget.userRole == 'রাইডার' && item.status == 'Active') ...[
                              DropdownButton<String>(
                                hint: const Text('রাইডার অ্যাসাইন করুন'),
                                items: ridersList.map((rider) {
                                  return DropdownMenuItem(value: rider, child: Text(rider));
                                }).toList(),
                                onChanged: (selectedRider) async {
                                  setState(() {
                                    item.assignedRider = selectedRider!;
                                  });
                                  await StorageService.saveSchedules(globalSchedules);
                                },
                              )
                            ]
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

// ---------------- RIDER LIST SCREEN ----------------
class RiderListScreen extends StatelessWidget {
  const RiderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> riders = [
      {'name': 'রিয়া (Riya)', 'schedules': globalSchedules.where((e) => e.assignedRider.contains('রিয়া')).length},
      {'name': 'আরিফ (Arif)', 'schedules': globalSchedules.where((e) => e.assignedRider.contains('আরিফ')).length},
      {'name': 'সাকিব (Sakib)', 'schedules': globalSchedules.where((e) => e.assignedRider.contains('সাকিব')).length},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('রাইডার তালিকা'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: riders.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final rider = riders[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(rider['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('মোট অ্যাসাইন্ড শিডিউল: ${rider['schedules']} টি'),
            ),
          );
        },
      ),
    );
  }
}
