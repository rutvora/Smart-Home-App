import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'network.dart';

class GlobalVariables {
  // Shared preferences structure:
  // deviceName: String
  // rooms: JSON object with the following structure:
  //        '{"hostname": {"name":"custom room name", "toggles": [{"name": "name", "pin": 1, "type": "bulb"}, {"name": "name", "pin": 2, "type": "bulb"}], "dimmers": [{"name": "name", "pin": 2, "type": "dimmable LED"}]}}'
  static SharedPreferences prefs;
  static String currentRoom;
  static ProgressDialog pleaseWait;
  static Map rooms = Map();
  static MQTT localBroker;
}
