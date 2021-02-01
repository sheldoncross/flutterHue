import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:flutterHue/model/light.dart';
import 'package:flutterHue/model/bridge.dart';

//TODO - Create function to retrieve information for individual lights
//TODO - Create a API call to toggle each light off and on
//TODO - Create a API call to adjust saturation, brightness and hue of a light

class LightApi {
  //Holds the responses from the bridge
  Map bridgeResponse;
  //Holds the key recieved from either the Hue bridge or the local database
  String profileKey;
  //Hue bridge address
  String address;

  Client client;

  LightApi({this.address, this.client});

  String setKey({String newKey}) {
    profileKey = newKey;
    return newKey;
  }

  //Create an API key if there is none or retrieve the API key from the local db
  Future<String> fetchKey({bool printMessages}) async {
    if (printMessages == true) {
      print('Retrieving hue bridge API key!');
    }

    //Register a new authorized user
    var response = await client.post('https://$address/api',
        body: '{"devicetype": "flutterHue#android_stefan"}');
    //Decode the JSON from the API response
    List data = jsonDecode(response.body);

    //Check if the bridge has returned a success value or an error value
    while (Bridge.fromMap(data[0]).error != null) {
      //Save the error information
      bridgeResponse = Bridge.fromMap(data[0]).error;
      //Get the error description
      String errorMessage =
          BridgeError.fromMap(Bridge.fromMap(data[0]).error).description;

      //Output message, reset the profile key, and rerun function
      if (printMessages == true) {
        print('$errorMessage!');
      }

      await Future.delayed(Duration(seconds: 5));
      response = await client.post('https://$address/api',
          body: '{"devicetype": "flutterHue#android_stefan"}');
      data = jsonDecode(response.body);
    }

    if (Bridge.fromMap(data[0]).success != null) {
      //Save the success information
      bridgeResponse = Bridge.fromMap(data[0]).success;
      //Get the username from the succes value
      profileKey =
          BridgeSuccess.fromMap(Bridge.fromMap(data[0]).success).username;
      print('Obtained key $profileKey');
      return profileKey;
    } else {
      //Exit if there is an error
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.dumpErrorToConsole(details);
      };
      exit(1);
    }
  }

  //Create and return a list containg each light object
  Future<List<Light>> fetchAllLights({bool printMessages}) async {
    print('Getting information for all lights!');
    List<Light> allLights = [];
    //Retrieve and store the light data
    var response = await client.get('https://$address/api/$profileKey/lights');
    //Map of light data containing each lights properties and state values
    Map data = jsonDecode(response.body);

    for (var i = 1; i <= data.length; i++) {
      Light light = Light.fromMap(data['$i']);
      allLights.add(light);
    }

    print('Information for all lights retrieved!');
    print('All Lights: $allLights');
    return allLights;
  }
}
