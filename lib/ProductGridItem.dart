import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'data/DataModel.dart';

class ProductGridItem extends StatelessWidget {
  final Data product;
  final bool isLoading; // Determines if this product is loading
  final Function(String productId) onAddToCart; // Callback for add to cart

  const ProductGridItem({
    required this.product,
    required this.isLoading,
    required this.onAddToCart,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with adjusted height
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              product.image ?? '',
              fit: BoxFit.contain,
              height: 175, // Adjusted height
              width: double.infinity,
            ),
          ),
          // Product name with increased font size
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product.name ?? '',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), // Increased font size
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Product price with larger font size
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "\$${product.price ?? '0.00'}",
              style: TextStyle(color: Colors.grey[700], fontSize: 18), // Increased font size
            ),
          ),
          Spacer(),
          // Full-width elevated button or loader
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: isLoading
                ? Center(
                  child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                                ),
                              ),
                )
                : ElevatedButton(
              onPressed: () {
                onAddToCart(product.id ?? '');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_shopping_cart, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Add to Cart",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
