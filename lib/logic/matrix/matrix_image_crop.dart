part of matrix;

class _MatrixImageCrop extends StatefulWidget {
  const _MatrixImageCrop({Key? key, required this.fileBytes}) : super(key: key);

  final Uint8List fileBytes;

  @override
  State<_MatrixImageCrop> createState() => __MatrixImageCropState();
}

class __MatrixImageCropState extends State<_MatrixImageCrop> {
  final _controller = CropController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bild zuschneiden")),
      body: Crop(
        image: widget.fileBytes,
        controller: _controller,
        onCropped: (image) {
          Navigator.pop(context, image);
        },
        aspectRatio: 1,
        progressIndicator: Center(child: CircularProgressIndicator.adaptive()),
        withCircleUi: true,
        // initialSize: 0.5,
        // initialArea: Rect.fromLTWH(240, 212, 800, 600),
        // initialAreaBuilder: (rect) => Rect.fromLTRB(rect.left + 24, rect.top + 32, rect.right - 24, rect.bottom - 32),

        baseColor: Colors.blue.shade900,
        maskColor: Colors.white.withAlpha(150),
        radius: 0,

        onStatusChanged: (value) {},
        cornerDotBuilder: (size, edgeAlignment) => DotControl(color: Theme.of(context).colorScheme.primary),
        interactive: false,
        // fixArea: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.cropCircle();
        },
        child: Icon(Icons.check),
        tooltip: "Zuschneiden bestätigen",
      ),
    );
  }
}
