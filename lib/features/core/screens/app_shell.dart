import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:log/log.dart';
import 'package:provider/provider.dart';
import 'package:rating/features/core/widgets/error_info.dart';
import 'package:rating/features/feed/screens/feed_screen.dart';
import 'package:rating/features/ratings/screens/edit_item_screen.dart';
import 'package:rating/features/ratings/screens/ratings_screen.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/shell_content.dart';
import 'package:rating/features/onboarding/screens/verify_screen.dart';
import 'package:rating/features/onboarding/screens/welcome_screen.dart';
import 'package:rating/features/social/screens/social_screen.dart';

class AppShell extends StatefulWidget {
  static const routeName = "/";
  final ShellContent? selectedContent;
  // final Widget child;
  const AppShell({super.key, this.selectedContent /*, required this.child*/});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final List<({ShellContent screen, String routeName})> _contents = const [
    (screen: FeedScreen(), routeName: FeedScreen.routeName),
    (screen: RatingsScreen(), routeName: RatingsScreen.routeName),
    (screen: SocialScreen(), routeName: SocialScreen.routeName),
    // (SettingsScreen(), SettingsScreen.routeName),
  ];

  bool _platformIsApple() {
    return Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.macOS;
  }

  void _selectScreen(int index) {
    setState(() => _selectedIndex = index);
    // context.go(_screens[index].routeName);
  }

  void _initSelectedIndex() {
    Log.debug("selectedScreen: ${widget.selectedContent}");
    if (widget.selectedContent == null) return;
    int selectedIndex = 0;
    selectedIndex = _contents.indexWhere((screen) => screen.runtimeType == widget.selectedContent.runtimeType);
    if (selectedIndex == -1) return;
    setState(() => _selectedIndex = selectedIndex);
  }

  void _navigateToAdd() {
    context.push(EditItemScreen.routeName);
  }

  Future<void> initData() async {
    await Provider.of<DataProvider>(context, listen: false).loadData();
  }

  @override
  void initState() {
    super.initState();
    _initSelectedIndex();
    initData();
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
                      title: Text(_contents[_selectedIndex].screen.displayName),
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
                    body: _contents[_selectedIndex].screen as Widget,
                    // body: widget.child,
                    bottomNavigationBar: _platformIsApple()
                        ? CupertinoTabBar(
                            currentIndex: _selectedIndex,
                            onTap: (index) => _selectScreen(index),
                            items: List.generate(_contents.length, (index) {
                              return BottomNavigationBarItem(
                                icon: _contents[index].screen.cupertinoIcon,
                                label: _contents[index].screen.displayName,
                                tooltip: "",
                              );
                            }),
                          )
                        : NavigationBar(
                            selectedIndex: _selectedIndex,
                            onDestinationSelected: (index) => _selectScreen(index),
                            destinations: List.generate(_contents.length, (index) {
                              return NavigationDestination(
                                icon: _contents[index].screen.icon,
                                label: _contents[index].screen.displayName,
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
