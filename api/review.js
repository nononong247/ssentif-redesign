// /api/review — 리뷰 남기기 페이지(/review)의 리뷰 초안 생성.
// 브라우저는 앱·키워드 id·길이만 보낸다. 프롬프트는 전부 여기서 아래 허용 목록으로 만든다
// (자유 입력을 받지 않아서 엉뚱한 글을 시키는 데 쓰일 수 없다).
// Vercel 환경변수 ANTHROPIC_API_KEY 필요.

import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

// review.html 의 APPS 키워드 id와 일치해야 한다. fact는 기능 설명 — 이 범위 밖은 쓰지 않게 한다.
const APPS = {
  coach: {
    name: "센티프 코치",
    desc: "PT·필라테스 센터의 강사와 관리자가 쓰는 업무 앱",
    personas: [
      "PT센터 트레이너", "필라테스 강사", "PT센터 대표", "센터 매니저",
      "이제 막 일 시작한 신입 트레이너", "경력 오래된 트레이너", "작은 센터를 혼자 운영하는 원장",
      "트레이너 여러 명을 관리하는 센터장", "여성 전용 센터 강사", "프리랜서로 여러 센터에서 수업하는 트레이너",
      "데스크 업무까지 같이 보는 매니저", "재활·자세교정 위주로 수업하는 트레이너",
    ],
    keywords: {
      journal: ["수업일지가 회원에게 바로", "수업 후 남긴 수업일지가 회원 앱으로 바로 전달돼, 수업 내용이 말로 끝나지 않고 기록으로 회원에게 남는다"],
      liked: ["회원님이 좋아함", "회원들이 회원 앱으로 수업 기록을 받아보며 관리받는다고 느끼고 좋아한다"],
      records: ["기록이 쌓여 근거가 됨", "회원별 수업 기록이 쌓여 상담하거나 다시 볼 때 근거로 꺼내 쓸 수 있다"],
      visible: ["관리 상태가 한눈에 보임", "담당 회원마다, 강사마다 회원 관리가 어떻게 되고 있는지 한눈에 보여 감이 아니라 눈으로 확인된다"],
      schedule: ["수업 일정 관리", "개인·그룹 수업 일정을 캘린더로 잡고 옮긴다"],
      pass: ["수강권 관리", "회원별 수강권의 남은 횟수와 기간이 바로 보이고, 수업 일정과 사용한 수강권이 연결된다"],
      members: ["회원 관리", "회원 정보와 수업 이력을 한 곳에서 본다"],
      video3d: ["3D 운동영상", "운동마다 3D 운동 영상이 있어 동작을 영상으로 보여줄 수 있다"],
      easy: ["쓰기 쉬움", "화면이 단순해서 금방 익숙해진다"],
      organized: ["센터가 체계적으로 보임", "누가 담당해도 같은 방식으로 기록이 남아, 회원에게 센터가 체계적으로 보인다"],
    },
  },
  member: {
    name: "센티프 회원",
    desc: "PT·필라테스 센터 회원이 쓰는 앱",
    personas: [
      "PT 받는 직장인 회원", "필라테스 다니는 회원", "운동 시작한 지 얼마 안 된 회원", "꾸준히 PT 받는 회원",
      "퇴근하고 저녁에 운동하는 회원", "새벽 수업 듣는 회원", "다이어트 목적으로 PT 시작한 회원",
      "자세 교정하려고 필라테스 다니는 회원", "운동 기록 남기는 걸 좋아하는 회원", "운동 앱 여러 개 써본 회원",
      "바디프로필 준비 중인 회원", "운동을 오래 쉬다가 다시 시작한 회원", "아이 키우면서 틈틈이 운동하는 회원",
    ],
    keywords: {
      journal: ["수업일지를 받아봄", "수업 후 트레이너가 남긴 수업일지가 앱으로 와서 오늘 한 수업 내용이 기록으로 남는다"],
      myvideo: ["내 운동 영상", "수업 중 찍은 내 운동 영상을 앱에서 다시 본다"],
      data: ["내 변화가 데이터로 보임", "내 운동 기록과 몸 변화를 데이터로 본다"],
      mine: ["내 기록이 내 것으로 남음", "수업 기록이 트레이너 메모가 아니라 내 앱에 내 것으로 남아 언제든 다시 본다"],
      managed: ["관리받는 느낌", "트레이너가 기록을 남기고 그 기록을 보며 챙겨 줘서 제대로 관리받는 느낌이 든다"],
      pass: ["남은 횟수가 투명함", "남은 수강권 횟수와 기간을 언제든 직접 본다"],
      schedule: ["수업 일정 확인", "내 수업 일정을 앱에서 본다"],
      motivation: ["운동 동기부여", "기록과 변화가 쌓이는 걸 보며 꾸준히 운동하게 된다"],
      easy: ["쓰기 쉬움", "화면이 단순해서 쓰기 쉽다"],
      talk: ["선생님과 소통", "트레이너와 앱 안에서 대화한다"],
    },
  },
};

