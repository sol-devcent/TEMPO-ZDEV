*&---------------------------------------------------------------------*
*&  Include           ZTSPMM_E004F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : return    TYPE STANDARD TABLE OF bapiret2,
         groups    TYPE STANDARD TABLE OF bapigroups,
         ls_groups LIKE LINE OF groups.

  SELECT *
    FROM ztspmmdt007
    INTO CORRESPONDING FIELDS OF TABLE gt_007
    WHERE werks = pa_werks.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    TABLES
      return   = return
      groups   = groups.

  IF line_exists( return[ type = 'E' ] ).
    MESSAGE return[ 1 ]-message TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  LOOP AT groups INTO ls_groups.
    IF ls_groups-usergroup = 'PID' OR
       ls_groups-usergroup = 'CEK' OR
      ls_groups-usergroup = 'POST'.
      gv_usergroup  = ls_groups-usergroup.
    ENDIF.
  ENDLOOP.

  IF gv_usergroup = 'CEK'.
    SELECT *
      FROM zmail
      INTO CORRESPONDING FIELDS OF TABLE gt_mail
      WHERE project = 'APV'
        AND werks   = pa_werks.
  ELSE.
    SELECT *
      FROM zmail
      INTO CORRESPONDING FIELDS OF TABLE gt_mail
      WHERE project = 'PID'
        AND werks   = pa_werks.
  ENDIF.

  SELECT SINGLE waers
    FROM t001k JOIN t001 ON t001k~bukrs = t001~bukrs
    INTO gv_waers
    WHERE bwkey = pa_werks.

  gv_mjahr  = sy-datum(4).
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  PERFORM f_modify_screen USING : '' '' '' '' ''.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  IF pa_werks IS INITIAL.
    PERFORM f_error_message USING 'PWE' ''.
  ENDIF.
ENDFORM.                    " F_SELECTION_SCREEN

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
FORM f_error_message  USING    fu_group fu_mess.
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

  IF lv_mess IS NOT INITIAL.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_006    TYPE STANDARD TABLE OF ztspmmdt006,
         lr_bwart  TYPE RANGE OF bwart,
         ls_bwart  LIKE LINE OF lr_bwart,
         lr_bwart1 TYPE RANGE OF bwart.

  CLEAR ls_bwart.
  ls_bwart-low    = '311'.
  ls_bwart-sign   = 'I'.
  ls_bwart-option = 'EQ'.
  APPEND ls_bwart TO lr_bwart.
  CLEAR ls_bwart.
  ls_bwart-low    = '101'.
  ls_bwart-sign   = 'I'.
  ls_bwart-option = 'EQ'.
  APPEND ls_bwart TO lr_bwart.
  CLEAR ls_bwart.
  ls_bwart-low    = '7*'.
  ls_bwart-sign   = 'I'.
  ls_bwart-option = 'CP'.
  APPEND ls_bwart TO lr_bwart.

  CLEAR ls_bwart.
  ls_bwart-low    = '312'.
  ls_bwart-sign   = 'I'.
  ls_bwart-option = 'EQ'.
  APPEND ls_bwart TO lr_bwart1.
  CLEAR ls_bwart.
  ls_bwart-low    = '102'.
  ls_bwart-sign   = 'I'.
  ls_bwart-option = 'EQ'.
  APPEND ls_bwart TO lr_bwart1.


  IF pa_all IS INITIAL.
    SELECT *
      FROM ztspmmdt006
      INTO CORRESPONDING FIELDS OF TABLE gt_006
      WHERE werks = pa_werks
        AND ivnum IN so_ivnum
        AND matnr IN so_matnr
        AND lgort IN so_lgort
        AND qdatu IN so_qdatu
        AND mblnr = space
      ORDER BY PRIMARY KEY.
  ELSE.
    SELECT *
      FROM ztspmmdt006
      INTO CORRESPONDING FIELDS OF TABLE gt_006
      WHERE werks = pa_werks
        AND ivnum IN so_ivnum
        AND matnr IN so_matnr
        AND lgort IN so_lgort
        AND qdatu IN so_qdatu
      ORDER BY PRIMARY KEY.
  ENDIF.

  lt_006[] = gt_006[].
  SORT lt_006 BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_006 COMPARING matnr.
  IF lt_006[] IS NOT INITIAL.
    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FOR ALL ENTRIES IN lt_006
      WHERE matnr = lt_006-matnr
        AND spras = sy-langu.

    SELECT *
      FROM mbew
      INTO CORRESPONDING FIELDS OF TABLE gt_mbew
      FOR ALL ENTRIES IN lt_006
      WHERE matnr = lt_006-matnr
        AND bwkey = pa_werks.
  ENDIF.

  lt_006[] = gt_006[].
  SORT lt_006 BY mblnr mjahr.
  DELETE lt_006 WHERE mblnr = space.
  DELETE ADJACENT DUPLICATES FROM lt_006 COMPARING mblnr mjahr.
  IF lt_006[] IS NOT INITIAL.
    SELECT *
      FROM mkpf
      INTO CORRESPONDING FIELDS OF TABLE gt_mkpf
      FOR ALL ENTRIES IN lt_006
      WHERE mblnr = lt_006-mblnr.
  ENDIF.

  lt_006[] = gt_006[].
  SORT lt_006 BY matnr werks lgort charg.
  DELETE ADJACENT DUPLICATES FROM lt_006 COMPARING matnr werks lgort charg.
  IF lt_006[] IS NOT INITIAL.
    SELECT iblnr gjahr zeili matnr werks lgort charg zldat buchm bstar
      INTO CORRESPONDING FIELDS OF TABLE gt_iseg
      FROM iseg FOR ALL ENTRIES IN lt_006
      WHERE iblnr = lt_006-ivnum
        AND bstar = lt_006-stktyp
      ORDER BY PRIMARY KEY.

    SELECT *
      FROM mchb
      INTO CORRESPONDING FIELDS OF TABLE gt_mchb
      FOR ALL ENTRIES IN lt_006
      WHERE matnr = lt_006-matnr
        AND werks = lt_006-werks
        AND lgort = lt_006-lgort
        AND charg = lt_006-charg.

    SELECT *
      FROM mseg
      INTO CORRESPONDING FIELDS OF TABLE gt_mseg
      FOR ALL ENTRIES IN lt_006
      WHERE matnr = lt_006-matnr
        AND werks = lt_006-werks
        AND lgort = lt_006-lgort
        AND charg = lt_006-charg
        AND bwart IN lr_bwart.
*        AND mjahr = gv_mjahr.

    SELECT *
      FROM mseg
      INTO CORRESPONDING FIELDS OF TABLE gt_mseg312
      FOR ALL ENTRIES IN lt_006
      WHERE matnr = lt_006-matnr
        AND werks = lt_006-werks
        AND lgort = lt_006-lgort
        AND charg = lt_006-charg
        AND bwart IN lr_bwart1.
*        AND mjahr = gv_mjahr.

    IF pa_werks = '0101' OR pa_werks = '0102'.
      DELETE gt_mseg WHERE shkzg NE 'S'
                       AND bwart NE '311'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : lt_x006  TYPE STANDARD TABLE OF ztspmmdt006,
         ls_x006  LIKE LINE OF lt_x006,
         ls_006   LIKE LINE OF gt_006,
         ls_out   LIKE LINE OF gt_out,
         lv_flag,
         lv_diffe TYPE ztspmmdt006-labst,
         ls_007   LIKE LINE OF gt_007,
         ls_makt  LIKE LINE OF gt_makt,
         ls_mbew  LIKE LINE OF gt_mbew,
         ls_mkpf  LIKE LINE OF gt_mkpf,
         ls_mseg  LIKE LINE OF gt_mseg,
         lv_3meng TYPE mseg-menge,
         lv_7meng TYPE mseg-menge,
         ls_iseg  LIKE LINE OF gt_iseg,
         ls_mchb  LIKE LINE OF gt_mchb.

  lt_x006[] = gt_006[].
  SORT lt_x006 BY ivnum.
  DELETE ADJACENT DUPLICATES FROM lt_x006 COMPARING ivnum.

  LOOP AT lt_x006 INTO ls_x006.
    lv_flag = 'X'.
    LOOP AT gt_006 INTO ls_006 WHERE ivnum = ls_x006-ivnum.
      IF gv_usergroup IS INITIAL.
        PERFORM f_style_cell USING '' 'MARK' ''
                             CHANGING ls_out-style.
      ENDIF.
      IF pa_all IS INITIAL.
        IF ls_006-labst = ls_006-menge.
          CONTINUE.
        ENDIF.
      ENDIF.
      MOVE-CORRESPONDING ls_006 TO ls_out.

      CLEAR ls_makt.
      READ TABLE gt_makt INTO ls_makt
                         WITH KEY matnr = ls_006-matnr.
      IF sy-subrc = 0.
        ls_out-maktx    = ls_makt-maktx.
      ENDIF.

      IF ls_out-mblnr IS NOT INITIAL.
        ls_out-icon = icon_led_green.
        PERFORM f_style_cell USING '' 'MARK' ''
                             CHANGING ls_out-style.
      ENDIF.

      IF pa_werks = '0101' OR pa_werks = '0102'.
