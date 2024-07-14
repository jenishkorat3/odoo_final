import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  final bool isAvailable;

  const BookDetailScreen({Key? key, required this.book, required this.isAvailable}) : super(key: key);

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  String? selectedTime;
  List<String> borrowTimes = ['1 Week', '2 Weeks', '1 Month', '2 Months', '3 Months'];

  Future<void> _borrowBook() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String isbnId = widget.book['isbn'];
      DateTime currentDate = DateTime.now();
      DateTime endDate;

      switch (selectedTime) {
        case '1 Week':
          endDate = currentDate.add(Duration(days: 7));
          break;
        case '2 Weeks':
          endDate = currentDate.add(Duration(days: 14));
          break;
        case '1 Month':
          endDate = currentDate.add(Duration(days: 30));
          break;
        case '2 Months':
          endDate = currentDate.add(Duration(days: 60));
          break;
        case '3 Months':
          endDate = currentDate.add(Duration(days: 90));
          break;
        default:
          endDate = currentDate;
          break;
      }

      DatabaseReference _orderRef = FirebaseDatabase.instance.ref().child('orders').push();
      DatabaseReference _itemsRef = FirebaseDatabase.instance.ref().child('items');

      // Create the new order
      await _orderRef.set({
        'userId': userId,
        'isbnId': isbnId,
        'startDate': DateFormat('yyyy-MM-dd').format(currentDate),
        'endDate': DateFormat('yyyy-MM-dd').format(endDate),
        'returnDate': null,
      });

      // Update the totalIssuedQty in the items database
      DataSnapshot snapshot = await _itemsRef.orderByChild('isbn').equalTo(isbnId).once().then((event) => event.snapshot);

      if (snapshot.exists) {
        Map<dynamic, dynamic> items;
        if (snapshot.value is Map) {
          items = snapshot.value as Map<dynamic, dynamic>;
        } else if (snapshot.value is List) {
          items = (snapshot.value as List).asMap();
        } else {
          throw Exception('Unexpected data format: ${snapshot.value}');
        }

        items.forEach((key, value) async {
          int currentTotalIssuedQty = (value['totalIssuedQty'] ?? 0) as int;
          await _itemsRef.child(key.toString()).update({
            'totalIssuedQty': currentTotalIssuedQty + 1,
          });
        });
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book borrowed successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to borrow book: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: widget.book['thumbnail'].isNotEmpty
                    ? Image.network(
                        widget.book['thumbnail'],
                        width: 150,
                        height: 220,
                        fit: BoxFit.cover,
                      )
                    : Placeholder(fallbackWidth: 150, fallbackHeight: 220),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Authors: ${widget.book['authors']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.book['publisher'].isNotEmpty)
                    Text(
                      'Publisher: ${widget.book['publisher']}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  if (widget.book['publishedDate'].isNotEmpty)
                    Text(
                      'Published Date: ${widget.book['publishedDate']}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 10),
                  const Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.book['description'],
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.book['pageCount'] > 0)
                    Text(
                      'Page Count: ${widget.book['pageCount']}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (widget.book['categories'].isNotEmpty)
                    Text(
                      'Categories: ${widget.book['categories']}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    'Language: ${widget.book['language']}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    hint: const Text('Choose time'),
                    value: selectedTime,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTime = newValue;
                      });
                    },
                    items: borrowTimes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  widget.isAvailable
                      ? Container(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _borrowBook();
                            },
                            child: Text('Borrow Now', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'Not Available',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
