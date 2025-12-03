import 'package:flutter/material.dart';

class TagInputPage extends StatefulWidget {
  const TagInputPage({super.key});

  @override
  State<TagInputPage> createState() => _TagInputPageState();
}

class _TagInputPageState extends State<TagInputPage> {
  final _controller = TextEditingController();

  void _handleSubmit() {
    final text = _controller.text.trim();

    // must be exactly 4 digits
    final isValid = RegExp(r'^\d{4}$').hasMatch(text);

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 4-digit numeric tag')),
      );
      return;
    }

    // Navigate to home page with the 4-digit tag
    Navigator.pushNamed(
      context,
      '/homefeedpage',
      arguments: text, // 👈 pass "1055" as a String
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Type your 4-digit tag here',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    hintText: '1234',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  onSubmitted: (_) => _handleSubmit(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// class TagInputPage extends StatefulWidget {
//   const TagInputPage({super.key});

//   @override
//   State<TagInputPage> createState() => _TagInputPageState();
// }

// class _TagInputPageState extends State<TagInputPage> {
//   final _controller = TextEditingController(text: 'Value');

//   void _handleSubmit() {
//     final text = _controller.text.trim();

//     final number = double.tryParse(text);
//     if (number != null) {
//       Navigator.pushNamed(
//         context,
//         '/homefeedpage',
//         arguments: number,
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a numeric value')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             children: [
//               // This Expanded + Center puts the content in the middle of the screen
//               Expanded(
//                 child: Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       const Text(
//                         'Type your tag here',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       const SizedBox(height: 12),

//                       // Constrain width so it doesn't stretch too wide on tablets
//                       SizedBox(
//                         width: 320,
//                         child: TextField(
//                           controller: _controller,
//                           decoration: InputDecoration(
//                             hintText: 'Value',
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 12,
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           onSubmitted: (_) => _handleSubmit(),
//                         ),
//                       ),

//                       const SizedBox(height: 24),
//                       ElevatedButton(
//                         onPressed: _handleSubmit,
//                         child: const Text('Button'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
