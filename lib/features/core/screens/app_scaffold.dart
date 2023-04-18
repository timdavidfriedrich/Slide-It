import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating/features/add/screens/add_screen.dart';
import 'package:rating/features/add/screens/choose_category_screen.dart';
import 'package:rating/features/categories/screens/categories_screen.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/screens/screen.dart';
import 'package:rating/features/home/home_screen.dart';
import 'package:rating/features/onboarding/screens/verify_screen.dart';
import 'package:rating/features/onboarding/screens/welcome_screen.dart';
import 'package:rating/features/profile/screens/profile_screen.dart';
import 'package:rating/features/settings/screens/settings_screen.dart';

class AppScaffold extends StatefulWidget {
  static const routeName = "/";
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;
  final List<Screen> _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  void _navigateToAdd() {
    Navigator.pushNamed(context, ChooseCategoryScreen.routeName);
  }

  @override
  void initState() {
    super.initState();
    Provider.of<DataProvider>(context, listen: false).loadData();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        // TODO: Find a solution (interupts the regular scaffold)
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
        // }
        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text("Error")));
        }
        if (snapshot.hasData) {
          bool isEmailVerified = snapshot.data!.isAnonymous || snapshot.data!.emailVerified;
          return !isEmailVerified
              ? const VerifyScreen()
              : SafeArea(
                  child: Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.macOS
                      ? CupertinoTabScaffold(
                          tabBar: CupertinoTabBar(
                            currentIndex: _selectedIndex,
                            onTap: (index) => setState(() => _selectedIndex = index),
                            items: List.generate(_screens.length, (index) {
                              return BottomNavigationBarItem(
                                icon: _screens[index].cupertinoIcon,
                                label: _screens[index].displayName,
                                tooltip: "",
                              );
                            }),
                          ),
                          tabBuilder: (context, index) {
                            return CupertinoTabView(
                              builder: (context) {
                                return CupertinoPageScaffold(
                                  navigationBar: CupertinoNavigationBar(
                                    middle: Text(_screens[_selectedIndex].displayName),
                                    trailing: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () => _navigateToAdd(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const AddScreen().icon,
                                          Text(const AddScreen().displayName),
                                        ],
                                      ),
                                    ),
                                  ),
                                  child: _screens[_selectedIndex] as Widget,
                                );
                              },
                            );
                          },
                        )
                      : Scaffold(
                          appBar: AppBar(title: Text(_screens[_selectedIndex].displayName)),
                          body: _screens[_selectedIndex] as Widget,
                          bottomNavigationBar: NavigationBar(
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
                          floatingActionButton: FloatingActionButton(onPressed: () => _navigateToAdd(), child: const AddScreen().icon),
                        ),
                );
        }
        return const WelcomeScreen();
      },
    );
  }
}
