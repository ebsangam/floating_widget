import 'dart:developer';

import 'package:flutter/material.dart';

const _viewHeight = 150.0;
const _viewWidth = 100.0;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Offset floatingWidetOffest = const Offset(10, 10);
  Offset localDifference = const Offset(0, 0);

  final parentKey = GlobalKey();
  final childKey = GlobalKey();

  Offset? getRelativeOffset() {
    final parentBox =
        parentKey.currentContext?.findRenderObject() as RenderBox?;
    final childBox = childKey.currentContext?.findRenderObject() as RenderBox?;

    if (parentBox == null || childBox == null) return null;

    final globalParentOffset = parentBox.localToGlobal(Offset.zero);
    final globalChildOffset = childBox.localToGlobal(Offset.zero);

    final childOffsetRelativeToParent = globalChildOffset - globalParentOffset;

    return _getCalculatedRelativeOffset(
      canvasWidth: parentBox.size.width,
      canvasHeight: parentBox.size.height,
      relativeOffset: childOffsetRelativeToParent,
      viewWidth: _viewWidth,
      viewHeight: _viewHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        key: parentKey,
        children: [
          AnimatedPositioned.fromRect(
            key: childKey,
            duration: Durations.short1,
            rect: Rect.fromLTWH(
              floatingWidetOffest.dx,
              floatingWidetOffest.dy,
              _viewWidth,
              _viewHeight,
            ),
            child: GestureDetector(
              onPanStart: (details) {
                log(details.globalPosition.toString());
                localDifference = floatingWidetOffest - details.localPosition;
              },
              onPanEnd: (_) {
                localDifference = const Offset(0, 0);
                final calculatedOffset = getRelativeOffset();
                log(calculatedOffset.toString());
                if (calculatedOffset != null) {
                  setState(() {
                    floatingWidetOffest = calculatedOffset;
                  });
                }
              },
              onPanUpdate: (details) {
                // log(details.localPosition.toString());
                setState(() {
                  floatingWidetOffest = localDifference + details.localPosition;
                });
              },
              child: localVideo(),
            ),
          ),
        ],
      ),
    );
  }
}

Widget localVideo() => const SizedBox(
      height: _viewHeight,
      width: _viewWidth,
      child: ColoredBox(color: Colors.orange),
    );

enum Corner { topLeft, topRight, bottomLeft, bottomRight }

Offset _getCalculatedRelativeOffset({
  required double canvasWidth,
  required double canvasHeight,
  required Offset relativeOffset,
  required double viewWidth,
  required double viewHeight,
}) {
  final centerOffset = relativeOffset + Offset(viewWidth / 2, viewHeight / 2);

  Corner corner;
  if (centerOffset.dx < canvasWidth / 2 && centerOffset.dy < canvasHeight / 2) {
    corner = Corner.topLeft;
  } else if (centerOffset.dx < canvasWidth / 2 &&
      centerOffset.dy > canvasHeight / 2) {
    corner = Corner.bottomLeft;
  } else if (centerOffset.dx > canvasWidth / 2 &&
      centerOffset.dy < canvasHeight / 2) {
    corner = Corner.topRight;
  } else {
    corner = Corner.bottomRight;
  }

  // Place the rectangle in the corner with the highest percentage
  switch (corner) {
    case Corner.topLeft:
      return const Offset(0, 0);

    case Corner.topRight:
      return Offset(canvasWidth - viewWidth, 0);

    case Corner.bottomLeft:
      return Offset(0, canvasHeight - viewHeight);

    case Corner.bottomRight:
      return Offset(canvasWidth - viewWidth, canvasHeight - viewHeight);
  }
}
