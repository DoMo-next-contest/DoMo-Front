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
import 'dart:async';
import 'dart:html' as html; // Only used for web
import 'dart:js_util' as js_util;
import 'dart:io' as io; // only used for native






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

    const flagKey = 'selfiePageHasReloaded';

    
      final hasReloaded = html.window.sessionStorage[flagKey] == 'true';
      if (!hasReloaded) {
        html.window.sessionStorage[flagKey] = 'true';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          html.window.location.reload();
        });
      }
    

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
    
    html.window.sessionStorage.remove('hasReloaded');
    super.dispose();
  }

Future<void> _onSharePressed() async {
  if (!kIsWeb) {
    // ── Native Android/iOS ───────────────────────────────────
    try {
      final boundary = _previewContainerKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(
        pixelRatio: ui.window.devicePixelRatio,
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final tmpDir = await getTemporaryDirectory();
      final fname = 'ar_selfie_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = io.File('${tmpDir.path}/$fname');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Domo AR Selfie!',
        subject: fname,
      );
    } catch (e) {
      debugPrint('Native share failed: $e');
      await Share.share('Check out my AR selfie from Domo!');
    }
    return;
  }

  // ── Web (Chrome/Safari) ───────────────────────────────────
  final videoEl = _webVideo!;
  final box = _previewContainerKey.currentContext!.findRenderObject() as RenderBox;
  final logicalSize = box.size;
  final dpr = html.window.devicePixelRatio;
  final width = (logicalSize.width * dpr).round();
  final height = (logicalSize.height * dpr).round();

  final canvas = html.CanvasElement(width: width, height: height);
  final ctx = canvas.context2D..scale(dpr, dpr);

  // Webcam video resolution
  final rawW = videoEl.videoWidth!;
  final rawH = videoEl.videoHeight!;

  // Compute scale to cover the canvas (object-fit: cover)
  final scale = math.max(
    logicalSize.width / rawW,
    logicalSize.height / rawH,
  );
  final drawW = rawW * scale;
  final drawH = rawH * scale;
  final dx = (drawW - logicalSize.width) / 2;
  final dy = (drawH - logicalSize.height) / 2;

  // Mirror and draw the video
  ctx.save();
  ctx.translate(logicalSize.width, 0);
  ctx.scale(-1, 1); // mirror
  ctx.drawImageScaled(
    videoEl,
    -dx,
    -dy,
    drawW,
    drawH,
  );
  ctx.restore();

  // Draw model-viewer snapshot
  final modelEl = html.document.querySelector('model-viewer')!;
  final modelBlob = await js_util.promiseToFuture<html.Blob>(
    js_util.callMethod(modelEl, 'toBlob', [{'type': 'image/png'}]),
  );
  final modelUrl = html.Url.createObjectUrlFromBlob(modelBlob);
  final img = html.ImageElement();
  final loadCompleter = Completer<void>();
  img.onLoad.listen((_) => loadCompleter.complete());
  img.src = modelUrl;
  await loadCompleter.future;

  final modelLeft = (logicalSize.width - size) / 2 + _modelOffset.dx;
  final modelTop = (logicalSize.height - size) / 2 + _modelOffset.dy;
  ctx.drawImageScaled(img, modelLeft, modelTop, size, size);
  html.Url.revokeObjectUrl(modelUrl);

  await html.window.animationFrame;

  // Export PNG
  final dataUrl = canvas.toDataUrl('image/png');
  final pngBytes = base64.decode(dataUrl.split(',').last);

  final fname = 'ar_selfie_${DateTime.now().millisecondsSinceEpoch}.png';
  final blob = html.Blob([pngBytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);

  // Trigger download
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..download = fname;
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();

  // Optional: Show popup/toast
  if (mounted) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 200),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.download_done, size: 48, color: Color(0xFFF2AC57)),
              const SizedBox(height: 16),
              const Text(
                '이미지가 다운로드되었습니다.\n공유를 위해 앨범에서 확인하세요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2AC57),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Try to share (Android Chrome only)
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
    debugPrint('Web share failed after download: $e');
  }

  html.Url.revokeObjectUrl(url);
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
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // When the user taps the AppBar back button, go to dashboard
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
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

