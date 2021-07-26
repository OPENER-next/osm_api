import 'dart:convert';
import '/src/authentication/auth.dart';

/**
 * A class which retains user login credentials and provides a method to generate the HTTP [Authorization] header.
 */
class BasicAuth implements Auth {
  String username;

  String password;

  BasicAuth({
    required this.username,
    required this.password
  });


  /**
   * Generates and returns the HTTP [Authorization] header based on the username and password.
   *
   * Note: The parameters [url] and [method] do not affect this method thus they can be empty strings.
   */
  @override
  String getAuthorizationHeader(String url, String method) {
    return 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  }
}