
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class customBackWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IconButton(
        onPressed: (){
          Navigator.pop(context);
        },
        icon: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: EdgeInsets.all(6.0),
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        )
    );
  }
}

class customFavwidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IconButton(
        onPressed: (){
          //Navigator.pop(context);
        },
        icon: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: EdgeInsets.all(6.0),
          child: Icon(
            Icons.favorite,
            color: Colors.black,
          ),
        )
    );
  }
}

class customBackWidget2 extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IconButton(
        onPressed: (){
          Navigator.pop(context);
        },
        icon: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
          ),
          padding: EdgeInsets.all(6.0),
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        )
    );
  }
}