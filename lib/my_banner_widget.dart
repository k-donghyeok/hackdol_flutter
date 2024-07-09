import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyBannerWidget extends StatelessWidget {
  final String assetImagePath;
  final String linkUrl;
  final String label;

  const MyBannerWidget({
    required this.assetImagePath,
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            assetImagePath,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            width: double.infinity,
            color: Colors.black54, // 배경색 및 투명도 설정
            padding: EdgeInsets.all(8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white, // 글자색 설정
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
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
