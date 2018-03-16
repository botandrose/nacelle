CKEDITOR.dialog.add "cellDialog", (editor) ->
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
    ]
  ]

  onShow: ->
    $.getJSON "/nacelle/cells.json", (data) =>
      select = @getContentElement("main", "cellName")
      for item in data.cells
        select.add item.name, item.id

  onOk: ->
    cell = editor.document.createElement("cell")
    cell.setAttribute "name", @getValueOf("main", "cellName")
    editor.insertElement cell

