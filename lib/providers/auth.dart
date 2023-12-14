
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/util/contact-method.dart';
import 'package:provider/provider.dart';
import "package:gigachat/api/user-class.dart";

class Auth extends ChangeNotifier{
  static Auth getInstance(BuildContext context){
    return Provider.of<Auth>(context , listen: false);
  }

  //TODO: change back to null
  User? _currentUser;

  Future<void> login(String username , String password , { void Function(ApiResponse<User>)? success , void Function(ApiResponse<User>)? error}) async {
    var res = await Account.apiLogin(username , password);
    if (res.data != null){
      _currentUser = res.data;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  User? getCurrentUser(){
    return _currentUser;
  }

  logout() async {
    if (_currentUser == null) {
      return;
    }
    bool ok = await Account.apiLogout(_currentUser!);
    if (ok){
      _currentUser = null;
    }
    notifyListeners();
  }

  bool get isLoggedIn {
    return _currentUser != null;
  }

  Future<List<ContactMethod>?> getContactMethods(String email , void Function(List<ContactMethod>) success ) async {
    var methods = await Account.apiGetContactMethods(email);
    if (methods != null){
      success(methods);
    }
    return methods;
  }

  Future<void> requestVerificationMethod(ContactMethod method , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiRequestVerificationMethod(method);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  Future<void> verifyMethod(ContactMethod method , String code ,String? token,bool isVerify, { void Function(ApiResponse<dynamic>)? success , void Function(ApiResponse<dynamic>)? error}) async {
    var res = await Account.apiVerifyMethod(method , code, isVerify,token);
    if (res.data != null){
      if(!isVerify) {
        _currentUser = res.data;
      }else{
        _currentUser!.email = res.data;
      }
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  Future<void> isValidEmail(String email , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiIsEmailValid(email);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> registerUser(String name , String email , String dob , { void Function(ApiResponse<ContactMethod>)? success , void Function(ApiResponse<ContactMethod>)? error}) async {
    var res = await Account.apiRegister(name , email , dob);
    if (res.code == ApiResponse.CODE_SUCCESS){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> createNewUserPassword(String password , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiCreateNewPassword(_currentUser!.auth! , password);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> setUserProfileImage(File img , { void Function(ApiResponse<String>)? success , void Function(ApiResponse<String>)? error}) async {
    var res = await Account.apiSetProfileImage(_currentUser!.auth! , img);
    if (res.data != null){
      _currentUser!.iconLink = res.data!;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  Future<void> setUserUsername(String name , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiSetUsername(_currentUser!.auth! , name);
    if (res.data!){
      //update the new username
      _currentUser!.id = name;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> changeUserUsername(String name , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiChangeUsername(_currentUser!.auth! , name);
    if (res.data!){
      //update the new username
      _currentUser!.id = name;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> verifyUserPassword(String password , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiVerifyPassword(_currentUser!.auth! , password);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> changeUserEmail(String email , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiChangeEmail(_currentUser!.auth! , email);
    if (res.data != null){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> changeUserPassword(String oldPassword, String newPassword , { void Function(ApiResponse<String>)? success , void Function(ApiResponse<String>)? error}) async {
    var res = await Account.apiChangePassword(_currentUser!.auth! , oldPassword, newPassword);
    if (res.data != null){
      _currentUser!.auth = res.data;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> setUserInfo(String name,String bio,String website, String location,DateTime birthDate,
      { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiUpdateUserInfo(_currentUser!.auth! , name,bio,website,location,birthDate);
    if (res.data!){
      _currentUser!.name = name;
      _currentUser!.birthDate = birthDate;
      _currentUser!.website = website;
      _currentUser!.location = location;
      _currentUser!.bio = bio;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> setUserBannerImage(File img , { void Function(ApiResponse<String>)? success , void Function(ApiResponse<String>)? error}) async {
    var res = await Account.apiSetBannerImage(_currentUser!.auth! , img);
    if (res.data != null){
      _currentUser!.bannerLink = res.data!;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  Future<void> follow(String username, { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.followUser(_currentUser!.auth! ,username);
    if (res.data!){
      _currentUser!.following++;
      notifyListeners();
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> unfollow(String username, { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.unfollowUser(_currentUser!.auth! ,username);
    if (res.data!){
      _currentUser!.following--;
      notifyListeners();
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> block(String username, { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.blockUser(_currentUser!.auth! ,username);
    if (res.data!){
      _currentUser!.following--;
      notifyListeners();
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> unblock(String username, { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.unblockUser(_currentUser!.auth! ,username);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> mute(String username, { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.muteUser(_currentUser!.auth! ,username);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> unmute(String username, { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.unmuteUser(_currentUser!.auth! ,username);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

}