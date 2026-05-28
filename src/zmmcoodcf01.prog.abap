*&---------------------------------------------------------------------*
*&  Include           ZMMCOODCF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN
*&---------------------------------------------------------------------*
FORM f_selection-screen .
  CASE 'X'.
    WHEN radio1.
      IF pa_vstel <> '0200'.
        PERFORM f_error_message USING 'PVS'
                                      'Receiving Point should be 0200'.
      ENDIF.
    WHEN radio2.
      IF pa_vstel = '0200'.
        PERFORM f_error_message USING 'PVS'
                                      'Receiving Point cannot be 0200'.
      ENDIF.

    WHEN radio3.
  ENDCASE.
ENDFORM.                    " F_SELECTION-SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection-screen_output .
  DATA : ls_val   TYPE i.
  IF sy-uname <> 'TDS_DEV01'.
    PERFORM f_modify_screen USING : 'DEL' '0' '' '' ''.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      pa_vstel  = '0200'.
      PERFORM f_modify_screen USING : 'PLG' '0' '' '' '',
                                      'PVS' '' '0' '' '',
                                      'SCO' '0' '' '' '',
                                      'SCD' '0' '' '' '',
                                      'SLP' '0' '' '' '',
                                      'SLA' '0' '' '' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'PLG' '0' '' '' '',
                                      'PVS' '' '1' '' '',
                                      'SCO' '0' '' '' '',
                                      'SCD' '0' '' '' '',
                                      'SLP' '0' '' '' '',
                                      'SLA' '0' '' '' ''.
    WHEN radio3 OR radio5 OR radio6.
      PERFORM f_modify_screen USING : 'PLG' '0' '' '' '',
                                      'PVS' '0' '' '' '',
                                      'SMA' '0' '' '' '',
                                      'SEB' '0' '' '' '',
                                      'SBE' '0' '' '' '',
                                      'SLP' '0' '' '' '',
                                      'SLA' '0' '' '' ''.
      IF radio3 IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'SCD' '0' '' '' ''.
      ENDIF.

    WHEN radio4.
      pa_lgnum         = '051'.
      so_lgtyp-low     = '9*'.
      so_lgtyp-sign    = 'E'.
      so_lgtyp-option  = 'CP'.
      APPEND so_lgtyp.

      PERFORM f_modify_screen USING : 'PVS' '0' '' '' '',
                                      'SEB' '0' '' '' '',
                                      'SBE' '0' '' '' '',
                                      'SCO' '0' '' '' '',
                                      'SCD' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_SELECTION-SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_length.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-length  = fu_length.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING   fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_zbdcdt01   LIKE LINE OF gt_zbdcdt01.

  SELECT *
    FROM zbdcdt01
    INTO CORRESPONDING FIELDS OF TABLE gt_zbdcdt01.

  LOOP AT gt_zbdcdt01 INTO  ls_zbdcdt01.
    PERFORM f_add_ranges USING ls_zbdcdt01.
  ENDLOOP.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_ADD_RANGES
*&---------------------------------------------------------------------*
FORM f_add_ranges  USING    fs_zbdcdt01   TYPE zbdcdt01.
  DATA : ls_bsart   LIKE LINE OF gr_bsart1,
         ls_reswk   LIKE LINE OF gr_reswk1,
         ls_ekorg   LIKE LINE OF gr_ekorg1,
         ls_reslo   LIKE LINE OF gr_reslo1,
         ls_eerks   LIKE LINE OF gr_eerks1,
         ls_egort   LIKE LINE OF gr_egort1,
         ls_merks   LIKE LINE OF gr_merks1,
         ls_mgort   LIKE LINE OF gr_mgort1,
         ls_proc    LIKE LINE OF gr_proc.

  CASE fs_zbdcdt01-dbtabname.
    WHEN 'EKKO'.
      CASE fs_zbdcdt01-fieldname.
        WHEN 'BSART'.
          ls_bsart-sign   = fs_zbdcdt01-sign.
          ls_bsart-option = fs_zbdcdt01-opti.
          ls_bsart-low    = fs_zbdcdt01-low.
          ls_bsart-high   = fs_zbdcdt01-high.
          CASE fs_zbdcdt01-zpotyp.
            WHEN '1'.
              APPEND ls_bsart TO gr_bsart.
              APPEND ls_bsart TO gr_bsart1.
            WHEN '2'.
              APPEND ls_bsart TO gr_bsart.
              APPEND ls_bsart TO gr_bsart2.
            WHEN '3'.
              APPEND ls_bsart TO gr_bsart.
              APPEND ls_bsart TO gr_bsart3.
          ENDCASE.
          CLEAR ls_bsart.

        WHEN 'RESWK'.
          ls_reswk-sign   = fs_zbdcdt01-sign.
          ls_reswk-option = fs_zbdcdt01-opti.
          ls_reswk-low    = fs_zbdcdt01-low.
          ls_reswk-high   = fs_zbdcdt01-high.
          CASE fs_zbdcdt01-zpotyp.
            WHEN '1'.
              APPEND ls_reswk TO gr_reswk.
              APPEND ls_reswk TO gr_reswk1.
            WHEN '2'.
              APPEND ls_reswk TO gr_reswk.
              APPEND ls_reswk TO gr_reswk2.
            WHEN '3'.
              APPEND ls_reswk TO gr_reswk.
              APPEND ls_reswk TO gr_reswk3.
          ENDCASE.
          CLEAR ls_reswk.

        WHEN 'EKORG'.
          ls_ekorg-sign   = fs_zbdcdt01-sign.
          ls_ekorg-option = fs_zbdcdt01-opti.
          ls_ekorg-low    = fs_zbdcdt01-low.
          ls_ekorg-high   = fs_zbdcdt01-high.
          CASE fs_zbdcdt01-zpotyp.
            WHEN '1'.
              APPEND ls_ekorg TO gr_ekorg.
              APPEND ls_ekorg TO gr_ekorg1.
            WHEN '2'.
              APPEND ls_ekorg TO gr_ekorg.
              APPEND ls_ekorg TO gr_ekorg2.
            WHEN '3'.
              APPEND ls_ekorg TO gr_ekorg.
              APPEND ls_ekorg TO gr_ekorg3.
          ENDCASE.
          CLEAR ls_ekorg.
      ENDCASE.

    WHEN 'EKPO'.
      CASE fs_zbdcdt01-fieldname.
        WHEN 'RESLO'.
          ls_reslo-sign   = fs_zbdcdt01-sign.
          ls_reslo-option = fs_zbdcdt01-opti.
          ls_reslo-low    = fs_zbdcdt01-low.
          ls_reslo-high   = fs_zbdcdt01-high.
          CASE fs_zbdcdt01-zpotyp.
            WHEN '1'.
              APPEND ls_reslo TO gr_reslo1.
            WHEN '2'.
              APPEND ls_reslo TO gr_reslo2.
            WHEN '3'.
              APPEND ls_reslo TO gr_reslo3.
          ENDCASE.
          CLEAR ls_reslo.

        WHEN 'WERKS'.
          ls_eerks-sign   = fs_zbdcdt01-sign.
          ls_eerks-option = fs_zbdcdt01-opti.
          ls_eerks-low    = fs_zbdcdt01-low.
          ls_eerks-high   = fs_zbdcdt01-high.
          CASE fs_zbdcdt01-zpotyp.
            WHEN '1'.
              APPEND ls_eerks TO gr_eerks1.
            WHEN '2'.
              APPEND ls_eerks TO gr_eerks2.
            WHEN '3'.
              APPEND ls_eerks TO gr_eerks3.
          ENDCASE.
          CLEAR ls_eerks.

        WHEN 'LGORT'.
          ls_egort-sign   = fs_zbdcdt01-sign.
          ls_egort-option = fs_zbdcdt01-opti.
          ls_egort-low    = fs_zbdcdt01-low.
          ls_egort-high   = fs_zbdcdt01-high.
          CASE fs_zbdcdt01-zpotyp.
            WHEN '1'.
              APPEND ls_egort TO gr_egort1.
            WHEN '2'.
              APPEND ls_egort TO gr_egort2.
            WHEN '3'.
              APPEND ls_egort TO gr_egort3.
          ENDCASE.
          CLEAR ls_egort.
      ENDCASE.

    WHEN 'MCHB'.
      CASE fs_zbdcdt01-fieldname.
        WHEN 'WERKS'.
          ls_merks-sign   = fs_zbdcdt01-sign.
          ls_merks-option = fs_zbdcdt01-opti.
          ls_merks-low    = fs_zbdcdt01-low.
          ls_merks-high   = fs_zbdcdt01-high.
          CASE fs_zbdcdt01-zpotyp.
            WHEN '1'.
              APPEND ls_merks TO gr_merks1.
            WHEN '2'.
              APPEND ls_merks TO gr_merks2.
            WHEN '3'.
              APPEND ls_merks TO gr_merks3.
          ENDCASE.
          APPEND ls_merks TO gr_merks.
          CLEAR ls_merks.

        WHEN 'LGORT'.
          ls_mgort-sign   = fs_zbdcdt01-sign.
          ls_mgort-option = fs_zbdcdt01-opti.
          ls_mgort-low    = fs_zbdcdt01-low.
          ls_mgort-high   = fs_zbdcdt01-high.
          CASE fs_zbdcdt01-zpotyp.
            WHEN '1'.
              APPEND ls_mgort TO gr_mgort1.
            WHEN '2'.
              APPEND ls_mgort TO gr_mgort2.
            WHEN '3'.
              APPEND ls_mgort TO gr_mgort3.
          ENDCASE.
          APPEND ls_mgort TO gr_mgort.
          CLEAR ls_mgort.
      ENDCASE.
  ENDCASE.

  ls_proc-sign   = 'I'.
  ls_proc-option = 'EQ'.
  ls_proc-low    = '02'.
  APPEND ls_proc TO gr_proc.
  CLEAR ls_proc.
  ls_proc-sign   = 'I'.
  ls_proc-option = 'EQ'.
  ls_proc-low    = '05'.
  APPEND ls_proc TO gr_proc.
  CLEAR ls_proc.
