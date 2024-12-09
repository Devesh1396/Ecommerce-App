import 'package:ecom_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/theme_bloc/themebloc.dart';

class SettingsUi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text("Dark Mode"),
            trailing: Switch(
              activeColor: Theme.of(context).primaryColor,
              inactiveTrackColor: Colors.grey[300],
              value: context.read<ThemeBloc>().state.themeData == AppTheme.darkTheme,
              onChanged: (value) {
                context.read<ThemeBloc>().toggleTheme();
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.language),
            title: Text("Language"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to Language Settings Screen
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notifications"),
            trailing: Switch(
              activeColor: Theme.of(context).primaryColor,
              inactiveTrackColor: Colors.grey[300],
              value: true, // Placeholder for notifications toggle
              onChanged: (value) {
                // Implement toggle for notifications
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Privacy & Security"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to Privacy & Security Screen
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.help),
            title: Text("Help & Support"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to Help & Support Screen
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text("About App"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to About App Screen
            },
          ),
        ],
      ),
    );
  }
}
