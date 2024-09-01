import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:recorder_summary/side_drawer_pages/app_bar_scaffold.dart';
import 'package:recorder_summary/widgets/message.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
        title: "Contact us",
        body: ListView.builder(
            itemCount: _titles.length,
            shrinkWrap: true,
            itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ContactBox(
                      title: _titles[index],
                      description: _descriptions[index],
                      iconData: _icons[index],
                      buttonTitle: _buttonTitles[index],
                      url: _urls[index]),
                )));
  }
}

class ContactBox extends StatelessWidget {
  final String title;
  final String description;
  final IconData iconData;
  final String url;
  final String buttonTitle;
  const ContactBox(
      {super.key,
      required this.title,
      required this.description,
      required this.iconData,
      required this.url,
      required this.buttonTitle});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 150,
          margin: const EdgeInsets.only(top: 40),
          padding: const EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // title
              Text(
                title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 5),
              // description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const Spacer(),
              // bottom bar
              Padding(
                padding: EdgeInsets.zero,
                child: InkWell(
                  onTap: () async {
                    if (url != "") {
                      _launchUrl(url);
                    } else {
                      message(context, "Failure", "Cannot launch url");
                    }
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12)),
                        color: Theme.of(context).colorScheme.primary),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          buttonTitle,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).scaffoldBackgroundColor),
                        ),
                        const SizedBox(width: 2),
                        Icon(MdiIcons.arrowRight,
                            size: 21,
                            weight: 100,
                            color: Theme.of(context).scaffoldBackgroundColor)
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        // icon
        Positioned(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData,
                size: 40, color: Theme.of(context).scaffoldBackgroundColor),
          ),
        ),
      ],
    );
  }

  // launch url
  _launchUrl(String url) async {
    Uri urlAddress = Uri.parse(url);
    if (!await launchUrl(urlAddress)) {
      throw Exception('Cannot launch $urlAddress');
    }
  }
}

// title of container
final List<String> _titles = [
  'Phone number',
  'Email',
  'LinkedIn',
];

// description of container
final List<String> _descriptions = [
  '+48 739 971 584',
  'k.hajduk.wroclaw@gmail.com',
  'Katarzyna Hajduk',
];

// icons of container
final List<IconData> _icons = [
  Icons.call,
  Icons.mail,
  FontAwesomeIcons.linkedin,
];

// container urls
final List<String> _urls = [
  'tel:+48739971584',
  'mailto:k.hajduk.wroclaw@gmail.com',
  'https://www.linkedin.com/in/katarzyna-hajduk-73b78026b/'
];

// button title
final List<String> _buttonTitles = [
  'Call',
  'Email',
  'Check',
];
