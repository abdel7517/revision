

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:revisionApp/main.dart';








class Home extends StatefulWidget {

Home(this.status);
final bool status;
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  _HomeState createState() => _HomeState(status);
}


class _HomeState extends State<Home>
{
  _HomeState(this.alreadyLog);
  TextEditingController controllerWord;
  TextEditingController controllerWordTraduction;
  TextEditingController controllerListName;
 final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, String> words = {};
  List<String> wordsIndex = [];
  String word, wordTraduction, listName, errorMessage, mail, mdp, cmdp;
  bool alreadySign = true;
  bool alreadyLog;
  bool goodMp = true;
  bool error = false;
  bool userAlreadyLog = false;
  bool inLoad = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();





@override
  void initState() {
    // TODO: implement initState
    super.initState();
    controllerWord = TextEditingController();
    controllerWordTraduction = TextEditingController();
    print(alreadyLog);

    // check if the user is connect 

    //shared preference ....
   
  }

// A Separate Function called from itemBuilder
Widget buildBody(BuildContext context, int index) {
  return new Center(child: Text("${wordsIndex[index]} : ${words[wordsIndex[index]]}"));
}

void displayErrorMessage(String message)
{

void setErrorMessage(error)
{
  print(error);
  setState(() {
     errorMessage =  error;
  });
}
 switch(message)
 {
   case "ERROR_INVALID_EMAIL": setErrorMessage("Email Invalide");
   break;
   case "ERROR_EMAIL_ALREADY_IN_USE": setErrorMessage("Email deja utilisé");
   break;
   case "listNotSend": setErrorMessage('L\'envoie de la liste à échoué');
   break;
   case "ERROR_WEAK_PASSWORD": setErrorMessage("Mot de passe trop faible");
   break;
   case "ERROR_USER_NOT_FOUND": setErrorMessage("Mot de passe ou email non reconnu(s) ");
   break;
   case "ERROR_WRONG_PASSWORD": setErrorMessage("Mot de passe ou email non reconnu(s) ");
   break;
   case "ERROR_NETWORK_REQUEST_FAILED": setErrorMessage("Problème réseaux, vérifié votre connection");
   break;
   default: setErrorMessage(message);
   //case pour mot de passe incorrecte 
 }

 
  error = true;    
  Navigator.pop(context);
  signPopUp();
}

void load()
{
  inLoad = true;
          Navigator.pop(context);
          signPopUp();
                          print("****");

}

void log() async 
{
  if(alreadyLog)
  {

     load();
      FirebaseUser user = await _auth.currentUser();
      setState(() {
       mail = user.email;
      });
      sendList();

  }
  else
  {
    if((mail.isNotEmpty) & (listName != null) )
    {
      if(alreadySign == true)
          {
            load();
            try
            {
              // check acount 
            final FirebaseUser user =  (await _auth.signInWithEmailAndPassword(
                      email: mail,
                      password: mdp,
                    )).user;
                    if(user != null)
                        {
                            final SharedPreferences prefs = await _prefs;
                            prefs.setBool("status", true);
                            setState(() {
                              alreadyLog = true;
                            });
                            print("*******log******");
                            print(user.email);
                            try{
                            sendList();
                            

                            }
                            catch(e)
                            {
                              print(e);
                            }
                          
                        }
            }
            catch(e)
            {
            
              displayErrorMessage(e.code);
              inLoad = false;
            }
              
          }
          else
          {
            try 
            {
                  if((mdp == cmdp ) & (mdp != null))
              {
                  load();
                  final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
                    email: mail,
                    password: mdp,
                  )).user;
                final SharedPreferences prefs = await _prefs;
                            prefs.setBool("status", true);
                            setState(() {
                              alreadyLog = true;
                            });
                  if(user != null)
                  {
                  sendList();
                  }
              }
              else
              {

                displayErrorMessage("Mot de passe non identique ");
              }
            }
            catch(e)
            {
                mdp = null;
                inLoad = false;
                displayErrorMessage(e.code);
            }

          }

    }
    else
    {
      displayErrorMessage("Vous n'avez pas indiquez votre mail");
    }
  }
}

void sendList() async 
{
  final FirebaseUser currentUser = await _auth.currentUser();

      try
      {
        await Firestore.instance.collection('lists').add({ 'mail': mail, "titre": listName, "list" : words });

          Navigator.of(context).pop();
                          Fluttertoast.showToast(
                          msg: "Votre liste à bien été enregistrer !",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            backgroundColor: Colors.blue[900],
                            textColor: Colors.white,
                            fontSize: 16.0);
                            inLoad =false;
      }
      catch(e)
      {
        print(e);
        inLoad =false;
      }




  
}


