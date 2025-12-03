import 'package:flutter/material.dart';
import 'package:myapp/pages/first_page.dart';
import 'package:myapp/pages/home_page.dart';

import 'package:myapp/pages/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
      routes: {
        '/firstpage': (context) =>  const WelcomePage(),
        '/taginputpage': (context) => const TagInputPage(),
        '/homefeedpage': (context) => const HomeFeedPage(),
      }
    );

          
          
     
  }
}

