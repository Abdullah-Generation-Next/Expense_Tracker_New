import 'dart:io';
import 'package:etmm/const/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewerPage extends StatefulWidget {
  final String path;

  const PDFViewerPage({Key? key, required this.path}) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  late PDFViewController pdfViewController;
  String? localFilePath;
  // int _currentPage = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    localFilePath = widget.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: themecolor,
          elevation: 0,
          title: Text(
            "PDF Viewer",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SfPdfViewer.file(File(widget.path))
        /*
      // isLoading == false
      //     ? Center(
      //   child: CircularProgressIndicator(
      //     color: themecolor,
      //   ),
      // )
      //     :
      localFilePath == null
          ? Center(
        child: Text(
          "Failed to load PDF.",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      )
          : Stack(
        children: [
          PDFView(
            filePath: localFilePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            onRender: (pages) {
              debugPrint("PDF rendered with $pages pages");
            },
            onViewCreated: (controller) {
              pdfViewController = controller;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page ?? 0;
              });
            },
          ),
          // Page Indicator
          Positioned(
            right: 20,
            top: 50, // Adjust the top position as needed
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Page ${_currentPage + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      */
        );
  }
}
