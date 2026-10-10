# Checks the site keeps working offline after the first visit, and when opened as a local file.
import asyncio, pathlib
from playwright.async_api import async_playwright
async def main():
    async with async_playwright() as p:
        b = await p.chromium.launch()
        ctx = await b.new_context(); pg = await ctx.new_page()
        await pg.goto("http://localhost:8080/#/cognitive/report")
        await pg.evaluate("navigator.serviceWorker.ready.then(() => true)")
        await pg.wait_for_timeout(1500)
        await ctx.set_offline(True)
        await pg.reload(); await pg.wait_for_selector(".sec")
        n = await pg.locator("#report-text p").count()
        await pg.goto("http://localhost:8080/#/movement/calculators/mrpi"); await pg.wait_for_selector("#mv-midbrain")
        img_ok = await pg.evaluate("(async()=>{const r=await fetch('img/picture_mta.webp');return r.ok})()")
        print("offline: report lines", n, "| movement page ok | image from cache:", img_ok)
        await ctx.close()
        ctx = await b.new_context(); pg = await ctx.new_page(); errs = []
        pg.on("pageerror", lambda e: errs.append(str(e)))
        await pg.goto("file://" + str(pathlib.Path("site/index.html").resolve()) + "#/cognitive/report"); await pg.wait_for_selector(".sec")
        print("file:// ok, report lines", await pg.locator("#report-text p").count(), "errors:", errs or "none")
        await b.close()
asyncio.run(main())
