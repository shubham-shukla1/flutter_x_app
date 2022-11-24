part of 'landing_bloc.dart';

abstract class LandingEvent extends Equatable {
  const LandingEvent();
}

class RunLandingLogicEvent extends LandingEvent {
  late final GeneralCubit generalCubit;
  late final BuildContext buildContext;

  RunLandingLogicEvent(this.generalCubit, this.buildContext);

  @override
  List<Object> get props => [generalCubit, buildContext];
}