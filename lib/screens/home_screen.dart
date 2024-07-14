import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:odoo_hackathon/screens/auth/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _booksRef =
      FirebaseDatabase.instance.ref().child('items');
  List<Map<String, dynamic>> _books = [];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
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
          'authors': value['authors'] is List
              ? (value['authors'] as List).join(', ')
              : value['authors'] ?? '',
          'publisher': value['publisher'] ?? '',
          'publishedDate': value['publishedDate'] ?? '',
          'description': value['description'] ?? '',
          'pageCount': value['pageCount'] ?? 0,
          'categories': value['categories'] is List
              ? (value['categories'] as List).join(', ')
              : value['categories'] ?? '',
          'thumbnail': value['thumbnail'] ?? '',
          'language': value['language'] ?? '',
          'previewLink': value['previewLink'] ?? '',
          'infoLink': value['infoLink'] ?? '',
          'isIssued': value['isIssued'] ?? false,
        });
      });
      setState(() {
        _books = fetchedBooks;
      });
    });
  }

  Future<Map<String, dynamic>> _fetchBookDetails(String isbn) async {
    final response = await http.get(
        Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['totalItems'] > 0) {
        final book = data['items'][0]['volumeInfo'];
        return {
          'title': book['title'] ?? '',
          'authors': book['authors'] != null ? book['authors'].join(', ') : '',
          'publisher': book['publisher'] ?? '',
          'publishedDate': book['publishedDate'] ?? '',
          'description': book['description'] ?? '',
          'pageCount': book['pageCount'] ?? 0,
          'categories':
              book['categories'] != null ? book['categories'].join(', ') : '',
          'thumbnail':
              book['imageLinks'] != null ? book['imageLinks']['thumbnail'] : '',
          'language': book['language'] ?? '',
          'previewLink': book['previewLink'] ?? '',
          'infoLink': book['infoLink'] ?? '',
        };
      }
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Your Library'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: _books.isEmpty
          ? Center(child: CircularProgressIndicator())
          : BookList(books: _books),
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
        return InkWell(
          onTap: () {
            // Navigate to book details screen or expand details
          },
          child: Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: books[index]['thumbnail'].isNotEmpty
                  ? Image.network(
                      books[index]['thumbnail'],
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : Placeholder(fallbackWidth: 80, fallbackHeight: 120),
              title: Text(books[index]['title']),
              subtitle: Text(books[index]['authors']),
              trailing: books[index]['isIssued']
                  ? Text('Unavailable')
                  : ElevatedButton(
                      onPressed: () {
                        // Implement checkout functionality
                      },
                      child: Text('Checkout'),
                    ),
            ),
          ),
        );
      },
    );
  }
}
