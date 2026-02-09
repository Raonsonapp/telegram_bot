import '../../models/reel_model.dart';

class ReelsState {
  ReelsState({required this.reels, this.loading = false});

  final List<ReelModel> reels;
  final bool loading;
}
