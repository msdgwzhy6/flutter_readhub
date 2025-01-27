import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_readhub/basis/basis_provider_widget.dart';
import 'package:flutter_readhub/helper/provider_helper.dart';
import 'package:flutter_readhub/helper/save_image_helper.dart';
import 'package:flutter_readhub/helper/string_helper.dart';
import 'package:flutter_readhub/model/share_model.dart';
import 'package:flutter_readhub/page/article_item_widget.dart';
import 'package:flutter_readhub/page/card_share_page.dart';
import 'package:flutter_readhub/util/dialog_util.dart';
import 'package:flutter_readhub/util/share_util.dart';
import 'package:flutter_readhub/util/toast_util.dart';
import 'package:flutter_readhub/view_model/theme_view_model.dart';
import 'package:flutter_readhub/view_model/update_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

///弹出作者信息分享提示框
Future<void> showAuthorDialog(BuildContext context) async {
  await showDialog<int>(
    context: context,
    builder: (BuildContext context) {
      ///部分手机调试模式出错增加居中及滚动
      return Center(
        child: AuthorDialog(),
      );
    },
  );
}

///弹出颜色选择框
Future<void> showThemeDialog(BuildContext context) async {
  DialogUtil.showModalBottomSheetDialog(
    context,
    clipBehavior: Clip.hardEdge,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(12),
      ),
    ),
    child: ThemeBody(didPop: true),
  );
}

///用户信息Dialog
class AuthorDialog extends Dialog {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child:

          ///圆角
          ClipRRect(
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.hardEdge,

        ///整体背景
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Container(
                  color: Theme.of(context).cardColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ///顶部信息
                      TopRoundWidget(),

                      ///意见反馈-发送邮件
                      FeedbackWidget(),

                      ///检查更新
                      UpdateWidget(),

                      ///应用分享
                      ShareAppWidget(),

                      ///选择颜色主题
                      ThemeWidget(),

                      ///文字尺寸设置
                      FontSizeWidget(),

                      ///赞赏开发者
                      AppreciateWidget(),

                      ///版权申明
                      CopyrightWidget(
                        scrollController: _scrollController,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///顶部个人信息介绍
class TopRoundWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: <Widget>[
          ClipPath(
            clipper: BottomClipper(),
            child: Container(
              height: 80,
              color: Theme.of(context).accentColor.withOpacity(0.8),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 32,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Image.asset(
                  'assets/images/user.jpg',
                  width: 56,
                  height: 56,
                ),
              ),
              SizedBox(
                height: 6,
              ),
              GestureDetector(
                onTap: () async => launch(
                  'https://github.com/AriesHoo/flutter_readhub',
                ),
                child: Text(
                  "开源「flutter_readhub」",
                  textScaleFactor: ThemeViewModel.textScaleFactor,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BottomClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    var path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height / 2);

    var p1 = Offset(size.width / 2, size.height);
    var p2 = Offset(size.width, size.height / 2);
    path.quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}

///意见反馈
class FeedbackWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      elevation: 0,
      child: ListTile(
        leading: Icon(
          Icons.mail_outline,
          color: Theme.of(context).accentColor,
        ),
        title: Text(
          StringHelper.getS()!.feedback,
          textScaleFactor: ThemeViewModel.textScaleFactor,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        trailing: Text(
          'AriesHoo@126.com',
          textScaleFactor: ThemeViewModel.textScaleFactor,
          style: Theme.of(context).textTheme.caption,
        ),
        onTap: () async {
          Uri _emailLaunchUri = Uri(
              scheme: 'mailto',
              path: 'AriesHoo@126.com',
              queryParameters: {'subject': '关于Freadhub的意见反馈'});

          ///发送邮件
          if (!await canLaunch(_emailLaunchUri.toString())) {
            ToastUtil.show(StringHelper.getS()!.tipNoEmailApp);
            return;
          }
          launch(_emailLaunchUri.toString());
        },
      ),
    );
  }
}

///检查更新
class UpdateWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return BasisProviderWidget<UpdateViewModel>(
      model: UpdateViewModel(),
      builder: (context, model, child) => Material(
        color: Theme.of(context).cardColor,
        child: ListTile(
          leading: Icon(
            Icons.system_update_tv_outlined,
            color: Theme.of(context).accentColor,
          ),
          title: Text(
            StringHelper.getS()!.checkUpdate,
            textScaleFactor: ThemeViewModel.textScaleFactor,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(),
          ),
          trailing: model.loading
              ? CupertinoActivityIndicator(
                  radius: 8,
                )
              : Text(
                  '${UpdateViewModel.appVersion}（${UpdateViewModel.appVersionCode}）',
                  textScaleFactor: ThemeViewModel.textScaleFactor,
                  style: Theme.of(context).textTheme.caption,
                ),
          onTap: model.loading
              ? null
              : () async {
                  await model.checkUpdate(context, showError: true);
                },
        ),
      ),
    );
  }
}

///分享App widget
class ShareAppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: Icon(
          Icons.share,
          color: Theme.of(context).accentColor,
        ),
        title: Text(
          StringHelper.getS()!.shareApp,
          textScaleFactor: ThemeViewModel.textScaleFactor,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).textTheme.caption!.color,
        ),
        onTap: () => CardSharePage.show(
          context,
          CardShareModel(
            title: '分享一个还不错的 Readhub 三方客户端-Freadhub',
            text:
                "${StringHelper.getS()!.saveImageShareTip} App 「Readhub 三方客户端-Freadhub」 链接:https://www.pgyer.com/ntMA",
            summary: StringHelper.getS()!.appName,
            url: 'https://www.pgyer.com/ntMA',
            notice: 'AriesHoo开发\n扫码查看详情',
            bottomNotice: StringHelper.getS()!.saveImageShareTip,
            summaryWidget: ShareAppSummaryWidget(),
          ),
        ),
      ),
    );
  }
}

