import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../home_repository.dart';
import '../post/post_widget.dart';
import '../story/story_bar.dart';
import 'feed_controller.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedController(HomeRepository()),
      child: Consumer<FeedController>(
        builder: (context, controller, _) {
          final state = controller.state;
          return RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                const StoryBar(),
                if (state.loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: LoadingWidget()),
                  )
                else if (state.posts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: EmptyStateWidget(
                      title: 'No posts yet',
                      subtitle: 'Start following friends to see their updates.',
                    ),
                  )
                else
                  ...state.posts.map((post) => PostWidget(post: post)),
              ],
            ),
          );
        },
      ),
    );
  }
}
