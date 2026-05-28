*&---------------------------------------------------------------------*
*&  Include           ZMM_ABSF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  IF pa_bukrs = '8210'.   "Pulau Mahoni
    PERFORM f_modify_screen USING : 'ABR' '1' ''.
    PERFORM f_modify_screen USING : 'BMC' '1' ''.
    PERFORM f_modify_screen USING : 'CRP' '0' ''.
    PERFORM f_modify_screen USING : 'PRP' '0' ''.
    PERFORM f_modify_screen USING : 'APR' '0' ''.
    PERFORM f_modify_screen USING : 'BBK' '0' ''.
    PERFORM f_modify_screen USING : 'CP' '0' ''.
    PERFORM f_modify_screen USING : 'PBP' '0' ''.
  ELSE.
    PERFORM f_modify_screen USING : 'BMC' '0' ''.
    PERFORM f_modify_screen USING : 'ABR' '1' ''.
    PERFORM f_modify_screen USING : 'CRP' '1' ''.
    PERFORM f_modify_screen USING : 'PRP' '1' ''.
    PERFORM f_modify_screen USING : 'APR' '1' ''.
    PERFORM f_modify_screen USING : 'BBK' '1' ''.
    PERFORM f_modify_screen USING : 'CP' '1' ''.
    PERFORM f_modify_screen USING : 'PBP' '1' ''.
  ENDIF.

  CASE 'X'.
    WHEN pa_abs.
    WHEN pa_mc.
      IF pa_bukrs NE '8210'.
        CLEAR: pa_mc.
        pa_abs = 'X'.
      ENDIF.
    WHEN OTHERS.
      IF pa_bukrs = '8210'.
        CLEAR: pa_crp,pa_prp,pa_apr,pa_bbk,pa_cp,pa_pbap,pa_bbk2.
        pa_abs = 'X'.
      ENDIF.
  ENDCASE.

  CASE 'X'.
    WHEN pa_abs.
      PERFORM f_modify_screen USING : 'SRN' '0' '',
                                      'SRD' '0' '',
                                      'PRN' '0' '',
                                      'PFT' '0' '',
                                      'PSC' '0' '',
                                      'PDE' '0' '',
                                      'C05' '' '0',
                                      'SBN' '0' '',
                                      'SBD' '0' '',
                                      'CLN' '0' '',
                                      'CLD' '0' '',
                                      'PBA' '0' '',
                                      'BAP' '0' '',
                                      'PRT' '0' ''.
    WHEN pa_crp.
      PERFORM f_modify_screen USING : 'ABS' '0' '',
                                      'PRN' '0' '',
                                      'PFT' '0' '',
                                      'PSC' '0' '',
                                      'C01' '0' '',
                                      'C02' '0' '',
                                      'C03' '0' '',
                                      'C04' '0' '',
                                      'C05' '0' '',
                                      'SBN' '0' '',
                                      'SBD' '0' '',
                                      'CLN' '0' '',
                                      'CLD' '0' '',
                                      'PBA' '0' '',
                                      'BAP' '0' '',
                                      'PRT' '0' ''.

    WHEN pa_prp.
      PERFORM f_modify_screen USING : 'ABS' '0' '',
                                      'SRN' '0' '',
                                      'SRD' '0' '',
                                      'PSC' '0' '',
                                      'C01' '0' '',
                                      'C02' '0' '',
                                      'C03' '0' '',
                                      'C04' '0' '',
                                      'C05' '0' '',
                                      'PDE' '0' '',
                                      'SBN' '0' '',
                                      'SBD' '0' '',
                                      'CLN' '0' '',
                                      'CLD' '0' '',
                                      'PBA' '0' '',
                                      'BAP' '0' ''.

    WHEN pa_apr.
      PERFORM f_modify_screen USING : 'ABS' '0' '',
                                      'PRN' '0' '',
                                      'PFT' '0' '',
                                      'PSC' '0' '',
                                      'C01' '0' '',
                                      'C02' '0' '',
                                      'C03' '0' '',
                                      'C04' '0' '',
                                      'C05' '0' '',
                                      'PDE' '0' '',
                                      'SBN' '0' '',
                                      'SBD' '0' '',
                                      'CLN' '0' '',
                                      'CLD' '0' '',
                                      'PBA' '0' '',
                                      'BAP' '0' '',
                                      'PRT' '0' ''.

    WHEN pa_bbk OR pa_bbk2.
      PERFORM f_modify_screen USING : 'ABS' '0' '',
                                      'PRN' '0' '',
                                      'PFT' '0' '',
                                      'PSC' '0' '',
                                      'C01' '0' '',
                                      'C02' '0' '',
                                      'C03' '0' '',
                                      'C04' '0' '',
                                      'C05' '0' '',
                                      'PDE' '0' '',
                                      'SBN' '0' '',
                                      'SBD' '0' '',
                                      'CLN' '0' '',
                                      'CLD' '0' '',
                                      'PBA' '0' '',
                                      'BAP' '0' '',
                                      'PRT' '0' ''.

    WHEN pa_cp.
      PERFORM f_modify_screen USING : 'ABS' '0' '',
                                      'PRN' '0' '',
                                      'PFT' '0' '',
                                      'PSC' '0' '',
                                      'C01' '0' '',
                                      'C02' '0' '',
                                      'C03' '0' '',
                                      'C04' '0' '',
                                      'C05' '0' '',
                                      'PDE' '0' '',
                                      'SRN' '0' '',
                                      'SRD' '0' '',
                                      'CLN' '0' '',
                                      'CLD' '0' '',
                                      'PBA' '0' '',
                                      'BAP' '0' '',
                                      'PRT' '0' ''.

    WHEN pa_pbap.
      PERFORM f_modify_screen USING : 'ABS' '0' '',
                                      'SRN' '0' '',
                                      'SRD' '0' '',
                                      'PFT' '0' '',
                                      'C01' '0' '',
                                      'C02' '0' '',
                                      'C03' '0' '',
                                      'C04' '0' '',
                                      'C05' '0' '',
                                      'PDE' '0' '',
                                      'SBN' '0' '',
                                      'SBD' '0' '',
                                      'PRN' '0' '',
                                      'CLN' '0' '',
                                      'CLD' '0' '',
                                      'PSC' '0' '',
                                      'PRT' '0' ''.

    WHEN pa_mc.
      PERFORM f_modify_screen USING : 'ABS' '0' '',
                                      'SRN' '0' '',
                                      'SRD' '0' '',
                                      'PFT' '0' '',
                                      'C01' '0' '',
                                      'C02' '0' '',
                                      'C03' '0' '',
                                      'C04' '0' '',
                                      'C05' '0' '',
                                      'PDE' '0' '',
                                      'SBN' '0' '',
                                      'SBD' '0' '',
                                      'PRN' '0' '',
                                      'PSC' '0' '',
                                      'PBA' '0' '',
                                      'BAP' '0' '',
                                      'PRT' '0' ''.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  CASE 'X'.
    WHEN pa_abs.
      IF pa_col01 IS INITIAL.
        PERFORM f_error_selection_screen USING 'C01' '0' ''.
      ENDIF.
      IF pa_col02 IS INITIAL.
        PERFORM f_error_selection_screen USING 'C02' '0' ''.
      ENDIF.
      IF pa_col03 IS INITIAL.
        PERFORM f_error_selection_screen USING 'C03' '0' ''.
      ENDIF.
      IF pa_col04 IS INITIAL.
        PERFORM f_error_selection_screen USING 'C04' '0' ''.
      ENDIF.
      pa_col05 = pa_col04.

    WHEN pa_prp.
      IF pa_reqno IS INITIAL.
        PERFORM f_error_selection_screen USING 'PRN' '0' ''.
      ENDIF.

      IF pa_reprt IS NOT INITIAL.
        SELECT SINGLE zfrmtl
          FROM zgdmmt0001 INTO pa_leter
          WHERE req_no = pa_reqno
            AND zfrmtl NE space.
        IF sy-subrc <> 0.
*          lv_check = sy-subrc.
          PERFORM f_error_selection_screen USING 'PRT' '3'
                                           'Do not use reprint for this request'.
        ENDIF.
      ENDIF.

      IF pa_leter IS INITIAL.
        PERFORM f_error_selection_screen USING 'PFT' '0' ''.
      ENDIF.

    WHEN pa_pbap.
      IF pa_bapno IS INITIAL.
        PERFORM f_error_selection_screen USING 'PBA' '0' ''.
      ENDIF.

    WHEN pa_mc.
      IF pa_clano IS INITIAL.
        PERFORM f_error_selection_screen USING 'CLN' '0' ''.
      ENDIF.
      IF pa_cladt IS INITIAL.
        PERFORM f_error_selection_screen USING 'CLD' '0' ''.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error fu_value.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
    WHEN '1'.
      lv_mess = 'You are not authorized'.
    WHEN '2'.
      lv_mess = fu_value.
      CONDENSE lv_mess.
      CONCATENATE 'Enter a number greater than to' lv_mess INTO lv_mess
      SEPARATED BY space.
    WHEN '3'.
      lv_mess = fu_value.
  ENDCASE.

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
ENDFORM.                    " F_ERROR_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ENTRY
*&---------------------------------------------------------------------*
FORM f_check_entry .
* Check some entered data for consistency
  CALL FUNCTION 'MMIM_ENTRYCHECK_MAIN'
    TABLES
      it_matnr = so_matnr
      it_werks = so_werks
      it_lgort = so_lgort.

* Material type
  IF so_mtart-low IS NOT INITIAL OR
    so_mtart-high IS NOT INITIAL.
    SELECT SINGLE *
      FROM t134m
      WHERE mtart IN so_mtart.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE e104(m3) WITH so_mtart-low.
    ENDIF.
  ENDIF.

* Material group
  IF so_matkl-low IS NOT INITIAL OR
    so_matkl-high IS NOT INITIAL.
    SELECT SINGLE *
      FROM t023
      WHERE matkl IN so_matkl.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE e883 WITH so_matkl-low.
    ENDIF.
  ENDIF.

* Aging
  IF pa_col01 IS NOT INITIAL AND
    pa_col02 IS NOT INITIAL AND
    pa_col03 IS NOT INITIAL AND
    pa_col04 IS NOT INITIAL.
    IF pa_col02 <= pa_col01.
      PERFORM f_error_selection_screen USING 'C02' '2' pa_col01.
    ENDIF.
    IF pa_col03 <= pa_col02.
      PERFORM f_error_selection_screen USING 'C03' '2' pa_col02.
    ENDIF.
    IF pa_col04 <= pa_col03.
      PERFORM f_error_selection_screen USING 'C04' '2' pa_col03.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_ENTRY

*&---------------------------------------------------------------------*
*&      Form  F_ORGANISATION
*&---------------------------------------------------------------------*
FORM f_organisation .
* get all existing storage bins of the required plants
  CLEAR   : g_t_organ[], g_s_organ.

  SELECT DISTINCT werks name1 bwkey
    FROM t001w
    INTO CORRESPONDING FIELDS OF TABLE g_t_organ
    WHERE werks IN so_werks.

  SORT g_t_organ BY bwkey.
  LOOP AT g_t_organ INTO g_s_organ.
    ON CHANGE OF g_s_organ-bwkey.
      CLEAR g_flag_ok.

      SELECT SINGLE *
        FROM t001k
        WHERE bwkey = g_s_organ-bwkey.

      IF sy-subrc IS INITIAL.
        SELECT SINGLE *
          FROM t001
          WHERE bukrs = t001k-bukrs.
        IF sy-subrc IS INITIAL.
          g_flag_ok = 'X'.
        ENDIF.
      ENDIF.
    ENDON.

    IF g_flag_ok = 'X'.
      MOVE-CORRESPONDING t001 TO g_s_organ.
      MODIFY g_t_organ FROM  g_s_organ.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_ORGANISATION

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM f_check_authorization .
  DATA : l_s_bukrs TYPE  stype_buffer,
         l_t_bukrs TYPE  stab_buffer.

  SORT g_t_organ BY werks.
  LOOP AT g_t_organ INTO g_s_organ.
    AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
        ID 'ACTVT' FIELD '03'
        ID 'WERKS' FIELD g_s_organ-werks.

    IF sy-subrc IS NOT INITIAL.
      SET CURSOR FIELD  'SO_WERKS-LOW'.
      MESSAGE e120 WITH  g_s_organ-werks.
    ENDIF.

* the user wants to see the values
    IF pa_dondv IS INITIAL.
      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
          ID 'BUKRS' FIELD g_s_organ-bukrs
          ID 'ACTVT' FIELD '03'.
      IF sy-subrc <> 0.
        MOVE : 'X'              TO  g_flag_mess_333,
               g_s_organ-bukrs  TO  l_s_bukrs-bukrs.
        COLLECT l_s_bukrs INTO  l_t_bukrs.
      ENDIF.
    ENDIF.
  ENDLOOP.

* send the info for each missing autority
  IF g_flag_mess_333 = 'X'.
    SORT l_t_bukrs.
    SET CURSOR FIELD  'SO_WERKS-LOW'.
    LOOP AT l_t_bukrs INTO l_s_bukrs.
* No authorization to display data for company code &
      MESSAGE i862(m3) WITH  l_s_bukrs-bukrs.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_CHECK_AUTHORIZATION

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  TYPES : BEGIN OF ty_001,
            reqno(12),
          END OF ty_001.

  DATA : ls_zgdmmt0001  TYPE zgdmmt0001.
  DATA : lt_zgdmmt0001 TYPE STANDARD TABLE OF zgdmmt0001,
         lt_001        TYPE STANDARD TABLE OF ty_001,
         ls_001        LIKE LINE OF lt_001,
         lt_reqno      TYPE TABLE OF string,
         lv_up1(6),
         lv_up2(4).

  SELECT SINGLE flag
    FROM zproject
    INTO gv_apo
    WHERE name = 'ZMM_ABS'.

  SELECT *
    FROM zgdmmt0002
    INTO CORRESPONDING FIELDS OF TABLE gt_zgdmmt0002.

  CASE 'X'.
    WHEN pa_abs.
*	Material dari MARA utk data mat type & mat group
      PERFORM f_get_material.

      IF gt_mara[] IS NOT INITIAL.
*	Current Blocked Stock dari MCHB
        PERFORM f_current_blocked_stock.
      ENDIF.

* Get Movement IN & Movement OUT
      PERFORM f_add_bwart USING '' : '344', '350', '325', '343', '349', '326',
                                     'Z51', 'Z52', '555', '556', '565', '566',
                                     '983', '984', '122', '123', '707', '708',
                                     '913', '914', '161', '162', '959', '960',
                                     '930', '931', '717', '718', 'Z17', 'Z18'.

*      PERFORM f_add_bwart USING 'IN' : '344', '350', '325', 'Z52', '556'.
*      PERFORM f_add_bwart USING 'OUT' : '343', '349', '326', 'Z51', '555'.

      PERFORM f_get_movement.

* Material Description
      PERFORM f_get_material_description.

* Expiry Date
      PERFORM f_expired_date.

* Current Value
      PERFORM f_current_value.

    WHEN pa_crp.
      IF pa_delrq IS NOT INITIAL.
        SELECT *
          FROM zgdmmt0001
          INTO CORRESPONDING FIELDS OF TABLE gt_zgdmmt0001
          WHERE req_no   IN so_reqno
            AND req_date IN so_reqdt.
      ELSE.
        SELECT *
          FROM zgdmmt0001
          INTO CORRESPONDING FIELDS OF TABLE gt_zgdmmt0001
          WHERE req_no   IN so_reqno
            AND req_date IN so_reqdt
            AND del      = pa_delrq.
      ENDIF.

      IF gt_zgdmmt0001[] IS NOT INITIAL.
        SELECT mblnr mjahr zeile matnr charg menge meins
          FROM mseg
          INTO CORRESPONDING FIELDS OF TABLE gt_mseg
          FOR ALL ENTRIES IN gt_zgdmmt0001
          WHERE mblnr = gt_zgdmmt0001-mblnr
            AND mjahr = gt_zgdmmt0001-mjahr
            AND zeile = gt_zgdmmt0001-zeile.

        SELECT mblnr mjahr xblnr budat
          FROM mkpf
          INTO CORRESPONDING FIELDS OF TABLE gt_mkpf
          FOR ALL ENTRIES IN gt_zgdmmt0001
          WHERE mblnr = gt_zgdmmt0001-mblnr
            AND mjahr = gt_zgdmmt0001-mjahr.

* Material Description
        PERFORM f_get_material_description.
* Current Value
        PERFORM f_current_value.
      ENDIF.

    WHEN pa_prp.
      gv_reqno  = pa_reqno.

      IF pa_reprt IS INITIAL.
        SELECT *
          FROM zgdmmt0001
          INTO CORRESPONDING FIELDS OF TABLE gt_zgdmmt0001
          WHERE req_no   = pa_reqno
            AND status   = space
            AND del      = space.
      ELSE.
        SELECT *
         FROM zgdmmt0001
         INTO CORRESPONDING FIELDS OF TABLE gt_zgdmmt0001
         WHERE req_no   = pa_reqno
           AND del      = space.
      ENDIF.

      IF gt_zgdmmt0001[] IS NOT INITIAL.
        SELECT mblnr mjahr zeile matnr charg menge meins
          FROM mseg
          INTO CORRESPONDING FIELDS OF TABLE gt_mseg
          FOR ALL ENTRIES IN gt_zgdmmt0001
          WHERE mblnr = gt_zgdmmt0001-mblnr
            AND mjahr = gt_zgdmmt0001-mjahr
            AND zeile = gt_zgdmmt0001-zeile.

        SELECT mblnr mjahr bktxt xblnr
          FROM mkpf
          INTO CORRESPONDING FIELDS OF TABLE gt_mkpf
          FOR ALL ENTRIES IN gt_zgdmmt0001
          WHERE mblnr = gt_zgdmmt0001-mblnr
            AND mjahr = gt_zgdmmt0001-mjahr.

* Material Description
        PERFORM f_get_material_description.

* Expiry Date
        PERFORM f_expired_date.
      ENDIF.

    WHEN pa_apr.
      SELECT *
        FROM zgdmmt0001
        INTO CORRESPONDING FIELDS OF TABLE gt_zgdmmt0001
        WHERE req_no    IN so_reqno
          AND req_date  IN so_reqdt
          AND status    = space
          AND scrap_no  = space
          AND del       = space
          AND bbk_no    = space.

    WHEN pa_bbk OR pa_bbk2.
      CASE 'X'.
        WHEN pa_bbk.
          SELECT *
            FROM zgdmmt0001
            INTO CORRESPONDING FIELDS OF TABLE gt_zgdmmt0001
            WHERE req_no    IN so_reqno
              AND req_date  IN so_reqdt
              AND status    = space
              AND scrap_no  = space
              AND del       = space
              AND relstatus = 'X'.
        WHEN pa_bbk2.
          SELECT *
            FROM zgdmmt0001
            INTO CORRESPONDING FIELDS OF TABLE gt_zgdmmt0001
            WHERE req_no    IN so_reqno
              AND req_date  IN so_reqdt
*              AND status    NE space
*              AND scrap_no  NE space
              AND del       = space
              AND relstatus = 'X'.
      ENDCASE.

      IF gt_zgdmmt0001[] IS NOT INITIAL.
        lt_zgdmmt0001[] = gt_zgdmmt0001[].
        SORT lt_zgdmmt0001 BY werks req_no.
        DELETE ADJACENT DUPLICATES FROM lt_zgdmmt0001 COMPARING werks req_no.
        CLEAR ls_zgdmmt0001.
        LOOP AT lt_zgdmmt0001 INTO ls_zgdmmt0001.
          SPLIT ls_zgdmmt0001-req_no AT '/' INTO TABLE lt_reqno.
          READ TABLE lt_reqno INTO lv_up1 INDEX 1.
          READ TABLE lt_reqno INTO lv_up2 INDEX 5.
          CONCATENATE lv_up1 '/' lv_up2
          INTO ls_001-reqno.
          APPEND ls_001 TO lt_001.
          CLEAR ls_001.
        ENDLOOP.

        SELECT *
          FROM ztspmmdt002
          INTO CORRESPONDING FIELDS OF TABLE gt_002
          FOR ALL ENTRIES IN gt_zgdmmt0001
          WHERE matnr    = gt_zgdmmt0001-matnr
            AND trandtrc = 'X'.

        IF lt_001[] IS NOT INITIAL AND gt_002[] IS NOT INITIAL.
          SELECT *
            FROM zaccdtd JOIN zaccdtm ON zaccdtd~senum = zaccdtm~senum
            INTO CORRESPONDING FIELDS OF TABLE gt_zaccu
            FOR ALL ENTRIES IN lt_001
            WHERE docat = 'DO'
              AND docno = lt_001-reqno
              AND xloek = space.
        ENDIF.

        SELECT mblnr mjahr zeile matnr charg menge meins
          FROM mseg
          INTO CORRESPONDING FIELDS OF TABLE gt_mseg
          FOR ALL ENTRIES IN gt_zgdmmt0001
          WHERE mblnr = gt_zgdmmt0001-mblnr AND
                mjahr = gt_zgdmmt0001-mjahr AND
                zeile = gt_zgdmmt0001-zeile.

* Material Description
        PERFORM f_get_material_description.
      ENDIF.

    WHEN pa_cp.
      SELECT *
        FROM zgdmmt0001
        INTO CORRESPONDING FIELDS OF TABLE gt_zgdmmt0001
        WHERE bbk_no   IN so_bbkno
          AND bbk_date IN so_bbkdt
          AND status   = space
          AND scrap_no = space
          AND del      = space.

      IF gt_zgdmmt0001[] IS NOT INITIAL.
        SELECT mblnr mjahr zeile matnr charg menge meins
          FROM mseg
          INTO CORRESPONDING FIELDS OF TABLE gt_mseg
          FOR ALL ENTRIES IN gt_zgdmmt0001
          WHERE mblnr = gt_zgdmmt0001-mblnr AND
                mjahr = gt_zgdmmt0001-mjahr AND
                zeile = gt_zgdmmt0001-zeile.

* Material Description
        PERFORM f_get_material_description.
      ENDIF.

    WHEN pa_pbap.
      SELECT *
        FROM zgdmmt0001
        INTO CORRESPONDING FIELDS OF TABLE gt_zgdmmt0001
        WHERE bap_no   = pa_bapno
          AND status   = 'SETTLE'.

      IF gt_zgdmmt0001[] IS NOT INITIAL.
        SELECT mblnr mjahr xblnr
          FROM mkpf
          INTO CORRESPONDING FIELDS OF TABLE gt_mkpf
          FOR ALL ENTRIES IN gt_zgdmmt0001
          WHERE mblnr = gt_zgdmmt0001-scrap_no AND
                mjahr = gt_zgdmmt0001-scrap_year.

        SELECT mblnr mjahr zeile matnr charg menge meins
          FROM mseg
          INTO CORRESPONDING FIELDS OF TABLE gt_mseg
          FOR ALL ENTRIES IN gt_zgdmmt0001
          WHERE mblnr = gt_zgdmmt0001-mblnr AND
                mjahr = gt_zgdmmt0001-mjahr AND
                zeile = gt_zgdmmt0001-zeile.

* Material Description
        PERFORM f_get_material_description.
      ENDIF.

    WHEN pa_mc.
      SELECT *
        FROM zgdmmt0001
        INTO CORRESPONDING FIELDS OF TABLE gt_zgdmmt0001
        WHERE werks    = gc_2100
          AND cla_no   = pa_clano
          AND cla_date = pa_cladt
          AND cla_sts = space.

      IF gt_zgdmmt0001[] IS NOT INITIAL.
        SELECT mblnr mjahr zeile matnr charg menge meins
          FROM mseg
          INTO CORRESPONDING FIELDS OF TABLE gt_mseg
          FOR ALL ENTRIES IN gt_zgdmmt0001
          WHERE mblnr = gt_zgdmmt0001-mblnr AND
                mjahr = gt_zgdmmt0001-mjahr AND
                zeile = gt_zgdmmt0001-zeile.

        SELECT mblnr mjahr xblnr budat
          FROM mkpf
          INTO CORRESPONDING FIELDS OF TABLE gt_mkpf
          FOR ALL ENTRIES IN gt_zgdmmt0001
          WHERE mblnr = gt_zgdmmt0001-mblnr
            AND mjahr = gt_zgdmmt0001-mjahr.

