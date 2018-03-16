CKEDITOR.plugins.add "cells",
  icons: "insertcell"
  init: (editor) ->
    editor.addCommand "insertCellDialog", new CKEDITOR.dialogCommand("cellDialog")

    CKEDITOR.dialog.add "cellDialog", "#{@path}dialogs/cells.js"

    editor.ui.addButton "InsertCell",
      label: "Insert Cell"
      command: "insertCellDialog"

CKEDITOR.dtd.$empty.cell = 1
CKEDITOR.dtd.$nonEditable.cell = 1
CKEDITOR.dtd.$object.cell = 1

