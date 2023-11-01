import 'dart:convert';

import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:pusher_manager/pusher_service/model/pusher_config.dart';

class PusherProvider {
  PusherChannelsFlutter? _pusher;
  PusherProvider._() {
    _pusher = PusherChannelsFlutter.getInstance();
    // apiKey = AppFlavor.type.apiKeyPusher;
    // _pusher = PusherChannelsFlutter.getInstance();
    // _pusher.init(
    //   apiKey: apiKey,
    //   cluster: cluster,
    //   authEndpoint: authEndpoint,
    //   // onAuthorizer: (channelName, socketId, data) async {
    //   //   final response = await Dio().post(authEndpoint, data: "socket_id=$socketId&channel_name=$channelName");
    //   //   return jsonDecode(response.data);
    //   // },
    //   maxReconnectGapInSeconds: 10,
    //   maxReconnectionAttempts: 99999999999999,
    // );
    // _pusher.connect();
  }

  static final PusherProvider instance = PusherProvider._();

  Future<void> init(PusherConfig pusherConfig) async {
    // _pusher = PusherChannelsFlutter.getInstance();
    if (_pusher?.connectionState == "DISCONNECTED") {
      await _pusher?.init(
        apiKey: pusherConfig.apiKey,
        cluster: pusherConfig.cluster,
        authEndpoint: pusherConfig.authEndpoint,
        // onAuthorizer: (channelName, socketId, data) async {
        //   final response = await Dio().post(authEndpoint, data: "socket_id=$socketId&channel_name=$channelName");
        //   return jsonDecode(response.data);
        // },
        maxReconnectGapInSeconds: 10,
        maxReconnectionAttempts: 99999999999999,
      );
      await _pusher?.connect();
    }
  }

  void subscribe({
    required String channelName,
    required String eventName,
    required Function onEvent,
    Function(int)? onSubscriptionCount,
  }) {
    _pusher?.subscribe(
      channelName: channelName,
      onEvent: onEvent,
      onSubscriptionCount: onSubscriptionCount,
    );
  }

  Future<void> unsubscribe(String channelName, String eventName) async {
    await _pusher?.unsubscribe(
      channelName: channelName,
    );
  }

  void disconnect() {
    if (_pusher != null && _pusher?.connectionState != "DISCONNECTED") {
      _pusher?.disconnect();
    }
  }

  Future<void> push({required String channelName, required String eventName, required Map<String, dynamic> data}) async {
    try {
      await _pusher?.trigger(
        PusherEvent(channelName: channelName, eventName: eventName, data: jsonEncode(data)),
      );
    } catch (e) {
      rethrow;
    }
  }
}
