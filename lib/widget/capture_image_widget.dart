import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_readhub/helper/string_helper.dart';
import 'package:flutter_readhub/util/resource_util.dart';
import 'package:flutter_readhub/view_model/theme_view_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

///需要进行截图-RepaintBoundary包裹部分参考
///https://www.codercto.com/a/46348.html
///https://blog.csdn.net/u014449046/article/details/98471268
///https://www.cnblogs.com/wupeng88/p/10797667.html
class CaptureImageWidget extends StatefulWidget {
  final String url;
  final GlobalKey globalKey;
  final String? title;
  final String? summary;
  final Widget? summaryWidget;

  const CaptureImageWidget(
    this.url,
    this.globalKey, {
    this.title,
    this.summary,
    this.summaryWidget,
    Key? key,
  }) : super(key: key);

  @override
  _CaptureImageWidgetState createState() => _CaptureImageWidgetState();
}

class _CaptureImageWidgetState extends State<CaptureImageWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ///使用SingleChildScrollView包裹RepaintBoundary才能截取完成图片
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: RepaintBoundary(
        key: widget.globalKey,
        child: Container(
          color: Theme.of(context).cardColor,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 顶部标题开始
                      ShareSlogan(),

                      /// 顶部标题结束
                      SizedBox(
                        height: TextUtil.isEmpty(widget.title) ? 0 : 12,
                      ),
                      Visibility(
                        child: Text(
                          '${widget.title}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.headline6!.copyWith(),
                        ),
                        visible: !TextUtil.isEmpty(widget.title),
                      ),
                      SizedBox(
                        height: TextUtil.isEmpty(widget.summary) &&
                                widget.summaryWidget == null
                            ? 0
                            : 12,
                      ),
                      Visibility(
                        visible: !TextUtil.isEmpty(widget.summary) ||
                            widget.summaryWidget != null,
                        child: widget.summaryWidget != null
                            ? widget.summaryWidget!
                            : Text(
                                '${widget.summary}',
                                strutStyle: StrutStyle(
                                  leading: 0.6,
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                      letterSpacing: 1,
                                    ),
                              ),
                      ),
                    ],
                  ),
                ),
                shadowColor: Colors.purple,
                borderOnForeground: false,
                color: Theme.of(context).cardColor,
                elevation: ThemeViewModel.darkMode ? 0 : 20,
                shape: Decorations.lineShapeBorder(
                  context,
                  lineWidth: ThemeViewModel.darkMode ? 0.5 : 0.000001,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(
                height: 24,
              ),

              ///二维码行开始
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: 20,
                  ),

                  ///左侧二维码
                  QrImage(
                    data: widget.url,
                    padding: EdgeInsets.zero,
                    version: QrVersions.auto,
                    size: 64,
                    foregroundColor:
                        Theme.of(context).textTheme.headline6!.color,
                    backgroundColor: Theme.of(context).cardColor,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StringHelper.getS()!.scanOrCodeForDetail,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontSize: 18,
                            ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                          text: StringHelper.getS()!.shareForm,
                          style: Theme.of(context).textTheme.bodyText2,
                          children: [
                            TextSpan(
                              text: '「${StringHelper.getS()!.appName}」',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    color: Theme.of(context).accentColor,
                                  ),
                            ),
                            TextSpan(text: 'App'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              ///二维码行结束
            ],
          ),
        ),
      ),
    );
  }
}

class ShareSlogan extends StatelessWidget {
  const ShareSlogan({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Image.asset(
          'assets/images/ic_logo_round.webp',
          width: 54,
          height: 54,
        ),
        SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                StringHelper.getS()!.appName,
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontSize: 20),
              ),
              SizedBox(
                height: 2,
              ),
              Text(
                StringHelper.getS()!.slogan,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .color!
                          .withOpacity(0.5),
                      fontSize: 14,
                    ),
              ),
            ],
          ),
          flex: 1,
        ),
      ],
    );
  }
}
