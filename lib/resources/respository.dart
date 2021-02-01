import 'dart:async';
import 'package:flutterHue/model/profile.dart';
import 'package:flutterHue/resources/profile_dao.dart';

class Repository {
  final ProfileDao _profileDao = ProfileDao();

  Future<int> insertProfile(profile) => _profileDao.insert(profile);

  Future<List<Profile>> getAllProfiles() => _profileDao.getAll();
}
