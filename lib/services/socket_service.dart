import 'package:chat/global/env.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {Online, OffLine, Connecting}

//Refrescara UI o widged o notificar a los clientes
class SocketService with ChangeNotifier {
  
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  void connect() async {

    final token = await AuthService.getToken();

    //Dart client
    _socket = IO.io(Environment.socketUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true,
      'extraHeaders': {
        'x-token': token
      }
    });

    _socket.on('connect', (_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    _socket.on('disconnect', (_){
      _serverStatus = ServerStatus.OffLine;
      notifyListeners();
    });

  }

  void disconnect() {
    _socket.disconnect();
  }
  
}