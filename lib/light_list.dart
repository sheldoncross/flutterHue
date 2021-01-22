import 'package:flutter/material.dart';
import 'package:flutterHue/network/hue_api.dart';
import 'package:flutterHue/util/light.dart';

//TODO - Style rows

class LightList extends StatefulWidget {
  LightList({Key key}) : super(key: key);

  @override
  _LightListState createState() => _LightListState();
}

class _LightListState extends State<LightList> {
  List<Padding> lightList = [];

  @override
  void initState() {
    super.initState();
    fetchList();
  }

  //Get list of all lights and then call the widget creation function for each
  void fetchList() async {
    List<Light> allLights;
    allLights = await HueApi().getAllLights();
    makeTempRows(allLights);
  }

  //A temporary function displaying rows of light information
  void makeTempRows(List<Light> allLights) {
    print('Creating a row for each light on the home page');
    for (Light light in allLights) {
      Padding row = Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(light.name),
            Text(light.onVal.toString()),
          ],
        ),
      );
      setState(() {
        lightList.add(row);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: lightList,
    );
  }
}
