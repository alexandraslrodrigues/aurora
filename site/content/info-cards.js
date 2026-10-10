/* =============================================================================
   ⓘ INFO CARDS — definitions, images, references and image credits
   -----------------------------------------------------------------------------
   Shown when the user clicks ⓘ (report sections and calculators share them).
   - "images": file names in the img/ folder.
   - "body" and "credits": short HTML. Use <p>…</p> for paragraphs,
     <ul><li>…</li></ul> for lists, <a href="…">…</a> for links.
   - Links open in a new tab automatically.
   ========================================================================== */

var Aurora = globalThis.Aurora = globalThis.Aurora || {};
Aurora.content = Aurora.content || {};

Aurora.content.info = {

  rsi: {
    title: "Recent small subcortical infarcts",
    images: ["picture_rsi.webp"],
    body:
      "<p>An acute infarct in the territory of a single perforating artery, as seen in MR DWI, typically associated with a corresponding focal neurological deficit. " +
      "The term small refers to a lesion less than 20 mm in maximum axial diameter (axial plane), though infarcts may appear slightly larger on coronal imaging. " +
      "No lower size limit is specified, as DWI allows distinction of very small infarcts from perivascular spaces.</p>" +
      "<p>Exclusions - do not classify as small subcortical infarcts:</p>" +
      "<ul><li>Striatocapsular infarcts: lesions &gt;20 mm in the basal ganglia/internal capsule caused by several penetrating arteries, typically comma-shaped (caudate head, internal capsule, putamen).</li>" +
      "<li>Anterior choroidal artery infarcts (aetiologically distinct), in the posterior limb of the internal capsule.</li></ul>",
    credits:
      "<p>Figure adapted from: Mahammedi, A. et al. (2022). <a href='https://doi.org/10.3174/ajnr.A7302'>Small Vessel Disease, a Marker of Brain Health: What the Radiologist Needs to Know. American Journal of Neuroradiology, 43, 650–660.</a> " +
      "© 2022 American Society of Neuroradiology. Used with permission.</p>" +
      "<p>Text adapted from: Duering, M. et al. (2023). <a href='https://doi.org/10.1016/s1474-4422(23)00131-x'>Neuroimaging standards for research into small vessel disease—advances since 2013.</a> The Lancet Neurology.</p>"
  },

  lacunes: {
    title: "Lacunes of presumed vascular origin",
    images: ["picture_li.webp"],
    body:
      "<p>Lacunes of presumed vascular origin are round or ovoid, fluid-filled cavities in the subcortical region that mirror cerebrospinal fluid signal. They typically measure 3–15 mm; cavities smaller than 3 mm can also be the end result of a recent small subcortical infarct.</p>" +
      "<p>Differentiation from enlarged perivascular spaces can be challenging, as both can be similar in size and may lack a hyperintense T2 rim. Consider cavity shape, the presence of adjacent perivascular spaces, and signal changes in surrounding tissue to improve specificity.</p>" +
      "<p>Lacunes may arise from small subcortical infarcts, small subcortical haemorrhages, incidental DWI-positive lesions, or represent end-stage cavitation within a white matter hyperintensity.</p>",
    credits:
      "<p>Figure adapted from: Mahammedi, A. et al. (2022). <a href='https://doi.org/10.3174/ajnr.A7302'>Small Vessel Disease, a Marker of Brain Health: What the Radiologist Needs to Know. American Journal of Neuroradiology, 43, 650–660.</a> " +
      "© 2022 American Society of Neuroradiology. Used with permission.</p>" +
      "<p>Text adapted from: Duering, M. et al. (2023). <a href='https://doi.org/10.1016/S1474-4422(23)00131-X'>Neuroimaging standards for research into small vessel disease—advances since 2013.</a> The Lancet Neurology.</p>"
  },

  wmh: {
    title: "White matter hyperintensities (Fazekas scale)",
    images: ["picture_fazekas.webp"],
    body:
      "<p>White matter hyperintensities of presumed vascular origin are signal abnormalities of variable size in the white matter, hyperintense on T2-weighted images such as FLAIR, without cavitation. Lesions in the subcortical grey matter or brainstem are not included unless explicitly stated (they are then called subcortical hyperintensities).</p>" +
      "<p><b>Periventricular:</b> 0 = absent; 1 = “caps” or pencil-thin lining; 2 = smooth “halo”; 3 = irregular periventricular signal extending into the deep white matter.<br>" +
      "<b>Deep white matter:</b> 0 = absent; 1 = punctate foci; 2 = beginning confluence; 3 = large confluent areas.</p>",
    credits:
      "<p>Figure adapted from: Mahammedi, A. et al. (2022). <a href='https://doi.org/10.3174/ajnr.A7302'>Small Vessel Disease, a Marker of Brain Health: What the Radiologist Needs to Know. American Journal of Neuroradiology, 43, 650–660.</a> " +
      "© 2022 American Society of Neuroradiology. Used with permission. Open access to non-subscribers at <a href='https://www.ajnr.org'>www.ajnr.org</a>.</p>" +
      "<p>Scale adapted from: Fazekas, F., Chawluk, J., Alavi, A., Hurtig, H. &amp; Zimmerman, R. (1987). <a href='https://doi.org/10.2214/ajr.149.2.351'>MR signal abnormalities at 1.5 T in Alzheimer’s dementia and normal aging. American Journal of Roentgenology, 149(2), 351–356.</a></p>"
  },

  pvs: {
    title: "The Enlarged Perivascular Spaces Scale",
    images: ["picture_pvs.webp", "picture_pvs_2.webp"],
    body:
      "<p>Severe perivascular spaces (PVS) are demonstrated in the basal ganglia and centrum semiovale (Figure 1), with additional PVS visible in the midbrain (arrowheads). " +
      "In Figure 2, the spectrum of PVS burden is illustrated: panel (a) shows grade 4 (severe) PVS in the centrum semiovale; panel (b) displays grade 2 involvement in the basal ganglia; and panel (c) highlights visible (grade 1) PVS in the midbrain, also indicated by arrowheads.</p>" +
      "<p>Basal ganglia and centrum semiovale (count in the hemisphere with more PVS, on the slice with the highest number): 0 = none; 1 = 1–10; 2 = 11–20; 3 = 21–40; 4 = &gt;40. Midbrain: 0 = none visible; 1 = visible.</p>",
    credits:
      "<p>Adapted from: Potter, G. M., Chappell, F. M., Morris, Z. &amp; Wardlaw, J. M. (2015). <a href='https://doi.org/10.1159/000375153'>Cerebral perivascular spaces visible on magnetic resonance imaging: development of a qualitative rating scale and its observer reliability. Cerebrovascular Diseases, 39(3–4), 224–231.</a> Licensed under <a href='https://creativecommons.org/licenses/by/3.0/'>CC BY 3.0</a>.</p>"
  },

  microbleeds: {
    title: "Microbleed Anatomical Rating Scale (MARS)",
    images: [],
    body:
      "<p>Cerebral microbleeds are small, chronic brain hemorrhages visible as focal, round, hypointense lesions on T2*-GRE or SWI sequences, reflecting hemosiderin deposits due to vascular leakage. The Microbleed Anatomical Rating Scale (MARS) provides a standardized approach for categorizing microbleeds by anatomical location and imaging characteristics.</p>" +
      "<ul><li>Lobar: cortical and subcortical regions, including subcortical U-fibers.</li>" +
      "<li>Deep: basal ganglia, thalamus, internal capsule, external capsule, corpus callosum, and deep/periventricular white matter (within approximately 10 mm of the lateral ventricles).</li>" +
      "<li>Infratentorial: brainstem and cerebellum.</li></ul>" +
      "<p>Imaging classification (GRE T2*-weighted):</p>" +
      "<ul><li>Definite microbleeds: small (2–10 mm), round or circular, well-defined hypointense lesions.</li>" +
      "<li>Possible microbleeds: less well-defined, less hypointense, or not strictly rounded.</li></ul>",
    credits:
      "<p>Adapted from: Gregoire, S. M. et al. (2009). <a href='https://doi.org/10.1212/WNL.0b013e3181c34a7d'>The Microbleed Anatomical Rating Scale (MARS): reliability of a tool to map brain microbleeds. Neurology, 73(21), 1759–1766.</a></p>"
  },

  css: {
    title: "Cortical Superficial Siderosis Multifocality Rating Scale",
    images: ["picture_ss.webp"],
    body:
      "<p>Cortical superficial siderosis (cSS) is identified as a well-defined, homogeneous, curvilinear hypointense signal (black) on T2*-GRE or SWI, following the outer surface of the cerebral cortex within the subarachnoid space. Do not score cSS if it is contiguous or anatomically connected to lobar intracerebral hemorrhage (ICH). To be considered separate, cSS must be ≥3 sulci away, or ≥2 sulci away on multiple axial levels without clear superficial communication.</p>" +
      "<ul><li>cSS score (each hemisphere): 0 = no cSS, 1 = 1 sulcus or ≤3 adjacent sulci and 2 = ≥2 non-adjacent or &gt;3 adjacent sulci.</li>" +
      "<li>cSS total score (right + left): 0 = no cSS, 1 = mild/unifocal and ≥2 = severe/multifocal.</li></ul>",
    credits:
      "<p>Picture adapted from: Andersen, N. H., Blauenfeldt, R. A., Mikkelsen, R. &amp; Simonsen, C. Z. (2023). <a href='https://doi.org/10.1186/s12883-023-03300-9'>Preceding symptoms and temporal development of cortical superficial siderosis in cerebral amyloid angiopathy: a case report. BMC Neurology, 23, 252.</a> Licensed under <a href='http://creativecommons.org/licenses/by/4.0/'>CC BY 4.0</a>.</p>" +
      "<p>Scale cSS adapted from: Charidimou, A. et al. (2017). <a href='https://doi.org/10.1212/WNL.0000000000004665'>Cortical superficial siderosis multifocality in cerebral amyloid angiopathy. Neurology, 89, 2128–2135.</a></p>"
  },

  gca: {
    title: "Global Cortical Atrophy Scale (GCA)",
    images: ["picture_gca.webp"],
    body:
      "<p>GCA scale 0: no atrophy; 1: mild atrophy – enlargement of sulci; 2: moderate atrophy – volume loss of gyri; 3: severe atrophy – “knife-blade” atrophy.</p>",
    credits:
      "<p>Figure adapted from: Furtner, J. &amp; Prayer, D. (2021). <a href='https://doi.org/10.1007/s10354-021-00825-x'>Neuroimaging in dementia. Wien Med Wochenschr, 171, 274–281.</a> Licensed under <a href='http://creativecommons.org/licenses/by/4.0/'>CC BY 4.0</a>.</p>" +
      "<p>GCA scale adapted from: Pasquier, F. et al. (1996). <a href='https://doi.org/10.1159/000117270'>Inter- and Intraobserver Reproducibility of Cerebral Atrophy Assessment on MRI Scans with Hemispheric Infarcts. European Neurology, 36(5), 268–272.</a></p>"
  },

  mta: {
    title: "Medial Temporal Lobe Atrophy Score (MTA)",
    images: ["picture_mta.webp"],
    body:
      "<p>Medial Temporal Lobe Atrophy (MTA) score in coronal T1-weighted MRI. The score is based on qualitative evaluation of the widening of the choroid fissure, enlargement of the temporal horn, and atrophy of the hippocampus.</p>" +
      "<ul><li>0: no CSF is visible around the hippocampus</li>" +
      "<li>1: choroid fissure is slightly widened</li>" +
      "<li>2: moderate widening of the choroid fissure, mild enlargement of the temporal horn and mild loss of hippocampal height</li>" +
      "<li>3: marked widening of the choroid fissure, moderate enlargement of the temporal horn, and moderate loss of hippocampal height</li>" +
      "<li>4: marked widening of the choroid fissure, marked enlargement of the temporal horn, and the hippocampus is markedly atrophied and internal structure is lost</li></ul>" +
      "<p>Published age-adjusted cut-offs (each hemisphere): ≥2 under 75 years; ≥3 from 75 years.</p>",
    credits:
      "<p>Figure adapted from: Håkansson, C. et al. (2022). <a href='https://doi.org/10.1007/s00330-021-08177-1'>Inter-modality assessment of medial temporal lobe atrophy in a non-demented population: application of a visual rating scale template across radiologists with varying clinical experience. Eur Radiol, 32, 1127–1134.</a> Licensed under <a href='http://creativecommons.org/licenses/by/4.0/'>CC BY 4.0</a>.</p>" +
      "<p>MTA scale adapted from: Scheltens, P., Leys, D., Barkhof, F. et al. (1992). <a href='https://doi.org/10.1136/jnnp.55.10.967'>Atrophy of medial temporal lobes on MRI in “probable” Alzheimer’s disease and normal ageing: diagnostic value and neuropsychological correlates. Journal of Neurology, Neurosurgery, and Psychiatry, 55(10), 967–972.</a></p>" +
      "<p>Reliability: Scheltens, P., Launer, L., Barkhof, F. et al. (1995). <a href='https://doi.org/10.1007/BF00868807'>Visual assessment of medial temporal lobe atrophy on magnetic resonance imaging: Interobserver reliability. Journal of Neurology, 242(9), 557–560.</a></p>" +
      "<p>Age-adjusted cut-off: Torisson, G., van Westen, D., Stavenow, L., Minthon, L. &amp; Londos, E. (2015). <a href='https://doi.org/10.1186/s12877-015-0066-4'>Medial temporal lobe atrophy is underreported and may have important clinical correlates in medical inpatients. BMC Geriatrics, 15, 65.</a></p>"
  },

  erica: {
    title: "Entorhinal Cortical Atrophy Score (ERICA)",
    images: ["picture_erica1.webp"],
    body:
      "<p>Orientation: coronal sections aligned to the brainstem with a section thickness of 1 mm.</p>" +
      "<ul><li>0: normal volume of the entorhinal cortex and parahippocampal gyrus.</li>" +
      "<li>1: mild atrophy with widening of the collateral sulcus.</li>" +
      "<li>2: moderate atrophy with detachment of the entorhinal cortex from the cerebellar tentorium (the 'tentorial cleft sign').</li>" +
      "<li>3: pronounced atrophy of the parahippocampal gyrus and a wide cleft between entorhinal cortex and the cerebellar tentorium.</li></ul>" +
      "<p>Published cut-off (each side): ≥2.</p>",
    credits:
      "<p>Figure adapted from: Roberge, X., Brisson, M. &amp; Laforce, R. J. (2023). <a href='https://doi.org/10.1017/cjn.2021.253'>Specificity of Entorhinal Atrophy MRI Scale in Predicting Alzheimer’s Disease Conversion. Canadian Journal of Neurological Sciences, 50, 112–114.</a> Licensed under <a href='http://creativecommons.org/licenses/by/4.0/'>CC BY 4.0</a>.</p>" +
      "<p>Scale adapted from: Enkirch, S. J. et al. (2018). <a href='https://doi.org/10.1148/radiol.2018171888'>The ERICA Score: An MR Imaging–based Visual Scoring System for the Assessment of Entorhinal Cortex Atrophy in Alzheimer Disease. Radiology, 288(1), 226–233.</a></p>"
  },

  koedam: {
    title: "Posterior parietal atrophy (Koedam score)",
    images: ["picture_pca.webp"],
    body:
      "<p>On sagittal images, assess the posterior cingulate sulcus and parieto-occipital sulcus, and check for atrophy of the precuneus. On axial and coronal images, evaluate the widening of the posterior cingulate sulcus and look for sulcal dilatation in the parietal lobes. Atrophy should be rated on a scale from 0 to 3: 0 = no atrophy, 1 = mild, 2 = moderate, and 3 = severe.</p>",
    credits:
      "<p>Adapted from: Koedam, E. L. G. E. et al. (2011). <a href='https://doi.org/10.1007/s00330-011-2205-4'>Visual assessment of posterior atrophy: development of a MRI rating scale. European Radiology, 21, 2618–2625.</a> Licensed under <a href='https://creativecommons.org/licenses/by-nc/2.0/'>CC BY-NC</a>.</p>"
  },

  svd: {
    title: "Total small vessel disease (SVD) score",
    images: ["picture_ssvds.webp"],
    body:
      "<p>The total MRI burden of small vessel disease is graded from 0 to 4. Assign one point for each of the following:</p>" +
      "<ul><li>Lacunes: presence of ≥1</li>" +
      "<li>Cerebral microbleeds: ≥1, any location (definite microbleeds; possible ones are described but do not count)</li>" +
      "<li>Perivascular spaces: moderate to severe (grade 2–4) in the basal ganglia</li>" +
      "<li>White matter hyperintensities (WMH): deep WMH (Fazekas 2–3) or irregular periventricular WMH extending into deep white matter (Fazekas 3)</li></ul>",
    credits:
      "<p>Adapted from: Staals, J., Makin, S. D. J., Doubal, F. N., Dennis, M. S. &amp; Wardlaw, J. M. (2014). <a href='https://doi.org/10.1212/WNL.0000000000000837'>Stroke subtype, vascular risk factors, and total MRI brain small-vessel disease burden. Neurology, 83(14), 1228–1234.</a> Open access article distributed under the Creative Commons Attribution License (CC BY).</p>"
  }
};
