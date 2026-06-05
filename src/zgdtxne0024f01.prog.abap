*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE0024F01                                           *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen.
  IF p_vbeln NE space AND p_faktur NE space.
    MESSAGE e000(zab) WITH 'Choose to fill either'
                          '"Billing Number" or "Faktur Pajak Number".'
                          'Do NOT fill both of them'.
  ENDIF.
ENDFORM.                    " F_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.

  IF p_vbeln NE space AND
    p_faktur EQ space AND
    p_coret EQ space.
    PERFORM f_del_sederhana.
  ELSEIF p_vbeln EQ space AND
    p_faktur NE space AND
    p_coret EQ space.
    PERFORM f_del_standard.
  ELSEIF p_vbeln EQ space AND
    p_faktur EQ space AND
    p_coret NE space.
    PERFORM f_del_coretax.
  ENDIF.

  IF d_subrc NE 0.
    MESSAGE i000(zab) WITH 'DATA NOT FOUND,'
                          'Enter the correct parameters'.
  ENDIF.

* Add by budi 08/02/2007
  LOOP AT t_00002.
    IF t_00002-masatx(4) LE 2006.
      MESSAGE i000(zab) WITH 'Year GE 2007 only'.
      STOP.
    ENDIF.
  ENDLOOP.
* End Add by budi 08/02/2007

ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_data.

  PERFORM f_build_fieldcat_har   USING   t_fieldcat[].
  PERFORM f_build_layout_har     USING   d_layout.
*  PERFORM f_build_sortfield_har  USING   t_sort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_event_har      TABLES  t_events[].

  d_repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      is_layout                = d_layout
      it_fieldcat              = t_fieldcat[]
      it_sort                  = t_sort[]
      i_default                = 'X'
      i_save                   = 'A'
      it_events                = t_events[]
      it_event_exit            = t_event_exit[]
      is_print                 = d_print
    TABLES
      t_outtab                 = t_00002[]
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

ENDFORM.                    " F_WRITE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DEL_SEDERHANA
*&---------------------------------------------------------------------*
*\\ delete faktur pajak sederhana from table zGDTXdt0002
*\\ Faktur pajak sederhana is indicated by field FAKTURNO = blank
*----------------------------------------------------------------------*
FORM f_del_sederhana.

  REFRESH: t_00002.

  SELECT
***modified by Rahmadi
*        vkorg
*        gsber
*        spart
        bukrs
        brnch
        busln
***end of modification
        vbeln gjahr fakturno bilref masatx matnr files
        INTO CORRESPONDING FIELDS OF TABLE t_00002
        FROM zgdtxdt0002
        WHERE ( vbeln    = p_vbeln   OR
                bilref   = p_vbeln ) AND
                fakturno = space     AND
***modified by Rahmadi
*                vkorg    = p_vkorg   AND
*                spart    = p_spart   AND
*                gsber    = p_gsber.
                bukrs    = p_bukrs   AND
                busln    = p_busln   AND
                brnch    = p_brnch.
***end of modification
  d_subrc = sy-subrc.

ENDFORM.                    " F_DEL_SEDERHANA

*&---------------------------------------------------------------------*
*&      Form  F_DEL_STANDARD
*&---------------------------------------------------------------------*
*\\ delete faktur pajak standard from table zGDTXdt0002
*\\ Faktur pajak standard is indicated by field FAKTURNO is not blank
*----------------------------------------------------------------------*
FORM f_del_standard.
  DATA : lv_subrc   TYPE sy-subrc.

  REFRESH: t_00002.

  IF p_faktur+3(1) EQ '.' AND
    p_faktur+7(1) EQ '-' AND
    p_faktur+10(1) EQ '.'.
    REPLACE '-' WITH space INTO p_faktur.
    DO 2 TIMES.
      REPLACE '.' WITH space INTO p_faktur.
    ENDDO.
    CONDENSE p_faktur NO-GAPS.
  ELSE.
    REPLACE '-' WITH space INTO p_faktur.
    CLEAR lv_subrc.
    WHILE lv_subrc IS INITIAL.
      REPLACE '.' WITH space INTO p_faktur.
      lv_subrc = sy-subrc.
    ENDWHILE.
    CONDENSE p_faktur NO-GAPS.
  ENDIF.

  SELECT SINGLE faktur_type files
         INTO (d_fakturtype, d_files)
         FROM zgdtxdt0003
         WHERE fakturno = p_faktur   AND
***modified by Rahmadi
*               vkorg    = p_vkorg    AND
*               spart    = p_spart    AND
*               gsber    = p_gsber.
               bukrs    = p_bukrs    AND
               busln    = p_busln    AND
               brnch    = p_brnch.
