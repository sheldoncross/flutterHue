import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutterHue/util/bridge.dart';
import 'package:flutterHue/db/local/model/profile.dart';
import 'package:flutterHue/db/local/model/profile_model.dart';
import 'dart:convert';

class LightList extends StatefulWidget {
  LightList({Key key, this.address}) : super(key: key);

  //Hue bridge address
  final String address;

  @override
  _LightListState createState() => _LightListState();
}

class _LightListState extends State<LightList> {
  //Holds the responses from the bridge
  Map bridgeResponse;
  //Holds the key recieved from either the Hue bridge or the local database
  String profileKey;

  @override
  void initState() {
    super.initState();
    //Get the API key needed for interaction with the Hue bridge
    _loadApiKey(printMessages: true);
  }

  Future<bool> _getSavedKey({bool printMessages}) async {
    print('Searching local database for key!');
    List<Profile> profileList = await ProfileModel().getProfiles();
    /*
    *For now only the first profile is used and the key is extracted from that
    *in the future multiple profiles may not be needed but for now they are 
    *included in case a need arises
    */
    if (profileList.isNotEmpty) {
      profileKey = profileList[0].key;
      print('Key found!');
      print('Locally saved key: $profileKey');
      return true;
    }
    return false;
  }

  Future<void> _loadApiKey({bool printMessages}) async {
    if (printMessages == true) {
      print('Retrieving hue bridge API key!');
    }

    //Check if the local database has a saved username key
    bool isSaved = await _getSavedKey(printMessages: printMessages);
    if (isSaved == false) {
      //Register a new authorized user
      var response = await http.post('https://${widget.address}/api',
          body: '{"devicetype": "flutterHue#android_stefan"}');

      //Decode the JSON from the API response
      List data = jsonDecode(response.body);

      //Check if the bridge has returned a success value or an error value
      if (Bridge.fromMap(data[0]).error != null) {
        //Save the error information
        bridgeResponse = Bridge.fromMap(data[0]).error;

        //Get the error description
        profileKey =
            BridgeError.fromMap(Bridge.fromMap(data[0]).error).description;

        //Output message, reset the profile key, and rerun function
        if (printMessages == true) {
          print('Please press the button on your hue bridge!');
        }
        profileKey = null;
        _loadApiKey(printMessages: false);
      } else if (Bridge.fromMap(data[0]).success != null) {
        //Save the success information
        bridgeResponse = Bridge.fromMap(data[0]).success;

        //Get the username from the succes value
        profileKey =
            BridgeSuccess.fromMap(Bridge.fromMap(data[0]).success).username;
        print('Obtained key!');

        /*
        *Create a new profile with the obtained key, save the profile to the
        *local database then output the obtained key
        */
        Profile newProfile = Profile(key: profileKey);
        ProfileModel().insertProfile(newProfile);
        List<Profile> savedProfileList = await ProfileModel().getProfiles();
        print('Locally saved key: ${savedProfileList[0].key}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [],
    );
  }
}
