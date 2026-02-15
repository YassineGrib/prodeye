import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/product_repository.dart';
import '../models/product.dart';
import '../../profile/data/profile_repository.dart';
import '../../history/data/history_repository.dart';
import '../data/health_score_engine.dart';

/// Provider to look up a product by barcode
final productByBarcodeProvider = FutureProvider.family<Product?, String>((
  ref,
  barcode,
) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductByBarcode(barcode);
});

/// Scan result screen - looks up the barcode in Firestore
/// and navigates to product details or not-found
class ScanResultScreen extends ConsumerStatefulWidget {
  final String barcode;

  const ScanResultScreen({super.key, required this.barcode});

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  @override
  void initState() {
    super.initState();
    // Delay navigation to avoid build-time context issues
    WidgetsBinding.instance.addPostFrameCallback((_) => _lookupAndNavigate());
  }

  Future<void> _lookupAndNavigate() async {
    try {
      final repository = ref.read(productRepositoryProvider);
      final product = await repository.getProductByBarcode(widget.barcode);

      if (!mounted) return;

      if (product != null) {
        // Calculate health score if possible
        // We need user profile for this. Fetch it once.
        final profile = await ref.read(userProfileProvider.future);
        double? score;
        if (profile != null) {
          final result = HealthScoreEngine.calculate(
            product: product,
            user: profile,
          );
          score = result.score;
        }

        // Add to history
        // Add to history (non-blocking)
        try {
          await ref
              .read(historyRepositoryProvider)
              .addToHistory(product, healthScore: score);
        } catch (e) {
          debugPrint('Error adding to history: $e');
        }

        if (!mounted) return;

        // Navigate to product details, replacing this screen
        context.pushReplacementNamed(
          'product-details',
          pathParameters: {'barcode': widget.barcode},
          extra: product,
        );
      } else {
        // Navigate to not-found screen
        context.pushReplacementNamed(
          'product-not-found',
          pathParameters: {'barcode': widget.barcode},
        );
      }
    } catch (e) {
      if (!mounted) return;
      // On error, show not found
      context.pushReplacementNamed(
        'product-not-found',
        pathParameters: {'barcode': widget.barcode},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loading animation
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'جاري البحث عن المنتج...',
              style: GoogleFonts.tajawal(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 8),
                  Text(
                    widget.barcode,
                    style: GoogleFonts.robotoMono(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