***end of modification

  d_subrc = sy-subrc.

  IF d_files IS INITIAL.
    IF d_subrc EQ 0.
      CASE d_fakturtype.
        WHEN 'S'.
          PERFORM f_satuan USING p_faktur.
        WHEN 'G'.
          PERFORM f_gabungan.
        WHEN 'A' OR 'I' OR 'Q'.
          PERFORM f_pecah.
      ENDCASE.
    ENDIF.

    PERFORM f_modify_faktur_number USING ''.
  ELSE.
    MESSAGE 'Faktur sudah diproses eFaktur' TYPE 'E'.
  ENDIF.

ENDFORM.                    " F_DEL_STANDARD

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT_HAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_FIELDCAT[]  text
*----------------------------------------------------------------------*
FORM f_build_fieldcat_har USING fu_fieldcat TYPE slis_t_fieldcat_alv.

  IF p_faktur EQ space.
    PERFORM f_fieldcat USING  fu_fieldcat :
***modified by Rahmadi
*     'VKORG'    06  'X' 'CODE' 'CODE' ''
*                ''  ''  'L' 'X' '' '' '' '' '' '',
*     'GSBER'    06  'X' 'AREA' 'AREA' ''
*                ''  ''  'L' 'X' '' '' ''  '' '' '',
*     'SPART'    05  'X' 'DIV.' 'DIV.' ''
*                ''  ''  'L' '' '' '' '' '' '' '',
     'BUKRS'    06  'X' 'COMPANY' 'COMPANY' ''
                ''  ''  'L' 'X' '' '' '' '' '' '',
     'BRNCH'    06  'X' 'BRANCH' 'BRANCH' ''
                ''  ''  'L' 'X' '' '' ''  '' '' '',
     'BUSLN'    05  'X' 'BUS. LINE' 'BUS. LINE' ''
                ''  ''  'L' '' '' '' '' '' '' '',
***end of modification
     'VBELN'    10  '' 'BILLING' 'BILLING' ''
                ''  'X'  'R' 'X' 'X' '' '' '' '' '' ,
     'GJAHR'    06  '' 'FISCAL' 'FISCAL' ''
                ''  'X'  'R' '' '' '' '' '' '' '' ,
     'FAKTURNO1' 18  '' 'FAKTUR NUMBER' 'FAKTUR NUMBER' ''
                ''  'X'  'R' '' '' '' '' '' '' '' ,
     'BILREF '  11  '' 'CANCEL BILL' 'CANCEL BILL' ''
                ''  'X'  'R' '' '' '' '' '' '' '' .
  ELSEIF p_vbeln EQ space.
    PERFORM f_fieldcat USING  fu_fieldcat :
***modified by Rahmadi
*     'VKORG'    06  'X' 'CODE' 'CODE' ''
*                ''  ''  'L' 'X' '' '' '' '' '' '',
*     'GSBER'    06  'X' 'AREA' 'AREA' ''
*                ''  ''  'L' 'X' '' '' ''  '' '' '',
*     'SPART'    05  'X' 'DIV.' 'DIV.' ''
*                ''  ''  'L' '' '' '' '' '' '' '',
     'BUKRS'    06  'X' 'COMPANY' 'COMPANY' ''
                ''  ''  'L' 'X' '' '' '' '' '' '',
     'BRNCH'    06  'X' 'BRANCH' 'BRANCH' ''
                ''  ''  'L' 'X' '' '' ''  '' '' '',
     'BUSLN'    05  'X' 'BUS. LINE' 'BUS. LINE' ''
                ''  ''  'L' '' '' '' '' '' '' '',
***end of modification
     'VBELN'    10  '' 'BILLING' 'BILLING' ''
                ''  'X'  'R' 'X' 'X' '' '' '' '' '' ,
     'GJAHR'    06  '' 'FISCAL' 'FISCAL' ''
                ''  'X'  'R' '' '' '' '' '' '' '' ,
     'FAKTURNO1' 19  '' 'FAKTUR NUMBER' 'FAKTUR NUMBER' ''
                ''  'X'  'R' '' '' '' '' '' '' '' ,
     'MATNR'    18  '' 'MATERIAL NUMBER' 'MATERIAL NUMBER' ''
                ''  'X'  'R' '' '' '' '' '' '' '' .
  ENDIF.

