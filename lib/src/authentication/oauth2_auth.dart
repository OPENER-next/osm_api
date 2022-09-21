import '/src/authentication/auth.dart';

/**
 * A class which retains the OAuth2 access token and provides a method to generate the HTTP [Authorization] header.
 * The [accessToken] is expected to be base64 encoded.
 */
class OAuth2 implements Auth {
  String accessToken;
  String tokenType;

  OAuth2({
    required this.accessToken,
    this.tokenType = 'Bearer'
  });


  /**
   * Generates and returns the HTTP [Authorization] header based on the OAuth2 access token.
   * https://www.rfc-editor.org/rfc/rfc6750#section-2.1
   *
   * Note: The parameters [url] and [method] do not affect this method thus they can be empty strings.
   */
  @override
  String getAuthorizationHeader([ String? url, String? method ]) {
    return tokenType + ' ' + accessToken;
  }
}