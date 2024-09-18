import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_epub_viewer/src/epub_controller.dart';
import 'package:flutter_epub_viewer/src/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class EpubViewer extends StatefulWidget {
  const EpubViewer({
    super.key,
    required this.epubController,
    required this.epubUrl,
    this.headers,
    this.initialCfi,
    this.onChaptersLoaded,
    this.onEpubLoaded,
    this.onRelocated,
    this.onTextSelected,
    this.displaySettings,
    this.selectionContextMenu,
    this.fontSize,
  });

  ///Epub controller to manage epub
  final EpubController epubController;

  ///Epub url to load epub from network
  final String epubUrl;

  ///Epub headers to load epub from network
  final Map<String, String>? headers;

  ///Initial cfi string to  specify which part of epub to load initially
  ///if null, the first chapter will be loaded
  final String? initialCfi;

  ///Call back when epub is loaded and displayed
  final VoidCallback? onEpubLoaded;

  ///Call back when chapters are loaded
  final ValueChanged<List<EpubChapter>>? onChaptersLoaded;

  ///Call back when epub page changes
  final ValueChanged<EpubLocation>? onRelocated;

  ///Call back when text selection changes
  final ValueChanged<EpubTextSelection>? onTextSelected;

  ///initial display settings
  final EpubDisplaySettings? displaySettings;

  ///initial display settings
  final int? fontSize;

  ///context menu for text selection
  ///if null, the default context menu will be used
  final ContextMenu? selectionContextMenu;

  @override
  State<EpubViewer> createState() => _EpubViewerState();
}

class _EpubViewerState extends State<EpubViewer> {
  final GlobalKey webViewKey = GlobalKey();

  final LocalServerController localServerController = LocalServerController();

  // late PullToRefreshController pullToRefreshController;
  // late ContextMenu contextMenu;
  var selectedText = '';
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(true);

  InAppWebViewController? webViewController;

  @override
  void initState() {
    // widget.epubController.initServer();
    super.initState();
  }

  @override
  void didUpdateWidget(EpubViewer oldWidget) {
    if (oldWidget.fontSize != widget.fontSize) {
      _isLoading.value = true;
    }
    super.didUpdateWidget(oldWidget);
  }