ENDFORM.                    " F_BUILD_FIELDCAT_HAR

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcat USING fu_fieldcat TYPE slis_t_fieldcat_alv
                      fu_fieldname
                      fu_outputlen
                      fu_no_sign
                      fu_seltext_l
                      fu_reptext_ddic
                      fu_quantity
                      fu_datatype
                      fu_do_sum
                      fu_just
                      fu_key
                      fu_hotspot
                      fu_currency
                      fu_no_zero
                      fu_decimals_out
                      fu_ref_field
                      fu_ref_table.


  DATA: lt_fieldcat TYPE slis_fieldcat_alv.

  CLEAR lt_fieldcat.
  lt_fieldcat-fieldname      = fu_fieldname.
  lt_fieldcat-outputlen      = fu_outputlen.
  lt_fieldcat-no_sign        = fu_no_sign.
  lt_fieldcat-seltext_l      = fu_seltext_l.
  lt_fieldcat-reptext_ddic   = fu_reptext_ddic.
  lt_fieldcat-quantity       = fu_quantity.
  lt_fieldcat-datatype       = fu_datatype.
  lt_fieldcat-do_sum         = fu_do_sum.
  lt_fieldcat-just           = fu_just.
  lt_fieldcat-key            = fu_key.
  lt_fieldcat-hotspot        = fu_hotspot.
  lt_fieldcat-currency       = fu_currency.
  lt_fieldcat-no_zero        = fu_no_zero.
  lt_fieldcat-decimals_out   = fu_decimals_out.
  lt_fieldcat-ref_fieldname  = fu_ref_field.
  lt_fieldcat-ref_tabname    = fu_ref_table.
  APPEND lt_fieldcat TO fu_fieldcat.

ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT_HAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_build_layout_har USING fu_layout TYPE slis_layout_alv.

  fu_layout-f2code             = 'F2'.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-totals_text        = ''.
  fu_layout-key_hotspot        = 'X'.

ENDFORM.                    " F_BUILD_LAYOUT_HAR

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_build_event_exit.

  t_event_exit-ucomm = '&OUP'. "sort up
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
  CLEAR t_event_exit.

  t_event_exit-ucomm = '&ODN'. "sort down
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
  CLEAR t_event_exit.

ENDFORM.                    " F_BUILD_EVENT_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_HAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_EVENTS[]  text
*----------------------------------------------------------------------*
FORM f_build_event_har TABLES ft_events LIKE t_events.

  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_HEADER'.
  APPEND ft_events.

ENDFORM.                    " F_BUILD_EVENT_HAR

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm    LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  CASE fu_ucomm.
    WHEN 'F2'.
      IF fu_selfield-fieldname = 'VBELN'.
        SET PARAMETER ID 'VF' FIELD fu_selfield-value.
        CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN '&DEL'.
      PERFORM f_popup.
  ENDCASE.

ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_header.

  DATA ld_butxt LIKE t001-butxt.

  FORMAT RESET.
  SELECT SINGLE butxt
         INTO ld_butxt
         FROM t001
         WHERE bukrs = p_bukrs.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING ld_butxt.
  PERFORM f_hdr_line2 USING '  BATAL FAKTUR PAJAK'.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
  SKIP 1.

ENDFORM.                    " F_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_SET_PF_STATUS
*&---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD' .
ENDFORM.                                               " F_SET_PF_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_POPUP
*&---------------------------------------------------------------------*
*\\ pop-up confirmation dialog before delete selected data
*----------------------------------------------------------------------*
FORM f_popup.

  DATA: ld_answer(1)     TYPE c,
        ld_question(100) TYPE c
                   VALUE 'Do you really want to delete the records ?'.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Delete Confirmation '
      text_question         = ld_question
      text_button_1         = 'Yes'
      icon_button_1         = 'ICON_OKAY '
      text_button_2         = 'No'
      icon_button_2         = 'ICON_DISCONNECT '
      default_button        = '1'
      display_cancel_button = 'X'
      start_column          = 25
      start_row             = 6
    IMPORTING
      answer                = ld_answer.

  IF ld_answer = '1'.
    IF p_vbeln NE space AND
      p_faktur EQ space AND
      p_coret EQ space.
      PERFORM f_delete_records_sederhana.
    ELSEIF p_vbeln EQ space AND
      p_faktur NE space AND
      p_coret EQ space.
      PERFORM f_delete_records_standard.
    ELSEIF p_vbeln EQ space AND
      p_faktur EQ space AND
      p_coret NE space.
      PERFORM f_delete_records_coretax.
    ENDIF.
  ELSE.
    sy-lsind = 0.
  ENDIF.

ENDFORM.                    " F_POPUP

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_RECORDS_SEDERHANA
*&---------------------------------------------------------------------*
*\\ delete records for faktur pajak sederhana from ZGDTXdt0002
*\\ but save the records first into ZGDTXdt0011
*----------------------------------------------------------------------*
FORM f_delete_records_sederhana.

  DATA: ld_total_delete(6)  TYPE c,
        ld_cancel_delete(6) TYPE c VALUE '0',
        ld_message_del(100) TYPE c,
        ld_cancel_del(65)   TYPE c.

  IF NOT t_00002[] IS INITIAL.
    CLEAR: d_total_delete, d_cancel_delete.

    LOOP AT t_00002.
      IF t_00002-files IS NOT INITIAL.
        CONTINUE.
      ELSE.
        DELETE FROM zgdtxdt0002 WHERE ( vbeln  = p_vbeln OR
                                          bilref = p_vbeln ).
        IF sy-subrc EQ 0.
          ADD 1 TO d_total_delete.
          MOVE 'X' TO t_00002-flag.
          MODIFY t_00002 TRANSPORTING flag.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF d_total_delete NE 0.
    IF d_total_delete EQ 1.
      CONCATENATE d_total_delete
                  'record has been deleted from ZGDTXdt0002.'
                  INTO d_message_del SEPARATED BY space.
    ELSE.
      CONCATENATE d_total_delete
                  'records have been deleted from ZGDTXdt0002.'
                  INTO d_message_del SEPARATED BY space.
    ENDIF.
    PERFORM f_dialog_confirm.
    IF sy-ucomm = 'GBCK'.
      LEAVE TO SCREEN 0.
    ENDIF.
  ELSE.
    MESSAGE e000(zab) WITH 'Data can not be deleted'.
    EXIT.
  ENDIF.

  CLEAR: d_total_delete.

