import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

sealed class FilterPageState {
  const FilterPageState();
}

class LoadingFilterPage extends FilterPageState {
  const LoadingFilterPage();
}

class LoadedFilterPage extends FilterPageState {
  LoadedFilterPage(
      {required this.listOfAvailableTags, required this.listOfSelectedTags});

  final List<Tag> listOfAvailableTags;
  final List<Tag>? listOfSelectedTags;

  LoadedFilterPage copyWith({
    List<Tag>? listOfAvailableTags,
    List<Tag>? listOfSelectedTags,
  }) {
    return LoadedFilterPage(
      listOfAvailableTags: listOfAvailableTags ?? this.listOfAvailableTags,
      listOfSelectedTags: listOfSelectedTags ?? this.listOfSelectedTags,
    );
  }
}

class ErrorFilterPage extends FilterPageState {
  const ErrorFilterPage({required this.error});

  final dynamic error;
}

class FilterCubit extends Cubit<FilterPageState> {
  FilterCubit(this._productsRepository)
      : super(
            LoadedFilterPage(listOfAvailableTags: [], listOfSelectedTags: []));

  final ProductsRepository _productsRepository;
  final List<ProductsPage> _pages = [];

  Future<List<Product>> _getListOfAllProducts() async {
    final totalPages = _pages.lastOrNull?.totalPages;
    try {
      final List<Future<ProductsPage>> pageFutures = List.generate(
        totalPages ?? 1,
        (index) => _productsRepository
            .getProductsPage(GetProductsPage(pageNumber: index + 1)),
      );

      final pages = await Future.wait(pageFutures);
      final products = pages.expand((page) => page.products).toList();

      return products;
    } catch (e) {
      print('Failed to get all of the products: $e');
      return [];
    }
  }

  Future<void> getListOfAvailableTags() async {
    try {
      final products = await _getListOfAllProducts();

      final uniqueTags =
          products.expand((product) => product.tags).toSet().toList();

      emit((state as LoadedFilterPage)
          .copyWith(listOfAvailableTags: uniqueTags));
    } catch (e) {
      print('Failed to get all tags: $e');
    }
  }

  Future<void> updateSelectedTag(Tag tag) async {
    try {
      final currentState = state as LoadedFilterPage;
      final List<Tag>? updatedTags = currentState.listOfSelectedTags;
      if (updatedTags?.contains(tag) != null &&
          updatedTags?.contains(tag) == true) {
        updatedTags?.removeWhere((element) => element.tag == tag.tag);
      } else {
        updatedTags?.add(tag);
      }

      emit((state as LoadedFilterPage)
          .copyWith(listOfSelectedTags: updatedTags));
    } catch (e) {
      print('Failed to get all tags: $e');
    }
  }

  // aply filters
  // remove filters
}
