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
            icon: const Icon(Icons.verified_user),
            label: const Text("Emojis stimmen überein"))
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [const Text("Verification"), Text(event.sasEmojis.map((e) => e.emoji).toList().join(" "))],
      ),
    );
  }
}
