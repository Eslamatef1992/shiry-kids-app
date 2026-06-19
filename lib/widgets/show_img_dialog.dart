import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';



class ShowImgDialog extends StatelessWidget {
  const ShowImgDialog({super.key, required this.img, required this.isCoupon});
  final String img ;
  final bool  isCoupon ;

  Uint8List imageFromBase64String(String base64String) {
    // حذف الجزء data:image/png;base64,
    final String pureBase64 =
        base64String.split(',').last;

    return base64Decode(pureBase64);
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          isCoupon? Image.memory(imageFromBase64String(img)) : Image.network(img),
          IconButton(icon: const Icon(Icons.close,size: 30,color: Colors.white,),
          onPressed: ()=> Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
