import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const ImageViewerScreen({super.key, required this.url, required this.title});

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  bool _showAppBar = true;
  final PhotoViewScaleStateController _scaleStateController =
  PhotoViewScaleStateController();

  @override
  void dispose() {
    _scaleStateController.dispose();
    super.dispose();
  }

  void _toggleAppBar() => setState(() => _showAppBar = !_showAppBar);

  void _resetZoom() =>
      _scaleStateController.scaleState = PhotoViewScaleState.initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showAppBar
          ? AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            onPressed: _resetZoom,
            tooltip: 'Reset zoom',
          ),
        ],
      )
          : null,
      body: GestureDetector(
        onTap: _toggleAppBar,
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(widget.url),
          scaleStateController: _scaleStateController,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 4,
          initialScale: PhotoViewComputedScale.contained,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          loadingBuilder: (context, event) {
            final progress = event?.expectedTotalBytes != null
                ? event!.cumulativeBytesLoaded / event.expectedTotalBytes!
                : null;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60, height: 60,
                    child: CircularProgressIndicator(
                      value: progress,
                      color: const Color(0xFF1E88E5),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    progress != null
                        ? 'Loading... ${(progress * 100).toInt()}%'
                        : 'Loading image...',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image_outlined,
                      color: Colors.white30, size: 72),
                  SizedBox(height: 16),
                  Text('Could not load image',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 8),
                  Text('Check your internet connection',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _showAppBar
          ? Container(
        color: Colors.black.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pinch, color: Colors.white54, size: 16),
            SizedBox(width: 6),
            Text('Pinch to zoom · Tap to hide toolbar',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      )
          : null,
    );
  }
}