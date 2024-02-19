import 'package:chat/helpers/mostrar_alerta.dart';
import 'package:chat/pages/boton_azul.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:chat/widgets/custom_input.dart';
import 'package:chat/widgets/labels.dart';
import 'package:chat/widgets/logo.dart';
import 'package:provider/provider.dart';


class RegisterPage extends StatelessWidget {

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
                const Logo(title: 'Registro'),
                _Form(),
                const Labels(ruta: 'login', texto1: '¿Ya tienes cuenta?', texto2: 'Ingresa ahora!'),
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

  final nombreCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl  = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final authService = Provider.of<AuthService>(context);

    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          CustomImput(
            icon: Icons.perm_identity,
            placeHolder: 'Nombre',
            keyboardType: TextInputType.text,
            textController: nombreCtrl,
          ),
          
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
            text: 'Crear cuanta',
            onPressed: () async {
              final registerOk = await authService.register(nombreCtrl.text.trim(), emailCtrl.text.trim(), passCtrl.text.trim());

              if(registerOk == true) {
                // TODO: Conectar al socket server
                Navigator.pushReplacementNamed(context, 'usuarios');
              }else{
                 mostrarAlerta(context, 'Registro incorrecto', registerOk);
              }
            },
          ),
        ],
      ),
    );
  }
}


