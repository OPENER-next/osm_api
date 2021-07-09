@Skip('This test is not working as an automated test yet and also requires an OAuth setup. Therefore skip it in the Github workflow.')

import 'dart:io';
import 'package:oauth1/oauth1.dart';
import 'package:osmapi/authentication/oauth-auth.dart';
import 'package:osmapi/osm-apis/osm-api.dart';
import 'package:test/test.dart';

void main() async {
  late OSMAPI osmapi;

  setUpAll(() async {
    // define platform (server)
    final platform = Platform(
      'http://127.0.0.1:3000/oauth/request_token',
      'http://127.0.0.1:3000/oauth/authorize',
      'http://127.0.0.1:3000/oauth/access_token',
      SignatureMethods.hmacSha1
    );

    // define client credentials (consumer keys)
    const apiKey = 'BcvrKSbk8Swhtl3PRPly6jzPTIKslAzL5Uyl47Md';
    const apiSecret = 'uBuMxhh3m5pRE6puzWxlh6K0jisnnxSSjYu6JMnK';

    final clientCredentials = ClientCredentials(apiKey, apiSecret);
    // create Authorization object with client credentials and platform definition
    final auth = Authorization(clientCredentials, platform);

    // request temporary credentials (request tokens)
    var res1 = await auth.requestTemporaryCredentials('oob');
    // redirect to authorization page
    print('Open with your browser:${auth.getResourceOwnerAuthorizationURI(res1.credentials.token)}');

    // get verifier (PIN)
    // the test needs to be run in terminal to receive inputs
    stdout.write('PIN: ');
    final verifier = stdin.readLineSync() ?? '';

    // request token credentials (access tokens)
    var res2 = await auth.requestTokenCredentials(res1.credentials, verifier);

    osmapi = OSMAPI(
      baseUrl: 'http://127.0.0.1:3000/api/0.6',
      authentication: OAuth(
        consumerKey: apiKey,
        consumerSecret: apiSecret,
        token: res2.credentials.token,
        tokenSecret: res2.credentials.tokenSecret
      )
    );
  });


  test('make some authenticated requests.', () async {
    print(await osmapi.sendRequest('/user/details.json'));

    print(await osmapi.sendRequest('/way/2.json'));
    // test with url parameter since they need to be taken into account when generating the OAuth signature
    print(await osmapi.sendRequest('/map?bbox=1,1,1.001,1.001'));
  });
}