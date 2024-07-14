import 'package:flutter/material.dart';

class BookDetailScreen extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookDetailScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: book['thumbnail'].isNotEmpty
                    ? Image.network(
                        book['thumbnail'],
                        width: 150,
                        height: 220,
                        fit: BoxFit.cover,
                      )
                    : Placeholder(fallbackWidth: 150, fallbackHeight: 220),
              ),
              SizedBox(height: 20),
              Text(
                book['title'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Authors: ${book['authors']}',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 10),
              if (book['publisher'].isNotEmpty)
                Text(
                  'Publisher: ${book['publisher']}',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              if (book['publishedDate'].isNotEmpty)
                Text(
                  'Published Date: ${book['publishedDate']}',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              SizedBox(height: 10),
              Text(
                'Description:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                book['description'],
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              if (book['pageCount'] > 0)
                Text(
                  'Page Count: ${book['pageCount']}',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              SizedBox(height: 10),
              if (book['categories'].isNotEmpty)
                Text(
                  'Categories: ${book['categories']}',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              SizedBox(height: 10),
              Text(
                'Language: ${book['language']}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
