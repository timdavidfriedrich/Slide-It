import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rating/features/add/screens/add_screen.dart';
import 'package:rating/features/categories/screens/categories_screen.dart';
import 'package:rating/features/core/screen.dart';
import 'package:rating/features/home/home_screen.dart';
import 'package:rating/features/profile/screens/profile_screen.dart';
import 'package:rating/features/settings/screens/settings_screen.dart';
import 'package:rating/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RatingApp());
}

class RatingApp extends StatelessWidget {
  const RatingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Slide it",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      initialRoute: Root.routeName,
      routes: {
        Root.routeName: (context) => const Root(),
        AddScreen.routeName: (context) => const AddScreen(),
      },
    );
  }
}

class Root extends StatefulWidget {
  static const routeName = "/";
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int _selectedIndex = 0;
  final List<Screen> _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  void _add() {
    Navigator.pushNamed(context, AddScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                        trailing: FilledButton.icon(
                          onPressed: () => _add(),
                          icon: const AddScreen().cupertinoIcon,
                          label: Text(const AddScreen().displayName),
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
              floatingActionButton: FloatingActionButton(onPressed: () => _add(), child: const AddScreen().icon),
            ),
    );
  }
}