*        CLEAR ls_mchb.
*        READ TABLE gt_mchb INTO ls_mchb
*                           WITH KEY matnr = ls_006-matnr
*                                    werks = ls_006-werks
*                                    lgort = ls_006-lgort
*                                    charg = ls_006-charg.
        CLEAR ls_iseg.
        READ TABLE gt_iseg INTO ls_iseg WITH KEY iblnr = ls_006-ivnum
                                                 zeili = ls_006-ivpos+1(3)
                                                 bstar = ls_006-stktyp.
        CASE ls_006-stktyp.
          WHEN '1'.
            IF ls_006-labst IS INITIAL.
              ls_006-labst = ls_iseg-buchm.   "ls_mchb-clabs.
            ELSE.
              ls_006-labst = ls_006-labst.
            ENDIF.
          WHEN '2'.
            IF ls_006-cinsm IS INITIAL.
              ls_006-labst = ls_iseg-buchm.   "ls_mchb-cinsm.
            ELSE.
              ls_006-labst = ls_006-cinsm.
            ENDIF.
          WHEN '3'.
            IF ls_006-cspem IS INITIAL.
              ls_006-labst = ls_iseg-buchm.   "ls_mchb-cspem.
            ELSE.
              ls_006-labst = ls_006-cspem.
            ENDIF.
          WHEN '4'.
            IF ls_006-cspem IS INITIAL.
              ls_006-labst = ls_iseg-buchm.   "ls_mchb-cspem.
            ELSE.
              ls_006-labst = ls_006-cspem.
            ENDIF.
        ENDCASE.
      ENDIF.

      CLEAR lv_diffe.
      lv_diffe = ls_006-labst - ls_006-menge - ls_006-notgi.
      IF lv_diffe < 0.
        ls_out-shkzg  = 'H'.
        ls_out-diffp  = abs( lv_diffe ).
      ELSEIF lv_diffe > 0.
        ls_out-shkzg  = 'S'.
        ls_out-diffm  = lv_diffe.
      ELSE.
        PERFORM f_style_cell USING '' 'MARK' ''
                             CHANGING ls_out-style.
      ENDIF.

      CLEAR ls_007.
      READ TABLE gt_007 INTO ls_007
                        WITH KEY werks  = ls_006-werks
                                 pidres = ls_006-pidres.
      IF sy-subrc = 0.
        ls_out-pidtxt = ls_007-pidtxt.
      ENDIF.

      IF ls_006-apnam_prdm IS NOT INITIAL.
        ls_out-apr_prdm = icon_allow.
      ENDIF.
      IF ls_006-rjnam_prdm IS NOT INITIAL.
        ls_out-apr_prdm  = icon_reject.
        ls_out-uname  = ls_006-rjnam_prdm.
        ls_out-datum  = ls_006-rjdat_prdm.
        READ TABLE ls_out-style ASSIGNING FIELD-SYMBOL(<fs_style>)
                                WITH KEY fieldname = 'MARK'.
        IF sy-subrc = 0.
          <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
        ELSE.
          PERFORM f_style_cell2 USING '' 'MARK' ''
                               CHANGING ls_out-style.
        ENDIF.
      ENDIF.

      IF ls_006-apnam IS NOT INITIAL.
        ls_out-appro  = icon_allow.
        ls_out-uname  = ls_006-apnam.
        ls_out-datum  = ls_006-apdat.
      ENDIF.
      IF ls_006-rjnam IS NOT INITIAL.
        ls_out-appro  = icon_reject.
        ls_out-uname  = ls_006-rjnam.
        ls_out-datum  = ls_006-rjdat.
*        PERFORM f_style_cell USING '' 'MARK' ''
*                             CHANGING ls_out-style.
        READ TABLE ls_out-style ASSIGNING <fs_style>
                                WITH KEY fieldname = 'MARK'.
        IF sy-subrc = 0.
          <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
        ELSE.
          PERFORM f_style_cell2 USING '' 'MARK' ''
                               CHANGING ls_out-style.
        ENDIF.
      ENDIF.

      CLEAR ls_mbew.
      READ TABLE gt_mbew INTO ls_mbew
                         WITH KEY matnr = ls_006-matnr.
      IF sy-subrc = 0.
        IF ls_out-diffp IS NOT INITIAL.
          IF ls_mbew-peinh IS NOT INITIAL.
            ls_out-value  = ls_out-diffp * ( ls_mbew-stprs / ls_mbew-peinh ).
          ELSE.
            ls_out-value  = ls_out-diffp * ls_mbew-stprs.
          ENDIF.
        ELSEIF ls_out-diffm IS NOT INITIAL.
          IF ls_mbew-peinh IS NOT INITIAL.
            ls_out-value  = ls_out-diffm * ( ls_mbew-stprs / ls_mbew-peinh ).
          ELSE.
            ls_out-value  = ls_out-diffm * ls_mbew-stprs.
          ENDIF.
        ENDIF.
      ENDIF.

      ls_out-waers  = gv_waers.

      CLEAR ls_mkpf.
      READ TABLE gt_mkpf INTO ls_mkpf
                         WITH KEY mblnr = ls_006-mblnr
                                  mjahr = ls_006-mjahr.
      IF sy-subrc = 0.
        ls_out-budat    = ls_mkpf-budat.
      ENDIF.

      CLEAR ls_mseg.
      READ TABLE gt_mseg INTO ls_mseg
                         WITH KEY mblnr = ls_006-mblnr
                                  mjahr = ls_006-mjahr
                                  matnr = ls_006-matnr
                                  charg = ls_006-charg.
      IF sy-subrc = 0.
        ls_out-zeile  = ls_mseg-zeile.
      ENDIF.

      CLEAR ls_mseg.
      LOOP AT gt_mseg INTO ls_mseg WHERE matnr = ls_006-matnr
                                     AND lgort = ls_006-lgort
                                     AND charg = ls_006-charg.
        CASE ls_mseg-bwart.
          WHEN '311' OR '101'.
            IF ls_mseg-shkzg = 'H'.
              ls_out-3meng = ls_out-3meng - ls_mseg-menge.
            ELSE.
              ADD ls_mseg-menge TO ls_out-3meng.
            ENDIF.
          WHEN OTHERS.
            IF ls_mseg-shkzg = 'H'.
              ls_out-7meng = ls_out-7meng - ls_mseg-menge.
            ELSE.
              ADD ls_mseg-menge TO ls_out-7meng.
            ENDIF.
        ENDCASE.
      ENDLOOP.

      IF ( pa_werks = '0101' OR pa_werks = '0102' ) AND
         ls_006-lgort(1) = '2'.
        CLEAR ls_mseg.
        LOOP AT gt_mseg312 INTO ls_mseg WHERE matnr = ls_006-matnr
                                          AND lgort = ls_006-lgort
                                          AND charg = ls_006-charg.
          CASE ls_mseg-bwart.
            WHEN '312' OR '102'.
              IF ls_mseg-shkzg = 'H'.
                ls_out-3meng = ls_out-3meng - ls_mseg-menge.
              ELSE.
                ADD ls_mseg-menge TO ls_out-3meng.
              ENDIF.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
      ENDIF.

      IF ls_out-diffp IS NOT INITIAL.
        ls_out-7meng  = ls_out-7meng + ls_out-diffp.
      ELSEIF ls_out-diffm IS NOT INITIAL.
        ls_out-7meng  = ls_out-7meng - ls_out-diffm.
      ENDIF.

      TRY .
          ls_out-pmeng  = ls_out-7meng / ls_out-3meng.
        CATCH cx_sy_zerodivide.
      ENDTRY.

      IF pa_werks = '0101' OR pa_werks = '0102'.
        READ TABLE gt_values_tab INTO DATA(ls_values_tab)
                                 WITH KEY domvalue_l = ls_006-stktyp.
        IF sy-subrc = 0.
          ls_out-stktyp = ls_values_tab-ddtext.
        ENDIF.

        CASE ls_006-stktyp.
          WHEN '1'.
            ls_out-labst  = ls_006-labst.
            ls_out-notgi  = ls_006-notgi.
            ls_out-qty311 = ls_out-3meng.
            TRY .
                IF ls_out-diffp IS NOT INITIAL.
                  ls_out-qty311% = ( ls_out-diffp / ls_out-qty311 ) * 100.
                ELSEIF ls_out-diffm IS NOT INITIAL.
                  ls_out-qty311% = ( ls_out-diffm / ls_out-qty311 ) * -100.
                ENDIF.
              CATCH cx_sy_zerodivide.
            ENDTRY.
            IF ls_006-rjnam IS NOT INITIAL.
              PERFORM f_style_cell2 USING '' 'NOTGI' ''
                                    CHANGING ls_out-style.
            ELSEIF gv_usergroup NE 'CEK'.
              PERFORM f_style_cell2 USING '' 'NOTGI' ''
                                    CHANGING ls_out-style.
            ENDIF.
          WHEN '2'.
*            ls_out-labst = ls_006-cinsm.
            ls_out-labst = ls_006-labst.
            ls_out-qty311 = ls_out-3meng.
            TRY .
                IF ls_out-diffp IS NOT INITIAL.
                  ls_out-qty311% = ( ls_out-diffp / ls_out-qty311 ) * 100.
                ELSEIF ls_out-diffm IS NOT INITIAL.
                  ls_out-qty311% = ( ls_out-diffm / ls_out-qty311 ) * -100.
                ENDIF.
              CATCH cx_sy_zerodivide.
            ENDTRY.
            PERFORM f_style_cell2 USING '' 'NOTGI' ''
                                  CHANGING ls_out-style.
          WHEN '3'.
