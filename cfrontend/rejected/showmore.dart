//
//
// import 'package:flutter/material.dart';
//
// class ShowMore extends LeafRenderObjectWidget {
//   const ShowMore({
//     super.key,
//     required this.text,
//     required this.shouldLines,
//   });
//
//   final String text;
//   final int Function(int actualLines) shouldLines;
//
//   @override
//   RenderObject createRenderObject(BuildContext context) {
//     return ShowMoreRenderObj(
//         shouldLines: shouldLines,
//         text: text,
//         textDirection: Directionality.of(context),
//         textStyle: Theme.of(context).textTheme.bodyText1!);
//   }
//
//   @override
//   void updateRenderObject(
//       BuildContext context,
//       ShowMoreRenderObj renderObject,
//       ) {
//     renderObject.text = text;
//   }
// }
//
// class ShowMoreRenderObj extends RenderBox {
//   ShowMoreRenderObj(
//       {required String text,
//         required int Function(int actualLines) shouldLines,
//         required TextDirection textDirection,
//         required TextStyle textStyle}) {
//     this.shouldLines = shouldLines;
//     _textPainter = TextPainter(
//         text: TextSpan(text: text, style: textStyle),
//         textDirection: textDirection);
//   }
//
//   TextPainter resetWith({int? maxLines}) => TextPainter(
//       text: _textPainter.text,
//       textDirection: _textPainter.textDirection,
//       maxLines: maxLines ?? _textPainter.maxLines);
//
//   late int Function(int actualLines) _shouldLines;
//   late TextPainter _textPainter;
//   late int maxLines;
//
//   String get text => _textPainter.plainText;
//
//   set text(String val) {
//     if (val == _textPainter.plainText) return;
//     _textPainter.text = TextSpan(text: text, style: _textPainter.text?.style);
//     markNeedsLayout();
//     markNeedsPaint();
//     markNeedsSemanticsUpdate();
//   }
//
//   set shouldLines(int Function(int actualLines) val) {
//     _shouldLines = val;
//     markNeedsLayout();
//     markNeedsSemanticsUpdate();
//   }
//
//   @override
//   void describeSemanticsConfiguration(SemanticsConfiguration config) {
//     super.describeSemanticsConfiguration(config);
//     config.isSemanticBoundary = true;
//     config.label = _textPainter.text!.toPlainText();
//     config.textDirection = _textPainter.textDirection;
//   }
//
//   @override
//   double computeMinIntrinsicWidth(double height) {
//     _layoutText(double.infinity);
//     return _textPainter.width;
//   }
//
//   @override
//   double computeMinIntrinsicHeight(double width) =>
//       computeMaxIntrinsicHeight(width);
//
//   @override
//   double computeMaxIntrinsicHeight(double width) {
//     final computedSize = _layoutText(width);
//     return computedSize.height;
//   }
//
//   @override
//   void performLayout() {
//     _textPainter.layout(maxWidth: constraints.maxWidth);
//     List<ui.LineMetrics> lines = _textPainter.computeLineMetrics();
//     maxLines = _shouldLines(lines.length);
//     _textPainter = resetWith(maxLines: maxLines);
//     size = constraints.constrain(_layoutText(constraints.maxWidth));
//   }
//
//   Size _layoutText(double maxWidth) {
//     if (_textPainter.text?.toPlainText() == '') return Size.zero;
//     assert(maxWidth > 0, 'Received a `maxWidth` value of $maxWidth.');
//     _textPainter.layout(maxWidth: maxWidth);
//     List<ui.LineMetrics> lines = _textPainter.computeLineMetrics();
//     double maxLineHeight = lines.first.height * _shouldLines(lines.length);
//     return Size(_textPainter.width, min(_textPainter.height, maxLineHeight));
//   }
//
//   @override
//   void paint(PaintingContext context, Offset offset) {
//     if (_textPainter.text?.toPlainText() == '') return;
//     _textPainter.paint(context.canvas, offset);
//   }
// }
