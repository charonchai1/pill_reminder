import 'dart:convert';
import 'dart:math';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:medicine/database/repository.dart';
import 'package:medicine/helpers/snack_bar.dart';
import 'package:medicine/models/medicine_type.dart';
import 'package:medicine/models/pill.dart';
import 'package:medicine/notifications/notifications.dart';
import '../../helpers/platform_flat_button.dart';
import '../../screens/add_new_medicine/form_fields.dart';
import '../../screens/add_new_medicine/medicine_type_card.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:medicine/pill_list/user_data.dart';
import 'package:http/http.dart' as http;

class AddNewMedicine extends StatefulWidget {
  @override
  _AddNewMedicineState createState() => _AddNewMedicineState();
}

class _AddNewMedicineState extends State<AddNewMedicine> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Snackbar snackbar = Snackbar();

  //medicine types
  final List<String> weightValues = ["pills", "ml", "mg"];

  //list of medicines forms objects
  final List<MedicineType> medicineTypes = [
    MedicineType("Syrup", Image.asset("assets/images/syrup.png"), true),
    MedicineType("Pill", Image.asset("assets/images/pills.png"), false),
    MedicineType("Capsule", Image.asset("assets/images/capsule.png"), false),
    MedicineType("Cream", Image.asset("assets/images/cream.png"), false),
    MedicineType("Drops", Image.asset("assets/images/drops.png"), false),
    MedicineType("Syringe", Image.asset("assets/images/syringe.png"), false),
  ];
  //list of time forms objects
  // final List<DateType> dateTypes = [
  //   DateType("Moring", Icon(Icons.wb_sunny_rounded), true),
  //   DateType("Afternoon", Icon(Icons.lunch_dining), false),
  //   DateType("Night", Icon(Icons.wb_twighlight), false),
  // ];
  //new add datetime 3 select
  //
  bool morning = false;
  bool afternoon = false;
  bool night = false;
  bool isCheck = false;
  //-------------Pill object------------------
  int howManyWeeks = 1;
  String selectWeight;

  DateTime setDate = DateTime.now();
  DateTime setDate1 = DateTime.now();
  DateTime setDate2 = DateTime.now();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  //==========================================

  //-------------- Database and notifications ------------------
  final Repository _repository = Repository();
  final Notifications _notifications = Notifications();

  //============================================================

  @override
  void initState() {
    super.initState();
    selectWeight = weightValues[0];
    getUser();
    initNotifies();
  }

  //init notifications
  Future initNotifies() async => flutterLocalNotificationsPlugin =
      await _notifications.initNotifies(context);

  //////newadd
  bool loading = true;
  void getUser() async {
    try {
      final response = await http.get(
          "https://raw.githubusercontent.com/charonchai1/demo/master/pill_dataset_beta.json");
      //final response = await http.get ("https://jsonplaceholder.typicode.com/users");
      //final response = await rootBundle.loadString('assets/pill_list.json');
      if (response.statusCode == 200) {
        setState(() {
          users = loadUsers(response.body);
          print('Users: ${users.length}');
          loading = false;
        });
      } else {
        print("no data");
      }
    } catch (e) {
      print("no data");
    }
  }

  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<User>> key = new GlobalKey();
  static List<User> users = new List<User>();
  Widget row(User user) {
    return Wrap(
      children: <Widget>[
        Text(
          user.name,
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }

  static List<User> loadUsers(String jsonString) {
    final parsed = json.decode(jsonString).cast<Map<String, dynamic>>();
    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }

  /////////////////

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height - 60.0;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromRGBO(248, 248, 248, 1),
      body: SafeArea(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 20.0, right: 20.0, top: 30.0, bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: deviceHeight * 0.05,
                  child: FittedBox(
                    child: InkWell(
                      child: Icon(Icons.arrow_back),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: deviceHeight * 0.01,
                ),
                ///////////new add search
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Wrap(
                      children: <Widget>[
                        loading
                            ? CircularProgressIndicator()
                            : searchTextField = AutoCompleteTextField<User>(
                                textInputAction: TextInputAction.next,
                                controller: nameController,
                                key: key,
                                clearOnSubmit: false,
                                suggestions: users,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.0),
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 20.0),
                                    labelText: "search pill",
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                            width: 0.5, color: Colors.grey)),
                                    suffixIcon: Icon(Icons.search)),
                                itemFilter: (item, query) {
                                  return item.name
                                      .toLowerCase()
                                      .startsWith(query.toLowerCase());
                                },
                                itemSorter: (a, b) {
                                  return a.name.compareTo(b.name);
                                },
                                itemSubmitted: (item) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                            title: Text(item.name),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                //position
                                                mainAxisSize: MainAxisSize.min,
                                                // wrap content in flutter
                                                children: <Widget>[
                                                  Text("ชื่อ : ",
                                                      style: new TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(item.name),
                                                  Text("สรรพคุณ : ",
                                                      style: new TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(item.properties),
                                                  Text("ขนาดและวิธีใช้ : ",
                                                      style: new TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(item.instruction),
                                                  Text("คำเตือน : ",
                                                      style: new TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(item.warming),
                                                  Text("การเก็บรักษา : ",
                                                      style: new TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(item.storage),
                                                  Text("ขนาดบรรจุ : ",
                                                      style: new TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(item.size)
                                                ],
                                              ),
                                            ));
                                      });
                                  setState(() {
                                    searchTextField.textField.controller.text =
                                        item.name;
                                  });
                                },
                                itemBuilder: (context, item) {
                                  return row(item);
                                },
                              )
                      ],
                    ),
                  ),
                ),
                /////////////////

                ///////////////////////////////////////
                Container(
                  height: deviceHeight * 0.30,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: FormFields(
                          howManyWeeks,
                          selectWeight,
                          popUpMenuItemChanged,
                          sliderChanged,
                          nameController,
                          amountController)),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: FittedBox(
                      child: Text(
                        "Medicine form",
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: deviceHeight * 0.02,
                ),
                Container(
                  height: 100,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      ...medicineTypes.map(
                          (type) => MedicineTypeCard(type, medicineTypeClick))
                    ],
                  ),
                ),
                SizedBox(
                  height: deviceHeight * 0.03,
                ),
                // Container(
                // dont forget
                // ),

                Row(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: FittedBox(
                          child: Text(
                            "When to take?",
                            style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      tooltip: 'Tap to open date picker',
                      onPressed: () {
                        openDatePicker();
                      },
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FittedBox(
                          child: Text(
                              '${setDate.year}-${setDate.month}-${setDate.day}')),
                    )
                  ],
                ),

                //new form date
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (morning == false) {
                          openTimePicker();
                        }
                        setState(() {
                          morning = !morning;
                        });
                      },
                      child: TimeCard(
                        icon: Icons.wb_sunny,
                        time: 'Morning',
                        isSelected: morning,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (afternoon == false) {
                          openTimePicker1();
                        }
                        setState(() {
                          afternoon = !afternoon;
                        });
                      },
                      child: TimeCard(
                        icon: Icons.wb_sunny,
                        time: 'Afternoon',
                        isSelected: afternoon,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (night == false) {
                          openTimePicker2();
                        }
                        setState(() {
                          night = !night;
                        });
                      },
                      child: TimeCard(
                        icon: Icons.wb_sunny,
                        time: 'Night',
                        isSelected: night,
                      ),
                    )
                  ],
                ),
                /////////////////////////////////////////////////
                SizedBox(
                  height: deviceHeight * 0.02,
                ),

                Spacer(),
                Container(
                  height: deviceHeight * 0.09,
                  width: double.infinity,
                  child: PlatformFlatButton(
                    handler: () async => savePill(),
                    color: Theme.of(context).primaryColor,
                    buttonChild: Text(
                      "Done",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17.0),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //slider changer
  void sliderChanged(double value) =>
      setState(() => this.howManyWeeks = value.round());

  //choose popum menu item
  void popUpMenuItemChanged(String value) =>
      setState(() => this.selectWeight = value);

  //------------------------OPEN TIME PICKER (SHOW)----------------------------
  //------------------------CHANGE CHOOSE PILL TIME----------------------------

  Future<void> openTimePicker() async {
    await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            helpText: "Choose Time")
        .then((value) {
      DateTime newDate = DateTime(
          setDate.year,
          setDate.month,
          setDate.day,
          value != null ? value.hour : setDate.hour,
          value != null ? value.minute : setDate.minute);
      setState(() => setDate = newDate);
      print("-----after opentimepicker--------");
      print("setDate $setDate");
      print("-----xxxxxxxxxx--------");

      print(newDate.hour);
      print(newDate.minute);
      print("-----------");
    });
  }

  Future<void> openTimePicker1() async {
    await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            helpText: "Choose Time")
        .then((value) {
      DateTime newDate = DateTime(
          setDate1.year,
          setDate1.month,
          setDate1.day,
          value != null ? value.hour : setDate1.hour,
          value != null ? value.minute : setDate1.minute);
      setState(() => setDate1 = newDate);
      print("-----after opentimepicker--------");
      print("setDate $setDate");
      print("-----xxxxxxxxxx--------");
      print(newDate.hour);
      print(newDate.minute);
      print("-----------");
    });
  }

  Future<void> openTimePicker2() async {
    await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            helpText: "Choose Time")
        .then((value) {
      DateTime newDate = DateTime(
          setDate2.year,
          setDate2.month,
          setDate2.day,
          value != null ? value.hour : setDate1.hour,
          value != null ? value.minute : setDate1.minute);
      setState(() => setDate2 = newDate);
      print("-----after opentimepicker--------");
      print("setDate $setDate");
      print("-----xxxxxxxxxx--------");
      print(newDate.hour);
      print(newDate.minute);
      print("-----------");
    });
  }

  //====================================================================

  //-------------------------SHOW DATE PICKER AND CHANGE CURRENT CHOOSE DATE-------------------------------
  Future<void> openDatePicker() async {
    await showDatePicker(
            context: context,
            initialDate: setDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 100000)))
        .then((value) {
      DateTime newDate = DateTime(
          value != null ? value.year : setDate.year,
          value != null ? value.month : setDate.month,
          value != null ? value.day : setDate.day,
          setDate.hour,
          setDate.minute);
      setState(() => setDate = newDate);
      setState(() => setDate1 = newDate);
      setState(() => setDate2 = newDate);
      print(setDate.day);
      print(setDate.month);
      print(setDate.year);
    });
  }

  //=======================================================================================================

  //--------------------------------------SAVE PILL IN DATABASE---------------------------------------
  Future savePill() async {
    if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
      isCheck = true;
    }
    //check if medicine time is lower than actual time
    if (morning && isCheck == true) {
      if (setDate.millisecondsSinceEpoch <=
          DateTime.now().millisecondsSinceEpoch) {
        snackbar.showSnack(
            "Check your medicine time and date", _scaffoldKey, null);
      } else {
        //create pill object\
        // print("time $setDate");
        // setDate = setDate1;
        // print("after set time $setDate");

        Pill pill = Pill(
            amount: amountController.text,
            howManyWeeks: howManyWeeks,
            medicineForm: medicineTypes[medicineTypes
                    .indexWhere((element) => element.isChoose == true)]
                .name,
            name: nameController.text,
            time: setDate.millisecondsSinceEpoch,
            type: selectWeight,
            notifyId: Random().nextInt(10000000));

        //---------------------| Save as many medicines as many user checks |----------------------
        for (int i = 0; i < howManyWeeks; i++) {
          dynamic result =
              await _repository.insertData("Pills", pill.pillToMap());
          if (result == null) {
            snackbar.showSnack("Something went wrong", _scaffoldKey, null);
            return;
          } else {
            //set the notification schneudele
            tz.initializeTimeZones();
            tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));
            await _notifications.showNotification(
                pill.name,
                pill.amount + " " + pill.medicineForm + " " + pill.type,
                time,
                pill.notifyId,
                flutterLocalNotificationsPlugin);
            setDate = setDate.add(Duration(milliseconds: 604800000));
            pill.time = setDate.millisecondsSinceEpoch;
            pill.notifyId = Random().nextInt(10000000);
            //new
            print("----------${pill.time}");
          }
        }
        //---------------------------------------------------------------------------------------
        snackbar.showSnack("Saved", _scaffoldKey, null);
        Navigator.pop(context);
      }
    } else {
      snackbar.showSnack("Check medicine name nad amount", _scaffoldKey, null);
    }

    if (afternoon && isCheck == true) {
      if (setDate1.millisecondsSinceEpoch <=
          DateTime.now().millisecondsSinceEpoch) {
        snackbar.showSnack(
            "Check your medicine time and date", _scaffoldKey, null);
      } else {
        //create pill object\
        // print("time $setDate");
        setDate = setDate1;
        // print("after set time $setDate");

        Pill pill = Pill(
            amount: amountController.text,
            howManyWeeks: howManyWeeks,
            medicineForm: medicineTypes[medicineTypes
                    .indexWhere((element) => element.isChoose == true)]
                .name,
            name: nameController.text,
            time: setDate.millisecondsSinceEpoch,
            type: selectWeight,
            notifyId: Random().nextInt(10000000));

        //---------------------| Save as many medicines as many user checks |----------------------
        for (int i = 0; i < howManyWeeks; i++) {
          dynamic result =
              await _repository.insertData("Pills", pill.pillToMap());
          if (result == null) {
            snackbar.showSnack("Something went wrong", _scaffoldKey, null);
            return;
          } else {
            //set the notification schneudele
            tz.initializeTimeZones();
            tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));
            await _notifications.showNotification(
                pill.name,
                pill.amount + " " + pill.medicineForm + " " + pill.type,
                time,
                pill.notifyId,
                flutterLocalNotificationsPlugin);
            setDate = setDate.add(Duration(milliseconds: 604800000));
            pill.time = setDate.millisecondsSinceEpoch;
            pill.notifyId = Random().nextInt(10000000);
            //new
            print("----------${pill.time}");
            if (morning != true) {
              snackbar.showSnack("Saved", _scaffoldKey, null);
              Navigator.pop(context);
            }
          }
        }
        //---------------------------------------------------------------------------------------

      }
    } else {
      snackbar.showSnack("Check medicine name nad amount", _scaffoldKey, null);
    }

    if (night && isCheck == true) {
      if (setDate2.millisecondsSinceEpoch <=
          DateTime.now().millisecondsSinceEpoch) {
        snackbar.showSnack(
            "Check your medicine time and date", _scaffoldKey, null);
      } else {
        //create pill object\
        // print("time $setDate");
        setDate = setDate2;
        // print("after set time $setDate");

        Pill pill = Pill(
            amount: amountController.text,
            howManyWeeks: howManyWeeks,
            medicineForm: medicineTypes[medicineTypes
                    .indexWhere((element) => element.isChoose == true)]
                .name,
            name: nameController.text,
            time: setDate.millisecondsSinceEpoch,
            type: selectWeight,
            notifyId: Random().nextInt(10000000));

        //---------------------| Save as many medicines as many user checks |----------------------
        for (int i = 0; i < howManyWeeks; i++) {
          dynamic result =
              await _repository.insertData("Pills", pill.pillToMap());
          if (result == null) {
            snackbar.showSnack("Something went wrong", _scaffoldKey, null);
            return;
          } else {
            //set the notification schneudele
            tz.initializeTimeZones();
            tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));
            await _notifications.showNotification(
                pill.name,
                pill.amount + " " + pill.medicineForm + " " + pill.type,
                time,
                pill.notifyId,
                flutterLocalNotificationsPlugin);
            setDate = setDate.add(Duration(milliseconds: 604800000));
            pill.time = setDate.millisecondsSinceEpoch;
            pill.notifyId = Random().nextInt(10000000);
            //new
            print("----------${pill.time}");
            if (morning != true && afternoon != true) {
              snackbar.showSnack("Saved", _scaffoldKey, null);
              Navigator.pop(context);
            }
          }
        }
        //---------------------------------------------------------------------------------------

      }
    } else {
      snackbar.showSnack("Check medicine name nad amount", _scaffoldKey, null);
    }
  }

  /////////////////SET DATE 3 TIME MORNING AFTERNOON NIGHT !! CHECK BOOLEAN BEFORE !!

  //---------------------end---------------------------------------

  //=================================================================================================

  //----------------------------CLICK ON MEDICINE FORM CONTAINER----------------------------------------
  void medicineTypeClick(MedicineType medicine) {
    setState(() {
      medicineTypes.forEach((medicineType) => medicineType.isChoose = false);
      medicineTypes[medicineTypes.indexOf(medicine)].isChoose = true;
    });
  }

  //=====================================================================================================

  //
  //get time difference

  int get time => (setDate.millisecondsSinceEpoch -
      tz.TZDateTime.now(tz.local).millisecondsSinceEpoch);
}

//get time diffrence from another time picked morning afternoon and night

/////////////////////////////////////////////////////////////////////////

class TimeCard extends StatelessWidget {
  const TimeCard({Key key, this.icon, this.time, this.isSelected})
      : super(key: key);
  final IconData icon;
  final String time;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 80,
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Color(0xFF073738), blurRadius: 10, offset: Offset(2, 3))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 30,
            color: isSelected ? Colors.green : Colors.red,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            time,
            style: TextStyle(
              color: isSelected ? Colors.green : Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
