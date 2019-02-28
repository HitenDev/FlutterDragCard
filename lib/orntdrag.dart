import 'package:flutter/gestures.dart';

enum _DragState {
  ready,
  possible,
  accepted,
}

abstract class _DragGestureRecognizer extends OneSequenceGestureRecognizer {
  /// Initialize the object.
  _DragGestureRecognizer({Object debugOwner}) : super(debugOwner: debugOwner);

  /// A pointer has contacted the screen and might begin to move.
  ///
  /// The position of the pointer is provided in the callback's `details`
  /// argument, which is a [DragDownDetails] object.
  GestureDragDownCallback onDown;

  /// A pointer has contacted the screen and has begun to move.
  ///
  /// The position of the pointer is provided in the callback's `details`
  /// argument, which is a [DragStartDetails] object.
  GestureDragStartCallback onStart;

  /// A pointer that is in contact with the screen and moving has moved again.
  ///
  /// The distance travelled by the pointer since the last update is provided in
  /// the callback's `details` argument, which is a [DragUpdateDetails] object.
  GestureDragUpdateCallback onUpdate;

  /// A pointer that was previously in contact with the screen and moving is no
  /// longer in contact with the screen and was moving at a specific velocity
  /// when it stopped contacting the screen.
  ///
  /// The velocity is provided in the callback's `details` argument, which is a
  /// [DragEndDetails] object.
  GestureDragEndCallback onEnd;

  /// The pointer that previously triggered [onDown] did not complete.
  GestureDragCancelCallback onCancel;

  /// The minimum distance an input pointer drag must have moved to
  /// to be considered a fling gesture.
  ///
  /// This value is typically compared with the distance traveled along the
  /// scrolling axis. If null then [kTouchSlop] is used.
  double minFlingDistance;

  /// The minimum velocity for an input pointer drag to be considered fling.
  ///
  /// This value is typically compared with the magnitude of fling gesture's
  /// velocity along the scrolling axis. If null then [kMinFlingVelocity]
  /// is used.
  double minFlingVelocity;

  /// Fling velocity magnitudes will be clamped to this value.
  ///
  /// If null then [kMaxFlingVelocity] is used.
  double maxFlingVelocity;

  _DragState _state = _DragState.ready;
  Offset _initialPosition;
  Offset _pendingDragOffset;
  Duration _lastPendingEventTimestamp;

  bool _isFlingGesture(VelocityEstimate estimate);

  Offset _getDeltaForDetails(Offset delta);

  double _getPrimaryValueFromOffset(Offset value);

  bool get _hasSufficientPendingDragDeltaToAccept;

  final Map<int, VelocityTracker> _velocityTrackers = <int, VelocityTracker>{};

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
    _velocityTrackers[event.pointer] = VelocityTracker();
    if (_state == _DragState.ready) {
      _state = _DragState.possible;
      _initialPosition = event.position;
      _pendingDragOffset = Offset.zero;
      _lastPendingEventTimestamp = event.timeStamp;
      if (onDown != null)
        invokeCallback<void>('onDown',
            () => onDown(DragDownDetails(globalPosition: _initialPosition)));
    } else if (_state == _DragState.accepted) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    assert(_state != _DragState.ready);
    if (!event.synthesized &&
        (event is PointerDownEvent || event is PointerMoveEvent)) {
      final VelocityTracker tracker = _velocityTrackers[event.pointer];
      assert(tracker != null);
      tracker.addPosition(event.timeStamp, event.position);
    }

