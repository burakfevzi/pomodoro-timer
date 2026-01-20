import 'package:flutter/material.dart';

class FlipDigit extends StatefulWidget {
  final int value;
  final bool shouldFlip;
  final bool isFocus;

  const FlipDigit({
    super.key,
    required this.value,
    required this.shouldFlip,
    required this.isFocus,
  });

  @override
  State<FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<FlipDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  int _displayValue = 0;
  int _nextValue = 0;

  @override
  void initState() {
    super.initState();
    _displayValue = widget.value;
    _nextValue = widget.value;
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(FlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.shouldFlip && widget.value != _displayValue) {
      _nextValue = widget.value;
      _startFlipAnimation();
    }
  }

  void _startFlipAnimation() {
    _controller.forward(from: 0.0).then((_) {
      setState(() {
        _displayValue = _nextValue;
      });
      _controller.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130, // Daha da büyüttük
      height: 160, // Daha da büyüttük
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          if (_flipAnimation.value == 0.0) {
            // Animasyon yok - normal gösterim
            return _buildDigitContainer(_displayValue);
          }
          
          final isFirstHalf = _flipAnimation.value < 0.5;
          
          if (isFirstHalf) {
            // İlk yarı - üst kısım aşağı katlanıyor
            final rotationX = _flipAnimation.value * 1.57; // π/2 radians (90 derece)
            return Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateX(-rotationX),
              child: _buildDigitContainer(_displayValue),
            );
          } else {
            // İkinci yarı - alt kısım yukarı açılıyor
            final rotationX = (1.0 - _flipAnimation.value) * 1.57; // π/2 radians
            return Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateX(rotationX),
              child: _buildDigitContainer(_nextValue),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildDigitContainer(int value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          if (widget.shouldFlip && _flipAnimation.value > 0)
            BoxShadow(
              color: (widget.isFocus 
                  ? const Color(0xFFFF6B6B) 
                  : const Color(0xFF4ECDC4))
                  .withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 3,
            ),
        ],
      ),
      child: Center(
        child: Text(
          '$value',
          style: const TextStyle(
            fontSize: 96, // 84'den 96'ya büyüttük
            fontWeight: FontWeight.w100,
            color: Colors.white,
            fontFamily: 'SF Mono',
            height: 1.0,
          ),
        ),
      ),
    );
  }
}