import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';

class FormattedText extends StatefulWidget {
  final String text;

  const FormattedText(this.text, {super.key});

  @override
  State<FormattedText> createState() => _FormattedTextState();
}

class _FormattedTextState extends State<FormattedText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    List<TextSpan> formatText(BuildContext context, String text) {
      final RegExp regex = RegExp(r'\((.*?)\)');
      final List<TextSpan> spans = [];
      final matches = regex.allMatches(text);
      final List<String> uniqueDescriptions = [];

      int lastEnd = 0;

      for (final match in matches) {
        final beforeMatch = text.substring(lastEnd, match.start);
        if (beforeMatch.isNotEmpty) {
          spans.add(TextSpan(
            text: '$beforeMatch\n',
            style: defaultLabelText(context, fontWeight: FontWeight.w600),
          ));
        }

        final description = match.group(1);
        if (description != null) {
          var descriptionStrings =
              description.split(',').map((s) => s.trim()).toList();
          final List<String> selectedDescriptions = [];

          for (var desc in descriptionStrings) {
            bool isUnique = true;
            for (var uniqueDesc in uniqueDescriptions) {
              if (uniqueDesc.contains(desc) || desc.contains(uniqueDesc)) {
                isUnique = false;
                break;
              }
            }
            if (isUnique) {
              uniqueDescriptions.add(desc);
              selectedDescriptions.add(desc);
              if (selectedDescriptions.length == 2) {
                break;
              }
            }
          }

          if (selectedDescriptions.isNotEmpty) {
            String formattedDescription;
            if (selectedDescriptions.length == 2) {
              formattedDescription =
                  '[${selectedDescriptions[0]} along with ${selectedDescriptions[1]}]\n';
            } else {
              formattedDescription = '[${selectedDescriptions[0]}]\n';
            }
            spans.add(TextSpan(
              text: formattedDescription,
              style: defaultLabelTextItalic(context,
                  fontColor: Theme.of(context).hintColor),
            ));
          }
        }

        lastEnd = match.end;
      }

      final afterLastMatch = text.substring(lastEnd);
      if (afterLastMatch.isNotEmpty) {
        spans.add(TextSpan(
          text: afterLastMatch,
          style: defaultLabelText(context),
        ));
      }

      return spans;
    }

    List<TextSpan> getFormattedTextSpans() {
      final List<TextSpan> spans = formatText(context, widget.text);
      if (!_isExpanded) {
        final previewSpans = <TextSpan>[];
        int currentLength = 0;
        for (final span in spans) {
          final spanText = span.text ?? '';
          if (currentLength + spanText.length > 100) {
            previewSpans.add(TextSpan(
                text: '${spanText.substring(0, 100 - currentLength)}...'));
            break;
          }
          previewSpans.add(span);
          currentLength += spanText.length;
        }
        return previewSpans;
      }
      return spans;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: getFormattedTextSpans(),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Text(
            _isExpanded ? 'Show Less' : 'Show More',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
