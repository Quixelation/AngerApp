import 'dart:convert';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';

@Deprecated("No Future Use")
abstract class _PageEngineComponent {
  /// Gibt an, mit welcher PageEngine Version, diese Methode implementiert wurde
  static late final int versionImplemented;
}

// #region Body
abstract class _PageBody extends StatelessWidget
    implements _PageEngineComponent {}

// TODO: Use [[_PageBody]]
Widget _buildPageBody(BuildContext context, Map<String, dynamic> pageData) {
  switch (pageData['type']) {
    case 'simple_block_page':
      return _SimpleBlockPage.fromPageData(context, pageData);
    default:
      throw Exception('Unknown page type: ${pageData['type']}');
  }
}

//#endregion

// #region Pages

class _SimpleBlockPage extends _PageBody {
  static _SimpleBlockPage fromPageData(
      BuildContext context, Map<String, dynamic> data) {
    var blocks = data['blocks'].map<_SimpleBlock>((dynamic block) {
      if (block is Map<String, dynamic>) {
        switch (block["type"]) {
          case "text":
            return _SimpleMarkdownBlock(data: block["data"]);
          case "card":
            return _SimpleCardBlock(data: block["data"]);
          case "linklist":
            return _SimpleLinkListBlock(data: block["data"]);
          default:
            return _SimpleUnkownTypeBlock();
        }
      }
      throw Exception('Unknown block type');
    }).toList();
    printInDebug(blocks);
    return _SimpleBlockPage(blocks);
  }

  final List<_SimpleBlock> blocks;
  _SimpleBlockPage(this.blocks);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (ctx, i) => blocks[i],
      separatorBuilder: (ctx, i) => const SizedBox(height: 20),
      itemCount: blocks.length,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
    );
  }
}

// #endregion

// #region Blocks

abstract class _SimpleBlock extends Widget {}

abstract class _SimpleStatelessBlock extends StatelessWidget
    implements _SimpleBlock {}

abstract class _SimpleStatefulBlock extends StatefulWidget {}

class _SimpleMarkdownBlock extends _SimpleStatelessBlock {
  final String data;

  _SimpleMarkdownBlock({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MarkdownBody(
        data: data,
        selectable: false,
        blockSyntaxes: const [],
      ),
    );
  }
}

class _SimpleCardBlock extends _SimpleStatelessBlock {
  final String data;
  _SimpleCardBlock({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: _SimpleMarkdownBlock(data: data),
    ));
  }
}

void _openLink(BuildContext context, Map<String, dynamic> linkMap) {
  if (linkMap['type'] == 'page') {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PageEngineScaffold(pageData: linkMap['data'])));
  } else {
    throw Exception('Unknown link type');
  }
}

class _SimpleLinkListBlock extends _SimpleStatelessBlock {
  final List<dynamic> data;
  _SimpleLinkListBlock({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: data.map<Widget>((dynamic link) {
      if (link is Map<String, dynamic>) {
        return ListTile(
          title: Text(link["title"]),
          //TODO: Use provided Icon, if provided an check if external url and use other icon
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _openLink(context, link["link"]);
          },
        );
      }
      throw Exception('Unknown link type');
    }).toList());
  }
}

class _SimpleUnkownTypeBlock extends _SimpleStatelessBlock {
  _SimpleUnkownTypeBlock();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Unbekannter Block-Typ"),
    );
  }
}

// #endregion

//#region PageHeader

AppBar _buildPageHeader(BuildContext context, Map<String, dynamic> headerData) {
  switch (headerData['type']) {
    case 'simple_header':
      return _SimplePageHeader(headerData['title']);
    default:
      throw Exception('Unknown page type: ${headerData['type']}');
  }
}

abstract class _PageHeader {
  final String title;
  _PageHeader(this.title);
}

AppBar _SimplePageHeader(String title) {
  return AppBar(
    title: Text(title),
  );
}
//#endregion

// #region PageScaffold
Widget parsePage(String Function() getJsonString) {
  // final minEngineMajorVersion = json['min_engine_major_version'] as int;
  // final int version = json['version'];
  // final String id = json['id'];
  // final pageData = json['data'] as Map<String, dynamic>;
  return RestartPageEngine(
    child: PageEngineScaffold(
      // id: id,
      pageData: jsonDecode(getJsonString())["data"],
    ),
  );
}

class PageEngineScaffold extends StatefulWidget {
  // final int minEngineMajorVersion;
  // final int version;
  // final String id;
  final Map<String, dynamic> pageData;

  const PageEngineScaffold({
    Key? key,
    // required this.id,

    required this.pageData,
  }) : super(key: key);

  @override
  State<PageEngineScaffold> createState() => _PageEngineScaffoldState();
}

class _PageEngineScaffoldState extends State<PageEngineScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: /* _buildPageHeader(context, pageData['header'])*/ AppBar(
          title: Text(widget.pageData["header"]["title"]),
        ),
        body: _buildPageBody(context, widget.pageData["body"]));
  }
}

class RestartPageEngine extends StatefulWidget {
  const RestartPageEngine({Key? key, required this.child}) : super(key: key);

  final Widget child;

  static void restartApp(BuildContext context) {
    var ancestor = context.findAncestorStateOfType<_RestartPageEngineState>();
    if (ancestor == null) {
      logger.e("no ancestor for restart");
    } else {
      ancestor.restartApp();
    }
  }

  @override
  _RestartPageEngineState createState() => _RestartPageEngineState();
}

class _RestartPageEngineState extends State<RestartPageEngine> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

// #endregion PageScaffold
