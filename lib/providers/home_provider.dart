import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widget_type.dart';

class HomeState {
  final List<WidgetType> widgets;
  final String text;
  final XFile? pickedImg;
  final String? savedText;
  final String? savedImgUrl;
  final bool isBusy;
  final String? error;

  HomeState({
    this.widgets = const [],
    this.text = '',
    this.pickedImg,
    this.savedText,
    this.savedImgUrl,
    this.isBusy = false,
    this.error,
  });

  HomeState copyWith({
    List<WidgetType>? widgets,
    String? text,
    XFile? pickedImg,
    bool clearPickedImg = false,
    String? savedText,
    String? savedImgUrl,
    bool? isBusy,
    String? error,
    bool clearError = false,
  }) {
    return HomeState(
      widgets: widgets ?? this.widgets,
      text: text ?? this.text,
      pickedImg: clearPickedImg ? null : pickedImg ?? this.pickedImg,
      savedText: savedText ?? this.savedText,
      savedImgUrl: savedImgUrl ?? this.savedImgUrl,
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final ImagePicker _imgPicker = ImagePicker();

  HomeNotifier() : super(HomeState());

  void addWidgets(List<WidgetType> widgetsToAdd) {
    // Clears the error when new widgets are added, per prototype logic
    state = state.copyWith(
      widgets: List.from(widgetsToAdd),
      clearError: true,
    );
  }

  void updateText(String newText) {
    state = state.copyWith(text: newText);
  }

  // Removed deleteWidget as it's not in the prototype
  // (You can add it back, but it wasn't in the video)

  Future<void> grabImage(ImageSource source) async {
    try {
      final img = await _imgPicker.pickImage(source: source);
      if (img != null) {
        state = state.copyWith(pickedImg: img);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to pick image: $e');
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<bool> doSave() async {
    bool hasSomething = state.widgets.contains(WidgetType.textbox) ||
        state.widgets.contains(WidgetType.imagebox);

    if (!hasSomething) {
      state = state.copyWith(error: 'Add at-least a widget to save.');
      return false;
    }

    state = state.copyWith(isBusy: true, clearError: true);

    try {
      String? imageUrl;
      if (state.pickedImg != null) {
        final name = 'uploads/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child(name);
        await ref.putFile(File(state.pickedImg!.path));
        imageUrl = await ref.getDownloadURL();
      }

      final textVal = state.text;

      await FirebaseFirestore.instance.collection('data').add({
        'text': textVal,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      state = state.copyWith(
        isBusy: false,
        savedText: textVal,
        savedImgUrl: imageUrl,
        text: '', // Clears text
        clearPickedImg: true,
      );
      return true;
    } catch (err) {
      state = state.copyWith(isBusy: false, error: 'Failed to save data: $err');
      return false;
    }
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});