ENDFORM.                    " F_ADD_RANGES

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_ekpo      TYPE STANDARD TABLE OF ekpo,
         lt_zbdcdt02  TYPE STANDARD TABLE OF zbdcdt02,
         lt_lqua      TYPE STANDARD TABLE OF lqua.

  CASE 'X'.
    WHEN radio3.
      SELECT *
        FROM zbdcdt02
        INTO CORRESPONDING FIELDS OF TABLE gt_zbdcdt02
        WHERE coono IN so_coono
          AND coodt IN so_coodt
          AND zendm = space.

      lt_zbdcdt02[] = gt_zbdcdt02[].
      SORT lt_zbdcdt02 BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_zbdcdt02 COMPARING matnr.
      IF lt_zbdcdt02[] IS NOT INITIAL.
        SELECT mara~matnr mara~meins makt~maktx
          FROM mara JOIN makt ON mara~matnr = makt~matnr
          INTO CORRESPONDING FIELDS OF TABLE gt_makt
          FOR ALL ENTRIES IN lt_zbdcdt02
          WHERE mara~matnr = lt_zbdcdt02-matnr
            AND makt~spras = sy-langu.
      ENDIF.

    WHEN radio4.
      SELECT *
        FROM lqua
        INTO CORRESPONDING FIELDS OF TABLE gt_lqua
        WHERE lgnum = pa_lgnum
          AND matnr IN so_matnr
          AND lgtyp IN so_lgtyp
          AND lgpla IN so_lgpla
          AND bestq = space.

      lt_lqua[] = gt_lqua[].
      SORT lt_lqua BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_lqua COMPARING matnr.
      IF lt_lqua[] IS NOT INITIAL.
        SELECT mara~matnr mara~meins makt~maktx
          FROM mara JOIN makt ON mara~matnr = makt~matnr
          INTO CORRESPONDING FIELDS OF TABLE gt_makt
          FOR ALL ENTRIES IN lt_lqua
          WHERE mara~matnr = lt_lqua-matnr
            AND makt~spras = sy-langu.
      ENDIF.

    WHEN radio5 OR radio6.
      SELECT *
        FROM zbdcdt02
        INTO CORRESPONDING FIELDS OF TABLE gt_zbdcdt02
        WHERE coono IN so_coono.

      lt_zbdcdt02[] = gt_zbdcdt02[].
      SORT lt_zbdcdt02 BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_zbdcdt02 COMPARING matnr.
      IF lt_zbdcdt02[] IS NOT INITIAL.
        SELECT mara~matnr mara~meins makt~maktx
          FROM mara JOIN makt ON mara~matnr = makt~matnr
          INTO CORRESPONDING FIELDS OF TABLE gt_makt
          FOR ALL ENTRIES IN lt_zbdcdt02
          WHERE mara~matnr = lt_zbdcdt02-matnr
            AND makt~spras = sy-langu.
      ENDIF.

    WHEN OTHERS.
      SELECT SINGLE name1
        FROM t001w
        INTO gv_name1
        WHERE werks = pa_vstel.

      SELECT *
        FROM zbdcdt02a
        INTO CORRESPONDING FIELDS OF TABLE gt_zbdcdt02a.
      IF gt_zbdcdt02a[] IS NOT INITIAL.
        SELECT *
          FROM zbdcdt02
          INTO CORRESPONDING FIELDS OF TABLE gt_zbdcdt02
          FOR ALL ENTRIES IN gt_zbdcdt02a
          WHERE coono = gt_zbdcdt02a-coono
            AND matnr IN so_matnr
            AND vbeln_al = space.
      ENDIF.

      SELECT *
        FROM ekko
        INTO CORRESPONDING FIELDS OF TABLE gt_ekko
        WHERE ebeln IN so_ebeln
          AND bsart IN gr_bsart
          AND bedat IN so_bedat
          AND loekz = space
          AND ekorg IN gr_ekorg
          AND bsart IN gr_bsart
          AND procstat IN gr_proc.

      IF gt_ekko[] IS NOT INITIAL.
        SELECT *
          FROM ekpo
          INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
          FOR ALL ENTRIES IN gt_ekko
          WHERE ebeln = gt_ekko-ebeln
            AND loekz = space
            AND matnr IN so_matnr
            AND elikz = space.
      ENDIF.

      IF gt_ekpo[] IS NOT INITIAL.
        SELECT *
          FROM eket
          INTO CORRESPONDING FIELDS OF TABLE gt_eket
          FOR ALL ENTRIES IN gt_ekpo
          WHERE ebeln = gt_ekpo-ebeln
            AND ebelp = gt_ekpo-ebelp.

        SELECT *
          FROM ekpv
          INTO CORRESPONDING FIELDS OF TABLE gt_ekpv
          FOR ALL ENTRIES IN gt_ekpo
          WHERE ebeln = gt_ekpo-ebeln
            AND ebelp = gt_ekpo-ebelp.
      ENDIF.

      lt_ekpo[] = gt_ekpo[].
      SORT lt_ekpo BY ebeln.
      DELETE ADJACENT DUPLICATES FROM lt_ekpo COMPARING ebeln.
      IF lt_ekpo[] IS NOT INITIAL.
      ENDIF.

      lt_ekpo[] = gt_ekpo[].
      SORT lt_ekpo BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_ekpo COMPARING matnr.
      IF lt_ekpo[] IS NOT INITIAL.
        SELECT *
          FROM mard
          INTO CORRESPONDING FIELDS OF TABLE gt_mard
          FOR ALL ENTRIES IN lt_ekpo
          WHERE matnr = lt_ekpo-matnr
            AND werks IN gr_merks
            AND lgort IN gr_mgort.

        SELECT *
          FROM vbbe
          INTO CORRESPONDING FIELDS OF TABLE gt_vbbe
          FOR ALL ENTRIES IN lt_ekpo
          WHERE matnr = lt_ekpo-matnr
            AND werks IN gr_merks
            AND lgort IN gr_mgort.

        SELECT mara~matnr mara~meins makt~maktx
          FROM mara JOIN makt ON mara~matnr = makt~matnr
          INTO CORRESPONDING FIELDS OF TABLE gt_makt
          FOR ALL ENTRIES IN lt_ekpo
          WHERE mara~matnr = lt_ekpo-matnr
            AND makt~spras = sy-langu.

        SELECT *
          FROM marm
          INTO CORRESPONDING FIELDS OF TABLE gt_marm
          FOR ALL ENTRIES IN lt_ekpo
          WHERE matnr = lt_ekpo-matnr
            AND meinh = 'KAR'.

        SELECT *
          FROM mlgn
          INTO CORRESPONDING FIELDS OF TABLE gt_mlgn
          FOR ALL ENTRIES IN lt_ekpo
          WHERE matnr = lt_ekpo-matnr
            AND lgnum = '051'.

        SELECT *
          FROM lqua
          INTO CORRESPONDING FIELDS OF TABLE gt_lqua
          FOR ALL ENTRIES IN lt_ekpo
          WHERE lgnum = '051'
            AND matnr = lt_ekpo-matnr
            AND lgtyp = 'OMB'
            AND bestq = space
            AND verme <> 0.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  TYPES : BEGIN OF ty_docno,
            vbeln   TYPE likp-vbeln,
            ebeln   TYPE ekko-ebeln,
          END OF ty_docno.

  DATA : ls_ekko      LIKE LINE OF gt_ekko,
         ls_ekpo      LIKE LINE OF gt_ekpo,
         ls_list      LIKE LINE OF gt_list,
         ls_makt      LIKE LINE OF gt_makt,
         ls_alvl1     LIKE LINE OF gt_alvl1,
         ls_zbdcdt02  LIKE LINE OF gt_zbdcdt02.

  DATA : lt_1         TYPE STANDARD TABLE OF zbdcst01,
         lt_2         TYPE STANDARD TABLE OF zbdcst01,
         lt_3         TYPE STANDARD TABLE OF zbdcst01,
         lt_1x        TYPE STANDARD TABLE OF zbdcst01,
         lt_2x        TYPE STANDARD TABLE OF zbdcst01,
         lt_3x        TYPE STANDARD TABLE OF zbdcst01.

  DATA : lv_lines     TYPE i,
         lv_tabix     TYPE sy-tabix,
         lv_flag,
         lv_subrc     TYPE sy-subrc,
         lv_menge     TYPE mseg-menge,
         lv_menge1    TYPE mseg-menge.

  DATA : lt_dn        TYPE STANDARD TABLE OF ty_docno,
         ls_dn        LIKE LINE OF lt_dn,
         lt_po        TYPE STANDARD TABLE OF ty_docno,
         ls_po        LIKE LINE OF lt_po.

  DATA : lt_xbdcdt02  TYPE STANDARD TABLE OF zbdcdt02,
         ls_xbdcdt02  LIKE LINE OF lt_xbdcdt02.

  DATA : lt_xlqua     TYPE STANDARD TABLE OF lqua,
         ls_xlqua     LIKE LINE OF lt_xlqua,
         lt_ylqua     TYPE STANDARD TABLE OF lqua,
         ls_ylqua     LIKE LINE OF lt_ylqua,
         ls_lqua      LIKE LINE OF gt_lqua,
         lv_count     TYPE i.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_create_dyn_int_table USING '1'.
    WHEN radio2.
      PERFORM f_create_dyn_int_table USING '1'.
    WHEN radio3.
      PERFORM f_create_dyn_int_table USING '1'.
    WHEN radio4.
      PERFORM f_create_dyn_int_table USING '1'.
    WHEN radio5 OR radio6.
      PERFORM f_create_dyn_int_table USING '1'.
  ENDCASE.

  CASE 'X'.
    WHEN radio3.
      LOOP AT gt_zbdcdt02 INTO ls_zbdcdt02.
        ls_dn-vbeln         = ls_zbdcdt02-vbeln_al.
        APPEND ls_dn TO lt_dn.
        ls_dn-vbeln         = ls_zbdcdt02-vbeln_mk.
        APPEND ls_dn TO lt_dn.
        ls_dn-vbeln         = ls_zbdcdt02-vbeln_fc.
        APPEND ls_dn TO lt_dn.

        ls_po-ebeln         = ls_zbdcdt02-ebeln_al.
        APPEND ls_po TO lt_po.
        ls_po-ebeln         = ls_zbdcdt02-ebeln_mk.
        APPEND ls_po TO lt_po.
        ls_po-ebeln         = ls_zbdcdt02-ebeln_fc.
        APPEND ls_po TO lt_po.
      ENDLOOP.

      SORT lt_dn BY vbeln.
      DELETE lt_dn WHERE vbeln IS INITIAL.
      DELETE ADJACENT DUPLICATES FROM lt_dn COMPARING vbeln.
      IF lt_dn[] IS NOT INITIAL.
        SELECT *
          FROM vbuk
          INTO CORRESPONDING FIELDS OF TABLE gt_vbuk
          FOR ALL ENTRIES IN lt_dn
          WHERE vbeln = lt_dn-vbeln.
      ENDIF.

      SORT lt_po BY ebeln.
      DELETE lt_po WHERE ebeln IS INITIAL.
      DELETE ADJACENT DUPLICATES FROM lt_po COMPARING ebeln.
      IF lt_po[] IS NOT INITIAL.
        SELECT *
          FROM ekpv
          INTO CORRESPONDING FIELDS OF TABLE gt_ekpv
          FOR ALL ENTRIES IN lt_po
          WHERE ebeln = lt_po-ebeln.
      ENDIF.

      lt_xbdcdt02[] = gt_zbdcdt02[].
      SORT lt_xbdcdt02 BY coono.
      DELETE ADJACENT DUPLICATES FROM lt_xbdcdt02 COMPARING coono.

      LOOP AT lt_xbdcdt02 INTO ls_xbdcdt02.
        lv_flag = 'X'.
        LOOP AT gt_zbdcdt02 INTO ls_zbdcdt02 WHERE coono = ls_xbdcdt02-coono.
          IF lv_flag IS INITIAL.
            PERFORM f_style_cell USING '' 'MARK' ''
                                 CHANGING ls_alvl1-style.
          ENDIF.

          ls_alvl1-coono  = ls_zbdcdt02-coono.
          ls_alvl1-coodt  = ls_zbdcdt02-coodt.
          ls_alvl1-cootm  = ls_zbdcdt02-cootm.
          ls_alvl1-coonm  = ls_zbdcdt02-coonm.
          ls_alvl1-zqty   = ls_zbdcdt02-zqty.
          ls_alvl1-posnr  = ls_zbdcdt02-posnr.
          ls_alvl1-matnr  = ls_zbdcdt02-matnr.
          CLEAR ls_makt.
          READ TABLE gt_makt INTO ls_makt
                             WITH KEY matnr = ls_zbdcdt02-matnr.
          IF sy-subrc = 0.
            ls_alvl1-maktx    = ls_makt-maktx.
            ls_alvl1-meins    = ls_makt-meins.
          ENDIF.
          ls_alvl1-ebeln1     = ls_zbdcdt02-ebeln_al.
          ls_alvl1-vbeln1     = ls_zbdcdt02-vbeln_al.
          ls_alvl1-ebeln2     = ls_zbdcdt02-ebeln_mk.
          ls_alvl1-vbeln2     = ls_zbdcdt02-vbeln_mk.
          ls_alvl1-ebeln3     = ls_zbdcdt02-ebeln_fc.
          ls_alvl1-vbeln3     = ls_zbdcdt02-vbeln_fc.
          ls_alvl1-zendm      = ls_zbdcdt02-zendm.

          PERFORM f_create_key USING ls_alvl1 'X'
                               CHANGING ls_alvl1-objkey.

          IF lv_flag IS NOT INITIAL.
            IF ls_alvl1-vbeln1 IS NOT INITIAL.
              ls_alvl1-icon   = icon_led_green.
              PERFORM f_list_error USING ls_alvl1-objkey '6'.
              PERFORM f_style_cell USING '' 'MARK' ''
                                   CHANGING ls_alvl1-style.
            ELSEIF ls_alvl1-vbeln3 IS NOT INITIAL AND
              ls_alvl1-vbeln2 IS INITIAL.
              PERFORM f_check_completed_coo USING    ls_alvl1-vbeln3
                                            CHANGING lv_subrc ls_alvl1.
            ELSEIF ls_alvl1-vbeln3 IS INITIAL AND
              ls_alvl1-vbeln2 IS NOT INITIAL.
              PERFORM f_check_completed_coo USING    ls_alvl1-vbeln2
                                            CHANGING lv_subrc ls_alvl1.
            ENDIF.
          ENDIF.

          IF ls_alvl1-icon IS INITIAL AND
            lv_subrc IS NOT INITIAL.
            ls_alvl1-icon   = icon_led_red.
            PERFORM f_list_error USING ls_alvl1-objkey lv_subrc.
          ENDIF.

          APPEND ls_alvl1 TO gt_alvl1.
          CLEAR : ls_alvl1, lv_flag.
        ENDLOOP.
        CLEAR lv_subrc.
      ENDLOOP.

    WHEN radio5 OR radio6.
      LOOP AT gt_zbdcdt02 INTO ls_zbdcdt02.
        ls_alvl1-coono  = ls_zbdcdt02-coono.
        ls_alvl1-posnr  = ls_zbdcdt02-posnr.
        ls_alvl1-matnr  = ls_zbdcdt02-matnr.
        CLEAR ls_makt.
        READ TABLE gt_makt INTO ls_makt
                           WITH KEY matnr = ls_zbdcdt02-matnr.
        IF sy-subrc = 0.
          ls_alvl1-maktx    = ls_makt-maktx.
          ls_alvl1-meins    = ls_makt-meins.
        ENDIF.
        ls_alvl1-ebeln1     = ls_zbdcdt02-ebeln_al.
        ls_alvl1-vbeln1     = ls_zbdcdt02-vbeln_al.
        ls_alvl1-ebeln2     = ls_zbdcdt02-ebeln_mk.
        ls_alvl1-vbeln2     = ls_zbdcdt02-vbeln_mk.
        ls_alvl1-ebeln3     = ls_zbdcdt02-ebeln_fc.
        ls_alvl1-vbeln3     = ls_zbdcdt02-vbeln_fc.
        ls_alvl1-zendm      = ls_zbdcdt02-zendm.

        APPEND ls_alvl1 TO gt_alvl1.
        CLEAR : ls_alvl1, lv_flag.
      ENDLOOP.

    WHEN radio4.
      lt_xlqua[] = gt_lqua[].
      SORT lt_xlqua BY werks lgtyp lgpla.
      DELETE ADJACENT DUPLICATES FROM lt_xlqua COMPARING werks lgtyp lgpla.
      lt_ylqua[] = lt_xlqua[].
      SORT lt_ylqua BY lgtyp lgpla.
      DELETE ADJACENT DUPLICATES FROM lt_ylqua COMPARING lgtyp lgpla.

      LOOP AT lt_ylqua INTO ls_ylqua.
        CLEAR : lv_count.
        LOOP AT lt_xlqua INTO ls_xlqua WHERE lgtyp = ls_ylqua-lgtyp
                                         AND lgpla = ls_ylqua-lgpla.
          IF ls_xlqua-verme = 0.
            CONTINUE.
          ENDIF.
          ADD 1 TO lv_count.
        ENDLOOP.

        IF lv_count > 1.
          LOOP AT gt_lqua INTO ls_lqua WHERE lgtyp = ls_ylqua-lgtyp
                                         AND lgpla = ls_ylqua-lgpla.

            ls_alvl1-matnr  = ls_lqua-matnr.
            CLEAR ls_makt.
            READ TABLE gt_makt INTO ls_makt
                               WITH KEY matnr = ls_lqua-matnr.
            IF sy-subrc = 0.
              ls_alvl1-maktx    = ls_makt-maktx.
              ls_alvl1-meins    = ls_makt-meins.
            ENDIF.
            ls_alvl1-lgpla  = ls_lqua-lgpla.
            ls_alvl1-lgtyp  = ls_lqua-lgtyp.
            ls_alvl1-werks  = ls_lqua-werks.
            ls_alvl1-lgnum  = ls_lqua-lgnum.
            ls_alvl1-charg  = ls_lqua-charg.
            ls_alvl1-lgort  = ls_lqua-lgort.
            ls_alvl1-verme  = ls_lqua-verme.
            ls_alvl1-meins  = ls_lqua-meins.
            ls_alvl1-bestq  = ls_lqua-bestq.
            ls_alvl1-sobkz  = ls_lqua-sobkz.

            IF ls_lqua-werks <> '0200'.
              PERFORM f_style_cell USING lv_flag 'MARK' ''
                     CHANGING ls_alvl1-style.
            ENDIF.

            APPEND ls_alvl1 TO gt_alvl1.
            CLEAR ls_alvl1.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

    WHEN OTHERS.
      LOOP AT gt_ekko INTO ls_ekko.
        READ TABLE gt_ekpo INTO ls_ekpo
                           WITH KEY ebeln = ls_ekko-ebeln.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        CASE 'X'.
          WHEN radio1.
            PERFORM f_prepare_data TABLES lt_1 lt_2 lt_3
                                   USING ls_ekko.
          WHEN radio2.
            PERFORM f_prepare_data TABLES lt_1 lt_2 lt_3
                                   USING ls_ekko.

        ENDCASE.
      ENDLOOP.

      LOOP AT gt_makt INTO ls_makt.
        CLEAR : lv_lines, lv_tabix, lt_1x[], lt_2x[], lt_3x[].
        PERFORM f_data_per_matnr TABLES lt_1 lt_1x
                                 USING ls_makt-matnr
                                 CHANGING lv_lines.
        PERFORM f_data_per_matnr TABLES lt_2 lt_2x
                                 USING ls_makt-matnr
                                 CHANGING lv_lines.
        PERFORM f_data_per_matnr TABLES lt_3 lt_3x
                                 USING ls_makt-matnr
                                 CHANGING lv_lines.

        DO lv_lines TIMES.
          ADD 1 TO lv_tabix.
          PERFORM f_read_table TABLES lt_1x
                               USING lv_tabix ls_makt-matnr '1'.
          PERFORM f_read_table TABLES lt_2x
                               USING lv_tabix ls_makt-matnr '2'.
          PERFORM f_read_table TABLES lt_3x
                               USING lv_tabix ls_makt-matnr '3'.

          IF bdcd IS NOT INITIAL.
            ls_list-matnr   = bdcd-matnr.
            ls_list-maktx   = bdcd-maktx.
            APPEND ls_list TO gt_list.
            CLEAR ls_list.
            APPEND bdcd TO gt_bdcd.
            CLEAR bdcd.
          ENDIF.
        ENDDO.
      ENDLOOP.

      SORT gt_list BY matnr.
      DELETE ADJACENT DUPLICATES FROM gt_list COMPARING matnr.

      LOOP AT gt_list INTO ls_list.
        lv_flag = 'X'.
        LOOP AT gt_bdcd INTO bdcd WHERE matnr = ls_list-matnr.
          CLEAR : ls_zbdcdt02, lv_menge, lv_menge1.
          CASE 'X'.
            WHEN radio1.
              LOOP AT gt_zbdcdt02 INTO ls_zbdcdt02 WHERE matnr = ls_list-matnr.
                ADD ls_zbdcdt02-zqty TO lv_menge.
              ENDLOOP.
            WHEN radio2.
              LOOP AT gt_zbdcdt02 INTO ls_zbdcdt02 WHERE matnr    = ls_list-matnr
                                                     AND ebeln_al = bdcd-ebeln1.
                ADD ls_zbdcdt02-zqty TO lv_menge.
              ENDLOOP.
              LOOP AT gt_zbdcdt02 INTO ls_zbdcdt02 WHERE matnr    = ls_list-matnr
                                                     AND ebeln_mk = bdcd-ebeln2.
                ADD ls_zbdcdt02-zqty TO lv_menge1.
              ENDLOOP.
          ENDCASE.

          ls_alvl1-matnr  = bdcd-matnr.
          ls_alvl1-maktx  = bdcd-maktx.
          ls_alvl1-meins  = bdcd-meins.
          ls_alvl1-vstel1 = bdcd-vstel1.
          ls_alvl1-ebeln1 = bdcd-ebeln1.
          ls_alvl1-ebelp1 = bdcd-ebelp1.
          ls_alvl1-menge1 = bdcd-menge1 - lv_menge.
          ls_alvl1-labst1 = bdcd-labst1.
          ls_alvl1-vstel2 = bdcd-vstel2.
          ls_alvl1-ebeln2 = bdcd-ebeln2.
          ls_alvl1-ebelp2 = bdcd-ebelp2.
          IF bdcd-ebeln3 IS INITIAL.
            ls_alvl1-menge2 = bdcd-menge2.
            ls_alvl1-labst2 = bdcd-labst2.
          ELSE.
            ls_alvl1-menge2 = bdcd-menge2 - lv_menge1.
            ls_alvl1-labst2 = bdcd-labst2.
          ENDIF.
          ls_alvl1-vstel3 = bdcd-vstel3.
          ls_alvl1-ebeln3 = bdcd-ebeln3.
          ls_alvl1-ebelp3 = bdcd-ebelp3.
          ls_alvl1-menge3 = bdcd-menge3.
          ls_alvl1-labst3 = bdcd-labst3.

          PERFORM f_create_key USING ls_alvl1 ''
                               CHANGING ls_alvl1-objkey.

          IF lv_flag IS INITIAL.
            PERFORM f_list_error USING ls_alvl1-objkey '3'.
          ENDIF.

          CASE 'X'.
            WHEN radio1.
              IF ls_alvl1-ebeln2 IS INITIAL.
                CLEAR : lv_flag.
                PERFORM f_list_error USING ls_alvl1-objkey '1'.
              ENDIF.
            WHEN radio2.
              IF ls_alvl1-ebeln1 IS INITIAL OR
                ls_alvl1-ebeln2 IS INITIAL.
                CLEAR : lv_flag.
                PERFORM f_list_error USING ls_alvl1-objkey '1'.
              ENDIF.
            WHEN radio3.
          ENDCASE.

          PERFORM f_dn_qty USING bdcd lv_menge lv_menge1
                           CHANGING ls_alvl1-dnqty ls_alvl1-carqty
                                    ls_alvl1-cooqty.

          IF ls_alvl1-dnqty = 0.
            CLEAR : lv_flag.
            PERFORM f_list_error USING ls_alvl1-objkey '2'.
          ENDIF.

          PERFORM f_style_cell USING lv_flag 'MARK' 'COOQTY'
                               CHANGING ls_alvl1-style.

          PERFORM f_color_cell USING lv_flag 'COOQTY'
                               CHANGING ls_alvl1-color.

          IF lv_flag IS INITIAL.
            ls_alvl1-icon = icon_led_red.
          ENDIF.

          APPEND ls_alvl1 TO gt_alvl1.
          CLEAR : ls_alvl1, lv_flag.
        ENDLOOP.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM f_display_data .
  CASE 'X'.
    WHEN radio1.
      IF gt_bdcd[] IS NOT INITIAL.
        CALL SCREEN 101.
      ENDIF.
    WHEN radio2.
      IF gt_bdcd[] IS NOT INITIAL.
        CALL SCREEN 1021.
      ENDIF.
    WHEN radio3.
      IF gt_alvl1[] IS NOT INITIAL.
        CALL SCREEN 103.
      ENDIF.
    WHEN radio4.
      IF gt_alvl1[] IS NOT INITIAL.
        CALL SCREEN 104.
      ENDIF.
    WHEN radio5 OR radio6.
      IF gt_alvl1[] IS NOT INITIAL.
        CALL SCREEN 103.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_data  TABLES   ft_1 STRUCTURE zbdcst01
                              ft_2 STRUCTURE zbdcst01
                              ft_3 STRUCTURE zbdcst01
                     USING    fs_ekko TYPE ekko.
  DATA : ls_ekpo        LIKE LINE OF gt_ekpo.

  IF fs_ekko-bsart IN gr_bsart1 AND
    fs_ekko-reswk IN gr_reswk1 AND
    fs_ekko-ekorg IN gr_ekorg1.
    LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = fs_ekko-ebeln.
      IF ls_ekpo-werks = pa_vstel AND
        ls_ekpo-reslo IN gr_reslo1.
        PERFORM f_calcutate_quantity TABLES ft_1
                                     USING ls_ekpo '1' fs_ekko-reswk.
      ENDIF.
    ENDLOOP.
  ELSEIF fs_ekko-bsart IN gr_bsart2 AND
    fs_ekko-reswk IN gr_reswk2 AND
    fs_ekko-ekorg IN gr_ekorg2.
    LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = fs_ekko-ebeln.
      IF ls_ekpo-lgort IN gr_egort2.
        PERFORM f_calcutate_quantity TABLES ft_2
                                     USING ls_ekpo '2' fs_ekko-reswk.
      ENDIF.
    ENDLOOP.
  ELSEIF fs_ekko-bsart IN gr_bsart3 AND
    fs_ekko-reswk IN gr_reswk3 AND
    fs_ekko-ekorg IN gr_ekorg3.
    LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = fs_ekko-ebeln.
      IF ls_ekpo-werks IN gr_eerks3.
        PERFORM f_calcutate_quantity TABLES ft_3
                                     USING ls_ekpo '3' fs_ekko-reswk.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PREPARE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CALCUTATE_QUANTITY
