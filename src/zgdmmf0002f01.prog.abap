*----------------------------------------------------------------------*
*   INCLUDE ZIBMFMMATDOCPRINTTEMPF01                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_process_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_report.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  PERFORM f_process_data.
  IF nast-kschl EQ 'ZWE2'.
    PERFORM f_get_packing.
    PERFORM f_karantina_process.
    PERFORM f_print_form1.
  ELSE.
    IF nast-kschl EQ 'ZWE1'.
      PERFORM f_get_packing.
      IF wa_hd-knttp = 'F'.
        PERFORM f_print_form.
      ELSE.
        PERFORM f_print_form2.
      ENDIF.
    ELSE.
      PERFORM f_print_form.
    ENDIF.
  ENDIF.
  PERFORM f_free_memory.

ENDFORM.                    " f_process_report
*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    " f_init_data
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA : adr_val TYPE addr1_val,
         add_sel TYPE addr1_sel.

* Get header
  SELECT SINGLE mblnr bldat bktxt xblnr tcode2
    FROM mkpf
    INTO CORRESPONDING FIELDS OF wa_hd
    WHERE mblnr EQ p_mblnr AND
          mjahr EQ p_mjahr.

* Get detail
  IF sy-subrc EQ 0.
*     Added SELECT lfa1
      SELECT sortl, lifnr INTO CORRESPONDING FIELDS OF TABLE @it_lfa1 FROM lfa1 WHERE lfa1~sortl = 'MITRAPAK'.

      IF nast-kschl EQ 'ZWA2'.
*{   REPLACE        P01K910442                                        1
*\      SELECT zeile werks umwrk lgort umlgo lifnr ebeln ebelp lfpos
*\             matnr charg menge meins erfmg erfme sgtxt qinspst bwart
*\             sakto kostl aufnr sobkz smbln grund insmk zustd lfbnr rsnum
*\             vfdat shkzg
*\        FROM mseg
*\        INTO CORRESPONDING FIELDS OF TABLE i_dt
*\        WHERE mblnr EQ p_mblnr AND
*\              mjahr EQ p_mjahr AND
*\              shkzg EQ 'S'.
        "Start SOH: Shell SCI Adjustment 20240222 RZL
        SELECT zeile werks umwrk lgort umlgo lifnr ebeln ebelp lfpos
               matnr charg menge meins erfmg erfme sgtxt qinspst bwart
               sakto kostl aufnr sobkz smbln grund insmk zustd lfbnr rsnum
               vfdat shkzg
          FROM mseg
          INTO CORRESPONDING FIELDS OF TABLE i_dt
          WHERE mblnr EQ p_mblnr AND
                mjahr EQ p_mjahr AND
                shkzg EQ 'S' ORDER BY PRIMARY KEY.
        "End SOH: Shell SCI Adjustment 20240222 RZL
*}   REPLACE

        SELECT spras bwart grund grtxt
          FROM t157e
          INTO TABLE t_t157e
          WHERE spras EQ sy-langu.
      ELSE.
