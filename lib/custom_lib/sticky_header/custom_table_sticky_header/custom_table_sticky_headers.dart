library table_sticky_headers;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rassi_assist/common/const.dart';
import 'cell_alignments.dart';
import 'cell_dimensions.dart';

/// Table with sticky headers. Whenever you scroll content horizontally
/// or vertically - top and left headers always stay.
class CustomStickyHeadersTable extends StatefulWidget {
  CustomStickyHeadersTable({
    Key? key,

    /// Number of Columns (for content only)
    required this.columnsLength,

    /// Number of Rows (for content only)
    required this.rowsLength,

    /// Title for Top Left cell (always visible)
    //this.legendCell = const Text(''),

    /// Builder for column titles. Takes index of content column as parameter
    /// and returns String for column title
    // required this.columnsTitleBuilder,

    /// Builder for row titles. Takes index of content row as parameter
    /// and returns String for row title
    required this.rowsTitleBuilder,

    /// Builder for content cell. Takes index for content column first,
    /// index for content row second and returns String for cell
    required this.contentCellBuilder,

    required this.rowTitleWidth,
    required this.dataCellcontentWidth,
    required this.titleViewHeight,
    required this.highLightedIndex,

    /// Table cell dimensions
    this.cellDimensions = CellDimensions.base,

    /// Alignments for cell contents
    this.cellAlignments = CellAlignments.base,

    /// Callbacks for when pressing a cell
    Function()? onStickyLegendPressed,
    Function(int columnIndex)? onColumnTitlePressed,
    Function(int rowIndex)? onRowTitlePressed,
    Function(int columnIndex, int rowIndex)? onContentCellPressed,

    /// Initial scroll offsets in X and Y directions
    this.initialScrollOffsetX = 0.0,
    this.initialScrollOffsetY = 0.0,

    /// Called when scrolling has ended, passing the current offset position
    required this.onEndScrolling,

    /// Scroll controllers for the table
    ScrollControllers? scrollControllers,
  })  : this.scrollControllers = scrollControllers ?? ScrollControllers(),
        this.onStickyLegendPressed = onStickyLegendPressed ?? (() {}),
        this.onColumnTitlePressed = onColumnTitlePressed ?? ((_) {}),
        this.onRowTitlePressed = onRowTitlePressed ?? ((_) {}),
        this.onContentCellPressed = onContentCellPressed ?? ((_, __) {}),
        super(key: key) {
    cellDimensions.runAssertions(rowsLength, columnsLength);
    cellAlignments.runAssertions(rowsLength, columnsLength);
  }

  final int rowsLength;
  final int columnsLength;

  final double rowTitleWidth;
  final double dataCellcontentWidth;  // 데이터 들어가는 행들의 width
  final double titleViewHeight;   // 데이터 들어가는 셀들의 0행[타이틀 표시] height
  final int highLightedIndex;   // 데이터 들어가는 셀들 중 특정 행에 하이라이트 주기 (다른컬러 배경)

  // final Widget legendCell;
  // final Widget Function(int columnIndex) columnsTitleBuilder;
  final Widget Function(int rowIndex) rowsTitleBuilder;
  final Widget Function(int columnIndex, int rowIndex) contentCellBuilder;
  final CellDimensions cellDimensions;
  final CellAlignments cellAlignments;
  final Function()? onStickyLegendPressed;
  final Function(int columnIndex)? onColumnTitlePressed;
  final Function(int rowIndex)? onRowTitlePressed;
  final Function(int columnIndex, int rowIndex)? onContentCellPressed;
  final double initialScrollOffsetX;
  final double initialScrollOffsetY;
  final Function(double x, double y) onEndScrolling;
  final ScrollControllers scrollControllers;

  @override
  _CustomStickyHeadersTableState createState() => _CustomStickyHeadersTableState();
}

class _CustomStickyHeadersTableState extends State<CustomStickyHeadersTable> {
  late _SyncScrollController _horizontalSyncController;
  late _SyncScrollController _verticalSyncController;

  late double _scrollOffsetX;
  late double _scrollOffsetY;