*&---------------------------------------------------------------------*
FORM f_calcutate_quantity  TABLES   ft_calc STRUCTURE zbdcst01
                           USING    fs_ekpo TYPE ekpo
                                    fu_type fu_reswk.

  DATA : ls_eket  LIKE LINE OF gt_eket,
         ls_ekpv  LIKE LINE OF gt_ekpv,
         ls_makt  LIKE LINE OF gt_makt,
         ls_calc  TYPE zbdcst01.

  ls_calc-werks   = pa_vstel.
  ls_calc-name1   = gv_name1.
  ls_calc-reswk   = fu_reswk.

  CLEAR ls_eket.
  READ TABLE gt_eket INTO ls_eket
                     WITH KEY ebeln = fs_ekpo-ebeln
                              ebelp = fs_ekpo-ebelp.
  IF sy-subrc = 0.
    ls_calc-matnr  = fs_ekpo-matnr.
    CLEAR ls_makt.
    READ TABLE gt_makt INTO ls_makt
                       WITH KEY matnr = fs_ekpo-matnr.
    IF sy-subrc = 0.
      ls_calc-maktx   = ls_makt-maktx.
      ls_calc-meins   = ls_makt-meins.
    ENDIF.

    CLEAR ls_ekpv.
    READ TABLE gt_ekpv INTO ls_ekpv
                       WITH KEY ebeln = fs_ekpo-ebeln
                                ebelp = fs_ekpo-ebelp.
    CASE fu_type.
      WHEN '1'.
        ls_calc-vstel1  = ls_ekpv-vstel.
        ls_calc-ebeln1  = fs_ekpo-ebeln.
        ls_calc-ebelp1  = fs_ekpo-ebelp.
        ls_calc-meins1  = fs_ekpo-meins.
        ls_calc-menge1  = ls_eket-menge - ls_eket-glmng.
        IF ls_calc-menge1 IS NOT INITIAL.
          APPEND ls_calc TO ft_calc.
        ENDIF.
      WHEN '2'.
        ls_calc-vstel2  = ls_ekpv-vstel.
        ls_calc-ebeln2  = fs_ekpo-ebeln.
        ls_calc-ebelp2  = fs_ekpo-ebelp.
        ls_calc-meins2  = fs_ekpo-meins.
        ls_calc-menge2  = ls_eket-menge - ls_eket-glmng.
        IF ls_calc-menge2 IS NOT INITIAL.
          APPEND ls_calc TO ft_calc.
        ENDIF.
      WHEN '3'.
        ls_calc-vstel3  = ls_ekpv-vstel.
        ls_calc-ebeln3  = fs_ekpo-ebeln.
        ls_calc-ebelp3  = fs_ekpo-ebelp.
        ls_calc-meins3  = fs_ekpo-meins.
        ls_calc-menge3  = ls_eket-menge - ls_eket-glmng.
        IF ls_calc-menge3 IS NOT INITIAL.
          APPEND ls_calc TO ft_calc.
        ENDIF.
    ENDCASE.
    CLEAR ls_calc.
  ENDIF.
ENDFORM.                    " F_CALCUTATE_QUANTITY

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA : fcode    TYPE TABLE OF sy-ucomm,
         dynlog   TYPE smp_dyntxt.

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      APPEND '&DEL' TO fcode.
      SET PF-STATUS 'STANDARD' EXCLUDING fcode.
      SET TITLEBAR 'TITLE1'.
    WHEN radio2.
      APPEND '&DEL' TO fcode.
      CASE sy-dynnr.
        WHEN '102'.
          SET PF-STATUS 'PFSTATUS'.
          tc_bdc02-fixed_cols   = 3.
        WHEN '1021'.
          SET PF-STATUS 'STANDARD' EXCLUDING fcode.
      ENDCASE.
      SET TITLEBAR 'TITLE2'.
    WHEN radio3.
      APPEND '&DEL' TO fcode.
      SET PF-STATUS 'STANDARD' EXCLUDING fcode.
      SET TITLEBAR 'TITLE3'.
    WHEN radio4.
      APPEND '&DEL' TO fcode.
      SET PF-STATUS 'STANDARD' EXCLUDING fcode.
      SET TITLEBAR 'TITLE4'.
    WHEN radio5.
      APPEND '&POS' TO fcode.
      APPEND '&DEL' TO fcode.
      SET PF-STATUS 'STANDARD' EXCLUDING fcode.
      SET TITLEBAR 'TITLE5'.
    WHEN radio6.
      APPEND '&POS' TO fcode.
      SET PF-STATUS 'STANDARD' EXCLUDING fcode.
      SET TITLEBAR 'TITLE5'.
  ENDCASE.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  PERFORM f_pbo.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
MODULE pai INPUT.

ENDMODULE.                 " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  PERFORM f_user_command.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
MODULE get_lines OUTPUT.
  CASE 'X'.
    WHEN radio1.
      READ TABLE gt_bdcd INTO bdcd INDEX tc_bdc01-current_line.
      PERFORM f_modify_screen USING '001' '' '' '1' ''.
  ENDCASE.
ENDMODULE.                 " GET_LINES  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_LINES  INPUT
*&---------------------------------------------------------------------*
MODULE modify_lines INPUT.
  line_count = sy-loopc.

  PERFORM f_modify_lines.
ENDMODULE.                 " MODIFY_LINES  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_LINES
*&---------------------------------------------------------------------*
FORM f_modify_lines .
ENDFORM.                    " F_MODIFY_LINES

*&---------------------------------------------------------------------*
*&      Form  F_DATA_PER_MATNR
*&---------------------------------------------------------------------*
FORM f_data_per_matnr  TABLES   ft_data STRUCTURE zbdcst01
                                ft_xdata STRUCTURE zbdcst01
                       USING    fu_matnr
                       CHANGING fc_lines.
  DATA : ls_data    TYPE zbdcst01,
         lv_line    TYPE i.

  LOOP AT ft_data INTO ls_data WHERE matnr = fu_matnr.
    APPEND ls_data TO ft_xdata.
    CLEAR ls_data.
  ENDLOOP.
  DESCRIBE TABLE ft_xdata LINES lv_line.
  IF lv_line > fc_lines.
    fc_lines = lv_line.
  ENDIF.
ENDFORM.                    " F_DATA_PER_MATNR

*&---------------------------------------------------------------------*
*&      Form  F_READ_TABLE
*&---------------------------------------------------------------------*
FORM f_read_table  TABLES   ft_data STRUCTURE zbdcst01
                   USING    fu_tabix fu_matnr fu_type.
  DATA : ls_data  TYPE zbdcst01.

  READ TABLE ft_data INTO ls_data INDEX fu_tabix.
  IF sy-subrc = 0.
    bdcd-matnr  = ls_data-matnr.
    bdcd-maktx  = ls_data-maktx.
    bdcd-meins  = ls_data-meins.
    bdcd-dnqty  = ls_data-dnqty.
    bdcd-carqty = ls_data-carqty.
    CASE fu_type.
      WHEN '1'.
        bdcd-vstel1 = ls_data-vstel1.
        bdcd-ebeln1 = ls_data-ebeln1.
        bdcd-ebelp1 = ls_data-ebelp1.
        bdcd-menge1 = ls_data-menge1.
        bdcd-meins1 = ls_data-meins1.
        PERFORM f_mard_stock USING ls_data-matnr fu_type
                             CHANGING bdcd-labst1.
*        bdcd-labst1 = ls_data-labst1.
*        bdcd-meins1 = ls_data-meins1.
      WHEN '2'.
        bdcd-vstel2 = ls_data-vstel2.
        bdcd-ebeln2 = ls_data-ebeln2.
        bdcd-ebelp2 = ls_data-ebelp2.
        bdcd-menge2 = ls_data-menge2.
        bdcd-meins2 = ls_data-meins2.
        PERFORM f_mard_stock USING ls_data-matnr fu_type
                             CHANGING bdcd-labst2.
*        bdcd-labst2 = ls_data-labst2.
*        bdcd-meins2 = ls_data-meins2.
      WHEN '3'.
        bdcd-vstel3 = ls_data-vstel3.
        bdcd-ebeln3 = ls_data-ebeln3.
        bdcd-ebelp3 = ls_data-ebelp3.
        bdcd-menge3 = ls_data-menge3.
        bdcd-meins3 = ls_data-meins3.
        PERFORM f_mard_stock USING ls_data-matnr fu_type
                             CHANGING bdcd-labst3.
*        bdcd-labst3 = ls_data-labst3.
*        bdcd-meins3 = ls_data-meins3.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_READ_TABLE

*&---------------------------------------------------------------------*
*&      Module  MATERIAL_LIST  INPUT
*&---------------------------------------------------------------------*
MODULE material_list INPUT.
  PERFORM f_material_list.
ENDMODULE.                 " MATERIAL_LIST  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_LIST
*&---------------------------------------------------------------------*
FORM f_material_list .
  DATA : name     TYPE vrm_id,
         list     TYPE vrm_values,
         value    TYPE vrm_value,
         ls_list  LIKE LINE OF gt_list.

  name = 'BDCH-LIST'.

  LOOP AT gt_list INTO ls_list.
    value-key = ls_list-matnr.
    value-text  = ls_list-maktx.
    APPEND value TO list.
  ENDLOOP.
*  value-key = '1'.
*  value-text = 'Text 1'.
*  APPEND value TO list.
*  value-key = '2'.
*  value-text = 'Text 2'.
*  APPEND value TO list.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = name
      values          = list
    EXCEPTIONS
      id_illegal_name = 0
      OTHERS          = 0.
ENDFORM.                    " F_MATERIAL_LIST

*&---------------------------------------------------------------------*
*&      Form  F_PBO
*&---------------------------------------------------------------------*
FORM f_pbo .
  TYPES : BEGIN OF ty_qty,
            dnqty   TYPE mchb-clabs,
          END OF ty_qty.

  DATA : ls_list    LIKE LINE OF gt_list,
         ls_bdcd    LIKE LINE OF gt_bdcd,
         lt_qty     TYPE STANDARD TABLE OF ty_qty,
         ls_qty     LIKE LINE OF lt_qty.

  bdch-werks  = pa_vstel.
  bdch-name1  = gv_name1.

  IF bdch-list IS INITIAL.
    READ TABLE gt_list INTO ls_list INDEX 1.
    bdch-list = ls_list-matnr.
  ENDIF.

  CLEAR : gt_listd[], bdch-meins, bdch-labst1, bdch-labst2, bdch-labst3.
  LOOP AT gt_bdcd INTO ls_bdcd WHERE matnr = bdch-list.
    IF bdch-meins IS INITIAL.
      bdch-meins = ls_bdcd-meins.
      bdch-ceins = 'KAR'.
      PERFORM f_conversion_unit USING ls_bdcd-meins1
                                CHANGING bdch-meins1.
      PERFORM f_conversion_unit USING ls_bdcd-meins2
                                CHANGING bdch-meins2.
      PERFORM f_conversion_unit USING ls_bdcd-meins3
                                CHANGING bdch-meins3.
      PERFORM f_conversion_unit USING ls_bdcd-meins
                                CHANGING bdch-meins4.
      PERFORM f_conversion_unit USING bdch-ceins
                                CHANGING bdch-meins5.
    ENDIF.

    IF bdch-labst1 IS INITIAL.
      bdch-labst1 = ls_bdcd-labst1.
    ENDIF.
    IF bdch-labst2 IS INITIAL.
      bdch-labst2 = ls_bdcd-labst2.
    ENDIF.
    IF bdch-labst3 IS INITIAL.
      bdch-labst3 = ls_bdcd-labst3.
    ENDIF.

    ls_qty-dnqty  = ls_bdcd-menge1.
    APPEND ls_qty TO lt_qty.
    ls_qty-dnqty  = ls_bdcd-menge2.
    APPEND ls_qty TO lt_qty.
    ls_qty-dnqty  = ls_bdcd-menge3.
    APPEND ls_qty TO lt_qty.
    ls_qty-dnqty  = ls_bdcd-labst1.
    APPEND ls_qty TO lt_qty.
    ls_qty-dnqty  = ls_bdcd-labst2.
    APPEND ls_qty TO lt_qty.
    ls_qty-dnqty  = ls_bdcd-labst3.
    APPEND ls_qty TO lt_qty.

    DELETE lt_qty WHERE dnqty = 0.
    SORT lt_qty BY dnqty.
    READ TABLE lt_qty INTO ls_qty INDEX 1.
    ls_bdcd-dnqty  = ls_qty-dnqty.

    PERFORM f_material_conversion USING ls_bdcd-dnqty ls_bdcd-matnr
                                  CHANGING ls_bdcd-carqty ls_bdcd-cooqty.

    APPEND ls_bdcd TO gt_listd.
    CLEAR ls_bdcd.
  ENDLOOP.
