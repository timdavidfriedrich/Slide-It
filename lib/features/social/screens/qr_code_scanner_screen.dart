import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rating/constants/constants.dart';

class QrCodeScannerScreen extends StatefulWidget {
  static const String routeName = "/QrCodeScanner";
  const QrCodeScannerScreen({super.key});

  @override
  State<QrCodeScannerScreen> createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends State<QrCodeScannerScreen> {
  bool _isTorchEnabled = false;
  MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  void _popWithInvitationGroupId(String invitationGroupId) {
    context.pop(invitationGroupId);
  }

  void _toggleTorch() async {
    await controller.toggleTorch();
    setState(() => _isTorchEnabled = !_isTorchEnabled);
  }

  void _processCapture(BarcodeCapture capture) {
    final List<Barcode> scannedBarcodes = capture.barcodes;
    String? invitationGroupId;
    for (final barcode in scannedBarcodes) {
      if (barcode.rawValue == null) continue;
      if (!barcode.rawValue!.startsWith("group--")) continue;
      invitationGroupId = barcode.rawValue;
    }
    if (invitationGroupId == null) return;
    _popWithInvitationGroupId(invitationGroupId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Scanne eine Einladung"),
        ),
        body: Column(
          children: [
            Expanded(
              child: MobileScanner(
                controller: controller,
                onDetect: (capture) => _processCapture(capture),
              ),
            ),
            const SizedBox(height: Constants.mediumPadding),
            TextButton.icon(
              onPressed: () => _toggleTorch(),
              icon: Icon(_isTorchEnabled ? CupertinoIcons.lightbulb_slash : CupertinoIcons.lightbulb_fill),
              label: Text("Licht ${_isTorchEnabled ? "aus" : "an"}"),
            ),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
