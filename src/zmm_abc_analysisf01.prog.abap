*&---------------------------------------------------------------------*
*&  Include           ZMM_ABC_ANALYSISF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF pa_spmon IS INITIAL.
    PERFORM f_screen_error USING 'SPM'.
  ENDIF.

  IF pa_svp IS NOT INITIAL.
    IF pa_agpa1 IS INITIAL OR
      pa_agpb1 IS INITIAL OR
      pa_agpc1 IS INITIAL.
      PERFORM f_screen_error USING 'SVP'.
    ENDIF.
  ENDIF.

  IF pa_svn IS NOT INITIAL.
    IF pa_agaa1 IS INITIAL OR
      pa_agab1 IS INITIAL.
      PERFORM f_screen_error USING 'SVN'.
    ENDIF.
  ENDIF.

*  IF pa_sqp IS NOT INITIAL.
*    IF pa_agpa2 IS INITIAL OR
*      pa_agpb2 IS INITIAL OR
*      pa_agpc2 IS INITIAL.
*      PERFORM f_screen_error USING 'SQP'.
*    ENDIF.
*  ENDIF.
*
*  IF pa_sqn IS NOT INITIAL.
*    IF pa_agaa2 IS INITIAL OR
*      pa_agab2 IS INITIAL.
*      PERFORM f_screen_error USING 'SQN'.
*    ENDIF.
*  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_ERROR
*&---------------------------------------------------------------------*
FORM f_screen_error  USING    fu_group.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_SCREEN_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA: l_begdt TYPE dats,
        l_enddt TYPE dats.

  SELECT *
    FROM tvkbt
    INTO CORRESPONDING FIELDS OF TABLE gt_tvkbt
    WHERE spras = sy-langu
      AND vkbur IN so_vkbur.

**  SELECT *
**    FROM zplbc
**    INTO CORRESPONDING FIELDS OF TABLE gt_zplbc
**    WHERE reswk NE space.

  CONCATENATE pa_spmon(6) '01' INTO l_begdt.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = l_begdt
    IMPORTING
      last_day_of_month = l_enddt.

  SELECT * INTO TABLE i_a890
    FROM a890 WHERE kappl EQ 'V'
                AND kschl EQ 'ZEXC'
                AND vkorg EQ '8020'
                AND datab BETWEEN l_begdt AND l_enddt.

  IF i_a890[] IS NOT INITIAL.
    LOOP AT i_a890.
      i_a890-werks = i_a890-kunnr+3(4).
      MODIFY i_a890 TRANSPORTING werks.
    ENDLOOP.

    SORT i_a890 BY werks.
    DELETE ADJACENT DUPLICATES FROM i_a890 COMPARING werks.

    SELECT * INTO TABLE gt_zplbc
      FROM zplbc FOR ALL ENTRIES IN i_a890
      WHERE werks EQ i_a890-werks
        AND reswk NE space.
  ENDIF.

  SELECT *
    FROM tvkol
    INTO CORRESPONDING FIELDS OF TABLE gt_tvkol
    WHERE vstel IN so_vkbur
      AND raube = space.

  SELECT *
    FROM tvkbz
    INTO CORRESPONDING FIELDS OF TABLE gt_tvkbz
    WHERE vtweg = '10'
      AND spart = '00'.

  PERFORM f_area_to_analysis.

  PERFORM f_get_sac7.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_AREA_TO_ANALYSIS
*&---------------------------------------------------------------------*
FORM f_area_to_analysis .
  DATA : lt_marc  LIKE gt_marc OCCURS 0 WITH HEADER LINE.

  IF gt_tvkol[] IS NOT INITIAL.
    SELECT marc~matnr werks marc~lvorm maabc matkl meins zeinr
      FROM marc JOIN mara ON marc~matnr = mara~matnr
      INTO TABLE gt_marc
      FOR ALL ENTRIES IN gt_tvkol
      WHERE marc~matnr IN so_matnr
        AND werks = gt_tvkol-werks.
  ENDIF.

  LOOP AT gt_marc.
    IF pa_loesc IS INITIAL.
      IF gt_marc-lvorm IS NOT INITIAL.
        DELETE gt_marc.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF gt_marc-matkl(3) NOT IN so_prod1 OR
      gt_marc-matkl+3(3) NOT IN so_prod2.
      DELETE gt_marc.
    ENDIF.
  ENDLOOP.

  lt_marc[] = gt_marc[].
  SORT lt_marc BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_marc COMPARING matnr.

  IF lt_marc[] IS NOT INITIAL.
    SELECT makt~matnr maktx matkl
      FROM makt JOIN mara ON makt~matnr = mara~matnr
      INTO TABLE gt_makt
      FOR ALL ENTRIES IN lt_marc
      WHERE mara~matnr = lt_marc-matnr
        AND spras = sy-langu.
  ENDIF.
