part of matrix;

class MatrixArchivedRoomsPage extends StatefulWidget {
  const MatrixArchivedRoomsPage({super.key});

  @override
  State<MatrixArchivedRoomsPage> createState() =>
      _MatrixArchivedRoomsPageState();
}

class _MatrixArchivedRoomsPageState extends State<MatrixArchivedRoomsPage> {
  List<Room>? _archivedRooms;

  @override
  void initState() {
    super.initState();
    AngerApp.matrix.client.loadArchive().then((value) {
      setState(() {
        _archivedRooms = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Archivierte Räume")),
        body: _archivedRooms == null
            ? const Center(child: CircularProgressIndicator.adaptive())
            : (_archivedRooms!.length == 0
                ? Center(child: Text("Keine archivierten Räume"))
                : ListView.builder(
                    itemCount: _archivedRooms!.length,
                    itemBuilder: (context, index) => AngerApp.matrix
                        .buildListTile(context, _archivedRooms![index],
                            showLogo: true),
                  )));
  }
}
