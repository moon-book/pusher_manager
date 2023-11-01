abstract class PusherConfig {
  String get apiKey;
  String get cluster;
  String get authEndpoint;
}

class DevPusherConfig implements PusherConfig {
  @override
  String get apiKey => '2f19810c2de48ce08d87';

  @override
  String get authEndpoint => 'https://pusher-dev.storynap.com/pusher/auth';

  @override
  String get cluster => 'ap1';
}

class ProdPusherConfig implements PusherConfig {
  @override
  String get apiKey => 'd72e08a29bf1db89a76c';

  @override
  String get authEndpoint => 'https://pusher.storynap.com/pusher/auth';

  @override
  String get cluster => 'ap1';
}
