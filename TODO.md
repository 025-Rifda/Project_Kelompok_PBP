# TODO: Fix Dark Mode Implementation

## Tasks
- [ ] Complete darkTheme in lib/core/theme.dart with missing properties (cardColor, elevatedButtonTheme, inputDecorationTheme, floatingActionButtonTheme)
- [ ] Update MediaCard to use Theme.of(context).cardColor instead of Colors.white
- [ ] Update AnimeCard to use Theme.of(context).cardColor instead of Colors.white
- [ ] Update AboutPage header to use theme colors
- [ ] Update FavoritePage header and filter bar to use theme colors
- [ ] Update SettingsPage header and filter bar to use theme colors
- [ ] Test dark mode toggle to ensure all parts change colors correctly
- [ ] Ensure text visibility in dark mode (fonts should be white or appropriate contrast)

# TODO: Add Badge to Favorite Icon in Sidebar

## Tasks
- [x] Modify lib/widgets/sidebar.dart to add badge on Favorite icon showing count of favorites
- [ ] Test the badge functionality by adding/removing favorites and checking if badge updates
- [ ] Ensure badge is visible and styled properly in both light and dark modes