ENDFORM.                    " F_PBO

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm   TYPE sy-ucomm,
         lv_valid   TYPE c,
         lt_alvl1   TYPE STANDARD TABLE OF ty_alvl1,
         ls_alvl1   LIKE LINE OF lt_alvl1,
         ls_xlqua   LIKE LINE OF gt_xlqua,
         lv_memdnr(100),
         lv_memdnp(100),
         lv_memto(100),
         lv_memlqua(100),
         lt_return  LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
         lt_post1   TYPE STANDARD TABLE OF ty_post1,
         ls_post1   LIKE LINE OF lt_post1,
         lv_objkey(50),
         lv_txz01   TYPE ekpo-txz01,
         lv_menge   TYPE ekpo-menge,
         lv_posnr   TYPE posnr,
         bdcd       TYPE zbdcst01,
         lv_cooqty(20),
         lv_subrc   TYPE sy-subrc,
         lv_xubrc   TYPE sy-subrc,
         lv_lgnum   TYPE ltak-lgnum,
         lv_vbeln   TYPE ltak-vbeln,
         lv_tanum   TYPE ltak-tanum,
         lx_root    TYPE REF TO cx_root,
         err_msg    TYPE char200,
         lv_ebeln   TYPE ekko-ebeln,
         lv_length  TYPE i.

  DATA : lt_zbdcdt02    TYPE STANDARD TABLE OF zbdcdt02,
         ls_zbdcdt02    LIKE LINE OF lt_zbdcdt02,
         lt_zbdcdt01    TYPE STANDARD TABLE OF zbdcdt01,
         ls_zbdcdt01    LIKE LINE OF lt_zbdcdt01,
         lt_proc        TYPE STANDARD TABLE OF zbdcdt02,
         ls_proc        LIKE LINE OF lt_proc.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN 'BDCD_LIST'.

    WHEN '&STS'.
      PERFORM f_display_status USING ''.

    WHEN '&ALL'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING 'X'.
      ENDIF.

    WHEN '&SAL'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING ''.
      ENDIF.

    WHEN '&POS'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        lt_alvl1[]  = gt_alvl1[].
        DELETE lt_alvl1 WHERE mark = space.

        CASE 'X'.
          WHEN radio3.
            LOOP AT lt_alvl1 INTO ls_alvl1.
              CLEAR : bdcd, rspar_tab[].
              IF ls_alvl1-vbeln3 IS NOT INITIAL.
* Factory Process
                PERFORM f_factory_post USING ls_alvl1-coono ls_alvl1-vbeln3 '3000'
                                             ls_alvl1-zendm 'X'
                                       CHANGING lv_subrc.
                IF lv_subrc IS INITIAL.
* Marketing Process
                  PERFORM f_marketing_post USING ls_alvl1-coono ls_alvl1-vbeln2 '1001'
                                                 ls_alvl1-zendm ls_alvl1-vbeln3 'X' ''
                                           CHANGING lv_subrc.
                ELSE.
                  CONTINUE.
                ENDIF.

                IF lv_subrc IS INITIAL.
* Alokasi Process
                  IF ls_alvl1-zendm IS INITIAL.
                    PERFORM f_alokasi_post USING ls_alvl1-coono ls_alvl1-vbeln1
                                                 ls_alvl1-zendm 'X'.
                  ENDIF.
                ELSE.
                  CONTINUE.
                ENDIF.
              ELSEIF ls_alvl1-vbeln3 IS INITIAL AND
                ls_alvl1-vbeln2 IS NOT INITIAL.
* Marketing Process
                PERFORM f_marketing_post USING ls_alvl1-coono ls_alvl1-vbeln2 '1001'
                                               ls_alvl1-zendm ls_alvl1-vbeln2 'X' 'X'
                                         CHANGING lv_subrc.
                IF lv_subrc IS INITIAL.
* Alokasi Process
                  IF ls_alvl1-zendm IS INITIAL.
                    PERFORM f_alokasi_post USING ls_alvl1-coono ls_alvl1-vbeln1
                                                 ls_alvl1-zendm 'X'.
                  ENDIF.
                ELSE.
                  CONTINUE.
                ENDIF.
              ENDIF.
            ENDLOOP.

          WHEN radio4.
            LOOP AT lt_alvl1 INTO ls_alvl1.
              CALL FUNCTION 'L_TO_CREATE_SINGLE'
                EXPORTING
                  i_lgnum               = ls_alvl1-lgnum
                  i_bwlvs               = '999'
                  i_betyp               = 'D'
                  i_benum               = ls_alvl1-lgpla
                  i_matnr               = ls_alvl1-matnr
                  i_werks               = ls_alvl1-werks
                  i_lgort               = ls_alvl1-lgort
                  i_charg               = ls_alvl1-charg
                  i_bestq               = ls_alvl1-bestq
                  i_sobkz               = ls_alvl1-sobkz
                  i_anfme               = ls_alvl1-verme
                  i_altme               = ls_alvl1-meins
                  i_vltyp               = ls_alvl1-lgtyp
                  i_vlpla               = ls_alvl1-lgpla
                IMPORTING
                  e_tanum               = lv_tanum
                EXCEPTIONS
                  no_to_created         = 1
                  bwlvs_wrong           = 2
                  betyp_wrong           = 3
                  benum_missing         = 4
                  betyp_missing         = 5
                  foreign_lock          = 6
                  vltyp_wrong           = 7
                  vlpla_wrong           = 8
                  vltyp_missing         = 9
                  nltyp_wrong           = 10
                  nlpla_wrong           = 11
                  nltyp_missing         = 12
                  rltyp_wrong           = 13
                  rlpla_wrong           = 14
                  rltyp_missing         = 15
                  squit_forbidden       = 16
                  manual_to_forbidden   = 17
                  letyp_wrong           = 18
                  vlpla_missing         = 19
                  nlpla_missing         = 20
                  sobkz_wrong           = 21
                  sobkz_missing         = 22
                  sonum_missing         = 23
                  bestq_wrong           = 24
                  lgber_wrong           = 25
                  xfeld_wrong           = 26
                  date_wrong            = 27
                  drukz_wrong           = 28
                  ldest_wrong           = 29
                  update_without_commit = 30
                  no_authority          = 31
                  material_not_found    = 32
                  lenum_wrong           = 33
                  OTHERS                = 34.
              IF sy-subrc = 0.
                ls_alvl1-icon   = icon_led_green.
                PERFORM f_style_cell USING '' 'MARK' ''
                                     CHANGING ls_alvl1-style.

                MODIFY TABLE gt_alvl1 FROM ls_alvl1
                                      TRANSPORTING mark style icon.

                CALL FUNCTION 'ZFMWAIT'.

                TRY .
                    UPDATE ltak SET queue = 'TREPLENISH'
                                WHERE lgnum = ls_alvl1-lgnum
                                  AND tanum = lv_tanum.
                  CATCH cx_root INTO lx_root.
                    err_msg = lx_root->get_text( ).
                ENDTRY.
              ENDIF.
              CLEAR ls_alvl1.
            ENDLOOP.

          WHEN OTHERS.
            IF lt_alvl1[] IS NOT INITIAL.
              LOOP AT lt_alvl1 INTO ls_alvl1.
                CLEAR : lv_objkey, bdcd.
                PERFORM f_create_key USING ls_alvl1 ''
                                     CHANGING lv_objkey.

                IF radio1 IS NOT INITIAL.
                  PERFORM f_validate_cooqty USING ls_alvl1 lv_txz01 lv_objkey
                                            CHANGING ls_alvl1-cooqty.
                ENDIF.

                IF ls_alvl1-cooqty > ls_alvl1-dnqty OR
                  ls_alvl1-cooqty <= 0.
                  IF ls_alvl1-cooqty <= 0.
                    lv_subrc  = 4.
                  ELSE.
                    lv_subrc  = 5.
                  ENDIF.

                  PERFORM f_list_error USING ls_alvl1-objkey lv_subrc.
                  ls_alvl1-icon = icon_led_red.
                  MODIFY gt_alvl1 FROM ls_alvl1
                                  TRANSPORTING icon
                                  WHERE objkey  = lv_objkey.
                  CONTINUE.
                ENDIF.

                lv_cooqty = ls_alvl1-cooqty.
                CONDENSE lv_cooqty NO-GAPS.

                IF ls_alvl1-ebeln3 IS NOT INITIAL.
                  CONCATENATE ls_alvl1-vstel3 ls_alvl1-ebeln3 ls_alvl1-ebelp3 lv_cooqty ls_alvl1-meins
                  INTO lv_txz01
                  SEPARATED BY '|'.
                  ls_alvl1-flag   = '3'.
                ELSEIF ls_alvl1-ebeln2 IS NOT INITIAL.
                  CONCATENATE ls_alvl1-vstel2 ls_alvl1-ebeln2 ls_alvl1-ebelp2 lv_cooqty ls_alvl1-meins
                  INTO lv_txz01
                  SEPARATED BY '|'.
                  ls_alvl1-flag   = '2'.
                ENDIF.

                MODIFY lt_alvl1 FROM ls_alvl1
                                TRANSPORTING flag cooqty.

                MODIFY gt_alvl1 FROM ls_alvl1
                                TRANSPORTING flag cooqty
                                WHERE objkey  = lv_objkey.

                PERFORM f_submit_parameter USING : 'PA_PROC' '1' 'P',
                                                   'SO_TXZ01-LOW' lv_txz01 'S'.
              ENDLOOP.

              IF lv_subrc IS INITIAL.
                CLEAR : lt_return[], gt_bapiret2[].
* Create DN
                SUBMIT zmmbdcdn WITH SELECTION-TABLE rspar_tab AND RETURN.
                IF sy-subrc = 0.
                  CONCATENATE 'BDCDN_RETURN' sy-uname INTO lv_memdnr.
                  IMPORT lt_return FROM MEMORY ID lv_memdnr.
                  IF sy-subrc = 0.
                    READ TABLE lt_return WITH KEY type = 'E'.
                    IF sy-subrc = 0.
                      gt_bapiret2[] = lt_return[].
                      lv_subrc = 1.
                    ELSE.
                      CONCATENATE 'BDCDN_POST' sy-uname INTO lv_memdnp.
                      IMPORT gt_post1 FROM MEMORY ID lv_memdnp.

                      LOOP AT lt_alvl1 INTO ls_alvl1.
                        PERFORM f_create_key USING ls_alvl1 ''
                                             CHANGING lv_objkey.
                        ADD 1 TO lv_posnr.
                        CLEAR : lv_length, lv_ebeln.
                        lv_length = STRLEN( lv_objkey ).
                        CASE 'X'.
                          WHEN radio1.
                            IF lv_length = 25.
                              lv_ebeln = lv_objkey+5(10).
                            ELSE.
                              lv_ebeln = lv_objkey+20(10).
                            ENDIF.
                          WHEN radio2.
                            IF lv_length = 45.
                              lv_ebeln = lv_objkey+30(10).
                            ELSE.
                              lv_ebeln = lv_objkey+15(10).
                            ENDIF.
                        ENDCASE.
                        READ TABLE gt_post1 INTO ls_post1
                                            WITH KEY ebeln = lv_ebeln.
                        IF sy-subrc = 0.
                          ls_alvl1-coono = ls_post1-coono.
                          ls_alvl1-coodn = ls_post1-coodn.
                        ENDIF.

                        PERFORM f_save_coo_no USING ls_alvl1 'X'
                                              CHANGING lv_posnr.

                        MODIFY gt_alvl1 FROM ls_alvl1
                                        TRANSPORTING coono coodn
                                        WHERE objkey  = lv_objkey.

                        LOOP AT gt_xlqua INTO ls_xlqua WHERE objkey = lv_objkey.
                          ls_xlqua-coodn  = ls_alvl1-coodn.
                          MODIFY gt_xlqua FROM ls_xlqua
                                          TRANSPORTING coodn
                                          WHERE objkey = lv_objkey.
                          CLEAR ls_xlqua.
                        ENDLOOP.

                        CLEAR : ls_alvl1, lv_objkey.
                      ENDLOOP.

                    ENDIF.
                    CLEAR : rspar_tab[].
                  ENDIF.
                ENDIF.
              ENDIF.

              IF lv_subrc IS INITIAL.
                CLEAR : lt_return[].
                lt_post1[] = gt_post1[].
                SORT lt_post1 BY coodn.
                DELETE ADJACENT DUPLICATES FROM lt_post1 COMPARING coodn.
                LOOP AT lt_post1 INTO ls_post1.
                  TRY .
                      UPDATE likp SET lgtor = pa_vstel+1(3)
                                  WHERE vbeln = ls_post1-coodn.
                    CATCH cx_root INTO lx_root.
                      err_msg = lx_root->get_text( ).
                  ENDTRY.

                  IF err_msg IS INITIAL.
                    PERFORM f_submit_parameter USING : 'PA_TYPE' 'DN' 'P',
                                                       'PA_LGNUM' '051' 'P',
                                                       'PA_VBELN' ls_post1-coodn 'P'.
* Create TO
                    IF radio1 IS NOT INITIAL.
                      PERFORM f_submit_parameter USING : 'PA_CONFI' 'X' 'P',
                                                         'PA_KGVNQ' 'X' 'P'.

                      CONCATENATE 'BDCTO_LQUA' sy-uname INTO lv_memlqua.
                      EXPORT gt_xlqua TO MEMORY ID lv_memlqua.
                    ENDIF.
                    SUBMIT zmmbdcto WITH SELECTION-TABLE rspar_tab AND RETURN.
                    IF sy-subrc = 0.
                      CONCATENATE 'BDCTO' sy-uname INTO lv_memto.
                      IMPORT lv_tanum FROM MEMORY ID lv_memto.
                      IF sy-subrc = 0.
                        CLEAR : rspar_tab[].
                        FREE MEMORY ID lv_memto.
                      ELSE.
