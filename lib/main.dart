import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/config/themes/theme_config.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/services/notification_service.dart';
import 'package:rating/features/core/utils/shell_content.dart';
import 'package:rating/features/core/widgets/error_info.dart';
import 'package:rating/features/onboarding/utils/sign_type.dart';
import 'package:rating/features/ratings/screens/category/category_screen.dart';
import 'package:rating/features/ratings/screens/category/create_category_screen.dart';
import 'package:rating/features/ratings/screens/item/edit_item_screen.dart';
import 'package:rating/features/ratings/screens/category/choose_category_screen.dart';
import 'package:rating/features/core/services/data/data_provider.dart';
import 'package:rating/features/core/widgets/app_shell.dart';
import 'package:rating/features/onboarding/screens/forgot_password_screen.dart';
import 'package:rating/features/onboarding/screens/sign_screen.dart';
import 'package:rating/features/onboarding/screens/welcome_screen.dart';
import 'package:rating/features/ratings/screens/group/choose_group_screen.dart';
import 'package:rating/features/ratings/screens/item/view_item_screen.dart';
import 'package:rating/features/ratings/screens/item/rate_item_screen.dart';
import 'package:rating/features/ratings/models/category.dart';
import 'package:rating/features/ratings/models/item.dart';
import 'package:rating/features/ratings/models/rating.dart';
import 'package:rating/features/ratings/screens/item/zoomable_image_screen.dart';
import 'package:rating/features/settings/provider/settings_provider.dart';
import 'package:rating/features/social/screens/group/create_group_screen.dart';
import 'package:rating/features/social/screens/group/group_screen.dart';
import 'package:rating/features/social/screens/group/join_group_screen.dart';
import 'package:rating/features/social/screens/group/qr_code_scanner_screen.dart';
import 'package:rating/features/social/models/group.dart';
import 'package:rating/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationService.instance.init();
  runApp(const RatingApp());
}

class RatingApp extends StatelessWidget {
  const RatingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return MaterialApp.router(
            title: "Slide It!",
            debugShowCheckedModeBanner: false,
            theme: ThemeConfig.dark(context, darkDynamic),
            darkTheme: ThemeConfig.dark(context, darkDynamic),
            routerConfig: GoRouter(
              navigatorKey: Global.navigatorState,
              initialLocation: AppShell.routeName,
              debugLogDiagnostics: true,
              errorBuilder: (context, state) => Scaffold(body: ErrorInfo(message: state.error.toString())),
              routes: [
                // ShellRoute(
                //   builder: (context, state, child) => AppScaffold(child: child),
                //   routes: [
                //     GoRoute(
                //       path: FeedScreen.routeName,
                //       builder: (context, state) => const FeedScreen(),
                //     ),
                //     GoRoute(
                //       path: RatingsScreen.routeName,
                //       builder: (context, state) => const RatingsScreen(),
                //     ),
                //     GoRoute(
                //       path: SocialScreen.routeName,
                //       builder: (context, state) => const SocialScreen(),
                //     ),
                //     GoRoute(
                //       path: SettingsScreen.routeName,
                //       builder: (context, state) => const SettingsScreen(),
                //     )
                //   ],
                // ),
                GoRoute(
                  path: AppShell.routeName,
                  builder: (context, state) {
                    final ShellContent? scaffoldScreen = state.extra as ShellContent?;
                    return AppShell(selectedContent: scaffoldScreen);
                  },
                ),
                GoRoute(
                  path: CategoryScreen.routeName,
                  builder: (context, state) {
                    final Category category = state.extra as Category;
                    return CategoryScreen(category: category);
                  },
                ),
                GoRoute(
                  path: GroupScreen.routeName,
                  builder: (context, state) {
                    final Group group = state.extra as Group;
                    return GroupScreen(group: group);
                  },
                ),
                GoRoute(
                  path: CreateGroupScreen.routeName,
                  builder: (context, state) => const CreateGroupScreen(),
                ),
                GoRoute(
                  path: JoinGroupScreen.routeName,
                  builder: (context, state) => const JoinGroupScreen(),
                ),
                GoRoute(
                  path: QrCodeScannerScreen.routeName,
                  builder: (context, state) => const QrCodeScannerScreen(),
                ),
                GoRoute(
                  path: ChooseGroupScreen.routeName,
                  builder: (context, state) => const ChooseGroupScreen(),
                ),
                GoRoute(
                  path: CreateCategoryScreen.routeName,
                  builder: (context, state) {
                    return const CreateCategoryScreen();
                  },
                ),
                GoRoute(
                  path: ChooseCategoryScreen.routeName,
                  builder: (context, state) => const ChooseCategoryScreen(),
                ),
                GoRoute(
                  path: ViewItemScreen.routeName,
                  builder: (context, state) {
                    final Item item = state.extra as Item;
                    return ViewItemScreen(item: item);
                  },
                ),
                GoRoute(
                  path: EditItemScreen.routeName,
                  builder: (context, state) {
                    final Item? itemToEdit = state.extra as Item?;
                    return EditItemScreen(itemToEdit: itemToEdit);
                  },
                ),
                GoRoute(
                  path: RateItemScreen.routeName,
                  builder: (context, state) {
                    // TODO: Use records with named parameters, if that is possible
                    final (Item item, Rating? rating) = state.extra as (Item, Rating?);
                    return RateItemScreen(item: item, rating: rating);
                  },
                ),
                GoRoute(
                  path: ZoomableImageScreen.routeName,
                  builder: (context, state) {
                    final Widget image = state.extra as Widget;
                    return ZoomableImageScreen(image: image);
                  },
                ),
                GoRoute(
                  path: WelcomeScreen.routeName,
                  builder: (context, state) => const WelcomeScreen(),
                ),
                GoRoute(
                  path: SignScreen.routeName,
                  builder: (context, state) {
                    final SignType? signType = state.extra as SignType?;
                    return SignScreen(signType: signType);
                  },
                ),
                GoRoute(
                  path: ForgotPasswordScreen.routeName,
                  builder: (context, state) => const ForgotPasswordScreen(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