ENDFORM.                    " F_DELETE_RECORDS

*&---------------------------------------------------------------------*
*&      Form  F_SATUAN
*&---------------------------------------------------------------------*
*\\ check for faktur pajak satuan
*\\ indicated by ZGDTXdt0003-FAKTUR_TYPE = 'S'
*----------------------------------------------------------------------*
FORM f_satuan USING fu_faktur.

  SELECT
***modified by Rahmadi
*        vkorg
*        gsber
*        spart
        bukrs
        brnch
        busln
***end of modification
        vbeln gjahr fakturno bilref masatx matnr files
        INTO CORRESPONDING FIELDS OF TABLE t_00002
        FROM zgdtxdt0002
        WHERE fakturno = fu_faktur AND
***modified by Rahmadi
*               vkorg    = p_vkorg    AND
*               spart    = p_spart    AND
*               gsber    = p_gsber.
               bukrs    = p_bukrs    AND
               busln    = p_busln    AND
               brnch    = p_brnch.
***end of modification

  d_subrc = sy-subrc.

ENDFORM.                    " F_SATUAN

*&---------------------------------------------------------------------*
*&      Form  F_GABUNGAN
*&---------------------------------------------------------------------*
*\\ check for faktur pajak gabungan
*\\ indicated by ZGDTXdt0003-FAKTUR_TYPE = 'G'
*----------------------------------------------------------------------*
FORM f_gabungan.

*{   REPLACE        P01K910475                                        1
*\  SELECT
*\***modified by Rahmadi
*\*        vkorg
*\*        gsber
*\*        spart
*\        bukrs
*\        brnch
*\        busln
*\***end of modification
*\        vbeln gjahr fakturno bilref masatx matnr files
*\        INTO CORRESPONDING FIELDS OF TABLE t_00002
*\        FROM zgdtxdt0002
*\        WHERE fakturno = p_faktur AND
*\***modified by Rahmadi
*\*               vkorg    = p_vkorg    AND
*\*               spart    = p_spart    AND
*\*               gsber    = p_gsber.
*\               bukrs    = p_bukrs    AND
*\               busln    = p_busln    AND
*\               brnch    = p_brnch.
*\***end of modification
  "Start SOH: Shell SCI Adjustment 20240223 RZL
  SELECT
***modified by Rahmadi
*        vkorg
*        gsber
*        spart
        bukrs
        brnch
        busln
***end of modification
        vbeln gjahr fakturno bilref masatx matnr files
        INTO CORRESPONDING FIELDS OF TABLE t_00002
        FROM zgdtxdt0002
        WHERE fakturno = p_faktur AND
***modified by Rahmadi
*               vkorg    = p_vkorg    AND
*               spart    = p_spart    AND
*               gsber    = p_gsber.
               bukrs    = p_bukrs    AND
               busln    = p_busln    AND
               brnch    = p_brnch ORDER BY PRIMARY KEY.
***end of modification
  "End SOH: Shell SCI Adjustment 20240223 RZL
*}   REPLACE

  d_subrc = sy-subrc.

ENDFORM.                    " F_GABUNGAN

*&---------------------------------------------------------------------*
*&      Form  F_PECAH
*&---------------------------------------------------------------------*
*\\ check for faktur pajak pecah
*\\ indicated by ZGDTXdt0003-FAKTUR_TYPE = 'A' , 'I', atau 'Q'
*----------------------------------------------------------------------*
FORM f_pecah.

  DATA: ld_vbeln LIKE vbak-vbeln.

  SELECT SINGLE vbeln
         INTO ld_vbeln
         FROM zgdtxdt0002
         WHERE fakturno = p_faktur AND
***modified by Rahmadi
*               vkorg    = p_vkorg    AND
*               spart    = p_spart    AND
*               gsber    = p_gsber.
               bukrs    = p_bukrs    AND
               busln    = p_busln    AND
               brnch    = p_brnch.
***end of modification

  d_subrc = sy-subrc.
  IF sy-subrc EQ 0.