*{   REPLACE        P01K910442                                        2
*\      SELECT zeile werks umwrk lgort umlgo lifnr ebeln ebelp lfpos
*\             matnr charg menge meins erfmg erfme sgtxt qinspst bwart
*\             sakto kostl aufnr sobkz smbln grund insmk zustd lfbnr rsnum
*\             vfdat shkzg
*\        FROM mseg
*\        INTO CORRESPONDING FIELDS OF TABLE i_dt
*\        WHERE mblnr EQ p_mblnr AND
*\              mjahr EQ p_mjahr.
        "Start SOH: Shell SCI Adjustment 20240222 RZL
        SELECT zeile werks umwrk lgort umlgo lifnr ebeln ebelp lfpos
               matnr charg menge meins erfmg erfme sgtxt qinspst bwart
               sakto kostl aufnr sobkz smbln grund insmk zustd lfbnr rsnum
               vfdat shkzg
          FROM mseg
          INTO CORRESPONDING FIELDS OF TABLE i_dt
          WHERE mblnr EQ p_mblnr AND
                mjahr EQ p_mjahr ORDER BY PRIMARY KEY.
        "End SOH: Shell SCI Adjustment 20240222 RZL
*}   REPLACE
      ENDIF.

      IF sy-subrc EQ 0.
        READ TABLE i_dt INTO wa_dt INDEX 1.
        IF sy-subrc EQ 0.
          wa_hd-werks = wa_dt-werks.
          IF nast-kschl EQ 'ZWA2'.
            wa_hd-rsnum = wa_dt-rsnum.
          ENDIF.
          IF wa_dt-bwart EQ '311' OR
            wa_dt-bwart EQ '312'  OR
            wa_dt-bwart EQ '313'  OR
            wa_dt-bwart EQ '314'  OR
            wa_dt-bwart EQ '325'  OR
            wa_dt-bwart EQ '326'.
            wa_hd-lgort = wa_dt-umlgo.
            wa_hd-umlgo = wa_dt-lgort.
          ELSE.
            wa_hd-lgort = wa_dt-lgort.
            wa_hd-umlgo = wa_dt-umlgo.
          ENDIF.
          wa_hd-umwrk = wa_dt-umwrk.

          IF wa_dt-bwart EQ '101' OR
            wa_dt-bwart EQ '102'  OR
            wa_dt-bwart EQ '103'  OR
            wa_dt-bwart EQ '104'  OR
            wa_dt-bwart EQ '105'  OR
            wa_dt-bwart EQ '106'  OR
            wa_dt-bwart EQ '122'  OR
            wa_dt-bwart EQ '123'  OR
            wa_dt-bwart EQ '161'  OR
            wa_dt-bwart EQ '162'.
            wa_hd-ebeln = wa_dt-ebeln.
          ELSE.
            wa_hd-ebeln = wa_hd-bktxt.
          ENDIF.

          IF nast-kschl EQ 'ZWE1'.
            SELECT SINGLE lifnr
              FROM ekko
              INTO wa_hd-lifnr
              WHERE ebeln EQ wa_hd-ebeln.

*****          CLEAR: gv_banfn,gv_aufnr,gv_matnr,gv_charg,gv_maktx,
*****                 gv_knttp,gv_werks.
*****          SELECT SINGLE banfn knttp werks
*****            INTO (gv_banfn,gv_knttp,gv_werks)
*****            FROM eban WHERE ebeln = wa_hd-ebeln
*****                        AND knttp = 'F'
*****                        AND werks IN ('0101','0102').
*****          SELECT SINGLE aufnr INTO gv_aufnr
*****            FROM ebkn WHERE banfn = gv_banfn.
*****          SELECT SINGLE matnr charg
*****            INTO (gv_matnr,gv_charg)
*****            FROM afpo WHERE aufnr = gv_aufnr.
*****          SELECT SINGLE maktx INTO gv_maktx
*****            FROM makt WHERE matnr = gv_matnr.

          ELSE.
            wa_hd-lifnr = wa_dt-lifnr.
          ENDIF.

          wa_hd-sakto = wa_dt-sakto.
          wa_hd-kostl = wa_dt-kostl.
          wa_hd-aufnr = wa_dt-aufnr.
          wa_hd-smbln = wa_dt-smbln.
          wa_hd-sobkz = wa_dt-sobkz.

* Get Plant Name
          SELECT SINGLE name1
            FROM t001w
            INTO wa_hd-name1_plant
            WHERE werks EQ wa_hd-werks.

* Get Description for Storage Location
          SELECT SINGLE lgobe
            FROM t001l
            INTO wa_hd-lgobe
            WHERE werks EQ wa_hd-werks AND
                  lgort EQ wa_hd-lgort.

* Get Description for To Storage Location
          SELECT SINGLE lgobe
            FROM t001l
            INTO wa_hd-lgobe1
            WHERE werks EQ wa_hd-umwrk AND
                  lgort EQ wa_hd-umlgo.

          SELECT SINGLE adrnr
            FROM ekko
            INTO add_sel-addrnumber
            WHERE ebeln EQ wa_dt-ebeln.

          IF add_sel-addrnumber NE space.
            CALL FUNCTION 'ADDR_GET'
              EXPORTING
                address_selection = add_sel
              IMPORTING
                address_value     = adr_val
              EXCEPTIONS
                OTHERS            = 1.
            wa_hd-name1_vendor = adr_val-name1.
            wa_hd-stras_vendor = adr_val-street.
            CONCATENATE adr_val-street adr_val-house_num1 INTO
            wa_hd-stras_vendor SEPARATED BY space.
            wa_hd-ort01_vendor = adr_val-city1.
          ELSE.
            SELECT SINGLE name1 stras ort01
              FROM lfa1
              INTO (wa_hd-name1_vendor, wa_hd-stras_vendor,
                    wa_hd-ort01_vendor)
              WHERE lifnr EQ wa_hd-lifnr.
          ENDIF.

