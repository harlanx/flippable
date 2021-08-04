# flippable

A Flutter Widget wrapper that enables vertical and horizontal dragging to flip the front and back widget.

I do not plan to release it on pub.dev. Feel free to fork it.

## Features
- Horizontal Dragging
- Vertical Dragging
- Both Direction Dragging (Only one single axis is active when dragging)
- Revert (Always animate back to front)

## Preview

<img src="https://user-images.githubusercontent.com/78299538/126768303-60fe8d76-f2a2-4ce2-b887-0ba9071da601.gif" width="450"/>

## Usage

```dart
import 'package:flippable/flippable.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flippable Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: SizedBox(
          height: 400,
          width: 400,
          child: Flippable(
            dragAxis: DragAxis.both,
            revert: false,
            frontWidget: Image.asset(
              'assets/images/credit_card_front.png',
              fit: BoxFit.contain,
            ),
            backWidget: Image.asset(
              'assets/images/credit_card_back.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
```

## Planned Features
  - True orientation (Correction of orientation of back widget will be disabled)
  - Create a controller to flip programatically.
  - Add onChanged bool function to listen front and back state.
