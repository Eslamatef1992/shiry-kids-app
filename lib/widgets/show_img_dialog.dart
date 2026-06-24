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
      child: SizedBox(
        width: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 3,left: 5,right: 5),
                child: IconButton(icon: const Icon(Icons.close,size: 30,color: Colors.black87,),
                  onPressed: ()=> Navigator.pop(context),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: images.map((img) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: isCoupon
                          ? Image.network('https://back.sherykids.com/$img', width: 220, height: 220, fit: BoxFit.contain)
                          : smartImage(img, width: 220, height: 220, fit: BoxFit.contain),
                    ),
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
