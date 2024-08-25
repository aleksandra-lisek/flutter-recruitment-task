import 'package:flutter/material.dart';
import 'package:flutter_recruitment_task/presentation/widgets/big_text.dart';

class FiltersPage extends StatelessWidget {
  const FiltersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BigText('Filters'),
        leading: const BackButton(),
      ),
    );
  }
}
