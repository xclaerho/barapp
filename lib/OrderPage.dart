import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderPage extends StatefulWidget {

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List _order;
  bool _loaded = false;

  @override
  void initState(){
    super.initState();
    _initMap();
  }

  @override
  Widget build(BuildContext context) {
    if(!_loaded){
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        body: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.euro_symbol),
              title: Text(_calculatePrice().toString()),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _order.length,
                itemBuilder: (context, index){
                  return ListTile(
                    title: Text(_order.elementAt(index)['name']),
                    trailing: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                                _order.elementAt(index)['amount']++; 
                            });
                          },
                        ),
                        Text(_order.elementAt(index)['amount'].toString()),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if(_order.elementAt(index)['amount']>0)
                                _order.elementAt(index)['amount']--; 
                            });
                          },
                        ),
                      ],
                      mainAxisSize: MainAxisSize.min,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.send),
          onPressed: () => _sendOrder(),

        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }
  }

  /// Load items that can be ordered into a map and set the state
  /// to no longer loading when done.
  void _initMap() async {
    _order = List();
    Future<QuerySnapshot> stock = Firestore.instance.collection('stock').getDocuments();
    stock.then((QuerySnapshot snapshot){
      snapshot.documents.forEach((DocumentSnapshot document){
        Map item = Map();
        item['name'] = document['item'];
        item['price'] = document['price'];
        item['amount'] = 0;
        item['documentID'] = document.documentID;
        _order.add(item);
      });
      setState(() {
       _loaded = true; 
      });
    });
  }

  /// Calculate the price of all items in the current order.
  double _calculatePrice(){
    double price = 0;
    _order.forEach((element) {
      price += element['amount']*element['price'];  
    });
    return price;
  }

  /// Send order to be stored in the database.
  void _sendOrder(){
    if(_calculatePrice()==0){
      // Don't send empty orders
      return;
    } else {
      // Set loading
      setState(() {
      _loaded = false; 
      });
      // create transaction
      Map<String, dynamic> transaction = Map();
      transaction['timestamp'] = Timestamp.now();
      transaction['price'] =_calculatePrice();
      transaction['order'] = List();
      // update stock if needed and add to transaction
      _order.forEach((element){
        if(element['amount']>0){
          // update stock
          DocumentReference ref = Firestore.instance.document('stock/' + element['documentID']);
          Firestore.instance.runTransaction((Transaction tx) async {
            DocumentSnapshot snapshot = await tx.get(ref);
            if(snapshot.exists){
              await tx.update(ref, <String, dynamic>{'amount': snapshot.data['amount'] - element['amount']});
            }
          });
          // add to transaction
          transaction['order'].add({'amount': element['amount'], 'item': element['name'], 'documentID': element['documentID']});
        }
      });
      // Send transaction to db
      Firestore.instance.runTransaction((Transaction tx) async {
        CollectionReference ref =  Firestore.instance.collection('transactions');
        await ref.add(transaction);
      });
      // New order (sets loaded to true as well)
      _initMap();
    }
  }
  
}