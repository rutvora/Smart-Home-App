import 'dart:async';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:multicast_dns/multicast_dns.dart';

Future<InternetAddress> resolveMDNS() async {
  // Create rawDatagramSocketFactory with reusePort set as false to avoid errors in Android
  var factory =
      (dynamic host, int port, {bool reuseAddress, bool reusePort, int ttl}) {
    return RawDatagramSocket.bind(host, port,
        reuseAddress: true, reusePort: false, ttl: ttl);
  };
  //Create MDnsClient with the given factory
  final client = MDnsClient(rawDatagramSocketFactory: factory);

  const String hostName = 'ideapad-510-15ISK.local';
  InternetAddress broker; //The value to be returned
  // Start the client with default options.
  await client.start();
  await for (IPAddressResourceRecord ptr
      in client.lookup<IPAddressResourceRecord>(
          ResourceRecordQuery.addressIPv4(hostName))) {
    broker = ptr.address;
    print(ptr.address);
    print('\n');
  }
  client.stop();
  if (broker == null) throw Exception("Broker not Found");
  return broker;
}

class MQTT {
  InternetAddress _host;
  MqttServerClient client;

  MQTT(InternetAddress host) {
    _host = host;
  }

  Future<void> connectToBroker() async {
    print("Connecting to Broker");
    final MqttServerClient mqttServerClient =
        MqttServerClient(_host.address, 'phone');
    try {
      await mqttServerClient.connect();
    } on Exception catch (e) {
      print("Connection Failed");
      throw e;
    }
    if (mqttServerClient.connectionStatus.state ==
        MqttConnectionState.connected) {
      print("Connected to Broker");
      client = mqttServerClient;
      return true;
    } else {
      throw Exception("Connection Failed!");
    }
  }

  void subscribe(String topic,
      Function(List<MqttReceivedMessage<MqttMessage>> data) listener) {
    client.subscribe(topic, MqttQos.exactlyOnce);
    print("Subscribed to " + topic);
    client.updates.listen((event) {
      listener(event);
    });
  }

  void publish(String topic, MqttClientPayloadBuilder payloadBuilder) {
    client.publishMessage(topic, MqttQos.exactlyOnce, payloadBuilder.payload);
  }
}

//Sample post function
//post("URL", body: "body");

void test() {
  Future<InternetAddress> addr = resolveMDNS();
  addr.then((value) {
    MQTT mqtt = MQTT(value);
    Future<void> client = mqtt.connectToBroker();
    client.then((value) {
      mqtt.subscribe("test/#", (data) {
        final MqttPublishMessage receivedMessage = data[0].payload;
        final message = MqttPublishPayload.bytesToStringAsString(
            receivedMessage.payload.message);
        print(data[0].topic);
        print(message);
      });
      MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString("Response");
      mqtt.publish("test/10", builder);
    }, onError: (e) {
      print(e);
    });
  }, onError: (e) {
    print(e);
  });
}
