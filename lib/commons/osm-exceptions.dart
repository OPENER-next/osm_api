
import 'package:dio/dio.dart';


/**
 * A generic exception for OSM API calls.
 */
abstract class OSMAPIException implements Exception {
  final int errorCode;
  
  final String description;

  final String response;

  OSMAPIException(this.errorCode, this.description, String? response) : this.response = response ?? '';

  @override
  String toString() => '$errorCode - $description | Response: $response';
}


/**
 * 400 - Bad Request
 * 
 * This exception may occur when:
 * - the size of the key or value exceeds 255 characters
 * - there are errors parsing the uploaded XML
 * - the request is malformed (parameters are missing or wrong)
 * - any of the node/way/relation limits are exceeded, in particular if the call would return more than 50'000 nodes
 * - the text field was not present when posting a comment
 * - a node is outside the world
 * - there are too many nodes for a way
 * - you are accessing the cgimap version of the API and OAuth fails with a "Bad OAuth request."
 */
class OSMBadRequestException extends OSMAPIException {
  OSMBadRequestException(String? response) :
  super(400, 'Bad Request: Visit the documentation for potential error causes.', response);
}


/**
 * 401 - Unauthorized
 * 
 * This exception occurs when the user login failed or authentication is required.
 */
class OSMUnauthorizedException extends OSMAPIException {
  OSMUnauthorizedException(String? response) :
  super(401, 'Unauthorized: The user login failed or authentication is required.', response);
}


/**
 * 403 - Forbidden
 * 
 * This exception may occur when:
 * - login was successfull but the user is blocked
 * - the version of the element is not available (due to redaction)
 */
class OSMForbiddenException extends OSMAPIException {
  OSMForbiddenException(String? response) :
  super(403, 'Forbidden: User may be blocked. Visit the documentation for other potential error causes.', response);
}


/**
 * 404 - Not Found
 * 
 * This exception may occur when:
 * - no changeset, or element with the given id could be found
 * - no user with the given uid or display_name could be found
 */
class OSMNotFoundException extends OSMAPIException {
  OSMNotFoundException(String? response) :
  super(404, 'Not Found: The requested element, changeset or user could not be found.', response);
}


/**
 * 405 - Method Not Allowed
 * 
 * This exception occurs when the client is using the wrong request method.
 */
class OSMMethodNotAllowedException extends OSMAPIException {
  OSMMethodNotAllowedException(String? response) :
  super(405, 'Method Not Allowed: The client is using the wrong request method.', response);
}


/**
 * 406 - Not Acceptable
 * 
 * This exception occurs when the same key occurs more than once in a set of preferences.
 */
class OSMNotAcceptableException extends OSMAPIException {
  OSMNotAcceptableException(String? response) :
  super(406, 'Not Acceptable: The same key occurs more than once in a set of preferences.', response);
}


/**
 * 409 - Conflict
 * 
 * This exception may occur when:
 * - the user tries to update a changeset that has already been closed
 * - the user trying to update the changeset is not the same as the one that created it
 * - the user tries to comment on a changeset which is not closed
 * - the version of the provided element does not match the current database version of the element
 */
class OSMConflictException extends OSMAPIException {
  OSMConflictException(String? response) :
  super(409, 'Conflict: Visit the documentation for potential error causes.', response);
}


/**
 * 410 - Gone
 * 
 * This exception occurs when the element in question has been deleted.
 */
class OSMGoneException extends OSMAPIException {
  OSMGoneException(String? response) :
  super(410, 'Gone: The element in question has been deleted.', response);
}


/**
 * 412 - Precondition Failed
 * 
 * This exception occurs when
 * - the user tries to upload a way or relation which has elements that do not exist or are deleted
 * - the user tries to delete an element that is still used by another element
 */
class OSMPreconditionFailedException extends OSMAPIException {
  OSMPreconditionFailedException(String? response) :
  super(412, 'Precondition Failed: Visit the documentation for potential error causes.', response);
}


/**
 * 413 - Payload Too Large
 * 
 * This exception occurs when the user tries to upload more than 150 preferences at once.
 */
class OSMPayloadTooLargeException extends OSMAPIException {
  OSMPayloadTooLargeException(String? response) :
  super(413, 'Payload Too Large: The user tried to upload more than 150 preferences at once.', response);
}


/**
 * 414 - Request-URI Too Large
 * 
 * This exception occurs when fetching multiple elements and the URI was too long (tested to be > 8213 characters in the URI, or > 725 elements for 10 digit IDs when not specifying versions).
 */
class OSMRequestURITooLargeException extends OSMAPIException {
  OSMRequestURITooLargeException(String? response) :
  super(414, 'Request-URI Too Large: The URI was too long when fetching multiple elements.', response);
}


/**
 * 509 - Bandwidth Limit Exceeded
 * 
 * This exception occurs when the user downloaded too much data in a short period of time.
 */
class OSMBandwidthLimitExceededException extends OSMAPIException {
  OSMBandwidthLimitExceededException(String? response) :
  super(509, 'Bandwidth Limit Exceeded: Too much data downloaded in a short period of time.', response);
}


/**
 * Unknown Exception
 * An unknown http response eception.
 */
class OSMUnknownException extends OSMAPIException {
  OSMUnknownException(int errorCode, String? response) :
  super(errorCode, 'Unkown OSM API Exception', response);
}


/**
 * Map dio response errors to cutsom OSM API exceptions
 */
void handleDioErrors(DioError error) {
  if (error.type == DioErrorType.response && error.response?.statusCode != null) {
    var response = error.response;
    var message = response?.data ?? response?.statusMessage;

    switch (response!.statusCode) {
			case 400: throw OSMBadRequestException(message);
      case 401: throw OSMUnauthorizedException(message);
      case 403: throw OSMForbiddenException(message);
      case 404: throw OSMNotFoundException(message);
      case 405: throw OSMMethodNotAllowedException(message);
      case 406: throw OSMNotAcceptableException(message);
      case 409: throw OSMConflictException(message);
      case 410: throw OSMGoneException(message);
      case 412: throw OSMPreconditionFailedException(message);
      case 413: throw OSMPayloadTooLargeException(message);
      case 414: throw OSMRequestURITooLargeException(message);
      case 509: throw OSMBandwidthLimitExceededException(message);

			default: OSMUnknownException(response.statusCode!, message);
		}
  }
}