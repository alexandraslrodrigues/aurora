# Aurora

**Clear reports, brighter outcomes.**

Aurora is a free, open-access website for structured neuroradiology reporting in neurodegenerative disorders.
It brings validated visual rating scales, calculators, recommended MRI protocols and reference images together,
with reports in English and Portuguese.

**Use Aurora:** https://aurora-report.com

- **Cognitive disorders:** Aurora Report (structured report of small vessel disease and atrophy findings,
  with copy and Excel export), recommended protocol, and calculators (GCA, MTA, ERICA, Koedam).
- **Movement disorders:** recommended protocol and calculators (midbrain/pons ratio, MRPI, MRPI 2.0,
  midbrain/pons diameter ratio, MCP width), each with the published cutoffs and their sources.

Aurora is a reporting aid. It is not a certified medical device and does not make diagnoses.

## Versions

| Version | What it is | Code |
|---|---|---|
| **2.0** (current, Oct 2026) | Plain HTML, CSS and JavaScript. Runs entirely in the browser, works offline and can be installed. Nothing entered leaves the device | this branch (`main`), folder `site/` |
| Shinylive (Sep–Oct 2026) | The R Shiny app running in the browser (Shinylive/webR) | branch [`aurora2.0`](../../tree/aurora2.0) (folder `web/`) |
| **1.0** (as published) | Server version (R Shiny on shinyapps.io), as described in the article | branch [`aurora1.0`](../../tree/aurora1.0) · release [v1.0](../../releases) |

## Repository

```
site/                        the website (this folder is what is published)
  index.html
  content/                   all texts, cutoffs and references, in plain data files
    cognitive-report.js        report sentences (EN/PT), choices, Excel columns, cut-offs
    info-cards.js              definitions, reference images, references and image credits
    movement-calculator.js     published cutoffs (one line each), DOIs, how to measure
    protocols.js               recommended MRI protocols
    pages.js                   home, Help and About texts
  js/                        code (no framework, no build step)
  css/aurora.css             colours and layout
  img/  fonts/  icons/
  sw.js, manifest.webmanifest  offline use and installation
tests/                       checks used when Aurora moved from R to JavaScript (Sep 2026)
```

**Edit a sentence, a cutoff or a reference:** open the file in `site/content/`, change the text between quotes
(keep the `{placeholders}` and the commas at line ends), save, and reload the page.

**Run locally:** open `site/index.html` in a browser, or serve the folder:
`python3 -m http.server 8080 --directory site` and open http://localhost:8080.

**Publish:** upload the `site` folder to the hosting (Cloudflare Pages). If you add or rename files, add them to
`FILES` in `site/sw.js` and change `VERSION` there.

**Tests:** the scripts in `tests/` compared the JavaScript report, sentence by sentence in English and Portuguese,
with the R Shiny version (838 cases, 0 differences in Sep 2026). The report has changed on purpose since then, so
new differences are expected.

## Privacy

- Everything typed in Aurora stays in the browser tab and is cleared when the tab is closed.
- Google Analytics counts page visits on the published site.
- The message button sends only what the user writes, the page it was sent from, and an email address if they add one.

## Citation

If you use Aurora, please cite:
> Rodrigues ASL, Gama Lobo G, Machado T, Jardim Pereira D. Aurora: Open-Access Web Application for
> Structured Neuroradiology Report and Score Calculation. *AJNR Am J Neuroradiol*. 2026.
> doi:[10.3174/ajnr.A8940](https://doi.org/10.3174/ajnr.A8940)

## License

Aurora © 2025–2026 is licensed under
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-nc-sa/4.0/).

Not covered by this licence:
- **Reference images** keep the copyright and licence of their sources, credited under each image on the site and in
  `site/content/info-cards.js`. Images © American Society of Neuroradiology are used with permission.
- **Inter** font (`site/fonts/`) © The Inter Project Authors, SIL Open Font License 1.1.
