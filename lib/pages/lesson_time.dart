import 'package:anger_buddy/logic/lessontime/lessontime.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:flutter/material.dart';

class PageLessonTimes extends StatefulWidget {
  const PageLessonTimes({Key? key}) : super(key: key);

  @override
  PageLessonTimesState createState() => PageLessonTimesState();
}

class PageLessonTimesState extends State<PageLessonTimes> {
  AsyncDataResponse<List<LessonTime>>? _lessonTimes;

  void _loadLessonTimes() async {
    getLessonTimeGroups().listen((value) {
      setState(() {
        _lessonTimes = value;
      });
    });
  }

  List<Widget> _buildLessonTimes() {
    List<Widget> widgetList = [];
    for (LessonTime group in _lessonTimes!.data) {
      widgetList.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ));
    }
    return widgetList;
  }

  @override
  void initState() {
    super.initState();
    _loadLessonTimes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Stundenzeiten'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadLessonTimes,
            ),
          ],
        ),
        body: Stack(
          children: [
            _lessonTimes?.loadingAction ==
                    AsyncDataResponseLoadingAction.currentlyLoading
                ? const Positioned(
                    child: LinearProgressIndicator(),
                    top: 0,
                    left: 0,
                    right: 0,
                  )
                : Container(),
            ListView(
              children: _lessonTimes?.data.isNotEmpty ?? false
                  ? _buildLessonTimes()
                  : [
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ],
            )
          ],
        ));
  }
}
