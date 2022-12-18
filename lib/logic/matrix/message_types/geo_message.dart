part of matrix;

String googleMapsUrlGenerator(String geoString) {
  return "https://www.google.com/maps/place/${geoString.replaceFirst("geo:", "")}";
}

class ChatBubbleLocationRenderer extends StatelessWidget {
  const ChatBubbleLocationRenderer(this.event, {Key? key}) : super(key: key);

  final Event event;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () {
          launchURL(googleMapsUrlGenerator(event.body), context);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.map_outlined),
            SizedBox(
              width: 8,
            ),
            Text("In Google-Maps öffnen"),
            // SizedBox(
            //   width: 8,
            // ),
            // Icon(Icons.open_in_new),
          ],
        ));
  }
}
