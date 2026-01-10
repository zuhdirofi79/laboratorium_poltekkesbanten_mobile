import '../../../core/errors/failure.dart';
import '../domain/praktikum_schedule.dart';

/// Schedule State
/// 
/// Represents all possible states for praktikum schedules
/// Used by UI layer to determine what to render
/// Pattern mirrors EquipmentState exactly
sealed class ScheduleState {
  const ScheduleState();
}

/// Initial State
/// 
/// Initial state before any load operation
class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

/// Loading State
/// 
/// Praktikum schedules are being loaded
class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

/// Loaded State
/// 
/// Praktikum schedules successfully loaded
class ScheduleLoaded extends ScheduleState {
  final List<PraktikumSchedule> schedules;
  
  const ScheduleLoaded(this.schedules);
}

/// Empty State
/// 
/// No praktikum schedules found
class ScheduleEmpty extends ScheduleState {
  const ScheduleEmpty();
}

/// Error State
/// 
/// Failed to load praktikum schedules
/// Contains Failure for UI error handling
class ScheduleError extends ScheduleState {
  final Failure failure;
  
  const ScheduleError(this.failure);
}
