import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_readhub/generated/i18n.dart';
import 'package:flutter_readhub/model/article_model.dart';
import 'package:flutter_readhub/util/log_util.dart';
import 'package:flutter_readhub/util/resource_util.dart';
import 'package:flutter_readhub/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_share_plugin/flutter_share_plugin.dart';

///弹出分享提示框
Future<void> showShareDialog(BuildContext context, ArticleItemModel data) async {
  await showDialog<int>(
    context: context,
    builder: (BuildContext context) {
      return ShareArticleDialog(data);
    },
  );
}

///分享文章详情
// ignore: must_be_immutable
class ShareArticleDialog extends Dialog {
  final ArticleItemModel data;

  ShareArticleDialog(this.data);

  final GlobalKey _globalKey = GlobalKey();

  ///已保存图片的路径
  String fileImage;

  ///保存图片
  _saveImage(BuildContext context, {bool share: false}) async {
    if (fileImage != null && fileImage.isNotEmpty) {
      if (share) {
        FlutterShare.shareFileWithText(
            textContent: "来自Readhub_flutter的分享", filePath: fileImage);
      } else {
        ToastUtil.show(S.of(context).saveImageSucceedInGallery);
      }
      return;
    }

    ///直接获取读写文件权限
    Map<PermissionGroup, PermissionStatus> map =
        await PermissionHandler().requestPermissions(<PermissionGroup>[
      PermissionGroup.storage,
    ]);
    PermissionStatus permission = map[PermissionGroup.storage];
    if (permission != PermissionStatus.granted) {
      ToastUtil.show(S.of(context).saveImagePermissionFailed);
      return;
    }
    RenderRepaintBoundary boundary =
        _globalKey.currentContext.findRenderObject();

    ///弹框宽度与屏幕宽度比值避免截图出来比预览更大
    ///分辨率通过获取设备的devicePixelRatio以达到清晰度良好
    var image = await boundary.toImage(
        pixelRatio: (MediaQuery.of(context).devicePixelRatio));

    ///转二进制
    ByteData byteData = await image.toByteData(format: ImageByteFormat.png);

    ///图片数据
    Uint8List pngBytes = byteData.buffer.asUint8List();

    ///保存图片到系统图库
    String resultSaveImage = await ImageGallerySaver.saveImage(pngBytes);
    LogUtil.e("resultSaveImage:" + resultSaveImage);
    if (resultSaveImage != null && resultSaveImage.isNotEmpty) {
      fileImage = resultSaveImage;
      _saveImage(context, share: share);
      return;
    }
    ToastUtil.show(S.of(context).saveImageFailed);
  }

  @override
  Widget build(BuildContext context) {
    ///最外层包裹设置距离屏幕边距
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ///最上边白色圆角开始
          ShotImageWidget(data, _globalKey),

          ///最上边白色圆角结束
          SizedBox(
            height: 20,
          ),

          ///最底部水平分享按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FloatingActionButton(
                elevation: 0,
                highlightElevation: 0,
                hoverElevation: 0,
                focusElevation: 0,
                disabledElevation: 0,
                tooltip: S.of(context).share,
                backgroundColor: Colors.blue,
                splashColor: Colors.white.withAlpha(50),
                child: Icon(Icons.share),
                onPressed: () => _saveImage(context, share: true),
              ),
              SizedBox(
                width: 20,
              ),
              FloatingActionButton(
                elevation: 0,
                highlightElevation: 0,
                hoverElevation: 0,
                focusElevation: 0,
                disabledElevation: 0,
                tooltip: S.of(context).downloadImage,
                backgroundColor: Colors.red,
                splashColor: Colors.white.withAlpha(50),
                child: Icon(Icons.file_download),
                onPressed: () => _saveImage(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

///需要进行截图-RepaintBoundary包裹部分参考
///https://www.codercto.com/a/46348.html
///https://blog.csdn.net/u014449046/article/details/98471268
///https://www.cnblogs.com/wupeng88/p/10797667.html
class ShotImageWidget extends StatelessWidget {
  final ArticleItemModel data;
  final GlobalKey globalKey;

  ShotImageWidget(this.data, this.globalKey);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          color: Theme.of(context).cardColor,
          padding: EdgeInsets.only(
            left: 20,
            top: 20,
            right: 20,
            bottom: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              ///标题
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(
                      data.title,
                      textAlign: TextAlign.justify,
                      style: Theme.of(context).textTheme.title.copyWith(
                            color: Theme.of(context)
                                .appBarTheme
                                .textTheme
                                .title
                                .color,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
//              Text(
//                data.timeFormatStr,
//                style: Theme.of(context).textTheme.caption.copyWith(
//                      fontSize: 10,
//                    ),
//              ),

              ///圆角分割线包裹内容开始
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 10,
                ),

                ///圆角线装修器
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Decorations.lineBoxBorder(
                      context,
                      left: true,
                      top: true,
                      right: true,
                      bottom: true,
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ///文章摘要
                    Text(
                      data.getSummary(),
                      style: Theme.of(context).textTheme.title.copyWith(
                            fontSize: 13,
                          ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ///扫码提示语
                        Expanded(
                          flex: 1,
                          child: Text(
                            data.getScanNote(),
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.title.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                          ),
                        ),

                        ///右侧二维码
                        QrImage(
                          data: data.getUrl(),
                          padding: EdgeInsets.all(2),
                          version: QrVersions.auto,
                          size: 64,
                          foregroundColor:
                              Theme.of(context).textTheme.title.color,
                          backgroundColor: Theme.of(context).cardColor,
                          embeddedImage: NetworkImage("https://avatars0.githubusercontent.com/u/19605922?s=460&v=4"),
                          embeddedImageStyle: QrEmbeddedImageStyle(
                            size: Size(20, 20),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              ///圆角分割线包裹内容结束

              SizedBox(
                height: 6,
              ),
              Text(
                S.of(context).saveImageShareTip,
                style: Theme.of(context).textTheme.caption.copyWith(
                      fontSize: 10,
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