*            ls_out-labst = ls_006-cspem.
            ls_out-labst = ls_006-labst.
            ls_out-qty311 = ls_out-3meng.
            TRY .
                IF ls_out-diffp IS NOT INITIAL.
                  ls_out-qty311% = ( ls_out-diffp / ls_out-qty311 ) * 100.
                ELSEIF ls_out-diffm IS NOT INITIAL.
                  ls_out-qty311% = ( ls_out-diffm / ls_out-qty311 ) * -100.
                ENDIF.
              CATCH cx_sy_zerodivide.
            ENDTRY.
            PERFORM f_style_cell2 USING '' 'NOTGI' ''
                                  CHANGING ls_out-style.
          WHEN OTHERS.
*            ls_out-labst = ls_006-cspem.
            ls_out-labst = ls_006-labst.
            ls_out-qty311 = ls_out-3meng.
            TRY .
                IF ls_out-diffp IS NOT INITIAL.
                  ls_out-qty311% = ( ls_out-diffp / ls_out-qty311 ) * 100.
                ELSEIF ls_out-diffm IS NOT INITIAL.
                  ls_out-qty311% = ( ls_out-diffm / ls_out-qty311 ) * -100.
                ENDIF.
              CATCH cx_sy_zerodivide.
            ENDTRY.
            PERFORM f_style_cell2 USING '' 'NOTGI' ''
                                  CHANGING ls_out-style.
        ENDCASE.

        CASE gv_usergroup.
          WHEN 'CEK'.
            IF ls_out-apr_prdm IS NOT INITIAL OR ls_out-appro IS NOT INITIAL.
              IF ls_out-mblnr IS NOT INITIAL.
                READ TABLE ls_out-style ASSIGNING <fs_style>
                                        WITH KEY fieldname = 'MARK'.
                IF sy-subrc = 0.
                  <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
                ELSE.
                  PERFORM f_style_cell2 USING '' 'MARK' ''
                                       CHANGING ls_out-style.
                ENDIF.
              ELSE.
                READ TABLE ls_out-style ASSIGNING <fs_style>
                                        WITH KEY fieldname = 'MARK'.
                IF sy-subrc = 0.
                  <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
                ELSE.
                  PERFORM f_style_cell2 USING '' 'MARK' ''
                                       CHANGING ls_out-style.
                ENDIF.
              ENDIF.

              READ TABLE ls_out-style ASSIGNING <fs_style>
                                      WITH KEY fieldname = 'NOTGI'.
              IF sy-subrc = 0.
                <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
              ELSE.
                PERFORM f_style_cell2 USING '' 'NOTGI' ''
                                     CHANGING ls_out-style.
              ENDIF.

              READ TABLE ls_out-style ASSIGNING <fs_style>
                                      WITH KEY fieldname = 'PIDRES'.
              IF sy-subrc = 0.
                <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
              ELSE.
                PERFORM f_style_cell2 USING '' 'PIDRES' ''
                                     CHANGING ls_out-style.
              ENDIF.

            ELSE.
              IF ls_out-mblnr IS NOT INITIAL.
                READ TABLE ls_out-style ASSIGNING <fs_style>
                                        WITH KEY fieldname = 'MARK'.
                IF sy-subrc = 0.
                  <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
                ELSE.
                  PERFORM f_style_cell2 USING '' 'MARK' ''
                                       CHANGING ls_out-style.
                ENDIF.
              ELSE.
                IF ls_out-appro IS INITIAL.
                  READ TABLE ls_out-style ASSIGNING <fs_style>
                                          WITH KEY fieldname = 'MARK'.
                  IF sy-subrc = 0.
                    <fs_style>-style = cl_gui_alv_grid=>mc_style_enabled.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

          WHEN 'PID'.
            IF ls_out-mblnr IS NOT INITIAL OR
               ls_out-apr_prdm = icon_reject.
              READ TABLE ls_out-style ASSIGNING <fs_style>
                                      WITH KEY fieldname = 'MARK'.
              IF sy-subrc = 0.
                <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
              ELSE.
                PERFORM f_style_cell2 USING '' 'MARK' ''
                                     CHANGING ls_out-style.
              ENDIF.
            ELSE.
              IF ls_out-apr_prdm IS INITIAL.
                READ TABLE ls_out-style ASSIGNING <fs_style>
                                        WITH KEY fieldname = 'MARK'.
                IF sy-subrc = 0.
                  <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
                ELSE.
                  PERFORM f_style_cell2 USING '' 'MARK' ''
                                       CHANGING ls_out-style.
                ENDIF.
              ELSE.
                IF ls_out-appro IS INITIAL.
                  READ TABLE ls_out-style ASSIGNING <fs_style>
                                          WITH KEY fieldname = 'MARK'.
                  IF sy-subrc = 0.
                    <fs_style>-style = cl_gui_alv_grid=>mc_style_enabled.
                  ENDIF.
                ELSE.
                  READ TABLE ls_out-style ASSIGNING <fs_style>
                                          WITH KEY fieldname = 'MARK'.
                  IF sy-subrc = 0.
                    <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
                  ELSE.
                    PERFORM f_style_cell2 USING '' 'MARK' ''
                                         CHANGING ls_out-style.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

            READ TABLE ls_out-style ASSIGNING <fs_style>
                                    WITH KEY fieldname = 'NOTGI'.
            IF sy-subrc = 0.
              <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
            ELSE.
              PERFORM f_style_cell2 USING '' 'NOTGI' ''
                                   CHANGING ls_out-style.
            ENDIF.

            READ TABLE ls_out-style ASSIGNING <fs_style>
                                    WITH KEY fieldname = 'PIDRES'.
            IF sy-subrc = 0.
              <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
            ELSE.
              PERFORM f_style_cell2 USING '' 'PIDRES' ''
                                   CHANGING ls_out-style.
            ENDIF.

          WHEN 'POST'.
            IF ls_out-mblnr IS NOT INITIAL OR
               ls_out-apr_prdm = icon_reject.
              READ TABLE ls_out-style ASSIGNING <fs_style>
                                      WITH KEY fieldname = 'MARK'.
              IF sy-subrc = 0.
                <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
              ELSE.
                PERFORM f_style_cell2 USING '' 'MARK' ''
                                     CHANGING ls_out-style.
              ENDIF.
            ELSE.
              IF ls_out-appro IS INITIAL.
                READ TABLE ls_out-style ASSIGNING <fs_style>
                                        WITH KEY fieldname = 'MARK'.
                IF sy-subrc = 0.
                  <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
                ELSE.
                  PERFORM f_style_cell2 USING '' 'MARK' ''
                                       CHANGING ls_out-style.
                ENDIF.
              ELSE.
                READ TABLE ls_out-style ASSIGNING <fs_style>
                                        WITH KEY fieldname = 'MARK'.
                IF sy-subrc = 0.
                  <fs_style>-style = cl_gui_alv_grid=>mc_style_enabled.
                ENDIF.
              ENDIF.
            ENDIF.

            READ TABLE ls_out-style ASSIGNING <fs_style>
                                    WITH KEY fieldname = 'NOTGI'.
            IF sy-subrc = 0.
              <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
            ELSE.
              PERFORM f_style_cell2 USING '' 'NOTGI' ''
                                   CHANGING ls_out-style.
            ENDIF.

            READ TABLE ls_out-style ASSIGNING <fs_style>
                                    WITH KEY fieldname = 'PIDRES'.
            IF sy-subrc = 0.
              <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
            ELSE.
              PERFORM f_style_cell2 USING '' 'PIDRES' ''
                                   CHANGING ls_out-style.
            ENDIF.

          WHEN OTHERS.
            READ TABLE ls_out-style ASSIGNING <fs_style>
                                    WITH KEY fieldname = 'PIDRES'.
            IF sy-subrc = 0.
              <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
            ELSE.
              PERFORM f_style_cell2 USING '' 'PIDRES' ''
                                   CHANGING ls_out-style.
            ENDIF.
        ENDCASE.

        IF ls_006-rjnam IS NOT INITIAL.
          READ TABLE ls_out-style ASSIGNING <fs_style>
                                  WITH KEY fieldname = 'MARK'.
          IF sy-subrc = 0.
            <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
          ELSE.
            PERFORM f_style_cell2 USING '' 'MARK' ''
                                 CHANGING ls_out-style.
          ENDIF.

          READ TABLE ls_out-style ASSIGNING <fs_style>
                                  WITH KEY fieldname = 'NOTGI'.
          IF sy-subrc = 0.
            <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
          ELSE.
            PERFORM f_style_cell2 USING '' 'NOTGI' ''
                                 CHANGING ls_out-style.
          ENDIF.

          READ TABLE ls_out-style ASSIGNING <fs_style>
                                  WITH KEY fieldname = 'PIDRES'.
          IF sy-subrc = 0.
            <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
          ELSE.
            PERFORM f_style_cell2 USING '' 'PIDRES' ''
                                 CHANGING ls_out-style.
          ENDIF.
        ENDIF.

        ls_out-total  = ls_006-menge + ls_006-notgi.
      ENDIF.

      APPEND ls_out TO gt_out.
      CLEAR : ls_out, lv_flag.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  IF gt_out[] IS NOT INITIAL.
    CALL SCREEN 101.
  ENDIF.
