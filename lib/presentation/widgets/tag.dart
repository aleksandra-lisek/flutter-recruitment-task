import 'package:flutter/material.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/utils/hex_color.dart';

class TagWidget extends StatelessWidget {
  const TagWidget(this.tag,
      {super.key, this.onSelected, this.onDeleted, this.selected = false});

  final Tag tag;
  final Function(bool)? onSelected;
  final Function()? onDeleted;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        onSelected: onSelected,
        selected: selected,
        color: MaterialStateProperty.all(HexColor(tag.color)),
        label: Text(
          tag.label,
          style: TextStyle(
            color: HexColor(tag.labelColor),
          ),
        ),
      ),
    );
  }
}
