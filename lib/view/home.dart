import 'package:flutter/material.dart';
import '../view/utente.dart';
import '../controller/ordine_controller.dart';
import '../model/ordine_model.dart';
import '../view/inserimento_dati.dart';
import 'offerte.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; //variabile che tiene traccia dell'indice della pagina attualmente selezionata

  final List<Map<String, dynamic>> _pages = [ //pages è una lista di mappe che definisce le pagine disponibili
    {
      'title': 'Home', //Il titolo da visualizzare nella barra superiore.
      'widget': HomePage(), //Il widget che rappresenta il contenuto della pagina.
    },
    {
      'title': 'Offerte',
      'widget': OffertePage(),
    },
    {
      'title': 'Profilo Utente',
      'widget': UserPage(),
    },
  ];

  void _onItemTapped(int index) { //funzione che aggiorna lo stato quando un elemento della barra di navigazione viene cliccato
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Piadina Party',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container( //si utilizza il Container per il titolo della pagina selezionata
            color: Colors.orange,
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                _pages[_selectedIndex]['title'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded( //si utilizza Expanded per il contenuto della pagina selezionata
            child: Container(
              color: Colors.orange,
              child: _pages[_selectedIndex]['widget'], //si utilizza il widget corrispondente alla pagina selezionata
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[ //items è una lista che rappresenta le opzioni disponibili (Home, Offerte, Profilo)
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
        currentIndex: _selectedIndex, //tiene traccia dell'indice della pagina attualmente selezionato
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped, //onTap chiama _onItemTapped quando un elemento viene cliccato
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
  late OrdineController ordineController;

  @override //inizializzi la variabile ordineController passandogli l'oggetto creato ordine per un utilizzo futuro del controller
  void initState() {
    super.initState();
    final ordine = Ordine(
      idOrdine: '12345',
      idUtente: 'utente1',
      piadine: {for (var item in piadine) item: 0},
      bevande: {for (var item in bevande) item: 0},
    );
    ordineController = OrdineController(ordine);
  }

  //settaggio info relative ai tasti + e -
  Widget _buildItemRow(String item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(item),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  ordineController.decrementQuantity(item);
                });
              },
            ),
            Text('${ordineController.ordine.piadine[item] ?? ordineController.ordine.bevande[item]}'),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  ordineController.incrementQuantity(item);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  //funzione se si clicca il pulsante confermaOrdine
  void _confermaOrdine() {
    final piadineSelezionate = ordineController.ordine.piadine.values.any((qty) => qty > 0); //Map di piadine con quantità > 0
    final bevandeSelezionate = ordineController.ordine.bevande.values.any((qty) => qty > 0);

    if (piadineSelezionate || bevandeSelezionate) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InserimentoDatiScreen(ordine: ordineController.ordine)),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Avviso'),
            content: Text('Selezionare almeno una piadina e/o una bevanda'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
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
            SizedBox(height: 32),
            Text(
              'Prezzo Totale: €${ordineController.getPrezzoTotale().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _confermaOrdine,
              child: Text('Conferma Ordine'),
            ),
          ],
        ),
      ),
    );
  }
}