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
import 'package:flutter/rendering.dart';

import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:typed_data';
import 'dart:convert';

import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:convert';
import 'dart:typed_data';

import 'dart:convert';            
import 'dart:html' as html;       
import 'dart:js_util' as js_util; 
import 'dart:io';                 
import 'dart:math' as math;       
import 'dart:ui' as ui;           
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';





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
  // ── NATIVE (Android/iOS) ────────────────────────────────────
  if (!kIsWeb) {
    try {
      final boundary = _previewContainerKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(
        pixelRatio: ui.window.devicePixelRatio,
      );
      final bytes = (await image.toByteData(
        format: ui.ImageByteFormat.png,
      ))!
          .buffer
          .asUint8List();

      final tmpDir = await getTemporaryDirectory();
      final fname = 'ar_selfie_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tmpDir.path}/$fname');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Domo AR Selfie!',
        subject: fname,
      );
      return;
    } catch (e) {
      debugPrint('Native share failed: $e');
      await Share.share('Check out my AR selfie from Domo!');
      return;
    }
  }

  // ── WEB (Chrome on Android / Safari on iOS) ────────────────────
  // 1) Grab your <video> element and its on‐screen CSS size
  final videoEl = _webVideo!; // set in _initWebcam()
  final rect = videoEl.getBoundingClientRect();
  final cssW = rect.width;
  final cssH = rect.height;
  final dpr = html.window.devicePixelRatio;

  // 2) Create a high-res canvas and scale to CSS pixels
  final canvas = html.CanvasElement(
    width: (cssW * dpr).round(),
    height: (cssH * dpr).round(),
  );
  final ctx = canvas.context2D..scale(dpr, dpr);

  // 3) Compute “cover”‐style cropping
  final rawW = videoEl.videoWidth!;
  final rawH = videoEl.videoHeight!;
  final scaleCover = math.max(cssW / rawW, cssH / rawH);
  final srcW = cssW / scaleCover;
  final srcH = cssH / scaleCover;
  final srcX = (rawW - srcW) / 2;
  final srcY = (rawH - srcH) / 2;

  // 4) Mirror & draw the video
  ctx.save();
  ctx.translate(cssW, 0);
  ctx.scale(-1, 1);
  ctx.drawImageScaledFromSource(
    videoEl,
    srcX, srcY, srcW, srcH,
    0, 0, cssW, cssH,
  );
  ctx.restore();

  // 5) Snapshot & draw the <model-viewer> at your Flutter offset
  final modelEl = html.document.querySelector('model-viewer')!;
  final modelBlob = await js_util.promiseToFuture<html.Blob>(
    js_util.callMethod(modelEl, 'toBlob', [
      {'type': 'image/png'}
    ]),
  );
  final modelUrl = html.Url.createObjectUrlFromBlob(modelBlob);
  final img = html.ImageElement(src: modelUrl);
  await img.onLoad.first;
  // Compute exactly where Flutter put it:
  final modelSize = size;
  final modelLeft = (cssW - modelSize) / 2 + _modelOffset.dx;
  final modelTop = (cssH - modelSize) / 2 + _modelOffset.dy;
  ctx.drawImageScaled(img, modelLeft, modelTop, modelSize, modelSize);
  html.Url.revokeObjectUrl(modelUrl);

  // 6) Export canvas → PNG bytes
final dataUrl = canvas.toDataUrl('image/png');
final pngBytes = base64.decode(dataUrl.split(',').last);

// 7) Create the Blob & File
final fname = 'ar_selfie_${DateTime.now().millisecondsSinceEpoch}.png';
final blob = html.Blob([pngBytes], 'image/png');
final url = html.Url.createObjectUrlFromBlob(blob);

// 🔹 7a) Trigger download (must be inside gesture)
final anchor = html.document.createElement('a') as html.AnchorElement
  ..href = url
  ..download = fname;
html.document.body!.append(anchor);
anchor.click();
anchor.remove();
html.Url.revokeObjectUrl(url);

// 🔹 7b) Try to share immediately after
try {
  final file = html.File([blob], fname, {'type': 'image/png'});
  final shareData = {
    'files': [file],
    'title': fname,
    'text': 'Check out my AR Selfie from Domo!',
  };

  final nav = html.window.navigator;
  final canShare = js_util.hasProperty(nav, 'canShare') &&
      js_util.callMethod(nav, 'canShare', [shareData]) == true;

  if (canShare) {
    await js_util.promiseToFuture(js_util.callMethod(nav, 'share', [shareData]));
  }
} catch (e) {
  debugPrint('Web share() failed after download: $e');
}
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
            'DoMo AR',
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
          const SizedBox(height: 20), // 👈 Add this line

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '두모와 사진 찍어보세요!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),

    RepaintBoundary(
      key: _previewContainerKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
                        top: (stackH - size) / 2 + _modelOffset.dy,
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
      ),
    ),



          /*
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

          ElevatedButton.icon(
            onPressed: _onSharePressed,
            icon: const Icon(Icons.share),
            label: const Text('Share AR Selfie'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              side: const BorderSide(color: Color(0xFF9AA5B6)),
            ),
          ),

          */

           // ── move/rotate switch and save ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align to right
              children: [
                // Move/Rotate toggle
                Row(
                  children: [
                    Text(
                      _isMoveMode ? 'Move' : 'Rotate',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
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
                const SizedBox(width: 12), // minimal spacing between switch and button
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2AC57),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                    child: ElevatedButton.icon(
                      onPressed: _onSharePressed,
                      icon: const Icon(Icons.ios_share, size: 18),
                      label: const Text('AR 셀카 공유'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2AC57),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        // ↓↓↓ limit height to exactly 32px ↓↓↓
                        fixedSize: const Size.fromHeight(32),
                        // OR: minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // removes extra touch padding
                      ),
                    )
                  ),
                )

              ],
            ),
          ),



          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          const SizedBox(height: 24),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(child: Icon(Icons.share_outlined, size: 14, color: Colors.black54)),
                        TextSpan(text: ' 현재 공유는 iOS Safari, Android Chrome에서만 지원돼요.\n'),
                        WidgetSpan(child: Icon(Icons.computer_outlined, size: 14, color: Colors.black54)),
                        TextSpan(text: ' 데스크톱 브라우저는 아직 미지원이며, 열심히 준비 중이에요!\n\n'),
                        WidgetSpan(child: Icon(Icons.refresh, size: 14, color: Colors.black54)),
                        TextSpan(text: ' 카메라가 보이지 않으면 페이지를 새로고침 해보세요.'),
                      ],
                    ),
                    style: TextStyle(fontSize: 12, height: 1.6, color: Colors.black87),
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

