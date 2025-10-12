import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:video_player/video_player.dart';

const int appId = 525450240;
const String appSign = "d310666f8ffddf3165413cadc4f92aff0581b8e91426936a26c80b95b29c4d22";

class VideoConsultationScreen extends StatefulWidget {
  final Color primaryColor;
  final void Function(bool) onFullScreen;

  const VideoConsultationScreen({
    Key? key,
    required this.primaryColor,
    required this.onFullScreen,
  }) : super(key: key);

  @override
  State<VideoConsultationScreen> createState() =>
      _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
  int _selectedIndex = 0;
  final TextEditingController _roomController = TextEditingController();

  // Pre-recorded local MP4 videos
  final List<Map<String, String>> preRecordedVideos = [
    {"title": "CPR Basics", "path": "assets/cpr.mp4"},
    {"title": "Diabetes Basics", "path": "assets/sugar.mp4"},
    {"title": "Snake Bite First Aid", "path": "assets/bite.mp4"},
  ];

  void _generateRandomRoom() {
    setState(() {
      _roomController.text = "Room_${DateTime.now().millisecondsSinceEpoch}";
    });
  }

  void _startVideoCall() {
    final roomID = _roomController.text.trim();
    if (roomID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter or generate a room name")),
      );
      return;
    }
    final userID = "user_${DateTime.now().millisecondsSinceEpoch}";
    widget.onFullScreen(true);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SafeArea(
          child: ZegoUIKitPrebuiltCall(
            appID: appId,
            appSign: appSign,
            userID: userID,
            userName: "Patient",
            callID: roomID,
            config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
          ),
        ),
      ),
    ).then((_) => widget.onFullScreen(false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Video Consultation',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Toggle buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedIndex == 0
                            ? Colors.white.withOpacity(0.9)
                            : Colors.white.withOpacity(0.7),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Text("Live Video"),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedIndex == 1
                            ? Colors.white.withOpacity(0.9)
                            : Colors.white.withOpacity(0.7),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: const Text("Prerecorded Videos"),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _selectedIndex == 0
                  ? _buildLiveVideoUI()
                  : _buildPreRecordedUI(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveVideoUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _roomController,
                decoration: InputDecoration(
                  hintText: "Enter room name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white70,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _generateRandomRoom,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text("Generate"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          onPressed: _startVideoCall,
          icon: const Icon(Icons.video_call),
          label: const Text("Start Video Call"),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildPreRecordedUI() {
    return ListView.builder(
      itemCount: preRecordedVideos.length,
      itemBuilder: (context, index) {
        final video = preRecordedVideos[index];
        return Card(
          color: Colors.white70,
          child: ListTile(
            title: Text(video['title'] ?? ''),
            trailing: const Icon(Icons.play_arrow),
            onTap: () {
              widget.onFullScreen(true);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LocalVideoPlayerScreen(videoPath: video['path']!),
                ),
              ).then((_) => widget.onFullScreen(false));
            },
          ),
        );
      },
    );
  }
}

// ------------------- Local Video Player Screen -------------------
class LocalVideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const LocalVideoPlayerScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<LocalVideoPlayerScreen> createState() => _LocalVideoPlayerScreenState();
}

class _LocalVideoPlayerScreenState extends State<LocalVideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Video Player'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying ? _controller.pause() : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
