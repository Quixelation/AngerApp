part of matrix;

class _MatrixChatNotice extends StatelessWidget {
  const _MatrixChatNotice({Key? key, required this.child, this.icon, required this.event}) : super(key: key);

  final Widget child;
  final Widget? icon;
  final Event? event;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context).copyWith(iconTheme: Theme.of(context).iconTheme.copyWith(size: 16));

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: InkWell(
          onTap: ((getIt.get<AppManager>().devtools.valueWrapper?.value ?? false) && event != null)
              ? () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      var encoder = const JsonEncoder.withIndent("     ");
                      var text = encoder.convert(event!.toJson());
                      return Material(child: SingleChildScrollView(child: Text(text)));
                    },
                  );
                }
              : null,
          child: Card(
              child: Padding(
            padding: EdgeInsets.all(8),
            child: Opacity(
              opacity: 0.67,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Theme(data: themeData, child: icon!),
                    const SizedBox(width: 4),
                  ],
                  child
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}
