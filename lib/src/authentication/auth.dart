/**
 * An interface to get the authorization header from different authentication methods.
 */
abstract class Auth {
  String getAuthorizationHeader();
}