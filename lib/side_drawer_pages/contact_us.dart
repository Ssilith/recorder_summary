import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recorder_summary/app_bar_scaffold.dart';
import 'package:recorder_summary/widgets/message.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final List<String> _titles = [
    'Phone number',
    'Email',
    'LinkedIn',
  ];

  final List<String> _descriptions = [
    '+48 739 971 584',
    'k.hajduk.wroclaw@gmail.com',
    'Katarzyna Hajduk',
  ];

  final List<IconData> _icons = [
    Icons.call,
    Icons.mail,
    FontAwesomeIcons.linkedin,
  ];

  final List<String> _urls = [
    'tel:+48739971584',
    'mailto:k.hajduk.wroclaw@gmail.com',
    'https://www.linkedin.com/in/katarzyna-hajduk-73b78026b/'
  ];

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
        title: "Contact us",
        body: ListView.builder(
            itemCount: _titles.length,
            shrinkWrap: true,
            itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: ContactContainer(
                      title: _titles[index],
                      icon: _icons[index],
                      description: _descriptions[index],
                      url: _urls[index]),
                )));
  }
}

class ContactContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String url;
  const ContactContainer(
      {super.key,
      required this.icon,
      required this.title,
      required this.description,
      required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onInverseSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 38.0,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 3),
                      VerticalDivider(
                        thickness: 1,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            description,
                            style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        onTap: () async {
          if (url != "") {
            _launchUrl(url);
          } else {
            message(context, "Failure", "Cannot launch url");
          }
        });
  }

  // launch url
  _launchUrl(String url) async {
    Uri urlAddress = Uri.parse(url);
    if (!await launchUrl(urlAddress)) {
      throw Exception('Cannot launch $urlAddress');
    }
  }
}
