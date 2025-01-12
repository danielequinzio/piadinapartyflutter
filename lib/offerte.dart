import 'package:flutter/material.dart';

class OffertePage extends StatelessWidget {
  final List<String> offerte = [
    'Piadina classica + coca cola',
    'Piadina al prosciutto + acqua',
    'Piadina vegetariana + birra'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: offerte.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(offerte[index]),
          );
        },
      ),
    );
  }
}