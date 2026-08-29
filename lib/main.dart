import 'package:flutter/material.dart';

void main() {
  runApp(const AparajitaDeliveryApp());
}

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

// ---------------- LOGIN SCREEN ----------------
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_shipping,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aparajita Delivery',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Phone / Email',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
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

// ---------------- DASHBOARD SCREEN ----------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
    if (picked != null && picked != selectedDate) {
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
        title: const Text('Aparajita Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selector Card
            Card(
              elevation: 3,
              color: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.deepPurple),
                title: const Text(
                  'ডেলিভারি তারিখ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
                trailing: ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('তারিখ পরিবর্তন'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Main Actions Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildDashboardCard(
                    context,
                    title: 'শিডিউল সাবমিট করুন',
                    icon: Icons.assignment_add,
                    color: Colors.deepPurple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$formattedDate তারিখের শিডিউল সাবমিট করা হয়েছে!'),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'রাইডার তালিকা',
                    icon: Icons.two_wheeler,
                    color: Colors.indigo,
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

  Widget _buildDashboardCard(
    BuildContext context, {
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- RIDER LIST SCREEN ----------------
class RiderListScreen extends StatelessWidget {
  const RiderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Rider details data
    final List<Map<String, dynamic>> riders = [
      {'name': 'রিয়া (Riya)', 'schedules': 8, 'status': 'Active'},
      {'name': 'আরিফ (Arif)', 'schedules': 5, 'status': 'Active'},
      {'name': 'সাকিব (Sakib)', 'schedules': 12, 'status': 'Completed'},
      {'name': 'রাহিম (Rahim)', 'schedules': 3, 'status': 'Pending'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('রাইডার ফোল্ডার ও শিডিউল'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: riders.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final rider = riders[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                child: const Icon(Icons.person, color: Colors.indigo),
              ),
              title: Text(
                rider['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('দৈনিক শিডিউল: ${rider['schedules']} টি'),
              trailing: Chip(
                label: Text(
                  rider['status'],
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: rider['status'] == 'Active' || rider['status'] == 'Completed'
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          );
        },
      ),
    );
  }
}
