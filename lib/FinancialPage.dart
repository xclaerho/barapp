import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FinancialPage extends StatefulWidget{
  @override
  _FinancialPageState createState() => _FinancialPageState();
}

class _FinancialPageState extends State<FinancialPage>{
  // Initial dates for statistics
  DateTime fromDate = DateTime.now().subtract(Duration(seconds: 1));
  DateTime toDate = DateTime.now();
  bool calculated = false;
  double revenue = 0.0;
  double profit = 0.0;
  
  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [
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
    ];
    List<Widget> statistics;
    if(calculated){
      statistics = [
        ListTile(
          title: Text("Omzet: € " + revenue.toString()),
        ),
        ListTile(
          title: Text("Winst: € " + profit.toString()),
        ),
      ];
    } else {
      statistics = [
        RaisedButton(
          child: Text("Bereken"),
          onPressed: () {
            _calculateStatistics();
          },
        ),
      ];
    }
    elements.addAll(statistics);
    return Scaffold(
      appBar: AppBar(
        title: Text('Financieel'),
      ),
      body: Column(children: elements,)
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
      fromDate = picked;
      setState(() {
        fromDate = picked;
        calculated = false;
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
      toDate = picked;
      setState(() {
        toDate = picked;
        calculated = false;
      });
    } else {
      _showDialog(context);
    }
  }

  Future<void> _calculateStatistics() async {
    profit = 0.0;
    revenue = 0.0;
    // Get all transactions between the picked dates
    Future<QuerySnapshot> stock = Firestore.instance.collection('transactions').where("timestamp", isGreaterThan: fromDate).where("timestamp", isLessThan:toDate).getDocuments();
    stock.then((QuerySnapshot snapshot){
      snapshot.documents.forEach((DocumentSnapshot document){
        // Calculate in eurocents to avoid floating point errors
        revenue += document['price'];
        profit += document['profit'];
      });
      // convert to euros and update state
     revenue = revenue/100;
     profit = profit/100;
     setState(() {
       calculated = true;
     });
    });
    
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