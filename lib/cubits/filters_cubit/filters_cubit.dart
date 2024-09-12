import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/cubits/filters_cubit/filters_state.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

class FilterCubit extends Cubit<FilterPageState> {
  final ProductsRepository _productsRepository;
  List<Product> _filteredProducts = [];

  FilterCubit(
    this._productsRepository,
  ) : super(
          const LoadingFilterPage(),
        ) {
    fetchDataForFilters();
  }

  Future<List<Product>> _getListOfAllProducts() async {
    try {
      final ProductsPage newPage = await _productsRepository
          .getProductsPage(GetProductsPage(pageNumber: 1));

      final List<Future<ProductsPage>> pageFutures = List.generate(
        newPage.totalPages,
        (index) => _productsRepository
            .getProductsPage(GetProductsPage(pageNumber: index + 1)),
      );

      final pages = await Future.wait(pageFutures);
      final products = pages.expand((page) => page.products).toList();

      return products;
    } catch (e) {
      return [];
    }
  }

  Future<void> fetchDataForFilters() async {
    try {
      emit(await _onLoadAvailableFilters());
    } catch (e) {
      emit(ErrorFilterPage(error: e));
    }
  }

  Future<FilterPageState> _onLoadAvailableFilters() async {
    try {
      _filteredProducts = await _getListOfAllProducts();
      final uniqueTags =
          _filteredProducts.expand((product) => product.tags).toSet().toList();
      final sellers = _filteredProducts
          .map((product) => product.offer.sellerName)
          .toSet()
          .toList();

      return LoadedFilterPage().copyWith(
        listOfAvailableTags: uniqueTags,
        listOfAvailableSellers: sellers,
        avaialbleProducts: _filteredProducts.length,
      );
    } catch (e) {
      return ErrorFilterPage(error: e);
    }
  }

  Future<void> updateSelectedTag(Tag tag) async {
    try {
      if (state is LoadedFilterPage) {
        final currentState = state as LoadedFilterPage;
        final List<Tag> updatedTags = currentState.listOfSelectedTags ?? [];

        if (updatedTags.contains(tag)) {
          updatedTags.removeWhere((element) => element.tag == tag.tag);
        } else {
          updatedTags.add(tag);
        }

        emit(currentState.copyWith(
          listOfSelectedTags: updatedTags,
          avaialbleProducts: _filteredProducts.length,
        ));
        _updateAmountOfAvailableProducts();
      }
    } catch (e) {
      emit(ErrorFilterPage(error: e));
    }
  }

  Future<void> updateSelectedSellers(String? sellerId) async {
    try {
      if (state is LoadedFilterPage) {
        final currentState = state as LoadedFilterPage;
        emit(currentState.copyWith(selectedSeller: sellerId));
        _updateAmountOfAvailableProducts();
      }
    } catch (e) {
      emit(ErrorFilterPage(error: e));
    }
  }

  void _updateAmountOfAvailableProducts() {
    if (state is LoadedFilterPage) {
      final currentState = state as LoadedFilterPage;
      // Get selected filters
      final selectedSellerId = currentState.selectedSeller;
      final selectedTags = currentState.listOfSelectedTags ?? [];

      // Filter products by the selected seller and selected tags
      _filteredProducts = _filteredProducts.where((product) {
        final matchesSeller = selectedSellerId == null ||
            product.offer.sellerName == selectedSellerId;
        final matchesTags = selectedTags.isEmpty ||
            selectedTags.every((tag) => product.tags.contains(tag));
        return matchesSeller && matchesTags;
      }).toList();
      emit(currentState.copyWith(
        avaialbleProducts: _filteredProducts.length,
      ));
    }
  }

  Future<void> applyFilters() async {
    try {
      if (state is LoadedFilterPage) {
        final currentState = state as LoadedFilterPage;

        // Emit the state with the filtered products
        emit(currentState.copyWith(
          filteredProducts: _filteredProducts,
          areProductsFiltered: true,
          avaialbleProducts: _filteredProducts.length,
        ));
      }
    } catch (e) {
      emit(ErrorFilterPage(error: e));
    }
  }
}
