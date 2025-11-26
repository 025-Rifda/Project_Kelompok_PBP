import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/anime_bloc.dart';
import '../../../bloc/anime_event.dart';
import '../../../bloc/anime_state.dart';

void showRatingFilterDialog(BuildContext context) {
  bool currentSortAsc = true;

  final state = context.read<AnimeBloc>().state;
  if (state is AnimeLoaded) {
    currentSortAsc = state.sortFavoritesAscending;
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Urutkan Berdasarkan Rating'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Low → High'),
            leading: Radio(
              value: true,
              groupValue: currentSortAsc,
              onChanged: (v) {
                context.read<AnimeBloc>().add(SortFavoritesEvent(true));
                Navigator.pop(context);
              },
            ),
          ),
          ListTile(
            title: const Text('High → Low'),
            leading: Radio(
              value: false,
              groupValue: currentSortAsc,
              onChanged: (v) {
                context.read<AnimeBloc>().add(SortFavoritesEvent(false));
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    ),
  );
}
