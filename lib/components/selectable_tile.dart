import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:selectable_container/selectable_container.dart';

class SelectableTile extends StatelessWidget {
  const SelectableTile(
      {Key? key,
      this.size = 80.0,
      // required this.image,
      required this.imageUrl,
      required this.label,
      this.tooltip = '',
      required this.onTap,
      required this.selected})
      : super(key: key);
  final double size;

  // final ImageProvider image;
  final String imageUrl;
  final String label;
  final String tooltip;
  final Function() onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SelectableContainer(
      onValueChanged: (isSelected) => onTap(),
      selected: selected,
      iconAlignment: Alignment.topLeft,
      borderRadius: 5.0,
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: size,
          child: Column(
            children: [
              if (imageUrl.startsWith('http'))
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) {
                    return const Icon(Icons.error);
                  },
                )
              else
                Image(image: AssetImage(imageUrl)),
              // Image(
              //   image: image,
              //   width: size,
              //   height: size,
              // ),
              Text(
                label,
                overflow: TextOverflow.visible,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