const LENGTHS = {
  short: "본문 한마디~두 문장, 5~80자. 아주 짧아도 된다",
  mid: "본문 서너 문장, 120~200자",
  long: "본문 250~400자. 문단을 나눠도 되고 한 덩어리로 써도 된다",
};
// 실제 리뷰는 고른 장점을 다 말하지 않는다. 길이별로 본문에서 언급할 최대 개수.
const MENTION_CAP = { short: 1, mid: 2, long: 3 };

// 리뷰 가이드 — 사용자가 보내 준 실제 앱스토어 리뷰 캡처(2026-10-26 라포, 2026-10-27 슬랙·영상편집 앱)에서 뽑은 말투 패턴.
// 실제 리뷰 문장은 넣지 않고 패턴만 옮겼다(남의 리뷰를 베낀 듯한 글이 나오지 않게).
// 공통 특징
// - 짧은 리뷰가 아주 많다. 한마디로 끝나는 별 다섯 개도 흔하다.
// - 존댓말(~요, ~습니다), 반말 평서체(~다), 음슴체가 사람마다 다르고, 한 글 안에서도 섞인다.
// - '~하는 사람으로서', '처음 ~하는데' 처럼 자기 정체성이나 처지를 먼저 밝힌다.
// - '다른 앱 쓰다가 넘어오니' 처럼 이전 방식과 비교한다.
// - 줄바꿈으로 문단을 한 줄씩 띄우고, 끝에 장난스러운 한마디를 붙이기도 한다.
// - '어플', '쌤', '회원님들', '~입장에서', '솔직하게', '진짜', '너무'.
// - 띄어쓰기를 붙여 쓰고, 문장 사이 마침표를 빠뜨리고, '..'·'~'·'!!'·'ㅠㅠ'·'ㅎㅎ'·':)'를 쓴다.
// - 별 다섯 개는 대부분 불만이 없다. 가끔 작은 바람을 덧붙인다.
// lengths: 이 말투가 나올 수 있는 길이. weight: 나올 비중.
const TONES = [
  {
    name: "초단문",
    guide: [
      "3~20자짜리 한마디로 끝낸다. 문장 하나, 많아야 둘이다.",
      "'~좋아요', '잘 쓰고 있습니다~' 같은 평범한 만족 한마디거나, 자기만의 짧은 평 한 줄이다.",
      "띄어쓰기나 마침표는 신경 쓰지 않는다.",
    ],
    lengths: ["short"],
    weight: 3,
    minimal: true,
  },
  {
    name: "한 줄 평",
    guide: [
      "한두 문장으로 느낀 점 하나만 말한다. 자기 처지 한 마디를 앞에 붙여도 된다('처음 ~하는데' 처럼).",
      "꾸밈말 없이 쓰고, 끝에 ':)'나 '~'를 붙여도 된다.",
    ],
    lengths: ["short"],
    weight: 2,
    minimal: true,
  },
  {
    name: "반말 평서체",
    guide: [
      "'좋다.', '편하다.' 처럼 ~다 체로 짧게 끊는다. 존댓말을 쓰지 않는다.",
      "앞 문장을 받는 이유를 문장 조각으로 덧붙인다('~하지도 않고.' 처럼 끝을 맺지 않아도 된다).",
    ],
    lengths: ["short", "mid"],
    weight: 1,
  },
  {
    name: "현장 경험담",
    guide: [
      "'~하는 사람으로서', '우선', '일단', '전반적으로' 같은 말로 시작해 생각나는 순서대로 말한다.",
      "'보통은 ~하는데 그건 ~니까요..', '다른 걸 쓰다가 넘어오니 ~' 처럼 원래 하던 방식과 한 번 비교한다.",
      "'저는 ~하는데 ~해서 좋았어요', '~입장에서 ~할 수 있을 것 같더라고요' 처럼 자기 일 얘기를 넣는다.",
      "한 글 안에서 ~요체와 ~습니다체를 섞는다. 문장이 길게 이어져도 된다.",
    ],
    lengths: ["mid", "long"],
    weight: 3,
  },
  {
    name: "알게 된 계기 후기",
    guide: [
      "'처음 ~하면서 ~해서 쓰게 됐어요' 처럼 쓰게 된 계기로 시작한다.",
      "좋았던 걸 '~도 너무 좋았어요!', '~하기 너무 편해요' 처럼 감정 섞어 말한다.",
      "끝은 '강력 추천합니다!'나 '추천해요!!' 같은 짧은 추천으로 끝내도 된다.",
    ],
    lengths: ["short", "mid", "long"],
    weight: 2,
  },
  {
    name: "담백한 만족",
    guide: [
      "~습니다체로 차분하게 쓴다. '~로 잘 활용하고 있습니다', '~해서 만족스럽습니다' 처럼 업무용 앱을 평가하는 말투다.",
      "마지막은 '앞으로도 더 잘 되길 바랍니다' 처럼 앱이 잘 되길 비는 한마디로 끝내도 된다.",
    ],
    lengths: ["short", "mid", "long"],
    weight: 2,
  },
  {
    name: "줄바꿈 수다형",
    guide: [
      "~요체로 친구한테 말하듯 쓰고, 문단을 빈 줄로 띄워 두세 덩어리로 나눈다. 한 덩어리는 한두 문장이다.",
      "'참 좋아요', '너무 재밌어요' 같은 감정 표현을 쓰고, 마지막 덩어리는 장난스러운 짧은 한마디로 끝낸다.",
    ],
    lengths: ["mid", "long"],
    weight: 2,
  },
  {
    name: "다 좋은데형",
    guide: [
      "좋은 점을 짧게 말하고, 아래 '덧붙일 바람'을 '~했으면 좋겠어요', '~하면 더 좋을 것 같아요' 처럼 한 번만 덧붙인다.",
      "'ㅠㅠ'나 '~!!'를 한 번 써도 된다.",
    ],
    lengths: ["mid", "long"],
    wish: true,
    weight: 1,
  },
];

