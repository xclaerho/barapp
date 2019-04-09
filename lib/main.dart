import 'package:flutter/material.dart';
import 'package:barapp/StockPage.dart';
import 'package:barapp/HistoryPage.dart';
import 'package:barapp/OrderPage.dart';
import 'package:barapp/FinancialPage.dart';
import 'package:barapp/StockSettings.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barapp',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Tabs(),
    );
  }
}

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: 1, vsync: this, length: 3);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(_controller.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text("Vermeylen bar"),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: navigate,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text("Financieel"),
                  value: "financial",
                ),
                PopupMenuItem(
                  child: Text("Bewerk stock"),
                  value: "stock",
                ),
              ];
            },
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
        bottom: TabBar(
          controller: _controller,
          tabs: <Widget>[
            Tab(icon: Icon(Icons.store)),
            Tab(icon: Icon(Icons.add_shopping_cart)),
            Tab(icon: Icon(Icons.history)),
          ],
        ),
        
      ),
      body: TabBarView(
        controller: _controller,
        children: <Widget>[
          StockPage(),
          OrderPage(),
          HistoryPage(),
        ],
      )
    );
  }

  navigate(String page){
    Widget route;
    if(page == "financial"){
      route = FinancialPage();
    } else if(page == "stock"){
      route = StockSettings();
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => route),
    );
  }
}
