*&---------------------------------------------------------------------*
*&  Include           ZWM_E001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
*  PERFORM f_modify_screen USING : 'XXX' '0' ''.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
*  PERFORM f_screen_error USING 'XXX' ''.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

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
*&      Form  F_SCREEN_ERROR
*&---------------------------------------------------------------------*
FORM f_screen_error  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

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
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  IF pa_lgnum(1) = 'C'.
    SELECT *
      FROM zwmdt001a
      INTO CORRESPONDING FIELDS OF TABLE gt_zwmdt001a
      WHERE lgnum = pa_lgnum
        AND nltyp = pa_lgtyp.
  ENDIF.

ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .

  DATA : lt_001      TYPE STANDARD TABLE OF zwmdt001 INITIAL SIZE 0,
         ls_001      LIKE LINE OF lt_001,
         lt_zwmdt001 TYPE STANDARD TABLE OF zwmdt001 INITIAL SIZE 0,
         ls_zwmdt001 LIKE LINE OF lt_zwmdt001,
*         lt_zwmdt001x TYPE STANDARD TABLE OF zwmdt001x INITIAL SIZE 0,
*         ls_zwmdt001x LIKE LINE OF lt_zwmdt001x,
         lt_mlgt     TYPE STANDARD TABLE OF mlgt INITIAL SIZE 0,
         ls_mlgt     LIKE LINE OF lt_mlgt,
         lt_lqua     TYPE STANDARD TABLE OF lqua INITIAL SIZE 0,
         ls_lqua     LIKE LINE OF lt_lqua,
         lt_lagp     TYPE STANDARD TABLE OF lagp INITIAL SIZE 0,
         ls_lagp     LIKE LINE OF lt_lagp.

  DATA : lr_lgtyp TYPE RANGE OF lgtyp,
         ls_lgtyp LIKE LINE OF lr_lgtyp,
         lr_lgort TYPE RANGE OF lgort_d,
         ls_lgort LIKE LINE OF lr_lgort.

  DATA : lv_verme TYPE lqua-verme,
         lv_gesme TYPE lqua-gesme.

  FIELD-SYMBOLS <fs>    TYPE any.
  DATA : ls_zwmdt001a     LIKE LINE OF gt_zwmdt001a,
         ls_001a          LIKE LINE OF gt_001a,
         lv_fieldname(30),
         lv_znou          TYPE znou.

  ls_lgort-low    = '*U0'.
  ls_lgort-sign   = 'E'.
  ls_lgort-option = 'CP'.
  APPEND ls_lgort TO lr_lgort.
  CLEAR ls_lgort.

  IF pa_lgnum(1) = 'C'.
    LOOP AT gt_zwmdt001a INTO ls_zwmdt001a.
      DO 10 TIMES.
        ADD 1 TO lv_znou.
        CONCATENATE 'LS_ZWMDT001A-VLTYP' lv_znou INTO lv_fieldname.
        ASSIGN (lv_fieldname) TO <fs>.
        IF <fs> IS ASSIGNED.
          ls_lgtyp-low = <fs>.
        ENDIF.
        IF ls_lgtyp-low IS INITIAL.
          EXIT.
        ENDIF.
        ls_lgtyp-sign   = 'I'.
        ls_lgtyp-option = 'EQ'.
        APPEND ls_lgtyp TO lr_lgtyp.

        ls_001a-znou  = lv_znou.
        ls_001a-lgtyp = ls_lgtyp-low.
        APPEND ls_001a TO gt_001a.
        CLEAR : ls_001a, ls_lgtyp.
      ENDDO.
    ENDLOOP.

    SELECT *
      FROM mlgt "as a join makt as b on b~matnr = a~matnr and
                "                       b~SPRAS = sy-langu
      INTO CORRESPONDING FIELDS OF TABLE lt_mlgt
      WHERE lgnum   = pa_lgnum
        AND lgtyp   = pa_lgtyp
        AND matnr   IN so_matnr
        AND lgpla   NE space.
    "and SPRAS = 'E'.

    IF lt_mlgt[] IS NOT INITIAL.
      SELECT *
        FROM lqua
        INTO CORRESPONDING FIELDS OF TABLE lt_lqua
        FOR ALL ENTRIES IN lt_mlgt
        WHERE lgnum = pa_lgnum
          AND lgtyp = pa_lgtyp
          AND matnr = lt_mlgt-matnr.
    ENDIF.

    LOOP AT lt_mlgt INTO ls_mlgt.
      ls_001-matnr    = ls_mlgt-matnr.
      ls_001-lgnum    = ls_mlgt-lgnum.
      ls_001-lgtyp    = ls_mlgt-lgtyp.
      ls_001-lpmin    = ls_mlgt-lpmin.
      ls_001-lpmax    = ls_mlgt-lpmax.
      ls_001-nsmng    = ls_mlgt-nsmng.
      IF ls_mlgt-lgpla IS NOT INITIAL.
        ls_001-lgpla01  = ls_mlgt-lgpla.
        CLEAR lv_gesme.
        LOOP AT lt_lqua INTO ls_lqua WHERE matnr = ls_mlgt-matnr
                                       AND lgpla = ls_mlgt-lgpla.
          ADD ls_lqua-gesme TO lv_gesme.
        ENDLOOP.
        IF ls_001-lpmin > 0.
          IF lv_gesme <= ls_mlgt-lpmin.
            APPEND ls_001 TO gt_001.
          ENDIF.
        ELSE.
          IF lv_gesme <= ls_mlgt-nsmng.
            APPEND ls_001 TO gt_001.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR ls_001.
    ENDLOOP.

    IF pa_lgtyp(1) NE 'L'.
      SELECT matnr lgnum lgtyp lgpla lpmin
        FROM zwmdt001x
        INTO CORRESPONDING FIELDS OF TABLE lt_zwmdt001x
        WHERE lgnum   = pa_lgnum
          AND lgtyp   = pa_lgtyp
          AND matnr   IN so_matnr.

      LOOP AT lt_zwmdt001x INTO ls_zwmdt001x.
        ls_001-matnr    = ls_zwmdt001x-matnr.
        ls_001-lgnum    = ls_zwmdt001x-lgnum.
        ls_001-lgtyp    = ls_zwmdt001x-lgtyp.
        ls_001-lpmin    = ls_zwmdt001x-lpmin.
        ls_001-lgpla01  = ls_zwmdt001x-lgpla.
        APPEND ls_001 TO gt_001.
      ENDLOOP.
    ENDIF.
  ELSE.
    ls_lgtyp-low    = pa_lgtyp.
    ls_lgtyp-sign   = 'E'.
    ls_lgtyp-option = 'EQ'.
    APPEND ls_lgtyp TO lr_lgtyp.
    CLEAR ls_lgtyp.

    ls_lgtyp-low    = '9*'.
    ls_lgtyp-sign   = 'E'.
    ls_lgtyp-option = 'CP'.
    APPEND ls_lgtyp TO lr_lgtyp.
    CLEAR ls_lgtyp.

    SELECT matnr lgnum lgtyp lgpla01 lgpla02 lgpla03 lgpla04 lgpla05 lpmin
      FROM zwmdt001
      INTO CORRESPONDING FIELDS OF TABLE lt_zwmdt001
      WHERE lgnum   = pa_lgnum
        AND lgtyp   = pa_lgtyp
        AND matnr   IN so_matnr.

    LOOP AT lt_zwmdt001 INTO ls_zwmdt001.
      ls_001-matnr    = ls_zwmdt001-matnr.
      ls_001-lgnum    = ls_zwmdt001-lgnum.
      ls_001-lgtyp    = ls_zwmdt001-lgtyp.
      ls_001-lpmin    = ls_zwmdt001-lpmin.
      IF ls_zwmdt001-lgpla01 IS NOT INITIAL.
        ls_001-lgpla01  = ls_zwmdt001-lgpla01.
        APPEND ls_001 TO gt_001.
      ENDIF.
      IF ls_zwmdt001-lgpla02 IS NOT INITIAL.
        ls_001-lgpla01  = ls_zwmdt001-lgpla02.
        APPEND ls_001 TO gt_001.
      ENDIF.
      IF ls_zwmdt001-lgpla03 IS NOT INITIAL.
        ls_001-lgpla01  = ls_zwmdt001-lgpla03.
        APPEND ls_001 TO gt_001.
      ENDIF.
      IF ls_zwmdt001-lgpla04 IS NOT INITIAL.
        ls_001-lgpla01  = ls_zwmdt001-lgpla04.
        APPEND ls_001 TO gt_001.
      ENDIF.
      IF ls_zwmdt001-lgpla05 IS NOT INITIAL.
        ls_001-lgpla01  = ls_zwmdt001-lgpla05.
        APPEND ls_001 TO gt_001.
      ENDIF.
    ENDLOOP.
  ENDIF.

  lt_001[] = gt_001[].
  SORT lt_001 BY lgpla01.
  DELETE ADJACENT DUPLICATES FROM lt_001 COMPARING lgpla01.
  IF lt_001[] IS NOT INITIAL.
    IF pa_lgnum(1) = 'C'.
      SELECT lgnum lgtyp lgpla lkapv rkapv kzler
      FROM lagp
      INTO CORRESPONDING FIELDS OF TABLE gt_lagp
      FOR ALL ENTRIES IN lt_001
      WHERE lgnum = lt_001-lgnum
        AND lgtyp = lt_001-lgtyp
        AND lgpla = lt_001-lgpla01.
    ELSE.
      SELECT lgnum lgtyp lgpla
        FROM lagp
        INTO CORRESPONDING FIELDS OF TABLE gt_lagp
        FOR ALL ENTRIES IN lt_001
        WHERE lgnum = lt_001-lgnum
          AND lgtyp = lt_001-lgtyp
          AND lgpla = lt_001-lgpla01
          AND kzler = 'X'.
    ENDIF.
  ENDIF.

  CLEAR : lt_001[], lt_001.
  lt_001[] = gt_001[].
  SORT lt_001 BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_001 COMPARING matnr.
  IF lt_001[] IS NOT INITIAL.
    SELECT *
      FROM mlgn
      INTO CORRESPONDING FIELDS OF TABLE gt_mlgn
      FOR ALL ENTRIES IN lt_001
      WHERE lgnum   = pa_lgnum
        AND matnr   = lt_001-matnr.

    IF pa_lgnum = 'C40'.
      SELECT lgnum lqnum matnr werks charg bestq sobkz sonum
             lgtyp lgpla letyp verme meins vfdat lgort wdatu
        FROM lqua
        INTO CORRESPONDING FIELDS OF TABLE gt_lqua
        FOR ALL ENTRIES IN lt_001
        WHERE lgnum = pa_lgnum
          AND lgtyp IN lr_lgtyp
          AND matnr = lt_001-matnr
          AND bestq = space
  "        AND ausme = 0
          AND verme GT 0
          AND lgort IN lr_lgort.
    ELSE.
      SELECT lgnum lqnum matnr werks charg bestq sobkz sonum
             lgtyp lgpla letyp verme meins vfdat lgort wdatu
        FROM lqua
        INTO CORRESPONDING FIELDS OF TABLE gt_lqua
        FOR ALL ENTRIES IN lt_001
        WHERE lgnum = pa_lgnum
          AND lgtyp IN lr_lgtyp
          AND matnr = lt_001-matnr
          AND bestq = space
          AND ausme = 0
          AND verme GT 0
          AND lgort IN lr_lgort.
    ENDIF.
    IF pa_lgnum(1) = 'C'.
      lt_lqua[] = gt_lqua[].
      SORT lt_lqua BY lgtyp lgpla.
      DELETE ADJACENT DUPLICATES FROM lt_lqua COMPARING lgtyp lgpla.
      IF lt_lqua[] IS NOT INITIAL.
        SELECT *
          FROM lagp
          INTO CORRESPONDING FIELDS OF TABLE lt_lagp
          FOR ALL ENTRIES IN lt_lqua
          WHERE lgnum = lt_lqua-lgnum
            AND lgtyp = lt_lqua-lgtyp
            AND lgpla = lt_lqua-lgpla
            AND skzua = space.

        LOOP AT gt_lqua INTO ls_lqua.
          CLEAR ls_lagp.
          READ TABLE lt_lagp INTO ls_lagp
                             WITH KEY lgnum = ls_lqua-lgnum
                                      lgtyp = ls_lqua-lgtyp
                                      lgpla = ls_lqua-lgpla.
          IF sy-subrc <> 0.
            DELETE TABLE gt_lqua FROM ls_lqua.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : lt_001       TYPE STANDARD TABLE OF zwmdt001 INITIAL SIZE 0,
         lt_lqua      TYPE STANDARD TABLE OF lqua INITIAL SIZE 0,
         ls_001       LIKE LINE OF gt_001,
         ls_lagp      LIKE LINE OF gt_lagp,
         ls_lqua      LIKE LINE OF gt_lqua,
         ls_out       LIKE LINE OF gt_out,
         ls_zwmdt001x LIKE LINE OF lt_zwmdt001x.
  DATA: lt_marm TYPE STANDARD TABLE OF marm.
  DATA : lv_matnr TYPE lqua-matnr,
         lv_lgnum TYPE lqua-lgnum,
         lv_index TYPE sy-index,
         lv_lgtyp TYPE lqua-lgtyp.

  SELECT * INTO TABLE @DATA(lt_t331)
    FROM t331 WHERE lgnum = @pa_lgnum
                AND lgtyp = @pa_lgtyp.

  lt_001[]  = gt_001[].
  SORT lt_001 BY matnr lgnum.
  DELETE ADJACENT DUPLICATES FROM lt_001 COMPARING matnr lgnum.

  LOOP AT lt_001 INTO ls_001.
    CLEAR : lv_matnr, lv_lgnum, lv_index, lt_lqua[], lt_lqua.
    lv_matnr  = ls_001-matnr.
    lv_lgnum  = ls_001-lgnum.
    CLEAR : ls_001.
    LOOP AT gt_001 INTO ls_001 WHERE matnr = lv_matnr
                                 AND lgnum = lv_lgnum.
      READ TABLE gt_lagp INTO ls_lagp WITH KEY lgnum = ls_001-lgnum
                                               lgtyp = ls_001-lgtyp
                                               lgpla = ls_001-lgpla01.
      IF sy-subrc = 0.
        ADD 1 TO lv_index.
