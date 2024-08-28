import 'package:bloc/bloc.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

sealed class HomeState {
  const HomeState();
}

class Loading extends HomeState {
  const Loading();
}

class Loaded extends HomeState {
  const Loaded({required this.pages});

  final List<ProductsPage> pages;
}

class NoProducts extends HomeState {
  const NoProducts();
}

class Error extends HomeState {
  const Error({required this.error});

  final dynamic error;
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._productsRepository) : super(const Loading());

  final ProductsRepository _productsRepository;
  final List<ProductsPage> _pages = [];
  var _param = GetProductsPage(pageNumber: 1);

  Future<void> getFilteredPages(List<Product>? filteredProducts) async {
    try {
      final List<List<Product>> listOfProducts =
          filteredProducts == null || filteredProducts.isEmpty
              ? []
              : [
                  for (int i = 0; i < filteredProducts.length; i += 20)
                    filteredProducts.skip(i).take(20).toList()
                ];
      final totalPages = listOfProducts.length;
      final List<ProductsPage> listOfFilteredProductPages = listOfProducts.fold(
          [],
          (previousValue, element) => [
                ProductsPage(
                    totalPages: totalPages,
                    pageNumber: listOfProducts.indexOf(element),
                    pageSize: 20,
                    products: element)
              ]);
      _pages.replaceRange(0, _pages.length, listOfFilteredProductPages);
      listOfProducts.isEmpty
          ? emit(const NoProducts())
          : emit(Loaded(pages: listOfFilteredProductPages));
    } catch (e) {
      emit(Error(error: e));
    }
  }

  Future<void> getNextPage() async {
    try {
      final totalPages = _pages.lastOrNull?.totalPages;
      if (totalPages != null && _param.pageNumber > totalPages) return;
      final newPage = await _productsRepository.getProductsPage(_param);
      _param = _param.increasePageNumber();
      _pages.add(newPage);
      emit(Loaded(pages: _pages));
    } catch (e) {
      emit(Error(error: e));
    }
  }
}
