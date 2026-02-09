import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/loading_widget.dart';
import '../search_repository.dart';
import '../search_categories/category_grid.dart';
import '../search_categories/category_tabs.dart';
import 'search_controller.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchController(SearchRepository()),
      child: Consumer<SearchController>(
        builder: (context, controller, _) {
          final state = controller.state;
          final categories = state.items.isEmpty
              ? ['Travel', 'Food', 'Style', 'Music', 'Animals']
              : state.items;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: controller.search,
              ),
              const SizedBox(height: 16),
              CategoryTabs(categories: categories),
              if (state.loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: LoadingWidget()),
                )
              else
                CategoryGrid(items: categories),
            ],
          );
        },
      ),
    );
  }
}