* Material Description
        PERFORM f_get_material_description.
      ENDIF.

  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_ADD_BWART
*&---------------------------------------------------------------------*
FORM f_add_bwart  USING    fu_flag fu_bwart.

  DATA : lr_bwart TYPE RANGE OF bwart,
         ls_bwart LIKE LINE OF lr_bwart.

  ls_bwart-low    = fu_bwart.
  ls_bwart-sign   = 'I'.
  ls_bwart-option = 'EQ'.

  CASE fu_flag.
    WHEN 'IN'.
      APPEND ls_bwart TO gr_movein.
    WHEN 'OUT'.
      APPEND ls_bwart TO gr_moveout.
    WHEN OTHERS.
      APPEND ls_bwart TO gr_bwart.
  ENDCASE.
ENDFORM.                    " F_ADD_BWART

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL
*&---------------------------------------------------------------------*
FORM f_get_material .
  SELECT matnr meins mtart bismt lvorm
    FROM mara
    INTO CORRESPONDING FIELDS OF TABLE gt_mara
    WHERE matnr IN so_matnr
      AND mtart IN so_mtart
      AND matkl IN so_matkl.
ENDFORM.                    " F_GET_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_CURRENT_BLOCKED_STOCK
*&---------------------------------------------------------------------*
FORM f_current_blocked_stock .
  SELECT matnr werks lgort charg cspem
     INTO CORRESPONDING FIELDS OF TABLE gt_mchb
     FROM mchb
     FOR ALL ENTRIES IN gt_mara
     WHERE matnr = gt_mara-matnr
       AND werks IN so_werks
       AND lgort IN so_lgort
       AND charg IN so_charg
       AND lvorm = space
       AND cspem <> 0.
ENDFORM.                    " F_CURRENT_BLOCKED_STOCK

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_DESCRIPTION
*&---------------------------------------------------------------------*
FORM f_get_material_description .
  DATA : lt_mchb TYPE STANDARD TABLE OF mchb,
         lt_mseg TYPE STANDARD TABLE OF mseg.

  CASE 'X'.
    WHEN pa_abs.
      lt_mchb[] = gt_mchb[].
      SORT lt_mchb BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_mchb COMPARING matnr.
      IF lt_mchb[] IS NOT INITIAL.
        SELECT matnr maktx
          FROM makt
          INTO CORRESPONDING FIELDS OF TABLE gt_makt
          FOR ALL ENTRIES IN lt_mchb
          WHERE matnr = lt_mchb-matnr
            AND spras = sy-langu.

        SELECT * INTO TABLE gt_mean
          FROM mean FOR ALL ENTRIES IN lt_mchb
          WHERE matnr EQ lt_mchb-matnr
            AND eantp EQ 'Z2'.
      ENDIF.

    WHEN pa_crp OR pa_prp OR pa_pbap OR pa_bbk OR pa_mc OR pa_bbk2.
      lt_mseg[] = gt_mseg[].
      SORT lt_mseg BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_mseg COMPARING matnr.
      IF lt_mseg[] IS NOT INITIAL.
        SELECT matnr maktx
          FROM makt
          INTO CORRESPONDING FIELDS OF TABLE gt_makt
          FOR ALL ENTRIES IN lt_mseg
          WHERE matnr = lt_mseg-matnr
            AND spras = sy-langu.

        SELECT * INTO TABLE gt_mean
          FROM mean FOR ALL ENTRIES IN lt_mseg
          WHERE matnr EQ lt_mseg-matnr
            AND eantp EQ 'Z2'.
      ENDIF.
  ENDCASE.

  IF pa_mc IS NOT INITIAL.
    SELECT matnr meins mtart bismt
    FROM mara
    INTO CORRESPONDING FIELDS OF TABLE gt_mara
    FOR ALL ENTRIES IN lt_mseg
    WHERE matnr = lt_mseg-matnr
      AND mtart IN so_mtart
      AND matkl IN so_matkl.

    IF sy-subrc = 0.
      SELECT * INTO TABLE gt_mean
        FROM mean FOR ALL ENTRIES IN gt_mara
        WHERE matnr EQ gt_mara-matnr
          AND eantp EQ 'Z2'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_MATERIAL_DESCRIPTION

*&---------------------------------------------------------------------*
*&      Form  F_GET_MOVEMENT
*&---------------------------------------------------------------------*
FORM f_get_movement .
  DATA : lt_move TYPE STANDARD TABLE OF ty_move,
         ls_move TYPE ty_move,
         lt_cek  TYPE STANDARD TABLE OF ty_move,
         ls_cek  TYPE ty_move.

  IF gt_mchb[] IS NOT INITIAL.
    SELECT mseg~mblnr mseg~mjahr mseg~zeile mseg~line_id mseg~parent_id
           mseg~bwart mseg~matnr mseg~werks mseg~lgort mseg~charg mseg~insmk
           mseg~shkzg mseg~menge mseg~meins mseg~smbln mseg~smblp mkpf~budat
           mkpf~bktxt mkpf~xblnr mkpf~cpudt mkpf~cputm
      INTO CORRESPONDING FIELDS OF TABLE lt_move
      FROM mseg JOIN mkpf ON mseg~mblnr = mkpf~mblnr AND
                             mseg~mjahr = mkpf~mjahr
      FOR ALL ENTRIES IN gt_mchb
      WHERE mseg~matnr = gt_mchb-matnr
        AND mseg~werks = gt_mchb-werks
        AND mseg~lgort = gt_mchb-lgort
        AND mseg~charg = gt_mchb-charg
        AND mseg~bwart IN gr_bwart.

    SORT lt_move BY lgort matnr charg mblnr zeile.

    lt_cek[] = lt_move[].

    LOOP AT lt_move INTO ls_move.
* Movement IN
      IF ls_move-shkzg = 'S'.
        IF ls_move-parent_id IS NOT INITIAL.
          READ TABLE lt_cek INTO ls_cek
                            WITH KEY mblnr   = ls_move-mblnr
                                     line_id = ls_move-parent_id
                                     lgort   = ls_move-lgort
                                     charg   = ls_move-charg
                            TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            IF ls_move-bwart = '325' OR ls_move-bwart = '326'.
              DELETE gt_moveout WHERE mblnr   = ls_move-mblnr
                                  AND line_id = ls_move-parent_id
                                  AND lgort   = ls_move-lgort.
              CONTINUE.
            ELSE.
              CONTINUE.
            ENDIF.
          ELSE.
            IF ls_move-bwart = '343'.
              CONTINUE.
            ELSE.
              APPEND ls_move TO gt_movein.
            ENDIF.
          ENDIF.
        ELSE.
          IF ls_move-bwart = 'Z52' OR
            ls_move-bwart = '123'.
            IF ls_move-insmk = '3' OR ls_move-insmk = 'S'.
              APPEND ls_move TO gt_movein.
            ENDIF.
          ELSEIF ls_move-bwart = '930'.
            IF ls_move-insmk NE 'X' AND ls_move-insmk NE '2'.
              APPEND ls_move TO gt_movein.
            ENDIF.
          ELSE.
            APPEND ls_move TO gt_movein.
          ENDIF.
        ENDIF.
      ELSEIF ls_move-shkzg = 'H'.
        IF ls_move-parent_id IS NOT INITIAL.
          READ TABLE lt_cek INTO ls_cek
                            WITH KEY mblnr   = ls_move-mblnr
                                     line_id = ls_move-parent_id
                                     lgort   = ls_move-lgort
                                     charg   = ls_move-charg
                            TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            IF ls_move-bwart = '325' OR ls_move-bwart = '326'.
              DELETE gt_movein WHERE mblnr   = ls_move-mblnr
                                 AND line_id = ls_move-parent_id
                                 AND lgort   = ls_move-lgort.
              CONTINUE.
            ELSE.
              CONTINUE.
            ENDIF.
          ELSE.
            IF ls_move-bwart = '344'.
              CONTINUE.
            ELSE.
              APPEND ls_move TO gt_moveout.
            ENDIF.
          ENDIF.
        ELSE.
          IF ls_move-bwart = 'Z51' OR
            ls_move-bwart = '122'.
            IF ls_move-insmk = '3' OR ls_move-insmk = 'S'.
              APPEND ls_move TO gt_moveout.
            ENDIF.
          ELSEIF ls_move-bwart = '931'.
            IF ls_move-insmk NE 'X' AND ls_move-insmk NE '2'.
              APPEND ls_move TO gt_moveout.
            ENDIF.
          ELSE.
            APPEND ls_move TO gt_moveout.
          ENDIF.
        ENDIF.
      ENDIF.
* Movement OUT
    ENDLOOP.
  ENDIF.

  IF gt_movein[] IS NOT INITIAL.
    SELECT *
      FROM zgdmmt0001
      INTO CORRESPONDING FIELDS OF TABLE gt_001i
      FOR ALL ENTRIES IN gt_movein
      WHERE mblnr = gt_movein-mblnr
        AND zeile = gt_movein-zeile.
  ENDIF.

  IF gt_moveout[] IS NOT INITIAL.
    SELECT *
      FROM zgdmmt0001
      INTO CORRESPONDING FIELDS OF TABLE gt_001o
      FOR ALL ENTRIES IN gt_moveout
      WHERE scrap_no    = gt_moveout-mblnr
        AND scrap_year  = gt_moveout-mjahr.
  ENDIF.
ENDFORM.                    " F_GET_MOVEMENT

*&---------------------------------------------------------------------*
*&      Form  F_EXPIRED_DATE
*&---------------------------------------------------------------------*
FORM f_expired_date .
  DATA : lt_mchb TYPE STANDARD TABLE OF mchb,
         lt_mch1 TYPE TABLE OF mch1 WITH HEADER LINE,
         lt_mseg TYPE STANDARD TABLE OF mseg.

  CASE 'X'.
    WHEN pa_abs.
      lt_mchb[] = gt_mchb[].
      SORT lt_mchb BY matnr charg.
      DELETE ADJACENT DUPLICATES FROM lt_mchb COMPARING matnr charg.

      IF lt_mchb[] IS NOT INITIAL.
        SELECT matnr charg vfdat lifnr
          FROM mch1
          INTO CORRESPONDING FIELDS OF TABLE gt_mch1
          FOR ALL ENTRIES IN lt_mchb
          WHERE matnr = lt_mchb-matnr
            AND charg = lt_mchb-charg
            AND lvorm = space.

        IF sy-subrc = 0.
          lt_mch1[] = gt_mch1[].
          SORT lt_mch1 BY lifnr.
          DELETE ADJACENT DUPLICATES FROM lt_mch1 COMPARING lifnr.
          SELECT lifnr name1
            INTO CORRESPONDING FIELDS OF TABLE gt_lfa1
            FROM lfa1 FOR ALL ENTRIES IN lt_mch1
            WHERE lifnr = lt_mch1-lifnr.
        ENDIF.
      ENDIF.

    WHEN pa_prp.
      lt_mseg[] = gt_mseg[].
      SORT lt_mseg BY matnr charg.
      DELETE ADJACENT DUPLICATES FROM lt_mseg COMPARING matnr charg.

      IF lt_mseg[] IS NOT INITIAL.
        SELECT matnr charg vfdat hsdat
          FROM mch1
          INTO CORRESPONDING FIELDS OF TABLE gt_mch1
          FOR ALL ENTRIES IN lt_mseg
          WHERE matnr = lt_mseg-matnr
            AND charg = lt_mseg-charg
            AND lvorm = space.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_EXPIRED_DATE

*&---------------------------------------------------------------------*
*&      Form  F_CURRENT_VALUE
*&---------------------------------------------------------------------*
FORM f_current_value .
  DATA : lt_mchb  TYPE STANDARD TABLE OF mchb.

  lt_mchb[] = gt_mchb[].
  SORT lt_mchb BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM lt_mchb COMPARING matnr werks.

  IF lt_mchb[] IS NOT INITIAL.
    SELECT matnr bwkey bwtar vprsv verpr stprs peinh
    FROM mbew
    INTO CORRESPONDING FIELDS OF TABLE gt_mbew
    FOR ALL ENTRIES IN lt_mchb
    WHERE matnr = lt_mchb-matnr
      AND bwkey = lt_mchb-werks.
  ENDIF.
ENDFORM.                    " F_CURRENT_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_REQUEST
*&---------------------------------------------------------------------*
FORM f_request .
  CASE pa_bukrs.
    WHEN '8210'.
      SELECT *
        FROM zgdmmt0001
        INTO CORRESPONDING FIELDS OF TABLE gt_zgdmmt0001.
*        WHERE cla_sts = space.

    WHEN OTHERS.
      SELECT *
        FROM zgdmmt0001
        INTO CORRESPONDING FIELDS OF TABLE gt_zgdmmt0001
        WHERE status = space.
  ENDCASE.

ENDFORM.                    " F_REQUEST

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  CASE 'X'.
    WHEN pa_abs.
      PERFORM f_filter_data_in_out.
      PERFORM f_collect_display_data.

    WHEN pa_crp.
      PERFORM f_collect_display_data.

    WHEN pa_prp.
      PERFORM f_collect_display_data.

    WHEN pa_apr.
      PERFORM f_collect_display_data.

    WHEN pa_bbk OR pa_bbk2.
      PERFORM f_collect_display_data.

    WHEN pa_cp.
      PERFORM f_collect_display_data.

    WHEN pa_pbap.
      PERFORM f_collect_display_data.

    WHEN pa_mc.
      PERFORM f_collect_display_data.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FILTER_DATA_IN_OUT
*&---------------------------------------------------------------------*
FORM f_filter_data_in_out .
  DATA : ls_movein  TYPE ty_move,
         ls_moveout TYPE ty_move,
         ls_001o    LIKE LINE OF gt_001o,
         ls_001i    LIKE LINE OF gt_001i,
         lv_menge   TYPE mseg-menge,
         lv_tabix   TYPE sy-tabix.

  SORT gt_movein BY werks lgort matnr charg mblnr zeile.
  SORT gt_001o BY werks lgort mblnr zeile.
  SORT gt_moveout BY werks lgort matnr charg smbln smblp.

  LOOP AT gt_movein INTO ls_movein.
    CLEAR : ls_moveout.
    READ TABLE gt_moveout INTO ls_moveout
                          WITH KEY smbln = ls_movein-mblnr
                                   smblp = ls_movein-zeile.
*                          BINARY SEARCH.
    IF sy-subrc = 0.
      DELETE TABLE gt_moveout FROM ls_moveout.
      DELETE TABLE gt_movein FROM ls_movein.
    ENDIF.
    CLEAR : ls_movein.
  ENDLOOP.

  SORT gt_moveout BY werks lgort matnr charg mblnr zeile.
  SORT gt_movein BY werks lgort matnr charg smbln smblp.
  LOOP AT gt_moveout INTO ls_moveout.
    CLEAR : ls_movein.
    READ TABLE gt_movein INTO ls_movein
                          WITH KEY smbln = ls_moveout-mblnr
                                   smblp = ls_moveout-zeile.
*                          BINARY SEARCH.
    IF sy-subrc = 0.
      DELETE TABLE gt_moveout FROM ls_moveout.
      DELETE TABLE gt_movein FROM ls_movein.
    ENDIF.
    CLEAR : ls_moveout.
  ENDLOOP.

  SORT gt_movein BY werks lgort matnr charg mblnr zeile.
  SORT gt_moveout BY werks lgort matnr charg mblnr zeile.
  LOOP AT gt_movein INTO ls_movein.
    CLEAR : ls_001o.
    READ TABLE gt_001o INTO ls_001o
                       WITH KEY mblnr = ls_movein-mblnr
                                zeile = ls_movein-zeile.
*                         BINARY SEARCH.
    IF sy-subrc = 0.
      CLEAR : ls_moveout.
      READ TABLE gt_moveout INTO ls_moveout
                            WITH KEY mblnr = ls_001o-scrap_no
                                     mjahr = ls_001o-scrap_year
                                     matnr = ls_movein-matnr
                                     charg = ls_movein-charg
                                     menge = ls_movein-menge.
      IF sy-subrc = 0.
*        IF ls_movein-menge = ls_moveout-menge.
        DELETE TABLE gt_moveout FROM ls_moveout.
        DELETE TABLE gt_movein FROM ls_movein.
*        ENDIF.
      ENDIF.
    ELSE.
      CLEAR : ls_001i.
      READ TABLE gt_001i INTO ls_001i
                         WITH KEY mblnr = ls_movein-mblnr
                                  zeile = ls_movein-zeile.
      IF sy-subrc = 0.
        ls_movein-flag  = 'X'.
        MODIFY gt_movein FROM ls_movein TRANSPORTING flag.
      ENDIF.
    ENDIF.
    CLEAR : ls_movein.
  ENDLOOP.

  IF gt_moveout[] IS NOT INITIAL.
    SORT gt_movein BY werks lgort matnr charg flag cpudt cputm mblnr zeile.
    SORT gt_moveout BY werks lgort matnr charg cpudt cputm mblnr zeile.

    LOOP AT gt_moveout INTO ls_moveout.
      lv_menge = ls_moveout-menge.
      LOOP AT gt_movein INTO ls_movein WHERE matnr = ls_moveout-matnr
                                         AND werks = ls_moveout-werks
                                         AND lgort = ls_moveout-lgort
                                         AND charg = ls_moveout-charg.
*        IF ls_movein-budat > ls_moveout-budat.
*          CONTINUE.
*        ELSEIF ls_movein-budat = ls_moveout-budat.
        IF ls_movein-cpudt > ls_moveout-cpudt.
          CONTINUE.
        ELSEIF ls_movein-cpudt = ls_moveout-cpudt.
          IF ls_movein-cputm > ls_moveout-cputm.
            CONTINUE.
          ENDIF.
        ENDIF.
*        ENDIF.
        lv_tabix  = sy-tabix.
        lv_menge = ls_movein-menge - lv_menge.
        IF lv_menge = 0.
          DELETE TABLE gt_movein FROM ls_movein.
          EXIT.
        ELSEIF lv_menge > 0.
          ls_movein-menge = lv_menge.
          MODIFY gt_movein FROM ls_movein INDEX lv_tabix TRANSPORTING menge.
          EXIT.
        ELSE.
          lv_menge = abs( lv_menge ).
          DELETE TABLE gt_movein FROM ls_movein.
          CONTINUE.
        ENDIF.
        CLEAR lv_tabix.
      ENDLOOP.

*      READ TABLE gt_movein INTO ls_movein
*                           WITH KEY matnr = ls_moveout-matnr
*                                    werks = ls_moveout-werks
*                                    lgort = ls_moveout-lgort
*                                    charg = ls_moveout-charg
*                                    menge = ls_moveout-menge
*                           BINARY SEARCH.
*      IF sy-subrc = 0.
*        DELETE TABLE gt_moveout FROM ls_moveout.
*        DELETE TABLE gt_movein FROM ls_movein.
*      ENDIF.
      CLEAR : ls_movein, ls_moveout.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_FILTER_DATA_IN_OUT

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM f_collect_display_data .
  DATA : ls_movein     TYPE ty_move,
         ls_moveout    TYPE ty_move,
         ls_makt       TYPE makt,
         ls_mara       TYPE mara,
         ls_mbew       TYPE mbew,
         ls_mch1       TYPE mch1,
         ls_mkpf       TYPE mkpf,
         lt_zgdmmt0001 TYPE STANDARD TABLE OF zgdmmt0001 INITIAL SIZE 0,
         ls_zgdmmt0001 TYPE zgdmmt0001,
         ls_zgdmmt0002 TYPE zgdmmt0002,
         ls_out        TYPE zgdmmst001,
         ls_mseg       TYPE mseg,
         lv_nou        LIKE zgdmmst001-nou,
         lv_menge      LIKE zgdmmst001-menge,
         lv_menget(20),
         lv_map        TYPE dec11_4,
         lv_count      TYPE int4.

  DATA : lt_out         TYPE STANDARD TABLE OF zgdmmst001.

  CASE 'X'.
    WHEN pa_abs.
* Request
      IF gt_movein[] IS NOT INITIAL.
        PERFORM f_request.
      ENDIF.

      LOOP AT gt_movein INTO ls_movein.
        ls_out-matnr = ls_movein-matnr.
        CLEAR ls_makt.
        READ TABLE gt_makt INTO ls_makt
                           WITH KEY matnr = ls_movein-matnr.
        IF sy-subrc = 0.
          ls_out-maktx = ls_makt-maktx.
        ENDIF.
        CLEAR ls_mara.
        READ TABLE gt_mara INTO ls_mara
                           WITH KEY matnr = ls_movein-matnr.
        IF sy-subrc = 0.
          ls_out-bismt = ls_mara-bismt.
        ENDIF.
        CLEAR gt_mean.
        READ TABLE gt_mean WITH KEY matnr = ls_movein-matnr.
        ls_out-ean11 = gt_mean-ean11.
        ls_out-werks = ls_movein-werks.
        ls_out-lgort = ls_movein-lgort.
        ls_out-charg = ls_movein-charg.
        PERFORM f_uom_conversion USING ls_movein-meins
                                 CHANGING ls_out-meins.

        CLEAR ls_mbew.
        READ TABLE gt_mbew INTO ls_mbew
                           WITH KEY matnr = ls_movein-matnr
                                    bwkey = ls_movein-werks.
        IF sy-subrc = 0.
*          IF ls_mbew-vprsv = 'S'.
*            ls_out-menge  = ls_movein-menge.
*            ls_out-value  = ls_out-menge * ( ls_mbew-stprs / ls_mbew-peinh ).
*          ELSE.
          ls_out-menge  = ls_movein-menge.
          IF ls_mbew-verpr IS NOT INITIAL.
            ls_out-value  = ls_out-menge * ( ls_mbew-verpr / ls_mbew-peinh ).
          ELSE.
            ls_out-value  = ls_out-menge * ( ls_mbew-stprs / ls_mbew-peinh ).
          ENDIF.