    if (event is PointerMoveEvent) {
      final Offset delta = event.delta;
      if (_state == _DragState.accepted) {
        if (onUpdate != null) {
          invokeCallback<void>(
              'onUpdate',
              () => onUpdate(DragUpdateDetails(
                    sourceTimeStamp: event.timeStamp,
                    delta: _getDeltaForDetails(delta),
                    primaryDelta: _getPrimaryValueFromOffset(delta),
                    globalPosition: event.position,
                  )));
        }
      } else {
        _pendingDragOffset += delta;
        _lastPendingEventTimestamp = event.timeStamp;
        if (_hasSufficientPendingDragDeltaToAccept)
          resolve(GestureDisposition.accepted);
      }
    }
    stopTrackingIfPointerNoLongerDown(event);
  }

  @override
  void acceptGesture(int pointer) {
    if (_state != _DragState.accepted) {
      _state = _DragState.accepted;
      final Offset delta = _pendingDragOffset;
      final Duration timestamp = _lastPendingEventTimestamp;
      _pendingDragOffset = Offset.zero;
      _lastPendingEventTimestamp = null;
      if (onStart != null) {
        invokeCallback<void>(
            'onStart',
            () => onStart(DragStartDetails(
                  sourceTimeStamp: timestamp,
                  globalPosition: _initialPosition,
                )));
      }
      if (delta != Offset.zero && onUpdate != null) {
        final Offset deltaForDetails = _getDeltaForDetails(delta);
        invokeCallback<void>(
            'onUpdate',
            () => onUpdate(DragUpdateDetails(
                  sourceTimeStamp: timestamp,
                  delta: deltaForDetails,
                  primaryDelta: _getPrimaryValueFromOffset(delta),
                  globalPosition: _initialPosition + deltaForDetails,
                )));
      }
    }
  }

  @override
  void rejectGesture(int pointer) {
    stopTrackingPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    if (_state == _DragState.possible) {
      resolve(GestureDisposition.rejected);
      _state = _DragState.ready;
      if (onCancel != null) invokeCallback<void>('onCancel', onCancel);
      return;
    }
    final bool wasAccepted = _state == _DragState.accepted;
    _state = _DragState.ready;
    if (wasAccepted && onEnd != null) {
      final VelocityTracker tracker = _velocityTrackers[pointer];
      assert(tracker != null);

      final VelocityEstimate estimate = tracker.getVelocityEstimate();
      if (estimate != null && _isFlingGesture(estimate)) {
        final Velocity velocity =
            Velocity(pixelsPerSecond: estimate.pixelsPerSecond).clampMagnitude(
                minFlingVelocity ?? kMinFlingVelocity,
                maxFlingVelocity ?? kMaxFlingVelocity);
        invokeCallback<void>(
            'onEnd',
            () => onEnd(DragEndDetails(
                  velocity: velocity,
                  primaryVelocity:
                      _getPrimaryValueFromOffset(velocity.pixelsPerSecond),
                )), debugReport: () {
          return '$estimate; fling at $velocity.';
        });
      } else {
        invokeCallback<void>(
            'onEnd',
            () => onEnd(DragEndDetails(
                  velocity: Velocity.zero,
                  primaryVelocity: 0.0,
                )), debugReport: () {
          if (estimate == null) return 'Could not estimate velocity.';
          return '$estimate; judged to not be a fling.';
        });
      }
    }
    _velocityTrackers.clear();
  }

  @override
  void dispose() {
    _velocityTrackers.clear();
    super.dispose();
  }
}

typedef ChangeGestureDirection = int Function();

class DirectionGestureRecognizer extends _DragGestureRecognizer {
  int direction;

  ChangeGestureDirection changeGestureDirection;

  static int left = 1 << 1;
  static int right = 1 << 2;
  static int up = 1 << 3;
  static int down = 1 << 4;
  static int all = left | right | up | down;

  DirectionGestureRecognizer(this.direction,
      {Object debugOwner})
      : super(debugOwner: debugOwner);

