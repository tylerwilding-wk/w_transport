# Changelog

## 2.0.0

> The 2.0.0 release is a major breaking release. While many of the patterns from
> 1.0.x were maintained, the HTTP API was broken up into several request classes
> and two response classes for a much more robust and useful API. As such, there
> is no backwards compatibility, but a migration guide is included below.

### Features

- **WebSockets**
  - Single API for the browser and the Dart VM.
  - Option to use SockJS library in place of native WebSockets for the ability
    to fall back to XHR streaming (configuration only, no API usage difference).

- **HTTP**
  - Support for most commonly used request types:
    - `Request` (content-type: text/plain)
    - `JsonRequest` (content-type: application/json)
    - `FormRequest` (content-type: application/x-www-form-urlencoded)
    - `MultipartRequest` (content-type: multipart/form-data)
  - Synchronous access to response bodies as bytes, text, and JSON.
  - Asynchronous request bodies (`StreamedRequest`).
  - Asynchronous response bodies via `streamGet()`, `streamPost()`, etc. on any
    of the above request classes.
  - Automatic request encoding and response decoding.

- **Mocks**
  - Because this library is designed to be platform-agnostic, it's easy to
    introduce mocks simply by treating tests as another platform, just like the
    browser or the Dart VM.
  - Import `package:w_transport/w_transport_mock.dart` and call
    `configureWTransportForTest()` to configure w_transport to use mock
    implementations for every class.
  - No changes necessary to your source code!
  - Utilize the `MockTransports` class to control WebSocket connections and HTTP
    requests.

- **Testing**
  - A big initiative in this 2.0.0 release was to increase our test coverage -
    which we've done. **With almost 1000 statements, `w_transport` has 99.7%
    coverage!**
  - Since this library is concerned with transport protocols, it is imperative
    that our testing included rigorous integration tests. **We have over 1000
    integration tests that run in the browser and on the Dart VM against real
    servers.**
  - Our test suites run against our mock implementations as well to ensure they
    are in parity with the real implementations.

### Migration Guide

#### `WRequest`

The `WRequest` class attempted to cover all HTTP request use cases. Its closest
analog now is `Request` - the class for sending plain-text requests. All other
request classes share a similar base API with additional support for a specific
type of request data (JSON, form, multipart, or streamed).

#### `WResponse`

The `WResponse` class made request meta data (status, headers) available as soon
as the request had finished; however, in an attempt to unify the API between the
`dart:io` HTTP requests and `dart:html` XHR requests, the response body was only
available asynchronously (as a stream, an untyped future, or decoded to text).
This meant two asynchronous steps were required for every request - one to get
the response, and one to get the response body.

This has been greatly improved by switching to two different response classes:

- `Response` - response meta data and body available synchronously
- `StreamedResponse` - response meta data available synchronously, body
  available as a stream of bytes

## 1.0.1
**Bug Fixes:**

- Allow request data to be set to `null`.
- Canceling an in-flight request now properly results in the returned Future
  completing with an error.
- Request data type validation now happens when sending the request instead of
  upon assignment, allowing intermediate data assignments.
- Verify w_transport configuration has been set before constructing a `WHttp`
  instance.

## 1.0.0
- Initial version of w_transport: a fluent-style, platform-agnostic library with
  ready to use transport classes for sending and receiving data over HTTP.