*          ENDIF.
        ENDIF.

        IF pa_dondv IS NOT INITIAL.
          CLEAR ls_out-value.
        ENDIF.

        CLEAR ls_mch1.
        READ TABLE gt_mch1 INTO ls_mch1
                           WITH KEY matnr = ls_movein-matnr
                                    charg = ls_movein-charg.
        IF sy-subrc = 0.
          ls_out-vfdat = ls_mch1-vfdat.
          ls_out-vndno = ls_mch1-lifnr.

          CLEAR gt_lfa1.
          READ TABLE gt_lfa1 WITH KEY lifnr = ls_out-vndno.
          ls_out-vndnm = gt_lfa1-name1.
        ENDIF.

        ls_out-budat = ls_movein-budat.

        ls_out-aging = sy-datum - ls_out-budat.
        IF ls_out-aging <= pa_col01.
          IF pa_dondv IS INITIAL AND
            pa_agqty IS INITIAL.
            PERFORM f_conversi_value USING ls_out-matnr ls_out-value 'IDR' ''
                                     CHANGING ls_out-acol1t ls_out-acol1_waers
                                              ls_out-acol1_meins.
          ELSE.
            PERFORM f_conversi_value USING ls_out-matnr ls_out-menge ''
                                           ls_out-meins
                                     CHANGING ls_out-acol1t ls_out-acol1_waers
                                              ls_out-acol1_meins.
          ENDIF.
        ELSEIF ( ls_out-aging > pa_col01 AND ls_out-aging <= pa_col02 ).
          IF pa_dondv IS INITIAL AND
            pa_agqty IS INITIAL.
            PERFORM f_conversi_value USING ls_out-matnr ls_out-value 'IDR' ''
                                     CHANGING ls_out-acol2t ls_out-acol2_waers
                                              ls_out-acol2_meins.
          ELSE.
            PERFORM f_conversi_value USING ls_out-matnr ls_out-menge ''
                                           ls_out-meins
                                     CHANGING ls_out-acol2t ls_out-acol2_waers
                                              ls_out-acol2_meins.
          ENDIF.
        ELSEIF ( ls_out-aging > pa_col02 AND ls_out-aging <= pa_col03 ).
          IF pa_dondv IS INITIAL AND
            pa_agqty IS INITIAL.
            PERFORM f_conversi_value USING ls_out-matnr ls_out-value 'IDR' ''
                                     CHANGING ls_out-acol3t ls_out-acol3_waers
                                              ls_out-acol3_meins.
          ELSE.
            PERFORM f_conversi_value USING ls_out-matnr ls_out-menge ''
                                           ls_out-meins
                                     CHANGING ls_out-acol3t ls_out-acol3_waers
                                              ls_out-acol3_meins.
          ENDIF.
        ELSEIF ( ls_out-aging > pa_col03 AND ls_out-aging <= pa_col04 ).
          IF pa_dondv IS INITIAL AND
            pa_agqty IS INITIAL.
            PERFORM f_conversi_value USING ls_out-matnr ls_out-value 'IDR' ''
                                     CHANGING ls_out-acol4t ls_out-acol4_waers
                                              ls_out-acol4_meins.
          ELSE.
            PERFORM f_conversi_value USING ls_out-matnr ls_out-menge ''
                                           ls_out-meins
                                     CHANGING ls_out-acol4t ls_out-acol4_waers
                                              ls_out-acol4_meins.
          ENDIF.
        ELSE.
          IF pa_dondv IS INITIAL AND
            pa_agqty IS INITIAL.
            PERFORM f_conversi_value USING ls_out-matnr ls_out-value 'IDR' ''
                                     CHANGING ls_out-acol5t ls_out-acol5_waers
                                              ls_out-acol5_meins.
          ELSE.
            PERFORM f_conversi_value USING ls_out-matnr ls_out-menge ''
                                           ls_out-meins
                                     CHANGING ls_out-acol5t ls_out-acol5_waers
                                              ls_out-acol5_meins.
          ENDIF.
        ENDIF.

        CLEAR ls_zgdmmt0001.
        READ TABLE gt_zgdmmt0001 INTO ls_zgdmmt0001
                                 WITH KEY mblnr = ls_movein-mblnr
                                          mjahr = ls_movein-mjahr
                                          zeile = ls_movein-zeile
                                          status = space.
        IF sy-subrc = 0.
          ls_out-req_no   = ls_zgdmmt0001-req_no.
          ls_out-req_date = ls_zgdmmt0001-req_date.
          ls_out-cla_no   = ls_zgdmmt0001-cla_no.
          ls_out-cla_date = ls_zgdmmt0001-cla_date.
          ls_out-cla_sts = ls_zgdmmt0001-cla_sts.
        ELSE.
          CLEAR : ls_out-req_no, ls_out-req_date, ls_out-cla_no, ls_out-cla_date, ls_out-cla_sts.
        ENDIF.

        ls_out-mblnr = ls_movein-mblnr.
        ls_out-mjahr = ls_movein-mjahr.
        ls_out-zeile = ls_movein-zeile.

        IF pa_wtreq IS NOT INITIAL.
          APPEND ls_out TO gt_out.
          CLEAR ls_out.
        ELSE.
          CASE pa_bukrs.
            WHEN '8210'.
              IF ls_out-cla_no IS INITIAL.
                APPEND ls_out TO gt_out.
                CLEAR ls_out.
              ENDIF.
*            WHEN '8220'.
            WHEN OTHERS.
              IF ls_out-req_no IS INITIAL.
                APPEND ls_out TO gt_out.
                CLEAR ls_out.
              ENDIF.
          ENDCASE.
        ENDIF.
      ENDLOOP.

    WHEN pa_crp.
      SORT gt_zgdmmt0001 BY mblnr mjahr zeile.
      SORT gt_mseg BY mblnr mjahr zeile.
      SORT gt_mkpf BY mblnr mjahr.

      LOOP AT gt_zgdmmt0001 INTO ls_zgdmmt0001.
        ls_out-scrap_no    = ls_zgdmmt0001-scrap_no.
        ls_out-req_no      = ls_zgdmmt0001-req_no.
        ls_out-req_date    = ls_zgdmmt0001-req_date.
        ls_out-bbk_no      = ls_zgdmmt0001-bbk_no.
        ls_out-bbk_date    = ls_zgdmmt0001-bbk_date.
        ls_out-bap_no      = ls_zgdmmt0001-bap_no.
        ls_out-bap_date    = ls_zgdmmt0001-bap_date.
        ls_out-requester   = ls_zgdmmt0001-requester.
        ls_out-status      = ls_zgdmmt0001-status.
        ls_out-del         = ls_zgdmmt0001-del.
        ls_out-deldt       = ls_zgdmmt0001-del_date.
        ls_out-delby       = ls_zgdmmt0001-del_by.

        ls_out-werks       = ls_zgdmmt0001-werks.
        ls_out-lgort       = ls_zgdmmt0001-lgort.
        ls_out-mblnr       = ls_zgdmmt0001-mblnr.
        ls_out-mjahr       = ls_zgdmmt0001-mjahr.
        ls_out-zeile       = ls_zgdmmt0001-zeile.
        READ TABLE gt_mseg INTO ls_mseg
                           WITH KEY mblnr = ls_zgdmmt0001-mblnr
                                    mjahr = ls_zgdmmt0001-mjahr
                                    zeile = ls_zgdmmt0001-zeile
                           BINARY SEARCH.
        READ TABLE gt_mkpf INTO ls_mkpf
                           WITH KEY mblnr = ls_zgdmmt0001-mblnr
                                    mjahr = ls_zgdmmt0001-mjahr
                           BINARY SEARCH.
        IF sy-subrc = 0.
          ls_out-matnr       = ls_mseg-matnr.
          READ TABLE gt_makt INTO ls_makt
                             WITH KEY matnr = ls_mseg-matnr.
          IF sy-subrc = 0.
            ls_out-maktx     = ls_makt-maktx.
          ENDIF.
          CLEAR gt_mean.
          READ TABLE gt_mean WITH KEY matnr = ls_mseg-matnr.
          ls_out-ean11 = gt_mean-ean11.
          ls_out-charg       = ls_mseg-charg.
          ls_out-menge       = ls_zgdmmt0001-menge.
          ls_out-budat       = ls_mkpf-budat.
          PERFORM f_uom_conversion USING ls_mseg-meins
                                   CHANGING ls_out-meins.
        ENDIF.

        APPEND ls_out TO gt_out.
        CLEAR ls_out.
      ENDLOOP.

      PERFORM f_modify_value.

    WHEN pa_prp.
      SORT gt_zgdmmt0001 BY mblnr mjahr zeile.
      SORT gt_mseg BY mblnr mjahr zeile.

      READ TABLE gt_zgdmmt0001 INTO ls_zgdmmt0001 INDEX 1.
      IF sy-subrc = 0.
        gs_header-werks = ls_zgdmmt0001-werks.
        SELECT SINGLE name1
          FROM t001w
          INTO gs_header-name1
          WHERE werks = ls_zgdmmt0001-werks.

        gs_header-lgort = ls_zgdmmt0001-lgort.

        SELECT SINGLE lgobe
          FROM t001l
          INTO gs_header-lgobe
          WHERE werks = ls_zgdmmt0001-werks
            AND lgort = ls_zgdmmt0001-lgort.

        WRITE ls_zgdmmt0001-req_date TO gs_header-req_datet DD/MM/YYYY.
      ENDIF.

      CLEAR ls_zgdmmt0001.
      LOOP AT gt_zgdmmt0001 INTO ls_zgdmmt0001.
        ADD 1 TO lv_nou.
        ls_out-nou  = lv_nou.
        READ TABLE gt_mseg INTO ls_mseg
                           WITH KEY mblnr = ls_zgdmmt0001-mblnr
                                    mjahr = ls_zgdmmt0001-mjahr
                                    zeile = ls_zgdmmt0001-zeile
                           BINARY SEARCH.
        IF sy-subrc = 0.
          ls_out-matnr       = ls_mseg-matnr.
          READ TABLE gt_makt INTO ls_makt
                             WITH KEY matnr = ls_mseg-matnr.
          IF sy-subrc = 0.
            ls_out-maktx     = ls_makt-maktx.
          ENDIF.
          CLEAR gt_mean.
          READ TABLE gt_mean WITH KEY matnr = ls_mseg-matnr.
          ls_out-ean11 = gt_mean-ean11.
          ls_out-charg       = ls_mseg-charg.
          PERFORM f_uom_conversion USING ls_mseg-meins
                                   CHANGING ls_out-meins.
          ls_out-menge       = ls_zgdmmt0001-menge.
          WRITE ls_zgdmmt0001-menge TO ls_out-menget UNIT ls_out-meins.
        ENDIF.

        CLEAR ls_mch1.
        READ TABLE gt_mch1 INTO ls_mch1
                           WITH KEY matnr = ls_mseg-matnr
                                    charg = ls_mseg-charg.
        IF sy-subrc = 0.
          ls_out-gjahr = ls_mch1-hsdat(4).
        ENDIF.

        ls_out-werks  = ls_zgdmmt0001-werks.
        ls_out-lgort  = ls_zgdmmt0001-lgort.

        TRY .
*            ls_out-map  = ls_zgdmmt0001-value_blocked / ls_zgdmmt0001-menge.
            CLEAR lv_map.
            lv_map  = ls_zgdmmt0001-value_blocked / ls_zgdmmt0001-menge.

          CATCH cx_sy_zerodivide .

        ENDTRY.

        ls_out-map    = lv_map * 100.
        ls_out-value  = ls_zgdmmt0001-value_blocked.
        CASE pa_leter.
          WHEN 'EP'.
            ls_out-keterangan = 'MKT EP'.
          WHEN 'CH'.
            ls_out-keterangan = 'MKT CH'.
          WHEN 'EXP'.
            ls_out-keterangan = 'MKT EXPORT'.
          WHEN 'FACTORY'.
            ls_out-keterangan = 'BEBAN FACTORY'.
          WHEN 'TLOG'.
            ls_out-keterangan = 'BEBAN TLOG'.
          WHEN 'TR'.
            ls_out-keterangan = 'BEBAN TR'.
          WHEN 'BARCLAY'.
            ls_out-keterangan = 'MKT BCL'.
          WHEN 'IBD'.
            ls_out-keterangan = 'MKT IBD'.
        ENDCASE.

*        IF ls_out-gjahr < sy-datum(4).
        IF ls_mch1-vfdat IS NOT INITIAL.
          IF ls_mch1-vfdat < ls_zgdmmt0001-req_date.
            ls_out-eketr = 'EXPIRED'.
          ELSE.
            ls_out-eketr = 'NON EXPIRED'.
          ENDIF.
        ELSE.
          ls_out-eketr = 'NON EXPIRED'.
        ENDIF.

        WRITE ls_out-value TO ls_out-valuet CURRENCY 'IDR'.
        WRITE ls_out-map TO ls_out-mapt. "CURRENCY 'IDR'.

        ADD ls_out-menge TO gs_header-menge.
        ADD ls_out-value TO gs_header-value.

        READ TABLE gt_mkpf INTO ls_mkpf
                           WITH KEY mblnr = ls_zgdmmt0001-mblnr
                                    mjahr = ls_zgdmmt0001-mjahr
                           BINARY SEARCH.
        IF sy-subrc = 0.
          ls_out-nordn  = ls_mkpf-bktxt.
        ENDIF.

        CLEAR ls_zgdmmt0002.
        READ TABLE gt_zgdmmt0002 INTO ls_zgdmmt0002
                                 WITH KEY zrecd = ls_zgdmmt0001-zrecd.
        IF sy-subrc = 0.
          gs_header-penyebab  = ls_zgdmmt0002-zrecdt.
          ls_out-penyebab     = ls_zgdmmt0002-zrecdt.
        ENDIF.
        APPEND ls_out TO gt_out.
        CLEAR ls_out.
      ENDLOOP.

      WRITE gs_header-value TO gs_header-valuet CURRENCY 'IDR'.

    WHEN pa_apr.
      SORT gt_zgdmmt0001 BY mblnr mjahr zeile.
      LOOP AT gt_zgdmmt0001 INTO ls_zgdmmt0001.
        ls_out-req_no     = ls_zgdmmt0001-req_no.
        ls_out-werks      = ls_zgdmmt0001-werks.
        ls_out-lgort      = ls_zgdmmt0001-lgort.
        ls_out-req_date   = ls_zgdmmt0001-req_date.
        ls_out-requester  = ls_zgdmmt0001-requester.
        ls_out-value      = ls_zgdmmt0001-value_blocked.
        ls_out-menge      = ls_zgdmmt0001-menge.
        ls_out-meins      = ls_zgdmmt0001-meins.
        ls_out-relstatus  = ls_zgdmmt0001-relstatus.
        IF ls_zgdmmt0001-relstatus IS NOT INITIAL.
          ls_out-upaprl   = icon_led_green.
        ENDIF.
        COLLECT ls_out INTO gt_out.
        CLEAR ls_out.
      ENDLOOP.

      SORT gt_out BY req_no.

    WHEN pa_bbk OR pa_bbk2.
      SORT gt_zgdmmt0001 BY mblnr mjahr zeile.
      SORT gt_mseg BY mblnr mjahr zeile.
      LOOP AT gt_zgdmmt0001 INTO ls_zgdmmt0001.
        ls_out-bbk_no     = ls_zgdmmt0001-bbk_no.
        ls_out-lifnr      = ls_zgdmmt0001-lifnr.
        ls_out-req_no     = ls_zgdmmt0001-req_no.
        ls_out-werks      = ls_zgdmmt0001-werks.
        ls_out-lgort      = ls_zgdmmt0001-lgort.
        ls_out-req_date   = ls_zgdmmt0001-req_date.
        ls_out-requester  = ls_zgdmmt0001-requester.
        ls_out-value      = ls_zgdmmt0001-value_blocked.
        ls_out-mblnr      = ls_zgdmmt0001-mblnr.
        ls_out-mjahr      = ls_zgdmmt0001-mjahr.
        ls_out-zeile      = ls_zgdmmt0001-zeile.
        ls_out-menge      = ls_zgdmmt0001-menge.
        ls_out-meins      = ls_zgdmmt0001-meins.

        CLEAR ls_mseg.
        READ TABLE gt_mseg INTO ls_mseg
                           WITH KEY mblnr = ls_zgdmmt0001-mblnr
                                    mjahr = ls_zgdmmt0001-mjahr
                                    zeile = ls_zgdmmt0001-zeile
                           BINARY SEARCH.
        IF sy-subrc = 0.
          ls_out-matnr      = ls_mseg-matnr.
          ls_out-charg      = ls_mseg-charg.
          CLEAR ls_makt.
          READ TABLE gt_makt INTO ls_makt
                             WITH KEY matnr = ls_mseg-matnr.
          IF sy-subrc = 0.
            ls_out-maktx     = ls_makt-maktx.
          ENDIF.
          CLEAR gt_mean.
          READ TABLE gt_mean WITH KEY matnr = ls_mseg-matnr.
          ls_out-ean11 = gt_mean-ean11.
        ENDIF.
        APPEND ls_out TO gt_out.
        CLEAR ls_out.
      ENDLOOP.

      lt_out[] = gt_out[].
      SORT lt_out BY matnr charg.
      DELETE ADJACENT DUPLICATES FROM lt_out COMPARING matnr charg.
      IF lt_out[] IS NOT INITIAL AND gt_002[] IS NOT INITIAL.
        SELECT DISTINCT matnr charg
          FROM zaccdtm
          INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtm
          FOR ALL ENTRIES IN lt_out
          WHERE matnr = lt_out-matnr
            AND charg = lt_out-charg.
      ENDIF.

      SORT gt_out BY req_no.

    WHEN pa_cp.
      SORT gt_zgdmmt0001 BY bbk_no werks lgort.
      LOOP AT gt_zgdmmt0001 INTO ls_zgdmmt0001.
        IF ls_zgdmmt0001-bbk_no IS INITIAL.
          CONTINUE.
        ENDIF.
        ls_out-bbk_no     = ls_zgdmmt0001-bbk_no.
        ls_out-werks      = ls_zgdmmt0001-werks.
        ls_out-lgort      = ls_zgdmmt0001-lgort.
        ls_out-bbk_date   = ls_zgdmmt0001-bbk_date.
        ls_out-requester  = ls_zgdmmt0001-requester.
        ls_out-value      = ls_zgdmmt0001-value_blocked.
        COLLECT ls_out INTO gt_out.
        CLEAR ls_out.
      ENDLOOP.

    WHEN pa_pbap.
      gs_header-bap_no  = pa_bapno.

      CLEAR ls_zgdmmt0001.
      SORT gt_zgdmmt0001 BY req_date.
      READ TABLE gt_zgdmmt0001 INTO ls_zgdmmt0001 INDEX 1.
      IF sy-subrc = 0.
** Req. by Eka 12.03.2018
*        gs_header-req_date  = ls_zgdmmt0001-req_date.
*        gs_header-spmon     = ls_zgdmmt0001-req_date(6).
        gs_header-req_date  = ls_zgdmmt0001-bbk_date.
        gs_header-spmon     = ls_zgdmmt0001-bbk_date(6).
        gs_header-bap_date  = ls_zgdmmt0001-bap_date.
** End Req. by Eka 12.03.2018
        gs_header-werks     = ls_zgdmmt0001-werks.

        SELECT SINGLE city1
          FROM t001w JOIN adrc ON t001w~adrnr = adrc~addrnumber
          INTO gs_header-city1
          WHERE werks = ls_zgdmmt0001-werks.
        TRANSLATE gs_header-city1 TO UPPER CASE.

        CLEAR ls_zgdmmt0001.
        lt_zgdmmt0001[] = gt_zgdmmt0001[].
        SORT lt_zgdmmt0001 BY req_no.
        DELETE ADJACENT DUPLICATES FROM lt_zgdmmt0001 COMPARING req_no.
        LOOP AT lt_zgdmmt0001 INTO ls_zgdmmt0001 FROM 1 TO 6.
          ADD 1 TO lv_count.
          CASE lv_count.
            WHEN 1 OR 2 OR 3.
              IF gs_header-reqno1 IS INITIAL.
                gs_header-reqno1 = ls_zgdmmt0001-req_no.
              ELSE.
                CONCATENATE gs_header-reqno1 ',' INTO gs_header-reqno1.
                CONCATENATE gs_header-reqno1 ls_zgdmmt0001-req_no INTO gs_header-reqno1
                  SEPARATED BY space.
              ENDIF.
            WHEN 4 OR 5 OR 6.
              IF gs_header-reqno2 IS INITIAL.
                gs_header-reqno2 = ls_zgdmmt0001-req_no.
              ELSE.
                CONCATENATE gs_header-reqno2 ',' INTO gs_header-reqno2.
                CONCATENATE gs_header-reqno2 ls_zgdmmt0001-req_no INTO gs_header-reqno2
                  SEPARATED BY space.
              ENDIF.
          ENDCASE.
        ENDLOOP.

        IF gs_header-reqno2 IS INITIAL.
          CONCATENATE gs_header-reqno1 ')' INTO gs_header-reqno1
            SEPARATED BY space.
        ELSE.
          CONCATENATE gs_header-reqno1 ',' INTO gs_header-reqno1.
          CONCATENATE gs_header-reqno2 ')' INTO gs_header-reqno2
            SEPARATED BY space.
        ENDIF.
      ENDIF.

      CLEAR ls_mkpf.
      READ TABLE gt_mkpf INTO ls_mkpf INDEX 1.
      IF sy-subrc = 0.
        gs_header-xblnr   = ls_mkpf-xblnr.
      ENDIF.

      SORT gt_zgdmmt0001 BY mblnr mjahr zeile.
      SORT gt_mseg BY mblnr mjahr zeile.

      CLEAR ls_zgdmmt0001.
      LOOP AT gt_zgdmmt0001 INTO ls_zgdmmt0001.
        ls_out-bbk_no   = ls_zgdmmt0001-bbk_no.
        ls_out-werks    = ls_zgdmmt0001-werks.
        ls_out-lgort    = ls_zgdmmt0001-lgort.
        READ TABLE gt_mseg INTO ls_mseg
                           WITH KEY mblnr = ls_zgdmmt0001-mblnr
                                    mjahr = ls_zgdmmt0001-mjahr
                                    zeile = ls_zgdmmt0001-zeile
                           BINARY SEARCH.
        IF sy-subrc = 0.
          ls_out-matnr       = ls_mseg-matnr.
          READ TABLE gt_makt INTO ls_makt
                             WITH KEY matnr = ls_mseg-matnr.
          IF sy-subrc = 0.
            ls_out-maktx     = ls_makt-maktx.
          ENDIF.
          CLEAR gt_mean.
          READ TABLE gt_mean WITH KEY matnr = ls_mseg-matnr.
          ls_out-ean11 = gt_mean-ean11.
          PERFORM f_uom_conversion USING ls_mseg-meins
                                   CHANGING ls_out-meins.
        ENDIF.

        ls_out-menge       = ls_zgdmmt0001-menge.
        APPEND ls_out TO lt_out.
        CLEAR ls_out.
      ENDLOOP.

      SORT lt_out BY bbk_no.
      CLEAR ls_out.
      LOOP AT lt_out INTO ls_out.
        wa_out-bbk_no = ls_out-bbk_no.
        wa_out-werks  = ls_out-werks.
        wa_out-lgort  = ls_out-lgort.

*        PERFORM f_unit_conversion USING    ls_out-matnr ls_out-menge
*                                           ls_out-meins 'KG'
*                                  CHANGING wa_out-menge lv_menget.
        wa_out-menge = ls_out-menge.
        WRITE wa_out-menge TO lv_menget UNIT ls_out-meins.

        COLLECT wa_out INTO gt_out.
        CLEAR ls_out.
      ENDLOOP.

      CLEAR ls_out.
      LOOP AT gt_out INTO ls_out.
        ADD 1 TO lv_nou.
        ls_out-nou  = lv_nou.
        ADD ls_out-menge TO lv_menge.
        WRITE ls_out-menge TO ls_out-menget UNIT 'KG'.
        MODIFY gt_out FROM ls_out TRANSPORTING nou menget.
        CLEAR ls_out.
      ENDLOOP.

      WRITE lv_menge TO gs_header-menget UNIT 'KG'.

    WHEN pa_mc.
      SORT gt_zgdmmt0001 BY mblnr mjahr zeile.
      SORT gt_mseg BY mblnr mjahr zeile.
      SORT gt_mkpf BY mblnr mjahr.
      LOOP AT gt_zgdmmt0001 INTO ls_zgdmmt0001.
        ls_out-bbk_no     = ls_zgdmmt0001-bbk_no.
        ls_out-lifnr      = ls_zgdmmt0001-lifnr.
        ls_out-cla_no     = ls_zgdmmt0001-cla_no.
        ls_out-werks      = ls_zgdmmt0001-werks.
        ls_out-lgort      = ls_zgdmmt0001-lgort.
        ls_out-cla_date   = ls_zgdmmt0001-cla_date.
        ls_out-requester  = ls_zgdmmt0001-requester.
        ls_out-value      = ls_zgdmmt0001-value_blocked.
        ls_out-mblnr      = ls_zgdmmt0001-mblnr.
        ls_out-mjahr      = ls_zgdmmt0001-mjahr.
        ls_out-zeile      = ls_zgdmmt0001-zeile.
        ls_out-menge      = ls_zgdmmt0001-menge.
        ls_out-meins      = ls_zgdmmt0001-meins.
        ls_out-cla_sts    = ls_zgdmmt0001-cla_sts.

        CLEAR ls_mkpf.
        READ TABLE gt_mkpf INTO ls_mkpf
                           WITH KEY mblnr = ls_zgdmmt0001-mblnr
                                    mjahr = ls_zgdmmt0001-mjahr
                           BINARY SEARCH.
        IF sy-subrc = 0.
          ls_out-budat = ls_mkpf-budat.
        ENDIF.

        CLEAR ls_mseg.
        READ TABLE gt_mseg INTO ls_mseg
                           WITH KEY mblnr = ls_zgdmmt0001-mblnr
                                    mjahr = ls_zgdmmt0001-mjahr
                                    zeile = ls_zgdmmt0001-zeile
                           BINARY SEARCH.
        IF sy-subrc = 0.
          ls_out-matnr      = ls_mseg-matnr.
          ls_out-charg      = ls_mseg-charg.
          CLEAR ls_makt.
          READ TABLE gt_makt INTO ls_makt
                             WITH KEY matnr = ls_mseg-matnr.
          IF sy-subrc = 0.
            ls_out-maktx     = ls_makt-maktx.
          ENDIF.
          CLEAR ls_mara.
          READ TABLE gt_mara INTO ls_mara
                             WITH KEY matnr = ls_mseg-matnr.
          IF sy-subrc = 0.
            ls_out-bismt     = ls_mara-bismt.
          ENDIF.
          CLEAR gt_mean.
          READ TABLE gt_mean WITH KEY matnr = ls_mseg-matnr.
          ls_out-ean11 = gt_mean-ean11.
        ENDIF.

        APPEND ls_out TO gt_out.
        CLEAR ls_out.
      ENDLOOP.

  ENDCASE.
