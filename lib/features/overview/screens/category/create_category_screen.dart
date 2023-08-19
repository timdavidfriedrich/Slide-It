import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/cloud_service.dart';
import 'package:rating/features/overview/screens/group/choose_group_screen.dart';
import 'package:rating/features/social/models/group.dart';

class CreateCategoryScreen extends StatefulWidget {
  static const String routeName = "/CreateCategory";
  const CreateCategoryScreen({super.key});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isInputValid = false;
  Group? selectedGroup;

  void _checkIfInputIsValid() {
    setState(() => _isInputValid = _nameController.text.isNotEmpty);
  }

  void _changeGroup() {
    context.push(ChooseGroupScreen.routeName);
  }

  void _createCategory() {
    if (_nameController.text.isEmpty) return;
    if (selectedGroup == null) return;
    CloudService.instance.createCategory(name: _nameController.text, group: selectedGroup!);
    context.pop();
  }

  void _cancel() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    selectedGroup = Provider.of<DataProvider>(context).selectedGroup;
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
                      leading: selectedGroup?.avatar,
                      title: Text(selectedGroup?.name ?? "(Wähle eine Gruppe)"),
                      subtitle: selectedGroup == null ? null : const Text("(Tippen zum wechseln)"),
                      onTap: () => _changeGroup(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Constants.mediumPadding),
            ElevatedButton(onPressed: _isInputValid ? () => _createCategory() : null, child: const Text("Erstellen")),
            const SizedBox(height: Constants.smallPadding),
            TextButton(onPressed: () => _cancel(), child: const Text("Abbrechen")),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
