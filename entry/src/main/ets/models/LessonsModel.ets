import { Classroom, LESSON_INFO, LESSON_NAME } from "../pages/classroom/Classroom";
import { res2string } from "../utils/common/Utils";
import { LocalWebServer } from "../utils/LocalWebServer";

/**
 * 课程数据。
 * @author li.hao85
 */
export interface LessonsModel {

  /** 课程ID。 */
  id: number;

  /** 标题图。 */
  titleImg?: Resource;

  /** 标题文字。 */
  titleText?: ResourceStr;

  /** 跳转动作。 */
  action?: Callback<void>;
}

/** 所有课程。 */
const CONTENTS: Array<LessonsModel> = [
  {
    id: 1,
    titleImg: $r('app.media.ic_lessons_big_ben'),
    titleText: $r('app.string.lesson_big_ben'),
    action: () => {
      const params: Record<string, ResourceStr | undefined> = {}
      params[LESSON_INFO] = makeParams(res2string($r('app.string.lesson_big_ben')));
      params[LESSON_NAME] = $r('app.string.lesson_big_ben');
      Classroom.go(params);
    }
  },
  {
    id: 2,
    titleImg: $r('app.media.ic_lessons_ny_harbor'),
    titleText: $r('app.string.lesson_ny_harbor'),
    action: () => {
      const params: Record<string, ResourceStr | undefined> = {}
      params[LESSON_INFO] = makeParams(res2string($r('app.string.lesson_ny_harbor')));
      params[LESSON_NAME] = $r('app.string.lesson_ny_harbor');
      Classroom.go(params);
    }
  },
];

function makeParams(picName: string): string {
  return `http://${LocalWebServer.getInstance().ip}:${LocalWebServer.getInstance().port}/lesson/index.html?pic_name=${picName}`
};

export default CONTENTS;