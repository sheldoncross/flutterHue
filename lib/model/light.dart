class Light {
  bool onVal;
  int brightness;
  int hue;
  int saturation;
  bool reachable;
  String name;

  Light(
      {this.onVal,
      this.brightness,
      this.hue,
      this.saturation,
      this.reachable,
      this.name});

  factory Light.fromMap(Map map) {
    return Light(
      onVal: map['state']['on'],
      brightness: map['state']['bri'],
      hue: map['state']['hue'],
      saturation: map['state']['sat'],
      reachable: map['state']['reachable'],
      name: map['name'],
    );
  }

  @override
  String toString() {
    return 'Name: $name, On: $onVal, Brightness: $brightness, Hue: $hue,' +
        ' Saturation: $saturation, Reachable: $reachable';
  }
}

class ApiLightList {
  Map lights;

  ApiLightList({this.lights});

  factory ApiLightList.fromMap(Map map) {
    return ApiLightList(
      lights: map['lights'],
    );
  }

  @override
  String toString() {
    return lights.toString();
  }
}
