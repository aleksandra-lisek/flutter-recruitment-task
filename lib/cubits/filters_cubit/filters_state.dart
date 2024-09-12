import 'package:flutter_recruitment_task/models/products_page.dart';

sealed class FilterPageState {
  const FilterPageState();
}

class LoadingFilterPage extends FilterPageState {
  const LoadingFilterPage();
}

class LoadedFilterPage extends FilterPageState {
  final List<Tag>? listOfAvailableTags;
  final List<Tag>? listOfSelectedTags;
  final List<String>? listOfAvailableSellers;
  final String? selectedSeller;
  final List<Product>? filteredProducts;
  final int? avaialbleProducts;
  final bool? areProductsFiltered;

  LoadedFilterPage({
    this.listOfAvailableTags,
    this.listOfSelectedTags,
    this.listOfAvailableSellers,
    this.selectedSeller,
    this.filteredProducts,
    this.avaialbleProducts,
    this.areProductsFiltered,
  });

  LoadedFilterPage copyWith({
    List<Tag>? listOfAvailableTags,
    List<Tag>? listOfSelectedTags,
    List<String>? listOfAvailableSellers,
    String? selectedSeller,
    List<Product>? filteredProducts,
    int? avaialbleProducts,
    bool? areProductsFiltered,
  }) {
    return LoadedFilterPage(
      listOfAvailableTags: listOfAvailableTags ?? this.listOfAvailableTags,
      listOfSelectedTags: listOfSelectedTags ?? this.listOfSelectedTags,
      listOfAvailableSellers:
          listOfAvailableSellers ?? this.listOfAvailableSellers,
      selectedSeller: selectedSeller ?? this.selectedSeller,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      avaialbleProducts: avaialbleProducts ?? this.avaialbleProducts,
      areProductsFiltered: areProductsFiltered ?? this.areProductsFiltered,
    );
  }
}

class ErrorFilterPage extends FilterPageState {
  const ErrorFilterPage({required this.error});
  final dynamic error;
}
