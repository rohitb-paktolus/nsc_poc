import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String source;
  final bool isNetwork;

  const VideoPlayerScreen({
    super.key,
    required this.source,
    this.isNetwork = true,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    if (widget.isNetwork) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.source));
    } else {
      _controller = VideoPlayerController.file(File(widget.source));
    }

    _controller.addListener(
          () {
        if (_controller.value.isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = _controller.value.isPlaying;
          });
        }
      },
    );

    _controller.initialize().then(
          (_) {
        setState(() {
          _isInitialized = true;
        });
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _seekForward() {
    final newPosition = _controller.value.position + const Duration(seconds: 10);
    _controller.seekTo(newPosition > _controller.value.duration
        ? _controller.value.duration
        : newPosition);
  }

  void _seekBackward() {
    final newPosition = _controller.value.position - const Duration(seconds: 10);
    _controller.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final nativeAspectRatio = _controller.value.aspectRatio;
    const double fixedHeight = 250;
    final width = fixedHeight * nativeAspectRatio;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: GestureDetector(
          onTap: _toggleControls,
          child: Container(
            height: fixedHeight,
            width: width,
            color: Colors.black,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),

                // Controls Overlay
                if (_showControls || !_isPlaying)
                  Container(
                    color: Colors.black54,
                    child: Stack(
                      children: [
                        // Center Play/Pause Button
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Backward Button
                              _ControlButton(
                                icon: Icons.replay_10,
                                onPressed: _seekBackward,
                              ),

                              const SizedBox(width: 20),

                              // Play/Pause Button
                              _ControlButton(
                                icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                                onPressed: _togglePlayPause,
                                size: 40,
                              ),

                              const SizedBox(width: 20),

                              // Forward Button
                              _ControlButton(
                                icon: Icons.forward_10,
                                onPressed: _seekForward,
                              ),
                            ],
                          ),
                        ),

                        // Video Progress Indicator at bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: Colors.red,
                              bufferedColor: Colors.grey,
                              backgroundColor: Colors.black26,
                            ),
                          ),
                        ),

                        // Position and Duration Info
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Text(
                            '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Auto-hide play button when video is not playing
                if (!_isPlaying && !_showControls)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: Colors.white,
        size: size,
      ),
      onPressed: onPressed,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}