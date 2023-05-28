import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating/config/themes/theme_config.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/ratings/screens/edit_item_screen.dart';
import 'package:rating/features/ratings/screens/choose_category_screen.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/screens/app_scaffold.dart';
import 'package:rating/features/core/services/notification_service.dart';
import 'package:rating/features/onboarding/screens/forgot_password_screen.dart';
import 'package:rating/features/onboarding/screens/sign_screen.dart';
import 'package:rating/features/onboarding/screens/welcome_screen.dart';
import 'package:rating/features/ratings/screens/choose_group_screen.dart';
import 'package:rating/features/ratings/screens/view_item_screen.dart';
import 'package:rating/features/ratings/screens/rate_item_screen.dart';
import 'package:rating/features/social/screens/create_group_screen.dart';
import 'package:rating/features/social/screens/group_screen.dart';
import 'package:rating/features/social/screens/join_group_screen.dart';
import 'package:rating/features/social/screens/qr_code_scanner_screen.dart';
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
      ],
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return MaterialApp(
            title: "Slide it",
            debugShowCheckedModeBanner: false,
            theme: ThemeConfig.light(context, lightDynamic),
            darkTheme: ThemeConfig.dark(context, darkDynamic),
            navigatorKey: Global.navigatorState,
            initialRoute: AppScaffold.routeName,
            routes: {
              AppScaffold.routeName: (context) => const AppScaffold(),
              GroupScreen.routeName: (context) => const GroupScreen(),
              CreateGroupScreen.routeName: (context) => const CreateGroupScreen(),
              JoinGroupScreen.routeName: (context) => const JoinGroupScreen(),
              QrCodeScannerScreen.routeName: (context) => const QrCodeScannerScreen(),
              ChooseGroupScreen.routeName: (context) => const ChooseGroupScreen(),
              ChooseCategoryScreen.routeName: (context) => const ChooseCategoryScreen(),
              ViewItemScreen.routeName: (context) => const ViewItemScreen(),
              EditItemScreen.routeName: (context) => const EditItemScreen(),
              RateItemScreen.routeName: (context) => const RateItemScreen(),
              WelcomeScreen.routeName: (context) => const WelcomeScreen(),
              SignScreen.routeName: (context) => const SignScreen(),
              ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
            },
          );
        },
      ),
    );
  }
}
