import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void launchURL(String url, BuildContext context) async {
  try {
    await launch(url);
  } catch (e) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text('Fehler'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
            content: Text('Die Url konnte nicht geöffnet werden: $url')));
  }
}