ENDFORM.                    " F_AREA_TO_ANALYSIS

*&---------------------------------------------------------------------*
*&      Form  F_GET_SAC7
*&---------------------------------------------------------------------*
FORM f_get_sac7 .
  DATA : lv_path LIKE rlgrap-filename,
         lv_datum   TYPE sy-datum.

  DATA : lt_marc  LIKE gt_marc OCCURS 0 WITH HEADER LINE.

  lt_marc[] = gt_marc[].
  SORT lt_marc BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_marc COMPARING matnr.

  PERFORM f_get_avgsls_var.

  CLEAR lv_path.
  IF pa_spmon = sy-datum(6).
    lv_path = '/interface/SAC7/SLOFF/'.
    lv_datum = sy-datum - 1.
    CONCATENATE lv_path lv_datum '.txt' INTO lv_path.
  ELSE.
    lv_path = '/interface/SAC7/SLOFF/Monthly/'.
    CONCATENATE lv_path pa_spmon '.txt' INTO lv_path.
  ENDIF.

  CLEAR : gt_string[], gt_string, gs_string.
*  CALL METHOD zcl_util=>m_open_dataset
  CALL METHOD zcl_sac7=>m_open_dataset
    EXPORTING
      param_name = lv_path
    IMPORTING
      t_return   = gt_string.

  IF gt_string[] IS NOT INITIAL.
    PERFORM f_move_data_fr_text TABLES lt_marc
                                USING 'PTT'.
  ENDIF.

  CLEAR lv_path.
*  lv_path = '/interface/SAC7/sut/monthly/'.
*  CONCATENATE sy-datum(6) '01' INTO lv_datum.
*  lv_datum  = lv_datum - 1.
*  CONCATENATE lv_path lv_datum(6) '_N.txt' INTO lv_path.

  IF pa_spmon = sy-datum(6).
    IF sy-opsys = 'AIX'.
      lv_path = '/interface/SAC7/sut/'.
    ELSE.
      lv_path = '\\tdsdev01\interface\SAC7\sut\'.
    ENDIF.
    CONCATENATE lv_path sy-datum '_N.txt' INTO lv_path.
  ELSE.
    IF sy-opsys = 'AIX'.
      lv_path = '/interface/SAC7/sut/monthly/'.
    ELSE.
      lv_path = '\\tdsdev01\interface\SAC7\sut\monthly\'.
    ENDIF.
    CONCATENATE lv_path pa_spmon '_N.txt' INTO lv_path.
  ENDIF.

  CLEAR : gt_string[], gt_string, gs_string.
*  CALL METHOD zcl_util=>m_open_dataset
  CALL METHOD zcl_sac7=>m_open_dataset
    EXPORTING
      param_name = lv_path
    IMPORTING
      t_return   = gt_string.

  IF gt_string[] IS NOT INITIAL.
    PERFORM f_move_data_fr_text TABLES lt_marc
                                USING 'SUT'.
  ENDIF.
ENDFORM.                    " F_GET_SAC7

*&---------------------------------------------------------------------*
*&      Form  F_GET_AVGSLS_VAR
*&---------------------------------------------------------------------*
FORM f_get_avgsls_var .
  DATA : lt_tvkbz   TYPE STANDARD TABLE OF tvkbz,
         lv_date1   TYPE sy-datum,
         lv_date2   TYPE sy-datum.

  lt_tvkbz[] = gt_tvkbz[].
  SORT lt_tvkbz BY vkorg.
  DELETE ADJACENT DUPLICATES FROM lt_tvkbz COMPARING vkorg.

  CONCATENATE sy-datum(6) '01' INTO lv_date1.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_date1
    IMPORTING
      last_day_of_month = lv_date2
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  SELECT *
    FROM zssac7_vavgsls
    INTO TABLE gt_varavg
    FOR ALL ENTRIES IN lt_tvkbz
    WHERE vkorg = lt_tvkbz-vkorg
      AND datab <= lv_date1
      AND datbi >= lv_date2.

  LOOP AT gt_varavg.
    gt_varavg-prodh1 = gt_varavg-prodh(3).
    gt_varavg-prodh2 = gt_varavg-prodh+3(3).
    gt_varavg-prodh3 = gt_varavg-prodh+6(3).
    MODIFY gt_varavg TRANSPORTING prodh1 prodh2 prodh3.
  ENDLOOP.
