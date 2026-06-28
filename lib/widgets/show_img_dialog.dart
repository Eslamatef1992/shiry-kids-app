import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shiry_kids_app/theme/app_colors.dart';

import 'network_image.dart';

class ShowImgDialog extends StatelessWidget {
  const ShowImgDialog({super.key, required this.images, required this.isCoupon});
  final List<String> images;
  final bool isCoupon;

  Future<void> shareImage(String imageUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/shared_image.png');
      debugPrint(imageUrl);
      final response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      await file.writeAsBytes(response.data);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 300,
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
                    padding: const EdgeInsets.only(bottom: 20,),
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 20,),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(width: 1.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: ()async{
                             await shareImage(img);
                            },
                            child: const Icon(Icons.share,color: AppColors.primary,),

                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: isCoupon
                                ? Image.network('https://back.sherykids.com$img', width: 220, height: 220, fit: BoxFit.contain)
                                : smartImage(img, width: 220, height: 220, fit: BoxFit.contain),
                          ),
                        ],
                      ),
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
