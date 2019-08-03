/*
import 'package:dio/dio.dart';
import './store.dart';
import 'package:flutter/material.dart';

// 记录学过的单词
putLearned(BuildContext context, String word, bool isLearned) async {
  Dio dio = getDio(context);
  // print('putLearned');
  var response = await dio.put(Store.baseURL + "learned",
      data: {"word": word, "learned": isLearned});
  return response.data;
}
*/
