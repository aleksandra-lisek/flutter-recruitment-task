import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/filter_page/filters_bloc.dart';
import 'package:flutter_recruitment_task/presentation/pages/filter_page/filters_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/filter_page/filters_state.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/home_cubit.dart';
import 'package:flutter_recruitment_task/presentation/widgets/big_text.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const _mainPadding = EdgeInsets.all(16.0);

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.scrollProductId});

  final String? scrollProductId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BigText('Products'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: TextButton(
              child: const Row(
                children: [
                  Icon(Icons.filter_list),
                  SizedBox(width: 5),
                  Text('Filtry')
                ],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FiltersPage(),
                  ),
                );
              },
            ),
          )
        ],
      ),
      body: Padding(
        padding: _mainPadding,
        child: BlocListener<FilterBloc, FilterPageState>(
          listener: (context, state) {
            if (state is LoadedFilterPage &&
                state.areProductsFiltered == true) {
              context
                  .read<HomeCubit>()
                  .getFilteredPages(state.filteredProducts);
            }
          },
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return switch (state) {
                Error() => BigText('Error: ${state.error}'),
                Loading() => const Center(child: CircularProgressIndicator()),
                NoProducts() => const BigText('No products'),
                Loaded() =>
                  _LoadedWidget(state: state, scrollProductId: scrollProductId),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _LoadedWidget extends StatelessWidget {
  const _LoadedWidget({
    required this.state,
    this.scrollProductId,
  });

  final Loaded state;
  final String? scrollProductId;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Expanded(
        child: _ProductsList(state: state, scrollProductId: scrollProductId),
      ),
      const Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Column(
          children: <Widget>[
            _GetNextPageButton(),
          ],
        )
      ])
    ]);
  }
}

class _ProductsList extends StatefulWidget {
  const _ProductsList({required this.state, this.scrollProductId});

  final Loaded state;
  final String? scrollProductId;

  @override
  State<_ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<_ProductsList> {
  late ItemScrollController _scrollController;
  late List<Product> _products;

  @override
  void initState() {
    _scrollController = ItemScrollController();
    _products = widget.state.pages
        .map((page) => page.products)
        .expand((product) => product)
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollProductId != null &&
          widget.scrollProductId!.isNotEmpty) {
        _scrollToKey(widget.scrollProductId!);
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _ProductsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    _products = widget.state.pages
        .map((page) => page.products)
        .expand((product) => product)
        .toList();
  }

  void _scrollToKey(String scrollProductId) async {
    int productIndex =
        _products.indexWhere((element) => element.id == scrollProductId);

    if (productIndex < 0) {
      await context.read<HomeCubit>().getNextPage().then((_) {
        productIndex =
            _products.indexWhere((element) => element.id == scrollProductId);

        _scrollToKey(scrollProductId);
      });
    } else {
      await _scrollController.scrollTo(
        index: productIndex,
        duration: const Duration(seconds: 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.separated(
      key: const Key('ScrollableList'),
      itemScrollController: _scrollController,
      itemCount: _products.length,
      itemBuilder: (context, index) =>
          _ProductCard(_products[index], index.toString()),
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(this.product, this.productIndex);

  final Product product;
  final String productIndex;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BigText(product.name),
          Text(product.id),
          Text(productIndex),
          _Tags(product: product),
        ],
      ),
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags({
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Wrap(children: [...product.tags.map(_TagWidget.new)]);
  }
}

class _TagWidget extends StatefulWidget {
  const _TagWidget(this.tag);

  final Tag tag;

  @override
  State<_TagWidget> createState() => _TagWidgetState();
}

class _TagWidgetState extends State<_TagWidget> {
  late MaterialColor _color;
  final List<MaterialColor> _possibleColors = Colors.primaries;

  @override
  void initState() {
    _color = _possibleColors[Random().nextInt(_possibleColors.length)];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Chip(
        color: MaterialStateProperty.all(_color),
        label: Text(widget.tag.label),
      ),
    );
  }
}

class _GetNextPageButton extends StatelessWidget {
  const _GetNextPageButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: context.read<HomeCubit>().getNextPage,
      child: const BigText('Get next page'),
    );
  }
}