*{   REPLACE        P01K910475                                        1
*\    SELECT
*\***modified by Rahmadi
*\*        vkorg
*\*        gsber
*\*        spart
*\        bukrs
*\        brnch
*\        busln
*\***end of modification
*\          vbeln gjahr fakturno bilref masatx matnr files
*\          INTO CORRESPONDING FIELDS OF TABLE t_00002
*\          FROM zgdtxdt0002
*\          WHERE vbeln    = ld_vbeln AND
*\***modified by Rahmadi
*\*               vkorg    = p_vkorg    AND
*\*               spart    = p_spart    AND
*\*               gsber    = p_gsber.
*\               bukrs    = p_bukrs    AND
*\               busln    = p_busln    AND
*\               brnch    = p_brnch.
*\***end of modification
    "Start SOH: Shell SCI Adjustment 20240223 RZL
    SELECT
***modified by Rahmadi
*        vkorg
*        gsber
*        spart
        bukrs
        brnch
        busln
***end of modification
          vbeln gjahr fakturno bilref masatx matnr files
          INTO CORRESPONDING FIELDS OF TABLE t_00002
          FROM zgdtxdt0002
          WHERE vbeln    = ld_vbeln AND
***modified by Rahmadi
*               vkorg    = p_vkorg    AND
*               spart    = p_spart    AND
*               gsber    = p_gsber.
               bukrs    = p_bukrs    AND
               busln    = p_busln    AND
               brnch    = p_brnch ORDER BY PRIMARY KEY.
***end of modification
    "End SOH: Shell SCI Adjustment 20240223 RZL
*}   REPLACE

  ENDIF.

ENDFORM.                    " F_PECAH

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_RECORDS_STANDARD
*&---------------------------------------------------------------------*
*\\ delete records for faktur pajak standard
*\\ from ZGDTXdt0002 and ZGDTXdt0003
*\\ but save the records first into ZGDTXdt0011
*----------------------------------------------------------------------*
FORM f_delete_records_standard.

  DATA: ld_total_delete(6)  TYPE c,
        ld_cancel_delete(6) TYPE c,
        ld_message_del(100) TYPE c,
        ld_1                TYPE i,
        ld_2                TYPE i,
        ld_obj              LIKE zgdtxdt0005-objrange,
        ld_cancel_del(65)   TYPE c,
        ld_index            LIKE sy-tabix.

  IF NOT t_00002[] IS INITIAL.
    CLEAR: d_total_delete, d_cancel_delete.

    LOOP AT t_00002 .
      IF t_00002-files IS NOT INITIAL.
        CONTINUE.
      ELSE.
        IF t_00002-flag NE 'X'.
          ADD 1 TO ld_index.
          REFRESH: t_00002_insert.
          MOVE-CORRESPONDING t_00002 TO t_00002_insert.
          MOVE sy-mandt TO t_00002_insert-mandt.
          MOVE sy-uname TO t_00002_insert-uname.
          MOVE sy-datum TO t_00002_insert-udate.
          MOVE sy-uzeit TO t_00002_insert-utime.

          IF t_00002-masatx(4) GT 2006.
            SELECT SINGLE objrange
                   INTO ld_obj
                   FROM zgdtxdt0005
                   WHERE bukrs = t_00002-bukrs.
          ELSE.
            SELECT SINGLE objrange
                   INTO ld_obj
                   FROM zgdtxdt0005
                   WHERE fptwo = t_00002-fakturno+6(3).
          ENDIF.

* Add by budi 08/02/2007
          BREAK bcdik.
*        t_00002_insert-fakturno = t_00002-fakturno+6(10).
          t_00002_insert-fakturno = t_00002-fakturno.
* End add by budi 08/02/2007

          t_00002_insert-objrange = ld_obj.
          APPEND t_00002_insert.

          DELETE FROM zgdtxdt0002
                 WHERE vbeln = t_00002-vbeln       AND
                       fakturno = t_00002-fakturno AND
****modified by Rahmadi
*                     vkorg = p_vkorg             AND
*                     gsber = p_gsber             AND
                       bukrs = p_bukrs             AND
                       brnch = p_brnch             AND
****end of modification
                       matnr = t_00002-matnr.

          IF sy-subrc EQ 0.
            ADD 1 TO d_total_delete.
            MOVE 'X' TO t_00002-flag.
            MODIFY t_00002 INDEX ld_index TRANSPORTING flag.
            DELETE FROM zgdtxdt0003
                   WHERE fakturno = t_00002-fakturno AND
****modified by Rahmadi
*                     vkorg = p_vkorg             AND
*                     gsber = p_gsber.
                       bukrs = p_bukrs             AND
                       brnch = p_brnch.
****end of modification

            IF sy-subrc EQ 0.
              INSERT INTO zgdtxdt0011 VALUES t_00002_insert.
            ENDIF.
          ENDIF.
        ELSE.
          MESSAGE e000(zab) WITH 'No data left for being deleted'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF d_total_delete NE 0.
    IF d_total_delete EQ 1.
      CONCATENATE d_total_delete
                  'record has been deleted from ZGDTXdt0002'
                  '& ZGDTXdt0003'
                  INTO d_message_del SEPARATED BY space.
    ELSE.
      CONCATENATE d_total_delete
                  'records have been deleted from ZGDTXdt0002'
                  '& ZGDTXdt0003'
                  INTO d_message_del SEPARATED BY space.
    ENDIF.
    PERFORM f_dialog_confirm.
    IF sy-ucomm = 'GBCK'.
      LEAVE TO SCREEN 0.
    ENDIF.
  ELSE.
    MESSAGE e000(zab) WITH 'Data can not be deleted'.
    EXIT.
  ENDIF.

  CLEAR: d_total_delete.