* Get Description for G/L Account
          SELECT SINGLE txt50
            FROM skat
            INTO wa_hd-txt50
            WHERE spras EQ sy-langu AND
                  saknr EQ wa_hd-sakto.

* Get Description for Cost Center
          SELECT SINGLE ktext
            FROM cskt
            INTO wa_hd-ktext
            WHERE spras EQ sy-langu AND
                  kostl EQ wa_hd-kostl.

* Get Company Code
          SELECT SINGLE bukrs INTO wa_hd-bukrs
            FROM t001k WHERE bwkey EQ wa_hd-werks.
        ENDIF.
      ENDIF.
    ENDIF.
ENDFORM.                    " f_get_data
*&---------------------------------------------------------------------*
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.

ENDFORM.                    " f_validate_data
*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  DATA: l_name(70),
        l_mtart    LIKE mara-mtart,
        l_cuobj_bm LIKE mch1-cuobj_bm,
        l_atinn    LIKE cabn-atinn,
        l_lifnr    LIKE mch1-lifnr.

  DATA: lt_mard     TYPE TABLE OF mard WITH HEADER LINE.

  IF wa_hd-bukrs = '8380'.
    SELECT matnr werks lgort pstat lfgja lfmon lgpbe
      INTO CORRESPONDING FIELDS OF TABLE lt_mard
      FROM mard FOR ALL ENTRIES IN i_dt
      WHERE matnr EQ i_dt-matnr
        AND werks EQ i_dt-werks
        AND lgort EQ i_dt-lgort.
    ENDIF.

    CLEAR: wa_dt.
    LOOP AT i_dt INTO wa_dt.

      IF wa_hd-bukrs = '8380'.
        CLEAR lt_mard.
        READ TABLE lt_mard WITH KEY matnr = wa_dt-matnr
                                    werks = wa_dt-werks
                                    lgort = wa_dt-lgort.
        wa_dt-lgpbe = lt_mard-lgpbe.
      ENDIF.

      SELECT SINGLE maktx
        FROM makt
        INTO wa_dt-maktx
        WHERE matnr EQ wa_dt-matnr AND
              spras EQ sy-langu.
        IF sy-subrc NE 0.
          IF nast-kschl NE 'ZWE2'.
            SELECT SINGLE txz01
              FROM ekpo
              INTO wa_dt-maktx
              WHERE ebeln EQ wa_dt-ebeln AND
                    ebelp EQ wa_dt-ebelp.
            ENDIF.
          ENDIF.

* Karantina
          IF nast-kschl EQ 'ZWE2'.
            SELECT SINGLE mprof mfrpn idnlf
              FROM ekpo
              INTO (wa_dt-mprof, wa_dt-mfrpn, wa_dt-idnlf)
              WHERE ebeln EQ wa_dt-ebeln AND
                    ebelp EQ wa_dt-ebelp.
              IF wa_dt-mprof NE space.
                wa_dt-tdline = wa_dt-mfrpn.
              ELSEIF wa_dt-idnlf NE space.
                CONCATENATE wa_dt-ebeln wa_dt-ebelp INTO l_name.

                CALL FUNCTION 'READ_TEXT'
                  EXPORTING
                    id                      = 'F05'
                    language                = sy-langu
                    name                    = l_name
                    object                  = 'EKPO'
                  TABLES
                    lines                   = t_lines
                  EXCEPTIONS
                    id                      = 1
                    language                = 2
                    name                    = 3
                    not_found               = 4
                    object                  = 5
                    reference_check         = 6
                    wrong_access_to_archive = 7
                    OTHERS                  = 8.
                IF sy-subrc = 0.
                  LOOP AT t_lines.
                    IF t_lines-tdline NE space.
                      wa_lines-ebeln  = wa_dt-ebeln.
                      wa_lines-ebelp  = wa_dt-ebelp.
                      wa_lines-tdline = t_lines-tdline.
                      APPEND wa_lines TO i_lines.
                    ENDIF.
                  ENDLOOP.
                  wa_dt-tdline = t_lines-tdline.
                ENDIF.
              ELSE.
                wa_dt-tdline = space.
              ENDIF.

              SELECT SINGLE name1
                FROM lfa1
                INTO wa_dt-name1_vendor
                WHERE lifnr EQ wa_dt-lifnr.
              ENDIF.
