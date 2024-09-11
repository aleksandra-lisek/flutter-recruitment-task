import 'package:bloc/bloc.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';
import 'package:equatable/equatable.dart';

sealed class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is List<ProductsPage> && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class Loading extends HomeState {
  const Loading();
}

class Loaded extends HomeState {
  const Loaded({required this.pages});

  final List<ProductsPage> pages;

  @override
  List<Object?> get props => [pages];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is List<ProductsPage> &&
          runtimeType == other.runtimeType &&
          pages == other;

  @override
  int get hashCode => pages.hashCode;
}

class NoProducts extends HomeState {
  const NoProducts();
}

class Error extends HomeState {
  const Error({required this.error});

  final dynamic error;

  @override
  List<Object?> get props => [error];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._productsRepository) : super(const Loading());

  final ProductsRepository _productsRepository;
  final List<ProductsPage> _pages = [];
  var _param = GetProductsPage(pageNumber: 1);

  void getLoadingPage() {
    emit(const Loading());
  }

  Future<void> getFilteredPages(List<Product>? filteredProducts) async {
    emit(const Loading());
    try {
      List<Map<String, dynamic>> listOfFilteredProducts =
          filteredProducts == null || filteredProducts.isEmpty
              ? []
              : [
                  for (int i = 0; i < filteredProducts.length; i += 20)
                    {
                      'index': i ~/ 20,
                      'products': filteredProducts.skip(i).take(20).toList()
                    }
                ];
      final totalPages = listOfFilteredProducts.length;
      final List<ProductsPage> listOfFilteredProductPages =
          listOfFilteredProducts.fold([], (previousValue, element) {
        return [
          ...previousValue,
          ProductsPage(
            totalPages: totalPages,
            pageNumber: element['index'] + 1,
            pageSize: 20,
            products: element['products'],
          )
        ];
      });
      _pages.replaceRange(0, _pages.length, listOfFilteredProductPages);
      listOfFilteredProducts.isEmpty
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
