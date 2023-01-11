import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  TextEditingController _todoController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TO DO APP"),
      ),
      body: Column(
        children: [
          Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                    width: MediaQuery.of(context).size.width * 0.78,
                    height: 45,
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(15)),
                    child: TextField(
                      controller: _todoController,
                      decoration: InputDecoration(
                          hintText: "Type Something Here",
                          border: InputBorder.none,
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _todoController.clear();
                              });
                            },
                            child: Icon(Icons.clear),
                          )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_todoController.text.isNotEmpty) {
                        FirebaseFirestore.instance
                            .collection("Todocollections")
                            .add({
                          "notes": _todoController.text,
                          "isChecked": false
                        });
                        _todoController.clear();
                      }
                      ;
                    },
                    child: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        )),
                  ),
                ]),
          ),
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Todocollections")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return Text('Loading...');
                  }
                  if (snapshot.data!.docs.length == 0) {
                    return Container(
                      child: Center(child: Text('No Notes yet')),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    // shrinkWrap: true,
                    // physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Todolist(
                          snapshot.data!.docs[index]['notes'],
                          snapshot.data!.docs[index]['isChecked'],
                          snapshot.data!.docs[index].id);
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget Todolist(String text, bool isMarked, String docId) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 60,
        // ignore: sort_child_properties_last
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                if (isMarked == false) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Completed")));
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Pending")));
                }
                FirebaseFirestore.instance
                    .collection('Todocollections')
                    .doc(docId)
                    .update({'isChecked': !isMarked});
              },
              child: CircleAvatar(
                  backgroundColor: isMarked ? Colors.green : Colors.black54,
                  radius: 10,
                  child: Icon(
                    Icons.done,
                    size: 15,
                  )),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.45,
              child: Text(text),
            ),
            GestureDetector(
              onTap: () {
                editText(text, docId);
              },
              child: Icon(
                Icons.edit,
                size: 15,
              ),
            ),
            GestureDetector(
              onTap: () {
                FirebaseFirestore.instance
                    .collection('Todocollections')
                    .doc(docId)
                    .delete();
              },
              child: Icon(
                Icons.delete,
                size: 15,
              ),
            )
          ],
        ),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  TextEditingController _edit = TextEditingController();
  void editText(String text, String documentId) {
    _edit.clear();
    _edit.text = text;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: TextField(
                    controller: _edit,
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('Todocollections')
                          .doc(documentId)
                          .update({'notes': _edit.text});
                      Navigator.of(context).pop();
                    },
                    child: Text('Edit')),
              ],
            ),
          ),
        );
      },
    ); // showBottomSheet(
    //   context: context,
    //   builder: (context) {
    //     return Scaffold(
    // body: Container(
    //   child: Column(
    //     children: [
    //       // TextField(),
    //       // ElevatedButton(onPressed: () {}, child: Text('data'))
    //     ],
    //   ),
    // ),
    //     );
    //   },
    // );
  }
}