ENDFORM.                    " F_GET_AVGSLS_VAR

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_DATA_FR_TEXT
*&---------------------------------------------------------------------*
FORM f_move_data_fr_text  TABLES ft_mara      STRUCTURE gt_marc
                          USING  fu_company.

  DATA : lv_datum  TYPE sy-datum,
         lv_month  LIKE vtbbewe-atage.

  DATA : ls_ptt    TYPE zsac7_soff,
         ls_sut    TYPE zsac7_werks.

  CLEAR : ls_ptt, ls_sut.

  IF gt_string[] IS NOT INITIAL.
    LOOP AT gt_string INTO gs_string.
      CASE fu_company.
        WHEN 'PTT'.
          ls_ptt = gs_string-string.
          READ TABLE ft_mara WITH KEY matnr = ls_ptt-matnr.
          IF sy-subrc = 0.
            gt_sac7-matnr   = ls_ptt-matnr.
            gt_sac7-vkbur   = ls_ptt-vkbur.
            gt_sac7-werks   = ls_ptt-werks.
            gt_sac7-prodh1  = ls_ptt-prodh1.
            gt_sac7-prodh2  = ls_ptt-prodh2.
            gt_sac7-prodh3  = ls_ptt-prodh3.
            gt_sac7-x1      = ls_ptt-x1.
            gt_sac7-x2      = ls_ptt-x2.
            gt_sac7-x3      = ls_ptt-x3.
            gt_sac7-x4      = ls_ptt-x4.
            gt_sac7-x5      = ls_ptt-x5.
            gt_sac7-x6      = ls_ptt-x6.
            gt_sac7-avqty   = ls_ptt-avqty.
            gt_sac7-avamt   = ls_ptt-avamt.
            gt_sac7-bretl   = ls_ptt-bretl.
          ENDIF.
        WHEN 'SUT'.
          ls_sut = gs_string-string.
          READ TABLE ft_mara WITH KEY matnr = ls_sut-matnr.
          IF sy-subrc = 0.
            gt_sac7-matnr   = ls_sut-matnr.
            gt_sac7-vkbur   = ls_sut-werks.
            gt_sac7-werks   = ls_sut-werks.
            gt_sac7-prodh1  = ls_sut-prodh1.
            gt_sac7-prodh2  = ls_sut-prodh2.
            gt_sac7-prodh3  = ls_sut-prodh3.
            gt_sac7-x1      = ls_sut-x1.
            gt_sac7-x2      = ls_sut-x2.
            gt_sac7-x3      = ls_sut-x3.
            gt_sac7-x4      = ls_sut-x4.
            gt_sac7-x5      = ls_sut-x5.
            gt_sac7-x6      = ls_sut-x6.
            gt_sac7-avqty   = ls_sut-avqty.
            gt_sac7-avamt   = ls_sut-avamt.
            gt_sac7-bretl   = ls_sut-bretl.
          ENDIF.
      ENDCASE.

      PERFORM f_get_company USING gt_sac7-vkbur gt_sac7-werks
                            CHANGING gt_sac7-bukrs gt_sac7-vkbur.

      IF gt_sac7-vkbur NOT IN so_vkbur.
        CONTINUE.
      ENDIF.

      APPEND gt_sac7.
      CLEAR gt_sac7.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MOVE_DATA_FR_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_GET_COMPANY
*&---------------------------------------------------------------------*
FORM f_get_company  USING    fu_vkbur fu_werks
                    CHANGING fc_bukrs fc_reswk.
  DATA : ls_tvkbz   TYPE tvkbz,
         ls_zplbc   TYPE zplbc.

  CLEAR : fc_bukrs, ls_tvkbz.
  READ TABLE gt_tvkbz INTO ls_tvkbz WITH KEY vkbur  = fu_vkbur.
  IF sy-subrc = 0.
    fc_bukrs  = ls_tvkbz-vkorg.
  ENDIF.

  CLEAR : fc_reswk, ls_zplbc.
  READ TABLE gt_zplbc INTO ls_zplbc WITH KEY bukrs = fc_bukrs
                                             werks = fu_werks.
  IF sy-subrc = 0.
    fc_reswk  = ls_zplbc-reswk.
  ELSE.
*    fc_reswk  = fu_werks.
    fc_reswk  = ls_tvkbz-vkbur.
  ENDIF.
ENDFORM.                    " F_GET_COMPANY

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : lt_wertetab  TYPE STANDARD TABLE OF bco_werte,
         ls_wertetab  TYPE bco_werte.
  DATA : wahl4        LIKE rmcb0-stab4,
         wahl3        LIKE rmcb0-stab3,
         wahl2        LIKE rmcb0-stab2,
         wahl1        LIKE rmcb0-stab1,
         wkum         LIKE rmcb0-stab1.

  DATA : ls_tvkol     TYPE tvkol,
         ls_tvkbt     TYPE tvkbt.

  IF pa_werku IS INITIAL.
    LOOP AT gt_tvkol INTO ls_tvkol.
      LOOP AT gt_sac7 WHERE vkbur = ls_tvkol-vstel.
