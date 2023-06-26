part of homepage;

class HomepageWidget extends StatelessWidget {
  const HomepageWidget({Key? key, required this.builder, required this.show}) : super(key: key);

  final Widget Function(BuildContext context) builder;
  final bool show;

  @override
  Widget build(BuildContext context) {
    if (show) {
      return Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: builder(context));
    } else {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
  }
}
