import 'package:socket_io_client/socket_io_client.dart' as IO;
import './api_service.dart';

class SocketService {
  static IO.Socket? _socket;

  static IO.Socket get socket {
    if (_socket == null) {
      _init();
    }
    return _socket!;
  }

  static final Set<String> _rooms = {};

  static void _init() {
    final String socketUrl = ApiService.baseUrl.replaceAll('/api', '');
    _socket = IO.io(socketUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());
    
    _socket!.onConnect((_) {
      print('Connected to Socket.io Server');
      // Re-join all rooms on reconnect
      for (var room in _rooms) {
        _socket!.emit('join_room', room);
      }
    });

    _socket!.onDisconnect((_) => print('Disconnected from Socket.io Server'));
    _socket!.onConnectError((err) => print('Socket Connect Error: $err'));
    
    _socket!.connect();
  }

  static void joinRoom(String room) {
    if (room.isEmpty) return;
    _rooms.add(room);
    if (socket.connected) {
      socket.emit('join_room', room);
    }
  }

  static void leaveRoom(String room) {
    _rooms.remove(room);
    socket.emit('leave_room', room);
  }

  static void onMessage(Function(dynamic) callback) {
    socket.on('receive_message', callback);
  }

  static void offMessage() {
    socket.off('receive_message');
  }

  static void sendNotification(Map<String, dynamic> data) {
    socket.emit('send_notification', data);
  }

  static void onNotification(Function(dynamic) callback) {
    socket.on('receive_notification', callback);
  }
}
