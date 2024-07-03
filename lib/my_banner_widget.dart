import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyBannerWidget extends StatelessWidget {
  final String imageUrl;
  final String linkUrl;
  final String label;

  const MyBannerWidget({
    required this.imageUrl,
    required this.linkUrl,
    required this.label,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _launchURL(linkUrl);
      },
      child: Column(
        children: [
          Image.network(
            imageUrl,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false); // forceSafariVC false로 설정
    } else {
      throw 'Could not launch $url';
    }
  }
}
