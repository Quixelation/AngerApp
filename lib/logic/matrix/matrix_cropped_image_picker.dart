part of matrix;

Future<Uint8List?> _getCroppedLibraryImage(BuildContext context) async {
  final _picker = ImagePicker();
  logger.d("Pick Image");
  var file = await _picker.pickImage(source: ImageSource.gallery);
  if (file == null) return null;

  var fileBytes = await file.readAsBytes();

  var cropped = await Navigator.of(context).push<Uint8List>(MaterialPageRoute(
      builder: (context) => _MatrixImageCrop(
            fileBytes: fileBytes,
          )));

  return fileBytes;
}