void signPopUp()
{
  showDialog(
        context: context,
        barrierDismissible: false,
        //context: _scaffoldKey.currentContext,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Center(child: Text("Titre de la liste")),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: 400,
              width: (MediaQuery.of(context).size.width - 20),
              child: SingleChildScrollView(
                child: 
                alreadyLog ? 

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: 
                [
                   SizedBox(
                      height: 20,
                    ),
                    Divider(color: Colors.grey),
                    SizedBox(
                      height: 20,
                    ),
                  TextField(
                        onChanged: (String value3){
                          setState(() {
                            listName = value3;
                          });
                          },
                            decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Titre',
                          ),
                        ),
                        inLoad ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            child: 
                          Center(child:  CupertinoActivityIndicator(),) ,):
                           Container(),
                ],):
               
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Divider(color: Colors.grey),
                    SizedBox(
                      height: 10,
                    ),
                     TextField(
                        onChanged: (String value3){
                          setState(() {
                            listName = value3;
                          });
                          },
                            decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Titre',
                          ),
                        ),
                        Container(height: 10,),

                        TextField(
                        onChanged: (String value3){
                          setState(() {
                            mail = value3;
                          });
                          },
                            decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                          ),
                        ),
                        Container(height: 10,),
                        TextField(
                        onChanged: (String value3){
                          setState(() {
                            mdp = value3;
                          });
                          },
                            obscureText: true,
                            decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '*****',
                          ),
                        ),
                        Container(height: 10,),
                         
                        alreadySign ?
                         FlatButton(
                            padding: EdgeInsets.only(left: 00.00),
                            child: Text(
                              'Pas de compte ?', 
                              style: TextStyle(color: Colors.red[900])
                              ),
                            onPressed: () {
                                          Navigator.of(context).pop();
                                          signPopUp();
                                          alreadySign = false;
                                          error = false;
                                           },
                          )
                        :Column(
                          children: [
                          TextField(
                        onChanged: (String value3){
                          setState(() {
                            cmdp = value3;
                          });
                          },
                            obscureText: true,
                            decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '******',
                          ),
                        ),
                        Container(height: 10,),
                      
                        FlatButton(
                            padding: EdgeInsets.only(left: 00.00),
                            child: Text(
                              'Déja un compte ?', 
                              style: TextStyle(color: Colors.red[900])
                              ),
                            onPressed: () {
                                          Navigator.of(context).pop();
                                          signPopUp();
                                          setState(() {
                                          alreadySign = true;
                                          error = false;
                                          });
                                                  
                                           },
                          ),                       
                        ],
                        ),
                         inLoad ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            child: 
                          Center(child:  CupertinoActivityIndicator(),) ,):
                           Container(),
                       
                     
                          error ? Center(child: 
                          Text("${errorMessage}", 
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                          )):
                        Container(),
                  ],
                ),


              ),
            ),
            actions: <Widget>[
              inLoad ? Container()
              : 
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                   Container(
                    width: MediaQuery.of(context).size.width * 0.20,
                    child: RaisedButton(
                      child: new Text(
                        'Créé',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blue,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      onPressed: () {
                        // envoie de la liste a firebase 
                        log();
                      },
                    ),
                  ),
                  Container(width: 10,),
                    Container(
                    width: MediaQuery.of(context).size.width * 0.20,
                    child: RaisedButton(
                      child: new Text(
                        'Retour',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blue,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        goodMp = true;
                        alreadySign = true;
                        error = false;
                      },
                    ),
                  ),
                  Container(width: 10,),
                 

                  
                ],
              ),
                
            
            ],
          );
        }); 
}

 @override
Widget displayWords()
{
  

    return Expanded(child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: wordsIndex.length,
            itemBuilder: (BuildContext context, int index) => buildBody(context, index)
            ));

}



    





 void showMenuSelection(String value) async 
 {
    if (value == "logout") {
    await FirebaseAuth.instance.signOut();
      final SharedPreferences prefs = await _prefs;
      prefs.setBool("status", false);
      setState(() {
        alreadyLog = false;
      });
      } 
      else
      {
           Navigator.push(context, MaterialPageRoute(builder: (context) =>   MyHomePage(title : "Revision") ));
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: back(context),
        title: Center(child: Text("Crée une nouvelle liste")),
          actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: showMenuSelection,
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              alreadyLog ? 
              const PopupMenuItem<String>(
                  value: 'logout', child: Text('Deconnexion')):
                  const PopupMenuItem<String>(
                  value: 'accueil', child: Text('Acceuil'))

                      ],
          )
        ],),
      body: 
      Container(child: 
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
           Container(height: 10,),
            RaisedButton(
            elevation: 10.0,
            color: Colors.blue,
            shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
            onPressed: () {
                          signPopUp();
                            },
            child: Text('Validé la liste')
          ), 
          Container(height: 10,),
          Container(height: 10,),
          TextField(
              onChanged: (String value){
              setState(() {
                word = value;
              });
               },
             controller: controllerWord, 
              decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Entrez un mot ',
            ),
          ),
          Container(height: 10,),
          TextField(
            onChanged: (String value1){
              setState(() {
                wordTraduction = value1;
              });
              },
             controller: controllerWordTraduction, 
              decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Entrez la traduction',
            ),
          ),
          Divider(height: 10,),
           RaisedButton(
            elevation: 5.0,
            color: Colors.blue,
            shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
            onPressed: () 
            {
              setState(() {
                
              });
              setState(() {
              words[word] = wordTraduction;
              wordsIndex.add(word);
              });
              controllerWord.clear();
              controllerWordTraduction.clear();
              Fluttertoast.showToast(
                msg: "Votre paires à été ajouté ",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                fontSize: 16.0);
            },
            child: Icon(Icons.add)
          ),
          Container(height: 50), 
          displayWords()
        ],
      ),
      ),
      );
    

  }





}