  addJavaScriptHandlers() {
    webViewController?.addJavaScriptHandler(
        handlerName: "displayed",
        callback: (data) {
          _isLoading.value = false;
          widget.onEpubLoaded?.call();
        });

    webViewController?.addJavaScriptHandler(
        handlerName: "rendered",
        callback: (data) {
          // widget.onEpubLoaded?.call();
        });

    webViewController?.addJavaScriptHandler(
        handlerName: "chapters",
        callback: (data) async {
          final chapters = await widget.epubController.parseChapters();
          widget.onChaptersLoaded?.call(chapters);
        });

    ///selection handler
    webViewController?.addJavaScriptHandler(
        handlerName: "selection",
        callback: (data) {
          var cfiString = data[0];
          var selectedText = data[1];
          widget.onTextSelected?.call(EpubTextSelection(
              selectedText: selectedText, selectionCfi: cfiString));
        });

    ///search callback
    webViewController?.addJavaScriptHandler(
        handlerName: "search",
        callback: (data) async {
          var searchResult = data[0];
          widget.epubController.searchResultCompleter.complete(
              List<EpubSearchResult>.from(
                  searchResult.map((e) => EpubSearchResult.fromJson(e))));
        });

    ///current cfi callback
    webViewController?.addJavaScriptHandler(
        handlerName: "relocated",
        callback: (data) {
          var location = data[0];
          widget.onRelocated?.call(EpubLocation.fromJson(location));
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: localServerController.initServer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container();
          }

          final displaySettings = jsonEncode(widget.displaySettings?.toJson() ??
              EpubDisplaySettings().toJson());

          final headers = jsonEncode(widget.headers);

          // Convert the string to a list of bytes using UTF-8 encoding
          List<int> bytes = utf8.encode(widget.epubUrl);

          // Encode the list of bytes to a Base64 string
          String base64String = base64.encode(bytes);

          return ValueListenableBuilder(
              valueListenable: _isLoading,
              builder: (_, isLoading, __) {
                return Stack(
                  children: [
                    InAppWebView(
                      contextMenu: widget.selectionContextMenu,
                      key: webViewKey,
                      initialUrlRequest: URLRequest(
                          url: WebUri(
                              'http://localhost:8001/html/swipe.html?epubUrl=${base64String}&cfi=${widget.initialCfi ?? ''}&displaySettings=$displaySettings&headers=$headers')),
                      // initialSettings: InAppWebViewSettings(
                      //   isInspectable: kDebugMode,
                      //   javaScriptEnabled: true,
                      //   mediaPlaybackRequiresUserGesture: false,
                      //   transparentBackground: true,
                      //   supportZoom: false,
                      //   builtInZoomControls: false,
                      //   displayZoomControls: false,
                      //   allowsInlineMediaPlayback: true,
                      //   disableLongPressContextMenuOnLinks: false,
                      //   iframeAllowFullscreen: true,
                      //   allowsLinkPreview: false,
                      //   verticalScrollBarEnabled: false,
                      //   defaultFontSize: widget.fontSize,
                      //   selectionGranularity: SelectionGranularity.CHARACTER,
                      // ),
                      // pullToRefreshController: pullToRefreshController,
                      androidOnPermissionRequest:
                          (InAppWebViewController controller, String origin,
                              List<String> resources) async {
                        return PermissionRequestResponse(
                            resources: resources,
                            action: PermissionRequestResponseAction.GRANT);
                      },
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          disableVerticalScroll: true,
                          disableHorizontalScroll: false,
                          supportZoom: false,
                          mediaPlaybackRequiresUserGesture: false,
                          javaScriptEnabled: true,
                          userAgent:
                              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36',
                        ),
                        android: AndroidInAppWebViewOptions(
                          overScrollMode:
                              AndroidOverScrollMode.OVER_SCROLL_NEVER,
                          defaultFontSize: widget.fontSize ?? 16,
                          builtInZoomControls:
                              false, // Disable built-in zoom controls
                          displayZoomControls: false, // Hide zoom controls
                          useHybridComposition:
                              true, // Enable hybrid composition to improve performance on Android
                        ),
                        ios: IOSInAppWebViewOptions(
                          allowsInlineMediaPlayback: true,
                          allowsAirPlayForMediaPlayback: true,
                        ),
                      ),
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                        widget.epubController.setWebViewController(controller);
                        addJavaScriptHandlers();
                      },
                      // onPermissionRequest: (controller, request) async {
                      //   return PermissionResponse(
                      //       resources: request.resources,
                      //       action: PermissionResponseAction.GRANT);
                      // },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        var uri = navigationAction.request.url!;

                        if (![
                          "http",
                          "https",
                          "file",
                          "chrome",
                          "data",
                          "javascript",
                          "about"
                        ].contains(uri.scheme)) {
                          // if (await canLaunchUrl(uri)) {
                          //   // Launch the App
                          //   await launchUrl(
                          //     uri,
                          //   );
                          //   // and cancel the request
                          //   return NavigationActionPolicy.CANCEL;
                          // }
                        }

                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStart: (controller, url) async {},
                      onLoadStop: (controller, url) async {},
                      // onReceivedError: (controller, request, error) {},
                      onProgressChanged: (controller, progress) {},
                      onUpdateVisitedHistory:
                          (controller, url, androidIsReload) {},
                      onConsoleMessage: (controller, consoleMessage) {
                        if (kDebugMode) {
                          debugPrint("JS_LOG: ${consoleMessage.message}");
                          // debugPrint(consoleMessage.message);
                        }
                      },
                      gestureRecognizers: {
                        Factory<VerticalDragGestureRecognizer>(
                            () => VerticalDragGestureRecognizer()),
                        Factory<LongPressGestureRecognizer>(() =>
                            LongPressGestureRecognizer(
                                duration: const Duration(milliseconds: 30))),
                      },
                    ),
                    if (isLoading) ...{
                      Positioned.fill(
                        child: Container(
                          color: Colors.white,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    },
                  ],
                );
              });
        });
  }
}
