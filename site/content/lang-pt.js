/* =============================================================================
   PORTUGUÊS (Portugal) — the interface in Portuguese
   -----------------------------------------------------------------------------
   Everything on screen in Portuguese: buttons, names, messages, the Help and
   About pages, the ⓘ definitions and the how-to-measure steps.
   The report sentences are not here: they are in content/cognitive-report.js
   (text.pt for the Aurora Report, calculatorText.pt for the calculators).

   How to edit (no JavaScript knowledge needed):
   - Part 1: "English": "Português". Change only the Portuguese text, on the
     right. The English text on the left must stay exactly as it is in the
     app (it is how Aurora finds the translation).
   - Part 2: the longer texts, with the same names as in the English content
     files (pages.js, info-cards.js, movement-calculator.js, protocols.js).
   - Keep the {placeholders}, the quotes and the commas at line ends.
   - A text with no translation here is shown in English.
   - To see what is missing or no longer used:  node tools/check-translations.js pt

   A new language: copy this file as lang-xx.js (xx = language code), change
   the name, code and texts, and add it to index.html and sw.js.
   ========================================================================== */

var Aurora = globalThis.Aurora = globalThis.Aurora || {};
Aurora.content = Aurora.content || {};
Aurora.content.languages = Aurora.content.languages || {};

