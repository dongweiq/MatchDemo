import { LHAppSettingsTextSizePlanModel } from "../../../models/common/LHAppSettingsTextSizePlanModel";
import { LHCommonTitleBar } from "../../../views/common/LHCommonTitleBar";
import { HomeMainTabBarBuilder } from '../../../views/HomeMainTabBarBuilder';

/**
 * 首页 - 课程。
 * @author li.hao85
 */
@Component
export struct HomeTabLessons {

  /** 当前选中的Tab序号。 */
  @Prop selectedIndex: number;

  /** 应用文字字号方案。 */
  @Prop appTextSizePlan: LHAppSettingsTextSizePlanModel;

  /** 顶部安全区高度。 */
  @Prop topSafeZoneHeightVp: number;

  /** 此Tab序号。 */
  private thisIndex: number = 0;

  build() {
    TabContent() {
      this.Content()
    }
    .tabBar(HomeMainTabBarBuilder({
      uiContext: this.getUIContext(),
      icon: this.selectedIndex === this.thisIndex ? $r('app.media.ic_home_tab_lessons_selected') : $r('app.media.ic_home_tab_lessons_unselected'),
      text: $r('app.string.home_tab_lessons'),
      textFontSize: this.appTextSizePlan.unifiedTabBarTextSize,
      textFontColor: this.selectedIndex === this.thisIndex ? $r('app.color.main_selected_color') : $r('app.color.main_unselected_color')
    }))
  }

  @Builder
  private Content() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: $r('app.string.home_tab_lessons'),
        centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize
      })
    }
    .width('100%')
    .height('100%')
    .margin({ top: this.topSafeZoneHeightVp })
  }
}