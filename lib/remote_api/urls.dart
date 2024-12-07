class Urls {
  static final String BASE_URL = "https://www.marketcraft.in/ecommerce-api/";

  //user
  static final String USER_URL = "${BASE_URL}user/";
  static final String REGISTER_URL = "${USER_URL}registration";
  static final String LOGIN_URL = "${USER_URL}login";
  static final String userslist_URL = "${USER_URL}list";

  //product
  static final String product_URL = "${BASE_URL}products";
  static final String add_cart_URL = "${BASE_URL}add-to-card";
  static final String view_cart_URL = "${BASE_URL}product/view-cart";
  static final String delete_cart_URL = "${BASE_URL}product/delete-cart";
  static final String decrement_URL = "${BASE_URL}product/decrement-quantity";
  static final String create_order_URL = "${BASE_URL}product/create-order";
  static final String get_order_URL = "${BASE_URL}product/get-order";
}
