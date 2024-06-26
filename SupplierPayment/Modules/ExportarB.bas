Attribute VB_Name = "ExportarB"
Sub ExportarB()
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual

    Dim wsProveedores As Worksheet
    Dim wsDestino As Worksheet
    Dim ultimaFilaProveedores As Long
    Dim tblDestino As ListObject
    Dim i As Long

    Set wsProveedores = ThisWorkbook.Sheets("Proveedores")

    On Error Resume Next
    Set wsDestino = ThisWorkbook.Sheets("B")
    On Error GoTo 0
    
    If wsDestino Is Nothing Then
        Sheets.Add(After:=Sheets(Sheets.Count)).Name = "B"
        Set wsDestino = Sheets("B")
    End If

    ultimaFilaProveedores = wsProveedores.Cells(wsProveedores.Rows.Count, "C").End(xlUp).Row
    
        ' Verificar la presencia de valores N/A en la columna de inter�s
    hayNAs = False
    For i = 3 To ultimaFilaProveedores
        If IsError(wsProveedores.Cells(i, 11).Value) Then
            If wsProveedores.Cells(i, 11).Value = CVErr(xlErrNA) Then
                hayNAs = True
                Exit For
            End If
        End If
    Next i
    
    ' Si hay valores N/A, mostrar mensaje y salir del subproceso
    If hayNAs Then
        MsgBox "No se puede exportar porque hay celdas con valores #N/D en la columna 'K'.", vbExclamation
        Application.ScreenUpdating = True
        Application.Calculation = xlCalculationAutomatic
        Exit Sub
    End If

    On Error Resume Next
    Set tblDestino = wsDestino.ListObjects("Tabla3")
    On Error GoTo 0
    
    If tblDestino Is Nothing Then
        MsgBox "No se encontr� la tabla en la hoja de destino.", vbExclamation
        Exit Sub
    End If

    For i = 3 To ultimaFilaProveedores
        If UCase(wsProveedores.Cells(i, 3).Value) = "B" Then
            tblDestino.ListRows.Add
            tblDestino.ListRows(tblDestino.ListRows.Count).Range.Cells(1, 1).Resize(, wsProveedores.Columns.Count).Value = wsProveedores.Rows(i).Value
        End If
    Next i

    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
    
    MsgBox "Los datos se exportaron correctamente a la hoja 'B'.", vbInformation
End Sub

