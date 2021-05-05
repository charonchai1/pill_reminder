import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:medicine/database/repository.dart';
import 'package:medicine/models/pill.dart';
import 'package:medicine/notifications/notifications.dart';

class MedicineCardHistory extends StatelessWidget {

  final Pill medicine;
  final Function setData;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  MedicineCardHistory(this.medicine,this.setData,this.flutterLocalNotificationsPlugin);

  @override
  Widget build(BuildContext context) {
    //check if the medicine time is lower than actual
    final bool isStart = DateTime.now().millisecondsSinceEpoch >= medicine.time;
    final bool isEnd = DateTime.now().millisecondsSinceEpoch == medicine.time;


    return Card(
        elevation: 0.0,
        margin: EdgeInsets.symmetric(vertical: 7.0),
        color: Colors.white,
        child: ListTile(
          
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            title: Text(
              medicine.name,
              style: Theme.of(context).textTheme.headline1.copyWith(
                  color: Colors.black,
                  fontSize: 20.0,
                  decoration: isStart ? TextDecoration.lineThrough : null,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "${medicine.amount} ${medicine.medicineForm}",
              style: Theme.of(context).textTheme.headline5.copyWith(
                  color: Colors.blue[600],
                  fontSize: 15.0,
                  decoration: isStart ? TextDecoration.lineThrough : null),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  DateFormat("dd.MMMMM.yyyyy  HH:mm").format(
                      DateTime.fromMillisecondsSinceEpoch(medicine.time)),
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      decoration: isStart ? TextDecoration.lineThrough : null),
                ),
              ],
            ),
            leading: Container(
              width: 60.0,
              height: 60.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        isStart ? Colors.white : Colors.transparent,
                        BlendMode.saturation),
                    child: Image.asset(
                      medicine.image
                    )),
              ),
            ),
           
            )
            );
  }


  


}