*        READ TABLE gt_marc WITH KEY matnr = gt_sac7-matnr
*                                    werks = gt_sac7-werks.
*        IF sy-subrc = 0.
*          gt_out-matkl  = gt_marc-matkl.
        gt_out-vkbur  = gt_sac7-vkbur.
        READ TABLE gt_tvkbt INTO ls_tvkbt WITH KEY vkbur = gt_sac7-vkbur.
        IF sy-subrc = 0.
          gt_out-bezei  = ls_tvkbt-bezei.
        ENDIF.
        gt_out-qtytl  = gt_sac7-avqty.
        gt_out-amttl  = gt_sac7-avamt * 100.
        COLLECT gt_out.

        PERFORM f_prepare_abc_analyze_data TABLES lt_wertetab
                                           USING  gt_out-qtytl gt_out-amttl.
*        ENDIF.
        CLEAR gt_out.
      ENDLOOP.

      CASE 'X'.
        WHEN pa_svp.
          wahl1 = selected.
        WHEN pa_svn.
          wahl2 = selected.
      ENDCASE.

      CALL FUNCTION 'ABC_ANALYSE'
        EXPORTING
          k_wert_abs_a              = pa_agaa1
          k_wert_abs_b              = pa_agab1
          k_wert_abs_flag           = wahl2
          k_wert_proz_a             = pa_agpa1
          k_wert_proz_b             = pa_agpb1
          k_wert_proz_c             = pa_agpc1
          k_wert_proz_flag          = wahl1
          werks_uebergreifend       = wkum
        TABLES
          werte                     = lt_wertetab
        EXCEPTIONS
          prozentsumme_nicht_100    = 1
          strategie_fehlt           = 2
          strategie_nicht_eindeutig = 3
          wertetabelle_leer         = 4
          OTHERS                    = 5.

      LOOP AT lt_wertetab INTO ls_wertetab.
        APPEND ls_wertetab TO wertetab.
        CLEAR ls_wertetab.
      ENDLOOP.

      CLEAR : lt_wertetab[], lt_wertetab.
    ENDLOOP.
  ELSE.
    SORT gt_sac7 BY matnr.
    LOOP AT gt_sac7.
      gt_out-vkbur  = '0200'.
      gt_out-matnr  = gt_sac7-matnr.
      gt_out-qtytl  = gt_sac7-avqty.
      gt_out-amttl  = gt_sac7-avamt * 100.
      COLLECT gt_out.

      PERFORM f_prepare_abc_analyze_data TABLES lt_wertetab
                                         USING  gt_out-qtytl gt_out-amttl.
      CLEAR gt_out.
    ENDLOOP.

    CASE 'X'.
      WHEN pa_svp.
        wahl1 = selected.
      WHEN pa_svn.
        wahl2 = selected.
    ENDCASE.

    CALL FUNCTION 'ABC_ANALYSE'
      EXPORTING
        k_wert_abs_a              = pa_agaa1
        k_wert_abs_b              = pa_agab1
        k_wert_abs_flag           = wahl2
        k_wert_proz_a             = pa_agpa1
        k_wert_proz_b             = pa_agpb1
        k_wert_proz_c             = pa_agpc1
        k_wert_proz_flag          = wahl1
        werks_uebergreifend       = wkum
      TABLES
        werte                     = lt_wertetab
      EXCEPTIONS
        prozentsumme_nicht_100    = 1
        strategie_fehlt           = 2
        strategie_nicht_eindeutig = 3
        wertetabelle_leer         = 4
        OTHERS                    = 5.

    LOOP AT lt_wertetab INTO ls_wertetab.
      APPEND ls_wertetab TO wertetab.

      gt_out1-matnr   = ls_wertetab-matnr.
      READ TABLE gt_makt WITH KEY matnr = gt_out1-matnr.
      IF sy-subrc = 0.
        gt_out1-maktx   = gt_makt-maktx.
        gt_out1-matkl   = gt_makt-matkl.
      ENDIF.
      gt_out1-maabc_new   = ls_wertetab-abc_neu.
      CALL FUNCTION 'FLTP_CHAR_CONVERSION'
        EXPORTING
          decim = 2
          ivalu = 'X'
          input = ls_wertetab-k_prozent
        IMPORTING
          flstr = gt_out1-cumpro.

      READ TABLE gt_out WITH KEY matnr = gt_out1-matnr.
      gt_out1-qtytl  = gt_out-qtytl.
      gt_out1-amttl  = ls_wertetab-k_wert.
      APPEND gt_out1.

      CLEAR ls_wertetab.
    ENDLOOP.

    CLEAR : lt_wertetab[], lt_wertetab.
  ENDIF.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  SORT gt_out BY amttl DESCENDING.

  IF pa_werku IS INITIAL.
    CALL SCREEN 100.
  ELSE.
    CALL SCREEN 101.
  ENDIF.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA : fcode TYPE TABLE OF sy-ucomm,
         lv_maktx   LIKE makt-maktx.

  IF sy-dynnr = '0102'.
    SET PF-STATUS 'PF_102'.
    SET TITLEBAR 'CHANGE_TITLE'.
  ELSE.
    CASE sy-dynnr.
      WHEN '0100'.
        IF pa_werku IS INITIAL.
          SET PF-STATUS 'PF_100'.
          gv_title  = 'Results of analysis according to'.
        ELSE.
          CLEAR : fcode[], fcode.
          APPEND '&CHOOSE'  TO fcode.
          SET PF-STATUS 'PF_100' EXCLUDING fcode.
          SELECT SINGLE maktx
            FROM makt
            INTO lv_maktx
            WHERE matnr = gv_match
              AND spras = sy-langu.
          CONCATENATE gv_match '-' lv_maktx
          INTO gv_title
          SEPARATED BY space.
        ENDIF.
      WHEN '0101'.
        IF pa_werku IS INITIAL.
          CLEAR : fcode[], fcode.
          APPEND '&CHOOSE'  TO fcode.
          SET PF-STATUS 'PF_101' EXCLUDING fcode.
          gv_title  = 'Analysis based on'.
          CONCATENATE 'Sales Office' gv_vkbur '-' gv_bezei
          INTO gv_plant
          SEPARATED BY space.
          WRITE sy-datum TO gv_date DD/MM/YYYY.
          CONCATENATE 'Analysis date' gv_date INTO gv_date SEPARATED BY space.
        ELSE.
          CLEAR : fcode[], fcode.
          APPEND '&CHNG'  TO fcode.
          SET PF-STATUS 'PF_101' EXCLUDING fcode.
          gv_title  = 'ABC Analysis National'.
        ENDIF.
    ENDCASE.

    SET TITLEBAR 'MAIN_TITLE'.

    IF pa_werku IS INITIAL.
      CASE 'X'.
        WHEN pa_svp OR pa_svn.
          CONCATENATE  gv_title 'Sales Average Value' INTO gv_title
          SEPARATED BY space.
