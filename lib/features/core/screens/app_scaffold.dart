import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:rating/features/core/services/app_scaffold_arguments.dart';
import 'package:rating/features/core/widgets/error_info.dart';
import 'package:rating/features/ratings/screens/edit_item_screen.dart';
import 'package:rating/features/ratings/screens/ratings_screen.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/scaffold_screen.dart';
import 'package:rating/features/onboarding/screens/verify_screen.dart';
import 'package:rating/features/onboarding/screens/welcome_screen.dart';
import 'package:rating/features/settings/screens/settings_screen.dart';
import 'package:rating/features/social/screens/social_screen.dart';

class AppScaffold extends StatefulWidget {
  static const routeName = "/";
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;
  final List<ScaffoldScreen> _screens = const [
    // HomeScreen(),
    RatingsScreen(),
    SocialScreen(),
    SettingsScreen(),
  ];

  bool _platformIsApple() {
    return Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.macOS;
  }

  void _initSelectedIndex() {
    AppScaffoldArguments? arguments = ModalRoute.of(context)!.settings.arguments as AppScaffoldArguments?;
    int selectedIndex = 0;
    if (arguments != null) {
      selectedIndex = _screens.indexWhere((screen) => screen.runtimeType == arguments.selectedScreen.runtimeType);
      if (selectedIndex != -1) {
        setState(() => _selectedIndex = selectedIndex);
      }
    }
  }

  void _navigateToAdd() {
    Navigator.pushNamed(context, EditItemScreen.routeName);
  }

  Future<void> initData() async {
    await Provider.of<DataProvider>(context, listen: false).loadData();
  }

  @override
  void initState() {
    super.initState();
    initData();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initSelectedIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        // TODO: Find a solution (interupts the regular scaffold).
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
        // }
        if (snapshot.hasError) {
          return ErrorInfo(message: snapshot.error.toString());
        }
        if (snapshot.hasData) {
          if (snapshot.data is! User) return const ErrorInfo();
          bool isEmailVerified = snapshot.data!.isAnonymous || snapshot.data!.emailVerified;
          return !isEmailVerified
              ? const VerifyScreen()
              : SafeArea(
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(_screens[_selectedIndex].displayName),
                      titleSpacing: 32,
                      actions: [
                        if (_platformIsApple())
                          FilledButton(
                            onPressed: () => _navigateToAdd(),
                            child: Row(
                              children: [const EditItemScreen().icon, const Text("Objekt")],
                            ),
                          ),
                        const SizedBox(width: 32),
                      ],
                    ),
                    body: _screens[_selectedIndex] as Widget,
                    bottomNavigationBar: _platformIsApple()
                        ? CupertinoTabBar(
                            currentIndex: _selectedIndex,
                            onTap: (index) => setState(() => _selectedIndex = index),
                            items: List.generate(_screens.length, (index) {
                              return BottomNavigationBarItem(
                                icon: _screens[index].cupertinoIcon,
                                label: _screens[index].displayName,
                                tooltip: "",
                              );
                            }),
                          )
                        : NavigationBar(
                            selectedIndex: _selectedIndex,
                            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                            destinations: List.generate(_screens.length, (index) {
                              return NavigationDestination(
                                icon: _screens[index].icon,
                                label: _screens[index].displayName,
                                tooltip: "",
                              );
                            }),
                          ),
                    floatingActionButton: _platformIsApple()
                        ? null
                        : FloatingActionButton(onPressed: () => _navigateToAdd(), child: const EditItemScreen().icon),
                  ),
                );
        }
        return const WelcomeScreen();
      },
    );
  }
}
