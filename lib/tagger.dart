import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:characters/characters.dart';

class Tagger extends StatefulWidget {
  final String? label;
  final TaggerController? controller;
  final EdgeInsets padding;
  final double minWidth;
  final TextStyle textStyle;
  final String? hint;
  final TextStyle hintTextStyle;
  final TextStyle buttonTextStyle;
  final Color textFieldBackgroundColor;
  final Color tagButtonColor;
  final Color tagButtonIconColor;
  final ValueChanged<String>? onChanged;
  final EdgeInsets textFieldPadding;
  final Widget? prefix;
  final double prefixWidth;

  const Tagger({
    Key? key,
    this.label,
    this.controller,
    this.padding = const EdgeInsets.all(8),
    this.minWidth = 60,
    this.textStyle = const TextStyle(fontSize: 16),
    this.hint,
    this.hintTextStyle = const TextStyle(
      fontSize: 16,
      color: Color(0xffA2A2A2),
    ),
    this.buttonTextStyle = const TextStyle(
      fontSize: 14,
      color: Colors.white,
    ),
    this.textFieldBackgroundColor = const Color(0xfffff5b0),
    this.tagButtonColor = const Color(0xff005779),
    this.tagButtonIconColor = Colors.white,
    this.onChanged,
    this.textFieldPadding = const EdgeInsets.symmetric(
      vertical: 8,
      horizontal: 12,
    ),
    this.prefix,
    this.prefixWidth = 0,
  }) : super(key: key);

  @override
  _TaggerState createState() => _TaggerState();
}

class _TaggerState extends State<Tagger> {
  late TaggerController controller;
  TextEditingController? lc;
  ValueNotifier<double> textWidthNotifier = ValueNotifier<double>(0);
  BoxConstraints? lastConstraints;

  List<String> buttonStrings = <String>[];
  List<Widget> buttons = <Widget>[];
  FocusNode focusNode = FocusNode();
  String? lastText;

