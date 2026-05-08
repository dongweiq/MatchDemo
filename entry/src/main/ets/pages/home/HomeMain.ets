import { Callback, emitter } from '@kit.BasicServicesKit';
import { AppSettings } from '../../utils/AppSettings';
import {
  GLOBAL_APP_SETTINGS_CHANGED_EVENT,
  GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN,
  GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN
} from '../../utils/common/GlobalAppSettings';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from '../../utils/common/GlobalConfig';
import { RouterUtils, ROUTER_CONFIG_KEY_ROUTER_STACK } from '../../utils/common/RouterUtils';
import {
  getScreenBottomSafeZoneHeightPx,
  getScreenTopSafeZoneHeightPx,
  getScreenUIType,
  ScreenUIType } from '../../utils/common/ScreenUIAdapter';
import window from '@ohos.window';
import { ScreenObserver, ScreenStatusInfo } from '../../utils/common/uiobserver/ScreenObserver';
import { LHAppSettingsTextSizePlanModel } from '../../models/common/LHAppSettingsTextSizePlanModel';
import { HomeTabLessons } from './hometabs/HomeTabLessons';
import { HomeTabNote } from './hometabs/HomeTabNote';
import { HomeTabSettings } from './hometabs/HomeTabSettings';
import { LocalWebServer } from '../../utils/LocalWebServer';

/**
 * 事件：物理返回键额外监听。
 * 用在全局配置设置中，监听函数格式为() => boolean。
 * 首页的onBackPress被触发后会拿出此监听函数的数组，并依次执行里面的函数，如果有任意一个函数执行结果为true，则onBackPress不再执行后续动作。
 */
export const GLOBAL_CONFIG_BACK_KEY_EVENT: string = 'GlobalConfigBackKeyEvent';

/**
 * 首页。
 * @author li.hao85
 */
@Entry
@Component
struct HomeMain {

  /** 应用文字字号方案。 */
  @State appTextSizePlan: LHAppSettingsTextSizePlanModel = AppSettings.textSizePlan();

  /** 当前选中的标签序号。 */
  @State curSelectedTabIndex: number = 0;

  /** 标签页控制器。 */
  private tabsController: TabsController = new TabsController();

  /** 页面栈控制器。 */
  private routerStack: NavPathStack = new NavPathStack();

  /** 是否使用分屏显示。 */
  private isSplitScreen: boolean = AppSettings.isSplitScreen();

  /** 屏幕状态信息。 */
  private screenStatusInfo: ScreenStatusInfo | undefined = undefined;

  /** 顶部安全区高度。 */
  @State topSafeZoneHeightVp: number = px2vp(getScreenTopSafeZoneHeightPx());

  /** 底部安全区高度。 */
  @State bottomSafeZoneHeightVp: number = px2vp(getScreenBottomSafeZoneHeightPx());

  /** 页面叠加模式。 */
  @State navMode: NavigationMode = NavigationMode.Stack;

  private onGlobalAppSettingsChangedEvent: Callback<emitter.EventData> = (dataWrap: emitter.EventData) => {
    if (dataWrap.data) {
      let eventType: string = dataWrap.data[GLOBAL_APP_SETTINGS_EVENT_TYPE] as string;
      switch (eventType) {
        case GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN:
          this.appTextSizePlan = AppSettings.textSizePlan();
          break;
        case GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN: {
          this.isSplitScreen = AppSettings.isSplitScreen();
          this.calcScreenParams();
        }
          break;
        default:
          break;
      }
    }
  };

