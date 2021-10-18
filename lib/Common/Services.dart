import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml2json/xml2json.dart';

import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/ClassList.dart';

Dio dio = new Dio();
Xml2Json xml2json = new Xml2Json();

class Services {

  static Future<ResponseDataClass> responseHandler(
      {@required apiName, body}) async {
    String url = "";
      url = NODE_API + "$apiName";
      print("===================================url ");
      print(url);
    var header = Options(
      headers: {
        "authorization": "$Access_Token" // set content-length
      },
    );
    var response;
    print("body request");
    print(body);
    print(apiName);
    try {
      if (body == null) {
        response = await dio.post(url, options: header);
      } else {
        response = await dio.post(url, data: body, options: header);
      }
      if (response.statusCode == 200) {
        ResponseDataClass responseData = new ResponseDataClass(
            Message: "No Data", IsSuccess: false, Data: "");
        var data = response.data;
        responseData.Message = data["Message"];
        responseData.IsSuccess = data["IsSuccess"];
        responseData.Data = data["Data"];
        print(responseData.Data);
        return responseData;
      } else {
        print("error ->" + response.data.toString());
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Catch error -> ${e.toString()}");
      throw Exception(e.toString());
    }
  }


  static Future<SaveDataClass> callingToMemberFromWatchmen(body) async {
    print(body.toString());
    String url = API_URL + 'WatchmanAppCalling';
    print("WatchmanAppCalling url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, Data: '0', IsRecord: false);

        xml2json.parse(response.data.toString());
        var jsonData = xml2json.toParker();
        var responseData = json.decode(jsonData);

        print("WatchmanAppCalling Response: " +
            responseData["ResultData"].toString());

        saveData.Message = responseData["ResultData"]["Message"].toString();
        saveData.IsSuccess =
        responseData["ResultData"]["IsSuccess"].toString().toLowerCase() ==
            "true"
            ? true
            : false;
        saveData.Data = responseData["ResultData"]["Data"].toString();

        return saveData;
      } else {
        print("Error CallingToMember");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Error CallingToMember : ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<List> MemberLogin(String staffId) async {
    String url =
        API_URL + 'SocietyStaffLogin?staffId=$staffId';
    print("MemberLogin URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        List list = [];
        print("MemberLogin Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("MemberLoginById Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> SocietyStaffLoginWithMobile(String mobileNo) async {
    String url =
        API_URL + 'SocietyStaffLoginWithMobile?mobileNo=$mobileNo';
    print("SocietyStaffLoginWithMobile URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        List list = [];
        print("SocietyStaffLoginWithMobile Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list.clear();
          if(responseData["Data"]!=0){
          for(int i=0;i<responseData["Data"].length;i++) {
            list.add(responseData["Data"][i]);
          }
          }
        } else {
          list = [0];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("SocietyStaffLoginWithMobile Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> GetSocietyName(String societyId) async {
    String url =
        API_URL + 'GetSocietyName?societyid=$societyId';
    print("GetSocietyName URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        List list = [];
        print("SocietyStaffLoginWithMobile Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("SocietyStaffLoginWithMobile Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> SaveNotice(body) async {
    print(body.toString());
    String url = API_URL + 'SaveNotice';
    print("SaveNotice : " + url);
    dio.options.contentType = Headers.formUrlEncodedContentType;
    dio.options.responseType = ResponseType.json;
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');

        xml2json.parse(response.data.toString());
        var jsonData = xml2json.toParker();
        var responseData = json.decode(jsonData);

        print("SaveNotice Response: " + responseData["ResultData"].toString());

        saveData.Message = responseData["ResultData"]["Message"].toString();
        saveData.IsSuccess =
            responseData["ResultData"]["IsSuccess"] == "true" ? true : false;
        saveData.Data = responseData["ResultData"]["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("App Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> SaveDocument(body) async {
    print(body.toString());
    String url = API_URL + 'SaveDocument';
    print("SaveDocument : " + url);
    dio.options.contentType = Headers.formUrlEncodedContentType;
    dio.options.responseType = ResponseType.json;
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');

        xml2json.parse(response.data.toString());
        var jsonData = xml2json.toParker();
        var responseData = json.decode(jsonData);

        print(
            "SaveDocument Responsefil: " + responseData["ResultData"].toString());

        saveData.Message = responseData["ResultData"]["Message"].toString();
        saveData.IsSuccess =
            responseData["ResultData"]["IsSuccess"] == "true" ? true : false;
        saveData.Data = responseData["ResultData"]["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("App Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<List> getNotice() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetNotice?societyId=$SocietyId';
    print("GetNotice URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("GetNotice Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("GetNotice Erorr : " + e.toString());
      throw Exception(e);
    }
  }
  static Future<SaveDataClass> DeleteNotice(String noticeID) async {
    String url = API_URL + 'DeleteNotice?id=$noticeID';
    print("DeleteNotice URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, IsRecord: false, Data: "");
        print("DeleteNotice Response: " + response.data.toString());
        var responseData = response.data;
        saveData.Message = responseData["Message"];
        saveData.IsSuccess = responseData["IsSuccess"];
        saveData.Data = responseData["Data"].toString();
        return saveData;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("DeleteNotice Erorr : " + e.toString());
      throw Exception(e);
    }
  }
  static Future<List> getDocument() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);
    String url = API_URL + 'GetDocument?societyId=$SocietyId';
    print("GetDocument URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("GetDocument Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("GetDocument Erorr : " + e.toString());
      throw Exception(e);
    }
  }
  static Future<SaveDataClass> DeleteDocument(String id) async {
    String url = API_URL + 'DeleteDocument?id=$id';
    print("DeleteDocument URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, IsRecord: false, Data: "");
        print("DeleteDocument Response: " + response.data.toString());
        var responseData = response.data;
        saveData.Message = responseData["Message"];
        saveData.IsSuccess = responseData["IsSuccess"];
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("DeleteDocument Erorr : " + e.toString());
      throw Exception(e);
    }
  }
  static Future<List> getMembersAllData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetMember?societyId=$SocietyId';
    print("getMembers URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getMembers Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getMembers Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> SendVerficationCode(
      String mobile, String code) async {
    String url = API_URL + 'SendVerificationCode?mobileNo=$mobile&code=$code';
    print("SendVerficationCode URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, IsRecord: false, Data: "");
        print("SendVerficationCode Response: " + response.data.toString());
        var responseData = response.data;
        saveData.Message = responseData["Message"];
        saveData.IsSuccess = responseData["IsSuccess"];
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("SendVerficationCode Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> GetWingData(String SocietyId) async {
    String url = API_URL + 'GetMemberCountByWingId?societyId=$SocietyId';
    print("GetWingData url : " + url);
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("GetWingData Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        print("Error GetWingData");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Error GetWingData   : ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<List> GetMemberByWing(String SocietyId, String WingId) async {
    String url =
        API_URL + 'GetMemberByWing?societyId=$SocietyId&wingId=$WingId';
    print("GetMemberByWing url : " + url);
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("GetMemberByWing Response: " + response.data.toString());
        var RulesData = response.data;
        if (RulesData["IsSuccess"] == true) {
          list = RulesData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        print("Error GetMemberByWing");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Error GetMemberByWing   : ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> AddVisitor(body) async {
    print(body.toString());
    String url = API_URL + 'SaveVisitorsV1';
    print("SaveVisitor : " + url);
    dio.options.contentType = Headers.formUrlEncodedContentType;
    dio.options.responseType = ResponseType.json;
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');

        xml2json.parse(response.data.toString());
        var jsonData = xml2json.toParker();
        var responseData = json.decode(jsonData);

        print("SaveVisitor Response: " + responseData["ResultData"].toString());

        saveData.Message = responseData["ResultData"]["Message"].toString();
        saveData.IsSuccess =
            responseData["ResultData"]["IsSuccess"] == "true" ? true : false;
        saveData.Data = responseData["ResultData"]["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("App Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<List> getRules() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetSocietyRules?societyId=$SocietyId';
    print("getRules URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        List list = [];
        print("getRules Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getRules Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> AddRules(body) async {
    print(body.toString());
    String url = API_URL + 'SaveSocietyRules';
    print("AddRules : " + url);
    dio.options.contentType = Headers.formUrlEncodedContentType;
    dio.options.responseType = ResponseType.json;
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');

        xml2json.parse(response.data.toString());
        var jsonData = xml2json.toParker();
        var responseData = json.decode(jsonData);

        print("AddRules Response: " + responseData["ResultData"].toString());

        saveData.Message = responseData["ResultData"]["Message"].toString();
        saveData.IsSuccess =
            responseData["ResultData"]["IsSuccess"] == "true" ? true : false;
        saveData.Data = responseData["ResultData"]["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("App Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> DeleteRule(String id) async {
    String url = API_URL + 'DeleteSocietyRules?id=$id';
    print("DeleteRule URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, IsRecord: false, Data: "");
        print("DeleteRule Response: " + response.data.toString());
        var responseData = response.data;
        saveData.Message = responseData["Message"];
        saveData.IsSuccess = responseData["IsSuccess"];
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("DeleteRule Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> AddVisitorByScan(String id) async {
    String url = API_URL + 'VisitorOTPVerification?id=$id';
    print("AddVisitorByScan URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, IsRecord: false, Data: "");
        print("AddVisitorByScan Response: " + response.data.toString());
        var responseData = response.data;
        saveData.Message = responseData["Message"].toString();
        saveData.IsSuccess = responseData["IsSuccess"];
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("AddVisitorByScan Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getWingList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetMemberCountByWingId?societyId=$SocietyId';
    print("getWingList URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        print("getWingList Response" + response.data.toString());
        List members = [];
        members = response.data["Data"];
        return members;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getWingList Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getComplaints() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetComplainBySociety?societyId=$SocietyId';
    print("GetComplainBySociety URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        print("GetComplainBySociety Response" + response.data.toString());
        List members = [];
        members = response.data["Data"];
        return members;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("GetComplainBySociety Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> DeleteComplaint(String id) async {
    String url = API_URL + 'DeleteComplain?id=$id';
    print("DeleteComplaint URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, IsRecord: false, Data: "");
        print("DeleteComplaint Response: " + response.data.toString());
        var responseData = response.data;
        saveData.Message = responseData["Message"];
        saveData.IsSuccess = responseData["IsSuccess"];
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("DeleteComplaint Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> AddComplaintToSolve(String id) async {
    String url = API_URL + 'UpdateComplainStatus?complainId=$id';
    print("AddComplaintToSolve URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, IsRecord: false, Data: "");
        print("AddComplaintToSolve Response: " + response.data.toString());
        var responseData = response.data;
        saveData.Message = responseData["Message"];
        saveData.IsSuccess = responseData["IsSuccess"];
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("AddComplaintToSolve Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getEmergencyData() async {
    String url = API_URL + 'GetEmergency';
    print("getEmergencyData URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        List list = [];
        print("getEmergencyData Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong\nPlease Try Again..");
      }
    } catch (e) {
      print("getEmergencyData Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getEvents() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetEvent?societyId=$SocietyId';
    print("getEvents URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        List list = [];
        print("getEvents Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getEvents Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> AddEventGallary(body) async {
    print(body.toString());
    String url = API_URL + 'SaveEventGallery';
    print("AddEventGallary : " + url);
    dio.options.contentType = Headers.formUrlEncodedContentType;
    dio.options.responseType = ResponseType.json;
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');

        xml2json.parse(response.data.toString());
        var jsonData = xml2json.toParker();
        var responseData = json.decode(jsonData);

        print("AddEventGallary Response: " +
            responseData["ResultData"].toString());

        saveData.Message = responseData["ResultData"]["Message"].toString();
        saveData.IsSuccess =
            responseData["ResultData"]["IsSuccess"] == "true" ? true : false;
        saveData.Data = responseData["ResultData"]["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("AddEventGallary Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<List> getEventGallary(String eventid) async {
    String url = API_URL + 'GetEventGallery?eventId=$eventid';
    print("getEventGallary URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getEventGallary Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getEventGallary Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> DeleteEventGallary(String photoId) async {
    String url = API_URL + 'DeleteEventGallery?id=$photoId';
    print("DeleteEventGallary URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, IsRecord: false, Data: "");
        print("DeleteEventGallary Response: " + response.data.toString());
        var responseData = response.data;
        saveData.Message = responseData["Message"];
        saveData.IsSuccess = responseData["IsSuccess"];
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("DeleteEventGallary Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> DeleteEvent(String noticeID) async {
    String url = API_URL + 'DeleteEvent?id=$noticeID';
    print("DeleteEvent URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, IsRecord: false, Data: "");
        print("DeleteEvent Response: " + response.data.toString());
        var responseData = response.data;
        saveData.Message = responseData["Message"];
        saveData.IsSuccess = responseData["IsSuccess"];
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("DeleteEvent Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> AddEvent(body) async {
    print(body.toString());
    String url = API_URL + 'SaveEvent';
    print("AddEvent : " + url);
    dio.options.contentType = Headers.formUrlEncodedContentType;
    dio.options.responseType = ResponseType.json;
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');

        xml2json.parse(response.data.toString());
        var jsonData = xml2json.toParker();
        var responseData = json.decode(jsonData);

        print("AddEvent Response: " + responseData["ResultData"].toString());

        saveData.Message = responseData["ResultData"]["Message"].toString();
        saveData.IsSuccess =
            responseData["ResultData"]["IsSuccess"] == "true" ? true : false;
        saveData.Data = responseData["ResultData"]["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("AddEvent Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<List> getDashBoardCount() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetDashboardCount?societyId=$SocietyId';
    print("getDashBoardCount URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        List list = [];
        print("getDashBoardCount Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getDashBoardCount Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getMembersByWing(String WingId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url =
        API_URL + 'GetMemberByWing?societyId=$SocietyId&wingId=$WingId';
    print("getMembersByWing URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getMembersByWing Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getMembersByWing Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List<memberClass>> getMembersByWingWithClass(
      String wingId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);
    String url =
        API_URL + 'GetMemberByWing?societyId=$SocietyId&wingId=$wingId';
    print("getMembersByWingWithClass Url:" + url);

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        List<memberClass> memberClassList = [];
        print("getMembersByWingWithClass Response" + response.data.toString());

        final jsonResponse = response.data;
        memberClassData data = new memberClassData.fromJson(jsonResponse);

        memberClassList = data.Data;

        return memberClassList;
      } else {
        throw Exception("No Internet Connection");
      }
    } catch (e) {
      print("Check getMembersByWingWithClass Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getVisitorCountByWing() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetVisitorCountByWingId?societyId=$SocietyId';
    print("getVisitorCountByWing URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        List list = [];
        print("getVisitorCountByWing Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getVisitorCountByWing Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getVisitorByWing(
      String wingId, String fromDate, String toDate) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL +
        'GetVisitorByWingId?SocietyId=$SocietyId&WingId=$wingId&FromDate=$fromDate&ToDate=$toDate';
    print("getVisitorByWing URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getVisitorByWing Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getVisitorByWing Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getStaffByWing(
      String wingId, String fromDate, String toDate) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL +
        'GetStaffsByWingId?SocietyId=$SocietyId&WingId=$wingId&FromDate=$fromDate&ToDate=$toDate';
    print("getVisitorByWing URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getVisitorByWing Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getVisitorByWing Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getVisitorByMemberId(String memberId) async {
    String url = API_URL + 'GetVisitorByMemberId?memberId=$memberId';
    print("getVisitorByMemberId URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getIncome Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getVisitorByMemberId Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getFamilyByMember(String memberId) async {
    String url = API_URL + 'GetFamilyMember?parentId=0&memberId=$memberId';
    print("getFamilyByMember URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getFamilyByMember Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getFamilyByMember Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getVehicleByMember(String memberId) async {
    String url = API_URL + 'GetMemberVehicleDetail?memberId=$memberId';
    print("getVehicleByMember URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getVehicleByMember Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getVehicleByMember Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getIncome(String month, String year) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL +
        'GetMonthlyIncomeBySocity?societyId=$SocietyId&month=$month&year=$year';
    print("getIncome URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getIncome Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getIncome Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getExpense(String month, String year) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL +
        'GetMonthlyExpenseBySocity?societyId=$SocietyId&month=$month&year=$year';
    print("getExpense URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getExpense Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getExpense Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getBalanceSheet() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetBalanceSheetBySociety?societyId=$SocietyId';
    print("getBalanceSheet URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getBalanceSheet Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getBalanceSheet Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getExpenseYearly(String year) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url =
        API_URL + 'GetYearlyExpenseBySocity?societyId=$SocietyId&year=$year';
    print("getExpenseYearly URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getExpenseYearly Response: " + response.data.toString());
        print("getExpenseYearly Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getExpenseYearly Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getIncomeYearly(String year) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url =
        API_URL + 'GetYearlyIncomeBySocity?societyId=$SocietyId&year=$year';
    print("getIncomeYearly URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getIncomeYearly Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getIncomeYearly Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> AddIncome(body) async {
    print(body.toString());
    String url = API_URL + 'SaveIncome';
    print("SaveIncome : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');
        var responseData = response.data;

        print("SaveIncome Response: " + responseData.toString());

        saveData.Message = responseData["Message"].toString();
        saveData.IsSuccess =
            responseData["IsSuccess"].toString() == "true" ? true : false;
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("App Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> AddExpense(body) async {
    print(body.toString());
    String url = API_URL + 'SaveExpense';
    print("AddExpense : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');
        var responseData = response.data;

        print("SaveIncome Response: " + responseData.toString());

        saveData.Message = responseData["Message"].toString();
        saveData.IsSuccess =
            responseData["IsSuccess"].toString() == "true" ? true : false;
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("App Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> AddIncomeSource(body) async {
    print(body.toString());
    String url = API_URL + 'SaveIncomeSource';
    print("SaveIncomeSource : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');
        var responseData = response.data;

        print("SaveIncomeSource Response: " + responseData.toString());

        saveData.Message = responseData["Message"].toString();
        saveData.IsSuccess =
            responseData["IsSuccess"].toString() == "true" ? true : false;
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("App Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<List<incomeSource>> getIncomeSource() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);
    String url = API_URL + 'GetIncomeSource?societyId=$SocietyId';
    print("getIncomeSource Url:" + url);

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        List<incomeSource> incomeSourceList = [];
        print("getIncomeSource Response" + response.data.toString());

        final jsonResponse = response.data;
        incomeSourceData data = new incomeSourceData.fromJson(jsonResponse);

        incomeSourceList = data.Data;

        return incomeSourceList;
      } else {
        throw Exception("No Internet Connection");
      }
    } catch (e) {
      print("Check getIncomeSource Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> DeleteIncomeSource(String id) async {
    String url = API_URL + 'DeleteIncomeSource?id=$id';
    print("DeleteIncomeSource URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, IsRecord: false, Data: "");
        print("DeleteIncomeSource Response: " + response.data.toString());
        var responseData = response.data;
        saveData.Message = responseData["Message"];
        saveData.IsSuccess = responseData["IsSuccess"];
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("DeleteIncomeSource Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> AddExpenseSource(body) async {
    print(body.toString());
    String url = API_URL + 'SaveExpenseType';
    print("AddExpenseSource : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');
        var responseData = response.data;

        print("AddExpenseSource Response: " + responseData.toString());

        saveData.Message = responseData["Message"].toString();
        saveData.IsSuccess =
            responseData["IsSuccess"].toString() == "true" ? true : false;
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("App Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> DeleteExpenseSource(String id) async {
    String url = API_URL + 'DeleteExpenseType?id=$id';
    print("DeleteExpenseSource URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, IsRecord: false, Data: "");
        print("DeleteExpenseSource Response: " + response.data.toString());
        var responseData = response.data;
        saveData.Message = responseData["Message"];
        saveData.IsSuccess = responseData["IsSuccess"];
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("DeleteExpenseSource Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List<expenseSource>> getExpenseSource() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);
    String url = API_URL + 'GetExpenseType?societyId=$SocietyId';
    print("getExpenseSource Url:" + url);

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        List<expenseSource> expenseSourceList = [];
        print("getExpenseSource Response" + response.data.toString());

        final jsonResponse = response.data;
        expenseSourceData data = new expenseSourceData.fromJson(jsonResponse);

        expenseSourceList = data.Data;

        return expenseSourceList;
      } else {
        throw Exception("No Internet Connection");
      }
    } catch (e) {
      print("Check getExpenseSource Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getPaymentMode() async {
    String url = API_URL + 'GetPaymentMode';
    print("getPaymentMode URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List<paymentTypeClass> paymentTypeClassList = [];
        print("getExpenseSource Response" + response.data.toString());

        final jsonResponse = response.data;
        paymentTypeClassData data =
            new paymentTypeClassData.fromJson(jsonResponse);

        paymentTypeClassList = data.Data;

        return paymentTypeClassList;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getPaymentMode Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getPollingList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetPollingCountList?societyId=$SocietyId';
    print("getPollingList URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getPollingList Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getPollingList Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> AddPollingQuation(body) async {
    print(body.toString());
    String url = API_URL + 'SavePolling';
    print("SavePolling : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');
        var responseData = response.data;

        print("SavePolling Response: " + responseData.toString());

        saveData.Message = responseData["Message"].toString();
        saveData.IsSuccess =
            responseData["IsSuccess"].toString() == "true" ? true : false;
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("App Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> UpdatePolling(body) async {
    print(body.toString());
    String url = API_URL + 'UpdatePolling';
    print("UpdatePolling : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');
        var responseData = response.data;

        print("UpdatePolling Response: " + responseData.toString());

        saveData.Message = responseData["Message"].toString();
        saveData.IsSuccess =
            responseData["IsSuccess"].toString() == "true" ? true : false;
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("App Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> AddPollingAnswer(body) async {
    print(body.toString());
    String url = API_URL + 'SavePollingOption';
    print("SavePollingOption : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');
        var responseData = response.data;

        print("SavePollingOption Response: " + responseData.toString());

        saveData.Message = responseData["Message"].toString();
        saveData.IsSuccess =
            responseData["IsSuccess"].toString() == "true" ? true : false;
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("App Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<List<WingClass>> GetWinglistData(String SocietyId) async {
    String url = API_URL + 'GetWingBySocietyId?societyId=$SocietyId';
    print("GetWinglistData:" + url);

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        List<WingClass> member = [];
        print("GetWinglistData Response" + response.data.toString());

        final jsonResponse = response.data;
        WingClassData memberData = new WingClassData.fromJson(jsonResponse);

        member = memberData.Data;

        return member;
      } else {
        throw Exception("No Internet Connection");
      }
    } catch (e) {
      print("Check GetWinglistData Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List<FlatClass>> GetFlatlistData(String WingId) async {
    String url = API_URL + 'GetFlatByWing?WingId=$WingId';
    print("getFlatData:" + url);

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        List<FlatClass> flat = [];
        print("getFlatData Response" + response.data.toString());

        final jsonResponse = response.data;
        FlatClassData flatClassData = new FlatClassData.fromJson(jsonResponse);

        flat = flatClassData.Data;

        return flat;
      } else {
        throw Exception("No Internet Connection");
      }
    } catch (e) {
      print("Check getFlatData Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List<staffClass>> GetStaffTypes() async {
    String url = API_URL + 'GetStaffType';
    print("GetStaffType Url:" + url);

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        List<staffClass> member = [];
        print("GetStaffType Response" + response.data.toString());

        final jsonResponse = response.data;
        staffClassData responseData = new staffClassData.fromJson(jsonResponse);

        member = responseData.Data;

        return member;
      } else {
        throw Exception("No Internet Connection");
      }
    } catch (e) {
      print("Check GetStaffType Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getVisitorType(String type) async {
    String url = API_URL + 'GetVisitorType?type=$type';
    print("GetVisitorType url : " + url);
    try {
      final response = await dio.get(
        url,
      );
      if (response.statusCode == 200) {
        List list = [];
        print("GetVisitorType Response: " + response.data.toString());
        var VisitorType = response.data;
        if (VisitorType["IsSuccess"] == true) {
          print(VisitorType["Data"]);
          list = VisitorType["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        print("Error GetVisitorType");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Error GetVisitorType   : ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<List> getCompanyName() async {
    String url = API_URL + 'GetCompany';
    print("getCompany url : " + url);
    try {
      final response = await dio.get(
        url,
      );
      if (response.statusCode == 200) {
        List list = [];
        print("getCompany Response: " + response.data.toString());
        var CompanyTypeData = response.data;
        if (CompanyTypeData["IsSuccess"] == true) {
          print(CompanyTypeData["Data"]);
          list = CompanyTypeData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        print("Error getCompany");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Error getCompany   : ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<List> getPurpose() async {
    String url = API_URL + 'GetPurpose';
    print("GetPurpose url : " + url);
    try {
      final response = await dio.get(
        url,
      );
      if (response.statusCode == 200) {
        List list = [];
        print("GetPurpose Response: " + response.data.toString());
        var CompanyTypeData = response.data;
        if (CompanyTypeData["IsSuccess"] == true) {
          print(CompanyTypeData["Data"]);
          list = CompanyTypeData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        print("Error GetPurpose");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Error GetPurpose   : ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> SaveStaff(body) async {
    print(body.toString());
    String url = API_URL + 'SaveStaffDetail';
    print("SaveStaffDetail url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, Data: '0', IsRecord: false);

        xml2json.parse(response.data.toString());
        var jsonData = xml2json.toParker();
        var responseData = json.decode(jsonData);

        print("SaveStaffDetail Response: " +
            responseData["ResultData"].toString());

        saveData.Message = responseData["ResultData"]["Message"].toString();
        saveData.IsSuccess =
            responseData["ResultData"]["IsSuccess"].toString().toLowerCase() ==
                    "true"
                ? true
                : false;
        saveData.Data = responseData["ResultData"]["Data"].toString();

        return saveData;
      } else {
        print("Error SaveStaffDetail");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Error SaveStaffDetail : ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  // static Future<List> getScanVisitorByQR_or_Code(
  //     String SocietyId, String Type, String UniqCode, String Id) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //
  //   String url = API_URL +
  //       'GetVisitorStaffUniqueCode?SocietyId=$SocietyId&Type=$Type&UniqCode=$UniqCode&Id=$Id';
  //   print("GetVisitorDataByCode Or QR URL: " + url);
  //   try {
  //     Response response = await dio.get(url);
  //
  //     if (response.statusCode == 200) {
  //       List list = [];
  //       print(
  //           "GetVisitorDataByCode Or QR Response: " + response.data.toString());
  //       var responseData = response.data;
  //       if (responseData["IsSuccess"] == true) {
  //         list = responseData["Data"];
  //       } else {
  //         list = [];
  //       }
  //       return list;
  //     } else {
  //       throw Exception("Something Went Wrong");
  //     }
  //   } catch (e) {
  //     print("GetVisitorDataByCode Or QR Erorr : " + e.toString());
  //     throw Exception(e);
  //   }
  // }
  static Future<List> getScanVisitorByQR_or_Code(
      String SocietyId, String Type, String UniqCode, String Id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String url = API_URL +
        'GetVisitorStaffUniqueCode?SocietyId=$SocietyId&Type=$Type&UniqCode=$UniqCode&Id=$Id';
    print("GetVisitorDataByCode Or QR URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        List list = [];
        print(
            "GetVisitorDataByCode Or QR Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("GetVisitorDataByCode Or QR Error : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> CheckInVisitorStaff(body) async {
    print(body.toString());
    String url = API_URL + 'CheckInV1';
    print("CheckInData : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');
        var responseData = response.data;

        print("CheckInData Response: " + responseData.toString());

        saveData.Message = responseData["Message"].toString();
        saveData.IsSuccess =
            responseData["IsSuccess"].toString() == "true" ? true : false;
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("App Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<List> getVisitorData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetVisitorsData?societyId=$SocietyId';
    print("getVisitorData URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getVisitorData Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getVisitorData Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> SaveVisitor(body) async {
    print(body.toString());
    String url = API_URL + 'SaveVisitors';
    print("SaveVisitorData url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, Data: '0', IsRecord: false);

        xml2json.parse(response.data.toString());
        var jsonData = xml2json.toParker();
        var responseData = json.decode(jsonData);

        print("SaveVisitorData Response: " +
            responseData["ResultData"].toString());

        saveData.Message = responseData["ResultData"]["Message"].toString();
        saveData.IsSuccess =
            responseData["ResultData"]["IsSuccess"].toString().toLowerCase() ==
                    "true"
                ? true
                : false;
        saveData.Data = responseData["ResultData"]["Data"].toString();

        return saveData;
      } else {
        print("Error SaveVisitorData");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Error SaveVisitorData : ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> SaveVisitorsV1(body) async {
    print(body.toString());
    String url = API_URL + 'SaveVisitorsV1';
    print("SaveVisitorsV1 url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, Data: '0', IsRecord: false);

        xml2json.parse(response.data.toString());
        var jsonData = xml2json.toParker();
        var responseData = json.decode(jsonData);

        print("SaveVisitorsV1 Response: " +
            responseData["ResultData"].toString());

        saveData.Message = responseData["ResultData"]["Message"].toString();
        saveData.IsSuccess =
            responseData["ResultData"]["IsSuccess"].toString().toLowerCase() ==
                    "true"
                ? true
                : false;
        saveData.Data = responseData["ResultData"]["Data"].toString();

        return saveData;
      } else {
        print("Error SaveVisitorsV1");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Error SaveVisitorsV1 : ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<List> SendTokanToServer(String fcmToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String memberId = prefs.getString(Session.MemberId);

    String url =
        API_URL + 'SocietyStaffFcmUpdate?Id=$memberId&FcmToken=$fcmToken';
    print("SendTokanToServer URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        List list = [];
        print("SendTokanToServer Response: " + response.data.toString());
        var memberDataClass = response.data;
        if (memberDataClass["IsSuccess"] == true &&
            memberDataClass["IsRecord"] == true) {
          print(memberDataClass["Data"]);
          list = memberDataClass["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something went wrong");
      }
    } catch (e) {
      print("SendTokanToServer : " + e.toString());
      throw Exception("Something went wrong");
    }
  }

  static Future<SaveDataClass> AddAMC(body) async {
    print(body.toString());
    String url = API_URL + 'AddAMCStatus';
    print("AddAMCStatus : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');
        var responseData = response.data;

        print("AddAMCStatus Response: " + responseData.toString());

        saveData.Message = responseData["Message"].toString();
        saveData.IsSuccess =
            responseData["IsSuccess"].toString() == "true" ? true : false;
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("App Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<List> getFlatData(String WingId) async {
    String url = API_URL + 'GetFlatByWing?WingId=$WingId';
    print("getFlatByWing URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getFlatByWing Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getFlatByWing Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getAMC() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String societyId = prefs.getString(Session.SocietyId);
    String url = API_URL + 'GetAMCStatus?SocietyId=$societyId';
    print("getAMC URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getAMC Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getAMC Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getInsideVisitorData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetVisitorCheckInList?societyId=$SocietyId';
    print("getInsideVisitorData URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getInsideVisitorData Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          print("----." + responseData["Data"].toString());
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getInsideVisitorData Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getOutSideVisitorData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetVisitorCheckOutList?societyId=$SocietyId';
    print("getOutsideVisitorData URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getOutsideVisitorData Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          print(responseData["Data"].toString());
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getOutsideVisitorData Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> UpdateOutTime(String entryid) async {
    String url = API_URL + 'CheckOut?EntryId=$entryid';
    print("CheckOutUpdate URL: " + url);
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        SaveDataClass saveData = new SaveDataClass(
            Message: 'No Data', IsSuccess: false, IsRecord: false, Data: "");
        print("CheckOutUpdate Response: " + response.data.toString());
        var responseData = response.data;
        saveData.Message = responseData["Message"];
        saveData.IsSuccess = responseData["IsSuccess"];
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("CheckOutUpdate Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getStaffData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetStaffData?SocietyId=$SocietyId';
    print("GetStaffData URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("GetStaffData Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          print("----." + responseData["Data"].toString());
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("GetStaffData Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<SaveDataClass> Savestaff(body) async {
    print(body.toString());
    String url = API_URL + 'SaveStaffs';
    print("SaveStaff : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');
        var responseData = response.data;

        print("SaveStaff Response: " + responseData.toString());

        saveData.Message = responseData["Message"].toString();
        saveData.IsSuccess =
            responseData["IsSuccess"].toString() == "true" ? true : false;
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("App Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<List> getInsideStaffData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetStaffCheckInList?SocietyId=$SocietyId';
    print("getInsideStaffData URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getInsideStaffData Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          print("----." + responseData["Data"].toString());
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getInsideStaffData Erorr : " + e.toString());
      throw Exception(e);
    }
  }

  static Future<List> getOutSideStaffData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String SocietyId = preferences.getString(Session.SocietyId);

    String url = API_URL + 'GetStaffCheckOutList?societyId=$SocietyId';
    print("getOutsideVisitorData URL: " + url);
    try {
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        List list = [];
        print("getOutsideVisitorData Response: " + response.data.toString());
        var responseData = response.data;
        if (responseData["IsSuccess"] == true) {
          print(responseData["Data"].toString());
          list = responseData["Data"];
        } else {
          list = [];
        }
        return list;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("getOutsideVisitorData Erorr : " + e.toString());
      throw Exception(e);
    }

  }

  static Future<SaveDataClass> checkInVisitorOrStaff(body) async {
    print(body.toString());
    String url = API_URL + 'CheckInV1';
    print("CheckIn Data : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: '0');
        var responseData = response.data;

        print("CheckIn Data Response: " + responseData.toString());

        saveData.Message = responseData["Message"].toString();
        saveData.IsSuccess =
            responseData["IsSuccess"].toString() == "true" ? true : false;
        saveData.Data = responseData["Data"].toString();

        return saveData;
      } else {
        print("Server Error");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("App Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<List<StaffType>> getRoleType() async {
    String url = API_URL + 'GetRoles';
    print("getRoles URL:" + url);

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        List<StaffType> staff = [];
        print("getRoles URL Response" + response.data.toString());

        final jsonResponse = response.data;
        StaffTypeData staffData = new StaffTypeData.fromJson(jsonResponse);

        staff = staffData.Data;

        return staff;
      } else {
        throw Exception("No Internet Connection");
      }
    } catch (e) {
      print("Check getRoles URL Erorr : " + e.toString());
      throw Exception(e);
    }
  }
}