*        IF lt_lqua[] IS INITIAL.
*          lt_lqua[] = gt_lqua[].
*          SORT lt_lqua BY matnr lgnum.
*          DELETE lt_lqua WHERE matnr <> ls_001-matnr.
*        ENDIF.
*        SORT lt_lqua BY vfdat verme wdatu.
*        READ TABLE lt_lqua INTO ls_lqua INDEX lv_index.
*        IF sy-subrc = 0.
*          IF ls_001-lpmax IS NOT INITIAL AND ls_lqua-verme > ls_001-lpmax.
*            ls_lqua-verme = ls_001-lpmax.
*          ENDIF.
        READ TABLE lt_zwmdt001x INTO ls_zwmdt001x WITH KEY lgnum = ls_001-lgnum
                                                           lgtyp = ls_001-lgtyp
                                                           lgpla = ls_001-lgpla01.
        IF sy-subrc = 0 AND ls_lagp-kzler NE 'X'.
          CONTINUE.
        ELSE.
          PERFORM f_get_lqua TABLES lt_marm
                              USING lv_index ls_001-matnr ls_001-lpmax
                             CHANGING ls_lqua.

          IF ls_lqua IS NOT INITIAL.

            "Cek kapasitas
            DATA(kapap) = VALUE #( lt_t331[ lgnum = pa_lgnum
                                            lgtyp = pa_lgtyp ]-kapap OPTIONAL ).
            DATA(lenvw) = VALUE #( lt_t331[ lgnum = pa_lgnum
                                            lgtyp = pa_lgtyp ]-lenvw OPTIONAL ).
            DATA(flg_neuer_let) = '1'.
            DATA(returncode) = sy-subrc.
            CLEAR: returncode.
