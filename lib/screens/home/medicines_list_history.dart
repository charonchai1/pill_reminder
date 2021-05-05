import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medicine/models/pill.dart';
import '../../screens/home/medicine_card.dart';
import '../../screens/home/medicine_card_history.dart';


class MedicinesListHistory extends StatelessWidget {
  final List<Pill> listOfMedicines;
  final Function setData;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  MedicinesListHistory(this.listOfMedicines,this.setData,this.flutterLocalNotificationsPlugin);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => MedicineCardHistory(listOfMedicines[index],setData,flutterLocalNotificationsPlugin),
      itemCount: listOfMedicines.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
  }
}

