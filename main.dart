import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const AmraAporajitaApp());
}

List<ScheduleModel> globalSchedules = [];

class CustomerDetailItem {
  String name;
  String phone;
  String address;
  String bill;

  CustomerDetailItem({
    this.name = '',
    this.phone = '',
    this.address = '',
    this.bill = '',
  });
}

class ScheduleModel {
  final String id;
  String entrepreneurName;
  String address;
  String phone;
  
  String customerName;
  String customerPhone;
  String customerAddress;
  String bill;

  String pickupTime;
  String deliveryTime;
  String deliveryDate;
  String note;
  bool isOffer;
  String selectedReaction;
  bool isPaymentCleared; // পেমেন্ট ক্লিয়ার স্ট্যাটাস (একবার true হলে পরিবর্তন লক)
  bool isTampered;       // পরিবর্তন করা হয়েছে কিনা (বি মার্ক)
  List<CustomerDetailItem> bulkCustomers;

  ScheduleModel({
    required this.id,
    required this.entrepreneurName,
    required this.address,
    required this.phone,
    this.customerName = '',
    this.customerPhone = '',
    this.customerAddress = '',
    required this.bill,
    required this.pickupTime,
    required this.deliveryTime,
    required this.deliveryDate,
    required this.note,
    this.isOffer = false,
    this.selectedReaction = '',
    this.isPaymentCleared = false,
    this.isTampered = false,
    List<CustomerDetailItem>? bulkCustomers,
  }) : bulkCustomers = bulkCustomers ?? [];
}

class AmraAporajitaApp extends StatelessWidget {
  const AmraAporajitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'আমরা অপরাজিতা',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF880E4F),
          primary: const Color(0xFF880E4F),
          secondary: const Color(0xFFAD1457),
        ),
        scaffoldBackgroundColor: const Color(0xFFFCE4EC),
      ),
      home: const LoginScreen(),
    );
  }
}

class SafeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const SafeTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _handleLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF880E4F), Color(0xFFC2185B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'আমরা অপরাজিতা',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      SafeTextField(controller: emailController, labelText: 'ফোন বা ইমেইল'),
                      const SizedBox(height: 15),
                      SafeTextField(controller: passwordController, labelText: 'পাসওয়ার্ড', obscureText: true),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF880E4F),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('লগইন করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<String> reactions = ['❤️', '👍', '😮', '☺️', '😡', '🅿️'];
  final List<String> riders = ['রাইডার রহিম', 'রাইডার করিম', 'রাইডার শাকিল', 'রাইডার জনি'];
  DateTime selectedDashboardDate = DateTime.now();

  void _showCallSimulation(BuildContext context, String title, String number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('নম্বরটিতে কল করতে চান: $number?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ডায়াল করা হচ্ছে: $number')),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('কল করুন'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDashboardDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDashboardDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && picked != selectedDashboardDate) {
      setState(() {
        selectedDashboardDate = picked;
      });
    }
  }

  void _assignRiderAndReact(ScheduleModel schedule, String emoji) {
    if (emoji == '🅿️') {
      // যদি একবার পেমেন্ট ক্লিয়ার হয়ে গিয়ে থাকে, তবে পুনরায় টগল বা অফ করতে গেলে তা 'বি' (Tampered) হিসেবে চিহ্নিত হবে
      if (schedule.isPaymentCleared) {
        setState(() {
          schedule.isTampered = true; // পরিবর্তন করার চেষ্টা করা হয়েছে বুঝাতে 'বি' মার্ক
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সতর্কতা: পেমেন্ট স্ট্যাটাস পরিবর্তন করা হয়েছে (বি মার্ক যুক্ত)!', style: TextStyle(color: Colors.red)), backgroundColor: Colors.white),
        );
        return;
      }

      setState(() {
        schedule.isPaymentCleared = true;
        schedule.selectedReaction = '🅿️';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('উদ্যোক্তার পেমেন্ট ক্লিয়ার (P) সফলভাবে সংরক্ষিত হয়েছে!')),
      );
      return;
    }

    // যদি পেমেন্ট ইতিমধ্যে দেওয়া থাকে এবং অন্য রিঅ্যাকশন বা রাইডার দিতে গিয়ে যদি কেউ ওভাররাইড করতে চায়
    if (schedule.isPaymentCleared) {
      setState(() {
        schedule.isTampered = true;
      });
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('রাইডার সিলেক্ট করুন'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: riders.length,
            itemBuilder: (context, index) {
              final rider = riders[index];
              return ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF880E4F)),
                title: Text(rider),
                onTap: () {
                  setState(() {
                    if (!schedule.isPaymentCleared) {
                      schedule.selectedReaction = emoji;
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('শিডিউলটি "$rider"-এর জন্য সংরক্ষণ করা হয়েছে!')),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showMasterRiderFolder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.folder, color: Color(0xFF880E4F)),
            SizedBox(width: 8),
            Text('রাইডার ফোল্ডার'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: riders.length,
            itemBuilder: (context, index) {
              String riderName = riders[index];
              List<ScheduleModel> assignedSchedules = globalSchedules.where((s) => s.selectedReaction.isNotEmpty && s.selectedReaction != '🅿️').toList();
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(riderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('মোট কাজ সম্পন্ন: ${assignedSchedules.length} টি'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _showSpecificRiderDetails(riderName);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বন্ধ করুন'),
          ),
        ],
      ),
    );
  }

  void _showSpecificRiderDetails(String riderName) {
    List<ScheduleModel> riderSchedules = globalSchedules.where((s) => s.selectedReaction.isNotEmpty && s.selectedReaction != '🅿️').toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$riderName-এর শিডিউল তালিকা'),
        content: SizedBox(
          width: double.maxFinite,
          child: riderSchedules.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('এই রাইডারের জন্য কোনো শিডিউল নেই।'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: riderSchedules.length,
                  itemBuilder: (context, idx) {
                    final sch = riderSchedules[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('সিরিয়াল #${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF880E4F))),
                            const SizedBox(height: 4),
                            Text('উদ্যোক্তা: ${sch.entrepreneurName}'),
                            Text('তারিখ: ${sch.deliveryDate}'),
                            Text('সময়: ${sch.deliveryTime}'),
                            Text('রিঅ্যাকশন: ${sch.selectedReaction}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ফিরে যান'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM, yyyy').format(selectedDashboardDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ড্যাশবোর্ড - আমরা অপরাজিতা'),
        backgroundColor: const Color(0xFF880E4F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('মোট শিডিউল:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF880E4F))),
                  Text('${globalSchedules.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF880E4F))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _showMasterRiderFolder,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF880E4F),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'রাইডার ফোল্ডার (সকল রাইডার ও শিডিউল দেখুন)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _pickDashboardDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF880E4F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF880E4F), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF880E4F), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'তারিখ: $formattedDate (পরিবর্তন করুন)',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF880E4F)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEditScheduleScreen(defaultDate: formattedDate)),
                ).then((_) => setState(() {}));
              },
              icon: const Icon(Icons.add),
              label: const Text('শিডিউল দিন', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF880E4F),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
            const SizedBox(height: 15),
            const Text('জমা দেওয়া শিডিউলসমূহ:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A148C))),
            const SizedBox(height: 8),
            Expanded(
              child: globalSchedules.isEmpty
                  ? const Center(child: Text('কোনো শিডিউল জমা দেওয়া হয়নি', style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : ListView.builder(
                      itemCount: globalSchedules.length,
                      itemBuilder: (context, index) {
                        final schedule = globalSchedules[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text('${index + 1}. উদ্যোক্তা: ${schedule.entrepreneurName}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF880E4F))),
                                        if (schedule.isPaymentCleared) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                                            child: const Text('P (পেমেন্ট ক্লিয়ার)', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                        if (schedule.isTampered) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                                            child: const Text('বি (পরিবর্তিত)', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (schedule.isOffer)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                                        child: const Text('অফার শিডিউল', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                                const Divider(height: 16),
                                Text('উদ্যোক্তার ঠিকানা: ${schedule.address}'),
                                InkWell(
                                  onTap: () => _showCallSimulation(context, 'উদ্যোক্তার ফোন', schedule.phone),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      children: [
                                        const Text('উদ্যোক্তার ফোন: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                        Text(schedule.phone, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (schedule.isOffer) ...[
                                  const Text('কাস্টমারগণের তালিকা:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A148C))),
                                  const SizedBox(height: 4),
                                  ...schedule.bulkCustomers.asMap().entries.map((entry) {
                                    int cIdx = entry.key;
                                    CustomerDetailItem cust = entry.value;
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('কাস্টমার #${cIdx + 1}: ${cust.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          InkWell(
                                            onTap: () => _showCallSimulation(context, 'কাস্টমার ফোন', cust.phone),
                                            child: Text('ফোন: ${cust.phone}', style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                                          ),
                                          Text('ঠিকানা: ${cust.address}'),
                                          if (cust.bill.isNotEmpty) Text('বিল: ${cust.bill}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    );
                                  }),
                                ] else ...[
                                  const Text('কাস্টমার তথ্য:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A148C))),
                                  Text('নাম: ${schedule.customerName}'),
                                  InkWell(
                                    onTap: () => _showCallSimulation(context, 'কাস্টমার ফোন', schedule.customerPhone),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(
                                        children: [
                                          const Text('ফোন: '),
                                          Text(schedule.customerPhone, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text('ঠিকানা: ${schedule.customerAddress}'),
                                  Text('বিল + ডেলিভারি চার্জ: ${schedule.bill}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                ],
                                const SizedBox(height: 6),
                                Text('পিকআপ সময়: ${schedule.pickupTime}'),
                                Text('ডেলিভারি সময়: ${schedule.deliveryTime}'),
                                Text('ডেলিভারি তারিখ: ${schedule.deliveryDate}'),
                                Text('নোট: ${schedule.note}', style: const TextStyle(fontStyle: FontStyle.italic)),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: reactions.map((emoji) {
                                      final bool isSelected = schedule.selectedReaction == emoji;
                                      return GestureDetector(
                                        onTap: () => _assignRiderAndReact(schedule, emoji),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.pink.shade100 : Colors.transparent,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isSelected ? const Color(0xFF880E4F) : Colors.transparent,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Text(
                                            emoji,
                                            style: const TextStyle(fontSize: 22),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => AddEditScheduleScreen(scheduleToEdit: schedule, defaultDate: formattedDate)),
                                        ).then((_) => setState(() {}));
                                      },
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddEditScheduleScreen extends StatefulWidget {
  final ScheduleModel? scheduleToEdit;
  final String defaultDate;
  const AddEditScheduleScreen({super.key, this.scheduleToEdit, required this.defaultDate});

  @override
  State<AddEditScheduleScreen> createState() => _AddEditScheduleScreenState();
}

class _AddEditScheduleScreenState extends State<AddEditScheduleScreen> {
  bool isOffer = false;
  
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  
  late TextEditingController custNameController;
  late TextEditingController custPhoneController;
  late TextEditingController custAddressController;
  late TextEditingController billController;
  
  late TextEditingController pickupTimeController;
  late TextEditingController deliveryTimeController;
  late TextEditingController deliveryDateController;
  late TextEditingController noteController;

  List<Map<String, TextEditingController>> bulkControllersList = [];

  @override
  void initState() {
    super.initState();
    final s = widget.scheduleToEdit;
    
    isOffer = s?.isOffer ?? false;
    
    nameController = TextEditingController(text: s?.entrepreneurName ?? '');
    addressController = TextEditingController(text: s?.address ?? '');
    phoneController = TextEditingController(text: s?.phone ?? '');
    
    custNameController = TextEditingController(text: s?.customerName ?? '');
    custPhoneController = TextEditingController(text: s?.customerPhone ?? '');
    custAddressController = TextEditingController(text: s?.customerAddress ?? '');
    billController = TextEditingController(text: s?.bill ?? '');
    
    pickupTimeController = TextEditingController(text: s?.pickupTime ?? '');
    deliveryTimeController = TextEditingController(text: s?.deliveryTime ?? '');
    deliveryDateController = TextEditingController(text: s?.deliveryDate ?? widget.defaultDate);
    noteController = TextEditingController(text: s?.note ?? '');

    if (s != null && s.isOffer && s.bulkCustomers.isNotEmpty) {
      for (var c in s.bulkCustomers) {
        bulkControllersList.add({
          'name': TextEditingController(text: c.name),
          'phone': TextEditingController(text: c.phone),
          'address': TextEditingController(text: c.address),
          'bill': TextEditingController(text: c.bill),
        });
      }
    } else {
      bulkControllersList.add({
        'name': TextEditingController(),
        'phone': TextEditingController(),
        'address': TextEditingController(),
        'bill': TextEditingController(),
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    custNameController.dispose();
    custPhoneController.dispose();
    custAddressController.dispose();
    billController.dispose();
    pickupTimeController.dispose();
    deliveryTimeController.dispose();
    deliveryDateController.dispose();
    noteController.dispose();
    for (var map in bulkControllersList) {
      map['name']?.dispose();
      map['phone']?.dispose();
      map['address']?.dispose();
      map['bill']?.dispose();
    }
    super.dispose();
  }

  void _addBulkCustomer() {
    setState(() {
      bulkControllersList.add({
        'name': TextEditingController(),
        'phone': TextEditingController(),
        'address': TextEditingController(),
        'bill': TextEditingController(),
      });
    });
  }

  void _save() {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('উদ্যোক্তার নাম এবং ফোন নম্বর দিন')),
      );
      return;
    }

    List<CustomerDetailItem> parsedBulk = [];
    if (isOffer) {
      for (var map in bulkControllersList) {
        parsedBulk.add(CustomerDetailItem(
          name: map['name']!.text,
          phone: map['phone']!.text,
          address: map['address']!.text,
          bill: map['bill']!.text,
        ));
      }
    }

    if (widget.scheduleToEdit == null) {
      globalSchedules.add(
        ScheduleModel(
          id: DateTime.now().toString(),
          entrepreneurName: nameController.text,
          address: addressController.text,
          phone: phoneController.text,
          customerName: custNameController.text,
          customerPhone: custPhoneController.text,
          customerAddress: custAddressController.text,
          bill: billController.text,
          pickupTime: pickupTimeController.text,
          deliveryTime: deliveryTimeController.text,
          deliveryDate: deliveryDateController.text,
          note: noteController.text,
          isOffer: isOffer,
          selectedReaction: '',
          isPaymentCleared: false,
          isTampered: false,
          bulkCustomers: isOffer ? parsedBulk : [],
        ),
      );
    } else {
      final s = widget.scheduleToEdit!;
      s.entrepreneurName = nameController.text;
      s.address = addressController.text;
      s.phone = phoneController.text;
      s.customerName = custNameController.text;
      s.customerPhone = custPhoneController.text;
      s.customerAddress = custAddressController.text;
      s.bill = billController.text;
      s.pickupTime = pickupTimeController.text;
      s.deliveryTime = deliveryTimeController.text;
      s.deliveryDate = deliveryDateController.text;
      s.note = noteController.text;
      s.isOffer = isOffer;
      s.bulkCustomers = isOffer ? parsedBulk : [];
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scheduleToEdit != null ? 'শিডিউল এডিট করুন' : 'নতুন শিডিউল তৈরি করুন'),
        backgroundColor: const Color(0xFF880E4F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 5,
              children: [
                const Text('শিডিউলের ধরন:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ChoiceChip(
                  label: const Text('সাধারণ শিডিউল'),
                  selected: !isOffer,
                  onSelected: (val) => setState(() => isOffer = false),
                ),
                ChoiceChip(
                  label: const Text('অফার শিডিউল'),
                  selected: isOffer,
                  onSelected: (val) => setState(() => isOffer = true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('উদ্যোক্তার তথ্য', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF880E4F))),
            const SizedBox(height: 8),
            SafeTextField(controller: nameController, labelText: 'উদ্যোক্তার নাম'),
            const SizedBox(height: 12),
            SafeTextField(controller: addressController, labelText: 'উদ্যোক্তার ঠিকানা', maxLines: 2),
            const SizedBox(height: 12),
            SafeTextField(
              controller: phoneController, 
              labelText: 'উদ্যোক্তার ফোন নম্বর', 
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),
            if (isOffer) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('কাস্টমারগণের তালিকা', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4A148C))),
                  ElevatedButton.icon(
                    onPressed: _addBulkCustomer,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('আরও যোগ করুন'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF880E4F), foregroundColor: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bulkControllersList.length,
                itemBuilder: (context, index) {
                  final map = bulkControllersList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('কাস্টমার সিরিয়াল #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (bulkControllersList.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      map['name']?.dispose();
                                      map['phone']?.dispose();
                                      map['address']?.dispose();
                                      map['bill']?.dispose();
                                      bulkControllersList.removeAt(index);
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SafeTextField(controller: map['name']!, labelText: 'কাস্টমার নাম'),
                          const SizedBox(height: 8),
                          SafeTextField(
                            controller: map['phone']!, 
                            labelText: 'কাস্টমার ফোন নম্বর', 
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                          const SizedBox(height: 8),
                          SafeTextField(controller: map['address']!, labelText: 'কাস্টমার ঠিকানা', maxLines: 2),
                          const SizedBox(height: 8),
                          SafeTextField(controller: map['bill']!, labelText: 'বিল / চার্জ'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ] else ...[
              const Text('কাস্টমার তথ্য', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF880E4F))),
              const SizedBox(height: 8),
              SafeTextField(controller: custNameController, labelText: 'কাস্টমার নাম'),
              const SizedBox(height: 12),
              SafeTextField(
                controller: custPhoneController, 
                labelText: 'কাস্টমার ফোন নম্বর', 
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 12),
              SafeTextField(controller: custAddressController, labelText: 'কাস্টমার ঠিকানা', maxLines: 2),
              const SizedBox(height: 12),
              SafeTextField(controller: billController, labelText: 'বিল + ডেলিভারি চার্জ'),
            ],
            const SizedBox(height: 12),
            SafeTextField(controller: pickupTimeController, labelText: 'পিকআপ সময়'),
            const SizedBox(height: 12),
            SafeTextField(controller: deliveryTimeController, labelText: 'ডেলিভারি সময়'),
            const SizedBox(height: 12),
            SafeTextField(controller: deliveryDateController, labelText: 'ডেলিভারি তারিখ'),
            const SizedBox(height: 12),
            SafeTextField(controller: noteController, labelText: 'নোট'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF880E4F),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('সংরক্ষণ করুন', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
