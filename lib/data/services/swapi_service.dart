import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../../domain/models/character.dart';

class StarWarsApiService {
  final Dio _dio;
  static const String baseUrl = 'https://swapi.dev/api/people/';

  StarWarsApiService() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 15);
    _dio.options.receiveTimeout = Duration(seconds: 15);

    // Configure HttpClient untuk menangani SSL certificate issues
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (
        X509Certificate cert,
        String host,
        int port,
      ) {
        print('⚠️ Bypassing SSL for $host');
        return true;
      };
      return client;
    };

    // Add interceptors untuk logging (optional)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
        logPrint: (obj) => print(obj),
      ),
    );
  }

  // Method untuk fetch single page
  Future<Map<String, dynamic>> fetchPeoplePage(String url) async {
    try {
      print('Fetching data from: $url');
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        print('Successfully fetched data');
        return response.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Failed to load data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('DioException occurred: ${e.message}');
      throw _handleDioError(e);
    } on SocketException catch (e) {
      print('SocketException occurred: ${e.message}');
      throw Exception(
        'Network connection failed. Please check your internet connection.',
      );
    } on HandshakeException catch (e) {
      print('HandshakeException occurred: ${e.message}');
      throw Exception('SSL connection failed. Please try again.');
    } catch (e) {
      print('Unexpected error occurred: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Method untuk fetch semua karakter dari semua halaman
  Future<List<CharacterModel>> fetchAllCharacters() async {
    List<CharacterModel> allCharacters = [];
    String? nextUrl = baseUrl;

    try {
      while (nextUrl != null) {
        final data = await fetchPeoplePage(nextUrl);
        final results = data['results'] as List;

        // Convert ke Character objects
        final pageCharacters =
            results.map((json) => CharacterModel.fromJson(json)).toList();

        allCharacters.addAll(pageCharacters);
        nextUrl = data['next'];
      }

      return allCharacters;
    } catch (e) {
      rethrow;
    }
  }

  // Method untuk handle Dio errors
  Exception _handleDioError(DioException e) {
    print('Handling DioException: ${e.type} - ${e.message}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.receiveTimeout:
        return Exception('Server response timeout. Please try again.');
      case DioExceptionType.connectionError:
        return Exception(
          'Connection error. Please check your internet connection and try again.',
        );
      case DioExceptionType.badResponse:
        return Exception(
          'Server error: ${e.response?.statusCode}. Please try again later.',
        );
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.unknown:
        if (e.message?.contains('HandshakeException') == true) {
          return Exception('SSL certificate error. Please try again.');
        } else if (e.message?.contains('SocketException') == true) {
          return Exception(
            'Network connection failed. Please check your internet connection.',
          );
        }
        return Exception('Network error. Please try again.');
      default:
        return Exception('Network error: ${e.message}');
    }
  }

  // Method untuk dispose dio
  void dispose() {
    _dio.close();
  }
}
