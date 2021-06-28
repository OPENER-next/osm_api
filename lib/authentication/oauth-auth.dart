import 'dart:collection';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'auth.dart';

/**
 * A class which retains OAuth 1.0a credentials and provides a method to generate the HTTP [Authorization] header.
 */
class OAuth implements Auth {
  String consumerKey;

  String consumerSecret;

  String token;

  String tokenSecret;

  OAuth({
    required this.consumerKey,
    required this.consumerSecret,
    required this.token,
    required this.tokenSecret
  });


  /**
   * Percent encoding of a given [String] as described in https://datatracker.ietf.org/doc/html/rfc5849#section-3.6
   */
  String _encode(String value) {
    // according to https://datatracker.ietf.org/doc/html/rfc5849#section-3.6
    value = Uri.encodeQueryComponent(value);
    // the above encoding replaces spaces with + signs
    // the standard however expects %20
    return value.replaceAll('+', '%20');
  }


  /**
   * This method is a rudimentary implementation of https://datatracker.ietf.org/doc/html/rfc5849#section-3.4 and generates the OAuth signature.
   *
   * [method] expects a HTTP method like GET or PUT.
   * [params] expects a [Map] of parameters used in the OAuth Authorization header.
   */
  String _signature(String url, String method, Map<String, String> params) {
    final uri = Uri.parse(url);

    // sort and encode parameters
    // https://datatracker.ietf.org/doc/html/rfc5849#section-3.4.1.3.2
    var normalizedParams = SplayTreeMap<String, String>();
    params.forEach((String k, String v) {
      normalizedParams[_encode(k)] = _encode(v);
    });
    // also include url query parameters
    // https://datatracker.ietf.org/doc/html/rfc5849#section-3.4.1.3
    uri.queryParameters.forEach((String k, String v) {
      normalizedParams[_encode(k)] = _encode(v);
    });
    normalizedParams.remove('realm');

    // concatenate the sortedParams with &
    // https://datatracker.ietf.org/doc/html/rfc5849#section-3.4.1.3.2
    var concatenatedParams = normalizedParams.keys.map((key) {
      return '$key=${normalizedParams[key]}';
    }).join('&');
    concatenatedParams = _encode(concatenatedParams);

    // get and encode base uri
    final baseURI = _encode(uri.origin + uri.path);

    // convert method to upper case and encode method
    // https://datatracker.ietf.org/doc/html/rfc5849#section-3.4.1.1
    method = _encode(method.toUpperCase());

    // construct signature string
    // https://datatracker.ietf.org/doc/html/rfc5849#section-3.4.1.1
    final signatureBaseString = '$method&$baseURI&$concatenatedParams';

    // generate hmac signature from base string
    // https://datatracker.ietf.org/doc/html/rfc5849#section-3.4.2
    final signingKey = _encode(consumerSecret) + '&' + _encode(tokenSecret);
    final hmac = Hmac(sha1, signingKey.codeUnits);
    final bytes = hmac.convert(signatureBaseString.codeUnits).bytes;
    return base64.encode(bytes);
  }


  /**
   * Generates and returns the HTTP [Authorization] header based on the OAuth credentials and parameters.
   *
   * [method] expects a HTTP method like GET or PUT.
   * OAuth 1.0a: https://oauth.net/core/1.0a/
   */
  @override
  String getAuthorizationHeader(String url, String method) {
    var nonce = DateTime.now().millisecondsSinceEpoch.toString();
    var timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    var oauthParams = <String, String>{
      'oauth_consumer_key': consumerKey,
      'oauth_token': token,
      'oauth_signature_method': 'HMAC-SHA1',
      'oauth_timestamp': timestamp,
      'oauth_nonce': nonce,
      'oauth_version': '1.0'
    };

    oauthParams['oauth_signature'] = _encode(_signature(url, method, oauthParams));

    var concatenatedParams = oauthParams.keys.map((key) {
      return '$key="${oauthParams[key]}"';
    }).join(',');

    return 'OAuth ' + concatenatedParams;
  }
}