ENDFORM.                    " F_COLLECT_DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CASE 'X'.
    WHEN pa_abs.
      CALL SCREEN 100.
    WHEN pa_crp.
      CALL SCREEN 100.
    WHEN pa_prp.
      CALL SCREEN 102.
    WHEN pa_apr.
      CALL SCREEN 100.
    WHEN pa_bbk OR pa_mc OR pa_bbk2.
      CALL SCREEN 104.
    WHEN pa_cp.
      CALL SCREEN 100.
    WHEN pa_pbap.
      IF gt_out[] IS NOT INITIAL.
        PERFORM f_cetak_form.
      ELSE.
        MESSAGE s000(zab) WITH 'Data not found'
                          DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  CASE sy-dynnr.
    WHEN '0100' OR '0104'.
      SET PF-STATUS 'PF100'.
      CASE 'X'.
        WHEN pa_abs.
          SET TITLEBAR 'TITLE1'.
        WHEN pa_crp.
          SET TITLEBAR 'TITLE3'.
        WHEN pa_apr.
          SET TITLEBAR 'TITLE8'.
        WHEN pa_bbk OR pa_bbk2.
          SET TITLEBAR 'TITLE7'.
        WHEN pa_cp.
          SET TITLEBAR 'TITLE5'.
        WHEN pa_mc.
          SET TITLEBAR 'TITLE9'.
      ENDCASE.
    WHEN '0101' OR '0103'.
      SET PF-STATUS 'PF101'.
      CASE 'X'.
        WHEN pa_abs.
          SET TITLEBAR 'TITLE2'.
        WHEN pa_cp.
          SET TITLEBAR 'TITLE6'.
      ENDCASE.
    WHEN '0102'.
      SET PF-STATUS 'PF100'.
      SET TITLEBAR 'TITLE4'.
    WHEN '0999'.
      SET PF-STATUS space.
  ENDCASE.

  PERFORM f_excluding_toolbar.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDING_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_excluding_toolbar .
  DATA : ls_exclude   TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_check.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row .
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_views.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.
ENDFORM.                    " F_EXCLUDING_TOOLBAR

*&---------------------------------------------------------------------*
*&      Module  OUT  OUTPUT
*&---------------------------------------------------------------------*
MODULE out OUTPUT.
  IF g_outcont IS INITIAL.
    CREATE OBJECT g_outcont
      EXPORTING
        container_name = 'CC_OUT'.
  ENDIF.

  IF g_outgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_outgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_outcont.

    PERFORM f_build_fieldcat.
    PERFORM f_build_layout.
    PERFORM f_build_sort_tab.
    PERFORM f_register_f4_for_fields USING 'PENYEBAB'.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_user_command
                event_receiver->handle_menu_button
                event_receiver->handle_toolbar FOR g_outgrid.

    CALL METHOD g_outgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_sort_grid[]
        it_outtab            = gt_out[]
        it_fieldcatalog      = gt_fieldcat[].

    CALL METHOD cl_gui_control=>set_focus
      EXPORTING
        control = g_outgrid.
    CALL METHOD cl_gui_cfw=>flush.
  ENDIF.

  PERFORM f_alv_refresh.
ENDMODULE.                 " OUT  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : lv_messsts(1),
         lv_mblnr TYPE mseg-mblnr.

  CASE sy-dynnr.
    WHEN '0100' OR '0102' OR '0104'.
      CASE ok_code.
        WHEN 'BACK' OR 'EXIT' OR 'CANC'.
          IF NOT g_outcont IS INITIAL.
            CALL METHOD g_outcont->free
              EXCEPTIONS
                cntl_system_error = 1
                cntl_error        = 2.
            CLEAR g_outcont.
            CLEAR g_outgrid.
          ENDIF.
          LEAVE TO SCREEN 0.
      ENDCASE.

    WHEN '0101'.
      CASE ok_code.
        WHEN 'CANCEL'.
          IF NOT g_outcont IS INITIAL.
            CALL METHOD g_outcont->free
              EXCEPTIONS
                cntl_system_error = 1
                cntl_error        = 2.
            CLEAR g_outcont.
            CLEAR g_outgrid.
          ENDIF.
          PERFORM f_select USING '' ''.
          LEAVE TO SCREEN 0.

        WHEN 'ENTER'.
          CASE gv_ucomm.
            WHEN '&ADDR'.
              IF pa_bukrs = '8210'.
                PERFORM f_add_claim.
              ELSE.
                PERFORM f_add_request.
              ENDIF.
            WHEN '&CLAIM'.
              PERFORM f_add_claim.
          ENDCASE.
          IF NOT g_outcont IS INITIAL.
            CALL METHOD g_outcont->free
              EXCEPTIONS
                cntl_system_error = 1
                cntl_error        = 2.
            CLEAR g_outcont.
            CLEAR g_outgrid.
          ENDIF.
          LEAVE TO SCREEN 0.
      ENDCASE.

    WHEN '0103'.
      CASE ok_code.
        WHEN 'CANCEL'.
          IF NOT g_outcont IS INITIAL.
            CALL METHOD g_outcont->free
              EXCEPTIONS
                cntl_system_error = 1
                cntl_error        = 2.
            CLEAR g_outcont.
            CLEAR g_outgrid.
          ENDIF.
          PERFORM f_select USING '' ''.
          LEAVE TO SCREEN 0.

        WHEN 'ENTER'.
          IF gv_bapno IS INITIAL.
            MESSAGE s000(zab) WITH 'Fill in all required entry fields'
                              DISPLAY LIKE 'E'.
          ELSE.
            PERFORM f_post_entries CHANGING lv_messsts lv_mblnr.
            IF NOT g_outcont IS INITIAL.
              CALL METHOD g_outcont->free
                EXCEPTIONS
                  cntl_system_error = 1
                  cntl_error        = 2.
              CLEAR g_outcont.
              CLEAR g_outgrid.
            ENDIF.
            IF lv_messsts IS NOT INITIAL.
              MESSAGE s000(zab) WITH 'Error posted' DISPLAY LIKE 'E'.
              CALL SCREEN 999.
            ELSE.
              MESSAGE s000(zab) WITH gv_bapno 'has been created with' lv_mblnr.
              LEAVE TO SCREEN 0.
            ENDIF.
          ENDIF.
      ENDCASE.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh .
  gs_stable-row = 'X'.
  gs_stable-col = 'X'.
  IF g_outgrid IS NOT INITIAL.
    CALL METHOD g_outgrid->refresh_table_display
      EXPORTING
        is_stable = gs_stable.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_build_fieldcat .
  DATA : lv_title1(15),
         lv_title2(15),
         lv_title2h(15),
         lv_title3(15),
         lv_title3h(15),
         lv_title4(15),
         lv_title4h(15),
         lv_title5(15).

  lv_title1   = pa_col01.
  CONDENSE lv_title1 NO-GAPS.
  lv_title2h  = pa_col02.
  CONDENSE lv_title2h NO-GAPS.
  lv_title3h  = pa_col03.
  CONDENSE lv_title3h NO-GAPS.
  lv_title4h  = pa_col04.
  CONDENSE lv_title4h NO-GAPS.
  lv_title5   = pa_col05.
  CONDENSE lv_title5 NO-GAPS.
  lv_title2   = pa_col01 + 1.
  CONDENSE lv_title2 NO-GAPS.
  lv_title3   = pa_col02 + 1.
  CONDENSE lv_title3 NO-GAPS.
  lv_title4   = pa_col03 + 1.
  CONDENSE lv_title4 NO-GAPS.

  CONCATENATE '1 -' lv_title1 'days' INTO lv_title1
  SEPARATED BY space.
  CONCATENATE lv_title2 '-' lv_title2h 'days' INTO lv_title2
  SEPARATED BY space.
  CONCATENATE lv_title3 '-' lv_title3h 'days' INTO lv_title3
  SEPARATED BY space.
  CONCATENATE lv_title4 '-' lv_title4h 'days' INTO lv_title4
  SEPARATED BY space.
  CONCATENATE '>' lv_title5 'days' INTO lv_title5
  SEPARATED BY space.

  CLEAR gt_fieldcat[].

  CASE 'X'.
    WHEN pa_abs.
      PERFORM f_abs_fieldcat USING lv_title1 lv_title2 lv_title3 lv_title4
                                   lv_title5.

    WHEN pa_crp.
      PERFORM f_crp_fieldcat.

    WHEN pa_prp.
      PERFORM f_prp_fieldcat.

    WHEN pa_apr.
      PERFORM f_apr_fieldcat.

    WHEN pa_bbk OR pa_bbk2.
      PERFORM f_bbk_fieldcat.

    WHEN pa_cp.
      PERFORM f_cp_fieldcat.

    WHEN pa_mc.
      PERFORM f_mc_fieldcat.

  ENDCASE.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout_alv-zebra               = selected.
  CASE 'X'.
    WHEN pa_abs OR pa_crp OR pa_cp.
      gs_layout_alv-box_fname           = 'CHECK'.
  ENDCASE.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT_TAB
*&---------------------------------------------------------------------*
FORM f_build_sort_tab .

ENDFORM.                    " F_BUILD_SORT_TAB

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg  USING    VALUE(fu_types)
                           VALUE(fu_fname)
                           VALUE(fu_reftb)
                           VALUE(fu_refld)
                           VALUE(fu_noout)
                           VALUE(fu_outln)
                           VALUE(fu_fltxt)
                           VALUE(fu_dosum)
                           VALUE(fu_hotsp)
                           VALUE(fu_colpos)
                           VALUE(fu_waers)
                           VALUE(fu_meins)
                           VALUE(fu_waers_f)
                           VALUE(fu_meins_f)
                           VALUE(fu_checkbox)
                           VALUE(fu_input)
                           VALUE(fu_icon)
                           VALUE(fu_just)
                           VALUE(fu_edit)
                           VALUE(fu_colopt)
                           VALUE(fu_emphasize)
                           VALUE(fu_decimals_o)
                           VALUE(fu_lowercase)
                           VALUE(fu_f4availabl).

  DATA: lv_fieldcat  TYPE  lvc_s_fcat.

  CLEAR: lv_fieldcat.
  lv_fieldcat-tabname           = fu_types.
  lv_fieldcat-fieldname         = fu_fname.
  lv_fieldcat-ref_field         = fu_refld.
  lv_fieldcat-ref_table         = fu_reftb.
  lv_fieldcat-no_out            = fu_noout.
  lv_fieldcat-outputlen         = fu_outln.
  lv_fieldcat-scrtext_l         = fu_fltxt.
  lv_fieldcat-scrtext_m         = fu_fltxt.
  lv_fieldcat-scrtext_s         = fu_fltxt.
  lv_fieldcat-reptext           = fu_fltxt.
  lv_fieldcat-no_out            = fu_noout.
  lv_fieldcat-do_sum            = fu_dosum.
  lv_fieldcat-hotspot           = fu_hotsp.
  lv_fieldcat-col_pos           = fu_colpos.
  lv_fieldcat-currency          = fu_waers.
  lv_fieldcat-quantity          = fu_meins.
  lv_fieldcat-qfieldname        = fu_meins_f.
  lv_fieldcat-cfieldname        = fu_waers_f.
  lv_fieldcat-checkbox          = fu_checkbox.
  lv_fieldcat-icon              = fu_icon.
  lv_fieldcat-just              = fu_just.
  lv_fieldcat-edit              = fu_edit.
  lv_fieldcat-emphasize         = fu_emphasize.
  lv_fieldcat-decimals_o        = fu_decimals_o.
  lv_fieldcat-lowercase         = fu_lowercase.
  lv_fieldcat-f4availabl        = fu_f4availabl.

  APPEND lv_fieldcat TO gt_fieldcat.
  CLEAR lv_fieldcat.
ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check fu_container.
  DATA : ls_out   TYPE zgdmmst001.

  LOOP AT gt_out INTO ls_out.
    IF ls_out-check = '-'.
      CONTINUE.
    ENDIF.
    ls_out-check  = fu_check.
    MODIFY gt_out FROM ls_out TRANSPORTING check.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_UP
*&---------------------------------------------------------------------*
FORM f_create_up USING fu_ucomm.
  DATA : lt_out        TYPE STANDARD TABLE OF zgdmmst001,
         lt_valid      TYPE STANDARD TABLE OF zgdmmst001,
         ls_out        TYPE zgdmmst001,
         ls_valid      TYPE zgdmmst001,
         lt_zgdmmt0001 TYPE STANDARD TABLE OF zgdmmt0001,
         ls_zgdmmt0001 TYPE zgdmmt0001,
         lv_sequence   TYPE zno6,
         lv_subrc      TYPE sy-subrc,
         lv_romawi(4),
         lv_reqno      TYPE zgdmmt0001-req_no,
         lv_werks      TYPE zgdmmst001-werks,
         lv_mjahr      TYPE zgdmmst001-mjahr.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.
  CASE fu_ucomm.
    WHEN '&CRUP'.
      DELETE lt_out WHERE req_no NE space.
    WHEN '&CLAIM'.
      DELETE lt_out WHERE cla_no NE space.
  ENDCASE.

  lt_valid[] = lt_out[].
  SORT lt_valid BY werks. " mjahr.
  DELETE ADJACENT DUPLICATES FROM lt_valid COMPARING werks. " mjahr.

*  LOOP AT lt_valid INTO ls_valid.
*    IF ls_valid-req_no IS NOT INITIAL.
*      DELETE lt_valid.
*    ENDIF.
*  ENDLOOP.

  IF lt_valid[] IS INITIAL.
    MESSAGE s000(zab) WITH 'No data to be processed' DISPLAY LIKE 'E'.
  ELSE.
    PERFORM f_validasi_number_range TABLES lt_valid
                                    USING '01'
                                    CHANGING lv_subrc lv_werks.
    IF lv_subrc IS INITIAL.
      LOOP AT lt_valid INTO ls_valid.
        PERFORM f_numbering USING '01' ls_valid-werks sy-datum(4)
                            CHANGING lv_sequence lv_subrc.

        LOOP AT lt_out INTO ls_out WHERE werks = ls_valid-werks.
*                                     AND mjahr = ls_valid-mjahr.
          CASE sy-datum+4(2).
            WHEN '01'.
              lv_romawi = 'I'.
            WHEN '02'.
              lv_romawi = 'II'.
            WHEN '03'.
              lv_romawi = 'III'.
            WHEN '04'.
              lv_romawi = 'IV'.
            WHEN '05'.
              lv_romawi = 'V'.
            WHEN '06'.
              lv_romawi = 'VI'.
            WHEN '07'.
              lv_romawi = 'VII'.
            WHEN '08'.
              lv_romawi = 'VIII'.
            WHEN '09'.
              lv_romawi = 'IX'.
            WHEN '10'.
              lv_romawi = 'X'.
            WHEN '11'.
              lv_romawi = 'XI'.
            WHEN '12'.
              lv_romawi = 'XII'.
          ENDCASE.

          CASE fu_ucomm.
            WHEN '&CRUP'.
              IF ls_out-werks = '0101' OR
                ls_out-werks = '0102'.
                CONCATENATE lv_sequence '/UP/' ls_out-lgort '/' lv_romawi
                            '/' sy-datum(4)
                       INTO ls_out-req_no.
              ELSE.
                CONCATENATE lv_sequence '/UP/' ls_out-werks
                            '-' ls_out-lgort '/' lv_romawi
                            '/' sy-datum(4)
                       INTO ls_out-req_no.
              ENDIF.
              IF lv_reqno IS INITIAL.
                lv_reqno = ls_out-req_no.
              ENDIF.
              ls_out-req_date   = sy-datum.
              ls_out-req_time   = sy-uzeit.
              CLEAR : ls_out-check.

              MODIFY gt_out FROM ls_out TRANSPORTING req_no req_date req_time check
                            WHERE werks = ls_out-werks
*                          AND mjahr = ls_out-mjahr
                              AND check = 'X'.

              PERFORM f_prepare_save_to_zgdmmt0001 USING ls_out-werks ls_out-lgort
                                                         ls_out-mblnr ls_out-mjahr
                                                         ls_out-zeile ls_out-req_no
                                                         ls_out-req_date ls_out-req_time
                                                         ls_out-menge ls_out-value
                                                         ls_out-meins fu_ucomm
                                                         ls_out-matnr ls_out-charg.
            WHEN '&CLAIM'.
              CONCATENATE lv_sequence '/CA/' ls_out-werks
                          '-' ls_out-lgort '/' lv_romawi
                          '/' sy-datum(4)
                     INTO ls_out-cla_no.
              IF lv_reqno IS INITIAL.
                lv_reqno = ls_out-cla_no.
              ENDIF.
              ls_out-cla_date   = sy-datum.
              ls_out-cla_time   = sy-uzeit.
              CLEAR : ls_out-check.

              MODIFY gt_out FROM ls_out TRANSPORTING cla_no cla_date cla_time check
                            WHERE werks = ls_out-werks
*                          AND mjahr = ls_out-mjahr
                              AND check = 'X'.

              PERFORM f_prepare_save_to_zgdmmt0001 USING ls_out-werks ls_out-lgort
                                                         ls_out-mblnr ls_out-mjahr
                                                         ls_out-zeile ls_out-cla_no
                                                         ls_out-cla_date ls_out-cla_time
                                                         ls_out-menge ls_out-value
                                                         ls_out-meins fu_ucomm
                                                         ls_out-matnr ls_out-charg.
          ENDCASE.

          CLEAR ls_out.

        ENDLOOP.
        CLEAR : lv_sequence.
      ENDLOOP.

      INSERT zgdmmt0001 FROM TABLE gt_save.
      CLEAR : gt_save[], gt_save.
      MESSAGE s000(zab) WITH lv_reqno 'has been created'.
    ELSE.
      MESSAGE s000(zab) WITH 'Please maintain number ranges for Plant'
                             lv_werks
                        DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CREATE_UP

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_SAVE_TO_ZGDMMT0001
*&---------------------------------------------------------------------*
FORM f_prepare_save_to_zgdmmt0001 USING  fu_werks fu_lgort fu_mblnr
                                         fu_mjahr fu_zeile fu_req_no
                                         fu_req_date fu_req_time fu_menge
                                         fu_value fu_meins fu_ucomm
                                         fu_matnr fu_charg.
  DATA : ls_save  TYPE zgdmmt0001.

  ls_save-werks          = fu_werks.
  ls_save-lgort          = fu_lgort.
  ls_save-mblnr          = fu_mblnr.
  ls_save-mjahr          = fu_mjahr.
  ls_save-zeile          = fu_zeile.
*  ls_save-req_no         = fu_req_no.
  ls_save-menge          = fu_menge.
  ls_save-value_blocked  = fu_value.
  ls_save-meins          = fu_meins.
*  ls_save-req_date       = fu_req_date.
*  ls_save-req_time       = fu_req_time.
  ls_save-requester      = sy-uname.
  ls_save-matnr          = fu_matnr.
  ls_save-charg          = fu_charg.

  CASE fu_ucomm.
    WHEN '&CRUP'.
      ls_save-req_no         = fu_req_no.
      ls_save-req_date       = fu_req_date.
      ls_save-req_time       = fu_req_time.
    WHEN '&CLAIM'.
      ls_save-cla_no         = fu_req_no.
      ls_save-cla_date       = fu_req_date.
      ls_save-cla_time       = fu_req_time.
  ENDCASE.

  ls_save-zrecd   = pa_zrecd.
  APPEND ls_save TO gt_save.
ENDFORM.                    " F_PREPARE_SAVE_TO_ZGDMMT0001

*&---------------------------------------------------------------------*
*&      Form  F_F4_REQUEST
*&---------------------------------------------------------------------*
FORM f_f4_request USING fu_ucomm.
  DATA : lt_out   TYPE STANDARD TABLE OF zgdmmst001,
         lt_valid TYPE STANDARD TABLE OF zgdmmst001,
         ls_valid TYPE zgdmmst001,
         lv_lines TYPE p.

  CASE fu_ucomm.
    WHEN '&ADDR'.
      lt_out[]  = gt_out[].
      DELETE lt_out WHERE check IS INITIAL.
      IF pa_bukrs = '8210'.
        DELETE lt_out WHERE cla_no IS NOT INITIAL.
      ELSE.
        DELETE lt_out WHERE req_no IS NOT INITIAL.
      ENDIF.

      lt_valid[] = lt_out[].
      SORT lt_valid BY werks lgort.
      DELETE ADJACENT DUPLICATES FROM lt_valid COMPARING werks lgort.
      DESCRIBE TABLE lt_valid LINES lv_lines.
      CASE lv_lines.
        WHEN 0.
          MESSAGE s000(zab) WITH 'No data to be processed' DISPLAY LIKE 'E'.

        WHEN 1.
          IF pa_bukrs = '8210'.
            SELECT *
              FROM zgdmmt0001
              INTO CORRESPONDING FIELDS OF TABLE gt_f4
              FOR ALL ENTRIES IN lt_valid
              WHERE werks     = lt_valid-werks
                AND lgort     = lt_valid-lgort
                AND cla_no    NE space
                AND cla_sts   = space
                AND print_id  = space
                AND del       = space.
          ELSE.
            SELECT *
              FROM zgdmmt0001
              INTO CORRESPONDING FIELDS OF TABLE gt_f4
              FOR ALL ENTRIES IN lt_valid
              WHERE werks     = lt_valid-werks
                AND lgort     = lt_valid-lgort
                AND req_no    NE space
                AND status    = space
                AND print_id  = space
                AND del       = space.
          ENDIF.

          IF gt_f4[] IS NOT INITIAL.
            CALL SCREEN 101 STARTING AT 10 10.
          ELSE.
            READ TABLE lt_valid INTO ls_valid INDEX 1.
            IF sy-subrc = 0.
              MESSAGE s000(zab)
              WITH 'Request No. not found for Plant ' ls_valid-werks
                   'and SLoc ' ls_valid-lgort
              DISPLAY LIKE 'E'.
            ENDIF.
          ENDIF.

        WHEN OTHERS.
          MESSAGE s000(zab) WITH 'Different Plant & SLoc' DISPLAY LIKE 'E'.
      ENDCASE.

    WHEN '&CLAIM'.
      lt_out[]  = gt_out[].
      DELETE lt_out WHERE check IS INITIAL.
      DELETE lt_out WHERE cla_no IS NOT INITIAL.

      lt_valid[] = lt_out[].
      SORT lt_valid BY werks lgort.
      DELETE ADJACENT DUPLICATES FROM lt_valid COMPARING werks lgort.
      DESCRIBE TABLE lt_valid LINES lv_lines.
      CASE lv_lines.
        WHEN 0.
          MESSAGE s000(zab) WITH 'No data to be processed' DISPLAY LIKE 'E'.

        WHEN 1.
          SELECT *
            FROM zgdmmt0001
            INTO CORRESPONDING FIELDS OF TABLE gt_f4
            FOR ALL ENTRIES IN lt_valid
            WHERE werks     = lt_valid-werks
              AND lgort     = lt_valid-lgort
              AND cla_no    NE space
              AND cla_sts   = space
              AND print_id  = space
              AND del       = space.

          IF gt_f4[] IS NOT INITIAL.
            CALL SCREEN 101 STARTING AT 10 10.
          ELSE.
            READ TABLE lt_valid INTO ls_valid INDEX 1.
            IF sy-subrc = 0.
