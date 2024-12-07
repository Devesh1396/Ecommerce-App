import 'package:ecom_app/data/DataModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/orders_bloc/order_bloc.dart';
import 'bloc/orders_bloc/order_event.dart';
import 'bloc/orders_bloc/order_state.dart';
import 'data/UserSession.dart';

class OrdersUI extends StatefulWidget {
  @override
  _OrdersUIState createState() => _OrdersUIState();
}

class _OrdersUIState extends State<OrdersUI> {
  late List<bool> _isExpanded;
  String? token;

  @override
  void initState() {
    super.initState();
    _isExpanded = []; // Initialize expansion state

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Await the token from SharedPreferences
      token = await UserSession().getTokenFromPrefs();
      if (token != null) {
        // Dispatch the event with the token
        context.read<OrderBloc>().add(LoadOrdersEvent(token: token!));
      } else {
        // Handle the case where the token is null (e.g., show an error or redirect)
        print("Error: Token not found");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoadingState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is OrderLoadedState) {
            final orders = state.orderModel.orders ?? [];

            // Ensure `_isExpanded` is correctly initialized
            if (_isExpanded.length != orders.length) {
              // Initialize the _isExpanded list for the first time or when the number of orders changes
              _isExpanded = List<bool>.filled(orders.length, false);
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpansionPanelList(
                          elevation: 1,
                          expandedHeaderPadding: EdgeInsets.symmetric(vertical: 4.0),
                          expansionCallback: (int panelIndex, bool isExpanded) {
                            setState(() {
                              _isExpanded[index] = !_isExpanded[index];
                            });
                          },
                          children: [
                            ExpansionPanel(
                              headerBuilder: (BuildContext context, bool isExpanded) {
                                return ListTile(
                                  title: Text(
                                    "Order #${order.orderNumber}",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text("Total: ₹${order.totalAmount}"),
                                );
                              },
                              body: Column(
                                children: order.product!.map((product) {
                                  return ListTile(
                                    leading: Image.network(
                                      product.image ?? '',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.contain,
                                    ),
                                    title: Text(product.name ?? ''),
                                    subtitle: Text(
                                      "Qty: ${product.quantity} • ₹${product.price}",
                                    ),
                                  );
                                }).toList(),
                              ),
                              isExpanded: _isExpanded[index],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else if (state is OrderErrorState) {
            return Center(child: Text("Error: ${state.error}"));
          }
          return Center(child: Text("No orders found."));
        },
      ),
    );
  }
}

