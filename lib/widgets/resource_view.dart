import 'package:flutter/material.dart';
import '../controllers/resource_controller.dart';
import 'app_error_view.dart';
import 'empty_view.dart';
import 'loading_view.dart';

class ResourceView<T> extends StatelessWidget {
  final ResourceController<T> controller;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? loadingView;
  final Widget Function(BuildContext context, String message)? errorBuilder;
  final Widget? emptyView;
  final VoidCallback? onRetry;
  final String? emptyTitle;
  final String? emptyMessage;

  const ResourceView({
    super.key,
    required this.controller,
    required this.builder,
    this.loadingView,
    this.errorBuilder,
    this.emptyView,
    this.onRetry,
    this.emptyTitle,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        switch (controller.status) {
          case ResourceStatus.initial:
          case ResourceStatus.loading:
            return loadingView ?? const LoadingView();

          case ResourceStatus.error:
            if (errorBuilder != null) {
              return errorBuilder!(
                context,
                controller.errorMessage ?? 'An error occurred',
              );
            }
            return AppErrorView(
              message: controller.errorMessage ?? 'An unknown error occurred.',
              onRetry: onRetry,
            );

          case ResourceStatus.empty:
            return emptyView ??
                EmptyView(
                  title: emptyTitle ?? 'No Data',
                  message: emptyMessage ?? 'No items available at this time.',
                  onAction: onRetry,
                  actionLabel: onRetry != null ? 'Refresh' : null,
                );

          case ResourceStatus.success:
            if (controller.data == null) {
              return emptyView ??
                  EmptyView(
                    title: emptyTitle ?? 'No Data',
                    message: emptyMessage ?? 'No items available at this time.',
                    onAction: onRetry,
                    actionLabel: onRetry != null ? 'Refresh' : null,
                  );
            }
            return builder(context, controller.data as T);
        }
      },
    );
  }
}
