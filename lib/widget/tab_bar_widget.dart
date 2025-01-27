import 'package:flutter/material.dart';
import 'package:flutter_readhub/view_model/theme_view_model.dart';

///TabBar效果
class TabBarWidget extends StatelessWidget {
  const TabBarWidget({
    Key? key,
    this.labels,
    this.controller,
    this.onTap,
  }) : super(key: key);
  final List? labels;
  final TabController? controller;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      onTap: onTap,
      tabs: List.generate(
          labels!.length,
              (i) => Tab(
              child: Text(
                labels![i],
                softWrap: false,
                overflow: TextOverflow.fade,
                textScaleFactor: ThemeViewModel.textScaleFactor,
              ))),

      ///不自动滚动则均分屏幕宽度
      isScrollable: false,

      ///指示器高度
      indicatorWeight: 1.5,

      ///指示器颜色
      indicatorColor: Theme.of(context).accentColor,

      ///指示器样式-根据label宽度
      indicatorSize: TabBarIndicatorSize.label,

      ///选中label颜色
      labelColor: Theme.of(context).textTheme.headline6!.color,

      ///未选择label颜色
      unselectedLabelColor:
      Theme.of(context).textTheme.headline6!.color!.withOpacity(0.6),
    );
  }
}