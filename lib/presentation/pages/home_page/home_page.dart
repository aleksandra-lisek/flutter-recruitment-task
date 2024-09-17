import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/cubits/filters_cubit/filters_cubit.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/filter_page/filters_page.dart';
import 'package:flutter_recruitment_task/cubits/filters_cubit/filters_state.dart';
import 'package:flutter_recruitment_task/cubits/home_cubit/home_cubit.dart';
import 'package:flutter_recruitment_task/presentation/widgets/big_text.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
                    builder: (context) {
                      return const FiltersPage();
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
      body: Padding(
        padding: _mainPadding,
        child: BlocListener<FilterCubit, FilterPageState>(
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
                Loaded() => _LoadedWidget(
                    state: state,
                    scrollProductId: scrollProductId,
                  ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _LoadedWidget extends HookWidget {
  const _LoadedWidget({
    required this.state,
    this.scrollProductId,
  });

  final Loaded state;
  final String? scrollProductId;

  List<Product> get _products => state.pages
      .map((page) => page.products)
      .expand((product) => product)
      .toList();

  void _scrollToKey(String? scrollProductId, BuildContext context,
      AutoScrollController controller) async {
    int productIndex =
        _products.indexWhere((element) => element.id == scrollProductId);

    if (productIndex < 0) {
      await context.read<HomeCubit>().getNextPage().then((_) {
        productIndex =
            _products.indexWhere((element) => element.id == scrollProductId);

        _scrollToKey(scrollProductId, context, controller);
      });
    } else {
      controller.scrollToIndex(
        productIndex,
        duration: const Duration(seconds: 1),
        preferPosition: AutoScrollPosition.begin,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = useMemoized(() => AutoScrollController());
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _scrollToKey(scrollProductId, context, scrollController);
      });
      return null;
    }, const []);
    return Column(children: <Widget>[
      Expanded(
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            _ProductsList(products: _products, controller: scrollController),
            if (state.morePagesAvailable) const _GetNextPageButton(),
          ],
        ),
      ),
    ]);
  }
}

class _ProductsList extends StatelessWidget {
  const _ProductsList({required this.products, required this.controller});

  final List<Product> products;
  final AutoScrollController controller;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: products.length,
      itemBuilder: (context, index) => AutoScrollTag(
        controller: controller,
        key: ValueKey(index),
        index: index,
        child: _ProductCard(products[index], index.toString()),
      ),
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(
    this.product,
    this.productIndex,
  );

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
    return SliverToBoxAdapter(
      child: TextButton(
        onPressed: context.read<HomeCubit>().getNextPage,
        child: const BigText('Get next page'),
      ),
    );
  }
}