*            PERFORM kapazitaetsberechnung(ll03af0s)
*              USING ls_lagp ls_lqua ls_ltap-werks ls_ltap-charg
*                    kapap lenvw ls_ltap-nsola ls_ltap-nsolm
*                    ls_ltap-altme ls_ltap-umrez ls_ltap-umren flg_neuer_let
*                    ls_ltap-letyp returncode hlp_menge refe_menge.
            IF returncode IS INITIAL.
*        IF sy-subrc = 0.
              "              CALL FUNCTION 'DIALOG_SET_NO_DIALOG'.

              TRY.

                  CALL FUNCTION 'L_TO_CREATE_SINGLE'
                    EXPORTING
                      i_lgnum               = pa_lgnum
                      i_bwlvs               = '999'
                      i_matnr               = ls_001-matnr
                      i_werks               = ls_lqua-werks
                      i_lgort               = ls_lqua-lgort
                      i_charg               = ls_lqua-charg
                      i_letyp               = 'SP'
                      i_anfme               = ls_lqua-verme
                      i_altme               = ls_lqua-meins
                      i_squit               = space
                      i_vltyp               = ls_lqua-lgtyp
                      i_vlpla               = ls_lqua-lgpla
                      i_nltyp               = pa_lgtyp
                      i_nlpla               = ls_001-lgpla01
                      i_commit_work         = 'X'
                    IMPORTING
                      e_tanum               = ls_out-tanum
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
                      error_message         = 99
                      OTHERS                = 34.

                CATCH cx_root INTO DATA(lo_root_exception).
              ENDTRY.
              IF sy-subrc <> 0.
                "                RAISE returncode.
              ENDIF.

              IF sy-subrc = 0.
                ls_out-lgnum  = pa_lgnum.
                ls_out-matnr  = ls_001-matnr.
                ls_out-werks  = ls_lqua-werks.
                ls_out-lgort  = ls_lqua-lgort.
                ls_out-charg  = ls_lqua-charg.
                ls_out-letyp  = 'SP'.
                ls_out-anfme  = ls_lqua-verme.
                ls_out-altme  = ls_lqua-meins.
                ls_out-vltyp  = ls_lqua-lgtyp.
                ls_out-vlpla  = ls_lqua-lgpla.
                ls_out-wdatu  = ls_lqua-wdatu.
                ls_out-nltyp  = pa_lgtyp.
                ls_out-nlpla  = ls_001-lgpla01.
                APPEND ls_out TO gt_out.
                CLEAR ls_out.
              ELSE.
                IF lo_root_exception IS NOT INITIAL.
                  sy-subrc = 34.
                ENDIF.
              ENDIF.
            ENDIF.
            "           CALL FUNCTION 'DIALOG_SET_WITH_DIALOG'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 100.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory .

ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA fcode TYPE TABLE OF sy-ucomm.

  CLEAR : fcode, fcode[].
  IF pa_lgnum = 'C40'.
    "    APPEND '&LOG'  TO fcode.
    APPEND '&PRC'  TO fcode.
    SET PF-STATUS 'STANDARD'.
    "    SET PF-STATUS 'PF_STATUS'.
  ELSE.
    IF gt_error[] IS INITIAL.
      APPEND '&LOG'  TO fcode.
      SET PF-STATUS 'PF_STATUS' EXCLUDING fcode.
    ELSE.
      SET PF-STATUS 'PF_STATUS'.
    ENDIF.
  ENDIF.
  "    SET PF-STATUS 'PF_STATUS'. " EXCLUDING fcode.

  SET TITLEBAR 'MAIN_TITLE'.

  PERFORM f_excluding_toolbar.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
  DATA : lv_contname(20).

  lv_contname   = 'CC_MAIN'.
  "  lv_contname   = 'MAIN'.

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
        container = g_container.
  ENDIF.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDING_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_excluding_toolbar .
  DATA : ls_exclude   TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_check.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.
