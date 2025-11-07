import 'package:flutter/material.dart';
import 'dart:math' as math;

class MergePdfScreen extends StatefulWidget {
  const MergePdfScreen({super.key});

  @override
  State<MergePdfScreen> createState() => _MergePdfScreenState();
}

class _MergePdfScreenState extends State<MergePdfScreen> {
  final List<PdfFileItem> _pdfFiles = [];
  bool _preserveBookmarks = true;
  bool _compressOutput = false;
  String _outputFilename = 'merged_output.pdf';
  String _pageRange = '';
  bool _isMerging = false;
  double _mergeProgress = 0.0;

  // Computed estimated output size
  String get _estimatedSize {
    if (_pdfFiles.isEmpty) return '0 MB';
    final totalBytes = _pdfFiles.fold<int>(0, (sum, file) => sum + file.sizeBytes);
    final sizeMB = totalBytes / (1024 * 1024);
    return '${sizeMB.toStringAsFixed(2)} MB';
  }

  void _addFiles() {
    // TODO: Implement file picker
    // Use file_picker package to select PDF files
    // For now, add mock data
    setState(() {
      _pdfFiles.add(PdfFileItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filename: 'Sample_${_pdfFiles.length + 1}.pdf',
        sizeBytes: (math.Random().nextInt(5) + 1) * 1024 * 1024,
        thumbnailPath: null,
      ));
    });
  }

  void _removeFile(String id) {
    setState(() {
      _pdfFiles.removeWhere((file) => file.id == id);
    });
  }

  void _reorderFiles(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _pdfFiles.removeAt(oldIndex);
      _pdfFiles.insert(newIndex, item);
    });
  }

  Future<void> _mergePdfs() async {
    if (_pdfFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add PDF files to merge')),
      );
      return;
    }

    setState(() {
      _isMerging = true;
      _mergeProgress = 0.0;
    });

    // TODO: Call backend merge function
    // ModuleManager.loadFrozenModule("merge")
    // Pass parameters: _pdfFiles, _preserveBookmarks, _pageRange, _compressOutput, _outputFilename
    
    // Simulate progress
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _mergeProgress = i / 100;
      });
    }

    setState(() {
      _isMerging = false;
      _mergeProgress = 0.0;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Merged PDFs saved as $_outputFilename')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Merge PDFs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Home > Tools > Merge PDFs',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag-and-drop area
              _buildDropArea(),
              const SizedBox(height: 24),
              
              // File list preview
              if (_pdfFiles.isNotEmpty) ..[
                _buildFileList(),
                const SizedBox(height: 24),
              ],
              
              // Controls section
              _buildControlsSection(),
              const SizedBox(height: 24),
              
              // Merge button and progress
              _buildMergeSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropArea() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.blue[300]!,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _addFiles,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 64,
                color: Colors.blue[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Drag and drop PDF files here',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'or',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _addFiles,
                icon: const Icon(Icons.add),
                label: const Text('Add Files'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Added Files (${_pdfFiles.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Est. size: $_estimatedSize',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pdfFiles.length,
            onReorder: _reorderFiles,
            itemBuilder: (context, index) {
              final file = _pdfFiles[index];
              return _buildFileItem(file, index, key: ValueKey(file.id));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(PdfFileItem file, int index, {required Key key}) {
    final sizeMB = (file.sizeBytes / (1024 * 1024)).toStringAsFixed(2);
    return Container(
      key: key,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.drag_handle,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                color: Colors.red[400],
                size: 28,
              ),
            ),
          ],
        ),
        title: Text(
          file.filename,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '$sizeMB MB',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.grey[600],
          onPressed: () => _removeFile(file.id),
          tooltip: 'Remove file',
        ),
      ),
    );
  }

  Widget _buildControlsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Merge Options',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Preserve bookmarks toggle
          SwitchListTile(
            title: const Text('Preserve Bookmarks'),
            subtitle: Text(
              'Keep bookmarks from original PDFs',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            value: _preserveBookmarks,
            onChanged: (value) {
              setState(() {
                _preserveBookmarks = value;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(),
          
          // Compress output checkbox
          CheckboxListTile(
            title: const Text('Compress Output'),
            subtitle: Text(
              'Reduce file size (may take longer)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            value: _compressOutput,
            onChanged: (value) {
              setState(() {
                _compressOutput = value ?? false;
              });
            },
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),
          
          // Page range input
          TextField(
            decoration: InputDecoration(
              labelText: 'Page Range (optional)',
              hintText: 'e.g., 1-5, 8, 11-13',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: 'Leave empty to include all pages',
              helperStyle: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
            onChanged: (value) {
              _pageRange = value;
            },
          ),
          const SizedBox(height: 16),
          
          // Output filename input
          TextField(
            decoration: InputDecoration(
              labelText: 'Output Filename',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixText: '.pdf',
            ),
            controller: TextEditingController(text: _outputFilename.replaceAll('.pdf', '')),
            onChanged: (value) {
              _outputFilename = value.endsWith('.pdf') ? value : '$value.pdf';
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMergeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: _isMerging ? null : _mergePdfs,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isMerging
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Merge PDFs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
        if (_isMerging) ..[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Merging PDFs...',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(_mergeProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _mergeProgress,
                  backgroundColor: Colors.grey[200],
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class PdfFileItem {
  final String id;
  final String filename;
  final int sizeBytes;
  final String? thumbnailPath;

  PdfFileItem({
    required this.id,
    required this.filename,
    required this.sizeBytes,
    this.thumbnailPath,
  });
}
