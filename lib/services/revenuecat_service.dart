import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/services.dart';

class RevenueCatService {
  static const String testStoreApiKey =
      String.fromEnvironment(
    'test_KLLnkCkIrXWdbvGgtTBVWZFVkOY',
  );

  static const String reconstructionProductId =
      'tower_reconstruction';

  static const String reconstructionPackageId =
      'reconstruction';

  static Future<void> initialize() async {
    if (testStoreApiKey.isEmpty) {
      throw Exception(
        'REVENUECAT_TEST_API_KEY was not provided.',
      );
    }

    await Purchases.setLogLevel(
      LogLevel.debug,
    );

    final configuration =
        PurchasesConfiguration(
      testStoreApiKey,
    );

    await Purchases.configure(
      configuration,
    );
  }

  static Future<bool> purchaseReconstruction() async {
  try {
    final offerings =
        await Purchases.getOfferings();

    final offering = offerings.current;

    if (offering == null) {
      throw Exception(
        'No current RevenueCat offering was found.',
      );
    }

    final packages = offering.availablePackages;

    if (packages.isEmpty) {
      throw Exception(
        'No packages are available.',
      );
    }

    final package = packages.firstWhere(
      (package) =>
          package.identifier ==
          reconstructionPackageId,
      orElse: () => packages.firstWhere(
        (package) =>
            package.storeProduct.identifier ==
            reconstructionProductId,
      ),
    );

    final purchaseParams =
        PurchaseParams.package(package);

    await Purchases.purchase(purchaseParams);

    return true;
  } on PlatformException catch (e) {
    final errorCode =
        PurchasesErrorHelper.getErrorCode(e);

    if (errorCode ==
        PurchasesErrorCode.purchaseCancelledError) {
      return false;
    }

    rethrow;
  }
}
}