import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;

@JS()
@staticInterop
extension type WindowExtension._(JSObject _) implements JSObject {
  external void postMessage(JSAny message, JSString targetOrigin);
}

extension WindowCasting on web.Window {
  WindowExtension get ext => this as WindowExtension;
}

class EditorController {
  web.HTMLIFrameElement? _iframe;
  void setIframe(web.HTMLIFrameElement iframe) {
    _iframe = iframe;
  }

  void sendMessage(dynamic msg) {
    final jsonMsg = jsonEncode(msg);
    final cw = _iframe?.contentWindow;
    if (cw == null) {
      debugPrint('Cannot send—window is null');
      return;
    }
    try {
      // targetOrigin matches editor server
      cw.ext.postMessage(jsonMsg.toJS, 'http://localhost:3005'.toJS);
      debugPrint('Message sent: $jsonMsg');
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final EditorController ctrl = EditorController();
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            ElevatedButton(
              onPressed:
                  () => ctrl.sendMessage({'type': 'test', 'data': 'Hello'}),
              child: Text('Send Message'),
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
