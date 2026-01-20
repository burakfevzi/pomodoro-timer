import 'package:flutter/material.dart';

class AnimatedSlider extends StatefulWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color color;
  final String suffix;
  final ValueChanged<double> onChanged;

  const AnimatedSlider({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.color,
    required this.suffix,
    required this.onChanged,
  });

  @override
  State<AnimatedSlider> createState() => _AnimatedSliderState();
}

class _AnimatedSliderState extends State<AnimatedSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onSliderChanged(double value) {
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                color: widget.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${widget.value.round()} ${widget.suffix}',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: 15),
        
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: widget.color,
            inactiveTrackColor: Colors.white.withOpacity(0.1),
            thumbColor: widget.color,
            overlayColor: widget.color.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 20,
            ),
            trackHeight: 6,
          ),
          child: Slider(
            value: widget.value,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: _onSliderChanged,
          ),
        ),
      ],
    );
  }
}