///分享app 摘要
class ShareAppSummaryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      textScaleFactor: ThemeViewModel.textScaleFactor,
      text: TextSpan(
        style: Theme.of(context).textTheme.headline6!.copyWith(
              fontSize: 13,
              color: Theme.of(context)
                  .textTheme
                  .headline6!
                  .color!
                  .withOpacity(0.8),
            ),
        text:
            'Freadhub 即 : Flutter 开发的 Readhub 客户端。由练习时长两月半的个人 Flutter 小学生 Aries Hoo 花费半月开发完成。'
            '\n囊括以下功能：',
        children: [
          TextSpan(
            style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontSize: 12,
                  color: Theme.of(context)
                      .textTheme
                      .headline6!
                      .color!
                      .withOpacity(0.8),
                  fontWeight: FontWeight.w900,
                ),
            text: '\n热门话题、科技动态、开发者、区块链四大模块'
                '\n相关聚合资讯快捷查看'
                '\n方便快捷的浅色/深色模式切换'
                '\n丰富的彩虹颜色主题/每日主题切换'
                '\n长按社会化分享预览图效果模式'
                '\n方便快捷的意见反馈入口',
          ),
          TextSpan(
              text: '\n其它功能由细心的你自己去探索。'
                  '\n如果你在使用体验上有自己独到的意见或建议,请通过意见反馈功能反馈，由衷感谢！'),
        ],
      ),
    );
  }
}

