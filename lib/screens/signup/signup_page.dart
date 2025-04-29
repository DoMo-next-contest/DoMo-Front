import 'package:flutter/material.dart';
import 'package:domo/utils/responsive.dart';
import 'package:domo/screens/welcome/components/background.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '', _id = '', _email = '', _password = '';

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pushReplacementNamed(context, '/onboardingStep2');
    }
  }

  /// 1) 393×852 Figma artboard 그대로
  Widget _figmaArtboard() {
    return SizedBox(
      width: 393,
      height: 852,
      child: Stack(children: [
        Positioned(
          left: 29,
          top: 0,
          child: Container(
            width: 335,
            height: 852,
            padding: const EdgeInsets.only(top: 55),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // progress bar
                Container(
                  width: double.infinity,
                  height: 5,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFEEEEEE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  child: Stack(children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 83.75,
                        height: 5,
                        color: const Color(0xFFAB4E18),
                      ),
                    )
                  ]),
                ),
                const SizedBox(height: 8),
                const SizedBox(
                  width: 335,
                  child: Text(
                    'Step 1/4',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 101),
                // title
                const SizedBox(
                  width: 335,
                  child: Text(
                    '지금 Domo에 가입하세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildField('이름', '홍길동', (v) => _name = v!),
                      const SizedBox(height: 28),
                      _buildField('ID', 'userid', (v) => _id = v!),
                      const SizedBox(height: 28),
                      _buildField('이메일', 'example@gmail.com', (v) => _email = v!),
                      const SizedBox(height: 28),
                      _buildField('패스워드', '********', (v) => _password = v!, obscure: true),
                    ],
                  ),
                ),
                const Spacer(),
                // buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 취소
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 16,
                            offset: Offset(0, 2),
                          )
                        ],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Color(0xFFC78E48),
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            letterSpacing: 0.10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 다음
                    Container(
                      height: 40,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFAB4E18),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 16,
                            offset: Offset(0, 2),
                          )
                        ],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: TextButton(
                        onPressed: _onSubmit,
                        child: const Text(
                          '다음',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            letterSpacing: 0.10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  /// 2) 한글 · Inter · Roboto 조합의 rounded field
  Widget _buildField(
    String label,
    String hint,
    FormFieldSetter<String> onSaved, {
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: ShapeDecoration(
            color: Colors.white,
            shadows: const [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 16,
                offset: Offset(0, 2),
              )
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: TextFormField(
            obscureText: obscure,
            decoration: InputDecoration.collapsed(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFB3B3B3),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.40,
              ),
            ),
            style: const TextStyle(color: Colors.black, fontSize: 16),
            onSaved: onSaved,
            validator: (v) => v == null || v.isEmpty ? '필수 항목입니다' : null,
          ),
        ),
      ],
    );
  }

  /// 3) fitHeight 로 높이 딱 맞추는 wrapper
  Widget _buildFigmaCard(double width, double height) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Colors.white),
      child: FittedBox(
        fit: BoxFit.fitHeight,
        alignment: Alignment.topCenter,
        child: _figmaArtboard(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final cardWidth = sw < 600 ? sw * 0.9 : 393.0;

    return Background(
      child: SafeArea(
        child: Responsive(
          mobile: Center(child: _buildFigmaCard(cardWidth, sh)),
          tablet: Center(child: _buildFigmaCard(393.0, sh)),
          desktop: LayoutBuilder(
            builder: (_, cons) => Center(child: _buildFigmaCard(393.0, cons.maxHeight)),
          ),
        ),
      ),
    );
  }
}