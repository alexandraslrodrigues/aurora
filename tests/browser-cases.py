# Drives the real page like a user (clicks and typing) to rebuild some test cases,
# then compares the report shown on screen with the Shiny app output (EN and PT),
# and downloads the Excel file.
import sys, json, asyncio, re
from playwright.async_api import async_playwright
BASE = "http://localhost:8080/"
cases = json.load(open("tests/out/cases.json")); shiny = json.load(open("tests/out/shiny.json"))
by_name = {c["name"]: (c, s) for c, s in zip(cases, shiny)}
PICK = ["svd 4", "rsi 4", "lacunes 3", "mb corpus callosum 3 + thalamus 1 (review item 1)", "gca third + frontal", "gca bilateral + single",
        "mta age 74.9 R2 L3", "mta age null R4 L1", "wmh pv 2 peri-atrial left", "wmh deep 3 corona radiata right",
        "pvs 243", "css 21", "erica/koedam R3 L1", "all sections off"] + [f"random {i}" for i in (3, 11, 42, 77, 150, 299)]
norm = lambda s: re.sub(r"\s+", " ", s).strip()

async def set_seg(page, sec, label, value):
    await page.locator(f'.sec[data-id="{sec}"] .field', has=page.locator(f'.label:text-is("{label}")')).locator(f'button[data-v="{value}"]').first.click()

async def apply(page, st, locmap):
    await page.goto(BASE + "#/cognitive/report"); await page.evaluate("sessionStorage.clear()"); await page.reload()
    await page.wait_for_selector(".sec")
    await page.locator(f'.patient button[data-v="{st["sex"]}"]').click()
    if st["age"] is not None: await page.fill("#age-input", str(st["age"]))
    for sec in ["rsi","lacunes","wmh","pvs","microbleeds","css","gca","mta","erica","koedam"]:
        await page.locator(f'.sec[data-id="{sec}"] .status button[data-v="abnormal"]').click()
    for key in ["rsi", "lacunes"]:
        for lid in st[key]:
            await page.locator(f'.sec[data-id="{key}"] button[aria-label="{locmap[lid]}"]').click()
    w = st["wmh"]
    await set_seg(page, "wmh", "Periventricular white matter", w["pvGrade"])
    if w["pvGrade"]:
        await page.locator('.sec[data-id="wmh"] .field-row > div').nth(0).locator(f'.field:has(.label:text-is("Predominant distribution")) button[data-v="{w["pvDist"]}"]').click()
        await page.locator('.sec[data-id="wmh"] .field-row > div').nth(0).locator(f'.field:has(.label:text-is("Laterality")) button[data-v="{w["pvLat"]}"]').click()
    await set_seg(page, "wmh", "Deep white matter", w["dwmGrade"])
    if w["dwmGrade"]:
        await page.locator('.sec[data-id="wmh"] .field-row > div').nth(1).locator(f'.field:has(.label:text-is("Predominant distribution")) button[data-v="{w["dwmDist"]}"]').click()
        await page.locator('.sec[data-id="wmh"] .field-row > div').nth(1).locator(f'.field:has(.label:text-is("Laterality")) button[data-v="{w["dwmLat"]}"]').click()
    for k, lab in [("cs","Centra semiovalia"),("bg","Basal ganglia"),("mes","Mesencephalon")]:
        await set_seg(page, "pvs", lab, st["pvs"][k])
    for reg, m in st["mb"].items():
        for f, name in [("dr","definite right"),("dl","definite left"),("pr","possible right"),("pl","possible left")]:
            if m[f]:
                lab = await page.evaluate(f'Aurora.content.cognitive.microbleedRegions.find(r=>r.key==="{reg}").label')
                await page.fill(f'.sec[data-id="microbleeds"] input[aria-label="{lab} {name}"]', str(m[f]))
    await set_seg(page, "css", "Right hemisphere", st["css"]["right"]); await set_seg(page, "css", "Left hemisphere", st["css"]["left"])
    g = st["gca"]
    for part, P in [("sulci","Sulci"),("ventricles","Ventricles")]:
        for reg, R in [("frontal","Frontal"),("po","Parieto-occipital"),("temporal","Temporal")]:
            for i, side in [(0,"right"),(1,"left")]:
                await page.locator(f'.sec[data-id="gca"] [aria-label="{P} {R} {side}"] button[data-v="{g[part][reg][i]}"]').click()
    await page.locator(f'.sec[data-id="gca"] [aria-label="Third ventricle"] button[data-v="{g["third"]}"]').click()
    for sec in ["mta","erica","koedam"]:
        await set_seg(page, sec, "Right hemisphere", st[sec]["right"]); await set_seg(page, sec, "Left hemisphere", st[sec]["left"])
    for sec, inc in st["include"].items():
        if not inc: await page.locator(f'.sec[data-id="{sec}"] .status button[data-v="na"]').click()

async def main():
    fails = 0
    async with async_playwright() as p:
        b = await p.chromium.launch()
        ctx = await b.new_context(viewport={"width": 1366, "height": 900}, accept_downloads=True)
        page = await ctx.new_page()
        page.on("dialog", lambda d: asyncio.ensure_future(d.accept()))
        errs = []; page.on("pageerror", lambda e: errs.append(str(e)))
        await page.goto(BASE + "#/cognitive/report")
        locmap = await page.evaluate("""(() => { const m = {}; Aurora.content.cognitive.locationGroups.forEach(g => g.rows.forEach(r => r.options.forEach(o => {
            m[o.id] = r.label + " " + (o.title || (o.btn === "R" ? "right" : o.btn === "L" ? "left" : o.btn)).toLowerCase(); }))); return m; })()""")
        for name in PICK:
            c, s = by_name[name]
            await apply(page, c["state"], locmap)
            await page.get_by_role("tab", name="Report").click()
            for lang in ["en", "pt"]:
                await page.locator(f'.report-view .lang button[data-v="{lang}"]').click()
                shown = [norm(t) for t in await page.locator("#report-text p:not(.empty)").all_inner_texts()]
                exp = [norm(t) for t in (s[lang] if isinstance(s[lang], list) else [s[lang]])]
                if shown != exp:
                    fails += 1
                    print(f"MISMATCH {name} {lang}"); 
                    for a, e in zip(shown + [""]*9, exp + [""]*9):
                        if a != e: print("  page :", a); print("  shiny:", e)
            await page.get_by_role("tab", name="Findings").click()
            print("done", name)
        # Excel download for the last case and for defaults
        await page.get_by_role("tab", name="Report").click()
        async with page.expect_download() as dl:
            await page.get_by_role("button", name="Download Excel").click()
        d = await dl.value; await d.save_as("tests/out/html_last.xlsx"); print("excel:", d.suggested_filename)
        await page.evaluate("sessionStorage.clear()"); await page.reload()
        await page.get_by_role("tab", name="Report").click()
        async with page.expect_download() as dl:
            await page.get_by_role("button", name="Download Excel").click()
        d = await dl.value; await d.save_as("tests/out/html_case1.xlsx")
        # Copy button
        await ctx.grant_permissions(["clipboard-read", "clipboard-write"])
        await page.get_by_role("button", name="Copy report").click()
        clip = await page.evaluate("navigator.clipboard.readText()")
        print("clipboard lines:", len(clip.split("\n")), "| first:", clip.split("\n")[0])
        await b.close()
    print("page errors:", errs or "none")
    print("UI cases with differences:", fails, "of", len(PICK))
asyncio.run(main())
