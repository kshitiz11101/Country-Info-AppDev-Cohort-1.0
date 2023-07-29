import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.amber,
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.black),
    ),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _country = '';
  Future<Map<String, dynamic>>? _countryData;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Country Information',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(
                  () {
                    _country = value;
                  },
                );
              },
              decoration: InputDecoration(
                labelText: "Enter Country Name",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: height * 0.06,
              width: width * 0.88,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.amber,
                  onPrimary: Colors.black,
                ),
                child: Text('Fetch Information'),
                onPressed: () {
                  setState(() {
                    _countryData = _fetchCountryData(_country);
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder<Map<String, dynamic>>(
              future: _countryData,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  );
                } else if (snapshot.hasData) {
                  Map<String, dynamic> data = snapshot.data;
                  return Expanded(
                    child: ListView(
                      children: <Widget>[
                        Container(
                          color: Colors.grey[200],
                          margin: EdgeInsets.all(8.0),
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('Name'),
                            subtitle: Text(data['name']),
                          ),
                        ),
                        Container(
                          color: Colors.grey[200],
                          margin: EdgeInsets.all(8.0),
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('Capital'),
                            subtitle: Text(data['capital']),
                          ),
                        ),
                        // Flag ListTile
                        Container(
                          color: Colors.grey[200],
                          margin: EdgeInsets.all(8.0),
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('Flag'),
                            subtitle: CachedNetworkImage(
                              imageUrl: data['flags']['png'],
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        ),
                        // More tiles
                        Container(
                          color: Colors.grey[200],
                          margin: EdgeInsets.all(8.0),
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('Currencies'),
                            subtitle: Text(data['currencies']
                                .map((currency) => currency['name'])
                                .join(', ')),
                          ),
                        ),
                        Container(
                          color: Colors.grey[200],
                          margin: EdgeInsets.all(8.0),
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('Languages'),
                            subtitle: Text(data['languages']
                                .map((lang) => lang['name'])
                                .join(', ')),
                          ),
                        ),
                        Container(
                          color: Colors.grey[200],
                          margin: EdgeInsets.all(8.0),
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('Population'),
                            subtitle: Text(data['population'].toString()),
                          ),
                        ),
                        Container(
                          color: Colors.grey[200],
                          margin: EdgeInsets.all(8.0),
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('Continent'),
                            subtitle: Text(data['region']),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return Container(); // Default empty container when there is no data or error and not in loading state
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchCountryData(String country) async {
    final response = await http.get(
      Uri.parse('https://restcountries.com/v2/name/$country'),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result[0];
    } else {
      throw Exception('Failed to load country data');
    }
  }
}