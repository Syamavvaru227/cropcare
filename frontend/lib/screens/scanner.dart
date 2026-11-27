import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import '../core/theme/app_theme.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';
import 'library.dart';

Uint8List prepareImage(Uint8List raw) {
  if (raw.length > 8 * 1024 * 1024) {
    throw StateError('badImage');
  }
  final decoder = img.findDecoderForData(raw);
  if (decoder is! img.JpegDecoder &&
      decoder is! img.PngDecoder &&
      decoder is! img.WebPDecoder) {
    throw StateError('badImage');
  }
  final info = decoder?.startDecode(raw);
  if (info == null ||
      info.width * info.height > 16000000 ||
      info.width < 64 ||
      info.height < 64) {
    throw StateError('badImage');
  }
  var image = decoder!.decode(raw);
  if (image == null) {
    throw StateError('badImage');
  }
  image = img.bakeOrientation(image);
  if (image.width > 1024 || image.height > 1024) {
    image = img.copyResize(
      image,
      width: image.width >= image.height ? 1024 : null,
      height: image.height > image.width ? 1024 : null,
    );
  }
  // Re-encode to strip location/EXIF data before storage or upload.
  image.exif.clear();
  return Uint8List.fromList(img.encodeJpg(image, quality: 82));
}

class ScannerScreen extends StatefulWidget {
  final AppState state;
  final bool galleryFirst;
  const ScannerScreen({
    super.key,
    required this.state,
    this.galleryFirst = false,
  });
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  CameraController? camera;
  Uint8List? image;
  bool opening = false, busy = false, torch = false;
  int scenario = 0, stage = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.galleryFirst) {
      WidgetsBinding.instance.addPostFrameCallback((_) => gallery());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    camera?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final old = camera;
      camera = null;
      old?.dispose();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> openCamera() async {
    setState(() => opening = true);
    CameraController? next;
    try {
      final devices = await availableCameras();
      if (devices.isEmpty) {
        throw StateError('camera');
      }
      next = CameraController(
        devices.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => devices.first,
        ),
        ResolutionPreset.high,
        enableAudio: false,
      );
      await next.initialize();
      if (!mounted) {
        await next.dispose();
        return;
      }
      await camera?.dispose();
      setState(() {
        camera = next;
        image = null;
        torch = false;
      });
    } catch (_) {
      await next?.dispose();
      if (mounted) {
        toast(context, 'cameraError');
      }
    } finally {
      if (mounted) {
        setState(() => opening = false);
      }
    }
  }

  Future<void> accept(XFile file) async {
    if (await file.length() > 8 * 1024 * 1024) {
      throw StateError('badImage');
    }
    final bytes = await compute(prepareImage, await file.readAsBytes());
    await camera?.dispose();
    camera = null;
    if (mounted) {
      setState(() => image = bytes);
    }
  }

  Future<void> gallery() async {
    if (busy) {
      return;
    }
    setState(() => busy = true);
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null) {
        await accept(file);
      }
    } catch (_) {
      if (mounted) {
        toast(context, 'badImage');
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  Future<void> capture() async {
    if (camera == null || busy) {
      return;
    }
    setState(() => busy = true);
    try {
      await accept(await camera!.takePicture());
    } catch (_) {
      if (mounted) {
        toast(context, 'cameraError');
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  Future<void> analyze() async {
    if (image == null || busy) {
      return;
    }
    setState(() {
      busy = true;
      stage = 1;
    });
    try {
      if (widget.state.demo) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      if (!mounted) {
        return;
      }
      setState(() => stage = 2);
      final result = await widget.state.repository.analyze(image!, scenario);
      if (!mounted) {
        return;
      }
      setState(() => stage = 3);
      await widget.state.refresh();
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiseaseScreen(
              state: widget.state,
              disease: widget.state.disease(result.diseaseId),
              result: result,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        toast(context, e is StateError ? 'storageFull' : 'offline');
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
          stage = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Scaffold(
      appBar: AppBar(
        title: Text(context.tr('scanCrop')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: Text(context.tr(widget.state.demo ? 'demo' : 'live')),
            ),
          ),
        ],
      ),
      body: PageBody(
        children: [
          Heading(
            context.tr(
              stage > 0
                  ? 'processing'
                  : image == null
                  ? 'scannerTitle'
                  : 'preview',
            ),
          ),
          if (widget.state.demo)
            Notice(context.tr('demoNotice'), warning: true),
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 330,
              color: forest,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (image != null)
                    Positioned.fill(
                      child: Image.memory(image!, fit: BoxFit.contain),
                    )
                  else if (camera?.value.isInitialized == true)
                    Center(
                      child: AspectRatio(
                        aspectRatio: camera!.value.aspectRatio,
                        child: CameraPreview(camera!),
                      ),
                    )
                  else
                    const Icon(Icons.eco_outlined, color: sage, size: 120),
                  if (image == null)
                    Container(
                      width: 230,
                      height: 270,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ivory.withValues(alpha: .8),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(48),
                      ),
                    ),
                  if (stage > 0)
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LinearProgressIndicator(color: gold),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('scanInstructions'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (stage > 0) ...[
            const SizedBox(height: 24),
            Text(context.tr('stage$stage')),
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 22),
          if (image == null) ...[
            if (camera?.value.isInitialized == true) ...[
              FilledButton.icon(
                onPressed: busy ? null : capture,
                icon: const Icon(Icons.camera),
                label: Text(context.tr('capture')),
              ),
              TextButton.icon(
                onPressed: busy
                    ? null
                    : () async {
                        try {
                          await camera!.setFlashMode(
                            torch ? FlashMode.off : FlashMode.torch,
                          );
                          if (mounted) {
                            setState(() => torch = !torch);
                          }
                        } catch (_) {
                          if (context.mounted) {
                            toast(context, 'cameraError');
                          }
                        }
                      },
                icon: Icon(torch ? Icons.flash_on : Icons.flash_off),
                label: Text(context.tr('flash')),
              ),
            ] else
              FilledButton.icon(
                onPressed: opening || busy ? null : openCamera,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(context.tr('openCamera')),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: busy ? null : gallery,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(context.tr('gallery')),
            ),
          ] else ...[
            if (widget.state.demo) ...[
              Text(context.tr('scenario')),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: scenario,
                isExpanded: true,
                items: List.generate(
                  3,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(
                      context.tr(
                        ['scenarioEarly', 'scenarioHealthy', 'scenarioLow'][i],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                onChanged: busy ? null : (v) => setState(() => scenario = v!),
              ),
              const SizedBox(height: 18),
            ],
            FilledButton.icon(
              onPressed: busy ? null : analyze,
              icon: const Icon(Icons.document_scanner_outlined),
              label: Text(context.tr('analyze')),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              children: [
                TextButton(
                  onPressed: busy ? null : openCamera,
                  child: Text(context.tr('retake')),
                ),
                TextButton(
                  onPressed: busy ? null : gallery,
                  child: Text(context.tr('changeImage')),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}
