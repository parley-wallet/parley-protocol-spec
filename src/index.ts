interface Env {
  ASSETS: Fetcher;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    // Redirect bare root to the canonical v1 location.
    if (url.pathname === "/" || url.pathname === "") {
      return Response.redirect(`${url.origin}/v1/protocol.html`, 301);
    }

    const response = await env.ASSETS.fetch(request);

    const headers = new Headers(response.headers);
    headers.set("Strict-Transport-Security", "max-age=63072000; includeSubDomains; preload");
    headers.set("X-Content-Type-Options", "nosniff");
    headers.set("Referrer-Policy", "no-referrer");
    headers.set("Content-Security-Policy",
      "default-src 'none'; style-src 'unsafe-inline' 'self'; img-src 'self' data:; base-uri 'none'; form-action 'none'; frame-ancestors 'none'");

    return new Response(response.body, { status: response.status, headers });
  },
};
