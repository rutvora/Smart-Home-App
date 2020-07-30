import 'dart:async';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:multicast_dns/multicast_dns.dart';

/// Discovers the IP address of a device by its [hostName]
Future<InternetAddress> resolveMDNS(String hostName) async {
  // Create rawDatagramSocketFactory with reusePort set as false to avoid errors in Android
  var factory =
      (dynamic host, int port, {bool reuseAddress, bool reusePort, int ttl}) {
    return RawDatagramSocket.bind(host, port,
        reuseAddress: true, reusePort: false, ttl: ttl);
  };
  //Create MDnsClient with the given factory
  final client = MDnsClient(rawDatagramSocketFactory: factory);

  hostName += '.local';
  InternetAddress broker; //The value to be returned
  // Start the client with default options.
  await client.start();
  await for (IPAddressResourceRecord ptr
      in client.lookup<IPAddressResourceRecord>(
          ResourceRecordQuery.addressIPv4(hostName))) {
    broker = ptr.address;
    print(ptr.address);
    print('\n');
    break;
  }
  client.stop();
  if (broker == null) return null;
  return broker;
}

/// Class representing an MQTT connection to a broker given by [_host]
class MQTT {
  InternetAddress _host;
  MqttServerClient _client;
  bool isConnected = false;
  Function connectionChangedCallback;

  MQTT(this._host, this.connectionChangedCallback);

  Future<void> connectToBroker() async {
    if (_client != null) return;
    print("Connecting to Broker");
    _client = MqttServerClient(_host.address, 'phone');
    _client.keepAlivePeriod = 5;
    _client.autoReconnect = true;
    _client.onDisconnected = () {
      print("Disconnected");
      connectionChangedCallback(false);
      isConnected = false;
    };
    _client.onConnected = () {
      connectionChangedCallback(true);
      isConnected = true;
    };
    _client.onAutoReconnect = () {
      connectionChangedCallback(false);
      isConnected = false;
    };
    connectionChangedCallback(false);
    try {
      await _client.connect();
    } on Exception catch (e) {
      print("Connection Failed");
      throw e;
    }
    if (_client.connectionStatus.state == MqttConnectionState.connected) {
      print("Connected to Broker");
      connectionChangedCallback(true);
      isConnected = true;
    } else {
      connectionChangedCallback(false);
      isConnected = false;
    }
  }

  void subscribe(String topic,
      Function(List<MqttReceivedMessage<MqttMessage>> data) listener) {
    _client.subscribe(topic, MqttQos.exactlyOnce);
    print("Subscribed to " + topic);
    _client.updates.listen((event) {
      listener(event);
    });
  }

  void publish(String topic, MqttClientPayloadBuilder payloadBuilder) {
    _client.publishMessage(topic, MqttQos.exactlyOnce, payloadBuilder.payload);
  }
}

//Test function
//void test() {
//  Future<InternetAddress> addr = resolveMDNS("ideapad-510-15ISK.local");
//  addr.then((value) {
//    MQTT mqtt = MQTT(value, () {});
//    Future<void> client = mqtt.connectToBroker();
//    client.then((value) {
//      mqtt.subscribe("test/#", (data) {
//        final MqttPublishMessage receivedMessage = data[0].payload;
//        final message = MqttPublishPayload.bytesToStringAsString(
//            receivedMessage.payload.message);
//        print(data[0].topic);
//        print(message);
//      });
//      MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
//      builder.addString("Response");
//      mqtt.publish("test/10", builder);
//    }, onError: (e) {
//      print(e);
//    });
//  }, onError: (e) {
//    print(e);
//  });
//}