*                      PERFORM f_add_to_error_table USING : 'PA_TYPE' 'DN' 'P',
*                                                           'PA_LGNUM' '051' 'P',
*                                                           'PA_VBELN' ls_post1-coodn 'P',
*                                                           'PA_CONFI' 'X' 'P',
*                                                           'PA_KGVNQ' 'X' 'P'.
                        lv_subrc = 2.
                      ENDIF.
                    ENDIF.
                  ELSE.
                    lv_subrc = 3.
                  ENDIF.
                ENDLOOP.
              ENDIF.

              IF lv_subrc IS INITIAL.
                LOOP AT lt_alvl1 INTO ls_alvl1.
                  CLEAR : lv_objkey, bdcd.
                  PERFORM f_create_key USING ls_alvl1 ''
                                       CHANGING lv_objkey.

                  ls_alvl1-icon   = icon_led_green.
                  CLEAR ls_alvl1-mark.

                  CASE ls_alvl1-flag.
                    WHEN '1'.
                      ls_alvl1-menge1   = ls_alvl1-menge1 - ls_alvl1-cooqty.
                      ls_alvl1-labst1   = ls_alvl1-labst1 - ls_alvl1-cooqty.
                    WHEN '2'.
                      ls_alvl1-menge2   = ls_alvl1-menge2 - ls_alvl1-cooqty.
                      ls_alvl1-labst2   = ls_alvl1-labst2 - ls_alvl1-cooqty.
                      ls_alvl1-menge1   = ls_alvl1-menge1 - ls_alvl1-cooqty.
                      READ TABLE gt_post1 INTO ls_post1
                                          WITH KEY ebeln = ls_alvl1-ebeln2
                                                   ebelp = ls_alvl1-ebelp2.
                      IF sy-subrc = 0.
                        ls_alvl1-coono  = ls_post1-coono.
                        ls_alvl1-coodn  = ls_post1-coodn.
                      ENDIF.
                    WHEN '3'.
                      ls_alvl1-menge3   = ls_alvl1-menge3 - ls_alvl1-cooqty.
                      ls_alvl1-labst3   = ls_alvl1-labst3 - ls_alvl1-cooqty.
                      ls_alvl1-menge2   = ls_alvl1-menge2 - ls_alvl1-cooqty.
                      ls_alvl1-menge1   = ls_alvl1-menge1 - ls_alvl1-cooqty.
                      READ TABLE gt_post1 INTO ls_post1
                                          WITH KEY ebeln = ls_alvl1-ebeln3
                                                   ebelp = ls_alvl1-ebelp3.
                      IF sy-subrc = 0.
                        ls_alvl1-coono  = ls_post1-coono.
                        ls_alvl1-coodn  = ls_post1-coodn.
                      ENDIF.
                  ENDCASE.

                  ls_alvl1-coodt     = sy-datum.
                  ls_alvl1-cootm     = sy-uzeit.
                  ls_alvl1-coonm     = sy-uname.
                  ls_alvl1-zqty      = ls_alvl1-cooqty.

                  MOVE-CORRESPONDING ls_alvl1 TO bdcd.
                  PERFORM f_dn_qty USING bdcd '' ''
                                   CHANGING ls_alvl1-dnqty ls_alvl1-carqty
                                            ls_alvl1-cooqty.

                  IF ls_alvl1-dnqty = 0.
                    PERFORM f_list_error USING ls_alvl1-objkey '2'.

                    PERFORM f_style_cell USING '' 'MARK' 'COOQTY'
                                         CHANGING ls_alvl1-style.

                    PERFORM f_color_cell USING '' 'COOQTY'
                                         CHANGING ls_alvl1-color.

*                  ls_alvl1-icon = icon_led_red.
                  ENDIF.

                  IF ls_alvl1-icon = icon_led_green.
                    MOVE-CORRESPONDING ls_alvl1 TO ls_zbdcdt02.
                    ls_zbdcdt02-ebeln_fc  = ls_alvl1-ebeln3.
                    ls_zbdcdt02-ebeln_mk  = ls_alvl1-ebeln2.
                    ls_zbdcdt02-ebeln_al  = ls_alvl1-ebeln1.

                    CASE ls_alvl1-flag.
                      WHEN '1'.
                        ls_zbdcdt02-vbeln_al  = ls_alvl1-coodn.
                      WHEN '2'.
                        ls_zbdcdt02-vbeln_mk  = ls_alvl1-coodn.
                      WHEN '3'.
                        ls_zbdcdt02-vbeln_fc  = ls_alvl1-coodn.
                    ENDCASE.

                    APPEND ls_zbdcdt02 TO lt_zbdcdt02.
                    CLEAR ls_zbdcdt02.
                  ENDIF.

                  IF radio1 IS NOT INITIAL.
                    ls_proc-coono   = ls_alvl1-coono.
                    APPEND ls_proc TO lt_proc.
                    CLEAR ls_proc.
                  ENDIF.

                  MODIFY gt_alvl1 FROM ls_alvl1
                                  TRANSPORTING mark icon
                                               menge1 menge2 menge3
                                               labst1 labst2 labst3
                                               dnqty carqty cooqty coono coodn
                                               coodt cootm coonm style flag color
                                  WHERE objkey  = lv_objkey.
                ENDLOOP.
              ENDIF.

*              PERFORM f_save_to_table TABLES lt_zbdcdt02.

              IF radio1 IS NOT INITIAL.
                IF lv_subrc IS INITIAL.
                  PERFORM f_process_continue TABLES lt_proc
                                             USING 'X'
                                             CHANGING lv_xubrc.
                ENDIF.
              ENDIF.
            ELSE.
              lv_subrc = '6'.
            ENDIF.

            FREE MEMORY ID lv_memdnr.
            FREE MEMORY ID lv_memdnp.

            CASE lv_subrc.
              WHEN '0'.
                IF lv_xubrc IS INITIAL.
                  MESSAGE s000(zab) WITH 'COO created'.
                ELSE.
                  MESSAGE s000(zab) WITH 'COO created with error' DISPLAY LIKE 'E'.
                ENDIF.
              WHEN '1'.
                MESSAGE s000(zab) WITH 'Create DN error' DISPLAY LIKE 'E'.
              WHEN '2'.
                MESSAGE s000(zab) WITH 'Create TO error' DISPLAY LIKE 'E'.
              WHEN '3'.
                MESSAGE s000(zab) WITH 'Update error' DISPLAY LIKE 'E'.
              WHEN '4'.
                MESSAGE s000(zab) WITH 'Ada error sebelum posting' DISPLAY LIKE 'E'.
              WHEN '5'.
                MESSAGE s000(zab) WITH 'Ada error sebelum posting' DISPLAY LIKE 'E'.
              WHEN '6'.
                MESSAGE s000(zab) WITH 'Please select item first' DISPLAY LIKE 'E'.
            ENDCASE.

            PERFORM f_select USING ''.
        ENDCASE.
      ENDIF.

      PERFORM f_alv_refresh USING 'X'.

    WHEN '&DEL'.

      PERFORM f_alv_refresh USING 'X'.

    WHEN '&LOG'.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_bapiret2.

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_UNIT
*&---------------------------------------------------------------------*
FORM f_conversion_unit  USING    fu_meins
                        CHANGING fc_meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_meins
    IMPORTING
      output         = fc_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " F_CONVERSION_UNIT

*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_CONVERSION
*&---------------------------------------------------------------------*
FORM f_material_conversion  USING    fu_labst fu_matnr
                            CHANGING fc_labst fc_cooqty.
  DATA : lv_round   TYPE p DECIMALS 0,
         lv_umrez   TYPE marm-umrez,
         lv_umren   TYPE marm-umren.

  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
    EXPORTING
      input                = fu_labst
      matnr                = fu_matnr
      meinh                = 'KAR'
    IMPORTING
      output               = fc_labst
      umrez                = lv_umrez
      umren                = lv_umren
    EXCEPTIONS
      conversion_not_found = 1
      input_invalid        = 2
      material_not_found   = 3
      meinh_not_found      = 4
      meins_missing        = 5
      no_meinh             = 6
      output_invalid       = 7
      overflow             = 8
      OTHERS               = 9.

  CALL FUNCTION 'ROUND'
    EXPORTING
      input         = fc_labst
      sign          = '-'
    IMPORTING
      output        = lv_round
    EXCEPTIONS
      input_invalid = 1
      overflow      = 2
      type_invalid  = 3
      OTHERS        = 4.

  IF sy-subrc = 0.
    fc_cooqty = ( lv_round * lv_umrez ) / lv_umren.
  ENDIF.
ENDFORM.                    " F_MATERIAL_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_STATUS
*&---------------------------------------------------------------------*
FORM f_display_status USING fu_row.
  TYPES : BEGIN OF ty_message,
            msgid  LIKE sy-msgid,
            msgty  LIKE sy-msgty,
            msgno  LIKE sy-msgno,
            msgv1  LIKE sy-msgv1,
            msgv2  LIKE sy-msgv2,
            msgv3  LIKE sy-msgv3,
            msgv4  LIKE sy-msgv4,
            lineno LIKE mesg-zeile,
          END OF ty_message.

  DATA : lv_cursor  TYPE i,
         ls_error   LIKE LINE OF gt_error,
         lt_message TYPE STANDARD TABLE OF ty_message,
         ls_alvl1   LIKE LINE OF gt_alvl1,
         ls_message LIKE LINE OF lt_message.

  IF fu_row IS NOT INITIAL.
    lv_cursor   = fu_row.
  ELSE.
    GET CURSOR LINE lv_cursor.
    lv_cursor = tc_bdc02-top_line + lv_cursor - 1.
  ENDIF.

  READ TABLE gt_alvl1 INTO ls_alvl1 INDEX lv_cursor.
  IF sy-subrc = 0.
    IF ls_alvl1-icon = icon_led_red.
      LOOP AT gt_error INTO ls_error WHERE objkey = ls_alvl1-objkey.
        MOVE-CORRESPONDING ls_error TO ls_message.
        ls_message-lineno = lv_cursor.
        APPEND ls_message TO lt_message.
        CLEAR ls_message.
      ENDLOOP.
    ENDIF.

    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      EXPORTING
        i_lineno      = lv_cursor
      TABLES
        i_message_tab = lt_message.
  ENDIF.
ENDFORM.                    " F_DISPLAY_STATUS

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
  PERFORM f_docking_split_container.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_DOCKING_SPLIT_CONTAINER
*&---------------------------------------------------------------------*
FORM f_docking_split_container .
  DATA : lv_contname(20).

  lv_contname   = 'CC_MAIN'.

  IF g_customcont IS INITIAL.
    CREATE OBJECT g_customcont
      EXPORTING
        container_name              = lv_contname
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_splitter
      EXPORTING
        parent  = g_customcont
        rows    = 1
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_contain01.

*    CALL METHOD g_splitter->get_container
*      EXPORTING
*        row       = 1
*        column    = 2
*      RECEIVING
*        container = g_contain02.
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Module  MAIN_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE main_alv OUTPUT.
  PERFORM f_main_alv.
ENDMODULE.                 " MAIN_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_MAIN_ALV
*&---------------------------------------------------------------------*
FORM f_main_alv .
  IF g_tabgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_tabgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain01.

    PERFORM f_build_layout.
    PERFORM f_build_sort.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_tabgrid.

    CALL METHOD g_tabgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = gt_alvl1[]
        it_fieldcatalog      = gt_main_fieldcat[].
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
*  gs_layout_alv-box_fname           = 'CHECK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
*  gs_layout_alv-no_rowmark          = selected.
  gs_layout_alv-cwidth_opt          = selected.
  gs_layout_alv-stylefname          = 'STYLE'.
  gs_layout_alv-ctab_fname          = 'COLOR'.
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-no_toolbar          = selected.
  gs_layout_alv-totals_bef          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_alv_sort USING : 1 'MATNR' 'X' '' 'X'.
    WHEN radio2.
      PERFORM f_alv_sort USING : 1 'MATNR' 'X' '' 'X'.
    WHEN radio4.
      PERFORM f_alv_sort USING : 1 'LGPLA' 'X' '' '',
                                 2 'LGTYP' 'X' '' '',
                                 3 'MATNR' 'X' '' ''.
  ENDCASE.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table  USING    fu_pos.
  DATA : lt_dyn_table     TYPE REF TO data,
         ls_line          TYPE REF TO data.

  IF radio5 IS INITIAL AND
    radio6 IS INITIAL.
    PERFORM f_dyn_int_table USING :
      fu_pos 'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
      'X' 'X' '' '' '',
      fu_pos 'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
      'X' 'X' '' '' ''.
  ENDIF.

  CASE 'X'.
    WHEN radio3 OR radio5 OR radio6.
      PERFORM f_dyn_int_table USING :
        fu_pos 'COONO' '' '' '' '' '' '' '' '' 'COO No.' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        fu_pos 'COODT' '' '' '' '' '' '' '' '' 'COO Date' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        fu_pos 'MATNR' '' '' '' '' '' '' 'MATNR' 'MARA' '' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        fu_pos 'MAKTX' '' '' '' '' '' '' 'MAKTX' 'MAKT' '' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        fu_pos 'EBELN1' '' '' '' '' '' '' 'EBELN_AL' 'ZBDCDT02' 'PO Alokasi' '' ''
        '' '' '' '' '' '' '' '' '',
        fu_pos 'VBELN1' '' '' '' '' '' '' 'VBELN_AL' 'ZBDCDT02' 'DN Alokasi' '' ''
        '' '' '' '' '' '' '' '' '',
        fu_pos 'EBELN2' '' '' '' '' '' '' 'EBELN_MK' 'ZBDCDT02' 'PO Marketing' '' ''
        '' '' '' '' '' '' '' '' '',
        fu_pos 'VBELN2' '' '' '' '' '' '' 'VBELN_MK' 'ZBDCDT02' 'DN Marketing' '' ''
        '' '' '' '' '' '' '' '' '',
        fu_pos 'EBELN3' '' '' '' '' '' '' 'EBELN_FC' 'ZBDCDT02' 'PO Factory' '' ''
        '' '' '' '' '' '' '' '' '',
        fu_pos 'VBELN3' '' '' '' '' '' '' 'VBELN_FC' 'ZBDCDT02' 'DN Factory' '' ''
        '' '' '' '' '' '' '' '' ''.

    WHEN radio4.
      PERFORM f_dyn_int_table USING :
        fu_pos 'MATNR' '' '' '' '' '' '' 'MATNR' 'MARA' '' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        fu_pos 'MAKTX' '' '' '' '' '' '' 'MAKTX' 'MAKT' '' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        fu_pos 'LGNUM' '' '' '' '' '' '' 'LGNUM' 'LQUA' '' '' '' '' '' '' ''
        '' '' '' '' '',
        fu_pos 'WERKS' '' '' '' '' '' '' 'WERKS' 'LQUA' '' '' '' '' '' '' ''
        '' '' '' '' '',
        fu_pos 'LGORT' '' '' '' '' '' '' 'LGORT' 'LQUA' '' '' '' '' '' '' ''
        '' '' '' '' '',
        fu_pos 'LGTYP' '' '' '' '' '' '' 'LGTYP' 'LQUA' '' '' '' '' '' '' ''
        '' '' '' '' '',
        fu_pos 'LGPLA' '' '' '' '' '' '' 'LGPLA' 'LQUA' '' '' '' '' '' '' ''
        '' '' '' '' '',
        fu_pos 'VERME' '' '' '' '' 'MEINS' '' 'VERME' 'LQUA' '' '' '' '' ''
        '' '' '' '' '' '' '',
        fu_pos 'MEINS' '' '' '' '' '' '' 'MEINS' 'MARA' '' '' '' '' '' '' ''
        '' '' '' '' ''.

    WHEN OTHERS.
      PERFORM f_dyn_int_table USING :
        fu_pos 'MATNR' '' '' '' '' '' '' 'MATNR' 'MARA' '' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        fu_pos 'MAKTX' '' '' '' '' '' '' 'MAKTX' 'MAKT' '' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        fu_pos 'MEINS' '' '' '' '' '' '' 'MEINS' 'MARA' '' '' '' '' '' '' ''
        'X' 'X' '' '' '',
        fu_pos 'COOQTY' '' '' '' '' 'MEINS' '' 'CLABS' 'MCHB' 'COO Qty'
        '' '' '' 'X' '' '' 'X' 'X' '' '' '',
        fu_pos 'DNQTY' '' '' '' '' 'MEINS' '' 'CLABS' 'MCHB' 'DN Qty'
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'CARQTY' '' '' '' 'KAR' '' '' 'CLABS' 'MCHB' 'Carton'
        '' '' '' '' '' '' '' '' '' '' ''.
      IF radio2 IS NOT INITIAL.
        PERFORM f_dyn_int_table USING :
          fu_pos 'EBELN1' '' '' '' '' '' '' 'EBELN' 'EKPO' 'PO Alokasi' '' ''
          '' '' '' '' '' '' '' '' '',
          fu_pos 'EBELP1' '' '' '' '' '' '' 'EBELP' 'EKPO' '' '' '' '' '' '' ''
          '' '' '' '' '',
          fu_pos 'MENGE1' '' '' '' '' 'MEINS' '' 'MENGE' 'EKPO' 'Out.Qty Alokasi'
          '' '' '' '' '' '' '' '' '' 'X' '',
          fu_pos 'LABST1' '' '' '' '' 'MEINS' '' 'CLABS' 'MCHB' 'Stock DC'
          '' '' '' '' '' '' '' '' '' 'A' 'X'.
      ENDIF.
      PERFORM f_dyn_int_table USING :
        fu_pos 'EBELN2' '' '' '' '' '' '' 'EBELN' 'EKPO' 'PO Distributor' '' ''
        '' '' '' '' '' '' '' '' '',
        fu_pos 'EBELP2' '' '' '' '' '' '' 'EBELP' 'EKPO' '' '' '' '' '' '' ''
        '' '' '' '' '',
        fu_pos 'MENGE2' '' '' '' '' 'MEINS' '' 'MENGE' 'EKPO' 'Out.Qty Distributor'
        '' '' '' '' '' '' '' '' '' 'X' '',
        fu_pos 'LABST2' '' '' '' '' 'MEINS' '' 'CLABS' 'MCHB' 'Stock Marketing'
        '' '' '' '' '' '' '' '' '' 'A' 'X',
        fu_pos 'EBELN3' '' '' '' '' '' '' 'EBELN' 'EKPO' 'PO Factory' '' ''
        '' '' '' '' '' '' '' '' '',
        fu_pos 'EBELP3' '' '' '' '' '' '' 'EBELP' 'EKPO' '' '' '' '' '' '' ''
        '' '' '' '' '',
        fu_pos 'MENGE3' '' '' '' '' 'MEINS' '' 'MENGE' 'EKPO' 'Out.Qty Factory'
        '' '' '' '' '' '' '' '' '' 'X' '',
        fu_pos 'LABST3' '' '' '' '' 'MEINS' '' 'CLABS' 'MCHB' 'Stock Factory'
        '' '' '' '' '' '' '' '' '' 'A' 'X',
        fu_pos 'COONO' '' '' '' '' '' '' 'EBELN' 'EKKO' 'COO No.'
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'COODT' '' '' '' '' '' '' 'COODT' 'ZBDCDT02' 'COO Date'
        '' '' '' '' '' '' '' '' '' '' '',
        fu_pos 'COODN' '' '' '' '' '' '' 'EBELN' 'EKKO' 'COO DN'
        '' '' '' '' '' '' '' '' '' '' ''.
  ENDCASE.