*    WHEN pa_sqp OR pa_sqn.
*      CONCATENATE  gv_title 'Sales Average Quantity' INTO gv_title
*      SEPARATED BY space.
      ENDCASE.
    ENDIF.

    gs_variant-report = gv_repid.
    gv_dynnr = sy-dynnr.

    CREATE OBJECT event_receiver.

    PERFORM f_excluding_toolbar.
  ENDIF.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
  DATA : lv_contname(20).

  CASE sy-dynnr.
    WHEN '0100'.
      lv_contname   = 'CC_CONTAINER'.
      IF g_custom_container IS INITIAL.
        CREATE OBJECT g_custom_container
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
            parent  = g_custom_container
            rows    = 1
            columns = 1.

        CALL METHOD g_splitter->get_container
          EXPORTING
            row       = 1
            column    = 1
          RECEIVING
            container = g_container.
      ENDIF.

    WHEN '0101'.
      lv_contname   = 'CC_CONTAINER1'.
      IF g_custom_container1 IS INITIAL.
        CREATE OBJECT g_custom_container1
          EXPORTING
            container_name              = lv_contname
          EXCEPTIONS
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5.

        CREATE OBJECT g_splitter1
          EXPORTING
            parent  = g_custom_container1
            rows    = 1
            columns = 1.

        CALL METHOD g_splitter1->get_container
          EXPORTING
            row       = 1
            column    = 1
          RECEIVING
            container = g_container1.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE alv OUTPUT.

  CASE sy-dynnr.
    WHEN '0100'.
      PERFORM f_build_fieldcat  USING 'ALV100'.
    WHEN '0101'.
      PERFORM f_build_fieldcat  USING 'ALV101'.
  ENDCASE.

  PERFORM f_build_layout.

  PERFORM f_sort_tab.

  PERFORM f_create_alv.

