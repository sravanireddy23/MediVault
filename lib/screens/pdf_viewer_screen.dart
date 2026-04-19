import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewerScreen({super.key, required this.url, required this.title});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  static const Color kPrimaryBlue = Color(0xFF1565C0);

  String? _localPath;
  bool    _isLoading        = true;
  bool    _hasError         = false;
  String  _errorMsg         = '';
  int     _totalPages       = 0;
  int     _currentPage      = 0;
  double  _downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      final tempDir  = await getTemporaryDirectory();
      final fileName = 'medivault_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${tempDir.path}/$fileName';

      debugPrint('PDF URL: ${widget.url}'); // ← ADD THIS

      final dio = Dio();
      await dio.download(
        widget.url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );
      setState(() { _localPath = filePath; _isLoading = false; });
    } catch (e) {
      debugPrint('PDF ERROR: $e'); // ← ADD THIS
      setState(() {
        _isLoading = false;
        _hasError  = true;
        _errorMsg  = 'Error: $e'; // ← show real error temporarily
      });
    }
  }

  @override
  void dispose() {
    if (_localPath != null) {
      try { File(_localPath!).deleteSync(); } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            if (_totalPages > 0)
              Text('Page ${_currentPage + 1} of $_totalPages',
                  style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: _showInfo),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60, height: 60,
              child: CircularProgressIndicator(
                  value: _downloadProgress > 0 ? _downloadProgress : null,
                  color: const Color(0xFF1E88E5), strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text(
                _downloadProgress > 0
                    ? 'Loading... ${(_downloadProgress * 100).toInt()}%'
                    : 'Preparing your report...',
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 64),
              const SizedBox(height: 16),
              Text(_errorMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading        = true;
                    _hasError         = false;
                    _downloadProgress = 0;
                  });
                  _downloadPdf();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        PDFView(
          filePath: _localPath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          pageSnap: true,
          fitPolicy: FitPolicy.BOTH,
          backgroundColor: const Color(0xFF1A1A2E),
          onRender: (pages) => setState(() => _totalPages = pages ?? 0),
          onPageChanged: (page, total) => setState(() {
            _currentPage = page ?? 0;
            _totalPages  = total ?? 0;
          }),
          onError: (_) => setState(() {
            _hasError = true;
            _errorMsg = 'Could not render this PDF.';
          }),
        ),
        if (_totalPages > 1)
          Positioned(
            bottom: 16, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${_currentPage + 1} / $_totalPages',
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ),
          ),
      ],
    );
  }

  void _showInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Document Info',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _infoRow('Title', widget.title),
            _infoRow('Pages', '$_totalPages'),
            _infoRow('Type', 'PDF Document'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 60,
              child: Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}