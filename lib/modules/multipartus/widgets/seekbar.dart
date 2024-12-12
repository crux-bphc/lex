import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lex/utils/extensions.dart';
import 'package:signals/signals_flutter.dart';

class SeekBar extends StatefulWidget {
  const SeekBar({
    super.key,
    this.barColor = const Color.fromARGB(107, 143, 143, 143),
    this.positionColor = const Color.fromARGB(255, 28, 164, 255),
    this.thumbColor = const Color.fromARGB(255, 28, 164, 255),
    this.bufferColor = const Color.fromARGB(94, 164, 164, 164),
    this.height = 3,
    this.hoverHeight = 6,
    this.thumbRadius = 7,
    this.initialBuffer = 0,
    this.initialPosition = 0,
    required this.bufferFraction,
    required this.positionFraction,
    required this.onSeek,
    required this.formatTimestamp,
  });

  final Color barColor, thumbColor, bufferColor, positionColor;
  final double height, hoverHeight, thumbRadius;

  final Stream<double> positionFraction, bufferFraction;
  final double initialPosition, initialBuffer;

  final void Function(double percent) onSeek;

  final String Function(double positionFraction) formatTimestamp;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> with SignalsMixin {
  final _thumbLayerLink = LayerLink();
  final _overlayController = OverlayPortalController();

  late final isHovering = createSignal(false);
  late final isDragging = createSignal(false);

  /// Fraction of the seekbar that the pointer is
  /// on (while hovering or dragging)
  late final pointerFraction = createSignal(0.0);

  late final positionFraction = createStreamSignal(
    () => widget.positionFraction,
    initialValue: widget.initialPosition,
  );

  late final bufferFraction = createStreamSignal(
    () => widget.bufferFraction.map((e) => e.clampNaN(0, 1)),
    initialValue: widget.initialBuffer,
  );

  late final position = createComputed<double>(
    () => isDragging()
        ? pointerFraction()
        : positionFraction().value!.clampNaN(0, 1),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 30,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: widget.thumbRadius * 2,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: _onEnter,
                  onExit: _onExit,
                  onHover: (event) => _onHover(event, constraints),
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (event) =>
                        _onPointerDown(event, constraints),
                    onPointerUp: _onPointerUp,
                    onPointerMove: (event) => _onMove(event, constraints),
                    child: Stack(
                      alignment: AlignmentDirectional.centerStart,
                      children: [
                        Center(
                          child: Watch(
                            (context) {
                              return Stack(
                                alignment: AlignmentDirectional.centerStart,
                                clipBehavior: Clip.none,
                                children: [
                                  AnimatedContainer(
                                    duration: 100.ms,
                                    height: isHovering()
                                        ? widget.hoverHeight
                                        : widget.height,
                                    width: constraints.maxWidth,
                                    child: Stack(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      children: [
                                        Container(
                                          width: constraints.maxWidth,
                                          color: widget.barColor,
                                        ),
                                        Container(
                                          width: constraints.maxWidth *
                                              bufferFraction().value!,
                                          color: widget.bufferColor,
                                        ),
                                        CompositedTransformTarget(
                                          link: _thumbLayerLink,
                                          child: Container(
                                            width: pointerFraction() *
                                                constraints.maxWidth,
                                            color: isHovering()
                                                ? widget.bufferColor
                                                    .withOpacity(0.7)
                                                : Colors.transparent,
                                          ),
                                        ),
                                        Container(
                                          width:
                                              constraints.maxWidth * position(),
                                          color: widget.positionColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    left: position() * constraints.maxWidth -
                                        widget.thumbRadius,
                                    child: SizedBox.square(
                                      dimension: widget.thumbRadius * 2,
                                      child: Center(
                                        child: AnimatedContainer(
                                          duration: 100.ms,
                                          height: isDragging() || isHovering()
                                              ? widget.thumbRadius * 2
                                              : 0,
                                          width: isDragging() || isHovering()
                                              ? widget.thumbRadius * 2
                                              : 0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: widget.positionColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              CompositedTransformFollower(
                link: _thumbLayerLink,
                targetAnchor: Alignment.topRight,
                followerAnchor: Alignment.bottomCenter,
                offset: Offset(0, -(widget.thumbRadius + 4)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.black38,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(widget.formatTimestamp(pointerFraction())),
                )
                    .animate(target: isHovering() || isDragging() ? 1 : 0)
                    .fade(duration: 100.ms),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onPointerDown(PointerDownEvent event, BoxConstraints constraints) {
    final percent = event.localPosition.dx / constraints.maxWidth;
    widget.onSeek(percent);

    if (mounted) isDragging.value = true;
  }

  void _onPointerUp(event) {
    if (mounted) isDragging.value = false;
  }

  void _onEnter(PointerEnterEvent _) {
    if (mounted) {
      isHovering.value = true;
      _overlayController.show();
    }
  }

  void _onExit(PointerExitEvent _) {
    // _overlayController.hide();

    if (mounted) {
      batch(() {
        isHovering.value = false;
      });
    }
  }

  void _onHover(PointerHoverEvent event, BoxConstraints constraints) {
    if (mounted) {
      batch(() {
        isHovering.value = true;
        pointerFraction.value = event.localPosition.dx / constraints.maxWidth;
      });
    }
  }

  void _onMove(PointerMoveEvent event, BoxConstraints constraints) {
    final percent = event.localPosition.dx / constraints.maxWidth;
    widget.onSeek(percent);

    if (mounted) {
      batch(() {
        isDragging.value = true;
        pointerFraction.value = percent;
      });
    }
  }

  @override
  void dispose() {
    // _overlayController.hide();

    super.dispose();
  }
}
