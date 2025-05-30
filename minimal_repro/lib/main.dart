import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;

@JS('jsMyx')
external JSObject get jsMyx;

extension JsMyxExt on JSObject {
  external void postMessage(web.HTMLIFrameElement iframe, String msg);
}

class EditorController {
  web.HTMLIFrameElement? _iframe;
  bool _iframeLoaded = false;
  final _messageQueue = <Map<String, dynamic>>[];

  void setIframe(web.HTMLIFrameElement iframe) {
    _iframe = iframe;
    _setupListeners(iframe);
  }

  void _setupListeners(web.HTMLIFrameElement iframe) {
    iframe.onLoad.listen((_) {
      _iframeLoaded = true;
      _processQueue();
    });

    web.window.onMessage.listen((event) {
      if (event.origin == 'http://localhost:3005') {
        try {
          final data =
              event.data is JSString
                  ? (event.data as JSString).toDart
                  : event.data.toString();

          final decodedData = jsonDecode(data);
          if (decodedData['type'] == 'iframeLoaded') {
            _iframeLoaded = true;
            _processQueue();
          }
        } catch (e) {
          debugPrint('Message parse error: $e');
        }
      }
    });
  }

  void _processQueue() {
    if (!_iframeLoaded || _iframe == null) return;

    for (final msg in _messageQueue) {
      sendMessage(msg);
    }
    _messageQueue.clear();
  }

  void sendMessage(Map<String, dynamic> msg) {
    if (!_iframeLoaded) {
      _messageQueue.add(msg);
      return;
    }

    try {
      if (_iframe == null) return;
      JsMyxExt(jsMyx).postMessage(_iframe!, jsonEncode(msg));
    } catch (e) {
      debugPrint('Send error: $e');
    }
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final EditorController ctrl = EditorController();

  MyApp({super.key});

  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            ElevatedButton(
              onPressed:
                  () => ctrl.sendMessage({'type': 'test', 'data': 'Hello'}),
              child: const Text('Send Message'),
            ),
            Expanded(child: EditorWebView(controller: ctrl)),
          ],
        ),
      ),
    );
  }
}

class EditorWebView extends StatefulWidget {
  final EditorController controller;
  const EditorWebView({required this.controller, super.key});

  @override
  State<EditorWebView> createState() => _EditorWebViewState();
}

class _EditorWebViewState extends State<EditorWebView> {
  late final String viewId;
  late final web.HTMLIFrameElement iframe;

  @override
  void initState() {
    super.initState();
    viewId = 'editor-iframe-${UniqueKey()}';
    iframe =
        web.document.createElement('iframe') as web.HTMLIFrameElement
          ..id = viewId
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..src = 'http://localhost:3005/editor.html';

    ui_web.platformViewRegistry.registerViewFactory(viewId, (i) => iframe);
    widget.controller.setIframe(iframe);
  }

  @override
  Widget build(BuildContext c) =>
      SizedBox.expand(child: HtmlElementView(viewType: viewId));
}
