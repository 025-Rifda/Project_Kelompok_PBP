import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../models/anime_model.dart';
import 'detail_page.dart';

class DetailLoaderPage extends StatefulWidget {
  final int id;
  const DetailLoaderPage({super.key, required this.id});

  @override
  State<DetailLoaderPage> createState() => _DetailLoaderPageState();
}

class _DetailLoaderPageState extends State<DetailLoaderPage> {
  Anime? _anime;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = context.read<Dio>();
      final res = await dio.get('https://api.jikan.moe/v4/anime/${widget.id}');
      final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      setState(() {
        _anime = Anime.fromJson(data);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat detail: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetch,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return DetailPage(anime: _anime!);
  }
}

