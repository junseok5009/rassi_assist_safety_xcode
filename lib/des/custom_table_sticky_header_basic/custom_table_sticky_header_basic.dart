// library table_sticky_headers;
//
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:table_sticky_headers/table_sticky_headers.dart';
//
// /// Table with sticky headers. Whenever you scroll content horizontally
// /// or vertically - top and left headers always stay.
// class CustomStickyHeadersTableBasic extends StatefulWidget {
//   CustomStickyHeadersTableBasic({
//     Key key,
//
//     /// Number of Columns (for content only)
//     this.columnsLength,
//
//     /// Number of Rows (for content only)
//     this.rowsLength,
//
//     /// Title for Top Left cell (always visible)
//     this.legendCell = const Text(''),
//
//     /// Builder for column titles. Takes index of content column as parameter
//     /// and returns String for column title
//     this.columnsTitleBuilder,
//
//     /// Builder for row titles. Takes index of content row as parameter
//     /// and returns String for row title
//     this.rowsTitleBuilder,
//
//     /// Builder for content cell. Takes index for content column first,
//     /// index for content row second and returns String for cell
//     this.contentCellBuilder,
//
//     /// Table cell dimensions
//     this.cellDimensions = CustomCellDimensionsBasic.base,
//
//     /// Alignments for cell contents
//     this.cellAlignments = CustomCellAlignmentsBasic.base,
//
//     /// Callbacks for when pressing a cell
//     Function() onStickyLegendPressed,
//     Function(int columnIndex) onColumnTitlePressed,
//     Function(int rowIndex) onRowTitlePressed,
//     Function(int columnIndex, int rowIndex) onContentCellPressed,
//
//     /// Called when scrolling has ended, passing the current offset position
//     this.onEndScrolling,
//
//     /// Scroll controllers for the table. Make sure that you dispose ScrollControllers inside when you don't need table_sticky_headers anymore.
//     ScrollControllers scrollControllers,
//
//     /// Custom Scroll physics for table
//     CustomScrollPhysics scrollPhysics,
//
//     /// Table Direction to support RTL languages
//     this.tableDirection = TextDirection.ltr,
//
//     /// Initial scroll offsets in X and Y directions. Specified in points. Overrides scroll Offset in index if both are present.
//     this.initialScrollOffsetX,
//     this.initialScrollOffsetY,
//
//     /// Initial scroll offsets in X and Y directions. Specified in index.
//     this.scrollOffsetIndexX,
//     this.scrollOffsetIndexY,
//
//     /// Turn scrollbars
//     this.showVerticalScrollbar,
//     this.showHorizontalScrollbar,
//   })  : this.shouldDisposeScrollControllers = scrollControllers == null,
//         this.scrollControllers = scrollControllers ?? ScrollControllers(),
//         this.onStickyLegendPressed = onStickyLegendPressed ?? (() {}),
//         this.onColumnTitlePressed = onColumnTitlePressed ?? ((_) {}),
//         this.onRowTitlePressed = onRowTitlePressed ?? ((_) {}),
//         this.onContentCellPressed = onContentCellPressed ?? ((_, __) {}),
//         this.scrollPhysics = scrollPhysics ?? CustomScrollPhysics(),
//         super(key: key) {
//     cellDimensions.runAssertions(rowsLength, columnsLength);
//     cellAlignments.runAssertions(rowsLength, columnsLength);
//   }
//
//   final int rowsLength;
//   final int columnsLength;
//   final Widget legendCell;
//   final Widget Function(int columnIndex) columnsTitleBuilder;
//   final Widget Function(int rowIndex) rowsTitleBuilder;
//   final Widget Function(int columnIndex, int rowIndex) contentCellBuilder;
//   final CustomCellDimensionsBasic cellDimensions;
//   final CustomCellAlignmentsBasic cellAlignments;
//   final Function() onStickyLegendPressed;
//   final Function(int columnIndex) onColumnTitlePressed;
//   final Function(int rowIndex) onRowTitlePressed;
//   final Function(int columnIndex, int rowIndex) onContentCellPressed;
//   final Function(double x, double y) onEndScrolling;
//   final ScrollControllers scrollControllers;
//   final CustomScrollPhysics scrollPhysics;
//   final TextDirection tableDirection;
//   final int scrollOffsetIndexY;
//   final int scrollOffsetIndexX;
//   final double initialScrollOffsetX;
//   final double initialScrollOffsetY;
//   final bool showVerticalScrollbar;
//   final bool showHorizontalScrollbar;
//   final bool shouldDisposeScrollControllers;
//
//   @override
//   _StickyHeadersTableState createState() => _StickyHeadersTableState();
// }
//
// class _StickyHeadersTableState extends State<CustomStickyHeadersTableBasic> {
//   final globalRowTitleKeys = <int, GlobalKey>{};
//   final globalColumnTitleKeys = <int, GlobalKey>{};
//
//   late _SyncScrollController _horizontalSyncController;
//   late _SyncScrollController _verticalSyncController;
//
//   late double _scrollOffsetX;
//   late double _scrollOffsetY;
//
//   bool _onHorizontalScrollingNotification({
//     ScrollNotification notification,
//     ScrollController controller,
//   }) {
//     final didEndScrolling = _horizontalSyncController.processNotification(
//       notification,
//       controller,
//     );
//     final onEndScrolling = widget.onEndScrolling;
//     if (didEndScrolling && onEndScrolling != null) {
//       _scrollOffsetX = controller.offset;
//       onEndScrolling(_scrollOffsetX, _scrollOffsetY);
//     }
//     return true;
//   }
//
//   bool _onVerticalScrollingNotification({
//     ScrollNotification notification,
//     ScrollController controller,
//   }) {
//     final didEndScrolling = _verticalSyncController.processNotification(
//       notification,
//       controller,
//     );
//     final onEndScrolling = widget.onEndScrolling;
//     if (didEndScrolling && onEndScrolling != null) {
//       _scrollOffsetY = controller.offset;
//       onEndScrolling(_scrollOffsetX, _scrollOffsetY);
//     }
//     return true;
//   }
//
//   void _shiftUsingOffsets() {
//     void jumpToIndex(GlobalKey key) {
//       final context = key.currentContext;
//       if (context != null) {
//         Scrollable.ensureVisible(context);
//       }
//     }
//
//     final scrollOffsetX = widget.initialScrollOffsetX;
//     if (scrollOffsetX != null) {
//       // Try to use natural offset first
//       widget.scrollControllers.horizontalTitleController.jumpTo(scrollOffsetX);
//     } else {
//       // Try to use index offset second
//       final scrollOffsetIndexX = widget.scrollOffsetIndexX;
//       final keyX = globalRowTitleKeys[scrollOffsetIndexX];
//       if (scrollOffsetIndexX != null && keyX != null) jumpToIndex(keyX);
//     }
//
//     final scrollOffsetY = widget.initialScrollOffsetY;
//     if (scrollOffsetY != null) {
//       // Try to use natural offset first
//       widget.scrollControllers.verticalTitleController.jumpTo(scrollOffsetY);
//     } else {
//       // Try to use index offset second
//       final scrollOffsetIndexY = widget.scrollOffsetIndexY;
//       final keyY = globalColumnTitleKeys[scrollOffsetIndexY];
//       if (scrollOffsetIndexY != null && keyY != null) jumpToIndex(keyY);
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollOffsetX = widget.initialScrollOffsetX ?? 0;
//     _scrollOffsetY = widget.initialScrollOffsetY ?? 0;
//   }
//
//   @override
//   void dispose() {
//     if (widget.shouldDisposeScrollControllers) {
//       widget.scrollControllers.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     _verticalSyncController = _SyncScrollController(
//       widget.scrollControllers.verticalTitleController,
//       widget.scrollControllers.verticalBodyController,
//     );
//     _horizontalSyncController = _SyncScrollController(
//       widget.scrollControllers.horizontalTitleController,
//       widget.scrollControllers.horizontalBodyController,
//     );
//     SchedulerBinding.instance.addPostFrameCallback((_) => _shiftUsingOffsets());
//     return Column(
//       children: <Widget>[
//         Row(
//           textDirection: widget.tableDirection,
//           children: <Widget>[
//             /// STICKY LEGEND
//             GestureDetector(
//               behavior: HitTestBehavior.opaque,
//               onTap: widget.onStickyLegendPressed,
//               child: Container(
//                 width: widget.cellDimensions.stickyLegendWidth,
//                 height: widget.cellDimensions.stickyLegendHeight,
//                 alignment: widget.cellAlignments.stickyLegendAlignment,
//                 child: widget.legendCell,
//               ),
//             ),
//
//             /// STICKY ROW
//             Expanded(
//               child: NotificationListener<ScrollNotification>(
//                 child: Scrollbar(
//                   // Key is required to avoid 'The Scrollbar's ScrollController has no ScrollPosition attached.
//                   key: Key('Row ${widget.showVerticalScrollbar}'),
//                   thumbVisibility: widget.showVerticalScrollbar ?? false,
//                   controller:
//                   widget.scrollControllers.horizontalTitleController,
//                   child: SingleChildScrollView(
//                     reverse: widget.tableDirection == TextDirection.rtl,
//                     physics: widget.scrollPhysics.stickyRow,
//                     scrollDirection: Axis.horizontal,
//                     controller:
//                     widget.scrollControllers.horizontalTitleController,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       textDirection: widget.tableDirection,
//                       children: List.generate(
//                         widget.columnsLength,
//                             (i) => GestureDetector(
//                           behavior: HitTestBehavior.opaque,
//                           onTap: () => widget.onColumnTitlePressed(i),
//                           child: Container(
//                             key: globalRowTitleKeys[i] ??= GlobalKey(),
//                             width: widget.cellDimensions.stickyWidth(i),
//                             height: widget.cellDimensions.stickyLegendHeight,
//                             alignment: widget.cellAlignments.rowAlignment(i),
//                             child: widget.columnsTitleBuilder(i),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 onNotification: (notification) =>
//                     _onHorizontalScrollingNotification(
//                       notification: notification,
//                       controller:
//                       widget.scrollControllers.horizontalTitleController,
//                     ),
//               ),
//             )
//           ],
//         ),
//         Expanded(
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             textDirection: widget.tableDirection,
//             children: <Widget>[
//               /// STICKY COLUMN
//               NotificationListener<ScrollNotification>(
//                 child: Scrollbar(
//                   // Key is required to avoid 'The Scrollbar's ScrollController has no ScrollPosition attached.
//                   key: Key('Column ${widget.showHorizontalScrollbar}'),
//                   thumbVisibility: widget.showHorizontalScrollbar ?? false,
//                   controller: widget.scrollControllers.verticalBodyController,
//                   child: SingleChildScrollView(
//                     physics: widget.scrollPhysics.stickyColumn,
//                     controller:
//                     widget.scrollControllers.verticalTitleController,
//                     child: Column(
//                       children: List.generate(
//                         widget.rowsLength,
//                             (i) => GestureDetector(
//                           behavior: HitTestBehavior.opaque,
//                           onTap: () => widget.onRowTitlePressed(i),
//                           child: Container(
//                             key: globalColumnTitleKeys[i] ??= GlobalKey(),
//                             width: widget.cellDimensions.stickyLegendWidth,
//                             height: widget.cellDimensions.stickyHeight(i),
//                             alignment: widget.cellAlignments.columnAlignment(i),
//                             child: widget.rowsTitleBuilder(i),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 onNotification: (notification) =>
//                     _onVerticalScrollingNotification(
//                       notification: notification,
//                       controller: widget.scrollControllers.verticalTitleController,
//                     ),
//               ),
//               // CONTENT
//               Expanded(
//                 child: NotificationListener<ScrollNotification>(
//                   child: SingleChildScrollView(
//                     reverse: widget.tableDirection == TextDirection.rtl,
//                     physics: widget.scrollPhysics.contentHorizontal,
//                     scrollDirection: Axis.horizontal,
//                     controller:
//                     widget.scrollControllers.horizontalBodyController,
//                     child: NotificationListener<ScrollNotification>(
//                       child: SingleChildScrollView(
//                         physics: widget.scrollPhysics.contentVertical,
//                         controller:
//                         widget.scrollControllers.verticalBodyController,
//                         child: Column(
//                           children: List.generate(
//                             widget.rowsLength,
//                                 (int rowIdx) => Row(
//                               textDirection: widget.tableDirection,
//                               children: List.generate(
//                                 widget.columnsLength,
//                                     (int columnIdx) => GestureDetector(
//                                   behavior: HitTestBehavior.opaque,
//                                   onTap: () => widget.onContentCellPressed(
//                                       columnIdx, rowIdx),
//                                   child: Container(
//                                     width: widget.cellDimensions
//                                         .contentSize(rowIdx, columnIdx)
//                                         .width,
//                                     height: widget.cellDimensions
//                                         .contentSize(rowIdx, columnIdx)
//                                         .height,
//                                     alignment: widget.cellAlignments
//                                         .contentAlignment(rowIdx, columnIdx),
//                                     child: widget.contentCellBuilder(
//                                         columnIdx, rowIdx),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       onNotification: (notification) =>
//                           _onVerticalScrollingNotification(
//                             notification: notification,
//                             controller:
//                             widget.scrollControllers.verticalBodyController,
//                           ),
//                     ),
//                   ),
//                   onNotification: (notification) =>
//                       _onHorizontalScrollingNotification(
//                         notification: notification,
//                         controller:
//                         widget.scrollControllers.horizontalBodyController,
//                       ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// /// SyncScrollController keeps scroll controllers in sync.
// class _SyncScrollController {
//   _SyncScrollController(
//       this._titleController,
//       this._bodyController,
//       );
//
//   final ScrollController _titleController;
//   final ScrollController _bodyController;
//
//   ScrollController _scrollingController;
//   bool _scrollingActive = false;
//
//   /// Returns true if reached scroll end
//   bool processNotification(
//       ScrollNotification notification,
//       ScrollController controller, {
//         Function(double x, double y) onEndScrolling,
//       }) {
//     if (notification is ScrollStartNotification && !_scrollingActive) {
//       _scrollingController = controller;
//       _scrollingActive = true;
//       return false;
//     }
//
//     if (identical(controller, _scrollingController) && _scrollingActive) {
//       if (notification is ScrollEndNotification) {
//         _scrollingController = null;
//         _scrollingActive = false;
//         return true;
//       }
//
//       if (notification is ScrollUpdateNotification) {
//         for (final controller in [_titleController, _bodyController]) {
//           if (identical(_scrollingController, controller)) continue;
//           if (controller.positions.isEmpty) continue;
//           final offset = _scrollingController?.offset;
//           if (offset != null) {
//             controller.jumpTo(offset);
//           }
//         }
//       }
//     }
//     return false;
//   }
// }
//
// class ScrollControllers {
//   final ScrollController verticalTitleController;
//   final ScrollController verticalBodyController;
//
//   final ScrollController horizontalBodyController;
//   final ScrollController horizontalTitleController;
//
//   ScrollControllers({
//     ScrollController verticalTitleController,
//     ScrollController verticalBodyController,
//     ScrollController horizontalBodyController,
//     ScrollController horizontalTitleController,
//   })  : this.verticalTitleController =
//       verticalTitleController ?? ScrollController(),
//         this.verticalBodyController =
//             verticalBodyController ?? ScrollController(),
//         this.horizontalBodyController =
//             horizontalBodyController ?? ScrollController(),
//         this.horizontalTitleController =
//             horizontalTitleController ?? ScrollController();
//
//   dispose(){
//     this.dispose();
//   }
//
// }
//
// /// Dimensions for table.
// class CustomCellDimensionsBasic {
//
//   final double contentCellWidth;
//   final double contentCellHeight;
//   final List<double> columnWidths;
//   final List<double> rowHeights;
//   final double stickyLegendWidth;
//   final double stickyLegendHeight;
//
//   static const CustomCellDimensionsBasic base = CustomCellDimensionsBasic.fixed(
//     contentCellWidth: 80.0,
//     contentCellHeight: 40.0,
//     stickyLegendWidth: 70.0,
//     stickyLegendHeight: 33.0,
//   );
//
//   @Deprecated('Use CustomStockHomeCellDimensions.fixed instead.')
//   const CustomCellDimensionsBasic({
//     /// Content cell width. Also applied to sticky row width.
//     this.contentCellWidth,
//
//     /// Content cell height. Also applied to sticky column height.
//     this.contentCellHeight,
//
//     /// Sticky legend width. Also applied to sticky column width.
//     this.stickyLegendWidth,
//
//     /// Sticky legend height. Also applied to sticky row height.
//     this.stickyLegendHeight,
//   })   : this.columnWidths = null,
//         this.rowHeights = null;
//
//   /// Same dimensions for each content cell, but different dimensions for the
//   /// sticky legend, column and row.
//   const CustomCellDimensionsBasic.fixed({
//     /// Content cell width. Also applied to sticky row width.
//     this.contentCellWidth,
//
//     /// Content cell height. Also applied to sticky column height.
//     this.contentCellHeight,
//
//     /// Sticky legend width. Also applied to sticky column width.
//     this.stickyLegendWidth,
//
//     /// Sticky legend height. Also applied to sticky row height.
//     this.stickyLegendHeight,
//   })   : this.columnWidths = null,
//         this.rowHeights = null;
//
//   Size contentSize(int i, int j) {
//     final width =
//         (columnWidths != null ? columnWidths[j] : contentCellWidth) ??
//             base.contentCellWidth;
//     final height = (rowHeights != null ? rowHeights[i] : contentCellHeight) ??
//         base.contentCellHeight;
//     return Size(width, height);
//   }
//
//   double stickyWidth(int i) =>
//       (columnWidths != null ? columnWidths[i] : contentCellWidth) ??
//           base.contentCellWidth;
//
//   double stickyHeight(int i) =>
//       (rowHeights != null ? rowHeights[i] : contentCellHeight) ??
//           base.contentCellHeight;
//
//   void runAssertions(int rowsLength, int columnsLength) {
//     assert(contentCellWidth != null || columnWidths != null);
//     assert(contentCellHeight != null || rowHeights != null);
//     if (columnWidths != null) {
//       assert(columnWidths.length == columnsLength);
//     }
//     if (rowHeights != null) {
//       assert(rowHeights.length == rowsLength);
//     }
//   }
// }
//
// /// Alignment for cell contents.
// class CustomCellAlignmentsBasic {
//   static const CustomCellAlignmentsBasic base = CustomCellAlignmentsBasic.uniform(Alignment.center);
//
//   /// Same alignment for each cell.
//   const CustomCellAlignmentsBasic.uniform(Alignment alignment)
//       : this.fixed(
//     contentCellAlignment: alignment,
//     stickyColumnAlignment: alignment,
//     stickyRowAlignment: alignment,
//     stickyLegendAlignment: alignment,
//   );
//
//   /// Same alignment for each content cell, but different alignment for the
//   /// sticky column, row and legend.
//   const CustomCellAlignmentsBasic.fixed({
//     /// Same alignment for each content cell.
//     this.contentCellAlignment,
//
//     /// Same alignment for each sticky column cell.
//     this.stickyColumnAlignment,
//
//     /// Same alignment for each sticky row cell.
//     this.stickyRowAlignment,
//
//     /// Alignment for the sticky legend cell.
//     this.stickyLegendAlignment,
//   })   : columnAlignments = null,
//         rowAlignments = null,
//         contentCellAlignments = null,
//         stickyColumnAlignments = null,
//         stickyRowAlignments = null;
//
//   /// Different alignment for each column.
//   const CustomCellAlignmentsBasic.variableColumnAlignment({
//     /// Different alignment for each column (for content only).
//     /// Length of list must match columnsLength.
//     this.columnAlignments,
//
//     /// Different alignment for each sticky row cell.
//     /// Length of list must match columnsLength.
//     this.stickyRowAlignments,
//
//     /// Same alignment for each sticky column cell.
//     this.stickyColumnAlignment,
//
//     /// Alignment for the sticky legend cell.
//     this.stickyLegendAlignment,
//   })   : contentCellAlignment = null,
//         rowAlignments = null,
//         contentCellAlignments = null,
//         stickyColumnAlignments = null,
//         stickyRowAlignment = null;
//
//   /// Different alignment for each row.
//   const CustomCellAlignmentsBasic.variableRowAlignment({
//     /// Different alignment for each row (for content only).
//     /// Length of list must match rowsLength.
//     this.rowAlignments,
//
//     /// Different alignment for each sticky column cell.
//     /// Length of list must match rowsLength.
//     this.stickyColumnAlignments,
//
//     /// Same alignment for each sticky row cell.
//     this.stickyRowAlignment,
//
//     /// Alignment for the sticky legend cell.
//     this.stickyLegendAlignment,
//   })   : contentCellAlignment = null,
//         columnAlignments = null,
//         contentCellAlignments = null,
//         stickyRowAlignments = null,
//         stickyColumnAlignment = null;
//
//   /// Different alignment for every cell.
//   const CustomCellAlignmentsBasic.variable({
//     /// Different alignment for each content cell.
//     /// Dimensions of array must match rowsLength x columnsLength.
//     this.contentCellAlignments,
//
//     /// Different alignment for each sticky column cell.
//     /// Length of list must match rowsLength.
//     this.stickyColumnAlignments,
//
//     /// Different alignment for each sticky row cell.
//     /// Length of list must match columnsLength.
//     this.stickyRowAlignments,
//
//     /// Alignment for the sticky legend cell.
//     this.stickyLegendAlignment,
//   })   : contentCellAlignment = null,
//         columnAlignments = null,
//         rowAlignments = null,
//         stickyColumnAlignment = null,
//         stickyRowAlignment = null;
//
//   final Alignment contentCellAlignment;
//   final List<Alignment> columnAlignments;
//   final List<Alignment> rowAlignments;
//   final List<List<Alignment>> contentCellAlignments;
//   final Alignment stickyColumnAlignment;
//   final List<Alignment> stickyColumnAlignments;
//   final Alignment stickyRowAlignment;
//   final List<Alignment> stickyRowAlignments;
//   final Alignment stickyLegendAlignment;
//
//   Alignment contentAlignment(int i, int j) {
//     if (contentCellAlignment != null) {
//       return contentCellAlignment;
//     } else if (columnAlignments != null) {
//       return columnAlignments[j];
//     } else if (rowAlignments != null) {
//       return rowAlignments[i];
//     } else if (contentCellAlignments != null) {
//       return contentCellAlignments[i][j];
//     }
//   }
//
//   Alignment rowAlignment(int i) {
//     if( stickyRowAlignments != null){
//       return stickyRowAlignments[i];
//     }else{
//       return stickyRowAlignment;
//     }
//   }
//
//   Alignment columnAlignment(int i) {
//     if( stickyColumnAlignments != null){
//       return stickyColumnAlignments[i];
//     }else{
//       return stickyColumnAlignment;
//     }
//   }
//
//   void runAssertions(int rowsLength, int columnsLength) {
//     assert(contentCellAlignment != null ||
//         columnAlignments != null ||
//         rowAlignments != null ||
//         contentCellAlignments != null);
//     assert(stickyColumnAlignment != null || stickyColumnAlignments != null);
//     assert(stickyRowAlignment != null || stickyRowAlignments != null);
//     if (columnAlignments != null) {
//       assert(columnAlignments.length == columnsLength);
//     }
//     if (rowAlignments != null) {
//       assert(rowAlignments.length == rowsLength);
//     }
//     if (contentCellAlignments != null) {
//       assert(contentCellAlignments.length == rowsLength);
//       for (int i = 0; i < contentCellAlignments.length; i++) {
//         assert(contentCellAlignments[i].length == columnsLength);
//       }
//     }
//     if (stickyColumnAlignments != null) {
//       assert(stickyColumnAlignments.length == rowsLength);
//     }
//     if (stickyRowAlignments != null) {
//       assert(stickyRowAlignments.length == columnsLength);
//     }
//   }
// }