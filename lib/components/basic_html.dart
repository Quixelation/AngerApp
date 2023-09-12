import 'package:anger_buddy/utils/url.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_html/flutter_html.dart';

class BasicHtml extends StatelessWidget {
  const BasicHtml(this.data, {super.key});

  final String data;

  @override
  Widget build(BuildContext context) {
    return Html(
      data: data,
      style: {"*": Style(fontSize: FontSize(1.1, Unit.rem))},
      onLinkTap: (url, attributes, element) {
        if (url != null) {
          launchURL(url, context);
        }
      },
    );
  }
}
