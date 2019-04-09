import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StockSettings extends StatefulWidget{
  @override
  _StockSettingsState createState() => _StockSettingsState();
}

class _StockSettingsState extends State<StockSettings>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock'),
      ),
      body: Text("TODO"),
    );
  }
  
}