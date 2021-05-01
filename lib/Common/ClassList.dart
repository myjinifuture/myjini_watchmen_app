import 'dart:convert';

class ResponseDataClass {
  String Message;
  bool IsSuccess;
  var Data;

  ResponseDataClass({this.Message, this.IsSuccess, this.Data});

  factory ResponseDataClass.fromJson(Map<String, dynamic> json) {
    return ResponseDataClass(
      Message: json['Message'] as String,
      IsSuccess: json['IsSuccess'] as bool,
      Data: json['Data'] as dynamic,
    );
  }
}

class SaveDataClass {
  String Message;
  bool IsSuccess;
  bool IsRecord;
  String Data;

  SaveDataClass({this.Message, this.IsSuccess, this.IsRecord, this.Data});

  factory SaveDataClass.fromJson(Map<String, dynamic> json) {
    return SaveDataClass(
        Message: json['Message'] as String,
        IsSuccess: json['IsSuccess'] as bool,
        IsRecord: json['IsRecord'] as bool,
        Data: json['Data'] as String);
  }
}

class incomeSourceData {
  String Message;
  bool IsSuccess;
  List<incomeSource> Data;

  incomeSourceData({
    this.Message,
    this.IsSuccess,
    this.Data,
  });

  factory incomeSourceData.fromJson(Map<String, dynamic> json) {
    return incomeSourceData(
        Message: json['Message'] as String,
        IsSuccess: json['IsSuccess'] as bool,
        Data: json['Data']
            .map<incomeSource>((json) => incomeSource.fromJson(json))
            .toList());
  }
}

class incomeSource {
  String id;
  String sourceName;

  incomeSource({this.id, this.sourceName});

  factory incomeSource.fromJson(Map<String, dynamic> json) {
    return incomeSource(
        id: json['Id'].toString(),
        sourceName: json['Title'].toString());
  }
}

class expenseSourceData {
  String Message;
  bool IsSuccess;
  List<expenseSource> Data;

  expenseSourceData({
    this.Message,
    this.IsSuccess,
    this.Data,
  });

  factory expenseSourceData.fromJson(Map<String, dynamic> json) {
    return expenseSourceData(
        Message: json['Message'] as String,
        IsSuccess: json['IsSuccess'] as bool,
        Data: json['Data']
            .map<expenseSource>((json) => expenseSource.fromJson(json))
            .toList());
  }
}

class expenseSource {
  String id;
  String sourceName;

  expenseSource({this.id, this.sourceName});

  factory expenseSource.fromJson(Map<String, dynamic> json) {
    return expenseSource(
        id: json['Id'].toString(),
        sourceName: json['Title'].toString());
  }
}

class paymentTypeClassData {
  String Message;
  bool IsSuccess;
  List<paymentTypeClass> Data;

  paymentTypeClassData({
    this.Message,
    this.IsSuccess,
    this.Data,
  });

  factory paymentTypeClassData.fromJson(Map<String, dynamic> json) {
    return paymentTypeClassData(
        Message: json['Message'] as String,
        IsSuccess: json['IsSuccess'] as bool,
        Data: json['Data']
            .map<paymentTypeClass>((json) => paymentTypeClass.fromJson(json))
            .toList());
  }
}

class paymentTypeClass {
  String id;
  String name;

  paymentTypeClass({this.id, this.name});

  factory paymentTypeClass.fromJson(Map<String, dynamic> json) {
    return paymentTypeClass(
        id: json['Id'].toString() as String,
        name: json['Name'].toString() as String);
  }
}

class memberClassData {
  String Message;
  bool IsSuccess;
  List<memberClass> Data;

  memberClassData({
    this.Message,
    this.IsSuccess,
    this.Data,
  });

  factory memberClassData.fromJson(Map<String, dynamic> json) {
    return memberClassData(
        Message: json['Message'] as String,
        IsSuccess: json['IsSuccess'] as bool,
        Data: json['Data']
            .map<memberClass>((json) => memberClass.fromJson(json))
            .toList());
  }
}

class memberClass {
  String id;
  String name;
  String flatno;

  memberClass({this.id, this.name, this.flatno});

  factory memberClass.fromJson(Map<String, dynamic> json) {
    return memberClass(
      id: json['Id'].toString() as String,
      name: json['Name'].toString() as String,
      flatno: json['FlatNo'].toString() as String,
    );
  }
}

class WingClassData {
  String Message;
  bool IsSuccess;
  List<WingClass> Data;

  WingClassData({
    this.Message,
    this.IsSuccess,
    this.Data,
  });

  factory WingClassData.fromJson(Map<String, dynamic> json) {
    return WingClassData(
        Message: json['Message'] as String,
        IsSuccess: json['IsSuccess'] as bool,
        Data: json['Data']
            .map<WingClass>((json) => WingClass.fromJson(json))
            .toList());
  }
}

class WingClass {
  String WingId;
  String WingName;

  WingClass({this.WingId, this.WingName});

  factory WingClass.fromJson(Map<String, dynamic> json) {
    return WingClass(
        WingId: json['Id'].toString() as String,
        WingName: json['WingName'].toString() as String);
  }
}

class FlatClassData {
  String Message;
  bool IsSuccess;
  List<FlatClass> Data;

  FlatClassData({
    this.Message,
    this.IsSuccess,
    this.Data,
  });

  factory FlatClassData.fromJson(Map<String, dynamic> json) {
    return FlatClassData(
        Message: json['Message'] as String,
        IsSuccess: json['IsSuccess'] as bool,
        Data: json['Data']
            .map<FlatClass>((json) => FlatClass.fromJson(json))
            .toList());
  }
}

class FlatClass {
  String MemberId;
  String FlatNo;
  String MemberName;

  FlatClass({this.MemberId, this.FlatNo, this.MemberName});

  factory FlatClass.fromJson(Map<String, dynamic> json) {
    return FlatClass(
      MemberId: json['MemberId'].toString() as String,
      FlatNo: json['FlatNo'].toString() as String,
      MemberName: json['MemberName'].toString() as String,
    );
  }
}

class staffClassData {
  String Message;
  bool IsSuccess;
  List<staffClass> Data;

  staffClassData({
    this.Message,
    this.IsSuccess,
    this.Data,
  });

  factory staffClassData.fromJson(Map<String, dynamic> json) {
    return staffClassData(
        Message: json['Message'] as String,
        IsSuccess: json['IsSuccess'] as bool,
        Data: json['Data']
            .map<staffClass>((json) => staffClass.fromJson(json))
            .toList());
  }
}

class staffClass {
  String id;
  String name;

  staffClass({this.id, this.name});

  factory staffClass.fromJson(Map<String, dynamic> json) {
    return staffClass(
        id: json['Id'].toString() as String,
        name: json['StaffType1'].toString() as String);
  }

}

class StaffTypeData {
  String Message;
  bool IsSuccess;
  List<StaffType> Data;

  StaffTypeData({
    this.Message,
    this.IsSuccess,
    this.Data,
  });

  factory StaffTypeData.fromJson(Map<String, dynamic> json) {
    return StaffTypeData(
        Message: json['Message'] as String,
        IsSuccess: json['IsSuccess'] as bool,
        Data: json['Data']
            .map<StaffType>((json) => StaffType.fromJson(json))
            .toList());
  }
}

class StaffType {
  String TypeId;
  String TypeName;

  StaffType({this.TypeId, this.TypeName});

  factory StaffType.fromJson(Map<String, dynamic> json) {
    return StaffType(
        TypeId: json['Id'].toString() as String,
        TypeName: json['Title'].toString() as String);
  }
}
