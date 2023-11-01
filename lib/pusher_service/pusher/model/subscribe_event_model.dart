class SubscribeEventModel {
  final String channelName;
  final String eventName;
  Function(dynamic) onEvent;
  Function(int)? onSubscriptionCount;
  SubscribeEventModel({
    required this.channelName,
    required this.eventName,
    required this.onEvent,
    this.onSubscriptionCount,
  });
}
