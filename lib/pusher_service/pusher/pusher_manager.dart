import 'package:logger/logger.dart';
import 'package:pusher_manager/pusher_service/pusher/model/pusher_config.dart';
import 'package:pusher_manager/pusher_service/pusher/model/subscribe_event_model.dart';
import 'pusher_provider.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class PusherManager {
  static PusherConfig? _pusherConfig;
  static initPusherConfig(PusherConfig pusherConfig) {
    _pusherConfig = pusherConfig;
    _connectPusher(_pusherConfig!);
  }

  final List<SubscribeEventModel> _listSubscribeEvent = [];

  static Future<void> _connectPusher(PusherConfig pusherConfig) async {
    await PusherProvider().init(pusherConfig);
  }

  static Future<void> disconnectPusher() async {
    PusherProvider().disconnect();
  }

  Future<void> addHandler(SubscribeEventModel subscribeEvent) async {
    try {
      for (int i = 0; i < _listSubscribeEvent.length; i++) {
        var element = _listSubscribeEvent[i];
        if (element.channelName == subscribeEvent.channelName) {
          await PusherProvider().unsubscribe(subscribeEvent.channelName, "");
          await Future.delayed(const Duration(seconds: 2));
        }
        _listSubscribeEvent.removeAt(i);
        i = i - 1;
      }

      PusherProvider().subscribe(
        channelName: subscribeEvent.channelName,
        eventName: subscribeEvent.eventName,
        onEvent: (data) {
          try {
            subscribeEvent.onEvent(data).call();
          } catch (e) {
            logger.e("error pusher  onEvent$e");
          }
        },
        onSubscriptionCount: (number) {
          try {
            if (subscribeEvent.onSubscriptionCount != null) {
              subscribeEvent.onSubscriptionCount!(number).call();
            }
          } catch (e) {
            logger.e("error pusher  onSubscriptionCount$e");
          }
        },
      );
    } catch (e) {
      logger.e("error pusher $e");
    }
  }

  Future<void> removeHandler(String channelName, String eventName) async {
    for (int i = 0; i < _listSubscribeEvent.length; i++) {
      var element = _listSubscribeEvent[i];
      if (element.channelName == channelName) {
        await PusherProvider().unsubscribe(channelName, "");
        await Future.delayed(const Duration(seconds: 2));
      }
      _listSubscribeEvent.removeAt(i);
      i = i - 1;
    }
  }
}
