import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppSelector extends StatefulWidget {
  Function(String package) callback;

  AppSelector(this.callback);

  @override
  _AppSelectorState createState() => _AppSelectorState();
}

class _AppSelectorState extends State<AppSelector> {
  bool checkSystem = true;
  bool checkLaunch = true;
  List<Application> apps;
  String search;
  String selected;

  @override
  void initState() {
    getApps();
    super.initState();
  }

  void getApps() {
    DeviceApps.getInstalledApplications(
            onlyAppsWithLaunchIntent: !checkLaunch,
            includeSystemApps: !checkSystem,
            includeAppIcons: true)
        .then((value) => setState(() => apps = value));
  }

  @override
  Widget build(BuildContext context) {
    List<Application> _apps = [];
    if (search == null || search.length == 0)
      _apps = apps;
    else
      apps.forEach((element) {
        if (element.packageName.contains(search) ||
            element.appName.contains(search)) _apps.add(element);
      });

    // print(selected);

    return AlertDialog(
//      title: Text("Type some text asdf asdfhba sdfhbfipsadfhbapsdihfbp"),
      content: Container(
        width: double.maxFinite,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            CheckboxListTile(
              title: Text("Hide system apps"),
              value: checkSystem,
              onChanged: (value) => setState(() {
                checkSystem = value;
                getApps();
              }),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: Text("Hide non-launchable apps"),
              value: checkLaunch,
              onChanged: (value) => setState(() {
                checkLaunch = value;
                getApps();
              }),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            TextField(
              onChanged: (value) => setState(() => search = value),
              decoration: InputDecoration(hintText: 'Search'),
            ),
            _apps != null
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: _apps.length,
                    physics: ScrollPhysics(),
                    itemBuilder: (context, item) {
                      ApplicationWithIcon app = _apps[item];
                      return ListTile(
                        leading: Image.memory(app.icon),
                        title: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(app.appName)),
                        subtitle: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              app.packageName,
                            )),
                        onTap: () => setState(() => selected = app.packageName),
                        selected: selected == app.packageName,
                      );
                    })
                : Center(
                    child: Container(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator()))
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Close"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Send"),
          onPressed: selected == null ? null : () {
            Navigator.of(context).pop();
            widget.callback(selected);
          },
        ),
      ],
    );
  }
}