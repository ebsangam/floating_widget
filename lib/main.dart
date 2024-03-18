import 'package:flutter/material.dart';

const _viewHeight = 180.0;
const _viewWidth = 120.0;

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
  Offset? floatingWidetOffest;

  /// FloatingOffset - LocalTapOffset of child widget.
  // Offset? tapOffsetDifference;

  final parentKey = GlobalKey();
  final childKey = GlobalKey();

  Offset? getRelativeOffset({
    required double parentWidth,
    required double parentHeight,
  }) {
    final parentBox =
        parentKey.currentContext?.findRenderObject() as RenderBox?;
    final childBox = childKey.currentContext?.findRenderObject() as RenderBox?;

    if (parentBox == null || childBox == null) return null;

    final globalParentOffset = parentBox.localToGlobal(Offset.zero);
    final globalChildOffset = childBox.localToGlobal(Offset.zero);

    final childOffsetRelativeToParent = globalChildOffset - globalParentOffset;

    return _getCalculatedRelativeOffset(
      canvasWidth: parentWidth,
      canvasHeight: parentHeight,
      relativeOffset: childOffsetRelativeToParent,
      viewWidth: _viewWidth,
      viewHeight: _viewHeight,
    );
  }

  // Offset
  Offset? movingLocalOffset;
  Offset? tapLocalOffset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          key: parentKey,
          children: [
            AnimatedPositioned.fromRect(
              key: childKey,
              duration: Durations.short1,
              rect: floatingOffset(constraints),
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    tapLocalOffset = details.localPosition;
                    movingLocalOffset = details.localPosition;
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    movingLocalOffset = null;
                    tapLocalOffset = null;
                  });
                  // }
                },
                onPanUpdate: (details) {
                  setState(() {
                    movingLocalOffset = details.localPosition;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: localVideo(),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Rect floatingOffset(BoxConstraints constraints) {
    Offset? offset;
    if (movingLocalOffset != null && floatingWidetOffest != null) {
      offset = floatingWidetOffest! -
          (tapLocalOffset ?? Offset.zero) +
          (movingLocalOffset!);

      return Rect.fromLTWH(
        offset.dx,
        offset.dy,
        _viewWidth,
        _viewHeight,
      );
    }

    offset = getRelativeOffset(
        parentHeight: constraints.maxHeight, parentWidth: constraints.maxWidth);
    if (offset == null) {
      return const Rect.fromLTWH(0, 0, _viewWidth, _viewHeight);
    }
    // set final offset once moving done.
    floatingWidetOffest = offset;
    return Rect.fromLTWH(
      offset.dx,
      offset.dy,
      _viewWidth,
      _viewHeight,
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
