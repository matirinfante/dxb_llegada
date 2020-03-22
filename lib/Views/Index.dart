import 'package:dxb_llegada/Views/Companion/CronometroCompanion.dart';
import 'package:dxb_llegada/Views/Maraton/CronometroMaraton.dart';
import 'package:flutter/material.dart';
import 'package:nice_button/nice_button.dart';

class Index extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            NiceButton(
              width: 255,
              elevation: 8.0,
              radius: 52.0,
              text: "Maratón",
              gradientColors: [Colors.blueGrey, Colors.blue],
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => CronometroMaraton()));
              },
            ),
            NiceButton(
              width: 255,
              elevation: 8.0,
              radius: 52.0,
              text: "Maratón",
              gradientColors: [Colors.blueGrey, Colors.blue],
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => CronometroCompanion()));
              },
            )
          ],
        ),
      ),
    );
  }
}
