import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:unique_identifier/unique_identifier.dart';

import 'dart:async';
import 'dart:convert';
import 'package:login_sas/HomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginDemo(),
    );
  }
}

class LoginDemo extends StatefulWidget {
  @override
  _LoginDemoState createState() => _LoginDemoState();
}

class _LoginDemoState extends State<LoginDemo> {
  String deviceId = "", _pass = '', _nama = '', _identifier = 'Unknown';
  bool setlog = false;
  TextEditingController namaController = TextEditingController(),
      passController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initUniqueIdentifierState();
  }

  Future<void> initUniqueIdentifierState() async {
    String identifier;

    try {
      identifier = (await UniqueIdentifier.serial)!;
    } on PlatformException {
      identifier = 'failed';
    }
    if (!mounted) return;
    setState(() {
      _identifier = identifier;
    });
  }

  Future<void> setLogin(String _nama, String _pass, String _identifier) async {
    try {
      String uri = "http://192.168.90.110/sas_api/api/login";

      var res = await http
          .post(Uri.parse(uri), body: {"username": _nama, "password": _pass});
      var response = jsonDecode(res.body);

      if (response["respon"] == true) {
        if (response["responPass"] == false) {
          _showToast(context, 'Password salah');
        } else if (!(response['imei'] == _identifier)) {
          _showToast(context, 'Perangkat tidak sesuai dengan Akun');
        } else {
          _showToast(context, 'Selamat datang ' + _nama);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HomePage(_nama)));
        }
      } else {
        _showToast(context, 'Username tidak ditemukan');
        print('salah');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: namaController,
              decoration: InputDecoration(labelText: 'username'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: passController,
              decoration: InputDecoration(labelText: 'password'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: RaisedButton(
              color: Colors.amber,
              child: Text('Login'),
              onPressed: () {
                setState(() {
                  _nama = namaController.text;
                  _pass = passController.text;
                });
                setLogin(_nama, _pass, _identifier);
              },
            ),
          ),
        ],
      ),
    );
  }
}

void _showToast(BuildContext context, String _pass) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(_pass),
      // action: SnackBarAction(
      //     label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
    ),
  );
}
