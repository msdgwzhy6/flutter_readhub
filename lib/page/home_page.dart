import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_readhub/data/article_http.dart';
import 'package:flutter_readhub/dialog/author_dialog.dart';
import 'package:flutter_readhub/helper/provider_helper.dart';
import 'package:flutter_readhub/helper/string_helper.dart';
import 'package:flutter_readhub/page/article_item_widget.dart';
import 'package:flutter_readhub/util/platform_util.dart';
import 'package:flutter_readhub/util/resource_util.dart';
import 'package:flutter_readhub/util/toast_util.dart';
import 'package:flutter_readhub/view_model/theme_view_model.dart';
import 'package:flutter_readhub/view_model/update_view_model.dart';
import 'package:flutter_readhub/widget/animated_switcher_icon_widget.dart';
import 'package:flutter_readhub/widget/tab_bar_widget.dart';

///主页面
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  ///api
  var _listUrls = [
    ArticleHttp.API_TOPIC,
    ArticleHttp.API_NEWS,
    ArticleHttp.API_TECH_NEWS,
    ArticleHttp.API_BLOCK_CHAIN
  ];

  ///tab栏
  var _listTab = ["热门话题", "科技动态", "开发者资讯", "区块链"];
  TabController? _tabController;
  ValueChanged<int>? _onTabTap;

  ///上次点击时间
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(initialIndex: 0, length: _listTab.length, vsync: this);
    _onTabTap = (i) {
      LogUtil.v('TabController:$i');
    };

    ///5s后进行版本检测
    Future.delayed(Duration(seconds: 5), () {
      UpdateViewModel().checkUpdate(context);
    });
  }

  ///深色浅色模式切换
  void switchDarkMode(BuildContext context) {
    if (ThemeViewModel.platformDarkMode) {
      ToastUtil.show(StringHelper.getS()!.tipSwitchThemeWhenPlatformDark);
    } else {
      ProviderHelper.of<ThemeViewModel>(context).switchTheme(
          userDarkMode: Theme.of(context).brightness == Brightness.light);
    }
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    LogUtil.v('home_page_didUpdateWidget');
  }

  @override
  Widget build(BuildContext context) {
    ///返回键控制
    return WillPopScope(
      onWillPop: () async {
        if (_lastPressedAt == null ||
            DateTime.now().difference(_lastPressedAt!) >
                Duration(milliseconds: 1500)) {
          ///两次点击间隔超过阈值则重新计时
          _lastPressedAt = DateTime.now();
          ToastUtil.show(
            StringHelper.getS()!.quitApp,
            duration: Duration(milliseconds: 1500),
            notification: false,
          );
          return false;
        }
        exit(0);
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: PreferredSize(
          ///设置AppBar高度
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            title: Image.asset(
              'assets/images/title.png',
              width: 108,
              color: Theme.of(context).appBarTheme.iconTheme!.color,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              colorBlendMode: BlendMode.srcIn,
            ),
            actions: <Widget>[
              ///更多信息
              AnimatedSwitcherIconWidget(
                defaultIcon: Icons.info,
                switchIcon: Icons.info_outline,
                tooltip: StringHelper.getS()!.moreSetting,
                onPressed: () => showAuthorDialog(context),
                checkTheme: true,
              ),

              ///暗黑模式切换
              AnimatedSwitcherIconWidget(
                defaultIcon: Icons.brightness_2,
                switchIcon: Icons.brightness_5,
                tooltip: ThemeViewModel.darkMode
                    ? StringHelper.getS()!.lightMode
                    : StringHelper.getS()!.darkMode,
                onPressed: () => switchDarkMode(context),
              ),
            ],
          ),
        ),

        ///内容区域
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ///tab栏
            Container(
              height: 36,
              width: double.infinity,

              ///添加该属性去掉Tab按下水波纹效果
              color: Theme.of(context).appBarTheme.color,

              ///TabBar
              child: TabBarWidget(
                labels: _listTab,
                controller: _tabController,
                onTap: _onTabTap,
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Decorations.lineBoxBorder(
                  context,
                  bottom: true,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: TabBarView(
                controller: _tabController,
                children: List.generate(
                  _listTab.length,
                  (i) => ArticleItemWidget(
                    url: _listUrls[i],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
