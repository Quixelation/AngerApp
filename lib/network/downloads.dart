import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:http/http.dart' as http;
import "package:html/parser.dart";

abstract class WpdmTreeItem {}

class WpdmDirectory extends WpdmTreeItem {
  String name;
  int dirId;
  WpdmDirectory({required this.name, required this.dirId});
}

class WpdmFile extends WpdmTreeItem {
  String name;
  Uri fileIconUri;
  String fileType;
  Uri fileUri;
  WpdmFile(
      {required this.name,
      required this.fileIconUri,
      required this.fileType,
      required this.fileUri});
}

// Make network request to fetch downloads and return them as a list of WpdmTreeItem
Future<AsyncDataResponse<List<WpdmTreeItem>?>> fetchDownloads(
    {int? dir}) async {
  try {
    var url = Uri.parse(AppManager.urls.downloads);
    var response = await http.post(
      url,
      body: {"dir": dir == null ? "/" : dir.toString()},
    );
    printInDebug(response.body);
    if (response.statusCode != 200) {
      printInDebug("Code not 200 --> Downloads");
      return AsyncDataResponse(
          data: null,
          loadingAction: AsyncDataResponseLoadingAction.none,
          error: true,
          allowReload: true);
    }
    var document = parse(response.body);
    final rawItems = document.querySelectorAll("li");
    final treeItems = rawItems.map((rawItem) {
      final isDir = rawItem.classes.contains("directory");
      final isFile = rawItem.classes.contains("file");
      if (isDir) {
        return WpdmDirectory(
            name: rawItem.text,
            dirId: int.parse(rawItem.children[0].attributes["rel"]!));
      } else if (isFile) {
        return WpdmFile(
            name: rawItem.text,
            fileIconUri: extractUrl(rawItem.attributes["style"]!),
            fileType: _getExtension(rawItem.className),
            fileUri: Uri.parse(rawItem.children[0].attributes["href"]!));
      } else {
        throw "Unknown item type";
      }
    }).toList();
    printInDebug(treeItems);
    return AsyncDataResponse(
        data: treeItems, loadingAction: AsyncDataResponseLoadingAction.none);
  } catch (e) {
    return AsyncDataResponse(
        data: null,
        loadingAction: AsyncDataResponseLoadingAction.none,
        error: true,
        allowReload: true);
  }
}

// Extract Url out of text
Uri extractUrl(String text) {
  var urlRegex = RegExp(r"(https?:\/\/[^\s]+)");
  var match = urlRegex.firstMatch(text);
  if (match == null) {
    throw "No Url found";
  }
  return Uri.parse(match.group(0)!);
}

// Get class name beginning with "ext-"
String _getExtension(String text) {
  var extRegex = RegExp(r"ext_\w+");
  var match = extRegex.firstMatch(text);
  if (match == null) {
    throw "No extension found";
  }
  return match.group(0)!;
}
