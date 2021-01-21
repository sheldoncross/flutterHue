import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'db_util.dart';
import 'profile.dart';

/*
*TODO - database shouldn't be initalized in every function call, best practices
*should be researched and implemented but for now the currrent implementation 
*works
*/

class ProfileModel {
  Future<int> insertProfile(Profile profile) async {
    final db = await DBUtils.init();
    return await db.insert(
      'profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Profile>> getProfiles() async {
    final db = await DBUtils.init();
    List<Map<String, dynamic>> maps = await db.query('profile');
    List<Profile> profiles = [];
    for (int i = 0; i < maps.length; i++) {
      profiles.add(Profile.fromMap(maps[i]));
    }
    return profiles;
  }
}
