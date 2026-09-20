import 'package:chopper/chopper.dart';

import '../../../../core/network/api_envelope.dart';
import '../models/{{feature_name.snakeCase()}}_model.dart';

part '{{feature_name.snakeCase()}}_api_client.chopper.dart';

@ChopperApi(baseUrl: '/{{feature_name.snakeCase()}}')
abstract class {{feature_name.pascalCase()}}ApiClient extends ChopperService {
  static {{feature_name.pascalCase()}}ApiClient create([ChopperClient? client]) =>
      _${{feature_name.pascalCase()}}ApiClient(client);

  @GET()
  Future<Response<ApiEnvelope<List<{{feature_name.pascalCase()}}Model>>>> get{{feature_name.pascalCase()}}();
}