*  CALL METHOD cl_alv_table_create=>create_dynamic_table
*    EXPORTING
*      it_fieldcatalog           = gt_main_fieldcat
*      i_length_in_byte          = 'X'
*    IMPORTING
*      ep_table                  = lt_dyn_table
*    EXCEPTIONS
*      generate_subpool_dir_full = 1
*      OTHERS                    = 2.
*  IF sy-subrc EQ 0.
*    ASSIGN lt_dyn_table->* TO <fs_out>.
*    CREATE DATA ls_line LIKE LINE OF <fs_out>.
*    ASSIGN ls_line->* TO <fs_lout>.
*  ENDIF.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_int_table  USING    fu_pos fu_fieldname fu_tabname
                               fu_currency fu_cfieldname fu_quantity
                               fu_qfieldname fu_checkbox fu_ref_field
                               fu_ref_table fu_coltext fu_outputlen
                               fu_inttype fu_no_out fu_edit fu_tech
                               fu_just fu_key fu_fix fu_icon fu_sum
                               fu_nosum.
  DATA : ls_dyn_fcat       TYPE lvc_s_fcat.

  PERFORM f_isi_judul USING fu_coltext '' '' ''
                      CHANGING ls_dyn_fcat-reptext ls_dyn_fcat-scrtext_l
                               ls_dyn_fcat-scrtext_m ls_dyn_fcat-scrtext_s.

  ls_dyn_fcat-fieldname   = fu_fieldname.
  ls_dyn_fcat-tabname     = fu_tabname.
  ls_dyn_fcat-currency    = fu_currency.
  ls_dyn_fcat-cfieldname  = fu_cfieldname.
  ls_dyn_fcat-quantity    = fu_quantity.
  ls_dyn_fcat-qfieldname  = fu_qfieldname.
  ls_dyn_fcat-checkbox    = fu_checkbox.
  ls_dyn_fcat-ref_field   = fu_ref_field.
  ls_dyn_fcat-ref_table   = fu_ref_table.
  ls_dyn_fcat-coltext     = fu_coltext.
  ls_dyn_fcat-edit        = fu_edit.
  ls_dyn_fcat-outputlen   = fu_outputlen.
  ls_dyn_fcat-inttype     = fu_inttype.
  ls_dyn_fcat-no_out      = fu_no_out.
  ls_dyn_fcat-tech        = fu_tech.
  ls_dyn_fcat-just        = fu_just.
  ls_dyn_fcat-key         = fu_key.
  ls_dyn_fcat-fix_column  = fu_fix.
  ls_dyn_fcat-icon        = fu_icon.
  ls_dyn_fcat-do_sum      = fu_sum.
  ls_dyn_fcat-no_sum      = fu_nosum.
  APPEND ls_dyn_fcat TO gt_main_fieldcat.
  CLEAR ls_dyn_fcat.
ENDFORM.                    " F_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_ISI_JUDUL
*&---------------------------------------------------------------------*
FORM f_isi_judul  USING    fu_coltext fu_l fu_m fu_s
                  CHANGING fc_reptext fc_scrtext_l fc_scrtext_m fc_scrtext_s.

  fc_reptext    = fu_coltext.
  fc_scrtext_l  = fu_coltext.
  fc_scrtext_m  = fu_coltext.
  fc_scrtext_s  = fu_coltext.
ENDFORM.                    " F_ISI_JUDUL

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check.
  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
  DATA : lv_style           TYPE lvc_s_styl-style,
         lt_stylerow        TYPE lvc_t_styl,
         ls_stylerow        TYPE lvc_s_styl.

  DATA : ls_alvl1           LIKE LINE OF gt_alvl1.

  CALL METHOD g_tabgrid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT gt_alvl1 INTO ls_alvl1.
        READ TABLE ls_alvl1-style INTO ls_stylerow
                                  WITH KEY fieldname = 'MARK'.
        IF sy-subrc = 0 AND
            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          CONTINUE.
        ENDIF.
        ls_alvl1-mark = fu_check.
        MODIFY gt_alvl1 FROM ls_alvl1.
        CLEAR ls_alvl1.
      ENDLOOP.
    ENDIF.
    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refresh.
  IF fu_refresh IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    IF g_tabgrid IS NOT INITIAL.
      CALL METHOD g_tabgrid->refresh_table_display
        EXPORTING
          is_stable = gs_stable.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_STYLE_CELL
*&---------------------------------------------------------------------*
FORM f_style_cell  USING    fu_flag fu_fieldname fu_fieldname1
                   CHANGING fc_celltab  TYPE lvc_t_styl.
  DATA : lt_celltab   TYPE lvc_t_styl WITH HEADER LINE.

  CLEAR : lt_celltab[], lt_celltab.

  IF fu_flag IS NOT INITIAL.
    lt_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
  ELSE.
    lt_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.

  CLEAR fc_celltab[].

  IF fu_fieldname1 IS NOT INITIAL.
    lt_celltab-fieldname = fu_fieldname1.
    APPEND lt_celltab.
  ENDIF.
  lt_celltab-fieldname = fu_fieldname.
  APPEND lt_celltab.

  INSERT LINES OF lt_celltab INTO TABLE fc_celltab.
ENDFORM.                    " F_STYLE_CELL

*&---------------------------------------------------------------------*
*&      Form  F_DN_QTY
*&---------------------------------------------------------------------*
FORM f_dn_qty  USING    fs_bdcd   TYPE zbdcst01 fu_menge fu_menge1
               CHANGING fc_dnqty fc_carqty fc_cooqty.
  TYPES : BEGIN OF ty_qty,
            dnqty   TYPE mchb-clabs,
          END OF ty_qty.

  DATA : lt_qty     TYPE STANDARD TABLE OF ty_qty,
         ls_qty     LIKE LINE OF lt_qty.

  IF fs_bdcd-ebeln1 IS NOT INITIAL.
    ls_qty-dnqty    = fs_bdcd-menge1 - fu_menge.
*    ls_qty-dnqty    = fs_bdcd-menge1.
    IF ls_qty-dnqty >= 0.
      APPEND ls_qty TO lt_qty.
    ELSE.
      ls_qty-dnqty = 0.
      APPEND ls_qty TO lt_qty.
    ENDIF.
*    ls_qty-dnqty    = fs_bdcd-labst1.
*    APPEND ls_qty TO lt_qty.
  ENDIF.

  IF fs_bdcd-ebeln2 IS NOT INITIAL.
    IF fs_bdcd-ebeln3 IS INITIAL.
*        ls_qty-dnqty    = fs_bdcd-labst2 - fu_menge.
*      ELSE.
      ls_qty-dnqty    = fs_bdcd-labst2.
*      ENDIF.
      IF ls_qty-dnqty >= 0.
        APPEND ls_qty TO lt_qty.
      ENDIF.
    ENDIF.
    ls_qty-dnqty    = fs_bdcd-menge2 - fu_menge1.
*    ls_qty-dnqty    = fs_bdcd-menge2.
    IF ls_qty-dnqty >= 0.
      APPEND ls_qty TO lt_qty.
    ELSE.
      ls_qty-dnqty = 0.
      APPEND ls_qty TO lt_qty.
    ENDIF.
  ENDIF.

  IF fs_bdcd-ebeln3 IS NOT INITIAL.
*      ls_qty-dnqty    = fs_bdcd-menge3 - fu_menge.
    ls_qty-dnqty    = fs_bdcd-menge3.
    IF ls_qty-dnqty >= 0.
      APPEND ls_qty TO lt_qty.
    ENDIF.
*      ls_qty-dnqty    = fs_bdcd-labst3 - fu_menge.
    ls_qty-dnqty    = fs_bdcd-labst3.
    IF ls_qty-dnqty >= 0.
      APPEND ls_qty TO lt_qty.
    ENDIF.
  ENDIF.

  SORT lt_qty BY dnqty.
  READ TABLE lt_qty INTO ls_qty INDEX 1.
  fc_dnqty  = ls_qty-dnqty.

  PERFORM f_material_conversion USING fc_dnqty fs_bdcd-matnr
                                CHANGING fc_carqty fc_cooqty.
ENDFORM.                    " F_DN_QTY

*&---------------------------------------------------------------------*
*&      Form  F_SUBMIT_PARAMETER
*&---------------------------------------------------------------------*
FORM f_submit_parameter  USING    fu_selname fu_value fu_kind.
  rspar_line-selname = fu_selname.
  rspar_line-kind    = fu_kind.
  rspar_line-sign    = 'I'.
  rspar_line-option  = 'EQ'.
  rspar_line-low     = fu_value.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.
ENDFORM.                    " F_SUBMIT_PARAMETER

*&---------------------------------------------------------------------*
*&      Form  F_LIST_ERROR
*&---------------------------------------------------------------------*
FORM f_list_error  USING    fu_objkey fu_subrc.
  DATA : ls_error   LIKE LINE OF gt_error.

  ls_error-objkey   = fu_objkey.
  ls_error-msgid    = 'ZAB'.
  ls_error-msgty    = 'E'.
  ls_error-msgno    = '000'.

  CASE fu_subrc.
    WHEN '1'.
      ls_error-msgv1  = '1'.
      ls_error-msgv2  = '1'.
      ls_error-msgv3  = '1'.
      ls_error-msgv4  = '1'.
    WHEN '2'.
      ls_error-msgv1  = '2'.
      ls_error-msgv2  = '2'.
      ls_error-msgv3  = '2'.
      ls_error-msgv4  = '2'.
    WHEN '3'.
      ls_error-msgv1  = '3'.
      ls_error-msgv2  = '3'.
      ls_error-msgv3  = '3'.
      ls_error-msgv4  = '3'.
    WHEN '4'.
      ls_error-msgv1  = 'Qty COO <= 0'.
    WHEN '5'.
      ls_error-msgv1  = 'Qty COO > QtyDN'.
    WHEN '6'.
      ls_error-msgv1  = 'COO Complete'.
    WHEN '7'.
      ls_error-msgv1  = 'WM not yet completed'.
    WHEN '8'.
      ls_error-msgv1  = 'PGI Error'.
    WHEN '9'.
      ls_error-msgv1  = 'Goods issue has already been posted for delivery'.
  ENDCASE.
  APPEND ls_error TO gt_error.
  CLEAR ls_error.
ENDFORM.                    " F_LIST_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_ALV_SORT
*&---------------------------------------------------------------------*
FORM f_alv_sort  USING    fu_spos fu_fieldname fu_up fu_down fu_subtot.

  gt_main_sort-spos      = fu_spos.
  gt_main_sort-fieldname = fu_fieldname.
  gt_main_sort-up        = fu_up.
  gt_main_sort-down      = fu_down.
  gt_main_sort-subtot    = fu_subtot.
  APPEND gt_main_sort.
  CLEAR gt_main_sort.
ENDFORM.                    " F_ALV_SORT

*&---------------------------------------------------------------------*
*&      Form  F_MARD_STOCK
*&---------------------------------------------------------------------*
FORM f_mard_stock  USING    fu_matnr fu_type
                   CHANGING fc_labst.

  DATA : ls_mard    LIKE LINE OF gt_mard,
         ls_vbbe    LIKE LINE OF gt_vbbe.

  LOOP AT gt_mard INTO ls_mard WHERE matnr = fu_matnr.
    CASE fu_type.
      WHEN '1'.
        IF ls_mard-werks IN gr_merks1 AND
          ls_mard-lgort IN gr_mgort1.
          ADD ls_mard-labst TO fc_labst.
        ENDIF.
      WHEN '2'.
        IF ls_mard-werks IN gr_merks2 AND
          ls_mard-lgort IN gr_mgort2.
          ADD ls_mard-labst TO fc_labst.
        ENDIF.
      WHEN '3'.
        IF ls_mard-werks IN gr_merks3 AND
          ls_mard-lgort IN gr_mgort3.
          ADD ls_mard-labst TO fc_labst.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  LOOP AT gt_vbbe INTO ls_vbbe WHERE matnr = fu_matnr.
    CASE fu_type.
      WHEN '1'.
        IF ls_vbbe-werks IN gr_merks1 AND
          ls_vbbe-lgort IN gr_mgort1.
          fc_labst = fc_labst - ls_vbbe-omeng.
        ENDIF.
      WHEN '2'.
        IF ls_vbbe-werks IN gr_merks2 AND
          ls_vbbe-lgort IN gr_mgort2.
          fc_labst = fc_labst - ls_vbbe-omeng.
        ENDIF.
      WHEN '3'.
        IF ls_vbbe-werks IN gr_merks3 AND
          ls_vbbe-lgort IN gr_mgort3.
          fc_labst = fc_labst - ls_vbbe-omeng.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_MARD_STOCK

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TO_TABLE
*&---------------------------------------------------------------------*
FORM f_save_to_table  TABLES   ft_zbdcdt02 STRUCTURE zbdcdt02.
  DATA : lt_xbdcdt02    TYPE STANDARD TABLE OF zbdcdt02,
         ls_xbdcdt02    LIKE LINE OF lt_xbdcdt02,
         ls_zbdcdt02    TYPE zbdcdt02.

  DATA : lv_posnr       TYPE posnr.

  lt_xbdcdt02[] = ft_zbdcdt02[].
  DELETE ADJACENT DUPLICATES FROM lt_xbdcdt02 COMPARING coono.
  LOOP AT lt_xbdcdt02 INTO ls_xbdcdt02.
    CLEAR lv_posnr.
    LOOP AT ft_zbdcdt02 INTO ls_zbdcdt02
                        WHERE coono = ls_xbdcdt02-coono.
      ADD 1 TO lv_posnr.
      ls_zbdcdt02-posnr = lv_posnr.
      IF radio1 IS NOT INITIAL.
        ls_zbdcdt02-zendm = 'X'.
      ENDIF.
      MODIFY ft_zbdcdt02 FROM ls_zbdcdt02 TRANSPORTING posnr zendm.
      CLEAR ls_zbdcdt02.
    ENDLOOP.
  ENDLOOP.

  TRY .
      MODIFY zbdcdt02 FROM TABLE ft_zbdcdt02.
    CATCH cx_sy_open_sql_db.
  ENDTRY.

  COMMIT WORK.
