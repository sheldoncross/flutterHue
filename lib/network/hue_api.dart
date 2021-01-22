import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutterHue/util/light.dart';
import 'package:flutterHue/util/bridge.dart';
import 'package:flutterHue/db/local/model/profile.dart';
import 'package:flutterHue/db/local/model/profile_model.dart';

//TODO - Create function to retrieve information for individual lights
//TODO - Create a API call to toggle each light off and on
//TODO - Create a API call to adjust saturation, brightness and hue of a light

class HueApi {
  //Holds the responses from the bridge
  Map bridgeResponse;
  //Holds the key recieved from either the Hue bridge or the local database
  String profileKey;
  //Hue bridge address
  String address = '192.168.4.48';

  //Check if a profile containing an API key is present
  Future<bool> _checkProfileList({bool printMessages}) async {
    print('Checking if profile table is empty!');

    List<Profile> profileList = await ProfileModel().getProfiles();

    /*
    *For now only the first profile is used and the key is extracted from that
    *in the future multiple profiles may not be needed but for now they are 
    *included in case a need arises
    */
    if (profileList.isNotEmpty) {
      print('Profile entry found!');
      return true;
    } else {
      return false;
    }
  }

  //Create an API key if there is none or retrieve the API key from the local db
  Future<void> loadKey({bool printMessages}) async {
    if (printMessages == true) {
      print('Retrieving hue bridge API key!');
    }

    //Check if the local database has a saved username key
    await _checkProfileList(printMessages: printMessages).then(
      (isSaved) async {
        if (isSaved == false) {
          //Register a new authorized user
          var response = await http.post('https://$address/api',
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

            loadKey(printMessages: false);
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
            print('Locally saved key: ${savedProfileList[0].key}!');
          }
        } else {
          print('Assigning stored key!');
          List<Profile> savedProfileList = await ProfileModel().getProfiles();
          profileKey = savedProfileList[0].key;
        }
      },
    );
  }

  //Create and return a list containg each light object
  Future<List<Light>> getAllLights({bool printMessages}) async {
    print('Getting information for all lights!');

    List<Light> allLights = [];

    //If profile key wasnt previously set then load it
    if (profileKey == null) {
      await loadKey(printMessages: true);
    }

    //Retrieve and store the light data
    var response = await http.get('https://$address/api/$profileKey/lights');

    //Map of light data containing each lights properties and state values
    Map data = jsonDecode(response.body);

    for (var i = 1; i <= data.length; i++) {
      Light light = Light.fromMap(data['$i']);
      allLights.add(light);
    }

    print('Information for all lights retrieved!');

    return allLights;
  }
}
