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
        onChange: (event) => {
          let select = event.sender
          let dialog = select.getDialog()
          let form = dialog.getContentElement("main", "form")
          let cellConfig = dialog.cellConfigs.find(config => config.id === event.data.value)

          form.getElement().setHtml(cellConfig.form)

          if(selectedCell = getSelectedCell()) {
            form.getElement().$.querySelectorAll("[name]").forEach(element => {
              setValue(element, selectedCell.getAttribute(element.name))
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

        this.cellConfigs.forEach(config => select.add(config.name, config.id))

        let selectedCell = getSelectedCell()
        if(selectedCell) {
          select.setValue(selectedCell.getAttribute("name"))
        }
      });
    },

    onOk: function() {
      let cell = editor.document.createElement("cell")
      cell.setAttribute("name", this.getValueOf("main", "cellName"));

      let form = this.getContentElement("main", "form")
      form.getElement().$.querySelectorAll("[name]").forEach(element => {
        cell.setAttribute(element.name, getValue(element))
      })

      editor.insertElement(cell)
    },
  };

  function getSelectedCell() {
    let node = editor.getSelectedHtml().$.firstElementChild
    if(node && node.nodeName == "CELL") {
      return node 
    }
  }

  function getValue(element) {
    switch(element.type) {
      case 'radio':
      case 'checkbox':
        const elements = document.querySelectorAll(`[name="${element.name}"]:checked`)
        const values = Array.from(elements).map(e => e.value)
        if(element.name.endsWith("[]")) {
          return values
        } else {
          return values[0]
        }
      default:
        return element.value
    }
  }

  function setValue(element, value) {
    if ('undefined' === typeof value) {
      value = '';
    }

    if (null === value) {
      value = '';
    }

    var type = element.type || element[0].type;

    switch(type ) {
      default:
        element.value = value;
        break;

      case 'radio':
      case 'checkbox':
        element.checked = element.value === value;
        break;

      case 'select-multiple':
        var values = value.constructor === Array ? value : [value];
        for(var k = 0; k < element.options.length; k++) {
          element.options[k].selected = (values.indexOf(element.options[k].value) > -1 );
        }
        break;

      case 'select':
      case 'select-one':
        element.value = value.toString() || value;
        break;

      case 'date':
        element.value = new Date(value).toISOString().split('T')[0];
        break;
    }
  };
});