ENDMODULE.                 " ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : et_row_no   TYPE lvc_t_roid,
         ls_row_no   TYPE lvc_s_roid.

  DATA : lv_qtytl     TYPE p DECIMALS 2,
         lv_amttl     TYPE p DECIMALS 2.

  DATA : vb_tab       TYPE STANDARD TABLE OF mcu2,
         ls_tab       TYPE mcu2.

  DATA : ls_tvkol     TYPE tvkol,
         ls_tvkbt     TYPE tvkbt.

  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF pa_werku IS INITIAL.
        CLEAR : gt_out1[], gt_out.
      ELSE.
        CLEAR : gt_out[], gt_out1.
      ENDIF.
      LEAVE TO SCREEN 0.

    WHEN '&CANC'.
      LEAVE TO SCREEN 0.

    WHEN '&CHOOSE'.
      IF pa_werku IS INITIAL.
        CALL METHOD g_grid->get_selected_rows
          IMPORTING
            et_row_no = et_row_no.

        READ TABLE et_row_no INTO ls_row_no INDEX 1.
        IF sy-subrc = 0.
          CLEAR : gv_werks.
          READ TABLE gt_out INDEX ls_row_no-row_id.
          IF sy-subrc = 0.
            gv_werks  = gt_out-werks.
            gv_vkbur  = gt_out-vkbur.
            SELECT SINGLE bezei
              FROM tvkbt
              INTO gv_bezei
              WHERE spras = sy-langu
                AND vkbur = gv_vkbur.

            lv_amttl  = gt_out-amttl.
            lv_qtytl  = gt_out-qtytl.

            PERFORM f_process_choose_alv USING lv_amttl lv_qtytl.

            CALL SCREEN 101.
          ENDIF.
        ENDIF.
      ELSE.
        CALL METHOD g_grid1->get_selected_rows
          IMPORTING
            et_row_no = et_row_no.

        READ TABLE et_row_no INTO ls_row_no INDEX 1.
        IF sy-subrc = 0.
          READ TABLE gt_out1 INDEX ls_row_no-row_id.
          IF sy-subrc = 0.
            gv_match  = gt_out1-matnr.
            CLEAR : gt_out[], gt_out.
            LOOP AT gt_sac7 WHERE matnr = gv_match.
              gt_out-vkbur  = gt_sac7-vkbur.
              READ TABLE gt_tvkbt INTO ls_tvkbt WITH KEY vkbur = gt_sac7-vkbur.
              IF sy-subrc = 0.
                gt_out-bezei  = ls_tvkbt-bezei.
              ENDIF.
              gt_out-qtytl  = gt_sac7-avqty.
              gt_out-amttl  = gt_sac7-avamt * 100.
              APPEND gt_out.
              CLEAR gt_out.
            ENDLOOP.

            SORT gt_out BY vkbur.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN '&CHNG'.
      CALL METHOD g_grid1->get_selected_rows
        IMPORTING
          et_row_no = et_row_no.

      READ TABLE et_row_no INTO ls_row_no INDEX 1.
      IF sy-subrc = 0.
        READ TABLE gt_out1 INDEX ls_row_no-row_id.
        IF sy-subrc = 0.
          gv_matnr  = gt_out1-matnr.
          gv_maabc  = gt_out1-maabc_new.

          CALL SCREEN 102 STARTING AT 10 10.
        ENDIF.
      ENDIF.

    WHEN '&CONT'.
      gt_out1-maabc_new = gv_maabc.
      MODIFY gt_out1 TRANSPORTING maabc_new WHERE matnr = gv_matnr
                                              AND werks = gv_werks.

      LEAVE TO SCREEN 0.

    WHEN '&SAVE'.
*      LOOP AT gt_out1.
*        ls_tab-werks    = gt_out1-werks.
*        ls_tab-matnr    = gt_out1-matnr.
*        ls_tab-abcin    = gt_out1-maabc_new.
*        ls_tab-abcinold = gt_out1-maabc.
*        APPEND ls_tab TO vb_tab.
*        CLEAR ls_tab.
*      ENDLOOP.
*
*      CALL FUNCTION 'UPDATE_ABC_FLAG'
*        TABLES
*          vb_tab = vb_tab.

      PERFORM f_save_data.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

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
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_build_fieldcat USING   fu_container.
  CLEAR : gt_fieldcat[], gt_fieldcat.

  CASE fu_container.
    WHEN 'ALV100'.
      PERFORM f_fieldcatg USING 'GT_OUT' :
        'VKBUR' 'TVBUR' 'VKBUR' '' '6' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'BEZEI' 'TVKBT' 'BEZEI' '' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'QTYTL' '' '' '' '20' 'Total Qty' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'AMTTL' '' '' '' '20' 'Total Value' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' ''.
    WHEN 'ALV101'.
      PERFORM f_fieldcatg USING 'GT_OUT1' :
        'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'QTYTL' '' '' '' '20' 'Total Qty' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'AMTTL' '' '' '' '20' 'Total Value' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'CUMPRO' '' '' '' '6' 'Cum %' '' '' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'MAABC' 'MARC' 'MAABC' '' '20' 'Old ABC Indicator' '' '' '' '' ''
        '' '' '' '' '' '' '' '' '' '',
        'MAABC_NEW' 'MARC' 'MAABC' '' '20' ' ABC Indicator' '' '' '' '' ''
        '' '' '' '' '' '' '' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout_alv-zebra         = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_ALV
*&---------------------------------------------------------------------*
FORM f_create_alv .
  DATA : is_stable    TYPE lvc_s_stbl.

  CASE sy-dynnr.
    WHEN '0100'.
      IF g_grid IS INITIAL.
        CREATE OBJECT g_grid
          EXPORTING
            i_appl_events = selected
            i_parent      = g_container.

        PERFORM f_register_events  USING 'ALV'.

        CALL METHOD g_grid->set_table_for_first_display
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
      ENDIF.

      is_stable-row = 'X'.
      is_stable-col = 'X'.

      CALL METHOD g_grid->refresh_table_display
        EXPORTING
          is_stable = is_stable.
