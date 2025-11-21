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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 4,),
          // Video Player - 1/4 of screen height
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: _buildVideoPlayer(),
          ),

          // Course Content List - takes remaining 3/4 of screen
          Expanded(
            child: _buildVideoContentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final nativeAspectRatio = _controller.value.aspectRatio;
    final screenWidth = MediaQuery.of(context).size.width;
    final videoHeight = MediaQuery.of(context).size.height * 0.25;
    final videoWidth = videoHeight * nativeAspectRatio;

    return Center(
      child: GestureDetector(
        onTap: _toggleControls,
        child: Container(
          height: videoHeight,
          width: videoWidth > screenWidth ? screenWidth : videoWidth,
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller),

              // Single Controls Overlay - Conditionally shown
              if (_showControls || !_isPlaying)
                Container(
                  color: _showControls ? Colors.black54 : Colors.transparent,
                  child: Stack(
                    children: [
                      // Center Play/Pause Button - Only show when video is not playing OR controls are visible
                      if (!_isPlaying || _showControls)
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Backward Button - Only show when controls are visible
                              if (_showControls)
                                _ControlButton(
                                  icon: Icons.replay_10,
                                  onPressed: _seekBackward,
                                ),

                              if (_showControls) const SizedBox(width: 20),

                              // Play/Pause Button - Always show when video is paused
                              _ControlButton(
                                icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                                onPressed: _togglePlayPause,
                                size: 40,
                              ),

                              if (_showControls) const SizedBox(width: 20),

                              // Forward Button - Only show when controls are visible
                              if (_showControls)
                                _ControlButton(
                                  icon: Icons.forward_10,
                                  onPressed: _seekForward,
                                ),
                            ],
                          ),
                        ),

                      // Video Progress Indicator at bottom - Only show when controls are visible
                      if (_showControls)
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

                      // Position and Duration Info - Only show when controls are visible
                      if (_showControls)
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContentList() {
    final List<CourseItem> courseItems = [
      CourseItem(
        title: 'Custom Form Styles',
        type: ContentType.video,
        duration: '05:34 mins',
        isCompleted: false,
      ),
      CourseItem(
        title: 'Protection against variable name changes',
        type: ContentType.video,
        duration: '07:27 mins',
        isCompleted: true,
      ),
      CourseItem(
        title: 'Calculate days between dates',
        type: ContentType.video,
        duration: '03:28 mins',
        isCompleted: true,
      ),
      CourseItem(
        title: 'Update note',
        type: ContentType.article,
        duration: 'Article',
        isCompleted: true,
      ),
      CourseItem(
        title: 'Validations: 7 business days',
        type: ContentType.video,
        duration: '10:14 mins remaining',
        isCompleted: false,
        isRemaining: true,
      ),
      CourseItem(
        title: 'Validations: Verify start and end date',
        type: ContentType.video,
        duration: '04:38 mins',
        isCompleted: false,
      ),
      CourseItem(
        title: 'Get available days count',
        type: ContentType.video,
        duration: '10:00 mins',
        isCompleted: false,
      ),
      CourseItem(
        title: 'Validations: Employee has enough vacation days',
        type: ContentType.video,
        duration: '03:40 mins',
        isCompleted: false,
      ),
      CourseItem(
        title: 'Discord Node: Send automatic message',
        type: ContentType.video,
        duration: '09:55 mins',
        isCompleted: false,
      ),
    ];

    return Column(
      children: [
        // Header Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderButton(Icons.play_circle_fill, 'Lectures', '${courseItems.length}'),
              _buildHeaderButton(Icons.download, 'Downloads', '0'),
              _buildHeaderButton(Icons.more_horiz, 'More', ''),
            ],
          ),
        ),

        // Content List
        Expanded(
          child: ListView.builder(
            itemCount: courseItems.length,
            itemBuilder: (context, index) {
              final item = courseItems[index];

              // Add divider after the 4th item
              if (index == 4) {
                return Column(
                  children: [
                    const Divider(height: 1, thickness: 1),
                    _buildListItem(item, index),
                  ],
                );
              }

              return _buildListItem(item, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderButton(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.purple[700],
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(CourseItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildLeadingIcon(item),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration: item.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
            color: item.isCompleted ? Colors.grey[600] : Colors.black,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              item.type == ContentType.video ? Icons.play_circle_outline : Icons.article_outlined,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              item.duration,
              style: TextStyle(
                fontSize: 12,
                color: item.isRemaining ? Colors.purple[700] : Colors.grey[600],
                fontWeight: item.isRemaining ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        trailing: item.isCompleted
            ? Icon(
          Icons.check_circle,
          color: Colors.purple[700],
          size: 20,
        )
            : null,
        onTap: () {
          // Handle item tap
        },
      ),
    );
  }

  Widget _buildLeadingIcon(CourseItem item) {
    if (item.isCompleted) {
      return Icon(
        Icons.check_circle,
        color: Colors.purple[700],
        size: 24,
      );
    }

    return Checkbox(
      value: item.isCompleted,
      onChanged: (value) {
        // Handle checkbox change
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
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

enum ContentType {
  video,
  article,
}

class CourseItem {
  final String title;
  final ContentType type;
  final String duration;
  final bool isCompleted;
  final bool isRemaining;

  CourseItem({
    required this.title,
    required this.type,
    required this.duration,
    this.isCompleted = false,
    this.isRemaining = false,
  });
}