// 아래 축들은 요청마다 하나씩 무작위로 뽑아 프롬프트에 넣는다. 조합이 많을수록
// 같은 키워드를 고른 여러 사람의 글이 한 프로그램이 찍어낸 것처럼 보이지 않는다.
const OPENINGS = [
  "첫 문장은 자기 상황 소개로 시작한다.",
  "첫 문장부터 바로 가장 좋은 점을 말한다.",
  "첫 문장은 이 앱을 쓰게 된 계기로 시작한다.",
  "첫 문장은 처음 써 봤을 때의 인상으로 시작한다.",
  "첫 문장은 구체적인 장면 하나로 시작한다.",
  "첫 문장은 한 단어나 아주 짧은 감탄으로 시작한다.",
];
// 정리하는 맺음말은 AI 티가 가장 많이 나서, 대부분은 그냥 끝나게 한다.
const CLOSINGS = [
  "맺음말 없이 마지막으로 말한 장점에서 그냥 끝낸다.",
  "맺음말 없이 마지막으로 말한 장점에서 그냥 끝낸다.",
  "맺음말 없이 마지막으로 말한 장점에서 그냥 끝낸다.",
  "마지막에 '추천해요', '굿' 처럼 두세 단어만 붙이고 끝낸다.",
  "마지막을 '~라고 생각합니다', '~것 같습니다' 처럼 자기 평가로 끝낸다.",
  "마지막을 앱이 잘 되길 바라는 한마디로 끝낸다.",
];
// '다 좋은데형'에서만 쓰는 바람. 같은 불만이 여러 리뷰에 반복되지 않게 서버가 하나를 골라 준다.
// 글씨 크기는 한 번 나오면 눈에 띄어서 비중을 낮췄다. 지금 있는 기능을 없다고 하는 바람은 넣지 않는다.
const WISHES = [
  "앱 켤 때 로딩이 조금만 더 빨랐으면",
  "처음에 메뉴 위치 익히는 데 조금 걸렸다(지금은 괜찮다)",
  "알림 소리를 고를 수 있었으면",
  "앱 아이콘이나 색 테마가 더 다양했으면",
  "업데이트가 더 자주 됐으면",
  "아이패드에서도 화면이 크게 쓰기 좋았으면",
  "가끔 화면 넘어갈 때 한 번 멈칫한다",
  "글씨 크기를 조금 키울 수 있었으면",
];

