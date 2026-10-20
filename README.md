# I-Ching: Stalks & Sacred Marbles · 易經 Oracle

An authentic, meditative I-Ching divination bar widget and interactive oracle for the **Omarchy** desktop environment.

Built with **pure QML / Quickshell** with zero binary dependencies, featuring **Andrew Kennedy's Revised Yarrow Algorithm** (2006), the mathematically optimal **38-Marble Divination Method**, the **Nuclear Trigram Engine (*Hù Guà*) with the Four Primordial Root Gates**, and an original, MIT-licensed **Classical *Zhōuyì* & *Ten Wings* British-English translation and scholarly commentary**.

![I-Ching: Stalks & Sacred Marbles](preview.png)

---

## What Makes This Oracle Unique?

### 1. The Coin Flaw in Digital Divination
Almost all computer I-Ching programs and Western interpretations use the three-coin toss (8 outcomes). Three coins produce equal 12.5% probabilities (1/8) for both changing lines (Old Yang and Old Yin).

In authentic Daoist cosmology, this is fundamentally incorrect:
* **Yang** (━━━━━━━) is active, dynamic solar energy; it is restless and burns out quickly, transforming three times more readily into Yin.
* **Yin** (━━━ ━━━) is receptive, steady lunar/earthen energy; it is quiet and slow to alter course.

### 2. Beyond Martin Gardner's 1974 "Chalkboard Mathematics"
In 1974, mathematician Martin Gardner published the classical yarrow stalk ratio in *Scientific American* (1/16 Old Yin, 3/16 Old Yang, 5/16 Young Yang, 7/16 Young Yin). This popularised the 16-ratio / 32-marble bag.

However, Gardner's model assumed idealised chalkboard mathematics where stalks divide into clean theoretical quarters and hands could hold zero stalks.

### 3. Andrew Kennedy's Revised Yarrow Algorithm (2006)
In 2006, researcher Andrew Kennedy published his revised yarrow algorithm in *Briefing Leaders: A new look at the I Ching and the Tao De Ching* (Gravity Publishing), demonstrating that stalks in physical human hands behave differently than idealised models:
1. When splitting 49 stalks between left and right hands, **neither hand can ever be empty**.
2. Drawing 1 stalk from the right hand to tuck between your fingers requires the right hand to hold **at least 2 stalks initially**.
3. Therefore, dividing 49 stalks creates **47 physical hand split points** (2 ≤ West ≤ 48).
4. **47 is a prime number**—it does not divide into clean chalkboard quarters.
5. On subsequent sorting passes (dividing 44, 40, 36, or 32 stalks), the same physical hand constraints apply.

### 4. The 38-Marble Mathematical Optimum
Because hands cannot hold zero stalks, real-world yarrow odds diverge from the old 32-marble model by up to **2.4% per line**.

Kennedy proved that an opaque pouch of **38 marbles** replicates physical hand-sorted stalks to within **less than a tenth of one percent (< 0.09%)** across all four line types. Furthermore, an exhaustive mathematical combinatorial search across all pouch sizes up to 100 objects proves that **38 is the #1 global optimum in existence**.

| Line Type | Symbol | Classical Meaning | Gardner (32 Bag) | True Physical Stalks | Kennedy's Revised (38 Bag) | Accuracy Delta |
| :--- | :---: | :--- | :---: | :---: | :---: | :---: |
| **Young Yin (8)** | ━━━ ━━━ | Unchanging Yin | 43.75% (14/32) | **44.84%** | **44.74%** (17/38) | **< 0.10%** |
| **Young Yang (7)** | ━━━━━━━ | Unchanging Yang | 31.25% (10/32) | **28.87%** | **28.95%** (11/38) | **< 0.08%** |
| **Old Yang (9)** | ━━━○━━━ | Changing Yang → Yin | 18.75% (6/32) | **21.12%** | **21.05%** (8/38) | **< 0.07%** |
| **Old Yin (6)** | ━━━✕━━━ | Changing Yin → Yang | 6.25% (2/32) | **5.17%** | **5.26%** (2/38) | **< 0.09%** |

---

## Major Features

### 1. Nuclear Trigrams Engine (*Hù Guà* · 互卦) & Four Primordial Root Gates
Beyond the primary surface reading lies the **Nuclear Hexagram (*Hù Guà*)**, an ancient interpretive dimension dating back to the *Zuǒ Zhuàn* (4th c. BCE) and the Han Dynasty commentators Zheng Xuan and Yu Fan:
* **The Core Extraction**:
  * **Lower Nuclear Trigram**: Lines 2, 3, 4 of the outer hexagram.
  * **Upper Nuclear Trigram**: Lines 3, 4, 5 of the outer hexagram.
