import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/filter_page/filters_cubit.dart';
import 'package:flutter_recruitment_task/presentation/pages/filter_page/filters_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/filter_page/filters_state.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/home_cubit.dart';
import 'package:flutter_recruitment_task/presentation/widgets/big_text.dart';
import 'package:flutter_recruitment_task/presentation/widgets/tag.dart';

const _mainPadding = EdgeInsets.all(16.0);

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.productId});

  final String? productId;

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
                  Text('Filters')
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
          listener: (context, fs) {
            final currentState = (fs as LoadedFilterPage);
            if (currentState.areProductsFiltered == true) {
              context
                  .read<HomeCubit>()
                  .getFilteredPages(currentState.filteredProducts);
            }
          },
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return switch (state) {
                Error() => BigText('Error: ${state.error}'),
                Loading() => const BigText('Loading...'),
                NoProducts() => const BigText('No products'),
                Loaded() => _LoadedWidget(state: state),
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
  });

  final Loaded state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _ProductsSliverList(state: state),
        const _GetNextPageButton(),
      ],
    );
  }
}

class _ProductsSliverList extends StatelessWidget {
  const _ProductsSliverList({required this.state});

  final Loaded state;

  @override
  Widget build(BuildContext context) {
    final products = state.pages
        .map((page) => page.products)
        .expand((product) => product)
        .toList();

    return SliverList.separated(
      itemCount: products.length,
      itemBuilder: (context, index) => _ProductCard(products[index]),
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BigText(product.name),
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
    return Wrap(children: [...product.tags.map(TagWidget.new)]);
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
