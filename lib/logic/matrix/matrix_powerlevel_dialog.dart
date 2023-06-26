part of matrix;

class _MatrixPowerLevelDialog extends StatelessWidget {
  const _MatrixPowerLevelDialog({Key? key, required this.currentPowerLevel}) : super(key: key);

  final int currentPowerLevel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Wähle ein Power-Level aus",
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          powerLevelButton(
              currentPowerLevel: currentPowerLevel,
              level: 0,
              onTap: (val) {
                Navigator.pop(context, val);
              }),
          powerLevelButton(
              currentPowerLevel: currentPowerLevel,
              level: 50,
              onTap: (val) {
                Navigator.pop(context, val);
              }),
          powerLevelButton(
              currentPowerLevel: currentPowerLevel,
              level: 100,
              onTap: (val) {
                Navigator.pop(context, val);
              }),
          //TODO: Custom Power-Level
        ],
      ),
    );
  }

  Widget powerLevelButton({required int currentPowerLevel, required int level, required void Function(int level) onTap}) {
    String additionalInfo = "";

    if (level == 0) {
      additionalInfo = " (Normal)";
    } else if (level == 50) {
      additionalInfo = " (Moderator)";
    } else if (level == 100) {
      additionalInfo = " (Administrator)";
    }

    var widget = Row(
      children: [
        Text(
          level.toString() + additionalInfo,
        )
      ],
    );

    return currentPowerLevel == level
        ? ElevatedButton(onPressed: () {}, child: widget)
        : OutlinedButton(
            onPressed: () {
              onTap(level);
            },
            child: widget);
  }
}