  @override
  void initState() {
    super.initState();
    _scrollOffsetX = widget.initialScrollOffsetX;
    _scrollOffsetY = widget.initialScrollOffsetY;
    _verticalSyncController = _SyncScrollController([
      widget.scrollControllers._verticalTitleController,
      widget.scrollControllers._verticalBodyController,
    ]);
    _horizontalSyncController = _SyncScrollController([
      widget.scrollControllers._horizontalTitleController,
      widget.scrollControllers._horizontalBodyController,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.scrollControllers._horizontalTitleController
          .jumpTo(widget.initialScrollOffsetX);
      widget.scrollControllers._verticalTitleController
          .jumpTo(widget.initialScrollOffsetY);
    });
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            // STICKY LEGEND
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onStickyLegendPressed,
              child: Container(
                width: widget.cellDimensions.stickyLegendWidth,
                height: 0,
                alignment: widget.cellAlignments.stickyLegendAlignment,
                //  child: widget.legendCell,
              ),
            ),
            // STICKY ROW
            Expanded(
              child: NotificationListener<ScrollNotification>(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller:
                  widget.scrollControllers._horizontalTitleController,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      widget.columnsLength,
                          (i) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onColumnTitlePressed!(i),
                        child: Container(
                          width: widget.cellDimensions.stickyWidth(i),
                          height: 0,
                          alignment: widget.cellAlignments.rowAlignment(i),
                          //   child: widget.columnsTitleBuilder(i),
                        ),
                      ),
                    ),
                  ),
                ),
                onNotification: (ScrollNotification notification) {
                  final didEndScrolling =
                  _horizontalSyncController.processNotification(
                    notification,
                    widget.scrollControllers._horizontalTitleController,
                  );
                  if (widget.onEndScrolling != null && didEndScrolling) {
                    _scrollOffsetX = widget
                        .scrollControllers._horizontalTitleController.offset;
                    widget.onEndScrolling(_scrollOffsetX, _scrollOffsetY);
                  }
                  return true;
                },
              ),
            )
          ],
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // STICKY COLUMN
              NotificationListener<ScrollNotification>(
                child: SingleChildScrollView(
                  controller: widget.scrollControllers._verticalTitleController,
                  child: Column(
                    children: List.generate(
                      widget.rowsLength,
                          (i) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onRowTitlePressed!(i),
                        child: _makeStickyRowView(i),
                      ),
                    ),
                  ),
                ),
                onNotification: (ScrollNotification notification) {
                  final didEndScrolling =
                  _verticalSyncController.processNotification(
                    notification,
                    widget.scrollControllers._verticalTitleController,
                  );
                  if (widget.onEndScrolling != null && didEndScrolling) {
                    _scrollOffsetY = widget
                        .scrollControllers._verticalTitleController.offset;
                    widget.onEndScrolling(_scrollOffsetX, _scrollOffsetY);
                  }
                  return true;
                },
              ),
              // CONTENT
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller:
                    widget.scrollControllers._horizontalBodyController,
                    child: NotificationListener<ScrollNotification>(
                      child: SingleChildScrollView(
                        controller:
                        widget.scrollControllers._verticalBodyController,
                        child: Column(
                          children: List.generate(
                            widget.rowsLength,
                                (int rowIdx) => Row(
                              children: List.generate(
                                widget.columnsLength,
                                    (int columnIdx) => GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => widget.onContentCellPressed!(
                                      columnIdx, rowIdx),
                                  child: _makeContentSellView(columnIdx, rowIdx),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      onNotification: (ScrollNotification notification) {
                        final didEndScrolling =
                        _verticalSyncController.processNotification(
                          notification,
                          widget.scrollControllers._verticalBodyController,
                        );
                        if (widget.onEndScrolling != null && didEndScrolling) {
                          _scrollOffsetY = widget
                              .scrollControllers._verticalBodyController.offset;
                          widget.onEndScrolling(
                              _scrollOffsetX, _scrollOffsetY);
                        }
                        return true;
                      },
                    ),
                  ),
                  onNotification: (ScrollNotification notification) {
                    final didEndScrolling =
                    _horizontalSyncController.processNotification(
                      notification,
                      widget.scrollControllers._horizontalBodyController,
                    );
                    if (widget.onEndScrolling != null && didEndScrolling) {
                      _scrollOffsetX = widget
                          .scrollControllers._horizontalBodyController.offset;
                      widget.onEndScrolling(_scrollOffsetX, _scrollOffsetY);
                    }
                    return true;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // DEFINE 종목명 들어가고 고정된 1열 만들기
  Widget _makeStickyRowView(int i){
    double? height;
    Color color = RColor.bgWeakGrey;
    if(i == 0) {  // 0행일때 크기 키워줘야함
      height = widget.titleViewHeight;
    } else {
      if(i == widget.highLightedIndex){
        color = RColor.chartHighlighColor;
      } else {
        color = RColor.bgWeakGrey;
      }
      height = widget.cellDimensions?.stickyHeight(i);
    }
    return Container(
      width: widget.rowTitleWidth,
      height: height,
      alignment: widget.cellAlignments?.columnAlignment(i),
      decoration: BoxDecoration(
        color: color,
        border: const Border(
          //left: BorderSide(color: Colors.black, width: 1),
          bottom: BorderSide(color: RColor.lineGrey2, width: 1),
        ),
      ),
      child: widget.rowsTitleBuilder(i),
    );
  }

  // DEFINE 타이틀 + 데이터 들어가고 움직이는 나머지 행열 만들기
  Widget _makeContentSellView(int columnIdx, int rowIdx){
    double height;
    Color color = RColor.bgWeakGrey;
    if(rowIdx == 0){  // 0행일때 크기 키워줘야함
      height = widget.titleViewHeight;
    }else{
      if(rowIdx == widget.highLightedIndex){
        color = RColor.chartHighlighColor;
      }else{
        color = RColor.bgWeakGrey;
      }
      height = widget.cellDimensions
          .contentSize(rowIdx, columnIdx)
          .height;

    }
    return Container(
      width: widget.dataCellcontentWidth,
      height: height,
      alignment: widget.cellAlignments
          ?.contentAlignment(rowIdx, columnIdx),
      decoration: BoxDecoration(
        color: color,
        border: const Border(
          left: BorderSide(color: RColor.lineGrey2, width: 1),
          bottom: BorderSide(color: RColor.lineGrey2, width: 1),
        ),
      ),
      child: widget.contentCellBuilder(
          columnIdx, rowIdx),
    );
  }

}

class ScrollControllers {
  final ScrollController _verticalTitleController;
  final ScrollController _verticalBodyController;
  final ScrollController _horizontalBodyController;
  final ScrollController _horizontalTitleController;

  ScrollControllers({
    ScrollController? verticalTitleController,
    ScrollController? verticalBodyController,
    ScrollController? horizontalBodyController,
    ScrollController? horizontalTitleController,
  })  : this._verticalTitleController =
      verticalTitleController ?? ScrollController(),
        this._verticalBodyController =
            verticalBodyController ?? ScrollController(),
        this._horizontalBodyController =
            horizontalBodyController ?? ScrollController(),
        this._horizontalTitleController =
            horizontalTitleController ?? ScrollController();
}

/// SyncScrollController keeps scroll controllers in sync.
class _SyncScrollController {
  _SyncScrollController(List<ScrollController> controllers) {
    controllers.forEach((controller) => _registeredScrollControllers.add(controller));
  }

  final List<ScrollController> _registeredScrollControllers = [];
  ScrollController? _scrollingController;
  bool _scrollingActive = false;

  /// Returns true if reached scroll end
  bool processNotification(
      ScrollNotification notification,
      ScrollController controller,
      ) {
    if (notification is ScrollStartNotification && !_scrollingActive) {
      _scrollingController = controller;
      _scrollingActive = true;
      return false;
    }

    if (identical(controller, _scrollingController) && _scrollingActive) {
      if (notification is ScrollEndNotification) {
        _scrollingController = null;
        _scrollingActive = false;
        return true;
      }

      if (notification is ScrollUpdateNotification) {
        for (ScrollController controller in _registeredScrollControllers) {
          if (identical(_scrollingController, controller)) continue;
          //controller.jumpTo(_scrollingController.offset);
        }
      }
    }
    return false;
  }
}
