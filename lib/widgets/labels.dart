import 'package:flutter/material.dart';

class Labels extends StatelessWidget {

  final String ruta;
  final String texto1;
  final String texto2;

  const Labels({
    super.key, 
    required this.ruta,
    required this.texto1,
    required this.texto2
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(texto1, style: const TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w300)),
          const SizedBox(height: 10),
          GestureDetector(
            child: Text(texto2, style: TextStyle(color: Colors.blue[600], fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pushReplacementNamed(context, ruta);
            },
          ),
        ],
      ),
    );
  }
}
