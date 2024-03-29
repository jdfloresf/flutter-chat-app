
import 'package:chat/helpers/mostrar_alerta.dart';
import 'package:chat/pages/boton_azul.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:flutter/material.dart';

import 'package:chat/widgets/custom_input.dart';
import 'package:chat/widgets/labels.dart';
import 'package:chat/widgets/logo.dart';
import 'package:provider/provider.dart';


class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Logo(title: 'Messenger'),
                _Form(),
                const Labels(ruta: 'register', texto1: '¿No tienes cuenta?', texto2: 'Crea una ahora!'),
                const Text('Terminos y Condiciones de uso', style: TextStyle(fontWeight: FontWeight.w200))
              ]
            ),
          ),
        ),
         ),
    );
  }
}

class _Form extends StatefulWidget {

  @override
  State<_Form> createState() => __FormState();
}

class __FormState extends State<_Form> {

  final emailCtrl = TextEditingController();
  final passCtrl  = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);

    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          CustomImput(
            icon: Icons.mail_outline,
            placeHolder: 'Correo',
            keyboardType: TextInputType.emailAddress,
            textController: emailCtrl,
          ),
         
          CustomImput(
            icon: Icons.lock_outline,
            placeHolder: 'Contraseña',
            textController: passCtrl,
            isPassword: true,
          ),
          
          BotonAzul(
            text: 'Ingrese',
            onPressed: () async {
                FocusScope.of(context).unfocus();
                final loginOk = await authService.login(emailCtrl.text.trim(), passCtrl.text.trim());

                if(loginOk) {
                  socketService.connect();
                  Navigator.pushReplacementNamed(context, 'usuarios');
                }else{
                  //mostrar alerta
                  mostrarAlerta(context, 'Login incorrecto', 'Credenciales incorrectas');
                }
              }
          ),
        ],
      ),
    );
  }
}


