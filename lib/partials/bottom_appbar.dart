import 'package:anger_buddy/components/animated_cliprect.dart';

import 'package:flutter/material.dart';

class MainBottomAppBar extends StatefulWidget {
  const MainBottomAppBar({Key? key}) : super(key: key);

  @override
  State<MainBottomAppBar> createState() => _MainBottomAppBarState();
}

class _MainBottomAppBarState extends State<MainBottomAppBar>
    with TickerProviderStateMixin {
  bool opened = false;

  void toggle() {
    setState(() {
      opened = !opened;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: Colors.indigo,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    toggle();
                  },
                ),
                const Expanded(child: SizedBox()),
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          AnimatedClipRect(
            open: opened,
            horizontalAnimation: false,
            verticalAnimation: true,
            alignment: Alignment.bottomCenter,
            duration: const Duration(milliseconds: 750),
            curve: Curves.fastLinearToSlowEaseIn,
            reverseCurve: Curves.fastLinearToSlowEaseIn.flipped,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 400,
              ),
              child: GridView.count(
                crossAxisCount: 4,
                children: [
                  _NavGridTile(
                      title: "Nachrichten", icon: Icons.now_widgets_rounded),
                  _NavGridTile(
                      title: "Nachrichten", icon: Icons.now_widgets_rounded),
                  _NavGridTile(
                      title: "Nachrichten", icon: Icons.now_widgets_rounded),
                  _NavGridTile(
                      title: "Nachrichten", icon: Icons.now_widgets_rounded),
                  _NavGridTile(
                      title: "Nachrichten", icon: Icons.now_widgets_rounded),
                  _NavGridTile(
                      title: "Nachrichten", icon: Icons.now_widgets_rounded),
                  _NavGridTile(
                      title: "Nachrichten", icon: Icons.now_widgets_rounded),
                  _NavGridTile(
                      title: "Nachrichten", icon: Icons.now_widgets_rounded),
                  _NavGridTile(
                      title: "Nachrichten", icon: Icons.now_widgets_rounded),
                  _NavGridTile(
                      title: "Nachrichten", icon: Icons.now_widgets_rounded),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _NavGridTile extends StatelessWidget {
  String title;
  IconData icon;

  _NavGridTile({Key? key, required this.title, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade200),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