* End Karantina

* Get Vendor Name.
              IF nast-kschl = 'ZWA2'.
                SELECT SINGLE lifnr
                  FROM mch1
                  INTO l_lifnr
                  WHERE matnr EQ wa_dt-matnr AND
                        charg EQ wa_dt-charg.
                  IF sy-subrc EQ 0.
                    SELECT SINGLE name1
                      FROM lfa1
                      INTO wa_dt-name1
                      WHERE lifnr EQ l_lifnr.
                    ENDIF.

                    IF wa_dt-bwart EQ '313'.
                      READ TABLE t_t157e WITH KEY bwart = wa_dt-bwart
                                                  grund = wa_dt-grund.
                      IF sy-subrc EQ 0.
                        wa_dt-grtxt = t_t157e-grtxt.
                      ENDIF.
                    ELSE.
                      IF wa_dt-werks = '0501' OR
                        wa_dt-werks = '2200'.
                        READ TABLE t_t157e WITH KEY bwart = wa_dt-bwart
                                                    grund = wa_dt-grund.
                        IF sy-subrc EQ 0.
                          wa_dt-grtxt = t_t157e-grtxt.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  ENDIF.

* Get Packing Type
                  IF nast-kschl = 'ZWE1'.
                    SELECT SINGLE mtart
                      FROM mara
                      INTO l_mtart
                      WHERE matnr EQ wa_dt-matnr.
                      CASE l_mtart.
                        WHEN 'ZRM'.
                          wa_dt-name_char = 'RM_PACKAGING'.
                        WHEN 'ZPM'.
                          wa_dt-name_char = 'PM_PACKAGING'.
                        WHEN 'ZSFG'.
                          wa_dt-name_char = 'SFG_PACKAGING'.
                      ENDCASE.
                    ELSE.
                      CLEAR: wa_dt-name_char.
                    ENDIF.

                    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
                      EXPORTING
                        input  = 'ZMF'
                      IMPORTING
                        output = l_atinn.

                    SELECT SINGLE licha cuobj_bm
                      FROM mch1
                      INTO (wa_dt-licha, l_cuobj_bm)
                      WHERE matnr EQ wa_dt-matnr AND
                            charg EQ wa_dt-charg.
                      IF sy-subrc EQ 0.
                        SELECT SINGLE atwrt
                          FROM ausp
                          INTO wa_dt-atwrt
                          WHERE objek  EQ l_cuobj_bm  AND
                                atinn  EQ l_atinn     AND
                                klart  EQ '023'.
                        ENDIF.

                        SELECT SINGLE btext
                          FROM t156t
                          INTO wa_dt-btext
                          WHERE spras EQ sy-langu AND
                                bwart EQ wa_dt-bwart.

                          IF wa_dt-qinspst EQ 1.
                            SELECT SINGLE prueflos anzgeb gebeh
                              FROM qals
                              INTO (wa_dt-prueflos, wa_dt-anzgeb, wa_dt-gebeh)
                              WHERE mblnr EQ p_mblnr AND
                                    mjahr EQ p_mjahr AND
                                    zeile EQ wa_dt-zeile.
                            ELSE.
                              wa_dt-prueflos = space.
                            ENDIF.

*****    IF nast-kschl EQ 'ZWE1' AND
*****       gv_knttp EQ 'F'      AND
*****     ( gv_werks EQ '0101' OR gv_werks EQ '0102' ) AND
*****       gv_matnr IS NOT INITIAL.
*****      wa_dt-matnr = gv_matnr.
*****      wa_dt-charg = gv_charg.
*****      wa_dt-maktx = gv_maktx.
*****      wa_dt-aufnr = gv_aufnr.
*****      wa_hd-knttp = wa_dt-knttp = gv_knttp.
*****    ENDIF.

                            MODIFY i_dt FROM wa_dt TRANSPORTING maktx licha atwrt btext prueflos
                                                                mprof mfrpn idnlf name1_vendor
                                                                tdline anzgeb gebeh name_char name1
                                                                grtxt lgpbe.
                            "matnr charg maktx aufnr
                            "knttp.

