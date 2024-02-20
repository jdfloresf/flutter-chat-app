import 'dart:io';

import 'package:chat/models/mensajes_response.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/widgets/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin{

  ChatService? chatService;
  SocketService? socketService;
  AuthService? authService;

  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _estaEscribiendo = false;

  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    
    chatService = Provider.of<ChatService>(context, listen: false);
    socketService = Provider.of<SocketService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);

    socketService?.socket.on('mensaje-personal', (data) => _escucharMensaje(data));

    if (chatService?.usuarioPara?.uid != null) {
    _cargarHistorial(chatService!.usuarioPara!.uid);
  }
  }

  void _escucharMensaje(dynamic payload) {
    ChatMessage message = ChatMessage(
      texto: payload['mensaje'], 
      uid: payload['de'], 
      animationController: AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
    ); 

    setState(() { _messages.add(message); });

    message.animationController.forward();
  }



  @override
  Widget build(BuildContext context) {

    final usuarioPara = chatService?.usuarioPara;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[200],
              maxRadius: 14,
              child: Text(usuarioPara!.nombre.substring(0,2), style: const TextStyle(fontSize: 12),),
            ),
            const SizedBox(height: 3),
            Text(usuarioPara.nombre, style: const TextStyle(color: Colors.black87, fontSize: 12), )
          ],
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _messages[i]
              )
            ),

            const Divider(height: 1),

            //TODO: caja de texto
            Container(
              color: Colors.white,
              height: 100,
              child: _inputChat(),
            )

          ],
        ),
      ),
   );
  }

  Widget _inputChat() {

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmit,
                onChanged: (texto) {
                  setState(() {
                    if(texto.trim().isNotEmpty){
                      _estaEscribiendo = true;
                    }else{
                      _estaEscribiendo = false;
                    }
                  });
                },
                decoration: const InputDecoration.collapsed(
                  hintText: 'Enviar mensaje'
                ),
                focusNode: _focusNode,
              )
            ),

            //Boton de enviar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Platform.isIOS
              ? CupertinoButton(
                onPressed: _estaEscribiendo 
                      ? () => _handleSubmit(_textController.text.trim())
                      : null,
                child: const Text('Enviar'), 
              )
              : Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconTheme(
                  data: IconThemeData(color: Colors.blue[400]),
                  child: IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: Icon(Icons.send, color: Colors.blue[400]),
                    onPressed: _estaEscribiendo 
                      ? () => _handleSubmit(_textController.text.trim())
                      : null,
                  ),
                ),
              )
            )
          ],
        ),
      )
    );  
  }

  _handleSubmit(String texto) {
    if(texto.isEmpty) return;

    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = ChatMessage(
      texto: texto, 
      uid: authService!.usuario!.uid,
      animationController: AnimationController(vsync: this, duration: const Duration(milliseconds: 400)),
    );
    _messages.add(newMessage);
    newMessage.animationController.forward();

    setState(() {_estaEscribiendo = false;});

    socketService?.emit('mensaje-personal', {
      'de': authService?.usuario?.uid,
      'para': chatService?.usuarioPara?.uid,
      'mensaje': texto
    });

  }

  void _cargarHistorial(String? usuarioID) async {
    List<Mensaje> chat = await chatService!.getChat(usuarioID!);
    
    final historial = chat.map((msg) => ChatMessage(
      texto: msg.mensaje, 
      uid: msg.de, 
      animationController: AnimationController(vsync: this, duration: const Duration(milliseconds: 0))..forward()
    ));

    setState(() { _messages.addAll(historial); });
  }

  @override
  void dispose() {

    for(ChatMessage message in _messages) {
      message.animationController.dispose();
    }


    socketService?.socket.off('mensaje-personal');

    super.dispose();
  }
}