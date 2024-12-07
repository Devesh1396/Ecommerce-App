abstract class OrderEvent {}

class LoadOrdersEvent extends OrderEvent {
  final String token;

  LoadOrdersEvent({required this.token});
}
