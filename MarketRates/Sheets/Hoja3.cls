VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Hoja3"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
 Dim borrarRealizado As Boolean

Private Sub Ayuda2_Click()
MsgBox "Para generar el ROTULO de Cotizaci�n correctamente, es necesario que NO se dejen vac�os los sig. campos en la tabla:" & vbCrLf & _
        " " & vbCrLf & _
        "CUENTA - CAJA- CONDICION DE PAGO - DESTINO" & vbCrLf & _
        "  - CUENTA poner un numero de identificaci�n provisorio para que pueda tomar los datos igual, ejemplo: 0, 00, 0000, 111, etc. " & vbCrLf & _
        "  - CONDICION DE PAGO y DESTINO agregar los valores correspondientes de manera manual, una vez que los clientes est�n en la base de datos se van a generar autom�ticamente." & vbCrLf & _
        "  - CAMPOS RESTANTES en caso de que no tener valores para ingresar, poner un signo -" & vbCrLf & _
        " " & vbCrLf & _
        "(*) En caso de requerir reformas o modificaciones incuir todos los detalles.", vbInformation, "Ayuda"
End Sub

Private Sub BotonInforme_Click()
    If Not borrarRealizado Then
        MsgBox "Por favor, presione el bot�n 'Borrar Informe' antes de generar el informe nuevamente.", vbExclamation
        Exit Sub
    End If

    ' Restablecer la variable de control despu�s de generar
    borrarRealizado = False

    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    
    Dim wsRotulo As Worksheet
    Dim wsPedidos As Worksheet
    Dim i As Long
    
    ' Hojas de c�lculo a tomar
    Set wsRotulo = Worksheets("ROTULO")
    Set wsPedidos = Worksheets("PEDIDOS")
    
    Dim nro_cotiz As Variant
    nro_cotiz = wsRotulo.Range("B4").Value
    
    Dim rngPedidos As ListObject
    Set rngPedidos = wsPedidos.ListObjects("Tabla25")
    
    Dim dataPedidos As Variant
    dataPedidos = rngPedidos.DataBodyRange.Value
    
    ' Verificar si alg�n campo est� vac�o
    Dim camposVacios As Boolean
    Dim camposFaltantes As String
    camposVacios = False
    camposFaltantes = ""
    
    For i = LBound(dataPedidos, 1) To UBound(dataPedidos, 1)
        If dataPedidos(i, 2) = nro_cotiz Then
            If Not IsNumeric(dataPedidos(i, 3)) Or _
               IsEmpty(dataPedidos(i, 5)) Or IsEmpty(dataPedidos(i, 6)) Or _
               IsEmpty(dataPedidos(i, 7)) Or IsEmpty(dataPedidos(i, 8)) Or _
               IsEmpty(dataPedidos(i, 9)) Then
                
                ' Cadena con los nombres de los campos vac�os
                If Not IsNumeric(dataPedidos(i, 3)) Then
                    camposFaltantes = "Columna 3 (Cuenta), "
                End If
                If IsEmpty(dataPedidos(i, 5)) Then
                    camposFaltantes = camposFaltantes & "Columna 5 (Caja), "
                End If
                If IsEmpty(dataPedidos(i, 6)) Then
                    camposFaltantes = camposFaltantes & "Columna 6 (Descripci�n), "
                End If
                If IsEmpty(dataPedidos(i, 7)) Then
                    camposFaltantes = camposFaltantes & "Columna 7 (Precio), "
                End If
                If IsEmpty(dataPedidos(i, 8)) Then
                    camposFaltantes = camposFaltantes & "Columna 8 (Cantidad M�nima), "
                End If
                If IsEmpty(dataPedidos(i, 9)) Then
                    camposFaltantes = camposFaltantes & "Columna 9 (Calidad), "
                End If
                
                camposVacios = True
                Exit For
            End If
        End If
    Next i
    
    ' Mostrar mensaje si alg�n campo est� vac�o
    If camposVacios Then
        MsgBox "�Los siguientes campos est�n vac�os en la hoja de PEDIDOS: " & Left(camposFaltantes, Len(camposFaltantes) - 2) & "! No se pudo generar el r�tulo.", vbExclamation
        Exit Sub
    End If
    
    ' Encuentra la �ltima fila ocupada en la columna A
    Dim UltimaFila As Long
    UltimaFila = wsRotulo.Cells(Rows.Count, "A").End(xlUp).Row
    
    ' Insertar una fila en blanco debajo de la �ltima fila ocupada
    wsRotulo.Rows(UltimaFila + 1).Insert Shift:=xlDown
    
    ' Insertar filas al final de la hoja
    wsRotulo.Rows(UltimaFila + 2 & ":" & UltimaFila + 1 + UBound(dataPedidos, 1)).Insert Shift:=xlDown
    
    ' Llenar la informaci�n en las filas insertadas
    For i = LBound(dataPedidos, 1) To UBound(dataPedidos, 1)
        If dataPedidos(i, 2) = nro_cotiz And IsNumeric(dataPedidos(i, 3)) Then
            wsRotulo.Cells(UltimaFila + 2, 1).Value = dataPedidos(i, 5)
            wsRotulo.Cells(UltimaFila + 2, 2).Value = dataPedidos(i, 6)
            wsRotulo.Cells(UltimaFila + 2, 3).Value = dataPedidos(i, 7)
            wsRotulo.Cells(UltimaFila + 2, 4).Value = dataPedidos(i, 8)
            wsRotulo.Cells(UltimaFila + 2, 5).Value = dataPedidos(i, 9)
    
            ' Aplicar estilo de fuente no negrita a las celdas de la fila insertada
            wsRotulo.Rows(UltimaFila + 2).Font.Bold = False
            UltimaFila = UltimaFila + 1 ' Incrementa la fila para la siguiente iteraci�n
        End If
    Next i
    
    ' Agregar la fecha actual en E3
    wsRotulo.Range("E3").Value = Date
    
    ' A�adir el r�tulo al final del informe
    Dim ultimaFilaInforme As Long
    ultimaFilaInforme = wsRotulo.Cells(Rows.Count, "A").End(xlUp).Row
    
    ' Insertar filas para el r�tulo
    
    ' Insertar una fila en blanco debajo de la �ltima fila ocupada
    wsRotulo.Rows(ultimaFilaInforme + 1).Insert Shift:=xlDown
    wsRotulo.Rows(ultimaFilaInforme + 2 & ":" & ultimaFilaInforme + 9).Insert Shift:=xlDown
    
    ' Escribir el r�tulo en las filas insertadas
    wsRotulo.Range("A" & ultimaFilaInforme + 2 & ":E" & ultimaFilaInforme + 9).Merge
    wsRotulo.Range("A" & ultimaFilaInforme + 2 & ":E" & ultimaFilaInforme + 9).Value = _
    "Las cantidades al momento de la entrega pueden tener una variaci�n de +- 7%." & vbCrLf & _
    "Precios por unidad: no incluyen IVA. | Validez de la oferta: 7 d�as." & vbCrLf & _
    " " & vbCrLf & _
    "Por favor, confirmar precio y cantidades para el correcto procesamiento del pedido." & vbCrLf & _
    " " & vbCrLf & _
    "Consultas o pedidos: info@embalajessrl.com.ar | ventas@embalajessrl.com.ar | comercial@embalajessrl.com.ar" & vbCrLf & _
    "Tel: +54 9 (341) 5477026"
    
    ' Aplicar estilos de fuente al r�tulo
    With wsRotulo.Range("A" & ultimaFilaInforme + 2 & ":E" & ultimaFilaInforme + 9).Font
        .Bold = True ' Puedes cambiar a False si no quieres negrita
        .Color = RGB(0, 0, 0) ' Puedes cambiar los valores RGB seg�n tus preferencias
        .Size = 10 ' Tama�o de la fuente
    End With
    
    ' A�adir bordes al r�tulo
    With wsRotulo.Range("A" & ultimaFilaInforme + 2 & ":E" & ultimaFilaInforme + 9).Borders(xlEdgeTop)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlThin
    End With
    With wsRotulo.Range("A" & ultimaFilaInforme + 2 & ":E" & ultimaFilaInforme + 9).Borders(xlEdgeBottom)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlThin
    End With
    With wsRotulo.Range("A" & ultimaFilaInforme + 2 & ":E" & ultimaFilaInforme + 9).Borders(xlEdgeLeft)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlThin
    End With
    With wsRotulo.Range("A" & ultimaFilaInforme + 2 & ":E" & ultimaFilaInforme + 9).Borders(xlEdgeRight)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlThin
    End With
    
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
End Sub
' BOTON PARA BORRAR EL LISTADO
Private Sub CommandButton1_Click()
    Dim wsRotulo As Worksheet
    Dim UltimaFila As Long
    
    ' Hoja de c�lculo a tomar
    Set wsRotulo = Worksheets("ROTULO")
    
    ' Elimina las filas de la 10 a la 100
    wsRotulo.Rows("10:100").Delete
    
    ' Establecer la variable de control en True despu�s de borrar
    borrarRealizado = True
    
    MsgBox "Filas borradas exitosamente.", vbInformation