*              MESSAGE s000(zab)
*              WITH 'Claim No. not found for Plant ' ls_valid-werks
*                   'and SLoc ' ls_valid-lgort
*              DISPLAY LIKE 'E'.
              PERFORM f_create_up USING fu_ucomm.
            ENDIF.
          ENDIF.

        WHEN OTHERS.
          MESSAGE s000(zab) WITH 'Different Plant & SLoc' DISPLAY LIKE 'E'.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_F4_REQUEST

*&---------------------------------------------------------------------*
*&      Module  F4_REQNO  INPUT
*&---------------------------------------------------------------------*
MODULE f4_reqno INPUT.
  DATA : lv_reqno TYPE help_info-dynprofld,
         ls_f4    TYPE zgdmmt0001.

  DATA : BEGIN OF lt_f4 OCCURS 0,
           reqno LIKE zgdmmt0001-req_no,
         END OF lt_f4.

  lv_reqno = 'GS_REQNO'.

  CLEAR : lt_f4[], lt_f4.
  LOOP AT gt_f4 INTO ls_f4.
    CASE gv_ucomm.
      WHEN '&ADDR'.
        IF pa_bukrs = '8210'.
          lt_f4-reqno     = ls_f4-cla_no.
        ELSE.
          lt_f4-reqno     = ls_f4-req_no.
        ENDIF.
      WHEN '&CLAIM'.
        lt_f4-reqno     = ls_f4-cla_no.
    ENDCASE.
    APPEND lt_f4.
  ENDLOOP.

  SORT lt_f4 BY reqno.
  DELETE ADJACENT DUPLICATES FROM lt_f4 COMPARING reqno.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'REQNO'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = lv_reqno
      value_org   = 'S'
    TABLES
      value_tab   = lt_f4.
ENDMODULE.                 " F4_REQNO  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_ADD_REQUEST
*&---------------------------------------------------------------------*
FORM f_add_request .
  DATA : lt_out       TYPE STANDARD TABLE OF zgdmmst001,
         ls_out       TYPE zgdmmst001,
         ls_f4        TYPE zgdmmt0001,
         lv_mess(100).

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.

  READ TABLE gt_f4 INTO ls_f4 WITH KEY req_no = gv_reqno.
  IF sy-subrc = 0.
    LOOP AT lt_out INTO ls_out.
      ls_out-req_no    = ls_f4-req_no.
      ls_out-req_date  = ls_f4-req_date.
      ls_out-req_time  = ls_f4-req_time.
      CLEAR : ls_out-check.

      MODIFY gt_out FROM ls_out TRANSPORTING req_no req_date req_time check
                    WHERE werks = ls_out-werks
                      AND lgort = ls_out-lgort
                      AND check = 'X'.

      PERFORM f_prepare_save_to_zgdmmt0001 USING ls_out-werks ls_out-lgort
                                                 ls_out-mblnr ls_out-mjahr
                                                 ls_out-zeile ls_out-req_no
                                                 ls_out-req_date ls_out-req_time
                                                 ls_out-menge ls_out-value
                                                 ls_out-meins '&CRUP'
                                                 ls_out-matnr ls_out-charg.
      CLEAR ls_out.
    ENDLOOP.
    INSERT zgdmmt0001 FROM TABLE gt_save.
    CLEAR : gt_save[], gt_save.
    MESSAGE s000(zab) WITH 'Data already processed'.
  ELSE.
    READ TABLE gt_f4 INTO ls_f4 INDEX 1.
    IF sy-subrc = 0.
      CONCATENATE 'Request No.' gv_reqno 'not found for Plant'
                  ls_f4-werks 'and SLoc' ls_f4-lgort
      INTO lv_mess
      SEPARATED BY space.
      MESSAGE s000(zab) WITH lv_mess DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ADD_REQUEST

*&---------------------------------------------------------------------*
*&      Form  F_ADD_CLAIM
*&---------------------------------------------------------------------*
FORM f_add_claim .
  DATA : lt_out       TYPE STANDARD TABLE OF zgdmmst001,
         ls_out       TYPE zgdmmst001,
         ls_f4        TYPE zgdmmt0001,
         lv_mess(100).

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.

  READ TABLE gt_f4 INTO ls_f4 WITH KEY cla_no = gv_reqno.
  IF sy-subrc = 0.
    LOOP AT lt_out INTO ls_out.
      ls_out-cla_no    = ls_f4-cla_no.
      ls_out-cla_date  = ls_f4-cla_date.
      ls_out-cla_time  = ls_f4-cla_time.
      CLEAR : ls_out-check.

      MODIFY gt_out FROM ls_out TRANSPORTING cla_no cla_date cla_time check
                    WHERE werks = ls_out-werks
                      AND lgort = ls_out-lgort
                      AND check = 'X'.

      PERFORM f_prepare_save_to_zgdmmt0001 USING ls_out-werks ls_out-lgort
                                                 ls_out-mblnr ls_out-mjahr
                                                 ls_out-zeile ls_out-cla_no
                                                 ls_out-cla_date ls_out-cla_time
                                                 ls_out-menge ls_out-value
                                                 ls_out-meins '&CLAIM'
                                                 ls_out-matnr ls_out-charg.
      CLEAR ls_out.
    ENDLOOP.
    INSERT zgdmmt0001 FROM TABLE gt_save.
    CLEAR : gt_save[], gt_save.
    MESSAGE s000(zab) WITH 'Data already processed'.
  ELSE.
*    READ TABLE gt_f4 INTO ls_f4 INDEX 1.
*    IF sy-subrc = 0.
*      CONCATENATE 'Claim No.' gv_reqno 'not found for Plant'
*                  ls_f4-werks 'and SLoc' ls_f4-lgort
*      INTO lv_mess
*      SEPARATED BY space.
*      MESSAGE s000(zab) WITH lv_mess DISPLAY LIKE 'E'.
*    ENDIF.
    PERFORM f_create_up USING gv_ucomm.
  ENDIF.
ENDFORM.                    " F_ADD_CLAIM

*&---------------------------------------------------------------------*
*&      Form  F_DELETE
*&---------------------------------------------------------------------*
FORM f_delete  USING    fu_flag.
  DATA : lt_out   TYPE STANDARD TABLE OF zgdmmst001,
         ls_out   TYPE zgdmmst001,
         lv_subrc TYPE sy-subrc.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.

  IF fu_flag IS INITIAL.
    SORT lt_out BY req_no.
    DELETE ADJACENT DUPLICATES FROM lt_out COMPARING req_no.

    LOOP AT lt_out INTO ls_out.
      PERFORM f_cek_request_settle USING ls_out fu_flag
                                   CHANGING lv_subrc.
      IF lv_subrc IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_subrc IS NOT INITIAL.
      MESSAGE s000(zab) WITH 'Data can not be deleted' DISPLAY LIKE 'E'.
    ELSE.
      LOOP AT lt_out INTO ls_out.
        ls_out-status = 'DELETE'.
        ls_out-del    = selected.
        ls_out-deldt  = sy-datum.
        ls_out-delby  = sy-uname.
        ls_out-check  = space.
        MODIFY gt_out FROM ls_out TRANSPORTING status del deldt delby check
                      WHERE req_no = ls_out-req_no.

        UPDATE zgdmmt0001 SET status   = ls_out-status
                              del      = ls_out-del
                              del_date = ls_out-deldt
                              del_by   = ls_out-delby
                          WHERE req_no = ls_out-req_no.
      ENDLOOP.
    ENDIF.
  ELSE.
    LOOP AT lt_out INTO ls_out.
      PERFORM f_cek_request_settle USING ls_out fu_flag
                                   CHANGING lv_subrc.
      IF lv_subrc IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_subrc IS NOT INITIAL.
      MESSAGE s000(zab) WITH 'Data can not be deleted' DISPLAY LIKE 'E'.
    ELSE.
      LOOP AT lt_out INTO ls_out.
        ls_out-status = 'DELETE'.
        ls_out-del    = selected.
        ls_out-deldt  = sy-datum.
        ls_out-delby  = sy-uname.
        ls_out-check  = space.
        MODIFY gt_out FROM ls_out TRANSPORTING status del deldt delby check
                      WHERE werks = ls_out-werks
                        AND lgort = ls_out-lgort
                        AND mblnr = ls_out-mblnr
                        AND mjahr = ls_out-mjahr
                        AND zeile = ls_out-zeile
                        AND req_no = ls_out-req_no.

        UPDATE zgdmmt0001 SET status   = ls_out-status
                              del      = ls_out-del
                              del_date = ls_out-deldt
                              del_by   = ls_out-delby
                          WHERE werks = ls_out-werks
                            AND lgort = ls_out-lgort
                            AND mblnr = ls_out-mblnr
                            AND mjahr = ls_out-mjahr
                            AND zeile = ls_out-zeile
                            AND req_no = ls_out-req_no.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DELETE

*&---------------------------------------------------------------------*
*&      Form  F_UNDELETE
*&---------------------------------------------------------------------*
FORM f_undelete  USING    fu_flag.
  DATA : lt_out   TYPE STANDARD TABLE OF zgdmmst001,
         ls_out   TYPE zgdmmst001,
         lv_subrc TYPE sy-subrc.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.

  IF fu_flag IS INITIAL.
    SORT lt_out BY req_no.
    DELETE ADJACENT DUPLICATES FROM lt_out COMPARING req_no.
    LOOP AT lt_out INTO ls_out.
      PERFORM f_cek_request_settle USING ls_out fu_flag
                                   CHANGING lv_subrc.
      IF lv_subrc IS NOT INITIAL.
        EXIT.
      ELSE.
        SELECT SINGLE *
          FROM zgdmmt0001
          WHERE mblnr  = ls_out-mblnr
            AND mjahr  = ls_out-mjahr
            AND zeile  = ls_out-zeile
            AND status = space.
        IF sy-subrc = 0.
          lv_subrc  = 4.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lv_subrc IS NOT INITIAL.
      MESSAGE s000(zab) WITH 'Data can not be undeleted' DISPLAY LIKE 'E'.
    ELSE.
      LOOP AT lt_out INTO ls_out.
        ls_out-status = space.
        ls_out-del    = space.
        ls_out-deldt  = space.
        ls_out-delby  = space.
        ls_out-check  = space.
        MODIFY gt_out FROM ls_out TRANSPORTING status del deldt delby check
                      WHERE req_no = ls_out-req_no.

        UPDATE zgdmmt0001 SET status   = ls_out-status
                              del      = ls_out-del
                              del_date = ls_out-deldt
                              del_by   = ls_out-delby
                          WHERE req_no = ls_out-req_no.
      ENDLOOP.
    ENDIF.
  ELSE.
    LOOP AT lt_out INTO ls_out.
      PERFORM f_cek_request_settle USING ls_out fu_flag
                                   CHANGING lv_subrc.
      IF lv_subrc IS NOT INITIAL.
        EXIT.
      ELSE.
        SELECT SINGLE *
          FROM zgdmmt0001
          WHERE mblnr  = ls_out-mblnr
            AND mjahr  = ls_out-mjahr
            AND zeile  = ls_out-zeile
            AND status = space.
        IF sy-subrc = 0.
          lv_subrc  = 4.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lv_subrc IS NOT INITIAL.
      MESSAGE s000(zab) WITH 'Data can not be undeleted' DISPLAY LIKE 'E'.
    ELSE.
      LOOP AT lt_out INTO ls_out.
        ls_out-status = space.
        ls_out-del    = space.
        ls_out-deldt  = space.
        ls_out-delby  = space.
        ls_out-check  = space.
        MODIFY gt_out FROM ls_out TRANSPORTING del deldt delby check status
                      WHERE werks = ls_out-werks
                        AND lgort = ls_out-lgort
                        AND mblnr = ls_out-mblnr
                        AND mjahr = ls_out-mjahr
                        AND zeile = ls_out-zeile
                        AND req_no = ls_out-req_no.

        UPDATE zgdmmt0001 SET status   = ls_out-status
                              del      = ls_out-del
                              del_date = ls_out-deldt
                              del_by   = ls_out-delby
                          WHERE werks = ls_out-werks
                            AND lgort = ls_out-lgort
                            AND mblnr = ls_out-mblnr
                            AND mjahr = ls_out-mjahr
                            AND zeile = ls_out-zeile
                            AND req_no = ls_out-req_no.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_UNDELETE

*&---------------------------------------------------------------------*
*&      Form  F_ABS_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_abs_fieldcat USING  fu_title1 fu_title2 fu_title3 fu_title4
                           fu_title5.
  PERFORM f_fieldcatg USING 'GT_OUT' :
    'CHECK' '' '' '' '5' '' '' '' '' '' '' '' '' 'X' '' '' ''
    'X' '' '' '' '' '',
    'MATNR' '' '' '' '10' 'Material' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' ''.
*    'LVORM' 'MARA' 'LVORM' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
*    '' '' '' '' '' ''.
  IF pa_bukrs = '8210'.
    PERFORM f_fieldcatg USING 'GT_OUT' :
      'BISMT' '' '' '' '18' 'Old Material' '' '' '' '' '' '' '' '' '' '' ''
      '' '' '' '' '' '',
      'EAN11' 'MEAN' 'EAN11' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
      '' '' '' '' '' '',
      'CLA_NO' 'ZGDMMT0001' 'CLA_NO' '' '' '' '' '' '' '' '' '' '' '' ''
      '' '' '' '' '' '' '' '',
      'CLA_DATE' 'ZGDMMT0001' 'CLA_DATE' '' '' '' '' '' '' '' '' '' '' '' ''
      '' '' '' '' '' '' '' '',
      'CLA_STS' 'ZGDMMT0001' 'CLA_STS' '' '' '' '' '' '' '' '' '' '' '' ''
      '' '' '' '' '' '' '' ''.
  ELSE.
    PERFORM f_fieldcatg USING 'GT_OUT' :
      'REQ_NO' 'ZGDMMT0001' 'REQ_NO' '' '' '' '' '' '' '' '' '' '' '' ''
      '' '' '' '' '' '' '' '',
      'REQ_DATE' 'ZGDMMT0001' 'REQ_DATE' '' '' '' '' '' '' '' '' '' '' '' ''
      '' '' '' '' '' '' '' ''.
  ENDIF.

  PERFORM f_fieldcatg USING 'GT_OUT' :
    'WERKS' 'MSEG' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'LGORT' 'MSEG' 'LGORT' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'CHARG' 'MSEG' 'CHARG' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'VNDNO' 'LFA1' 'LIFNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'VNDNM' 'LFA1' 'NAME1' '' '' 'Vendor Name' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MEINS' 'MSEG' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MENGE' 'MSEG' 'MENGE' '' '15' 'Blocked Qty' '' '' '' '' '' ''
    'MEINS' '' '' '' '' '' '' '' '' '' '',
    'VALUE' 'ZGDMMST001' 'VALUE' '' '15' 'Blocked Value' '' '' '' 'IDR' '' '' ''
    '' '' '' '' '' '' '' '' '' '',
    'VFDAT' 'MCH1' 'VFDAT' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'BUDAT' 'MKPF' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'AGING' '' '' '' '15' 'Aging(in days)' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' ''.

  IF pa_dondv IS INITIAL AND
    pa_agqty IS INITIAL.
    PERFORM f_fieldcatg USING 'GT_OUT' :
      'ACOL1_WAERS' '' '' '' '15' fu_title1 '' '' '' 'IDR' '' '' '' '' ''
      '' 'R' '' '' '' '' '' '',
      'ACOL2_WAERS' '' '' '' '15' fu_title2 '' '' '' 'IDR' '' '' '' '' ''
      '' 'R' '' '' '' '' '' '',
      'ACOL3_WAERS' '' '' '' '15' fu_title3 '' '' '' 'IDR' '' '' '' '' ''
      '' 'R' '' '' '' '' '' '',
      'ACOL4_WAERS' '' '' '' '15' fu_title4 '' '' '' 'IDR' '' '' '' '' ''
      '' 'R' '' '' '' '' '' '',
      'ACOL5_WAERS' '' '' '' '15' fu_title5 '' '' '' 'IDR' '' '' '' '' ''
      '' 'R' '' '' '' '' '' ''.
  ELSE.
    PERFORM f_fieldcatg USING 'GT_OUT' :
      'ACOL1_MEINS' '' '' '' '15' fu_title1 '' '' '' '' '' ''
      'MEINS' '' '' '' '' '' '' '' '' '' '',
      'ACOL2_MEINS' '' '' '' '15' fu_title2 '' '' '' '' '' ''
      'MEINS' '' '' '' '' '' '' '' '' '' '',
      'ACOL3_MEINS' '' '' '' '15' fu_title3 '' '' '' '' '' ''
      'MEINS' '' '' '' '' '' '' '' '' '' '',
      'ACOL4_MEINS' '' '' '' '15' fu_title4 '' '' '' '' '' ''
      'MEINS' '' '' '' '' '' '' '' '' '' '',
      'ACOL5_MEINS' '' '' '' '15' fu_title5 '' '' '' '' '' ''
      'MEINS' '' '' '' '' '' '' '' '' '' ''.
  ENDIF.



  PERFORM f_fieldcatg USING 'GT_OUT' :
    'MBLNR' 'MSEG' 'MBLNR' 'X' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MJAHR' 'MSEG' 'MJAHR' 'X' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'ZEILE' 'MSEG' 'ZEILE' 'X' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' ''.
ENDFORM.                    " F_ABS_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_CRP_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_crp_fieldcat .
  PERFORM f_fieldcatg USING 'GT_OUT' :
    'CHECK' '' '' '' '5' '' '' '' '' '' '' '' '' 'X' '' '' ''
    'X' '' '' '' '' '',
    'REQ_NO' 'ZGDMMT0001' 'REQ_NO' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '',
    'WERKS' 'MSEG' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'LGORT' 'MSEG' 'LGORT' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MBLNR' 'MSEG' 'MBLNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'BUDAT' 'MKPF' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'ZEILE' 'MSEG' 'ZEILE' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MATNR' '' '' '' '10' 'Material' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'EAN11' 'MEAN' 'EAN11' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'CHARG' 'MSEG' 'CHARG' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MENGE' '' '' '' '15' 'Qty' '' '' '' '' '' '' 'MEINS' '' '' '' ''
    '' '' '' '' '' '',
    'MEINS' 'MSEG' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'VALUE' 'ZGDMMST001' 'VALUE' '' '15' 'Blocked Value' '' '' '' 'IDR' '' '' ''
    '' '' '' '' '' '' '' '' '' '',
    'REQ_DATE' 'ZGDMMT0001' 'REQ_DATE' '' '12' 'Tgl.Request' '' '' ''
    '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SCRAP_NO' '' '' '' '13' 'Mat.Doc.Scrap' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'BBK_NO' 'ZGDMMT0001' 'BBK_NO' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'BBK_DATE' 'ZGDMMT0001' 'BBK_DATE' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'BAP_NO' 'ZGDMMT0001' 'BAP_NO' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'BAP_DATE' 'ZGDMMT0001' 'BAP_DATE' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'REQUESTER' 'ZGDMMT0001' 'REQUESTER' '' '12' 'Requester' '' '' ''
    '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'STATUS' 'ZGDMMT0001' 'STATUS' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'DEL' 'ZGDMMT0001' 'DEL' '' '' 'Del' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'DELDT' 'ZGDMMT0001' 'DEL_DATE' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '' '' '',
    'DELBY' 'ZGDMMT0001' 'DEL_BY' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_CRP_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_PRP_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_prp_fieldcat .
  PERFORM f_fieldcatg USING 'GT_OUT' :
    'NOU' '' '' '' '5' 'No.' '' '' '' '' '' '' '' '' '' '' 'R' '' '' ''
    '' '' '',
    'MATNR' '' '' '' '10' 'Material' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'EAN11' 'MEAN' 'EAN11' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'CHARG' 'MSEG' 'CHARG' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'GJAHR' '' '' '' '10' 'Prod.Year' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MEINS' 'MSEG' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'WERKS' 'MSEG' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MENGE' '' '' '' '15' 'Qty' '' '' '' '' '' '' 'MEINS' '' '' '' ''
    '' '' '' '' '' '',
*    'MAP' '' '' '' '15' 'MAP' '' '' '' 'IDR' '' '' '' '' '' '' '' ''
    'MAP' '' '' '' '15' 'MAP' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'VALUE' '' '' '' '15' 'Total' '' '' '' 'IDR' '' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'KETERANGAN' '' '' '' '15' 'Keterangan' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '',
    'EKETR' '' '' '' '18' 'Expired/NonExpired' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '',
    'PENYEBAB' '' '' '' '30' 'Penyebab' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '',
    'NORDN' '' '' '' '30' 'No.RDN-No.Memo MKT' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' 'X' '',
    'REMARKS' '' '' '' '30' 'Remarks' '' '' '' '' '' '' '' '' ''
    '' '' 'X' '' '' '' 'X' '',
    'SISABUDG' '' '' '' '30' 'Sisa Budget' '' '' '' 'IDR' '' '' '' '' ''
    '' '' 'X' '' '' '' '' ''.
ENDFORM.                    " F_PRP_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BBK_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_bbk_fieldcat .
  PERFORM f_fieldcatg USING 'GT_OUT' :
    'CHECK' '' '' '' '5' '' '' '' '' '' '' '' '' 'X' '' '' ''
    'X' '' '' '' '' '',
    'BBK_NO' 'ZGDMMT0001' 'BBK_NO' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '',
    'REQ_NO' 'ZGDMMT0001' 'REQ_NO' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '',
    'WERKS' 'MSEG' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'LGORT' 'MSEG' 'LGORT' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MATNR' '' '' '' '10' 'Material' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'EAN11' 'MEAN' 'EAN11' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'REQ_DATE' 'ZGDMMT0001' 'REQ_DATE' '' '12' 'Tgl.Request' '' '' ''
    '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'REQUESTER' 'ZGDMMT0001' 'REQUESTER' '' '12' 'Requester' '' '' ''
    '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MEINS' 'MSEG' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MENGE' '' '' '' '15' 'Qty' '' '' '' '' '' '' 'MEINS' '' '' '' ''
    '' '' '' '' '' '',
    'VALUE' '' '' '' '15' 'Total' '' '' '' 'IDR' '' '' '' '' '' '' '' ''
    '' '' '' '' ''.
ENDFORM.                    " F_BBK_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_CP_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_cp_fieldcat .
  PERFORM f_fieldcatg USING 'GT_OUT' :
    'CHECK' '' '' '' '5' '' '' '' '' '' '' '' '' 'X' '' '' ''
    'X' '' '' '' '' '',
    'BBK_NO' 'ZGDMMT0001' 'BBK_NO' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '',
    'WERKS' 'MSEG' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'LGORT' 'MSEG' 'LGORT' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'BBK_DATE' 'ZGDMMT0001' 'BBK_DATE' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'REQUESTER' 'ZGDMMT0001' 'REQUESTER' '' '12' 'Requester' '' '' ''
    '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VALUE' '' '' '' '15' 'Total' '' '' '' 'IDR' '' '' '' '' '' '' '' ''
    '' '' '' '' ''.
ENDFORM.                    " F_CP_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_FORM
*&---------------------------------------------------------------------*
FORM f_cetak_form .
  SELECT SINGLE *
    FROM ztnpqmdt001
    INTO gs_001
    WHERE sysid   = sy-sysid
      AND bname   = sy-uname.

  IF sy-subrc = 0.
    gv_host  = gs_001-rfchost.
  ENDIF.

  CASE 'X'.
    WHEN pa_pbap.
