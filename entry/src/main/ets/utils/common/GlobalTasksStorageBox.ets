import HashMap from "@ohos.util.HashMap";

/**
 * 全局任务寄存箱。
 * @author li.hao85
 */
export class GlobalTasksStorageBox {

  /** 存储任务信息。key：钥匙卡，value：任务包裹。 */
  private static tasksStorageBox: HashMap<string, object> = new HashMap();

  /**
   * 向寄存箱存储一个任务包裹，拿取钥匙卡。
   * @param task 任务包裹。
   * @returns 钥匙卡。
   */
  static put(task: object): string {
    const key: string = `${new Date().getTime()}_${Math.floor(Math.random() * 1000000000)}`;
    try {
      GlobalTasksStorageBox.tasksStorageBox.set(key, task);
    } catch (error) {
    }
    return key;
  }

  /**
   * 从寄存箱中拿取一个任务包裹，并删除钥匙卡。
   * @param key 钥匙卡。
   * @returns 任务包裹。
   */
  static remove(key: string): object | undefined {
    try {
      if (GlobalTasksStorageBox.tasksStorageBox.hasKey(key)) {
        return GlobalTasksStorageBox.tasksStorageBox.remove(key);
      }
    } catch (error) {
    }
    return undefined;
  }

  /**
   * 从寄存箱中拿取一个任务包裹，不删除钥匙卡。下次还能凭同样的钥匙卡再获取对应的任务包裹。
   * @param key 钥匙卡。
   * @returns 任务包裹。
   */
  static get(key: string): object | undefined {
    try {
      if (GlobalTasksStorageBox.tasksStorageBox.hasKey(key)) {
        return GlobalTasksStorageBox.tasksStorageBox.get(key);
      }
    } catch (error) {
    }
    return undefined;
  }

  /**
   * 检查钥匙卡是否有效。
   * @param key 钥匙卡。
   * @returns 检查结果。
   */
  static has(key: string): boolean {
    try {
      return GlobalTasksStorageBox.tasksStorageBox.hasKey(key);
    } catch (error) {
    }
    return false;
  }
}