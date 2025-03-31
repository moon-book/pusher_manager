import 'dart:async';

class SubscribeClientModel {
  final String id;
  final String channelName;
  final String eventName;

  Function(dynamic)? onEvent;
  Function(int)? onSubscriptionCount;
  Function(dynamic)? onSubscriptionSucceeded;

  SubscribeClientModel({
    this.id = "",
    required this.channelName,
    required this.eventName,
    this.onEvent,
    this.onSubscriptionSucceeded,
    this.onSubscriptionCount,
  });

  SubscribeClientModel copyWith(String id) {
    return SubscribeClientModel(
        id: id,
        channelName: channelName,
        eventName: eventName,
        onEvent: onEvent,
        onSubscriptionCount: onSubscriptionCount,
        onSubscriptionSucceeded: onSubscriptionSucceeded);
  }
}
