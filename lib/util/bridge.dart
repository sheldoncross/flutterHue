class Bridge {
  Map error;
  Map success;

  Bridge({this.error, this.success});

  factory Bridge.fromMap(Map map) {
    return Bridge(
      error: map['error'],
      success: map['success'],
    );
  }

  String toString() {
    return 'Bridge status - Error: $error - Success: $success ';
  }
}

class BridgeError {
  String description;

  BridgeError({this.description});

  factory BridgeError.fromMap(Map map) {
    return BridgeError(
      description: map['description'],
    );
  }
}

class BridgeSuccess {
  String username;

  BridgeSuccess({this.username});

  factory BridgeSuccess.fromMap(Map map) {
    return BridgeSuccess(
      username: map['username'],
    );
  }
}
