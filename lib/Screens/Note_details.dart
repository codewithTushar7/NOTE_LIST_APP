import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Databse_to_UI/Database.dart';
import '../Model_class/Modal_class.dart';

class NoteDetail extends StatefulWidget {

  final String appBarTitle;
  final Note note;
  NoteDetail(this.note, this.appBarTitle);
  @override
  NoteDetailState createState() => NoteDetailState(this.note, this.appBarTitle);
}

class NoteDetailState extends State<NoteDetail> {

  static var _priorities = ['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();

  late String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note,this.appBarTitle);

  var _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = Theme
        .of(context)
        .textTheme
        .headline6;


    titleController.text = note.title ?? '';
    descriptionController.text = note.description ?? '';

    return WillPopScope(
      onWillPop: () async {
        MoveToLastScreen();
        return true;
      },
      child: Form(
        key: _formKey,
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                print("back");
                MoveToLastScreen();
              },
            ),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: [
                ListTile(
                  title: DropdownButton(
                    items: _priorities.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    value: getPriorityAsString(note.priority!),
                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        print('User selected $valueSelectedByUser');
                        updatePriorityAsInt(valueSelectedByUser.toString());
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 15.0, 0.0, 15.0),
                  child: TextFormField(
                    controller: titleController,
                    style: textStyle,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      print('Something changed in Title Text Field');
                      updateTitle();
                    },
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 15.0, 0.0, 15.0),
                  child: TextFormField(
                    controller: descriptionController,
                    style: textStyle,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      print('Something changed in Description Text Field');
                      updateDescriptions();
                    },
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 15.0, 0, 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          child: Text("Save", textScaleFactor: 1.5),
                          onPressed: () {
                            final isValid = _formKey.currentState?.validate();
                            if (!isValid!) {
                              return;
                            }
                            _formKey.currentState?.save();
                            setState(() {
                              _save();
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          child: Text("Delete", textScaleFactor: 1.5),
                          onPressed: () {
                            setState(() {
                              _delete();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
   void updatePriorityAsInt(String? value) {
     switch (value) {
       case 'High':
         note.priority = 1;
         break;
       case 'Low':
         note.priority = 2;
         break;
     }
   }

   String? getPriorityAsString(int value) {
     String? priority;
     switch (value) {
       case 1:
         priority = _priorities[0];
         break;
       case 2:
         priority = _priorities[1];
         break;
     }
     return priority;
   }

  void updateTitle() {
    note.title=titleController.text;
  }

  void updateDescriptions(){
     note.description=descriptionController.text;
   }

   void _save() async {
     MoveToLastScreen();
     note.date = DateFormat.yMMMd().format(DateTime.now());
     int result;
     if (note.id != null) {
       result = await helper.updateNote(note);
     } else {
       result = await helper.insertNote(note);
     }

     if (result != 0) {
       _showAlertDialog('Status', "Note Saved Successfully!");
     } else {
       _showAlertDialog('Status', "Problem Saving Note");
     }
   }

   void _showAlertDialog(String title, String message) {
     AlertDialog alertDialog =
     AlertDialog(title: Text(title), content: Text(message));
     showDialog(
       context: context,
       builder: (_) => alertDialog,
     );
   }

   void MoveToLastScreen(){
    Navigator.pop(context, true);
   }

   void _delete() async {
     MoveToLastScreen();
     if (note.id == null) {
       _showAlertDialog('Status', 'No note was deleted!');
       return;
     }
     int result = await helper.deleteNote(note.id!);
     if (result != 0) {
       _showAlertDialog('Status', 'Note Deleted Successfully');
     } else {
       _showAlertDialog('Status', 'Error Occured');
     }
   }
}








