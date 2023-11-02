class SubscribeEventModel {
  final String channelName;
  final String eventName;
  Function(dynamic)? onEvent;
  Function(int)? onSubscriptionCount;
  Map<String, dynamic>? data;

  SubscribeEventModel({
    required this.channelName,
    required this.eventName,
    this.onEvent,
    this.data,
    this.onSubscriptionCount,
  });
}
