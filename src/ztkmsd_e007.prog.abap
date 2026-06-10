*&----------------------------------------------------------------------
*&
*&----------------------------------------------------------------------
*& RICEF ID             : ESD-01
*& Program Name         : ZTKMSD_E001
*& Functional Designer  :
*& ABAP Developer       : Sukardi
*& Creation Date        : 15.04.2018
*& SAP Release          : ECC6.0
*& Description          :
*&
*&---------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&---------------------------------------------------------------------*
*& Log  TR          FUNCTIONAL  ABAPER    DESCRIPTION
*&---------------------------------------------------------------------*
*& 001
*&
*&---------------------------------------------------------------------*
REPORT  ztkmsd_e004 NO STANDARD PAGE HEADING
                     LINE-SIZE 255.

*------------------common TOP includes for the program----------------*

INCLUDE ztkmsd_e007top.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS    : p_vkorg TYPE ztkmsddt001-vkorg DEFAULT '8800',
                p_tplst LIKE ztkmsddt001-tplst DEFAULT '8001' NO-DISPLAY.
SELECTION-SCREEN SKIP 1.
PARAMETERS : p_scanid    LIKE ztkmsddt001-scanid NO-DISPLAY,
             p_nortm     LIKE ztkmsddt001-nortm NO-DISPLAY,
             p_tknum(10) OBLIGATORY.
SELECTION-SCREEN SKIP 1.
PARAMETERS : p_route LIKE vttk-route.
SELECTION-SCREEN COMMENT 45(35) p_bezei.
SELECTION-SCREEN SKIP 1.
PARAMETERS : p_date LIKE sy-datum DEFAULT sy-datum NO-DISPLAY,
             p_time LIKE sy-uzeit DEFAULT sy-uzeit NO-DISPLAY.

SELECTION-SCREEN END OF BLOCK block1.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_free_data.
*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name = 'P_VKORG'.
      screen-input = '0'.
    ENDIF.
    IF screen-name = 'P_TPLST'.
      screen-input = '0'.
    ENDIF.
    IF screen-name = 'P_SCANID'.
      screen-input = '0'.
    ENDIF.
    IF screen-name = 'P_NORTM'.
      screen-input = '0'.
    ENDIF.
    IF screen-name = 'P_ROUTE'.
      screen-input = '0'.
    ENDIF.
    IF screen-name = 'P_DATE'.
      screen-input = '0'.
    ENDIF.
    IF screen-name = 'P_TIME'.
      screen-input = '0'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

AT SELECTION-SCREEN.

**AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_tknum.
**  REFRESH gt_tknum.
**  SELECT  * INTO CORRESPONDING FIELDS OF TABLE gt_tknum FROM ztkmsddt006
**     WHERE status = 'B'.
**
**  gv_retfield = 'TKNUM'.
**  gv_dynprofld = 'P_TKNUM'.
**  PERFORM f_get_f4 TABLES gt_tknum  USING  gv_retfield gv_dynprofld '' ''.

AT SELECTION-SCREEN ON p_tknum.
  CLEAR: gv_message, gv_time, gv_date, gv_error.
  SELECT SINGLE kunnr INTO gv_kunnr FROM vttk AS a JOIN vttp AS b ON a~tknum = b~tknum
    JOIN likp AS c ON b~vbeln = c~vbeln
    WHERE a~tknum = p_tknum.
  IF sy-subrc EQ 0.
    IF gv_kunnr(3) = 'TBA'.
      gv_vkbur = gv_kunnr+3(4).
      AUTHORITY-CHECK OBJECT 'ZV_VBKAVKO'
          ID 'VKBUR' FIELD gv_vkbur.
      IF sy-subrc NE 0.
        MESSAGE e002(zz) WITH 'You are not authorized with Sales Office'
         gv_vkbur.
        gv_error = 'E'.
      ENDIF.
    ENDIF.
  ELSE.
    CONCATENATE 'Shipment No. ' p_tknum 'tidak ditemukan' INTO gv_message SEPARATED BY space.
    gv_error = 'E'.
  ENDIF.

  CLEAR: gv_message, gv_time, gv_date, gv_error.
  SELECT SINGLE * FROM ztkmsddt006
     WHERE tknum = p_tknum. " AND  status NE 'U'.
  IF sy-subrc EQ 0.
    CASE ztkmsddt006-status.
      WHEN 'U'.
        gv_error = 'E'.
        WRITE ztkmsddt006-cabtime TO gv_time.
        WRITE ztkmsddt006-cabdate TO gv_date.
        CONCATENATE 'Sdh Bongkar oleh ' ztkmsddt006-cabname 'Tgl' gv_date '-' gv_time
        INTO gv_message SEPARATED BY space.
      WHEN 'X'.
        gv_error = 'E'.
        WRITE ztkmsddt006-cendtime TO gv_time.
        WRITE ztkmsddt006-cenddate TO gv_date.
        CONCATENATE 'Sdh Selesai -' ztkmsddt006-cendname 'Tgl' gv_date '-' gv_time
        INTO gv_message SEPARATED BY space.
      WHEN 'B'.
        SELECT SINGLE a~route bezei tplst INTO (p_route, p_bezei, p_tplst)
             FROM vttk AS a JOIN tvrot AS b ON a~route = b~route
             WHERE tknum = p_tknum AND spras = sy-langu.
    ENDCASE.
  ELSE.
    CONCATENATE 'Shipment Number ' p_tknum 'Belum Daftar' INTO gv_message SEPARATED BY space.
    gv_error = 'E'.
  ENDIF.
  IF  gv_error = 'E'.
    MESSAGE e004(zab) WITH gv_message.
  ENDIF.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  DATA: l_answer(1), l_mess(100).
  CONCATENATE 'Apakah Shipment ' p_tknum 'dengan route' p_route '-' p_bezei 'yang diproses ?' INTO l_mess SEPARATED BY space.
  PERFORM f_lock_table.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'PERHATIAN'
      text_question         = l_mess
      text_button_1         = 'Ya'
      icon_button_1         = 'ICON_CHECKED'
      text_button_2         = 'Tidak'
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '2'
      display_cancel_button = ''
    IMPORTING
      answer                = l_answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

  IF l_answer = '1'.
    PERFORM f_proses_pick.
  ELSE.
    WRITE: / 'Batal Bongkar'.
  ENDIF.
  PERFORM f_unlock_table.
  PERFORM f_free_data.

END-OF-SELECTION.

*------------------common Routine includes for the program----------------*
  INCLUDE ztkmsd_e007f01.
