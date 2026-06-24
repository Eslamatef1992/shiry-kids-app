import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'network_image.dart';

class ShowImgDialog extends StatelessWidget {
  const ShowImgDialog({super.key, required this.images, required this.isCoupon});
  final List<String> images;
  final bool isCoupon;



  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3,left: 10,right: 10),
            child: IconButton(icon: const Icon(Icons.close,size: 30,color: Colors.black87,),
              onPressed: ()=> Navigator.pop(context),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: images.map((img) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isCoupon
                      ? Image.network('https://back.sherykids.com/$img', width: 150, height: 150, fit: BoxFit.contain)
                      : smartImage(img, width: 150, height: 150, fit: BoxFit.contain),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