Aurora.content.languages.pt = {

  name: "Português",                     // in the language menu
  code: "PT",                            // on the language button
  reportName: "Português (Portugal)",    // on the PT button of the report
  htmlLang: "pt-PT",
  decimal: ",",                          // 13,55 instead of 13.55

  /* ---------------------------------------------------------------------------
     1. SHORT TEXTS   "English": "Português"
     --------------------------------------------------------------------------- */
  labels: {
    /* Top bar and page title (index.html) */
    "Skip to content": "Saltar para o conteúdo",
    "Aurora home": "Página inicial da Aurora",
    "Main": "Principal",
    "Aurora · Structured neuroradiology reports and calculators": "Aurora · Relatórios estruturados de neurorradiologia e calculadoras",

    /* Pages, protocol page, message button, night mode (js/app.js) */
    "Protocol": "Protocolo",
    "Calculators": "Calculadoras",
    "Formula: {formula}": "Fórmula: {formula}",
    "More": "Mais",
    "Help": "Ajuda",
    "About": "Sobre",
    "Field strength": "Intensidade do campo",
    "Abbreviations: {list}.": "Abreviaturas: {list}.",
    "Updated {date}": "Atualizado em {date}",
    "References": "Referências",
    "Close": "Fechar",
    "Recommended protocol": "Protocolo recomendado",
    "Citation copied": "Citação copiada",
    "Copy failed": "Não foi possível copiar",
    "Page not found": "Página não encontrada",
    "Go to the home page": "Ir para a página inicial",
    "Write your message": "Escrever a mensagem",
    "Share your feedback or report an issue": "Partilhar uma sugestão ou comunicar um problema",
    "Feedback": "Sugestões",
    "Collaboration": "Colaboração",
    "Type of message": "Tipo de mensagem",
    "Email": "Email",
    "Email (optional)": "Email (opcional)",
    "Message": "Mensagem",
    "Send": "Enviar",
    "Write the email": "Escrever email",
    "Please do not include patient information.": "Não incluir dados de doentes.",
    "Write a message first.": "Falta escrever a mensagem.",
    "Add your email so we can reply.": "Indicar um email para resposta.",
    "Check the email address.": "Verificar o email.",
    "Check the email address, or leave it empty.": "Verificar o email ou deixar o campo vazio.",
    "Sending…": "A enviar…",
    "Thank you, your message was sent": "Mensagem enviada. Obrigado.",
    "Not sent. Check your connection, or write to {email}.": "Não foi possível enviar. Verificar a ligação à internet ou escrever para {email}.",
    "Send us a message": "Enviar mensagem",
    "Send a message: feedback or collaboration": "Enviar mensagem: sugestões ou colaboração",
    "Day mode": "Modo diurno",
    "Night mode": "Modo noturno",
    "Language": "Idioma",
    "Language: {name}": "Idioma: {name}",

    /* Aurora Report: steps, buttons and messages (js/report-page.js) */
    "R": "D",
    "L": "E",
    "C": "C",
    "M": "M",
    "right": "direita",
    "left": "esquerda",
    "central": "central",
    "midline": "linha média",
    "Remove {item}": "Remover {item}",
    "Predominant distribution": "Distribuição predominante",
    "Laterality": "Lateralidade",
    "Periventricular white matter": "Substância branca periventricular",
    "Deep white matter": "Substância branca profunda",
    "Centrum semiovale": "Centro semioval",
    "Basal ganglia": "Gânglios da base",
    "Midbrain": "Mesencéfalo",
    "One less: {label}": "Menos um: {label}",
    "One more: {label}": "Mais um: {label}",
    "Definite": "Definitivas",
    "Possible": "Possíveis",
    "definite right": "definitivas à direita",
    "definite left": "definitivas à esquerda",
    "possible right": "possíveis à direita",
    "possible left": "possíveis à esquerda",
    "Lacunes (≥1)": "Lacunas (≥1)",
    "Cerebral microbleeds (≥1 definite)": "Micro-hemorragias cerebrais (≥1 definitiva)",
    "Perivascular spaces, basal ganglia (moderate or more)": "Espaços perivasculares nos gânglios da base (moderados ou mais)",
    "White matter hyperintensities (deep Fazekas 2–3 or periventricular 3)": "Hipersinal da substância branca (Fazekas profundo 2–3 ou periventricular 3)",
    "Not assessed": "Não avaliado",
    "{n} point": "{n} ponto",
    "{n} points": "{n} pontos",
    "Total (incomplete)": "Total (incompleto)",
    "Total": "Total",
    "Age and sex": "Idade e sexo",
    "Previous": "Anterior",
    "Report": "Relatório",
    "Next": "Seguinte",
    "Next: {step}": "Seguinte: {step}",
    "Include in report": "Incluir no relatório",
    "Exclude from report": "Excluir do relatório",
    "Steps": "Passos",
    "Normal": "Normal",
    "Abnormal": "Alterado",
    "Go to": "Ir para",
    "Not included in the report.": "Secção não incluída no relatório.",
    "Include": "Incluir",
    "Clear findings": "Repor secção",
    "About the age": "Sobre a idade",
    "Used for the age-adjusted MTA cutoff.": "Usada no valor de referência da MTA ajustado à idade.",
    "Age of the patient, in years": "Idade do doente, em anos",
    "Sex": "Sexo",
    "Age": "Idade",
    "years": "anos",
    "Copy report": "Copiar relatório",
    "Download Excel": "Exportar Excel",
    "All sections are marked “Not assessed”.": "Todas as secções estão marcadas como “Não avaliado”.",
    "Go to section": "Ir para a secção",
    "{text} (go to section)": "{text} (ir para a secção)",
    "Nothing to copy: every section is marked “Not assessed”": "Sem texto para copiar: todas as secções estão marcadas como “Não avaliado”",
    "Report copied": "Relatório copiado",
    "Copy failed: select the text and copy it": "Não foi possível copiar. Selecionar e copiar o texto.",
    "Excel file saved": "Ficheiro Excel guardado",
    "Export failed": "Não foi possível exportar",
    "Start a new report? All values will be cleared.": "Começar um novo relatório? Todos os dados serão apagados.",
    "New report": "Novo relatório",
    "Image and definition": "Imagem e definição",

    /* Aurora Report: section names, buttons and grade descriptions (content/cognitive-report.js)
     The report sentences themselves are in content/cognitive-report.js (text.pt). */
    "Recent small subcortical infarcts": "Pequenos enfartes subcorticais recentes",
    "Recent small infarcts": "Pequenos enfartes recentes",
    "Lacunes of presumed vascular origin": "Lacunas de presumível origem vascular",
    "Lacunes": "Lacunas",
    "White matter hyperintensities (Fazekas)": "Hipersinal da substância branca (Fazekas)",
    "White matter (Fazekas)": "Substância branca (Fazekas)",
    "Perivascular spaces": "Espaços perivasculares",
    "Microbleeds": "Micro-hemorragias",
    "Cortical superficial siderosis": "Siderose superficial cortical",
    "Superficial siderosis": "Siderose superficial",
    "Global cortical atrophy (GCA)": "Atrofia cortical global (GCA)",
    "Medial temporal atrophy (MTA)": "Atrofia temporal mesial (MTA)",
    "Entorhinal cortical atrophy (ERICA)": "Atrofia cortical entorrinal (ERICA)",
    "Posterior parietal atrophy (Koedam)": "Atrofia parietal posterior (Koedam)",
    "Total small vessel disease score": "Score total de doença de pequenos vasos",
    "Total SVD score": "Score total de SVD",
    "Female": "Feminino",
    "Male": "Masculino",
    "absent": "ausente",
    "“caps” or pencil-thin lining": "“capuchos” ou linha fina",
    "smooth “halo”": "“halo” regular",
    "irregular periventricular signal extending into the deep white matter": "sinal periventricular irregular que se estende à substância branca profunda",
    "Diffuse": "Difusa",
    "Occipital": "Occipital",
    "Peri-atrial": "Peri-atrial",
    "punctate foci": "focos punctiformes",
    "beginning confluence": "início de confluência",
    "large confluent areas": "grandes áreas confluentes",
    "Corona radiata": "Corona radiata",
    "Bilateral": "Bilateral",
    "None": "Ausentes",
    "Mild": "Ligeiros",
    "Moderate": "Moderados",
    "Frequent": "Frequentes",
    "Severe": "Marcados",
    "Visible": "Visíveis",
    "none": "ausente",
    "1 sulcus or up to 3 immediately adjacent sulci with cSS": "1 sulco ou até 3 sulcos imediatamente adjacentes com cSS",
    "2 or more nonadjacent sulci or more than 3 adjacent sulci with cSS": "2 ou mais sulcos não adjacentes ou mais de 3 sulcos adjacentes com cSS",
    "no cerebrospinal fluid visible around the hippocampus": "sem líquido cefalorraquidiano visível em torno do hipocampo",
    "choroid fissure is slightly widened": "discreto alargamento da fissura coroideia",
    "moderate widening of the choroid fissure, mild enlargement of the temporal horn and mild loss of hippocampal height": "moderado alargamento da fissura coroideia, discreto aumento do corno temporal e discreta perda de altura do hipocampo",
    "marked widening of the choroid fissure, moderate enlargement of the temporal horn, and moderate loss of hippocampal height": "marcado alargamento da fissura coroideia, moderado aumento do corno temporal e moderada perda de altura do hipocampo",
    "marked widening of the choroid fissure, marked enlargement of the temporal horn, and the hippocampus is markedly atrophied and internal structure is lost": "marcado alargamento da fissura coroideia, marcado aumento do corno temporal e marcada atrofia do hipocampo, com perda da estrutura interna",
    "normal volume of the entorhinal cortex and parahippocampal gyrus": "volume normal do córtex entorrinal e do giro para-hipocampal",
    "mild atrophy of the entorhinal cortex and parahippocampal gyrus; widening of the collateral sulcus": "discreta atrofia do córtex entorrinal e do giro para-hipocampal; alargamento do sulco colateral",
    "moderate atrophy of the entorhinal cortex and parahippocampal gyrus; elevation of the entorhinal cortex away from the adjacent cerebellar tentorium": "moderada atrofia do córtex entorrinal e do giro para-hipocampal; afastamento do córtex entorrinal em relação à tenda do cerebelo adjacente",
    "marked atrophy of the entorhinal cortex and parahippocampal gyrus; wide cleft between the entorhinal cortex and the adjacent cerebellar tentorium": "marcada atrofia do córtex entorrinal e do giro para-hipocampal; fenda larga entre o córtex entorrinal e a tenda do cerebelo adjacente",
    "closed sulci; no gyral atrophy": "sulcos fechados; sem atrofia dos giros",
    "mild sulcal widening; mild gyral atrophy": "discreto alargamento dos sulcos; discreta atrofia dos giros",
    "substantial sulcal widening; substantial gyral atrophy": "alargamento substancial dos sulcos; atrofia substancial dos giros",
    "marked sulcal widening; knife-blade gyral atrophy": "marcado alargamento dos sulcos; atrofia dos giros em “lâmina de faca”",
    "Supratentorial": "Supratentorial",
    "Centrum semiovale – frontal": "Centro semioval – frontal",
    "Centrum semiovale – parietal": "Centro semioval – parietal",
    "Corona radiata – frontal": "Corona radiata – frontal",
    "Corona radiata – parietal": "Corona radiata – parietal",
    "Caudate nucleus": "Núcleo caudado",
    "External capsule": "Cápsula externa",
    "Internal capsule – anterior limb": "Cápsula interna – braço anterior",
    "Internal capsule – genu": "Cápsula interna – joelho",
    "Internal capsule – posterior limb": "Cápsula interna – braço posterior",
    "Lentiform nucleus": "Núcleo lentiforme",
    "Thalamus – anterior": "Tálamo – anterior",
    "Thalamus – lateral": "Tálamo – lateral",
    "Thalamus – medial": "Tálamo – medial",
    "Thalamus – posterior": "Tálamo – posterior",
    "Brainstem": "Tronco encefálico",
    "Midbrain – cerebral peduncle": "Mesencéfalo – pedúnculo cerebral",
    "Midbrain – tegmentum": "Mesencéfalo – tegmento",
    "Central": "Central",
    "Midbrain – tectum": "Mesencéfalo – teto",
    "Midline": "Linha média",
    "Pons – basis": "Ponte – base",
    "Pons – tegmentum": "Ponte – tegmento",
    "Medulla – anterior": "Bulbo – anterior",
    "Medulla – posterior": "Bulbo – posterior",
    "Cerebellum": "Cerebelo",
    "Thalamus": "Tálamo",
    "Internal capsule": "Cápsula interna",
    "Corpus callosum": "Corpo caloso",
    "Deep/periventricular WM": "Substância branca profunda e periventricular",
    "Parietal": "Parietal",
    "Insula": "Ínsula",
    "Infratentorial": "Infratentoriais",
    "Deep": "Profundas",
    "Lobar": "Lobares",

    /* Atrophy calculators: GCA, MTA, ERICA, Koedam (js/calculators.js) */
    "Global Cortical Atrophy (GCA)": "Atrofia cortical global (GCA)",
    "Global cortical atrophy": "Atrofia cortical global",
    "Sulci and ventricles, 0–3 per region": "Sulcos e ventrículos, 0–3 por região",
    "Medial Temporal Atrophy (MTA)": "Atrofia temporal mesial (MTA)",
    "Medial temporal atrophy": "Atrofia temporal mesial",
    "Scheltens score, 0–4 per side": "Escala de Scheltens, 0–4 por lado",
    "Entorhinal Cortical Atrophy (ERICA)": "Atrofia cortical entorrinal (ERICA)",
    "Entorhinal atrophy": "Atrofia entorrinal",
    "Enkirch score, 0–3 per side": "Escala de Enkirch, 0–3 por lado",
    "Posterior Parietal Atrophy (Koedam)": "Atrofia parietal posterior (Koedam)",
    "Posterior parietal atrophy": "Atrofia parietal posterior",
    "Koedam score, 0–3 per side": "Escala de Koedam, 0–3 por lado",
    "Info": "Informação",
    "Definition, reference images and source": "Definição, imagens de referência e fonte",
    "Info: {title}": "Informação: {title}",
    "Clear values": "Apagar valores",
    "Result copied": "Resultado copiado",
    "Copy result": "Copiar resultado",
    "Sulci": "Sulcos",
    "Ventricles": "Ventrículos",
    "Frontal": "Frontal",
    "Parieto-occipital": "Parieto-occipital",
    "Temporal": "Temporal",
    "Right": "Direita",
    "{part} {region} right": "{part}, {region}, direita",
    "Left": "Esquerda",
    "{part} {region} left": "{part}, {region}, esquerda",
    "Third ventricle": "Terceiro ventrículo",
    "Right hemisphere": "Hemisfério direito",
    "Left hemisphere": "Hemisfério esquerdo",

    /* Movement calculators: results and warnings (js/movement.js) */
    "How to measure": "Como medir",
    "Method:": "Método:",
    "Meets the published cutoff": "Cumpre o valor de referência publicado",
    "Does not meet the published cutoff": "Não cumpre o valor de referência publicado",
    "{verdict} ({cut} for {cmp}; {source}).": "{verdict} ({cut} para {cmp}; {source}).",
    "Does not meet the {cut} cutoff for {cmp} ({source}).": "Não cumpre o valor de referência {cut} para {cmp} ({source}).",
    "Meets the {cut} cutoff for {cmp} ({source}).": "Cumpre o valor de referência {cut} para {cmp} ({source}).",
    "and": "e",
    "Does not meet the proposed value {list}, which was not tested in a cohort.": "Não cumpre o valor proposto {list}, não testado numa coorte.",
    "Does not meet the proposed values {list}, which were not tested in a cohort.": "Não cumpre os valores propostos {list}, não testados numa coorte.",
    "Meets the proposed value {list}, which was not tested in a cohort.": "Cumpre o valor proposto {list}, não testado numa coorte.",
    "Meets the proposed values {list}, which were not tested in a cohort.": "Cumpre os valores propostos {list}, não testados numa coorte.",
    "Proposed from the literature, not tested in a cohort": "Proposto na literatura, não testado numa coorte",
    "Met": "Cumpre",
    "Not met": "Não cumpre",
    "All cutoffs and sources": "Todos os valores de referência e fontes",
    "Cutoff": "Valor de referência",
    "Reported for": "Descrito para",
    "Source": "Fonte",
    "This value": "Este valor",
    "{name}: enter a number above 0": "{name}: introduzir um valor superior a 0",
    "{name} {value} (usual {range})": "{name} {value} (intervalo habitual: {range})",
    "Check the measurements: {list}.": "Verificar as medições: {list}.",
    "(mean of {n})": "(média de {n})",
    "Mean {value}": "Média: {value}",
    "({n} of {total}; the method uses {total})": "({n} de {total}; o método usa {total})",
    "{name}, {part}": "{name}, {part}",

    /* Movement calculators: names, measurements, notes of each cutoff (content/movement-calculator.js) */
    "vs PD": "vs PD",
    "1.5 T; sensitivity and specificity 100%": "1,5 T; sensibilidade e especificidade 100%",
    "vs MSA-P": "vs MSA-P",
    "vs PD and MSA": "vs PD e MSA",
    "1.5 T; sensitivity 82.9%, specificity 86.2%": "1,5 T; sensibilidade 82,9%, especificidade 86,2%",
    "3 T; sensitivity 100%, specificity 94.3%": "3 T; sensibilidade 100%, especificidade 94,3%",
    "3 T; sensitivity and specificity 100%": "3 T; sensibilidade e especificidade 100%",
    "1.5 T; sensitivity 81.4%, specificity 87.1%": "1,5 T; sensibilidade 81,4%, especificidade 87,1%",
    "vs MSA": "vs MSA",
    "Autopsy cohort, 1.5 T: sensitivity 83%, specificity 100%; clinical cohort, 3 T: 90.5% and 100%": "Coorte de autópsia, 1,5 T: sensibilidade 83%, especificidade 100%; coorte clínica, 3 T: 90,5% e 100%",
    "1.5 T; sensitivity 90.0%, specificity 90.2%": "1,5 T; sensibilidade 90,0%, especificidade 90,2%",
    "Autopsy cohort, 1.5 T: sensitivity 67%, specificity 100%; clinical cohort, 3 T: 85.7% and 100%": "Coorte de autópsia, 1,5 T: sensibilidade 67%, especificidade 100%; coorte clínica, 3 T: 85,7% e 100%",
    "1.5 T; sensitivity 88.6%, specificity 89.0%": "1,5 T; sensibilidade 88,6%, especificidade 89,0%",
    "1.5 T; 16 MSA vs 26 PD; sensitivity and specificity 100%": "1,5 T; 16 MSA vs 26 PD; sensibilidade e especificidade 100%",
    "vs PD and PSP": "vs PD e PSP",
    "1.5 T; sensitivity 69.3%, specificity 88.8%": "1,5 T; sensibilidade 69,3%, especificidade 88,8%",
    "(pons area / midbrain area) × (MCP width / SCP width)": "(área da ponte / área do mesencéfalo) × (largura do MCP / largura do SCP)",
    "MRPI × (third ventricle width / frontal horns width)": "MRPI × (largura do terceiro ventrículo / largura dos cornos frontais)",
    "Midbrain/pons area ratio": "Rácio das áreas mesencéfalo/ponte",
    "midbrain area / pons area": "área do mesencéfalo / área da ponte",
    "Midbrain anteroposterior diameter": "Diâmetro anteroposterior do mesencéfalo",
    "midsagittal": "sagital na linha média",
    "Midbrain/pons diameter ratio": "Rácio dos diâmetros mesencéfalo/ponte",
    "midbrain diameter / pontine base diameter": "diâmetro do mesencéfalo / diâmetro da base da ponte",
    "Middle cerebellar peduncle width": "Largura do pedúnculo cerebeloso médio",
    "mean of the right and left peduncles": "média dos pedúnculos direito e esquerdo",
    "Midbrain surface area (mm²)": "Área do mesencéfalo (mm²)",
    "Midbrain area": "Área do mesencéfalo",
    "Pons surface area (mm²)": "Área da ponte (mm²)",
    "Pons area": "Área da ponte",
    "Width of superior cerebellar peduncles (mm), right and left": "Largura dos pedúnculos cerebelosos superiores (mm), à direita e à esquerda",
    "Superior cerebellar peduncle width": "Largura do pedúnculo cerebeloso superior",
    "Width of middle cerebellar peduncles (mm), right and left": "Largura dos pedúnculos cerebelosos médios (mm), à direita e à esquerda",
    "Width of the third ventricle V3 (mm), 3 measurements": "Largura do terceiro ventrículo V3 (mm), 3 medições",
    "Third ventricle width (mean)": "Largura do terceiro ventrículo (média)",
    "Third ventricle width": "Largura do terceiro ventrículo",
    "Anterior": "Anterior",
    "Middle": "Média",
    "Posterior": "Posterior",
    "Frontal horns width, maximal left-to-right (mm)": "Largura dos cornos frontais, máxima da esquerda para a direita (mm)",
    "Frontal horns width": "Largura dos cornos frontais",
    "Midbrain AP diameter, collicular plate excluded (mm)": "Diâmetro AP do mesencéfalo, sem a placa quadrigémea (mm)",
    "Midbrain AP diameter": "Diâmetro AP do mesencéfalo",
    "Pontine base AP diameter, tegmentum excluded (mm)": "Diâmetro AP da base da ponte, sem o tegmento (mm)",
    "Pontine base AP diameter": "Diâmetro AP da base da ponte",
    "Midbrain/pons ratio": "Rácio mesencéfalo/ponte",
    "Midbrain/Pons Ratio": "Rácio mesencéfalo/ponte",
    "MRPI (Magnetic Resonance Parkinsonism Index)": "MRPI (índice de parkinsonismo por ressonância magnética)",
    "Midbrain/Pons Diameter Ratio": "Rácio dos diâmetros mesencéfalo/ponte",
    "MCP width": "Largura do MCP",
    "Middle Cerebellar Peduncle Width": "Largura do pedúnculo cerebeloso médio",
    "Midbrain and pons areas": "Áreas do mesencéfalo e da ponte",
    "Superior cerebellar peduncle (SCP) width": "Largura do pedúnculo cerebeloso superior (SCP)",
    "Middle cerebellar peduncle (MCP) width": "Largura do pedúnculo cerebeloso médio (MCP)",
    "Midbrain and pons anteroposterior diameters": "Diâmetros anteroposteriores do mesencéfalo e da ponte",

    /* Protocols (content/protocols.js) */
    "Diagnosis": "Diagnóstico",
    "Suspected cognitive disorder": "Suspeita de alterações cognitivas",
    "1.5 T minimum, 3 T preferred": "1,5 T mínimo, 3 T preferencial",
    "Core": "Base",
    "Sequence": "Sequência",
    "Plane": "Plano",
    "Thickness": "Espessura",
    "Look for": "Avaliar",
    "Sagittal · coronal reformat perpendicular to the hippocampus": "Sagital · reconstrução coronal perpendicular ao hipocampo",
    "1 mm isotropic": "1 mm isotrópico",
    "MTA · GCA · Koedam · focal atrophy": "MTA · GCA · Koedam · atrofia focal",
    "3D or 2D axial": "3D ou 2D axial",
    "1 mm if 3D": "1 mm se 3D",
    "White matter hyperintensities · infarcts": "Hipersinal da substância branca · enfartes",
    "Axial": "Axial",
    "Lacunes vs perivascular spaces · other pathology": "Lacunas vs espaços perivasculares · outra patologia",
    "T2*-GRE or SWI": "T2*-GRE ou SWI",
    "3–5 mm if 2D": "3–5 mm se 2D",
    "Microbleeds · superficial siderosis": "Micro-hemorragias · siderose superficial",
    "3–5 mm": "3–5 mm",
    "Acute infarct · Creutzfeldt–Jakob disease": "Enfarte agudo · doença de Creutzfeldt–Jakob",
    "Optional": "Opcional",
    "Temporoparietal or frontotemporal hypoperfusion (Alzheimer’s disease, frontotemporal dementia)": "Hipoperfusão temporoparietal ou frontotemporal (doença de Alzheimer, demência frontotemporal)",
    "T1 + contrast": "T1 + contraste",
    "Only if cerebral amyloid angiopathy-related inflammation · infection · tumor": "Só se inflamação associada a angiopatia amiloide cerebral · infeção · tumor",
    "Parkinsonism": "Parkinsonismo",
    "Suspected parkinsonism": "Suspeita de parkinsonismo",
    "1.5 T minimum, 3 T preferred for the nigra": "1,5 T mínimo, 3 T preferencial para a substância negra",
    "Sagittal 3D · reformats: true midsagittal (areas, diameters), parasagittal (MCP), oblique coronal tangent to the 4th ventricle floor (SCP), axial parallel to AC–PC (third ventricle, frontal horns)": "Sagital 3D · reconstruções: sagital na linha média (áreas, diâmetros), parassagital (MCP), coronal oblíquo tangente ao pavimento do 4.º ventrículo (SCP), axial paralelo a AC–PC (terceiro ventrículo, cornos frontais)",
    "≤1 mm isotropic": "≤1 mm isotrópico",
    "Planimetry · hummingbird sign": "Planimetria · sinal do colibri",
    "Hot cross bun · putamen · MCP · hyperintense putaminal rim only at 1.5 T (normal at 3 T)": "Sinal da cruz (hot cross bun) · putamen · MCP · faixa de hipersinal na margem externa do putamen, só a 1,5 T (normal a 3 T)",
    "3D or 2D sagittal and axial": "3D ou 2D sagital e axial",
    "Vascular lesions · normal pressure hydrocephalus · MCP sign · at 3 T, a T2 rim that is vague or absent on FLAIR is likely normal": "Lesões vasculares · hidrocefalia de pressão normal · sinal do MCP · a 3 T, uma faixa de hipersinal em T2 ténue ou ausente em FLAIR é provavelmente normal",
    "Putamen and MCP diffusivity · infarct · Creutzfeldt–Jakob disease": "Difusividade do putamen e do MCP · enfarte · doença de Creutzfeldt–Jakob",
    "Putaminal hypointensity · microbleeds · mineralization": "Hipointensidade putaminal · micro-hemorragias · mineralização",
    "Nigral SWI": "SWI da substância negra",
    "Axial through the midbrain": "Axial ao nível do mesencéfalo",
    "High resolution · 1.3–1.5 mm at 3 T · 1.6–1.8 mm at 1.5 T": "Alta resolução · 1,3–1,5 mm a 3 T · 1,6–1,8 mm a 1,5 T",
    "Dorsolateral nigral hyperintensity · swallow tail sign": "Hiperintensidade nigral dorsolateral · sinal da cauda de andorinha",
    "Neuromelanin T1 TSE": "Neuromelanina T1 TSE",
    "Oblique axial perpendicular to the 4th ventricle floor · posterior commissure to inferior pons": "Axial oblíquo perpendicular ao pavimento do 4.º ventrículo · da comissura posterior à porção inferior da ponte",
    "0.5 × 0.5 × 2.5 mm": "0,5 × 0,5 × 2,5 mm",
    "Substantia nigra · locus coeruleus": "Substância negra · locus coeruleus",
    "MCP · SCP · putamen": "MCP · SCP · putamen",

    /* Home, About and Help: names and headings (content/pages.js) */
    "Cognitive disorders": "Alterações cognitivas",
    "Small vessel disease and atrophy": "Doença de pequenos vasos e atrofia",
    "Aurora Report · GCA · MTA · ERICA · Koedam": "Aurora Report · GCA · MTA · ERICA · Koedam",
    "Movement disorders": "Doenças do movimento",
    "MRPI · MRPI 2.0 · Midbrain/pons ratios · MCP width": "MRPI · MRPI 2.0 · Rácios mesencéfalo/ponte · Largura do MCP",
    "Project lead": "Coordenação do projeto",
    "Department of Physics and CIBIT": "Departamento de Física e CIBIT",
    "University of Coimbra": "Universidade de Coimbra",
    "Hospital Lusíadas, Lisbon": "Hospital Lusíadas, Lisboa",
    "NOVA Medical School, Lisbon": "NOVA Medical School, Lisboa",
    "Scientific advisors": "Consultoria científica",
    "ULS Coimbra": "ULS Coimbra",
    "Faculty of Medicine and CIBIT": "Faculdade de Medicina e CIBIT",
    "Web development advisor": "Consultoria em desenvolvimento web",
    "Faculty of Medicine": "Faculdade de Medicina",
    "University of Lisbon": "Universidade de Lisboa",
    "ORCID iD of {name}": "ORCID iD de {name}",
    "Principles": "Princípios",
    "Who we are": "Quem somos",
    "How to cite": "Como citar",
    "Software: Aurora {version}": "Software: Aurora {version}",
    "Copy citation": "Copiar citação",
    "Get involved": "Colaborar",
    "Propose a collaboration": "Propor colaboração",
    "or": "ou",
    "How Aurora works": "Como funciona a Aurora",
    "On the home page, select Cognitive disorders or Movement disorders. Each area includes three tools:": "Na página inicial, selecione Alterações Cognitivas ou Doenças do Movimento. Cada área inclui três ferramentas:",
    "Writing a report": "Criar um relatório",
    "Frequently asked questions": "Perguntas frequentes"
  },

  /* ---------------------------------------------------------------------------
     2. LONGER TEXTS (same names as in the English content files)
     --------------------------------------------------------------------------- */

  // content/pages.js
  pages: {
    categories: {
      cognitive: {
        tiles: {
          report: "Relatório estruturado",
          protocol: "Protocolos de RM",
          calculators: "GCA · MTA · ERICA · Koedam"
        }
      },
      movement: {
        tiles: {
          report: "Em desenvolvimento",
          protocol: "Protocolos de RM",
          calculators: "MRPI · MRPI 2.0 · rácios · largura do MCP"
        }
      }
    },
    disclaimer: "A Aurora reúne escalas e valores de referência publicados para apoiar o relatório estruturado. " +
      "Não é um dispositivo médico certificado e não faz diagnósticos.",
    protocol: {
      cognitive: "<p class='muted'>Em breve.</p>",
      movement: "<p class='muted'>Em breve.</p>"
    },
    movementReport: "<p class='muted'>Em desenvolvimento.</p>",
    helpTools: [
      [
        "Aurora Report",
        "Relatório estruturado de doença de pequenos vasos e atrofia cerebral. O relatório das doenças do movimento está em desenvolvimento."
      ],
      [
        "Protocolo",
        "Protocolos de ressonância magnética recomendados para a suspeita de alterações cognitivas e de parkinsonismo, baseados em recomendações publicadas."
      ],
      [
        "Calculadoras",
        "Escalas visuais de atrofia (GCA, MTA, ERICA, Koedam) e medições do mesencéfalo e da ponte no parkinsonismo (MRPI, MRPI 2.0, rácios, largura do pedúnculo cerebeloso médio)."
      ]
    ],
    helpSteps: [
      "Começar por <strong>Idade e sexo</strong>. A idade define o valor de referência da MTA.",
      "Avançar com <strong>Seguinte</strong> e <strong>Anterior</strong>, ou escolher uma secção na lista. " +
        "Todas as secções começam como normais: registar apenas os achados presentes.",
      "Para excluir uma secção não avaliada, selecionar <strong>×</strong> junto ao nome, na lista (ou <strong>Excluir do relatório</strong>).",
      "Selecionar <strong>ⓘ</strong> junto a um título para consultar a definição, as imagens de referência e a fonte.",
      "O último passo é o <strong>Aurora Report</strong>, no idioma do site: copiar o texto ou exportar para Excel. " +
        "Selecionar uma frase para voltar à respetiva secção.",
      "<strong>Novo relatório</strong> apaga todos os dados e recomeça."
    ],
    helpFaq: [
      [
        "Os dados introduzidos são guardados ou enviados?",
        "Não. Os dados de relatórios e calculadoras ficam apenas neste separador do browser, até este ser fechado ou até selecionar Novo relatório. " +
          "A Aurora conta as visitas às páginas com o Google Analytics, que não tem acesso aos dados introduzidos. " +
          "Só as mensagens enviadas pelo botão de mensagem chegam à equipa."
      ],
      [
        "A Aurora funciona no telemóvel e sem internet?",
        "Sim. Funciona em telemóveis, tablets e computadores. " +
          "Após a primeira visita, funciona também sem internet e pode ser instalada a partir do menu do browser (“Adicionar ao ecrã principal” ou “Instalar aplicação”)."
      ],
      [
        "Que idiomas estão disponíveis?",
        "O site e os relatórios estão disponíveis em inglês (EUA) e em português (Portugal); o idioma escolhe-se no canto superior direito da aplicação. " +
          "Estão previstos mais idiomas, e a ajuda com traduções é bem-vinda."
      ],
      [
        "De onde vêm as escalas e os valores de referência?",
        "De publicações com revisão por pares. As fontes estão em ⓘ, junto a cada secção, calculadora ou protocolo."
      ],
      [
        "A Aurora faz diagnósticos?",
        "Não. A Aurora não é um dispositivo médico certificado. Apoia o registo estruturado dos achados; a interpretação cabe sempre ao radiologista."
      ]
    ],
    helpFeedback: "Problemas ou sugestões? Usar o botão de mensagem, no canto inferior direito de cada página, ou enviar um email.",
    aboutTitle: ["Relatórios estruturados de neurorradiologia,", "baseados em evidência científica"],
    aboutIntro: "A Aurora reúne escalas visuais, calculadoras e imagens de referência para apoiar a avaliação sistemática e reprodutível dos achados de ressonância magnética cerebral. " +
      "Inclui ferramentas para alterações cognitivas e doenças do movimento, com novos módulos em desenvolvimento.",
    aboutPrinciples: [
      [
        "Evidência científica",
        "Cada escala, valor de referência e imagem de referência provém da literatura com revisão por pares, com ligação para a fonte original."
      ],
      [
        "Apoio ao relatório",
        "A Aurora não é um dispositivo médico certificado e não faz diagnósticos. A interpretação cabe ao radiologista."
      ],
      [
        "Privacidade dos dados",
        "Os dados introduzidos no relatório e nas calculadoras são processados localmente no browser e não são enviados para servidores."
      ],
      [
        "Acesso e licença",
        "A Aurora é gratuita e o código está disponível no <a href='https://github.com/alexandraslrodrigues/aurora'>GitHub</a> (CC BY-NC-SA 4.0)."
      ]
    ],
    getInvolved: "A Aurora é um projeto sem fins comerciais, desenvolvido e mantido de forma voluntária. " +
      "São bem-vindos contributos científicos e técnicos, incluindo propostas de novos módulos clínicos ou a revisão dos existentes.",
    license: "Aurora © 2025–2026 está licenciada sob <a href='https://creativecommons.org/licenses/by-nc-sa/4.0/'>Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International</a>."
  },

  // content/info-cards.js (ⓘ): title and definition. The credits (sources, permissions) stay as in the English file.
  info: {
    rsi: {
      title: "Pequenos enfartes subcorticais recentes",
      body: "<p>Enfarte agudo no território de uma única artéria perfurante, visível na sequência de difusão (DWI), tipicamente associado a um défice neurológico focal correspondente. " +
        "Considera-se pequeno quando tem menos de 20 mm de diâmetro máximo no plano axial; nas imagens coronais pode parecer ligeiramente maior. " +
        "Não há limite inferior de tamanho, porque a DWI permite distinguir enfartes muito pequenos de espaços perivasculares.</p>" +
        "<p>Não classificar como pequenos enfartes subcorticais:</p>" +
        "<ul><li>Enfartes estriatocapsulares: lesões &gt;20 mm nos gânglios da base/cápsula interna, causadas por várias artérias perfurantes, tipicamente em forma de vírgula (cabeça do caudado, cápsula interna, putamen).</li>" +
        "<li>Enfartes da artéria coroideia anterior (de etiologia distinta), no braço posterior da cápsula interna.</li></ul>"
    },
    lacunes: {
      title: "Lacunas de presumível origem vascular",
      body: "<p>As lacunas de presumível origem vascular são cavidades subcorticais redondas ou ovoides, preenchidas por líquido, com sinal semelhante ao do líquido cefalorraquidiano. " +
        "Medem tipicamente 3–15 mm; cavidades com menos de 3 mm também podem resultar de um pequeno enfarte subcortical recente.</p>" +
        "<p>A distinção com espaços perivasculares pode ser difícil, por poderem ter dimensões idênticas e não ter o halo hiperintenso em T2. " +
        "A forma da cavidade, a presença de espaços perivasculares adjacentes e as alterações de sinal do tecido envolvente ajudam a aumentar a especificidade do diagnóstico diferencial.</p>" +
        "<p>As lacunas podem resultar de pequenos enfartes subcorticais, de pequenas hemorragias subcorticais ou de lesões incidentais com restrição à difusão, ou corresponder à cavitação, em fase tardia, de uma hiperintensidade da substância branca.</p>"
    },
    wmh: {
      title: "Hipersinal da substância branca (escala de Fazekas)",
      body: "<p>As hiperintensidades da substância branca de presumível origem vascular são alterações de sinal da substância branca de tamanho variável, hiperintensas em imagens ponderadas em T2 como o FLAIR, sem cavitação. " +
        "As lesões na substância cinzenta subcortical ou no tronco encefálico não são incluídas, salvo indicação explícita (designam-se então hiperintensidades subcorticais).</p>" +
        "<p><b>Periventricular:</b> 0 = ausente; 1 = “capuchos” ou linha fina; 2 = “halo” regular; 3 = sinal periventricular irregular que se estende à substância branca profunda.<br>" +
        "<b>Substância branca profunda:</b> 0 = ausente; 1 = focos punctiformes; 2 = início de confluência; 3 = grandes áreas confluentes.</p>"
    },
    pvs: {
      title: "Escala de espaços perivasculares alargados",
      body: "<p>Marcado alargamento de espaços perivasculares nos gânglios da base e no centro semioval (Figura 1), com espaços perivasculares também visíveis no mesencéfalo (pontas de seta). " +
        "A Figura 2 ilustra o espectro de gravidade: (a) grau 4 (marcado) no centro semioval; (b) grau 2 nos gânglios da base; " +
        "(c) espaços perivasculares visíveis (grau 1) no mesencéfalo, também assinalados por pontas de seta.</p>" +
        "<p>Gânglios da base e centro semioval (contagem no hemisfério com mais espaços perivasculares, no corte com o maior número): 0 = ausentes; 1 = 1–10; 2 = 11–20; 3 = 21–40; 4 = &gt;40. " +
        "Mesencéfalo: 0 = ausentes; 1 = visíveis.</p>"
    },
    microbleeds: {
      title: "Escala anatómica de micro-hemorragias (MARS)",
      body: "<p>As micro-hemorragias cerebrais são pequenas hemorragias crónicas, visíveis como lesões focais, redondas e hipointensas em sequências de eco de gradiente ponderadas em T2* (T2*-GRE) ou ponderadas em suscetibilidade, que refletem depósitos de hemossiderina por extravasamento vascular. " +
        "A Microbleed Anatomical Rating Scale (MARS) classifica as micro-hemorragias de forma padronizada, pela localização anatómica e pelas características de imagem.</p>" +
        "<ul><li>Lobares: regiões corticais e subcorticais, incluindo as fibras em U subcorticais.</li>" +
        "<li>Profundas: gânglios da base, tálamo, cápsula interna, cápsula externa, corpo caloso e substância branca profunda/periventricular (até cerca de 10 mm dos ventrículos laterais).</li>" +
        "<li>Infratentoriais: tronco encefálico e cerebelo.</li></ul><p>Classificação de imagem (T2*-GRE):</p>" +
        "<ul><li>Micro-hemorragias definitivas: lesões hipointensas pequenas (2–10 mm), redondas ou circulares e bem definidas.</li>" +
        "<li>Micro-hemorragias possíveis: menos bem definidas, menos hipointensas ou não estritamente redondas.</li></ul>"
    },
    css: {
      title: "Escala de multifocalidade da siderose superficial cortical",
      body: "<p>A siderose superficial cortical (cSS) identifica-se como um sinal hipointenso curvilíneo, bem definido e homogéneo em sequências de eco de gradiente ponderadas em T2* ou ponderadas em suscetibilidade, que acompanha a superfície externa do córtex cerebral no espaço subaracnoideu. " +
        "Não pontuar a cSS contígua ou anatomicamente ligada a uma hemorragia intracerebral lobar. " +
        "Para ser considerada separada, a cSS tem de estar a ≥3 sulcos de distância, ou a ≥2 sulcos em vários níveis axiais sem comunicação superficial evidente.</p>" +
        "<ul><li>Score de cSS (cada hemisfério): 0 = sem cSS; 1 = 1 sulco ou ≤3 sulcos adjacentes; 2 = ≥2 sulcos não adjacentes ou &gt;3 sulcos adjacentes.</li>" +
        "<li>Score total de cSS (direito + esquerdo): 0 = sem cSS; 1 = ligeira/unifocal; ≥2 = marcada/multifocal.</li></ul>"
    },
    gca: {
      title: "Escala de atrofia cortical global (GCA)",
      body: "<p><b>Escala:</b> 0 = sem atrofia; 1 = discreta atrofia, com alargamento dos sulcos; 2 = moderada atrofia, com perda de volume dos giros; 3 = marcada atrofia, em “lâmina de faca”.</p>"
    },
    mta: {
      title: "Escala de atrofia temporal mesial (MTA)",
      body: "<p><b>Orientação:</b> imagem coronal ponderada em T1, num plano paralelo ao eixo do tronco encefálico, através do hipocampo ao nível da porção anterior da ponte. " +
        "Cada hemisfério é classificado separadamente.</p><p><b>Escala</b> (largura da fissura coroideia, largura do corno temporal e altura do hipocampo):</p>" +
        "<ul><li>0: sem líquido cefalorraquidiano visível em torno do hipocampo</li><li>1: discreto alargamento da fissura coroideia</li>" +
        "<li>2: moderado alargamento da fissura coroideia, discreto aumento do corno temporal e discreta perda de altura do hipocampo</li>" +
        "<li>3: marcado alargamento da fissura coroideia, moderado aumento do corno temporal e moderada perda de altura do hipocampo</li>" +
        "<li>4: marcado alargamento da fissura coroideia, marcado aumento do corno temporal e marcada atrofia do hipocampo, com perda da estrutura interna</li>" +
        "</ul><p>Valores de referência publicados, ajustados à idade (cada hemisfério): ≥2 abaixo dos 75 anos; ≥3 a partir dos 75 anos.</p>"
    },
    erica: {
      title: "Escala de atrofia cortical entorrinal (ERICA)",
      body: "<p><b>Orientação:</b> cortes coronais alinhados com o tronco encefálico, com 1 mm de espessura.</p><p><b>Escala:</b></p>" +
        "<ul><li>0: volume normal do córtex entorrinal e do giro para-hipocampal</li><li>1: discreta atrofia, com alargamento do sulco colateral</li>" +
        "<li>2: moderada atrofia, com afastamento do córtex entorrinal em relação à tenda do cerebelo (“sinal da fenda tentorial”)</li>" +
        "<li>3: marcada atrofia do giro para-hipocampal e fenda larga entre o córtex entorrinal e a tenda do cerebelo</li></ul>" +
        "<p>Valor de referência publicado (cada lado): ≥2.</p>"
    },
    koedam: {
      title: "Atrofia parietal posterior (escala de Koedam)",
      body: "<p><b>Orientação:</b> imagens sagitais, axiais e coronais.</p>" +
        "<p><b>Avaliar:</b> nas imagens sagitais, o sulco cingulado posterior, o sulco parieto-occipital e a atrofia do pré-cúneo; nas imagens axiais e coronais, o alargamento do sulco cingulado posterior e a dilatação dos sulcos parietais.</p>" +
        "<p><b>Escala:</b> 0 = sem atrofia; 1 = discreta; 2 = moderada; 3 = marcada.</p>"
    },
    svd: {
      title: "Score total de doença de pequenos vasos (SVD)",
      body: "<p>Um ponto por cada critério presente:</p><ul><li>Lacunas: ≥1</li>" +
        "<li>Micro-hemorragias cerebrais: ≥1, em qualquer localização (apenas definitivas; as possíveis são descritas mas não pontuam)</li>" +
        "<li>Espaços perivasculares: moderados a marcados (grau 2–4) nos gânglios da base</li>" +
        "<li>Hipersinal da substância branca: profundo (Fazekas 2–3) ou periventricular irregular que se estende à substância branca profunda (Fazekas 3)</li>" +
        "</ul>"
    }
  },

  // content/info-cards.js: abbreviations explained under each ⓘ card
  infoAbbreviations: {
    CSF: "líquido cefalorraquidiano",
    DWI: "imagem ponderada em difusão",
    FLAIR: "fluid-attenuated inversion recovery",
    GRE: "eco de gradiente",
    MR: "ressonância magnética",
    SWI: "imagem ponderada em suscetibilidade",
    LCR: "líquido cefalorraquidiano",
    RM: "ressonância magnética"
  },

  // content/movement-calculator.js
  movement: {
    indices: {
      mrpi: {
        about: "Marcador de PSP: aumenta com a atrofia do mesencéfalo e dos pedúnculos cerebelosos superiores. " +
          "Valores acima do valor de referência associam-se a PSP. " +
          "Encontram-se valores baixos na PD e em controlos, e valores ainda mais baixos na MSA (atrofia da ponte e dos pedúnculos cerebelosos médios), com sobreposição entre eles."
      },
      mrpi2: {
        about: "Marcador de PSP que acrescenta ao MRPI o alargamento do terceiro ventrículo. Desenvolvido para distinguir PSP-P de PD. " +
          "O estudo original não incluiu MSA; num estudo posterior a 3 T, a diferença entre PSP-P e MSA-P não foi significativa após correção para comparações múltiplas ({Madetko 2022})."
      },
      mpa: {
        about: "Marcador de PSP: diminui quando o mesencéfalo está atrófico em relação à ponte. Valores abaixo do valor de referência associam-se a PSP."
      },
      md: {
        about: "Marcador de PSP: um diâmetro curto do mesencéfalo indica atrofia do mesencéfalo."
      },
      mdpd: {
        about: "Marcador de PSP: diminui quando o mesencéfalo está atrófico em relação à ponte."
      },
      mcp: {
        about: "Marcador de MSA: o estreitamento indica atrofia do pedúnculo cerebeloso médio, um marcador de ressonância magnética nos critérios MDS 2022 de MSA; os critérios usam avaliação visual e não especificam o valor de referência quantitativo usado aqui."
      }
    },
    howto: {
      "area_mes_pon.webp": {
        steps: [
          "Imagem sagital ponderada em T1, na linha média (através do aqueduto e da cisterna interpeduncular).",
          "Linha azul superior: através da incisura pôntica superior e do bordo inferior da placa quadrigémea.",
          "Linha azul inferior: paralela à superior, através da incisura pôntica inferior.",
          "Área do mesencéfalo (contorno vermelho superior): o tegmento mesencefálico, em forma de delta, acima da linha superior e fechado por ela; o teto (placa quadrigémea) é excluído.",
          "Área da ponte (contorno vermelho inferior): entre as duas linhas azuis, limitada pelas margens anterior e posterior da ponte."
        ]
      },
      "picture_scp.webp": {
        steps: [
          "Imagens coronais oblíquas ponderadas em T1, reconstruídas a partir de um bloco tangente ao pavimento do quarto ventrículo (linha vermelha).",
          "Imagem de partida: a primeira imagem, no sentido anteroposterior, em que os colículos inferiores e os SCP estão separados.",
          "Medir a distância entre os bordos medial e lateral de cada SCP, a meio da sua extensão, em 3 cortes consecutivos.",
          "Introduzir as larguras direita e esquerda (cada uma, a média dos seus 3 cortes); a Aurora usa a média das duas."
        ]
      },
      "picture_mcp.webp": {
        steps: [
          "Imagem parassagital ponderada em T1 que melhor mostra o MCP entre a ponte e o cerebelo.",
          "Medir a distância entre os bordos superior e inferior do MCP, delimitados pelo líquido cefalorraquidiano das cisternas pontocerebelosas.",
          "Medir à direita e à esquerda; a Aurora usa a média das duas."
        ]
      },
      "picture_3v.webp": {
        steps: [
          "Imagem axial ponderada em T1 ao nível das comissuras anterior e posterior.",
          "Medir a distância máxima entre os bordos laterais do terceiro ventrículo nas porções anterior, média e posterior.",
          "Introduzir as 3 medições; a Aurora usa a média das medições introduzidas."
        ]
      },
      "picture_fh.webp": {
        steps: [
          "Imagem axial ponderada em T1 com a dilatação máxima dos cornos frontais.",
          "Medir a maior largura dos cornos frontais, da esquerda para a direita."
        ]
      },
      help_diameters: {
        steps: [
          "Imagem sagital ponderada em T1, na linha média.",
          "Colocar uma região elíptica sobre o mesencéfalo e outra sobre a ponte.",
          "Traçar o eixo longo (oblíquo, superoinferior) de cada elipse e medir o diâmetro máximo perpendicular a esse eixo.",
          "A medição do mesencéfalo exclui a placa quadrigémea; a medição da ponte corresponde à base da ponte (sem o tegmento pôntico)."
        ]
      }
    },
    abbreviations: {
      PSP: "paralisia supranuclear progressiva",
      "PSP-RS": "paralisia supranuclear progressiva com síndrome de Richardson",
      "PSP-P": "paralisia supranuclear progressiva com parkinsonismo predominante",
      PD: "doença de Parkinson",
      MSA: "atrofia multissistémica",
      "MSA-P": "atrofia multissistémica, tipo parkinsónico",
      "MSA-C": "atrofia multissistémica, tipo cerebeloso",
      MCP: "pedúnculo cerebeloso médio",
      SCP: "pedúnculo cerebeloso superior",
      MDS: "International Parkinson and Movement Disorder Society",
      MRI: "ressonância magnética",
      T: "tesla"
    },
    notes: {
      pspAge: "Acima dos 80 anos, a fiabilidade dos valores de referência publicados é incerta: a atrofia do mesencéfalo relacionada com a idade pode reduzir a especificidade ({Chougar 2024}). " +
        "O MRPI é menos afetado pela idade do que o rácio das áreas mesencéfalo/ponte ({Morelli 2014}).",
      general: "Os valores de referência publicados dependem do método, da intensidade do campo e da coorte. " +
        "Apoiam a avaliação imagiológica, mas não são diagnósticos por si só."
    }
  },

  // content/protocols.js (by protocol id)
  protocols: {
    cognitive: {
      diagnosis: {
        abbreviations: "2D, bidimensional; 3D, tridimensional; ADC, coeficiente de difusão aparente; ASL, arterial spin labeling; DWI, imagem ponderada em difusão; " +
          "FLAIR, fluid-attenuated inversion recovery; GCA, atrofia cortical global; GRE, eco de gradiente; MTA, atrofia temporal mesial; " +
          "SWI, imagem ponderada em suscetibilidade; T, tesla"
      }
    },
    movement: {
      parkinsonism: {
        abbreviations: "2D, bidimensional; 3D, tridimensional; AC–PC, comissura anterior–comissura posterior; ADC, coeficiente de difusão aparente; " +
          "DTI, imagem por tensor de difusão; DWI, imagem ponderada em difusão; FLAIR, fluid-attenuated inversion recovery; MCP, pedúnculo cerebeloso médio; " +
          "SCP, pedúnculo cerebeloso superior; SWI, imagem ponderada em suscetibilidade; T, tesla; TSE, turbo spin echo"
      }
    }
  }
};
