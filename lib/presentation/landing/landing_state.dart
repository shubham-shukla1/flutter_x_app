part of 'landing_bloc.dart';

abstract class LandingState extends Equatable {
  const LandingState();
}

class LandingInitial extends LandingState {
  @override
  List<Object> get props => [];
}

class NavigateToState extends LandingState {
  final String routeName;

  NavigateToState(this.routeName);

  @override
  List<Object> get props => [routeName];
}

class AppIsNowReadyState extends LandingState {
  @override
  List<Object> get props => [];
}
