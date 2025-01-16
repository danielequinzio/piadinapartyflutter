import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/ordine_model.dart';
import '../view/riepilogo_ordine.dart';

class InserimentoDatiScreen extends StatefulWidget {
  final Ordine ordine;
  final String? indirizzo;
  final String? orario;
  final String? metodoPagamento;

  InserimentoDatiScreen({
    required this.ordine,
    this.indirizzo,
    this.orario,
    this.metodoPagamento,
  });

  @override
  _InserimentoDatiScreenState createState() => _InserimentoDatiScreenState();
}

class _InserimentoDatiScreenState extends State<InserimentoDatiScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _indirizzo;
  late String _orario;
  late String _metodoPagamento;
  String _numeroCarta = '';
  String _scadenzaCarta = '';
  String _cvvCarta = '';
  final TextEditingController _orarioController = TextEditingController();

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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: now,
    );

    if (picked != null) {
      final DateTime nowDateTime = DateTime.now();
      final DateTime pickedDateTime = DateTime(
        nowDateTime.year,
        nowDateTime.month,
        nowDateTime.day,
        picked.hour,
        picked.minute,
      );

      final DateTime earliestAllowedTime = nowDateTime.add(Duration(minutes: 30));
      final DateTime latestAllowedTime = DateTime(
        nowDateTime.year,
        nowDateTime.month,
        nowDateTime.day,
        23,
        0,
      );

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
          _orario = picked.format(context);
          _orarioController.text = _orario;
        });
      }
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year, now.month),
      firstDate: DateTime(now.year),
      lastDate: DateTime(now.year + 10),
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
    if (picked != null) {
      setState(() {
        _scadenzaCarta = '${picked.month.toString().padLeft(2, '0')}/${picked.year.toString().substring(2)}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inserimento Dati'),
        automaticallyImplyLeading: false, // Rimuove l'icona di ritorno indietro
      ),
      body: Container(
        color: Colors.orange,
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _indirizzo,
                  decoration: InputDecoration(labelText: 'Indirizzo di Consegna'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci un indirizzo';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _indirizzo = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Orario di Consegna',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () => _selectTime(context),
                    ),
                  ),
                  readOnly: true,
                  controller: _orarioController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci un orario';
                    }

                    final DateTime now = DateTime.now();
                    final parts = value.split(' ');
                    final timeParts = parts[0].split(':');
                    int hour = int.parse(timeParts[0]);
                    final int minute = int.parse(timeParts[1]);

                    if (parts[1] == 'PM' && hour != 12) {
                      hour += 12;
                    } else if (parts[1] == 'AM' && hour == 12) {
                      hour = 0;
                    }

                    final DateTime selectedTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      hour,
                      minute,
                    );

                    if (selectedTime.isBefore(now.add(Duration(minutes: 30)))) {
                      return 'L\'orario di consegna deve essere almeno 30 minuti dopo l\'orario corrente.';
                    }

                    if (selectedTime.hour < 19 || selectedTime.hour >= 23) {
                      return 'L\'orario di consegna deve essere tra le 7 PM e le 11 PM.';
                    }

                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _metodoPagamento,
                  decoration: InputDecoration(labelText: 'Metodo di Pagamento'),
                  items: ['Contanti', 'Carta di Credito'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
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
                    onSaved: (value) {
                      _numeroCarta = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Data di Scadenza (MM/YY)',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectExpiryDate(context),
                      ),
                    ),
                    readOnly: true,
                    controller: TextEditingController(text: _scadenzaCarta),
                    validator: (value) {
                      if (value == null || value.isEmpty || !RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                        return 'Inserisci una data di scadenza valida';
                      }
                      return null;
                    },
                  ),
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
                    onSaved: (value) {
                      _cvvCarta = value!;
                    },
                  ),
                ],
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RiepilogoDatiScreen(
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