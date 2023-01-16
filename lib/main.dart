import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerBackgroundCallback(backgroundCallback);
  runApp(MyApp());
}

// Poziva se kad se pokrene Doing Background Work iz widgeta
Future<void> backgroundCallback(Uri? uri) async {
  if (uri!.host == 'updatecounter') {
    int? _counter;
    await HomeWidget.getWidgetData<int>('_counter', defaultValue: 0).then((value) {
      _counter = value!;
      _counter = _counter! + 1;
    });
    await HomeWidget.saveWidgetData<int>('_counter', _counter);
    await HomeWidget.updateWidget(name: 'AppWidgetProvider', iOSName: 'AppWidgetProvider');
  }
}

class MyApp extends StatelessWidget {

  // Ovaj widget je korijen aplikacije
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    HomeWidget.widgetClicked.listen((Uri? uri) => loadData());
    loadData(); // Ovo će učitavati podatke iz widgeta svaki put kada se otvori aplikacija
  }

  void loadData() async {
    await HomeWidget.getWidgetData<int>('_counter', defaultValue: 0).then((value) {
      _counter = value!;
    });
    setState(() {});
  }

  Future<void> updateAppWidget() async {
    await HomeWidget.saveWidgetData<int>('_counter', _counter);
    await HomeWidget.updateWidget(name: 'AppWidgetProvider', iOSName: 'AppWidgetProvider');
  }

  void _incrementCounter() {
    setState(() {
      // Ovaj poziv setState govori Flutter okviru da se nešto
      // promijenjenilo u ovom stanju, što uzrokuje ponovno pokretanje metode build u nastavku
      // tako da prikaz može odražavati ažurirane vrijednosti. Kad bismo promijenili
      // _counter bez pozivanja setState(), tada metoda izgradnje ne bi bila
      // ponovno pozvana i činilo bi se kao da se ništa ne događa.
      _counter++;
    });
    updateAppWidget();
  }

  @override
  Widget build(BuildContext context) {
    // Ova se metoda ponovno pokreće svaki put kada se pozove setState, na primjer kao
    // metodom _incrementCounter iznad.
    //
    // Flutter okvir je optimiziran za ponovno pokretanje metoda izgradnje
    // brzo, tako da možete jednostavno ponovno izgraditi sve što treba ažurirati
    // nego da morate pojedinačno mijenjati instance widgeta.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Kliknuli ste gumb ovoliko puta:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
