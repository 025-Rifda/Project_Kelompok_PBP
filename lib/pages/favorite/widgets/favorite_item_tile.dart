import 'package:flutter/material.dart';
import '../../../models/anime_model.dart';

class FavoriteItemTile extends StatelessWidget {
  const FavoriteItemTile({
    super.key,
    required this.anime,
    required this.onTap,
    required this.onDelete,
  });

  final Anime anime;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  anime.imageUrl,
                  width: 70,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          anime.score?.toStringAsFixed(1) ?? 'N/A',
                          style: TextStyle(
                            color: colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    if (anime.year != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Tahun: ${anime.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: colorScheme.error),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
