part of website_integration;

class WordpressMenuItem {
  final String title;
  final List<WordpressMenuItem>? children;
  final String url;

  WordpressMenuItem({
    required this.title,
    required this.url,
    this.children,
  });

  @override
  String toString() {
    return "WordpressMenuItem(title: $title, url: $url, children: $children)";
  }
}

Future<String> getWordpressHomepage(Uri? url) async {
  url ??= Uri.parse(AppManager.urls.wordpress_homepage);

  final result = await http.get(url);
  if (result.statusCode != 200) {
    throw Exception('Failed to load homepage');
  }
  return result.body;
}

Future<List<WordpressMenuItem>> getWordpressMenuItems(
    {String? html, Uri? url}) async {
  html ??= await getWordpressHomepage(url);
  final document = parse(html);
  final navUlElement = document.querySelector(".main-navigation ul");
  if (navUlElement == null) {
    throw Exception('Failed to find menu');
  }

  logger.d("navUlElement: $navUlElement");

  List<WordpressMenuItem>? findChildren(dom.Element? ulElement) {
    if (ulElement == null) return null;
    List<WordpressMenuItem> menuItems = [];
    final menuItemElements =
        ulElement.children.where((element) => element.localName == 'li');
    logger.d("menuItemElements: $menuItemElements");

    for (final menuItemElement in menuItemElements) {
      //NOTE: querySelector("& > a") does not work, because "&" is not supported
      final linkElement = menuItemElement.children
          .where(
            (element) => element.localName == "a",
          )
          .firstOrNull;
      final subMenuElement = menuItemElement.children
          .where(
            (element) => element.localName == "ul",
          )
          .firstOrNull;

      menuItems.add(WordpressMenuItem(
          title: linkElement?.text.trim() ?? "%TITLE%",
          url: linkElement?.attributes['href'] ?? '',
          children: findChildren(subMenuElement)));
    }
    return menuItems;
  }

  return findChildren(navUlElement) ?? [];
}