* Added changes in description material
                            IF wa_hd-werks = '2300' AND wa_dt-bwart = '541' AND nast-kschl = 'ZWA2'.
                              READ TABLE it_lfa1 INTO DATA(ls_lfa1) WITH KEY lifnr = wa_hd-lifnr.
                              IF sy-subrc = 0.
                                wa_dt-name1 = ''.
                                MODIFY i_dt FROM wa_dt TRANSPORTING name1.
                              ENDIF.
                              IF sy-subrc = 0 AND wa_dt-matnr(2) = 'RM'.
                                ADD 1 TO count_rm.
*                                wa_dt-maktx = |Raw Material { count_rm }|.
                                wa_dt-maktx = |Raw Material { wa_dt-matnr+6(4) }|.
                                MODIFY i_dt FROM wa_dt TRANSPORTING maktx.
                              ELSEIF sy-subrc = 0 AND wa_dt-matnr(2) = 'PM'.
                                ADD 1 TO count_pm.
*                                wa_dt-maktx = |Packaging Material { count_pm }|.
                                wa_dt-maktx = |Packaging Material { wa_dt-matnr+6(4) }|.
                                MODIFY i_dt FROM wa_dt TRANSPORTING maktx.
                              ENDIF.
                            ENDIF.


                            CLEAR: wa_dt.
                          ENDLOOP.
ENDFORM.                    " f_process_data
*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_form.
  IF nast-kschl = 'ZWA2' AND wa_hd-werks = '2100'.
    p_tdform = 'ZGDMMF0002_07'.
  ENDIF.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.
  IF d_frm_subrc IS INITIAL.
    IF NOT nast-anzal IS INITIAL.
      d_output_opt-tdcopies = nast-anzal.
    ENDIF.
*      call the generated function module of the form
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        wa_hd              = wa_hd
      TABLES
        i_dt               = i_dt.
  ENDIF.


ENDFORM.                    " f_print_form
*&---------------------------------------------------------------------*
*&      Form  f_free_memory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
  REFRESH: i_dt, i_lines, i_itab.
  CLEAR: wa_hd, wa_dt, wa_lines, wa_itab,
         i_dt, i_lines, i_itab.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  f_karantina_process
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_karantina_process.
  DATA: l_flag  TYPE i,
        l_mfrpn LIKE mara-mfrpn,
        l_licha LIKE mcha-licha.

  CLEAR: wa_dt.
  LOOP AT i_dt INTO wa_dt.
*    SELECT SINGLE mfrpn
*      FROM mara
*      INTO l_mfrpn
*      WHERE matnr EQ wa_dt-matnr.

    ADD 1 TO l_flag.
    CASE l_flag.
      WHEN 1.
        wa_itab-name1_plant_l  = wa_hd-name1_plant.
        wa_itab-matnr_l        = wa_dt-matnr.
        wa_itab-maktx_l        = wa_dt-maktx.
        wa_itab-charg_l        = wa_dt-charg.
        wa_itab-ebeln_l        = wa_dt-ebeln.
*        wa_itab-tdline_l       = wa_dt-mfrpn.
        IF wa_dt-atwrt IS NOT INITIAL.
          wa_itab-tdline_l       = wa_dt-atwrt.
        ELSE.
          wa_itab-tdline_l       = wa_dt-mfrpn.
        ENDIF.
        wa_itab-mblnr_l        = wa_hd-mblnr.
        wa_itab-name1_vendor_l = wa_dt-licha.
        wa_itab-bldat_l        = wa_hd-bldat.
        wa_itab-meins_l        = wa_dt-meins.
        wa_itab-menge_l        = wa_dt-menge.
        wa_itab-packing_l      = wa_dt-packing.
        wa_itab-sgtxt_l        = wa_dt-sgtxt.
      WHEN 2.
        wa_itab-name1_plant_r  = wa_hd-name1_plant.
        wa_itab-matnr_r        = wa_dt-matnr.
        wa_itab-maktx_r        = wa_dt-maktx.
        wa_itab-charg_r        = wa_dt-charg.
        wa_itab-ebeln_r        = wa_dt-ebeln.
