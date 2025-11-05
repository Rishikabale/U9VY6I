import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'add_widget_sheet.dart';
import 'package:assignment/providers/home_provider.dart';
import 'dart:io';
import 'widget_type.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _textController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
  
    _textController.addListener(() {
      ref.read(homeProvider.notifier).updateText(_textController.text);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);

  
    ref.listen<HomeState>(homeProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        _showErrorSnackBar(next.error ?? 'Unknown error');
        ref.read(homeProvider.notifier).clearError();
      }

      if (previous?.isBusy == true && next.isBusy == false && next.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved successfully!', style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (next.text != _textController.text) {
        _textController.text = next.text;
      }
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Assignment App',
          style: GoogleFonts.poppins(
            color: Colors.green[900],
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _drawContentArea(state),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              ElevatedButton(
                onPressed: _openAddSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Add Widgets',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawContentArea(HomeState state) {
    if (state.widgets.isEmpty) {
      // nothing to show yet
      return Center(
        child: Text(
          'No widget is added',
          style: GoogleFonts.poppins(color: Colors.black54, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      itemCount: state.widgets.length,
      itemBuilder: (ctx, index) => _renderWidget(index, state),
    );
  }

  Widget _renderWidget(int index, HomeState state) {
    final type = state.widgets[index];
    final notifier = ref.read(homeProvider.notifier);

    final deleteButton = Positioned(
      top: -8,
      right: -8,
      child: IconButton(
        icon: Icon(Icons.cancel, color: Colors.red[400]),
        onPressed: () => notifier.deleteWidget(index),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
      ),
    );

    switch (type) {
      case WidgetType.textbox:
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        labelText: 'Enter Text',
                        border: const OutlineInputBorder(),
                        labelStyle: GoogleFonts.poppins(),
                      ),
                    ),
                    if (state.savedText != null && state.savedText!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'Saved: ${state.savedText}',
                          style: GoogleFonts.poppins(color: Colors.green[600]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            deleteButton,
          ],
        );

      case WidgetType.imagebox:
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _decideImage(state),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _grabImage,
                      icon: const Icon(Icons.upload),
                      label: Text('Upload Image', style: GoogleFonts.poppins()),
                    ),
                  ],
                ),
              ),
            ),
            deleteButton,
          ],
        );

      case WidgetType.saveButton:
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[500],
                  foregroundColor: Colors.white,
                ),
                onPressed: state.isBusy ? null : notifier.doSave,
                child: state.isBusy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Save', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
            deleteButton,
          ],
        );
    }
  }

  void _openAddSheet() async {
    final selectedWidgets = await showModalBottomSheet<List<WidgetType>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddWidgetSheet(),
    );

    // I should probably add a check here for null/empty
    if (selectedWidgets != null && selectedWidgets.isNotEmpty) {
      ref.read(homeProvider.notifier).addWidgets(selectedWidgets);
    }
  }

  Future<void> _grabImage() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;
    await ref.read(homeProvider.notifier).grabImage(source);
  }

  Future<ImageSource?> _showImageSourceDialog() {
    return showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Select Source', style: GoogleFonts.poppins()),
        content: Text('Pick an image from your Gallery or use the Camera.',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            child: Text('Gallery', style: GoogleFonts.poppins()),
            onPressed: () => Navigator.of(ctx).pop(ImageSource.gallery),
          ),
          TextButton(
            child: Text('Camera', style: GoogleFonts.poppins()),
            onPressed: () => Navigator.of(ctx).pop(ImageSource.camera),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _decideImage(HomeState state) {
    
    if (state.pickedImg != null) {
      return Image.file(File(state.pickedImg!.path), fit: BoxFit.cover);
    } else if (state.savedImgUrl != null) {
      return Image.network(
        state.savedImgUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loading) {
          if (loading == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }
    return Center(
      child: Text('Upload Image', style: GoogleFonts.poppins(color: Colors.grey)),
    );
  }
}