///颜色主题选择
class ChoiceThemeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        StringHelper.getS()!.choiceTheme,
        textScaleFactor: ThemeViewModel.textScaleFactor,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      trailing: Text('trailing'),
      initiallyExpanded: false,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Wrap(
            runSpacing: 5,
            spacing: 5,
            children: <Widget>[
              ...ThemeViewModel.themeValueList.map((color) {
                int index = ThemeViewModel.themeValueList.indexOf(color);
                return Material(
                  borderRadius: BorderRadius.circular(2),
                  color: color,
                  child: InkWell(
                    onTap: () {
                      var model = ProviderHelper.of<ThemeViewModel>(context);
                      model.switchTheme(themeIndex: index);
                    },
                    splashColor: Colors.white.withAlpha(50),
                    child: Container(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: Text(
                          ThemeViewModel.themeName(i: index),
                          textScaleFactor: ThemeViewModel.textScaleFactor,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}

///主题选择
class ThemeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: Icon(
          Icons.color_lens,
          color: Theme.of(context).accentColor,
        ),
        title: Text(
          StringHelper.getS()!.choiceTheme,
          textScaleFactor: ThemeViewModel.textScaleFactor,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).textTheme.caption!.color,
        ),
        onTap: () => showThemeDialog(context),
      ),
      // child: ExpansionTile(
      //   leading: Icon(
      //     Icons.color_lens,
      //     color: Theme.of(context).accentColor,
      //   ),
      //   title: Text(
      //     StringHelper.getS()!.choiceTheme,
      //     textScaleFactor: ThemeViewModel.textScaleFactor,
      //     style: Theme.of(context).textTheme.bodyText1,
      //   ),
      //   children: [
      //     ThemeBody(),
      //   ],
      //   // trailing: Text(ThemeViewModel.themeName()),
      // ),
    );
  }
}

///颜色选择dialog
class ThemeDialog extends Dialog {
  @override
  Widget build(BuildContext context) {
    return ThemeBody(
      dialog: true,
    );
  }
}

///主题选择内容区
class ThemeBody extends StatelessWidget {
  ///是否dialog
  final bool dialog;

  ///点击后是否pop页面
  final bool didPop;

  const ThemeBody({
    Key? key,
    this.dialog: false,
    this.didPop: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: dialog ? 40 : 0,
        vertical: dialog ? 10 : 0,
      ),

      ///所有颜色按钮垂直排列
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            color: Theme.of(context).cardColor,
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: dialog ? 24 : 16,
            ),
            child: Wrap(
              runSpacing: 12,
              children: ThemeViewModel.themeValueList.map((color) {
                int index = ThemeViewModel.themeValueList.indexOf(color);
                return Material(
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.hardEdge,
                  color: ThemeViewModel.getThemeColor(i: index),
                  child: InkWell(
                    onTap: () {
                      var model = ProviderHelper.of<ThemeViewModel>(context);
                      model.switchTheme(themeIndex: index);
                      if (dialog || didPop) {
                        Navigator.of(context).pop();
                      }
                    },
                    splashColor: Colors.black.withAlpha(50),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 46,
                          child: Center(
                            child: Text(
                              ThemeViewModel.themeName(i: index),
                              textScaleFactor: ThemeViewModel.textScaleFactor,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 124),
                          child: Icon(
                            Icons.check,
                            size: 22,
                            color: index ==
                                    ProviderHelper.of<ThemeViewModel>(context)
                                        .themeIndex
                                ? Colors.white
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

///文字大小
class FontSizeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: ExpansionTile(
        leading: Icon(
          Icons.font_download,
          color: Theme.of(context).accentColor,
        ),
        title: Text(
          StringHelper.getS()!.fontSize,
          textScaleFactor: ThemeViewModel.textScaleFactor,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ///标题
                Text(
                  '资讯标题预览',
                  textScaleFactor: ThemeViewModel.articleTextScaleFactor,
                  maxLines: 2,
                  strutStyle: StrutStyle(
                      forceStrutHeight: true,
                      height: textLineHeight,
                      leading: leading),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: letterSpacing,
                      ),
                ),
                SizedBox(
                  height: 6,
                ),

                ///描述摘要
                Text(
                  '资讯摘要预览',
                  textScaleFactor: ThemeViewModel.articleTextScaleFactor,
                  overflow: TextOverflow.ellipsis,
                  strutStyle: StrutStyle(
                      forceStrutHeight: true,
                      height: textLineHeight,
                      leading: leading),
                  style: Theme.of(context).textTheme.caption!.copyWith(
                      letterSpacing: letterSpacing,
                      color: Theme.of(context)
                          .textTheme
                          .headline6!
                          .color!
                          .withOpacity(0.8)),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    ///已拖动的颜色
                    activeTrackColor: Theme.of(context).accentColor,

                    ///未拖动的颜色
                    inactiveTrackColor:
                        Theme.of(context).accentColor.withOpacity(0.25),

                    ///提示进度的气泡的背景色
                    valueIndicatorColor: Theme.of(context).accentColor,

                    ///提示进度的气泡文本的颜色
                    valueIndicatorTextStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),

                    ///滑块中心的颜色
                    thumbColor: Theme.of(context).accentColor,

                    ///滑块边缘的颜色
                    overlayColor:
                        Theme.of(context).accentColor.withOpacity(0.3),

                    ///divisions对进度线分割后，断续线中间间隔的颜色
                    inactiveTickMarkColor:
                        Theme.of(context).accentColor.withOpacity(0.25),
                    activeTickMarkColor: Theme.of(context).accentColor,
                  ),
                  child: Slider(
                    min: 8,
                    max: 12,
                    value: ThemeViewModel.articleTextScaleFactor! * 10,
                    divisions: 8,
                    label: '${ThemeViewModel.articleTextScaleFactor! * 10}',
                    onChanged: (value) {
                      ProviderHelper.of<ThemeViewModel>(context)
                          .switchFontTextSize(value / 10);
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///赞赏开发
class AppreciateWidget extends StatelessWidget {
  final GlobalKey _globalKey = GlobalKey();
  final SaveImageHelper _saveImageHelper = SaveImageHelper();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: ExpansionTile(
        backgroundColor: Colors.transparent,
        leading: Icon(
          Icons.payment,
          color: Theme.of(context).accentColor,
        ),
        title: Text(
          StringHelper.getS()!.appreciateDeveloper,
          textScaleFactor: ThemeViewModel.textScaleFactor,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onLongPress: () async {
                    String? _path = await _saveImageHelper.saveImage(
                        context, _globalKey, '/pay.png');
                    if (_path == null) {
                      ToastUtil.show(StringHelper.getS()!.shotFailed);
                    } else {
                      if (!await ShareUtil.isWeChatInstall()) {
                        ToastUtil.show(StringHelper.getS()!.weChatNotInstall);
                      } else {
                        ShareUtil.shareImagesToWeChatFriend([_path]);
                      }
                    }
                  },
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: Image.asset(
                      'assets/images/pay.png',
                      fit: BoxFit.fitWidth,
                      width: 80,
                      height: 80,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: RichText(
                      strutStyle: StrutStyle(
                          forceStrutHeight: true,
                          height: textLineHeight,
                          leading: leading),
                      text: TextSpan(
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .color!
                                        .withOpacity(0.8),
                                  ),
                          children: [
                            TextSpan(
                                text: '←   长按图片保存,微信扫码',
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 12,
                                )),
                            TextSpan(
                                text:
                                    '\n个人开发不易，如果您觉得Freadhub 不错，可以通过捐赠来支持一下，感谢！'),
                          ]),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

///版本声明
class CopyrightWidget extends StatelessWidget {
  final ScrollController? scrollController;

  const CopyrightWidget({Key? key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: ExpansionTile(
        onExpansionChanged: (opened) {
          if (opened && Platform.isAndroid) {
            ///开启详情延时滚动底部-Android有效
            Future.delayed(Duration(milliseconds: 200), () {
              scrollController!.animateTo(
                MediaQuery.of(context).size.height,
                duration: Duration(
                  milliseconds: 10,
                ),
                curve: Curves.easeInCirc,
              );
            });
          }
        },
        leading: Icon(
          Icons.content_copy,
          color: Theme.of(context).accentColor,
        ),
        title: Text(
          StringHelper.getS()!.appCopyright,
          textScaleFactor: ThemeViewModel.textScaleFactor,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(),
        ),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: RichText(
              text: TextSpan(
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontSize: 12,
                        color: Theme.of(context)
                            .textTheme
                            .headline6!
                            .color!
                            .withOpacity(0.8),
                      ),
                  text:
                      '1、本软件为 AriesHoo 通过 Flutter 开发而成的 Readhub 三方客户端，非无码科技 Readhub 官方应用。',
                  children: [
                    TextSpan(
                      text: '所有数据来源于无码科技 Readhub ,版权归无码科技 Readhub 所有。',
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context)
                                .textTheme
                                .headline6!
                                .color!
                                .withOpacity(0.8),
                          ),
                    ),
                    TextSpan(
                      text: '可访问',
                    ),
                    TextSpan(
                        text: ' readhub.cn ',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Theme.of(context).accentColor,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            ///点击跳转链接
                            await launch('https://www.readhub.cn/');
                          }),
                    TextSpan(text: '了解更多。'),
                    TextSpan(
                        text:
                            '\n2、本软件开发过程中UI部分参(chao)考(xi)了 Marno 的 Kotlin 版本 Readhub+ 应用；Flutter 功能实现上借(zhao)鉴(ban)了 phoenixsky 的 Flutter 版本 玩android 应用 Fun Android ，在此由衷感谢！'),
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
