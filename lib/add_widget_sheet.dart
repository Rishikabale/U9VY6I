import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart'; 
import 'widget_type.dart';

class AddWidgetSheet extends StatefulWidget {
  const AddWidgetSheet({super.key});

  @override
  State<AddWidgetSheet> createState() => _AddWidgetSheetState();
}

class _AddWidgetSheetState extends State<AddWidgetSheet> {
  final Map<WidgetType, bool> _chosen = {
    WidgetType.textbox: false,
    WidgetType.imagebox: false,
    WidgetType.saveButton: false,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            'Add Widgets',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 12),

          CheckboxListTile(
            title: Text('Text Widget', style: GoogleFonts.poppins(fontSize: 16)),
            value: _chosen[WidgetType.textbox],
            onChanged: (val) => setState(() => _chosen[WidgetType.textbox] = val ?? false),
            activeColor: Colors.green[400],
          ),
          CheckboxListTile(
            title: Text('Image Widget', style: GoogleFonts.poppins(fontSize: 16)),
            value: _chosen[WidgetType.imagebox],
            onChanged: (val) => setState(() => _chosen[WidgetType.imagebox] = val ?? false),
            activeColor: Colors.green[400],
          ),
          CheckboxListTile(
            title: Text('Button Widget', style: GoogleFonts.poppins(fontSize: 16)),
            value: _chosen[WidgetType.saveButton],
            onChanged: (val) => setState(() => _chosen[WidgetType.saveButton] = val ?? false),
            activeColor: Colors.green[400],
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[400],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: _handleImport,
            child: Text(
              'Import Widgets',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _handleImport() {
    final selected = <WidgetType>[];
    _chosen.forEach((key, val) {
      if (val) selected.add(key);
    });

    Navigator.of(context).pop(selected);
  }
}
