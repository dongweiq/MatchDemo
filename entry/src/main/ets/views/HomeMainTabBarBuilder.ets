/**
 * 首页 - 底部Tab构造器。
 * @author li.hao85
 */

/** 首页 - 底部Tab信息。 */
export interface HomeMainTabBarInfo {
  uiContext: UIContext,
  icon: ResourceStr,
  text: ResourceStr,
  textFontSize: ResourceColor,
  textFontColor: ResourceColor,
  showFirstPagePopTips?: boolean,
  onPopTipsShowed?: Callback<void, void>
}

@Builder
export function HomeMainTabBarBuilder(info: HomeMainTabBarInfo) {
  Column() {
    Image(info.icon)
      .width(24)
      .height(24)
      .margin({ bottom: 4 })
    Text(info.text)
      .fontSize(info.textFontSize)
      .fontFamily('HarmonyHeiTi-Medium')
      .fontColor(info.textFontColor)
  }
  .padding({ top: 6, bottom: 6 })
  .alignItems(HorizontalAlign.Center)
}