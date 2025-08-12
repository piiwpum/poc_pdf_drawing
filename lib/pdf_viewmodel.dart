import 'package:flutter/material.dart';
import 'package:pdf_annotation_poc/drawing/stroke.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class PdfViewModel extends ChangeNotifier {
  final TransformationController transformationController =
      TransformationController();
  final PdfViewerController pdfViewerController = PdfViewerController();

  int currentPage = 1;
  int totalPage = 1;
  List<int> bookmarks = [];
  double pdfWidth = 0;
  double pdfHeight = 0;

  bool editMode = false;
  bool isZooming = false;
  bool isDrawing = false;

  Offset? startPosition;
  DateTime? startTime;
  bool swipedRight = false;
  bool swipedLeft = false;

  void setEditModel(bool v) {
    print('v = ${v.toString()}');
    editMode = v;
    notifyListeners();
  }

  void onPageChanged(PdfPageChangedDetails details) {
    currentPage = details.newPageNumber;
    notifyListeners();
  }

  void onDocumentLoaded(PdfDocumentLoadedDetails details) {
    totalPage = details.document.pages.count;
    // final firstPageSize = details.document.pages[0].size;
    // final pdfWidth = firstPageSize.width;
    // final pdfHeight = firstPageSize.height;
  }

  void nextPage() {
    if (currentPage < pdfViewerController.pageCount) {
      pdfViewerController.jumpToPage(currentPage + 1);
    }
  }

  void previousPage() {
    if (currentPage > 1) {
      pdfViewerController.jumpToPage(currentPage - 1);
    }
  }

  void jumpToBookmark(int page) {
    pdfViewerController.jumpToPage(page);
  }

  bool isBookmarked(int page) {
    return bookmarks.contains(page);
  }

  bool toggleBookmark() {
    if (isBookmarked(currentPage)) {
      bookmarks.remove(currentPage);
      notifyListeners();
      return false;
    } else {
      bookmarks.add(currentPage);
      notifyListeners();
      return true;
    }
  }

  Color currentColor = Colors.black;
  double currentStrokeWidth = 4.0;

  Map<int, List<Stroke>> strokesByPage = {};
  Map<int, List<Stroke>> undoneStrokesByPage = {};
  List<Offset> _currentPoints = [];

  bool isErasing = false;
  void setErasing(bool value) {
    isErasing = value;
    notifyListeners();
  }

  List<Stroke> get strokes => strokesByPage[currentPage] ?? [];
  set strokes(List<Stroke> value) {
    strokesByPage[currentPage] = value;
  }

  List<Stroke> get undoneStrokes => undoneStrokesByPage[currentPage] ?? [];
  set undoneStrokes(List<Stroke> value) {
    undoneStrokesByPage[currentPage] = value;
  }

  void startStroke(Offset startPoint) {
    _currentPoints = [startPoint];
    final newStroke = Stroke(
      points: List.of(_currentPoints),
      color: currentColor,
      strokeWidth: currentStrokeWidth,
    );
    strokes = List.of(strokes)..add(newStroke);
    undoneStrokes = [];
    notifyListeners();
  }

  void updateStroke(Offset nextPoint) {
    _currentPoints = List.of(_currentPoints)..add(nextPoint);
    final updatedStroke = strokes.last.copyWith(points: _currentPoints);
    final updatedStrokes = List.of(strokes);
    updatedStrokes[updatedStrokes.length - 1] = updatedStroke;
    strokes = updatedStrokes;
    notifyListeners();
  }

  void endStroke() {
    _currentPoints = [];
    notifyListeners();
  }

  void clearCanvas() {
    strokesByPage.clear();
    undoneStrokesByPage.clear();
    notifyListeners();
  }

  void undo() {
    if (strokes.isNotEmpty) {
      undoneStrokes = List.of(undoneStrokes)..add(strokes.last);
      strokes = List.of(strokes)..removeLast();
      notifyListeners();
    }
  }

  void redo() {
    if (undoneStrokes.isNotEmpty) {
      strokes = List.of(strokes)..add(undoneStrokes.last);
      undoneStrokes = List.of(undoneStrokes)..removeLast();
      notifyListeners();
    }
  }

  bool get canUndo => strokes.isNotEmpty;
  bool get canRedo => undoneStrokes.isNotEmpty;

  // Eraser: ลบ stroke ที่มีจุดใกล้ตำแหน่ง point
  void eraseAt(Offset point, {double threshold = 10}) {
    strokes = strokes.where((stroke) {
      return !stroke.points.any((p) => (p - point).distance <= threshold);
    }).toList();
    notifyListeners();
  }

  void setZooming(bool zoom) {
    isZooming = zoom;
    notifyListeners();
  }

  void setDrawing(bool draw) {
    isDrawing = draw;
    notifyListeners();
  }

  void setPdfSize(double width, double height) {
    pdfWidth = width;
    pdfHeight = height;
    notifyListeners();
  }

  Offset transformToCanvasCoordinates(Offset localPosition) {
    final matrix = transformationController.value;
    final inverseMatrix = Matrix4.inverted(matrix);
    final vector4 = Vector4(localPosition.dx, localPosition.dy, 0, 1);
    final transformed = inverseMatrix.transform(vector4);
    return Offset(transformed.x, transformed.y);
  }
}
