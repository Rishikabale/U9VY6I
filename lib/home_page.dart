import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:assignment/providers/home_provider.dart';
import 'widget_type.dart';
import 'add_widget_screen.dart';

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
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0.0;

    
    ref.listen<HomeState>(homeProvider, (previous, next) {
      if (previous?.isBusy == true && next.isBusy == false && next.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved successfully!'),
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
        title: const Text('Assignment App'),
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
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _drawContentArea(state),
              ),
            ),

            // hides button when keyboard is open (avoids overflow)
            if (!isKeyboardOpen) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _navigateToAddWidgetScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8E6C9),
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Add Widgets'),
              ),
            ]
          ],
        ),
      ),
    );
  }


  Widget _drawContentArea(HomeState state) {
    if (state.widgets.isEmpty && state.error == null) {
      return const Center(
        child: Text(
          'No widget is added',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final List<Widget> children = [
      if (state.error != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Text(
            state.error!,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.widgets.length,
        itemBuilder: (ctx, index) => _renderWidget(index, state),
      ),
    ];

    final bool hasInputWidgets = state.widgets.contains(WidgetType.textbox) ||
        state.widgets.contains(WidgetType.imagebox);

    // choose scroll vs centered layout
    if (hasInputWidgets) {
      return SingleChildScrollView(child: Column(children: children));
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      );
    }
  }


  Widget _renderWidget(int index, HomeState state) {
    final type = state.widgets[index];
    final notifier = ref.read(homeProvider.notifier);

    switch (type) {
      case WidgetType.textbox:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Enter Text',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              if (state.savedText != null && state.savedText!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 4),
                  child: Text(
                    'Saved: ${state.savedText}',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );

      case WidgetType.imagebox:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: GestureDetector(
            onTap: _grabImage,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: _decideImage(state),
            ),
          ),
        );

      case WidgetType.saveButton:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8E6C9),
                foregroundColor: Colors.black87,
                minimumSize: const Size(80, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                elevation: 0,
              ),
              onPressed: state.isBusy ? null : notifier.doSave,
              child: state.isBusy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.black54,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Save'),
            ),
          ),
        );
    }
  }

  void _navigateToAddWidgetScreen() async {
    final selectedWidgets = await Navigator.push<List<WidgetType>>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddWidgetScreen(),
      ),
    );

    if (selectedWidgets != null && selectedWidgets.isNotEmpty) {
      ref.read(homeProvider.notifier).addWidgets(selectedWidgets);
    }
  }

  // picks an image from gallery
  Future<void> _grabImage() async {
    await ref.read(homeProvider.notifier).grabImage(ImageSource.gallery);
  }

  Widget _decideImage(HomeState state) {
    if (state.pickedImg != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Image.file(
          File(state.pickedImg!.path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        ),
      );
    } else if (state.savedImgUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Image.network(
          state.savedImgUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
          loadingBuilder: (context, child, loading) {
            if (loading == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    }

   
    return const Center(
      child: Text('Upload Image', style: TextStyle(color: Colors.black54)),
    );
  }
}
