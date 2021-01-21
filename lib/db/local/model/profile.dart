class Profile {
  String key;

  Profile({this.key});

  Profile.fromMap(Map<String, dynamic> map) {
    this.key = map['key'];
  }

  Map<String, dynamic> toMap() {
    return {
      'key': this.key,
    };
  }

  @override
  String toString() {
    return ('Profile - Key: $key');
  }
}
