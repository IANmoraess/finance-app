// Placeholder para configuração do Dio.
// Ao adicionar o backend, instancie o Dio aqui e registre em Injector.init().
//
// Exemplo de uso:
//   import 'package:dio/dio.dart';
//
//   class DioClient {
//     static Dio instance([String? baseUrl]) => Dio(BaseOptions(
//       baseUrl: baseUrl ?? 'https://api.example.com',
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//       headers: {'Content-Type': 'application/json'},
//     ))..interceptors.addAll([
//       LogInterceptor(requestBody: true, responseBody: true),
//     ]);
//   }
