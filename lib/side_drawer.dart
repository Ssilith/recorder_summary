// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:recorder_summary/auth/login_page.dart';
import 'package:recorder_summary/providers/auth_provider.dart';
import 'package:recorder_summary/side_drawer_pages/about_app.dart';
import 'package:recorder_summary/side_drawer_pages/contact_us.dart';
import 'package:recorder_summary/widgets/dialogs/my_alert_dialog.dart';
import 'package:recorder_summary/widgets/message.dart';

class SideDrawer extends StatelessWidget {
  final AuthProvider authProvider;
  final VoidCallback onClose;
  const SideDrawer(
      {super.key, required this.authProvider, required this.onClose});

  // log out popup
  _logOut(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
            title: "Log out",
            description: "Are you sure you wanna log out from your account?",
            onPressed: () async {
              await authProvider.signOut();
              Navigator.of(context).pop();
              message(
                  context,
                  'Success',
                  "You have been successfully logged out",
                  SnackbarType.success);
            },
          );
        });
  }

  // delete account popup
  _deleteAccount(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
            title: "Delete account",
            description:
                "Are you sure you wanna delete this account?\nThis action cannot be undone.",
            onPressed: () async {
              await authProvider.deleteUserAccount();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => LoginPage(authProvider: authProvider)));
              message(
                  context,
                  'Success',
                  "The account has been successfully deleted",
                  SnackbarType.success);
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: SingleChildScrollView(
            child: Column(children: [
      // logo
      const Padding(
        padding: EdgeInsets.only(top: 20, bottom: 5),
        child: SizedBox(
            height: 150,
            child: Center(child: Image(image: AssetImage("assets/logo.png")))),
      ),
      // user email
      Text(
        authProvider.user!.email!,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 15),
      ChangeBackgroundColor(
        children: [
          // logout button
          DrawerTile(
              onTap: () => _logOut(context),
              text: "Logout",
              iconData: MdiIcons.logout),
          // delete account button
          DrawerTile(
              onTap: () => _deleteAccount(context),
              text: "Delete account",
              iconData: Icons.no_accounts),
        ],
      ),
      ChangeBackgroundColor(
        children: [
          // about app button
          DrawerTile(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AboutApp()));
              onClose();
            },
            text: "About app",
            iconData: Icons.info,
          ),
          // contact us button
          DrawerTile(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ContactUs()));
              onClose();
            },
            text: "Contact us",
            iconData: MdiIcons.phone,
          ),
        ],
      ),
    ])));
  }
}

class DrawerTile extends StatelessWidget {
  final String text;
  final Color? color;
  final IconData iconData;
  final VoidCallback onTap;
  const DrawerTile(
      {super.key,
      required this.onTap,
      required this.text,
      required this.iconData,
      this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(iconData, color: Theme.of(context).colorScheme.primary),
      title: Text(text,
          style: TextStyle(
              fontWeight: FontWeight.w500, color: color ?? Colors.white)),
      onTap: onTap,
    );
  }
}

class ChangeBackgroundColor extends StatelessWidget {
  final List<Widget> children;
  const ChangeBackgroundColor({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onInverseSurface,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}
