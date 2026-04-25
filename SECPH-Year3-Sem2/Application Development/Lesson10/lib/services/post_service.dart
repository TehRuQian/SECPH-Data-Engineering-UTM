import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Post>> fetchPosts() async {
    final Uri url = Uri.parse('$baseUrl/posts');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      return jsonList
          .map((item) => Post.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to load posts (status ${response.statusCode})',
      );
    }
  }
}