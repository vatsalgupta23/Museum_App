import 'package:flutter/material.dart';
import 'package:myapp/pages/home_page.dart';
import 'package:myapp/pages/profile_page.dart';
import 'package:myapp/pages/settings_page.dart';


// class FirstPage extends StatefulWidget {
//   FirstPage({super.key});

//   @override
//   State<FirstPage> createState() => _FirstPageState();
// }

// class _FirstPageState extends State<FirstPage> {
//   int _selectedIndex = 0;

//   void _navigateBottomBar(int index){
//     setState(() {
//       _selectedIndex = index;
//     });

//   }

//   final List _pages = [

//     HomePage(),

//     // ProfilePage(), 
//     ProfilePage(),
//     SettingsPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("First Page"),
//         centerTitle: true,
//         backgroundColor: Colors.purple,
//       ),
//       body: _pages[_selectedIndex],

//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _navigateBottomBar,
//         items:[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//       ),
//     );
      
         
       
        
  
//   }
// }


class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3), // pushes content downward
              // Top section (centered)
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: 80),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome to MSU Museum App',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/taginputpage');
                      },
                      child: const Text('Start'),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3), // space between top & bottom sections
              // Bottom section (stays near bottom)
              Column(
                children: [
                  Image.asset('assets/imls_logo_2c.jpg', height: 60),
                  const SizedBox(height: 8),
                  const Text(
                    'This project was made possible in part by the Institute of Museum and Library Services (grant# ME-255578-OMS-24).',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 12), // small bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
