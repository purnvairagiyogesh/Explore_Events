import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_seat_booking/SummaryPage.dart';
import 'package:flutter/material.dart';

class Bookseats extends StatefulWidget {
  final String eventName;
  final String eventDate;
  final String eventTime;
  final double ticketPrice;

  const Bookseats({
    super.key,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.ticketPrice,
  });

  @override
  State<Bookseats> createState() => _BookseatsState();
}

class _BookseatsState extends State<Bookseats> {
  final Set<String> selectedSeats = {};
  final List<String> rows = ['A', 'B', 'C', 'D'];
  final List<int> cols = [1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Select Seats"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('eventName', isEqualTo: widget.eventName)
            .snapshots(),
        builder: (context, snapshot) {
          List<String> bookedSeats = [];
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              List<dynamic> seats = doc['seats'];
              bookedSeats.addAll(seats.cast<String>());
            }
          }

          return Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("SCREEN / STAGE", style: TextStyle(fontSize: 12, letterSpacing: 3, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rows.length * cols.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    int rowIndex = index ~/ cols.length;
                    int colIndex = index % cols.length;
                    String seatId = "${rows[rowIndex]}${cols[colIndex]}";
                    bool isBooked = bookedSeats.contains(seatId);
                    bool isSelected = selectedSeats.contains(seatId);

                    return GestureDetector(
                      onTap: () {
                        if (!isBooked) {
                          setState(() {
                            if (isSelected) {
                              selectedSeats.remove(seatId);
                            } else {
                              selectedSeats.add(seatId);
                            }
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isBooked
                              ? Colors.grey.shade300
                              : isSelected
                                  ? Colors.blue
                                  : Colors.white,
                          border: Border.all(
                            color: isBooked
                                ? Colors.grey.shade300
                                : isSelected
                                    ? Colors.blue
                                    : Colors.green.shade400,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            seatId,
                            style: TextStyle(
                              color: isSelected ? Colors.white : (isBooked ? Colors.grey : Colors.green.shade700),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem("Available", Colors.green.shade400),
                        _buildLegendItem("Selected", Colors.blue),
                        _buildLegendItem("Booked", Colors.grey.shade300),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: selectedSeats.isEmpty
                          ? null
                          : () {
                              // Filter out any seats that might have been booked by someone else while picking
                              final List<String> finalSelection = selectedSeats.where((s) => !bookedSeats.contains(s)).toList();
                              
                              if (finalSelection.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Selected seats were just booked by someone else!"), backgroundColor: Colors.red),
                                );
                                setState(() {
                                  selectedSeats.clear();
                                });
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SummaryPage(
                                    eventName: widget.eventName,
                                    eventDate: widget.eventDate,
                                    eventTime: widget.eventTime,
                                    ticketPrice: widget.ticketPrice,
                                    selectedSeats: finalSelection,
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
                      child: Text(
                        selectedSeats.isEmpty ? "Select Seats" : "Confirm Booking (${selectedSeats.length})",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
