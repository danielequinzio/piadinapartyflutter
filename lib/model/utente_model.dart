//definisce classe utente
class UserModel {
  final String id;
  final String name;
  final String surname;
  final String email;

  //costruttore per creare istanza della classe
  UserModel({
    required this.id,    //con required si impone che i quattro campi dell'istanza devono assumere un valore
    required this.name,
    required this.surname,
    required this.email,
  });

  //alternativa di costruttore partendo da un Map
  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id, //id passato separatamente mentre altri campi estratti dal map
      name: data['name'] ?? '',   //Se un valore nella mappa non è presente, si usa il valore predefinito di stringa vuota
      surname: data['surname'] ?? '',
      email: data['email'] ?? '',
    );
  }

  //metodo per convertire istanza di utente in map e salvarlo nel database
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'email': email,
    };
  }
}