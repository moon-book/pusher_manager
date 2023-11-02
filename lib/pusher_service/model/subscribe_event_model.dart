class SubscribeEventModel {
  final String channelName;
  final String eventName;
  Function(dynamic)? onEvent;
  Function(int)? onSubscriptionCount;
  Function(dynamic)? onSubscriptionSucceeded;

  SubscribeEventModel({
    required this.channelName,
    required this.eventName,
    this.onEvent,
    this.onSubscriptionSucceeded,
    this.onSubscriptionCount,
  });
}
