import { LHAppSettingsTextSizePlanModel } from "../../../models/common/LHAppSettingsTextSizePlanModel";
import { LHCommonTitleBar } from "../../../views/common/LHCommonTitleBar";
import { HomeMainTabBarBuilder } from '../../../views/HomeMainTabBarBuilder';

/**
 * 首页 - 单词本。
 * @author li.hao85
 */
@Component
export struct HomeTabNote {

  /** 当前选中的Tab序号。 */
  @Prop selectedIndex: number;

  /** 应用文字字号方案。 */
  @Prop appTextSizePlan: LHAppSettingsTextSizePlanModel;

  /** 顶部安全区高度。 */
  @Prop topSafeZoneHeightVp: number;

  /** 此Tab序号。 */
  private thisIndex: number = 1;

  build() {
    TabContent() {
      this.Content()
    }
    .tabBar(HomeMainTabBarBuilder({
      uiContext: this.getUIContext(),
      icon: this.selectedIndex === this.thisIndex ? $r('app.media.ic_home_tab_note_selected') : $r('app.media.ic_home_tab_note_unselected'),
      text: $r('app.string.home_tab_note'),
      textFontSize: this.appTextSizePlan.unifiedTabBarTextSize,
      textFontColor: this.selectedIndex === this.thisIndex ? $r('app.color.main_selected_color') : $r('app.color.main_unselected_color')
    }))
  }

  @Builder
  private Content() {
    Column() {
      Column() {
        LHCommonTitleBar({
          centerTitleText: $r('app.string.home_tab_note'),
          centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize,
          titleBarBg: Color.Transparent
        })
      }
      .width('100%')
      .padding({ top: this.topSafeZoneHeightVp })
      .backgroundColor($r('app.color.main_selected_light_color'))
    }
    .width('100%')
    .height('100%')
  }
}