*      PERFORM f_cetak_pbap USING 'ZMM_BERITA_ACARA'.
      IF gs_header-werks = '0401'.
        PERFORM f_cetak_pbap USING 'ZTNPMM_BERITA_ACARA'.
      ELSE.
        PERFORM f_cetak_pbap USING 'ZMM_BERITA_ACARA'.
      ENDIF.

    WHEN OTHERS.
      IF gs_header-werks = '0401'.
        PERFORM f_cetak_lampiran_up USING 'ZTNPMM_LAMPIRAN_UP'.
      ELSE.
        IF gs_header-lgort(1) = '3'.
          IF gv_apo IS INITIAL.
            PERFORM f_cetak_lampiran_up USING 'ZMM_LAMPIRAN_UP_QR'.
          ELSE.
            PERFORM f_cetak_lampiran_up_qr USING 'ZMM_LAMPIRAN_UP'.
          ENDIF.
        ELSE.
          PERFORM f_cetak_lampiran_up USING 'ZMM_LAMPIRAN_UP'.
        ENDIF.
      ENDIF.
      IF ( sy-ucomm = 'PRNT' OR gv_ucomm = 'PRNT' ) AND pa_prp IS NOT INITIAL AND pa_reprt IS INITIAL.
        UPDATE zgdmmt0001 SET zfrmtl = pa_leter
                          WHERE req_no   = pa_reqno
                            AND status   = space
                            AND del      = space.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_CETAK_FORM

*&---------------------------------------------------------------------*
*&      Form  F_UOM_CONVERSION
*&---------------------------------------------------------------------*
FORM f_uom_conversion  USING    fu_meins
                       CHANGING fc_meins.
*    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
*      EXPORTING
*        input          = fu_meins
*      IMPORTING
*        output         = fc_meins
*      EXCEPTIONS
*        unit_not_found = 1
*        OTHERS         = 2.
  fc_meins  = fu_meins.
ENDFORM.                    " F_UOM_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_LAMPIRAN_UP
*&---------------------------------------------------------------------*
FORM f_cetak_lampiran_up USING  fu_formname.
  DATA : d_smrt_funcmod TYPE rs38l_fnam,
         lv_formname    TYPE tdsfname.

  gs_header-req_no  = gv_reqno.
  gs_header-leter   = pa_leter.

  READ TABLE gt_out INTO wa_out INDEX 1.
  gs_header-sisabudg = wa_out-sisabudg.
  WRITE gs_header-sisabudg TO gs_header-sisabudgt CURRENCY 'IDR'.

  CALL FUNCTION 'STF4_GET_DOMAIN_VALUE_TEXT'
    EXPORTING
      iv_domname      = 'ZFRMTL'
      iv_value        = pa_leter
    IMPORTING
      ev_value_text   = gs_header-beban
    EXCEPTIONS
      value_not_found = 1
      OTHERS          = 2.

  IF fu_formname = 'ZMM_LAMPIRAN_UP'.
    IF gs_header-beban(15) = 'Beban Marketing'.
      lv_formname = fu_formname.
    ELSE.
      lv_formname = 'ZMM_LAMPIRAN_UP_FAC'.
    ENDIF.
  ELSE.
    lv_formname = fu_formname.
  ENDIF.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname          "fu_formname
    IMPORTING
      fm_name            = d_smrt_funcmod
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  CALL FUNCTION d_smrt_funcmod
    EXPORTING
      control_parameters = d_ctrl_param
      output_options     = d_output_opt
      user_settings      = space
      gs_header          = gs_header
    TABLES
      gt_detail          = gt_out.
ENDFORM.                    " F_CETAK_LAMPIRAN_UP

*&---------------------------------------------------------------------*
*&      Form  F_MVTTYP_CHOICE
*&---------------------------------------------------------------------*
FORM f_mvttyp_choice .
  DATA : lt_out       TYPE STANDARD TABLE OF zgdmmst001,
         lt_check     TYPE STANDARD TABLE OF zgdmmst001,
         ls_check     TYPE zgdmmst001,
         lv_count     TYPE int4,
         lv_sequence  TYPE zno6,
         lv_subrc     TYPE sy-subrc,
         lv_romawi(4).

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.

  IF lt_out[] IS NOT INITIAL.
    lt_check[]  = lt_out[].
    SORT lt_check BY werks.
    DELETE ADJACENT DUPLICATES FROM lt_check COMPARING werks.

    DESCRIBE TABLE lt_check LINES lv_count.
    IF lv_count = 1.
      READ TABLE lt_check INTO ls_check INDEX 1.
      IF sy-subrc = 0.
        PERFORM f_numbering USING '03' ls_check-werks sy-datum(4)
                            CHANGING lv_sequence lv_subrc.

        CASE sy-datum+4(2).
          WHEN '01'.
            lv_romawi = 'I'.
          WHEN '02'.
            lv_romawi = 'II'.
          WHEN '03'.
            lv_romawi = 'III'.
          WHEN '04'.
            lv_romawi = 'IV'.
          WHEN '05'.
            lv_romawi = 'V'.
          WHEN '06'.
            lv_romawi = 'VI'.
          WHEN '07'.
            lv_romawi = 'VII'.
          WHEN '08'.
            lv_romawi = 'VIII'.
          WHEN '09'.
            lv_romawi = 'IX'.
          WHEN '10'.
            lv_romawi = 'X'.
          WHEN '11'.
            lv_romawi = 'XI'.
          WHEN '12'.
            lv_romawi = 'XII'.
        ENDCASE.

        CONCATENATE lv_sequence '/BAP/' ls_check-werks
                    '/' lv_romawi
                    '/' sy-datum(4)
               INTO gv_bapno.
        CONCATENATE lv_sequence '/' lv_romawi
                    '/' sy-datum(4)
               INTO gv_xblnr.
      ENDIF.

      CALL SCREEN 103 STARTING AT 10 10.

      CASE ok_code.
        WHEN 'ENTER'.
          LEAVE TO SCREEN 0.
      ENDCASE.
    ELSE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MVTTYP_CHOICE

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries CHANGING fc_messsts fc_mblnr.
  DATA : lt_out        TYPE STANDARD TABLE OF zgdmmst001,
         ls_out        TYPE zgdmmst001,
         ls_zgdmmt0001 TYPE zgdmmt0001,
         ls_0001       TYPE zgdmmt0001,
         ls_mseg       TYPE mseg,
         lt_update     TYPE STANDARD TABLE OF zgdmmst001,
         ls_update     TYPE zgdmmst001,
         lt_bbkno      TYPE TABLE OF string,
         lv_no1(6),
         lv_no2(4).

  DATA : goodsmvt_header TYPE bapi2017_gm_head_01,
         goodsmvt_item   TYPE STANDARD TABLE OF bapi2017_gm_item_create,
         return          TYPE STANDARD TABLE OF bapiret2,
         ls_return       TYPE bapiret2,
         ls_item         TYPE bapi2017_gm_item_create,
         lv_mblnr        LIKE mseg-mblnr,
         lv_mjahr        LIKE mseg-mjahr,
         lv_success      TYPE int4,
         lv_error        TYPE int4,
         lv_bbkno        LIKE zgdmmst001-bbk_no.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.

  LOOP AT lt_out INTO ls_out.
    CLEAR : goodsmvt_header, lv_mblnr, lv_mjahr,
            goodsmvt_item[], goodsmvt_item,
            return[], return, lv_bbkno.

    goodsmvt_header-pstng_date       = sy-datum.
    goodsmvt_header-doc_date         = sy-datum.
    SPLIT ls_out-bbk_no AT '/' INTO TABLE lt_bbkno.
    READ TABLE lt_bbkno INTO lv_no1 INDEX 1.
    READ TABLE lt_bbkno INTO lv_no2 INDEX 5.
    CONCATENATE lv_no1 '/' lv_no2
    INTO lv_bbkno.
    goodsmvt_header-ref_doc_no       = lv_bbkno.
    goodsmvt_header-ref_doc_no_long  = lv_bbkno.
    goodsmvt_header-pr_uname         = sy-uname.
*    WRITE ls_out-req_date TO goodsmvt_header-header_txt DD/MM/YYYY. "Perubahan terkait project accuracy
*    CONCATENATE ls_out-req_no goodsmvt_header-header_txt
*    INTO goodsmvt_header-header_txt
*    SEPARATED BY space.
    goodsmvt_header-header_txt       = gv_xblnr.
    goodsmvt_header-ver_gr_gi_slip   = '3'.
    goodsmvt_header-ver_gr_gi_slipx  = selected.

    CLEAR ls_zgdmmt0001.
    LOOP AT gt_zgdmmt0001 INTO ls_zgdmmt0001
                          WHERE bbk_no = ls_out-bbk_no
                            AND werks  = ls_out-werks
                            AND lgort  = ls_out-lgort.

      ls_item-plant       = ls_out-werks.
      ls_item-stge_loc    = ls_out-lgort.

      LOOP AT gt_mseg INTO ls_mseg WHERE mblnr = ls_zgdmmt0001-mblnr
                                     AND mjahr = ls_zgdmmt0001-mjahr
                                     AND zeile = ls_zgdmmt0001-zeile.

        ls_item-material    = ls_mseg-matnr.
        ls_item-batch       = ls_mseg-charg.
        IF pa_555 IS NOT INITIAL.
          ls_item-move_type   = '555'.
          ls_item-stck_type   = '3'.
        ENDIF.
        IF pa_z51 IS NOT INITIAL.
          ls_item-move_type   = 'Z51'.
          ls_item-stck_type   = 'S'.
        ENDIF.
        CLEAR ls_0001.
        ls_item-entry_qnt   = ls_zgdmmt0001-menge.
        ls_item-entry_uom   = ls_mseg-meins.
        APPEND ls_item TO goodsmvt_item.
        CLEAR ls_item.

        ls_update-werks   = ls_zgdmmt0001-werks.
        ls_update-lgort   = ls_zgdmmt0001-lgort.
        ls_update-mblnr   = ls_zgdmmt0001-mblnr.
        ls_update-mjahr   = ls_zgdmmt0001-mjahr.
        ls_update-zeile   = ls_zgdmmt0001-zeile.
        ls_update-req_no  = ls_zgdmmt0001-req_no.
        ls_update-bbk_no  = ls_zgdmmt0001-bbk_no.
        APPEND ls_update TO lt_update.
        CLEAR ls_update.
      ENDLOOP.
    ENDLOOP.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = goodsmvt_header
        goodsmvt_code    = '03'
      IMPORTING
        materialdocument = lv_mblnr
        matdocumentyear  = lv_mjahr
      TABLES
        goodsmvt_item    = goodsmvt_item
        return           = return.

    LOOP AT return INTO ls_return.
      CASE ls_return-type.
        WHEN 'E' OR 'A'.
          gt_error-icon   = icon_led_red.
        WHEN 'W'.
          gt_error-icon   = icon_led_yellow.
        WHEN 'I' OR 'S'.
          CONTINUE.
      ENDCASE.
      gt_error-mess = ls_return-message.
      APPEND gt_error.
    ENDLOOP.

    IF lv_mblnr IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      IF sy-subrc = 0.
        ADD 1 TO lv_success.
        LOOP AT lt_update INTO ls_update.
          UPDATE zgdmmt0001 SET status      = 'SETTLE'
                                scrap_no    = lv_mblnr
                                scrap_year  = lv_mjahr
                                bap_no      = gv_bapno
                                bap_date    = sy-datum
                                bap_time    = sy-uzeit
                            WHERE werks   = ls_update-werks
                              AND lgort   = ls_update-lgort
                              AND mblnr   = ls_update-mblnr
                              AND mjahr   = ls_update-mjahr
                              AND zeile   = ls_update-zeile
                              AND req_no  = ls_update-req_no
                              AND bbk_no  = ls_update-bbk_no.
        ENDLOOP.
        CLEAR : lt_update[], lt_update, ls_update.
      ELSE.
        ADD 1 TO lv_error.
      ENDIF.
    ELSE.
      ADD 1 TO lv_error.
    ENDIF.
  ENDLOOP.

  IF lv_error IS NOT INITIAL.
    fc_messsts  = 'X'.
  ELSE.
    fc_mblnr  = lv_mblnr.
  ENDIF.
ENDFORM.                    " F_POST_ENTRIES

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSI_VALUE
*&---------------------------------------------------------------------*
FORM f_conversi_value  USING    fu_matnr
                                fu_value
                                fu_waers
                                fu_meins
                       CHANGING fc_value fc_waers fc_meins.
  DATA : lv_value(15).

  IF fu_waers IS NOT INITIAL.
    WRITE fu_value TO lv_value CURRENCY fu_waers.
    REPLACE ALL OCCURRENCES OF '.' IN lv_value WITH space.
    CONDENSE lv_value NO-GAPS.
    fc_value = lv_value.
    fc_waers = fu_value.
  ENDIF.

  IF fu_meins IS NOT INITIAL.
    WRITE fu_value TO lv_value UNIT fu_meins.
    fc_value = lv_value.
    fc_meins = fu_value.
  ENDIF.
ENDFORM.                    " F_CONVERSI_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_PBAP
*&---------------------------------------------------------------------*
FORM f_cetak_pbap  USING    fu_formname.
  DATA : d_smrt_funcmod TYPE rs38l_fnam,
         ls_ctrl_param  TYPE ssfctrlop,
         lv_count       TYPE p DECIMALS 0.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fu_formname
    IMPORTING
      fm_name            = d_smrt_funcmod
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF pa_chk01 IS NOT INITIAL AND
    pa_chk02 IS NOT INITIAL.
    DO 2 TIMES.
      ADD 1 TO lv_count.
      gs_header-flag  = lv_count.
      CASE lv_count.
        WHEN 1.
          ls_ctrl_param-no_close = 'X'.
        WHEN 2.
          ls_ctrl_param-no_close = space.
      ENDCASE.

      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters = ls_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          gs_header          = gs_header
        TABLES
          gt_detail          = gt_out.

      ls_ctrl_param-no_open = 'X'.
    ENDDO.
  ELSEIF pa_chk01 IS NOT INITIAL.
    gs_header-flag  = '1'.
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = ls_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        gs_header          = gs_header
      TABLES
        gt_detail          = gt_out.
  ELSEIF pa_chk02 IS NOT INITIAL.
    gs_header-flag  = '2'.
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = ls_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        gs_header          = gs_header
      TABLES
        gt_detail          = gt_out.
  ENDIF.
ENDFORM.                    " F_CETAK_PBAP

*&---------------------------------------------------------------------*
*&      Form  F_F4_VALUE_ON_REQUEST
*&---------------------------------------------------------------------*
FORM f_f4_value_on_request  USING    fu_retfield fu_dynprofield.
  DATA : lv_dynprofield TYPE help_info-dynprofld,
         lv_scrap_no    LIKE zgdmmt0001-scrap_no.

  DATA : BEGIN OF lt_reqno OCCURS 0,
           werks    LIKE zgdmmt0001-werks,
           lgort    LIKE zgdmmt0001-lgort,
           req_no   LIKE zgdmmt0001-req_no,
           req_date LIKE zgdmmt0001-req_date,
         END OF lt_reqno.
  DATA : BEGIN OF lt_reqno1 OCCURS 0,
           werks    LIKE zgdmmt0001-werks,
           lgort    LIKE zgdmmt0001-lgort,
           req_no   LIKE zgdmmt0001-req_no,
           scrap_no LIKE zgdmmt0001-scrap_no,
         END OF lt_reqno1.

  DATA : BEGIN OF lt_bbkno OCCURS 0,
           werks    LIKE zgdmmt0001-werks,
           lgort    LIKE zgdmmt0001-lgort,
           bbk_no   LIKE zgdmmt0001-bbk_no,
           bbk_date LIKE zgdmmt0001-bbk_date,
         END OF lt_bbkno.
  DATA : BEGIN OF lt_bbkno1 OCCURS 0,
           werks    LIKE zgdmmt0001-werks,
           lgort    LIKE zgdmmt0001-lgort,
           bbk_no   LIKE zgdmmt0001-bbk_no,
           bbk_date LIKE zgdmmt0001-bbk_date,
         END OF lt_bbkno1.

  DATA : BEGIN OF lt_bapno OCCURS 0,
           werks    LIKE zgdmmt0001-werks,
           lgort    LIKE zgdmmt0001-lgort,
           bap_no   LIKE zgdmmt0001-bap_no,
           bap_date LIKE zgdmmt0001-bap_date,
         END OF lt_bapno.

  DATA : BEGIN OF lt_clano OCCURS 0,
           werks    LIKE zgdmmt0001-werks,
           lgort    LIKE zgdmmt0001-lgort,
           cla_no   LIKE zgdmmt0001-cla_no,
           cla_date LIKE zgdmmt0001-cla_date,
         END OF lt_clano.

  DATA : BEGIN OF lt_scrapno OCCURS 0,
           werks    LIKE zgdmmt0001-werks,
           lgort    LIKE zgdmmt0001-lgort,
           req_no   LIKE zgdmmt0001-req_no,
           scrap_no LIKE zgdmmt0001-scrap_no,
         END OF lt_scrapno.

  DATA : return_tab  TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return   TYPE ddshretval,
         dynpfields  TYPE STANDARD TABLE OF dynpfields INITIAL SIZE 0,
         ls_dynpread TYPE dynpread.

  DATA : lt_zgdmmt0002  TYPE STANDARD TABLE OF zgdmmt0002 INITIAL SIZE 0
                        WITH HEADER LINE.

  DATA : BEGIN OF lt_leter OCCURS 0,
           zfrmtl TYPE zgdmmt0001-zfrmtl,
           desc   TYPE dd07v-ddtext,
         END OF lt_leter.

  DATA : lt_tab   TYPE STANDARD TABLE OF dd07v,
         ls_tab   LIKE LINE OF lt_tab,
         ls_leter LIKE LINE OF lt_leter.

  lv_dynprofield  = fu_dynprofield.

  CASE fu_retfield.
    WHEN 'REQ_NO'.
      IF pa_reprt IS INITIAL.
        SELECT *
          FROM zgdmmt0001
          INTO CORRESPONDING FIELDS OF TABLE lt_reqno.
      ELSE.
        SELECT *
          FROM zgdmmt0001
          INTO CORRESPONDING FIELDS OF TABLE lt_reqno
          WHERE zfrmtl = pa_leter.
      ENDIF.

      SORT lt_reqno BY werks lgort req_no req_date.
      DELETE ADJACENT DUPLICATES FROM lt_reqno COMPARING werks lgort req_no req_date.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield    = fu_retfield
          dynpprog    = sy-repid
          dynpnr      = sy-dynnr
          dynprofield = lv_dynprofield
          value_org   = 'S'
        TABLES
          value_tab   = lt_reqno.

    WHEN 'BBK_NO'.
      SELECT *
        FROM zgdmmt0001
        INTO CORRESPONDING FIELDS OF TABLE lt_bbkno
        WHERE bbk_no <> space.

      SORT lt_bbkno BY werks lgort bbk_no bbk_date.
      DELETE ADJACENT DUPLICATES FROM lt_bbkno COMPARING werks lgort bbk_no bbk_date.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield    = fu_retfield
          dynpprog    = sy-repid
          dynpnr      = sy-dynnr
          dynprofield = lv_dynprofield
          value_org   = 'S'
        TABLES
          value_tab   = lt_bbkno.

    WHEN 'BAP_NO'.
      SELECT *
        FROM zgdmmt0001
        INTO CORRESPONDING FIELDS OF TABLE lt_bapno
        WHERE bap_no <> space.

      SORT lt_bapno BY werks lgort bap_no bap_date.
      DELETE ADJACENT DUPLICATES FROM lt_bapno COMPARING werks lgort bap_no bap_date.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield    = fu_retfield
          dynpprog    = sy-repid
          dynpnr      = sy-dynnr
          dynprofield = lv_dynprofield
          value_org   = 'S'
        TABLES
          value_tab   = lt_bapno.

    WHEN 'CLA_NO'.
      SELECT *
        FROM zgdmmt0001
        INTO CORRESPONDING FIELDS OF TABLE lt_clano
        WHERE cla_no <> space
          AND cla_date = pa_cladt
          AND cla_sts = space.

      SORT lt_clano BY werks lgort cla_no cla_date.
      DELETE ADJACENT DUPLICATES FROM lt_clano COMPARING werks lgort cla_no cla_date.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield    = fu_retfield
          dynpprog    = sy-repid
          dynpnr      = sy-dynnr
          dynprofield = lv_dynprofield
          value_org   = 'S'
        TABLES
          value_tab   = lt_clano.

    WHEN 'SCRAP_NO'.
      IF pa_pbap IS NOT INITIAL.
        SELECT *
          FROM zgdmmt0001
          INTO CORRESPONDING FIELDS OF TABLE lt_reqno1
          WHERE scrap_no NE space.

        SORT lt_reqno1 BY werks lgort req_no scrap_no.
        DELETE ADJACENT DUPLICATES FROM lt_reqno1 COMPARING werks lgort req_no scrap_no.

        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
          EXPORTING
            retfield    = fu_retfield
            dynpprog    = sy-repid
            dynpnr      = sy-dynnr
            dynprofield = lv_dynprofield
            value_org   = 'S'
          TABLES
            value_tab   = lt_reqno1
            return_tab  = return_tab.

        READ TABLE return_tab INTO ls_return INDEX 1.
        IF sy-subrc = 0.
          lv_scrap_no  = ls_return-fieldval.
          READ TABLE lt_reqno1 WITH KEY scrap_no = lv_scrap_no.
          IF sy-subrc = 0.
            pa_reqno = lt_reqno1-req_no.

            ls_dynpread-fieldname  = 'PA_REQNO'.
            ls_dynpread-fieldvalue = pa_reqno.
            APPEND ls_dynpread TO dynpread.
            ls_dynpread-fieldname  = 'PA_SCRAP'.
            ls_dynpread-fieldvalue = lv_scrap_no.
            APPEND ls_dynpread TO dynpread.

            PERFORM f_dyn_values_update.
          ENDIF.
        ENDIF.
      ELSE.
        SELECT *
          FROM zgdmmt0001
          INTO CORRESPONDING FIELDS OF TABLE lt_scrapno
          WHERE scrap_no  <> space.

        SORT lt_scrapno BY werks lgort scrap_no.
        DELETE ADJACENT DUPLICATES FROM lt_scrapno COMPARING werks lgort scrap_no.

        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
          EXPORTING
            retfield    = fu_retfield
            dynpprog    = sy-repid
            dynpnr      = sy-dynnr
            dynprofield = lv_dynprofield
            value_org   = 'S'
          TABLES
            value_tab   = lt_scrapno.
      ENDIF.

    WHEN 'ZRECD'.
      SELECT *
        FROM zgdmmt0002
        INTO CORRESPONDING FIELDS OF TABLE lt_zgdmmt0002.

      SORT lt_zgdmmt0002.
      DELETE ADJACENT DUPLICATES FROM lt_zgdmmt0002 COMPARING zrecd.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield    = fu_retfield
          dynpprog    = sy-repid
          dynpnr      = sy-dynnr
          dynprofield = lv_dynprofield
          value_org   = 'S'
        TABLES
          value_tab   = lt_zgdmmt0002.

    WHEN 'ZFRMTL'.
      CALL FUNCTION 'DD_DOMVALUES_GET'
        EXPORTING
          domname        = fu_retfield
          text           = 'X'
          langu          = sy-langu
        TABLES
          dd07v_tab      = lt_tab
        EXCEPTIONS
          wrong_textflag = 1
          OTHERS         = 2.

      IF pa_reprt IS INITIAL.
        LOOP AT lt_tab INTO ls_tab.
          ls_leter-zfrmtl = ls_tab-domvalue_l.
          ls_leter-desc   = ls_tab-ddtext.
          APPEND ls_leter TO lt_leter.
          CLEAR ls_leter.
        ENDLOOP.
      ELSE.
        SELECT SINGLE zfrmtl
          FROM zgdmmt0001
          INTO ls_leter-zfrmtl
          WHERE req_no = pa_reqno.

        CLEAR ls_tab.
        READ TABLE lt_tab INTO ls_tab
                          WITH KEY domvalue_l = ls_leter-zfrmtl.
        IF sy-subrc = 0.
          ls_leter-desc   = ls_tab-ddtext.
          APPEND ls_leter TO lt_leter.
        ENDIF.
      ENDIF.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield    = fu_retfield
          dynpprog    = sy-repid
          dynpnr      = sy-dynnr
          dynprofield = lv_dynprofield
          value_org   = 'S'
        TABLES
          value_tab   = lt_leter.
  ENDCASE.
