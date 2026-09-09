import 'package:event_seat_booking/AuthPage.dart';
import 'package:event_seat_booking/BookSeats.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Eventpage extends StatelessWidget {
  final String EventName;
  final String EventDate;
  final String EventTime;
  final String TicketPrice;
  final String EventVenue;
  final String longDis;
  final String image;

  const Eventpage({
    super.key,
    required this.EventName,
    required this.EventDate,
    required this.EventTime,
    required this.TicketPrice,
    required this.EventVenue,
    required this.longDis,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(image, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(EventName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text("₹$TicketPrice", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(EventDate, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("About Event", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(longDis, style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5)),
                  const SizedBox(height: 24),
                  const Text("Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(EventVenue, style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Bookseats(
                  eventName: EventName,
                  eventDate: EventDate,
                  eventTime: EventTime,
                  ticketPrice: double.parse(TicketPrice.replaceAll('₹', '')),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Book Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