ENDFORM.                    " F_PRINT_DATA

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
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode  TYPE TABLE OF sy-ucomm,
         dynlog TYPE smp_dyntxt.

  IF gt_bapiret2[] IS INITIAL.
    APPEND '&LOG' TO fcode.
  ENDIF.

  CASE gv_usergroup.
    WHEN 'PID'.
      APPEND '&POS' TO fcode.
    WHEN 'POST'.
      APPEND '&APPROVE' TO fcode.
      APPEND '&REJECT' TO fcode.
    WHEN 'CEK'.
      APPEND '&POS' TO fcode.
    WHEN OTHERS.
      APPEND '&POS' TO fcode.
      APPEND '&APPROVE' TO fcode.
      APPEND '&REJECT' TO fcode.
  ENDCASE.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
  SET TITLEBAR 'TITLE1'.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm TYPE sy-ucomm,
         lv_valid TYPE c,
         lv_lines TYPE i.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&LOG'.
      DESCRIBE TABLE gt_bapiret2 LINES lv_lines.
      IF lv_lines = 1.
        APPEND INITIAL LINE TO gt_bapiret2.
      ENDIF.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_bapiret2.

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

    WHEN '&APPROVE'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_prepare_posting_data USING 'A'.
        PERFORM f_approval_data.
        PERFORM f_send_mail USING 'A'.
      ENDIF.

      PERFORM f_alv_refresh USING 'X'.

    WHEN '&REJECT'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_prepare_posting_data USING 'R'.
        PERFORM f_reject_data.
        PERFORM f_send_mail USING 'R'.
      ENDIF.

      PERFORM f_alv_refresh USING 'X'.

    WHEN '&POS'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_prepare_posting_data USING ''.
        PERFORM f_posting_data.
      ENDIF.

      PERFORM f_alv_refresh USING 'X'.

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

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
                event_receiver->handle_data_changed
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
        it_outtab            = gt_out[]
        it_fieldcatalog      = gt_main_fieldcat[].

* When edit display
    CALL METHOD g_tabgrid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

* Set editable cells to ready for input initially
    CALL METHOD g_tabgrid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.

*  ELSE.
*    CALL METHOD g_tabgrid->refresh_table_display( ).
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
*  gs_layout_alv-totals_bef          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort.

  PERFORM f_alv_sort USING : 1 'IVNUM' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  PERFORM f_dyn_int_table USING :
    'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
    'X' 'X' '' '' '' '',
    'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
    'X' 'X' '' '' '' '',
    'APPRO' '' '' '' '' '' '' '' '' 'Approve/Reject' '' '' '' '' '' ''
    'X' 'X' '' '' '' ''.

  PERFORM f_dyn_int_table USING :
    'WERKS' '' '' '' '' '' '' 'WERKS' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '',
    'IVNUM' '' '' '' '' '' '' 'IVNUM' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '',
    'IVPOS' '' '' '' '' '' '' 'IVPOS' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '',
    'MATNR' '' '' '' '' '' '' 'MATNR' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '',
    'MAKTX' '' '' '' '' '' '' 'MAKTX' 'MAKT' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '',
    'CHARG' '' '' '' '' '' '' 'CHARG' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '',
    'LGORT' '' '' '' '' '' '' 'LGORT' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'QDATU' '' '' '' '' '' '' 'QDATU' 'ZTSPMMDT006' 'Tanggal PID' '' ''
    '' '' '' '' '' '' '' '' '' '',
    'BUDAT' '' '' '' '' '' '' 'BUDAT' 'MKPF' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'MEINS' '' '' '' '' '' '' 'MEINS' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'LABST' '' '' '' '' 'MEINS' '' 'LABST' 'ZTSPMMDT006' '' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'MENGE' '' '' '' '' 'MEINS' '' 'MENGE' 'ZTSPMMDT006' '' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'DIFFM' '' '' '' '' 'MEINS' '' 'MENGE' 'ZTSPMMDT006' 'Qty Kurang' ''
    '' '' '' '' '' '' '' '' '' '' '',
    'DIFFP' '' '' '' '' 'MEINS' '' 'MENGE' 'ZTSPMMDT006' 'Qty Lebih' ''
    '' '' '' '' '' '' '' '' '' '' ''.
  IF gv_usergroup = 'POST'.
    PERFORM f_dyn_int_table USING :
      'WAERS' '' '' '' '' '' '' 'WAERS' 'T001' '' '' '' '' '' '' '' '' ''
      '' '' '' '',
      '3MENG' '' '' '' '' 'MEINS' '' 'MENGE' 'ZTSPMMDT006' 'Qty 311' ''
      '' '' '' '' '' '' '' '' '' '' '',
      '7MENG' '' '' '' '' 'MEINS' '' 'MENGE' 'ZTSPMMDT006' 'Qty 7**' ''
      '' '' '' '' '' '' '' '' '' '' '',
      'PMENG' '' '' '' '' '' '' '' '' 'Persen (%)' '' '' '' '' '' '' ''
      '' '' '' '' '',
      'VALUE' '' '' 'WAERS' '' '' '' 'STPRS' 'MBEW' 'Value' '' '' '' '' ''
      '' '' '' '' '' '' ''.
  ENDIF.
  PERFORM f_dyn_int_table USING :
    'PIDTXT' '' '' '' '' '' '' 'PIDTXT' 'ZTSPMMDT007' '' '' '' '' ''
    '' '' '' '' '' '' '' '',
    'KZNUL' '' '' '' '' '' '' 'KZNUL' 'ZTSPMMDT006' 'ZeroCnt' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'MBLNR' '' '' '' '' '' '' 'MBLNR' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'ZEILE' '' '' '' '' '' '' 'ZEILE' 'MSEG' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'UNAME' '' '' '' '' '' '' '' '' 'Appr/Reject User' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'DATUM' '' '' '' '' '' '' '' '' 'Appr/Reject Date' '' '' '' '' '' ''
    '' '' '' '' '' ''.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE_TSP
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table_tsp .
  PERFORM f_dyn_int_table USING :
    'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
    'X' 'X' '' '' '' '',
    'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
    'X' 'X' '' '' '' '',
    'APR_PRDM' '' '' '' '' '' '' '' '' 'Approve PRDM' '' '' '' '' '' ''
    'X' 'X' '' '' '' '',
    'APPRO' '' '' '' '' '' '' '' '' 'Approve/Reject' '' '' '' '' '' ''
    'X' 'X' '' '' '' ''.

  PERFORM f_dyn_int_table USING :
    'WERKS' '' '' '' '' '' '' 'WERKS' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '',
    'IVNUM' '' '' '' '' '' '' 'IVNUM' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '',
    'IVPOS' '' '' '' '' '' '' 'IVPOS' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '',
    'MATNR' '' '' '' '' '' '' 'MATNR' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '',
    'MAKTX' '' '' '' '' '' '' 'MAKTX' 'MAKT' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '',
    'CHARG' '' '' '' '' '' '' 'CHARG' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    'X' 'X' '' '' '' '',
    'LGORT' '' '' '' '' '' '' 'LGORT' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'QDATU' '' '' '' '' '' '' 'QDATU' 'ZTSPMMDT006' 'Tanggal PID' '' ''
    '' '' '' '' '' '' '' '' '' '',
    'BUDAT' '' '' '' '' '' '' 'BUDAT' 'MKPF' '' '' '' '' '' '' '' '' ''
    '' '' '' '',
    'STKTYP' '' '' '' '' '' '' 'STKTYP' 'ZTSPMMDT006' 'Stock type' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MEINS' '' '' '' '' '' '' 'MEINS' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'LABST' '' '' '' '' 'MEINS' '' 'LABST' 'ZTSPMMDT006' 'Qty SAP' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'MENGE' '' '' '' '' 'MEINS' '' 'MENGE' 'ZTSPMMDT006' 'Qty Fisik' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'NOTGI' '' '' '' '' 'MEINS' '' 'NOTGI' 'ZTSPMMDT006' 'Belum GI' '' '' ''
    'X' '' '' '' '' '' '' '' '',
    'TOTAL' '' '' '' '' 'MEINS' '' 'NOTGI' 'ZTSPMMDT006' 'Qty Total' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'DIFFM' '' '' '' '' 'MEINS' '' 'MENGE' 'ZTSPMMDT006' 'Qty Kurang' ''
    '' '' '' '' '' '' '' '' '' '' '',
    'DIFFP' '' '' '' '' 'MEINS' '' 'MENGE' 'ZTSPMMDT006' 'Qty Lebih' ''
    '' '' '' '' '' '' '' '' '' '' '',
    'QTY311' '' '' '' '' 'MEINS' '' 'QTY311' 'ZTSPMMDT006' 'Penerimaan' ''
    '' '' '' '' '' '' '' '' '' '' '',
    'QTY311%' '' '' '' '' '' '' 'MENGE' 'ZTSPMMDT006' 'Penerimaan%' ''
    '' '' '' '' '' '' '' '' '' '' ''.
  IF gv_usergroup = 'POST'.
    PERFORM f_dyn_int_table USING :
      'WAERS' '' '' '' '' '' '' 'WAERS' 'T001' '' '' '' '' '' '' '' '' ''
      '' '' '' '',
      '3MENG' '' '' '' '' 'MEINS' '' 'MENGE' 'ZTSPMMDT006' 'Qty 311' ''
      '' '' '' '' '' '' '' '' '' '' '',
      '7MENG' '' '' '' '' 'MEINS' '' 'MENGE' 'ZTSPMMDT006' 'Qty 7**' ''
      '' '' '' '' '' '' '' '' '' '' '',
      'PMENG' '' '' '' '' '' '' '' '' 'Persen (%)' '' '' '' '' '' '' ''
      '' '' '' '' '',
      'VALUE' '' '' 'WAERS' '' '' '' 'STPRS' 'MBEW' 'Value' '' '' '' '' ''
      '' '' '' '' '' '' ''.
  ENDIF.
  PERFORM f_dyn_int_table USING :
    'PIDRES' '' '' '' '' '' '' 'PIDRES' 'ZTSPMMDT006' '' '' '' '' 'X'
    '' '' '' '' '' '' '' 'X',
    'PIDTXT' '' '' '' '' '' '' 'PIDTXT' 'ZTSPMMDT007' '' '' '' '' ''
    '' '' '' '' '' '' '' '',
    'KZNUL' '' '' '' '' '' '' 'KZNUL' 'ZTSPMMDT006' 'ZeroCnt' '' '' ''
    '' '' '' '' '' '' '' '' '',
    'MBLNR' '' '' '' '' '' '' 'MBLNR' 'ZTSPMMDT006' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'ZEILE' '' '' '' '' '' '' 'ZEILE' 'MSEG' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'UNAME' '' '' '' '' '' '' '' '' 'Appr/Reject User' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'DATUM' '' '' '' '' '' '' '' '' 'Appr/Reject Date' '' '' '' '' '' ''
    '' '' '' '' '' ''.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE_TSP

