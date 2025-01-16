class Ordine {
  final String idOrdine;
  final String idUtente;
  final Map<String, int> piadine;
  final Map<String, int> bevande;
  double prezzo;

  Ordine({
    required this.idOrdine,
    required this.idUtente,
    required this.piadine,
    required this.bevande,
    this.prezzo = 0.0,
  });

  void calcolaPrezzo() {
    const prezziPiadine = {
      'Piadina Classica': 5.0,
      'Piadina Vegetariana': 6.0,
      'Piadina al Prosciutto': 7.0,
    };
    const prezziBevande = {
      'Acqua': 1.0,
      'Coca Cola': 2.0,
      'Birra': 3.0,
    };

    prezzo = 0.0;
    piadine.forEach((item, qty) {
      prezzo += (prezziPiadine[item] ?? 0) * qty;
    });
    bevande.forEach((item, qty) {
      prezzo += (prezziBevande[item] ?? 0) * qty;
    });
  }
}