import { AppSettingsTextSizePlans } from '../models/AppSettingsTextSizePlan';
import { LHAppSettingsTextSizePlanModel } from '../models/common/LHAppSettingsTextSizePlanModel';
import { GlobalAppSettings } from './common/GlobalAppSettings';

/**
 * 应用设置工具类。
 * @author li.hao85
 */
export class AppSettings {

  /**
   * 查询应用字号大小方案设置。
   * @returns 查询结果。
   */
  public static textSizePlan(): LHAppSettingsTextSizePlanModel {
    let planID: number = GlobalAppSettings.textSizePlan().id;
    switch (planID) {
      case AppSettingsTextSizePlans.NORMAL.id: return AppSettingsTextSizePlans.NORMAL;
      case AppSettingsTextSizePlans.BIG.id: return AppSettingsTextSizePlans.BIG;
      case AppSettingsTextSizePlans.HUGE.id: return AppSettingsTextSizePlans.HUGE;
      case AppSettingsTextSizePlans.SMALL.id:
      default: return AppSettingsTextSizePlans.SMALL;
    }
  }

  /**
   * 设置应用字号方案。
   * @param newSizePlan 新的字号方案。
   */
  public static setTextSizePlan(newSizePlan: LHAppSettingsTextSizePlanModel) {
    GlobalAppSettings.setTextSizePlan(newSizePlan);
  }

  /**
   * 设置应用字号方案。
   * @param newSizePlanID 方案的ID。
   */
  public static setTextSizePlanByID(newSizePlanID: number) {
    GlobalAppSettings.setTextSizePlanByID(newSizePlanID);
  }

  /**
   * 查询应用是否使用了分屏显示设置。
   * @returns 查询结果。
   */
  public static isSplitScreen(): boolean {
    return GlobalAppSettings.isSplitScreen();
  }

  /**
   * 设置应用是否使用了分屏显示功能。
   * @param flag 分屏显示设置开关。
   */
  public static setIsSplitScreen(flag: boolean) {
    GlobalAppSettings.setIsSplitScreen(flag);
  }
}