End Sub


' BOTON PARA SELECCIONAR EL INFORME GENERADO AUTOMATICAMENTE

Private Sub SeleccionarRango_Click()
    Dim wsRotulo As Worksheet
    Dim UltimaFila As Long
    
    ' Hoja de c�lculo a tomar
    Set wsRotulo = Worksheets("ROTULO")
    
    ' Encuentra la �ltima fila ocupada en la columna A
    UltimaFila = wsRotulo.Cells(Rows.Count, "A").End(xlUp).Row
    
    ' Seleccionar el rango desde A1 hasta la �ltima fila del r�tulo
    Dim RangoInforme As Range
    Set RangoInforme = wsRotulo.Range("A1:E" & UltimaFila)
    RangoInforme.Select
    
    ' Agregar borde alrededor del rango seleccionado
    RangoInforme.BorderAround LineStyle:=xlContinuous, Weight:=xlThin, Color:=RGB(0, 0, 0) ' Estilo de l�nea continuo, grosor mediano, color negro
End Sub

' BOTON PARA GENERAR PDF

Private Sub ImprimirAFormatoPDF_Click()
    Dim RangoSeleccionado As Range
    Dim NombreArchivoPDF As String
    Dim NumCotizacion As Variant
    Dim NombreCliente As String
    Dim CeldaNumCotizacion As Range
    
     Application.ScreenUpdating = False
    
    ' Obtener el n�mero de cotizaci�n y el nombre del cliente
    NumCotizacion = Worksheets("ROTULO").Range("B4").Value
    NombreCliente = Worksheets("ROTULO").Range("A3").Value
    
    ' Verifica si hay alguna selecci�n
    On Error Resume Next
    Set RangoSeleccionado = Selection
    On Error GoTo 0

    ' Buscar la celda que contiene el n�mero de cotizaci�n en el rango seleccionado
    Set CeldaNumCotizacion = RangoSeleccionado.Find(NumCotizacion, LookIn:=xlValues)
    
    If CeldaNumCotizacion Is Nothing Then
        MsgBox "No fue seleccionado el informe para poder generar el PDF. Por favor hacer click en - Seleccionar Informe -.", vbExclamation
        Exit Sub
    End If
    
    ' Genera el nombre del archivo PDF con el n�mero de cotizaci�n y el nombre del cliente
    NombreArchivoPDF = NumCotizacion & "_" & NombreCliente & ".pdf"
    
    ' Pide al usuario el nombre del archivo PDF y la ubicaci�n
    NombreArchivoPDF = Application.GetSaveAsFilename(FileFilter:="Archivos PDF (*.pdf), *.pdf", _
                                                      Title:="Guardar como PDF", _
                                                      InitialFileName:=NombreArchivoPDF)
    
    ' Comprueba si el usuario ha cancelado
    If NombreArchivoPDF = "Falso" Then
        Exit Sub
    End If
    
    ' Imprime el rango seleccionado en el archivo PDF
    RangoSeleccionado.ExportAsFixedFormat Type:=xlTypePDF, Filename:=NombreArchivoPDF
    
    MsgBox "El archivo PDF se ha creado exitosamente.", vbInformation
    
     Application.ScreenUpdating = True
End Sub

