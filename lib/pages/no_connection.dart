import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoConnectionColumn extends StatelessWidget {
  final List<Widget> footerWidgets;
  final bool showImage;
  final String title;
  final String subtitle;
  const NoConnectionColumn(
      {this.showImage = true,
      this.footerWidgets = const [],
      this.title = "Keine Verbindung",
      this.subtitle =
          "Wir konnten leider keine Verbindung zum Server herstellen.",
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showImage) ...[
          const SizedBox(height: 64),
          Center(
            child: SvgPicture.asset("assets/undraw/undraw_outer_space.svg",
                width: 250),
          ),
          const SizedBox(height: 48),
        ],
        Center(
          child: Opacity(
            opacity: 0.87,
            child: Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Opacity(
              opacity: 0.6,
              child: Text(subtitle, style: const TextStyle(fontSize: 18)),
            ),
          ),
        ),
        if (footerWidgets.isNotEmpty) ...[
          const SizedBox(height: 32),
          ...footerWidgets
        ],
      ],
    );
  }
}
