// import 'package:flutter/material.dart';
//
// /// Alignment for cell contents.
// class CellAlignments {
//   static const CellAlignments base = CellAlignments.uniform(Alignment.center);
//
//   /// Same alignment for each cell.
//   const CellAlignments.uniform(Alignment alignment)
//       : this.fixed(
//     contentCellAlignment: alignment,
//     stickyColumnAlignment: alignment,
//     stickyRowAlignment: alignment,
//     stickyLegendAlignment: alignment,
//   );
//
//   /// Same alignment for each content cell, but different alignment for the
//   /// sticky column, row and legend.
//   const CellAlignments.fixed({
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
//   const CellAlignments.variableColumnAlignment({
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
//   const CellAlignments.variableRowAlignment({
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
//   const CellAlignments.variable({
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
//       if( stickyRowAlignments != null){
//         return stickyRowAlignments[i];
//       }else{
//         return stickyRowAlignment;
//       }
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