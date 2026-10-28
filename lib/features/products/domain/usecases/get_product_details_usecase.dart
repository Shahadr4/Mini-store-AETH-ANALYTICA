import '../../../../core/error/result.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetProductDetailsUseCase {
  const GetProductDetailsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<Product>> call(int id) => _repository.getProductDetails(id);
}