ENDFORM.                    " F_F4_VALUE_ON_REQUEST

*&---------------------------------------------------------------------*
*&      Module  ERROR_LIST_PROCESSING  OUTPUT
*&---------------------------------------------------------------------*
MODULE error_list_processing OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_error_list.
ENDMODULE.                 " ERROR_LIST_PROCESSING  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_LIST
*&---------------------------------------------------------------------*
FORM f_error_list .
  DATA : lv_zebra(1).

  ULINE AT /(87).
  FORMAT COLOR COL_HEADING.
  WRITE: /  sy-vline NO-GAP, (4) 'Sts.' NO-GAP,
            sy-vline NO-GAP, (80) 'Error message' NO-GAP,
            sy-vline.
  ULINE AT /(87).
  LOOP AT gt_error.
    PERFORM f_zebra CHANGING lv_zebra.
    WRITE: /  sy-vline NO-GAP, (4) gt_error-icon NO-GAP,
              sy-vline NO-GAP, gt_error-mess(80) NO-GAP,
              sy-vline NO-GAP.
  ENDLOOP.
  ULINE AT /(87).
  CLEAR : gt_error[], gt_error.
ENDFORM.                    " F_ERROR_LIST

*&---------------------------------------------------------------------*
*&      Form  F_ZEBRA
*&---------------------------------------------------------------------*
FORM f_zebra  CHANGING fc_zebra.
  FORMAT INTENSIFIED OFF.
  IF fc_zebra IS INITIAL.
    fc_zebra = 'X'.
    FORMAT COLOR COL_HEADING.
  ELSE.
    CLEAR : fc_zebra.
    FORMAT COLOR COL_NORMAL.
  ENDIF.
ENDFORM.                    " F_ZEBRA

*&---------------------------------------------------------------------*
*&      Form  F_CEK_REQUEST_SETTLE
*&---------------------------------------------------------------------*
FORM f_cek_request_settle  USING    fs_out STRUCTURE zgdmmst001
                                    fu_flag
                           CHANGING fc_subrc.

  DATA : ls_out   TYPE zgdmmst001.

  IF fu_flag IS INITIAL.
    READ TABLE gt_out INTO ls_out WITH KEY req_no = fs_out-req_no
                                           status = 'SETTLE'
                                  TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      fc_subrc = 4.
    ENDIF.
  ELSE.
    READ TABLE gt_out INTO ls_out WITH KEY req_no = fs_out-req_no
                                           status = 'SETTLE'
                                           mblnr  = fs_out-mblnr
                                           mjahr  = fs_out-mjahr
                                           zeile  = fs_out-zeile
                                  TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      fc_subrc = 4.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CEK_REQUEST_SETTLE

*&---------------------------------------------------------------------*
*&      Form  F_REGISTER_F4_FOR_FIELDS
*&---------------------------------------------------------------------*
FORM f_register_f4_for_fields USING   fu_field.
  DATA : lt_f4 TYPE lvc_t_f4 WITH HEADER LINE.

  CLEAR lt_f4.
  lt_f4-fieldname = fu_field.
  lt_f4-register  = selected.
  INSERT TABLE lt_f4.

  SET HANDLER event_receiver->handle_on_f4 FOR g_outgrid.

  CALL METHOD g_outgrid->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4[].
ENDFORM.                    " F_REGISTER_F4_FOR_FIELDS

*&---------------------------------------------------------------------*
*&      Form  F_ON_F4_HELP
*&---------------------------------------------------------------------*
FORM f_on_f4_help  USING    fu_fieldname
                            fu_row_id
                            fu_event_data TYPE REF TO cl_alv_event_data
                            fu_bad_cells
                            fu_display.

  DATA : BEGIN OF lt_f4 OCCURS 0,
           zrecd  LIKE zgdmmt0002-zrecd,
           zrecdt LIKE zgdmmt0002-zrecdt,
         END OF lt_f4.

  DATA : ls_zgdmmt0002 TYPE zgdmmt0002,
         lv_dynprofld  TYPE help_info-dynprofld,
         ls_out        TYPE zgdmmst001.

  DATA : lt_ret TYPE TABLE OF ddshretval  WITH HEADER LINE.

  CLEAR : lt_f4[], lt_f4.
  LOOP AT gt_zgdmmt0002 INTO ls_zgdmmt0002.
    lt_f4-zrecd     = ls_zgdmmt0002-zrecd.
    lt_f4-zrecdt    = ls_zgdmmt0002-zrecdt.
    APPEND lt_f4.
  ENDLOOP.

  lv_dynprofld  = 'GT_OUT-PENYEBAB'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'ZRECD'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = lv_dynprofld
      value_org   = 'S'
    TABLES
      value_tab   = lt_f4
      return_tab  = lt_ret.

  CHECK sy-subrc IS INITIAL.

  READ TABLE lt_f4 WITH KEY zrecd = lt_ret-fieldval.
  IF sy-subrc = 0.
    ls_out-penyebab = lt_f4-zrecdt.
    MODIFY gt_out FROM ls_out INDEX fu_row_id TRANSPORTING penyebab.
  ENDIF.
ENDFORM.                    " F_ON_F4_HELP

*&---------------------------------------------------------------------*
*&      Form  F_NUMBERING
*&---------------------------------------------------------------------*
FORM f_numbering  USING    fu_nrrange fu_werks fu_mjahr
                  CHANGING fc_number fc_subrc.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = fu_nrrange
      object                  = 'ZMAGING'
      subobject               = fu_werks
      toyear                  = fu_mjahr
    IMPORTING
      number                  = fc_number
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.

  fc_subrc  = sy-subrc.
ENDFORM.                    " F_NUMBERING

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_BBK
*&---------------------------------------------------------------------*
FORM f_create_bbk USING   fu_proc.
  TYPES : BEGIN OF ty_sum,
            req_no TYPE zgdmmt0001-req_no,
            matnr  TYPE zgdmmt0001-matnr,
            charg  TYPE zgdmmt0001-charg,
            werks  TYPE zgdmmt0001-werks,
            lgort  TYPE zgdmmt0001-lgort,
            meins  TYPE zgdmmt0001-meins,
            menge  TYPE zgdmmt0001-menge,
          END OF ty_sum.

  DATA : lt_out            TYPE STANDARD TABLE OF zgdmmst001 INITIAL SIZE 0,
         lt_proc           TYPE STANDARD TABLE OF zgdmmst001 INITIAL SIZE 0,
         ls_out            TYPE zgdmmst001,
         lt_valid          TYPE STANDARD TABLE OF zgdmmst001 INITIAL SIZE 0,
         ls_valid          TYPE zgdmmst001,
         ls_save           TYPE zgdmmt0001,
         lv_sequence       TYPE zno6,
         lv_subrc          TYPE sy-subrc,
         lv_nosnro         TYPE sy-subrc,
         lv_nou            TYPE zgdmmst001-nou,
         lv_romawi(4),
         ls_control_option TYPE ssfctrlop,
         lt_detail         TYPE STANDARD TABLE OF zgdmmst001 INITIAL SIZE 0,
         ls_output_option  TYPE ssfcompop,
         lv_kg             LIKE zgdmmst001-menge,
         lv_ob             LIKE zgdmmst001-menge,
         lv_menge          LIKE zgdmmst001-menge,
         lv_menge_kg       LIKE zgdmmst001-menge,
         lv_menge_ob       LIKE zgdmmst001-menge,
         lv_subobject      TYPE nriv-subobject,
         lv_nrrangenr      TYPE nriv-nrrangenr,
         lv_lifnr          LIKE lfa1-lifnr,
         lv_create         TYPE sy-subrc,
         lv_reprnt         TYPE sy-subrc,
         lv_bbkno          TYPE zgdmmst001-bbk_no,
         e_name(100),
         e_addr1(100),
         e_addr2(100),
         e_addr3(100),
         e_addr4(100),
         lv_bbk_no         TYPE zgdmmst001-bbk_no,
         lv_bbk_date       TYPE zgdmmst001-bbk_date,
         lv_bbk_time       TYPE zgdmmst001-bbk_time,
         lv_mjahr          TYPE zgdmmst001-mjahr,
         lv_werks          TYPE zgdmmst001-werks.

  DATA : lt_sum     TYPE STANDARD TABLE OF ty_sum,
         ls_sum     LIKE LINE OF lt_sum,
         ls_zaccu   LIKE LINE OF gt_zaccu,
         ls_zaccdtm LIKE LINE OF gt_zaccdtm,
         lt_zaccdtd TYPE STANDARD TABLE OF zaccdtd,
         ls_zaccdtd LIKE LINE OF lt_zaccdtd,
         lt_bbkno   TYPE TABLE OF string,
         lt_s501    TYPE STANDARD TABLE OF s501,
         ls_s501    LIKE LINE OF lt_s501,
         ls_002     LIKE LINE OF gt_002,
         lv_no1(6),
         lv_no2(4).

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.

  SORT lt_out BY req_no matnr charg werks lgort.
  LOOP AT lt_out INTO ls_out.
    READ TABLE gt_002 INTO ls_002
                      WITH KEY matnr = ls_out-matnr.
    IF sy-subrc = 0.
      READ TABLE gt_zaccdtm INTO ls_zaccdtm
                            WITH KEY matnr = ls_out-matnr
                                     charg = ls_out-charg.
      IF sy-subrc = 0.
        ls_sum-req_no = ls_out-req_no.
        ls_sum-matnr  = ls_out-matnr.
        ls_sum-charg  = ls_out-charg.
        ls_sum-werks  = ls_out-werks.
        ls_sum-lgort  = ls_out-lgort.
        ls_sum-meins  = ls_out-meins.
        ls_sum-menge  = ls_out-menge.
        COLLECT ls_sum INTO lt_sum.
        CLEAR ls_sum.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_sum INTO ls_sum.
    CLEAR lv_menge.
    LOOP AT gt_zaccu INTO ls_zaccu WHERE matnr = ls_sum-matnr
                                     AND charg = ls_sum-charg
                                     AND werks = ls_sum-werks
                                     AND lgort = ls_sum-lgort.
      ADD 1 TO lv_menge.
    ENDLOOP.
    IF ls_sum-menge > lv_menge.
      lv_subrc  = 1.
      MESSAGE s000(zab) WITH 'Serial number scanned is insufficient'.
      EXIT.
    ENDIF.
  ENDLOOP.

  CLEAR lv_menge.
  IF lv_subrc IS INITIAL.
    PERFORM f_validasi_create_bbk TABLES   lt_out lt_valid
                                  USING    fu_proc
                                  CHANGING lv_create lv_reprnt lv_subrc.

    IF lt_valid[] IS INITIAL.
      MESSAGE s000(zab) WITH 'No data to be processed' DISPLAY LIKE 'E'.
    ELSE.
      PERFORM f_validasi_number_range TABLES lt_valid
                                      USING '02'
                                      CHANGING lv_subrc lv_werks.
      IF lv_subrc IS INITIAL.
        lv_mjahr  = sy-datum(4).
        LOOP AT lt_valid INTO ls_valid.
          IF lv_create IS NOT INITIAL.
            CASE fu_proc.
              WHEN 'PREV'.
                lv_subobject  = ls_valid-werks.
                lv_nrrangenr  = '02'.

                SELECT SINGLE nrlevel
                  FROM nriv
                  INTO lv_sequence
                  WHERE object    = 'ZMAGING'
                    AND subobject = lv_subobject
                    AND nrrangenr = lv_nrrangenr
                    AND toyear    = lv_mjahr.

              WHEN 'POST'.
                PERFORM f_numbering USING '02' ls_valid-werks lv_mjahr
                                    CHANGING lv_sequence lv_nosnro.
            ENDCASE.
          ENDIF.

          IF lv_nosnro IS INITIAL.
            SELECT SINGLE butxt
              FROM t001k JOIN t001 ON t001k~bukrs = t001~bukrs
              INTO gs_header-butxt
              WHERE bwkey = ls_valid-werks.
            TRANSLATE gs_header-butxt TO UPPER CASE.

            SELECT SINGLE city1
              FROM t001w JOIN adrc ON t001w~adrnr = adrc~addrnumber
              INTO gs_header-city1
              WHERE werks = ls_valid-werks.
            TRANSLATE gs_header-city1 TO UPPER CASE.

            PERFORM f_detail_print_process TABLES lt_out lt_proc
                                           USING  ls_valid lv_reprnt fu_proc
                                           CHANGING gv_lifnr.

            IF gv_name1 IS NOT INITIAL.
              gs_header-name_to  = gv_name1.
              gs_header-addr1_to = gv_addr1.
              gs_header-addr2_to = gv_addr2.
            ELSE.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = gv_lifnr
                IMPORTING
                  output = lv_lifnr.

              CALL FUNCTION 'GET_VENDOR_DETAILS'
                EXPORTING
                  i_lifnr         = lv_lifnr
                  i_get_address   = 'X'
                IMPORTING
                  e_name          = e_name
                  e_addr1         = e_addr1
                  e_addr2         = e_addr2
                  e_addr3         = e_addr3
                  e_addr4         = e_addr4
                EXCEPTIONS
                  not_found       = 1
                  parameter_error = 2
                  OTHERS          = 3.

              gs_header-name_to  = e_name.
              gs_header-addr1_to = e_addr1.
              gs_header-addr2_to = e_addr2.
            ENDIF.

            CASE sy-datum+4(2).
              WHEN '01'.
                lv_romawi = 'I'.
              WHEN '02'.
                lv_romawi = 'II'.
              WHEN '03'.
                lv_romawi = 'III'.
              WHEN '04'.
                lv_romawi = 'IV'.
              WHEN '05'.
                lv_romawi = 'V'.
              WHEN '06'.
                lv_romawi = 'VI'.
              WHEN '07'.
                lv_romawi = 'VII'.
              WHEN '08'.
                lv_romawi = 'VIII'.
              WHEN '09'.
                lv_romawi = 'IX'.
              WHEN '10'.
                lv_romawi = 'X'.
              WHEN '11'.
                lv_romawi = 'XI'.
              WHEN '12'.
                lv_romawi = 'XII'.
            ENDCASE.

            CONCATENATE lv_sequence '/BBK/' ls_valid-werks
                        '/' lv_romawi
                        '/' sy-datum(4)
                   INTO lv_bbk_no.

            LOOP AT lt_proc INTO ls_out.
              IF lv_reprnt IS INITIAL.
                ls_out-bbk_no     = lv_bbk_no.
                gs_header-bbk_no  = ls_out-bbk_no.
                ls_out-bbk_date   = sy-datum.
                ls_out-bbk_time   = sy-uzeit.
              ELSE.
                gs_header-bbk_no  = ls_out-bbk_no.
              ENDIF.

              IF lv_bbkno IS INITIAL.
                lv_bbkno = ls_out-bbk_no.
              ENDIF.

              CLEAR : ls_out-check.

              IF fu_proc = 'PREV'.
                CLEAR ls_out-bbk_no.
              ENDIF.

              ls_out-lifnr  = gv_lifnr.
              MODIFY gt_out FROM ls_out TRANSPORTING bbk_no bbk_date bbk_time
                                                     check lifnr
                            WHERE werks  = ls_out-werks
                              AND lgort  = ls_out-lgort
                              AND mblnr  = ls_out-mblnr
                              AND mjahr  = ls_out-mjahr
                              AND zeile  = ls_out-zeile
                              AND req_no = ls_out-req_no
                              AND check  = 'X'.

              PERFORM f_prepupd_bbk_zgdmmt0001 USING ls_out-werks ls_out-lgort
                                                     ls_out-mblnr ls_out-mjahr
                                                     ls_out-zeile ls_out-req_no
                                                     ls_out-bbk_no ls_out-bbk_date
                                                     ls_out-bbk_time gv_lifnr
                                                     ls_out-menge ls_out-matnr
                                                     ls_out-charg ls_out-meins.
              ADD 1 TO lv_nou.
              ls_out-nou = lv_nou.
              WRITE ls_out-menge TO ls_out-menget UNIT ls_out-meins.

              PERFORM f_unit_conversion USING    ls_out-matnr ls_out-menge
                                                 ls_out-meins 'KG'
                                        CHANGING lv_kg ls_out-menge_kg.
              PERFORM f_unit_conversion USING    ls_out-matnr ls_out-menge
                                                 ls_out-meins 'OB'
                                        CHANGING lv_ob ls_out-menge_ob.

              ADD ls_out-menge TO lv_menge.
              ADD lv_kg TO lv_menge_kg.
              ADD lv_ob TO lv_menge_ob.

              IF lv_menge_kg IS NOT INITIAL.
                WRITE lv_menge_kg TO gs_header-menge_kg UNIT 'KG'.
              ENDIF.

              IF lv_menge_ob IS NOT INITIAL.
                WRITE lv_menge_ob TO gs_header-menge_ob UNIT 'OB'.
              ENDIF.

              IF lv_menge IS NOT INITIAL.
                WRITE lv_menge TO gs_header-menget DECIMALS 0.
              ENDIF.

              APPEND ls_out TO lt_detail.
              CLEAR ls_out.
            ENDLOOP.

            AT FIRST.
              ls_control_option-no_close = 'X'.
            ENDAT.

            AT LAST.
              ls_control_option-no_close = space.
            ENDAT.

            PERFORM f_cetak_bbk TABLES   lt_detail
                                USING    ls_control_option fu_proc 'ZMM_BBK'
                                         lv_reprnt.

            ls_control_option-no_open = 'X'.

            CLEAR : lv_sequence, lt_detail[], lt_detail, lv_nou,
                    lv_menge_kg, gs_header-menge_kg, lv_menge_ob,
                    lv_menge,gs_header-menge_ob.
          ENDIF.
        ENDLOOP.

        CLEAR ls_out.
        IF lv_nosnro IS INITIAL.
          IF fu_proc = 'POST'.
            LOOP AT gt_save INTO ls_save.
              CLEAR lv_menge.
              LOOP AT gt_zaccu INTO ls_zaccu WHERE matnr = ls_save-matnr AND
                                                   charg = ls_save-charg AND
                                                   werks = ls_save-werks AND
                                                   lgort = ls_save-lgort AND
                                                   check IS INITIAL.
                IF lv_menge < ls_save-menge.
                  ls_zaccu-check = 'X'.
                  MODIFY gt_zaccu FROM ls_zaccu TRANSPORTING check.
                  TRY .
                      UPDATE zaccdtd SET xloek ='X'
                                     WHERE docat = ls_zaccu-docat
                                       AND docno = ls_zaccu-docno
                                       AND posnr = ls_zaccu-posnr
                                       AND senum = ls_zaccu-senum.
                    CATCH cx_sy_conversion_no_number.
                  ENDTRY.
                  ls_zaccdtd-docat  = ls_zaccu-docat.
                  SPLIT ls_save-bbk_no AT '/' INTO TABLE lt_bbkno.
                  READ TABLE lt_bbkno INTO lv_no1 INDEX 1.
                  READ TABLE lt_bbkno INTO lv_no2 INDEX 5.
                  CONCATENATE lv_no1 '/' lv_no2
                  INTO ls_zaccdtd-docno.
                  ls_zaccdtd-posnr  = ls_zaccu-posnr.
                  ls_zaccdtd-senum  = ls_zaccu-senum.
                  ls_zaccdtd-scandt = sy-datum.
                  ls_zaccdtd-ernam  = sy-uname.
                  ls_zaccdtd-time   = sy-uzeit.
                  APPEND ls_zaccdtd TO lt_zaccdtd.

                  ls_s501-sptag     = sy-datum.
                  ls_s501-docat     = ls_zaccdtd-docat.
                  ls_s501-docno     = ls_zaccdtd-docno.
                  ls_s501-posnr     = ls_zaccdtd-posnr.
                  ls_s501-vrsio     = '000'.
                  ls_s501-spmon     = sy-datum(6).
                  ls_s501-spwoc     = '000000'.
                  ls_s501-spbup     = '000000'.
                  ls_s501-ssour     = space.
                  ls_s501-periv     = space.
                  ls_s501-vwdat     = space.
                  ls_s501-basme     = ls_save-meins.
                  ls_s501-werks     = ls_zaccu-werks.
                  ls_s501-lgort     = ls_zaccu-lgort.
                  ls_s501-charg     = ls_zaccu-charg.
                  ls_s501-matnr     = ls_zaccu-matnr.
                  ls_s501-menge     = 1.
                  ls_s501-meins     = ls_save-meins.
                  COLLECT ls_s501 INTO lt_s501.
                  ADD 1 TO lv_menge.
                ELSE.
                  EXIT.
                ENDIF.
              ENDLOOP.

              UPDATE zgdmmt0001 SET bbk_no    = ls_save-bbk_no
                                    bbk_date  = ls_save-bbk_date
                                    bbk_time  = ls_save-bbk_time
                                    lifnr     = ls_save-lifnr
                                WHERE werks   = ls_save-werks
                                  AND lgort   = ls_save-lgort
                                  AND mblnr   = ls_save-mblnr
                                  AND mjahr   = ls_save-mjahr
                                  AND zeile   = ls_save-zeile
                                  AND req_no  = ls_save-req_no.
            ENDLOOP.

            IF lt_zaccdtd[] IS NOT INITIAL.
              TRY.
                  INSERT zaccdtd FROM TABLE lt_zaccdtd.
                CATCH cx_sy_open_sql_db.
              ENDTRY.
            ENDIF.

            IF lt_s501[] IS NOT INITIAL.
              TRY.
                  INSERT s501 FROM TABLE lt_s501.
                CATCH cx_sy_open_sql_db.
              ENDTRY.
            ENDIF.

            CLEAR : gt_save[], gt_save.
            MESSAGE s000(zab) WITH lv_bbkno 'has been created'.
          ELSE.
            CLEAR : gt_save[], gt_save.
            IF lv_reprnt IS NOT INITIAL.
              CLEAR gv_lifnr.
            ENDIF.
          ENDIF.
        ELSE.
          MESSAGE s000(zab) WITH 'Please maintain number ranges first'
                            DISPLAY LIKE 'E'.
        ENDIF.
      ELSE.
        CASE lv_subrc.
          WHEN 4.
            MESSAGE s000(zab) WITH 'Data cannot be processed'
                              DISPLAY LIKE 'E'.
          WHEN 8.
            MESSAGE s000(zab) WITH 'Please maintain number ranges for Plant'
                                   lv_werks
                              DISPLAY LIKE 'E'.
        ENDCASE.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CREATE_BBK

*&---------------------------------------------------------------------*
*&      Module  F4_LIST  INPUT
*&---------------------------------------------------------------------*
MODULE f4_list INPUT.

ENDMODULE.                 " F4_LIST  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4_LIFNR  INPUT
*&---------------------------------------------------------------------*
MODULE f4_lifnr INPUT.
  DATA : lt_return_values TYPE STANDARD TABLE OF ddshretval,
         ls_return_values TYPE ddshretval,
         lv_lifnr         TYPE lfa1-lifnr,
         e_name(100),
         e_addr1(100),
         e_addr2(100),
         e_addr3(100),
         e_addr4(100).

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname           = 'EKKO'
      fieldname         = 'LIFNR'
      searchhelp        = 'KRED'
      shlpparam         = 'LIFNR'
      dynpprog          = sy-cprog
      dynpnr            = sy-dynnr
      dynprofield       = 'GV_LIFNR'
      display           = ''
    TABLES
      return_tab        = lt_return_values
    EXCEPTIONS
      field_not_found   = 1
      no_help_for_field = 2
      inconsistent_help = 3
      no_values_found   = 4
      OTHERS            = 5.

  IF sy-subrc = 0.
    READ TABLE lt_return_values INTO ls_return_values INDEX 1.
    IF sy-subrc = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_return_values-fieldval
        IMPORTING
          output = lv_lifnr.

      CALL FUNCTION 'GET_VENDOR_DETAILS'
        EXPORTING
          i_lifnr         = lv_lifnr
          i_get_address   = 'X'
        IMPORTING
          e_name          = e_name
          e_addr1         = e_addr1
          e_addr2         = e_addr2
          e_addr3         = e_addr3
          e_addr4         = e_addr4
        EXCEPTIONS
          not_found       = 1
          parameter_error = 2
          OTHERS          = 3.
    ENDIF.

    gv_name1  = e_name.
    gv_addr1  = e_addr1.
    gv_addr2  = e_addr2.
    gv_addr3  = e_addr3.
    gv_addr4  = e_addr4.
  ENDIF.
