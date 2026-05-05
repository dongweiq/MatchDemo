import { Classroom, LESSON_INFO, LESSON_NAME } from "../pages/classroom/Classroom";

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
      params[LESSON_INFO] = makeParams(1);
      params[LESSON_NAME] = $r('app.string.lesson_big_ben');
      Classroom.go(params);
    }
  },
];

function makeParams(id: number): string {
  return `resource://rawfile/classroom/index.html?lesson_id=${id}`
};

export default CONTENTS;