* **The 16 Nuclear Families**: While there are 64 primary hexagrams, there are strictly **only 16 possible nuclear hexagrams**. Every primary hexagram belongs to one of these 16 core patterns.
* **The Four Primordial Root Gates**: Iterating nuclear reduction recursively collapses all 64 hexagrams into one of **Four Primordial Attractors** (Root Gates):
  * **Gate 1: Hexagram 1 — The Creative Principle (乾 · Qián)** — Pure Creative Yang & Dynamic Initiative
  * **Gate 2: Hexagram 2 — The Receptive Earth (坤 · Kūn)** — Pure Receptivity, Devotion & Grounding
  * **Gate 3: Hexagram 63 — Already Across (既濟 · Jì Jì)** — Peak Order, Dynamic Equilibrium & Balanced Reciprocity
  * **Gate 4: Hexagram 64 — Not Yet Across (未濟 · Wèi Jì)** — Primordial Genesis, Infinite Becoming & Open Potential
* Every hexagram card displays a standalone Primordial Root Gate badge identifying its ultimate cosmological attractor.

### 2. The X → Y Nuclear Transition Matrix
When a reading contains changing lines, transformation occurs not only on the manifest outer surface, but deep inside the embryonic core:
* **Visual Side-by-Side Matrix**:
  * **Initial Core (State X)**: The nuclear hexagram of the Primary Hexagram.
  * **Relating Core (State Y)**: The nuclear hexagram of the Transformed (*Zhī Guà*) Hexagram.
* **Active Nuclear Core Lines**: Distinct visual markers indicating which inner lines (Lines 2, 3, 4, 5) are actively shifting across the transformation.
* **Dynamic Transition Vectors**: Centre directional indicators explicitly mapping which nuclear levels undergo change (e.g. `Lines 1, 2, 3, 4 ➔`, `Line 2 ➔`, `Lines 2, 4 ➔`, etc.).
* **Equalised Card Geometry**: Balanced side-by-side cards with top-aligned baselines and clean non-overflowing badge pills.

### 3. Two-Level Layered Flipping Architecture
Replaces lengthy, overwhelming vertical scrolling with a focused, meditative layered navigation system:
* **Level 1 (Stage Flipping)**: When changing lines occur, smoothly step or jump between:
  * `[ ☯ Present (Hexagram X) ]`: Primary Hexagram.
  * `[ ⚡ Lines (Y) ]`: The Changing Lines operative counsel.
  * `[ ➔ Future (Hexagram Z) ]`: Relating Hexagram (*Zhī Guà*).
  * Intuitive sequential stepper buttons (`Next: The Changing Lines ➔`, `← Present / Next: Future ➔`, etc.) guide the inquiry seamlessly.
* **Level 2 (Hexagram Aspect Flipping)**: Inside any hexagram card, inspect distinct dimensions:
  * `[ 📜 Judgment ]`: King Wen oracle verse (*Guàcí*) + Classical Commentary on the Judgment (*Tuàn Zhuàn*).
  * `[ 🌊 Image ]`: The Great Image verse (*Dà Xiàng*) + Classical Commentary on the Image.
  * `[ ☯ Trigrams ]`: Dual Trigram polarity breakdown with prominent 42px glyphs, Realm badges (Outer Realm Lines 4–6 vs Inner Realm Lines 1–3), Chinese/Pinyin/Element/Quality attributes, and Structural & Elemental dynamics.
  * `[ ⚛ Nuclear ]`: Dedicated Nuclear Hexagram breakdown with Root Gate pill, inner trigrams, and the full X → Y Transition Matrix.

### 4. Original MIT-Licensed Classical *Zhōuyì* & *Ten Wings* Translation
* Complete King Wen Judgments (*Guàcí*, 卦辭), Great Images (*Dà Xiàng*, 大象), and Duke of Zhou Line Texts (*Yáocí*, 爻辭) across all 64 hexagrams, freshly translated and synthesised in British English by Matthew Hudson directly from the public-domain Classical Chinese canon and pre-1929 public-domain sinological scholarship.
* Comprehensive commentaries on the Judgments (*Tuàn Zhuàn*), Great Images (*Dà Xiàng*), and Structural Trigram dynamics across all 64 hexagrams.
* All 384 changing lines plus the two special seventh lines for Hexagram 1 (*All Nines · Yòng Jiǔ*) and Hexagram 2 (*All Sixes · Yòng Liù*), with positional analysis (*Dāng Wèi* correctness, *Zhōng* centrality, *Yìng* resonance, and *Xiǎo Xiàng* Small Images).
* Released in full under the repository's **MIT Licence**, with zero third-party copyrighted translation text.

