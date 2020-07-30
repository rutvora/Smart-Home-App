import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

ProgressDialog pleaseWait(BuildContext context,
    [String message = "Please wait..."]) {
  ProgressDialog dialog = ProgressDialog(
    context,
    type: ProgressDialogType.Normal,
    isDismissible: false,
  );
  dialog.style(message: message);
  return dialog;
}
