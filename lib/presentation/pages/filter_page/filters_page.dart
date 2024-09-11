import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/blocs/filter_bloc/filters_events.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/blocs/filter_bloc/filters_bloc.dart';
import 'package:flutter_recruitment_task/blocs/filter_bloc/filters_state.dart';
import 'package:flutter_recruitment_task/presentation/widgets/big_text.dart';
import 'package:flutter_recruitment_task/utils/hex_color.dart';

class FiltersPage extends StatelessWidget {
  const FiltersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BigText('Filtry'),
        leading: const CloseButton(),
      ),
      body: BlocBuilder<FilterBloc, FilterPageState>(builder: (context, state) {
        return switch (state) {
          LoadedFilterPage() => _Filters(state: state),
          LoadingFilterPage() => const BigText('Loading...'),
          ErrorFilterPage() => BigText('Error: ${state.error}'),
        };
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Wyczyść filtry'),
              onPressed: () =>
                  context.read<FilterBloc>().add(FetchDataForFilters()),
            ),
            const SizedBox(width: 24),
            ElevatedButton(
                child: const Text('Pokaz produkty'),
                onPressed: () {
                  context.read<FilterBloc>().add(ApplyFiltersEvent());
                  Navigator.maybePop(context);
                }),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.state,
  });

  final LoadedFilterPage state;

  @override
  Widget build(BuildContext context) {
    final List<String> listOfAvailableSellers =
        state.listOfAvailableSellers ?? [];
    return Container(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wybierz interecujące Cię tagi:'),
          const SizedBox(height: 24),
          state.listOfAvailableTags != null &&
                  state.listOfAvailableTags!.isNotEmpty
              ? Wrap(
                  children: [
                    ...state.listOfAvailableTags!.map((tag) => _TagWidget(
                          tag,
                          onSelected: (_) =>
                              BlocProvider.of<FilterBloc>(context)
                                  .add(UpdateSelectedTagEvent(tag)),
                          selected:
                              state.listOfSelectedTags?.contains(tag) ?? false,
                        )),
                  ],
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text('Wybierz sprzedawcę:'),
              const SizedBox(width: 24),
              listOfAvailableSellers.isNotEmpty
                  ? SizedBox(
                      width: 140,
                      child: DropdownButton(
                        enableFeedback: true,
                        value: state.selectedSeller,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        items: [
                          ...listOfAvailableSellers.map(
                            (e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e),
                            ),
                          )
                        ],
                        onChanged: (value) =>
                            BlocProvider.of<FilterBloc>(context)
                                .add(UpdateSelectedSellersEvent(value)),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagWidget extends StatelessWidget {
  const _TagWidget(
    this.tag, {
    this.onSelected,
    this.selected = false,
  });

  final Tag tag;
  final Function(bool)? onSelected;

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
