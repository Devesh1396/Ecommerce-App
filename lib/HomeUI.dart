import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecom_app/MainProfileUI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'ProductGridItem.dart';
import 'app_colors.dart';
import 'bloc/cart_bloc/cart_bloc.dart';
import 'bloc/cart_bloc/cart_event.dart';
import 'bloc/cart_bloc/cart_state.dart';
import 'bloc/product_bloc/product_bloc.dart';
import 'bloc/product_bloc/product_event.dart';
import 'bloc/product_bloc/product_state.dart';
import 'data/DataModel.dart';

class HomeUI extends StatefulWidget {
  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {

  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;

  final List<String> banners = [
    "assets/images/1.png",
    "assets/images/2.png",
    "assets/images/3.png",
    "assets/images/4.png",
    "assets/images/5.png",
  ];

  @override
  void initState() {
    super.initState();

    // Dispatch the LoadProductsEvent when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(LoadProductsEvent());
    });
  }

  String? _loadingProductId; // To track which product is loading

  void _addToCart(String productId) {
    setState(() {
      _loadingProductId = productId; // Set the loading product ID
    });
    context.read<CartBloc>().add(AddToCartEvent(productId: productId));
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Navigate to profile or user settings
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => profileUI()),
              );
            },
          ),
        ],
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerSlider(),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Trending Products",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )
              ),
            ),
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoadingState) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ProductLoadedState) {
                  return _buildProductGrid(state.productModel.data ?? []);
                } else if (state is ProductErrorState) {
                  return Center(child: Text(state.error));
                } else {
                  return Center(child: Text("No products available."));
                }
              },
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Search Bar in AppBar
  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color:  Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search products",
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10), // Adjust vertical padding
        ),
      ),
    );
  }


  // Banner Slider with Pagination Dots
  Widget _buildBannerSlider() {
    return Column(
      children: [
        CarouselSlider(
          items: banners.map((banner) {
            return ClipRRect(
              child: Image.asset(
                banner,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          }).toList(),
          carouselController: _carouselController,
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: false,
            viewportFraction: 1.0,
            aspectRatio: 2.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: banners.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _carouselController.animateToPage(entry.key),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withOpacity(_currentIndex == entry.key ? 0.9 : 0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Product Grid View
  Widget _buildProductGrid(List<Data> products) {
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartSuccessState) {
          setState(() {
            _loadingProductId = null;
          });
          showToast("Product Added to Cart");
        } else if (state is CartErrorState) {
          setState(() {
            _loadingProductId = null;
          });
          showToast(state.error);
        }
      },
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns per row
          crossAxisSpacing: 10, // Spacing between columns
          mainAxisSpacing: 10, // Spacing between rows
          childAspectRatio: 9 / 16, // Adjust the aspect ratio to fit the card layout
        ),
        itemCount: products.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemBuilder: (context, index) {
          return ProductGridItem(
            product: products[index],
            isLoading: _loadingProductId == products[index].id,
            onAddToCart: (productId) => _addToCart(productId),
          );
        },
      ),
    );
  }


  /*// Common Product Tile for Grid
  Widget _buildProductTile(Data product) {
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
              fit: BoxFit.cover,
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
          // Full-width elevated button instead of a circular button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ElevatedButton(
                    onPressed: () {
                      _addToCart(context, product.id ?? ''); // Pass product ID
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Rounded corners for button
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
  }*/

}



