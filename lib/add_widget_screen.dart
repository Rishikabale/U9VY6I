import 'package:flutter/material.dart';
import 'widget_type.dart';

class AddWidgetScreen extends StatefulWidget {
  const AddWidgetScreen({super.key});

  @override
  State<AddWidgetScreen> createState() => _AddWidgetScreenState();
}

class _AddWidgetScreenState extends State<AddWidgetScreen> {
  // using a map to track which widget types the user picked
  final Map<WidgetType, bool> _chosen = {
    WidgetType.textbox: false,
    WidgetType.imagebox: false,
    WidgetType.saveButton: false,
  };

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Widgets'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFE8F5E9),

      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85, 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCheckItem(WidgetType.textbox, 'Text Widget'),
              const SizedBox(height: 24),

              _buildCheckItem(WidgetType.imagebox, 'Image Widget'),
              const SizedBox(height: 24),

              _buildCheckItem(WidgetType.saveButton, 'Button Widget'),
              const SizedBox(height: 64),

              // button to finalize selection
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8E6C9),
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: const BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
                onPressed: _handleImport,
                child: const Text('Import Widgets'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildCheckItem(WidgetType type, String title) {
    return Row(
      children: [
        Checkbox(
          value: _chosen[type],
          onChanged: (val) {
            
            setState(() {
              _chosen[type] = val ?? false;
            });
          },
          shape: const CircleBorder(),
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.green[400];
            }
            // fallback grey fill to match light theme
            return Colors.grey[300];
          }),
          side: const BorderSide(
            color: Colors.white,
            width: 10.0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.all(12.0),
            
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  // handles what happens when you tap Import Widgets
  void _handleImport() {
    final selected = <WidgetType>[];

    _chosen.forEach((key, val) {
      if (val) selected.add(key);
    });

    
    Navigator.of(context).pop(selected);
  }
}


