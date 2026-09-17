import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "IChingData.js" as IChingData

Panel {
  id: root

  moduleName: "io.github.layolayo.iching-oracle"
  ipcTarget: "io.github.layolayo.iching-oracle"
  manageIpc: false

  property string method: "marbles" // "marbles" (38 marbles) or "yarrow"
  property string activeTab: "chamber" // "chamber", "reading", "lore"
  property string readingStage: "present" // "present", "lines", "future"
  property string hexAspect: "judgment" // "judgment", "image", "structure"
  property string loreSection: "ritual" // "ritual", "math", "nuclear", "protocol", "wilhelm"
  property var castLines: []
  property var consultation: null
  property var latestLine: null
  property string copyStatusMessage: ""
  property string inquiryText: ""

  readonly property var lowerTrigramData: castLines.length >= 3 ? IChingData.resolveTrigram([castLines[0], castLines[1], castLines[2]]) : null
  readonly property var upperTrigramData: castLines.length >= 6 ? IChingData.resolveTrigram([castLines[3], castLines[4], castLines[5]]) : null

  readonly property string currentGlyph: consultation && consultation.primary ? consultation.primary.unicode : "☯"
  readonly property color foreground: bar ? bar.foreground : Color.popups.text
  readonly property color background: bar ? bar.background : Color.popups.background
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property color accentColor: Color.accent
  readonly property color changingLineColor: "#f59e0b"
  readonly property color mutedColor: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.6)

  function toggleMethod() {
    if (method === "marbles") {
      method = "yarrow"
    } else {
      method = "marbles"
    }
    if (castLines.length === 0) {
      resetConsultation()
    }
  }

  function methodLabel() {
    if (method === "yarrow") return "🌿 49 Yarrow Stalks"
    return "🔮 38 Marbles (Kennedy's Revised)"
  }

  function castNextLine() {
    if (castLines.length >= 6) return
    var nextNum = castLines.length + 1
    var line = IChingData.castSingleLine(nextNum, root.method)
    var next = []
    for (var i = 0; i < castLines.length; i++) {
      next.push(castLines[i])
    }
    next.push(line)
    castLines = next
    latestLine = line
    copyStatusMessage = ""

    if (castLines.length === 6) {
      consultation = IChingData.resolveConsultation(castLines)
      readingStage = "present"
      hexAspect = "judgment"
      activeTab = "reading"
    }
  }

  function castAllLines() {
    while (castLines.length < 6) {
      castNextLine()
    }
  }

  function resetConsultation() {
    castLines = []
    consultation = null
    latestLine = null
    copyStatusMessage = ""
    inquiryText = ""
    readingStage = "present"
    hexAspect = "judgment"
    activeTab = "chamber"
  }

  function copyReading() {
    if (!consultation || !consultation.primary) return
    var p = consultation.primary
    var methodLabel = (root.method === "yarrow")
      ? "Authentic 50 Yarrow Stalks Method"
      : "38 Marbles Pouch (Andrew Kennedy's Revised Yarrow Algorithm)"
    var text = "☯ I-Ching Oracle Reading (" + methodLabel + ") ☯\n"
    text += "Translation & Commentary: Richard Wilhelm / Cary F. Baynes (Princeton University Press)\n\n"
    if (root.inquiryText.trim() !== "") {
      text += "Inquiry: \"" + root.inquiryText.trim() + "\"\n\n"
    }
    text += "Primary Hexagram: #" + p.number + " " + p.chinese + " (" + p.pinyin + ") — " + p.english + " " + p.unicode + "\n"
    text += "Trigrams: " + p.upperTrigram.name + " (" + p.upperTrigram.symbol + ") above " + p.lowerTrigram.name + " (" + p.lowerTrigram.symbol + ")\n"
    if (p.structureCommentary) {
      text += "\nTrigram Dynamics & Structural Analysis:\n" + p.structureCommentary + "\n"
    }
    text += "\nThe Judgment:\n" + p.judgment + "\n"
    if (p.judgmentCommentary) {
      text += "\nWilhelm Commentary on the Judgment:\n" + p.judgmentCommentary + "\n"
    }
    text += "\nThe Image:\n" + p.image + "\n"
    if (p.imageCommentary) {
      text += "\nWilhelm Commentary on the Image:\n" + p.imageCommentary + "\n"
    }
    if (p.nuclear) {
      var pGateName = p.nuclear.rootGate ? (" · " + p.nuclear.rootGate.name) : ""
      text += "\nNuclear Hexagram (Hidden Core · 互卦" + pGateName + "): #" + p.nuclear.hexagram.number + " " + p.nuclear.hexagram.chinese + " (" + p.nuclear.hexagram.pinyin + ") — " + p.nuclear.hexagram.english + " " + p.nuclear.hexagram.unicode + "\n"
      text += "Nuclear Trigrams: " + p.nuclear.upperTrigram.name + " (" + p.nuclear.upperTrigram.symbol + ") above " + p.nuclear.lowerTrigram.name + " (" + p.nuclear.lowerTrigram.symbol + ")\n"
      text += "Nuclear Judgment: " + p.nuclear.hexagram.judgment + "\n"
    }
    text += "\n"

    if (consultation.hasChangingLines) {
      var changingStr = ""
      for (var k = 0; k < consultation.changingLines.length; k++) {
        if (k > 0) changingStr += ", "
        changingStr += "Line " + consultation.changingLines[k]
      }
      text += "Changing Lines: " + changingStr + "\n\n"

      if (consultation.changingLineDetails && consultation.changingLineDetails.length > 0) {
        text += "The Lines (Operative Counsel):\n"
        for (var cd = 0; cd < consultation.changingLineDetails.length; cd++) {
          var cld = consultation.changingLineDetails[cd]
          text += "  Line " + cld.line + " — " + cld.name + ":\n"
          text += "  \"" + cld.text.replace(/\n/g, " ") + "\"\n"
          if (cld.comments) {
            text += "  Commentary: " + cld.comments.replace(/\n/g, " ") + "\n"
          }
          text += "\n"
        }
      }

      if (consultation.transformed) {
        var t = consultation.transformed
        text += "Relating Hexagram (Future): #" + t.number + " " + t.chinese + " (" + t.pinyin + ") — " + t.english + " " + t.unicode + "\n"
        text += "Trigrams: " + t.upperTrigram.name + " (" + t.upperTrigram.symbol + ") above " + t.lowerTrigram.name + " (" + t.lowerTrigram.symbol + ")\n"
        if (t.structureCommentary) {
          text += "\nTrigram Dynamics & Structural Analysis:\n" + t.structureCommentary + "\n"
        }
        text += "\nThe Judgment:\n" + t.judgment + "\n"
        if (t.judgmentCommentary) {
          text += "\nWilhelm Commentary on the Judgment:\n" + t.judgmentCommentary + "\n"
        }
        text += "\nThe Image:\n" + t.image + "\n"
        if (t.imageCommentary) {
          text += "\nWilhelm Commentary on the Image:\n" + t.imageCommentary + "\n"
        }
        if (consultation.nuclearTransition) {
          text += "\nInterior Core Transition (" + consultation.nuclearTransition.badge + "):\n"
          text += consultation.nuclearTransition.headline + "\n"
          text += consultation.nuclearTransition.description + "\n"
        }
        if (t.nuclear) {
          var tGateName = t.nuclear.rootGate ? (" · " + t.nuclear.rootGate.name) : ""
          text += "\nRelating Nuclear Hexagram (Hidden Core · 互卦" + tGateName + "): #" + t.nuclear.hexagram.number + " " + t.nuclear.hexagram.chinese + " (" + t.nuclear.hexagram.pinyin + ") — " + t.nuclear.hexagram.english + " " + t.nuclear.hexagram.unicode + "\n"
          text += "Nuclear Trigrams: " + t.nuclear.upperTrigram.name + " (" + t.nuclear.upperTrigram.symbol + ") above " + t.nuclear.lowerTrigram.name + " (" + t.nuclear.lowerTrigram.symbol + ")\n"
          text += "Nuclear Judgment: " + t.nuclear.hexagram.judgment + "\n"
        }
        text += "\n"
      }
    }

    text += "Lines Cast (Bottom Line 1 to Top Line 6):\n"
    for (var j = 0; j < castLines.length; j++) {
      var l = castLines[j]
      text += "  Line " + l.lineNumber + ": " + l.title + " [" + l.symbol + "] — " + l.description + "\n"
    }

    Quickshell.execDetached(["bash", "-c", "printf %s " + Util.shellQuote(text) + " | wl-copy"])
    copyStatusMessage = "Reading copied to clipboard!"
  }

  function getLineAt(index) {
    if (index >= 0 && index < castLines.length) {
      return castLines[index]
    }
    return null
  }

  function getLoreSectionTitle() {
    for (var i = 0; i < IChingData.LORE_SECTIONS.length; i++) {
      if (IChingData.LORE_SECTIONS[i].id === root.loreSection) {
        return IChingData.LORE_SECTIONS[i].title
      }
    }
    return IChingData.LORE_SECTIONS[0].title
  }

  function getLoreSectionSubtitle() {
    for (var i = 0; i < IChingData.LORE_SECTIONS.length; i++) {
      if (IChingData.LORE_SECTIONS[i].id === root.loreSection) {
        return IChingData.LORE_SECTIONS[i].subtitle
      }
    }
    return IChingData.LORE_SECTIONS[0].subtitle
  }

  function getLoreSectionParagraphs() {
    for (var i = 0; i < IChingData.LORE_SECTIONS.length; i++) {
      if (IChingData.LORE_SECTIONS[i].id === root.loreSection) {
        return IChingData.LORE_SECTIONS[i].paragraphs
      }
    }
    return IChingData.LORE_SECTIONS[0].paragraphs
  }

  IpcHandler {
    target: root.ipcTarget

    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function cast(): void { root.castNextLine() }
    function castAll(): void { root.castAllLines() }
    function reset(): void { root.resetConsultation() }
    function setMethod(m: string): void { if (m === "marbles" || m === "marbles32" || m === "marbles38" || m === "yarrow") root.method = (m === "yarrow" ? "yarrow" : "marbles") }
  }

  component HexagramLineRow: Item {
    id: lineRow
    required property int lineIndex
    readonly property var lineData: root.getLineAt(lineIndex)
    readonly property int displayLineNumber: lineIndex + 1

    width: parent ? parent.width : 0
    implicitHeight: Style.space(24)

    Text {
      id: lineLabel
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: lineRow.lineIndex === 5 ? "6 (Top)" : (lineRow.lineIndex === 0 ? "1 (Base)" : String(lineRow.displayLineNumber))
      color: lineRow.lineData ? root.foreground : root.mutedColor
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: !!lineRow.lineData
      width: Style.space(55)
    }

    Item {
      anchors.left: lineLabel.right
      anchors.right: lineBadge.left
      anchors.leftMargin: Style.space(8)
      anchors.rightMargin: Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
      height: Style.space(12)

      // Placeholder outline when uncast
      Rectangle {
        anchors.fill: parent
        visible: !lineRow.lineData
        radius: height / 2
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.16)
      }

      // Solid Yang Line (7 or 9)
      Rectangle {
        anchors.fill: parent
        visible: !!lineRow.lineData && (lineRow.lineData.value === 7 || lineRow.lineData.value === 9)
        radius: height / 2
        color: lineRow.lineData && lineRow.lineData.isChanging ? root.changingLineColor : root.accentColor

        // Prominent High-Contrast Center Dot Marker for Old Yang (9)
        Item {
          anchors.centerIn: parent
          width: Style.space(16)
          height: Style.space(16)
          visible: lineRow.lineData && lineRow.lineData.value === 9

          // Dark contrasting circular pill cutout
          Rectangle {
            anchors.centerIn: parent
            width: Style.space(16)
            height: Style.space(16)
            radius: width / 2
            color: "#0f172a"
            border.width: 1.5
            border.color: "#ffffff"
          }

          // Solid bright white center dot
          Rectangle {
            anchors.centerIn: parent
            width: Style.space(6)
            height: Style.space(6)
            radius: width / 2
            color: "#ffffff"
          }
        }
      }

      // Broken Yin Line (6 or 8)
      Item {
        anchors.fill: parent
        visible: !!lineRow.lineData && (lineRow.lineData.value === 6 || lineRow.lineData.value === 8)

        Rectangle {
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          width: (parent.width - Style.space(24)) / 2
          radius: height / 2
          color: lineRow.lineData && lineRow.lineData.isChanging ? root.changingLineColor : root.accentColor
        }

        // Prominent High-Contrast Center Cross for Old Yin (6)
        Item {
          anchors.centerIn: parent
          width: Style.space(16)
          height: Style.space(16)
          visible: lineRow.lineData && lineRow.lineData.value === 6

          Rectangle {
            anchors.centerIn: parent
            width: Style.space(16)
            height: Style.space(16)
            radius: width / 2
            color: "#0f172a"
            border.width: 1.5
            border.color: root.changingLineColor

            Text {
              anchors.centerIn: parent
              text: "✕"
              color: "#ffffff"
              font.pixelSize: Style.space(10)
              font.bold: true
            }
          }
        }

        Rectangle {
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          width: (parent.width - Style.space(24)) / 2
          radius: height / 2
          color: lineRow.lineData && lineRow.lineData.isChanging ? root.changingLineColor : root.accentColor
        }
      }
    }

    Text {
      id: lineBadge
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      text: lineRow.lineData ? lineRow.lineData.title : "—"
      color: lineRow.lineData && lineRow.lineData.isChanging ? root.changingLineColor : (lineRow.lineData ? root.foreground : root.mutedColor)
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: lineRow.lineData && lineRow.lineData.isChanging
      horizontalAlignment: Text.AlignRight
      width: Style.space(110)
    }
  }

  implicitWidth: barButton.implicitWidth
  implicitHeight: barButton.implicitHeight

  BarIconButton {
    id: barButton
    anchors.fill: parent
    bar: root.bar
    text: root.currentGlyph
    fontSize: Style.bar.iconFont + 2
    tooltipText: root.consultation && root.consultation.primary
      ? ("I-Ching: #" + root.consultation.primary.number + " " + root.consultation.primary.english)
      : "I-Ching Oracle"
    onPressed: function(button) { root.toggle() }
  }

  KeyboardPanel {
    id: panel
    anchorItem: barButton
    owner: root
    bar: root.bar
    open: root.opened
    centerOnBar: false
    contentWidth: Style.space(510)
    contentHeight: panel.fittedContentHeight(scrollContent.implicitHeight + panel.padding * 2, Style.space(740))

    Controls.ScrollView {
      id: scrollArea
      anchors.fill: parent
      clip: true
      rightPadding: Style.space(16)
      Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
      Controls.ScrollBar.vertical.policy: scrollContent.implicitHeight > height
        ? Controls.ScrollBar.AsNeeded
        : Controls.ScrollBar.AlwaysOff

      Column {
        id: scrollContent
        width: scrollArea.availableWidth
        spacing: Style.space(12)

        // ----------------- Header -----------------
        Item {
          width: parent.width
          implicitHeight: Math.max(headerIcon.implicitHeight, headerTextCol.implicitHeight, headerActions.implicitHeight)

          Text {
            id: headerIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: root.currentGlyph
            font.pixelSize: Style.space(34)
            color: root.foreground
          }

          Column {
            id: headerTextCol
            anchors.left: headerIcon.right
            anchors.leftMargin: Style.space(12)
            anchors.right: headerActions.left
            anchors.rightMargin: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              width: parent.width
              text: "I-Ching Oracle · 易經"
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.heading
              font.bold: true
              elide: Text.ElideRight
            }

            Text {
              width: parent.width
              text: root.activeTab === "reading"
                ? "Oracle Reading & Contemplation"
                : (root.activeTab === "lore"
                  ? "Origin, Mathematics & Protocol"
                  : (root.method === "yarrow"
                    ? "Authentic 50 Yarrow Stalks (大衍筮法)"
                    : "38 Marbles Pouch (Andrew Kennedy's Revised Yarrow Algorithm)"))
              color: root.mutedColor
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              elide: Text.ElideRight
            }
          }

          Row {
            id: headerActions
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(6)

            Button {
              text: "↺"
              tooltipText: "Reset Consultation"
              visible: root.castLines.length > 0
              onClicked: root.resetConsultation()
            }
          }
        }

        // ----------------- Segmented Tab Navigation -----------------
        Row {
          width: parent.width
          spacing: Style.space(6)

          Button {
            width: (parent.width - Style.space(12)) / 3
            implicitHeight: Style.space(30)
            text: root.castLines.length > 0 ? ("☯ Chamber " + root.castLines.length + "/6") : "☯ Chamber"
            bordered: true
            selected: root.activeTab === "chamber"
            accent: root.accentColor
            onClicked: root.activeTab = "chamber"
          }

          Button {
            width: (parent.width - Style.space(12)) / 3
            implicitHeight: Style.space(30)
            text: root.consultation ? "📖 Reading ✨" : "📖 Reading"
            bordered: true
            selected: root.activeTab === "reading"
            accent: root.accentColor
            onClicked: root.activeTab = "reading"
          }

          Button {
            width: (parent.width - Style.space(12)) / 3
            implicitHeight: Style.space(30)
            text: "ℹ Lore & Math"
            bordered: true
            selected: root.activeTab === "lore"
            accent: root.accentColor
            onClicked: root.activeTab = "lore"
          }
        }

        // ----------------- Method Selector (2 Options: 38 Marbles & 49 Stalks) -----------------
        Row {
          width: parent.width
          visible: root.activeTab === "chamber"
          spacing: Style.space(8)

          Button {
            width: (parent.width - Style.space(8)) * 0.5
            text: "🔮 38 Marbles Pouch"
            bordered: true
            selected: root.method !== "yarrow"
            accent: root.accentColor
            onClicked: {
              root.method = "marbles"
              if (root.castLines.length === 0) root.resetConsultation()
            }
          }

          Button {
            width: (parent.width - Style.space(8)) * 0.5
            text: "🌿 49 Yarrow Stalks"
            bordered: true
            selected: root.method === "yarrow"
            accent: root.accentColor
            onClicked: {
              root.method = "yarrow"
              if (root.castLines.length === 0) root.resetConsultation()
            }
          }
        }

        // Status Banner
        BorderSurface {
          width: parent.width
          visible: root.activeTab === "chamber"
          implicitHeight: Style.space(30)
          color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.05)
          radius: Style.cornerRadius
          borderSpec: Border.flat(Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.12), 1)

          Text {
            anchors.centerIn: parent
            text: root.castLines.length === 0
              ? (root.method === "yarrow"
                ? "Ready (49 Stalks Prepared)"
                : "Ready (38 Marbles in Sacred Pouch)")
              : (root.castLines.length === 6
                ? "✨ Complete"
                : "Line " + (root.castLines.length + 1) + " of 6 (Bottom Up)")
            color: root.castLines.length === 6 ? root.accentColor : root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            font.bold: true
          }
        }

        // ----------------- Sincere Inquiry & Focus of Intent -----------------
        BorderSurface {
          width: parent.width
          visible: root.activeTab === "chamber"
          implicitHeight: inquiryCol.implicitHeight + Style.space(14)
          color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.04)
          radius: Style.cornerRadius
          borderSpec: Border.flat(Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.22), 1)

          Column {
            id: inquiryCol
            width: parent.width - Style.space(20)
            anchors.centerIn: parent
            spacing: Style.space(5)

            Row {
              width: parent.width
              spacing: Style.space(6)
              Text {
                text: "☯ Sincere Inquiry (問道 · Focus of Intent)"
                color: root.accentColor
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
              }
              Text {
                visible: root.castLines.length > 0
                text: "🔒 (Locked)"
                color: root.mutedColor
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }
            }

            TextField {
              id: questionInputField
              width: parent.width
              readOnly: root.castLines.length > 0
              placeholderText: root.castLines.length === 0
                ? "Formulate your question & hold it in mind throughout..."
                : "(Silent contemplation · Focus of intent)"
              text: root.inquiryText
              font.pixelSize: Style.font.caption
              onTextChanged: {
                if (root.castLines.length === 0) {
                  root.inquiryText = text
                }
              }
            }

            Text {
              width: parent.width
              text: root.castLines.length === 6
                ? "Consultation complete. Reflect deeply upon the Judgment and Image in relation to your inquiry."
                : "The classics teach: quiet your mind, formulate what you seek counsel on, and hold it firmly in thought through all six draws."
              color: root.mutedColor
              font.family: root.fontFamily
              font.pixelSize: Style.space(11)
              wrapMode: Text.WordWrap
            }
          }
        }

        // ----------------- Visual Hexagram Chamber (Bottom-Up) -----------------
        BorderSurface {
          width: parent.width
          visible: root.activeTab === "chamber"
          implicitHeight: chamberCol.implicitHeight + Style.space(20)
          color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.04)
          radius: Style.cornerRadius
          borderSpec: Border.flat(Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.15), 1)

          Column {
            id: chamberCol
            width: parent.width - Style.space(24)
            anchors.centerIn: parent
            spacing: Style.space(8)

            // Upper Trigram Header
            Row {
              width: parent.width
              spacing: Style.space(6)
              Text {
                text: "Upper Trigram (Lines 4–6)"
                color: root.mutedColor
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
              }
              Text {
                visible: !!root.upperTrigramData && !!root.upperTrigramData.primary
                text: root.upperTrigramData && root.upperTrigramData.primary ? ("— " + root.upperTrigramData.primary.symbol + " " + root.upperTrigramData.primary.name + " (" + root.upperTrigramData.primary.chinese + ") · " + root.upperTrigramData.primary.element) : ""
                color: root.accentColor
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
              }
              Text {
                visible: !!root.upperTrigramData && root.upperTrigramData.hasChanging && !!root.upperTrigramData.transformed
                text: root.upperTrigramData && root.upperTrigramData.transformed ? ("➔ " + root.upperTrigramData.transformed.symbol + " " + root.upperTrigramData.transformed.name) : ""
                color: root.changingLineColor
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
              }
            }

            // Lines 6, 5, 4
            Repeater {
              model: [5, 4, 3]
              delegate: HexagramLineRow {
                required property int modelData
                lineIndex: modelData
              }
            }

            // Divider
            Item {
              width: parent.width
              implicitHeight: Style.space(10)
              Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.15)
              }
            }

            // Lower Trigram Header
            Row {
              width: parent.width
              spacing: Style.space(6)
              Text {
                text: "Lower Trigram (Lines 1–3)"
                color: root.mutedColor
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
              }
              Text {
                visible: !!root.lowerTrigramData && !!root.lowerTrigramData.primary
                text: root.lowerTrigramData && root.lowerTrigramData.primary ? ("— " + root.lowerTrigramData.primary.symbol + " " + root.lowerTrigramData.primary.name + " (" + root.lowerTrigramData.primary.chinese + ") · " + root.lowerTrigramData.primary.element) : ""
                color: root.accentColor
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
              }
              Text {
                visible: !!root.lowerTrigramData && root.lowerTrigramData.hasChanging && !!root.lowerTrigramData.transformed
                text: root.lowerTrigramData && root.lowerTrigramData.transformed ? ("➔ " + root.lowerTrigramData.transformed.symbol + " " + root.lowerTrigramData.transformed.name) : ""
                color: root.changingLineColor
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
              }
            }

            // Lines 3, 2, 1
            Repeater {
              model: [2, 1, 0]
              delegate: HexagramLineRow {
                required property int modelData
                lineIndex: modelData
              }
            }
          }
        }

        // ----------------- Action Buttons -----------------
        Row {
          width: parent.width
          visible: root.activeTab === "chamber"
          spacing: Style.space(8)

          Button {
            id: castLineBtn
            visible: root.castLines.length < 6
            width: (parent.width - Style.space(8)) * 0.65
            text: ((root.method !== "yarrow") ? "Draw Marble " : "Cast Line ") + (root.castLines.length + 1) + " (Bottom Up)"
            iconText: (root.method !== "yarrow") ? "🔮" : "🌿"
            accent: root.accentColor
            bordered: true
            onClicked: root.castNextLine()
          }

          Button {
            id: castAllBtn
            visible: root.castLines.length < 6
            width: (parent.width - Style.space(8)) * 0.35
            text: "Cast All"
            iconText: "⚡"
            onClicked: root.castAllLines()
          }

          Button {
            id: viewReadingBtn
            visible: root.castLines.length === 6
            width: (parent.width - Style.space(16)) * 0.44
            text: "View Reading ➔"
            iconText: "📖"
            accent: root.accentColor
            bordered: true
            onClicked: root.activeTab = "reading"
          }

          Button {
            id: newConsultationBtn
            visible: root.castLines.length === 6
            width: (parent.width - Style.space(16)) * 0.26
            text: "Reset"
            iconText: "↺"
            onClicked: root.resetConsultation()
          }

          Button {
            id: copyReadingBtn
            visible: root.castLines.length === 6
            width: (parent.width - Style.space(16)) * 0.3
            text: root.copyStatusMessage !== "" ? root.copyStatusMessage : "Copy"
            iconText: "📋"
            onClicked: root.copyReading()
          }
        }

        // Copy Status Toast
        Text {
          visible: root.copyStatusMessage !== ""
          width: parent.width
          text: root.copyStatusMessage
          color: root.accentColor
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          horizontalAlignment: Text.AlignHCenter
        }

        // ----------------- Stalk / Marble Division Tray -----------------
        BorderSurface {
          width: parent.width
          visible: root.activeTab === "chamber" && !!root.latestLine
          implicitHeight: detailsCol.implicitHeight + Style.space(14)
          color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.03)
          radius: Style.cornerRadius
          borderSpec: Border.flat(Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.08), 1)

          Column {
            id: detailsCol
            width: parent.width - Style.space(20)
            anchors.centerIn: parent
            spacing: Style.space(4)

            Text {
              text: root.latestLine && (root.latestLine.method !== "yarrow")
                ? ("🔮 Pouch Draw (Line " + root.latestLine.lineNumber + " · " + root.latestLine.title + "):")
                : ("🌿 Yarrow Stalk Division (Line " + (root.latestLine ? root.latestLine.lineNumber : "") + "):")
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
            }

            Text {
              width: parent.width
              text: root.latestLine ? (
                (root.latestLine.method !== "yarrow") && root.latestLine.marble ? (
                  "Drawn Marble: " + root.latestLine.marble.name + " (" + root.latestLine.marble.totalInBag + " of 38 in pouch · " + root.latestLine.marble.probPct + ")\n" +
                  "Yields: " + root.latestLine.title + " — " + root.latestLine.description
                ) : (
                  "Pass 1 (49 stalks): Hand remainder = " + root.latestLine.passes[0].hand + " → Value " + root.latestLine.passes[0].count + "\n" +
                  "Pass 2 (" + root.latestLine.passes[0].stalksLeft + " stalks): Hand remainder = " + root.latestLine.passes[1].hand + " → Value " + root.latestLine.passes[1].count + "\n" +
                  "Pass 3 (" + root.latestLine.passes[1].stalksLeft + " stalks): Hand remainder = " + root.latestLine.passes[2].hand + " → Value " + root.latestLine.passes[2].count + "\n" +
                  "Total: " + root.latestLine.passes[0].count + " + " + root.latestLine.passes[1].count + " + " + root.latestLine.passes[2].count + " = " + root.latestLine.value + " (" + root.latestLine.title + ")"
                )
              ) : ""
              color: root.mutedColor
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              lineHeight: 1.2
            }
          }
        }

        // ----------------- Empty Reading Notice -----------------
        BorderSurface {
          width: parent.width
          visible: root.activeTab === "reading" && !root.consultation
          implicitHeight: emptyReadingCol.implicitHeight + Style.space(32)
          color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.04)
          radius: Style.cornerRadius
          borderSpec: Border.flat(Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.12), 1)

          Column {
            id: emptyReadingCol
            width: parent.width - Style.space(32)
            anchors.centerIn: parent
            spacing: Style.space(10)

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: "☯"
              font.pixelSize: Style.space(42)
              color: root.accentColor
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: "Oracle Awaiting Consultation"
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.heading
              font.bold: true
            }

            Text {
              width: parent.width
              horizontalAlignment: Text.AlignHCenter
              text: "Formulate your inquiry and cast all six lines from the bottom up in the Chamber to reveal the primary hexagram, relating hexagram, judgment, and image."
              color: root.mutedColor
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              wrapMode: Text.WordWrap
            }

            Button {
              anchors.horizontalCenter: parent.horizontalCenter
              text: "➔ Open Chamber"
              accent: root.accentColor
              bordered: true
              onClicked: root.activeTab = "chamber"
            }
          }
        }

        // ----------------- Reading Actions / Inquiry Header -----------------
        BorderSurface {
          width: parent.width
          visible: root.activeTab === "reading" && !!root.consultation
          implicitHeight: readingHeaderCol.implicitHeight + Style.space(18)
          color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.04)
          radius: Style.cornerRadius
          borderSpec: Border.flat(Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.12), 1)

          Column {
            id: readingHeaderCol
            width: parent.width - Style.space(20)
            anchors.centerIn: parent
            spacing: Style.space(8)

            Text {
              visible: root.inquiryText.trim() !== ""
              width: parent.width
              text: "“" + root.inquiryText.trim() + "”"
              color: root.accentColor
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              font.bold: true
              font.italic: true
              wrapMode: Text.WordWrap
            }

            Row {
              width: parent.width
              spacing: Style.space(6)

              Button {
                width: (parent.width - Style.space(12)) * 0.35
                text: "↺ New"
                tooltipText: "New Consultation"
                onClicked: root.resetConsultation()
              }

              Button {
                width: (parent.width - Style.space(12)) * 0.35
                text: root.copyStatusMessage !== "" ? root.copyStatusMessage : "📋 Copy"
                accent: root.accentColor
                bordered: true
                onClicked: root.copyReading()
              }

              Button {
                width: (parent.width - Style.space(12)) * 0.3
                text: "← Chamber"
                tooltipText: "Review Line History & Math"
                onClicked: root.activeTab = "chamber"
              }
            }
          }
        }

        // ----------------- Reading Stage Switcher Bar (Present / Lines / Future) -----------------
        Row {
          width: parent.width
          visible: root.activeTab === "reading" && root.castLines.length === 6 && root.consultation && root.consultation.hasChangingLines
          spacing: Style.space(6)

          Button {
            width: (parent.width - Style.space(12)) / 3
            implicitHeight: Style.space(32)
            text: root.consultation && root.consultation.primary ? ("☯ Present (#" + root.consultation.primary.number + ")") : "☯ Present"
            bordered: true
            selected: root.readingStage === "present"
            accent: root.accentColor
            onClicked: root.readingStage = "present"
          }

          Button {
            width: (parent.width - Style.space(12)) / 3
            implicitHeight: Style.space(32)
            text: root.consultation ? ("⚡ Lines (" + root.consultation.changingLines.length + ")") : "⚡ Lines"
            bordered: true
            selected: root.readingStage === "lines"
            accent: root.changingLineColor
            onClicked: root.readingStage = "lines"
          }

          Button {
            width: (parent.width - Style.space(12)) / 3
            implicitHeight: Style.space(32)
            text: root.consultation && root.consultation.transformed ? ("➔ Future (#" + root.consultation.transformed.number + ")") : "➔ Future"
            bordered: true
            selected: root.readingStage === "future"
            accent: root.changingLineColor
            onClicked: root.readingStage = "future"
          }
        }

        // ----------------- Primary Hexagram Card (Present) -----------------
        BorderSurface {
          width: parent.width
          visible: root.activeTab === "reading" && root.castLines.length === 6 && root.consultation && !!root.consultation.primary && (!root.consultation.hasChangingLines || root.readingStage === "present")
          implicitHeight: Math.max(primaryResultCol.implicitHeight + Style.space(24), Style.space(380))
          color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.07)
          radius: Style.cornerRadius
          borderSpec: Border.flat(Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.35), 1)

          Column {
            id: primaryResultCol
            width: parent.width - Style.space(24)
            anchors.centerIn: parent
            spacing: Style.space(12)

            Row {
              width: parent.width
              spacing: Style.space(14)

              Text {
                id: hexGlyphLarge
                anchors.verticalCenter: parent.verticalCenter
                text: root.consultation && root.consultation.primary ? root.consultation.primary.unicode : ""
                font.pixelSize: Style.space(52)
                color: root.accentColor
              }

              Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - hexGlyphLarge.implicitWidth - Style.space(14)
                spacing: Style.space(2)

                Text {
                  width: parent.width
                  text: root.consultation && root.consultation.primary
                    ? ("#" + root.consultation.primary.number + " · " + root.consultation.primary.chinese + " · " + root.consultation.primary.english)
                    : ""
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.heading
                  font.bold: true
                  wrapMode: Text.WordWrap
                }

                Text {
                  width: parent.width
                  text: root.consultation && root.consultation.primary
                    ? ("Primary Hexagram (本卦 · Present) · " + root.consultation.primary.pinyin)
                    : ""
                  color: root.mutedColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                }

                Text {
                  width: parent.width
                  text: root.consultation && root.consultation.primary
                    ? (root.consultation.primary.upperTrigram.symbol + " " + root.consultation.primary.upperTrigram.name + " (" + root.consultation.primary.upperTrigram.element + ") over " +
                       root.consultation.primary.lowerTrigram.symbol + " " + root.consultation.primary.lowerTrigram.name + " (" + root.consultation.primary.lowerTrigram.element + ")")
                    : ""
                  color: root.accentColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  wrapMode: Text.WordWrap
                }
              }
            }

            // Aspect Switcher Tabs: Judgment / Image / Trigrams
            Row {
              width: parent.width
              spacing: Style.space(6)

              Button {
                width: (parent.width - Style.space(12)) / 3
                implicitHeight: Style.space(30)
                text: "📜 Judgment"
                bordered: true
                selected: root.hexAspect === "judgment"
                accent: root.accentColor
                onClicked: root.hexAspect = "judgment"
              }

              Button {
                width: (parent.width - Style.space(12)) / 3
                implicitHeight: Style.space(30)
                text: "🌊 Image"
                bordered: true
                selected: root.hexAspect === "image"
                accent: root.accentColor
                onClicked: root.hexAspect = "image"
              }

              Button {
                width: (parent.width - Style.space(12)) / 3
                implicitHeight: Style.space(30)
                text: "☯ Trigrams"
                bordered: true
                selected: root.hexAspect === "structure"
                accent: root.accentColor
                onClicked: root.hexAspect = "structure"
              }
            }

            // --- Aspect Content: Judgment ---
            Column {
              width: parent.width
              visible: root.hexAspect === "judgment"
              spacing: Style.space(8)

              Column {
                width: parent.width
                spacing: Style.space(3)

                Text {
                  text: "The Judgment (彖辭 · Tuàn Cí)"
                  color: root.accentColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  font.bold: true
                }

                Text {
                  width: parent.width
                  text: root.consultation && root.consultation.primary ? root.consultation.primary.judgment : ""
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  lineHeight: 1.35
                  wrapMode: Text.WordWrap
                }
              }

              // Wilhelm Commentary on Judgment
              Column {
                width: parent.width
                visible: !!(root.consultation && root.consultation.primary && root.consultation.primary.judgmentCommentary)
                spacing: Style.space(4)

                Text {
                  text: "📖 Wilhelm Commentary on the Judgment"
                  color: root.mutedColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                }

                BorderSurface {
                  width: parent.width
                  implicitHeight: pJudgComText.implicitHeight + Style.space(16)
                  color: Qt.rgba(0, 0, 0, 0.22)
                  radius: Style.cornerRadius
                  borderSpec: Border.flat(Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.2), 1)

                  Text {
                    id: pJudgComText
                    width: parent.width - Style.space(16)
                    anchors.centerIn: parent
                    text: root.consultation && root.consultation.primary ? (root.consultation.primary.judgmentCommentary || "") : ""
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    lineHeight: 1.35
                    wrapMode: Text.WordWrap
                  }
                }
              }
            }

            // --- Aspect Content: Image ---
            Column {
              width: parent.width
              visible: root.hexAspect === "image"
              spacing: Style.space(8)

              Column {
                width: parent.width
                spacing: Style.space(3)

                Text {
                  text: "The Image (大象 · Dà Xiàng)"
                  color: root.accentColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  font.bold: true
                }

                Text {
                  width: parent.width
                  text: root.consultation && root.consultation.primary ? root.consultation.primary.image : ""
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  lineHeight: 1.35
                  wrapMode: Text.WordWrap
                }
              }

              // Wilhelm Commentary on Image
              Column {
                width: parent.width
                visible: !!(root.consultation && root.consultation.primary && root.consultation.primary.imageCommentary)
                spacing: Style.space(4)

                Text {
                  text: "🌊 Wilhelm Commentary on the Image"
                  color: root.mutedColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                }

                BorderSurface {
                  width: parent.width
                  implicitHeight: pImgComText.implicitHeight + Style.space(16)
                  color: Qt.rgba(0, 0, 0, 0.22)
                  radius: Style.cornerRadius
                  borderSpec: Border.flat(Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.2), 1)

                  Text {
                    id: pImgComText
                    width: parent.width - Style.space(16)
                    anchors.centerIn: parent
                    text: root.consultation && root.consultation.primary ? (root.consultation.primary.imageCommentary || "") : ""
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    lineHeight: 1.35
                    wrapMode: Text.WordWrap
                  }
                }
              }
            }

            // --- Aspect Content: Trigrams & Structure ---
            Column {
              width: parent.width
              visible: root.hexAspect === "structure"
              spacing: Style.space(8)

              // Two side-by-side realm cards
              Row {
                width: parent.width
                spacing: Style.space(8)

                // Upper Trigram (Outer Realm)
                BorderSurface {
                  width: (parent.width - Style.space(8)) * 0.5
                  implicitHeight: Math.max(pUpperCol.implicitHeight, pLowerCol.implicitHeight) + Style.space(14)
                  color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.08)
                  radius: Style.cornerRadius
                  borderSpec: Border.flat(Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.35), 1)

                  Column {
                    id: pUpperCol
                    width: parent.width - Style.space(16)
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Style.space(7)
                    spacing: Style.space(4)

                    // Header Tag
                    Row {
                      spacing: Style.space(5)
                      Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: Style.space(6)
                        height: Style.space(6)
                        radius: Style.space(3)
                        color: root.accentColor
                      }
                      Text {
                        text: "Outer Realm · Lines 4–6"
                        color: root.accentColor
                        font.family: root.fontFamily
                        font.pixelSize: Style.space(11)
                        font.bold: true
                      }
                    }

                    // Glyph & Identity
                    Row {
                      width: parent.width
                      spacing: Style.space(8)

                      Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.consultation && root.consultation.primary ? root.consultation.primary.upperTrigram.symbol : ""
                        font.pixelSize: Style.space(32)
                        color: root.accentColor
                      }

                      Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - Style.space(40)
                        spacing: Style.space(1)

                        Text {
                          width: parent.width
                          text: root.consultation && root.consultation.primary
                            ? (root.consultation.primary.upperTrigram.name + " · " + root.consultation.primary.upperTrigram.chinese)
                            : ""
                          color: root.foreground
                          font.family: root.fontFamily
                          font.pixelSize: Style.space(12)
                          font.bold: true
                          wrapMode: Text.WordWrap
                        }

                        Text {
                          width: parent.width
                          text: root.consultation && root.consultation.primary
                            ? (root.consultation.primary.upperTrigram.pinyin + " · " + root.consultation.primary.upperTrigram.element)
                            : ""
                          color: root.accentColor
                          font.family: root.fontFamily
                          font.pixelSize: Style.space(11)
                          font.bold: true
                        }
                      }
                    }

                    Text {
                      width: parent.width
                      text: root.consultation && root.consultation.primary ? root.consultation.primary.upperTrigram.nature : ""
                      color: root.foreground
                      font.pixelSize: Style.space(11)
                      wrapMode: Text.WordWrap
                    }

                    Text {
                      width: parent.width
                      text: "Manifest action & outer conditions"
                      color: root.mutedColor
                      font.family: root.fontFamily
                      font.pixelSize: Style.space(10)
                      font.italic: true
                      wrapMode: Text.WordWrap
                    }
                  }
                }

                // Lower Trigram (Inner Realm)
                BorderSurface {
                  width: (parent.width - Style.space(8)) * 0.5
                  implicitHeight: Math.max(pUpperCol.implicitHeight, pLowerCol.implicitHeight) + Style.space(14)
                  color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.08)
                  radius: Style.cornerRadius
                  borderSpec: Border.flat(Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.35), 1)

                  Column {
                    id: pLowerCol
                    width: parent.width - Style.space(16)
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Style.space(7)
                    spacing: Style.space(4)

                    // Header Tag
                    Row {
                      spacing: Style.space(5)
                      Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: Style.space(6)
                        height: Style.space(6)
                        radius: Style.space(3)
                        color: root.accentColor
                      }
                      Text {
                        text: "Inner Realm · Lines 1–3"
                        color: root.accentColor
                        font.family: root.fontFamily
                        font.pixelSize: Style.space(11)
                        font.bold: true
                      }
                    }

                    // Glyph & Identity
                    Row {
                      width: parent.width
                      spacing: Style.space(8)

                      Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.consultation && root.consultation.primary ? root.consultation.primary.lowerTrigram.symbol : ""
                        font.pixelSize: Style.space(32)
                        color: root.accentColor
                      }

                      Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - Style.space(40)
                        spacing: Style.space(1)

                        Text {
                          width: parent.width
                          text: root.consultation && root.consultation.primary
                            ? (root.consultation.primary.lowerTrigram.name + " · " + root.consultation.primary.lowerTrigram.chinese)
                            : ""
                          color: root.foreground
                          font.family: root.fontFamily
                          font.pixelSize: Style.space(12)
                          font.bold: true
                          wrapMode: Text.WordWrap
                        }

                        Text {
                          width: parent.width
                          text: root.consultation && root.consultation.primary
                            ? (root.consultation.primary.lowerTrigram.pinyin + " · " + root.consultation.primary.lowerTrigram.element)
                            : ""
                          color: root.accentColor
                          font.family: root.fontFamily
                          font.pixelSize: Style.space(11)
                          font.bold: true
                        }
                      }
                    }

                    Text {
                      width: parent.width
                      text: root.consultation && root.consultation.primary ? root.consultation.primary.lowerTrigram.nature : ""
                      color: root.foreground
                      font.pixelSize: Style.space(11)
                      wrapMode: Text.WordWrap
                    }

                    Text {
                      width: parent.width
                      text: "Heart-mind & root conditions"
                      color: root.mutedColor
                      font.family: root.fontFamily
                      font.pixelSize: Style.space(10)
                      font.italic: true
                      wrapMode: Text.WordWrap
                    }
                  }
                }
              }

              // Nuclear Core (Hù Guà / 互卦)
              BorderSurface {
                width: parent.width
                implicitHeight: pNuclearCol.implicitHeight + Style.space(16)
                color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.05)
                radius: Style.cornerRadius
                borderSpec: Border.flat(Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.25), 1)

                Column {
                  id: pNuclearCol
                  width: parent.width - Style.space(20)
                  anchors.centerIn: parent
                  spacing: Style.space(5)

                  Row {
                    width: parent.width
                    spacing: Style.space(6)

                    Rectangle {
                      anchors.verticalCenter: parent.verticalCenter
                      width: Style.space(6)
                      height: Style.space(6)
                      radius: Style.space(3)
                      color: root.accentColor
                    }
                    Text {
                      anchors.verticalCenter: parent.verticalCenter
                      text: "Hidden Core · Nuclear Hexagram (互卦 · Hù Guà)"
                      color: root.accentColor
                      font.family: root.fontFamily
                      font.pixelSize: Style.space(11)
                      font.bold: true
                    }
                    BorderSurface {
                      anchors.verticalCenter: parent.verticalCenter
                      visible: !!(root.consultation && root.consultation.primary && root.consultation.primary.nuclear && root.consultation.primary.nuclear.rootGate)
                      implicitHeight: Style.space(18)
                      implicitWidth: pGateText.implicitWidth + Style.space(12)
                      radius: Style.space(4)
                      color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.12)
                      borderSpec: Border.flat(Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.35), 1)

                      Text {
                        id: pGateText
                        anchors.centerIn: parent
                        text: root.consultation && root.consultation.primary && root.consultation.primary.nuclear && root.consultation.primary.nuclear.rootGate
                          ? root.consultation.primary.nuclear.rootGate.name
                          : ""
                        color: root.accentColor
                        font.family: root.fontFamily
                        font.pixelSize: Style.space(9)
                        font.bold: true
                      }
                    }
                  }

                  Text {
                    width: parent.width
                    text: "Latent interior engine & psychological undercurrent gestating inside lines 2–5:"
                    color: root.mutedColor
                    font.family: root.fontFamily
                    font.pixelSize: Style.space(10)
                    font.italic: true
                    wrapMode: Text.WordWrap
                  }

                  Row {
                    width: parent.width
                    spacing: Style.space(10)

                    Text {
                      anchors.verticalCenter: parent.verticalCenter
                      text: root.consultation && root.consultation.primary && root.consultation.primary.nuclear
                        ? root.consultation.primary.nuclear.hexagram.unicode
                        : ""
                      font.pixelSize: Style.space(28)
                      color: root.accentColor
                    }

                    Column {
                      anchors.verticalCenter: parent.verticalCenter
                      width: parent.width - Style.space(42)
                      spacing: Style.space(1)

                      Text {
                        width: parent.width
                        text: root.consultation && root.consultation.primary && root.consultation.primary.nuclear
                          ? ("#" + root.consultation.primary.nuclear.hexagram.number + " " + root.consultation.primary.nuclear.hexagram.english + " · " + root.consultation.primary.nuclear.hexagram.chinese + " (" + root.consultation.primary.nuclear.hexagram.pinyin + ")")
                          : ""
                        color: root.foreground
                        font.family: root.fontFamily
                        font.pixelSize: Style.space(12)
                        font.bold: true
                        wrapMode: Text.WordWrap
                      }

                      Text {
                        width: parent.width
                        text: root.consultation && root.consultation.primary && root.consultation.primary.nuclear
                          ? ("Upper Core (3–5): " + root.consultation.primary.nuclear.upperTrigram.symbol + " " + root.consultation.primary.nuclear.upperTrigram.name + " (" + root.consultation.primary.nuclear.upperTrigram.nature + ")  •  Lower Core (2–4): " + root.consultation.primary.nuclear.lowerTrigram.symbol + " " + root.consultation.primary.nuclear.lowerTrigram.name + " (" + root.consultation.primary.nuclear.lowerTrigram.nature + ")")
                          : ""
                        color: root.mutedColor
                        font.family: root.fontFamily
                        font.pixelSize: Style.space(10)
                        wrapMode: Text.WordWrap
                      }
                    }
                  }

                  Text {
                    width: parent.width
                    text: root.consultation && root.consultation.primary && root.consultation.primary.nuclear
                      ? root.consultation.primary.nuclear.hexagram.judgment
                      : ""
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    lineHeight: 1.25
                    wrapMode: Text.WordWrap
                  }
                }
              }

              // Wilhelm Structural Dynamics
              Column {
                width: parent.width
                visible: !!(root.consultation && root.consultation.primary && root.consultation.primary.structureCommentary)
                spacing: Style.space(4)

                Text {
                  text: "📖 Wilhelm Structural & Elemental Commentary"
                  color: root.mutedColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                }

                BorderSurface {
                  width: parent.width
                  implicitHeight: pStructComText.implicitHeight + Style.space(14)
                  color: Qt.rgba(0, 0, 0, 0.22)
                  radius: Style.cornerRadius
                  borderSpec: Border.flat(Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.2), 1)

                  Text {
                    id: pStructComText
                    width: parent.width - Style.space(16)
                    anchors.centerIn: parent
                    text: root.consultation && root.consultation.primary ? (root.consultation.primary.structureCommentary || "") : ""
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    lineHeight: 1.3
                    wrapMode: Text.WordWrap
                  }
                }
              }
            }

            // Step Button: Next to Changing Lines
            Button {
              width: parent.width
              visible: root.consultation && root.consultation.hasChangingLines
              text: root.consultation ? ("Next: The Changing Lines (" + root.consultation.changingLines.length + ") ➔") : "Next: Changing Lines ➔"
              accent: root.changingLineColor
              bordered: true
              onClicked: root.readingStage = "lines"
            }
          }
        }

        // ----------------- Changing Lines (Yáo Cí · The Lines) -----------------
        BorderSurface {
          width: parent.width
          visible: root.activeTab === "reading" && root.castLines.length === 6 && root.consultation && root.consultation.hasChangingLines && root.consultation.changingLineDetails && root.consultation.changingLineDetails.length > 0 && root.readingStage === "lines"
          implicitHeight: Math.max(changingLinesCol.implicitHeight + Style.space(24), Style.space(380))
          color: Qt.rgba(245/255, 158/255, 11/255, 0.07)
          radius: Style.cornerRadius
          borderSpec: Border.flat(Qt.rgba(245/255, 158/255, 11/255, 0.35), 1)

          Column {
            id: changingLinesCol
            width: parent.width - Style.space(24)
            anchors.centerIn: parent
            spacing: Style.space(12)

            Row {
              width: parent.width
              spacing: Style.space(8)

              Text {
                text: "⚡"
                font.pixelSize: Style.font.heading
                color: root.changingLineColor
              }

              Column {
                width: parent.width - Style.space(32)
                spacing: Style.space(2)

                Text {
                  width: parent.width
                  text: "The Changing Lines · 爻辭 (Operative Counsel)"
                  color: root.changingLineColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  font.bold: true
                }

                Text {
                  width: parent.width
                  text: "Active lines in motion, revealing specific advice for the turning point:"
                  color: root.mutedColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  wrapMode: Text.WordWrap
                }
              }
            }

            // List each changing line
            Repeater {
              model: root.consultation && root.consultation.changingLineDetails ? root.consultation.changingLineDetails : []
              delegate: Column {
                required property var modelData
                width: parent.width
                spacing: Style.space(6)

                // Line Title badge
                Row {
                  spacing: Style.space(6)

                  Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Style.space(8)
                    height: Style.space(8)
                    radius: Style.space(4)
                    color: root.changingLineColor
                  }

                  Text {
                    text: (modelData.line && modelData.line <= 6 ? ("Line " + modelData.line + " — ") : "") + (modelData.name || "")
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                  }
                }

                // Line Oracle Text & Commentary Box
                BorderSurface {
                  width: parent.width
                  implicitHeight: lineTextCol.implicitHeight + Style.space(16)
                  color: Qt.rgba(0, 0, 0, 0.25)
                  radius: Style.cornerRadius
                  borderSpec: Border.flat(Qt.rgba(245/255, 158/255, 11/255, 0.25), 1)

                  Column {
                    id: lineTextCol
                    width: parent.width - Style.space(16)
                    anchors.centerIn: parent
                    spacing: Style.space(6)

                    Text {
                      width: parent.width
                      text: modelData.text || ""
                      color: root.foreground
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.caption
                      font.bold: true
                      lineHeight: 1.3
                      wrapMode: Text.WordWrap
                    }

                    Text {
                      visible: !!modelData.comments
                      width: parent.width
                      text: modelData.comments ? ("Commentary: " + modelData.comments) : ""
                      color: root.mutedColor
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.caption
                      lineHeight: 1.25
                      wrapMode: Text.WordWrap
                    }
                  }
                }
              }
            }

            // Navigation Row: Back to Present / Next to Future
            Row {
              width: parent.width
              spacing: Style.space(8)

              Button {
                width: (parent.width - Style.space(8)) * 0.5
                implicitHeight: Style.space(32)
                text: root.consultation && root.consultation.primary ? ("← Present (#" + root.consultation.primary.number + ")") : "← Present"
                bordered: true
                onClicked: root.readingStage = "present"
              }

              Button {
                width: (parent.width - Style.space(8)) * 0.5
                implicitHeight: Style.space(32)
                text: root.consultation && root.consultation.transformed ? ("Next: Future (#" + root.consultation.transformed.number + ") ➔") : "Next: Future ➔"
                accent: root.changingLineColor
                bordered: true
                onClicked: root.readingStage = "future"
              }
            }
          }
        }

        // ----------------- Transformed Hexagram (if changing lines) -----------------
        BorderSurface {
          width: parent.width
          visible: root.activeTab === "reading" && root.castLines.length === 6 && root.consultation && root.consultation.hasChangingLines && !!root.consultation.transformed && root.readingStage === "future"
          implicitHeight: Math.max(futureCol.implicitHeight + Style.space(24), Style.space(380))
          color: Qt.rgba(245/255, 158/255, 11/255, 0.08)
          radius: Style.cornerRadius
          borderSpec: Border.flat(Qt.rgba(245/255, 158/255, 11/255, 0.4), 1)

          Column {
            id: futureCol
            width: parent.width - Style.space(24)
            anchors.centerIn: parent
            spacing: Style.space(12)

            Row {
              width: parent.width
              spacing: Style.space(6)

              Text {
                text: "➔ Evolved via Changing Lines:"
                color: root.changingLineColor
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
              }

              Text {
                text: root.consultation ? root.consultation.changingLines.map(function(n) { return "Line " + n }).join(", ") : ""
                color: root.changingLineColor
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
              }
            }

            Row {
              width: parent.width
              spacing: Style.space(14)

              Text {
                id: transGlyphLarge
                anchors.verticalCenter: parent.verticalCenter
                text: root.consultation && root.consultation.transformed ? root.consultation.transformed.unicode : ""
                font.pixelSize: Style.space(52)
                color: root.changingLineColor
              }

              Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - transGlyphLarge.implicitWidth - Style.space(14)
                spacing: Style.space(2)

                Text {
                  width: parent.width
                  text: root.consultation && root.consultation.transformed
                    ? ("#" + root.consultation.transformed.number + " · " + root.consultation.transformed.chinese + " · " + root.consultation.transformed.english)
                    : ""
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.heading
                  font.bold: true
                  wrapMode: Text.WordWrap
                }

                Text {
                  width: parent.width
                  text: root.consultation && root.consultation.transformed
                    ? ("Relating Hexagram (之卦 · Future / Evolved) · " + root.consultation.transformed.pinyin)
                    : ""
                  color: root.mutedColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                }

                Text {
                  width: parent.width
                  text: root.consultation && root.consultation.transformed
                    ? (root.consultation.transformed.upperTrigram.symbol + " " + root.consultation.transformed.upperTrigram.name + " (" + root.consultation.transformed.upperTrigram.element + ") over " +
                       root.consultation.transformed.lowerTrigram.symbol + " " + root.consultation.transformed.lowerTrigram.name + " (" + root.consultation.transformed.lowerTrigram.element + ")")
                    : ""
                  color: root.changingLineColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  wrapMode: Text.WordWrap
                }
              }
            }

            // Aspect Switcher Tabs for Future Hexagram
            Row {
              width: parent.width
              spacing: Style.space(6)

              Button {
                width: (parent.width - Style.space(12)) / 3
                implicitHeight: Style.space(30)
                text: "📜 Judgment"
                bordered: true
                selected: root.hexAspect === "judgment"
                accent: root.changingLineColor
                onClicked: root.hexAspect = "judgment"
              }

              Button {
                width: (parent.width - Style.space(12)) / 3
                implicitHeight: Style.space(30)
                text: "🌊 Image"
                bordered: true
                selected: root.hexAspect === "image"
                accent: root.changingLineColor
                onClicked: root.hexAspect = "image"
              }

              Button {
                width: (parent.width - Style.space(12)) / 3
                implicitHeight: Style.space(30)
                text: "☯ Trigrams"
                bordered: true
                selected: root.hexAspect === "structure"
                accent: root.changingLineColor
                onClicked: root.hexAspect = "structure"
              }
            }

            // --- Transformed Aspect Content: Judgment ---
            Column {
              width: parent.width
              visible: root.hexAspect === "judgment"
              spacing: Style.space(8)

              Column {
                width: parent.width
                spacing: Style.space(3)

                Text {
                  text: "The Judgment (彖辭 · Tuàn Cí)"
                  color: root.changingLineColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  font.bold: true
                }

                Text {
                  width: parent.width
                  text: root.consultation && root.consultation.transformed ? root.consultation.transformed.judgment : ""
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  lineHeight: 1.35
                  wrapMode: Text.WordWrap
                }
              }

              // Wilhelm Commentary on Judgment
              Column {
                width: parent.width
                visible: !!(root.consultation && root.consultation.transformed && root.consultation.transformed.judgmentCommentary)
                spacing: Style.space(4)

                Text {
                  text: "📖 Wilhelm Commentary on the Judgment"
                  color: root.mutedColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                }

                BorderSurface {
                  width: parent.width
                  implicitHeight: tJudgComText.implicitHeight + Style.space(16)
                  color: Qt.rgba(0, 0, 0, 0.22)
                  radius: Style.cornerRadius
                  borderSpec: Border.flat(Qt.rgba(root.changingLineColor.r, root.changingLineColor.g, root.changingLineColor.b, 0.25), 1)

                  Text {
                    id: tJudgComText
                    width: parent.width - Style.space(16)
                    anchors.centerIn: parent
                    text: root.consultation && root.consultation.transformed ? (root.consultation.transformed.judgmentCommentary || "") : ""
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    lineHeight: 1.35
                    wrapMode: Text.WordWrap
                  }
                }
              }
            }

            // --- Transformed Aspect Content: Image ---
            Column {
              width: parent.width
              visible: root.hexAspect === "image"
              spacing: Style.space(8)

              Column {
                width: parent.width
                spacing: Style.space(3)

                Text {
                  text: "The Image (大象 · Dà Xiàng)"
                  color: root.changingLineColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  font.bold: true
                }

                Text {
                  width: parent.width
                  text: root.consultation && root.consultation.transformed ? root.consultation.transformed.image : ""
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  lineHeight: 1.35
                  wrapMode: Text.WordWrap
                }
              }

              // Wilhelm Commentary on Image
              Column {
                width: parent.width
                visible: !!(root.consultation && root.consultation.transformed && root.consultation.transformed.imageCommentary)
                spacing: Style.space(4)

                Text {
                  text: "🌊 Wilhelm Commentary on the Image"
                  color: root.mutedColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                }

                BorderSurface {
                  width: parent.width
                  implicitHeight: tImgComText.implicitHeight + Style.space(16)
                  color: Qt.rgba(0, 0, 0, 0.22)
                  radius: Style.cornerRadius
                  borderSpec: Border.flat(Qt.rgba(root.changingLineColor.r, root.changingLineColor.g, root.changingLineColor.b, 0.25), 1)

                  Text {
                    id: tImgComText
                    width: parent.width - Style.space(16)
                    anchors.centerIn: parent
                    text: root.consultation && root.consultation.transformed ? (root.consultation.transformed.imageCommentary || "") : ""
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    lineHeight: 1.35
                    wrapMode: Text.WordWrap
                  }
                }
              }
            }

            // --- Transformed Aspect Content: Trigrams & Structure ---
            Column {
              width: parent.width
              visible: root.hexAspect === "structure"
              spacing: Style.space(8)

              // Two side-by-side realm cards
              Row {
                width: parent.width
                spacing: Style.space(8)

                // Upper Trigram (Outer Realm)
                BorderSurface {
                  width: (parent.width - Style.space(8)) * 0.5
                  implicitHeight: Math.max(tUpperCol.implicitHeight, tLowerCol.implicitHeight) + Style.space(14)
                  color: Qt.rgba(root.changingLineColor.r, root.changingLineColor.g, root.changingLineColor.b, 0.08)
                  radius: Style.cornerRadius
                  borderSpec: Border.flat(Qt.rgba(root.changingLineColor.r, root.changingLineColor.g, root.changingLineColor.b, 0.35), 1)

                  Column {
                    id: tUpperCol
                    width: parent.width - Style.space(16)
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Style.space(7)
                    spacing: Style.space(4)

                    // Header Tag
                    Row {
                      spacing: Style.space(5)
                      Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: Style.space(6)
                        height: Style.space(6)
                        radius: Style.space(3)
                        color: root.changingLineColor
                      }
                      Text {
                        text: "Outer Realm · Lines 4–6"
                        color: root.changingLineColor
                        font.family: root.fontFamily
                        font.pixelSize: Style.space(11)
                        font.bold: true
                      }
                    }

                    // Glyph & Identity
                    Row {
                      width: parent.width
                      spacing: Style.space(8)

                      Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.consultation && root.consultation.transformed ? root.consultation.transformed.upperTrigram.symbol : ""
                        font.pixelSize: Style.space(32)
                        color: root.changingLineColor
                      }

                      Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - Style.space(40)
                        spacing: Style.space(1)

                        Text {
                          width: parent.width
                          text: root.consultation && root.consultation.transformed
                            ? (root.consultation.transformed.upperTrigram.name + " · " + root.consultation.transformed.upperTrigram.chinese)
                            : ""
                          color: root.foreground
                          font.family: root.fontFamily
                          font.pixelSize: Style.space(12)
                          font.bold: true
                          wrapMode: Text.WordWrap
                        }

                        Text {
                          width: parent.width
                          text: root.consultation && root.consultation.transformed
                            ? (root.consultation.transformed.upperTrigram.pinyin + " · " + root.consultation.transformed.upperTrigram.element)
                            : ""
                          color: root.changingLineColor
                          font.family: root.fontFamily
                          font.pixelSize: Style.space(11)
                          font.bold: true
                        }
                      }
                    }

                    Text {
                      width: parent.width
                      text: root.consultation && root.consultation.transformed ? root.consultation.transformed.upperTrigram.nature : ""
                      color: root.foreground
                      font.pixelSize: Style.space(11)
                      wrapMode: Text.WordWrap
                    }

                    Text {
                      width: parent.width
                      text: "Manifest action & outer conditions"
                      color: root.mutedColor
                      font.family: root.fontFamily
                      font.pixelSize: Style.space(10)
                      font.italic: true
                      wrapMode: Text.WordWrap
                    }
                  }
                }

                // Lower Trigram (Inner Realm)
                BorderSurface {
                  width: (parent.width - Style.space(8)) * 0.5
                  implicitHeight: Math.max(tUpperCol.implicitHeight, tLowerCol.implicitHeight) + Style.space(14)
                  color: Qt.rgba(root.changingLineColor.r, root.changingLineColor.g, root.changingLineColor.b, 0.08)
                  radius: Style.cornerRadius
                  borderSpec: Border.flat(Qt.rgba(root.changingLineColor.r, root.changingLineColor.g, root.changingLineColor.b, 0.35), 1)

                  Column {
                    id: tLowerCol
                    width: parent.width - Style.space(16)
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Style.space(7)
                    spacing: Style.space(4)

                    // Header Tag
                    Row {
                      spacing: Style.space(5)
                      Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: Style.space(6)
                        height: Style.space(6)
                        radius: Style.space(3)
                        color: root.changingLineColor
                      }
                      Text {
                        text: "Inner Realm · Lines 1–3"
                        color: root.changingLineColor
                        font.family: root.fontFamily
                        font.pixelSize: Style.space(11)
                        font.bold: true
                      }
                    }

                    // Glyph & Identity
                    Row {
                      width: parent.width
                      spacing: Style.space(8)

                      Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.consultation && root.consultation.transformed ? root.consultation.transformed.lowerTrigram.symbol : ""
                        font.pixelSize: Style.space(32)
                        color: root.changingLineColor
                      }

                      Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - Style.space(40)
                        spacing: Style.space(1)

                        Text {
                          width: parent.width
                          text: root.consultation && root.consultation.transformed
                            ? (root.consultation.transformed.lowerTrigram.name + " · " + root.consultation.transformed.lowerTrigram.chinese)
                            : ""
                          color: root.foreground
                          font.family: root.fontFamily
                          font.pixelSize: Style.space(12)
                          font.bold: true
                          wrapMode: Text.WordWrap
                        }

                        Text {
                          width: parent.width
                          text: root.consultation && root.consultation.transformed
                            ? (root.consultation.transformed.lowerTrigram.pinyin + " · " + root.consultation.transformed.lowerTrigram.element)
                            : ""
                          color: root.changingLineColor
                          font.family: root.fontFamily
                          font.pixelSize: Style.space(11)
                          font.bold: true
                        }
                      }
                    }

                    Text {
                      width: parent.width
                      text: root.consultation && root.consultation.transformed ? root.consultation.transformed.lowerTrigram.nature : ""
                      color: root.foreground
                      font.pixelSize: Style.space(11)
                      wrapMode: Text.WordWrap
                    }

                    Text {
                      width: parent.width
                      text: "Heart-mind & root conditions"
                      color: root.mutedColor
                      font.family: root.fontFamily
                      font.pixelSize: Style.space(10)
                      font.italic: true
                      wrapMode: Text.WordWrap
                    }
                  }
                }
              }

              // Nuclear Transition Card (X -> Y Matrix)
              BorderSurface {
                width: parent.width
                visible: !!(root.consultation && root.consultation.nuclearTransition)
                implicitHeight: nTransCol.implicitHeight + Style.space(16)
                color: Qt.rgba(0, 0, 0, 0.28)
                radius: Style.cornerRadius
                borderSpec: Border.flat(Qt.rgba(root.changingLineColor.r, root.changingLineColor.g, root.changingLineColor.b, 0.35), 1)

                Column {
                  id: nTransCol
                  width: parent.width - Style.space(16)
                  anchors.centerIn: parent
                  spacing: Style.space(5)

                  Row {
                    width: parent.width
                    spacing: Style.space(6)

                    Rectangle {
                      anchors.verticalCenter: parent.verticalCenter
                      width: Style.space(6)
                      height: Style.space(6)
                      radius: Style.space(3)
                      color: root.changingLineColor
                    }

                    Text {
                      anchors.verticalCenter: parent.verticalCenter
                      text: "Interior Core Transition (X ➔ Y Engine Matrix)"
                      color: root.changingLineColor
                      font.family: root.fontFamily
                      font.pixelSize: Style.space(11)
                      font.bold: true
                    }

                    BorderSurface {
                      anchors.verticalCenter: parent.verticalCenter
                      visible: !!(root.consultation && root.consultation.nuclearTransition)
                      implicitHeight: Style.space(18)
                      implicitWidth: transLvlText.implicitWidth + Style.space(12)
                      radius: Style.space(4)
                      color: Qt.rgba(root.changingLineColor.r, root.changingLineColor.g, root.changingLineColor.b, 0.15)
                      borderSpec: Border.flat(Qt.rgba(root.changingLineColor.r, root.changingLineColor.g, root.changingLineColor.b, 0.4), 1)

                      Text {
                        id: transLvlText
                        anchors.centerIn: parent
                        text: root.consultation && root.consultation.nuclearTransition
                          ? root.consultation.nuclearTransition.badge
                          : ""
                        color: root.changingLineColor
                        font.family: root.fontFamily
                        font.pixelSize: Style.space(9)
                        font.bold: true
                      }
                    }
                  }

                  Text {
                    width: parent.width
                    text: root.consultation && root.consultation.nuclearTransition
                      ? root.consultation.nuclearTransition.headline
                      : ""
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.space(12)
                    font.bold: true
                    wrapMode: Text.WordWrap
                  }

                  Text {
                    width: parent.width
                    text: root.consultation && root.consultation.nuclearTransition
                      ? root.consultation.nuclearTransition.description
                      : ""
                    color: root.mutedColor
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    lineHeight: 1.3
                    wrapMode: Text.WordWrap
                  }
                }
              }

              // Nuclear Core Card (Hidden Core · 互卦)
              BorderSurface {
                width: parent.width
                implicitHeight: tNuclearCol.implicitHeight + Style.space(16)
                color: Qt.rgba(root.changingLineColor.r, root.changingLineColor.g, root.changingLineColor.b, 0.06)
                radius: Style.cornerRadius
                borderSpec: Border.flat(Qt.rgba(root.changingLineColor.r, root.changingLineColor.g, root.changingLineColor.b, 0.25), 1)

                Column {
                  id: tNuclearCol
                  width: parent.width - Style.space(16)
                  anchors.centerIn: parent
                  spacing: Style.space(5)

                  Row {
                    width: parent.width
                    spacing: Style.space(6)

                    Rectangle {
                      anchors.verticalCenter: parent.verticalCenter
                      width: Style.space(6)
                      height: Style.space(6)
                      radius: Style.space(3)
                      color: root.changingLineColor
                    }

                    Text {
                      anchors.verticalCenter: parent.verticalCenter
                      text: "Nuclear Core (Hidden Core · 互卦 · Hù Guà)"
                      color: root.changingLineColor
                      font.family: root.fontFamily
                      font.pixelSize: Style.space(11)
                      font.bold: true
                    }

                    BorderSurface {
                      anchors.verticalCenter: parent.verticalCenter
                      visible: !!(root.consultation && root.consultation.transformed && root.consultation.transformed.nuclear && root.consultation.transformed.nuclear.rootGate)
                      implicitHeight: Style.space(18)
                      implicitWidth: tGateText.implicitWidth + Style.space(12)
                      radius: Style.space(4)
                      color: Qt.rgba(root.changingLineColor.r, root.changingLineColor.g, root.changingLineColor.b, 0.12)
                      borderSpec: Border.flat(Qt.rgba(root.changingLineColor.r, root.changingLineColor.g, root.changingLineColor.b, 0.35), 1)

                      Text {
                        id: tGateText
                        anchors.centerIn: parent
                        text: root.consultation && root.consultation.transformed && root.consultation.transformed.nuclear && root.consultation.transformed.nuclear.rootGate
                          ? root.consultation.transformed.nuclear.rootGate.name
                          : ""
                        color: root.changingLineColor
                        font.family: root.fontFamily
                        font.pixelSize: Style.space(9)
                        font.bold: true
                      }
                    }
                  }

                  Text {
                    width: parent.width
                    text: "Latent interior engine & psychological undercurrent gestating inside lines 2–5:"
                    color: root.mutedColor
                    font.family: root.fontFamily
                    font.pixelSize: Style.space(10)
                    font.italic: true
                    wrapMode: Text.WordWrap
                  }

                  Row {
                    width: parent.width
                    spacing: Style.space(10)

                    Text {
                      anchors.verticalCenter: parent.verticalCenter
                      text: root.consultation && root.consultation.transformed && root.consultation.transformed.nuclear
                        ? root.consultation.transformed.nuclear.hexagram.unicode
                        : ""
                      font.pixelSize: Style.space(28)
                      color: root.changingLineColor
                    }

                    Column {
                      anchors.verticalCenter: parent.verticalCenter
                      width: parent.width - Style.space(42)
                      spacing: Style.space(1)

                      Text {
                        width: parent.width
                        text: root.consultation && root.consultation.transformed && root.consultation.transformed.nuclear
                          ? ("#" + root.consultation.transformed.nuclear.hexagram.number + " " + root.consultation.transformed.nuclear.hexagram.english + " · " + root.consultation.transformed.nuclear.hexagram.chinese + " (" + root.consultation.transformed.nuclear.hexagram.pinyin + ")")
                          : ""
                        color: root.foreground
                        font.family: root.fontFamily
                        font.pixelSize: Style.space(12)
                        font.bold: true
                        wrapMode: Text.WordWrap
                      }

                      Text {
                        width: parent.width
                        text: root.consultation && root.consultation.transformed && root.consultation.transformed.nuclear
                          ? ("Upper Core (3–5): " + root.consultation.transformed.nuclear.upperTrigram.symbol + " " + root.consultation.transformed.nuclear.upperTrigram.name + " (" + root.consultation.transformed.nuclear.upperTrigram.nature + ")  •  Lower Core (2–4): " + root.consultation.transformed.nuclear.lowerTrigram.symbol + " " + root.consultation.transformed.nuclear.lowerTrigram.name + " (" + root.consultation.transformed.nuclear.lowerTrigram.nature + ")")
                          : ""
                        color: root.mutedColor
                        font.family: root.fontFamily
                        font.pixelSize: Style.space(10)
                        wrapMode: Text.WordWrap
                      }
                    }
                  }

                  Text {
                    width: parent.width
                    text: root.consultation && root.consultation.transformed && root.consultation.transformed.nuclear
                      ? root.consultation.transformed.nuclear.hexagram.judgment
                      : ""
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    lineHeight: 1.25
                    wrapMode: Text.WordWrap
                  }
                }
              }

              // Wilhelm Structural Dynamics
              Column {
                width: parent.width
                visible: !!(root.consultation && root.consultation.transformed && root.consultation.transformed.structureCommentary)
                spacing: Style.space(4)

                Text {
                  text: "📖 Wilhelm Structural & Elemental Commentary"
                  color: root.mutedColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                }

                BorderSurface {
                  width: parent.width
                  implicitHeight: tStructComText.implicitHeight + Style.space(14)
                  color: Qt.rgba(0, 0, 0, 0.22)
                  radius: Style.cornerRadius
                  borderSpec: Border.flat(Qt.rgba(root.changingLineColor.r, root.changingLineColor.g, root.changingLineColor.b, 0.25), 1)

                  Text {
                    id: tStructComText
                    width: parent.width - Style.space(16)
                    anchors.centerIn: parent
                    text: root.consultation && root.consultation.transformed ? (root.consultation.transformed.structureCommentary || "") : ""
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    lineHeight: 1.3
                    wrapMode: Text.WordWrap
                  }
                }
              }
            }

            // Navigation Row: Back to Lines / Back to Present
            Row {
              width: parent.width
              spacing: Style.space(8)

              Button {
                width: (parent.width - Style.space(8)) * 0.5
                implicitHeight: Style.space(32)
                text: "← Back to Lines"
                bordered: true
                onClicked: root.readingStage = "lines"
              }

              Button {
                width: (parent.width - Style.space(8)) * 0.5
                implicitHeight: Style.space(32)
                text: "↺ Back to Present"
                accent: root.accentColor
                bordered: true
                onClicked: root.readingStage = "present"
              }
            }
          }
        }

        // ----------------- Source Citation Footer -----------------
        Text {
          width: parent.width
          visible: root.activeTab === "reading" && root.castLines.length === 6 && !!root.consultation
          horizontalAlignment: Text.AlignHCenter
          text: "📖 Translation & Commentary: Richard Wilhelm / Cary F. Baynes · Princeton University Press"
          color: root.mutedColor
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          font.italic: true
          wrapMode: Text.WordWrap
          lineHeight: 1.3
          topPadding: Style.space(4)
          bottomPadding: Style.space(12)
        }

        // ----------------- Lore & Philosophy Tab -----------------
        BorderSurface {
          width: parent.width
          visible: root.activeTab === "lore"
          implicitHeight: loreCol.implicitHeight + Style.space(24)
          color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.06)
          radius: Style.cornerRadius
          borderSpec: Border.flat(Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.25), 1)

          Column {
            id: loreCol
            width: parent.width - Style.space(24)
            anchors.centerIn: parent
            spacing: Style.space(10)

            // Lore Section Switcher Tabs (5 selectable sections)
            Row {
              width: parent.width
              spacing: Style.space(4)

              Button {
                width: (parent.width - Style.space(16)) / 5
                implicitHeight: Style.space(30)
                text: "🌿 Ritual"
                bordered: true
                selected: root.loreSection === "ritual"
                accent: root.accentColor
                onClicked: root.loreSection = "ritual"
              }

              Button {
                width: (parent.width - Style.space(16)) / 5
                implicitHeight: Style.space(30)
                text: "🔮 Math"
                bordered: true
                selected: root.loreSection === "math"
                accent: root.accentColor
                onClicked: root.loreSection = "math"
              }

              Button {
                width: (parent.width - Style.space(16)) / 5
                implicitHeight: Style.space(30)
                text: "⚛ Nuclear"
                bordered: true
                selected: root.loreSection === "nuclear"
                accent: root.accentColor
                onClicked: root.loreSection = "nuclear"
              }

              Button {
                width: (parent.width - Style.space(16)) / 5
                implicitHeight: Style.space(30)
                text: "🧘 Mind"
                bordered: true
                selected: root.loreSection === "protocol"
                accent: root.accentColor
                onClicked: root.loreSection = "protocol"
              }

              Button {
                width: (parent.width - Style.space(16)) / 5
                implicitHeight: Style.space(30)
                text: "📜 Wilhelm"
                bordered: true
                selected: root.loreSection === "wilhelm"
                accent: root.accentColor
                onClicked: root.loreSection = "wilhelm"
              }
            }

            // Lore Content Display Card
            BorderSurface {
              width: parent.width
              implicitHeight: loreContentCol.implicitHeight + Style.space(20)
              color: Qt.rgba(0, 0, 0, 0.22)
              radius: Style.cornerRadius
              borderSpec: Border.flat(Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.25), 1)

              Column {
                id: loreContentCol
                width: parent.width - Style.space(20)
                anchors.centerIn: parent
                spacing: Style.space(8)

                Column {
                  width: parent.width
                  spacing: Style.space(2)

                  Text {
                    width: parent.width
                    text: root.getLoreSectionTitle()
                    color: root.accentColor
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                    wrapMode: Text.WordWrap
                  }

                  Text {
                    width: parent.width
                    text: root.getLoreSectionSubtitle()
                    color: root.mutedColor
                    font.family: root.fontFamily
                    font.pixelSize: Style.space(10)
                    font.italic: true
                    wrapMode: Text.WordWrap
                  }
                }

                Repeater {
                  model: root.getLoreSectionParagraphs()
                  delegate: Text {
                    required property string modelData
                    width: loreContentCol.width
                    text: modelData
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    lineHeight: 1.3
                    wrapMode: Text.WordWrap
                  }
                }
              }
            }

            Button {
              width: parent.width
              implicitHeight: Style.space(32)
              text: "← Return to Casting Chamber"
              accent: root.accentColor
              bordered: true
              onClicked: root.activeTab = "chamber"
            }
          }
        }

      }
    }
  }
}
