import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FinancialPage extends StatefulWidget{
  @override
  _FinancialPageState createState() => _FinancialPageState();
}

class _FinancialPageState extends State<FinancialPage>{
  // Initial dates for statistics
  DateTime fromDate = DateTime.now().subtract(Duration(days: 1));
  DateTime toDate = DateTime.now();
  double revenue = 0.0;
  double profit = 0.0;

  @override
  Widget build(BuildContext context) {
    _calculateStatistics();
    return Scaffold(
      appBar: AppBar(
        title: Text('Financieel'),
      ),
      body: Column(children: <Widget>[
        ListTile(
          leading: Text("Van:"),
          title: Text(fromDate.toString()),
          onTap: () {_selectFromDate(context);},
        ),
        ListTile(
          leading: Text("Tot:"),
          title: Text(toDate.toString()),
          onTap: () {_selectToDate(context);},
        ),
        Divider(),
        ListTile(
          title: Text("Omzet: € " + revenue.toString()),
        ),
        ListTile(
          title: Text("Winst: € " + profit.toString()),
        ),
      ],)
    );
  }

  Future<Null> _selectFromDate(BuildContext context) async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    final TimeOfDay time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    DateTime picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if(picked != null && picked != fromDate && picked.isBefore(toDate)){
      setState(() {
        fromDate = picked;
      });
    } else {
      _showDialog(context);
    }
  }

  Future<Null> _selectToDate(BuildContext context) async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: toDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    final TimeOfDay time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    DateTime picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if(picked != null && picked != toDate && picked.isAfter(fromDate)){
      setState(() {
       toDate = picked; 
      });
    } else {
      _showDialog(context);
    }
  }

  _calculateStatistics(){
    // Get all transactions between the picked dates
    // Calculate the statistics on these transactions
    revenue = 0.0;
    profit = 0.0;
  }

  _showDialog(context){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Er ging iets mis!"),
          content: Text("Zorg ervoor dat de 'van' datum voor de 'tot' datum komt."),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }
  
}