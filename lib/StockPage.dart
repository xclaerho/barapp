import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StockPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('stock').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(snapshot.hasError)
          return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return Center(child: CircularProgressIndicator(),);
          default:
            return Scaffold(
              body: ListView(
                children: snapshot.data.documents.map((DocumentSnapshot document) {
                  return ListTile(
                    title: Text(document['item']),
                    subtitle: Text(document['amount'].toString()),
                  );
                }).toList(),
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.local_shipping),
                onPressed: (){
                  //TODO: delivery modal
                },
              ),
            );
        }
      },
    );
  }
  
}
