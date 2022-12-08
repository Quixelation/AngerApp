/// IN DEVELOPMENT

library messages;

import 'package:flutter/material.dart';

abstract class MessageService<M extends Message, C extends Conversation> {
  abstract final String name;

  Future<List<C>> getUnread();
  Future<List<C>> getAll();

  ListTile buildListTile(C message);
  Widget buildPage();
}

abstract class Message<idType> {
  abstract final idType id;
}

abstract class Conversation {
  abstract final String id;
}
