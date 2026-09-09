import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  String? userEmail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('currentUser_email');
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        centerTitle: true,
      ),
      body: userEmail == null
          ? const Center(child: Text("Please login to see your bookings"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('userEmail', isEqualTo: userEmail)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No bookings found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var booking = snapshot.data!.docs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(booking['eventName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${booking['eventDate']} | Seats: ${booking['seats'].join(', ')}"),
                        trailing: Text("₹${booking['totalAmount']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
