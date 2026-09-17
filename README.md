# I-Ching: Stalks & Sacred Marbles · 易經 Oracle

An authentic, meditative I-Ching divination bar widget and interactive oracle for the **Omarchy** desktop environment.

Built with **pure QML / Quickshell** with zero binary dependencies, featuring **Andrew Kennedy's Revised Yarrow Algorithm** (2006) and the mathematically optimal **38-Marble Divination Method**.

![I-Ching: Stalks & Sacred Marbles](preview.png)

---

## What Makes This Oracle Unique?

### 1. The Coin Flaw in Digital Divination
Almost all computer I-Ching programs and Western interpretations use the three-coin toss (2³ = 8 outcomes). Three coins produce equal 12.5% probabilities (1/8) for both changing lines (Old Yang and Old Yin). 

In authentic Daoist cosmology, this is fundamentally incorrect:
* **Yang** (━━━━━━━) is active, dynamic solar energy; it is restless and burns out quickly, transforming three times more readily into Yin.
* **Yin** (━━━ ━━━) is receptive, steady lunar/earthen energy; it is quiet and slow to alter course.

### 2. Beyond Martin Gardner's 1974 "Chalkboard Math"
In 1974, mathematician Martin Gardner published the classical yarrow stalk ratio in *Scientific American* (1/16 Old Yin, 3/16 Old Yang, 5/16 Young Yang, 7/16 Young Yin). This popularized the 16-ratio / 32-marble bag.

However, Gardner's model assumed idealized chalkboard mathematics where stalks divide into clean theoretical quarters and hands could hold zero stalks.

### 3. Andrew Kennedy's Revised Yarrow Algorithm (2006)
In 2006, researcher Andrew Kennedy published his revised yarrow algorithm in *Briefing Leaders: A new look at the I Ching and the Tao De Ching* (Gravity Publishing), demonstrating that stalks in physical human hands behave differently than idealized models:
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

## Features

- **Two-Level Layered Flipping Architecture (New in v1.2.0)**:
  - Replaces overwhelming vertical scripts with a focused, meditative layered interface.
  - **Level 1 (Stage Flipping)**: When changing lines occur, sequentially step or jump between:
    - `[ ☯ Present (#X) ]`: Primary Hexagram.
    - `[ ⚡ Lines (Y) ]`: The Changing Lines operative counsel.
    - `[ ➔ Future (#Z) ]`: Relating Hexagram (*Zhī Guà*).
  - **Level 2 (Aspect Flipping)**: Within any hexagram card, inspect distinct dimensions with instant pill tabs:
    - `[ 📜 Judgment ]`: King Wen's oracle verse + Wilhelm Commentary on the Judgment.
    - `[ 🌊 Image ]`: The Great Image verse + Wilhelm Commentary on the Image.
    - `[ ☯ Trigrams ]`: Dual Trigram polarity breakdown with prominent 42px glyphs, distinct Realm badges (Outer Realm Lines 4–6 vs Inner Realm Lines 1–3), Chinese/Pinyin/Element/Quality cosmological attributes, and Wilhelm's Structural & Elemental Dynamics.
    - `[ 👁 Both ]`: Condensed at-a-glance view of both Judgment and Image verses.
- **Definitive Wilhelm / Baynes Translation & Complete Commentary**:
  - Full King Wen judgments, images, line texts (爻辭, *Yáo Cí*), commentaries on judgments and images, and deep structural trigram dynamics from the authoritative Richard Wilhelm & Cary F. Baynes translation (*Princeton University Press, Bollingen Series XIX*).
  - All 64 hexagrams, 384 individual lines, and special 7th lines for Hexagram 1 (The Creative — *all nines*) and Hexagram 2 (The Receptive — *all sixes*).
- **The Changing Lines (爻辭 · Operative Counsel)**:
  - Focused transformation card isolating all lines in active motion.
  - Traditional position titles (*"Nine at the beginning"*, *"Six in the second place"*, etc.), poetic oracle verses, and practical counsel for the turning point.
- **Two Authentic Divination Methods**:
  - **🔮 38 Marbles Pouch**: Rapid blind draw simulating physical hand-sorted stalks with < 0.09% error (the #1 most accurate integer model in existence).
  - **🌿 49 Yarrow Stalks**: Full classical 3-pass ritual sorting (1 stalk set aside for Taiji, 49 divided between Heaven and Earth, counted off in 4s).
- **Intent-Locked Sincere Inquiry**:
  - Frame your question before casting; the field locks into focus during the bottom-up draw with a stable, zero-shift layout for effortless rapid casting.
- **Segmented 3-Phase Navigation**:
  - **☯ Chamber**: Interactive bottom-up line casting (Line 1 Earth → Line 6 Heaven) with dynamic lower and upper trigram illumination.
  - **📖 Reading**: Comprehensive presentation of Primary Hexagram, Operative Counsel for Changing Lines, and Future Relating Hexagram (*Zhī Guà*).
  - **ℹ Lore & Math**: In-app guide explaining Zhu Xi (1186), Martin Gardner (1974), Andrew Kennedy's Revised Yarrow Algorithm (2006), and the Wilhelm/Baynes classical lineage.
- **Refined Reading Layout & Typography**:
  - Spacious 510px layout with an isolated right-hand scrollbar gutter that never overlays text or cards.
- **Desktop Clipboard Export**:
  - One-click copy (`📋 Copy`) generating a formatted, publication-grade Markdown consultation report complete with Judgment commentaries, Image commentaries, Trigram dynamics, and line counsel.
- **Zero External Dependencies**:
  - Written in pure QML / QtQuick / Quickshell running natively and lightweight in Omarchy.

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

## References

* **Kennedy, Andrew** (2006). *Briefing Leaders: A new look at the I Ching and the Tao De Ching*. Gravity Publishing. ISBN: 978-0955355608.
* **Gardner, Martin** (1974). "Mathematical Games: The Combinatorial Properties of the I Ching." *Scientific American*, 230(1), 108–113.
* **Zhu Xi** (1186 CE). *Yixue Qimeng* (易學啟蒙, *Introduction to the Study of the I Ching*).
* **Wilhelm, Richard & Baynes, Cary F.** (1950/1967). *The I Ching or Book of Changes*. Foreword by C.G. Jung. Princeton University Press (Bollingen Series XIX). ISBN: 978-0691097503.

---

## License

MIT License. Copyright (c) 2026 Matthew Hudson.
