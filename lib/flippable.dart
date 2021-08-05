library flippable;

import 'package:flutter/material.dart';

/// Allows a widget to be flipped and show front and back side.
///
/// Note: Combination not of snapBack: false with DragAxis.both is not working correctly. Use Cautiously.
class Flippable extends StatefulWidget {
  /// Provide a controller to flip the widget programatically.
  final FlippableController? controller;

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

  /// Animation curve of the flip rotation.
  final Curve curve;

  /// Returns the current flip state when changed
  final ValueChanged<bool>? onChanged;

  const Flippable({
    Key? key,
    required this.frontWidget,
    this.controller,
    Widget? backWidget,
    this.onChanged,
    this.revert = true,
    this.dragAxis = DragAxis.horizontal,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeIn,
  })  : backWidget = backWidget != null ? backWidget : frontWidget,
        super(key: key);

  @override
  _FlippableState createState() => _FlippableState();
}

class _FlippableState extends State<Flippable> with TickerProviderStateMixin {
  final _kPi = 3.1415; // Using math.pi causes crash in web so we used a shorter one.
  late AnimationController _vertAnimCtrlr, _horizAnimCtrlr;
  late Animation<double> _vertAnimation, _horizAnimation;
  ValueNotifier<double> _verticalDrag = ValueNotifier(0.0), _horizontalDrag = ValueNotifier(0.0);
  ValueNotifier<bool> _isFront = ValueNotifier(true);
  double _lastVertDrag = 0.0, _lastHorizDrag = 0.0;

  @override
  void initState() {
    super.initState();
    _vertAnimCtrlr = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _horizAnimCtrlr = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _verticalDrag.addListener(() {
      _setWidgetSide(_verticalDrag.value);
      //print('Vertical: ${verticalDrag.value}');
      //print('Horizontal: ${horizontalDrag.value}');
    });

    _horizontalDrag.addListener(() {
      _setWidgetSide(_horizontalDrag.value);
      //print('Horizontal: ${horizontalDrag.value}');
      //print('Vertical: ${verticalDrag.value}');
    });

    _isFront.addListener(() {
      widget.onChanged!(_isFront.value);
    });

    widget.controller?._addState(this);
  }

