import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'core/clock.dart';
import 'core/widgets/app_nav_bar.dart';
import 'features/diary/add_food_page.dart';
import 'features/diary/today_page.dart';
import 'features/goals/goal_page.dart';
import 'features/products/food_form_page.dart';
import 'features/products/product_page.dart';
import 'features/profile/about_page.dart';
import 'features/profile/meals_settings_page.dart';
import 'features/profile/my_foods_page.dart';
import 'features/profile/profile_page.dart';
import 'features/scan/scan_page.dart';
import 'features/scan/scanner_page.dart';
import 'features/scan/search_results_page.dart';
import 'features/stats/stats_page.dart';
import 'l10n/app_localizations.dart';

/// All screen addresses of the app in one place.
///
/// Always build locations with these helpers instead of typing paths, so a
/// typo cannot send the user to a missing page. Example:
/// `context.push(Routes.product('4001686301265'))`.
abstract final class Routes {
  static const today = '/today';
  static const scan = '/scan';
  static const stats = '/stats';
  static const profile = '/profile';
  static const goal = '/profile/goal';
  static const meals = '/profile/meals';
  static const myFoods = '/profile/my-foods';
  static const about = '/profile/about';

  static String addFood(String day, int mealId) => '/today/add/$day/$mealId';

  static String addFoodScan(String day, int mealId) =>
      '${addFood(day, mealId)}/scan';

  static String search(String query) =>
      Uri(path: '/scan/search', queryParameters: {'q': query}).toString();

  /// The product page of a barcode. [fromSearch]: the code is from an Open
  /// Food Facts search hit, so it is not checked like a scanned code
  /// (`?from=search`, see ProductRepository.lookupBarcode).
  static String product(
    String barcode, {
    String? day,
    int? mealId,
    bool fromSearch = false,
  }) => _withTarget('/product/$barcode', day, mealId, {
    if (fromSearch) 'from': 'search',
  });

  static String food(int id, {String? day, int? mealId}) =>
      _withTarget('/food/$id', day, mealId);

  static String newFood({String? barcode, String? day, int? mealId}) =>
      _withQuery('/food/new', {
        'barcode': ?barcode,
        'day': ?day,
        if (mealId != null) 'meal': '$mealId',
      });

  static String editFood(int id) => '/food/$id/edit';

  /// Adds `?day=…&meal=…` when the food should go to a specific meal, and
  /// [more] parameters.
  static String _withTarget(
    String path,
    String? day,
    int? mealId, [
    Map<String, String> more = const {},
  ]) => _withQuery(path, {
    'day': ?day,
    if (mealId != null) 'meal': '$mealId',
    ...more,
  });

  /// [path] plus the encoded [query]; no lonely `?` when [query] is empty.
  static String _withQuery(String path, Map<String, String> query) =>
      Uri(path: path, queryParameters: query.isEmpty ? null : query).toString();
}

/// Reads `?day=` (only if it is a real yyyy-MM-dd date).
String? _dayParam(GoRouterState state) {
  final day = state.uri.queryParameters['day'];
  return day != null && isDayKey(day) ? day : null;
}

/// Reads `?meal=` as a number.
int? _mealParam(GoRouterState state) =>
    int.tryParse(state.uri.queryParameters['meal'] ?? '');

/// The navigator above the tabs: pages pushed on it cover the bottom bar.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// The router of the app. Created in a provider so every test gets a fresh
/// one.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.today,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.today,
                builder: (_, _) => const TodayPage(),
                routes: [
                  GoRoute(
                    path: 'add/:day/:mealId',
                    builder: (_, state) => AddFoodPage(
                      day: state.pathParameters['day']!,
                      mealId: int.parse(state.pathParameters['mealId']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'scan',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (_, state) => ScannerPage(
                          day: state.pathParameters['day']!,
                          mealId: int.parse(state.pathParameters['mealId']!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.scan,
                builder: (_, _) => const ScanPage(),
                routes: [
                  GoRoute(
                    path: 'search',
                    builder: (_, state) => SearchResultsPage(
                      query: state.uri.queryParameters['q'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.stats, builder: (_, _) => const StatsPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfilePage(),
                routes: [
                  GoRoute(path: 'goal', builder: (_, _) => const GoalPage()),
                  GoRoute(
                    path: 'meals',
                    builder: (_, _) => const MealsSettingsPage(),
                  ),
                  GoRoute(
                    path: 'my-foods',
                    builder: (_, _) => const MyFoodsPage(),
                  ),
                  GoRoute(path: 'about', builder: (_, _) => const AboutPage()),
                ],
              ),
            ],
          ),
        ],
      ),
      // Full-screen pages outside the tabs.
      GoRoute(
        path: '/product/:barcode',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => ProductPage.barcode(
          barcode: state.pathParameters['barcode']!,
          day: _dayParam(state),
          mealId: _mealParam(state),
          fromSearch: state.uri.queryParameters['from'] == 'search',
        ),
      ),
      // '/food/new' must come before '/food/:id', otherwise "new" would be
      // read as an id.
      GoRoute(
        path: '/food/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => FoodFormPage(
          barcode: state.uri.queryParameters['barcode'],
          day: _dayParam(state),
          mealId: _mealParam(state),
        ),
      ),
      GoRoute(
        path: '/food/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => ProductPage.food(
          foodId: int.parse(state.pathParameters['id']!),
          day: _dayParam(state),
          mealId: _mealParam(state),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (_, state) =>
                FoodFormPage(foodId: int.parse(state.pathParameters['id']!)),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// The frame around the four tabs: the page of the current tab plus the
/// app's own floating navigation bar at the bottom. The page ends above the
/// bar, so the bar never covers text or buttons.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: AppNavBar(
        selectedIndex: shell.currentIndex,
        // Tapping the open tab again goes back to its first page.
        onSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: [
          AppNavDestination(icon: Icons.home_rounded, label: l10n.tabToday),
          AppNavDestination(
            icon: Icons.qr_code_scanner_rounded,
            label: l10n.tabScan,
          ),
          AppNavDestination(
            icon: Icons.bar_chart_rounded,
            label: l10n.tabStats,
          ),
          AppNavDestination(icon: Icons.person_rounded, label: l10n.tabProfile),
        ],
      ),
    );
  }
}