// 사람 글의 흔한 흐트러짐. 요청마다 0~2개를 뽑는다.
const QUIRKS = [
  "띄어쓰기를 한두 군데 붙여 쓴다.",
  "마지막 문장 끝에 마침표를 찍지 않는다.",
  "말줄임표 '..'를 한 번 쓴다.",
  "주어나 조사를 몇 군데 생략한다.",
  "좋았던 말을 한 번 더 반복해 강조한다.",
  "줄바꿈을 한두 번 넣어 문장을 끊는다.",
  "'앱' 대신 '어플'이라고 쓴다.",
  "트레이너를 '쌤'이나 'PT쌤'이라고 부른다(회원 시점일 때).",
  "두 문장 사이 마침표를 하나 빠뜨리고 그냥 이어 쓴다.",
  "'~!!', 'ㅠㅠ', 'ㅎㅎ', ':)' 중 하나를 한 번 쓴다.",
  "'솔직하게', '진짜', '너무' 중 하나를 한 번 쓴다.",
  "앱 이름 '센티프'를 한 번 부른다.",
];
const SCENES = {
  coach: ["수업과 수업 사이 쉬는 시간", "퇴근 전 정리할 때", "회원 상담 중", "아침에 하루 일정 볼 때", "회원한테 질문 받았을 때", "월말 정리할 때"],
  member: ["퇴근길 지하철에서", "수업 끝나고 집에 와서", "운동 가기 전에", "주말에 기록 돌아볼 때", "선생님한테 물어보고 싶을 때", "운동 쉬고 싶은 날"],
};
const RHYTHMS = [
  "문장 길이를 들쭉날쭉하게 섞는다.",
  "짧은 문장 위주로 쓴다.",
  "한 문장을 쉼표 없이 길게 이어 쓴다.",
];

