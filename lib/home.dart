import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'offerte.dart';
import 'utente.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Elenco delle schermate
  final List<Widget> _pages = [
    HomePage(),       // Schermata principale (Home)
    OffertePage(),    // Schermata Offerte
    UserPage(),       // Schermata Utente
  ];

  final List<String> _titles = [
    'Home',
    'Offerte',
    'Profilo Utente',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Aggiorna l'indice selezionato
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        automaticallyImplyLeading: false, // Rimuove il pulsante per tornare indietro
      ),
      body: _pages[_selectedIndex], // Mostra la schermata selezionata
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Offerte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Utente',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped, // Cambia la schermata al tocco
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> piadine = ['Piadina Classica', 'Piadina Vegetariana', 'Piadina al Prosciutto'];
  final List<String> bevande = ['Acqua', 'Coca Cola', 'Birra'];
  final Map<String, int> quantities = {};

  @override
  void initState() {
    super.initState();
    for (var item in piadine) {
      quantities[item] = 0;
    }
    for (var item in bevande) {
      quantities[item] = 0;
    }
  }

  void _incrementQuantity(String item) {
    setState(() {
      quantities[item] = (quantities[item] ?? 0) + 1;
    });
  }

  void _decrementQuantity(String item) {
    setState(() {
      if ((quantities[item] ?? 0) > 0) {
        quantities[item] = (quantities[item] ?? 0) - 1;
      }
    });
  }

  Widget _buildItemRow(String item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(item),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () => _decrementQuantity(item),
            ),
            Text('${quantities[item]}'),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _incrementQuantity(item),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Piadine',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: piadine.length,
              itemBuilder: (context, index) {
                return _buildItemRow(piadine[index]);
              },
            ),
            SizedBox(height: 32),
            Text(
              'Bevande',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: bevande.length,
              itemBuilder: (context, index) {
                return _buildItemRow(bevande[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}