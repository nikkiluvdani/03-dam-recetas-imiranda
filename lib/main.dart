import 'package:flutter/material.dart';
import 'package:recetasapp/screens/splash_screen.dart';

void main() {
  runApp(const RecetasApp());
}

class RecetasApp extends StatelessWidget {
  const RecetasApp({super.key});

  // This widget is the root of your application.
@override
  Widget build(BuildContext context){
    //TODO imple,ment build
    return MaterialApp(
     title: "Recetas del Mayab",
     debugShowCheckedModeBanner: false,
     home: SplashScreen(),
    ); 
  }
}