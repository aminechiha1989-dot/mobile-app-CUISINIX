// Supabase Edge Function : quick-responder (détection d'ingrédients par photo)
// Reçoit une photo, demande à Gemini (offre gratuite) quels ingrédients (parmi une liste connue) sont visibles.
// Secret requis côté Supabase : GEMINI_API_KEY (jamais dans le dépôt).
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    const { image_base64, media_type, known } = await req.json();
    const allowed = ["image/jpeg", "image/png", "image/webp"];
    if (typeof image_base64 !== "string" || image_base64.length === 0 || image_base64.length > 4_000_000) {
      return json({ error: "Image invalide ou trop lourde" }, 400);
    }
    if (!allowed.includes(media_type)) return json({ error: "Format d'image non supporté" }, 400);
    if (!Array.isArray(known) || known.length === 0 || known.length > 200) {
      return json({ error: "Liste d'ingrédients invalide" }, 400);
    }
    const knownList: string[] = known.map((k: unknown) => String(k));

    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) return json({ error: "Clé API manquante côté serveur" }, 500);

    const prompt =
      `Voici une photo d'ingrédients de cuisine. Liste ceux qui sont clairement visibles, ` +
      `en choisissant UNIQUEMENT parmi cette liste : ${knownList.join(", ")}. ` +
      `N'invente rien. Réponds uniquement avec un tableau JSON de chaînes, par exemple ["tomate","oeuf"]. ` +
      `Si rien ne correspond, réponds [].`;

    const model = "gemini-3.1-flash-lite"; // modèle avec offre gratuite
    const resp = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
      {
        method: "POST",
        headers: { "x-goog-api-key": apiKey, "content-type": "application/json" },
        body: JSON.stringify({
          contents: [{
            parts: [
              { inline_data: { mime_type: media_type, data: image_base64 } },
              { text: prompt },
            ],
          }],
          generationConfig: { temperature: 0, responseMimeType: "application/json" },
        }),
      },
    );

    if (!resp.ok) {
      const detail = await resp.text();
      console.error("Gemini error", resp.status, detail);
      return json({ error: resp.status === 429 ? "Limite gratuite atteinte, réessaie plus tard" : "Échec de l'analyse de l'image" }, 502);
    }

    const data = await resp.json();
    const text: string = data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "[]";
    const match = text.match(/\[[\s\S]*\]/);
    let found: unknown[] = [];
    try {
      found = match ? JSON.parse(match[0]) : [];
    } catch (_) {
      found = [];
    }
    const set = new Set(knownList);
    const ingredients = [...new Set(found.map((x) => String(x)).filter((x) => set.has(x)))];
    return json({ ingredients });
  } catch (e) {
    console.error(e);
    return json({ error: "Erreur serveur" }, 500);
  }
});
