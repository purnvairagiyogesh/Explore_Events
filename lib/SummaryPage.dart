import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_seat_booking/AuthPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SummaryPage extends StatelessWidget {
  final String eventName;
  final String eventDate;
  final String eventTime;
  final double ticketPrice;
  final List<String> selectedSeats;

  const SummaryPage({
    super.key,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.ticketPrice,
    required this.selectedSeats,
  });

  @override
  Widget build(BuildContext context) {
    int seatCount = selectedSeats.length;
    double subtotal = seatCount * ticketPrice;
    double gst = subtotal * 0.18;
    double total = subtotal + gst;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Order Summary"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eventName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(eventDate, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(eventTime, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("Booking Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildPriceRow("Seats", selectedSeats.join(", ")),
                  _buildPriceRow("Price per seat", "₹${ticketPrice.toStringAsFixed(2)}"),
                  _buildPriceRow("Quantity", "x $seatCount"),
                  const Divider(height: 30),
                  _buildPriceRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),
                  _buildPriceRow("GST (18%)", "₹${gst.toStringAsFixed(2)}"),
                  const Divider(height: 30),
                  _buildPriceRow("Total Amount", "₹${total.toStringAsFixed(2)}", isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _confirmBooking(context, total),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Confirm & Pay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _confirmBooking(BuildContext context, double totalAmount) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userEmail = prefs.getString('currentUser_email');
    final userName = prefs.getString('currentUser_name');

    if (!isLoggedIn || userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to confirm booking")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
      return;
    }

    try {
      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

      await FirebaseFirestore.instance.collection('bookings').add({
        'userName': userName ?? 'Anonymous',
        'userEmail': userEmail,
        'eventName': eventName,
        'eventDate': eventDate,
        'eventTime': eventTime,
        'seats': selectedSeats,
        'totalAmount': totalAmount,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Booking Confirmed!"),
            content: const Text("Your seats have been successfully booked."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text("Back to Home"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}
