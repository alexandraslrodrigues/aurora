# Opens every page at phone/tablet/desktop sizes, reports JS errors, takes screenshots.
import sys, asyncio
from playwright.async_api import async_playwright
BASE = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8080/"
ROUTES = ["#/", "#/cognitive/report", "#/cognitive/protocol", "#/cognitive/protocol/anti-amyloid", "#/movement/protocol", "#/cognitive/protocol/xyz", "#/cognitive/calculators", "#/cognitive/calculators/gca",
          "#/cognitive/calculators/mta", "#/cognitive/calculators/erica", "#/cognitive/calculators/koedam",
          "#/movement/report", "#/movement/calculators", "#/movement/calculators/mrpi", "#/movement/calculators/mrpi-2",
          "#/movement/calculators/midbrain-pons-ratio", "#/movement/calculators/diameter-ratio", "#/movement/calculators/mcp-width",
          "#/help", "#/about", "#/nope"]
SIZES = {"phone": (390, 844), "tablet": (820, 1180), "desktop": (1366, 900)}
async def main():
    async with async_playwright() as p:
        b = await p.chromium.launch()
        errors = []
        for name, (w, h) in SIZES.items():
            ctx = await b.new_context(viewport={"width": w, "height": h}, device_scale_factor=1)
            page = await ctx.new_page()
            page.on("pageerror", lambda e: errors.append(f"{name}: {e}"))
            page.on("console", lambda m: errors.append(f"{name} console {m.type}: {m.text}") if m.type in ("error", "warning") else None)
            for r in ROUTES:
                await page.goto(BASE + r); await page.wait_for_timeout(250)
                sw = await page.evaluate("document.documentElement.scrollWidth > window.innerWidth + 1")
                if sw: errors.append(f"{name} {r}: horizontal overflow")
                if r in ("#/", "#/cognitive/protocol", "#/cognitive/protocol/anti-amyloid", "#/movement/protocol", "#/cognitive/report", "#/movement/calculators/mrpi", "#/cognitive/calculators/gca"):
                    await page.screenshot(path=f"tests/shots/{name}_{r.strip('#/').replace('/','_') or 'home'}.png", full_page=False)
            await ctx.close()
        await b.close()
        print("\n".join(errors) or "no errors")
asyncio.run(main())
