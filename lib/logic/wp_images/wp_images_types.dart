part of wp_images;

class WpImage {
  final int id;
  final DateTime date;
  final DateTime modified;
  final String guid;
  final String slug;
  final String link;
  final String altText;
  final String mediaType;
  final String mimeType;
  final int? postId;
  final String title;
  final _WpImageMediaDetails? mediaDetails;
  final int? foundOnPage;
  final String sourceUrl;

  String generatePostUrl() {
    if (postId != null) {
      return "https://angergymnasium.jena.de/?p=$postId";
    } else {
      throw ErrorDescription("No PostId");
    }
  }

  WpImage(
      {required this.altText,
      required this.date,
      required this.guid,
      required this.id,
      required this.link,
      required this.mediaType,
      required this.mimeType,
      required this.modified,
      required this.postId,
      required this.slug,
      required this.title,
      this.foundOnPage,
      required this.sourceUrl,
      required this.mediaDetails});

  WpImage.fromApiMap(Map<String, dynamic> apiMap, {this.foundOnPage})
      : id = apiMap["id"],
        date = DateTime.parse(apiMap["date"]),
        modified = DateTime.parse(apiMap["modified"]),
        guid = apiMap["guid"]["rendered"],
        altText = apiMap["alt_text"],
        link = apiMap["link"],
        mediaType = apiMap["media_type"],
        mimeType = apiMap["mime_type"],
        postId = apiMap["post"],
        slug = apiMap["slug"],
        sourceUrl = apiMap["source_url"],
        mediaDetails =
            (apiMap["media_details"] as Map<String, dynamic>).isNotEmpty
                ? _WpImageMediaDetails.fromApiMap(apiMap["media_details"])
                : null,
        title = apiMap["title"]["rendered"];
}

class _WpImageMediaDetails {
  final int? height;
  final int? width;
  final _WpImageSizes? sizes;
  final _WpImageMeta? imageMeta;

  _WpImageMediaDetails.fromApiMap(Map<String, dynamic> apiMap)
      : height = apiMap["height"] != null
            ? (apiMap["height"].runtimeType == String
                ? int.parse(apiMap["height"])
                : apiMap["height"])
            : null,
        width = apiMap["width"] != null
            ? apiMap["width"].runtimeType == String
                ? int.parse(apiMap["width"])
                : apiMap["width"]
            : null,
        imageMeta = apiMap["image_meta"] != null &&
                (apiMap["image_meta"] as Map).isNotEmpty
            ? _WpImageMeta.fromApiMap(apiMap["image_meta"])
            : null,
        sizes = apiMap["sizes"] != null && (apiMap["sizes"] as Map).isNotEmpty
            ? _WpImageSizes.fromApiMap(apiMap["sizes"])
            : null;
}

class _WpImageSizes {
  final _WpImageSize thumbnail;
  final _WpImageSize? medium;
  final _WpImageSize? mediumLarge;
  final _WpImageSize? large;
  final _WpImageSize full;

  _WpImageSizes.fromApiMap(Map<String, dynamic> apiMap)
      : thumbnail = _WpImageSize.fromApiMap(apiMap["thumbnail"]),
        medium = apiMap["medium"] != null
            ? _WpImageSize.fromApiMap(apiMap["medium"])
            : null,
        mediumLarge = apiMap["medium_large"] != null
            ? _WpImageSize.fromApiMap(apiMap["medium_large"])
            : null,
        large = apiMap["large"] != null
            ? _WpImageSize.fromApiMap(apiMap["large"])
            : null,
        full = _WpImageSize.fromApiMap(apiMap["full"]);
}

class _WpImageSize {
  final int height;
  final int width;
  final String sourceUrl;
  _WpImageSize.fromApiMap(Map<String, dynamic> apiMap)
      : height = apiMap["height"].runtimeType == String
            ? int.parse(apiMap["height"])
            : apiMap["height"],
        width = apiMap["width"].runtimeType == String
            ? int.parse(apiMap["width"])
            : apiMap["width"],
        sourceUrl = apiMap["source_url"];
}

class _WpImageMeta {
  final String aperture;
  final String credit;
  final String camera;
  final String caption;
  final String createdTimestamp;
  final String copyright;
  final String focalLength;
  final String iso;
  final String shutterSpeed;
  final String title;
  final String orientation;
  final List<String> keywords;

  _WpImageMeta(
      {required this.aperture,
      required this.camera,
      required this.caption,
      required this.copyright,
      required this.createdTimestamp,
      required this.credit,
      required this.focalLength,
      required this.iso,
      required this.keywords,
      required this.orientation,
      required this.shutterSpeed,
      required this.title});

  _WpImageMeta.fromApiMap(Map<String, dynamic> apiMap)
      : aperture = apiMap["aperture"].toString(),
        credit = apiMap["credit"].toString(),
        camera = apiMap["camera"].toString(),
        caption = apiMap["caption"].toString(),
        createdTimestamp = apiMap["created_timestamp"].toString(),
        copyright = apiMap["copyright"].toString(),
        focalLength = apiMap["focal_length"].toString(),
        iso = apiMap["iso"].toString(),
        shutterSpeed = apiMap["shutter_speed"].toString(),
        title = apiMap["title"].toString(),
        orientation = apiMap["orientation"].toString(),
        keywords =
            apiMap["keywords"] != null ? List.from(apiMap["keywords"]) : [];
}