*          i_soft_refresh = 'X'.

    WHEN '0101'.
      IF g_grid1 IS INITIAL.
        CREATE OBJECT g_grid1
          EXPORTING
            i_appl_events = selected
            i_parent      = g_container1.

        PERFORM f_register_events  USING 'ALV'.

        CALL METHOD g_grid1->set_table_for_first_display
          EXPORTING
            is_layout            = gs_layout_alv
            i_save               = 'A'
            is_variant           = gs_variant
            i_default            = 'X'
            it_toolbar_excluding = gs_exclude
          CHANGING
            it_sort              = gt_sort_grid[]
            it_outtab            = gt_out1[]
            it_fieldcatalog      = gt_fieldcat[].
      ENDIF.

      is_stable-row = 'X'.
      is_stable-col = 'X'.

      CALL METHOD g_grid1->refresh_table_display
        EXPORTING
          is_stable = is_stable.
*          i_soft_refresh = 'X'.

  ENDCASE.
ENDFORM.                    " F_CREATE_ALV

*&---------------------------------------------------------------------*
*&      Form  F_REGISTER_EVENTS
*&---------------------------------------------------------------------*
FORM f_register_events USING   fu_container.
  DATA : lt_events  TYPE cntl_simple_events,
         ls_event   TYPE cntl_simple_event.

  CASE fu_container.
    WHEN 'ALV'.
  ENDCASE.
ENDFORM.                    " F_REGISTER_EVENTS