### 5. Segmented 5-Tab Lore Section & Classical Scholarship
An integrated, encyclopaedic reference drawer organised into 5 focused tabs:
1. **🌿 Ritual**: The 18-step yarrow stalk ceremony from the Han-era *Great Treatise* (*Dà Zhuàn*) and Zhu Xi's *Yìxué Qǐméng* (1186 CE).
2. **🔮 Math**: Rigorous mathematical dissection comparing Martin Gardner's 1974 chalkboard model with Andrew Kennedy's 2006 Revised Yarrow Algorithm and the 38-Marble global optimum (< 0.09% error).
3. **⚛ Nuclear**: Complete mathematical derivation of recursive nuclear reduction, the 16 nuclear families, the Four Primordial Root Gates, and the mechanics of core inner transformation.
4. **🧘 Mind**: Consultation protocol, Sincerity of Intent (*Chéng*, 誠), open framing, and the classical rule of Hexagram 4.
5. **📜 Canon**: Textual provenance and bibliography covering the Western Zhou *Zhōuyì*, the Confucian *Ten Wings* (*Shí Yì*), Song Neo-Confucian exegesis, and public-domain European scholarship:
   * *Zuǒ Zhuàn* (左傳, 4th c. BCE) — earliest documented historical divinations utilising nuclear trigrams (*Hù Tǐ*).
   * *Dà Zhuàn* (大傳 / *Xìcí Zhuàn*, Warring States) — classical authority on inner line resonance and mutual interpenetration.
   * Zheng Xuan (鄭玄, 127–200 CE) & Yu Fan (虞翻, 164–233 CE) — foundational Han Dynasty systematisers of nuclear trigram analysis.
   * James Legge (*The Yi King*, Sacred Books of the East, Vol. XVI, Oxford University Press, 1882/1899 — Public Domain).
   * Richard Wilhelm (*I Ging: Das Buch der Wandlungen*, Eugen Diederichs Verlag, Jena, 1923 — Public Domain).
   * Andrew Kennedy (2006, *Briefing Leaders: A new look at the I Ching and the Tao De Ching*, Gravity Publishing).

### 6. Desktop Integration & Polish
* **Uniform Button Styling**: All buttons across the application (Cast All, Reset, Copy, New Consultation, and Chamber buttons) feature crisp, uniform bordered boxes and matching heights.
* **Dedicated Scrollbar Gutter**: 16px isolated right-hand scroll gutter ensures scrollbars never overlay cards or clip typography.
* **Intent-Locked Sincere Inquiry**: Inscribe your question prior to consultation; the input field locks with zero layout jitter during line generation.
* **One-Click Publication Export**: The `📋 Copy` action streams a publication-ready Markdown report directly to `wl-copy` via standard input (`Quickshell.Io.Process` stdin), keeping user inquiries private and off process command-line arguments.

---

## Installation

Install directly with the Omarchy CLI:

```bash
omarchy plugin add https://github.com/layolayo/omarchy-iching-oracle.git --enable
```

Or add it to your bar layout via the Omarchy Bar Settings or `shell.toml`.

---

## Removal

To disable or completely remove the plugin:

```bash
# Disable the plugin
omarchy plugin disable io.github.layolayo.iching-oracle

# Remove from system
omarchy plugin remove io.github.layolayo.iching-oracle
```

---

## Keyboard Shortcuts

While the panel is open:
- `Space`: Cast the next line (or draw marble) from the bottom up.
- `R`: Reset and begin a new consultation.
- `1`: Switch to Casting Chamber.
- `2`: Switch to Reading View.
- `3`: Switch to Lore & Math Drawer.

---

## Classical & Academic References

* **Zhōuyì (周易) & Shí Yì (十翼, *The Ten Wings*)** (c. 1046–200 BCE). Received classical standard text (*Shísānjīng Zhùshū*, Ruan Yuan ed., 1815 — Public Domain).
* **Zhu Xi (朱熹)** (1177 / 1186 CE). *Zhōuyì Běnyì* (周易本義) & *Yìxué Qǐméng* (易學啟蒙, *Introduction to the Study of the Classic of Changes* — Public Domain).
* **Legge, James** (1882/1899). *The Yi King* (*Sacred Books of the East*, Vol. XVI). Oxford University Press (Public Domain).
* **Wilhelm, Richard** (1923). *I Ging: Das Buch der Wandlungen*. Eugen Diederichs Verlag, Jena (Public Domain; author died 1930).
* **Kennedy, Andrew** (2006). *Briefing Leaders: A new look at the I Ching and the Tao De Ching*. Gravity Publishing. ISBN: 978-0955355608.
* **Gardner, Martin** (1974). "Mathematical Games: The Combinatorial Properties of the I Ching." *Scientific American*, 230(1), 108–113.
* **Zuo Qiuming** (4th c. BCE). *Zuǒ Zhuàn* (左傳, *The Zuo Tradition / Commentary on the Spring and Autumn Annals*).
* **Zheng Xuan** (127–200 CE) & **Yu Fan** (164–233 CE). *Han Dynasty Commentaries on the Changes and Hù Tǐ (互體)*.

---

## Licence & Dataset Provenance

**MIT Licence**. Copyright (c) 2026 Matthew Hudson.

All QML/JavaScript source code and the complete English translation and commentary dataset in `IChingData.js` (64 Judgments, 64 Great Images, 386 Line Texts, and all Judgment, Image, Structural, Nuclear, and Line commentaries) are original works by Matthew Hudson derived directly from public-domain Classical Chinese sources (*Zhōuyì* and *Ten Wings*) and pre-1929 public-domain scholarship, and are distributed under the MIT Licence (see [LICENSE](LICENSE)).
