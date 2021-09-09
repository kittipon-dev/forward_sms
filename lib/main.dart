// @dart=2.9
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sms/sms.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Forward SMS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _hostname = TextEditingController();
  final _path = TextEditingController();
  final _filter = TextEditingController();
  bool _switchValue = false;

  String _txt = "";

  Future<void> _forwared_web(SmsMessage msg) async {
    print(msg.body);
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('POST', Uri.parse('${_hostname.text}${_path.text}'));
    request.body = json.encode({
      "address": '${msg.address}',
      "body": '${msg.body}',
      "date": '${msg.date}',
    });
    request.headers.addAll(headers);
    if (_switchValue == true) {
      if (_filter.text == msg.address) {
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          _txt = 'Forward ${msg.date} ${msg.address} OK';
          setState(() {});
        } else {
          _txt = 'Send failed';
          setState(() {});
        }
      }
    } else {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        _txt = 'Forward ${msg.date} OK';
        setState(() {});
      } else {
        _txt = 'Send failed';
        setState(() {});
      }
    }
  }

  Future<void> _getconfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _hostname.text = await prefs.getString('hostname') ?? "";
    _path.text = await prefs.getString('path') ?? "";
    _filter.text = await prefs.getString('filter') ?? "";
    _switchValue = await prefs.getBool('swFilter') ?? false;
    setState(() {});
  }

  Future<void> _setconfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('hostname', _hostname.text);
    await prefs.setString('path', _path.text);
    await prefs.setString('filter', _filter.text);
    await prefs.setBool('swFilter', _switchValue);
    _txt = 'Save Changes OK';
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getconfig();
    SmsReceiver receiver = new SmsReceiver();
    receiver.onSmsReceived.listen((SmsMessage msg) => _forwared_web(msg));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('(DEMO) Forward sms'),
        actions: [
          IconButton(
              onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('HTTP POST'),
                      content: const Text(
                          'body\n{\n"address":"0800000000",\n"body":"Hello World",\n"date":"2021-06-13 07:39:38.266"\n}'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
              icon: Icon(Icons.help_outline)),
          IconButton(
              onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Contact'),
                      content: const Text('https://neware.dev'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
              icon: Icon(Icons.info_outline))
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _hostname,
                  decoration: InputDecoration(
                      hintText: "http://192.168.1.2:3000",
                      labelText: "Hostname"),
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                TextFormField(
                  controller: _path,
                  decoration: InputDecoration(hintText: "/", labelText: "Path"),
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                ),
                SizedBox(
                  width: 30,
                ),
                Flexible(
                  child: TextFormField(
                    controller: _filter,
                    decoration: InputDecoration(
                        hintText: "0800000000", labelText: "Filter Number"),
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () => _setconfig(),
                    child: Text(
                      "Save Changes",
                      style: TextStyle(fontSize: 18),
                    )),
                ElevatedButton(
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Demo version'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                  child: Text(
                    "Run Background",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              ],
            ),
          ),
          Text(_txt)
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
