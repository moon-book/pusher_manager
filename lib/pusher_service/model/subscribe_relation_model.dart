import 'dart:async';

class SubscribeRelationModel {
  String id;
  String channelName;
  String eventName;
  StreamSubscription<dynamic>? subscriptionEvent;
  StreamSubscription<int>? subscriptionCount;
  StreamSubscription<dynamic>? subscriptionSucceeded;

  SubscribeRelationModel({
    this.id = "",
    required this.channelName,
    required this.eventName,
    this.subscriptionCount,
    this.subscriptionEvent,
    this.subscriptionSucceeded,
  });
}