*        wa_itab-tdline_r       = wa_dt-mfrpn.
        IF wa_dt-atwrt IS NOT INITIAL.
          wa_itab-tdline_r       = wa_dt-atwrt.
        ELSE.
          wa_itab-tdline_r       = wa_dt-mfrpn.
        ENDIF.
        wa_itab-mblnr_r        = wa_hd-mblnr.
        wa_itab-name1_vendor_r = wa_dt-licha.
        wa_itab-bldat_r        = wa_hd-bldat.
        wa_itab-meins_r        = wa_dt-meins.
        wa_itab-menge_r        = wa_dt-menge.
        wa_itab-packing_r      = wa_dt-packing.
        wa_itab-sgtxt_r        = wa_dt-sgtxt.
        APPEND wa_itab TO i_itab.
        CLEAR: l_flag, wa_itab.
    ENDCASE.

    AT LAST.
      IF l_flag EQ 1.
        APPEND wa_itab TO i_itab.
        CLEAR: l_flag, wa_itab.
      ENDIF.
    ENDAT.
    CLEAR: wa_dt.
  ENDLOOP.
ENDFORM.                    " f_karantina_process

*&---------------------------------------------------------------------*
*&      Form  f_print_form1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_form1.
  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.
  IF d_frm_subrc IS INITIAL.
    IF NOT nast-anzal IS INITIAL.
      d_output_opt-tdcopies = nast-anzal.
    ENDIF.
* call the generated function module of the form
    LOOP AT i_itab INTO wa_itab.

* One Spool
      AT FIRST.
        d_ctrl_param-no_close = 'X'.
      ENDAT.

* to cater multiple printing
      AT LAST.
        d_ctrl_param-no_close = space.
      ENDAT.

      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          wa_itab            = wa_itab
        TABLES
          i_itab             = i_itab.

* One Spool
      d_ctrl_param-no_open = 'X'.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_print_form1

*&---------------------------------------------------------------------*
*&      Form  f_get_packing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_packing.
  DATA: alloclist       LIKE bapi1003_alloc_list OCCURS 0
                        WITH HEADER LINE,
        return          LIKE bapiret2 OCCURS 0,
        characteristics LIKE bapi_char OCCURS 0
                        WITH HEADER LINE,
        char_values     LIKE bapi_char_values OCCURS 0,
        wa_char_values  LIKE bapi_char_values,
        l_object(50),
        name_char(30),
        descr_char(30),
        unit_char       LIKE bapi_char-unit,
        number_decimals LIKE bapi_char-number_decimals,
        l_cuobj         LIKE inob-cuobj,
        l_atflv         LIKE ausp-atflv,
        l_atflv1(22),
        l_anzgeb(6).

  CLEAR: wa_dt.
  LOOP AT i_dt INTO wa_dt.
    wa_hd-bwart = wa_dt-bwart.
    wa_hd-btext = wa_dt-btext.
    IF wa_dt-werks EQ '2300'.
      IF wa_dt-bwart EQ '315'.
        wa_hd-ref = 'X'.
      ENDIF.
    ENDIF.
    IF wa_dt-qinspst EQ 1.
      l_object = wa_dt-matnr.
      l_object+18 = wa_dt-charg.
      CALL FUNCTION 'BAPI_OBJCL_GETCLASSES'
        EXPORTING
          objectkey_imp   = l_object
          objecttable_imp = 'MCH1'
          classtype_imp   = '023'
        TABLES
          alloclist       = alloclist
          return          = return.

      CALL FUNCTION 'BAPI_CLASS_GET_CHARACTERISTICS'
        EXPORTING
          classnum        = alloclist-classnum
          classtype       = alloclist-classtype
        TABLES
          characteristics = characteristics
          char_values     = char_values.

      IF wa_dt-name_char EQ 'PM_PACKAGING'.
        SELECT SINGLE cuobj
          FROM inob
          INTO l_cuobj
          WHERE klart EQ alloclist-classtype AND
                obtab EQ alloclist-objtyp    AND
                objek EQ alloclist-object.

