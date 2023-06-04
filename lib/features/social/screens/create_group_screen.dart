import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';

class CreateGroupScreen extends StatefulWidget {
  static const String routeName = "/CreateGroup";
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isInputValid = false;

  void _checkIfInputIsValid() {
    setState(() => _isInputValid = _nameController.text.isNotEmpty);
  }

  void _createGroup() {
    if (_nameController.text.isEmpty) return;
    CloudService.instance.createGroup(_nameController.text);
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
            Text("Neue Gruppe erstellen", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: Constants.mediumPadding),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
                children: [
                  TextField(
                    controller: _nameController,
                    onChanged: (text) => _checkIfInputIsValid(),
                    decoration: const InputDecoration(
                      labelText: "Gruppenname",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Constants.mediumPadding),
            ElevatedButton(onPressed: _isInputValid ? () => _createGroup() : null, child: const Text("Erstellen")),
            const SizedBox(height: Constants.smallPadding),
            TextButton(onPressed: () => _cancel(), child: const Text("Abbrechen")),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
