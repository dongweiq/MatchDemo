import { RouterUtils } from '../../utils/common/RouterUtils';
import { LHCommonTitleBar, LHCommonTitleBarLeftNavBack } from '../../views/common/LHCommonTitleBar';
import { LHWebView } from '../../views/common/LHWebView';
import { webview } from '@kit.ArkWeb';
import { LHAppSettingsTextSizePlanModel } from '../../models/common/LHAppSettingsTextSizePlanModel';
import { LHAppSettingsTextSizePlans } from '../../models/common/LHAppSettingsTextSizePlans';
import {
  GlobalAppSettings,
  GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN
} from '../../utils/common/GlobalAppSettings';
import { emitter } from '@kit.BasicServicesKit';
import { GLOBAL_APP_SETTINGS_CHANGED_EVENT } from '../../utils/common/GlobalAppSettings';
import { getScreenBottomSafeZoneHeightPx, getScreenTopSafeZoneHeightPx } from '../../utils/common/ScreenUIAdapter';
import { ScreenObserver, ScreenStatusInfo } from '../../utils/common/uiobserver/ScreenObserver';
import window from '@ohos.window';
import { LocalWebServer } from '../../utils/LocalWebServer';

export namespace Classroom {
  export function go(params: Record<string, ResourceStr | undefined>) {
    RouterUtils.navPushPath('Classroom', params);
  }
}

@Builder
export function ClassroomBuilder() {
  ClassroomComponent()
}

/** 传递的url参数。 */
export const LESSON_INFO: string = 'url_params';

/** 课程名称。 */
export const LESSON_NAME: string = 'lesson_name';

/**
 * 网页浏览器，基于原生Web组件实现。
 * @author li.hao85
 */
@Component
struct ClassroomComponent {

  /** 应用文字字号方案。 */
  @State appTextSizePlan: LHAppSettingsTextSizePlanModel = LHAppSettingsTextSizePlans.SMALL;

  /** 地址信息。 */
  private url?: ResourceStr;

  /** 课程名称。 */
  private lessonName?: ResourceStr;

  /** 浏览器控制器。 */
  private controller?: webview.WebviewController;

  /** 顶部安全区高度。 */
  @State topSafeZoneHeightVp: number = px2vp(getScreenTopSafeZoneHeightPx());

  /** 底部安全区高度。 */
  @State bottomSafeZoneHeightVp: number = px2vp(getScreenBottomSafeZoneHeightPx());

  /** 标题栏可见性。 */
  @State titleVisible: boolean = true;

  private onGlobalAppSettingsChangedEvent: Callback<emitter.EventData> = (dataWrap: emitter.EventData) => {
    if (dataWrap.data) {
      let eventType: string = dataWrap.data[GLOBAL_APP_SETTINGS_EVENT_TYPE] as string;
      switch (eventType) {
        case GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN:
          this.appTextSizePlan = GlobalAppSettings.textSizePlan();
          break;
        default:
          break;
      }
    }
  };

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        LHWebView({
          src: this.url,
          mobileMode: true,
          onControllerAttachedCallback: (webViewController: webview.WebviewController): void => this.onControllerAttachedCallback(webViewController)
        })
          .width('100%')
          .height('100%')
          .onClick((_: ClickEvent) => {
            this.titleVisible = !this.titleVisible;
          })
        Column() {
          LHCommonTitleBar({
            centerTitleText: this.lessonName ?? $r('app.string.browser'),
            centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize,
            leftAction: LHCommonTitleBarLeftNavBack,
            titleBarBg: Color.Transparent
          })
        }
        .padding({ top: this.topSafeZoneHeightVp })
        .backgroundColor(Color.White)
        .visibility(this.titleVisible ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.main_bg_gray_color'))
    }
    .hideTitleBar(true)
    .backButtonIcon(undefined)
    .onReady((context: NavDestinationContext) => {
      let urlParams: Record<string, ResourceStr | undefined> =
        RouterUtils.navGetParams(context) as Record<string, ResourceStr | undefined>;
      this.url = urlParams[LESSON_INFO];
      this.lessonName = urlParams[LESSON_NAME];
      this.appTextSizePlan = GlobalAppSettings.textSizePlan();
      emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onGlobalAppSettingsChangedEvent);
      ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
        if (screenStatus.avoidArea !== undefined) {
          if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_SYSTEM) {
            this.topSafeZoneHeightVp = px2vp(screenStatus.avoidArea.topRect.height);
          } else if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
            this.bottomSafeZoneHeightVp = px2vp(screenStatus.avoidArea.bottomRect.height);
          }
        }
      });
    })
    .onBackPressed(() => {
      try {
        if (this.controller !== undefined && this.controller.accessBackward()) {
          this.controller.backward();
          return true;
        }
      } catch (error) {
      }
      return false;
    })
    .onDisAppear(() => {
      emitter.off(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onGlobalAppSettingsChangedEvent);
      ScreenObserver.unsubscribe(this.getUIContext());
    })
  }

  /**
   * 控制器绑定完毕回调。
   * @param webViewController WebView控制器。
   */
  private onControllerAttachedCallback(webViewController: webview.WebviewController) {
    this.controller = webViewController;
  }
}