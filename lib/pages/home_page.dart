import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class TagInputPage extends StatefulWidget {
  const TagInputPage({super.key});

  @override
  State<TagInputPage> createState() => _TagInputPageState();
}

class _TagInputPageState extends State<TagInputPage> {
  final _controller = TextEditingController();
  bool _isNfcAvailable = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  Future<void> _checkNfcAvailability() async {
    final isAvailable = await NfcManager.instance.isAvailable();
    if (mounted) {
      setState(() {
        _isNfcAvailable = isAvailable;
      });
    }
  }

  void _handleSubmit() {
    final text = _controller.text.trim().toUpperCase();

    // must be exactly 4 alphanumeric characters (letters and/or numbers)
    final isValid = RegExp(r'^[A-Z0-9]{4}$').hasMatch(text);

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 4-character alphanumeric tag')),
      );
      return;
    }

    // Navigate to home page with the 4-character tag
    Navigator.pushNamed(
      context,
      '/homefeedpage',
      arguments: text, // pass tag as uppercase String
    );
  }

  Future<void> _scanNfcTag() async {
    if (!_isNfcAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NFC is not available on this device')),
      );
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          // Try to read NDEF records
          final ndef = Ndef.from(tag);
          if (ndef != null && ndef.cachedMessage != null) {
            final records = ndef.cachedMessage!.records;
            for (var record in records) {
              // Check if it's a text record
              if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown) {
                try {
                  final payload = record.payload;
                  // Skip the first byte (language code length) and language code
                  final languageCodeLength = payload[0];
                  final textBytes = payload.sublist(1 + languageCodeLength);
                  final text = String.fromCharCodes(textBytes).trim().toUpperCase();
                  
                  // Validate the text (4 alphanumeric characters)
                  if (RegExp(r'^[A-Z0-9]{4}$').hasMatch(text)) {
                    await NfcManager.instance.stopSession();
                    if (mounted) {
                      _controller.text = text;
                      setState(() {
                        _isScanning = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tag read successfully: $text')),
                      );
                      // Auto-submit after successful read
                      _handleSubmit();
                    }
                    return;
                  }
                } catch (e) {
                  debugPrint('Error parsing NFC record: $e');
                }
              }
            }
          }
          
          // If we get here, no valid tag was found
          await NfcManager.instance.stopSession(errorMessage: 'Invalid tag format');
          if (mounted) {
            setState(() {
              _isScanning = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No valid 4-character tag found on NFC')),
            );
          }
        },
        onError: (error) async {
          debugPrint('NFC error: $error');
          if (mounted) {
            setState(() {
              _isScanning = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('NFC Error: ${error.message}')),
            );
          }
        },
      );
    } catch (e) {
      debugPrint('Error starting NFC session: $e');
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _cancelNfcScan() {
    NfcManager.instance.stopSession();
    setState(() {
      _isScanning = false;
    });
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
                  'Enter your 4-character tag',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.text,
                  maxLength: 4,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'A1B2',
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
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                const Text(
                  'Or scan an NFC tag',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                if (_isNfcAvailable)
                  _isScanning
                      ? Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            const Text(
                              'Hold your phone near the NFC tag...',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _cancelNfcScan,
                              child: const Text('Cancel'),
                            ),
                          ],
                        )
                      : ElevatedButton.icon(
                          onPressed: _scanNfcTag,
                          icon: const Icon(Icons.nfc),
                          label: const Text('Scan NFC Tag'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        )
                else
                  const Text(
                    'NFC not available on this device',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_isScanning) {
      NfcManager.instance.stopSession();
    }
    super.dispose();
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