ENDFORM.                    " F_EXCLUDING_TOOLBAR

*&---------------------------------------------------------------------*
*&      Module  MAIN_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE main_alv OUTPUT.
  IF g_maingrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_maingrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_container.

    "    PERFORM f_build_fieldcat USING 'MAIN'.
    PERFORM f_build_layout USING 'MAIN'.
    PERFORM f_build_sort_tab_grid USING 'MAIN'.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_maingrid.

    CALL METHOD g_maingrid->set_table_for_first_display
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
  ELSE.
    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDMODULE.                 " MAIN_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_build_fieldcat USING fu_container.
  CLEAR : gt_main_fieldcat[], gt_main_fieldcat.

  CASE fu_container.
    WHEN 'MAIN'.
      IF pa_lgnum = 'C40'.
        PERFORM f_fieldcat USING 'GT_OUT' :
          'CHECK' '' '' '' '3' 'Ch Box' '' '' '' '' '' '' '' 'X' '' '' ''
          'X' 'X' ''.
        PERFORM f_fieldcat USING 'GT_OUT' :
          'TANUM' 'LTAK' 'TANUM' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'MATNR' 'LTAP' 'MATNR' '' '10' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'MAKTX' 'MAKT' 'MAKTX' '' '25' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'WERKS' 'LTAP' 'WERKS' '' '5' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'LGORT' 'LTAP' 'LGORT' '' '5' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'CHARG' 'LTAP' 'CHARG' '' '10' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'LETYP' 'LTAP' 'LETYP' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'WDATU' 'LQUA' 'WDATU' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'ANFME' 'RL03T' 'ANFME' '' '7' '' '' '' '' '' '' '' 'ALTME' '' ''
          '' '' '' 'X' '',
          'ALTME' 'LTAP' 'ALTME' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'ECER' 'RL03T' 'ANFME' '' '7' 'Qty Ecer' '' '' '' '' '' '' 'UOM_ECER' '' ''
          '' '' '' 'X' '',
          'UOM_ECER' 'LTAP' 'ALTME' '' '' 'Uom Ecer' 'Uom' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'KARTON' 'RL03T' 'ANFME' '' '7' 'Qty Karton' '' '' '' '' '' '' 'UOM_KARTON' '' ''
          '' '' '' 'X' '',
          'UOM_KARTON' 'LTAP' 'ALTME' '' '' 'Uom Karton' 'Uom' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'VLTYP' 'LTAP' 'VLTYP' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'VLPLA' 'LTAP' 'VLPLA' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'NLTYP' 'LTAP' 'NLTYP' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'NLPLA' 'LTAP' 'NLPLA' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'REMARK' '' '' '' '100' 'Message Error' '' '' '' '' '' '' '' '' ''
          '' '' '' 'X' ''.
      ELSE.
        PERFORM f_fieldcat USING 'GT_OUT' :
          'TANUM' 'LTAK' 'TANUM' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'MATNR' 'LTAP' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'WERKS' 'LTAP' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'LGORT' 'LTAP' 'LGORT' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'CHARG' 'LTAP' 'CHARG' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'LETYP' 'LTAP' 'LETYP' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'WDATU' 'LQUA' 'WDATU' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'ANFME' 'RL03T' 'ANFME' '' '' '' '' '' '' '' '' '' 'ALTME' '' ''
          '' '' '' 'X' '',
          'ALTME' 'LTAP' 'ALTME' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'VLTYP' 'LTAP' 'VLTYP' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'VLPLA' 'LTAP' 'VLPLA' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'NLTYP' 'LTAP' 'NLTYP' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'NLPLA' 'LTAP' 'NLPLA' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
          '' 'X' ''.
      ENDIF.
  ENDCASE.

ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refr01.
  IF fu_refr01 IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    CALL METHOD g_maingrid->refresh_table_display
      EXPORTING
        is_stable = gs_stable.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCAT
*&---------------------------------------------------------------------*
*&  Emphasize
*&  - 1st char = C (color property)
*&  - 2nd char = color code (from 0 to 7)
*&    0 = background color
*&    1 = blue
*&    2 = gray
*&    3 = yellow
*&    4 = blue/gray
*&    5 = green
*&    6 = red
*&    7 = orange
*&  - 3rd char = intensified (0=off, 1=on)
*&  - 4th char = inverse display (0=off, 1=on)
*----------------------------------------------------------------------*
FORM f_fieldcat  USING    VALUE(fu_types)
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
                          VALUE(fu_emphasize).

  DATA: ld_fieldcat  TYPE  lvc_s_fcat.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_field         = fu_refld.
  ld_fieldcat-ref_table         = fu_reftb.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-scrtext_l         = fu_fltxt.
  ld_fieldcat-scrtext_m         = fu_fltxt.
  ld_fieldcat-scrtext_s         = fu_fltxt.
  ld_fieldcat-reptext           = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-col_pos           = fu_colpos.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-icon              = fu_icon.
  ld_fieldcat-just              = fu_just.
  ld_fieldcat-edit              = fu_edit.
  ld_fieldcat-emphasize         = fu_emphasize.

  CASE fu_types.
    WHEN 'GT_OUT'.
      APPEND ld_fieldcat TO gt_main_fieldcat.
  ENDCASE.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout  USING    fu_layout.
  gs_layout_alv-zebra               = selected.
  IF pa_lgnum = 'C40'.
    gs_layout_alv-box_fname           = 'CHECK'.
    gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
    gs_layout_alv-no_rowmark          = selected.
    gs_layout_alv-stylefname          = 'STYLE'.
    gs_layout_alv-zebra               = selected.
    gs_layout_alv-no_toolbar          = selected.
  ENDIF.
