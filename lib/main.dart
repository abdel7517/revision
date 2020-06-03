

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:revisionApp/home.dart';
import 'package:revisionApp/detailsList.dart';




void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revison',
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
      home: MyHomePage(title: 'Revison'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
bool status = false;
Timer timer;
 Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
   String _queryText;
    FirebaseUser user;


  
@override
  void initState() {
    super.initState();
        getList();

  
  }

  void getList() async 
  {
        final SharedPreferences prefs = await _prefs;

     setState(()  
        {
          status = (prefs.getBool('status') ?? false);
          print(status);
    

        });

      FirebaseAuth.instance.currentUser().then((value) {
        setState(() {
          user = value;
                    print(user.email);

        });

      });

  }

 void showMenuSelection(String value) async 
 {
    if (value == "logout") {
    await FirebaseAuth.instance.signOut();
      final SharedPreferences prefs = await _prefs;
      prefs.setBool("status", false);
      setState(() {
        status = false;
      });
      } 
      else
      {
           Navigator.push(context, MaterialPageRoute(builder: (context) =>   MyHomePage(title : "Revision") ));
      }
 }


Widget _buildListItem(DocumentSnapshot document) {
  return  ListTile(
    title: Center(child: Text( "List : "+ document["titre"].toString())),
    onTap: ()=> Navigator.push(
                            context, MaterialPageRoute(builder: (context) => DetailsList(document["titre"]) )),
  );
}

 Widget _fireSearch() {


   if(user != null)
   {
      return new StreamBuilder(
    stream: Firestore.instance.collection("lists").where("mail", isEqualTo: user.email).snapshots(),
    builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasData) {

        return new ListView.builder(
        itemCount: snapshot.data.documents.length,
        itemBuilder: (BuildContext context, int index) =>
            _buildListItem(snapshot.data.documents[index]),
      );

      }
      else
      {
        return Text("RIEN");
      }
   
    },);

   } else{
     return Container();
   }
 

 }

   
  Widget back(context)
  {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () { Navigator.push(context, 
          MaterialPageRoute(builder: (context) => MyHomePage(title: "Revision") )); },
      );
  }
 
   @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        leading: back(context),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
         actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: showMenuSelection,
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              status ? 
              const PopupMenuItem<String>(
                  value: 'logout', child: Text('Deconnexion')):
                  const PopupMenuItem<String>(
                  value: 'accueil', child: Text('Acceuil'))

                      ],
          )
        ]
        
      ),
      body: 

        Column(crossAxisAlignment: CrossAxisAlignment.center,
          children: 
        [
          Container(height: 10,),
            RaisedButton(
            onPressed: () { Navigator.push(
                            context, MaterialPageRoute(builder: (context) => Home(status) ));
                            },
            child: Text('Crée une liste')
                          
          ),
          Expanded(child:  _fireSearch())

          
        ],) ,
      
         
      
     // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
