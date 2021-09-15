import 'dart:convert';
import 'dart:io';
//import 'package:contacts_service/contacts_service.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String msg = 'Choose your .XLSX file ';
  String file_path ='';
  List<Contact> content = [];
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40,),
            Text(msg,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
            Expanded(
              child: ListView.builder(
                  itemCount: content.length,
                  itemBuilder: (context,index){
                return ListTile(title: Text(content[index].name.first,style: TextStyle(fontSize:18)),subtitle: Text(content[index].phones[0].number.toString(),style: TextStyle(fontSize: 18)),);
              }),
            ),
            SizedBox(height: 10,),
            Text('developed by Ahmed Sobhy',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
            SizedBox(height: 10,)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //  remove all contact
          content.clear();

          // get contact permission
          if (!await FlutterContacts.requestPermission()) {
            setState(() => msg = 'you should give app contact permission');
          }

          // file picker to get permission and get file data
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['xlsx'],allowMultiple: false,withData: true);

          // if picked file
            if(result != null){
             file_path = result.files.first.path;
             var file = file_path;
             var bytes = File(file).readAsBytesSync();
             //var bytes = result.files.single.bytes;
            // if(bytes!=null) {
             // convert file to table and gets all data from file
             // file content 2 columns name , phone
               var excel = Excel.decodeBytes(bytes);
               for (var table in excel.tables.keys) {
                 for (var row in excel.tables[table]!.rows) {
                  // await ContactsService.addContact(Contact(displayName:row[0]!.value.toString(),phones: ));
                   // check if have contact permission
                   if (await FlutterContacts.requestPermission()) {
                     // if have contact permission add contact
                     final newContact = Contact()
                       ..name.first = row[0]!.value.toString()
                       ..phones = [Phone(row[1]!.value.toString())];
                     await newContact.insert();
                     content.add(newContact);
                     setState(()=>msg = 'added all contact successfully');
                   }else{
                     // if haven't contact permission send error message
                     setState(()=>msg = 'you should give app contact permission');
                   }
                 }
               }
             // }else
             //   print(bytes);
            }


          },
        tooltip: 'file Picker',
        child: Icon(Icons.attach_file_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


