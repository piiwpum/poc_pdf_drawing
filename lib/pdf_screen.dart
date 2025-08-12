import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:pdf_annotation_poc/drawing/drawing_painter.dart';

import 'package:pdf_annotation_poc/pdf_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewPage extends StatelessWidget {
  const PdfViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PdfViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBarModeNormal(
              title: 'Document name',
              onClickEditMode: () {
                print('click');
                vm.setEditModel(true);
              },
            ),
            Expanded(
              child: Stack(
                children: [
                  InteractiveViewer(
                    transformationController: vm.transformationController,
                    maxScale: 5.0,
                    minScale: 1.0,
                    panEnabled: !vm.isDrawing,
                    scaleEnabled: true,
                    onInteractionStart: (details) {
                      //check drawing i sus
                      if (vm.editMode) {
                        if (details.pointerCount == 1 && !vm.isZooming) {
                          vm.setDrawing(true);
                          final canvasPoint = vm.transformToCanvasCoordinates(
                            details.localFocalPoint,
                          );
                          if (vm.isErasing) {
                            vm.eraseAt(canvasPoint);
                          } else {
                            vm.startStroke(canvasPoint);
                          }
                        } else {
                          vm.setZooming(true);
                          vm.setDrawing(false);
                        }
                      }
                      //check swipe to change doc page i sus
                      if (!vm.editMode) {
                        vm.startPosition = details.focalPoint;
                        vm.startTime = DateTime.now();
                      }
                    },
                    onInteractionUpdate: (details) {
                      //check drawing i sus
                      if (vm.editMode) {
                        if (details.pointerCount == 1 && vm.isDrawing) {
                          final canvasPoint = vm.transformToCanvasCoordinates(
                            details.localFocalPoint,
                          );
                          if (vm.isErasing) {
                            vm.eraseAt(canvasPoint);
                          } else {
                            vm.updateStroke(canvasPoint);
                          }
                        }
                      }
                      //check swipe to change doc page i sus
                      if (!vm.editMode) {
                        if (vm.startPosition == null || vm.startTime == null)
                          return;

                        final dx = details.focalPoint.dx - vm.startPosition!.dx;
                        final elapsed =
                            DateTime.now()
                                .difference(vm.startTime!)
                                .inMilliseconds /
                            1000.0;
                        if (vm.transformationController.value
                                .getMaxScaleOnAxis() ==
                            1.0) {
                          if (elapsed <= 0.1) {
                            if (dx > 100) {
                              vm.swipedRight = true;
                              vm.swipedLeft = false;
                              vm.startPosition = null;
                              vm.startTime = null;
                              vm.previousPage();
                            } else if (dx < -100) {
                              vm.swipedLeft = true;
                              vm.swipedRight = false;
                              vm.startPosition = null;
                              vm.startTime = null;
                              vm.nextPage();
                            }
                          }
                        }
                      }
                    },
                    onInteractionEnd: (details) {
                      if (vm.editMode) {
                        if (details.pointerCount == 0) {
                          vm.setZooming(false);
                          vm.setDrawing(false);
                        }
                        if (vm.isDrawing && !vm.isErasing) {
                          vm.endStroke();
                        }
                      }
                      //check swipe to change doc page i sus
                      if (!vm.editMode) {
                        vm.startPosition = null;
                        vm.startTime = null;
                      }
                    },
                    child: Stack(
                      children: [
                        IgnorePointer(
                          ignoring: true,
                          child: SfPdfViewer.asset(
                            'assets/pdf/sample.pdf',
                            controller: vm.pdfViewerController,
                            onPageChanged: vm.onPageChanged,
                            onDocumentLoaded: vm.onDocumentLoaded,
                            enableDoubleTapZooming: false,
                            scrollDirection: PdfScrollDirection.horizontal,
                            pageLayoutMode: PdfPageLayoutMode.single,
                            canShowScrollHead: false,
                            canShowTextSelectionMenu: false,
                            canShowPaginationDialog: false,
                            canShowScrollStatus: false,
                            enableDocumentLinkAnnotation: false,
                            enableTextSelection: false,
                            interactionMode: PdfInteractionMode.pan,
                            maxZoomLevel: 1,
                          ),
                        ),
                        SizedBox(
                          width: vm.pdfWidth,
                          height: vm.pdfHeight,
                          child: CustomPaint(
                            painter: DrawingPainter(vm.strokes),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: vm.editMode
                  ? _buildBottomBarModeEdit(
                      vm: vm,
                      onClickSuccess: () {
                        vm.setEditModel(false);
                      },
                    )
                  : _buildBottomBarModeNormal(
                      currentPage: vm.currentPage,
                      totalPage: vm.totalPage,
                      onClickPrevious: () {
                        vm.previousPage();
                      },
                      onClickForward: () {
                        vm.nextPage();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarModeNormal({
    required String title,
    required VoidCallback onClickEditMode,
  }) {
    return Container(
      width: double.infinity,
      color: Colors.green,
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22.0,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          IconButton(
            onPressed: onClickEditMode,
            icon: Icon(Icons.mode_edit, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBarModeNormal({
    required int currentPage,
    required int totalPage,
    required VoidCallback onClickPrevious,
    required VoidCallback onClickForward,
  }) {
    return Container(
      key: const ValueKey('normalMode'), // 👈 ใส่ key ตรงนี้
      width: double.infinity,
      color: Colors.green,
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        children: [
          Expanded(child: SizedBox()),
          IconButton(
            onPressed: onClickPrevious,
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '$currentPage / $totalPage',
              style: TextStyle(
                fontSize: 18.0,
                fontStyle: FontStyle.normal,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          IconButton(
            onPressed: onClickForward,
            icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBarModeEdit({
    required PdfViewModel vm,
    required VoidCallback onClickSuccess,
  }) {
    return Container(
      key: const ValueKey('editMode'), // 👈 ใส่ key ตรงนี้
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: vm.canUndo ? vm.undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: vm.canRedo ? vm.redo : null,
          ),
          Spacer(),
          TextButton(onPressed: onClickSuccess, child: Text('done')),
        ],
      ),
    );
  }
}