  @override
  void initState() {
    super.initState();

    controller = widget.controller ?? TaggerController();

    controller._onWholeTextChanged = onWholeTextChanged;
    controller._onTagsRequested = onTagsRequested;

    controller.addListener(() {
      onTextChanged();
      lc = TextEditingController.fromValue(controller.value);
    });

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (controller.text.isNotEmpty) onTextChanged();
      if (textWidthNotifier.value == 0 && lastConstraints != null) {
        textWidthNotifier.value =
            lastConstraints!.maxWidth - widget.padding.horizontal -
                widget.prefixWidth - (widget.prefix != null ? 8 : 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        lastConstraints = constraints;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8)
                    .copyWith(bottom: 6),
                child: Text(
                  widget.label!,
                  style: TextStyle(fontSize: 12, color: Color(0xff686868)),
                ),
              ),
            Container(
              padding: widget.padding,
              width: constraints.maxWidth,
              color: Colors.white,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (widget.prefix != null)Container(
                    width: widget.prefixWidth, child: widget.prefix!,),
                  ...buttons,
                  ValueListenableBuilder(
                    valueListenable: textWidthNotifier,
                    builder: (BuildContext context, double textWidthValue,
                        Widget? child) {
                      return RawKeyboardListener(
                        focusNode: focusNode,
                        onKey: (key) {
                          if (key.runtimeType.toString() == 'RawKeyDownEvent') {
                            if (key.logicalKey ==
                                LogicalKeyboardKey.backspace) {
                              if (controller.text.isEmpty &&
                                  buttonStrings.isNotEmpty) {
                                whenEditLastTag();
                              }
                            }
                          }
                        },
                        child: Container(
                          width: textWidthValue,
                          decoration: BoxDecoration(
                            color: widget.textFieldBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: controller,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              isDense: true,
                              hintStyle: widget.hintTextStyle,
                              hintText: widget.hint,
                              contentPadding: widget.textFieldPadding,
                              suffixIconConstraints:
                              BoxConstraints(minHeight: 0),
                              prefixIconConstraints:
                              BoxConstraints(minHeight: 0),
                              border: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                            ),
                            style: widget.textStyle,
                            onSubmitted: (s) {
                              checkForTags("$s ");
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void onTextChanged() {
    String s = controller.text;

    if (widget.onChanged != null) widget.onChanged!(s);

    if (s == lastText) return;

    lastText = s;

    checkForTags(s);
  }

  void checkForTags(String s) {
    List<String> parts = s.split(" ").map((e) => e.trim()).toList();

    List<String> filteredParts = <String>[];

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty || i == parts.length - 1) {
        filteredParts.add(parts[i]);
      }
    }

    if (filteredParts.length > 1) {
      buttonStrings.addAll(
        filteredParts.getRange(0, filteredParts.length - 1),
      );
      buttons.addAll(
        filteredParts.getRange(0, filteredParts.length - 1).map(
              (e) {
            TextPainter tp = TextPainter(
              text: TextSpan(text: e, style: widget.buttonTextStyle),
              textDirection: TextDirection.ltr,
            );

            tp.layout();

            double textWidth = min(
              tp.width,
              (lastConstraints!.maxWidth - widget.padding.horizontal) -
                  18 -
                  16, //18 is icon + padding
            );

            return InkWell(
              onTap: () {
                int index = buttonStrings.indexOf(e);
                buttons.removeAt(index);
                buttonStrings.removeAt(index);
                refresh();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: widget.tagButtonColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: textWidth,
                      child: Text(
                        e.overflow,
                        overflow: TextOverflow.ellipsis,
                        style: widget.buttonTextStyle,
                        maxLines: 1,
                      ),
                    ),
                    Icon(
                      Icons.close,
                      size: 18,
                      color: widget.tagButtonIconColor,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      textWidthNotifier.value = whenButtonChanged();
    }

    controller.text = filteredParts.last;
    controller.selection = controller.value.selection.copyWith(
      extentOffset: filteredParts.last.length,
      baseOffset: filteredParts.last.length,
    );

    TextPainter tp = TextPainter(
      text: TextSpan(text: controller.text, style: widget.textStyle),
      textDirection: TextDirection.ltr,
    );

    tp.layout();

    double textWidth = min(
      max(tp.width + widget.textFieldPadding.horizontal + 2, widget.minWidth),
      lastConstraints!.maxWidth - 18,
    );

    if (textWidth > textWidthNotifier.value)
      textWidthNotifier.value = textWidth;
    else if (textWidth < textWidthNotifier.value) {
      double shouldBe = whenButtonChanged();
      if (textWidth < shouldBe) {
        textWidthNotifier.value = shouldBe;
      } else {
        textWidthNotifier.value = textWidth;
      }
    }

    refresh();
  }

  double whenButtonChanged() {
    double availableWidth =
    (lastConstraints!.maxWidth - widget.padding.left);

    List<double> computedWidths = buttonStrings.map((e) {
      TextPainter tp = TextPainter(
        text: TextSpan(text: e, style: widget.buttonTextStyle),
        textDirection: TextDirection.ltr,
      );

      tp.layout();

      /// 18 is icon width
      /// 16 is button padding
      /// 8 is right margin for button
      return tp.width + 18 + 16 + 8;
    }).toList();

    computedWidths.insert(0, widget.prefixWidth +
        (widget.prefix != null ? 8 : 0));

    double totalWidth = computedWidths.isEmpty
        ? 0
        : computedWidths.reduce(
          (value, element) {
        double maybeNext = value + element;

        if (maybeNext > availableWidth) {
          return element;
        }

        return maybeNext;
      },
    );

    double shouldBe = totalWidth > availableWidth
        ? availableWidth - widget.padding.right
        : (availableWidth - totalWidth - widget.padding.right);

    if (shouldBe < widget.minWidth)
      shouldBe = availableWidth - widget.padding.right;

    return shouldBe;
  }

  void whenEditLastTag() {
    lastText = buttonStrings.last;

    String l = buttonStrings.last;

    buttons.removeLast();
    buttonStrings.removeLast();

    double temp = whenButtonChanged();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      controller.value = controller.value.copyWith(
        selection: controller.selection.copyWith(
          extentOffset: l.length,
          baseOffset: l.length,
        ),
      );
    });

    controller.value = controller.value.copyWith(
      text: l,
    );

    TextPainter tp = TextPainter(
      text: TextSpan(
        text: controller.text,
        style: widget.textStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    tp.layout();

    double textWidth = min(
      tp.width + widget.textFieldPadding.horizontal + 2,
      (lastConstraints!.maxWidth - widget.padding.horizontal) -
          18 -
          16, //18 is icon + padding
    );

    if (textWidth > temp)
      textWidthNotifier.value = textWidth;
    else if (textWidth < temp) {
      double shouldBe = whenButtonChanged();
      if (textWidth < shouldBe) {
        textWidthNotifier.value = shouldBe;
      } else {
        textWidthNotifier.value = textWidth;
      }
    }
    // });

    refresh();
  }

  void onWholeTextChanged(String wholeText) {
    buttons.clear();
    buttonStrings.clear();
    controller.text = wholeText;
    refresh();
  }

  List<String> onTagsRequested() {
    return buttonStrings;
  }
}

extension on State {
  void refresh() {
    if (this.mounted) {
      setState(() {});
    }
  }
}

typedef WholeTextCallback = void Function(String data);
typedef TagsGetterCallback = List<String> Function();

class TaggerController extends TextEditingController {
  WholeTextCallback? _onWholeTextChanged;
  TagsGetterCallback? _onTagsRequested;

  set wholeText(String newWholeText) {
    if (_onWholeTextChanged != null) {
      _onWholeTextChanged!(newWholeText);
    }
  }

  List<String> get tags {
    if (_onTagsRequested != null)
      return List<String>.from(_onTagsRequested!())
        ..add(this.text);
    else
      return <String>[]..add(this.text);
  }
}


extension on String {
  String get overflow =>
      Characters(this)
          .replaceAll(Characters(''), Characters('\u{200B}'))
          .toString();
}