ENDFORM.                    " F_SAVE_TO_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_COLOR_CELL
*&---------------------------------------------------------------------*
FORM f_color_cell  USING    fu_flag fu_fieldname
                   CHANGING fc_cellcol  TYPE lvc_t_scol.
  DATA : lt_cellcol   TYPE lvc_t_scol WITH HEADER LINE.

  CLEAR fc_cellcol[].

  IF fu_flag IS INITIAL.
    lt_cellcol-fname      = fu_fieldname.
    lt_cellcol-color-col  = '6'.
    lt_cellcol-color-int  = '1'.
    lt_cellcol-color-inv  = '0'.
    APPEND lt_cellcol.

    INSERT LINES OF lt_cellcol INTO TABLE fc_cellcol.
  ENDIF.
ENDFORM.                    " F_COLOR_CELL

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_COMPLETED_COO
*&---------------------------------------------------------------------*
FORM f_check_completed_coo  USING    fu_vbeln
                            CHANGING fc_subrc
                                     fs_alvl1  TYPE ty_alvl1.

  DATA : ls_vbuk      TYPE vbuk,
         lv_subrc     TYPE sy-subrc.

  CLEAR ls_vbuk.
  READ TABLE gt_vbuk INTO ls_vbuk
                     WITH KEY vbeln = fu_vbeln.
  IF sy-subrc = 0.
    IF ls_vbuk-lvstk <> 'C'.
      fc_subrc = 7.
    ENDIF.
  ENDIF.

  IF fc_subrc IS NOT INITIAL.
    fs_alvl1-icon   = icon_led_red.
    PERFORM f_list_error USING fs_alvl1-objkey fc_subrc.
    PERFORM f_style_cell USING '' 'MARK' ''
                         CHANGING fs_alvl1-style.
  ENDIF.
ENDFORM.                    " F_CHECK_COMPLETED_COO

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_KEY
*&---------------------------------------------------------------------*
FORM f_create_key  USING    fs_alvl1  TYPE ty_alvl1
                            fu_objkey
                   CHANGING fc_objkey.

  CASE fu_objkey.
    WHEN 'X'.
      fc_objkey  = fs_alvl1-coono.
    WHEN OTHERS.
      CONCATENATE fs_alvl1-ebeln1 fs_alvl1-ebelp1
                  fs_alvl1-ebeln2 fs_alvl1-ebelp2
                  fs_alvl1-ebeln3 fs_alvl1-ebelp3
             INTO fc_objkey.
  ENDCASE.
ENDFORM.                    " F_CREATE_KEY

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ME23N
*&---------------------------------------------------------------------*
FORM f_display_me23n  USING    fu_row fu_flag.
  DATA : lv_cursor  TYPE i,
         ls_alvl1   LIKE LINE OF gt_alvl1,
         lv_ebeln   TYPE mseg-ebeln,
         lv_fieldname(30).

  FIELD-SYMBOLS <fs>  TYPE ANY.

  IF fu_row IS NOT INITIAL.
    lv_cursor   = fu_row.
  ELSE.
    GET CURSOR LINE lv_cursor.
    lv_cursor = tc_bdc02-top_line + lv_cursor - 1.
  ENDIF.

  READ TABLE gt_alvl1 INTO ls_alvl1 INDEX lv_cursor.
  IF sy-subrc = 0.
    CONCATENATE 'LS_ALVL1-EBELN' fu_flag INTO lv_fieldname.
    CONDENSE lv_fieldname NO-GAPS.
    ASSIGN (lv_fieldname) TO <fs>.
    lv_ebeln = <fs>.
    SET PARAMETER ID 'BES' FIELD lv_ebeln.
    CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
  ENDIF.
ENDFORM.                    " F_DISPLAY_ME23N

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_VL03N
*&---------------------------------------------------------------------*
FORM f_display_vl03n  USING    fu_row fu_flag.
  DATA : lv_cursor  TYPE i,
         ls_alvl1   LIKE LINE OF gt_alvl1,
         lv_vbeln   TYPE likp-vbeln,
         lv_fieldname(30).

  FIELD-SYMBOLS <fs>  TYPE ANY.

  IF fu_row IS NOT INITIAL.
    lv_cursor   = fu_row.
  ELSE.
    GET CURSOR LINE lv_cursor.
    lv_cursor = tc_bdc02-top_line + lv_cursor - 1.
  ENDIF.

  READ TABLE gt_alvl1 INTO ls_alvl1 INDEX lv_cursor.
  IF sy-subrc = 0.
    CONCATENATE 'LS_ALVL1-VBELN' fu_flag INTO lv_fieldname.
    CONDENSE lv_fieldname NO-GAPS.
    ASSIGN (lv_fieldname) TO <fs>.
    lv_vbeln = <fs>.
    SET PARAMETER ID 'VL' FIELD lv_vbeln.
    CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
  ENDIF.
ENDFORM.                    " F_DISPLAY_VL03N

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_STATUS
*&---------------------------------------------------------------------*
FORM f_check_status  USING    fu_fieldname fu_status fu_vbeln
                     CHANGING fc_subrc.
  FIELD-SYMBOLS <fs>   TYPE ANY.

  DATA : ls_vbuk    LIKE LINE OF gt_vbuk,
         lv_fieldname(100).

  CLEAR : ls_vbuk, fc_subrc.
  READ TABLE gt_vbuk INTO ls_vbuk
                     WITH KEY vbeln = fu_vbeln.
  IF sy-subrc = 0.
    CONCATENATE 'LS_VBUK-' fu_fieldname INTO lv_fieldname.
    ASSIGN (lv_fieldname) TO <fs>.
    IF <fs> = fu_status.
      fc_subrc = 4.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_RETURN_MESSAGE
*&---------------------------------------------------------------------*
FORM f_return_message  USING    fu_memory
                       CHANGING fc_subrc fc_mblnr fc_mjahr fc_vbeln.
  DATA : lv_memory(100),
         gt_return  LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
         ls_return  TYPE bapiret2.

  CONCATENATE fu_memory sy-uname INTO lv_memory.
  IMPORT gt_return FROM MEMORY ID lv_memory.
  IF sy-subrc = 0.
    READ TABLE gt_return WITH KEY type = 'E'.
    IF sy-subrc = 0.
      LOOP AT gt_return INTO ls_return.
        APPEND ls_return TO gt_bapiret2.
        CLEAR ls_return.
      ENDLOOP.
      fc_subrc = 4.
    ELSE.
      READ TABLE gt_return WITH KEY type = space.
      CASE gt_return-number.
        WHEN '001'.
          SPLIT gt_return-message AT '|' INTO fc_mblnr fc_mjahr.
        WHEN '002'.
          fc_vbeln  = gt_return-message.
      ENDCASE.
    ENDIF.
  ENDIF.

  FREE MEMORY ID lv_memory.
  CLEAR : rspar_tab[].
ENDFORM.                    " F_RETURN_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_GUI_MESSAGE
*&---------------------------------------------------------------------*
FORM f_gui_message  USING    fu_percen fu_text1 fu_text2.
  DATA : lv_text(100).

  CONCATENATE fu_text1 fu_text2 INTO lv_text
  SEPARATED BY space.

  IF lv_text IS NOT INITIAL.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = fu_percen
        text       = lv_text.
  ENDIF.
ENDFORM.                    " F_GUI_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_FACTORY_POST
*&---------------------------------------------------------------------*
FORM f_factory_post  USING    fu_coono fu_vbeln fu_lgort fu_zendm fu_kgvnq
                     CHANGING fc_subrc.
  DATA : lv_subrc   TYPE sy-subrc,
         lv_mblnr   TYPE mseg-mblnr,
         lv_mjahr   TYPE mseg-mjahr,
         lv_vbeln   TYPE likp-vbeln.

* PGI
  PERFORM f_submit_parameter USING 'PA_VBELN' fu_vbeln 'P'.
  PERFORM f_gui_message USING '10' 'PGI DN Factory ...' ''.
  SUBMIT zmmbdcgi WITH SELECTION-TABLE rspar_tab AND RETURN.
  PERFORM f_return_message USING 'BDCGI_RETURN'
                           CHANGING lv_subrc lv_mblnr lv_mjahr lv_vbeln.
  IF lv_subrc IS INITIAL.
* GR
    PERFORM f_submit_parameter USING : 'PA_VBELN' fu_vbeln 'P',
                                       'PA_LGORT' fu_lgort 'P'.
    PERFORM f_gui_message USING '20' 'GR DN Factory ...' ''.
    SUBMIT zmmbdcgr WITH SELECTION-TABLE rspar_tab AND RETURN.
    PERFORM f_return_message USING 'BDCGR_RETURN'
                             CHANGING lv_subrc lv_mblnr lv_mjahr lv_vbeln.
    IF lv_subrc IS INITIAL.
* TO
      PERFORM f_submit_parameter USING : 'PA_TYPE' 'TR' 'P',
                                         'PA_ZENDM' fu_zendm 'P',
                                         'PA_MBLNR' lv_mblnr 'P',
                                         'PA_MJAHR' lv_mjahr 'P',
                                         'PA_VBELN' fu_vbeln 'P',
                                         'PA_VBEL1' fu_vbeln 'P',
                                         'PA_LGNUM' '051' 'P',
                                         'PA_KGVNQ' fu_kgvnq 'P'.
      PERFORM f_gui_message USING '30' 'TO Putaway Factory ...' ''.
      SUBMIT zmmbdcto WITH SELECTION-TABLE rspar_tab AND RETURN.
      PERFORM f_return_message USING 'BDCTO_RETURN'
                               CHANGING lv_subrc lv_mblnr lv_mjahr lv_vbeln.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_FACTORY_POST

*&---------------------------------------------------------------------*
*&      Form  F_MARKETING_POST
*&---------------------------------------------------------------------*
FORM f_marketing_post  USING    fu_coono fu_vbeln fu_lgort fu_zendm
                                fu_vbel1 fu_kgvnq fu_flag
                       CHANGING fc_subrc.
  DATA : ls_alvl1     LIKE LINE OF gt_alvl1,
         lv_subrc     TYPE sy-subrc,
         lv_mblnr     TYPE mseg-mblnr,
         lv_mjahr     TYPE mseg-mjahr,
         lv_vbeln     TYPE likp-vbeln,
         ls_ekpv      LIKE LINE OF gt_ekpv,
         lv_txz01     TYPE ekpo-txz01,
         ls_zbdcdt02  LIKE LINE OF gt_zbdcdt02.

  IF fu_vbeln IS INITIAL.
* DN
    LOOP AT gt_alvl1 INTO ls_alvl1 WHERE coono = fu_coono.
      CLEAR : ls_ekpv.
      READ TABLE gt_ekpv INTO ls_ekpv
                         WITH KEY ebeln = ls_alvl1-ebeln2.
      CLEAR lv_txz01.
      CONCATENATE ls_ekpv-vstel ls_alvl1-vbeln3 ls_alvl1-ebeln2 ls_alvl1-matnr
      INTO lv_txz01
      SEPARATED BY '|'.
      PERFORM f_submit_parameter USING : 'PA_PROC' '2' 'P',
                                         'SO_TXZ01-LOW' lv_txz01 'S'.
    ENDLOOP.

    PERFORM f_gui_message USING '40' 'DN Marketing ...' ''.
    SUBMIT zmmbdcdn WITH SELECTION-TABLE rspar_tab AND RETURN.
    PERFORM f_return_message USING 'BDCDN_RETURN'
                             CHANGING lv_subrc lv_mblnr lv_mjahr lv_vbeln.
    IF lv_subrc IS INITIAL.
      IF lv_vbeln IS NOT INITIAL.
        CLEAR : ls_zbdcdt02.
        ls_alvl1-vbeln2 = lv_vbeln.
        MODIFY gt_alvl1 FROM ls_alvl1
                        TRANSPORTING vbeln2
                        WHERE coono  = ls_alvl1-coono.

        MOVE-CORRESPONDING ls_alvl1 TO ls_zbdcdt02.
        ls_zbdcdt02-ebeln_fc  = ls_alvl1-ebeln3.
        ls_zbdcdt02-ebeln_mk  = ls_alvl1-ebeln2.
        ls_zbdcdt02-ebeln_al  = ls_alvl1-ebeln1.
        ls_zbdcdt02-vbeln_fc  = ls_alvl1-vbeln3.
        ls_zbdcdt02-vbeln_mk  = ls_alvl1-vbeln2.
        ls_zbdcdt02-vbeln_al  = ls_alvl1-vbeln1.
        TRY .
            MODIFY zbdcdt02 FROM ls_zbdcdt02.
          CATCH cx_root.
        ENDTRY.
      ENDIF.
    ELSE.
      lv_vbeln  = fu_vbeln.
    ENDIF.
* TO
    PERFORM f_submit_parameter USING : 'PA_TYPE' 'DN' 'P',
                                       'PA_COO' 'X' 'P',
                                       'PA_ZENDM' fu_zendm 'P',
                                       'PA_CONFI' 'X' 'P',
                                       'PA_LGNUM' '051' 'P',
                                       'PA_VBELN' lv_vbeln 'P',
                                       'PA_VBEL1' fu_vbel1 'P',
                                       'PA_KGVNQ' fu_kgvnq 'P'.
    PERFORM f_gui_message USING '50' 'TO DN Marketing ...' ''.
    SUBMIT zmmbdcto WITH SELECTION-TABLE rspar_tab AND RETURN.
    PERFORM f_return_message USING 'BDCTO_RETURN'
                             CHANGING lv_subrc lv_mblnr lv_mjahr lv_vbeln.
    IF lv_subrc IS INITIAL.
* PGI
      PERFORM f_submit_parameter USING 'PA_VBELN' lv_vbeln 'P'.
      PERFORM f_gui_message USING '60' 'PGI DN Marketing ...' ''.
      SUBMIT zmmbdcgi WITH SELECTION-TABLE rspar_tab AND RETURN.
      PERFORM f_return_message USING 'BDCGI_RETURN'
                               CHANGING lv_subrc lv_mblnr lv_mjahr lv_vbeln.
      IF lv_subrc IS INITIAL.
* GR
        PERFORM f_submit_parameter USING : 'PA_VBELN' lv_vbeln 'P',
                                           'PA_LGORT' '1001' 'P'.
        PERFORM f_gui_message USING '70' 'GR DN Marketing ...' ''.
        SUBMIT zmmbdcgr WITH SELECTION-TABLE rspar_tab AND RETURN.
        PERFORM f_return_message USING 'BDCGR_RETURN'
                                 CHANGING lv_subrc lv_mblnr lv_mjahr lv_vbeln.
        IF lv_subrc IS INITIAL.
* TO
          PERFORM f_submit_parameter USING : 'PA_TYPE' 'TR' 'P',
                                             'PA_ZENDM' fu_zendm 'P',
                                             'PA_MBLNR' lv_mblnr 'P',
                                             'PA_MJAHR' lv_mjahr 'P',
                                             'PA_VBELN' fu_vbeln 'P',
                                             'PA_LGNUM' '051' 'P',
                                             'PA_VBEL1' fu_vbel1 'P',
                                             'PA_KGVNQ' fu_kgvnq 'P'.
          PERFORM f_gui_message USING '80' 'TO Putaway Marketing ...' ''.
          SUBMIT zmmbdcto WITH SELECTION-TABLE rspar_tab AND RETURN.
          PERFORM f_return_message USING 'BDCTO_RETURN'
                                   CHANGING lv_subrc lv_mblnr lv_mjahr lv_vbeln.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    IF fu_flag IS NOT INITIAL.
* PGI
      PERFORM f_submit_parameter USING 'PA_VBELN' fu_vbeln 'P'.
      PERFORM f_gui_message USING '60' 'PGI DN Marketing ...' ''.
      SUBMIT zmmbdcgi WITH SELECTION-TABLE rspar_tab AND RETURN.
      PERFORM f_return_message USING 'BDCGI_RETURN'
                               CHANGING lv_subrc lv_mblnr lv_mjahr lv_vbeln.
      IF lv_subrc IS INITIAL.