*&---------------------------------------------------------------------*
*&      Form  F_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_int_table  USING    fu_fieldname fu_tabname
                               fu_currency fu_cfieldname fu_quantity
                               fu_qfieldname fu_checkbox fu_ref_field
                               fu_ref_table fu_coltext fu_outputlen
                               fu_inttype fu_no_out fu_edit fu_tech
                               fu_just fu_key fu_fix fu_icon fu_sum
                               fu_nosum fu_f4availabl.
  DATA : ls_dyn_fcat       TYPE lvc_s_fcat.

  PERFORM f_isi_judul USING fu_coltext '' '' ''
                      CHANGING ls_dyn_fcat-reptext ls_dyn_fcat-scrtext_l
                               ls_dyn_fcat-scrtext_m
ls_dyn_fcat-scrtext_s.

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
  ls_dyn_fcat-f4availabl  = fu_f4availabl.
  APPEND ls_dyn_fcat TO gt_main_fieldcat.
  CLEAR ls_dyn_fcat.
ENDFORM.                    " F_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_ISI_JUDUL
*&---------------------------------------------------------------------*
FORM f_isi_judul  USING    fu_coltext fu_l fu_m fu_s
                  CHANGING fc_reptext fc_scrtext_l fc_scrtext_m
fc_scrtext_s.

  fc_reptext    = fu_coltext.
  fc_scrtext_l  = fu_coltext.
  fc_scrtext_m  = fu_coltext.
  fc_scrtext_s  = fu_coltext.
ENDFORM.                    " F_ISI_JUDUL

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
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check.
  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
  DATA : lv_style    TYPE lvc_s_styl-style,
         lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  DATA : ls_out             LIKE LINE OF gt_out.

  CALL METHOD g_tabgrid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT gt_out INTO ls_out.
        READ TABLE ls_out-style INTO ls_stylerow
                                WITH KEY fieldname = 'MARK'.
        IF sy-subrc = 0 AND
            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          CONTINUE.
        ENDIF.
        ls_out-mark = fu_check.
        MODIFY gt_out FROM ls_out.
        CLEAR ls_out.
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
*&      Form  F_STYLE_CELL2
*&---------------------------------------------------------------------*
FORM f_style_cell2  USING    fu_flag fu_fieldname fu_fieldname1
                    CHANGING fc_celltab  TYPE lvc_t_styl.
  DATA : lt_celltab   TYPE lvc_t_styl WITH HEADER LINE.

  CLEAR : lt_celltab[], lt_celltab.

  IF fu_flag IS NOT INITIAL.
    lt_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
  ELSE.
    lt_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.

*  CLEAR fc_celltab[].

  lt_celltab-fieldname = fu_fieldname.
  APPEND lt_celltab.

  INSERT LINES OF lt_celltab INTO TABLE fc_celltab.
ENDFORM.                    " F_STYLE_CELL2

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_posting_data  USING    fu_flag.
  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout,
         ls_out  LIKE LINE OF gt_out,
         ls_post LIKE LINE OF gt_post,
         ls_appr LIKE LINE OF gt_appr,
         ls_rjct LIKE LINE OF gt_rjct.

  CLEAR : gt_post[], gt_bapiret2[], gt_appr, gt_rjct[].

  lt_xout[]   = gt_out[].
  DELETE lt_xout WHERE mark = space.

  CASE fu_flag.
    WHEN 'A'.
      LOOP AT lt_xout INTO ls_xout.
        MOVE-CORRESPONDING ls_xout TO ls_appr.
        APPEND ls_appr TO gt_appr.
      ENDLOOP.

    WHEN 'R'.
      LOOP AT lt_xout INTO ls_xout.
        MOVE-CORRESPONDING ls_xout TO ls_rjct.
        APPEND ls_rjct TO gt_rjct.
      ENDLOOP.

    WHEN OTHERS.
      LOOP AT lt_xout INTO ls_xout.
        IF ls_xout-appro IS NOT INITIAL.
          MOVE-CORRESPONDING ls_xout TO ls_post.
          APPEND ls_post TO gt_post.
        ELSE.
          MOVE-CORRESPONDING ls_xout TO ls_appr.
          APPEND ls_appr TO gt_appr.
        ENDIF.
      ENDLOOP.
  ENDCASE.

  CLEAR ls_out.
  LOOP AT gt_out INTO ls_out WHERE mark = 'X'.
    CLEAR ls_out-style[].
    CASE fu_flag.
      WHEN 'A'.
        IF gv_usergroup = 'CEK'.
          ls_out-apr_prdm = icon_allow.
          READ TABLE ls_out-style ASSIGNING FIELD-SYMBOL(<fs_style>)
                                  WITH KEY fieldname = 'MARK'.
          IF sy-subrc = 0.
            <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
          ELSE.
            PERFORM f_style_cell2 USING '' 'MARK' ''
                                  CHANGING ls_out-style.
            PERFORM f_style_cell2 USING '' 'NOTGI' ''
                                  CHANGING ls_out-style.
            PERFORM f_style_cell2 USING '' 'PIDRES' ''
                                  CHANGING ls_out-style.
          ENDIF.
        ELSE.
          ls_out-appro  = icon_allow.
          READ TABLE ls_out-style ASSIGNING <fs_style>
                                  WITH KEY fieldname = 'NOTGI'.
          IF sy-subrc = 0.
            <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
          ELSE.
            PERFORM f_style_cell2 USING '' 'NOTGI' ''
                                  CHANGING ls_out-style.
          ENDIF.
          READ TABLE ls_out-style ASSIGNING <fs_style>
                                  WITH KEY fieldname = 'PIDRES'.
          IF sy-subrc = 0.
            <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
          ELSE.
            PERFORM f_style_cell2 USING '' 'PIDRES' ''
                                  CHANGING ls_out-style.
          ENDIF.
        ENDIF.

      WHEN 'R'.
        IF gv_usergroup = 'CEK'.
          ls_out-apr_prdm = icon_reject.
          READ TABLE ls_out-style ASSIGNING <fs_style>
                                  WITH KEY fieldname = 'MARK'.
          IF sy-subrc = 0.
            <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
          ELSE.
            PERFORM f_style_cell2 USING '' 'MARK' ''
                                  CHANGING ls_out-style.
          ENDIF.
          READ TABLE ls_out-style ASSIGNING <fs_style>
                                  WITH KEY fieldname = 'NOTGI'.
          IF sy-subrc = 0.
            <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
          ELSE.
            PERFORM f_style_cell2 USING '' 'NOTGI' ''
                                  CHANGING ls_out-style.
          ENDIF.
          READ TABLE ls_out-style ASSIGNING <fs_style>
                                  WITH KEY fieldname = 'PIDRES'.
          IF sy-subrc = 0.
            <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
          ELSE.
            PERFORM f_style_cell2 USING '' 'PIDRES' ''
                                  CHANGING ls_out-style.
          ENDIF.
        ELSE.
          ls_out-appro  = icon_reject.
          READ TABLE ls_out-style ASSIGNING <fs_style>
                                  WITH KEY fieldname = 'NOTGI'.
          IF sy-subrc = 0.
            <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
          ELSE.
            PERFORM f_style_cell2 USING '' 'NOTGI' ''
                                  CHANGING ls_out-style.
          ENDIF.
          READ TABLE ls_out-style ASSIGNING <fs_style>
                                  WITH KEY fieldname = 'PIDRES'.
          IF sy-subrc = 0.
            <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
          ELSE.
            PERFORM f_style_cell2 USING '' 'PIDRES' ''
                                  CHANGING ls_out-style.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
        READ TABLE gt_appr INTO ls_appr
                           WITH KEY ivnum = ls_out-ivnum
                                    ivpos = ls_out-ivpos.
        IF sy-subrc = 0.
          ls_out-icon = icon_led_red.
          PERFORM f_write_error USING 'E' 'ZAB' '000'
                                      ls_out-ivnum 'has not been approved'
                                      '' ''.
        ELSE.
          READ TABLE ls_out-style ASSIGNING <fs_style>
                                  WITH KEY fieldname = 'NOTGI'.
          IF sy-subrc = 0.
            <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
          ELSE.
            PERFORM f_style_cell2 USING '' 'NOTGI' ''
                                  CHANGING ls_out-style.
          ENDIF.
          READ TABLE ls_out-style ASSIGNING <fs_style>
                                  WITH KEY fieldname = 'PIDRES'.
          IF sy-subrc = 0.
            <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
          ELSE.
            PERFORM f_style_cell2 USING '' 'PIDRES' ''
                                  CHANGING ls_out-style.
          ENDIF.
        ENDIF.
    ENDCASE.
    CLEAR ls_out-mark.
    MODIFY gt_out FROM ls_out TRANSPORTING mark icon apr_prdm appro style.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA : goodsmvt_header  TYPE bapi2017_gm_head_01,
         goodsmvt_code    TYPE bapi2017_gm_code,
         goodsmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
         materialdocument TYPE bapi2017_gm_head_ret-mat_doc,
         matdocumentyear  TYPE bapi2017_gm_head_ret-doc_year,
         return           TYPE STANDARD TABLE OF bapiret2,
         ls_return        LIKE LINE OF return,
         ls_item          LIKE LINE OF goodsmvt_item,
         lv_budat         TYPE mkpf-budat,
         lv_bldat         TYPE mkpf-bldat.

  DATA : lt_xpost TYPE STANDARD TABLE OF ty_out,
         ls_xpost LIKE LINE OF lt_xpost,
         ls_post  LIKE LINE OF gt_post,
         lv_subrc TYPE sy-subrc.

  CALL SELECTION-SCREEN 200 STARTING AT 10 10.

  PERFORM f_postdiff.

  lt_xpost[]  = gt_post[].
  DELETE lt_xpost WHERE doctyp = '06'.

  IF lt_xpost[] IS NOT INITIAL.

    SORT lt_xpost BY ivnum.
    DELETE ADJACENT DUPLICATES FROM lt_xpost COMPARING ivnum.