*  CASE fu_layout.
*    WHEN 'MAIN'.
*      gs_layout_alv-box_fname           = 'CHECK'.
*      gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
*      gs_layout_alv-no_rowmark          = selected.
*      gs_layout_alv-stylefname          = 'STYLE'.
*  ENDCASE.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT_TAB_GRID
*&---------------------------------------------------------------------*
FORM f_build_sort_tab_grid  USING    fu_sort.
  CLEAR gt_main_sort.

*  CASE fu_sort.
*    WHEN 'MAIN'.
*      gt_main_sort-spos = 1.
*      gt_main_sort-fieldname = 'EBELN'.
*      gt_main_sort-down      = selected.
*      APPEND gt_main_sort.
*      CLEAR gt_main_sort.
*  ENDCASE.
ENDFORM.                    " F_BUILD_SORT_TAB_GRID

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : lv_ucomm  TYPE sy-ucomm,
         lv_valid  TYPE c,
         lt_fidx   TYPE lvc_t_fidx,
         ls_fidx   TYPE sy-tabix,
         ls_filter LIKE LINE OF gt_filter.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF NOT g_container IS INITIAL.
        CALL METHOD g_container->free
          EXCEPTIONS
            cntl_system_error = 1
            cntl_error        = 2.
        CLEAR : g_container, g_maingrid.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN '&ALL'.
      CALL METHOD g_maingrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING 'X'.
      ENDIF.

    WHEN '&SAL'.
      CALL METHOD g_maingrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING ''.
      ENDIF.
    WHEN '&PRC'.
      CLEAR lv_valid.
      CALL METHOD g_maingrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_create_to_c40.
        "        PERFORM f_select USING ''.
      ENDIF.

    WHEN '&POS'.
      CLEAR lv_valid.
      CALL METHOD g_maingrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_posting_data.
      ENDIF.

    WHEN '&LOG'.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_error.

    WHEN '&OUP' OR '&ODN' OR '&OL0'.
      CALL METHOD g_maingrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
      "  gt_xout[] = gt_out[].
    WHEN OTHERS.
      CALL METHOD g_maingrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.

  CALL FUNCTION 'BUFFER_REFRESH_ALL'.

  CLEAR ok_code.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  HEADER  OUTPUT
*&---------------------------------------------------------------------*
MODULE header OUTPUT.
  DATA : lr_rows      TYPE REF TO cl_salv_form_layout_grid,
         lr_element   TYPE REF TO cl_salv_form_element,
         lr_container TYPE REF TO cl_gui_container,
         lr_dydos     TYPE REF TO cl_salv_form_dydos.

  CREATE OBJECT lr_rows.

  g_content = lr_rows.

  CLEAR lr_element.
  PERFORM header_line CHANGING lr_element.
  lr_rows->set_element( r_element = lr_element
                        row       = 1
                        column    = 1 ).

  CREATE OBJECT lr_container
    TYPE
    cl_gui_custom_container
    EXPORTING
      container_name = 'CC_HEADER'.

  CREATE OBJECT lr_dydos
    EXPORTING
      r_container = lr_container
      r_content   = g_content.

  lr_dydos->display( ).
ENDMODULE.                 " HEADER  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  HEADER_LINE
*&---------------------------------------------------------------------*
FORM header_line  CHANGING cr_element TYPE REF TO cl_salv_form_element.

  DATA: lr_rows   TYPE REF TO cl_salv_form_layout_grid,
        lr_grid   TYPE REF TO cl_salv_form_layout_grid,
        lr_grid_1 TYPE REF TO cl_salv_form_layout_grid,
        lr_grid_2 TYPE REF TO cl_salv_form_layout_grid,
        lr_label  TYPE REF TO cl_salv_form_label,
        lr_text   TYPE REF TO cl_salv_form_text.

  CREATE OBJECT lr_rows.

*  lr_rows->create_header_information(
*    row    = 1
*    column = 1
*    text   = text-t03 ).
*
*  lr_rows->add_row( ).

  lr_grid = lr_rows->create_grid(
              row    = 3
              column = 1 ).
  lr_grid_1 = lr_grid->create_grid(
    row    = 1
    column = 1 ).
  lr_grid_2 = lr_grid->create_grid(
    row    = 1
    column = 2 ).

  lr_label = lr_grid_1->create_label(
    row    = 1
    column = 1
    text   = TEXT-h01 ).
  lr_text = lr_grid_1->create_text(
    row    = 1
    column = 2
    text   = '8020' ).
  lr_grid_1->create_text(
    row    = 1
    column = 3
    text   = 'PT. Tempo' ).
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_1->create_label(
    row    = 2
    column = 1
    text   = TEXT-h02 ).
  lr_text = lr_grid_1->create_text(
    row    = 2
    column = 2
    text   = 'Januari 2018' ).
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_2->create_label(
    row    = 1
    column = 1
    text   = TEXT-h11 ).
  lr_text = lr_grid_2->create_text(
    row    = 1
    column = 2
    text   = '0200' ).
  lr_grid_2->create_text(
    row    = 1
    column = 3
    text   = 'Tempo Head Office - Jakarta' ).
  lr_label->set_label_for( lr_text ).

  lr_rows->add_row( ).

*  lr_rows->create_action_information(
*    row    = 5
*    column = 1
*    text   = text-t09 ).

  cr_element = lr_rows.
ENDFORM.                    " HEADER_LINE

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check. " fu_container.
  DATA : ls_out          LIKE LINE OF gt_out,
         ls_fieldcatalog TYPE lvc_t_fcat WITH HEADER LINE.
  DATA : lv_style    TYPE lvc_s_styl-style,
         lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  CALL METHOD g_maingrid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  lv_style = cl_gui_alv_grid=>mc_style_disabled.
  ls_stylerow-fieldname = 'CHECK'.
  ls_stylerow-style     = lv_style.
  APPEND ls_stylerow TO lt_stylerow.

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'CHECK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT gt_out INTO ls_out.
        IF ls_out-style = lt_stylerow.
          CONTINUE.
        ENDIF.
        ls_out-check  = fu_check.
        MODIFY gt_out FROM ls_out TRANSPORTING check.
        CLEAR ls_out.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDSTYLE
