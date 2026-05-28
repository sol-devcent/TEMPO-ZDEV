REPORT zgdmm_e0002 .

  DATA: ld_project(15), ld_event(20), ld_status(1), ld_data TYPE bstkd,
  ld_data1(20).
  DATA: lv_salesdocument TYPE vbeln_va,
        lv_message(255),
        lv_status(1).

SELECTION-SCREEN BEGIN OF BLOCK sele WITH FRAME TITLE TEXT-001.
PARAMETERS: p_oppo  RADIOBUTTON GROUP radi DEFAULT 'X' USER-COMMAND radi,
            p_clspo RADIOBUTTON GROUP radi.
SELECTION-SCREEN END OF BLOCK sele.

TABLES : t134m.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  IF p_clspo IS INITIAL.
    UPDATE t134m SET wertu = 'X'
    WHERE bwkey = '1601' AND mtart = 'ZPCC'.
    IF sy-subrc = '0'.
      MESSAGE i002(zz) WITH
      'Administrasi sedang melakukan switch on PO'.

    ENDIF.
  ELSE.                     "background
    UPDATE t134m SET wertu = ''
    WHERE bwkey = '1601' AND mtart = 'ZPCC'.
    IF sy-subrc = '0'.
      MESSAGE i002(zz) WITH
      'Administrasi sedang melakukan switch off PO'.
      CALL FUNCTION 'ZTWSIT_F0001'
      "          DESTINATION lv_destination "'DEVCLNT800'  "
        EXPORTING
          zproses = 'TNF' "er_entity-zproject  "
          zevent  = 'TNF_GETGR' "er_entity-zevent "
          zdata   = ld_data1 "er_entity-zdata
        IMPORTING
          proses  = ld_project "er_entity-zproject "
          event   = ld_event "er_entity-zevent "
          data    = ld_data1
          status  = ld_status
          message = lv_message.
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.
