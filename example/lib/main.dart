// ignore_for_file: avoid_print

import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:example/chapter_drawer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("E-pub"),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyHomePage(
                                title: ' 1',
                                url:
                                    "https://cdn.ambition.guru/agcdn/medias/2024/8/21/Rudane-3.epub?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20240918%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20240918T113933Z&X-Amz-SignedHeaders=host&X-Amz-Expires=542127&X-Amz-Signature=5ab990100b8f40971486cf10d2cba8282d49a7593a1afd096fb7c725bfb39061",
                              )));
                },
                child: const Text("E-pub 1")),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyHomePage(
                                title: ' 2',
                                url:
                                    "https://cdn.ambition.guru/agcdn/medias/2024/8/21/Rudane-3.epub?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20240919%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20240919T053947Z&X-Amz-SignedHeaders=host&X-Amz-Expires=563713&X-Amz-Signature=bf38adc44756ca86c5a35f7ab06ffb7557e161bd43cf2f0875ce00eacff38f0a",
                              )));
                },
                child: const Text("E-pub 2")),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final epubController = EpubController();
  final ValueNotifier<double> _fontSize = ValueNotifier<double>(30.0);
  double _fontSizeProgress = 30.0;

  var textSelectionCfi = '';

  updateFontSettings() {
    return showModalBottomSheet(
        context: context,
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        enableDrag: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (context) {
          return SingleChildScrollView(
              child: StatefulBuilder(
                  builder: (BuildContext context, setState) => SizedBox(
                        height: 70,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            "Aa",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Expanded(
                                            child: ValueListenableBuilder(
                                                valueListenable: _fontSize,
                                                builder: (_, fontSize, __) {
                                                  return Slider(
                                                    activeColor: Colors.blue,
                                                    value: _fontSizeProgress,
                                                    min: 30.0,
                                                    max: 50.0,
                                                    onChangeEnd:
                                                        (double value) {
                                                      _fontSizeProgress = value;
                                                      _fontSize.value = value;
                                                    },
                                                    onChanged: (double value) {
                                                      ///For updating widget's inside
                                                      setState(() {
                                                        _fontSizeProgress =
                                                            value;
                                                      });
                                                    },
                                                  );
                                                }),
                                          ),
                                          const Text(
                                            "Aa",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      )
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      )));
        });
  }

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ChapterDrawer(
        controller: epubController,
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.search),
          //   onPressed: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => SearchPage(
          //                   epubController: epubController,
          //                 )));
          //   },
          // ),
          InkWell(
              onTap: () {
                updateFontSettings();
              },
              child: Container(
                width: 40,
                alignment: Alignment.center,
                child: const Text(
                  "Aa",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )),
        ],
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
                valueListenable: _fontSize,
                builder: (_, fontSize, __) {
                  return Stack(
                    children: [
                      EpubViewer(
                        epubSource: EpubSource.fromUrl(widget.url
                            // 'https://github.com/IDPF/epub3-samples/releases/download/20230704/accessible_epub_3.epub',
                            ),
                        epubController: epubController,
                        fontSize: fontSize.toInt(),
                        displaySettings: EpubDisplaySettings(
                          fontSize: fontSize.toInt(),
                          flow: EpubFlow.paginated,
                          snap: true,
                          allowScriptedContent: true,
                        ),
                        selectionContextMenu: ContextMenu(
                          menuItems: [
                            ContextMenuItem(
                              title: "Highlight",
                              id: 1,
                              action: () async {
                                epubController.addHighlight(
                                    cfi: textSelectionCfi);
                              },
                            ),
                          ],
                          settings: ContextMenuSettings(
                              hideDefaultSystemContextMenuItems: true),
                        ),
                        onChaptersLoaded: (chapters) {
                          setState(() {
                            isLoading = false;
                          });
                        },
                        onEpubLoaded: () async {
                          print('Epub loaded');
                        },
                        onRelocated: (value) {
                          print("Reloacted to $value");
                        },
                        onAnnotationClicked: (cfi) {
                          print("Annotation clicked $cfi");
                        },
                        onTextSelected: (epubTextSelection) {
                          textSelectionCfi = epubTextSelection.selectionCfi;
                          print(textSelectionCfi);
                        },
                      ),
                      Visibility(
                        visible: isLoading,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    ],
                  );
                }),
          ),
        ],
      )),
    );
  }
}
