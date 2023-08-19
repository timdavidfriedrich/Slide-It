import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/data/cloud_data_service.dart';
import 'package:rating/features/core/widgets/error_dialog.dart';
import 'package:rating/features/social/screens/group/qr_code_scanner_screen.dart';

class JoinGroupScreen extends StatefulWidget {
  static const String routeName = "/JoinGroup";
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final TextEditingController _idController = TextEditingController();

  bool _isInputValid = false;

  void _checkIfInputIsValid() {
    setState(() => _isInputValid = _idController.text.isNotEmpty);
  }

  void _scanGroupId() async {
    final result = await context.push<String>(QrCodeScannerScreen.routeName);
    if (result == null) return;
    setState(() => _idController.text = result);
    _checkIfInputIsValid();
  }

  void _cancel() {
    context.pop();
  }

  void _joinGroup() async {
    if (_idController.text.isEmpty) return;
    final bool groupHasBeenJoined = await CloudService.instance.joinGroup(_idController.text);
    if (!mounted) return;
    if (!groupHasBeenJoined) {
      ErrorDialog.show(context, message: "You are already a member of this group.");
      return;
    }
    context.pop();
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
                          controller: _idController,
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
