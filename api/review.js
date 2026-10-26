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
  short: "본문 1~2문장, 80자 안팎",
  mid: "본문 3~4문장, 200자 안팎",
  long: "본문 5~7문장, 400자 안팎, 두세 문단(문단 사이 빈 줄)",
};

// 말투 3타입 — 한국 앱스토어 피트니스 앱(플랜핏·바디코디·짐워크·번핏) 4~5점 리뷰 153건을 보고 나눈 패턴.
// 생성할 때마다 하나를 무작위로 고른다. 예시 문장은 직접 쓴 것(실제 리뷰 문장 복사 아님).
const TONES = [
  {
    name: "짧은 감탄형",
    guide: [
      "가볍게 툭 던지듯 쓴다. 문장이 짧고, '~좋음', '~편함', '추천중' 같은 음슴체·명사형 끝맺음과 '~요'를 섞는다.",
      "느낌표나 물결(~)을 한두 번 쓰고, 'ㅎㅎ'나 'ㅋㅋ'는 넣어도 되고 안 넣어도 된다.",
      "제목은 감탄 한마디처럼 아주 짧게 쓴다.",
    ],
  },
  {
    name: "경험담 비교형",
    guide: [
      "자기 상황을 먼저 말하고, 예전 방식이나 다른 방법과 비교해서 지금 좋은 점을 말한다. '~했는데 ~니까 좋아요' 흐름.",
      "~요체로 쓰고, 느낌표는 많아야 한 번이다. 'ㅋㅋ'는 많아야 한 번.",
      "제목은 자기 경험을 한 줄로 요약한다.",
    ],
  },
  {
    name: "정중한 사용 후기형",
    guide: [
      "'잘 사용하고 있습니다'처럼 정중한 ~습니다체로 쓴다. 인사('안녕하세요')로 시작해도 된다.",
      "좋은 점을 차분히 정리하고, 끝은 '앞으로도 잘 쓰겠습니다', '업데이트도 기대하겠습니다' 같은 인사로 맺는다. 새 기능을 요청하지는 않는다.",
      "느낌표와 'ㅎㅎ'·'ㅋㅋ'는 쓰지 않는다. 길게 쓸 때는 문단을 나눈다.",
      "제목은 단정한 ~습니다체나 명사형으로 쓴다.",
    ],
  },
];

// 아래 축들은 요청마다 하나씩 무작위로 뽑아 프롬프트에 넣는다. 조합이 많을수록
// 같은 키워드를 고른 여러 사람의 글이 한 프로그램이 찍어낸 것처럼 보이지 않는다.
const TITLE_STYLES = [
  "좋았던 기능 하나를 콕 집어 말하는 제목",
  "쓰고 나서 달라진 점을 말하는 제목",
  "누구에게 권하는지 말하는 제목(예: '~하는 분들께')",
  "느낌이나 감정을 한마디로 쓴 제목",
  "짧은 질문형 제목",
  "'드디어', '이제야' 처럼 기다렸다는 느낌의 제목",
  "담담하게 평가 한 줄로 쓴 제목",
  "자기 상황을 말하는 제목(예: 센터 규모, 운동 목적)",
];
const OPENINGS = [
  "첫 문장은 자기 상황 소개로 시작한다.",
  "첫 문장부터 바로 가장 좋은 점을 말한다.",
  "첫 문장은 이 앱을 쓰게 된 계기로 시작한다.",
  "첫 문장은 솔직한 첫인상(기대 안 했다, 반신반의했다 등)으로 시작한다.",
  "첫 문장은 구체적인 장면 하나로 시작한다.",
  "첫 문장은 한 단어나 아주 짧은 감탄으로 시작한다.",
];
const CLOSINGS = [
  "마지막은 누군가에게 추천하는 말로 끝낸다.",
  "마지막은 앞으로의 기대로 끝낸다.",
  "마지막 문장은 좋은 점을 하나 더 말하고 인사 없이 그냥 끝낸다.",
  "마지막은 짧은 한마디로 툭 끝낸다.",
  "마지막은 사소하게 아쉬운 점(기능 요청이 아닌, 익숙해지는 데 시간이 조금 걸렸다 정도)을 가볍게 덧붙이고 그래도 만족한다고 끝낸다.",
  "마지막은 고맙다는 말로 끝낸다.",
];
const SCENES = {
  coach: ["수업과 수업 사이 쉬는 시간", "퇴근 전 정리할 때", "회원 상담 중", "아침에 하루 일정 볼 때", "회원한테 질문 받았을 때", "월말 정리할 때"],
  member: ["퇴근길 지하철에서", "수업 끝나고 집에 와서", "운동 가기 전에", "주말에 기록 돌아볼 때", "선생님한테 물어보고 싶을 때", "운동 쉬고 싶은 날"],
};
const RHYTHMS = [
  "문장 길이를 들쭉날쭉하게 섞는다.",
  "짧은 문장 위주로 쓴다.",
  "한 문장은 길게, 나머지는 짧게 쓴다.",
  "말하듯이 쉼표 없이 이어 쓰는 문장을 하나 넣는다.",
];

