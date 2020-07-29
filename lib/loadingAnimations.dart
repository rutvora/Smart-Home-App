import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

ProgressDialog pleaseWait(BuildContext context) {
  ProgressDialog dialog = ProgressDialog(
    context,
    type: ProgressDialogType.Normal,
    isDismissible: false,
  );
  return dialog;
}
