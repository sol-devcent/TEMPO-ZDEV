*&---------------------------------------------------------------------*
*& Program Name     : ZSSUT_R004                                       *
*& Module Name      : SD                                               *
*& Author           : Aji (SAP_DEV02)                                  *
*& Functional       : Gunawan                                          *
*& Create Date      : 31/10/2013                                       *
*& Program Type     : Transaksi                                        *
*& Transaction      : N/A                                              *
*& SAP Release      : ECC6                                             *
*& Description      : Upload Visitation Matrix for Customer
*&                    from Excel to ZSSUTDT022
*&                    Format Excel sama seperti struktur ZSSUTDT022 tanpa MANDT dan tanpa Header
*&---------------------------------------------------------------------*
*& REVISION LOG                                                        *
*&---------------------------------------------------------------------*
*& 1  EVK936589   Aji  22/10/2013   Initial Creation                   *
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zssut_r004.

DATA: BEGIN OF gt_excel OCCURS 0,
      vkorg	TYPE vkorg,
      vtweg	TYPE vtweg,
      spart	TYPE spart,
      kunnr	TYPE kunnr,
      vkbur	TYPE vkbur,
      kunn2	TYPE kunn2,
      pernr	TYPE pernr_d,
      sun1  TYPE char1,
      mon1  TYPE char1,
      tue1  TYPE char1,
      wed1  TYPE char1,
      thu1  TYPE char1,
      fri1  TYPE char1,
      sat1  TYPE char1,
      sun2  TYPE char1,
      mon2  TYPE char1,
      tue2  TYPE char1,
      wed2  TYPE char1,
      thu2  TYPE char1,
      fri2  TYPE char1,
      sat2  TYPE char1,
      sun3  TYPE char1,
      mon3  TYPE char1,
      tue3  TYPE char1,
      wed3  TYPE char1,
      thu3  TYPE char1,
      fri3  TYPE char1,
      sat3  TYPE char1,
      sun4  TYPE char1,
      mon4  TYPE char1,
      tue4  TYPE char1,
      wed4  TYPE char1,
      thu4  TYPE char1,
      fri4  TYPE char1,
      sat4  TYPE char1,
      sun5  TYPE char1,
      mon5  TYPE char1,
      tue5  TYPE char1,
      wed5  TYPE char1,
      thu5  TYPE char1,
      fri5  TYPE char1,
      sat5  TYPE char1,
      END OF gt_excel.
DATA: gt_022 TYPE TABLE OF zssutdt022 WITH HEADER LINE.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_fname TYPE rlgrap-filename OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(79) text-002.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(79) text-003.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(79) text-004.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(79) text-005.
SELECTION-SCREEN END OF LINE.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fname.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = 'p_fname'
    IMPORTING
      file_name  = p_fname.

AT SELECTION-SCREEN.
  IF p_fname IS NOT INITIAL.
    SEARCH p_fname FOR '.txt'.
    IF sy-subrc NE 0.
      SEARCH p_fname FOR '.TXT'.
      IF sy-subrc NE 0.
        MESSAGE e000(zab) WITH 'Filename harus text file'.
      ENDIF.
    ENDIF.
  ENDIF.

START-OF-SELECTION.
  PERFORM f_upload_data.

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_DATA
*&---------------------------------------------------------------------*
FORM f_upload_data .
  DATA: lv_fname TYPE string.

  MOVE p_fname TO lv_fname.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_fname
      filetype                = 'ASC'
      has_field_separator     = 'X'
    TABLES
      data_tab                = gt_excel[]
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

  IF sy-subrc <> 0.
    MESSAGE 'File error' TYPE 'I'.
    EXIT.
  ENDIF.

  REFRESH gt_022.
  LOOP AT gt_excel.
    CLEAR gt_022.
    MOVE-CORRESPONDING gt_excel TO gt_022.
    PERFORM f_upper_case.
    APPEND gt_022.
  ENDLOOP.

  MODIFY zssutdt022 FROM TABLE gt_022[].
  IF sy-subrc = 0.
    MESSAGE 'Successfully upload data to ZSSUTDT022 (Visitation Matrix table)' TYPE 'I'.
  ELSE.
    MESSAGE 'Error in uploading data to ZSSUTDT022 (Visitation Matrix table)' TYPE 'I'.
  ENDIF.
ENDFORM.                    " F_UPLOAD_DATA

*&---------------------------------------------------------------------*
*&      Form  F_UPPER_CASE
*&---------------------------------------------------------------------*
form F_UPPER_CASE .
    TRANSLATE gt_022-SUN1 TO UPPER CASE.
    TRANSLATE gt_022-MON1 TO UPPER CASE.
    TRANSLATE gt_022-TUE1 TO UPPER CASE.
    TRANSLATE gt_022-WED1 TO UPPER CASE.
    TRANSLATE gt_022-THU1 TO UPPER CASE.
    TRANSLATE gt_022-FRI1 TO UPPER CASE.
    TRANSLATE gt_022-SAT1 TO UPPER CASE.

    TRANSLATE gt_022-SUN2 TO UPPER CASE.
    TRANSLATE gt_022-MON2 TO UPPER CASE.
    TRANSLATE gt_022-TUE2 TO UPPER CASE.
    TRANSLATE gt_022-WED2 TO UPPER CASE.
    TRANSLATE gt_022-THU2 TO UPPER CASE.
    TRANSLATE gt_022-FRI2 TO UPPER CASE.
    TRANSLATE gt_022-SAT2 TO UPPER CASE.

    TRANSLATE gt_022-SUN3 TO UPPER CASE.
    TRANSLATE gt_022-MON3 TO UPPER CASE.
    TRANSLATE gt_022-TUE3 TO UPPER CASE.
    TRANSLATE gt_022-WED3 TO UPPER CASE.
    TRANSLATE gt_022-THU3 TO UPPER CASE.
    TRANSLATE gt_022-FRI3 TO UPPER CASE.
    TRANSLATE gt_022-SAT3 TO UPPER CASE.

    TRANSLATE gt_022-SUN4 TO UPPER CASE.
    TRANSLATE gt_022-MON4 TO UPPER CASE.
    TRANSLATE gt_022-TUE4 TO UPPER CASE.
    TRANSLATE gt_022-WED4 TO UPPER CASE.
    TRANSLATE gt_022-THU4 TO UPPER CASE.
    TRANSLATE gt_022-FRI4 TO UPPER CASE.
    TRANSLATE gt_022-SAT4 TO UPPER CASE.

    TRANSLATE gt_022-SUN5 TO UPPER CASE.
    TRANSLATE gt_022-MON5 TO UPPER CASE.
    TRANSLATE gt_022-TUE5 TO UPPER CASE.
    TRANSLATE gt_022-WED5 TO UPPER CASE.
    TRANSLATE gt_022-THU5 TO UPPER CASE.
    TRANSLATE gt_022-FRI5 TO UPPER CASE.
    TRANSLATE gt_022-SAT5 TO UPPER CASE.

endform.                    " F_UPPER_CASE
