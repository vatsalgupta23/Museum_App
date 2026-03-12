import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  final _heroController = PageController(viewportFraction: 0.9);

  // --- WebSocket + audio ---
  WebSocketChannel? _ws;
  late final AudioPlayer _player;
  String? _nowPlayingTitle;
  bool _wsConnected = false;

  String? _userShortId;

  // Track if audio is currently playing
  bool _isPlaying = false;

  // Map to cache preloaded audio sources with actual loaded data
  final Map<String, AudioSource> _preloadedAudio = {};
  
  // Track which audio files have been fully loaded
  final Set<String> _fullyLoadedTitles = {};

  // Map exhibit title -> audio asset (change filenames to yours)
  final Map<String, String> _audioForTitle = const {
    'Skeletons': 'assets/audio/Skeletons2.mp3',
    'Skulls': 'assets/audio/Skulls2.mp3',
    'Tundra': 'assets/audio/Tundra.mp3',
    'Boreal forest': 'assets/audio/Boreal.mp3',
    'Alpine': 'assets/audio/Alpine.mp3',
    'Deciduous': 'assets/audio/Eastern.mp3',
    'Grassland': 'assets/audio/Grassland.mp3',
    'Desert': 'assets/audio/Desert.mp3',
    'Rainforest': 'assets/audio/Rainforest.mp3',
    'Habitat Hall': 'assets/audio/HabitatHall.mp3', // example; pick your file
    'Casts': 'assets/audio/Casts.mp3',
  };

  // Fake data (add descriptions)
  final List<_HeroItem> heroItems = const [
    _HeroItem(
      title: 'Habitat Hall',
      imageUrl: 'assets/Dioramas.jpg',
      description:
          '''Here you see seven of the major habitats of North and Central America. Different habitats are home to different animals. When habitats are threatened, animal diversity is threatened. The dioramas focus on members of the deer family and pronghorn antelope. The different sizes and forms of these animals reflect adaptation to their environments. What differences can you see? ''',
    ),
  ];

  final List<_CardItem> cardItems = const [
    _CardItem(
      tag: 'Exhibit',
      title: 'Skeletons',
      imageUrl: 'assets/Dinosaurs_platform.jpg',
      description:
          '''Dinosaurs dominated the Earth for nearly 200 million years, during the Mesozoic Era. During that time a tremendous diversity of dinosaurs evolved and lived in many different environments. Their fossilized remains have been found on every continent, from Alaska to Antarctica. Some were harmless herbivores, while others were fearsome predators. A few were no bigger than a chicken; the largest were as tall as a five-story building. Although dinosaurs did go extinct 65 million years ago, most paleontologists now agree that birds are their direct descendants.  ''',
    ),
    _CardItem(
      tag: 'Exhibit',
      title: 'Tundra',
      imageUrl: 'assets/Tundra.jpg',
      description: '''Cold and Delicate 

The arctic tundra is a cold, dry region. Winters are long, dark and bitterly cold, with strong, icy winds. The low annual precipitation occurs mostly as snow which covers the tundra in winter. 

 

The tundra is noted for its permafrost - soil which is frozen except for the top few inches which thaw during the short summer. The ground is carpeted by a thick, spongy mat of low growing plants such as lichens, sedges, mosses, and shrubs.  

 

The tundra is delicate due to the shallow soil and the slow growth rate of its plants. Tire ruts, like the ones on the left, may last for decades.  ''',
    ),
    _CardItem(
      tag: 'Exhibit',
      title: 'Boreal forest',
      imageUrl: 'assets/Boreal_Wong.jpg',
      description:
          '''Boreal forests are found in northern regions, just south of the tundra. Winters are cold and long, but less severe than on the tundra. Summers are short and mild. Boreal forests are dominated by a few species of coniferous, or evergreen trees such as fir, spruce, cedar, and pine. Some broadleaf trees, such as birch and alder, are hardly enough to survive the short growing season. ''',
    ),
    _CardItem(
      tag: 'Exhibit',
      title: 'Alpine',
      imageUrl: 'assets/Alpine_Wong.jpg',
      description:
          '''The Rocky Mountains are high and rugged, rising over 14,000 feet. Conditions on the mountain tops resemble the tundra with harsh climate, thin, rocky soil, and sparse vegetation. Farther down the mountain side, the climate is less severe and there are meadows and coniferous forests. ''',
    ),
    _CardItem(
      tag: 'Exhibit',
      title: 'Eastern Deciduous',
      imageUrl: 'assets/Deciduous.jpg',
      description:
          '''Deciduous forests are found throughout the Eastern United States. Deciduous forests are made up of trees like these beech and maples, which lose their leaves in the winter. Unlike the rainforests, relatively few species of trees dominate deciduous woodlands. 

 

Temperatures change significantly during the four seasons. A warm growing season during the long summer, contrasts with winters that are cold but not too severe. Precipitation is abundant and fairly constant throughout the year. ''',
    ),
    _CardItem(
      tag: 'Exhibit',
      title: 'Grassland',
      imageUrl: 'assets/Grassland_Wong.jpg',
      description:
          '''Grasslands, also known as prairies, pampas, and steppes, receive enough rain to support grasses, but not enough for forests. Nearly constant winds keep the habitat even drier. Frequent fires and heavy grazing also suppress the growth of woody plants. Grassland soil is rich and fertile.  ''',
    ),
    _CardItem(
      tag: 'Exhibit',
      title: 'Desert',
      imageUrl: 'assets/Desert_Wong.jpg',
      description:
          ''' In the cool of the morning, a female mule deer makes its way through the desert. Many plants and animals found here have special adaptations that allow them to conserve water and to avoid the heat. Many animals are active at night, spending the days in relatively cool burrows or in other sheltered locations. ''',
    ),
    _CardItem(
      tag: 'Exhibit',
      title: 'Tropical Rainforest',
      imageUrl: 'assets/Rainforest_Wong.jpg',
      description:
          '''Truly a Jungle - The small deer finding its way through the dense vegetation is a mazama or brocket deer. In the tropics, mammals are often small, while insects and reptiles are frequently large. 
Tropical rain forests are home to the greatest diversity of animal life on earth. The richness of this diversity can be seen in this Mexican rain forest, where you can see a spider monkey, parrot, termite nest, anteater, and many other plants and animals. ''',
    ),
    _CardItem(
      tag: 'Exhibit',
      title: 'Casts',
      imageUrl: 'assets/Dinosaurs_platform.jpg',
      description:
          '''Truly a Jungle - The small deer finding its way through the dense vegetation is a mazama or brocket deer. In the tropics, mammals are often small, while insects and reptiles are frequently large. 
Tropical rain forests are home to the greatest diversity of animal life on earth. The richness of this diversity can be seen in this Mexican rain forest, where you can see a spider monkey, parrot, termite nest, anteater, and many other plants and animals. ''',
    ),

  ];

  @override
  void initState() {
    super.initState();
    _validateAudioMapping();
    _initializeAudioSession();
    _initializeAudioPlayer();
    _preloadAudioFiles();
    _connectWebSocket();
  }

  // Initialize audio session for screen reader compatibility
  Future<void> _initializeAudioSession() async {
    try {
      final session = await AudioSession.instance;
      
      // Configure audio session to allow ducking of other audio (like screen readers)
      // instead of interrupting them completely
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage.assistanceSonification,
            flags: AndroidAudioFlags.audibilityEnforced,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
          androidWillPauseWhenDucked: false,
        ),
      );
      
      // Handle interruptions (like phone calls)
      session.interruptionEventStream.listen((event) {
        debugPrint('🔊 Audio interruption: ${event.type}');
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              // Another app needs audio focus, lower our volume
              _player.setVolume(0.3);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              // Pause our audio
              _player.pause();
              if (mounted) {
                setState(() => _isPlaying = false);
              }
              break;
          }
        } else {
          // Interruption ended, restore
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
              // Don't auto-resume, let user control
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });
      
      // Handle becoming noisy (headphones unplugged)
      session.becomingNoisyEventStream.listen((_) {
        debugPrint('🎧 Audio becoming noisy - pausing');
        _player.pause();
        if (mounted) {
          setState(() => _isPlaying = false);
        }
      });
      
      debugPrint('✅ Audio session configured for screen reader compatibility');
    } catch (e) {
      debugPrint('❌ Error configuring audio session: $e');
    }
  }

  // Validate audio configuration
  void _validateAudioMapping() {
    debugPrint('🔍 Audio configuration:');
    debugPrint('📋 Available audio titles (${_audioForTitle.length}):');
    for (final title in _audioForTitle.keys) {
      debugPrint('   • "$title"');
    }
    
    // Optional: check if card titles match audio titles
    final cardTitles = cardItems.map((e) => e.title).toSet();
    final audioTitles = _audioForTitle.keys.toSet();
    
    final cardsWithoutAudio = cardTitles.difference(audioTitles);
    if (cardsWithoutAudio.isNotEmpty) {
      debugPrint('⚠️ Cards without audio: $cardsWithoutAudio');
    }
    
    debugPrint('✅ Server should send these exact titles in WebSocket messages');
  }

  // Initialize audio player with low latency settings
  void _initializeAudioPlayer() {
    _player = AudioPlayer(
      // Configure for low latency playback
      audioPipeline: AudioPipeline(
        androidAudioEffects: [],
      ),
    );
    
    // Set volume to ready state for faster response
    _player.setVolume(1.0);
  }

  // Preload all audio files with actual data loading for instant playback
  Future<void> _preloadAudioFiles() async {
    debugPrint('Starting audio preload...');
    final loadTasks = <Future>[];
    
    for (final entry in _audioForTitle.entries) {
      final title = entry.key;
      final path = entry.value;
      
      // Create audio source and store it
      final source = AudioSource.asset(path);
      _preloadedAudio[title] = source;
      
      // Load audio data in background
      final loadTask = _loadAudioData(title, source);
      loadTasks.add(loadTask);
    }
    
    // Wait for all audio files to load
    await Future.wait(loadTasks);
    debugPrint('✓ Preloaded ${_fullyLoadedTitles.length}/${_audioForTitle.length} audio files');
  }
  
  // Load actual audio data into memory for a specific source
  Future<void> _loadAudioData(String title, AudioSource source) async {
    try {
      // Create a temporary player to preload the audio data
      final tempPlayer = AudioPlayer();
      await tempPlayer.setAudioSource(source, preload: true);
      
      // Seek to ensure data is buffered
      await tempPlayer.seek(Duration.zero);
      
      // Mark as fully loaded
      _fullyLoadedTitles.add(title);
      
      // Dispose the temporary player
      await tempPlayer.dispose();
      
      debugPrint('  ✓ Loaded: $title');
    } catch (e) {
      debugPrint('  ✗ Failed to load $title: $e');
    }
  }

  void _connectWebSocket() {
    final uri = Uri.parse('wss://museum-server-u9st.onrender.com');
    _ws = WebSocketChannel.connect(uri);

    _ws!.stream.listen(
      (data) async {
        try {
          final msg = jsonDecode(data as String) as Map<String, dynamic>;
          final type = (msg['type'] ?? '').toString();
          final title = (msg['title'] ?? '').toString();
          final shortId = (msg['shortId'] ?? '').toString();

          debugPrint('📡 WebSocket received: type="$type", title="$title", shortId="$shortId"');
          debugPrint('   Current state: _nowPlayingTitle="$_nowPlayingTitle", _isPlaying=$_isPlaying');

          if (_userShortId != null && shortId.isNotEmpty && shortId != _userShortId) {
            debugPrint('   ⏭️ Skipped (not for this user: $_userShortId)');
            return;
          }

          if (type == 'WELCOME') {
            if (mounted) setState(() => _wsConnected = true);
            return;
          }

          if (type == 'PLAY_EXHIBIT' && title.isNotEmpty) {
            debugPrint('📻 Received play command for: "$title"');
            
            // Use preloaded audio source for near-instant playback
            final audioSource = _preloadedAudio[title];
            if (audioSource != null) {
              // Stop current playback first if something is playing
              final wasPlaying = _isPlaying;
              if (wasPlaying) {
                await _player.stop();
              }
              
              // UPDATE STATE (before playing so UI updates immediately)
              if (mounted) {
                setState(() {
                  _nowPlayingTitle = title;
                  _isPlaying = true;
                });
                debugPrint('🔄 State updated: _nowPlayingTitle="$_nowPlayingTitle"');
              }
              
              // Activate audio session for proper focus management
              try {
                final session = await AudioSession.instance;
                if (!session.isActive) {
                  await session.setActive(true);
                  debugPrint('🔊 Audio session activated');
                }
              } catch (e) {
                debugPrint('⚠️ Could not activate audio session: $e');
              }
              
              // Set and play audio
              await _player.setAudioSource(audioSource, preload: true);
              await _player.play();
              
              final loadStatus = _fullyLoadedTitles.contains(title) ? '⚡' : '⏳';
              debugPrint('✅ Audio playing. Player status: playing=$_isPlaying, title in state: "$_nowPlayingTitle"');
              
              // Show notification AFTER state is updated
              if (mounted) {
                // Capture the current state value to ensure we show what's actually in state
                final displayTitle = _nowPlayingTitle ?? title;
                debugPrint('📢 Showing notification for: "$displayTitle"');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$loadStatus Playing: $displayTitle'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            } else {
              debugPrint('❌ ERROR: No audio found for "$title"');
              debugPrint('   Available titles: ${_audioForTitle.keys.toList()}');
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('⚠️ Audio not found: $title'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          } else if (type == 'STOP_EXHIBIT' && title.isNotEmpty) {
            await _player.stop();
            if (mounted) {
              setState(() {
                _nowPlayingTitle = null;
                _isPlaying = false;
              });
            }
          }
        } catch (e) {
          debugPrint('WS parse error: $e');
        }
      },
      onDone: () => debugPrint('WebSocket closed'),
      onError: (err) => debugPrint('WebSocket error: $err'),
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    _heroController.dispose();
    _ws?.sink.close(ws_status.goingAway);
    _player.dispose();
    // Deactivate audio session
    AudioSession.instance.then((session) => session.setActive(false));
    super.dispose();
  }

  void _showItemSheet({
    required BuildContext context,
    required String title,
    required String description,
    required String imageUrl,
    String? tag,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.asset(imageUrl, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (tag != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Audio player UI shown below the card slider
  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2E7D32),
            const Color(0xFF43A047),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.audiotrack,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Now Playing',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _nowPlayingTitle ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                color: Colors.white,
                iconSize: 48,
                onPressed: () async {
                  if (_nowPlayingTitle == null) return;
                  final audioSource = _preloadedAudio[_nowPlayingTitle!];
                  if (audioSource == null) return;

                  if (_isPlaying) {
                    await _player.pause();
                    setState(() => _isPlaying = false);
                  } else {
                    // If not already loaded, set the source first
                    if (_player.audioSource != audioSource) {
                      await _player.setAudioSource(audioSource, preload: true);
                    }
                    await _player.play();
                    setState(() => _isPlaying = true);
                  }
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.stop_circle),
                color: Colors.white,
                iconSize: 36,
                onPressed: () async {
                  await _player.stop();
                  setState(() {
                    _nowPlayingTitle = null;
                    _isPlaying = false;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'MSU Museum',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE8F5E9),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search exhibits...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color(0xFF2E7D32),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: const Color(0xFFE8F5E9),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: const Color(0xFF2E7D32),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // WS status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _wsConnected
                    ? const Color(0xFFE8F5E9)
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _wsConnected
                      ? const Color(0xFF2E7D32)
                      : Colors.red.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _wsConnected ? Icons.check_circle : Icons.error_outline,
                    size: 20,
                    color: _wsConnected
                        ? const Color(0xFF2E7D32)
                        : Colors.red.shade700,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _wsConnected ? 'Connected to server' : 'Disconnected',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _wsConnected
                          ? const Color(0xFF1B5E20)
                          : Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Featured Section Header
            const Text(
              'Featured',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 16),

            // Slider #1
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _heroController,
                itemCount: heroItems.length,
                itemBuilder: (context, index) {
                  final item = heroItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap:
                          () => _showItemSheet(
                            context: context,
                            title: item.title,
                            description: item.description,
                            imageUrl: item.imageUrl,
                          ),
                      child: _HeroCard(item: item),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            Row(
              children: const [
                Text(
                  'Museum Exhibits',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF2E7D32),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Slider #2
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cardItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final item = cardItems[index];
                  final isActive = item.title == _nowPlayingTitle;
                  return GestureDetector(
                    onTap:
                        () => _showItemSheet(
                          context: context,
                          title: item.title,
                          description: item.description,
                          imageUrl: item.imageUrl,
                          tag: item.tag,
                        ),
                    child: _SmallItemCard(
                      item: item,
                      isActive: isActive,
                    ),
                  );
                },
              ),
            ),

            // NEW: audio player under the cards
            if (_nowPlayingTitle != null) ...[
              const SizedBox(height: 16),
              _buildAudioPlayer(),
            ],

            const SizedBox(height: 24),

            // IMLS text at the very bottom
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'The views, findings, conclusions or recommendations expressed in this application '
                'do not necessarily represent those of the Institute of Museum and Library Services.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only read once
    if (_userShortId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is String) {
        // should already be 4 digits
        _userShortId = args;
      } else if (args is num) {
        // if you ever pass a number, make it 4 digits
        _userShortId = args.toInt().toString().padLeft(4, '0');
      }

      debugPrint('User shortId: $_userShortId');
    }
  }


}

/* --- Models --- */
class _HeroItem {
  final String title;
  final String imageUrl;
  final String description;
  const _HeroItem({
    required this.title,
    required this.imageUrl,
    required this.description,
  });
}

class _CardItem {
  final String tag;
  final String title;
  final String imageUrl;
  final String description;
  const _CardItem({
    required this.tag,
    required this.title,
    required this.imageUrl,
    required this.description,
  });
}

/* --- Cards --- */

class _HeroCard extends StatelessWidget {
  final _HeroItem item;
  const _HeroCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(item.imageUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Tap to explore',
                      style: TextStyle(
                        color: Color(0xFF1B5E20),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// UPDATED: supports isActive highlighting (Option A)
class _SmallItemCard extends StatelessWidget {
  final _CardItem item;
  final bool isActive;

  const _SmallItemCard({required this.item, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF2E7D32) : const Color(0xFFE8F5E9),
          width: isActive ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? const Color(0xFF2E7D32).withOpacity(0.2)
                : Colors.black.withOpacity(0.06),
            blurRadius: isActive ? 12 : 8,
            offset: Offset(0, isActive ? 6 : 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(item.imageUrl, fit: BoxFit.cover),
                ),
              ),
              if (isActive)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.volume_up,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Playing',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.tag,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isActive ? const Color(0xFF1B5E20) : Colors.black87,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
