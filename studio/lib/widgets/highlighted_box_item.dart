import 'package:code_arrow_creator_studio/defaults/fonts.dart';
import 'package:code_arrow_creator_studio/screens/home/home.dart';
import 'package:flutter/material.dart';

class HighlightedBoxItem extends StatefulWidget {
  final Icon icon;
  final String label;
  final Function? callback;
  final int index;
  const HighlightedBoxItem({super.key, required this.icon, required this.label, required this.callback, required this.index});

  @override
  State<HighlightedBoxItem> createState() => _HighlightedBoxItemState();
}

class _HighlightedBoxItemState extends State<HighlightedBoxItem> {
  Widget _buildIcon(BuildContext context) {
    if (_isHovering) {
      return Icon(widget.icon.icon, color: Theme.of(context).colorScheme.primary);
    }

    if (CreatorStudioHome.selectedThing[widget.index]) {
      return Icon(widget.icon.icon, color: Theme.of(context).colorScheme.primary);
    } else {
      return Icon(
        widget.icon.icon,
        color: Theme.of(context).disabledColor,
      );
    }
  }

  TextStyle _buildTextStyle(BuildContext context) {
    if (_isHovering) {
      return defaultDarkLabelText(context, fontColor: Theme.of(context).colorScheme.primary);
    }

    if (CreatorStudioHome.selectedThing[widget.index]) {
      return defaultDarkLabelText(context, fontColor: Theme.of(context).colorScheme.primary);
    } else {
      return defaultDarkLabelText(context, fontColor: Theme.of(context).hintColor);
    }
  }

  bool _isHovering = false;

  Color _buildColor(BuildContext context) {
    Color defaultColor = Theme.of(context).canvasColor;
    Color hoverColor = Theme.of(context).hoverColor;

    if (_isHovering) {
      return hoverColor;
    } else {
      return defaultColor;
    }
  }

  Color _buildArrowColor(BuildContext context) {
    Color defaultColor = Theme.of(context).canvasColor;
    Color hoverColor = Theme.of(context).colorScheme.primary;

    if (_isHovering) {
      return hoverColor;
    } else {
      return defaultColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.callback!(widget.index);
        setState(() {});
      },
      onHover: (hovering) {
        _isHovering = hovering;
        setState(() {});
      },
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(left: 5),
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
            color: CreatorStudioHome.selectedThing[widget.index] ? Theme.of(context).highlightColor : _buildColor(context),
            borderRadius: BorderRadius.circular(5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(margin: const EdgeInsets.only(left: 10), child: _buildIcon(context)),
                Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Text(
                      widget.label,
                      style: _buildTextStyle(context),
                    )),
              ],
            ),
            Icon(
              Icons.arrow_forward,
              color: CreatorStudioHome.selectedThing[widget.index] ? Theme.of(context).colorScheme.primary : _buildArrowColor(context),
            )
          ],
        ),
      ),
    );
  }
}
