import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  runApp(
    MaterialApp(
      home: Home(),
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        hintColor: Colors.blue,
        primaryColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

Future<Map> getData(String cidade) async {
  final url = 'http://api.openweathermap.org/data/2.5/weather?q=$cidade&appid=3483b8e2ec0fe01edd4b0d3eb3341908&units=metric&lang=pt_br';
  http.Response response = await http.get(Uri.parse(url));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  Map? dadosClima;
  final cidadeController = TextEditingController();
  String? erro;
  bool _isLoading = false;

  void _limpar() {
    cidadeController.text = "";
    setState(() {
      dadosClima = null;
      erro = null;
      _isLoading = false;
    });
  }

  void buscarClima() async {
    final cidade = cidadeController.text;
    if (cidade.isEmpty) return;

    setState(() {
      _isLoading = true;
      erro = null;
    });

    try {
      final dados = await getData(cidade);
      setState(() {
        dadosClima = dados;
        erro = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        erro = "Erro ao buscar clima.";
        dadosClima = null;
        _isLoading = false;
      });
    }
  }

  String getImagemParaDescricao(String descricao) {
    descricao = descricao.toLowerCase();

    if (descricao.contains("nuvem") || descricao.contains("céu")) {
      return 'assets/sol.png';
    } else if (descricao.contains("chuva")) {
      return 'assets/chuva.png';
    } else if (descricao.contains("neve")) {
      return 'assets/neve.png';
    } else if (descricao.contains("névoa") || descricao.contains("nublado") || descricao.contains("neblina")) {
      return 'assets/nublado.png';
    } else if (descricao.contains("tempestade") || descricao.contains("trovoada")) {
      return 'assets/tempestade.png';
    } else if (descricao.contains("vento") || descricao.contains("ventania")) {
      return 'assets/vento.png';
    } else {
      return 'assets/sol.png'; 
    }
  }

  String getDataFormatada() {
    final agora = DateTime.now();
    final formatador = DateFormat("EEEE, d 'de' MMMM 'de' y", 'pt_BR');
    return formatador.format(agora);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wb_twilight, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Clima",
              style: TextStyle(                
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 37, 89, 131),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _limpar,
            color: Colors.white,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
            'Digite o nome de uma cidade, e informaremos o clima!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 41, 45, 54),
            ),
          ),
          SizedBox(height: 30),
            TextField(
              controller: cidadeController,
              style: TextStyle(color: Color.fromARGB(255, 14, 49, 114)),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.wb_twilight, color: Color.fromARGB(255, 14, 49, 114)),
                labelText: "Digite o nome da cidade",
                labelStyle: TextStyle(color: Color.fromARGB(255, 14, 49, 114)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), 
                  borderSide: BorderSide(color: Colors.grey), 
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), 
                  borderSide: BorderSide(color: Colors.grey),  
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: buscarClima,
              style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 206, 206, 206),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
              child: Text("Buscar Clima",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 18, 68, 100),
                ),
              ),
            ),
            SizedBox(height: 20),
             if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
            if (erro != null)
              Text(
                erro!,
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            if (dadosClima != null)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Clima em ${dadosClima!['name']}",
                      style: TextStyle(color: Colors.black, fontSize: 22),
                    ),                    
                    Text(
                      getDataFormatada(),
                      style: TextStyle(
                        color: Color.fromARGB(255, 14, 49, 114),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    Image.asset(
                      getImagemParaDescricao(dadosClima!['weather'][0]['description']),
                      height: 100,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "${dadosClima!['main']['temp']}°C",
                      style: TextStyle(color: Colors.grey, fontSize: 40),
                    ),
                    Text(
                      dadosClima!['weather'][0]['description'],
                      style: TextStyle(color: const Color.fromARGB(255, 0, 131, 238), fontSize: 18),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
