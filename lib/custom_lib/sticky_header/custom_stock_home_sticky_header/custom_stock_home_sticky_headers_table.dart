library table_sticky_headers;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../custom_table_sticky_header/cell_alignments.dart';
import 'custom_stock_home_cell_dimensions.dart';

/// Table with sticky headers. Whenever you scroll content horizontally
/// or vertically - top and left headers always stay.
class CustomStockHomeStickyHeadersTable extends StatefulWidget {
  CustomStockHomeStickyHeadersTable({
    Key? key,

    /// Number of Columns (for content only)
    required this.columnsLength,

    /// Number of Rows (for content only)
    required this.rowsLength,

    /// Title for Top Left cell (always visible)
    this.legendCell = const Text(''),

    /// Builder for column titles. Takes index of content column as parameter
    /// and returns String for column title
    required this.columnsTitleBuilder,

    /// Builder for row titles. Takes index of content row as parameter
    /// and returns String for row title
    required this.rowsTitleBuilder,

    /// Builder for content cell. Takes index for content column first,
    /// index for content row second and returns String for cell
    required this.contentCellBuilder,

    /// Table cell dimensions
    this.cellDimensions = CustomStockHomeCellDimensions.base,

    /// Alignments for cell contents
    this.cellAlignments = CellAlignments.base,

    /// Callbacks for when pressing a cell
    Function()? onStickyLegendPressed,
    Function(int columnIndex)? onColumnTitlePressed,
    Function(int rowIndex)? onRowTitlePressed,
    Function(int columnIndex, int rowIndex)? onContentCellPressed,

    /// Called when scrolling has ended, passing the current offset position
    this.onEndScrolling,

    /// Initial scroll offsets in X and Y directions. Specified in points. Overrides scroll Offset in index if both are present.
    this.initialScrollOffsetX,
    this.initialScrollOffsetY,

    /// Scroll controllers for the table. Make sure that you dispose ScrollControllers inside when you don't need table_sticky_headers anymore.
    ScrollControllers? scrollControllers,

    /// Table Direction to support RTL languages
    this.tableDirection = TextDirection.ltr,

    /// Initial scroll offsets in X and Y directions. Specified in index.
    this.scrollOffsetIndexX,
    this.scrollOffsetIndexY,

    /// Turn scrollbars
    required this.showVerticalScrollbar,
    required this.showHorizontalScrollbar,
  })  : this.shouldDisposeScrollControllers = scrollControllers == null,
        this.scrollControllers = scrollControllers ?? ScrollControllers(),
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
  final Widget legendCell;
  final Widget Function(int columnIndex) columnsTitleBuilder;
  final Widget Function(int rowIndex) rowsTitleBuilder;
  final Widget Function(int columnIndex, int rowIndex) contentCellBuilder;
  final CustomStockHomeCellDimensions cellDimensions;
  final CellAlignments cellAlignments;
  final Function() onStickyLegendPressed;
  final Function(int columnIndex) onColumnTitlePressed;
  final Function(int rowIndex) onRowTitlePressed;
  final Function(int columnIndex, int rowIndex) onContentCellPressed;
  final Function(double x, double y)? onEndScrolling;
  final ScrollControllers scrollControllers;
  final TextDirection tableDirection;
  final int? scrollOffsetIndexY;
  final int? scrollOffsetIndexX;
  final double? initialScrollOffsetX;
  final double? initialScrollOffsetY;
  final bool showVerticalScrollbar;
  final bool showHorizontalScrollbar;

  final bool shouldDisposeScrollControllers;

  @override
  _CustomStockHomeStickyHeadersTableState createState() => _CustomStockHomeStickyHeadersTableState();
}

class _CustomStockHomeStickyHeadersTableState extends State<CustomStockHomeStickyHeadersTable> {
  final globalRowTitleKeys = <int, GlobalKey>{};
  final globalColumnTitleKeys = <int, GlobalKey>{};
  _SyncScrollController? _horizontalSyncController;
  _SyncScrollController? _verticalSyncController;
  late double _scrollOffsetX;
  late double _scrollOffsetY;

