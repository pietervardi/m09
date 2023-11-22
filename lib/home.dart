import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:minggu_09_revisi/model.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  List<EventModel> details = [];

  @override
  void initState() {
    readData();
    super.initState();
  }

  // Future testData() async {
  //   await Firebase.initializeApp();
  //   print('init Done');
  //   FirebaseFirestore db = await FirebaseFirestore.instance;
  //   print('init Firestore Done');
  //   var data = await db.collection('event_detail').get().then((event) {
  //     for (var doc in event.docs) {
  //       print('${doc.id} => ${doc.data()}');
  //     }
  //   });
  // }

  Future readData() async {
    await Firebase.initializeApp();
    FirebaseFirestore db = await FirebaseFirestore.instance;
    var data = await db.collection('event_id').get();
    setState(() {
      details = data.docs.map((doc) => EventModel.fromDocSnapshot(doc)).toList();
    });
  }

  addRand() async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    EventModel insertData = EventModel(
      judul: getRandString(5),
      keterangan: getRandString(30),
      tanggal: getRandString(10),
      is_like: Random().nextBool(),
      pembicara: getRandString(20)
    );
    await db.collection("event_id").add(insertData.toMap());
    setState(() {
      details.add(insertData);
      readData();
    });
  }

  deleteLast(String documentId) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    await db.collection("event_id").doc(documentId).delete();
    setState(() {
      details.removeLast();
    });
  }

  deleteItemAt(int position, String documentId) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    await db.collection("event_id").doc(documentId).delete();
    setState(() {
      details.removeAt(position);
      readData();
    });
  }

  updateEvent(int pos) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    await db
      .collection("event_id")
      .doc(details[pos].id)
      .update({'is_like': !details[pos].is_like});
    setState(() {
      details[pos].is_like = !details[pos].is_like;
      readData();
    });
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Firestore')),
      body: ListView.builder(
        itemCount: details.length,
        itemBuilder: (context, position) {
          return ListTile(
            title: Text(details[position].judul),
            subtitle: Text(
              "${details[position].keterangan}" +
              "\nHari : ${details[position].tanggal}" +
              "\nPembicara : ${details[position].pembicara}"
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    updateEvent(position);
                  },
                  icon: Icon(details[position].is_like
                      ? Icons.favorite
                      : Icons.favorite_border),
                ),
                IconButton(
                  onPressed: () {
                    _showDeleteDialog(details[position].id, position);
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          );
        }
      ),
      floatingActionButton: FabCircularMenu(
        children: <Widget>[
          IconButton(
            onPressed: () {
              addRand();
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              if (details.last.id != null) {
                deleteLast(details.last.id!);
              }
            }, 
            icon: const Icon(Icons.minimize),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String? documentId, int position) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Event"),
          content: const Text("Are you sure you want to delete this event?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (documentId != null) {
                  deleteItemAt(position, documentId);
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      }
    );
  }
}