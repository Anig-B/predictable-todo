import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class XpFloat {
  final int id;
  final double x;
  final double y;
  final int value;
  final int multiplier;

  const XpFloat({
    required this.id,
    required this.x,
    required this.y,
    required this.value,
    required this.multiplier,
  });
}

class ToastData {
  final String icon;
  final String title;
  final String desc;

  const ToastData({
    required this.icon,
    required this.title,
    required this.desc,
  });
}

class EffectsState {
  final bool showConfetti;
  final List<XpFloat> xpFloats;
  final ToastData? toast;

  const EffectsState({
    this.showConfetti = false,
    this.xpFloats = const [],
    this.toast,
  });

  EffectsState copyWith({
    bool? showConfetti,
    List<XpFloat>? xpFloats,
    ToastData? toast,
    bool clearToast = false,
  }) =>
      EffectsState(
        showConfetti: showConfetti ?? this.showConfetti,
        xpFloats: xpFloats ?? this.xpFloats,
        toast: clearToast ? null : (toast ?? this.toast),
      );
}

class EffectsNotifier extends StateNotifier<EffectsState> {
  EffectsNotifier() : super(const EffectsState());

  int _floatId = 0;

  void triggerConfetti() {
    state = state.copyWith(showConfetti: true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) state = state.copyWith(showConfetti: false);
    });
  }

  void spawnXpFloat({required double x, required double y, required int value, int multiplier = 1}) {
    final id = _floatId++;
    final floats = [...state.xpFloats, XpFloat(id: id, x: x, y: y, value: value, multiplier: multiplier)];
    state = state.copyWith(xpFloats: floats);
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) {
        state = state.copyWith(xpFloats: state.xpFloats.where((f) => f.id != id).toList());
      }
    });
  }

  void showToast({required String icon, required String title, required String desc}) {
    state = state.copyWith(toast: ToastData(icon: icon, title: title, desc: desc));
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) state = state.copyWith(clearToast: true);
    });
  }

  void clearToast() => state = state.copyWith(clearToast: true);
}

final effectsProvider = StateNotifierProvider<EffectsNotifier, EffectsState>(
  (ref) => EffectsNotifier(),
);
