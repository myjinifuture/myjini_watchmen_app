package com.itfuturz.mygenie_staff

//import android.os.Bundle
//import android.os.Handler
//import io.flutter.app.FlutterActivity
//import io.flutter.plugins.GeneratedPluginRegistrant
//import android.os.Looper
//import io.flutter.plugin.common.MethodChannel

//class MainActivity: FlutterActivity() {
//  override fun onCreate(savedInstanceState: Bundle?) {
//    super.onCreate(savedInstanceState)
//    GeneratedPluginRegistrant.registerWith(this)
//  }
//}
//
//private class MethodResultWrapper internal constructor(result: MethodChannel.Result) :
//  MethodChannel.Result {
//  private val methodResult: MethodChannel.Result
//  private val handler: Handler
//
//  override fun success(result: Any?) {
//    handler.post(
//      object : Runnable {
//        override fun run() {
//          methodResult.success(result)
//        }
//      })
//  }
//
//  override fun error(
//    errorCode: String?, errorMessage: String?, errorDetails: Any?
//  ) {
//    handler.post(
//      object : Runnable {
//        override fun run() {
//          methodResult.error(errorCode, errorMessage, errorDetails)
//        }
//      })
//  }
//
//  override fun notImplemented() {
//    handler.post(
//      object : Runnable {
//        override fun run() {
//          methodResult.notImplemented()
//        }
//      })
//  }
//
//  init {
//    methodResult = result
//    handler = Handler(Looper.getMainLooper())
//  }
//}

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

}