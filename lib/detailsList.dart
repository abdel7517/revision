import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:convert';
import 'package:revisionApp/home.dart';
import 'package:revisionApp/main.dart';




class DetailsList extends StatefulWidget
{
  DetailsList(this.page);
  final String page;

  @override
  DetailsListState createState() => DetailsListState(page);
}

class DetailsListState extends State<DetailsList>
{
  DetailsListState(this.page);
  final String page;
  Map list = {};
  Map listQuiz = {};
  bool launchQuiz = false;
  bool quizFinish = false;
  int numberQuestion = 0;
  bool getList = false;
  String actualQuestion;
  String actualAnswer;
  int resultQuiz= 0;
  String key;

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    
  }
 


 Widget _fireSearch() {
  return new StreamBuilder(
    stream: Firestore.instance.collection("lists").where("titre", isEqualTo: page).snapshots(),
    builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasData) {
          list = snapshot.data.documents[0]["list"];
             if(list.length > 0)
              {
                getList = true;
              }
     
      
    
       return new ListView.builder(
  itemCount: snapshot.data.documents[0]["list"].length,
  itemBuilder: (BuildContext context, int index) {
    String key = snapshot.data.documents[0]["list"].keys.elementAt(index);
    return new Column(
      children: <Widget>[
        new ListTile(
          title: new Text("$key"),
          subtitle: new Text("${snapshot.data.documents[0]["list"][key]}"),
        ),
        new Divider(
          height: 2.0,
        ),
      ],
    );
  },
);
      


       
      }

      else
      {
        return Text("RIEN");
      }
   
    },);
 }

void displayResultQuiz()
{
    showDialog(context: context,
     barrierDismissible: false,
     builder: (context){
       return AlertDialog(
         contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Center(child: Text("Résultat")),
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: 100,
              width: (MediaQuery.of(context).size.width - 20),
              child: 
              Column(
              children: [
                Center(child: Text("Votre résultat : ${resultQuiz}/${list.length} ")),
              ],), 
            )  ,             
              actions: [
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>   MyHomePage(title : "Revision") ));

                        
                      },
                    ),
                  ),
              ],
       );


     }
     );
}
 void checkAnswer(String key)
 {
   print("********");
  String  goodAnswer = listQuiz[key];
     print("GA"+listQuiz[key].toString());
  print("response"+ actualAnswer.toString());

   if(goodAnswer == actualAnswer)
   {
     setState(() {
     resultQuiz ++;
     });
   }
   else{
                  print("result null" +resultQuiz.toString());

     return null;

   }
        print("result" +resultQuiz.toString());

 }

bool firstQuestion = true;
bool lastQuestion = false;



void getQuestion()
{
  int max= listQuiz.length;


  // it's not the first click for launched the quiz and not the last question
  if(max != 1 && firstQuestion == false)
{
        checkAnswer(key);

}

// it's the last question 
  if(max == 1)
  {
       key = listQuiz.keys.first;
           checkAnswer(key);
      setState(() {
        actualQuestion = key;
        quizFinish = true;
          });
  }
  else
  {
    setState(() {
          listQuiz.remove(key);
          // max -1 because the index must be less than list.length
        int index = Random().nextInt(max -1);
        // get the question to display
        key = listQuiz.keys.elementAt(index);
        actualQuestion = key;
        numberQuestion ++;

    });
  
  }


  if(firstQuestion == true)
  {
    
    firstQuestion = false;

  }

    if(quizFinish == true )
  {
    displayResultQuiz();
  }


    print("laaaaaaa"+max.toString());


}
  
 

@override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Liste "+ page)),
      body: launchQuiz ?
         Column(children: 
        [
          Container(height: 40,),
          Center(child: Text("Qestion ${numberQuestion}/${list.length}")),
          Container(height: 20,),
          Center(child: Text("Donnez la traduction de : ${actualQuestion} ")),
          Container(height: 30,),
          Container(
            margin:    EdgeInsets.only(left: MediaQuery.of(context).size.width/5, right: MediaQuery.of(context).size.width/5),
            child:   TextField(
                        onChanged: (String value){
                          setState(() {
                            actualAnswer = value;
                          });
                          },
                            decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Votre réponse',
                          ),
                        ),),
                            
          Container(height: 30,),
          FlatButton(onPressed: ()=> getQuestion(), child: Text("valider" ),color: Colors.blue)




        ],)
        :
          Column(children: [
          FlatButton(
            onPressed: (){ setState(() {
            launchQuiz = true; 
            listQuiz = json.decode(json.encode(list));
          });  
          getQuestion();
}, 
            clipBehavior: Clip.none,
            autofocus: true,
            child: Text("Lancez un quiz !"), color: Colors.blue,),
          Expanded(child:   _fireSearch() )
          ],)
     
        
        );
  }

}