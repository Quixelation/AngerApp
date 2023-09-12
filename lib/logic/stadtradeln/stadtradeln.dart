library stadtradeln;

import "dart:convert";
import "package:anger_buddy/angerapp.dart";
import "package:anger_buddy/logic/homepage/homepage.dart";
import "package:anger_buddy/utils/logger.dart";
import "package:anger_buddy/utils/url.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;

part "stadtradeln_widget.dart";


class StadtRadelnManager {
  Map? _data = null;
    bool isEnabled = true;

  getData() async {
    if (_data == null && isEnabled != false) {
      final response = await http.get(Uri.parse(
          "https://angerapp.angergymnasium.jena.de/cms/items/feature_flags"));
      if (response.statusCode != 200) {
                logger.e("Failed to load data");
        throw Exception("Failed to load data");
      }

      final json = jsonDecode(response.body);

            //TODO: Put this in own Manager-Class
            if(json["data"]?["stadtradeln"] == null ){
                logger.e("Failed to load data");

            }

            if( json["data"]?["stadtradeln"] == false){

                logger.i("Stadtradeln is disabled");
                isEnabled = false;
                return null;
            }

      if (json["data"]?["stadtradeln_data"] == null) {
                logger.e("Failed to load data");
        throw Exception("Failed to load data");
      }

      _data = json["data"]?["stadtradeln_data"];
    }

    return _data;
  }
}