*&---------------------------------------------------------------------*
FORM f_fieldstyle  USING    fu_fieldname fu_edit
                   CHANGING fc_style.
  DATA : ls_stylerow      TYPE lvc_s_styl,
         lv_style         TYPE lvc_s_styl-style,
         lt_main_stylerow TYPE lvc_t_styl.

  CLEAR : ls_stylerow.

  IF fu_edit IS INITIAL.
    lv_style      = cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.

  ls_stylerow-fieldname = fu_fieldname.
  ls_stylerow-style     = lv_style.

  INSERT ls_stylerow INTO TABLE lt_main_stylerow.
  fc_style  = lt_main_stylerow.
ENDFORM.                    " F_FIELDSTYLE

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA : return    TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0,
         ls_return TYPE bapiret2,
         ls_error  TYPE bapiret2.

  LOOP AT return INTO ls_return.
    IF ls_return-type = 'E'.
      ls_error-type       = ls_return-type.
      ls_error-id         = ls_return-id.
      ls_error-number     = ls_return-number.
      ls_error-message    = ls_return-message.
      ls_error-message_v1 = ls_return-message_v1.
      ls_error-message_v2 = ls_return-message_v2.
      ls_error-message_v3 = ls_return-message_v3.
      APPEND ls_error TO gt_error.
      CLEAR ls_error.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_LQUA
*&---------------------------------------------------------------------*
FORM f_get_lqua  TABLES  fu_marm
  USING  fu_index fu_matnr fu_lpmax

                 CHANGING fs_lqua TYPE lqua.

  DATA : lt_lqua  TYPE STANDARD TABLE OF lqua,
         ls_001a  LIKE LINE OF gt_001a,
         lv_subrc TYPE sy-subrc,
         ls_mlgn  LIKE LINE OF gt_mlgn,
         ls_lqua  LIKE LINE OF gt_lqua.
  DATA: lv_mod  TYPE i, lv_div TYPE i,
        lt_marm TYPE STANDARD TABLE OF marm INITIAL SIZE 0,
        ls_marm LIKE LINE OF lt_marm.

  CLEAR fs_lqua.
  lt_marm[] = fu_marm[].
  lt_lqua[] = gt_lqua[].
  SORT lt_lqua BY matnr lgnum.
  DELETE lt_lqua WHERE matnr <> fu_matnr.
  SORT lt_lqua BY vfdat verme wdatu.

  IF pa_lgnum(1) = 'C'.
    SORT gt_001a BY znou.
    LOOP AT gt_001a INTO ls_001a.
      lv_subrc = 4.
      LOOP AT lt_lqua INTO fs_lqua WHERE lgtyp = ls_001a-lgtyp.
        IF fu_lpmax IS NOT INITIAL AND fs_lqua-verme > fu_lpmax.
          fs_lqua-verme = fu_lpmax.
        ELSE.
          CLEAR ls_mlgn.
          READ TABLE gt_mlgn INTO ls_mlgn
                             WITH KEY matnr = fs_lqua-matnr.
          IF sy-subrc = 0.
            ls_lqua = fs_lqua.
            IF fs_lqua-verme > ls_mlgn-lhmg1.
              ls_lqua-verme = ls_mlgn-lhmg1.
            ELSE.
              IF pa_lgnum = 'C40'.
                SORT lt_marm BY matnr.
                READ TABLE lt_marm INTO ls_marm WITH KEY matnr = fs_lqua-matnr
                BINARY SEARCH.
                IF sy-subrc EQ 0.
                  lv_mod    = fs_lqua-verme MOD ls_marm-umrez.
                  lv_div    = fs_lqua-verme  DIV ls_marm-umrez.
                  IF lv_div NE 0.
                    "                    lv_subrc = 1.
                    CLEAR lv_subrc.
                    fs_lqua = ls_lqua.
                    EXIT.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
          CLEAR lv_subrc.
          "       EXIT.
        ENDIF.
      ENDLOOP.
      IF lv_subrc IS INITIAL.
        DELETE TABLE gt_lqua FROM fs_lqua.
        fs_lqua = ls_lqua.
        EXIT.
      ENDIF.
    ENDLOOP.
  ELSE.
    READ TABLE lt_lqua INTO fs_lqua INDEX fu_index.
    IF sy-subrc = 0.
      IF fu_lpmax IS NOT INITIAL AND fs_lqua-verme > fu_lpmax.
        fs_lqua-verme = fu_lpmax.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_SOURCE_BIN
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_C40
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data_c40 .
  DATA : lt_001       TYPE STANDARD TABLE OF zwmdt001 INITIAL SIZE 0,
         lt_lqua      TYPE STANDARD TABLE OF lqua INITIAL SIZE 0,
         ls_001       LIKE LINE OF gt_001,
         ls_lagp      LIKE LINE OF gt_lagp,
         ls_lqua      LIKE LINE OF gt_lqua,
         ls_out       LIKE LINE OF gt_out,
         ls_zwmdt001x LIKE LINE OF lt_zwmdt001x,
         lt_makt      TYPE STANDARD TABLE OF makt INITIAL SIZE 0,
         ls_makt      LIKE LINE OF lt_makt,
         lt_marm      TYPE STANDARD TABLE OF marm INITIAL SIZE 0,
         ls_marm      LIKE LINE OF lt_marm.

  DATA : lv_matnr TYPE lqua-matnr,
         lv_lgnum TYPE lqua-lgnum,
         lv_index TYPE sy-index,
         lv_lgtyp TYPE lqua-lgtyp,
         lv_mod   TYPE i, lv_div TYPE i.
  DATA: lv_nourut TYPE i.
  SELECT * INTO TABLE @DATA(lt_t331)
    FROM t331 WHERE lgnum = @pa_lgnum
                AND lgtyp = @pa_lgtyp.

  lt_001[]  = gt_001[].
  SORT lt_001 BY matnr lgnum.
  DELETE ADJACENT DUPLICATES FROM lt_001 COMPARING matnr lgnum.
  IF lt_001[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_makt FROM makt
      FOR ALL ENTRIES IN lt_001
      WHERE matnr = lt_001-matnr
       AND spras = sy-langu.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_marm FROM marm
      FOR ALL ENTRIES IN lt_001
      WHERE matnr = lt_001-matnr
        AND meinh = 'KAR'.
  ENDIF.
  lv_nourut = 0.
  LOOP AT lt_001 INTO ls_001.
    CLEAR : lv_matnr, lv_lgnum, lv_index, lt_lqua[], lt_lqua.
    lv_matnr  = ls_001-matnr.
    lv_lgnum  = ls_001-lgnum.
    CLEAR : ls_001.
    LOOP AT gt_001 INTO ls_001 WHERE matnr = lv_matnr
                                 AND lgnum = lv_lgnum.
      READ TABLE gt_lagp INTO ls_lagp WITH KEY lgnum = ls_001-lgnum
                                               lgtyp = ls_001-lgtyp
                                               lgpla = ls_001-lgpla01.
      IF sy-subrc = 0.
        ADD 1 TO lv_index.
*        IF lt_lqua[] IS INITIAL.
*          lt_lqua[] = gt_lqua[].
*          SORT lt_lqua BY matnr lgnum.
*          DELETE lt_lqua WHERE matnr <> ls_001-matnr.
*        ENDIF.
*        SORT lt_lqua BY vfdat verme wdatu.
*        READ TABLE lt_lqua INTO ls_lqua INDEX lv_index.
*        IF sy-subrc = 0.
*          IF ls_001-lpmax IS NOT INITIAL AND ls_lqua-verme > ls_001-lpmax.
*            ls_lqua-verme = ls_001-lpmax.
*          ENDIF.
        READ TABLE lt_zwmdt001x INTO ls_zwmdt001x WITH KEY lgnum = ls_001-lgnum
                                                           lgtyp = ls_001-lgtyp
                                                           lgpla = ls_001-lgpla01.
        IF sy-subrc = 0 AND ls_lagp-kzler NE 'X'.
          CONTINUE.
        ELSE.
          PERFORM f_get_lqua TABLES lt_marm
                              USING lv_index ls_001-matnr ls_001-lpmax
                             CHANGING ls_lqua.

          IF ls_lqua IS NOT INITIAL.

            "Cek kapasitas
            DATA(kapap) = VALUE #( lt_t331[ lgnum = pa_lgnum
                                            lgtyp = pa_lgtyp ]-kapap OPTIONAL ).
            DATA(lenvw) = VALUE #( lt_t331[ lgnum = pa_lgnum
                                            lgtyp = pa_lgtyp ]-lenvw OPTIONAL ).
            DATA(flg_neuer_let) = '1'.
            DATA(returncode) = sy-subrc.
            CLEAR: returncode.
