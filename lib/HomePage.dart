import 'package:event_seat_booking/AuthPage.dart';
import 'package:event_seat_booking/EventPage.dart';
import 'package:event_seat_booking/MyBookingsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }
  // ... events list remains the same ...
  final List<Map<String, dynamic>> events = [
    {
      "name": "Neon Nights Music Festival",
      "date": "20 Sept 2026",
      "time": "7:00 PM",
      "price": "799",
      "venue": "Pramukh Swami Auditorium, Rajkot",
      "image": "https://pixmob.com/assets/images/projects/electric-run-dubai-2016/electrin-run---dubai-concert.webp",
      "description": "Get ready for an unforgettable musical experience at Neon Nights Music Festival. Enjoy live performances, energetic beats, spectacular lighting, and an incredible atmosphere."
    },
    {
      "name": "Laugh Riot Comedy Night",
      "date": "27 Sept 2026",
      "time": "6:30 PM",
      "price": "499",
      "venue": "Hemu Gadhavi Auditorium, Rajkot",
      "image": "https://s3.eu-west-2.amazonaws.com/data.list.co.uk/ck_files/images/data-feed/e2786d4e-f888-11ed-96d8-c637bbd43f0a-LST757001-600x600.jpg",
      "description": "Take a break from your daily routine and spend an evening laughing out loud at Laugh Riot. Featuring talented stand-up comedians performing their best routines."
    },
    {
      "name": "Gujarat Cultural Carnival",
      "date": "04 Oct 2026",
      "time": "5:00 PM",
      "price": "199",
      "venue": "Savani Hall, Rajkot",
      "image": "https://www.wanderlustmagazine.com/wp-content/uploads/2023/11/gujarat-top-image-scaled.jpg",
      "description": "Experience the rich traditions and colorful heritage of Gujarat at the Gujarat Cultural Carnival. Enjoy traditional folk dances and live music."
    },
    {
      "name": "The Magic of Live Orchestra",
      "date": "11 Oct 2026",
      "time": "7:30 PM",
      "price": "999",
      "venue": "Shri Atal Bihari Vajpayee Auditorium, Rajkot",
      "image": "https://www.gdynia.pl/dla-mediow/module/Files/controller/Default/action/previewFile/hash/5e4618959c07ace99dd5442cd7330a6d",
      "description": "Let the power of live music take you on an unforgettable journey. A talented orchestra will perform a collection of cinematic themes."
    },
    {
      "name": "TechNext 2026",
      "date": "18 Oct 2026",
      "time": "10:00 AM",
      "price": "499",
      "venue": "Arvindbhai Maniar Hall, Rajkot",
      "image": "https://ts-production.imgix.net/images/mobile-cover-uploaded/6e58338e-15dc-42df-94d2-977068130436.jpg?auto=compress%2Cformat&h=450&w=800",
      "description": "Discover the latest technology, innovative ideas, and exciting digital experiences. TechNext 2026 brings together technology enthusiasts."
    },
    {
      "name": "Midnight Beats DJ Night",
      "date": "04 Nov 2026",
      "time": "8:00 PM",
      "price": "999",
      "venue": "Phoenix Resort, Rajkot",
      "image": "https://files.value-press.com/czMjYXJ0aWNsZSM0NDU3MCMyMDM0MTEjNDQ1NzBfbUNWYUlIcExZay5qcGc.jpg",
      "description": "Dance the night away with energetic DJ performances, beats, and spectacular lights at Midnight Beats DJ Night."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Discover Events", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookingsPage())),
          ),
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                await prefs.remove('currentUser_email');
                await prefs.remove('currentUser_name');
                setState(() {
                  isLoggedIn = false;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthPage()));
                _checkLoginStatus();
              },
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Eventpage(
                    EventName: event['name'],
                    EventDate: event['date'],
                    EventTime: event['time'],
                    TicketPrice: event['price'],
                    EventVenue: event['venue'],
                    longDis: event['description'],
                    image: event['image'],
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      event['image'],
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                event['name'],
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "₹${event['price']}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(event['date'], style: const TextStyle(color: Colors.grey)),
                            const SizedBox(width: 16),
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(child: Text(event['venue'], style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
