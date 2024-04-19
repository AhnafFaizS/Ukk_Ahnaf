import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/constant/endpoint.dart';
import '../../../data/model/user/response_login.dart';
import '../../../data/provider/api_provider.dart';
import '../../../data/provider/storage_provider.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {

  final loadinglogin = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  var isPasswordHidden = true.obs;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  loginPost() async {
    loadinglogin(true);
    try {
      FocusScope.of(Get.context!).unfocus();
      formKey.currentState?.save();
      if (formKey.currentState!.validate()) {
        final response = await ApiProvider.instance().post(Endpoint.login,
            data: dio.FormData.fromMap(
                {
                  "email": emailController.text.toString(),
                  "password": passwordController.text.toString()
                }
            )
        );
        if (response.statusCode == 200) {
          ResponseLogin responseLogin = ResponseLogin.fromJson(response.data);
          await StorageProvider.write(StorageKey.status, "logged");
          await StorageProvider.write(StorageKey.username, responseLogin.data!.username.toString());
          await StorageProvider.write(StorageKey.tokenUser, responseLogin.data!.token.toString());
          await StorageProvider.write(StorageKey.idUser, responseLogin.data!.id.toString());
          await StorageProvider.write(StorageKey.email, responseLogin.data!.email.toString());
          await StorageProvider.write(StorageKey.bio, responseLogin.data!.bio.toString());
          await StorageProvider.write(StorageKey.namaLengkap, responseLogin.data!.namaLengkap.toString());
          await StorageProvider.write(StorageKey.telepon, responseLogin.data!.telepon.toString());

          String username =  StorageProvider.read(StorageKey.username);
          _showMyDialog(
                  (){
                Get.offAllNamed(Routes.DASHBOARD);
              },
              Icons.check_circle,
              "Login Berhasil",
              "Selamat Datang Kembali $username",
              "Lanjut");
        } else {
          _showMyDialog(
                  (){
                Navigator.pop(Get.context!, 'OK');
              },
              Icons.alarm_rounded,
              "Pemberitahuan",
              "Login Gagal, Coba kembali masuk dengan akun anda",
              "Ok"
          );
        }
      }
      loadinglogin(false);
    } on dio.DioException catch (e) {
      loadinglogin(false);
      if (e.response != null) {
        if (e.response?.data != null) {
          _showMyDialog(
                  (){
                Navigator.pop(Get.context!, 'OK');
              },
              Icons.alarm_rounded,
              "Pemberitahuan",
              "${e.response?.data['message']}",
              "Ok"
          );
        }
      } else {
        _showMyDialog(
              (){
            Navigator.pop(Get.context!, 'OK');
          },
          Icons.alarm_rounded,
          "Pemberitahuan",
          e.message ?? "",
          "OK",
        );
      }
    } catch (e) {
      loadinglogin(false);
      _showMyDialog(
            (){
          Navigator.pop(Get.context!, 'OK');
        },
        Icons.alarm_rounded,
        "Error",
        e.toString(),
        "OK",
      );
    }
  }

  Future<void> _showMyDialog(final onPressed, final IconData icons, String judul, String deskripsi, String nameButton) async {
    return showDialog<void>(
      context: Get.context!,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            icons,
            color: Colors.white,
            size: 50,
          ),
          backgroundColor: const Color(0xFF5000CA),
          title: Text(
            'ReadHub App',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 16.0,
              color: const Color(0xFFFFFFFF),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  judul,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 18.0
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  deskripsi,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 14.0
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: TextButton(
                autofocus: true,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F5F5),
                  animationDuration: const Duration(milliseconds: 300),
                ),
                onPressed: onPressed,
                child: Text(
                  nameButton,
                  style: GoogleFonts.poppins(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5000CA),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}