ENDFORM.                    " F_DELETE_RECORDS_STANDARD

*&---------------------------------------------------------------------*
*&      Form  F_DIALOG_CONFIRM
*&---------------------------------------------------------------------*
*\\ dialog box for displaying record status after delete process is done
*----------------------------------------------------------------------*
FORM f_dialog_confirm.

  CALL FUNCTION 'C14A_POPUP_LIST_DISPLAY'
    EXPORTING
      i_callback            = 'F_WINDOW'
      i_callback_program    = d_repid
      i_title               = 'Process Result !!!!!'
      i_col                 = 15
      i_row                 = 15
      i_width               = 105
      i_height              = 15
    EXCEPTIONS
      no_callback_specified = 1
      OTHERS                = 2.

ENDFORM.                    " F_DIALOG_CONFIRM

*&---------------------------------------------------------------------*
*&      Form  F_WINDOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  pop up window
*  as a report that shows the result of delete process
*----------------------------------------------------------------------*
FORM f_window.

  DATA: ld_counter(4) TYPE n.

  REFRESH t_list.
  SHIFT d_message_del LEFT DELETING LEADING space.
  PERFORM f_header.
  WRITE: / 'Delete process has finished.',
           'This report shows you which documents that have been',
           'deleted.',
           sy-uline,
         / d_message_del,
         / 'Status legend : ',
         /  icon_red_light, ' =  fail  ',
            icon_green_light, ' =  success'.
  SKIP 1.

  LOOP AT t_00002.
    MOVE-CORRESPONDING t_00002 TO t_list.
    IF t_00002-flag = 'X'.
      MOVE d_success TO t_list-status.
      WRITE icon_green_light TO t_list-icon.
    ELSE.
      MOVE d_fail TO t_list-status.
      WRITE icon_red_light TO t_list-icon.
    ENDIF.
    IF d_fakturno <> space.
      t_list-fakturno = t_00002-fakturno1.
    ENDIF.
    APPEND t_list.
  ENDLOOP.

  LOOP AT t_list.
    PERFORM f_intensified.
    IF ld_counter IS INITIAL.
      PERFORM f_write_subheader.
    ENDIF.
    ADD 1 TO ld_counter.
    WRITE: /1(04) ld_counter NO-ZERO COLOR COL_POSITIVE,

***modified by Rahmadi
*             (05) t_list-vkorg COLOR COL_HEADING,
*             (05) t_list-gsber COLOR COL_POSITIVE ,
*             (03) t_list-spart COLOR COL_POSITIVE ,
             (05) t_list-bukrs COLOR COL_HEADING,
             (05) t_list-brnch COLOR COL_POSITIVE ,
             (03) t_list-busln COLOR COL_POSITIVE ,
***end of modification
             (05) t_list-gjahr COLOR COL_POSITIVE,
             (10) t_list-vbeln COLOR COL_POSITIVE,
             (18) t_list-fakturno COLOR COL_POSITIVE.
    IF p_sdh = 'X'.
      WRITE: (10) t_list-bilref COLOR COL_POSITIVE.
    ENDIF.
    WRITE:   (10) t_list-masatx COLOR COL_POSITIVE,
             (10) t_list-status COLOR COL_POSITIVE,
             (06) t_list-icon  COLOR COL_POSITIVE.
  ENDLOOP.

  IF sy-subrc = 0.
    d_flag_intensified = 'X'.
    PERFORM f_intensified.
  ENDIF.

ENDFORM.                    " F_WINDOW

*&---------------------------------------------------------------------*
*&      Form  F_INTENSIFIED
*&---------------------------------------------------------------------*
FORM f_intensified.

  IF d_flag_intensified = 'X'.
    FORMAT INTENSIFIED ON.
    CLEAR d_flag_intensified.
  ELSE.
    FORMAT INTENSIFIED OFF.
    d_flag_intensified = 'X'.
  ENDIF.

ENDFORM.                    " F_INTENSIFIED

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_SUBHEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_subheader.

  WRITE: /1 sy-uline.
  WRITE: /1(04) 'No' COLOR COL_HEADING,
           (05) 'Comp.' COLOR COL_HEADING,
           (05) 'Area' COLOR COL_HEADING,
           (03) 'Div' CENTERED COLOR COL_HEADING,
           (05) 'Tahun' COLOR COL_HEADING,
           (10) 'Billing No.' COLOR COL_HEADING,
           (18) 'Faktur No' CENTERED COLOR COL_HEADING.
  IF p_sdh = 'X'.
    WRITE: (10) 'Reference' RIGHT-JUSTIFIED COLOR COL_HEADING.
  ENDIF.
  WRITE:   (10) 'Masa Pajak' RIGHT-JUSTIFIED COLOR COL_HEADING,
           (10) 'Status' RIGHT-JUSTIFIED COLOR COL_HEADING,
           (04) 'Sign' RIGHT-JUSTIFIED COLOR COL_HEADING.
  WRITE: /1 sy-uline.

