# I-Ching: Stalks & Sacred Marbles · 易經 Oracle

An authentic, meditative I-Ching divination bar widget and interactive oracle for the **Omarchy** desktop environment.

Built with **pure QML / Quickshell** with zero binary dependencies, featuring the **2006 Andrew Kennedy Physical Hands Yarrow Algorithm** and the mathematically optimal **38-Marble Divination Method**.

![I-Ching: Stalks & Sacred Marbles](preview.png)

---

## What Makes This Oracle Unique?

### 1. The Coin Flaw in Digital Divination
Almost all computer I-Ching programs and Western interpretations use the three-coin toss (2³ = 8 outcomes). Three coins produce equal 12.5% probabilities (1/8) for both changing lines (Old Yang and Old Yin). 

In authentic Daoist cosmology, this is fundamentally incorrect:
* **Yang** (⚊) is active, dynamic solar energy; it is restless and burns out quickly, transforming three times more readily into Yin.
* **Yin** (⚋) is receptive, steady lunar/earthen energy; it is quiet and slow to alter course.

### 2. Beyond Martin Gardner's 1974 "Chalkboard Math"
In 1974, mathematician Martin Gardner published the classical yarrow stalk ratio in *Scientific American* (1/16 Old Yin, 3/16 Old Yang, 5/16 Young Yang, 7/16 Young Yin). This popularized the 16-ratio / 32-marble bag.

However, Gardner's model assumed idealized chalkboard mathematics where stalks divide into clean theoretical quarters and hands could hold zero stalks.

### 3. The 2006 Andrew Kennedy Discovery (Physical Hand Boundaries)
In 2006, researcher Andrew Kennedy demonstrated in *Briefing Leaders* that stalks in physical human hands behave differently:
1. When splitting 49 stalks between left and right hands, **neither hand can ever be empty**.
2. Drawing 1 stalk from the right hand to tuck between your fingers requires the right hand to hold **at least 2 stalks initially**.
3. Therefore, dividing 49 stalks creates **47 physical hand split points** (2 ≤ West ≤ 48).
4. **47 is a prime number**—it does not divide into clean chalkboard quarters.
5. On subsequent sorting passes (dividing 44, 40, 36, or 32 stalks), the same physical hand constraints apply.

### 4. The 38-Marble Mathematical Optimum
Because hands cannot hold zero stalks, real-world yarrow odds diverge from the old 32-marble model by up to **2.4% per line**. 

Kennedy proved that an opaque pouch of **38 marbles** replicates physical hand-sorted stalks to within **less than a tenth of one percent (< 0.09%)** across all four line types. Furthermore, an exhaustive mathematical combinatorial search across all pouch sizes up to 100 objects proves that **38 is the #1 global optimum in existence**.

| Line Type | Symbol | Classical Meaning | Gardner (32 Bag) | True Physical Stalks | Kennedy (38 Bag) | Accuracy Delta |
| :--- | :---: | :--- | :---: | :---: | :---: | :---: |
| **Young Yin (8)** | ⚋ | Unchanging Yin | 43.75% (14/32) | **44.84%** | **44.74%** (17/38) | **< 0.10%** |
| **Young Yang (7)** | ⚊ | Unchanging Yang | 31.25% (10/32) | **28.87%** | **28.95%** (11/38) | **< 0.08%** |
| **Old Yang (9)** | ⚊ ○ | Changing Yang → Yin | 18.75% (6/32) | **21.12%** | **21.05%** (8/38) | **< 0.07%** |
| **Old Yin (6)** | ⚋ ✕ | Changing Yin → Yang | 6.25% (2/32) | **5.17%** | **5.26%** (2/38) | **< 0.09%** |

---

## Features

- **Two Authentic Divination Methods**:
  - **🔮 38 Marbles Pouch**: Rapid blind draw simulating physical stalks with < 0.09% error.
  - **🌿 49 Yarrow Stalks**: Full 3-pass ritual sorting (1 stalk set aside for Taiji, 49 divided between Heaven and Earth, counted off in 4s).
- **Segmented 3-Phase Navigation**:
  - **☯ Chamber**: Step-by-step bottom-up line casting (Line 1 Earth → Line 6 Heaven) with lower and upper trigram illumination.
  - **📖 Reading**: Complete King Wen presentation of both Primary and Relating (transformed) hexagrams with Judgment, Image, and changing line details.
  - **ℹ Lore & Math**: Built-in historical guide explaining Zhu Xi, Gardner (1974), and Kennedy (2006).
- **Sincere Inquiry Card**: Frame your query and hold single-minded intent throughout the casting.
- **Desktop Clipboard Export**: Format a full, beautiful Markdown consultation log with one click (`📋 Copy`).
- **Zero External Dependencies**: Pure QML / QtQuick / Quickshell running natively in Omarchy.

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

## License

MIT License. Copyright (c) 2026 Matthew Hudson.
