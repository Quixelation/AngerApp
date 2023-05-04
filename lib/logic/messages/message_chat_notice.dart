part of messages;

class MessagingChatNotice extends StatelessWidget {
  const MessagingChatNotice({Key? key, required this.child, this.icon, required this.matrixEvent}) : super(key: key);

  final Widget child;
  final Widget? icon;
  final Event? matrixEvent;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context).copyWith(iconTheme: Theme.of(context).iconTheme.copyWith(size: 16));

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: InkWell(
          onTap: ((getIt.get<AppManager>().devtools.valueWrapper?.value ?? false) && matrixEvent != null)
              ? () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      var encoder = const JsonEncoder.withIndent("     ");
                      var text = encoder.convert(matrixEvent!.toJson());
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
                    const SizedBox(width: 8),
                  ],
                  Flexible(child: child)
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}
