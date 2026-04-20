import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(12),
            ),
              child: Image.asset(
                'assets/icons/boy.png',
                width: 40,
                height: 40,
              )
          ),


          Image.asset(
            'assets/icons/logo2.png',
            height: 40,
          ),

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE3E8EE)),
            ),


                child: Image.asset(
                    'assets/icons/icon.png',
                  width: 40,
                  height: 40,
                )


          ),
        ],
      ),
    );
  }
}
