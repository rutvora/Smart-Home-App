import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalVariables {
  // Shared preferences structure:
  // deviceName: String
  // rooms: JSON object with the following structure:
  //        {"room name": {"toggles": [{"name": "name", "pin": val, "type": "bulb"}], "dimmers": [{"name": "name", "pin": val, "type": "dimmable LED"}]}}
  static SharedPreferences prefs;
  static String currentRoom;
  static ProgressDialog pleaseWait;
  static Map rooms = Map();
}
