import 'package:carousal_slider/utils.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MaterialApp(home: BridgeCarousel()));

class BridgeCarousel extends StatefulWidget {
  @override
  _BridgeCarouselState createState() => _BridgeCarouselState();
}

class _BridgeCarouselState extends State<BridgeCarousel> {
  static const int virtualMultiplier = 10000; // Large multiplier
  int virtualLength = categories.length * virtualMultiplier;
  PageController _pageController = PageController(
    viewportFraction: 0.2,
    initialPage:
        virtualMultiplier ~/ 2 * categories.length, // Start in the middle
  );
  double _currentPage = (virtualMultiplier ~/ 2 * categories.length).toDouble();

  int textIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            bottom: 495,
            child: CustomPaint(
              size: Size(size.width, size.height * 0.5),
              painter: CurvePainter(),
            ),
          ),
          PageView.builder(
            clipBehavior: Clip.none,
            pageSnapping: false,
            controller: _pageController,
            itemCount: 1000000,
            itemBuilder: (context, index) {
              textIndex = (_currentPage % categories.length).toInt();
              int realIndex = index % categories.length;

              double relativePosition = index - _currentPage;

              double heightPosition = _getYForPosition(relativePosition, size);
              double scaleFactor =
                  1 + (0.2 * (1 - relativePosition.abs()).clamp(0.0, 1.0));

              // Calculate the additional margin. This will be 0 when scaleFactor is 1
              // and will increase as scaleFactor increases.
              // double additionalMargin = 8 * (scaleFactor - .4);
              // double scaleFactor = 1.3 - (0.3 * relativePosition.abs().clamp(0.0, 1.0));

              // relativePosition = relativePosition.clamp(-1.0, 1.0);
              // final curveValue =
              //     Curves.easeOut.transform(1.0 - relativePosition.abs());
              // double scaleFactor = .9 + (0.1 * curveValue);


              return Transform.translate(
                offset: Offset(0, heightPosition),
                child: Transform.scale(
                  scale: scaleFactor,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      color: Color.lerp(Colors.white, Colors.green, 0.3),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(4),
                    margin:
                        EdgeInsets.symmetric(horizontal: 8), // Adjusted margin
                    child: Container(
                      height: 20,
                      width: 20,
                      child: Center(
                        child: FractionallySizedBox(
                          heightFactor: 0.06,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image:
                                    NetworkImage(categories[realIndex]['flag']),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 400,
            left: 60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 40),
                  padding: EdgeInsets.all(10),
                  child: Text(
                    categories[textIndex]['Currency'],
                    style: TextStyle(color: Colors.green),
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(10)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 40,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.green, width: 1),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: Colors.green,
                        ),
                        // color: Colors.green,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 30, left: 30, top: 10),
                      child: Text(
                        '€ 12,560.00',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'dmSans',
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print('press');
                        _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 40,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.green, width: 1),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: Colors.green,
                        ),
                        // color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getYForPosition(double relativePosition, Size size) {
    double curveHeight = size.height * 0.3; // Adjusted for the moved curve
    return pow(relativePosition * size.width * 0.12, 2) / (size.width * 0.6) -
        curveHeight;
  }

  double calculateAdditionalMargin(double relativePosition) {
    const double range =
        2.0; // Adjust this value to determine which items receive the extra margin
    if (relativePosition.abs() <= range) {
      return (range - relativePosition.abs()) *
          10; // The '10' determines the maximum additional margin
    }
    return 0;
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(0, size.height * 0.7); // Adjusted starting point
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.4, size.width,
        size.height * 0.7); // Adjusted control point

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
