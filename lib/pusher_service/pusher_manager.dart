import 'package:logger/logger.dart';
import 'package:pusher_manager/pusher_service/model/pusher_config.dart';
import 'package:pusher_manager/pusher_service/model/subscribe_event_model.dart';

import 'pusher_provider.dart';

var loggerPusher = Logger(
  printer: PrettyPrinter(),
);

class PusherManager {
  static PusherConfig? _pusherConfig;
  static Future<void> initPusher(PusherConfig pusherConfig) async {
    _pusherConfig = pusherConfig;
    await _connectPusher(_pusherConfig!);
  }

  static final Map<String, SubscribeEventModel> _mapSubscribeEvent = {};

  static Future<void> _connectPusher(PusherConfig pusherConfig) async {
    await PusherProvider.instance.init(pusherConfig);
  }

  static Future<void> disconnectPusher() async {
    PusherProvider.instance.disconnect();
  }

  Future<void> trigger({
    required SubscribeEventModel subscribeEventModel,
    required Map<String, dynamic> data,
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      await PusherProvider.instance.trigger(
        channelName: subscribeEventModel.channelName,
        eventName: subscribeEventModel.eventName,
        data: data,
      );
      onSuccess?.call();
    } catch (e) {
      onError?.call();
      loggerPusher.e("error trigger $e");
      rethrow;
    }
  }

  static Future<void> subscribe(SubscribeEventModel subscribeEvent) async {
    try {
      await unsubscribe(subscribeEvent.channelName, subscribeEvent.eventName);
      _mapSubscribeEvent[subscribeEvent.channelName] = subscribeEvent;
      PusherProvider.instance.subscribe(
        channelName: subscribeEvent.channelName,
        eventName: subscribeEvent.eventName,
        onSubscriptionSucceeded: (data) {
          try {
            subscribeEvent.onSubscriptionSucceeded?.call(data);
          } catch (e) {
            loggerPusher.e("error pusher  onSubscriptionSucceeded:$e");
            rethrow;
          }
        },
        onEvent: (data) {
          try {
            if (data.data != null && data.data.toString() != "{}") {
              subscribeEvent.onEvent?.call(data);
            }
          } catch (e) {
            loggerPusher.e("error pusher  onEvent:$e");
            rethrow;
          }
        },
        onSubscriptionCount: (number) {
          try {
            subscribeEvent.onSubscriptionCount?.call(number);
          } catch (e) {
            loggerPusher.e("error pusher  onSubscriptionCount:$e");
            rethrow;
          }
        },
      );
    } catch (e) {
      loggerPusher.e("error pusher : $e");
    }
  }

  static Future<void> unsubscribe(String channelName, String eventName) async {
    if (_mapSubscribeEvent[channelName] != null) {
      await PusherProvider.instance.unsubscribe(channelName, "");
      _mapSubscribeEvent.remove(channelName);
    }
  }
}