** Qty UOM per packing
          name_char = 'QTY_CONVERSION'.
          READ TABLE characteristics WITH KEY name_char = name_char.
          IF sy-subrc EQ 0.
            number_decimals = characteristics-number_decimals.
          ELSE.
            number_decimals = 0.
          ENDIF.
          CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
            EXPORTING
              input  = name_char
            IMPORTING
              output = name_char.

          SELECT SINGLE atflv
            FROM ausp
            INTO l_atflv
            WHERE objek EQ l_cuobj AND
                  atinn EQ name_char.

            IF sy-subrc EQ 0.
              CALL FUNCTION 'FLTP_CHAR_CONVERSION'
                EXPORTING
                  input = l_atflv
                  ivalu = 'X'
                  decim = number_decimals
                IMPORTING
                  flstr = l_atflv1.
**
** Transaction UOM
              READ TABLE characteristics INDEX 3.
              IF sy-subrc EQ 0.
                name_char = characteristics-name_char.
              ENDIF.
              CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
                EXPORTING
                  input  = name_char
                IMPORTING
                  output = name_char.

              SELECT SINGLE atwrt
                FROM ausp
                INTO descr_char
                WHERE objek EQ l_cuobj AND
                      atinn EQ name_char.
**

                READ TABLE char_values INTO wa_char_values
                  WITH KEY name_char = wa_dt-name_char.
                IF sy-subrc EQ 0.
                  wa_dt-gebeh = wa_char_values-char_value.
                ENDIF.

                SHIFT l_atflv1 LEFT DELETING LEADING space.
                WRITE wa_dt-anzgeb TO l_anzgeb UNIT wa_dt-erfme.
                SHIFT l_anzgeb LEFT DELETING LEADING space.

                CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
                  EXPORTING
                    input          = wa_dt-erfme
                    language       = sy-langu
                  IMPORTING
                    output         = wa_dt-erfme
                  EXCEPTIONS
                    unit_not_found = 1
                    OTHERS         = 2.
                IF sy-subrc <> 0.
                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                ENDIF.

                CONCATENATE l_anzgeb descr_char '@' l_atflv1 wa_dt-erfme
                                                      INTO wa_dt-packing
                                                      SEPARATED BY space.
                MODIFY i_dt FROM wa_dt TRANSPORTING packing.
              ENDIF.

            ELSE.
              LOOP AT characteristics.
                IF characteristics-department_view EQ 'S'.
                  name_char       = characteristics-name_char.
                  descr_char      = characteristics-descr_char.
                  number_decimals = characteristics-number_decimals.
                  unit_char       = characteristics-unit.

                  SELECT SINGLE cuobj
                    FROM inob
                    INTO l_cuobj
                    WHERE klart EQ alloclist-classtype AND
                          obtab EQ alloclist-objtyp    AND
                          objek EQ alloclist-object.

                    IF sy-subrc EQ 0.
                      CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
                        EXPORTING
                          input  = name_char
                        IMPORTING
                          output = name_char.

                      SELECT SINGLE atflv
                        FROM ausp
                        INTO l_atflv
                        WHERE objek EQ l_cuobj AND
                              atinn EQ name_char.

                        IF sy-subrc EQ 0.
                          CALL FUNCTION 'FLTP_CHAR_CONVERSION'
                            EXPORTING
                              input = l_atflv
                              ivalu = 'X'
                              decim = number_decimals
                            IMPORTING
                              flstr = l_atflv1.

                          READ TABLE char_values INTO wa_char_values
                            WITH KEY name_char = wa_dt-name_char.
                          IF sy-subrc EQ 0.
                            wa_dt-gebeh = wa_char_values-char_value.
                          ENDIF.

                          SHIFT l_atflv1 LEFT DELETING LEADING space.
                          WRITE wa_dt-anzgeb TO l_anzgeb UNIT wa_dt-gebeh.
                          SHIFT l_anzgeb LEFT DELETING LEADING space.

                          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
                            EXPORTING
                              input          = wa_dt-erfme
                              language       = sy-langu
                            IMPORTING
                              output         = wa_dt-erfme
                            EXCEPTIONS
                              unit_not_found = 1
                              OTHERS         = 2.
                          IF sy-subrc <> 0.
                            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                          ENDIF.

                          CONCATENATE l_anzgeb unit_char '@' l_atflv1 descr_char
                             INTO wa_dt-packing
                             SEPARATED BY space.
                          MODIFY i_dt FROM wa_dt TRANSPORTING packing.
                          EXIT.
                        ELSE.
