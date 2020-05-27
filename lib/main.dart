import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_readhub/util/router_manger.dart';
import 'package:flutter_readhub/home_page.dart';
import 'package:flutter_readhub/util/sp_util.dart';
import 'package:flutter_readhub/view_model/update_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'generated/i18n.dart';
import 'view_model/locale_model.dart';
import 'view_model/theme_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

void main() async {
//  await SPUtil.getInstance();

  ///黑白化效果-缅怀
//  runApp(ColorFiltered(
//    colorFilter: ColorFilter.mode(Colors.white, BlendMode.color),
//    child: MyApp(),
//  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ///OKToast初始化以便全局使用context
    return OKToast(
      ///Provider 以便主题及国际化语言
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeModel>.value(value: ThemeModel()),
          ChangeNotifierProvider<LocaleModel>.value(value: LocaleModel()),
          ChangeNotifierProvider<UpdateModel>.value(value: UpdateModel()),
        ],
        child: Consumer3<ThemeModel, LocaleModel, UpdateModel>(
          builder: (context, themeModel, localeModel, updateModel, child) =>
              AppWidget(
            themeModel: themeModel,
            localeModel: localeModel,
          ),
        ),
      ),
    );
  }
}

///App
class AppWidget extends StatelessWidget {
  final ThemeModel themeModel;
  final LocaleModel localeModel;

  const AppWidget({
    Key key,
    this.themeModel,
    this.localeModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      ///全局主题配置
      theme: themeModel.themeData(),
//      darkTheme: themeModel.themeData(platformDarkMode: true),

      ///去掉右上顶部debug标签
      debugShowCheckedModeBanner: false,

      ///国际化语言
      locale: localeModel.locale,
      localizationsDelegates: [
        S.delegate,

        ///下拉刷新库国际化配置
        RefreshLocalizations.delegate,

        ///不配置该项会在EditField点击弹出复制粘贴工具时抛异常 The getter 'cutButtonLabel' was called on null.
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,

      ///配置页面路由
      onGenerateRoute: Router.generateRoute,

//      ///主页
//      home: HomePage(
//        updateModel: updateModel,
//      ),
      home: SplashPage(),
    );
  }
}

///增加一个闪屏页
class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () {
      Navigator.of(context).pushReplacementNamed(RouteName.tab);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: SizedBox(),
          ),
          Image.asset(
            'assets/images/ic_logo_round.webp',
            width: 96,
            height: 96,
          ),
          SizedBox(
            height: 10,
          ),
          Image.asset(
            'assets/images/ic_slogan.webp',
            width: 205,
            height: 205 * 140 / 815,
            color: Theme.of(context).textTheme.title.color,
          ),
          SizedBox(
            height: 160,
          ),
          Expanded(
            flex: 1,
            child: SizedBox(),
          ),
          Image.asset(
            'assets/images/ic_powered.webp',
            width: 110,
            height: 110 * 100 / 436,
            color: Theme.of(context).textTheme.title.color,
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
