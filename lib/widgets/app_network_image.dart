import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String placeholder;
  final Alignment alignment;
  final ImageRepeat repeat;
  final Color? color;
  final BlendMode? colorBlendMode;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder = 'assets/images/banners/banner_1.png',
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.color,
    this.colorBlendMode,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return Image.asset(
        placeholder,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        color: color,
        colorBlendMode: colorBlendMode,
      );
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          placeholder,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          repeat: repeat,
          color: color,
          colorBlendMode: colorBlendMode,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC9A227)),
              ),
            ),
          ),
        );
      },
    );
  }
}
