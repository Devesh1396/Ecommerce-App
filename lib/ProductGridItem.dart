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
      color: Theme.of(context).cardColor,
      elevation: 4,
      shadowColor: Theme.of(context).shadowColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with adjusted height
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Image.network(
                product.image ?? '',
                fit: BoxFit.contain,
                height: 150, // Adjusted height
                width: double.infinity,
              ),
            ),
          ),
          Spacer(),
          // Product name with increased font size
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(product.name ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    )),
          ),
          // Product price with larger font size
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("\$${product.price ?? '0.00'}",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ) // Increased font size
                ),
          ),
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
