import 'package:rxdart/rxdart.dart';
import 'package:flutterHue/model/profile.dart';
import 'package:flutterHue/resources/respository.dart';

class ProfileBloc {
  Repository _repository = Repository();

  final _profileListFetcher = PublishSubject<List<Profile>>();

  Stream<List<Profile>> get profile => _profileListFetcher.stream;

  fetchProfile() async {
    List<Profile> profileResponse = await _repository.getAllProfiles();
    _profileListFetcher.sink.add(profileResponse);
  }

  insertProfile(String profileKey) async {
    await _repository.insertProfile(Profile(key: profileKey));
    List<Profile> profileResponse = await _repository.getAllProfiles();
    _profileListFetcher.sink.add(profileResponse);
  }

  dispose() {
    _profileListFetcher.close();
  }
}

final ProfileBloc profileBloc = ProfileBloc();