  aboutToAppear(): void {
    GlobalConfig.set(ROUTER_CONFIG_KEY_ROUTER_STACK, this.routerStack);
    emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onGlobalAppSettingsChangedEvent);
    ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
      this.screenStatusInfo = screenStatus;
      this.calcScreenParams();
    });
    this.calcScreenParams();
  }

  aboutToDisappear(): void {
    emitter.off(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onGlobalAppSettingsChangedEvent);
    ScreenObserver.unsubscribe(this.getUIContext());
  }

  onBackPress(): boolean | void {
    if (RouterUtils.navGetPathsCount() > 0) {
      RouterUtils.navBack();
      return true;
    }
    let backKeyEvents: Array<() => boolean> | undefined = GlobalConfig.get(GLOBAL_CONFIG_BACK_KEY_EVENT);
    if (backKeyEvents !== undefined && backKeyEvents.length > 0) {
      for (let index = 0; index < backKeyEvents.length; index++) {
        let func: () => boolean = backKeyEvents[index];
        if (func()) {
          return true;
        }
      }
    }
    return false;
  }

  build() {
    Navigation(this.routerStack) {
      Tabs({
        barPosition: BarPosition.End,
        index: this.curSelectedTabIndex,
        controller: this.tabsController
      }) {
        HomeTabLessons({
          selectedIndex: this.curSelectedTabIndex,
          appTextSizePlan: this.appTextSizePlan,
          topSafeZoneHeightVp: this.topSafeZoneHeightVp
        })
        HomeTabNote({
          selectedIndex: this.curSelectedTabIndex,
          appTextSizePlan: this.appTextSizePlan,
          topSafeZoneHeightVp: this.topSafeZoneHeightVp
        })
        HomeTabSettings({
          selectedIndex: this.curSelectedTabIndex,
          appTextSizePlan: this.appTextSizePlan,
          topSafeZoneHeightVp: this.topSafeZoneHeightVp
        })
      }
      .layoutWeight(1)
      .margin({ bottom: this.bottomSafeZoneHeightVp })
      .vertical(false)
      .edgeEffect(EdgeEffect.None)
      .scrollable(true)
      .onChange((newIndex: number) => this.curSelectedTabIndex = newIndex)
      .onTabBarClick((newIndex: number) => this.tabsController.changeIndex(newIndex))
    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideBackButton(true)
    .mode(this.navMode)
    .backgroundColor($r('app.color.main_bg_gray_color'))
    .onAppear(() => {
      let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window;
      mainWindow.setWindowLayoutFullScreen(true).catch(() => {});

      LocalWebServer.getInstance().start();
    })
    .onDisAppear(() => {
      let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window;
      mainWindow.setWindowLayoutFullScreen(false).catch(() => {});

      LocalWebServer.getInstance().stop();
    })
  }

  /** 计算屏幕状态参数。 */
  private calcScreenParams() {
    // 计算安全区尺寸。
    if (this.screenStatusInfo?.avoidArea !== undefined) {
      if (this.screenStatusInfo.avoidAreaType === window.AvoidAreaType.TYPE_SYSTEM) {
        this.topSafeZoneHeightVp = px2vp(this.screenStatusInfo.avoidArea.topRect.height);
      } else if (this.screenStatusInfo.avoidAreaType === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        this.bottomSafeZoneHeightVp = px2vp(this.screenStatusInfo.avoidArea.bottomRect.height);
      }
    }
    // 计算页面叠加模式。
    this.calcNavMode();
  }


  /** 计算页面叠加模式。 */
  private calcNavMode() {
    try {
      let screenUIType = this.screenStatusInfo?.screenUIType ?? getScreenUIType();
      let windowStatusType = this.screenStatusInfo?.windowStatusType ?? (GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window).getWindowStatus();
      let windowWidthBreakpoint = this.screenStatusInfo?.windowWidthBreakpoint ?? this.getUIContext().getWindowWidthBreakpoint();
      this.navMode =
        windowStatusType === window.WindowStatusType.FLOATING || windowStatusType === window.WindowStatusType.SPLIT_SCREEN ? (
          this.isSplitScreen && screenUIType === ScreenUIType.PAD && windowWidthBreakpoint >= WidthBreakpoint.WIDTH_MD ? NavigationMode.Split :
            NavigationMode.Stack
        ) :
          (
            screenUIType === ScreenUIType.NORMAL ? NavigationMode.Stack :
              this.isSplitScreen ? NavigationMode.Split : NavigationMode.Stack
          );
    } catch (error) {
    }
  }
}