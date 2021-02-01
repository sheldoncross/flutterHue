import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:flutterHue/model/profile.dart';
import 'package:flutterHue/database/db_utils.dart';

/*
*TODO - database shouldn't be initalized in every function call, best practices
*should be researched and implemented but for now the currrent implementation 
*works
*/

class ProfileDao {
  Future<int> insert(Profile profile) async {
    final db = await DBUtils.init();
    return await db.insert(
      'profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Profile>> getAll() async {
    final db = await DBUtils.init();
    List<Map<String, dynamic>> maps = await db.query('profile');
    List<Profile> profiles = [];
    for (int i = 0; i < maps.length; i++) {
      profiles.add(Profile.fromMap(maps[i]));
    }
    return profiles;
  }
}