  @override
  bool _isFlingGesture(VelocityEstimate estimate) {
    if (changeGestureDirection != null) {
      direction = changeGestureDirection();
    }
    final double minVelocity = minFlingVelocity ?? kMinFlingVelocity;
    final double minDistance = minFlingDistance ?? kTouchSlop;
    if (_hasAll) {
      return estimate.pixelsPerSecond.distanceSquared > minVelocity &&
          estimate.offset.distanceSquared > minDistance;
    } else {
      bool result = false;
      if (_hasVertical) {
        result |= estimate.pixelsPerSecond.dy.abs() > minVelocity &&
            estimate.offset.dy.abs() > minDistance;
      }
      if (_hasHorizontal) {
        result |= estimate.pixelsPerSecond.dx.abs() > minVelocity &&
            estimate.offset.dx.abs() > minDistance;
      }
      return result;
    }
  }

  bool get _hasLeft => _has(DirectionGestureRecognizer.left);

  bool get _hasRight => _has(DirectionGestureRecognizer.right);

  bool get _hasUp => _has(DirectionGestureRecognizer.up);

  bool get _hasDown => _has(DirectionGestureRecognizer.down);
  bool get _hasHorizontal => _hasLeft || _hasRight;
  bool get _hasVertical => _hasUp || _hasDown;

  bool get _hasAll => _hasLeft && _hasRight && _hasUp && _hasDown;

  bool _has(int flag) {
    return (direction & flag) != 0;
  }

  @override
  bool get _hasSufficientPendingDragDeltaToAccept {
    if (changeGestureDirection != null) {
      direction = changeGestureDirection();
    }
    // if (_hasAll) {
    //   return _pendingDragOffset.distance > kPanSlop;
    // }
    bool result = false;
    if (_hasUp) {
      result |= _pendingDragOffset.dy < -kTouchSlop;
    }
    if (_hasDown) {
      result |= _pendingDragOffset.dy > kTouchSlop;
    }
    if (_hasLeft) {
      result |= _pendingDragOffset.dx < -kTouchSlop;
    }
    if (_hasRight) {
      result |= _pendingDragOffset.dx > kTouchSlop;
    }
    return result;
  }

  @override
  Offset _getDeltaForDetails(Offset delta) {
    if (_hasAll || (_hasVertical && _hasHorizontal)) {
      return delta;
    }

    double dx = delta.dx;
    double dy = delta.dy;

    if (_hasVertical) {
      dx = 0;
    }
    if (_hasHorizontal) {
      dy = 0;
    }
    Offset offset = Offset(dx, dy);
    return offset;
  }

  @override
  double _getPrimaryValueFromOffset(Offset value) {
    return null;
  }

  @override
  String get debugDescription => 'orientation_' + direction.toString();
}

class IgnorePanGestureRecognizer extends _DragGestureRecognizer {
  final int ignoreDirection;

  static int left = 1;
  static int right = 2;
  static int up = 3;
  static int down = 4;

  IgnorePanGestureRecognizer(this.ignoreDirection, {Object debugOwner})
      : super(debugOwner: debugOwner);

  @override
  bool _isFlingGesture(VelocityEstimate estimate) {
    final double minVelocity = minFlingVelocity ?? kMinFlingVelocity;
    final double minDistance = minFlingDistance ?? kTouchSlop;
    return estimate.pixelsPerSecond.distanceSquared >
        minVelocity * minVelocity &&
        estimate.offset.distanceSquared > minDistance * minDistance;
  }

  @override
  bool get _hasSufficientPendingDragDeltaToAccept {
    bool ignore = false;
    if (ignoreDirection == left) {
      ignore = _pendingDragOffset.dx <= -kTouchSlop;
    } else if (ignoreDirection == right) {
      ignore = _pendingDragOffset.dx >= kTouchSlop;
    } else if (ignoreDirection == up) {
      ignore = _pendingDragOffset.dy <= -kTouchSlop;
    } else if (ignoreDirection == down) {
      ignore = _pendingDragOffset.dy >= kTouchSlop;
    }
    return !ignore && _pendingDragOffset.distance > kPanSlop;
  }

  @override
  Offset _getDeltaForDetails(Offset delta) => delta;

  @override
  double _getPrimaryValueFromOffset(Offset value) => null;

  @override
  String get debugDescription => 'pan';
}
