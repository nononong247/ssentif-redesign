import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const SLACK_WEBHOOK_URL = Deno.env.get("SLACK_WEBHOOK_URL") ?? "";

serve(async (req) => {
  try {
    const payload = await req.json();
    const r = payload.record;

    if (!r || payload.type !== "INSERT") {
      return new Response("ok", { status: 200 });
    }

    const msgText = r.message
      ? `\n> ${r.message.replace(/\n/g, "\n> ")}`
      : "";

    const submittedAt = r.submitted_at
      ? new Date(r.submitted_at).toLocaleString("ko-KR", { timeZone: "Asia/Seoul" })
      : new Date().toLocaleString("ko-KR", { timeZone: "Asia/Seoul" });

    const body = {
      blocks: [
        {
          type: "header",
          text: { type: "plain_text", text: "📬 새 상담 문의가 접수됐습니다", emoji: true },
        },
        {
          type: "section",
          fields: [
            { type: "mrkdwn", text: `*성함*\n${r.name}${r.role ? ` (${r.role})` : ""}` },
            { type: "mrkdwn", text: `*센터명*\n${r.center_name}` },
            { type: "mrkdwn", text: `*연락처*\n${r.phone}` },
            { type: "mrkdwn", text: `*이메일*\n${r.email || "—"}` },
            { type: "mrkdwn", text: `*센터 규모*\n${r.center_size || "미기재"}` },
            { type: "mrkdwn", text: `*관심 플랜*\n${r.plan || "미정"}` },
          ],
        },
        ...(r.message
          ? [{ type: "section", text: { type: "mrkdwn", text: `*문의 내용*${msgText}` } }]
          : []),
        { type: "divider" },
        {
          type: "context",
          elements: [
            { type: "mrkdwn", text: `문의 ID: #${r.id} · 접수: ${submittedAt}` },
          ],
        },
      ],
    };

    const res = await fetch(SLACK_WEBHOOK_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });

    if (!res.ok) {
      console.error("Slack webhook failed:", res.status, await res.text());
    }

    return new Response("ok", { status: 200 });
  } catch (err) {
    console.error("notify-slack error:", err);
    return new Response("error", { status: 500 });
  }
});
