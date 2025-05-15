import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:html' as html;  // ← add at top, only for web
import 'dart:html' as html;  
import 'package:share_plus/share_plus.dart';

import 'dart:io';
import 'dart:ui' as ui;                    // for ImageByteFormat & window.devicePixelRatio
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';



// Mobile camera
import 'package:camera/camera.dart';

// 3D model viewer
import 'package:model_viewer_plus/model_viewer_plus.dart';

// Your item service
import 'package:domo/services/item_service.dart';

// Web-only imports
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: undefined_prefixed_name
import 'dart:ui' as ui;



class SelfiePage extends StatefulWidget {
  const SelfiePage({Key? key}) : super(key: key);

  @override
  _SelfiePageState createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  final GlobalKey _previewContainerKey = GlobalKey();


  // Mobile camera
  CameraController? _cameraController;
  bool _cameraInitialized = false;

  // Web video
  html.VideoElement? _webVideo;
  bool _webInitialized = false;

  // Model overlay
  String? _modelSrc;
  bool _modelLoading = true;
  double size = 200;


  // Move vs Rotate mode
  bool _isMoveMode = false;
  Offset _modelOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initWebcam();
    } else {
      _initCamera();
    }
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      final item = await ItemService.fetchRecentEquippedItem();
      await ItemService.equipItem(item.id);
      setState(() => _modelSrc = item.imageUrl);
    } catch (_) {
      final fallback = await ItemService.getItemById(9);
      setState(() => _modelSrc = fallback.imageUrl);
    } finally {
      setState(() => _modelLoading = false);
    }
  }

  Future<void> _initCamera() async {
    final cams = await availableCameras();
    final front = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cams.first,
    );
    _cameraController = CameraController(
      front,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() => _cameraInitialized = true);
  }

  Future<void> _initWebcam() async {
  _webVideo = html.VideoElement()
    ..autoplay = true
    ..muted = true
    // keep playback inline on iOS and Android
    ..setAttribute('playsinline', '')        
    ..setAttribute('webkit-playsinline', '')  
    // hide any native controls
    ..controls = false                         
    ..style.objectFit = 'cover'
    ..style.transform = 'scaleX(-1)';

  try {
    final stream = await html.window.navigator.mediaDevices!
        .getUserMedia({'video': true});
    _webVideo!.srcObject = stream;

    // register for Flutter Web
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'webcamElement',
      (int _) => _webVideo!,
    );

    setState(() => _webInitialized = true);
  } catch (e) {
    debugPrint('Web camera error: $e');
  }
}
  @override
  void dispose() {
    if (kIsWeb) {
      _webVideo?.srcObject?.getTracks().forEach((t) => t.stop());
    } else {
      _cameraController?.dispose();
    }
    super.dispose();
  }

  Future<void> _onSharePressed() async {
    // Simple text share; you can also share files (images/screenshots) via Share.shareXFiles
    await Share.share(
      'Check out my AR selfie from Domo! 📸',
      subject: 'My Domo AR Selfie'
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget preview = _cameraInitialized && _cameraController != null
        ? Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: CameraPreview(_cameraController!),
          )
        : const Center(child: CircularProgressIndicator());

    if (kIsWeb) {
      preview = _webInitialized
          ? const HtmlElementView(viewType: 'webcamElement')
          : const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,  // ← make the bar itself white
        elevation: 0,                   // optional: remove shadow if you want
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: const BackButton(),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'AR with Domo',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
      ),


      body: Column(
        children: [
          // ── camera + model preview, max 300px tall ───────────────
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 500,    // ← won’t grow taller than this
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final stackW = constraints.maxWidth;
                    final stackH = constraints.maxHeight;

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        preview,

                        Positioned(
                          left: (stackW - size) / 2 + _modelOffset.dx,
                          top:  (stackH - size) / 2 + _modelOffset.dy,
                          width: size,
                          height: size,
                          child: AbsorbPointer(
                            absorbing: _isMoveMode,
                            child: ModelViewer(
                              key: const ValueKey('decoOverlay'),
                              src: _modelSrc!,
                              alt: 'Deco Overlay',
                              cameraControls: !_isMoveMode,
                              autoRotate: !_isMoveMode,
                              disableZoom: true,
                              disablePan: true,
                              disableTap: true,
                              backgroundColor: Colors.transparent,
                              shadowIntensity: 0.0,

                             

        // ── turn off all AR on native ───────────────────────────
        ar: false,
        arModes: const [],

        
                            ),
                          ),
                        ),

                        if (_isMoveMode)
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onPanUpdate: (details) =>
                                  setState(() => _modelOffset += details.delta),
                            ),
                          ),

                        if (_modelLoading)
                          const Center(child: CircularProgressIndicator()),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // ── move/rotate switch ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 0, bottom: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isMoveMode ? 'Move' : 'Rotate',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isMoveMode,
                    onChanged: (v) {
                      setState(() => _isMoveMode = v);
                      if (kIsWeb) {
                        html.document
                            .querySelectorAll('model-viewer')
                            .forEach((el) {
                          (el as html.HtmlElement).style.pointerEvents =
                              v ? 'none' : 'auto';
                        });
                      }
                    },
                    activeColor: const Color(0xFFF2AC57),
                    activeTrackColor: Colors.grey.shade300,
                    inactiveThumbColor: Colors.grey.shade400,
                    inactiveTrackColor: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
          ),

          
        ],
      ),
    );
  }
}