*            PERFORM kapazitaetsberechnung(ll03af0s)
*              USING ls_lagp ls_lqua ls_ltap-werks ls_ltap-charg
*                    kapap lenvw ls_ltap-nsola ls_ltap-nsolm
*                    ls_ltap-altme ls_ltap-umrez ls_ltap-umren flg_neuer_let
*                    ls_ltap-letyp returncode hlp_menge refe_menge.
            IF returncode IS INITIAL.
*        IF sy-subrc = 0.
              "              CALL FUNCTION 'DIALOG_SET_NO_DIALOG'.

**              TRY.
**
**                      CALL FUNCTION 'L_TO_CREATE_SINGLE'
**                        EXPORTING
**                          i_lgnum               = pa_lgnum
**                          i_bwlvs               = '999'
**                          i_matnr               = ls_001-matnr
**                          i_werks               = ls_lqua-werks
**                          i_lgort               = ls_lqua-lgort
**                          i_charg               = ls_lqua-charg
**                          i_letyp               = 'SP'
**                          i_anfme               = ls_lqua-verme
**                          i_altme               = ls_lqua-meins
**                          i_squit               = space
**                          i_vltyp               = ls_lqua-lgtyp
**                          i_vlpla               = ls_lqua-lgpla
**                          i_nltyp               = pa_lgtyp
**                          i_nlpla               = ls_001-lgpla01
**                          i_commit_work         = 'X'
**                        IMPORTING
**                          e_tanum               = ls_out-tanum
**                        EXCEPTIONS
**                          no_to_created         = 1
**                          bwlvs_wrong           = 2
**                          betyp_wrong           = 3
**                          benum_missing         = 4
**                          betyp_missing         = 5
**                          foreign_lock          = 6
**                          vltyp_wrong           = 7
**                          vlpla_wrong           = 8
**                          vltyp_missing         = 9
**                          nltyp_wrong           = 10
**                          nlpla_wrong           = 11
**                          nltyp_missing         = 12
**                          rltyp_wrong           = 13
**                          rlpla_wrong           = 14
**                          rltyp_missing         = 15
**                          squit_forbidden       = 16
**                          manual_to_forbidden   = 17
**                          letyp_wrong           = 18
**                          vlpla_missing         = 19
**                          nlpla_missing         = 20
**                          sobkz_wrong           = 21
**                          sobkz_missing         = 22
**                          sonum_missing         = 23
**                          bestq_wrong           = 24
**                          lgber_wrong           = 25
**                          xfeld_wrong           = 26
**                          date_wrong            = 27
**                          drukz_wrong           = 28
**                          ldest_wrong           = 29
**                          update_without_commit = 30
**                          no_authority          = 31
**                          material_not_found    = 32
**                          lenum_wrong           = 33
**                          error_message         = 99
**                          OTHERS                = 34.
**
**                CATCH cx_root INTO DATA(lo_root_exception).
**              ENDTRY.
**              IF sy-subrc <> 0.
**"                RAISE returncode.
**              ENDIF.

              IF sy-subrc = 0.
                ls_out-lgnum  = pa_lgnum.
                ls_out-matnr  = ls_001-matnr.
                ls_out-werks  = ls_lqua-werks.
                ls_out-lgort  = ls_lqua-lgort.
                ls_out-charg  = ls_lqua-charg.
                ls_out-letyp  = 'SP'.
                ls_out-anfme  = ls_lqua-verme.
                ls_out-altme  = ls_lqua-meins.
                ls_out-vltyp  = ls_lqua-lgtyp.
                ls_out-vlpla  = ls_lqua-lgpla.
                ls_out-wdatu  = ls_lqua-wdatu.
                ls_out-nltyp  = pa_lgtyp.
                ls_out-nlpla  = ls_001-lgpla01.
                ls_out-ecer = ls_out-anfme.
                ls_out-uom_ecer = ls_out-altme.
                ls_out-uom_karton = 'KAR'.
                ADD 1 TO lv_nourut.
                ls_out-nourut = lv_nourut.
                SORT lt_makt BY matnr.
                READ TABLE lt_makt INTO ls_makt WITH KEY matnr = ls_out-matnr
                BINARY SEARCH.
                IF sy-subrc EQ 0.
                  ls_out-maktx = ls_makt-maktx.
                ELSE.
                  CLEAR:  ls_out-maktx.
                ENDIF.
                SORT lt_marm BY matnr.
                READ TABLE lt_marm INTO ls_marm WITH KEY matnr = ls_out-matnr
                BINARY SEARCH.
                IF sy-subrc EQ 0.
                  lv_mod    = ls_out-anfme MOD ls_marm-umrez.
                  lv_div    = ls_out-anfme  DIV ls_marm-umrez.
                  ls_out-karton = lv_div.
                  ls_out-ecer = lv_mod.
                  IF lv_div NE 0.
                    ls_out-anfme = lv_div * ls_marm-umrez.
                    CLEAR ls_out-ecer.
                  ENDIF.
                ENDIF.
                IF lv_div IS NOT INITIAL.
                  APPEND ls_out TO gt_out.
                ENDIF.
                CLEAR ls_out.
              ELSE.
