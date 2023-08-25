part of hip;

class _NotenCountChart extends StatelessWidget {
  const _NotenCountChart(this.noten);

  final List<DataNote> noten;

  @override
  Widget build(BuildContext context) {
    var notenCount = List.generate(16, (index) => 0);

    for (var note in noten) {
      notenCount[note.note]++;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16).copyWith(right: 16),
      child: BarChart(BarChartData(
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(),
          barTouchData: BarTouchData(
            enabled: true,
          ),
          groupsSpace: 16,
          barGroups: [
            for (var note = 0; note < notenCount.length; note++)
              BarChartGroupData(x: note, barsSpace: 16, barRods: [
                BarChartRodData(
                    toY: (notenCount[note]).toDouble(),
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    width: 15)
              ])
          ])),
    );
  }
}
