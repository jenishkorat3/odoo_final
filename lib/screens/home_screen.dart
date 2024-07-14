import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:odoo_hackathon/screens/book_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _booksRef = FirebaseDatabase.instance.ref().child('items');
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _filteredBooks = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _searchController.addListener(_filterBooks);
  }

  void _fetchBooks() {
    _booksRef.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      List<Map<String, dynamic>> fetchedBooks = [];
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        fetchedBooks.add({
          'id': key,
          'isbn': value['isbn'] ?? '',
          'title': value['title'] ?? '',
          'authors': value['authors'] is List ? (value['authors'] as List).join(', ') : value['authors'] ?? '',
          'publisher': value['publisher'] ?? '',
          'publishedDate': value['publishedDate'] ?? '',
          'description': value['description'] ?? '',
          'pageCount': value['pageCount'] ?? 0,
          'categories': value['categories'] is List ? (value['categories'] as List).join(', ') : value['categories'] ?? '',
          'thumbnail': value['thumbnail'] ?? '',
          'language': value['language'] ?? '',
          'previewLink': value['previewLink'] ?? '',
          'infoLink': value['infoLink'] ?? '',
          'isIssued': value['isIssued'] ?? false,
          'qty': value['qty'] ?? 0,
          'totalIssuedQty': value['totalIssuedQty'] ?? 0,
        });
      });
      setState(() {
        _books = fetchedBooks;
        _filteredBooks = fetchedBooks;
      });
    });
  }

  void _filterBooks() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = _books.where((book) {
        return book['title'].toLowerCase().contains(query) || book['authors'].toLowerCase().contains(query) || book['categories'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Your Library'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by title, author, or categories',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: _filteredBooks.isEmpty ? Center(child: CircularProgressIndicator()) : BookList(books: _filteredBooks),
          ),
        ],
      ),
    );
  }
}

class BookList extends StatelessWidget {
  final List<Map<String, dynamic>> books;

  const BookList({Key? key, required this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final isAvailable = book['qty'] - book['totalIssuedQty'] > 0;

        return InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailScreen(book: books[index])));
          },
          child: Card(
            margin: EdgeInsets.all(8.0),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
                leading: book['thumbnail'].isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          book['thumbnail'],
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Placeholder(fallbackWidth: 80, fallbackHeight: 120),
                title: Text(
                  book['title'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(book['authors']),
                trailing: isAvailable
                    ? ElevatedButton(
                        onPressed: () {
                          // Implement checkout functionality
                        },
                        child: Text(
                          'Checkout',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          // Implement checkout functionality
                        },
                        child: Text(
                          'Not Available',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      )),
          ),
        );
      },
    );
  }
}
