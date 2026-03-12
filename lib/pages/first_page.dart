import 'package:flutter/material.dart';


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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE8F5E9), // Light green
              Colors.white,
              const Color(0xFFF1F8F4),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Top section (centered)
                Center(
                  child: Column(
                    children: [
                      // Logo with subtle shadow
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset('assets/logo.png', height: 80),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Welcome to',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'MSU Museum App',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Explore exhibits with interactive audio guides',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/taginputpage');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF2E7D32).withOpacity(0.4),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),
                // Bottom section (stays near bottom)
                Column(
                  children: [
                    Image.asset('assets/imls_logo_2c.jpg', height: 50),
                    const SizedBox(height: 12),
                    const Text(
                      'This project was made possible in part by the Institute of Museum and Library Services (grant# ME-255578-OMS-24).',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF757575),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