*    CALL SELECTION-SCREEN 200 STARTING AT 10 10.

    IF pa_budat IS INITIAL.
      lv_budat  = sy-datum.
    ELSE.
      lv_budat  = pa_budat.
    ENDIF.

    IF pa_bldat IS INITIAL.
      lv_bldat  = sy-datum.
    ELSE.
      lv_bldat  = pa_bldat.
    ENDIF.

    LOOP AT lt_xpost INTO ls_xpost.
      IF ls_xpost-icon = icon_led_red.
        PERFORM f_write_error USING 'E' 'ZAB' '000'
                                    ls_xpost-ivnum 'error data' '' ''.
      ELSE.
        goodsmvt_code = '06'.

        goodsmvt_header-doc_date   = lv_bldat.
        goodsmvt_header-pstng_date = lv_budat.
        goodsmvt_header-ref_doc_no = ls_xpost-ivnum.

        CLEAR : goodsmvt_item[].
        LOOP AT gt_post INTO ls_post WHERE ivnum = ls_xpost-ivnum
                                       AND icon  <> icon_led_red
                                       AND appro = icon_allow.
          CLEAR : ls_item.

          IF pa_werks = '0101' OR pa_werks = '0102'.
            CASE ls_post-stktyp.
              WHEN 'QI'.
                IF ls_post-diffm IS NOT INITIAL.
                  ls_item-move_type        = '704'.
                ELSEIF ls_post-diffp IS NOT INITIAL.
                  ls_item-move_type        = '703'.
                ENDIF.
              WHEN 'UU'.
                IF ls_post-diffm IS NOT INITIAL.
                  ls_item-move_type        = '702'.
                ELSEIF ls_post-diffp IS NOT INITIAL.
                  ls_item-move_type        = '701'.
                ENDIF.
              WHEN 'BLOCKED'.
                IF ls_post-diffm IS NOT INITIAL.
                  ls_item-move_type        = '708'.
                ELSEIF ls_post-diffp IS NOT INITIAL.
                  ls_item-move_type        = '707'.
                ENDIF.
            ENDCASE.
          ELSE.
            IF ls_post-diffm IS NOT INITIAL.
              ls_item-move_type        = '702'.
            ELSEIF ls_post-diffp IS NOT INITIAL.
              ls_item-move_type        = '701'.
            ENDIF.
          ENDIF.

          IF ls_post-diffm IS NOT INITIAL.
            ls_item-entry_qnt        = ls_post-diffm.
          ELSEIF ls_post-diffp IS NOT INITIAL.
            ls_item-entry_qnt        = ls_post-diffp.
          ENDIF.

          ls_item-material         = ls_post-matnr.
          ls_item-plant            = ls_post-werks.
          ls_item-stge_loc         = ls_post-lgort.
          ls_item-batch            = ls_post-charg.
          ls_item-item_text        = ls_post-pidtxt.

          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
            EXPORTING
              input          = ls_post-meins
            IMPORTING
              output         = ls_item-entry_uom
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.

          APPEND ls_item TO goodsmvt_item.
          CLEAR ls_item.
        ENDLOOP.

        CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
          EXPORTING
            goodsmvt_header  = goodsmvt_header
            goodsmvt_code    = goodsmvt_code
          IMPORTING
            materialdocument = materialdocument
            matdocumentyear  = matdocumentyear
          TABLES
            goodsmvt_item    = goodsmvt_item
            return           = return.

        CLEAR : ls_return, lv_subrc.
        READ TABLE return INTO ls_return
                          WITH KEY type = 'E'.
        IF sy-subrc = 0.
          lv_subrc = 4.
          LOOP AT return INTO ls_return.
            APPEND ls_return TO gt_bapiret2.
            CLEAR ls_return.
          ENDLOOP.
        ENDIF.

        IF lv_subrc IS INITIAL.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ENDIF.

        PERFORM f_modify_data USING materialdocument matdocumentyear
                                    ls_xpost-ivnum.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATA
*&---------------------------------------------------------------------*
FORM f_modify_data  USING    fu_mblnr fu_mjahr fu_ivnum.
  DATA : ls_post    LIKE LINE OF gt_post,
         lv_icon(4).

  IF fu_mblnr IS NOT INITIAL.
    lv_icon = icon_led_green.
  ELSE.
    lv_icon = icon_led_red.
  ENDIF.

  LOOP AT gt_post INTO ls_post WHERE ivnum = fu_ivnum.
    IF lv_icon = icon_led_green.
      PERFORM f_style_cell USING '' 'MARK' ''
                       CHANGING ls_post-style.
    ENDIF.

    READ TABLE ls_post-style ASSIGNING FIELD-SYMBOL(<fs_style>)
                            WITH KEY fieldname = 'NOTGI'.
    IF sy-subrc = 0.
      <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
    ELSE.
      PERFORM f_style_cell2 USING '' 'NOTGI' '' CHANGING ls_post-style.
    ENDIF.
    READ TABLE ls_post-style ASSIGNING <fs_style> WITH KEY fieldname = 'PIDRES'.
    IF sy-subrc = 0.
      <fs_style>-style = cl_gui_alv_grid=>mc_style_disabled.
    ELSE.
      PERFORM f_style_cell2 USING '' 'PIDRES' '' CHANGING ls_post-style.
    ENDIF.

    ls_post-mblnr = fu_mblnr.
    ls_post-mjahr = fu_mjahr.
    ls_post-icon  = lv_icon.

    MODIFY gt_out FROM ls_post
                  TRANSPORTING style icon mblnr mjahr style
                  WHERE ivnum = ls_post-ivnum
                    AND ivpos = ls_post-ivpos.

*    TRY .
    UPDATE ztspmmdt006 SET mblnr = fu_mblnr
                           mjahr = fu_mjahr
                       WHERE werks  = ls_post-werks
                         AND lgort  = ls_post-lgort
                         AND ivnum  = ls_post-ivnum
                         AND ivpos  = ls_post-ivpos.
*      CATCH cx_sy_open_sql_db.
*    ENDTRY.
    CLEAR ls_post.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_APPROVAL_DATA
