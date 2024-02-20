import 'package:chat/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:chat/services/auth_service.dart';
import 'package:chat/services/usuarios_service.dart';
import 'package:chat/services/socket_service.dart';

import 'package:chat/models/usuarios.dart';


class UsuarioPage extends StatefulWidget {

  @override
  _UsuarioPageState createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {

  final usuariosService = UsuariosService();
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  List<Usuario> usuarios = [];
  @override
  void initState() {
    _cargarUsuarios();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);
    
    final usuario = authService.usuario;

    return Scaffold(
      appBar: AppBar(
        title: Text(usuario!.nombre, style: const TextStyle(color: Colors.black54)),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: (){
            socketService.disconnect();
            Navigator.pushReplacementNamed(context, 'login');
            AuthService.deleteToken();
          },
        ),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
            ? Icon(Icons.check_circle, color: Colors.blue[400],)
            : const Icon(Icons.offline_bolt, color: Colors.red,),
          )
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: _cargarUsuarios,
        header: WaterDropHeader(
          complete: Icon(Icons.check, color: Colors.blue[400],),
          waterDropColor: Colors.blue,
        ),
        child: _listViewUsuarios(),
      )
   );
  }

  ListView _listViewUsuarios() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (_, i) => _usuarioListTile(usuarios[i]), 
      separatorBuilder: (_, i) => Divider(), 
      itemCount: usuarios.length
    );
  }

  ListTile _usuarioListTile(Usuario usuario) {
    return ListTile(
        title: Text(usuario.nombre),
        subtitle: Text(usuario.email),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(usuario.nombre.substring(0,2)),
        ),
        trailing: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: usuario.online ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(100)
          ),
        ),
        onTap: () {
          final chatService = Provider.of<ChatService>(context, listen: false);
          chatService.usuarioPara = usuario;
          Navigator.pushNamed(context, 'chat');
        },
      );
  }

  void _cargarUsuarios() async {
    usuarios = await usuariosService.getUsuarios();
    setState(() {});
    _refreshController.refreshCompleted();
  }
}