// 이 화면에서 이미 나온 제목(브라우저가 보냄). 한글·영문·숫자·기본 문장부호만 남기고 짧게 자른다.
function cleanUsed(list) {
  if (!Array.isArray(list)) return [];
  return list
    .filter((t) => typeof t === "string")
    .map((t) => t.replace(/[^\p{Script=Hangul}\p{L}\p{N} ~!?.,·'’]/gu, "").trim().slice(0, 30))
    .filter(Boolean)
    .slice(0, 8);
}

const SYSTEM = [
  "너는 앱스토어 리뷰 초안을 한국어로 쓴다. 실제 사용자가 휴대폰으로 직접 쓴 것처럼 자연스럽게 쓰고, 말투는 사용자가 정해 준 타입을 그대로 따른다.",
  "규칙:",
  "- 사용자가 준 기능 설명 범위 안의 내용만 쓴다. 설명에 없는 기능이나 효과는 지어내지 않는다.",
  "- '완벽', '최고', '무조건', '100%', '모든' 같은 단정·과장 표현을 쓰지 않는다.",
  "- 숫자, 기간, 금액, 센터 이름, 사람 이름을 지어내지 않는다.",
  "- 광고 문구, 해시태그, 이모지를 쓰지 않는다.",
  "- 제목은 20자 이내로 쓴다. 제목과 본문 첫 문장이 같은 말을 반복하지 않게 한다.",
  "- 기능 설명을 그대로 옮겨 적지 말고, 작성자가 자기 말로 바꿔 말하듯 쓴다. 기능 이름을 꼭 그대로 쓸 필요는 없다.",
  "- 좋았던 점을 전부 같은 비중으로 나열하지 않는다. 사용자가 '중심'으로 지정한 것을 자세히 쓰고 나머지는 가볍게 스치거나 생략해도 된다.",
].join("\n");

const SCHEMA = {
  type: "object",
  properties: {
    title: { type: "string" },
    body: { type: "string" },
  },
  required: ["title", "body"],
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

  const tone = pick(TONES);
  const ordered = shuffle(kws); // 맨 앞이 중심 키워드
  const usedTitles = cleanUsed(used);
  const prompt = [
    `앱: ${A.name} (${A.desc})`,
    `작성자: ${pick(A.personas)}`,
    `말투 타입: ${tone.name}`,
    ...tone.guide.map((g) => `- ${g}`),
    "좋았던 점:",
    ...ordered.map((id, i) => `- ${A.keywords[id][0]}${i === 0 ? " (중심)" : ""}: ${A.keywords[id][1]}`),
    `길이: ${LENGTHS[length]}`,
    "글 구성:",
    `- ${pick(OPENINGS)}`,
    `- ${pick(CLOSINGS)}`,
    `- ${pick(RHYTHMS)}`,
    `- 떠올릴 장면: ${pick(SCENES[app])} (꼭 쓰지 않아도 되지만, 쓰면 이 장면으로)`,
    `- 제목 스타일: ${pick(TITLE_STYLES)}`,
    ...(usedTitles.length ? ["이미 쓴 제목(비슷한 제목 금지):", ...usedTitles.map((t) => `- ${t}`)] : []),
    "이 앱의 리뷰 제목과 본문을 써줘.",
  ].join("\n");

  try {
    const response = await client.beta.messages.create({
      model: "claude-opus-5-5",
      max_tokens: 4000,
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
    if (typeof out.title !== "string" || typeof out.body !== "string" || !out.body.trim()) {
      return res.status(502).json({ error: "no_result" });
    }
    return res.status(200).json({ title: out.title.trim(), body: out.body.trim(), tone: tone.name });
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
