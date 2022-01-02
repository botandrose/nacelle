CKEDITOR.dialog.add("cellDialog", function(editor) {
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
      }],
    }],

    onShow: function() {
      fetch("/nacelle/cells.json").then(r => r.json()).then(data => {
        var select = this.getContentElement("main", "cellName");
        for(var i=0; i < data.cells.length; i++) {
          var item = data.cells[i];
          select.add(item.name, item.id);
        }
      });
    },

    onOk: function() {
      var cell = editor.document.createElement("cell");
      cell.setAttribute("name", this.getValueOf("main", "cellName"));
      editor.insertElement(cell)
    },
  };
});

