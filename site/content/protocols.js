/* =============================================================================
   PROTOCOLS — recommended clinical MRI protocols (Protocol pages)

   How to edit:
   - Each category (cognitive, movement) has a list of protocols.
     More than one protocol shows a switch at the top of the page.
   - title:    name of the protocol (not shown on the page; used for the switch when there are several)
   - field:    field strength, shown under the table
   - abbreviations: shown at the end, "ABBR, meaning; ABBR, meaning"
   - sections: each has a title, the column names and the rows.
               A row is a list with one text per column.
   - notes:    small lines under the tables
   - refs:     [label, link], shown with ⓘ next to the page title
   - hidden:   true keeps a protocol in this file but off the website
   Keep labels short and without final punctuation.
   ========================================================================== */

var Aurora = globalThis.Aurora = globalThis.Aurora || {};
Aurora.content = Aurora.content || {};

Aurora.content.protocols = {

  updated: "Sep 2026",

  cognitive: [
    {
      id: "diagnosis",
      tab: "Diagnosis",
      title: "Suspected cognitive disorder",
      field: "1.5 T minimum, 3 T preferred",
      sections: [
        {
          title: "Core",
          cols: ["Sequence", "Plane", "Thickness", "Look for"],
          rows: [
            ["3D T1", "Sagittal · coronal reformat perpendicular to the hippocampus", "1 mm isotropic", "MTA · GCA · Koedam · focal atrophy"],
            ["FLAIR", "3D or 2D axial", "1 mm if 3D", "White matter hyperintensities · infarcts"],
            ["T2", "Axial", "2D", "Lacunes vs perivascular spaces · other pathology"],
            ["T2*-GRE or SWI", "Axial", "3–5 mm if 2D", "Microbleeds · superficial siderosis"],
            ["DWI + ADC", "Axial", "3–5 mm", "Acute infarct · Creutzfeldt–Jakob disease"]
          ]
        },
        {
          title: "Optional",
          cols: ["Sequence", "Plane", "Thickness", "Look for"],
          rows: [
            ["ASL", "Axial", "", "Temporoparietal or frontotemporal hypoperfusion (Alzheimer’s disease, frontotemporal dementia)"],
            ["T1 + contrast", "", "", "Only if cerebral amyloid angiopathy-related inflammation · infection · tumor"]
          ]
        }
      ],
      notes: [],
      abbreviations: "2D, two-dimensional; 3D, three-dimensional; ADC, apparent diffusion coefficient; " +
        "ASL, arterial spin labeling; DWI, diffusion-weighted imaging; " +
        "FLAIR, fluid-attenuated inversion recovery; GCA, global cortical atrophy; GRE, gradient echo; MTA, medial temporal atrophy; " +
        "SWI, susceptibility-weighted imaging; T, tesla",
      refs: [
        ["Vernooij 2019 · ESNR", "https://doi.org/10.1007/s00234-019-02188-y"],
        ["Duering 2023 · STRIVE-2", "https://doi.org/10.1016/S1474-4422(23)00131-X"],
        ["Pizzini 2022", "https://doi.org/10.1007/s11547-022-01534-0"]
      ]
    },
    {
      id: "anti-amyloid",
      hidden: true,            // not shown for now; change to false to show it again
      tab: "Anti-amyloid",
      title: "Anti-amyloid therapy",
      field: "1.5 T minimum, 3 T preferred; the same field strength for every scan",
      sections: [
        {
          title: "Baseline",
          cols: ["Sequence", "Plane", "Thickness", "Look for"],
          rows: [
            ["3D T1", "Sagittal", "1 mm isotropic", "Atrophy"],
            ["T2", "Axial", "2D", "Other pathology"],
            ["FLAIR", "2D or 3D", "", "White matter hyperintensities · vasogenic edema"],
            ["T2*-GRE", "Axial", "TE 15–20 ms at 3 T · 25–35 ms at 1.5 T", "Microbleeds · superficial siderosis · hemorrhage"],
            ["DWI + ADC", "Axial", "", "Infarct"],
            ["SWI", "Axial", "Optional", "Microbleeds"]
          ]
        },
        {
          title: "Monitoring",
          cols: ["Sequence", "Plane", "Thickness", "Look for"],
          rows: [
            ["FLAIR", "2D or 3D", "", "ARIA-E"],
            ["T2*-GRE", "Axial", "Same as baseline", "ARIA-H"],
            ["DWI + ADC", "Axial", "", "Infarct vs ARIA"],
            ["SWI", "Axial", "Optional", "ARIA-H"]
          ]
        },
        {
          title: "Schedule",
          cols: ["Drug", "Baseline MRI", "MRI before infusion"],
          rows: [
            ["Lecanemab", "Within 6 months", "3 · 5 · 7 · 14"],
            ["Donanemab", "Within 6 months", "2 · 3 · 4 · 7 · 12 if ApoE4 heterozygous or prior ARIA"],
            ["Any", "", "New symptoms"]
          ]
        }
      ],
      notes: [
        "Schedule from the EU labels",
        "US: baseline within 12 months · donanemab infusion 12 not in the US label"
      ],
      abbreviations: "2D, two-dimensional; 3D, three-dimensional; ApoE4, apolipoprotein E ε4; ARIA, amyloid-related imaging abnormalities " +
        "(-E, edema or effusion; -H, hemosiderin deposition); DWI, diffusion-weighted imaging; FLAIR, fluid-attenuated inversion recovery; " +
        "GRE, gradient echo; SWI, susceptibility-weighted imaging; T, tesla",
      refs: [
        ["Cogswell 2025 · ASNR", "https://doi.org/10.3174/ajnr.A8469"],
        ["Cummings 2023 · lecanemab", "https://doi.org/10.14283/jpad.2023.30"],
        ["Rabinovici 2025 · donanemab", "https://doi.org/10.1016/j.tjpad.2025.100150"],
        ["Leqembi EU label", "https://www.ema.europa.eu/en/documents/product-information/leqembi-epar-product-information_en.pdf"],
        ["Kisunla EU label", "https://www.ema.europa.eu/en/documents/product-information/kisunla-epar-product-information_en.pdf"]
      ]
    }
  ],

  movement: [
    {
      id: "parkinsonism",
      tab: "Parkinsonism",
      title: "Suspected parkinsonism",
      field: "1.5 T minimum, 3 T preferred for the nigra",
      sections: [
        {
          title: "Core",
          cols: ["Sequence", "Plane", "Thickness", "Look for"],
          rows: [
            ["3D T1", "Sagittal 3D · reformats: true midsagittal (areas, diameters), parasagittal (MCP), oblique coronal tangent to the 4th ventricle floor (SCP), axial parallel to AC–PC (third ventricle, frontal horns)", "≤1 mm isotropic", "Planimetry · hummingbird sign"],
            ["T2", "Axial", "2D", "Hot cross bun · putamen · MCP · hyperintense putaminal rim only at 1.5 T (normal at 3 T)"],
            ["FLAIR", "3D or 2D sagittal and axial", "", "Vascular lesions · normal pressure hydrocephalus · MCP sign · at 3 T, a T2 rim that is vague or absent on FLAIR is likely normal"],
            ["DWI + ADC", "Axial", "", "Putamen and MCP diffusivity · infarct · Creutzfeldt–Jakob disease"],
            ["SWI", "Axial", "", "Putaminal hypointensity · microbleeds · mineralization"],
            ["Nigral SWI", "Axial through the midbrain", "High resolution · 1.3–1.5 mm at 3 T · 1.6–1.8 mm at 1.5 T", "Dorsolateral nigral hyperintensity · swallow tail sign"]
          ]
        },
        {
          title: "Optional",
          cols: ["Sequence", "Plane", "Thickness", "Look for"],
          rows: [
            ["Neuromelanin T1 TSE", "Oblique axial perpendicular to the 4th ventricle floor · posterior commissure to inferior pons", "0.5 × 0.5 × 2.5 mm", "Substantia nigra · locus coeruleus"],
            ["DTI", "Axial", "", "MCP · SCP · putamen"]
          ]
        }
      ],
      notes: [],
      abbreviations: "2D, two-dimensional; 3D, three-dimensional; AC–PC, anterior commissure–posterior commissure; ADC, apparent diffusion coefficient; " +
        "DTI, diffusion tensor imaging; DWI, diffusion-weighted imaging; FLAIR, fluid-attenuated inversion recovery; " +
        "MCP, middle cerebellar peduncle; SCP, superior cerebellar peduncle; " +
        "SWI, susceptibility-weighted imaging; T, tesla; TSE, turbo spin echo",
      refs: [
        ["Peralta 2022 · MDS", "https://doi.org/10.1002/mdc3.13354"],
        ["Reimão 2020", "https://doi.org/10.1002/mds.28204"],
        ["Wenning 2022 · MDS MSA", "https://doi.org/10.1002/mds.29005"],
        ["Haller 2025", "https://doi.org/10.1148/radiol.242044"],
        ["Brammerloh 2022", "https://doi.org/10.1148/radiol.212696"],
        ["Lee 2005", "https://pmc.ncbi.nlm.nih.gov/articles/PMC7976126/"]
      ]
    }
  ]
};
