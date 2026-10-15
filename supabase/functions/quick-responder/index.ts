// Supabase Edge Function : détection d'ingrédients et de produits emballés
// Reçoit une photo et demande à Gemini (offre gratuite) :
//  - quels ingrédients (parmi une liste connue) sont visibles ;
//  - quels produits emballés (parmi une liste de marques connues) sont reconnus à leur emballage.
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
    const { image_base64, media_type, known, products } = await req.json();
    const allowed = ["image/jpeg", "image/png", "image/webp"];
    if (typeof image_base64 !== "string" || image_base64.length === 0 || image_base64.length > 4_000_000) {
      return json({ error: "Image invalide ou trop lourde" }, 400);
    }
    if (!allowed.includes(media_type)) return json({ error: "Format d'image non supporté" }, 400);
    if (!Array.isArray(known) || known.length === 0 || known.length > 200) {
      return json({ error: "Liste d'ingrédients invalide" }, 400);
    }
    const knownList: string[] = known.map((k: unknown) => String(k));

    // Produits emballés connus : [{ id, label }], optionnel
    const productList: { id: number; label: string }[] = [];
    if (Array.isArray(products)) {
      if (products.length > 150) return json({ error: "Liste de produits trop longue" }, 400);
      for (const p of products) {
        const id = Number(p?.id);
        const label = String(p?.label ?? "").slice(0, 120);
        if (Number.isInteger(id) && label) productList.push({ id, label });
      }
    }

    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) return json({ error: "Clé API manquante côté serveur" }, 500);

    let prompt =
      `Voici une photo d'ingrédients de cuisine et de produits d'épicerie. ` +
      `1) Liste les ingrédients clairement visibles, en choisissant UNIQUEMENT parmi cette liste : ${knownList.join(", ")}. ` +
      `Un produit emballé (boîte de conserve, tube, brique de lait, pain de beurre, boîte de fromage) compte pour l'ingrédient qu'il contient. `;
    if (productList.length > 0) {
      prompt +=
        `2) Identifie les produits emballés dont tu lis la marque ou reconnais clairement l'emballage, ` +
        `UNIQUEMENT parmi cette liste (id: description) : ` +
        productList.map((p) => `${p.id}: ${p.label}`).join(" ; ") +
        `. Pour chacun, indique combien d'exemplaires sont visibles (count). Si la marque est lisible mais la taille ou la variante est incertaine, choisis le produit le plus proche de la même marque. ` +
        `Si tu n'es pas sûr de la marque, ne le mets pas. `;
    }
    prompt +=
      `N'invente rien. Réponds uniquement avec un objet JSON de la forme ` +
      `{"ingredients":["tomate","oeuf"],"products":[{"id":3,"count":2}]}. ` +
      `Si rien ne correspond, réponds {"ingredients":[],"products":[]}.`;

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
    const text: string = data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "{}";
    let foundIngredients: unknown[] = [];
    let foundProducts: unknown[] = [];
    try {
      const objMatch = text.match(/\{[\s\S]*\}/);
      const arrMatch = text.match(/\[[\s\S]*\]/);
      if (objMatch) {
        const parsed = JSON.parse(objMatch[0]);
        if (Array.isArray(parsed?.ingredients)) foundIngredients = parsed.ingredients;
        if (Array.isArray(parsed?.products)) foundProducts = parsed.products;
      } else if (arrMatch) {
        foundIngredients = JSON.parse(arrMatch[0]); // ancien format : simple tableau
      }
    } catch (_) {
      foundIngredients = [];
      foundProducts = [];
    }

    const set = new Set(knownList);
    const ingredients = [...new Set(foundIngredients.map((x) => String(x)).filter((x) => set.has(x)))];

    const validIds = new Set(productList.map((p) => p.id));
    const counts = new Map<number, number>();
    for (const p of foundProducts) {
      const id = Number((p as { id?: unknown })?.id);
      let count = Math.round(Number((p as { count?: unknown })?.count ?? 1));
      if (!validIds.has(id)) continue;
      if (!Number.isFinite(count) || count < 1) count = 1;
      counts.set(id, Math.min(20, (counts.get(id) ?? 0) + count));
    }
    const productsOut = [...counts.entries()].map(([id, count]) => ({ id, count }));

    return json({ ingredients, products: productsOut });
  } catch (e) {
    console.error(e);
    return json({ error: "Erreur serveur" }, 500);
  }
});