// 이 화면에서 이미 나온 리뷰의 첫머리(브라우저가 보냄). 한글·영문·숫자·기본 문장부호만 남기고 짧게 자른다.
function cleanUsed(list) {
  if (!Array.isArray(list)) return [];
  return list
    .filter((t) => typeof t === "string")
    .map((t) => t.replace(/[^\p{Script=Hangul}\p{L}\p{N} ~!?.,·'’]/gu, "").trim().slice(0, 30))
    .filter(Boolean)
    .slice(0, 8);
}

const SYSTEM = [
  "너는 앱스토어 리뷰 초안을 한국어로 쓴다. 휴대폰으로 1~2분 만에 대충 쓴 실제 사람 리뷰처럼 써야 한다. 잘 쓴 글이 아니라 진짜 같은 글이 목표다.",
  "",
  "사람 리뷰의 특징:",
  "- 좋았던 것 한두 개만 말한다. 장점을 고루 나열하거나 정리하지 않는다.",
  "- 기능을 설명하지 않는다. '그게 나한테 어땠는지'만 말한다(다른 앱 예시: '출석이 자동으로 기록된다' X → '출석 신경 안 써도 돼서 편함' O. 이 예시 문장은 쓰지 말 것).",
  "- 문장 연결이 매끄럽지 않다. 접속사로 논리를 이어 붙이지 않는다.",
  "- 서론·본론·결론 구조가 없다. 요약하거나 마무리 짓지 않는다.",
  "",
  "쓰지 말 것(AI 글에서 자주 보이는 표현):",
  "- '특히', '또한', '뿐만 아니라', '덕분에', '~하는 데 도움이 됩니다', '가장 좋은 점은', '가장 달라진 점은', '~할 수 있어서 좋습니다'를 연달아 쓰는 것",
  "- '한눈에', '체계적', '꼼꼼하게', '차곡차곡', '수월하다', '매끄럽다', '관리받는 느낌' 같은 소개문 단어(사용자가 고른 좋았던 점 이름에 들어 있어도 그대로 쓰지 말고 다른 말로)",
  "- '반신반의', '처음에는 ~했는데 지금은 ~' 같은 전환 공식",
  "- '앞으로도 잘 쓰겠습니다', '좋은 앱 만들어 주셔서 감사합니다', '~분들께 권해 드립니다' 같은 정리 인사('강력 추천합니다!'처럼 짧은 추천은 괜찮다)",
  "- 앱 이름(센티프)을 본문에 넣는 것(글 구성에서 부르라고 할 때만 한 번)",
  "",
  "지킬 것:",
  "- 사용자가 준 기능 설명 범위 안의 내용만 쓴다. 설명에 없는 기능이나 효과는 지어내지 않는다.",
  "- 조작 방법(끌어다 놓기, 스와이프, 버튼 위치 등)이나 예약·결제 같은 기능을 구체적으로 지어내지 않는다. 기능 설명에 없는 화면 동작은 쓰지 않는다.",
  "- '완벽', '최고', '무조건', '100%', '모든' 같은 단정·과장 표현을 쓰지 않는다.",
  "- 숫자, 기간, 금액, 센터 이름, 사람 이름을 지어내지 않는다. 새로 나온 버전이라 '몇 년째', '오래 썼다' 같은 사용 기간 얘기도 하지 않는다.",
  "- 광고 문구, 해시태그, 이모지를 쓰지 않는다.",
  "- 기능 설명을 그대로 옮겨 적지 말고, 작성자가 자기 말로 바꿔 말하듯 쓴다. 기능 이름을 꼭 그대로 쓸 필요는 없다.",
  "- 사용자가 '언급할 것'으로 준 것만 쓴다. 나머지 좋았던 점은 쓰지 않는다.",
  "",
  "쓰는 순서: 먼저 draft에 초안을 쓰고, 초안에서 위 '쓰지 말 것'이나 설명문·광고문처럼 읽히는 부분을 ai_like에 짚은 다음, 그 부분을 사람 말로 고친 최종본을 body에 쓴다. 제목은 쓰지 않는다.",
].join("\n");

const SCHEMA = {
  type: "object",
  properties: {
    draft: { type: "string" },
    ai_like: { type: "array", items: { type: "string" } },
    body: { type: "string" },
  },
  required: ["draft", "ai_like", "body"],
  additionalProperties: false,
};

const ALLOWED_ORIGINS = [/^https:\/\/(www\.)?ssentif\.kr$/, /^https:\/\/[a-z0-9-]+\.vercel\.app$/, /^http:\/\/(127\.0\.0\.1|localhost)(:\d+)?$/];

// 인스턴스별 간이 제한(분당 IP당 8회). 완전한 차단은 아니고 연타 방지용.
const hits = new Map();
function limited(ip) {
  const now = Date.now();
  const recent = (hits.get(ip) || []).filter((t) => now - t < 60_000);
  recent.push(now);
  hits.set(ip, recent);
  return recent.length > 8;
}

const pick = (a) => a[Math.floor(Math.random() * a.length)];
const pickWeighted = (a) => {
  let r = Math.random() * a.reduce((s, x) => s + (x.weight || 1), 0);
  for (const x of a) { r -= x.weight || 1; if (r < 0) return x; }
  return a[a.length - 1];
};
const shuffle = (a) => {
  a = a.slice();
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
};

export default async function handler(req, res) {
  if (req.method !== "POST") return res.status(405).json({ error: "method_not_allowed" });

  const origin = req.headers.origin;
  if (origin && !ALLOWED_ORIGINS.some((re) => re.test(origin))) return res.status(403).json({ error: "forbidden" });

  const ip = String(req.headers["x-forwarded-for"] || "").split(",")[0].trim() || "unknown";
  if (limited(ip)) return res.status(429).json({ error: "too_many_requests" });

  const { app, keywords, length, used } = req.body || {};
  const A = APPS[app];
  if (!A || !LENGTHS[length] || !Array.isArray(keywords)) return res.status(400).json({ error: "bad_request" });
  const kws = [...new Set(keywords)].filter((id) => typeof id === "string" && A.keywords[id]).slice(0, 11);
  if (!kws.length) return res.status(400).json({ error: "bad_request" });

  // '한 줄 평'은 사용자가 '짧게'를 골랐을 때만 나온다
  const tone = pickWeighted(TONES.filter((t) => t.lengths.includes(length)));
  const ordered = shuffle(kws).slice(0, MENTION_CAP[length]); // 고른 것 중 일부만 언급
  const quirks = shuffle(QUIRKS).slice(0, Math.floor(Math.random() * 3));
  const usedStarts = cleanUsed(used);
  const prompt = [
    `앱: ${A.name} (${A.desc})`,
    `작성자: ${pick(A.personas)}`,
    `말투 타입: ${tone.name}`,
    ...tone.guide.map((g) => `- ${g}`),
    "언급할 것(기능 설명은 참고용, 그대로 옮기지 말 것):",
    ...ordered.map((id) => `- ${A.keywords[id][0]}: ${A.keywords[id][1]}`),
    `길이: ${LENGTHS[length]}`,
    "글 구성:",
    // 초단문·한 줄 평은 구성 지시가 붙으면 길어지므로 흐트러짐만 하나 넣는다
    ...(tone.minimal
      ? [...quirks.slice(0, 1).map((q) => `- ${q}`), "- 불만, 아쉬움, 바라는 점은 쓰지 않는다."]
      : [
          `- ${pick(OPENINGS)}`,
          `- ${pick(CLOSINGS)}`,
          tone.wish ? `- 덧붙일 바람: ${pick(WISHES)} (다른 불만이나 바람은 쓰지 않는다)` : "- 불만, 아쉬움, 바라는 점은 쓰지 않는다.",
          `- ${pick(RHYTHMS)}`,
          ...quirks.map((q) => `- ${q}`),
          `- 떠올릴 장면: ${pick(SCENES[app])} (꼭 쓰지 않아도 되지만, 쓰면 이 장면으로)`,
        ]),
    ...(usedStarts.length ? ["이미 쓴 리뷰의 첫머리(이렇게 시작하지 말 것):", ...usedStarts.map((t) => `- ${t}`)] : []),
    "이 앱의 리뷰 본문을 써줘.",
  ].join("\n");

  try {
    const response = await client.beta.messages.create({
      model: "claude-opus-5-5",
      max_tokens: 6000,
      betas: ["server-side-fallback-2026-07-01"],
      fallbacks: "default",
      output_config: { effort: "low", format: { type: "json_schema", schema: SCHEMA } },
      system: SYSTEM,
      messages: [{ role: "user", content: prompt }],
    });

    if (response.stop_reason === "refusal" || response.stop_reason === "max_tokens") {
      return res.status(502).json({ error: "no_result" });
    }
    const text = response.content.find((b) => b.type === "text")?.text;
    const out = JSON.parse(text || "{}");
    if (typeof out.body !== "string" || !out.body.trim()) {
      return res.status(502).json({ error: "no_result" });
    }
    return res.status(200).json({ body: out.body.trim(), tone: tone.name });
  } catch (error) {
    if (error instanceof Anthropic.RateLimitError) {
      return res.status(429).json({ error: "too_many_requests" });
    }
    if (error instanceof Anthropic.APIError) {
      console.error(`Claude API error ${error.status}:`, error.message);
      return res.status(502).json({ error: "upstream_error" });
    }
    console.error("review generation failed:", error);
    return res.status(500).json({ error: "server_error" });
  }
}
