import '/src/authentication/auth.dart';

/**
 * A class which retains the OAuth2 access token and provides a method to generate the HTTP [Authorization] header.
 * The [accessToken] is expected to be base64 encoded.
 */
class OAuth2 implements Auth {
  final String accessToken;
  final String tokenType;

  const OAuth2({
    required this.accessToken,
    this.tokenType = 'Bearer'
  });


  /**
   * Generates and returns the HTTP [Authorization] header based on the OAuth2 access token.
   * https://www.rfc-editor.org/rfc/rfc6750#section-2.1
   */
  @override
  String getAuthorizationHeader() {
    return tokenType + ' ' + accessToken;
  }
}