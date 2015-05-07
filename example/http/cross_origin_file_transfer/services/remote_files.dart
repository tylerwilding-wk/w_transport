library w_transport.example.http.cross_origin_file_transfer.services.remote_files;

import 'dart:async';
import 'dart:convert';

import 'package:w_transport/w_http_client.dart';

import './proxy.dart';


int _remoteFilePollingInterval = 3; // 3 seconds


class RemoteFiles {

  /// Establish a connection with the remote files server.
  static RemoteFiles connect() {
    return new RemoteFiles._();
  }

  static void deleteAll() {
    new WRequest().delete(getFilesEndpointUrl());
  }

  /// Close the connection with the remote files server.
  void close() {
    _connected = false;
    _endPolling();
  }

  /// Stream that updates with the latest list of remote files.
  Stream<List<RemoteFileDescription>> get stream => _fileStream;

  /// Stream of errors that may occur when trying to communicate with the proxy file server.
  Stream<WHttpException> get errorStream => _errorStream;


  bool _connected;
  StreamController _errorStreamController;
  Stream _errorStream;
  StreamController<List<RemoteFileDescription>> _fileStreamController;
  Stream<List<RemoteFileDescription>> _fileStream;
  Timer _pollingTimer;

  /// Construct a RemoteFiles instance and connect to the proxy server
  /// via HTTP polling.
  RemoteFiles._() {
    _connected = true;
    _errorStreamController = new StreamController();
    _errorStream = _errorStreamController.stream.asBroadcastStream();
    _fileStreamController = new StreamController<List<RemoteFileDescription>>();
    _fileStream = _fileStreamController.stream.asBroadcastStream();
    _startPolling();
  }

  /// Send polling requests 2 seconds apart.
  void _startPolling() {
    if (!_connected) return;
    _poll().then((_) {
      _pollingTimer = new Timer(new Duration(seconds: _remoteFilePollingInterval), _startPolling);
    });
  }

  /// Send the HTTP polling request.
  Future _poll() async {
    if (!_connected) return;
    try {
      WResponse response = await new WRequest().get(getFilesEndpointUrl());

      // Parse the file list from the response
      List results = JSON.decode(response.text)['results'];
      List<RemoteFileDescription> files = results.map((Map file) => new RemoteFileDescription(file['name'], file['size'])).toList();

      // Send the updated file list to listeners
      _fileStreamController.add(files);
    } catch (e, stackTrace) {
      // Send the error to listeners
      _errorStreamController.add(e);
      print(e);
      print(stackTrace);
    }
  }

  /// Cancel polling.
  void _endPolling() {
    if (_pollingTimer != null) {
      _pollingTimer.cancel();
    }
  }

}


class RemoteFileDescription {
  final String name;
  final int size;

  RemoteFileDescription(this.name, this.size);
}