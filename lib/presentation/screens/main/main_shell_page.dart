import 'package:flutter/material.dart';
import 'package:auth_profile_example/core/constants/constants.dart';
import 'package:auth_profile_example/presentation/screens/home/home_page.dart';
import 'package:auth_profile_example/presentation/screens/profile/profile_page.dart';
import 'package:auth_profile_example/presentation/widgets/common/asset_icon.dart';

class MainShellPage extends StatefulWidget {
  final String phoneNumber;
  final String countryName;
  final String flagEmoji;

  const MainShellPage({
    super.key,
    required this.phoneNumber,
    required this.countryName,
    required this.flagEmoji,
  });

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        phoneNumber: widget.phoneNumber,
        flagEmoji: widget.flagEmoji,
      ),
      ProfilePage(
        phoneNumber: widget.phoneNumber,
        countryName: widget.countryName,
        flagEmoji: widget.flagEmoji,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 3.2,
            right: MediaQuery.of(context).size.width / 3.2,
            bottom: MediaQuery.of(context).padding.bottom + 10,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(65),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    spreadRadius: 0.3,
                    offset: const Offset(0, 1),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildItem(
                    index: 0,
                    size: 26,
                    icon: AppConstants.homeIconAsset,
                    fallback: Icons.home_rounded,
                  ),
                  _buildItem(
                    index: 1,
                    size: 30,
                    icon: AppConstants.profileIconAsset,
                    fallback: Icons.person_rounded,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItem({
    required int index,
    required double size,
    required String icon,
    required IconData fallback,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(35),
        onTap: () {
          setState(() => _currentIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(
                left: index == 0 ? 15 : 0, right: index == 1 ? 15 : 0),
            child: AssetIcon(
              assetPath: icon,
              size: size,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              fallback: fallback,
            ),
          ),
        ),
      ),
    );
  }
}
