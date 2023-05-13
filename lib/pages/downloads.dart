// import 'package:anger_buddy/network/downloads.dart';
// import 'package:anger_buddy/pages/no_connection.dart';
// import 'package:anger_buddy/utils/logger.dart';
// import 'package:anger_buddy/utils/mini_utils.dart';
// import 'package:anger_buddy/utils/network_assistant.dart';
// import 'package:anger_buddy/utils/url.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';

// class Utils {
//   static String getFormattedDateTime({required DateTime dateTime}) {
//     String day = '${dateTime.day}';
//     String month = '${dateTime.month}';
//     String year = '${dateTime.year}';

//     String hour = '${dateTime.hour}';
//     String minute = '${dateTime.minute}';
//     String second = '${dateTime.second}';
//     return '$day/$month/$year $hour/$minute/$second';
//   }
// }

// class PageDownloads extends StatefulWidget {
//   const PageDownloads({Key? key}) : super(key: key);

//   @override
//   _PageDownloadsState createState() => _PageDownloadsState();
// }

// class _PageDownloadsState extends State<PageDownloads> {
//   AsyncDataResponse<List<WpdmTreeItem>?>? downloadItemsResp;

//   void loadDownloads() {
//     fetchDownloads().then((value) {
//       if (mounted) {
//         setState(() {
//           downloadItemsResp = value;
//         });
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     loadDownloads();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Downloads'),
//         ),
//         body: downloadItemsResp == null
//             ? const Center(
//                 child: CircularProgressIndicator(),
//               )
//             : (downloadItemsResp!.error == true
//                 ? NoConnectionColumn(
//                     footerWidgets: [
//                       Center(
//                         child: OutlinedButton.icon(
//                             onPressed: loadDownloads,
//                             icon: const Icon(Icons.refresh),
//                             label: const Text("Erneut versuchen")),
//                       )
//                     ],
//                   )
//                 : (downloadItemsResp!.data != null
//                     ? Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: TreeView(
//                             nodes: generateTreeViewWidgets(
//                                 downloadItemsResp!.data!, 0)),
//                       )
//                     : NoConnectionColumn(
//                         title: "Keine Daten",
//                         subtitle: "Wir konnten leider keine Daten finden.",
//                         footerWidgets: [
//                           OutlinedButton.icon(
//                               onPressed: loadDownloads,
//                               icon: const Icon(Icons.refresh),
//                               label: const Text("Neu laden"))
//                         ],
//                       ))));
//   }
// }

// List<TreeNode> generateTreeViewWidgets(List<WpdmTreeItem> items, int level) {
//   List<TreeNode> widgets = [];
//   Widget addPadding(item) {
//     return Padding(
//       padding:
//           EdgeInsets.only(left: level == 0 ? 0 : (32 /*  * level*/).toDouble()),
//       child: item,
//     );
//   }

//   for (var item in items) {
//     if (item.runtimeType == WpdmDirectory) {
//       widgets.add(addPadding(_DirectoryWidget((item as WpdmDirectory), level)));
//     } else if (item.runtimeType == WpdmFile) {
//       widgets.add(addPadding(_FileWidget(file: item as WpdmFile)));
//     }
//   }
//   return widgets;
// }

// class _DirectoryWidget extends StatefulWidget {
//   final WpdmDirectory dir;
//   final int level;

//   const _DirectoryWidget(this.dir, this.level);

//   @override
//   State<_DirectoryWidget> createState() => _DirectoryWidgetState();
// }

// class _DirectoryWidgetState extends State<_DirectoryWidget> {
//   List<WpdmTreeItem>? children;
//   bool _expanded = false;
//   _tapped() async {
//     if (children == null) {
//       fetchDownloads(dir: widget.dir.dirId).then((value) {
//         if (value.error == true) {
//           logger.e("ERR TRUE Downlaods");
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//               content: Text("Es gab einen Fehler beim Laden der Downloads")));
//         } else {
//           setState(() {
//             children = value.data ?? [];
//           });
//         }
//       });
//     }
//     setState(() {
//       _expanded = !_expanded;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget titleWidget = Text(widget.dir.name);
//     Icon folderIcon = Icon(
//       _expanded ? Icons.folder_open : Icons.folder,
//       color: Colors.blueAccent,
//     );

//     Icon expandButton =
//         Icon(_expanded ? Icons.keyboard_arrow_down : Icons.navigate_next);

//     return TreeViewChild(
//       parent: Card(
//         color: Theme.of(context).cardColor,
//         child: ListTile(
//           leading: folderIcon,
//           title: titleWidget,
//           trailing: expandButton,
//           onTap: (() => _tapped()),
//         ),
//       ),
//       children: children == null
//           ? [
//               const Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Text("Lädt"),
//               )
//             ]
//           : children!.isEmpty
//               ? [
//                   const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Text("Keine Dateien"),
//                   )
//                 ]
//               : generateTreeViewWidgets(children!, widget.level + 1),
//     );
//   }
// }

// class _FileWidget extends StatelessWidget {
//   final WpdmFile file;

//   const _FileWidget({required this.file});

//   @override
//   Widget build(BuildContext context) {
//     Widget fileNameWidget = Text(file.name);

//     Icon fileIcon = Icon(
//       Icons.insert_drive_file,
//       color: Colors.amber.shade600,
//     );

//     var color = Theme.of(context).cardColor;
//     printInDebug(color);

//     return InkWell(
//       onTap: () => launchURL(file.fileUri.toString(), context),
//       child: Card(
//         color: color,
//         elevation: 1.0,
//         child: ListTile(
//           leading: SvgPicture.network(
//             file.fileIconUri.toString(),
//             height: IconTheme.of(context).size,
//             semanticsLabel: 'Datei Icon',
//             placeholderBuilder: (BuildContext context) => fileIcon,
//           ),
//           title: fileNameWidget,
//         ),
//       ),
//     );
//   }
// }