*&---------------------------------------------------------------------*
*&      Form  F_SORT_TAB
*&---------------------------------------------------------------------*
FORM f_sort_tab .
  CLEAR : gt_sort_grid[], gt_sort_grid.

  IF pa_werku IS INITIAL.
    CASE sy-dynnr.
      WHEN '0101'.
        gt_sort_grid-spos      = 1.
        gt_sort_grid-fieldname = 'AMTTL'.
        gt_sort_grid-down      = selected.
        APPEND gt_sort_grid.
        CLEAR gt_sort_grid.
    ENDCASE.
  ELSE.
    CASE sy-dynnr.
      WHEN '0100'.
        gt_sort_grid-spos      = 1.
        gt_sort_grid-fieldname = 'VKBUR'.
        gt_sort_grid-up        = selected.
        APPEND gt_sort_grid.
        CLEAR gt_sort_grid.
      WHEN '0101'.
        gt_sort_grid-spos      = 1.
        gt_sort_grid-fieldname = 'AMTTL'.
        gt_sort_grid-down      = selected.
        APPEND gt_sort_grid.
        CLEAR gt_sort_grid.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_SORT_TAB

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg  USING    value(fu_types)
                           value(fu_fname)
                           value(fu_reftb)
                           value(fu_refld)
                           value(fu_noout)
                           value(fu_outln)
                           value(fu_fltxt)
                           value(fu_dosum)
                           value(fu_hotsp)
                           value(fu_colpos)
                           value(fu_waers)
                           value(fu_meins)
                           value(fu_waers_f)
                           value(fu_meins_f)
                           value(fu_checkbox)
                           value(fu_input)
                           value(fu_icon)
                           value(fu_just)
                           value(fu_edit)
                           value(fu_emphasize)
                           value(fu_decimals_o)
                           value(fu_fix_column).

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
  lv_fieldcat-fix_column        = fu_fix_column.

  APPEND lv_fieldcat TO gt_fieldcat.
  CLEAR lv_fieldcat.
ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_CHOOSE_ALV
*&---------------------------------------------------------------------*
FORM f_process_choose_alv USING   fu_amttl fu_qtytl.
  DATA : ls_werte   TYPE bco_werte.

  DATA : lv_value   TYPE p DECIMALS 2.

  DATA : lt_sac7    LIKE gt_sac7 OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_mard OCCURS 0,
           matnr    LIKE mard-matnr,
           werks    LIKE mard-werks,
           lgort    LIKE mard-lgort,
           exppg    LIKE mard-exppg,
         END OF lt_mard.

  DATA : ls_tvkol TYPE tvkol,
         lv_werks TYPE tvkol-werks,
         lv_lgort TYPE tvkol-lgort.

  CLEAR : gt_out1[], gt_out1.

  READ TABLE gt_tvkol INTO ls_tvkol WITH KEY vstel = gv_vkbur.
  IF sy-subrc = 0.
    lv_werks  = ls_tvkol-werks.
    lv_lgort  = ls_tvkol-lgort.
  ENDIF.

  lt_sac7[] = gt_sac7[].
  SORT lt_sac7[] BY vkbur.
  DELETE lt_sac7 WHERE vkbur <> gv_vkbur.
  IF lt_sac7[] IS NOT INITIAL.
    SELECT matnr werks lgort exppg
      FROM mard
      INTO TABLE lt_mard
      FOR ALL ENTRIES IN lt_sac7
      WHERE matnr = lt_sac7-matnr
        AND werks = lv_werks
        AND lgort = lv_lgort.
  ENDIF.

  LOOP AT gt_sac7 WHERE vkbur = gv_vkbur.
    gt_out1-werks   = gt_sac7-werks.
    gt_out1-vkbur   = gt_sac7-vkbur.
    gt_out1-matnr   = gt_sac7-matnr.

    READ TABLE gt_makt WITH KEY matnr = gt_sac7-matnr.
    IF sy-subrc = 0.
      gt_out1-maktx   = gt_makt-maktx.
    ENDIF.

    READ TABLE lt_mard WITH KEY matnr = gt_sac7-matnr
                                werks = lv_werks
                                lgort = lv_lgort.
    IF sy-subrc = 0.
      gt_out1-maabc   = lt_mard-exppg.
    ELSE.
      CLEAR gt_out1.
      CONTINUE.
    ENDIF.

    READ TABLE wertetab INTO ls_werte WITH KEY matnr = gt_out1-matnr
                                               orga  = gt_out1-vkbur.
    IF sy-subrc = 0.
      gt_out1-maabc_new   = ls_werte-abc_neu.
      CALL FUNCTION 'FLTP_CHAR_CONVERSION'
        EXPORTING
          decim = 2
          ivalu = 'X'
          input = ls_werte-k_prozent
        IMPORTING
          flstr = gt_out1-cumpro.
    ELSE.
      CLEAR gt_out1.
      CONTINUE.
    ENDIF.

    gt_out1-qtytl  = gt_sac7-avqty.
    gt_out1-amttl  = gt_sac7-avamt * 100.
    COLLECT gt_out1.
    CLEAR gt_out1.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_CHOOSE_ALV

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_ABC_ANALYZE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_abc_analyze_data TABLES  ft_wertetab  STRUCTURE bco_werte
                                USING   fu_qtytl fu_amttl.
  DATA : ls_werte   TYPE bco_werte.

  IF pa_werku IS INITIAL.
    ls_werte-orga   = gt_sac7-vkbur.
    ls_werte-werks  = gt_sac7-werks.
    ls_werte-matnr  = gt_sac7-matnr.
    CASE 'X'.
      WHEN pa_svp.
        IF fu_amttl < 0.
          ls_werte-k_wert  = 0.
        ELSE.
          ls_werte-k_wert  = fu_amttl.
        ENDIF.
      WHEN pa_svn.
        IF fu_amttl < 0.
          ls_werte-k_wert = 0.
        ELSE.
          ls_werte-k_wert  = fu_amttl.
        ENDIF.
    ENDCASE.

    APPEND ls_werte TO ft_wertetab.
    CLEAR ls_werte.
  ELSE.
    ls_werte-werks  = '0200'.
    ls_werte-matnr  = gt_sac7-matnr.
    CASE 'X'.
      WHEN pa_svp.
        IF fu_amttl < 0.
          ls_werte-k_wert  = 0.
        ELSE.
          ls_werte-k_wert  = fu_amttl.
        ENDIF.
      WHEN pa_svn.
        IF fu_amttl < 0.
          ls_werte-k_wert = 0.
        ELSE.
          ls_werte-k_wert  = fu_amttl.
        ENDIF.
    ENDCASE.

    COLLECT ls_werte INTO ft_wertetab.
    CLEAR ls_werte.
  ENDIF.
ENDFORM.                    " F_PREPARE_ABC_ANALYZE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data .
  DATA : ls_tvkol     TYPE tvkol.

  LOOP AT gt_out1.
    AUTHORITY-CHECK OBJECT 'ZMMABC'
        ID 'ACTVT' FIELD '01'
        ID 'MATKL' FIELD gt_out1-matkl.
    IF sy-subrc = 0.
      READ TABLE gt_tvkol INTO ls_tvkol WITH KEY vstel = gt_out1-vkbur.
      IF sy-subrc = 0.
        IF pa_werku IS INITIAL.
          UPDATE mard SET exppg = gt_out1-maabc_new
                      WHERE matnr = gt_out1-matnr
                        AND werks = ls_tvkol-werks
                        AND lgort = ls_tvkol-lgort.
        ELSE.
          UPDATE marc SET maabc = gt_out1-maabc_new
                      WHERE matnr = gt_out1-matnr
                        AND werks = '0200'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM f_check_authorization .
  LOOP AT gt_out1.
    AUTHORITY-CHECK OBJECT 'ZMMABC'
        ID 'ACTVT' FIELD '01'
        ID 'MATKL' FIELD gt_out1-matkl.
    IF sy-subrc <> 0.
      gv_subrc = 4.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHECK_AUTHORIZATION
