import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class Service {
  Handler get handler {
    final router = Router();

    // GET
    router.get('/pay', (Request request, int amount) {
      return Response.ok('pay $amount');
    });

    return router;
  }
}
