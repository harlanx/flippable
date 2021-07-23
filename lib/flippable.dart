library flippable;

import 'package:flutter/material.dart';

/// Allows a widget to be flipped and show front and back side.
///
/// Note: Combination not of snapBack: false with DragAxis.both is not working correctly. Use Cautiously.
class Flippable extends StatefulWidget {
  /// The widget to show as default
  final Widget frontWidget;

  /// The widget to show when flipped
  final Widget? backWidget;

  /// Set to [true] to snap(revert) animation to front widget.
  ///
  /// Set to [false] to allow user to flip to back widget without reverting to front widget.
  final bool revert;

  /// Axis where the user can drag to interact with the flippable widget.
  final DragAxis dragAxis;

  /// Duration of the animation when the flip is snapping to front and back position.
  final Duration duration;

  const Flippable({
    Key? key,
    required this.frontWidget,
    Widget? backWidget,
    this.revert = true,
    this.dragAxis = DragAxis.horizontal,
    this.duration = const Duration(milliseconds: 500),
  })  : backWidget = backWidget != null ? backWidget : frontWidget,
        super(key: key);

  @override
  _FlippableState createState() => _FlippableState();
}

class _FlippableState extends State<Flippable> with TickerProviderStateMixin {
  // Using math.pi causes crash in web so we used a shorter one.
  final kPi = 3.1415;
  late AnimationController vertAnimCtrlr, horizAnimCtrlr;
  late Animation<double> vertAnimation, horizAnimation;
  ValueNotifier<double> verticalDrag = ValueNotifier(0.0), horizontalDrag = ValueNotifier(0.0);
  ValueNotifier<bool> isFront = ValueNotifier(true);
  double lastVertDrag = 0.0, lastHorizDrag = 0.0;

  @override
  void initState() {
    super.initState();
    vertAnimCtrlr = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    horizAnimCtrlr = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    verticalDrag.addListener(() {
      setImageSide(verticalDrag.value);
      //print('Vertical: ${verticalDrag.value}');
      //print('Horizontal: ${horizontalDrag.value}');
    });

    horizontalDrag.addListener(() {
      setImageSide(horizontalDrag.value);
      //print('Horizontal: ${horizontalDrag.value}');
      //print('Vertical: ${verticalDrag.value}');
    });
  }