* GR
        PERFORM f_submit_parameter USING : 'PA_VBELN' fu_vbeln 'P',
                                           'PA_LGORT' '1001' 'P'.
        PERFORM f_gui_message USING '70' 'GR DN Marketing ...' ''.
        SUBMIT zmmbdcgr WITH SELECTION-TABLE rspar_tab AND RETURN.
        PERFORM f_return_message USING 'BDCGR_RETURN'
                                 CHANGING lv_subrc lv_mblnr lv_mjahr lv_vbeln.
        IF lv_subrc IS INITIAL.
* TO
          PERFORM f_submit_parameter USING : 'PA_TYPE' 'TR' 'P',
                                             'PA_ZENDM' fu_zendm 'P',
                                             'PA_MBLNR' lv_mblnr 'P',
                                             'PA_MJAHR' lv_mjahr 'P',
                                             'PA_VBELN' fu_vbeln 'P',
                                             'PA_LGNUM' '051' 'P',
                                             'PA_VBEL1' fu_vbel1 'P',
                                             'PA_KGVNQ' fu_kgvnq 'P'.
          PERFORM f_gui_message USING '80' 'TO Putaway Marketing ...' ''.
          SUBMIT zmmbdcto WITH SELECTION-TABLE rspar_tab AND RETURN.
          PERFORM f_return_message USING 'BDCTO_RETURN'
                                   CHANGING lv_subrc lv_mblnr lv_mjahr lv_vbeln.
        ENDIF.
      ENDIF.
    ENDIF.

    IF radio1 IS NOT INITIAL.
      IF lv_subrc IS INITIAL.
        DELETE FROM zbdcdt02a WHERE coono = fu_coono.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MARKETING_POST

*&---------------------------------------------------------------------*
*&      Form  F_ALOKASI_POST
*&---------------------------------------------------------------------*
FORM f_alokasi_post  USING    fu_coono fu_vbeln fu_zendm fu_kgvnq.
  DATA : ls_alvl1     LIKE LINE OF gt_alvl1,
         lv_subrc     TYPE sy-subrc,
         lv_mblnr     TYPE mseg-mblnr,
         lv_mjahr     TYPE mseg-mjahr,
         lv_vbeln     TYPE likp-vbeln,
         ls_ekpv      LIKE LINE OF gt_ekpv,
         lv_txz01     TYPE ekpo-txz01,
         ls_zbdcdt02  LIKE LINE OF gt_zbdcdt02.

  IF fu_vbeln IS INITIAL.
* DN
    LOOP AT gt_alvl1 INTO ls_alvl1 WHERE coono = fu_coono.
      CLEAR : ls_ekpv.
      READ TABLE gt_ekpv INTO ls_ekpv
                         WITH KEY ebeln = ls_alvl1-ebeln1.
      CLEAR lv_txz01.
      CONCATENATE ls_ekpv-vstel ls_alvl1-vbeln2 ls_alvl1-ebeln1 ls_alvl1-matnr
      INTO lv_txz01
      SEPARATED BY '|'.

      CLEAR rspar_tab[].
      PERFORM f_submit_parameter USING : 'PA_PROC' '2' 'P',
                                         'SO_TXZ01-LOW' lv_txz01 'S'.

      PERFORM f_gui_message USING '90' 'DN Alokasi ...' ''.
      SUBMIT zmmbdcdn WITH SELECTION-TABLE rspar_tab AND RETURN.
      PERFORM f_return_message USING 'BDCDN_RETURN'
                               CHANGING lv_subrc lv_mblnr lv_mjahr lv_vbeln.
      IF lv_subrc IS INITIAL.
        IF lv_vbeln IS NOT INITIAL.
          CLEAR : ls_zbdcdt02.
          ls_alvl1-vbeln1 = lv_vbeln.
          MODIFY gt_alvl1 FROM ls_alvl1
                          TRANSPORTING vbeln1
                          WHERE coono  = ls_alvl1-coono
                            AND posnr  = ls_alvl1-posnr.

          MOVE-CORRESPONDING ls_alvl1 TO ls_zbdcdt02.
          ls_zbdcdt02-ebeln_fc  = ls_alvl1-ebeln3.
          ls_zbdcdt02-ebeln_mk  = ls_alvl1-ebeln2.
          ls_zbdcdt02-ebeln_al  = ls_alvl1-ebeln1.
          ls_zbdcdt02-vbeln_fc  = ls_alvl1-vbeln3.
          ls_zbdcdt02-vbeln_mk  = ls_alvl1-vbeln2.
          ls_zbdcdt02-vbeln_al  = ls_alvl1-vbeln1.
          TRY .
              MODIFY zbdcdt02 FROM ls_zbdcdt02.
            CATCH cx_root.
          ENDTRY.
        ENDIF.
      ELSE.
        lv_vbeln  = fu_vbeln.
      ENDIF.
* TO
      PERFORM f_submit_parameter USING : 'PA_TYPE' 'DN' 'P',
                                         'PA_COO' 'X' 'P',
                                         'PA_ZENDM' fu_zendm 'P',
                                         'PA_CONFI' 'X' 'P',
                                         'PA_LGNUM' '051' 'P',
                                         'PA_VBELN' lv_vbeln 'P',
                                         'PA_KGVNQ' fu_kgvnq 'P'.
      PERFORM f_gui_message USING '100' 'TO DN Alokasi ...' ''.
      SUBMIT zmmbdcto WITH SELECTION-TABLE rspar_tab AND RETURN.
      PERFORM f_return_message USING 'BDCTO_RETURN'
                               CHANGING lv_subrc lv_mblnr lv_mjahr lv_vbeln.
      IF lv_subrc IS INITIAL.
        PERFORM f_style_cell USING '' 'MARK' ''
                             CHANGING ls_alvl1-style.

        ls_alvl1-icon = icon_led_green.

        DELETE FROM zbdcdt02a WHERE coono = fu_coono.

        MODIFY gt_alvl1 FROM ls_alvl1
                        TRANSPORTING icon style
                        WHERE coono = fu_coono.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_ALOKASI_POST

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_CONTINUE
*&---------------------------------------------------------------------*
FORM f_process_continue  TABLES   ft_proc STRUCTURE zbdcdt02
                         USING    fu_zendm
                         CHANGING fc_subrc.
  DATA : lt_proc        TYPE STANDARD TABLE OF zbdcdt02,
         ls_proc        LIKE LINE OF lt_proc,
         lt_zbdcdt02    TYPE STANDARD TABLE OF zbdcdt02,
         ls_zbdcdt02    LIKE LINE OF lt_zbdcdt02,
         ls_alvl1       LIKE LINE OF gt_alvl1.

  CALL FUNCTION 'ZFMWAIT'.

  lt_proc[] = ft_proc[].
  SORT lt_proc BY coono.
  DELETE ADJACENT DUPLICATES FROM lt_proc COMPARING coono.
  IF lt_proc[] IS NOT INITIAL.

    SELECT *
      FROM zbdcdt02
      INTO CORRESPONDING FIELDS OF TABLE lt_zbdcdt02
      FOR ALL ENTRIES IN lt_proc
      WHERE coono = lt_proc-coono.

    LOOP AT gt_alvl1 INTO ls_alvl1.
      CLEAR ls_zbdcdt02.
      READ TABLE lt_zbdcdt02 INTO ls_zbdcdt02
                             WITH KEY coono = ls_alvl1-coono
                                      matnr = ls_alvl1-matnr.
      IF sy-subrc = 0.
        CASE ls_alvl1-flag.
          WHEN '2'.
            ls_alvl1-vbeln2   = ls_alvl1-coodn.
            ls_alvl1-posnr    = ls_zbdcdt02-posnr.
          WHEN '3'.
            ls_alvl1-vbeln3   = ls_alvl1-coodn.
            ls_alvl1-posnr    = ls_zbdcdt02-posnr.
        ENDCASE.
        ls_alvl1-zendm  = ls_zbdcdt02-zendm.
        MODIFY gt_alvl1 FROM ls_alvl1.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_proc INTO ls_proc.
      LOOP AT gt_alvl1 INTO ls_alvl1 WHERE coono = ls_proc-coono.
        CLEAR : bdcd, rspar_tab[].
        CASE ls_alvl1-flag.
          WHEN '2'.
            IF ls_alvl1-vbeln2 IS NOT INITIAL.
* Marketing Process
              PERFORM f_marketing_post USING ls_alvl1-coono ls_alvl1-vbeln2 '1001'
                                             fu_zendm ls_alvl1-vbeln2 'X' 'X'
                                       CHANGING fc_subrc.
            ENDIF.
          WHEN '3'.
            IF ls_alvl1-vbeln3 IS NOT INITIAL.
* Factory Process
              PERFORM f_factory_post USING ls_alvl1-coono ls_alvl1-vbeln3 '3000'
                                           fu_zendm 'X'
                                     CHANGING fc_subrc.
              IF fc_subrc IS INITIAL.
* Marketing Process
                PERFORM f_marketing_post USING ls_alvl1-coono ls_alvl1-vbeln2 '1001'
                                               fu_zendm ls_alvl1-vbeln3 'X' ''
                                         CHANGING fc_subrc.
              ELSE.
                CONTINUE.
              ENDIF.
            ENDIF.
        ENDCASE.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PROCESS_CONTINUE

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_COO_NO
*&---------------------------------------------------------------------*
FORM f_save_coo_no  USING    fs_alvl1   TYPE ty_alvl1
                             fu_zendm
                    CHANGING fc_posnr.

  DATA : ls_post1       LIKE LINE OF gt_post1,
         ls_zbdcdt02    TYPE zbdcdt02,
         ls_zbdcdt02a   TYPE zbdcdt02a.

  MOVE-CORRESPONDING fs_alvl1 TO ls_zbdcdt02.
  ls_zbdcdt02-ebeln_fc  = fs_alvl1-ebeln3.
  ls_zbdcdt02-ebeln_mk  = fs_alvl1-ebeln2.
  ls_zbdcdt02-ebeln_al  = fs_alvl1-ebeln1.

  CASE fs_alvl1-flag.
    WHEN '1'.
      ls_zbdcdt02-vbeln_al  = fs_alvl1-coodn.
    WHEN '2'.
      ls_zbdcdt02-vbeln_mk  = fs_alvl1-coodn.
    WHEN '3'.
      ls_zbdcdt02-vbeln_fc  = fs_alvl1-coodn.
  ENDCASE.

  ls_zbdcdt02-posnr = fc_posnr.
  IF radio1 IS NOT INITIAL.
    ls_zbdcdt02-zendm = fu_zendm.
  ENDIF.

  ls_zbdcdt02-coodt = sy-datum.
  ls_zbdcdt02-cootm = sy-uzeit.
  ls_zbdcdt02-coonm = sy-uname.
  ls_zbdcdt02-zqty  = fs_alvl1-cooqty.

  IF ls_zbdcdt02-coono IS NOT INITIAL.
    TRY .
        MODIFY zbdcdt02 FROM ls_zbdcdt02.
      CATCH cx_sy_open_sql_db.
    ENDTRY.

    ls_zbdcdt02a-coono = ls_zbdcdt02-coono.

    TRY .
        MODIFY zbdcdt02a FROM ls_zbdcdt02a.
      CATCH cx_sy_open_sql_db.
    ENDTRY.

    COMMIT WORK.
  ENDIF.
ENDFORM.                    " F_SAVE_COO_NO

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_COOQTY
*&---------------------------------------------------------------------*
FORM f_validate_cooqty  USING    fs_alvl1  TYPE ty_alvl1
                                 fu_txz01 fu_objkey
                        CHANGING fc_cooqty.
  DATA : lv_reswk   TYPE ekko-reswk,
         ls_ekko    LIKE LINE OF gt_ekko,
         ls_lqua    LIKE LINE OF gt_lqua,
         ls_marm    LIKE LINE OF gt_marm,
         ls_mlgn    LIKE LINE OF gt_mlgn,
         ls_xlqua   LIKE LINE OF gt_xlqua,
         lv_cart    TYPE lips-lfimg,
         lv_pallet  TYPE lips-lfimg,
         lv_cooqty  TYPE mchb-clabs,
         lv_tbpos   TYPE mseg-tbpos,
         lv_days    TYPE i,
         lv_sisa    TYPE lips-lfimg.

  IF fs_alvl1-ebeln3 IS NOT INITIAL.
    READ TABLE gt_ekko INTO ls_ekko
                       WITH KEY ebeln = fs_alvl1-ebeln3.
    IF sy-subrc = 0.
      lv_reswk  = ls_ekko-reswk.
    ENDIF.
  ELSEIF fs_alvl1-ebeln2 IS NOT INITIAL.
    READ TABLE gt_ekko INTO ls_ekko
                       WITH KEY ebeln = fs_alvl1-ebeln2.
    IF sy-subrc = 0.
      lv_reswk  = ls_ekko-reswk.
    ENDIF.
  ELSEIF fs_alvl1-ebeln1 IS NOT INITIAL.
    READ TABLE gt_ekko INTO ls_ekko
                       WITH KEY ebeln = fs_alvl1-ebeln1.
    IF sy-subrc = 0.
      lv_reswk  = ls_ekko-reswk.
    ENDIF.
  ENDIF.

  CLEAR ls_marm.
  READ TABLE gt_marm INTO ls_marm
                     WITH KEY matnr = fs_alvl1-matnr.
  IF sy-subrc = 0.
    lv_cart = ls_marm-umrez / ls_marm-umren.
  ENDIF.

  CLEAR ls_mlgn.
  READ TABLE gt_mlgn INTO ls_mlgn
                     WITH KEY matnr = fs_alvl1-matnr.
  IF sy-subrc = 0.
    lv_pallet = ls_mlgn-lhmg1.
  ENDIF.

  lv_cooqty   = fs_alvl1-cooqty.

  IF lv_cooqty BETWEEN lv_cart AND lv_pallet.
    SORT gt_lqua BY verme vfdat charg lgpla ASCENDING.
  ELSEIF lv_cooqty > lv_pallet.
    SORT gt_lqua BY verme DESCENDING vfdat charg lgpla ASCENDING.
  ENDIF.

  LOOP AT gt_lqua INTO ls_lqua WHERE matnr = fs_alvl1-matnr
                                 AND werks = lv_reswk.

    lv_days = ls_lqua-vfdat - sy-datum.
    IF lv_days < 365.
      CONTINUE.
    ENDIF.
    ls_xlqua-objkey  = fu_objkey.
    ADD 1 TO lv_tbpos.
*    ls_xlqua-txz01   = fu_txz01.
    ls_xlqua-tbpos   = lv_tbpos.
    ls_xlqua-matnr   = ls_lqua-matnr.
    ls_xlqua-charg   = ls_lqua-charg.
    ls_xlqua-verme   = ls_lqua-verme.
    ls_xlqua-meins   = ls_lqua-meins.
    ls_xlqua-lgtyp   = ls_lqua-lgtyp.
    ls_xlqua-lgpla   = ls_lqua-lgpla.
    IF lv_cooqty < ls_lqua-verme.
      IF lv_cooqty < lv_cart.
        fc_cooqty = fs_alvl1-cooqty - lv_cooqty.
        CLEAR: lv_cooqty.
      ELSE.
        lv_sisa = lv_cooqty MOD lv_cart.
        ls_xlqua-verme  = lv_cooqty - lv_sisa.
        APPEND ls_xlqua TO gt_xlqua.
        CLEAR: fc_cooqty, lv_cooqty.
        LOOP AT gt_xlqua INTO ls_xlqua WHERE matnr = fs_alvl1-matnr.
          ADD ls_xlqua-verme TO fc_cooqty.
        ENDLOOP.
      ENDIF.
      EXIT.
    ELSE.
      lv_cooqty = lv_cooqty - ls_lqua-verme.
      APPEND ls_xlqua TO gt_xlqua.
    ENDIF.
  ENDLOOP.

  fc_cooqty = fs_alvl1-cooqty - lv_cooqty.
ENDFORM.                    " F_VALIDATE_COOQTY
