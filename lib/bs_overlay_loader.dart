library bs_overlay_loader;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class BsOverlayLoaderController {
  void Function(double) updatingProgress;
  void Function() refresh;
}

class BsOverlayLoader extends StatefulWidget {
  final BsOverlayLoaderController _controller;
  final String text;
  BsOverlayLoader._(
    this._controller,
    this.text,
  );

  static OverlayEntry _currentLoader;
  static OverlayState _overlayState;
  static BsOverlayLoaderController _loaderController =
      BsOverlayLoaderController();

  static void update(double progress) {
    if (_loaderController.updatingProgress != null) {
      _loaderController.updatingProgress(progress);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => update(progress));
    }
  }

  static void hide() {
    if (_currentLoader != null) {
      try {
        _currentLoader.remove();
      } catch (e) {
        print(e.toString());
      } finally {
        _currentLoader = null;
      }
    }
  }

  static void refresh() {
    if (_loaderController.refresh != null) {
      _loaderController.refresh();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => refresh());
    }
  }

  static void show(BuildContext context,
      {Color overlayColor, String text, bool showPercentage = false}) {
    _overlayState = Overlay.of(context);
    if (_currentLoader == null) {
      _currentLoader = new OverlayEntry(
          builder: (context) => Stack(
                children: <Widget>[
                  Container(
                    color: overlayColor ?? Color(0xccffffff),
                  ),
                  Center(
                      child: BsOverlayLoader._(
                    _loaderController,
                    text,
                  )),
                ],
              ));
      try {
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => _overlayState.insertAll([_currentLoader]));
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  _BsOverlayLoaderState createState() => _BsOverlayLoaderState();
}

class _BsOverlayLoaderState extends State<BsOverlayLoader> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    widget._controller.updatingProgress = updateProgress;
  }

  @override
  void dispose() {
    super.dispose();
    widget._controller.updatingProgress = null;
  }

  void updateProgress(double progress) {
    if (mounted) {
      setState(() {
        if (progress < 0) {
          _progress = 0;
        } else if (progress > 1) {
          _progress = 1;
        }
        _progress = progress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BsCircleProgressBar(
        backgroundColor: Colors.grey[400],
        foregroundColor: Colors.blueGrey[400],
        value: _progress,
        text: widget.text,
        loaderController: widget._controller,
      ),
    );
  }
}

class BsCircleProgressBar extends StatefulWidget {
  final Color backgroundColor;
  final Color foregroundColor;
  final double value;
  final String text;
  final BsOverlayLoaderController loaderController;
  const BsCircleProgressBar({
    Key key,
    this.backgroundColor,
    @required this.foregroundColor,
    @required this.value,
    @required this.text,
    @required this.loaderController,
  }) : super(key: key);

  @override
  _BsCircleProgressBarState createState() => _BsCircleProgressBarState();
}

class _BsCircleProgressBarState extends State<BsCircleProgressBar>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Tween<double> _valueTween;
  Animation<double> _curve;

  void refresh() {
    this._valueTween = Tween<double>(
      begin: 0,
      end: 1,
    );
    this._controller.reset();
  }

  @override
  void initState() {
    super.initState();
    widget.loaderController.refresh = refresh;
    this._controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceInOut,
    );
    this._controller.forward();
    this._valueTween = Tween<double>(
      begin: 0,
      end: this.widget.value,
    );
  }

  @override
  void dispose() {
    widget.loaderController.refresh = null;
    this._controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BsCircleProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (this.widget.value != oldWidget.value) {
      double beginValue =
          this._valueTween?.evaluate(this._controller) ?? oldWidget?.value ?? 0;
      this._valueTween = Tween<double>(
        begin: beginValue,
        end: this.widget.value ?? 1,
      );

      this._controller
        ..value = 0
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = this.widget.backgroundColor;
    final foregroundColor = this.widget.foregroundColor;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: this._controller,
              child: Container(),
              builder: (context, child) {
                double percentage = this._valueTween.evaluate(_curve);
                return Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      child: CustomPaint(
                        child: child,
                        foregroundPainter: CircleProgressBarPainter(
                          backgroundColor: backgroundColor,
                          foregroundColor: foregroundColor,
                          percentage: percentage,
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      child: Center(
                        child: Text(
                          (percentage * 100).toStringAsFixed(0) + '%',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              widget.text,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircleProgressBarPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color backgroundColor;
  final Color foregroundColor;

  CircleProgressBarPainter({
    this.backgroundColor,
    @required this.foregroundColor,
    @required this.percentage,
    double strokeWidth,
  }) : this.strokeWidth = strokeWidth ?? 8;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Size constrainedSize =
        size - Offset(this.strokeWidth, this.strokeWidth);
    final shortestSide = min(constrainedSize.width, constrainedSize.height);
    final foregroundPaint = Paint()
      ..color = this.foregroundColor
      ..strokeWidth = this.strokeWidth
      ..style = PaintingStyle.stroke;
    final radius = (shortestSide / 2);

    final double startAngle = -(2 * pi * 0.25);
    final double sweepAngle = (2 * pi * (this.percentage ?? 0));

    if (this.backgroundColor != null) {
      final backgroundPaint = Paint()
        ..color = this.backgroundColor
        ..strokeWidth = this.strokeWidth
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius, backgroundPaint);
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final oldPainter = (oldDelegate as CircleProgressBarPainter);
    return oldPainter.percentage != this.percentage ||
        oldPainter.backgroundColor != this.backgroundColor ||
        oldPainter.foregroundColor != this.foregroundColor ||
        oldPainter.strokeWidth != this.strokeWidth;
  }
}