  @override
  void dispose() {
    vertAnimCtrlr.dispose();
    horizAnimCtrlr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (dragDetails) {
        if (widget.dragAxis == DragAxis.vertical || widget.dragAxis == DragAxis.both) {
          vertAnimCtrlr.reset();
          verticalDrag.value = lastVertDrag;
        }
      },
      onVerticalDragUpdate: (dragDetails) {
        if (widget.dragAxis == DragAxis.vertical || widget.dragAxis == DragAxis.both) {
          verticalDrag.value = (verticalDrag.value + dragDetails.delta.dy) % 360;
        }
      },
      onVerticalDragEnd: (dragDetails) {
        if (widget.dragAxis == DragAxis.vertical || widget.dragAxis == DragAxis.both) {
          double endRotation = 0.0;
          if (widget.revert) {
            endRotation = 360 - verticalDrag.value >= 180 ? 0.0 : 360;
            lastVertDrag = endRotation;
            vertAnimation = Tween<double>(begin: verticalDrag.value, end: endRotation).animate(vertAnimCtrlr)
              ..addListener(() {
                verticalDrag.value = vertAnimation.value;
              });
            vertAnimCtrlr.fling();
          } else {
            if (verticalDrag.value >= 90 && verticalDrag.value <= 270) {
              endRotation = 180;
            } else {
              endRotation = 360 - verticalDrag.value >= 180 ? 0.0 : 360;
            }
            lastVertDrag = endRotation;
            lastHorizDrag = endRotation;
            vertAnimation = Tween<double>(begin: verticalDrag.value, end: endRotation).animate(vertAnimCtrlr)
              ..addListener(() {
                verticalDrag.value = vertAnimation.value;
              });
            vertAnimCtrlr.fling();
          }
        }
      },
      onHorizontalDragStart: (dragDetails) {
        if (widget.dragAxis == DragAxis.horizontal || widget.dragAxis == DragAxis.both) {
          horizAnimCtrlr.reset();
          horizontalDrag.value = lastHorizDrag;
        }
      },
      onHorizontalDragUpdate: (dragDetails) {
        if (widget.dragAxis == DragAxis.horizontal || widget.dragAxis == DragAxis.both) {
          horizontalDrag.value = (horizontalDrag.value - dragDetails.delta.dx) % 360;
        }
      },
      onHorizontalDragEnd: (dragDetails) {
        if (widget.dragAxis == DragAxis.horizontal || widget.dragAxis == DragAxis.both) {
          double endRotation = 0.0;
          if (widget.revert) {
            endRotation = 360 - horizontalDrag.value >= 180 ? 0.0 : 360;
            lastHorizDrag = endRotation;
            horizAnimation = Tween<double>(begin: horizontalDrag.value, end: endRotation).animate(horizAnimCtrlr)
              ..addListener(() {
                horizontalDrag.value = horizAnimation.value;
              });
            horizAnimCtrlr.fling();
          } else {
            if (horizontalDrag.value >= 90 && horizontalDrag.value <= 270) {
              endRotation = 180;
            } else {
              endRotation = 360 - horizontalDrag.value >= 180 ? 0.0 : 360;
            }
            lastHorizDrag = endRotation;
            lastVertDrag = endRotation;
            horizAnimation = Tween<double>(begin: horizontalDrag.value, end: endRotation).animate(horizAnimCtrlr)
              ..addListener(() {
                horizontalDrag.value = horizAnimation.value;
              });
            horizAnimCtrlr.fling();
          }
        }
      },
      child: SizedBox(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateX(verticalDrag.value / 180 * kPi)
            ..rotateY(horizontalDrag.value / 180 * kPi),
          child: ValueListenableBuilder<bool>(
            valueListenable: isFront,
            builder: (context, front, _) {
              if (front) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..rotateX(frontImageXAngle)
                    ..rotateY(frontImageYAngle),
                  child: widget.frontWidget,
                );
              } else {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..rotateX(backImageXAngle)
                    ..rotateY(backImageYAngle),
                  child: widget.backWidget,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void setImageSide(double drag) {
    if (drag <= 90 || drag >= 270) {
      isFront.value = true;
    } else {
      isFront.value = false;
    }
    setState(() {});
  }

  double get frontImageXAngle {
    double angle = 0.0;
    if (widget.dragAxis == DragAxis.both) {
      if (verticalDrag.value >= 90 && verticalDrag.value <= 270) {
        angle = kPi;
      }
    }
    return angle;
  }

  double get frontImageYAngle {
    double angle = 0.0;
    if (widget.dragAxis == DragAxis.both) {
      if (horizontalDrag.value >= 90 && horizontalDrag.value <= 270) {
        angle = kPi;
      }
    }
    return angle;
  }

  double get backImageXAngle {
    double angle = 0.0;
    if (widget.dragAxis == DragAxis.both) {
      if (verticalDrag.value >= 90 && verticalDrag.value <= 270) {
        angle = kPi;
      } else {
        angle = 0.0;
      }
    } else {
      if (widget.dragAxis == DragAxis.vertical) {
        angle = kPi;
      } else {
        angle = 0.0;
      }
    }
    return angle;
  }

  double get backImageYAngle {
    double angle = 0.0;
    if (widget.dragAxis == DragAxis.both) {
      if (horizontalDrag.value >= 90 && horizontalDrag.value <= 270) {
        angle = kPi;
      } else {
        angle = 0.0;
      }
    } else {
      if (widget.dragAxis == DragAxis.horizontal) {
        angle = kPi;
      } else {
        angle = 0.0;
      }
    }
    return angle;
  }
}

/// Axis where the child widget can be dragged to flip.
enum DragAxis {
  horizontal,
  vertical,
  both,
}
