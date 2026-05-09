import { LHAppSettingsTextSizePlanModel } from "../models/common/LHAppSettingsTextSizePlanModel";
import { GlobalAppSettings } from "../utils/common/GlobalAppSettings";
import { getScreenBottomSafeZoneHeightPx, getScreenTopSafeZoneHeightPx } from "../utils/common/ScreenUIAdapter";
import { ScreenObserver, ScreenStatusInfo } from "../utils/common/uiobserver/ScreenObserver";
import window from "@ohos.window";
import { PhotoPickerUtils } from "../utils/common/mediapicker/PhotoPickerUtils";
import { CopyFileResult } from "../utils/common/filecenter/models/FileCopyModel";
import promptAction from "@ohos.promptAction";
import { res2string } from "../utils/common/Utils";
import image from "@ohos.multimedia.image";

/**
 * 保存课堂图拍呢对话框。
 * @author li.hao85
 */
@Component
export struct TakePhotoDialog {

  /** 应用文字字号方案。 */
  private appTextSizePlan: LHAppSettingsTextSizePlanModel = GlobalAppSettings.textSizePlan();

  /** 图片数据。 */
  private photoData: ArrayBuffer | undefined = undefined;

  /** 图片。 */
  img?: PixelMap;

  /** 关闭对话框的回调。 */
  closeCallback?: Callback<void, void> = undefined;

  /** 顶部安全区高度。 */
  @State topSafeZoneHeightVp: number = px2vp(getScreenTopSafeZoneHeightPx());

  /** 底部安全区高度。 */
  @State bottomSafeZoneHeightVp: number = px2vp(getScreenBottomSafeZoneHeightPx());

  /** 是否允许保存图片。 */
  @State private canSave: boolean = false;

  aboutToAppear(): void {
    ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
      if (screenStatus.avoidArea !== undefined) {
        if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_SYSTEM) {
          this.topSafeZoneHeightVp = px2vp(screenStatus.avoidArea.topRect.height);
        } else if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          this.bottomSafeZoneHeightVp = px2vp(screenStatus.avoidArea.bottomRect.height);
        }
      }
    });
    if (this.img !== undefined) {
      const imagePackerApi = image.createImagePacker();
      let packOpts: image.PackingOption = { format:"image/jpeg", quality: 100 };
      imagePackerApi.packToData(this.img, packOpts)
        .then((data: ArrayBuffer) => {
          this.photoData = data;
          this.canSave = true;
        })
        .catch((_ : BusinessError) => {})
    }
  }

  aboutToDisappear(): void {
    ScreenObserver.unsubscribe(this.getUIContext());
  }

  build() {
    Column() {
      Image(this.img)
        .margin({ bottom: 8 })
        .objectFit(ImageFit.Contain)
        .layoutWeight(1)

      if (this.canSave) {
        SaveButton()
          .fontSize(this.appTextSizePlan.unifiedDialogButtonsTextSize)
          .onClick((_: ClickEvent, __: SaveButtonOnClickResult, ___?: BusinessError<void>) => {
            if (this.photoData !== undefined) {
              PhotoPickerUtils.saveOnePhotoToGallery(this.photoData)
                .then((result?: CopyFileResult) => {
                  if (result && result.resultUri !== undefined && result.resultUri.length > 0) {
                    promptAction.showToast({
                      message: res2string($r('app.string.save_success')) + result.resultUri
                    });
                  } else {
                    promptAction.showToast({
                      message: $r('app.string.save_failure')
                    });
                  }
                })
                .catch(() => promptAction.showToast({
                  message: $r('app.string.save_failure')
                }))
            } else {
              promptAction.showToast({
                message: $r('app.string.save_failure')
              });
            }
            this.closeCallback?.();
          })
      }
    }
    .width(320)
    .constraintSize({ maxHeight: 480 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
    .border({ radius: 12 })
    .padding(8)
    .margin({
      top: this.topSafeZoneHeightVp,
      bottom: this.bottomSafeZoneHeightVp
    })
  }
}