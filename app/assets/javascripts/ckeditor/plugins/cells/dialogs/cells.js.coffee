CKEDITOR.dialog.add "cellDialog", (editor) ->
  getSelectedCell = ->
    node = editor.getSelectedHtml().$.firstElementChild
    return node if node?.nodeName == "CELL"

  title: "Insert Cell"
  minWidth: 400
  minHeight: 200

  contents: [
    id: "main"
    elements: [
      type: "select"
      id: "cellName"
      label: "Select Cell"
      items: []
      onChange: (event) =>
        select = event.sender
        dialog = select.getDialog()
        form = dialog.getContentElement("main", "form")
        cellConfig = dialog.cellConfigs.find (cellConfig) =>
          cellConfig.id == event.data.value

        form.getElement().setHtml cellConfig.form

        if selectedCell = getSelectedCell()
          $(form.getElement().$).find("[name]").each (_, element) =>
            $(element).val selectedCell.getAttribute(element.name)
    ,
      type: "html"
      id: "form"
      html: ""
    ]
  ]

  onShow: ->
    $.getJSON "/nacelle/cells.json", (data) =>
      @cellConfigs = data.cells
      select = @getContentElement("main", "cellName")
      select.clear()
      for cellConfig in @cellConfigs
        select.add cellConfig.name, cellConfig.id

      if selectedCell = getSelectedCell()
        select.setValue selectedCell.getAttribute("name")

  onOk: ->
    cell = editor.document.createElement("cell")
    cell.setAttribute "name", @getValueOf("main", "cellName")

    form = @getContentElement("main", "form")
    $(form.getElement().$).find("[name]").each (_, element) =>
      cell.setAttribute element.name, $(element).val()

    editor.insertElement cell

