import 'package:ecom_app/OrdersUI.dart';
import 'package:ecom_app/SettingsUI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/user/bloc_code.dart';
import 'bloc/user/events.dart';
import 'data/UserSession.dart';

class profileUI extends StatefulWidget {
  @override
  _ProfileUIState createState() => _ProfileUIState();

  final bool showBackButton;

  profileUI({this.showBackButton = true});

}

class _ProfileUIState extends State<profileUI> {
  ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  String? username;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 30 &&
          !_scrollController.position.outOfRange) {
        if (!_isScrolled) {
          setState(() {
            _isScrolled = true;
          });
        }
      } else if (_scrollController.offset <= 30 &&
          !_scrollController.position.outOfRange) {
        if (_isScrolled) {
          setState(() {
            _isScrolled = false;
          });
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fetchedUsername = await UserSession().getNameFromPrefs();
      if (fetchedUsername != null) {
        setState(() {
          username = fetchedUsername;
        });
      } else {
        print("Error: Name not found");
      }
    });

  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: 90.0,
                  collapsedHeight: 60.0,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    title: widget.showBackButton && _isScrolled
                        ? Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    )
                        : null,
                    titlePadding: EdgeInsets.symmetric(horizontal: 8.0),
                    background: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.showBackButton)
                              IconButton(
                                icon: Icon(
                                    Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            Text(
                              'Profile',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )
                            ),
                            IconButton(
                              icon: Icon(
                                  Icons.edit, color: Theme.of(context).primaryColor),
                              onPressed: () {
                                //
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _profileTop(),
                        SizedBox(height: 20),
                        _buildMenu(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _profileTop() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage("assets/images/user_profile.png"),
          ),
          SizedBox(height: 10),
          username == null
              ? CircularProgressIndicator() // Show a loader until the username is available
              : Text(
            username!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu() {
    return Container(
        child: Column(
      children: [
        _buildMenuItem(Icons.person, "Profile", () {}),
        _buildDivider(),
        _buildMenuItem(Icons.shopping_bag, "My Orders", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrdersUI()),
          );
        }),
        _buildDivider(),
        _buildMenuItem(Icons.favorite_border_outlined, "Wishlist", () {}),
        _buildDivider(),
        _buildMenuItem(Icons.settings, "Settings", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsUi()),
          );
        }),
        _buildDivider(),
        _buildMenuItem(Icons.support, "Support", () {}),
        _buildDivider(),
        _buildMenuItem(Icons.logout, "Logout", () => context.read<UserBloc>().add(UserLogoutEvent())),
        _buildDivider(),
        _buildMenuItem(Icons.info_outline, "App Info", () {}),
      ],
    ));
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 4.0),
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[300],
      thickness: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
