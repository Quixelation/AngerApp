import 'dart:async';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/jsp/jsp_loginpage.dart';
import 'package:flutter/material.dart';

class JspPassthroughPage extends StatefulWidget {
  const JspPassthroughPage({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<JspPassthroughPage> createState() => _JspPassthroughPageState();
}

class _JspPassthroughPageState extends State<JspPassthroughPage> {
  var loggedIn = Credentials.jsp.credentialsAvailable;
  StreamSubscription? credsSub;

  @override
  void initState() {
    super.initState();

    credsSub = Credentials.jsp.subject.listen((value) {
      if (!mounted) {
        credsSub?.cancel();
        return;
      }

      setState(() {
        loggedIn = Credentials.jsp.credentialsAvailable;
      });
    });
  }

  @override
  void dispose() {
    credsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((loggedIn ?? false) == true) {
      return widget.child;
    } else {
      return JspLoginPage();
    }
  }
}
