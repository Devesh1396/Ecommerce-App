import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
    _isExpanded = [];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      token = await UserSession().getTokenFromPrefs();
      if (token != null) {
        context.read<OrderBloc>().add(LoadOrdersEvent(token: token!));
      } else {
        print("Error: Token not found");
      }
    });
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "Invalid Date";

    try {
      // Parse the date from the string
      final parsedDate = DateTime.parse(date);

      // Format the date in dd-MM-yy format
      final formattedDate = DateFormat('dd-MM-yy').format(parsedDate);

      return formattedDate;
    } catch (e) {
      // Handle any parsing errors
      return "Invalid Date";
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
        automaticallyImplyLeading: true,
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Card(
                          elevation: 0,
                          color: Colors.white,
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
                                    trailing: Text(
                                      "Date: ${_formatDate(order.createdAt)}",
                                      style: TextStyle(fontSize: 15),
                                    ),
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
                                      title: Text(product.name ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
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

