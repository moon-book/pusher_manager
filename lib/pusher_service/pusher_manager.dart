import 'dart:async';

import 'package:logger/logger.dart';
import 'package:pusher_manager/pusher_service/model/pusher_config.dart';
import 'package:pusher_manager/pusher_service/model/subscribe_client_model.dart';
import 'package:pusher_manager/pusher_service/model/subscribe_pusher_model.dart';
import 'package:pusher_manager/pusher_service/model/subscribe_relation_model.dart';
import 'package:uuid/uuid.dart';

import 'pusher_provider.dart';

var loggerPusher = Logger(
  printer: PrettyPrinter(),
);

class PusherManager {
  static PusherConfig? _pusherConfig;
  static List<SubscribeClientModel> listSubscribeClient = [];
  static List<SubscribeRelationModel> listSubscribeRelation = [];
  static final Map<String, SubscribePusherModel> _mapSubscribePusher = {};

  static Future<void> initPusher(PusherConfig pusherConfig) async {
    _pusherConfig = pusherConfig;
    await _connectPusher(_pusherConfig!);
  }

  static Future<void> _connectPusher(PusherConfig pusherConfig) async {
    await PusherProvider.instance.init(pusherConfig);
  }

  static Future<void> disconnectPusher() async {
    PusherProvider.instance.disconnect();
  }

  Future<void> trigger({
    required SubscribeClientModel subscribeEventModel,
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

  static String subscribe(SubscribeClientModel subscribeClient) {
    try {
      String clientId = const Uuid().v1();
      subscribeClient = subscribeClient.copyWith(clientId);
      if (_mapSubscribePusher[subscribeClient.channelName] == null) {
        SubscribePusherModel subscribePusher = SubscribePusherModel(
          channelName: subscribeClient.channelName,
          eventName: subscribeClient.eventName,
          streamEvent: StreamController<dynamic>.broadcast(),
          streamSubscriptionCount: StreamController<int>.broadcast(),
          streamSubscriptionSucceeded: StreamController<dynamic>.broadcast(),
        );
        _mapSubscribePusher[subscribeClient.channelName] = subscribePusher;
        PusherProvider.instance.subscribe(
          channelName: subscribePusher.channelName,
          eventName: subscribePusher.eventName,
          onSubscriptionSucceeded: (data) {
            try {
              subscribePusher.streamSubscriptionSucceeded.add(data);
            } catch (e) {
              loggerPusher.e("error pusher onSubscriptionSucceeded:$e");
              rethrow;
            }
          },
          onEvent: (data) {
            try {
              subscribePusher.streamEvent.add(data);
            } catch (e) {
              loggerPusher.e("error pusher onEvent:$e");
              rethrow;
            }
          },
          onSubscriptionCount: (number) {
            try {
              subscribePusher.streamSubscriptionCount.add(number);
            } catch (e) {
              loggerPusher.e("error pusher onSubscriptionCount:$e");
              rethrow;
            }
          },
        );
      }

      _mapSubscribePusher[subscribeClient.channelName]!.subscribeCount += 1;
      SubscribePusherModel? subscribeOrigin = _mapSubscribePusher[subscribeClient.channelName];

      SubscribeRelationModel subscribeRelationModel = SubscribeRelationModel(
        id: subscribeClient.id,
        channelName: subscribeClient.channelName,
        eventName: subscribeClient.eventName,
      );
      subscribeRelationModel.subscriptionEvent = subscribeOrigin!.streamEvent.stream.listen((event) {
        subscribeClient.onEvent?.call(event);
      });
      subscribeRelationModel.subscriptionCount = subscribeOrigin.streamSubscriptionCount.stream.listen((event) {
        subscribeClient.onSubscriptionCount?.call(event);
      });
      subscribeRelationModel.subscriptionSucceeded = subscribeOrigin.streamSubscriptionSucceeded.stream.listen((event) {
        subscribeClient.onSubscriptionSucceeded?.call(event);
      });

      listSubscribeClient.add(subscribeClient);
      listSubscribeRelation.add(subscribeRelationModel);
      return clientId;
    } catch (e) {
      loggerPusher.e("error pusher : $e");
      return "";
    }
  }

  static Future<void> unsubscribe(
    String channelName,
    String eventName, {
    required String id,
  }) async {
    try {
      if (_mapSubscribePusher[channelName] == null) {
        return;
      }
      if (listSubscribeClient.where((element) => element.id == id).toList().isNotEmpty) {
        _mapSubscribePusher[channelName]!.subscribeCount =
            (_mapSubscribePusher[channelName]!.subscribeCount - 1) < 0 ? 0 : (_mapSubscribePusher[channelName]!.subscribeCount - 1);
      } else {
        return;
      }

      /// dừng các subscribe có id và channel
      for (var element in listSubscribeRelation) {
        if (element.channelName == channelName && element.id == id) {
          element.subscriptionCount!.cancel();
          element.subscriptionEvent!.cancel();
          element.subscriptionSucceeded!.cancel();
        }
      }

      listSubscribeClient.removeWhere((element) => element.channelName == channelName && element.id == id);

      listSubscribeRelation.removeWhere((element) => element.channelName == channelName && element.id == id);

      if (_mapSubscribePusher[channelName] != null && _mapSubscribePusher[channelName]!.subscribeCount == 0) {
        /// dừng các subscribe không có id vẫn đang lắng nghe
        for (var element in listSubscribeRelation) {
          if (element.channelName == channelName) {
            element.subscriptionCount!.cancel();
            element.subscriptionEvent!.cancel();
            element.subscriptionSucceeded!.cancel();
          }
        }

        listSubscribeClient.removeWhere((element) => element.channelName == channelName);

        listSubscribeRelation.removeWhere((element) => element.channelName == channelName);

        await PusherProvider.instance.unsubscribe(channelName, "");
        _mapSubscribePusher.remove(channelName);
      }
    } catch (e) {
      loggerPusher.e("error unsubscribe : $e");
    }
  }
}
