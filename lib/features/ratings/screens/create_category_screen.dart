import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';
import 'package:rating/features/core/widgets/error_info.dart';
import 'package:rating/features/ratings/screens/choose_group_screen.dart';
import 'package:rating/features/ratings/services/create_category_screen_arguments.dart';
import 'package:rating/features/social/services/group.dart';

class CreateCategoryScreen extends StatefulWidget {
  static const String routeName = "/CreateCategory";
  const CreateCategoryScreen({super.key});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isInputValid = false;

  Future<Group> _loadGroup() async {
    CreateCategoryScreenArguments arguments = ModalRoute.of(context)!.settings.arguments as CreateCategoryScreenArguments;
    return arguments.group;
  }

  void _checkIfInputIsValid() {
    setState(() => _isInputValid = _nameController.text.isNotEmpty);
  }

  void _changeGroup() {
    Navigator.pushNamed(context, ChooseGroupScreen.routeName);
  }

  void _createCategoryInGroup(Group group) {
    if (_nameController.text.isEmpty) return;
    CloudService.instance.createCategory(name: _nameController.text, group: group);
    Navigator.pop(context);
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadGroup(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorInfo(message: snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.data is! Group) return const ErrorInfo();
          Group group = Provider.of<DataProvider>(context).selectedGroup ?? snapshot.data as Group;
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: Constants.largePadding),
                  Text("Neue Kategorie erstellen", style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: Constants.mediumPadding),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
                      children: [
                        TextField(
                          controller: _nameController,
                          onChanged: (text) => _checkIfInputIsValid(),
                          decoration: const InputDecoration(
                            labelText: "Name der Kategorie",
                          ),
                        ),
                        const SizedBox(height: Constants.mediumPadding),
                        const Text("Für Gruppe:"),
                        const SizedBox(height: Constants.smallPadding),
                        Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            leading: group.avatar,
                            title: Text(group.name),
                            subtitle: const Text("(Tippen zum wechseln)"),
                            onTap: () => _changeGroup(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Constants.mediumPadding),
                  ElevatedButton(onPressed: _isInputValid ? () => _createCategoryInGroup(group) : null, child: const Text("Erstellen")),
                  const SizedBox(height: Constants.smallPadding),
                  TextButton(onPressed: () => _cancel(), child: const Text("Abbrechen")),
                  const SizedBox(height: Constants.largePadding),
                ],
              ),
            ),
          );
        });
  }
}
