import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/ordine_model.dart';
import '../view/riepilogo_ordine.dart';

//è un widget che può modificare il suo stato e rappresenta la schermata per inserire dati di un ordine
class InserimentoDatiScreen extends StatefulWidget {
  final Ordine ordine;
  final String? indirizzo;
  final String? orario;
  final String? metodoPagamento;

  //parametri passati tramite costruttore
  InserimentoDatiScreen({
    required this.ordine,
    this.indirizzo,
    this.orario,
    this.metodoPagamento,
  });


  //creazione dello stato della schermata
  @override
  _InserimentoDatiScreenState createState() => _InserimentoDatiScreenState();
}

class _InserimentoDatiScreenState extends State<InserimentoDatiScreen> {
  final _formKey = GlobalKey<FormState>();  //serve a validare il form presente nella schermata
  late String _indirizzo;  //dati inseriti dall'utente
  late String _orario;
  late String _metodoPagamento;
  String _numeroCarta = '';
  String _scadenzaCarta = '';
  String _cvvCarta = '';
  final TextEditingController _orarioController = TextEditingController(); //controller che gestisce l'input per l'orario.

  //metodo che inizializza le variabili
  @override
  void initState() {
    super.initState();
    _indirizzo = widget.indirizzo ?? '';
    _orario = widget.orario ?? '';
    _metodoPagamento = widget.metodoPagamento ?? 'Contanti';
    _orarioController.text = _orario;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay now = TimeOfDay.now();

    //con showTimePicker si ha apertura del time picker con orario impostato a quello corrente
    final TimeOfDay? picked = await showTimePicker(  //picked è la variabile che fa riferimento all'orario selezionato dall'utente
      context: context,
      initialTime: now,
    );

    //se l'utente ha selezionato orario
    if (picked != null) {
      final DateTime nowDateTime = DateTime.now();
      final DateTime pickedDateTime = DateTime(   //orario convertito in oggetto di tipo DateTime
        nowDateTime.year,
        nowDateTime.month,
        nowDateTime.day,
        picked.hour,
        picked.minute,
      );

      final DateTime earliestAllowedTime = nowDateTime.add(Duration(minutes: 30));  //vincolo dei 30 minuti
      final DateTime latestAllowedTime = DateTime(  //vincolo dell'ultimo orario disponibile per la consegna (max alle 23)
        nowDateTime.year,
        nowDateTime.month,
        nowDateTime.day,
        23,
        0,
      );

      //controlli sull'orario scelto dall'utente
      if (pickedDateTime.isBefore(earliestAllowedTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('L\'orario di consegna deve essere almeno 30 minuti dopo l\'orario corrente.')),
        );
      } else if (pickedDateTime.isAfter(latestAllowedTime) || pickedDateTime.hour < 19) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('L\'orario di consegna deve essere tra le 7 PM e le 11 PM.')),
        );
      } else {
        setState(() {
          //aggiornamento delle variabili orario e orarioController con l'orario selezionato
          _orario = picked.format(context);
          _orarioController.text = _orario;
        });
      }
    }
  }

  //funzione per selezionare data di scadenza della carta di credito
  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime now = DateTime.now(); //istanza che tiene conto di ora e data corrente
    final DateTime? picked = await showDatePicker( //picked è la data di scadenza selezionata dall'utente
      context: context,
      initialDate: DateTime(now.year, now.month), //data iniziale mostrata nel picker è impostata all'inizio del mese corrente
      firstDate: DateTime(now.year), //la data minima selezionabile è l'inizio dell'anno corrente
      lastDate: DateTime(now.year + 10), //l'ultima data selezionabile settata tra 10 anni
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            primaryColor: Colors.blue,
            colorScheme: ColorScheme.light(primary: Colors.blue),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    //controlli sulla data selezionata
    if (picked != null) {
      setState(() {
        _scadenzaCarta = '${picked.month.toString().padLeft(2, '0')}/${picked.year.toString().substring(2)}';  //scadenza carta formattata: MM/YY
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( //Scaffold restituisce la struttura base della schermata e contiene appBar, body
      appBar: AppBar( //definizione struttura appBar
        title: Text('Inserimento Dati'),
        automaticallyImplyLeading: false,
      ),
      body: Container( //definizione struttura body come Cointainer
        color: Colors.orange,
        width: double.infinity, //dimensioni per riempire tutta la schermata
        height: double.infinity, //dimensioni per riempire tutta la schermata
        padding: const EdgeInsets.all(16.0), //Margini interni di 16 pixel
        child: Form(
          key: _formKey, //Gestisce la validazione del form
          child: SingleChildScrollView(   //inserimento dello scroll per scorrere pagina
            child: Column( //Contiene i campi di input con allineamento orizzontale a sinistra
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(  //campi di testo dell'indirizzo
                  initialValue: _indirizzo,
                  decoration: InputDecoration(labelText: 'Indirizzo di Consegna'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {  //controllo se il campo è vuoto
                      return 'Inserisci un indirizzo';
                    }
                    return null;
                  },
                  onSaved: (value) {   //aggiornamento della variabile indirizzp dopo aver salvato il form
                    _indirizzo = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Orario di Consegna',
                    suffixIcon: IconButton( //aggiunta dell'iconButton relativo all'orologio
                      icon: Icon(Icons.access_time),
                      onPressed: () => _selectTime(context),
                    ),
                  ),
                  readOnly: true,   //campo come non modificabile direttamente dall'utente (solo tramite il pulsante dell'orologio)
                  controller: _orarioController, //_orarioController per controllare e aggiornare il valore visualizzato nel campo
                  validator: (value) {  //controllo che il campo non sia vuoto
                    if (value == null || value.isEmpty) {
                      return 'Inserisci un orario';
                    }

                    final DateTime now = DateTime.now();
                    final parts = value.split(' ');  //divide la stringa value che contiene l'orario selezionato
                    final timeParts = parts[0].split(':');  //estrae i valori delle ore e dei minuti come stringhe separate e splittate da :
                    int hour = int.parse(timeParts[0]);  //conversione in int della stringa relativa alle ore
                    final int minute = int.parse(timeParts[1]); //conversione in int della stringa relativa ai minuti

                    //controllo per convertire dal formato PM e AM in 24 ore
                    if (parts[1] == 'PM' && hour != 12) {
                      hour += 12;
                    }
                    //per settare la mezzanotte in 00:00
                    else if (parts[1] == 'AM' && hour == 12) {
                      hour = 0;
                    }

                    final DateTime selectedTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      hour,
                      minute,
                    );

                    if (selectedTime.isBefore(now.add(Duration(minutes: 30)))) {   //controllo che l'orario selezionato non sia prima di 30 minuti dall'orario attuale
                      return 'L\'orario di consegna deve essere almeno 30 minuti dopo l\'orario corrente.';
                    }

                    if (selectedTime.hour < 19 || selectedTime.hour >= 23) { //controllo orario selezionato compreso tra le 19 e le 23
                      return 'L\'orario di consegna deve essere tra le 7 PM e le 11 PM.';
                    }

                    return null;
                  },
                ),

                //menu a discesa per selezionare il metodo di pagamento tra "Contanti" e "Carta di Credito".
                DropdownButtonFormField<String>(
                  value: _metodoPagamento,   //valore iniziale visualizzato sul DropDownButton
                  decoration: InputDecoration(labelText: 'Metodo di Pagamento'),
                  items: ['Contanti', 'Carta di Credito'].map((String value) {  //lista di opzioni generate dinamicamente usando .map()
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) { //Aggiorna _metodoPagamento con il valore selezionato e chiama setState per aggiornare la UI
                    setState(() {
                      _metodoPagamento = newValue!;
                    });
                  },
                ),
                if (_metodoPagamento == 'Carta di Credito') ...[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Numero Carta'),
                    maxLength: 12,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length != 12) {
                        return 'Inserisci un numero di carta valido';
                      }
                      return null;
                    },

                    //Se valido, salva il valore in _numeroCarta
                    onSaved: (value) {
                      _numeroCarta = value!;
                    },
                  ),
                  TextFormField(    //campo di testo per l'inserimento della data di scadenza in formato MM/YY
                    decoration: InputDecoration(
                      labelText: 'Data di Scadenza (MM/YY)',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectExpiryDate(context),  //icona accanto al campo per aprire un selettore di date
                      ),
                    ),
                    readOnly: true,  //campo di sola lettura perchè l'utente deve usare il selettore di date
                    controller: TextEditingController(text: _scadenzaCarta),   //controller usato per sincronizzare _scadenzaCarta con il valore visibile sul campo di testo
                    validator: (value) {
                      if (value == null || value.isEmpty || !RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                        return 'Inserisci una data di scadenza valida';
                      }
                      return null;
                    },
                  ),

                  //campo di testo relativo al cvv
                  TextFormField(
                    decoration: InputDecoration(labelText: 'CVV'),
                    maxLength: 3,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length != 3) {
                        return 'Inserisci un CVV valido';
                      }
                      return null;
                    },

                    //se il valore è corretto, valore salvato nella variabile del CVV
                    onSaved: (value) {
                      _cvvCarta = value!;
                    },
                  ),
                ],
                SizedBox(height: 16),

                //bottone conferma
                ElevatedButton(
                  onPressed: () {

                    //controllo tramite il medoto validate dell'oggetto formKey che i dati inseriti nei campi siano validi
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();  //salvataggio dei dati inseriti nei campi
                      Navigator.pushReplacement( //navigazione verso la schermata di riepilogo
                        context,
                        MaterialPageRoute(
                          builder: (context) => RiepilogoDatiScreen(    //I dati raccolti nel modulo passati come argomenti al costruttore di RiepilogoDatiScreen
                            indirizzo: _indirizzo,
                            orario: _orario,
                            metodoPagamento: _metodoPagamento,
                            ordine: widget.ordine,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text('Conferma'),
                ),
                SizedBox(height: 16),

                //bottone indietro
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false); // Torna alla schermata home
                  },
                  child: Text('Indietro'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}