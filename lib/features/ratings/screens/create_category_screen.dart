import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';
import 'package:rating/features/ratings/screens/choose_group_screen.dart';
import 'package:rating/features/social/services/group.dart';

class CreateCategoryScreen extends StatefulWidget {
  static const String routeName = "/CreateCategory";
  final Group group;
  const CreateCategoryScreen({super.key, required this.group});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isInputValid = false;

  void _checkIfInputIsValid() {
    setState(() => _isInputValid = _nameController.text.isNotEmpty);
  }

  void _changeGroup() {
    context.push(ChooseGroupScreen.routeName);
  }

  void _createCategoryInGroup(Group group) {
    if (_nameController.text.isEmpty) return;
    CloudService.instance.createCategory(name: _nameController.text, group: group);
    context.pop();
  }

  void _cancel() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
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
                    // ! Inrupts the focus, because the the state updates
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
                      leading: widget.group.avatar,
                      title: Text(widget.group.name),
                      subtitle: const Text("(Tippen zum wechseln)"),
                      onTap: () => _changeGroup(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Constants.mediumPadding),
            ElevatedButton(onPressed: _isInputValid ? () => _createCategoryInGroup(widget.group) : null, child: const Text("Erstellen")),
            const SizedBox(height: Constants.smallPadding),
            TextButton(onPressed: () => _cancel(), child: const Text("Abbrechen")),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
