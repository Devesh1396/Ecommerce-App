import 'package:ecom_app/OrdersUI.dart';
import 'package:ecom_app/bloc/cart_bloc/cart_event.dart';
import 'package:ecom_app/data/UserSession.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'app_colors.dart';
import 'bloc/cart_bloc/cart_bloc.dart';
import 'bloc/cart_bloc/cart_state.dart';
import 'data/DataModel.dart';

class CartUI extends StatefulWidget {
  const CartUI({Key? key}) : super(key: key);

  @override
  State<CartUI> createState() => _CartUIState();
}

class _CartUIState extends State<CartUI> {

  String? token; // Declare the token variable globally in the class
  List<CartItem> cartData = [];
  bool isLoading = true; // To track initial loading state
  bool isCoupon = false;
  double couponValue = 500.0; // Coupon value

  @override
  void initState() {
    super.initState();

    // Use addPostFrameCallback to ensure this runs after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Await the token from SharedPreferences
      token = await UserSession().getTokenFromPrefs();
      if (token != null) {
        // Dispatch the event with the token
        context.read<CartBloc>().add(LoadCartEvent(token: token!));
      } else {
        // Handle the case where the token is null (e.g., show an error or redirect)
        print("Error: Token not found");
      }
    });
  }

  void _deleteAllCartItems(BuildContext context, List<CartItem> cartItems) {
    // Extract all cart IDs
    final cartIds = cartItems.map((item) => item.id).toList();

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete All Items"),
          content: Text("Are you sure you want to delete all items from the cart?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Trigger the delete events for each cart ID
                for (var id in cartIds) {
                  context.read<CartBloc>().add(DeleteCartItemEvent(cartId: id!, token: token!));
                }
                Navigator.of(context).pop(); // Close the dialog after triggering the events
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

   void _onQuantitySelected(int selected_qty, int curent_qty, int prod_id) {

     if (selected_qty > curent_qty) {
       // Increment API:
       final incrementQty = selected_qty - curent_qty;
       context.read<CartBloc>().add(
         UpdateCartQtyEvent(
           productId: prod_id.toString() ?? '',
           quantity: incrementQty,
           token: token!,
         ),
       );
     } else if (selected_qty < curent_qty) {
       // Decrement API: Calculate difference and update
       final decrementQty = curent_qty - selected_qty;
       context.read<CartBloc>().add(
         DecrementCartQtyEvent(
           productId: prod_id.toString() ?? '',
           quantity: decrementQty,
           token: token!,
         ),
       );
     }

   }

  void _placeOrder(BuildContext context) {
    context.read<CartBloc>().add(PlaceOrderEvent(token: token!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping Bag"),
      ),
      body: BlocListener<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartLoadingState) {
            // Handle loading state
            setState(() {
              isLoading = true;
            });
          } else if (state is CartLoadedState) {
            // Update cart data when loaded
            setState(() {
              cartData = state.cart.data ?? [];
              isLoading = false; // Data has been loaded
            });
          } else if (state is CartDeletedState || state is CartEmptyState) {
            // Clear cart data when cart is empty
            setState(() {
              cartData = [];
              isLoading = false; // Data has been loaded
            });
          } else if (state is CartUpdatingState || state is OrderPlacingState || state is CartItemDeletingState) {
            // Show overlay loader for updating state
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
              ),
            );
          } else if (state is CartUpdatedState || state is CartItemDeletedState) {
            // Dismiss loader after updating
            Navigator.pop(context);
          }
          else if (state is OrderPlacedState) {
            Navigator.pop(context); // Dismiss the loader
            _showLottieOverlay(context); // Show Lottie animation
        } else if (state is CartErrorState) {
            // Handle errors and dismiss loader if visible
            Navigator.pop(context); // Dismiss any open loader
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
            setState(() {
              isLoading = false; // Stop loading even if there's an error
            });
          }
        },
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(), // Show loader while loading
        )
            : cartData.isEmpty
            ? Center(
          child: Text(
            "Your cart is empty.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
            : CustomScrollView(
          slivers: [
            // Sliver for Cart Items
            SliverToBoxAdapter(
              child: _buildCartItems(cartData), // Pass updated cartData to display items
            ),

            // Sliver for Apply Coupon Button
            SliverToBoxAdapter(
              child: CouponWidget(
                isCouponApplied: isCoupon,
                onToggleCoupon: (bool applied) {
                  setState(() {
                    isCoupon = applied;
                  });
                },
              ),
            ),

            // Sliver for Place Order Widget
            SliverToBoxAdapter(
              child: PlaceOrderWidget(
                cartItems: cartData,
                couponDiscount: isCoupon ? couponValue : 0.0,
                platformFee: 20.0, // Example platform fee
                shippingFee: 0.0, // Example free shipping
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: cartData.isEmpty
          ? SizedBox.shrink() // Hide the button when cart is empty
          : Container(
        color: Colors.white, // Add background color here
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            _placeOrder(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(
            "PLACE ORDER",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),

    );
  }

  Widget _buildCartItems(List<CartItem> cartItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row with Delete All Icon
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Items",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Handle delete all functionality
                  _deleteAllCartItems(context, cartItems);
                },
                icon: Icon(Icons.delete_outline_outlined, color: Colors.red),
              ),
            ],
          ),
        ),

        // Cart Items List
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true, // Important to avoid layout overflow
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            final item = cartItems[index];
            return _buildCartTile(item);
          },
        ),
      ],
    );
  }

  // Individual Cart Tile
  Widget _buildCartTile(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                child: Image.network(
                  item.image ?? '',
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 12),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    // Quantity Container
                    GestureDetector(
                      onTap: () {
                        showQuantityBottomSheet(context, (quantity) {
                          _onQuantitySelected(quantity, item.quantity!, item.productId!);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Qty: ${item.quantity ?? 1}",
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 4), // Space between text and icon
                            Icon(
                              Icons.arrow_drop_down, // Down arrow icon
                              color: AppColors.primaryColor,
                              size: 22, // Adjust size to fit with text
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Price
                    Text(
                      "₹${(int.parse(item.price ?? '0') * (item.quantity ?? 1)).toString()}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Remove Icon
              IconButton(
                onPressed: () {
                  context.read<CartBloc>().add(DeleteItemEvent(cartId: item.id!, token: token!));
                },
                icon: Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Stack(
      children: [
        // Dimmed background
        Opacity(
          opacity: 0.5,
          child: Container(
            color: Colors.black,
          ),
        ),
        // Centered CircularProgressIndicator
        Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  void showQuantityBottomSheet(BuildContext context, Function(int) onQuantitySelected) {
    int selectedQuantity = 1; // Default selected quantity

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // Optional overlay color
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Quantity",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context), // Close the bottom sheet
                        child: Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Horizontal list of quantities
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10, // Numbers from 1 to 10
                    itemBuilder: (context, index) {
                      final quantity = index + 1; // Quantity starts at 1
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedQuantity = quantity; // Update selected quantity
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          alignment: Alignment.center,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedQuantity == quantity
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                              width: 2,
                            ),
                            color: selectedQuantity == quantity
                                ? Theme.of(context).primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          child: Text(
                            "$quantity",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: selectedQuantity == quantity
                                  ? Theme.of(context).primaryColor
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                // Done Button
                SizedBox(
                  width: double.infinity, // Full width button
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                      onQuantitySelected(selectedQuantity); // Pass the selected quantity
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12), // Adjust height of button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Text(
                      "DONE",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLottieOverlay(BuildContext context) {
    final overlayState = Overlay.of(context); // Get the overlay state
    if (overlayState == null) return;

    late OverlayEntry overlayEntry;

    // Function to remove the overlay
    void removeOverlay() {
      overlayEntry.remove();
    }

    // Define the overlay entry
    overlayEntry = OverlayEntry(
      builder: (context) {
        return Container(
          color: Colors.white, // Full-screen white background
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lottie Animation
                Lottie.asset(
                  'assets/images/success.json',
                  width: 150,
                  height: 150,
                  repeat: false,
                ),
                const SizedBox(height: 16),
                // Thank You Text
                Text(
                  "Thank you for your order!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    // Insert the overlay
    overlayState.insert(overlayEntry);

    // Remove the overlay and navigate after the Lottie animation finishes
    Future.delayed(Duration(seconds: 3), () {
      removeOverlay(); // Remove the overlay
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrdersUI()), // Replace with your new UI
      );
    });
  }

}

class CouponWidget extends StatefulWidget {

  final bool isCouponApplied; // Track if coupon is applied
  final Function(bool) onToggleCoupon; // Callback to toggle coupon state in parent

  CouponWidget({required this.isCouponApplied, required this.onToggleCoupon});

  @override
  State<CouponWidget> createState() => _CouponWidgetState();
}

class _CouponWidgetState extends State<CouponWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100], // Light background for the coupon section
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Best Coupon For You",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle "All Coupons" action
                },
                child: Text(
                  "All Coupons",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Coupon Details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First Row: Main Text
                Text(
                  "Extra ₹500 OFF",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Second Row: Subtext
                Text(
                  "For Your First Order off NAYA",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),

                // Third Row: Coupon Code and Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Coupon Code with SVG Background
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/coupon_svg.svg', // Path to your SVG
                          height: 60, // Adjust height as per design
                          width: 80, // Adjust width as per design
                          fit: BoxFit.contain,
                        ),
                        Text(
                          "TRYNAYA",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Apply Coupon Button
                    ElevatedButton(
                      onPressed: () {
                        widget.onToggleCoupon(!widget.isCouponApplied);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          side: BorderSide(
                            color: AppColors.primaryColor,
                          )
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.isCouponApplied ? "REMOVE" : "APPLY COUPON",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceOrderWidget extends StatelessWidget {
  final List<CartItem> cartItems; // Pass cart data
  final double couponDiscount; // Coupon discount value
  final double platformFee; // Platform fee value
  final double shippingFee; // Shipping fee value

  PlaceOrderWidget({
    required this.cartItems,
    this.couponDiscount = 0.0, // Default to zero
    this.platformFee = 20.0, // Example platform fee
    this.shippingFee = 0.0, // Example free shipping
  });

  @override
  Widget build(BuildContext context) {
    final int itemCount = cartItems.length;
    final double itemsTotal = cartItems.fold(
      0.0,
          (sum, item) => sum + (int.parse(item.price ?? '0') * (item.quantity ?? 1)),
    );

    final double totalAmount = itemsTotal - couponDiscount + platformFee + shippingFee;

    return Container(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "PRICE DETAILS ($itemCount Item${itemCount > 1 ? 's' : ''})",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(thickness: 1),

          // Price Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                _buildPriceRow("Item(s) Total", "₹${itemsTotal.toStringAsFixed(2)}"),
                _buildPriceRow("Coupon Discount", "- ₹${couponDiscount.toStringAsFixed(2)}"),
                _buildPriceRow("Platform Fee", "₹${platformFee.toStringAsFixed(2)}",
                    actionText: "Know More"),
                _buildPriceRow("Shipping Fee", shippingFee == 0.0 ? "FREE" : "₹${shippingFee.toStringAsFixed(2)}",
                    valueColor: shippingFee == 0.0 ? Colors.green : null, actionText: "Know More"),
              ],
            ),
          ),
          Divider(thickness: 1),

          // Total Amount
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Amount",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹${totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a price detail row
  Widget _buildPriceRow(String title, String value, {Color? valueColor, String? actionText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(title, style: TextStyle(fontSize: 14)),
              if (actionText != null) ...[
                SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    // Handle action tap (e.g., show a dialog or navigate)
                  },
                  child: Text(
                    actionText,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                  ),
                ),
              ],
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: valueColor ?? Colors.black),
          ),
        ],
      ),
    );
  }
}


