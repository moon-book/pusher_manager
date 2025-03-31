import 'dart:async';

class SubscribePusherModel {
  String channelName;
  String eventName;
  int subscribeCount;
  StreamController<dynamic> streamEvent;
  StreamController<int> streamSubscriptionCount;
  StreamController<dynamic> streamSubscriptionSucceeded;
  SubscribePusherModel({
    this.subscribeCount = 0,
    required this.channelName,
    required this.eventName,
    required this.streamEvent,
    required this.streamSubscriptionCount,
    required this.streamSubscriptionSucceeded,
  });
}