ENDFORM.                    " F_WRITE_SUBHEADER

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_screen.

  LOOP AT SCREEN.
    IF screen-name CS 'P_FAKTUR'.
      screen-input = 1.
    ENDIF.
    IF screen-name CS 'P_VBELN'.
      screen-input = 1.
    ENDIF.
    IF screen-name CS 'P_CORET'.
      screen-input = 1.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

  LOOP AT SCREEN.
    IF p_sdh = 'X'.
      p_faktur = ''.
      IF screen-name CS 'P_FAKTUR' OR
        screen-name CS 'P_CORET'.
        screen-input = 0.
      ENDIF.
    ELSEIF p_std = 'X'.
      p_vbeln = ''.
      IF screen-name CS 'P_VBELN' OR
        screen-name CS 'P_CORET'.
        screen-input = 0.
      ENDIF.
    ELSEIF p_cor = 'X'.
      p_coret = ''.
      IF screen-name CS 'P_VBELN' OR
        screen-name CS 'P_FAKTUR'.
        screen-input = 0.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " F_SCREEN

*&---------------------------------------------------------------------*
*&      Form  f_check_tax_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_tax_period CHANGING fc_subrc LIKE sy-subrc.

  DATA ld_status.
  DATA ld_uname LIKE sy-uname.
  DATA: tx04usr LIKE indx-srtfd VALUE 'ZGDTXDT0106'.

  CALL FUNCTION 'Z_GDTXFC_CHECK_TAX_PERIOD'
    IMPORTING
      fe_status                    = ld_status
      fe_uname                     = ld_uname
    EXCEPTIONS
      program_running              = 1
      tax_period_program_not_found = 2
      OTHERS                       = 3.
  fc_subrc = sy-subrc.
  IF fc_subrc <> 0.
    CASE fc_subrc.
      WHEN 1.
        IMPORT zgdtxdt0106-uname FROM MEMORY ID tx04usr.
        ld_uname = zgdtxdt0106-uname.
        MESSAGE i000(zab) WITH 'Tax period program is still locked by'
                               ld_uname.
      WHEN 2.
        MESSAGE i000(zab) WITH 'Please maintain Tax period program to'
                               'ZGDTXDT0106 table'.
    ENDCASE.
    EXIT.
  ENDIF.

ENDFORM.                    " f_check_tax_period

*&---------------------------------------------------------------------*
*&      Form  f_modify_faktur_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_faktur_number USING fu_faktur.
  DATA : lv_faktur(20).

  READ TABLE t_00002 INDEX 1.
  IF sy-subrc EQ 0.
    IF t_00002-fakturno CP '*****-***-*******'.
      t_00002-fakturno1 = t_00002-fakturno.
    ELSE.
*      SELECT SINGLE fakturno
*        FROM zfvatfp
*        INTO lv_faktur
*        WHERE bukrs EQ t_00002-bukrs.
*      IF sy-subrc EQ 0.
*        WRITE t_00002-fakturno TO t_00002-fakturno1
*        USING EDIT MASK lv_faktur.
*      ELSE.
      CONCATENATE t_00002-fakturno(3) '.' t_00002-fakturno+3(3) '-'
                  t_00002-fakturno+6(2) '.' t_00002-fakturno+8(8)
      INTO t_00002-fakturno1.
*      ENDIF.
    ENDIF.

*    IF t_00002-masatx(4) GT 2006.
*      CONCATENATE t_00002-fakturno(3) '.' t_00002-fakturno+3(3) '-'
*                  t_00002-fakturno+6(2) '.' t_00002-fakturno+8(8)
*      INTO t_00002-fakturno1.
*    ELSE.
*      t_00002-fakturno1 = t_00002-fakturno.
*    ENDIF.
  ENDIF.

  IF fu_faktur IS NOT INITIAL.
    t_00002-xfakturno1 = t_00002-fakturno.
    t_00002-fakturno1  = fu_faktur.
  ENDIF.

  MODIFY t_00002 INDEX 1 TRANSPORTING fakturno1 xfakturno1.
ENDFORM.                    " f_modify_faktur_number

