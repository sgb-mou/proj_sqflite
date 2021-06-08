import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'catatan.dart';
import 'database_helper.dart';

void main() {
  runApp(CatatanApp());
}

class CatatanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ListCatatan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ListCatatan(),
    );
  }
}

class DetailCatatan extends StatefulWidget {
  final String appBarTitle;
  final Catatan catatan;

  DetailCatatan(this.catatan, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return DetailCatatanState(this.catatan, this.appBarTitle);
  }
}

class DetailCatatanState extends State<DetailCatatan> {
  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Catatan catatan;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  DetailCatatanState(this.catatan, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = catatan.title;
    descriptionController.text = catatan.description;

    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey,
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Judul Berubah');
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'Judul',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Keterangan Berubah');
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Keterangan',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Colors.grey,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Simpan',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Tombol Simpan ditekan");
                              _save();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Colors.grey,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Hapus',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Tombol Hapus ditekan");
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
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updateTitle() {
    catatan.title = titleController.text;
  }

  void updateDescription() {
    catatan.description = descriptionController.text;
  }

  void _save() async {
    moveToLastScreen();

    catatan.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (catatan.id != null) {
      result = await helper.updateCatatan(catatan);
    } else {
      result = await helper.insertCatatan(catatan);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Berhasil menyimpan catatan');
    } else {
      _showAlertDialog('Status', 'Gagal menyimpan catatan');
    }
  }

  void _delete() async {
    moveToLastScreen();

    if (catatan.id == null) {
      _showAlertDialog('Status', 'Nomer catatan telah dihapus');
      return;
    }

    int result = await helper.deleteCatatan(catatan.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Berhasil menghapus catatan');
    } else {
      _showAlertDialog('Status', 'Gagal menghapus catatan');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}

class ListCatatan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ListCatatanState();
  }
}

class ListCatatanState extends State<ListCatatan> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Catatan> catatanList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (catatanList == null) {
      catatanList = List<Catatan>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text('Catatan'),
        centerTitle: true,
      ),
      body: getListCatatanView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        onPressed: () {
          debugPrint('Tombol Ditekan');
          navigateToDetail(Catatan('', '', ''), 'Tambah Catatan');
        },
        tooltip: 'Tambah Catatan',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getListCatatanView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber,
              child: Text(getFirstLetter(this.catatanList[position].title),
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(this.catatanList[position].title,
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(this.catatanList[position].description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onTap: () {
                    _delete(context, catatanList[position]);
                  },
                ),
              ],
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              navigateToDetail(this.catatanList[position], 'Edit Catatan');
            },
          ),
        );
      },
    );
  }

  getFirstLetter(String title) {
    return title.substring(0, 2);
  }

  void _delete(BuildContext context, Catatan catatan) async {
    int result = await databaseHelper.deleteCatatan(catatan.id);
    if (result != 0) {
      _showSnackBar(context, 'Catatan Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Catatan catatan, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return DetailCatatan(catatan, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Catatan>> catatanListFuture = databaseHelper.getListCatatan();
      catatanListFuture.then((catatanList) {
        setState(() {
          this.catatanList = catatanList;
          this.count = catatanList.length;
        });
      });
    });
  }
}
