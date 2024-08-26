import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/presentation/pages/filter_page/filters_cubit.dart';
import 'package:flutter_recruitment_task/presentation/widgets/big_text.dart';
import 'package:flutter_recruitment_task/presentation/widgets/tag.dart';

class FiltersPage extends StatelessWidget {
  const FiltersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BigText('Filters'),
        leading: const CloseButton(),
      ),
      body:
          BlocBuilder<FilterCubit, FilterPageState>(builder: (context, state) {
        return switch (state) {
          LoadedFilterPage() => _LoadedWidget(state: state),
          LoadingFilterPage() => const BigText('Loading...'),
          ErrorFilterPage() => BigText('Error: ${state.error}'),
        };
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Column(children: [
        ElevatedButton(
            child: const Text('Remove filters'),
            onPressed: () {
              print('a');
            }),
        const SizedBox(height: 24),
        ElevatedButton(
            child: const Text('Apply filters'),
            onPressed: () {
              print('b');
            })
      ]),
    );
  }
}

class _LoadedWidget extends StatelessWidget {
  const _LoadedWidget({
    required this.state,
  });

  final LoadedFilterPage state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tagi:'),
          const SizedBox(height: 24),
          Wrap(
            children: [
              ...state.listOfAvailableTags.map((tag) => TagWidget(
                    tag,
                    onSelected: (_) =>
                        context.read<FilterCubit>().updateSelectedTag(tag),
                    selected: state.listOfSelectedTags?.contains(tag) ?? false,
                  )),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Sprzedawca:'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
