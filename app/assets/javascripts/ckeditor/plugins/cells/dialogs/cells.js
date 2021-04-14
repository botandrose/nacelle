CKEDITOR.dialog.add("cellDialog", function(editor) {
  function getSelectedCell() {
    let node = editor.getSelectedHtml().$.firstElementChild
    return node if node?.nodeName == "CELL"
  }

  return {
    title: "Insert Cell",
    minWidth: 400,
    minHeight: 200,
    contents: [{
      id: "main",
      elements: [{
        type: "select",
        id: "cellName",
        label: "Select Cell",
        items: [],
        onChange: (event) => {
          let select = event.sender
          let dialog = select.getDialog()
          let form = dialog.getContentElement("main", "form")
          let cellConfig = dialog.cellConfigs.find((cellConfig) => {
            cellConfig.id === event.data.value
          })

          form.getElement().setHtml(cellConfig.form)

          if(selectedCell = getSelectedCell()) {
            $(form.getElement().$).find("[name]").each((_, element) => {
              $(element).val selectedCell.getAttribute(element.name)
            })
          }
        },
      },
      {
        type: "html",
        id: "form",
        html: "",
      }],
    }],

    onShow: function() {
      fetch("/nacelle/cells.json").then(r => r.json()).then(data => {
        this.cellConfigs = data.cells
        let select = this.getContentElement("main", "cellName")
        select.clear()

        for(let i=0; i < this.cellConfigs.length; i++) {
          let cellConfig = this.cellConfigs[i]
          select.add(cellConfig.name, cellConfig.id)
        }
        if(let selectedCell = getSelectedCell()) {
          select.setValue(selectedCell.getAttribute("name"))
        }
      });
    },

    onOk: function() {
      let cell = editor.document.createElement("cell")
      cell.setAttribute("name", this.getValueOf("main", "cellName"));

      let form = this.getContentElement("main", "form")
      $(form.getElement().$).find("[name]").each((_, element) => {
        cell.setAttribute(element.name, $(element).val())
      })

      editor.insertElement(cell)
    },
  };
});