  bool _onHorizontalScrollingNotification({
    required ScrollNotification notification,
    required ScrollController controller,
  }) {
    final didEndScrolling = _horizontalSyncController?.processNotification(
      notification,
      controller,
    );
    final onEndScrolling = widget.onEndScrolling;
    if (didEndScrolling! && onEndScrolling != null) {
      _scrollOffsetX = controller.offset;
      onEndScrolling(_scrollOffsetX, _scrollOffsetY);
    }
    return true;
  }

  bool _onVerticalScrollingNotification({
    required ScrollNotification notification,
    required ScrollController controller,
  }) {
    final didEndScrolling = _verticalSyncController?.processNotification(
      notification,
      controller,
    );
    final onEndScrolling = widget.onEndScrolling;
    if (didEndScrolling! && onEndScrolling != null) {
      _scrollOffsetY = controller.offset;
      onEndScrolling(_scrollOffsetX, _scrollOffsetY);
    }
    return true;
  }

  void _shiftUsingOffsets() {
    void jumpToIndex(GlobalKey key) {
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(context);
      }
    }

    final scrollOffsetX = widget.initialScrollOffsetX;
    if (scrollOffsetX != null) {
      // Try to use natural offset first
      widget.scrollControllers._horizontalTitleController.jumpTo(scrollOffsetX);
    } else {
      // Try to use index offset second
      final scrollOffsetIndexX = widget.scrollOffsetIndexX;
      final keyX = globalRowTitleKeys[scrollOffsetIndexX];
      if (scrollOffsetIndexX != null && keyX != null) jumpToIndex(keyX);
    }

    final scrollOffsetY = widget.initialScrollOffsetY;
    if (scrollOffsetY != null) {
      // Try to use natural offset first
      widget.scrollControllers._verticalTitleController.jumpTo(scrollOffsetY);
    } else {
      // Try to use index offset second
      final scrollOffsetIndexY = widget.scrollOffsetIndexY;
      final keyY = globalColumnTitleKeys[scrollOffsetIndexY];
      if (scrollOffsetIndexY != null && keyY != null) jumpToIndex(keyY);
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollOffsetX = widget.initialScrollOffsetX ?? 0;
    _scrollOffsetY = widget.initialScrollOffsetY ?? 0;
  }

