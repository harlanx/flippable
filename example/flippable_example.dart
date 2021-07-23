import 'package:flippable/flippable.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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