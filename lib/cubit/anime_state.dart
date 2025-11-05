import 'package:equatable/equatable.dart';

abstract class AnimeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AnimeInitial extends AnimeState {}

class AnimeLoading extends AnimeState {}

class AnimeLoaded extends AnimeState {
  final List<dynamic> animeList;
  AnimeLoaded(this.animeList);

  @override
  List<Object?> get props => [animeList];
}

class AnimeError extends AnimeState {
  final String message;
  AnimeError(this.message);

  @override
  List<Object?> get props => [message];
}