**                IF lo_root_exception IS NOT INITIAL.
**                  sy-subrc = 34.
**                ENDIF.
              ENDIF.
            ENDIF.
            "           CALL FUNCTION 'DIALOG_SET_WITH_DIALOG'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
  "  PERFORM f_select USING ''. " 'MAIN'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_TO_C40
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_to_c40 .
  DATA: ls_out LIKE LINE OF gt_out.
  DATA: ls_out1 LIKE LINE OF gt_out.
  DATA: lt_out LIKE TABLE OF gt_out.
  DATA: lv_subrc TYPE sy-subrc.
  DATA: lv_message TYPE bapi_msg.
  FIELD-SYMBOLS <fs> TYPE any.
  FIELD-SYMBOLS <fs1> TYPE any.
  DATA : ls_fieldcatalog TYPE lvc_t_fcat WITH HEADER LINE,
         lv_style        TYPE lvc_s_styl-style,
         lt_stylerow     TYPE lvc_t_styl,
         ls_stylerow     TYPE lvc_s_styl.

  LOOP AT gt_out INTO ls_out WHERE check = 'X'.
    APPEND ls_out TO lt_out.
    "    MODIFY gt_out FROM ls_out TRANSPORTING style.
  ENDLOOP.
  IF lt_out[] IS NOT INITIAL.
    LOOP AT lt_out INTO ls_out.
      TRY.
          CALL FUNCTION 'L_TO_CREATE_SINGLE'
            EXPORTING
              i_lgnum               = pa_lgnum
              i_bwlvs               = '999'
              i_matnr               = ls_out-matnr
              i_werks               = ls_out-werks
              i_lgort               = ls_out-lgort
              i_charg               = ls_out-charg
              i_letyp               = 'SP'
              i_anfme               = ls_out-anfme
              i_altme               = ls_out-altme
              i_squit               = space
              i_vltyp               = ls_out-vltyp
              i_vlpla               = ls_out-vlpla
              i_nltyp               = ls_out-nltyp
              i_nlpla               = ls_out-nlpla
              i_commit_work         = 'X'
            IMPORTING
              e_tanum               = ls_out-tanum
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
              error_message         = 99
              OTHERS                = 34.
        CATCH cx_root INTO DATA(lo_root_exception).
      ENDTRY.
      IF lo_root_exception IS NOT INITIAL.
        CLEAR: ls_out-tanum.
        sy-subrc = 98.
      ENDIF.
      IF sy-subrc NE 0.
        TRY.
            lv_subrc = sy-subrc.
            CALL FUNCTION 'ZWMSFM002'
              EXPORTING
                pi_subrc    = lv_subrc
                pi_function = 'L_TO_CREATE_SINGLE'
              IMPORTING
                pe_message  = lv_message.
            ls_out-remark = lv_message.
          CATCH cx_root INTO DATA(lo_root_exception1).
        ENDTRY.
        IF lo_root_exception1 IS NOT INITIAL.
          CLEAR: ls_out-tanum.
          ls_out-remark = 'Error call function'.
        ENDIF.
      ELSE.
        CLEAR: ls_out-remark..
      ENDIF.
      "      ls_out-tanum = '123456'.
      MODIFY lt_out FROM ls_out TRANSPORTING tanum remark.
    ENDLOOP.

    LOOP AT lt_out INTO ls_out. " WHERE tanum IS NOT INITIAL.
      SORT gt_out BY nourut.
      READ TABLE gt_out ASSIGNING <fs> WITH KEY nourut = ls_out-nourut
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF ls_out-tanum IS NOT INITIAL.
          ASSIGN COMPONENT 'TANUM' OF STRUCTURE <fs> TO <fs1>.
          <fs1> = ls_out-tanum.
          ASSIGN COMPONENT 'CHECK' OF STRUCTURE <fs> TO <fs1>.
          <fs1> = '1'.
          ls_stylerow-fieldname = 'CHECK'.
          ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
          APPEND ls_stylerow TO ls_out-style.
          ASSIGN COMPONENT 'STYLE' OF STRUCTURE <fs> TO <fs1>.
          <fs1> = ls_out-style.
          ASSIGN COMPONENT 'REMARK' OF STRUCTURE <fs> TO <fs1>.
          <fs1> = ls_out-remark.
        ELSE.
          ASSIGN COMPONENT 'REMARK' OF STRUCTURE <fs> TO <fs1>.
          <fs1> = ls_out-remark.
        ENDIF.
      ENDIF.
    ENDLOOP.
    PERFORM f_alv_refresh USING 'X'.
    PERFORM f_select USING ' '.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_exit .
  LEAVE TO SCREEN 0.
ENDFORM.
