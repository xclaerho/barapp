import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState()  => _HistoryPageState();
  
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('transactions').where("timestamp", isGreaterThan: DateTime.now().subtract(Duration(hours: 24))).orderBy('timestamp', descending: true).limit(10).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(snapshot.hasError)
          return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return Center(child: CircularProgressIndicator());
          default:
            return ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                String hour = (document['timestamp'].hour < 10)? "0"+document["timestamp"].hour.toString() : document['timestamp'].hour.toString();
                String minute = (document['timestamp'].minute < 10)? "0"+document["timestamp"].minute.toString() : document['timestamp'].minute.toString();
                return ExpansionTile(
                    leading: Text("€ " + document['price'].toString()),
                    title: Text(hour + ":" + minute),
                    children: _orderDetails(document["order"], document.documentID),
                );
              }).toList(),
            );
        }
      },
    );
  }

  /// Build children for the ExpansionTile for a certain order displaying which items
  /// were in the order and how many.
  List<Widget> _orderDetails(List order, String documentID){
    List<Widget> rows = List();
    order.forEach((item) {
      Widget row = Row(
        children: <Widget>[
          Text(item["item"]),
          Text(item["amount"].toString()),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      );
      rows.add(row);
    });
    Widget deleteRow = Row(
      children: <Widget> [
        IconButton(
          icon: Icon(Icons.delete_outline),
          onPressed: (){
            _undoOrder(order, documentID);
          },
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
    rows.add(deleteRow);
    return rows;
  }

  /// Undo an order by resetting the changes made to the stock
  /// by the order and removing the transaction from the database.
  void _undoOrder(List order, String documentID){
    // reset stock for each item
    order.forEach((item){
      DocumentReference ref = Firestore.instance.document('stock/' + item['documentID']);
      Firestore.instance.runTransaction((Transaction tx) async {
        DocumentSnapshot snapshot = await tx.get(ref);
        if(snapshot.exists){
          await tx.update(ref, <String, dynamic>{'amount': snapshot.data['amount'] + item['amount']});
        }
      });
    });
    // remove transaction from database
    DocumentReference ref = Firestore.instance.document('transactions/' + documentID);
    Firestore.instance.runTransaction((Transaction tx) async {
      await tx.delete(ref);
    });
  }
  
}