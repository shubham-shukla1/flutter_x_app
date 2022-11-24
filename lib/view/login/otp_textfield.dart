import 'package:flutter/material.dart';
import 'package:basic_utils/basic_utils.dart';

import '../../shared/app_theme/app_colors/app_colors.dart';
import '../../own_package/country_picker/country_code.dart';
import '../../own_package/country_picker/country_code_picker.dart';

class OTPTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String hint;
  final Function(CountryCode)? heyChange;
  final VoidCallback onResendTap;
  late String? errorMsg;
  late TextInputType? keyBoardType = TextInputType.text;

  OTPTextField({
    required this.textEditingController,
    required this.hint,
    required this.heyChange,
    required this.onResendTap,
    required this.errorMsg,
    this.keyBoardType,
    Key? key,
  }) : super(key: key);

  @override
  State<OTPTextField> createState() => _OTPTextFieldState();
}

class _OTPTextFieldState extends State<OTPTextField> {
  bool? isEmail;
  bool? isAnimationNeeded = false;
  // int _start = AppConstants.resendOTPSecs;
  // late Timer _timer;
  bool isHint = true;

  @override
  void initState() {
    // startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        keyboardAppearance: MediaQuery.of(context).platformBrightness,
        controller: widget.textEditingController,
        textInputAction: TextInputAction.done,
        keyboardType: widget.keyBoardType,
        // keyboardType: TextInputType.number,
        style: TextStyle(
          // fontFamily: 'Montserrat',
          color: AppColors.black.withOpacity(0.5),
          fontSize: 14,
        ),
        // Change cursor color
        cursorColor: AppColors.black.withOpacity(0.25),
        onChanged: (String? text) {
          if (StringUtils.isNotNullOrEmpty(text)) {
            setState(() {
              isHint = false;
            });
            if (isNumeric(text)) {
              setState(() {
                widget.errorMsg = null;
                isEmail = false;
              });
            } /*else {
              Pattern pattern = AppConstants.emailPattern;
              RegExp regex = RegExp(pattern.toString());
              if (!regex.hasMatch(text!)) {
                setState(() {
                  widget.errorMsg = 'Please enter a valid email';
                });
              } else {
                widget.errorMsg = null;
              }
              setState(() {
                isEmail = true;
              });
            }*/
            if (text!.length == 1) {
              setState(() {
                isAnimationNeeded = true;
              });
            }
          } else {
            setState(() {
              isHint = true;

              widget.errorMsg = null;
              isAnimationNeeded = false;
              isEmail = null;
            });
          }
        },
        decoration: InputDecoration(
          contentPadding: isHint
              ? EdgeInsets.only(left: 10, bottom: 0, top: 12)
              : EdgeInsets.only(left: 10, bottom: 0, top: 16),
          hintText: widget.hint,
          errorText: widget.errorMsg,
          alignLabelWithHint: true,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.textFiledBorderColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.textFiledBorderColor),
          ),
          prefixIcon: widget.heyChange != null && isEmail != null && !isEmail!
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: SizedBox(
                    height: 20,
                    width: 21,
                    child: CountryCodePicker(
                      initialSelection: 'IN',
                      hideMainText: true,
                      showDropDownButton: false,
                      builder: (countryCode) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 21,
                                child: Image.asset(
                                  'assets/images/flags/${countryCode!.code!.toLowerCase()}.png',
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.grey2,
                                size: 16,
                              )
                              // Text(countryCode.dialCode!),
                            ],
                          ),
                        );
                      },
                      onChanged: (countryCode) {
                        if (widget.heyChange != null) {
                          widget.heyChange!(countryCode);
                        }
                      },
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // _timer.cancel();
    super.dispose();
  }

  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}