*&---------------------------------------------------------------------*
FORM f_approval_data .
  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout,
         ls_out  LIKE LINE OF gt_out,
         ls_pid  LIKE LINE OF gt_pid.

  IF gv_usergroup = 'CEK'.
    lt_xout[] = gt_out[].
    DELETE lt_xout WHERE apr_prdm IS INITIAL.
    LOOP AT lt_xout INTO ls_xout.
      TRY .
          UPDATE ztspmmdt006 SET pidres     = ls_xout-pidres
                                 notgi      = ls_xout-notgi

                                 apdat_prdm = sy-datum
                                 apzet_prdm = sy-uzeit
                                 apnam_prdm = sy-uname
                             WHERE werks  = ls_xout-werks
                               AND lgort  = ls_xout-lgort
                               AND ivnum  = ls_xout-ivnum
                               AND ivpos  = ls_xout-ivpos.
        CATCH cx_sy_open_sql_db.
      ENDTRY.
      ls_pid-ivnum  = ls_xout-ivnum.
      APPEND ls_pid TO gt_pid.
      CLEAR : ls_xout, ls_pid.
    ENDLOOP.

    SORT gt_pid BY ivnum.
    DELETE ADJACENT DUPLICATES FROM gt_pid COMPARING ivnum.
  ELSE.
    lt_xout[] = gt_out[].
    DELETE lt_xout WHERE appro IS INITIAL.
    DELETE lt_xout WHERE appro = icon_reject.
    LOOP AT lt_xout INTO ls_xout.
      TRY .
          UPDATE ztspmmdt006 SET pidres     = ls_xout-pidres
                                 notgi      = ls_xout-notgi
                                 apdat      = sy-datum
                                 apzet      = sy-uzeit
                                 apnam      = sy-uname
                             WHERE werks  = ls_xout-werks
                               AND lgort  = ls_xout-lgort
                               AND ivnum  = ls_xout-ivnum
                               AND ivpos  = ls_xout-ivpos.
        CATCH cx_sy_open_sql_db.
      ENDTRY.
      ls_pid-ivnum  = ls_xout-ivnum.
      APPEND ls_pid TO gt_pid.
      CLEAR : ls_xout, ls_pid.
    ENDLOOP.

    SORT gt_pid BY ivnum.
    DELETE ADJACENT DUPLICATES FROM gt_pid COMPARING ivnum.
  ENDIF.
ENDFORM.                    " F_APPROVAL_DATA

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_ERROR
*&---------------------------------------------------------------------*
FORM f_write_error  USING    fu_type fu_id fu_number
                             fu_mess1 fu_mess2 fu_mess3 fu_mess4.
  DATA : ls_error   TYPE bapiret2.

  ls_error-type         = fu_type.
  ls_error-id           = fu_id.
  ls_error-number       = fu_number.
  ls_error-message_v1   = fu_mess1.
  ls_error-message_v2   = fu_mess2.
  ls_error-message_v3   = fu_mess3.
  ls_error-message_v4   = fu_mess4.
  APPEND ls_error TO gt_bapiret2.
ENDFORM.                    " F_WRITE_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_SEND_MAIL
*&---------------------------------------------------------------------*
FORM f_send_mail USING fu_flag.
  DATA : lo_mime_helper  TYPE REF TO cl_gbt_multirelated_service,
         lt_soli         TYPE TABLE OF soli,
         ls_soli         TYPE soli,
         lo_doc_bcs      TYPE REF TO cl_document_bcs,
         lo_bcs          TYPE REF TO cl_bcs,
         ls_mail         LIKE LINE OF gt_mail,
         lo_recipient    TYPE REF TO if_recipient_bcs,
         lv_status       TYPE bcs_rqst,
         lv_subject(50),
         lw_document_bcs TYPE REF TO cx_document_bcs.

  IF gt_pid[] IS NOT INITIAL.
    lv_subject = 'PID Sub Warehouse'.

    CLEAR lt_soli[].
    PERFORM f_create_email_body TABLES lt_soli
                                USING  fu_flag.

    CREATE OBJECT lo_mime_helper.

    CALL METHOD lo_mime_helper->set_main_html
      EXPORTING
        content = lt_soli.

    lo_doc_bcs = cl_document_bcs=>create_from_multirelated(
                    i_subject          = lv_subject
                    i_importance       = '9'
                    i_multirel_service = lo_mime_helper ).

    lo_bcs = cl_bcs=>create_persistent( ).

    lo_bcs->set_document( i_document = lo_doc_bcs ).

* Set the email address
    LOOP AT gt_mail INTO ls_mail.
      IF ls_mail-zto IS NOT INITIAL.
        CLEAR lo_recipient.
        lo_recipient = cl_cam_address_bcs=>create_internet_address(
                          i_address_string = ls_mail-email ).
        lo_bcs->add_recipient( i_recipient = lo_recipient ).
      ENDIF.

      IF ls_mail-cc IS NOT INITIAL.
        CLEAR lo_recipient.
        lo_recipient = cl_cam_address_bcs=>create_internet_address(
                      i_address_string = ls_mail-email ).
        lo_bcs->add_recipient( i_recipient = lo_recipient
                               i_copy      = 'X').
      ENDIF.
    ENDLOOP.

    lv_status = 'N'.
    CALL METHOD lo_bcs->set_status_attributes
      EXPORTING
        i_requested_status = lv_status.
    TRY.
        lo_bcs->send( ).
        COMMIT WORK.
      CATCH cx_bcs.
        ROLLBACK WORK.
    ENDTRY.
  ENDIF.
ENDFORM.                    " F_SEND_MAIL

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_EMAIL_BODY
*&---------------------------------------------------------------------*
FORM f_create_email_body  TABLES   ft_soli STRUCTURE soli
                          USING    fu_flag.
  DATA : ls_soli TYPE soli,
         ls_pid  LIKE LINE OF gt_pid.

  CASE fu_flag.
    WHEN 'A'.
      gt_pid[] = gt_appr[].
      PERFORM f_create_merge USING 'ZPID_BODY' ''.
      PERFORM f_create_merge USING 'ZPID_IVNUM' ''.
      PERFORM f_create_merge USING 'ZPID_FOOTER' ''.
    WHEN 'R'.
      gt_pid[] = gt_rjct[].
      PERFORM f_create_merge USING 'ZPID_RBODY' ''.
      PERFORM f_create_merge USING 'ZPID_IVNUM' ''.
      PERFORM f_create_merge USING 'ZPID_RFOOTER' ''.
  ENDCASE.

  LOOP AT gt_body INTO ls_soli.
    APPEND ls_soli TO ft_soli.
    CLEAR ls_soli.
  ENDLOOP.
  LOOP AT gt_html INTO ls_soli.
    APPEND ls_soli TO ft_soli.
    CLEAR ls_soli.
  ENDLOOP.
  LOOP AT gt_foot INTO ls_soli.
    APPEND ls_soli TO ft_soli.
    CLEAR ls_soli.
  ENDLOOP.
ENDFORM.                    " F_CREATE_EMAIL_BODY

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_MERGE
*&---------------------------------------------------------------------*
FORM f_create_merge  USING    fu_template fu_itab.
  TYPES : BEGIN OF ty_xpid,
            werks       TYPE ztspmmdt006-werks,
            lgort       TYPE ztspmmdt006-lgort,
            ivnum       TYPE ztspmmdt006-ivnum,
            qdatu       TYPE ztspmmdt006-qdatu,
            ivpos       TYPE ztspmmdt006-ivpos,
            matnr       TYPE ztspmmdt006-matnr,
            maktx       TYPE makt-maktx,
            charg       TYPE ztspmmdt006-charg,
            meins       TYPE ztspmmdt006-meins,
            labst(20),
            menge(20),
            lebih(20),
            kurang(20),
            pidtxt(100),
          END OF ty_xpid.

  DATA : ls_pid    LIKE LINE OF gt_pid,
         lt_xpid   TYPE STANDARD TABLE OF ty_xpid,
         ls_xpid   LIKE LINE OF lt_xpid,
         lt_fields TYPE STANDARD TABLE OF w3fields WITH HEADER LINE,
         lt_header TYPE STANDARD TABLE OF w3head WITH HEADER LINE,
         lt_fcat   TYPE lvc_t_fcat,
         ls_fcat   TYPE lvc_s_fcat,
         w_head    TYPE w3head.

  CASE fu_template.
    WHEN 'ZPID_BODY'.
      CALL FUNCTION 'WWW_HTML_MERGER'
        EXPORTING
          template    = fu_template
        IMPORTING
          html_table  = gt_body[]
        CHANGING
          merge_table = gt_bmerge[].

    WHEN 'ZPID_RBODY'.
      CALL FUNCTION 'WWW_HTML_MERGER'
        EXPORTING
          template    = fu_template
        IMPORTING
          html_table  = gt_body[]
        CHANGING
          merge_table = gt_bmerge[].

    WHEN 'ZPID_IVNUM'.
      ls_fcat-coltext = 'Plant'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'SLoc.'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'No. PID'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Tanggal PID'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Item'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Material'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Description'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Batch'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Uom'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Quantity'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Counted Qty'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Qty Lebih'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Qty Kurang'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Reason'.
      APPEND ls_fcat TO lt_fcat.

      LOOP AT lt_fcat INTO ls_fcat.
        w_head-text = ls_fcat-coltext.

        CALL FUNCTION 'WWW_ITAB_TO_HTML_HEADERS'
          EXPORTING
            field_nr = sy-tabix
            text     = w_head-text
            fgcolor  = 'black'
            bgcolor  = 'green'
          TABLES
            header   = lt_header.

        CALL FUNCTION 'WWW_ITAB_TO_HTML_LAYOUT'
          EXPORTING
            field_nr = sy-tabix
            fgcolor  = 'black'
            size     = '3'
          TABLES
            fields   = lt_fields.
      ENDLOOP.

      LOOP AT gt_pid INTO ls_pid.
        ls_xpid-werks = ls_pid-werks.
        ls_xpid-lgort = ls_pid-lgort.
        ls_xpid-ivnum = ls_pid-ivnum.
        ls_xpid-qdatu = ls_pid-qdatu.
        ls_xpid-ivpos = ls_pid-ivpos.
        ls_xpid-matnr = ls_pid-matnr.
        ls_xpid-maktx = ls_pid-maktx.
        ls_xpid-charg = ls_pid-charg.
        PERFORM f_conversion_meins USING ls_pid-meins
                                   CHANGING ls_xpid-meins.
        PERFORM f_unit_conversion USING ls_pid-meins ls_pid-labst
                                  CHANGING ls_xpid-labst.
        PERFORM f_unit_conversion USING ls_pid-meins ls_pid-menge
                                  CHANGING ls_xpid-menge.
        PERFORM f_unit_conversion USING ls_pid-meins ls_pid-diffm
                                  CHANGING ls_xpid-kurang.
        PERFORM f_unit_conversion USING ls_pid-meins ls_pid-diffp
                                  CHANGING ls_xpid-lebih.
        ls_xpid-pidtxt  = ls_pid-pidtxt.

        APPEND ls_xpid TO lt_xpid.
        CLEAR ls_xpid.
      ENDLOOP.

      CLEAR gt_html[].
      CALL FUNCTION 'WWW_ITAB_TO_HTML'
        TABLES
          html       = gt_html
          fields     = lt_fields
          row_header = lt_header
          itable     = lt_xpid.

