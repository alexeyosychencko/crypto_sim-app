import 'package:hive/hive.dart';

part 'wallet.g.dart';

@HiveType(typeId: 0)
class Wallet extends HiveObject {
  @HiveField(0)
  double balance;

  @HiveField(1)
  double invested;

  Wallet({this.balance = 3000.0, this.invested = 0.0});
}
