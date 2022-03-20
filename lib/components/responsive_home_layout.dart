import 'package:flutter/material.dart';

class ResponseHomeLayout extends StatefulWidget {
  List<Widget> widgets;
  ResponseHomeLayout(this.widgets, {Key? key}) : super(key: key);

  @override
  State<ResponseHomeLayout> createState() => _ResponseHomeLayoutState();
}

class _ResponseHomeLayoutState extends State<ResponseHomeLayout> {
  List<List<Widget>> splitupWidgets() {
    var result = <List<Widget>>[];
    final width = MediaQuery.of(context).size.width;

    if (width < 700) {
      for (var i = 0; i < widget.widgets.length; i++) {
        int index = i % 2 == 0 ? 0 : 1;
        if (result[index] == null) {
          result[index] = [];
        }
        result[index].add(widget.widgets[i]);
      }
    } else {
      result.add(widget.widgets);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final widgetList = splitupWidgets();
    return Container(
      child: Row(
        children: [
          for (int i = 0; i < widgetList.length; i++)
            Column(children: widgetList[i])
        ],
      ),
    );
  }
}
