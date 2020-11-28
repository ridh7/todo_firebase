import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        accentColor: Colors.orange,
      ),
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String input = "";

  createTodo() {
    DocumentReference documentReference =
        Firestore.instance.collection('Todo').document(input);

    Map<String, String> todos = {"todoTitle": input};

    documentReference
        .setData(todos)
        .whenComplete(() => print('$input created'));
  }

  deleteTodo(item) {
    DocumentReference documentReference =
        Firestore.instance.collection('Todo').document(item);
    documentReference.delete().whenComplete(() => print('$item deleted'));
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('To-do'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  title: Text('Add to-do list'),
                  content: TextField(
                    autofocus: true,
                    onChanged: (value) {
                      input = value;
                    },
                  ),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        createTodo();
                        Navigator.pop(context);
                      },
                      child: Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        body: StreamBuilder(
          stream: Firestore.instance.collection('Todo').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            return ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot documentSnapshot =
                      snapshot.data.documents[index];
                  return Dismissible(
                    onDismissed: (direction) {
                      deleteTodo(documentSnapshot['todoTitle']);
                    },
                    key: Key(documentSnapshot['todoTitle']),
                    child: Card(
                      elevation: 8,
                      margin: EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(documentSnapshot['todoTitle']),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            deleteTodo(documentSnapshot['todoTitle']);
                          },
                        ),
                      ),
                    ),
                  );
                },
                itemCount: snapshot.data.documents.length);
          },
        ));
  }
}
