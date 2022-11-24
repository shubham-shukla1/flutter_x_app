import 'package:flutter/material.dart';
import 'package:basic_utils/basic_utils.dart';

import '../../shared/app_constants.dart';
import '../../shared/app_theme/app_colors/app_colors.dart';
import '../../own_package/country_picker/country_code.dart';
import '../../own_package/country_picker/country_code_picker.dart';

class MobileTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String hint;
  final Function(CountryCode)? heyChange;
  late String? errorMsg;
  late TextInputType? keyBoardType = TextInputType.text;

  MobileTextField({
    required this.textEditingController,
    required this.hint,
    required this.heyChange,
    required this.errorMsg,
    this.keyBoardType,
    Key? key,
  }) : super(key: key);

  @override
  State<MobileTextField> createState() => _MobileTextFieldState();
}

class _MobileTextFieldState extends State<MobileTextField> {
  bool? isEmail;
  bool? isAnimationNeeded = false;
  bool isHint = true;

  @override
  void initState() {
    if (StringUtils.isNotNullOrEmpty(widget.textEditingController.text)) {
      setState(() {
        isHint = false;
      });
      if (isNumeric(widget.textEditingController.text)) {
        setState(() {
          widget.errorMsg = null;
          isEmail = false;
        });
      } else {
        Pattern pattern = AppConstants.emailPattern;
        RegExp regex = RegExp(pattern.toString());
        if (!regex.hasMatch(widget.textEditingController.text)) {
          setState(() {
            widget.errorMsg = 'Please enter a valid email';
          });
        } else {
          widget.errorMsg = null;
        }
        setState(() {
          isEmail = true;
        });
      }
      if (widget.textEditingController.text.length == 1) {
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
            } else {
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
            }
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
          hintText: widget.hint,
          errorText: widget.errorMsg,
          alignLabelWithHint: true,
          contentPadding: isHint
              ? EdgeInsets.only(left: 8, right: 0, bottom: 0, top: 13)
              : EdgeInsets.only(left: 8, right: 0, bottom: 0, top: 20),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.textFiledBorderColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.textFiledBorderColor),
          ),
          prefixIcon: widget.heyChange != null && isEmail != null && !isEmail!
              ? Padding(
                  padding: EdgeInsets.only(top: 18, bottom: 5),
                  child: SizedBox(
                    height: 20,
                    width: 21,
                    child: CountryCodePicker(
                      initialSelection: 'IN',
                      hideMainText: true,
                      showDropDownButton: false,
                      builder: (countryCode) {
                        return Row(
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
          suffixIcon: isEmail == null
              ? SizedBox.shrink()
              : isEmail! && widget.heyChange != null
                  ? AnimatedOpacity(
                      opacity: isAnimationNeeded! ? 1 : 0,
                      duration: Duration(milliseconds: 900),
                      child: Padding(
                        padding: EdgeInsets.only(left: 15, bottom: 0, top: 18),
                        child: Icon(
                          Icons.email_rounded,
                          color: AppColors.grey1,
                          size: 18,
                        ),
                      ),
                    )
                  : widget.heyChange != null
                      ? AnimatedOpacity(
                          opacity: isAnimationNeeded! ? 1 : 0,
                          duration: Duration(milliseconds: 900),
                          child: Padding(
                            padding: EdgeInsets.only(left: 15, top: 18),
                            child: Icon(
                              Icons.call,
                              color: AppColors.grey1,
                              size: 18,
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
        ),
      ),
    );
  }

  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}
