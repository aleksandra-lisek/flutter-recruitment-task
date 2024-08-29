import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/home_cubit.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late MockProductsRepository mockProductsRepository;
  late HomeCubit homeCubit;

  setUpAll(() {
    registerFallbackValue(GetProductsPage(pageNumber: 1));
    mockProductsRepository = MockProductsRepository();
    homeCubit = HomeCubit(mockProductsRepository);
  });

  tearDown(() {
    homeCubit.close();
  });

  group('HomeCubit', () {
    final sampleProducts = List.generate(
      40,
      (index) => Product(
        id: index.toString(),
        name: 'Product $index',
        mainImage: '',
        description: '',
        available: true,
        isFavorite: null,
        isBlurred: null,
        sellerId: '',
        tags: const [],
        offer: const Offer(
          sellerId: "seller722",
          sellerName: "seller722",
          skuId: "10067",
          regularPrice: Price(amount: 50, currency: "PLN"),
          promotionalPrice: Price(amount: 50, currency: "PLN"),
          normalizedPrice:
              NormalizedPrice(amount: 50, currency: "PLN", unitLabel: "/kg"),
          promotionalNormalizedPrice:
              NormalizedPrice(amount: 1, currency: "PLN", unitLabel: "/kg"),
          omnibusPrice: Price(amount: 50, currency: "PLN"),
          omnibusLabel: "Najniższa cena od wprowadzenia towaru",
          isBest: false,
          isSponsored: false,
          subtitle: "",
          tags: [],
        ),
      ),
    );

    final sampleProductPages = [
      ProductsPage(
        totalPages: 2,
        pageNumber: 1,
        pageSize: 20,
        products: sampleProducts.take(20).toList(),
      ),
      ProductsPage(
        totalPages: 2,
        pageNumber: 2,
        pageSize: 20,
        products: sampleProducts.skip(20).take(20).toList(),
      ),
    ];

    blocTest<HomeCubit, HomeState>(
      'emits Loaded when getFilteredPages',
      build: () {
        when(() => mockProductsRepository.getProductsPage(any()))
            .thenAnswer((_) async => sampleProductPages[0]);

        return homeCubit;
      },
      act: (cubit) async {
        await cubit.getFilteredPages(sampleProducts);
      },
      expect: () => [
        Loaded(pages: sampleProductPages),
      ],
    );
  });
}

// The test isn't passing because I couldn't resolve an issue where the loaded states are identical, but the test doesn't recognize them as the same. such.
