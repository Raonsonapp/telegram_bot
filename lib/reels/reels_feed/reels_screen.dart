import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/loading_widget.dart';
import '../reels_repository.dart';
import 'reels_controller.dart';

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReelsController(ReelsRepository()),
      child: Consumer<ReelsController>(
        builder: (context, controller, _) {
          if (controller.state.loading) {
            return const Center(child: LoadingWidget());
          }
          final reel = controller.state.reels.first;
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(color: Colors.black45),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {},
                        ),
                        const Expanded(
                          child: Text(
                            'Reels',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      reel.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(reel.caption),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 120,
                child: Column(
                  children: [
                    _ReelAction(icon: Icons.favorite, label: '1.2M'),
                    const SizedBox(height: 16),
                    _ReelAction(icon: Icons.mode_comment_outlined, label: '56.3K'),
                    const SizedBox(height: 16),
                    _ReelAction(icon: Icons.send_outlined, label: '18.7K'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReelAction extends StatelessWidget {
  const _ReelAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
