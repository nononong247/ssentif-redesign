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
    personas: ["PT센터 트레이너", "필라테스 강사", "PT센터 대표", "센터 매니저"],
    keywords: {
      schedule: ["수업 일정 관리", "개인·그룹 수업 일정을 캘린더로 잡고 옮긴다"],
      pass: ["수강권 관리", "회원별 수강권의 남은 횟수와 기간을 보고, 수업 일정과 사용한 수강권이 연결된다"],
      members: ["회원 관리", "회원 정보와 수업 이력을 한 곳에서 본다"],
      journal: ["수업일지", "수업 후 남긴 수업일지가 회원 앱으로 전달된다"],
      video3d: ["3D 운동영상", "운동마다 3D 운동 영상이 있어 동작을 영상으로 보여줄 수 있다"],
      easy: ["쓰기 쉬움", "화면이 단순해서 금방 익숙해진다"],
      liked: ["회원님이 좋아함", "회원들이 회원 앱으로 수업 기록을 받아보며 관리받는다고 느끼고 좋아한다"],
      timesave: ["업무 시간 줄어듦", "일정·수강권·수업일지를 한 앱에서 처리해 따로 정리하던 시간이 준다"],
      records: ["기록이 쌓여 든든함", "회원별 수업 기록이 쌓여 언제든 다시 꺼내 볼 수 있다"],
      organized: ["센터 운영이 체계적", "센터 업무가 한 앱으로 정리되고 누가 써도 같은 방식으로 기록이 남는다"],
    },
  },
  member: {
    name: "센티프 회원",
    desc: "PT·필라테스 센터 회원이 쓰는 앱",
    personas: ["PT 받는 직장인 회원", "필라테스 다니는 회원", "운동 시작한 지 얼마 안 된 회원", "꾸준히 PT 받는 회원"],
    keywords: {
      easy: ["쓰기 쉬움", "화면이 단순해서 쓰기 쉽다"],
      data: ["내 데이터 확인", "내 운동 기록과 몸 변화 데이터를 앱에서 본다"],
      myvideo: ["내 운동 영상", "수업 중 찍은 내 운동 영상을 앱에서 다시 본다"],
      journal: ["수업일지", "수업 후 트레이너가 남긴 수업일지를 받아본다"],
      pass: ["남은 횟수 확인", "남은 수강권 횟수와 기간을 본다"],
      schedule: ["수업 일정 확인", "내 수업 일정을 앱에서 본다"],
      motivation: ["운동 동기부여", "기록과 변화가 쌓이는 걸 보며 꾸준히 운동하게 된다"],
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
      "제목은 '굿굿', '편해요!', '센터 필수앱인듯' 처럼 아주 짧은 감탄으로 쓴다.",
      "예시 느낌: '수업일지 바로 와서 좋음! 쓰기도 쉬워요~'",
    ],
  },
  {
    name: "경험담 비교형",
    guide: [
      "자기 상황을 먼저 말하고, 예전 방식이나 다른 방법과 비교해서 지금 좋은 점을 말한다. '~했는데 ~니까 좋아요' 흐름.",
      "~요체로 쓰고, 느낌표는 많아야 한 번이다. 'ㅋㅋ'는 많아야 한 번.",
      "제목은 '카톡 대신 앱으로 하니 편해요' 처럼 경험을 한 줄로 요약한다.",
      "예시 느낌: '예전엔 수업 끝나고 카톡으로 따로 보냈는데, 이제는 앱에 남기면 회원님한테 바로 가서 편해요.'",
    ],
  },
  {
    name: "정중한 사용 후기형",
    guide: [
      "'잘 사용하고 있습니다'처럼 정중한 ~습니다체로 쓴다. 인사('안녕하세요')로 시작해도 된다.",
      "좋은 점을 차분히 정리하고, 끝은 '앞으로도 잘 쓰겠습니다', '업데이트도 기대하겠습니다' 같은 인사로 맺는다. 새 기능을 요청하지는 않는다.",
      "느낌표와 'ㅎㅎ'·'ㅋㅋ'는 쓰지 않는다. 길게 쓸 때는 문단을 나눈다.",
      "제목은 '잘 사용하고 있습니다', '센터 운영에 도움이 됩니다' 처럼 단정하게 쓴다.",
    ],
  },
];

const SYSTEM = [
  "너는 앱스토어 리뷰 초안을 한국어로 쓴다. 실제 사용자가 휴대폰으로 직접 쓴 것처럼 자연스럽게 쓰고, 말투는 사용자가 정해 준 타입을 그대로 따른다.",
  "규칙:",
  "- 사용자가 준 기능 설명 범위 안의 내용만 쓴다. 설명에 없는 기능이나 효과는 지어내지 않는다.",
  "- '완벽', '최고', '무조건', '100%', '모든' 같은 단정·과장 표현을 쓰지 않는다.",
  "- 숫자, 기간, 금액, 센터 이름, 사람 이름을 지어내지 않는다.",
  "- 광고 문구, 해시태그, 이모지를 쓰지 않는다.",
  "- 제목은 20자 이내로 쓴다.",
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

export default async function handler(req, res) {
  if (req.method !== "POST") return res.status(405).json({ error: "method_not_allowed" });

  const origin = req.headers.origin;
  if (origin && !ALLOWED_ORIGINS.some((re) => re.test(origin))) return res.status(403).json({ error: "forbidden" });

  const ip = String(req.headers["x-forwarded-for"] || "").split(",")[0].trim() || "unknown";
  if (limited(ip)) return res.status(429).json({ error: "too_many_requests" });

  const { app, keywords, length } = req.body || {};
  const A = APPS[app];
  if (!A || !LENGTHS[length] || !Array.isArray(keywords)) return res.status(400).json({ error: "bad_request" });
  const kws = [...new Set(keywords)].filter((id) => typeof id === "string" && A.keywords[id]).slice(0, 11);
  if (!kws.length) return res.status(400).json({ error: "bad_request" });

  const tone = pick(TONES);
  const prompt = [
    `앱: ${A.name} (${A.desc})`,
    `작성자: ${pick(A.personas)}`,
    `말투 타입: ${tone.name}`,
    ...tone.guide.map((g) => `- ${g}`),
    "좋았던 점:",
    ...kws.map((id) => `- ${A.keywords[id][0]}: ${A.keywords[id][1]}`),
    `길이: ${LENGTHS[length]}`,
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
