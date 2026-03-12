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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE8F5E9),
              Colors.white,
              const Color(0xFFF1F8F4),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 48,
                      color: const Color(0xFF2E7D32),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Enter your tag',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your 4-character exhibit tag',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.text,
                      maxLength: 4,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 8,
                        color: Color(0xFF1B5E20),
                      ),
                      decoration: InputDecoration(
                        hintText: 'A1B2',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          letterSpacing: 8,
                        ),
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFF1F8F4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: const Color(0xFFE8F5E9),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: const Color(0xFF2E7D32),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                      ),
                      onSubmitted: (_) => _handleSubmit(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (_isNfcAvailable)
                      _isScanning
                          ? Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const CircularProgressIndicator(
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Hold your phone near the NFC tag...',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                OutlinedButton(
                                  onPressed: _cancelNfcScan,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF2E7D32),
                                    side: const BorderSide(
                                      color: Color(0xFF2E7D32),
                                      width: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _scanNfcTag,
                                icon: const Icon(Icons.nfc, size: 24),
                                label: const Text(
                                  'Scan NFC Tag',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF43A047),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'NFC not available on this device',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
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
