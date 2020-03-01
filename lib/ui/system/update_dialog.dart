import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/web_client.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/ui/app/loading_indicator.dart';
import 'package:invoiceninja_flutter/utils/dialogs.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';

class UpdateDialog extends StatefulWidget {
  @override
  _UpdateDialogState createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    return AlertDialog(
      title: Text(localization.updateAvailable),
      content: _isLoading
          ? LoadingIndicator(height: 50)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(localization.aNewVersionIsAvailable),
                SizedBox(height: 20),
                Text('• ${localization.currentVersion}: v$kAppVersion'),
                //Text('• ${localization.latestVersion}: v???'),
              ],
            ),
      actions: <Widget>[
        if (!_isLoading) ...[
          FlatButton(
            child: Text(localization.cancel.toUpperCase()),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(localization.updateNow.toUpperCase()),
            onPressed: () {
              updateApp(context);
            },
          ),
        ]
      ],
    );
  }

  void updateApp(BuildContext context) {
    setState(() => _isLoading = true);

    final state = StoreProvider.of<AppState>(context).state;
    final credentials = state.credentials;
    final webClient = WebClient();
    const url = '/self-update';
    webClient.post(url, credentials.token).then((dynamic response) {
      print('DONE: $response');
      setState(() => _isLoading = false);
    }).catchError((dynamic error) {
      showErrorDialog(context: context, message: '$error');
      setState(() => _isLoading = false);
    });
  }
}