*&---------------------------------------------------------------------*
*&      Form  F_DEL_CORETAX
*&---------------------------------------------------------------------*
FORM f_del_coretax .
  DATA : lv_subrc    TYPE sy-subrc.

  REFRESH: t_00002.

  IF p_coret+3(1) EQ '.' AND
    p_coret+7(1) EQ '-' AND
    p_coret+10(1) EQ '.'.
    REPLACE '-' WITH space INTO p_coret.
    DO 2 TIMES.
      REPLACE '.' WITH space INTO p_coret.
    ENDDO.
    CONDENSE p_coret NO-GAPS.
  ELSE.
    REPLACE '-' WITH space INTO p_coret.
    CLEAR lv_subrc.
    WHILE lv_subrc IS INITIAL.
      REPLACE '.' WITH space INTO p_coret.
      lv_subrc = sy-subrc.
    ENDWHILE.
    CONDENSE p_coret NO-GAPS.
  ENDIF.

  SELECT SINGLE fakturno faktur_type files
         INTO (d_fakturno, d_fakturtype, d_files)
         FROM zgdtxdt0003
         WHERE nocoretax = p_coret   AND
               bukrs     = p_bukrs   AND
               busln     = p_busln   AND
               brnch     = p_brnch.

  d_subrc = sy-subrc.

  IF d_subrc EQ 0.
    CASE d_fakturtype.
      WHEN 'S'.
        PERFORM f_satuan USING d_fakturno.
      WHEN 'G'.
        PERFORM f_gabungan.
      WHEN 'A' OR 'I' OR 'Q'.
        PERFORM f_pecah.
    ENDCASE.
  ENDIF.

  PERFORM f_modify_faktur_number USING p_coret.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_RECORDS_CORETAX
*&---------------------------------------------------------------------*
FORM f_delete_records_coretax .
  DATA: ld_total_delete(6)  TYPE c,
        ld_cancel_delete(6) TYPE c,
        ld_message_del(100) TYPE c,
        ld_1                TYPE i,
        ld_2                TYPE i,
        ld_obj              LIKE zgdtxdt0005-objrange,
        ld_cancel_del(65)   TYPE c,
        ld_index            LIKE sy-tabix.

  IF NOT t_00002[] IS INITIAL.
    CLEAR: d_total_delete, d_cancel_delete.

    LOOP AT t_00002 .
      IF t_00002-files IS NOT INITIAL.
        CONTINUE.
      ELSE.
        IF t_00002-flag NE 'X'.
          ADD 1 TO ld_index.
          REFRESH: t_00002_insert.
          MOVE-CORRESPONDING t_00002 TO t_00002_insert.
          MOVE sy-mandt TO t_00002_insert-mandt.
          MOVE sy-uname TO t_00002_insert-uname.
          MOVE sy-datum TO t_00002_insert-udate.
          MOVE sy-uzeit TO t_00002_insert-utime.

          IF t_00002-masatx(4) GT 2006.
            SELECT SINGLE objrange
                   INTO ld_obj
                   FROM zgdtxdt0005
                   WHERE bukrs = t_00002-bukrs.
          ELSE.
            SELECT SINGLE objrange
                   INTO ld_obj
                   FROM zgdtxdt0005
                   WHERE fptwo = t_00002-fakturno+6(3).
          ENDIF.

          t_00002_insert-fakturno  = t_00002-xfakturno1.
          t_00002_insert-objrange  = ld_obj.
          t_00002_insert-nocoretax = t_00002-fakturno1.
          APPEND t_00002_insert.

          DELETE FROM zgdtxdt0002
                 WHERE vbeln    = t_00002-vbeln
                   AND fakturno = t_00002-fakturno
                   AND bukrs    = p_bukrs
                   AND brnch    = p_brnch
                   AND matnr    = t_00002-matnr.

          IF sy-subrc EQ 0.
            ADD 1 TO d_total_delete.
            MOVE 'X' TO t_00002-flag.
            MODIFY t_00002 INDEX ld_index TRANSPORTING flag.
            DELETE FROM zgdtxdt0003
                   WHERE fakturno = t_00002-fakturno
                     AND bukrs    = p_bukrs
                     AND brnch    = p_brnch.
****end of modification

            IF sy-subrc EQ 0.
              INSERT INTO zgdtxdt0011 VALUES t_00002_insert.
            ENDIF.
          ENDIF.
        ELSE.
          MESSAGE e000(zab) WITH 'No data left for being deleted'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF d_total_delete NE 0.
    IF d_total_delete EQ 1.
      CONCATENATE d_total_delete
                  'record has been deleted from ZGDTXdt0002'
                  '& ZGDTXdt0003'
                  INTO d_message_del SEPARATED BY space.
    ELSE.
      CONCATENATE d_total_delete
                  'records have been deleted from ZGDTXdt0002'
                  '& ZGDTXdt0003'
                  INTO d_message_del SEPARATED BY space.
    ENDIF.
    PERFORM f_dialog_confirm.
    IF sy-ucomm = 'GBCK'.
      LEAVE TO SCREEN 0.
    ENDIF.
  ELSE.
    MESSAGE e000(zab) WITH 'Data can not be deleted'.
    EXIT.
  ENDIF.

  CLEAR: d_total_delete.
ENDFORM.
