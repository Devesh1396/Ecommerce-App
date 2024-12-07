import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_exceptions.dart';

class ApiService {

  Future<dynamic> getAPI({
    required String url,
    String? token, // Optional for authenticated requests
  }) async {
    var uri = Uri.parse(url);

    try {
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );
      return _returnResponse(response);
    } on SocketException {
      throw FetchDataExceptions(errorMsg: "No Internet Connection!");
    }
  }

  Future<dynamic> postAPI({
    required String url,
    Map<String, dynamic>? body, // Make body optional
    String? token, // Optional for authenticated requests
  }) async {
    var uri = Uri.parse(url);

    try {
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: body != null ? json.encode(body) : null, // Include body only if it's provided
      );

      return _returnResponse(response);
    } on SocketException {
      throw FetchDataExceptions(errorMsg: "No Internet Connection!");
    }
  }

  Future<Map<String, dynamic>?> fetchUserDetails({
    required String url, // Accept URL as a parameter
    required String token, // Token for authentication
    String? email, // Email to identify the user
  }) async {
    var uri = Uri.parse(url); // Parse the URL
    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token", // Pass the token for authentication
          "Content-Type": "application/json",
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == true && responseData['data'] != null) {
          final List<dynamic> users = responseData['data'];

          // Find the user matching the provided email
          final user = users.firstWhere(
                (u) => u['email'] == email, // Match by email
            orElse: () => null,
          );

          return user; // Return the matched user as a map
        } else {
          throw BadRequestExceptions(
              errorMsg: "Invalid response: ${responseData['message'] ?? 'No data available.'}");
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedExceptions(errorMsg: "Unauthorized access.");
      } else if (response.statusCode == 400) {
        throw BadRequestExceptions(errorMsg: "Bad request.");
      } else {
        throw FetchDataExceptions(
            errorMsg: "Error occurred with status code: ${response.statusCode}");
      }
    } on SocketException {
      throw FetchDataExceptions(errorMsg: "No Internet Connection!");
    } catch (e) {
      throw FetchDataExceptions(errorMsg: "Failed to fetch user details: $e");
    }
  }


  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return json.decode(response.body);
      case 400:
        throw BadRequestExceptions(errorMsg: "Bad Request");
      case 401:
      case 403:
        throw UnauthorizedExceptions(errorMsg: "Unauthorized Request");
      case 500:
        throw FetchDataExceptions(errorMsg: "Internal Server Error");
      default:
        throw FetchDataExceptions(errorMsg: "Unknown Error: ${response.statusCode}");
    }
  }
}
