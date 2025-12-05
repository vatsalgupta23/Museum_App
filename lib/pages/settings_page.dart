import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:just_audio/just_audio.dart';
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
  final AudioPlayer _player = AudioPlayer();
  String? _nowPlayingTitle;
  bool _wsConnected = false;

  String? _userShortId;

  // NEW: track if audio is currently playing
  bool _isPlaying = false;

  // Map exhibit title -> audio asset (change filenames to yours)
  final Map<String, String> _audioForTitle = const {
    'Skeletons': 'assets/audio/Skeletons2.mp3',
    'Skulls': 'assets/audio/Skulls2.mp3',
    'Tundra': 'assets/audio/Tundra.mp3',
    'Boreal forest': 'assets/audio/Boreal.mp3',
    'Alpine': 'assets/audio/Alpine.mp3',
    'Eastern Deciduous': 'assets/audio/Eastern.mp3',
    'Grassland': 'assets/audio/Grassland.mp3',
    'Desert': 'assets/audio/Desert.mp3',
    'Tropical Rainforest': 'assets/audio/Rainforest.mp3',
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
    _connectWebSocket();
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

          if (_userShortId != null && shortId.isNotEmpty && shortId != _userShortId) {
            // Not for this user
            return;
          }

          if (type == 'WELCOME') {
            if (mounted) setState(() => _wsConnected = true);
            return;
          }

          if (type == 'PLAY_EXHIBIT' && title.isNotEmpty) {
            final assetPath = _audioForTitle[title];
            if (assetPath != null) {
              await _player.setAsset(assetPath);
              await _player.play();
              if (mounted) {
                setState(() {
                  _nowPlayingTitle = title;
                  _isPlaying = true;
                });
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Playing: $title')));
              }
            } else {
              debugPrint('No audio mapped for "$title"');
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.asset(imageUrl, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (tag != null) ...[
                      Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // NEW: simple audio player UI shown below the card slider
  Widget _buildAudioPlayer() {
    if (_nowPlayingTitle == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.volume_up),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nowPlayingTitle ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Audio description',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () async {
              if (_nowPlayingTitle == null) return;
              final assetPath = _audioForTitle[_nowPlayingTitle!];
              if (assetPath == null) return;

              if (_isPlaying) {
                await _player.pause();
                setState(() => _isPlaying = false);
              } else {
                // ensure the correct asset is loaded before play
                await _player.setAsset(assetPath);
                await _player.play();
                setState(() => _isPlaying = true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.stop),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 255, 239),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // WS status
            Row(
              children: [
                Icon(
                  _wsConnected ? Icons.cloud_done : Icons.cloud_off,
                  size: 18,
                  color: _wsConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(_wsConnected ? 'Connected to server' : 'Disconnected'),
              ],
            ),
            const SizedBox(height: 8),

            // Slider #1
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _heroController,
                itemCount: heroItems.length,
                itemBuilder: (context, index) {
                  final item = heroItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
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
            const SizedBox(height: 16),

            Row(
              children: const [
                Text(
                  'Title',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 6),
                Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 12),

            // Slider #2
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cardItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
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
                      isActive: isActive, // NEW: highlight when playing
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(item.imageUrl, fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.15)),
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.title,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
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
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: 160,
      padding: EdgeInsets.all(isActive ? 6 : 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border:
            isActive
                ? Border.all(color: Colors.amber.shade600, width: 3)
                : null,
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                : [],
        color: isActive ? Colors.white : Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.asset(item.imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),

          // Tag + Now playing pill (if active)
          Row(
            children: [
              Text(
                item.tag,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              if (isActive) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Now playing',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),

          // Title
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.black : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