*      CALL FUNCTION 'WWW_HTML_MERGER'
*        EXPORTING
*          template    = fu_template
*        IMPORTING
*          html_table  = gt_table[]
*        CHANGING
*          merge_table = gt_tmerge[].

    WHEN 'ZPID_FOOTER'.
      CALL FUNCTION 'WWW_HTML_MERGER'
        EXPORTING
          template    = fu_template
        IMPORTING
          html_table  = gt_foot[]
        CHANGING
          merge_table = gt_fmerge[].

    WHEN 'ZPID_RFOOTER'.
      CALL FUNCTION 'WWW_HTML_MERGER'
        EXPORTING
          template    = fu_template
        IMPORTING
          html_table  = gt_foot[]
        CHANGING
          merge_table = gt_fmerge[].
  ENDCASE.
ENDFORM.                    " F_CREATE_MERGE

*&---------------------------------------------------------------------*
*&      Form  F_REJECT_DATA
*&---------------------------------------------------------------------*
FORM f_reject_data .
  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout,
         ls_out  LIKE LINE OF gt_out,
         ls_pid  LIKE LINE OF gt_pid.

  IF gv_usergroup = 'CEK'.
    lt_xout[] = gt_out[].
    DELETE lt_xout WHERE apr_prdm IS INITIAL.
    DELETE lt_xout WHERE apr_prdm = icon_allow.
    LOOP AT lt_xout INTO ls_xout.
      TRY .
          UPDATE ztspmmdt006 SET rjdat_prdm = sy-datum
                                 rjzet_prdm = sy-uzeit
                                 rjnam_prdm = sy-uname
                             WHERE werks  = ls_xout-werks
                               AND lgort  = ls_xout-lgort
                               AND ivnum  = ls_xout-ivnum
                               AND ivpos  = ls_xout-ivpos.
        CATCH cx_sy_open_sql_db.
      ENDTRY.
      ls_pid-ivnum  = ls_xout-ivnum.
      APPEND ls_pid TO gt_pid.
      CLEAR : ls_xout, ls_pid.
    ENDLOOP.

  ELSE.
    lt_xout[] = gt_out[].
    DELETE lt_xout WHERE appro IS INITIAL.
    DELETE lt_xout WHERE appro = icon_allow.
    LOOP AT lt_xout INTO ls_xout.
      TRY .
          UPDATE ztspmmdt006 SET rjdat = sy-datum
                                 rjzet = sy-uzeit
                                 rjnam = sy-uname
                             WHERE werks  = ls_xout-werks
                               AND lgort  = ls_xout-lgort
                               AND ivnum  = ls_xout-ivnum
                               AND ivpos  = ls_xout-ivpos.
        CATCH cx_sy_open_sql_db.
      ENDTRY.
      ls_pid-ivnum  = ls_xout-ivnum.
      APPEND ls_pid TO gt_pid.
      CLEAR : ls_xout, ls_pid.
    ENDLOOP.
  ENDIF.

  SORT gt_pid BY ivnum.
  DELETE ADJACENT DUPLICATES FROM gt_pid COMPARING ivnum.
ENDFORM.                    " F_REJECT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_MEINS
*&---------------------------------------------------------------------*
FORM f_conversion_meins  USING    fu_meins
                         CHANGING fc_meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_meins
    IMPORTING
      output         = fc_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " F_CONVERSION_MEINS

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION
*&---------------------------------------------------------------------*
FORM f_unit_conversion  USING    fu_meins fu_menge
                        CHANGING fc_menge.
  WRITE fu_menge TO fc_menge UNIT fu_meins.
  CONDENSE fc_menge.
ENDFORM.                    " F_UNIT_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_GET_DOMAIN_VALUES
*&---------------------------------------------------------------------*
FORM f_get_domain_values .
  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      domname         = 'ZTSPDM001'
    TABLES
      values_tab      = gt_values_tab
    EXCEPTIONS
      no_values_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_POSTDIFF
*&---------------------------------------------------------------------*
FORM f_postdiff .
  DATA: lt_xpost      TYPE STANDARD TABLE OF ty_out,
        lv_value      TYPE bapicurr-bapicurr,
        lt_post_items TYPE bapi_physinv_post_items  OCCURS 0 WITH HEADER LINE,
        lt_bapiret2   TYPE bapiret2 OCCURS 0 WITH HEADER LINE,
        lv_subrc      TYPE sy-subrc,
        lv_budat      TYPE mkpf-budat.

  DATA : items    TYPE STANDARD TABLE OF bapi_physinv_count_items,
         ls_items LIKE LINE OF items.

  lt_xpost[] = gt_post[].
  DELETE lt_xpost WHERE doctyp NE '06'.

  IF lt_xpost[] IS NOT INITIAL.
    SORT lt_xpost BY ivnum gjahr.
    DELETE ADJACENT DUPLICATES FROM lt_xpost COMPARING ivnum gjahr.

    LOOP AT lt_xpost INTO DATA(ls_xpost).
      CLEAR: lt_post_items[],lt_bapiret2[].
      LOOP AT gt_post INTO DATA(ls_post) WHERE ivnum = ls_xpost-ivnum
                                           AND icon  <> icon_led_red
                                           AND appro = icon_allow.
        lt_post_items-item  = ls_post-ivpos+1(3).
        lt_post_items-material = ls_post-matnr.
        lt_post_items-batch = ls_post-charg.
        APPEND lt_post_items.

        ls_items-item      = ls_post-ivpos+1(3).
        ls_items-material  = ls_post-matnr.
        ls_items-batch     = ls_post-charg.
        ls_items-entry_qnt = ls_post-total.
        ls_items-entry_uom = ls_post-meins.
        APPEND ls_items TO items.
        CLEAR ls_items.
      ENDLOOP.

      IF pa_budat IS INITIAL.
        lv_budat  = ls_xpost-qdatu.
      ELSE.
        lv_budat  = pa_budat.
      ENDIF.

      CALL FUNCTION 'BAPI_MATPHYSINV_CHANGECOUNT'
        EXPORTING
          physinventory = ls_xpost-ivnum
          fiscalyear    = ls_xpost-gjahr
        TABLES
          items         = items
          return        = lt_bapiret2.

      CALL FUNCTION 'BAPI_MATPHYSINV_POSTDIFF'
        EXPORTING
          physinventory = ls_xpost-ivnum
          fiscalyear    = ls_xpost-gjahr
          pstng_date    = lv_budat
*         threshold_value = lv_value
        TABLES
          items         = lt_post_items
          return        = lt_bapiret2.

      IF line_exists( lt_bapiret2[ type = 'E' ] ).
        lv_subrc = 4.
        LOOP AT lt_bapiret2 INTO DATA(ls_return).
          APPEND ls_return TO gt_bapiret2.
          CLEAR ls_return.
        ENDLOOP.
      ENDIF.

      IF lv_subrc IS INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        IF line_exists( lt_bapiret2[ type = 'S' id = 'M7' number = '716' ] ).
          ls_xpost-mblnr = lt_bapiret2[ type = 'S' id = 'M7' number = '716' ]-message_v2.
          ls_xpost-mjahr = sy-datum(4).
        ENDIF.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.

      PERFORM f_modify_data USING ls_xpost-mblnr ls_xpost-mjahr
                                  ls_xpost-ivnum.

    ENDLOOP.
  ENDIF.
ENDFORM.
