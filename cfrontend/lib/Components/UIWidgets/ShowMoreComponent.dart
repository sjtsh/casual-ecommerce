import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../Constants/SpacePalette.dart';

class ShowMoreComponent extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const ShowMoreComponent(this.text, {super.key, this.style});

  @override
  State<ShowMoreComponent> createState() => _ShowMoreComponentState();
}

class _ShowMoreComponentState extends State<ShowMoreComponent> {
  bool showMore = true;

  changeShowMore() => setState(() => showMore = !showMore);

  bool crossedMax(BoxConstraints constraints) {
    TextPainter p = TextPainter(
        text: TextSpan(text: widget.text, style: widget.style),
        textDirection: Directionality.of(context))
      ..layout(maxWidth: constraints.maxWidth);
    int trueLines = p.computeLineMetrics().length;
    return trueLines > 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      bool crossedMax = this.crossedMax(constraints);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: widget.style,
            overflow: (crossedMax && showMore)
                ? TextOverflow.ellipsis
                : TextOverflow.visible,
            maxLines: (crossedMax && showMore) ? 1 : 10,
          ),
          SpacePalette.spaceTiny,
          if (crossedMax)
            GestureDetector(
                onTap: () {
                  setState(() {
                    showMore = !showMore;
                  });
                },
                child: Container(
                    color: Colors.transparent,
                    child: Text(showMore ? "Show more" : "Show less",
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold)))),
        ],
      );
    });
  }
}
