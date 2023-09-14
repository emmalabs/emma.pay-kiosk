import 'package:drift/drift.dart';
import 'package:emmapay/appconfig.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'database.dart';

class Service {
  Handler get handler {
    final router = Router();

    // GET
    router.get('/pay/<amount>', (Request request, String amount) async {
      //Check if amount is a number
      if (double.tryParse(amount) == null) {
        return Response.badRequest(body: 'Amount must be a number');
      }

      //Insert transaction
      double amountDouble = double.tryParse(amount) ?? 0;
      AppTransactionsCompanion entry = AppTransactionsCompanion(
          amount: Value<double>(amountDouble),
          currency: const Value<String>('EUR'),
          status: const Value<String>('pending'));

      AppTransaction t = await AppConfigSingleton().db.addTransaction(entry);

      return Response.ok(t.id);
    });

    return router;
  }
}