ENDMODULE.                 " F4_LIFNR  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_PREPUPD_BBK_ZGDMMT0001
*&---------------------------------------------------------------------*
FORM f_prepupd_bbk_zgdmmt0001  USING    fu_werks fu_lgort fu_mblnr
                                        fu_mjahr fu_zeile fu_req_no
                                        fu_bbk_no fu_bbk_date fu_bbk_time
                                        fu_lifnr fu_menge fu_matnr fu_charg fu_meins.
  DATA : ls_save  TYPE zgdmmt0001.

  ls_save-werks     = fu_werks.
  ls_save-lgort     = fu_lgort.
  ls_save-mblnr     = fu_mblnr.
  ls_save-mjahr     = fu_mjahr.
  ls_save-zeile     = fu_zeile.
  ls_save-req_no    = fu_req_no.
  ls_save-bbk_no    = fu_bbk_no.
  ls_save-bbk_date  = fu_bbk_date.
  ls_save-bbk_time  = fu_bbk_time.
  ls_save-lifnr     = fu_lifnr.
  ls_save-menge     = fu_menge.
  ls_save-matnr     = fu_matnr.
  ls_save-charg     = fu_charg.
  ls_save-meins     = fu_meins.
  APPEND ls_save TO gt_save.
ENDFORM.                    " F_PREPUPD_BBK_ZGDMMT0001

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_BBK
*&---------------------------------------------------------------------*
FORM f_cetak_bbk  TABLES   ft_detail  STRUCTURE zgdmmst001
                  USING    fs_control_option STRUCTURE ssfctrlop
                           fu_proc fu_formname fu_reprnt.

  DATA : d_smrt_funcmod   TYPE rs38l_fnam,
         ls_output_option TYPE ssfcompop.

  IF fu_reprnt IS INITIAL.
    CASE fu_proc.
      WHEN 'PREV'.
        ls_output_option-tdnoprint   = 'X'.
      WHEN 'POST'.
        ls_output_option-tdnoprev    = 'X'.
    ENDCASE.
  ENDIF.

  IF fu_proc = 'PREV'.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = fu_formname
      IMPORTING
        fm_name            = d_smrt_funcmod
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.

    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = fs_control_option
        output_options     = ls_output_option
        user_settings      = space
        gs_header          = gs_header
      TABLES
        gt_detail          = ft_detail.
  ENDIF.
ENDFORM.                    " F_CETAK_BBK

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION
*&---------------------------------------------------------------------*
FORM f_unit_conversion  USING    fu_matnr fu_menge fu_in fu_out
                        CHANGING fc_menge fc_menget.

  DATA : lv_menge  LIKE zgdmmst001-menge.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      i_matnr              = fu_matnr
      i_in_me              = fu_in
      i_out_me             = fu_out
      i_menge              = fu_menge
    IMPORTING
      e_menge              = lv_menge
    EXCEPTIONS
      error_in_application = 1
      error                = 2
      OTHERS               = 3.

  fc_menge  = lv_menge.
  IF lv_menge IS NOT INITIAL.
    WRITE lv_menge TO fc_menget UNIT fu_out.
  ENDIF.
ENDFORM.                    " F_UNIT_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_CREATE_BBK
*&---------------------------------------------------------------------*
FORM f_validasi_create_bbk  TABLES   ft_out STRUCTURE zgdmmst001
                                     ft_valid STRUCTURE zgdmmst001
                            USING    fu_proc
                            CHANGING fc_create fc_reprnt fc_subrc.
  DATA : ls_out   TYPE zgdmmst001,
         ls_valid TYPE zgdmmst001,
         lv_mtart LIKE mara-mtart.

  CLEAR : fc_create, fc_reprnt, fc_subrc.

  LOOP AT ft_out INTO ls_out.
    IF ls_out-bbk_no IS INITIAL.
      fc_create = 1.
    ELSE.
      fc_reprnt = 1.
    ENDIF.
  ENDLOOP.

  IF fc_create = 1 AND
    fc_reprnt = 1.
    fc_subrc = 4.
  ELSE.
    IF fu_proc = 'POST'.
      IF fc_reprnt IS NOT INITIAL.
        fc_subrc = 4.
      ELSE.
        fc_subrc = 0.
        ft_valid[] = ft_out[].
        SORT ft_valid BY werks.
        DELETE ADJACENT DUPLICATES FROM ft_valid COMPARING werks.
      ENDIF.
    ELSE.
      fc_subrc = 0.
      IF fc_reprnt IS NOT INITIAL.
        ft_valid[] = ft_out[].
        SORT ft_valid BY werks bbk_no.
        DELETE ADJACENT DUPLICATES FROM ft_valid COMPARING werks bbk_no.
      ELSE.
        ft_valid[] = ft_out[].
        SORT ft_valid BY werks.
        DELETE ADJACENT DUPLICATES FROM ft_valid COMPARING werks.
      ENDIF.
    ENDIF.

    IF fc_create IS NOT INITIAL AND
      gv_lifnr IS INITIAL AND
      fc_subrc IS INITIAL.
      CALL FUNCTION 'POPUP_DISPLAY_MESSAGE'
        EXPORTING
          msgid = 'ZAB'
          msgty = 'I'
          msgno = '000'
          msgv1 = 'Vendor is empty'.

      fc_subrc = 3.
    ENDIF.
  ENDIF.

  IF ft_valid[] IS NOT INITIAL.
    READ TABLE ft_valid INTO ls_valid INDEX 1.
    IF sy-subrc = 0.
      SELECT SINGLE mtart
        FROM mara
        INTO lv_mtart
        WHERE matnr = ls_valid-matnr.

      CASE lv_mtart.
        WHEN 'ZPHA' OR 'ZCGB'.
          CLEAR gs_header-mtart_flag.
        WHEN OTHERS.
          gs_header-mtart_flag  = 'X'.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDASI_CREATE_BBK

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL_PRINT_PROCESS
*&---------------------------------------------------------------------*
FORM f_detail_print_process  TABLES   ft_out STRUCTURE zgdmmst001
                                      ft_proc STRUCTURE zgdmmst001
                             USING    fs_valid STRUCTURE zgdmmst001
                                      fu_reprnt fu_proc
                             CHANGING fc_lifnr.

  DATA : ls_out   TYPE zgdmmst001,
         lt_ref   TYPE STANDARD TABLE OF zgdmmst001 INITIAL SIZE 0,
         ls_ref   TYPE zgdmmst001,
         lv_count TYPE int4.

  CLEAR : ft_proc[], ft_proc.
  IF fu_reprnt IS INITIAL.
    LOOP AT ft_out INTO ls_out WHERE werks = fs_valid-werks.
      CASE fu_proc.
        WHEN 'PREV'.
          CLEAR: ls_out-req_date,ls_out-req_time,ls_out-requester,
                 ls_out-mblnr,ls_out-mjahr,ls_out-zeile.
          COLLECT ls_out INTO ft_proc.
        WHEN OTHERS.
          APPEND ls_out TO ft_proc.
      ENDCASE.
      CLEAR ls_out.
    ENDLOOP.
  ELSE.
    LOOP AT gt_out INTO ls_out WHERE werks  = fs_valid-werks
                                 AND bbk_no = fs_valid-bbk_no.
      fc_lifnr  = ls_out-lifnr.
      CASE fu_proc.
        WHEN 'PREV'.
          CLEAR: ls_out-req_date,ls_out-req_time,ls_out-requester,
                 ls_out-mblnr,ls_out-mjahr,ls_out-zeile.
          COLLECT ls_out INTO ft_proc.
        WHEN OTHERS.
          APPEND ls_out TO ft_proc.
      ENDCASE.
      CLEAR ls_out.
    ENDLOOP.
  ENDIF.

  CLEAR : lt_ref[], lt_ref.
  lt_ref[] = ft_proc[].
  SORT lt_ref BY req_no.
  DELETE ADJACENT DUPLICATES FROM lt_ref COMPARING req_no.
  LOOP AT lt_ref INTO ls_ref.
    IF lv_count IS INITIAL.
      lv_count = 1.
      gs_header-ref = ls_ref-req_no.
    ELSE.
      CONCATENATE gs_header-ref ls_ref-req_no INTO gs_header-ref
      SEPARATED BY ', '.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_DETAIL_PRINT_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM f_authorization .
  DATA : lt_out TYPE STANDARD TABLE OF zgdmmst001 INITIAL SIZE 0,
         ls_out TYPE zgdmmst001.

  IF pa_apr IS INITIAL.
    lt_out[]  = gt_out[].
    SORT lt_out BY werks lgort.
    DELETE ADJACENT DUPLICATES FROM lt_out COMPARING werks lgort.

    LOOP AT lt_out INTO ls_out.
      AUTHORITY-CHECK OBJECT 'M_MSEG_LGO'
          ID 'ACTVT' FIELD '01'
          ID 'WERKS' FIELD ls_out-werks
          ID 'LGORT' FIELD ls_out-lgort.
      IF sy-subrc <> 0.
        DELETE gt_out WHERE werks = ls_out-werks
                        AND lgort = ls_out-lgort.
      ENDIF.
    ENDLOOP.
  ELSE.
    AUTHORITY-CHECK OBJECT 'ZMUPAPP'
      ID 'ACTVT' FIELD '01'.
    IF sy-subrc <> 0.
      gv_autho = 4.
      EXIT.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_AUTHORIZATION

*&---------------------------------------------------------------------*
*&      Form  F_APR_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_apr_fieldcat .
  PERFORM f_fieldcatg USING 'GT_OUT' :
    'CHECK' '' '' '' '5' '' '' '' '' '' '' '' '' 'X' '' '' ''
    'X' '' '' '' '' '',
    'UPAPRL' '' '' '' '' 'UP Approval' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '',
    'REQ_NO' 'ZGDMMT0001' 'REQ_NO' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '',
    'WERKS' 'MSEG' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'LGORT' 'MSEG' 'LGORT' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'REQ_DATE' 'ZGDMMT0001' 'REQ_DATE' '' '12' 'Tgl.Request' '' '' ''
    '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'REQUESTER' 'ZGDMMT0001' 'REQUESTER' '' '12' 'Requester' '' '' ''
    '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MEINS' 'MSEG' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MENGE' '' '' '' '15' 'Qty' '' '' '' '' '' '' 'MEINS' '' '' '' ''
    '' '' '' '' '' '',
    'VALUE' '' '' '' '15' 'Total' '' '' '' 'IDR' '' '' '' '' '' '' '' ''
    '' '' '' '' ''.
ENDFORM.                    " F_APR_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_UP_APPROVAL
*&---------------------------------------------------------------------*
FORM f_up_approval USING fu_selected.
  DATA : lt_out TYPE STANDARD TABLE OF zgdmmst001 INITIAL SIZE 0,
         ls_out TYPE zgdmmst001.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.

  LOOP AT lt_out INTO ls_out.
    IF fu_selected IS INITIAL.
      CLEAR ls_out-upaprl.
    ELSE.
      ls_out-upaprl = icon_led_green.
    ENDIF.

    CLEAR ls_out-check.

    MODIFY gt_out FROM ls_out TRANSPORTING upaprl check
                                     WHERE werks   = ls_out-werks
                                       AND lgort   = ls_out-lgort
                                       AND req_no  = ls_out-req_no.

    UPDATE zgdmmt0001 SET relstatus = fu_selected
                      WHERE werks   = ls_out-werks
                        AND lgort   = ls_out-lgort
                        AND req_no  = ls_out-req_no.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_UP_APPROVAL

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_NUMBER_RANGE
*&---------------------------------------------------------------------*
FORM f_validasi_number_range  TABLES   ft_valid STRUCTURE zgdmmst001
                              USING    fu_nrrange
                              CHANGING fc_subrc fc_werks.

  DATA : lt_nriv      TYPE STANDARD TABLE OF nriv INITIAL SIZE 0,
         ls_nriv      TYPE nriv,
         ls_valid     TYPE zgdmmst001,
         lv_subobject TYPE nriv-subobject,
         lv_toyear    TYPE nriv-toyear.

  IF ft_valid[] IS NOT INITIAL.
    SELECT *
      FROM nriv
      INTO CORRESPONDING FIELDS OF TABLE lt_nriv
      WHERE object    = 'ZMAGING'
        AND nrrangenr = fu_nrrange.
  ENDIF.

  LOOP AT ft_valid INTO ls_valid.
    lv_subobject  = ls_valid-werks.
    lv_toyear     = sy-datum(4).
    READ TABLE lt_nriv INTO ls_nriv WITH KEY subobject = lv_subobject
                                             toyear    = lv_toyear.
    IF sy-subrc <> 0.
      fc_subrc  = 8.
      fc_werks  = ls_valid-werks.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_VALIDASI_NUMBER_RANGE

*&---------------------------------------------------------------------*
*&      Form  F_CEK_2100
*&---------------------------------------------------------------------*
FORM f_cek_2100 .
  IF pa_abs = 'X'.
    READ TABLE gt_out WITH KEY werks = gc_2100 TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      gv_2100 = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CEK_2100

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_CLAIM
*&---------------------------------------------------------------------*
FORM f_create_claim .
  DATA: lt_zgdmmt0001 TYPE TABLE OF zgdmmt0001 WITH HEADER LINE,
        lt_out        TYPE STANDARD TABLE OF zgdmmst001,
        lv_seq        TYPE char5,
        lv_date1      TYPE datum,
        lv_date2      TYPE datum.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.
  DELETE lt_out WHERE cla_no NE space.
  DELETE lt_out WHERE werks NE gc_2100.

  IF lt_out[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'I'.

  ELSE.
    "Get number claim
    CONCATENATE sy-datum(6) '01' INTO lv_date1.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = lv_date1
      IMPORTING
        last_day_of_month = lv_date2.

    SELECT * INTO TABLE lt_zgdmmt0001
      FROM zgdmmt0001 WHERE werks = gc_2100
                        AND cla_date BETWEEN lv_date1 AND lv_date2.
    IF sy-subrc = 0.
      SORT lt_zgdmmt0001 BY cla_no DESCENDING.
      READ TABLE lt_zgdmmt0001 INDEX 1.
      lv_seq = lt_zgdmmt0001-cla_no(5).
      lv_seq = lv_seq + 1.
    ELSE.
      lv_seq = '40001'.
    ENDIF.

    "Update table
    CLEAR: lt_zgdmmt0001,lt_zgdmmt0001[].
    SELECT * INTO TABLE lt_zgdmmt0001
      FROM zgdmmt0001 FOR ALL ENTRIES IN lt_out
      WHERE werks = lt_out-werks
        AND lgort = lt_out-lgort
        AND mblnr = lt_out-mblnr
        AND mjahr = lt_out-mjahr
        AND zeile = lt_out-zeile
        AND req_no = lt_out-req_no
        AND cla_no = space.

    CLEAR: lt_zgdmmt0001-cla_no,
           lt_zgdmmt0001-cla_date,
           lt_zgdmmt0001-cla_time.

    CONCATENATE lv_seq '/CA/' lt_zgdmmt0001-werks '-' lt_zgdmmt0001-lgort
                sy-datum+4(2) '/' sy-datum(4) INTO lt_zgdmmt0001-cla_no.
    lt_zgdmmt0001-cla_date = sy-datum.
    lt_zgdmmt0001-cla_time = sy-uzeit.

    MODIFY lt_zgdmmt0001 TRANSPORTING cla_no cla_date cla_time
      WHERE cla_no = space.

    MODIFY zgdmmt0001 FROM TABLE lt_zgdmmt0001.
  ENDIF.
ENDFORM.                    " F_CREATE_CLAIM

*&---------------------------------------------------------------------*
*&      Form  F_MC_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_mc_fieldcat .
  PERFORM f_fieldcatg USING 'GT_OUT' :
*    'CHECK' '' '' '' '5' '' '' '' '' '' '' '' '' 'X' '' '' ''
*    'X' '' '' '' '' '',
    'CLA_NO' 'ZGDMMT0001' 'CLA_NO' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '',
    'CLA_DATE' 'ZGDMMT0001' 'CLA_DATE' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'WERKS' 'MSEG' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'LGORT' 'MSEG' 'LGORT' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MBLNR' 'MSEG' 'MBLNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MJAHR' 'MSEG' 'MJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'BUDAT' 'MKPF' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'ZEILE' 'MSEG' 'ZEILE' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MATNR' '' '' '' '10' 'Material' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'BISMT' '' '' '' '18' 'Old Material' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'EAN11' 'MEAN' 'EAN11' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'CHARG' 'MSEG' 'CHARG' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MENGE' '' '' '' '15' 'Qty' '' '' '' '' '' '' 'MEINS' '' '' '' ''
    '' '' '' '' '' '',
    'MEINS' 'MSEG' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'VALUE' '' '' '' '15' 'Total' '' '' '' 'IDR' '' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'REQUESTER' 'ZGDMMT0001' 'REQUESTER' '' '12' 'Requester' '' '' ''
    '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_MC_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status  USING fu_sts.
  gt_zgdmmt0001-cla_sts = fu_sts.
  MODIFY gt_zgdmmt0001 TRANSPORTING cla_sts WHERE cla_sts NE fu_sts.
  MODIFY zgdmmt0001 FROM TABLE gt_zgdmmt0001.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_CONFIRM_MESSAGE
*&---------------------------------------------------------------------*
FORM f_confirm_message  USING fu_sts
                              fu_answer.
  DATA: lv_title TYPE char100,
        lv_text  TYPE char100.

  lv_title = 'Confirm Message.....'.
  CONCATENATE 'Yakin akan' fu_sts 'dokumen ini...??' INTO lv_text SEPARATED BY space.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = lv_title
      text_question         = lv_text
      text_button_1         = 'Yes'
      text_button_2         = 'No'
      default_button        = '1'
      display_cancel_button = 'X'
    IMPORTING
      answer                = fu_answer.
ENDFORM.                    " F_CONFIRM_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_DATA
*&---------------------------------------------------------------------*
FORM f_validasi_data  USING    fc_subrc.
  DATA : ls_out   TYPE zgdmmst001.

  LOOP AT gt_out INTO ls_out WHERE check IS NOT INITIAL.
    IF ls_out-req_no IS NOT INITIAL.
      fc_subrc = 4.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_VALIDASI_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_LETER_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM f_check_leter_authorization .
  DATA : lv_check   TYPE sy-subrc.

  IF pa_leter IS NOT INITIAL.
    LOOP AT g_t_organ INTO g_s_organ.
      IF g_s_organ-werks = '0401' OR g_s_organ-werks = '1900'.
        lv_check = 4.
      ENDIF.
    ENDLOOP.

    IF lv_check IS INITIAL.
      IF pa_leter = 'BARCLAY' OR
        pa_leter = 'IBD'.
        MESSAGE e000(zab) WITH 'You are not authorized'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_LETER_AUTHORIZATION

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_VALUE
*&---------------------------------------------------------------------*
FORM f_modify_value .
  DATA: ls_mbew TYPE mbew,
        ls_out  TYPE zgdmmst001,
        lt_out  LIKE gt_out.

  lt_out[] = gt_out[].
  SORT lt_out BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM lt_out COMPARING matnr werks.

  SELECT matnr bwkey bwtar vprsv verpr stprs peinh
    INTO CORRESPONDING FIELDS OF TABLE gt_mbew
    FROM mbew FOR ALL ENTRIES IN lt_out
    WHERE matnr = lt_out-matnr
      AND bwkey = lt_out-werks.

  LOOP AT gt_out INTO ls_out.
    CLEAR ls_mbew.
    READ TABLE gt_mbew INTO ls_mbew
                       WITH KEY matnr = ls_out-matnr
                                bwkey = ls_out-werks.
    IF sy-subrc = 0.
      IF ls_mbew-verpr IS NOT INITIAL.
        ls_out-value  = ls_out-menge * ( ls_mbew-verpr / ls_mbew-peinh ).
      ELSE.
        ls_out-value  = ls_out-menge * ( ls_mbew-stprs / ls_mbew-peinh ).
      ENDIF.
    ENDIF.
    MODIFY gt_out FROM ls_out TRANSPORTING value.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_LAMPIRAN_UP_QR
*&---------------------------------------------------------------------*
FORM f_cetak_lampiran_up_qr  USING    fu_formname.
  DATA : d_smrt_funcmod TYPE rs38l_fnam,
         lv_formname    TYPE tdsfname.

  DATA : lt_out   TYPE STANDARD TABLE OF zgdmmst001,
         ls_out   LIKE LINE OF lt_out,
         ls_xout  LIKE LINE OF lt_out,
         lv_lines TYPE i,
         lv_count TYPE i,
         fr       TYPE i,
         to       TYPE i.

  gs_header-req_no  = gv_reqno.
  gs_header-leter   = pa_leter.

  CALL FUNCTION 'STF4_GET_DOMAIN_VALUE_TEXT'
    EXPORTING
      iv_domname      = 'ZFRMTL'
      iv_value        = pa_leter
    IMPORTING
      ev_value_text   = gs_header-beban
    EXCEPTIONS
      value_not_found = 1
      OTHERS          = 2.

*  IF gs_001-active IS INITIAL.
*    lv_formname   = 'ZMM_LAMPIRAN_UPQR'.
*
*    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*      EXPORTING
*        formname           = lv_formname
*      IMPORTING
*        fm_name            = d_smrt_funcmod
*      EXCEPTIONS
*        no_form            = 1
*        no_function_module = 2
*        OTHERS             = 3.
*
*    CALL FUNCTION d_smrt_funcmod
*      EXPORTING
*        control_parameters = d_ctrl_param
*        output_options     = d_output_opt
*        user_settings      = space
*        gs_header          = gs_header
*      TABLES
*        gt_detail          = gt_out.
*  ELSE.
  CALL FUNCTION 'RFC_MODIFY_R3_DESTINATION'
    EXPORTING
      destination                = gs_001-destination
      action                     = 'M'
      systemnr                   = gs_001-rfcservice
      server                     = gv_host
      language                   = sy-langu
      client                     = gs_001-rfcclient
      user                       = gs_001-rfcuser
      password                   = gs_001-password
    EXCEPTIONS
      authority_not_available    = 1
      destination_already_exist  = 2
      destination_not_exist      = 3
      destination_enqueue_reject = 4
      information_failure        = 5
      trfc_entry_invalid         = 6
      internal_failure           = 7
      snc_information_failure    = 8
      snc_internal_failure       = 9
      destination_is_locked      = 10
      OTHERS                     = 11.
  IF sy-subrc = 0.
    DESCRIBE TABLE gt_out LINES lv_lines.
    lv_lines  = ( lv_lines DIV 250 ) + 1.

    DO lv_lines TIMES.
      CLEAR lt_out[].
      fr = lv_count + 1.
      to = lv_count + 250.
      LOOP AT gt_out INTO ls_out FROM fr TO to.
        ADD 1 TO lv_count.
        ls_xout = ls_out.
        APPEND ls_xout TO lt_out.
        CLEAR ls_xout.
      ENDLOOP.

      CALL FUNCTION 'ZRFC_ZMM_LAMPIRAN_UP'
        DESTINATION gs_001-destination
        EXPORTING
          pi_cntrlpara = d_ctrl_param
          pi_outputopt = d_output_opt
          pi_tdsfname  = fu_formname
          pi_rspolname = gs_001-name
          pi_header    = gs_header
          pi_packsize  = 'X'
        IMPORTING
          pe_ucomm     = gv_ucomm
        TABLES
          pt_detail    = lt_out.
    ENDDO.
  ENDIF.
*  ENDIF.
ENDFORM.                    " F_CETAK_LAMPIRAN_UP_QR

*&---------------------------------------------------------------------*
*&      Form  F_DYN_VALUES_UPDATE
*&---------------------------------------------------------------------*
FORM f_dyn_values_update .
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dynpread
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.
ENDFORM.                    " F_DYN_VALUES_UPDATE
