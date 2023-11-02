import 'package:logger/logger.dart';
import 'package:pusher_manager/pusher_service/model/pusher_config.dart';
import 'package:pusher_manager/pusher_service/model/subscribe_event_model.dart';

import 'pusher_provider.dart';

var loggerPusher = Logger(
  printer: PrettyPrinter(),
);

class PusherManager {
  static PusherConfig? _pusherConfig;
  static initPusherConfig(PusherConfig pusherConfig) {
    _pusherConfig = pusherConfig;
    _connectPusher(_pusherConfig!);
  }

  static final List<SubscribeEventModel> _listSubscribeEvent = [];

  static Future<void> _connectPusher(PusherConfig pusherConfig) async {
    await PusherProvider.instance.init(pusherConfig);
  }

  static Future<void> disconnectPusher() async {
    PusherProvider.instance.disconnect();
  }

  Future<void> trigger({
    required String channelName,
    required String eventName,
    required Map<String, dynamic> data,
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      await PusherProvider.instance.trigger(
        channelName: channelName,
        eventName: eventName,
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
      for (int i = 0; i < _listSubscribeEvent.length; i++) {
        var element = _listSubscribeEvent[i];
        if (element.channelName == subscribeEvent.channelName) {
          await PusherProvider.instance.unsubscribe(subscribeEvent.channelName, "");
          await Future.delayed(const Duration(seconds: 2));
          _listSubscribeEvent.removeAt(i);
          i = i - 1;
        }
      }
      _listSubscribeEvent.add(subscribeEvent);
      PusherProvider.instance.subscribe(
        channelName: subscribeEvent.channelName,
        eventName: subscribeEvent.eventName,
        onEvent: (data) {
          try {
            subscribeEvent.onEvent!(data).call();
          } catch (e) {
            loggerPusher.e("error pusher  onEvent$e");
            rethrow;
          }
        },
        onSubscriptionCount: (number) {
          try {
            if (subscribeEvent.onSubscriptionCount != null) {
              subscribeEvent.onSubscriptionCount!(number).call();
            }
          } catch (e) {
            loggerPusher.e("error pusher  onSubscriptionCount$e");
            rethrow;
          }
        },
      );
    } catch (e) {
      loggerPusher.e("error pusher $e");
    }
  }

  static Future<void> unsubscribe(String channelName, String eventName) async {
    for (int i = 0; i < _listSubscribeEvent.length; i++) {
      var element = _listSubscribeEvent[i];
      if (element.channelName == channelName) {
        await PusherProvider.instance.unsubscribe(channelName, "");
        await Future.delayed(const Duration(seconds: 2));
      }
      _listSubscribeEvent.removeAt(i);
      i = i - 1;
    }
  }
}
