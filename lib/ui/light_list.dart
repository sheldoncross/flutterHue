import 'package:flutter/material.dart';
import 'package:flutterHue/model/light.dart';
import 'package:flutterHue/model/profile.dart';
import 'package:flutterHue/blocs/light_bloc.dart';
import 'package:flutterHue/blocs/profile_bloc.dart';

//TODO - Style rows

class LightList extends StatefulWidget {
  LightList({Key key}) : super(key: key);

  @override
  _LightListState createState() => _LightListState();
}

class _LightListState extends State<LightList> {
  //A temporary function displaying rows of light information
  Column _buildRows(List<Light> allLights) {
    List<Padding> _lightList = [];

    print('Creating a row for each light on the home page!');

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
      _lightList.add(row);
    }
    return Column(children: _lightList);
  }

  @override
  Widget build(BuildContext context) {
    //Check for previously saved profiles
    profileBloc.fetchProfile();
    //Watch changes to profiles database
    return StreamBuilder(
      stream: profileBloc.profile,
      builder: (context, AsyncSnapshot<List<Profile>> snapshot) {
        //If a profile is recently found refresh light list with most recent key
        if (snapshot.data?.isNotEmpty ?? false) {
          print('Previous profile found!');
          print('Profile list: ${snapshot.data}!');
          //Set the api key and retrieve lights
          lightBloc.setKey(snapshot.data.last.key);
          lightBloc.fetchLightData();
          //Watch for changes to light api key
          return StreamBuilder(
            stream: lightBloc.apiKey,
            builder: (context, AsyncSnapshot<String> snapsshot) {
              //If a new key has been found watch for changes to lights list
              if (snapshot.hasData) {
                return StreamBuilder(
                  stream: lightBloc.lights,
                  builder: (context, AsyncSnapshot<List<Light>> snapshot) {
                    //If a light list has been changed build the home page rows
                    if (snapshot.hasData) {
                      return _buildRows(snapshot.data);
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    return LinearProgressIndicator();
                  },
                );
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return LinearProgressIndicator();
            },
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else if (snapshot.data?.isEmpty ?? false) {
          //Obtain the API key for the new profile
          print('No prevous profile found!');
          lightBloc.fetchKey();
          return StreamBuilder(
            stream: lightBloc.apiKey,
            builder: (context, AsyncSnapshot<String> snapshot) {
              //When new API key is detected insert a new profile into database
              if (snapshot.hasData) {
                profileBloc.insertProfile(snapshot.data);
                print('New key generated!');
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return LinearProgressIndicator();
            },
          );
        }
        return LinearProgressIndicator();
      },
    );
  }
}