  @override
  void dispose() {
    _vertAnimCtrlr.dispose();
    _horizAnimCtrlr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (dragDetails) {
        if (widget.dragAxis == DragAxis.vertical || widget.dragAxis == DragAxis.both) {
          _vertAnimCtrlr.reset();
          _verticalDrag.value = _lastVertDrag;
        }
      },
      onVerticalDragUpdate: (dragDetails) {
        if (widget.dragAxis == DragAxis.vertical || widget.dragAxis == DragAxis.both) {
          _verticalDrag.value = (_verticalDrag.value + dragDetails.delta.dy) % 360;
        }
      },
      onVerticalDragEnd: (dragDetails) {
        if (widget.dragAxis == DragAxis.vertical || widget.dragAxis == DragAxis.both) {
          double endRotation = 0.0;
          if (widget.revert) {
            endRotation = 360 - _verticalDrag.value >= 180 ? 0.0 : 360;
            _lastVertDrag = endRotation;
            _vertAnimation =
                Tween<double>(begin: _verticalDrag.value, end: endRotation).animate(CurvedAnimation(parent: _vertAnimCtrlr, curve: widget.curve))
                  ..addListener(() {
                    _verticalDrag.value = _vertAnimation.value;
                  });
            _vertAnimCtrlr.fling();
          } else {
            if (_verticalDrag.value >= 90 && _verticalDrag.value <= 270) {
              endRotation = 180;
            } else {
              endRotation = 360 - _verticalDrag.value >= 180 ? 0.0 : 360;
            }
            _lastVertDrag = endRotation;
            _lastHorizDrag = endRotation;
            _vertAnimation =
                Tween<double>(begin: _verticalDrag.value, end: endRotation).animate(CurvedAnimation(parent: _vertAnimCtrlr, curve: widget.curve))
                  ..addListener(() {
                    _verticalDrag.value = _vertAnimation.value;
                  });
            _vertAnimCtrlr.fling();
          }
        }
      },
      onHorizontalDragStart: (dragDetails) {
        if (widget.dragAxis == DragAxis.horizontal || widget.dragAxis == DragAxis.both) {
          _horizAnimCtrlr.reset();
          _horizontalDrag.value = _lastHorizDrag;
        }
      },
      onHorizontalDragUpdate: (dragDetails) {
        if (widget.dragAxis == DragAxis.horizontal || widget.dragAxis == DragAxis.both) {
          _horizontalDrag.value = (_horizontalDrag.value - dragDetails.delta.dx) % 360;
        }
      },
      onHorizontalDragEnd: (dragDetails) {
        if (widget.dragAxis == DragAxis.horizontal || widget.dragAxis == DragAxis.both) {
          double endRotation = 0.0;
          if (widget.revert) {
            endRotation = 360 - _horizontalDrag.value >= 180 ? 0.0 : 360;
            _lastHorizDrag = endRotation;
            _horizAnimation =
                Tween<double>(begin: _horizontalDrag.value, end: endRotation).animate(CurvedAnimation(parent: _vertAnimCtrlr, curve: widget.curve))
                  ..addListener(() {
                    _horizontalDrag.value = _horizAnimation.value;
                  });
            _horizAnimCtrlr.fling();
          } else {
            if (_horizontalDrag.value >= 90 && _horizontalDrag.value <= 270) {
              endRotation = 180;
            } else {
              endRotation = 360 - _horizontalDrag.value >= 180 ? 0.0 : 360;
            }
            _lastHorizDrag = endRotation;
            _lastVertDrag = endRotation;
            _horizAnimation =
                Tween<double>(begin: _horizontalDrag.value, end: endRotation).animate(CurvedAnimation(parent: _vertAnimCtrlr, curve: widget.curve))
                  ..addListener(() {
                    _horizontalDrag.value = _horizAnimation.value;
                  });
            _horizAnimCtrlr.fling();
          }
        }
      },
      child: SizedBox(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateX(_verticalDrag.value / 180 * _kPi)
            ..rotateY(_horizontalDrag.value / 180 * _kPi),
          child: ValueListenableBuilder<bool>(
            valueListenable: _isFront,
            builder: (context, front, _) {
              if (front) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..rotateX(_frontWidgetXAngle)
                    ..rotateY(_frontWidgetYAngle),
                  child: widget.frontWidget,
                );
              } else {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..rotateX(_backWidgetXAngle)
                    ..rotateY(_backWidgetYAngle),
                  child: widget.backWidget,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _setWidgetSide(double drag) {
    if (drag <= 90 || drag >= 270) {
      _isFront.value = true;
    } else {
      _isFront.value = false;
    }
    setState(() {});
  }

  double get _frontWidgetXAngle {
    double angle = 0.0;
    if (widget.dragAxis == DragAxis.both) {
      if (_verticalDrag.value >= 90 && _verticalDrag.value <= 270) {
        angle = _kPi;
      }
    }
    return angle;
  }

  double get _frontWidgetYAngle {
    double angle = 0.0;
    if (widget.dragAxis == DragAxis.both) {
      if (_horizontalDrag.value >= 90 && _horizontalDrag.value <= 270) {
        angle = _kPi;
      }
    }
    return angle;
  }

  double get _backWidgetXAngle {
    double angle = 0.0;
    if (widget.dragAxis == DragAxis.both) {
      if (_verticalDrag.value >= 90 && _verticalDrag.value <= 270) {
        angle = _kPi;
      }
    } else {
      if (widget.dragAxis == DragAxis.vertical) {
        angle = _kPi;
      }
    }
    return angle;
  }

  double get _backWidgetYAngle {
    double angle = 0.0;
    if (widget.dragAxis == DragAxis.both) {
      if (_horizontalDrag.value >= 90 && _horizontalDrag.value <= 270) {
        angle = _kPi;
      }
    } else {
      if (widget.dragAxis == DragAxis.horizontal) {
        angle = _kPi;
      }
    }
    return angle;
  }
}

/// Axis where the front and back child widgets can be dragged to flip.
enum DragAxis {
  horizontal,
  vertical,
  both,
}

/// Controller to remove the need of GlobalKey to access and change the state of the FLippable Widget
class FlippableController extends ChangeNotifier {
  _FlippableState? state;

  void _addState(_FlippableState state) {
    this.state = state;
  }

  bool get isFront => state?._isFront.value ?? true;

  ValueNotifier<double> get verticalDrag => state?._verticalDrag ?? ValueNotifier(0.0);

  ValueNotifier<double> get horizontalDrag => state?._horizontalDrag ?? ValueNotifier(0.0);

  double get lastVerticalDrag => state?._lastVertDrag ?? 0.0;

  double get lastHorizDrag => state?._lastHorizDrag ?? 0.0;

  /// Flip widget to the provided axis angle. Cannot be used with DragAxis.both.
  void flipTo(double axisAngle) {
    if (state != null) {
      switch (state!.widget.dragAxis) {
        case DragAxis.vertical:
          state?._vertAnimCtrlr.reset();
          state?._verticalDrag.value = state!._lastVertDrag;
          state?._vertAnimation = Tween<double>(begin: state?._verticalDrag.value, end: axisAngle)
              .animate(CurvedAnimation(parent: state!._vertAnimCtrlr, curve: state!.widget.curve))
                ..addListener(() {
                  state?._verticalDrag.value = state!._vertAnimation.value;
                });
          state!._lastVertDrag = axisAngle;
          state!._vertAnimCtrlr.forward();
          break;
        case DragAxis.horizontal:
          state?._horizAnimCtrlr.reset();
          state?._horizontalDrag.value = state!._lastHorizDrag;
          state?._horizAnimation = Tween<double>(begin: state?._horizontalDrag.value, end: axisAngle)
              .animate(CurvedAnimation(parent: state!._horizAnimCtrlr, curve: state!.widget.curve))
                ..addListener(() {
                  state?._horizontalDrag.value = state!._horizAnimation.value;
                });
          state!._lastHorizDrag = axisAngle;
          state!._horizAnimCtrlr.forward();
          break;
        default:
          break;
      }
    }

    notifyListeners();
  }
}
