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
    activeTab = "chamber"
  }

  function copyReading() {
    if (!consultation || !consultation.primary) return
    var p = consultation.primary
    var methodLabel = (root.method === "yarrow")
      ? "Authentic 50 Yarrow Stalks Method"
      : "38 Marbles Pouch (Andrew Kennedy's Revised Yarrow Algorithm)"
    var text = "☯ I-Ching Oracle Reading (" + methodLabel + ") ☯\n\n"
    if (root.inquiryText.trim() !== "") {
      text += "Inquiry: \"" + root.inquiryText.trim() + "\"\n\n"
    }
    text += "Primary Hexagram: #" + p.number + " " + p.chinese + " (" + p.pinyin + ") — " + p.english + " " + p.unicode + "\n"
    text += "Trigrams: " + p.upperTrigram.name + " (" + p.upperTrigram.symbol + ") above " + p.lowerTrigram.name + " (" + p.lowerTrigram.symbol + ")\n"
    text += "\nThe Judgment:\n" + p.judgment + "\n"
    text += "\nThe Image:\n" + p.image + "\n\n"

    if (consultation.hasChangingLines && consultation.transformed) {
      var t = consultation.transformed
      var changingStr = ""
      for (var k = 0; k < consultation.changingLines.length; k++) {
        if (k > 0) changingStr += ", "
        changingStr += "Line " + consultation.changingLines[k]
      }
      text += "Changing Lines: " + changingStr + "\n\n"
      text += "Relating Hexagram (Future): #" + t.number + " " + t.chinese + " (" + t.pinyin + ") — " + t.english + " " + t.unicode + "\n"
      text += "Trigrams: " + t.upperTrigram.name + " (" + t.upperTrigram.symbol + ") above " + t.lowerTrigram.name + " (" + t.lowerTrigram.symbol + ")\n"
      text += "\nThe Judgment:\n" + t.judgment + "\n"
      text += "\nThe Image:\n" + t.image + "\n\n"
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
    contentWidth: Style.space(440)
    contentHeight: panel.fittedContentHeight(scrollContent.implicitHeight + panel.padding * 2, Style.space(740))

    Controls.ScrollView {
      id: scrollArea
      anchors.fill: parent
      clip: true
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
            text: root.castLines.length > 0 ? ("☯ Chamber " + root.castLines.length + "/6") : "☯ Chamber"
            bordered: true
            selected: root.activeTab === "chamber"
            accent: root.accentColor
            onClicked: root.activeTab = "chamber"
          }

          Button {
            width: (parent.width - Style.space(12)) / 3
            text: root.consultation ? "📖 Reading ✨" : "📖 Reading"
            bordered: true
            selected: root.activeTab === "reading"
            accent: root.accentColor
            onClicked: root.activeTab = "reading"
          }

          Button {
            width: (parent.width - Style.space(12)) / 3
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
            }

            TextField {
              id: questionInputField
              width: parent.width
              visible: root.castLines.length === 0
              placeholderText: "Formulate your question & hold it in mind throughout..."
              text: root.inquiryText
              font.pixelSize: Style.font.caption
              onTextChanged: root.inquiryText = text
            }

            Text {
              visible: root.castLines.length > 0 && root.inquiryText.trim() !== ""
              width: parent.width
              text: "“" + root.inquiryText.trim() + "”"
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              wrapMode: Text.WordWrap
            }

            Text {
              width: parent.width
              text: root.castLines.length === 0
                ? "The classics teach: quiet your mind, formulate what you seek counsel on, and hold it firmly in thought through all six draws."
                : (root.castLines.length < 6
                  ? "Maintain single-minded focus on this inquiry as each line is drawn from the bottom up."
                  : "Reflect deeply upon the Judgment and Image in relation to your inquiry.")
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

        // ----------------- Primary Hexagram Card -----------------
        BorderSurface {
          width: parent.width
          visible: root.activeTab === "reading" && root.castLines.length === 6 && root.consultation && !!root.consultation.primary
          implicitHeight: primaryResultCol.implicitHeight + Style.space(24)
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

            // The Judgment
            Column {
              width: parent.width
              spacing: Style.space(4)

              Text {
                text: "The Judgment"
                color: root.foreground
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
                lineHeight: 1.3
                wrapMode: Text.WordWrap
              }
            }

            // The Image
            Column {
              width: parent.width
              spacing: Style.space(4)

              Text {
                text: "The Image"
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
                font.bold: true
              }

              Text {
                width: parent.width
                text: root.consultation && root.consultation.primary ? root.consultation.primary.image : ""
                color: root.mutedColor
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                lineHeight: 1.3
                wrapMode: Text.WordWrap
              }
            }
          }
        }

        // ----------------- Transformed Hexagram (if changing lines) -----------------
        BorderSurface {
          width: parent.width
          visible: root.activeTab === "reading" && root.castLines.length === 6 && root.consultation && root.consultation.hasChangingLines && !!root.consultation.transformed
          implicitHeight: futureCol.implicitHeight + Style.space(24)
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

            // Transformed Judgment
            Column {
              width: parent.width
              spacing: Style.space(4)

              Text {
                text: "The Judgment"
                color: root.foreground
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
                lineHeight: 1.3
                wrapMode: Text.WordWrap
              }
            }

            // Transformed Image
            Column {
              width: parent.width
              spacing: Style.space(4)

              Text {
                text: "The Image"
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
                font.bold: true
              }

              Text {
                width: parent.width
                text: root.consultation && root.consultation.transformed ? root.consultation.transformed.image : ""
                color: root.mutedColor
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                lineHeight: 1.3
                wrapMode: Text.WordWrap
              }
            }
          }
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
            spacing: Style.space(12)

            Text {
              text: "☯ Origin, Mathematics & Philosophy"
              color: root.accentColor
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              font.bold: true
            }

            Text {
              width: parent.width
              text: "• Zhu Xi (朱熹, 1186 CE):\nPreserved the authentic 18-step physical yarrow stalk algorithm in his manual 'Yixue Qimeng' from the ancient Han-era Great Treatise (Dazhuan).\n\n• Flawed 3-Coin Shortcut & Gardner (1974):\nWestern coin-tossing gives equal 12.5% chances to both changing lines. Martin Gardner showed in Scientific American that authentic yarrow division produces a dynamic asymmetry: restless Yang transforms 3 to 4 times more readily than Yin. Gardner's chalkboard math suggested a 16/32 ratio.\n\n• Andrew Kennedy's Revised Yarrow Algorithm (2006):\nGardner's math assumed theoretical numbers dividing into quarters. But real human hands cannot divide stalks with zero on either side: when splitting 49 stalks into left and right hands, neither hand can ever be empty, and removing 1 stalk to hold between fingers means the right hand must hold at least 2. Dividing 49 stalks with physical non-zero hands yields 47 possible physical splits—a prime number that doesn't divide cleanly into quarters.\n\n• Why 38 Marbles Replaces 32:\nThe classical 32-marble bag had chalkboard errors of up to 2.4% on every line. By contrast, a 38-marble pouch matches the exact physical hand division of yarrow stalks to within 0.09%—the #1 most accurate integer model in existence.\n\n• Sacred 38-Marble Pouch:\n  • 17 Pure Black = Young Yin (8) [44.7%]\n  • 11 Pure White = Young Yang (7) [28.9%]\n  • 8 White with Black Specks = Old Yang (9) [21.1% · Changing]\n  • 2 Black with White Specks = Old Yin (6) [5.3% · Changing]\n\n• Present vs Future:\nChanging lines (Old Yang ● and Old Yin ✕) indicate points of active transformation, evolving the Present Hexagram into the Future Relating Hexagram.\n\n• Classical Consultation Protocol (Mind, Intent & Hexagram 4):\n  - Sincerity of Intent (Chéng, 誠): The Great Treatise teaches: 'In stillness it is without thought, tranquil and unmoving; when stirred, it penetrates all under heaven.' Approach with a quiet, centered mind.\n  - Hold the Question Throughout: Maintain uninterrupted focus on your inquiry as each line is drawn from the bottom up.\n  - How to Frame an Inquiry: Ask open-ended questions about dynamics, counsel, and attitude (e.g. 'What forces are at play in this situation?' or 'How should I navigate this conflict?') rather than testing or trivial yes/no predictions.\n  - The Rule of Hexagram 4 (Youthful Folly): 'The first consultation informs; asking repeatedly out of dissatisfaction is importunity' (初筮告，再三瀆，瀆則不告). Accept the oracle's counsel with an open, meditative heart."
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              lineHeight: 1.25
              wrapMode: Text.WordWrap
            }

            Button {
              width: parent.width
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
