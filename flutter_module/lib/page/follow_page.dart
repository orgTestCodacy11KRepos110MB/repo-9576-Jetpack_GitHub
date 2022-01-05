import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_module/bloc/follow/follow_bloc.dart';
import 'package:flutter_module/bloc/follow/follow_event.dart';
import 'package:flutter_module/bloc/follow/follow_state.dart';
import 'package:flutter_module/color/color.dart';
import 'package:flutter_module/common/common_page_status.dart';
import 'package:flutter_module/model/follow_model.dart';
import 'package:flutter_module/string/string.dart';
import 'package:flutter_module/util/navigation_util.dart';
import 'package:flutter_module/widget/follow_page_item.dart';
import 'package:flutter_module/widget/loading_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FollowPage extends StatelessWidget {
  final String userName;
  final String type;

  const FollowPage(this.userName, this.type, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FollowBloc>(
      create: (c) => FollowBloc()..add(GetFollowersEvent(userName, type, 1)),
      child: FollowListPage(userName, type),
    );
  }
}

class FollowListPage extends StatelessWidget {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final String userName;
  final String type;

  FollowListPage(this.userName, this.type, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => NavigationUtil.pop()),
          backgroundColor: DColor.themeColor,
          title: Text(type == DString.FOLLOWERS_TYPE
              ? DString.FOLLOWER
              : DString.FOLLOWING),
        ),
        body:
            BlocBuilder<FollowBloc, FollowersState>(builder: (context, state) {
          if (state.pageStatus == PageStatus.LOADING) {
            return LoadingDialog();
          }
          _loadComplete();
          if (state.pageStatus == PageStatus.SUCCESS ||
              state.pageStatus == PageStatus.LOAD_MORE_FAIL) {
            if (state.followList.isEmpty) {
              _refreshController.loadNoData();
            } else {
              _refreshController.footerMode.value = LoadStatus.canLoading;
            }
            if (state.pageStatus == PageStatus.LOAD_MORE_FAIL) {
              _refreshController.loadFailed();
            }
            return _contentWidget(context, state.followList);
          } else {
            return _errorWidget(context);
          }
        }));
  }

  Widget _contentWidget(BuildContext context, List<FollowModel> followList) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      controller: _refreshController,
      onRefresh: () => context
          .read<FollowBloc>()
          .add(GetFollowersEvent(userName, type, 1, isRefresh: true)),
      onLoading: () => context.read<FollowBloc>().add(GetFollowersEvent(
          userName, type, context.read<FollowBloc>().page + 1)),
      child: ListView.builder(
        itemBuilder: (context, index) => FollowPageItem(followList[index]),
        itemCount: followList.length,
      ),
    );
  }

  Widget _errorWidget(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onPressed: () => context
            .read<FollowBloc>()
            .add(GetFollowersEvent(userName, type, 1)),
        child: Text(DString.LOAD_AGAINT),
      ),
    );
  }

  _loadComplete() {
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
  }
}
