import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';

class JoinGroupScreen extends StatefulWidget {
  static const String routeName = "/JoinGroup";
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final TextEditingController _nameController = TextEditingController();

  bool _isInputValid = false;

  void _checkIfInputIsValid() {
    setState(() => _isInputValid = _nameController.text.isNotEmpty);
  }

  void _scanGroupId() {}

  void _cancel() {
    Navigator.pop(context);
  }

  void _joinGroup() {
    if (_nameController.text.isEmpty) return;
    CloudService.joinGroup(_nameController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: Constants.largePadding),
            Text("Gruppe beitreten", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: Constants.mediumPadding),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          onChanged: (text) => _checkIfInputIsValid(),
                          decoration: const InputDecoration(
                            labelText: "Gruppen-ID",
                          ),
                        ),
                      ),
                      const SizedBox(width: Constants.smallPadding),
                      IconButton(
                        onPressed: () => _scanGroupId(),
                        // * There is no PlatformIcons(context).qrcode
                        icon: const Icon(CupertinoIcons.qrcode),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(onPressed: _isInputValid ? () => _joinGroup() : null, child: const Text("Beitreten")),
            const SizedBox(height: Constants.smallPadding),
            TextButton(onPressed: () => _cancel(), child: const Text("Abbrechen")),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