  @override
  void dispose() {
    if (widget.shouldDisposeScrollControllers) {
      widget.scrollControllers.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _verticalSyncController = _SyncScrollController(
      widget.scrollControllers._verticalTitleController,
      widget.scrollControllers._verticalBodyController,
    );
    _horizontalSyncController = _SyncScrollController(
      widget.scrollControllers._horizontalTitleController,
      widget.scrollControllers._horizontalBodyController,
    );
    SchedulerBinding.instance.addPostFrameCallback((_) => _shiftUsingOffsets());
    return Column(
      children: <Widget>[
        Row(
          textDirection: widget.tableDirection,
          children: <Widget>[
            /// STICKY LEGEND
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onStickyLegendPressed,
              child: Container(
                width: widget.cellDimensions.stickyLegendWidth,
                height: widget.cellDimensions.stickyLegendHeight,
                alignment: widget.cellAlignments.stickyLegendAlignment,
                child: widget.legendCell,
              ),
            ),

            /// STICKY ROW
            Expanded(
              child: NotificationListener<ScrollNotification>(
                child: Scrollbar(
                  // Key is required to avoid 'The Scrollbar's ScrollController has no ScrollPosition attached.
                  key: Key('Row ${widget.showVerticalScrollbar}'),
                  thumbVisibility: widget.showVerticalScrollbar ?? false,
                  controller:
                  widget.scrollControllers._horizontalTitleController,
                  child: SingleChildScrollView(
                    reverse: widget.tableDirection == TextDirection.rtl,
                    scrollDirection: Axis.horizontal,
                    controller:
                    widget.scrollControllers._horizontalTitleController,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      textDirection: widget.tableDirection,
                      children: List.generate(
                        widget.columnsLength,
                            (i) => GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onColumnTitlePressed(i),
                          child: Container(
                            key: globalRowTitleKeys[i] ??= GlobalKey(),
                            width: widget.cellDimensions.stickyWidth(i),
                            height: widget.cellDimensions.stickyLegendHeight,
                            alignment: widget.cellAlignments.rowAlignment(i),
                            child: widget.columnsTitleBuilder(i),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                onNotification: (notification) =>
                    _onHorizontalScrollingNotification(
                      notification: notification,
                      controller:
                      widget.scrollControllers._horizontalTitleController,
                    ),
              ),
            )
          ],
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: widget.tableDirection,
            children: <Widget>[
              /// STICKY COLUMN
              NotificationListener<ScrollNotification>(
                child: Scrollbar(
                  // Key is required to avoid 'The Scrollbar's ScrollController has no ScrollPosition attached.
                  key: Key('Column ${widget.showHorizontalScrollbar}'),
                  thumbVisibility: widget.showHorizontalScrollbar ?? false,
                  controller: widget.scrollControllers._verticalBodyController,
                  child: SingleChildScrollView(
                    controller:
                    widget.scrollControllers._verticalTitleController,
                    child: Column(
                      children: List.generate(
                        widget.rowsLength,
                            (i) => GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onRowTitlePressed(i),
                          child: Container(
                            key: globalColumnTitleKeys[i] ??= GlobalKey(),
                            //width: widget.cellDimensions.stickyLegendWidth,
                            width: 140,
                            //height: widget.cellDimensions.stickyHeight(i),
                            height: 50,
                            alignment: widget.cellAlignments.columnAlignment(i),
                            child: widget.rowsTitleBuilder(i),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                onNotification: (notification) =>
                    _onVerticalScrollingNotification(
                      notification: notification,
                      controller: widget.scrollControllers._verticalTitleController,
                    ),
              ),
              // CONTENT
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  child: SingleChildScrollView(
                    reverse: widget.tableDirection == TextDirection.rtl,
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
                              textDirection: widget.tableDirection,
                              children: List.generate(
                                widget.columnsLength,
                                    (int columnIdx) => GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => widget.onContentCellPressed(
                                      columnIdx, rowIdx),
                                  child: Container(
                                    width: widget.cellDimensions
                                        .contentSize(rowIdx, columnIdx)
                                        .width,
                                    /*height: widget.cellDimensions
                                        .contentSize(rowIdx, columnIdx)
                                        .height,*/
                                    height: 50,
                                    alignment: widget.cellAlignments
                                        .contentAlignment(rowIdx, columnIdx),
                                    child: widget.contentCellBuilder(
                                        columnIdx, rowIdx),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      onNotification: (notification) =>
                          _onVerticalScrollingNotification(
                            notification: notification,
                            controller:
                            widget.scrollControllers._verticalBodyController,
                          ),
                    ),
                  ),
                  onNotification: (notification) =>
                      _onHorizontalScrollingNotification(
                        notification: notification,
                        controller:
                        widget.scrollControllers._horizontalBodyController,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// SyncScrollController keeps scroll controllers in sync.
class _SyncScrollController {
  _SyncScrollController(
      this._titleController,
      this._bodyController,
      );

  final ScrollController _titleController;
  final ScrollController _bodyController;

  ScrollController? _scrollingController;
  bool _scrollingActive = false;

  /// Returns true if reached scroll end
  bool processNotification(
      ScrollNotification notification,
      ScrollController controller, {
        Function(double x, double y)? onEndScrolling,
      }) {
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
        for (final controller in [_titleController, _bodyController]) {
          if (identical(_scrollingController, controller)) continue;
          if (controller.positions.isEmpty) continue;
          final offset = _scrollingController?.offset;
          if (offset != null) {
            controller.jumpTo(offset);
          }
        }
      }
    }
    return false;
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

  dispose(){
    this.dispose();
  }

}