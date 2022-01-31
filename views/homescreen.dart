import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart'as http ;
import 'package:weather/models/temperture.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String weather ='clear';
  String abbr='c';
  int temp =0;
  String location='city';
  int woeid=0;
  Future<void> fetchcity(String input)async{
    var url=Uri.parse('https://www.metaweather.com/api/location/search/?query=$input');
    var searchResult=await http.get(url);
    var responseBody=jsonDecode(searchResult.body)[0];
    setState(() {
      location=responseBody['title'];
      woeid=responseBody['woeid'];
    });
  }
  Future<void> fetchtemp()async{
    var url=Uri.parse("https://www.metaweather.com/api/location/$woeid/");
    var searchResult=await http.get(url);
    var responseBody=jsonDecode(searchResult.body)['consolidated_weather'][0];
    setState(() {
      weather=responseBody['weather_state_name'].replaceAll(' ','').toLowerCase();
      temp=responseBody['the_temp'].round();
      abbr=responseBody['weather_state_abbr'];
    });
  }
  Future<List<Temper>>fetchtemplist()async{
    List<Temper>list=[];
    var url=Uri.parse("https://www.metaweather.com/api/location/$woeid/");
    var searchResult=await http.get(url);
    var responseBody=jsonDecode(searchResult.body)['consolidated_weather'];
    for(var i in responseBody){
      Temper x=Temper(i['applicable_date'],i['weather_state_abbr'],i['max_temp'],i['min_temp']);
      list.add(x);
    }
    return list;
  }

  Future<void> onSubmittedText(String input)async{
    await fetchcity(input);
    await fetchtemp();
  }
    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      home:Container(
        decoration:BoxDecoration(
          image:DecorationImage(
              image:AssetImage('assets/images/$weather.png'),
            fit:BoxFit.cover,
          ) ,
        ),
        child:Scaffold(
          backgroundColor:Colors.transparent,
          body:SingleChildScrollView(
            child: Column(
              crossAxisAlignment:CrossAxisAlignment.center,
              mainAxisAlignment:MainAxisAlignment.spaceEvenly,
              // the first column for icon+temp+location
              children:[
                Column(
                  children:[
                    Center(
                      child: Image.network('https://www.metaweather.com/static/img/weather/png/$abbr.png',
                        width:100,

                      ),
                    ),
                    Text('$temp ℃',style:TextStyle(
                      color:Colors.white,
                      fontSize:50,
                    ),
                      textAlign:TextAlign.center,
                    ),
                    Text('$location',style:TextStyle(
                      color:Colors.white,
                      fontSize:50,
                    ),
                      textAlign:TextAlign.center,
                    ),
                  ],
                ),
                //the second column for text field+list view
                Column(
                  crossAxisAlignment:CrossAxisAlignment.start,
                  children:[
                    Container(
                      width:MediaQuery.of(context).size.width/1.1,
                      child: TextField(
                        onSubmitted:(String input){
                            onSubmittedText(input);
                        },
                        style:TextStyle(
                          color:Colors.white,fontSize:25,
                        ),
                        decoration:InputDecoration(
                          hintText:'Search location...',
                          hintStyle:TextStyle(
                            color:Colors.white,fontSize:25,
                          ),
                          prefixIcon:Icon(Icons.search,color:Colors.white,size:30,) ,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical:20,horizontal:5,),
                      child: Container(
                        height:170,
                          child:FutureBuilder(
                            future:fetchtemplist(),
                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                              if(snapshot.hasData){
                            return ListView.builder(
                                      itemCount:snapshot.data.length,
                                       scrollDirection:Axis.horizontal,
                                           shrinkWrap:true,
                                         itemBuilder: (BuildContext context, int index) {
                                                    return Card(
      color:Colors.transparent,
      shape:RoundedRectangleBorder(
      borderRadius:BorderRadius.circular(25),
      ),
      child:Container(
      height:170,
      width:120,
      child: Column(
      crossAxisAlignment:CrossAxisAlignment.center,
      mainAxisAlignment:MainAxisAlignment.spaceEvenly,
      children:[
      Text('Date:${snapshot.data[index].applicable_date}',
      style:TextStyle(
      color:Colors.white,
      fontSize:12,
      ),
      textAlign:TextAlign.center,
      ),
      Center(
      child: Image.network('https://www.metaweather.com/static/img/weather/png/${snapshot.data[index].weather_state_abbr}.png',
      width:30,
      height:30,

      ),
      ),
      Text('$location',
      style:TextStyle(
      color:Colors.white,
      fontSize:15,
      ),
      textAlign:TextAlign.center,
      ),
      Text('Min:${snapshot.data[index].min_temp.round()}',
      style:TextStyle(
      color:Colors.white,
      fontSize:15,
      ),
      textAlign:TextAlign.center,
      ),
      Text('Max:${snapshot.data[index].max_temp.round()}',
      style:TextStyle(
      color:Colors.white,
      fontSize:15,
      ),
      textAlign:TextAlign.center,
      ),


      ],
      ),
      ),

      );
      },);
                                    }
                              else{
                                return Center(child:Text(''),);
                              }
                                 },
                              ),
                          )),
                  ],
                ),


              ],
            ),
          ),

        ),
      ),


    );
  }
}
