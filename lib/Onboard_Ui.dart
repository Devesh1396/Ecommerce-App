import 'package:ecom_app/SignIn_Ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'app_colors.dart';

class OnboardingUI extends StatefulWidget {
  @override
  _OnboardingUIState createState() => _OnboardingUIState();
}

class _OnboardingUIState extends State<OnboardingUI> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
      {
        'title': 'Welcome to Naya!',
        'description': 'Your One-Stop Destination for Quality Products and Great Deals.',
        'image': 'assets/images/onboard1.svg',
      },
      {
        'title': 'Effortless Shopping Experience',
        'description': 'Explore, Buy, and Track Orders Easily with Our Intuitive App.',
        'image': 'assets/images/onboard2.svg',
      },
      {
        'title': 'Join the Naya Family',
        'description': 'Experience the Joy of Shopping with Personalized Recommendations.',
        'image': 'assets/images/onboard3.svg',
      },
  ];

  void _onNextPressed() async {
    if (_currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SigninUi()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPage(
                title: onboardingData[index]['title']!,
                description: onboardingData[index]['description']!,
                image: onboardingData[index]['image']!
              );
            },
          ),
          Positioned(
            top: 30,
            right: 20,
            child: _currentIndex < onboardingData.length - 1
                ? TextButton(
              onPressed: () {
                // Skip to the last page
                _pageController.animateToPage(
                  onboardingData.length - 1,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              child: Text(
                'Skip',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            )
                : Container(), // Hide Skip button on the last page
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: onboardingData.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.primaryColor,
                    dotColor: Colors.grey,
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    _currentIndex == onboardingData.length - 1 ? 'Get Started' : 'Next',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  OnboardingPage({required this.title, required this.description, required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Placeholder for the image
          SvgPicture.asset(
            image,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