** Qty UOM per packing
                          name_char = 'QTY_CONVERSION'.
                          READ TABLE characteristics WITH KEY name_char = name_char.
                          IF sy-subrc EQ 0.
                            number_decimals = characteristics-number_decimals.
                          ELSE.
                            number_decimals = 0.
                          ENDIF.

                          CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
                            EXPORTING
                              input  = name_char
                            IMPORTING
                              output = name_char.

                          SELECT SINGLE atflv
                            FROM ausp
                            INTO l_atflv
                            WHERE objek EQ l_cuobj AND
                                  atinn EQ name_char.

                            IF sy-subrc EQ 0.
                              CALL FUNCTION 'FLTP_CHAR_CONVERSION'
                                EXPORTING
                                  input = l_atflv
                                  ivalu = 'X'
                                  decim = number_decimals
                                IMPORTING
                                  flstr = l_atflv1.
**

** Transaction UOM
                              READ TABLE characteristics INDEX 3.
                              IF sy-subrc EQ 0.
                                name_char = characteristics-name_char.
                              ENDIF.
                              CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
                                EXPORTING
                                  input  = name_char
                                IMPORTING
                                  output = name_char.

                              SELECT SINGLE atwrt
                                FROM ausp
                                INTO descr_char
                                WHERE objek EQ l_cuobj AND
                                      atinn EQ name_char.
**

                                READ TABLE char_values INTO wa_char_values
                                  WITH KEY name_char = wa_dt-name_char.
                                IF sy-subrc EQ 0.
                                  wa_dt-gebeh = wa_char_values-char_value.
                                ENDIF.

                                SHIFT l_atflv1 LEFT DELETING LEADING space.
                                WRITE wa_dt-anzgeb TO l_anzgeb UNIT wa_dt-erfme.
                                SHIFT l_anzgeb LEFT DELETING LEADING space.

                                CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
                                  EXPORTING
                                    input          = wa_dt-erfme
                                    language       = sy-langu
                                  IMPORTING
                                    output         = wa_dt-erfme
                                  EXCEPTIONS
                                    unit_not_found = 1
                                    OTHERS         = 2.
                                IF sy-subrc <> 0.
                                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                                ENDIF.

                                CONCATENATE l_anzgeb descr_char '@' l_atflv1 wa_dt-erfme
                                                                      INTO wa_dt-packing
                                                                      SEPARATED BY space.
                                MODIFY i_dt FROM wa_dt TRANSPORTING packing.
                              ENDIF.
                            ENDIF.
                          ENDIF.
                        ENDIF.
                      ENDLOOP.
                    ENDIF.
                  ENDIF.
                  CLEAR: wa_dt.
                ENDLOOP.
ENDFORM.                    " f_get_packing

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM2
*&---------------------------------------------------------------------*
FORM f_print_form2 .
  DATA : lt_dt    TYPE ta_hd OCCURS 0,
         ls_dt    LIKE LINE OF lt_dt,
         lt_dtl   TYPE ta_hd OCCURS 0,
         lv_zeile TYPE mseg-zeile.

  lt_dt[] = i_dt[].
  SORT lt_dt BY shkzg DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_dt COMPARING shkzg.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.
  IF d_frm_subrc IS INITIAL.
    LOOP AT lt_dt INTO ls_dt.
      AT FIRST.
        d_ctrl_param-no_close = 'X'.
      ENDAT.

      AT LAST.
        d_ctrl_param-no_close = space.
      ENDAT.

      wa_hd-bwart = ls_dt-bwart.
      wa_hd-btext = ls_dt-btext.

      IF ls_dt-shkzg  = 'H'.
        wa_hd-judul = 'GOODS ISSUE SLIP'.
      ELSE.
        wa_hd-judul = 'GOODS RECEIPT SLIP'.
      ENDIF.

      CLEAR : wa_dt, lt_dtl[], lt_dtl, lv_zeile.
      LOOP AT i_dt INTO wa_dt WHERE shkzg = ls_dt-shkzg.
        ADD 1 TO lv_zeile.
        wa_dt-zeile = lv_zeile.
        APPEND wa_dt TO lt_dtl.
        CLEAR wa_dt.
      ENDLOOP.

      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          wa_hd              = wa_hd
        TABLES
          i_dt               = lt_dtl.

      d_ctrl_param-no_open = 'X'.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PRINT_FORM2
