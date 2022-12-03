part of matrix;

class MatrixSasDialog extends StatelessWidget {
  const MatrixSasDialog(this.event, {Key? key}) : super(key: key);

  final KeyVerification event;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton.icon(
            onPressed: () {
              event.acceptSas();
            },
            icon: Icon(Icons.verified_user),
            label: Text("Emojis stimmen überein"))
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text("Verification"), Text(event.sasEmojis.map((e) => e.emoji).toList().join(" "))],
      ),
    );
  }
}
