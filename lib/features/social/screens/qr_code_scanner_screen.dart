import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:log/log.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rating/constants/constants.dart';

class QrCodeScannerScreen extends StatefulWidget {
  static const String routeName = "/QrCodeScanner";
  const QrCodeScannerScreen({super.key});

  @override
  State<QrCodeScannerScreen> createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends State<QrCodeScannerScreen> {
  bool _torchIsEnabled = false;
  bool _hasDetected = false;
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  void _popWithInvitationGroupId(String invitationGroupId) {
    Log.hint("Scanned QR Code with invitationGroupId: $invitationGroupId");
    context.pop(invitationGroupId);
  }

  void _toggleTorch() async {
    await _controller.toggleTorch();
    setState(() => _torchIsEnabled = !_torchIsEnabled);
  }

  void _processCapture(BarcodeCapture capture) {
    final List<Barcode> scannedBarcodes = capture.barcodes;
    String? invitationGroupId;
    for (final Barcode barcode in scannedBarcodes) {
      bool barcodeHasNoGroupId = !(barcode.rawValue?.startsWith("group--") ?? false);
      if (barcodeHasNoGroupId) continue;
      invitationGroupId = barcode.rawValue;
    }
    if (invitationGroupId == null) return;
    if (_hasDetected) return;
    _hasDetected = true;
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
                controller: _controller,
                onDetect: (capture) => _processCapture(capture),
              ),
            ),
            const SizedBox(height: Constants.mediumPadding),
            TextButton.icon(
              onPressed: () => _toggleTorch(),
              icon: Icon(_torchIsEnabled ? CupertinoIcons.lightbulb_slash : CupertinoIcons.lightbulb_fill),
              label: Text("Licht ${_torchIsEnabled ? "aus" : "an"}"),
            ),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
