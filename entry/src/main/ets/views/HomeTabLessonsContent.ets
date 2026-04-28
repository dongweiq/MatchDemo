import { LHAppSettingsTextSizePlanModel } from "../models/common/LHAppSettingsTextSizePlanModel";
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from "../utils/common/GlobalConfig";
import { getScreenUIType, ScreenUIType } from "../utils/common/ScreenUIAdapter";
import { ScreenObserver, ScreenStatusInfo } from "../utils/common/uiobserver/ScreenObserver";
import window from "@ohos.window";
import CONTENTS, { LessonsModel } from "../models/LessonsModel";

/**
 * 首页 - 课程 - 课程列表。
 * @author li.hao85
 */
@Component
export struct HomeTabLessonsContent {

  /** 应用文字字号方案。 */
  @Prop @Watch('onAppTextSizePlanChanged') appTextSizePlan: LHAppSettingsTextSizePlanModel;

  /** 当前屏幕状态信息。 */
  private screenStatus: ScreenStatusInfo | undefined = undefined;

  /** 列数规定。 */
  @State columnsTemplate: string = '';

  /** 每个小卡片的高。 */
  @State cardHeight: number = -1;

  aboutToAppear(): void {
    ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
      this.screenStatus = screenStatus;
      this.calcColumnTemplate();
    });
    this.calcColumnTemplate();
  }

  aboutToDisappear(): void {
    ScreenObserver.unsubscribe(this.getUIContext());
  }

  build() {
    Grid() {
      ForEach(CONTENTS, (content: LessonsModel) => {
        GridItem() {
          this.LessonCard(content)
        }
      })
    }
    .columnsTemplate(this.columnsTemplate)
    .columnsGap(4)
    .rowsGap(4)
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .edgeEffect(EdgeEffect.None)
    .scrollBar(BarState.Off)
  }

  @Builder
  private LessonCard(content: LessonsModel) {
    Button() {
      Row({ space: 8 }) {
        Image(content.titleImg)
          .objectFit(ImageFit.Contain)
          .width(120)
          .height(90)
        Text(content.titleText)
          .fontSize(this.appTextSizePlan.unifiedDialogTitleTextSize)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .height(this.cardHeight)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .padding(8)
      .onSizeChange((_, newSize: SizeOptions) => {
        this.cardHeight = Math.max(this.cardHeight, newSize.height as number)
      })
    }
    .borderRadius(4)
    .backgroundColor(Color.White)
    .onClick((_) => content.action?.())
  }

  /** 当字号设置方案变化时，设置cardHeight为-1，重新计算卡片的高度。 */
  onAppTextSizePlanChanged() {
    this.cardHeight = -1;
  }

  /**
   * 计算列数。
   */
  private calcColumnTemplate() {
    try {
      let screenUIType = this.screenStatus?.screenUIType ?? getScreenUIType();
      let windowStatusType = this.screenStatus?.windowStatusType ?? (GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window).getWindowStatus();
      let windowWidthBreakpoint = this.screenStatus?.windowWidthBreakpoint ?? this.getUIContext().getWindowWidthBreakpoint();
      // 计算列数。
      this.columnsTemplate =
        windowStatusType === window.WindowStatusType.FLOATING || windowStatusType === window.WindowStatusType.SPLIT_SCREEN ? (
          screenUIType === ScreenUIType.PAD && windowWidthBreakpoint === WidthBreakpoint.WIDTH_MD ? '1fr 1fr' :
          screenUIType === ScreenUIType.PAD && windowWidthBreakpoint >= WidthBreakpoint.WIDTH_LG ? '1fr 1fr 1fr' :
          '1fr'
        ) :
        (
          screenUIType === ScreenUIType.FOLD_OPENED ? '1fr 1fr' :
          screenUIType === ScreenUIType.PAD ? '1fr 1fr 1fr' :
          '1fr'
        );
    } catch (error) {
    }
  }
}