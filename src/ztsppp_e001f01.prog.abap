*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA: usergroups TYPE STANDARD TABLE OF usgroups,
        ls_groups  LIKE LINE OF usergroups.

  gv_authorization  = 'X'.
  gv_print  = '1'.

  CALL FUNCTION 'SUSR_USER_GROUP_GROUPS_GET'
    EXPORTING
      bname      = sy-uname
    TABLES
      usergroups = usergroups.

  LOOP AT usergroups INTO ls_groups.
    CASE ls_groups-usergroup.
      WHEN 'NOPASSWORD'.
        gv_npass = 'X'.
      WHEN 'DISPLAYWEIGHT'.
        gv_dispw = 'X'.
      WHEN 'NOWEIGH'.
        gv_nweig = 'X'.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  CASE sy-dynnr.
    WHEN '0101'.
      APPEND '&NEXT' TO fcode.
  ENDCASE.

  SET PF-STATUS 'PFSTATUS' EXCLUDING fcode.
  SET TITLEBAR 'TITLE01'.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_BEFORE_OUTPUT
*&---------------------------------------------------------------------*
FORM f_process_before_output .
  DATA : ls_rawmat LIKE LINE OF gt_rawmat,
         ls_006    LIKE LINE OF gt_006.

  CASE sy-dynnr.
    WHEN '0101'.
      PERFORM f_get_excluding_material.
      PERFORM f_get_order.
      PERFORM f_get_stock.

      IF gt_order[] IS INITIAL.
        IF gs_head-werks IS NOT INITIAL AND
          gs_head-gstrp IS NOT INITIAL AND
          gs_head-plnbez IS NOT INITIAL.
          PERFORM f_error_message USING 'E' 'Data not found' '' '' ''.
          CLEAR : gs_head-werks, gs_head-gstrp, gs_head-plnbez.
        ENDIF.

        APPEND INITIAL LINE TO gt_order.
        PERFORM f_modify_screen USING : 'ORD' '0' '' '' '',
                                        'NXT' '0' '' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'HED' '' '0' '' ''.
      ENDIF.

      DESCRIBE TABLE gt_order LINES n2.
      gv_order  = n2.

      IF gs_head-werks IS INITIAL.
        PERFORM f_cursor_position USING 'GS_HEAD-WERKS' ''.
      ELSEIF gs_head-plnbez IS INITIAL.
        PERFORM f_cursor_position USING 'GS_HEAD-PLNBEZ' ''.
      ELSEIF gs_head-gstrp IS INITIAL.
        PERFORM f_cursor_position USING 'GS_HEAD-GSTRP' ''.
      ELSE.
        PERFORM f_cursor_position USING 'GS_HEAD-POSNR' '1'.
      ENDIF.

    WHEN '0102'.
*      IF gv_ppifa IS INITIAL.
      PERFORM f_modify_screen USING : 'MAN' '0' '' '' ''.
*      ENDIF.

      PERFORM f_with_password.

      IF gs_weight-operator IS NOT INITIAL.
        IF gs_weight-pengawas IS INITIAL.
          PERFORM f_cursor_position USING 'GS_WEIGHT-PENGAWAS' ''.
        ELSEIF gs_weight-aufnr IS INITIAL.
          PERFORM f_cursor_position USING 'GS_WEIGHT-AUFNR' ''.
        ELSEIF gs_weight-wb IS INITIAL.
          PERFORM f_cursor_position USING 'GS_WEIGHT-WB' ''.
        ELSEIF gs_weight-equnr IS INITIAL.
          PERFORM f_cursor_position USING 'GS_WEIGHT-EQUNR' ''.
        ELSEIF gs_weight-rmmat IS INITIAL.
          PERFORM f_cursor_position USING 'GS_WEIGHT-MATERIAL' ''.
        ELSEIF gs_rawmat-charg IS NOT INITIAL.
          PERFORM f_cursor_position USING 'WEIGHT' ''.
        ENDIF.
      ENDIF.

      IF gs_weight-operator IS INITIAL OR
        gs_weight-pengawas IS INITIAL OR
        gs_weight-aufnr IS INITIAL.
        PERFORM f_modify_screen USING : 'FGM' '0' '' '' '',
                                        'WB' '0' '' '' '',
                                        'TIM' '0' '' '' '',
                                        'RMM' '0' '' '' '',
                                        'NXA' '0' '' '' '',
                                        'NXV' '0' '' '' '',
                                        'RM1' '0' '' '' '',
                                        'WGH' '0' '' '' '',
                                        'WG1' '0' '' '' ''.
      ENDIF.

      IF gv_weight IS INITIAL.
        PERFORM f_modify_screen USING : 'PRT' '0' '' '' ''.
      ENDIF.

      IF gs_weight-fgmat IS NOT INITIAL.
        IF gs_weight-operator IS NOT INITIAL AND
          gs_weight-pengawas IS NOT INITIAL.
          PERFORM f_modify_screen USING : 'OPR' '' '0' '' ''.
        ENDIF.
        IF gs_weight-wb IS NOT INITIAL.
          PERFORM f_modify_screen USING : 'WB' '' '0' '' ''.
        ENDIF.
        IF gs_weight-equnr IS NOT INITIAL.
          PERFORM f_modify_screen USING : 'TIM' '' '0' '' ''.
          LOOP AT gt_rawmat INTO ls_rawmat.
            IF ls_rawmat IS INITIAL.
              DELETE TABLE gt_rawmat FROM ls_rawmat.
            ENDIF.
          ENDLOOP.
          IF gs_weight-rmmat IS INITIAL.
            PERFORM f_modify_screen USING : 'NXV' '0' '' '' '',
                                            'RM1' '0' '' '' '',
                                            'WGH' '0' '' '' '',
                                            'WG1' '0' '' '' ''.
          ELSE.
            IF gt_rawmat[] IS INITIAL.
              PERFORM f_modify_screen USING : 'WGH' '0' '' '' '',
                                              'WG1' '0' '' '' ''.
            ELSE.
              IF gv_err_sanitasi IS INITIAL.
                PERFORM f_modify_screen USING : 'SAN' '' '0' '' ''.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          PERFORM f_modify_screen USING : 'RMM' '0' '' '' '',
                                          'RM1' '0' '' '' '',
                                          'NXA' '0' '' '' '',
                                          'NXV' '0' '' '' '',
                                          'WGH' '0' '' '' '',
                                          'WG1' '0' '' '' ''.
        ENDIF.
      ENDIF.

      CLEAR gs_weight-bdmng.
      IF gs_weight-rmmat IS NOT INITIAL.
        READ TABLE gt_006 INTO ls_006
                          WITH KEY werks = gs_head-werks
                                   matnr = gv_matnr.
        PERFORM f_exception_matnr USING ls_006-excty.
      ENDIF.

      IF gs_weight-bdmng IS INITIAL.
        PERFORM f_modify_screen USING : 'RM2' '0' '' '' ''.
      ENDIF.

      IF gv_char IS INITIAL.
        PERFORM f_modify_screen USING : 'IFA' '0' '' '' ''.
      ENDIF.

      IF gv_subrc = 10.
        PERFORM f_modify_screen USING : 'RMM' '' '0' '' ''.
      ENDIF.

      IF gv_err_sanitasi IS NOT INITIAL.
        gs_weight-message = gv_err_sanitasi.
        PERFORM f_modify_screen USING : 'RMM' '0' '' '' '',
                                        'RM1' '0' '' '' '',
                                        'RM2' '0' '' '' '',
                                        'NXA' '0' '' '' '',
                                        'NXV' '0' '' '' '',
                                        'WGH' '0' '' '' '',
                                        'WG1' '0' '' '' ''.
        CLEAR gv_err_sanitasi.
      ENDIF.

      IF gt_rawmat[] IS INITIAL.
        APPEND INITIAL LINE TO gt_rawmat.
      ENDIF.
      DESCRIBE TABLE gt_rawmat LINES n2.

    WHEN '1999'.
      PERFORM f_pbo99.
      IF gv_sanitasi = 'X'.
        PERFORM f_modify_screen USING : 'OPR' '0' '' '' ''.
        PERFORM f_modify_screen USING : 'OPS' '0' '' '' ''.
        IF gv_ocheck = 'X' OR gv_wcheck = 'X'.
          PERFORM f_modify_screen USING : 'F3B' '' '0' '' ''.
        ENDIF.
      ENDIF.

    WHEN '0104'.
      n1 = 1.
      DESCRIBE TABLE gt_sanitasi LINES n2.
      gs_head-from  = 1.
      CONDENSE gs_head-from NO-GAPS.
      gs_head-to    = n2.
      CONDENSE gs_head-to NO-GAPS.
      CLEAR gs_head-select.
      PERFORM f_cursor_position USING 'GS_HEAD-SELECT' ''.

    WHEN '0105'.
      IF gs_weights-operator IS NOT INITIAL.
        IF gs_weights-wb IS INITIAL.
          PERFORM f_cursor_position USING 'GS_WEIGHTS-WB' ''.
        ELSEIF gs_weights-equnr IS INITIAL.
          PERFORM f_cursor_position USING 'GS_WEIGHTS-EQUNR' ''.
        ENDIF.
      ENDIF.

      IF gs_weights-operator IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'OPR' '' '0' '' ''.
      ENDIF.

      IF gs_weights-wb IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'WB' '' '0' '' ''.
      ENDIF.

      IF gs_weights-equnr IS INITIAL.
        IF gs_weights-wb IS INITIAL.
          PERFORM f_modify_screen USING : 'TIM' '' '0' '' ''.
        ENDIF.
        PERFORM f_modify_screen USING : 'PRT' '' '0' '' ''.
        PERFORM f_modify_screen USING : 'STR' '' '0' '' ''.
        PERFORM f_modify_screen USING : 'VER' '' '0' '' ''.
        PERFORM f_modify_screen USING : 'END' '' '0' '' ''.
        PERFORM f_modify_screen USING : 'STI' '0' '' '' ''.
        PERFORM f_modify_screen USING : 'FTI' '0' '' '' ''.
        PERFORM f_modify_screen USING : 'WAS' '0' '' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'TIM' '' '0' '' ''.
        IF gs_weights-start IS INITIAL.
          PERFORM f_modify_screen USING : 'PRT' '' '0' '' ''.
          PERFORM f_modify_screen USING : 'VER' '' '0' '' ''.
          PERFORM f_modify_screen USING : 'END' '' '0' '' ''.
          PERFORM f_modify_screen USING : 'STI' '0' '' '' ''.
          PERFORM f_modify_screen USING : 'FTI' '0' '' '' ''.
          PERFORM f_modify_screen USING : 'WAS' '0' '' '' ''.
        ELSEIF gs_weights-finish IS INITIAL.
          PERFORM f_modify_screen USING : 'PRT' '' '0' '' ''.
          PERFORM f_modify_screen USING : 'STR' '' '0' '' ''.
          PERFORM f_modify_screen USING : 'VER' '' '0' '' ''.
          PERFORM f_modify_screen USING : 'FTI' '0' '' '' ''.
          PERFORM f_modify_screen USING : 'WAS' '0' '' '' ''.
        ELSEIF gs_weights-pengawas IS INITIAL.
          PERFORM f_modify_screen USING : 'PRT' '' '0' '' ''.
          PERFORM f_modify_screen USING : 'STR' '' '0' '' ''.
          PERFORM f_modify_screen USING : 'END' '' '0' '' ''.
          PERFORM f_modify_screen USING : 'WAS' '0' '' '' ''.
        ELSE.
          PERFORM f_modify_screen USING : 'STR' '' '0' '' ''.
          PERFORM f_modify_screen USING : 'VER' '' '0' '' ''.
          PERFORM f_modify_screen USING : 'END' '' '0' '' ''.
        ENDIF.
      ENDIF.

      IF gs_weights-matdes IS NOT INITIAL.
*        PERFORM f_modify_screen USING : 'STX' '' '0' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'STX' '0' '' '' ''.
      ENDIF.

      IF gs_weights-santol IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'STL' '' '0' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'STL' '0' '' '' ''.
      ENDIF.

      IF gs_weights-pengawas IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'WAS' '' '0' '' ''.
      ENDIF.

      IF gs_weights-lastmat IS INITIAL.
        PERFORM f_modify_screen USING : 'LMA' '0' '' '' ''.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_PROCESS_BEFORE_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_AFTER_INPUT
*&---------------------------------------------------------------------*
FORM f_process_after_input .
  DATA: ls_sanitasi LIKE LINE OF gt_sanitasi.

  CASE sy-dynnr.
    WHEN '0102'.
      IF gs_weight-material IS NOT INITIAL.
        gs_weight-scandt = sy-datum.
        gs_weight-scantm = sy-uzeit.
      ENDIF.
    WHEN '0104'.
*      IF gs_head-select IS NOT INITIAL.
*        CLEAR gs_head-message.
*        READ TABLE gt_sanitasi INTO ls_sanitasi
*                               WITH KEY posnr = gs_head-select.
*        IF sy-subrc = 0.
*          gs_head-maktx  = ls_sanitasi-maktx.
*        ENDIF.
*      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_PROCESS_AFTER_INPUT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm   TYPE sy-ucomm,
         ls_rawmat  LIKE LINE OF gt_rawmat,
         lv_meanval TYPE bapi2045d2-mean_value,
         ls_002     LIKE LINE OF gt_002.

  DATA : ls_xorder     LIKE LINE OF gt_xorder,
         ls_xoperation LIKE LINE OF gt_xoperation.

  DATA : lv_date(10), lv_time(8),
         lv_tvarv_val TYPE tvarv_val.

  lv_ucomm = ok_code.
  CLEAR ok_code.

  CASE sy-dynnr.
    WHEN '1999'.
      CASE lv_ucomm.
        WHEN '&NEXT'.
          PERFORM f_next99.

        WHEN '&OK'.
          PERFORM f_ok99.
      ENDCASE.

    WHEN OTHERS.
      CASE lv_ucomm.
        WHEN '&LOGOFF'.
          PERFORM f_clear_data USING ''.
          CLEAR gt_sanitasi.
          CALL 'SYST_LOGOFF'.

        WHEN '&NEXT'.
          CASE sy-dynnr.
            WHEN '0101'.
              PERFORM f_next_button.
            WHEN '0102'.
              CLEAR gv_err_sanitasi.
              PERFORM f_next_entry.
            WHEN '0103'.
              LEAVE TO SCREEN 0.
            WHEN '0104'.
              PERFORM f_next_sanitasi.
              LEAVE TO SCREEN 0.
            WHEN '0105'.
              PERFORM f_next_0105.
          ENDCASE.

        WHEN '&WEIGHT'.
          CLEAR gv_print.
          PERFORM f_get_weight USING 'X'.

        WHEN '&CLEAR'.
          CLEAR gv_tara.

        WHEN '&RAWMAT'.
          CLEAR : gs_weight-rmmat.

        WHEN '&BACK'.
          n1 = 1.
          CASE sy-dynnr.
            WHEN '0101'.
              IF gs_head IS INITIAL.
                CLEAR : gs_head.
                LEAVE TO SCREEN 0.
              ELSEIF gs_head-werks IS INITIAL
                AND gs_head-plnbez IS INITIAL.
                CLEAR : gs_head.
                LEAVE TO SCREEN 0.
              ELSE.
                CLEAR : gs_head.
              ENDIF.

            WHEN '0102'.
              CLEAR : gs_head-posnr, gv_print.
              PERFORM f_clear_data USING ''.
              CLEAR gt_sanitasi.
              LEAVE TO SCREEN 0.

            WHEN '0105'.
              CLEAR: gs_weights,gt_sanitasi,gs_sanitasi,gt_ztspppdt009,gs_ztspppdt009,
                     gs_ztspppdt007,gs_zppresb_add,gv_wuser,gv_sanitasi,gv_tools,
                     gv_wname,gv_wnrp,gv_wpass,gv_wcheck,gv_message.
              LEAVE TO SCREEN 0.
          ENDCASE.

        WHEN '&NXOPERATION'.
          IF gv_print IS INITIAL.
            READ TABLE gt_rawmat INTO ls_rawmat
                                 WITH KEY enmng = 0.
            IF sy-subrc = 0.
              gs_weight-message = 'Harus proses timbang dahulu'.
            ELSE.
              gs_weight-message = 'Harus print label dahulu'.
            ENDIF.
          ELSE.
            ls_xoperation-aufnr   = gs_weight-aufnr.
            ls_xoperation-matnr   = gs_weight-rmmat.
            ls_xoperation-vornr   = gs_weight-vornr.
            APPEND ls_xoperation TO gt_xoperation.
            CLEAR ls_xoperation.

            PERFORM f_next_operation USING gs_weight-rmmat 'X'
                                     CHANGING gs_weight-vornr gs_weight-posnr.

            CLEAR : gt_rawmat[], gs_rawmat,
                    gv_netto, gv_bruto, gv_tara, gv_nmein,
                    gv_tmein, gv_matnr.

            PERFORM f_next_entry.
          ENDIF.

        WHEN '&NXORDER'.
          IF gv_print IS INITIAL.
            READ TABLE gt_rawmat INTO ls_rawmat
                                 WITH KEY enmng = 0.
            IF sy-subrc = 0.
              gs_weight-message = 'Harus proses timbang dahulu'.
            ELSE.
              gs_weight-message = 'Harus print label dahulu'.
            ENDIF.
          ELSE.
            CLEAR : gv_netto, gv_bruto, gv_tara, gv_nmein,
                    gv_tmein, gv_matnr.

            gv_order = gv_order - 1.
*            IF gv_order < 0.
*              gs_weight-message = 'Order sudah selesai'.
*            ELSE.
            ls_xorder-aufnr   = gs_weight-aufnr.
            APPEND ls_xorder TO gt_xorder.
            CLEAR ls_xorder.

            PERFORM f_next_order CHANGING gs_weight-aufnr.
            CLEAR : gs_weight-rmmat, gs_weight-rmktx, gs_weight-vornr,
                    gs_weight-posnr, gs_weight-ltxa1, gt_rawmat[].
            PERFORM f_next_entry.
*            ENDIF.
          ENDIF.

        WHEN '&PPGUP'.
          PERFORM f_display_data USING '-'.

        WHEN '&PPGDN'.
          PERFORM f_display_data USING '+'.

        WHEN '&PRINT'.
          CASE sy-dynnr.
            WHEN '0105'.
              PERFORM f_print_sanitasi.
              LEAVE TO SCREEN 0.

            WHEN OTHERS.
              PERFORM f_cek_minmax_timbang USING    gs_weight-werks
                                                    gs_weight-equnr
                                                    gv_nmein
                                                    gv_bruto
                                           CHANGING gs_weight-message
                                                    gv_minmax.
              IF gv_minmax IS INITIAL.
                PERFORM f_prepare_print USING gv_print.
                PERFORM f_unlock_table.
                PERFORM f_modify_data TABLES gt_iresb gt_uresb gt_onr00
                                             gt_jest gt_jsto
                                      CHANGING gv_print.
              ELSE.
              ENDIF.
          ENDCASE.

        WHEN '&SANITASI'.
          gv_sanitasi = 'X'.
          PERFORM f_get_sanitasi.
          CLEAR gs_weight-message.
          CALL SCREEN 104.

        WHEN '&STR'.
          gs_weights-strdat = sy-datum.
          gs_weights-strtim = sy-uzeit.
          CLEAR: lv_date, lv_time.
          WRITE gs_weights-strdat TO lv_date.
          WRITE gs_weights-strtim TO lv_time.
          CONCATENATE lv_date lv_time
            INTO gs_weights-start SEPARATED BY '/'.

        WHEN '&END'.
          gv_tools = 'X'.
          gs_weights-findat = sy-datum.
          gs_weights-fintim = sy-uzeit.
          CLEAR: lv_date, lv_time.
          WRITE gs_weights-findat TO lv_date.
          WRITE gs_weights-fintim TO lv_time.
          CONCATENATE lv_date lv_time INTO gs_weights-finish
                                      SEPARATED BY '/'.

          SELECT SINGLE low INTO lv_tvarv_val
            FROM tvarvc WHERE name = 'SANITASI'.

          IF gs_weights-matdes NE lv_tvarv_val.
            PERFORM f_get_sanitasi.
            CLEAR gs_weight-message.
            SET SCREEN 104.
          ENDIF.

        WHEN '&VERI'.
          MOVE: gv_pengawas  TO gv_pengawass,
                gv_wuser     TO gv_wusers,
                gv_wname     TO gv_wnames,
                gv_wnrp      TO gv_wnrps,
                gv_wpass     TO gv_wpasss.
          CLEAR: gv_pengawas,gv_wuser,gv_wname,gv_wnrp,gv_wpass,gv_wcheck.
          IF sy-uname = 'TDS_DEV01'. "OR sy-uname = 'PPIFA'.
            gv_operator = '2022020008;Ifa'.
            gv_opass    = 'A12345'.
          ENDIF.

          CALL SCREEN 1999.

          IF gv_pass = 'X' AND gv_sanitasi = 'X'.
            gs_weights-pengawas = gv_pengawas.
            PERFORM f_get_last_material.
            PERFORM f_calc_validity.
          ENDIF.

        WHEN OTHERS.
          CASE sy-dynnr.
            WHEN '0101'.
            WHEN '0102'.
            WHEN '0104'.
            WHEN '0105'.
          ENDCASE.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_DATA
*&---------------------------------------------------------------------*
FORM f_clear_data USING fu_exclude.

  CASE fu_exclude.
    WHEN 'PRINT'.
      CLEAR : gs_weight-rmmat, gs_weight-rmktx,gs_weight-ltxa1,
              gt_rawmat[], gs_head-posnr, gv_weight, gv_netto,
              gv_bruto, gv_tara, gv_nmein, gv_tmein, gv_index,
              gv_reprint, gv_istad, gv_istau.

      PERFORM f_unlock_table.

    WHEN OTHERS.
      CLEAR : gs_weight, gt_rawmat[], gs_head-posnr, gv_weight, gv_netto,
              gv_bruto, gv_tara, gv_nmein, gv_tmein, gv_index, gv_reprint,
              gv_meanval.

      PERFORM f_unlock_table.
  ENDCASE.
ENDFORM.                    " F_CLEAR_DATA

*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_NEXT_ENTRY
*&---------------------------------------------------------------------*
FORM f_next_entry .
  DATA : lv_nrp(30),
         lv_name(30),
         ls_rawmat    LIKE LINE OF gt_rawmat.

  CLEAR gs_weight-message.

  IF gs_weight-operator IS NOT INITIAL AND
    gs_weight-pengawas IS NOT INITIAL.
    IF gs_weight-pengawas IS NOT INITIAL.
      SPLIT gs_weight-pengawas AT ';' INTO lv_nrp lv_name.
      IF lv_name IS NOT INITIAL.
        SPLIT lv_name AT space INTO gs_weight-pengawas lv_name.
        CONDENSE gs_weight-pengawas.
      ENDIF.
    ENDIF.

    IF gs_weight-bdmng IS INITIAL.
      IF gv_subrc = 10.
        CLEAR gv_subrc.
      ENDIF.

      LOOP AT gt_rawmat INTO ls_rawmat.
        IF ls_rawmat-clabs < ls_rawmat-enmng.
          gv_subrc = 10.
          gs_weight-message = 'Jumlah timbang lebih dari stock'.
          CLEAR : gs_weight-material, gv_weight.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF gs_weight-aufnr IS NOT INITIAL.
      PERFORM f_conversion_exit_alpha USING ''
                                      CHANGING gs_weight-aufnr.
      PERFORM f_get_process_order.
      IF gs_weight-message IS INITIAL.
        PERFORM f_get_timbangan.
      ENDIF.
      IF gs_weight-message IS INITIAL.
        PERFORM f_get_rawmat.
      ENDIF.
    ENDIF.

*    IF gv_ppifa IS NOT INITIAL.
*      CLEAR gv_ppifa.
*      PERFORM f_get_weight USING ''.
*    ENDIF.
  ELSEIF gs_weight-operator IS INITIAL AND
    gs_weight-pengawas IS INITIAL.
    gs_weight-message = 'Operator / Pengawas harus diisi'.
  ELSEIF gs_weight-operator IS NOT INITIAL.
    SPLIT gs_weight-operator AT ';' INTO lv_nrp lv_name.
    IF lv_name IS NOT INITIAL.
      SPLIT lv_name AT space INTO gs_weight-operator lv_name.
      CONDENSE gs_weight-operator.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_NEXT_ENTRY

*&---------------------------------------------------------------------*
*&      Form  F_GET_PROCESS_ORDER
*&---------------------------------------------------------------------*
FORM f_get_process_order .
  CLEAR gt_component[].
  PERFORM f_procord_get_detail USING gs_weight-aufnr.
ENDFORM.                    " F_GET_PROCESS_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_PROCORD_GET_DETAIL
*&---------------------------------------------------------------------*
FORM f_procord_get_detail USING fu_aufnr.
  DATA : lt_header        TYPE TABLE OF bapi_order_header1,
         lt_position      TYPE TABLE OF bapi_order_item,
         lt_sequence      TYPE TABLE OF bapi_order_sequence,
         lt_phase         TYPE TABLE OF bapi_order_phase,
         lt_trigger_point TYPE TABLE OF bapi_order_trigger_point,
         lt_prod_rel_tool TYPE TABLE OF bapi_order_prod_rel_tools.

  DATA : ls_order_objects TYPE bapi_pi_order_objects,
         ls_return        TYPE bapiret2,
         ls_header        LIKE LINE OF lt_header,
         ls_resb          LIKE LINE OF gt_resb,
         ls_component     LIKE LINE OF gt_component,
         ls_order         LIKE LINE OF gt_order,
         ls_jest          TYPE jest.

  DATA : lv_aufnr TYPE caufv-aufnr,
         lv_objnr TYPE jest-objnr.

  LOOP AT gt_resb INTO ls_resb.
    ls_component  = ls_resb.
    APPEND ls_component TO gt_component.
    CLEAR ls_component.
  ENDLOOP.

  READ TABLE gt_order INTO ls_order
                      WITH KEY aufnr = fu_aufnr.

  IF sy-subrc = 0.
    CONCATENATE 'OR' gs_weight-aufnr INTO lv_objnr.
    SELECT SINGLE *
      FROM jest
      INTO CORRESPONDING FIELDS OF ls_jest
      WHERE objnr = lv_objnr
        AND stat  = 'E0002'
        AND inact = space.
    IF sy-subrc = 0.
      gs_weight-werks   = ls_order-werks.
      gs_weight-fgmat   = ls_order-plnbez.
      SELECT SINGLE maktx
        FROM makt
        INTO gs_weight-fgktx
        WHERE matnr = ls_order-plnbez.
      gs_weight-charg   = ls_order-fcharg.
      PERFORM f_validate_component.
    ELSE.
      PERFORM f_conversion_exit_alpha USING gs_weight-aufnr
                                      CHANGING lv_aufnr.
      CONCATENATE 'Process order' lv_aufnr 'belum release'
      INTO gs_weight-message SEPARATED BY space.
      CLEAR gs_weight-aufnr.
    ENDIF.
  ENDIF.
*  ELSE.
*    gs_weight-message = ls_return-message.
*    CLEAR gs_weight-aufnr.
*  ENDIF.
ENDFORM.                    " F_PROCORD_GET_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_CURSOR_POSITION
*&---------------------------------------------------------------------*
FORM f_cursor_position USING    fu_field fu_pos.
  SET CURSOR FIELD fu_field LINE fu_pos.
ENDFORM.                    " F_CURSOR_POSITION

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_required.
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

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_EXIT_ALPHA
*&---------------------------------------------------------------------*
FORM f_conversion_exit_alpha  USING    fu_value
                              CHANGING fc_value.

  IF fu_value IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = fc_value
      IMPORTING
        output = fc_value.
  ELSE.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = fu_value
      IMPORTING
        output = fc_value.

  ENDIF.
ENDFORM.                    " F_CONVERSION_EXIT_ALPHA

*&---------------------------------------------------------------------*
*&      Form  F_GET_TIMBANGAN
*&---------------------------------------------------------------------*
FORM f_get_timbangan .
  IF gs_weight-equnr IS NOT INITIAL.
    PERFORM f_conversion_exit_alpha USING ''
                                    CHANGING gs_weight-equnr.
    PERFORM f_get_equipment.
  ENDIF.
ENDFORM.                    " F_GET_TIMBANGAN

*&---------------------------------------------------------------------*
*&      Form  F_GET_EQUIPMENT
*&---------------------------------------------------------------------*
FORM f_get_equipment .
  DATA : e_equi_header TYPE alm_me_tob_header,
         return        TYPE STANDARD TABLE OF bapiret2.

  DATA : ls_return        LIKE LINE OF return.

  DATA : lv_equnr         TYPE equi-equnr.

  SELECT *
    FROM ztnpppdt002
    INTO CORRESPONDING FIELDS OF TABLE gt_002
    WHERE equnr = gs_weight-equnr
    ORDER BY PRIMARY KEY.
  IF sy-subrc = 0.
    CALL FUNCTION 'ALM_ME_EQUIPMENT_GETDETAIL'
      EXPORTING
        i_equipment    = gs_weight-equnr
      IMPORTING
        e_equi_header  = e_equi_header
      TABLES
        return         = return
      EXCEPTIONS
        not_successful = 1
        OTHERS         = 2.

    READ TABLE return INTO ls_return
                      WITH KEY type = 'E'.
    IF sy-subrc = 0.
      PERFORM f_conversion_exit_alpha USING gs_weight-equnr
                                      CHANGING lv_equnr.
      CONCATENATE 'Timbangan belum terdaftar' lv_equnr
      INTO gs_weight-message
      SEPARATED BY space.
      CLEAR gs_weight-equnr.
    ELSE.
      IF gs_weight-werks <> e_equi_header-swerk.
        CONCATENATE 'Timbangan bukan untuk Plant' gs_weight-werks
        INTO gs_weight-message
        SEPARATED BY space.
        CLEAR gs_weight-equnr.
      ELSE.
        gs_weight-shtxt   = e_equi_header-shtxt.
        SELECT SINGLE print_dest
          FROM adr10
          INTO gv_print_dest
          WHERE addrnumber = e_equi_header-adrnr.

        SELECT SINGLE remark
          FROM adrt
          INTO gv_remark
          WHERE addrnumber = e_equi_header-adrnr
            AND comm_type  = 'URI'.
*{   REPLACE        P01K910795                                        1
*\
*\        SELECT SINGLE uri_addr
*\          FROM adr12
*\          INTO gv_uri_addr
*\          WHERE addrnumber = e_equi_header-adrnr.
        "Start SOH: Shell SCI Adjustment 20240402 KRS
        DATA lv_uri_length TYPE adr12-uri_length.
        CLEAR: lv_uri_length, gv_uri_addr.
        SELECT SINGLE uri_length uri_addr
          FROM adr12
          INTO (lv_uri_length, gv_uri_addr)
          WHERE addrnumber = e_equi_header-adrnr.
        "End SOH: Shell SCI Adjustment 20240402 KRS
*}   REPLACE

        gv_eqfnr  = e_equi_header-eqfnr.
      ENDIF.
    ENDIF.
  ELSE.
    PERFORM f_conversion_exit_alpha USING gs_weight-equnr
                                    CHANGING lv_equnr.
    CONCATENATE 'Timbangan belum terdaftar' lv_equnr
    INTO gs_weight-message
    SEPARATED BY space.
    CLEAR gs_weight-equnr.
  ENDIF.
ENDFORM.                    " F_GET_EQUIPMENT

*&---------------------------------------------------------------------*
*&      Form  F_GET_RAWMAT
*&---------------------------------------------------------------------*
FORM f_get_rawmat .
  DATA : ls_002     LIKE LINE OF gt_002.

  DATA : lv_space(50),
         lv_equnr     TYPE equi-equnr,
         lv_vornr     TYPE resb-vornr,
         lv_posnr     TYPE resb-posnr,
         ls_rawmat    LIKE LINE OF gt_rawmat,
         lv_subrc     TYPE sy-subrc,
         lv_lgort     TYPE mchb-lgort.

  IF gs_weight-material IS NOT INITIAL.
    CLEAR : gv_matnr, gv_charg, gs_head-message.
    IF gs_weight-message IS INITIAL.
      SPLIT gs_weight-material AT ';' INTO gv_matnr gv_charg lv_space.
      IF gv_authorization IS NOT INITIAL.
*        PERFORM f_check_lock_entry USING 'AUFK'
*                                   CHANGING lv_subrc.
*        IF lv_subrc = 0.
*        PERFORM f_check_lock_entry USING 'MCH1'
*                                   CHANGING lv_subrc.
        PERFORM f_check_lock_entry USING 'MCHB'
                                   CHANGING lv_subrc lv_lgort.
        IF lv_subrc = 0.
          PERFORM f_lock_table USING : 'AUFK' '',
                                       'MCHB' lv_lgort.
        ELSE.
          CLEAR : gv_matnr.
        ENDIF.
*        ELSE.
*          CLEAR : gv_matnr.
*        ENDIF.
      ENDIF.
    ENDIF.

    IF gs_weight-message IS INITIAL.
      IF gs_weight-rmmat IS NOT INITIAL.
        IF gs_weight-rmmat <> gv_matnr.
          gs_weight-message = 'Material yang ditimbang berbeda'.
          CLEAR gs_weight-material.
        ENDIF.
      ENDIF.
    ENDIF.

    IF gs_weight-bdmng IS INITIAL.
      IF gv_subrc = 10.
        CLEAR gv_subrc.
      ENDIF.

      IF gs_weight-message IS INITIAL.
        CLEAR ls_rawmat.
        LOOP AT gt_rawmat INTO ls_rawmat.
          IF ls_rawmat-clabs < ls_rawmat-enmng.
            gv_subrc = 10.
            gs_weight-message = 'Jumlah timbang lebih dari stock'.
            CLEAR : gs_weight-material, gv_weight.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF gs_weight-message IS INITIAL.
      CLEAR ls_002.
      READ TABLE gt_002 INTO ls_002
                        WITH KEY matnr = gv_matnr
                                 werks = gs_weight-werks.
      IF sy-subrc = 0.
        CLEAR : gs_weight-material.
        IF gv_istad IS INITIAL.
          gv_istad  = sy-datum.
          gv_istau  = sy-uzeit.
        ENDIF.

        PERFORM f_printer_check.

        IF gs_weight-message IS INITIAL.
          IF ls_002-factor IS NOT INITIAL.
            PERFORM f_material_factor USING gv_matnr gv_charg gs_weight-werks
                                      CHANGING gv_meanval.
          ELSE.
            gv_meanval = 1.
          ENDIF.

          PERFORM f_next_operation USING gv_matnr ''
                                   CHANGING lv_vornr lv_posnr.

          PERFORM f_cek_batch USING gv_matnr gv_charg lv_posnr.

          IF gs_weight-message IS INITIAL.
            PERFORM f_display_rawmat USING gv_matnr gv_charg gv_lgort
                                           gv_meanval lv_vornr ls_002-factor.
          ENDIF.
        ENDIF.
      ELSE.
        PERFORM f_conversion_exit_alpha USING gs_weight-equnr
                                        CHANGING lv_equnr.
        CONCATENATE 'Material' gv_matnr 'tidak bisa ditimbang di' lv_equnr
        INTO gs_weight-message
        SEPARATED BY space.
        CLEAR gs_weight-material.
      ENDIF.
    ENDIF.

    IF gs_weight-message IS INITIAL.
      PERFORM f_check_sanitasi.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_RAWMAT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_COMPONENT
*&---------------------------------------------------------------------*
FORM f_validate_component .
  TYPES : BEGIN OF ty_mara,
            matnr TYPE mara-matnr,
            meins TYPE mara-meins,
          END OF ty_mara.

  DATA : lt_x         TYPE STANDARD TABLE OF resb,
         ls_x         LIKE LINE OF lt_x,
         lt_y         TYPE TABLE OF bapi_order_component,
         ls_y         LIKE LINE OF lt_y,
         ls_component LIKE LINE OF gt_component,
         lt_mara      TYPE STANDARD TABLE OF ty_mara,
         ls_mara      LIKE LINE OF lt_mara,
         lt_mchb      TYPE STANDARD TABLE OF mchb,
         ls_xresb     LIKE LINE OF gt_xresb,
         ls_yresb     LIKE LINE OF gt_yresb.

  lt_x[]  = gt_component[].
  SORT lt_x BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM lt_x COMPARING matnr werks.
  IF lt_x[] IS NOT INITIAL.
    SELECT marc~matnr mara~meins
      FROM marc JOIN mara ON marc~matnr = mara~matnr
      INTO TABLE lt_mara
      FOR ALL ENTRIES IN lt_x
      WHERE marc~matnr = lt_x-matnr
        AND marc~werks = lt_x-werks
        AND mara~mtart IN ('ZRM', 'ZSFG').
  ENDIF.

  LOOP AT gt_component INTO ls_component.
    CLEAR ls_mara.
    READ TABLE lt_mara INTO ls_mara
                       WITH KEY matnr = ls_component-matnr.
    IF sy-subrc <> 0.
      DELETE TABLE gt_component FROM ls_component.
    ENDIF.
  ENDLOOP.

  CLEAR lt_x[].
  lt_x[]  = gt_component[].
  SORT lt_x BY werks matnr lgort charg.
  DELETE ADJACENT DUPLICATES FROM lt_x COMPARING werks matnr lgort charg.
  IF lt_x[] IS NOT INITIAL.
    SELECT *
      FROM mchb
      INTO CORRESPONDING FIELDS OF TABLE gt_mchb
      FOR ALL ENTRIES IN lt_x
      WHERE matnr = lt_x-matnr
        AND werks = lt_x-werks
        AND lgort = lt_x-lgort
        AND lvorm = space
        AND clabs <> 0
      ORDER BY PRIMARY KEY.

    lt_mchb[] = gt_mchb[].
    SORT lt_mchb BY matnr werks charg.
    DELETE ADJACENT DUPLICATES FROM lt_mchb COMPARING matnr werks charg.
    IF lt_mchb[] IS NOT INITIAL.
      SELECT *
        FROM resb
        INTO CORRESPONDING FIELDS OF TABLE gt_yresb
        FOR ALL ENTRIES IN lt_mchb
        WHERE matnr = lt_mchb-matnr
          AND werks = lt_mchb-werks
          AND charg = lt_mchb-charg
*          AND wempf IN ('W', 'T')
          AND bwart = gv_261
          AND kzear = space
          AND xloek = space
        ORDER BY PRIMARY KEY.

*      LOOP AT gt_xresb INTO ls_xresb.
*        READ TABLE gt_yresb INTO ls_yresb
*                            WITH KEY aufnr = ls_xresb-aufnr.
*        IF sy-subrc = 0.
*          DELETE gt_yresb WHERE aufnr = ls_xresb-aufnr.
*        ENDIF.
*      ENDLOOP.
    ENDIF.
  ENDIF.

  SORT lt_x BY matnr charg.
  DELETE ADJACENT DUPLICATES FROM lt_x COMPARING matnr charg.
  IF lt_x[] IS NOT INITIAL.
    SELECT *
      FROM mch1
      INTO CORRESPONDING FIELDS OF TABLE gt_mch1
      FOR ALL ENTRIES IN lt_x
      WHERE matnr = lt_x-matnr
        AND lvorm = space
      ORDER BY PRIMARY KEY.
  ENDIF.
ENDFORM.                    " F_VALIDATE_COMPONENT

*&---------------------------------------------------------------------*
*&      Form  F_CEK_BATCH
*&---------------------------------------------------------------------*
FORM f_cek_batch  USING    fu_matnr fu_charg fu_posnr.
  DATA : ls_mch1      LIKE LINE OF gt_mch1,
         ls_mchb      LIKE LINE OF gt_mchb,
         ls_component LIKE LINE OF gt_component.

  CLEAR : ls_mch1, gv_lgort.
  READ TABLE gt_mch1 INTO ls_mch1
                     WITH KEY matnr = fu_matnr
                              charg = fu_charg.
  IF sy-subrc = 0.
    IF ls_mch1-vfdat = '00000000'.
      CONCATENATE 'Tanggal expired untuk Batch' fu_charg 'masih kosong'
      INTO gs_weight-message
      SEPARATED BY space.
    ELSEIF ls_mch1-vfdat < sy-datum.
      CONCATENATE 'Bacth' fu_charg 'expired'
      INTO gs_weight-message
      SEPARATED BY space.
    ELSE.
      CLEAR ls_component.
      READ TABLE gt_component INTO ls_component
                              WITH KEY matnr = fu_matnr
                                       aufnr = gs_weight-aufnr
                                       posnr = fu_posnr.
      IF sy-subrc = 0.
        CLEAR ls_mchb.
        READ TABLE gt_mchb INTO ls_mchb
                           WITH KEY matnr = fu_matnr
                                    lgort = ls_component-lgort
                                    charg = fu_charg.
        IF sy-subrc = 0.
          gs_rawmat-charg = fu_charg.
          gv_lgort        = ls_component-lgort.
          PERFORM f_uom_conversion USING fu_matnr ls_component-erfme
                                         ls_component-meins ls_mchb-clabs
                                   CHANGING ls_mchb-clabs.

          gs_rawmat-clabs = ls_mchb-clabs.
        ELSE.
          CONCATENATE 'Tidak ada stock untuk batch' fu_charg 'material' fu_matnr
          INTO gs_weight-message
          SEPARATED BY space.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    CONCATENATE 'Batch' fu_charg 'untuk material' fu_matnr 'tidak ditemukan'
    INTO gs_weight-message
    SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_CEK_BATCH

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_RAWMAT
*&---------------------------------------------------------------------*
FORM f_display_rawmat  USING    fu_matnr fu_charg fu_lgort fu_meanval fu_vornr
                                fu_factor.
  DATA : ls_rawmat LIKE LINE OF gt_rawmat,
         ls_006    LIKE LINE OF gt_006,
         lv_count  TYPE i,
         ls_xresb  LIKE LINE OF gt_xresb,
         ls_yresb  LIKE LINE OF gt_yresb,
         lv_index  TYPE i,
         lv_subrc  TYPE sy-subrc,
         lv_clabs  TYPE mchb-clabs,
         lv_lines  TYPE i,
         lv_bdmng  TYPE p DECIMALS 4,
         lv_enmng  TYPE resb-enmng,
         lv_erfmg  TYPE resb-erfmg,
         lv_enmng1 TYPE resb-enmng.

  CLEAR : gs_rawmat-enmng.

  IF gs_weight-message IS INITIAL.
    lv_subrc          = 4.
    IF gv_index IS INITIAL.
      gv_index = 1.
    ENDIF.
    gs_weight-rmmat   = fu_matnr.

    SELECT *
      FROM marm
      INTO CORRESPONDING FIELDS OF TABLE gt_marm
      WHERE matnr = fu_matnr
      ORDER BY PRIMARY KEY.

    SELECT SINGLE maktx meins
      FROM mara JOIN makt ON mara~matnr = makt~matnr
      INTO (gs_weight-rmktx, gs_weight-meins)
      WHERE makt~spras = sy-langu
        AND mara~matnr = fu_matnr.

    gs_rawmat-matnr  = fu_matnr.
    gs_rawmat-charg  = fu_charg.
    gs_weight-vornr  = fu_vornr.

    CLEAR ls_xresb.
    LOOP AT gt_xresb INTO ls_xresb WHERE aufnr = gs_weight-aufnr
                                     AND matnr = fu_matnr
                                     AND vornr = fu_vornr.
      IF ls_xresb-vmeng IS NOT INITIAL.
        IF fu_meanval IS NOT INITIAL.
*          ls_xresb-vmeng = ls_xresb-vmeng * fu_meanval.
          ls_xresb-erfmg = ls_xresb-erfmg * fu_meanval.
        ENDIF.
        IF ls_xresb-charg = space.
          ADD 1 TO lv_index.
          gs_rawmat-rsnum     = ls_xresb-rsnum.
          gs_rawmat-rspos     = ls_xresb-rspos.
          gs_rawmat-bdmng     = ls_xresb-erfmg - ls_xresb-enmng. "ls_xresb-vmeng.

          LOOP AT gt_006 INTO ls_006.
            CASE ls_006-excty.
              WHEN 'R'.
                IF fu_factor IS NOT INITIAL.
                  PERFORM f_modify_required_qty USING ls_006-werks ls_006-matnr gs_rawmat-matnr
                                                      gs_weight-aufnr ls_xresb-posnr
                                                CHANGING gs_rawmat-bdmng.
                ENDIF.
            ENDCASE.
          ENDLOOP.

*          PERFORM f_modify_required_qty USING '0101' 'R0605' gs_rawmat-matnr gs_weight-aufnr
*                                              ls_xresb-posnr
*                                        CHANGING gs_rawmat-bdmng.
*          PERFORM f_modify_required_qty USING '0102' 'R1318' gs_rawmat-matnr gs_weight-aufnr
*                                              ls_xresb-posnr
*                                        CHANGING gs_rawmat-bdmng.
*          PERFORM f_modify_required_qty USING '0102' 'R0503' gs_rawmat-matnr gs_weight-aufnr
*                                              ls_xresb-posnr
*                                        CHANGING gs_rawmat-bdmng.

          gs_rawmat-meins     = ls_xresb-erfme.
          gs_rawmat-meanval   = gv_meanval.
          gs_rawmat-meantyp   = 'F'.
          gs_weight-posnr     = ls_xresb-posnr.
          PERFORM f_get_description USING ls_xresb-rsnum ls_xresb-rspos ls_xresb-vornr
                                    CHANGING gs_weight-ltxa1.
          IF lv_index = gv_index.
            CLEAR lv_subrc.
            EXIT.
          ENDIF.
        ELSEIF ls_xresb-charg = fu_charg.
*          ADD ls_xresb-vmeng TO lv_clabs.
        ELSE.
          CLEAR lv_subrc.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CLEAR ls_yresb.
    LOOP AT gt_yresb INTO ls_yresb WHERE matnr = fu_matnr
                                     AND charg = fu_charg
                                     AND lgort = fu_lgort.

      PERFORM f_uom_conversion USING '' ls_yresb-erfme
                                     gs_rawmat-meins ls_yresb-erfmg
                               CHANGING lv_erfmg.

      ADD lv_erfmg TO lv_clabs.
*      ADD ls_yresb-erfmg TO lv_clabs.
    ENDLOOP.

    IF lv_subrc = 0.
      LOOP AT gt_rawmat INTO ls_rawmat.
        IF ls_rawmat IS INITIAL.
          DELETE TABLE gt_rawmat FROM ls_rawmat.
          CONTINUE.
        ENDIF.
        IF ls_rawmat-enmng IS INITIAL.
          ADD 1 TO lv_count.
        ENDIF.

        PERFORM f_matnr_pc USING '2' ls_rawmat-enmng ls_rawmat-enmng2 ''
                           CHANGING lv_enmng1.

        ADD lv_enmng1 TO lv_enmng.
        lv_bdmng  = ( ls_rawmat-bdmng - lv_enmng1 ).  " / ls_rawmat-meanval.
      ENDLOOP.

      lv_bdmng  = lv_bdmng * gv_meanval.

      LOOP AT gt_006 INTO ls_006.
        CASE ls_006-excty.
          WHEN 'R'.
            PERFORM f_modify_required_qty USING ls_006-werks ls_006-matnr gs_rawmat-matnr gs_weight-aufnr
                                                gs_weight-posnr
                                          CHANGING lv_bdmng.
        ENDCASE.
      ENDLOOP.

*      PERFORM f_modify_required_qty USING '0101' 'R0605' gs_rawmat-matnr
*                                          gs_weight-aufnr gs_weight-posnr
*                                    CHANGING lv_bdmng.
*      PERFORM f_modify_required_qty USING '0102' 'R1318' gs_rawmat-matnr
*                                          gs_weight-aufnr gs_weight-posnr
*                                    CHANGING lv_bdmng.
*      PERFORM f_modify_required_qty USING '0102' 'R0503' gs_rawmat-matnr
*                                          gs_weight-aufnr gs_weight-posnr
*                                    CHANGING lv_bdmng.

      IF lv_count > 0.
        gs_weight-message = 'Harus proses timbang dahulu'.
        CLEAR gs_weight-material.
      ELSE.
        gs_rawmat-clabs = gs_rawmat-clabs - lv_clabs.
        DESCRIBE TABLE gt_rawmat LINES lv_lines.
        IF lv_lines > 0.
          IF fu_factor IS INITIAL.
            ls_rawmat-bdmng = lv_bdmng + lv_enmng.
            LOOP AT gt_006 INTO ls_006.
              CASE ls_006-excty.
                WHEN 'R'.
                  PERFORM f_modify_required_qty USING ls_006-werks ls_006-matnr gs_rawmat-matnr gs_weight-aufnr
                                                      gs_weight-posnr
                                                CHANGING ls_rawmat-bdmng.
              ENDCASE.
            ENDLOOP.
            gs_rawmat-bdmng = lv_bdmng.
          ELSE.
            ls_rawmat-bdmng2 = ( ls_rawmat-bdmng - ls_rawmat-enmng ) / ls_rawmat-meanval.
            gs_rawmat-bdmng = ls_rawmat-bdmng2 * gv_meanval.
            LOOP AT gt_006 INTO ls_006.
              CASE ls_006-excty.
                WHEN 'R'.
                  PERFORM f_modify_required_qty USING ls_006-werks ls_006-matnr gs_rawmat-matnr gs_weight-aufnr
                                                      gs_weight-posnr
                                                CHANGING gs_rawmat-bdmng.
              ENDCASE.
            ENDLOOP.
            ls_rawmat-bdmng = ls_rawmat-enmng + gs_rawmat-bdmng.
          ENDIF.

*          PERFORM f_modify_required_qty USING '0101' 'R0605' gs_rawmat-matnr
*                                              gs_weight-aufnr gs_weight-posnr
*                                        CHANGING ls_rawmat-bdmng.
*          PERFORM f_modify_required_qty USING '0102' 'R1318' gs_rawmat-matnr
*                                              gs_weight-aufnr gs_weight-posnr
*                                        CHANGING ls_rawmat-bdmng.
*          PERFORM f_modify_required_qty USING '0102' 'R0503' gs_rawmat-matnr
*                                              gs_weight-aufnr gs_weight-posnr
*                                        CHANGING ls_rawmat-bdmng.

          MODIFY gt_rawmat FROM ls_rawmat INDEX 1
                           TRANSPORTING bdmng meins.
        ENDIF.
        IF gs_rawmat-clabs = 0.
          gs_weight-message = 'Stock tidak ada'.
          CLEAR : gs_weight-material, gs_weight-rmmat, gs_weight-rmktx.
        ELSE.
          APPEND gs_rawmat TO gt_rawmat.
        ENDIF.
      ENDIF.
    ELSE.
      CONCATENATE 'Material' fu_matnr 'batch' fu_charg 'tidak untuk operation' gs_weight-vornr
      INTO gs_weight-message
      SEPARATED BY space.
      CLEAR : gs_weight-material, gs_weight-rmmat, gs_weight-rmktx.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DISPLAY_RAWMAT

*&---------------------------------------------------------------------*
*&      Form  F_GET_WEIGHT
*&---------------------------------------------------------------------*
FORM f_get_weight USING fu_weight.
  DATA : status   TYPE extcmdexex-status,
         exitcode	TYPE extcmdexex-exitcode.

  DATA : iserveroutput    TYPE STANDARD TABLE OF btcxpm,
         ls_iserveroutput LIKE LINE OF iserveroutput,
         lt_char          TYPE STANDARD TABLE OF string.

  DATA : ls_xresb    LIKE LINE OF gt_xresb,
         lv_char     TYPE zchar1500,
         lv_meins    TYPE mara-meins,
         lv_xmein    TYPE mara-meins,
         lv_enmng    TYPE resb-enmng,
         lv_total    TYPE resb-enmng,
         lv_bdmng    TYPE resb-bdmng,
         lv_netto    TYPE resb-bdmng,
         commandname TYPE sxpgcolist-name,
         add_param   TYPE sxpgcolist-parameters,
         ls_rawmat   LIKE LINE OF gt_rawmat,
         lv_lines    TYPE i,
         lv_count    TYPE i,
         lv_clabs    TYPE mard-labst.

  IF gv_subrc = 10.
    CLEAR gv_subrc.
  ENDIF.

  commandname  = gv_remark.
  CONCATENATE gv_uri_addr 'all' gv_eqfnr INTO add_param
  SEPARATED BY space.

  IF fu_weight IS NOT INITIAL.
    CALL FUNCTION 'SXPG_COMMAND_EXECUTE'
      EXPORTING
        commandname                   = commandname
        additional_parameters         = add_param
      IMPORTING
        status                        = status
        exitcode                      = exitcode
      TABLES
        exec_protocol                 = iserveroutput
      EXCEPTIONS
        no_permission                 = 1
        command_not_found             = 2
        parameters_too_long           = 3
        security_risk                 = 4
        wrong_check_call_interface    = 5
        program_start_error           = 6
        program_termination_error     = 7
        x_error                       = 8
        parameter_expected            = 9
        too_many_parameters           = 10
        illegal_command               = 11
        wrong_asynchronous_parameters = 12
        cant_enq_tbtco_entry          = 13
        jobcount_generation_error     = 14
        OTHERS                        = 15.

    IF sy-subrc = 0.
      LOOP AT iserveroutput INTO ls_iserveroutput
                            WHERE message IS NOT INITIAL.
        CLEAR lv_char.
        lv_char = ls_iserveroutput-message.

        CALL METHOD zcl_util=>m_replace_eol_flag
          EXPORTING
            pvi_char = lv_char
          IMPORTING
            pvo_char = lv_char.

        IF sy-uname = 'TDS_DEV01' OR
          sy-uname = 'PPIFA' OR
          sy-uname = 'QMADK' OR
          sy-uname = 'PPMRA' OR
          gv_dispw = 'X'.
          gv_char  = lv_char.
          CALL SCREEN 103 STARTING AT 10 10.
          lv_char  = gv_char.
        ENDIF.

        SPLIT lv_char AT '|' INTO TABLE lt_char.
      ENDLOOP.
    ENDIF.
  ELSE.
    SPLIT gv_char AT '|' INTO TABLE lt_char.
  ENDIF.

  IF gv_tara IS INITIAL.
    READ TABLE lt_char INTO gv_tara INDEX 1.
    READ TABLE lt_char INTO gv_tmein INDEX 4.
    TRANSLATE gv_tmein TO UPPER CASE.
  ELSE.
    READ TABLE lt_char INTO gv_netto INDEX 1.
    READ TABLE lt_char INTO gv_nmein INDEX 4.
    TRANSLATE gv_nmein TO UPPER CASE.
  ENDIF.

  IF gs_weight-bdmng IS INITIAL.
    READ TABLE gt_rawmat INTO ls_rawmat INDEX 1.
    IF sy-subrc = 0.
      lv_bdmng  = ls_rawmat-bdmng.
      lv_meins  = ls_rawmat-meins.
    ENDIF.
  ELSE.
    lv_bdmng  = gs_weight-bdmng.
    lv_meins  = gs_weight-vrkme.
  ENDIF.

  DESCRIBE TABLE gt_rawmat LINES lv_lines.

  LOOP AT gt_rawmat INTO ls_rawmat.
    ADD ls_rawmat-clabs TO lv_clabs.
    ADD 1 TO lv_count.
    IF lv_count = lv_lines.
      CONTINUE.
    ENDIF.
    ADD ls_rawmat-enmng TO lv_total.
  ENDLOOP.

  PERFORM f_uom_conversion USING '' ls_rawmat-meins gv_nmein
                                 lv_total
                           CHANGING lv_total.

  CLEAR ls_rawmat.
  READ TABLE gt_rawmat INTO ls_rawmat
                       WITH KEY charg = gv_charg.
  IF sy-subrc = 0.
    IF gv_netto IS NOT INITIAL.
      PERFORM f_validasi_netto USING '' gv_netto gv_nmein
                                     gv_tara gv_tmein 'X'.
      IF lv_total = 0.
        ls_rawmat-enmng = gv_netto.
      ELSE.
        ls_rawmat-enmng = gv_netto - lv_total.
      ENDIF.

      IF gs_weight-bdmng IS INITIAL.
        lv_xmein  = ls_rawmat-meins.
      ELSE.
        lv_xmein  = gs_weight-vrkme.
      ENDIF.

      PERFORM f_uom_conversion USING '' gv_nmein lv_xmein
                                     ls_rawmat-enmng
                               CHANGING ls_rawmat-enmng.

      PERFORM f_matnr_pc USING '1' ls_rawmat-enmng '' ''
                         CHANGING ls_rawmat-enmng2.

      MODIFY TABLE gt_rawmat FROM ls_rawmat
                             TRANSPORTING enmng enmng2.
    ENDIF.
  ENDIF.

  LOOP AT gt_xresb INTO ls_xresb WHERE aufnr = gs_weight-aufnr
                                   AND rsnum = ls_rawmat-rsnum
                                   AND rspos = ls_rawmat-rspos.
    ADD ls_xresb-vmeng TO lv_enmng.
  ENDLOOP.

  CLEAR gv_weight.
  PERFORM f_validasi_netto USING '' lv_bdmng lv_meins
                                 gv_netto gv_nmein ''.

  lv_meins = VALUE #( gt_rawmat[ matnr = gv_matnr
                                 charg = gv_charg ]-meins ).
  lv_clabs = VALUE #( gt_rawmat[ matnr = gv_matnr
                                 charg = gv_charg ]-clabs ).
  lv_bdmng = VALUE #( gt_rawmat[ matnr = gv_matnr
                                 charg = gv_charg ]-bdmng ).
  lv_enmng = VALUE #( gt_rawmat[ matnr = gv_matnr
                                 charg = gv_charg ]-enmng ).

*  IF gv_nmein NE lv_meins.
*    PERFORM f_uom_conversion USING '' lv_meins gv_nmein lv_clabs
*                             CHANGING lv_clabs.
*
*  ENDIF.

  IF gs_weight-bdmng IS INITIAL.
*    IF lv_clabs < gv_netto.
    IF lv_clabs < lv_enmng.
      gv_subrc = 10.
      gs_weight-message = 'Jumlah timbang lebih dari stock'.
      CLEAR : gs_weight-material, gv_weight.
    ELSE.
      gv_subrc = 10.
      IF gs_weight-message = 'Jumlah timbang lebih dari stock'.
        CLEAR : gs_weight-message, gv_weight.
      ENDIF.
    ENDIF.
  ELSE.
    PERFORM f_matnr_pc USING '4' gs_weight-bdmng '' ''
                       CHANGING lv_netto.
    IF gv_netto = lv_netto.
      gv_weight = 'X'.
      CLEAR : gs_weight-message.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_WEIGHT

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_type fu_msgv1 fu_msgv2 fu_msgv3 fu_msgv4.
  gs_head-message = fu_msgv1.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_GET_ORDER
*&---------------------------------------------------------------------*
FORM f_get_order .
  DATA : ls_order LIKE LINE OF gt_order,
         lv_subrc TYPE sy-subrc,
         lv_count TYPE afpo-posnr,
         lt_afpo  TYPE STANDARD TABLE OF afpo,
         ls_afpo  LIKE LINE OF lt_afpo,
         lt_xresb TYPE STANDARD TABLE OF resb,
         ls_xresb LIKE LINE OF lt_xresb,
         ls_resb  LIKE LINE OF gt_resb,
         ls_item  LIKE LINE OF gt_item.

  DATA : lr_wempf TYPE RANGE OF wempf,
         ls_wempf LIKE LINE OF lr_wempf.

  CLEAR : gt_order[], gs_head-message, gt_item[].

  ls_wempf-low    = 'W'.
  ls_wempf-sign   = 'E'.
  ls_wempf-option = 'EQ'.
  APPEND ls_wempf TO lr_wempf.

  ls_wempf-low    = 'T'.
  ls_wempf-sign   = 'E'.
  ls_wempf-option = 'EQ'.
  APPEND ls_wempf TO lr_wempf.

*  IF gs_head-gstrp IS INITIAL.
*    gs_head-gstrp = sy-datum.
*  ENDIF.

  IF gs_head-werks IS NOT INITIAL AND
    gs_head-gstrp IS NOT INITIAL AND
    gs_head-plnbez IS NOT INITIAL.
    SELECT afko~aufnr afko~gstrp afko~plnbez aufk~werks aufk~objnr
      FROM afko JOIN aufk ON afko~aufnr = aufk~aufnr
      INTO CORRESPONDING FIELDS OF TABLE gt_order
      WHERE werks   = gs_head-werks
        AND gstrp   = gs_head-gstrp
        AND plnbez  = gs_head-plnbez.

    SORT gt_order BY aufnr.

    SELECT SINGLE maktx
      FROM makt
      INTO gs_head-maktx
      WHERE matnr = gs_head-plnbez
        AND spras = sy-langu.
  ENDIF.

  IF gt_order[] IS NOT INITIAL.
    CLEAR : gt_resb[], gt_xresb[].
    SELECT *
      FROM afpo
      INTO CORRESPONDING FIELDS OF TABLE lt_afpo
      FOR ALL ENTRIES IN gt_order
      WHERE aufnr = gt_order-aufnr
      ORDER BY PRIMARY KEY.

    SELECT *
      FROM resb
      INTO CORRESPONDING FIELDS OF TABLE gt_resb
      FOR ALL ENTRIES IN gt_order
      WHERE aufnr = gt_order-aufnr
        AND kzear = space
        AND xloek = space
      ORDER BY PRIMARY KEY.

    gt_xresb[]  = gt_resb[].
    DELETE gt_xresb WHERE wempf IN lr_wempf.
    lt_xresb[]  = gt_resb[].
    SORT lt_xresb BY aufnr rsnum rspos DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_xresb COMPARING aufnr rsnum.
    LOOP AT lt_xresb INTO ls_xresb.
      ls_item-aufnr = ls_xresb-aufnr.
      ls_item-rsnum = ls_xresb-rsnum.
      ls_item-rspos = ls_xresb-rspos.
      APPEND ls_item TO gt_item.
      CLEAR ls_item.
    ENDLOOP.
  ENDIF.

  IF gt_resb[] IS NOT INITIAL.
    SELECT *
      FROM stpo
      INTO CORRESPONDING FIELDS OF TABLE gt_stpo
      FOR ALL ENTRIES IN gt_resb
      WHERE stlty = gt_resb-stlty
        AND stlnr = gt_resb-stlnr
        AND stlkn = gt_resb-stlkn
        AND stpoz = gt_resb-stpoz
      ORDER BY PRIMARY KEY.
  ENDIF.

  LOOP AT gt_order INTO ls_order.
    PERFORM f_status_order  USING ls_order-objnr
                            CHANGING lv_subrc.
    IF lv_subrc IS INITIAL.
      CLEAR ls_resb.
      READ TABLE gt_xresb INTO ls_resb
                          WITH KEY aufnr = ls_order-aufnr.
      IF sy-subrc = 0.
        ADD 1 TO lv_count.
        ls_order-posnr  = lv_count.
        CLEAR ls_afpo.
        READ TABLE lt_afpo INTO ls_afpo
                           WITH KEY aufnr = ls_order-aufnr.
        IF sy-subrc = 0.
          ls_order-fcharg = ls_afpo-charg.
        ENDIF.
        MODIFY gt_order FROM ls_order TRANSPORTING posnr fcharg.
      ELSE.
        DELETE TABLE gt_order FROM ls_order.
      ENDIF.
    ENDIF.
  ENDLOOP.

  lt_xresb[] = gt_xresb[].
  SORT lt_xresb BY aufpl aplzl.
  DELETE ADJACENT DUPLICATES FROM lt_xresb COMPARING aufpl aplzl.
  IF lt_xresb[] IS NOT INITIAL.
    SELECT *
      FROM afvc
      INTO CORRESPONDING FIELDS OF TABLE gt_afvc
      FOR ALL ENTRIES IN lt_xresb
      WHERE aufpl = lt_xresb-aufpl
        AND aplzl = lt_xresb-aplzl
      ORDER BY PRIMARY KEY.
  ENDIF.
ENDFORM.                    " F_GET_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_STATUS_ORDER
*&---------------------------------------------------------------------*
FORM f_status_order  USING    fu_objnr
                     CHANGING fc_subrc.
  TYPES : BEGIN OF ty_status,
            itx04 TYPE jestd-itx04,
          END OF ty_status.

  DATA : lt_status TYPE STANDARD TABLE OF ty_status,
         ls_status LIKE LINE OF lt_status,
         line      TYPE bsvx-sttxt.

  CLEAR fc_subrc.
*  PERFORM f_range_status USING : 'REL'.

  CALL FUNCTION 'STATUS_TEXT_EDIT'
    EXPORTING
      flg_user_stat    = 'X'
      objnr            = fu_objnr
      only_active      = 'X'
      spras            = sy-langu
    IMPORTING
      line             = line
    EXCEPTIONS
      object_not_found = 1
      OTHERS           = 2.

  SPLIT line AT space INTO TABLE lt_status.
  READ TABLE lt_status INTO ls_status
                       WITH KEY itx04 = 'REL'.
  IF sy-subrc <> 0.
    DELETE gt_order WHERE objnr = fu_objnr.
    fc_subrc = 4.
  ELSE.
    IF gr_sttxt[] IS NOT INITIAL.
      LOOP AT lt_status INTO ls_status.
        IF ls_status-itx04 IN gr_sttxt.
          DELETE gt_order WHERE objnr = fu_objnr.
          fc_subrc = 4.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_STATUS_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_RANGE_STATUS
*&---------------------------------------------------------------------*
FORM f_range_status  USING    fu_sttxt.
  DATA : ls_sttxt     LIKE LINE OF gr_sttxt.

  ls_sttxt-low    = fu_sttxt.
  ls_sttxt-sign   = 'I'.
  ls_sttxt-option = 'EQ'.
  APPEND ls_sttxt TO gr_sttxt.
ENDFORM.                    " F_RANGE_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_TABLE
*&---------------------------------------------------------------------*
FORM f_generate_table .
  DATA : lv_div   TYPE p DECIMALS 0,
         lv_total TYPE mchb-clabs.

  idx = sy-stepl + line.

  CASE sy-dynnr.
    WHEN '0101'.
*      READ TABLE gt_order INTO gs_order INDEX idx.
    WHEN '0102'.
*      READ TABLE gt_rawmat INTO gs_rawmat INDEX idx.
    WHEN '0104'.
*      READ TABLE gt_sanitasi INTO gs_sanitasi INDEX idx.
  ENDCASE.
ENDFORM.                    " F_GENERATE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TABLE
*&---------------------------------------------------------------------*
FORM f_modify_table .
  DATA : lv_line        TYPE i.

  GET CURSOR LINE lv_line.

  CASE sy-dynnr.
    WHEN '0101'.
    WHEN '0102'.
  ENDCASE.
ENDFORM.                    " F_MODIFY_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_NEXT_BUTTON
*&---------------------------------------------------------------------*
FORM f_next_button .
  DATA : ls_order LIKE LINE OF gt_order,
         lv_line  TYPE i,
         lv_subrc TYPE sy-subrc.

  IF gt_order[] IS NOT INITIAL.
    READ TABLE gt_order INTO ls_order
                        WITH KEY posnr = gs_head-posnr.
    IF sy-subrc = 0.
      gs_weight-aufnr   = ls_order-aufnr.
      gs_weight-charg   = ls_order-fcharg.
      CALL SCREEN 102.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_NEXT_BUTTON

*&---------------------------------------------------------------------*
*&      Form  F_QTY_CONVERSION
*&---------------------------------------------------------------------*
FORM f_qty_conversion  USING    fu_matnr fu_werks fu_charg fu_atnam fu_split
                       CHANGING fc_packq.

  DATA : cob    TYPE STANDARD TABLE OF clbatch,
         ls_cob LIKE LINE OF cob.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      matnr              = fu_matnr
      charg              = fu_charg
      werks              = fu_werks
      get_classification = 'X'
    TABLES
      char_of_batch      = cob
    EXCEPTIONS
      no_material        = 1
      no_batch           = 2
      no_plant           = 3
      material_not_found = 4
      plant_not_found    = 5
      no_authority       = 6
      batch_not_exist    = 7
      lock_on_batch      = 8
      OTHERS             = 9.

  IF sy-subrc = 0.
    READ TABLE cob INTO ls_cob
                   WITH KEY atnam = 'QTY_CONVERSION'.
    IF sy-subrc = 0.
      TRANSLATE ls_cob-atwtb USING '. '.
      TRANSLATE ls_cob-atwtb USING ',.'.
      CONDENSE ls_cob-atwtb NO-GAPS.
      fc_packq  = ls_cob-atwtb.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_QTY_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_PRINT
*&---------------------------------------------------------------------*
FORM f_prepare_print USING fu_print.
  DATA : ls_label     LIKE LINE OF gt_label,
         ls_rawmat    LIKE LINE OF gt_rawmat,
         lv_enmng     TYPE resb-enmng,
         ls_batch     LIKE LINE OF gt_batch,
         lt_hazcom    TYPE TABLE OF ztspmdhazcom WITH HEADER LINE,
         h(10), f(10), r(10),
         lv_hazcom    TYPE char30,
         lv_netto(30).

  DATA : lv_lifnr LIKE lfa1-lifnr,
         lv_name1 LIKE lfa1-name1.

  IF fu_print IS INITIAL.
    CLEAR: lt_hazcom,lv_hazcom,h,f,r.
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF lt_hazcom
      FROM ztspmdhazcom WHERE matnr = gs_weight-rmmat
                          AND werks = gs_head-werks.
    IF sy-subrc = 0.
      CONCATENATE 'H =' lt_hazcom-health INTO h SEPARATED BY space.
      CONCATENATE 'F =' lt_hazcom-fire   INTO f SEPARATED BY space.
      CONCATENATE 'R =' lt_hazcom-reactivity INTO r SEPARATED BY space.
      CONCATENATE h f r  INTO lv_hazcom SEPARATED BY ' ; '.
      ls_label-hazcom = lv_hazcom.
    ENDIF.

    ls_label-aufnr      = gs_weight-aufnr.
    ls_label-fcharg     = gs_weight-charg.
    ls_label-plnbez     = gs_weight-fgmat.
    ls_label-fmaktx     = gs_weight-fgktx.
    ls_label-shtxt      = gs_weight-shtxt.
    ls_label-vornr      = gs_weight-vornr.
    ls_label-posnr      = gs_weight-posnr.
    ls_label-ltxa1      = gs_weight-ltxa1.
    ls_label-operator   = gs_weight-operator.
    ls_label-pengawas   = gs_weight-pengawas.
    ls_label-wb         = gs_weight-wb.
    ls_label-istad      = gv_istad.
    ls_label-istau      = gv_istau.
    ls_label-datum      = sy-datum.
    ls_label-uzeit      = sy-uzeit.
    ls_label-matnr      = gs_weight-rmmat.
    ls_label-maktx      = gs_weight-rmktx.

    IF gs_weight-bdmng IS NOT INITIAL.
      gs_rawmat-meins = gs_weight-vrkme.
    ENDIF.

    CLEAR : gt_batch[].
    LOOP AT gt_rawmat INTO ls_rawmat.
      ls_batch-charg  = ls_rawmat-charg.

      IF gs_weight-bdmng IS NOT INITIAL.
        ls_rawmat-meins = gs_weight-vrkme.
      ENDIF.

      ADD ls_rawmat-enmng TO lv_enmng.
      WRITE ls_rawmat-enmng TO ls_batch-netto UNIT ls_rawmat-meins.
      PERFORM f_conv_uom USING ls_rawmat-meins ''
                         CHANGING ls_batch-netto ls_batch-nmein.
      CONDENSE ls_rawmat-meanval NO-GAPS.
      IF ls_rawmat-meanval <> '1'.
        CONDENSE ls_rawmat-meanval NO-GAPS.
*        CONCATENATE '( F' ls_rawmat-meanval ')' INTO ls_batch-meanval
*        SEPARATED BY space.
        CASE ls_rawmat-meantyp.
          WHEN 'X'.
*            CONCATENATE '(' ls_rawmat-meantyp INTO ls_batch-meanval.
*            CONCATENATE ls_batch-meanval ls_rawmat-meanval
*              INTO ls_batch-meanval SEPARATED BY space.
            CONCATENATE '(X=' ls_rawmat-meanval 'mg)' INTO ls_batch-meanval.
          WHEN 'F'.
            CONCATENATE '(' ls_rawmat-meantyp INTO ls_batch-meanval
              SEPARATED BY space.
            CONCATENATE ls_batch-meanval ls_rawmat-meanval
              INTO ls_batch-meanval SEPARATED BY space.
            CONCATENATE ls_batch-meanval ')' INTO ls_batch-meanval
              SEPARATED BY space.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
      APPEND ls_batch TO gt_batch.
      CLEAR ls_batch.

      CLEAR: lv_lifnr,lv_name1.
      PERFORM f_get_vendor USING ls_rawmat-matnr
                                 ls_rawmat-charg
                           CHANGING lv_lifnr lv_name1.
*      IF lv_lifnr = ls_label-lifnr OR
*         lv_lifnr = ls_label-lifnr2 OR
*         lv_lifnr = ls_label-lifnr3.
*      ELSE.
*        IF ls_label-lifnr IS INITIAL.
*          ls_label-lifnr = lv_lifnr.
*          CONCATENATE '(' lv_name1(30) ')' INTO lv_name1.
*          ls_label-name1 = lv_name1.
*        ELSEIF ls_label-lifnr2 IS INITIAL.
*          ls_label-lifnr2 = lv_lifnr.
*          CONCATENATE '(' lv_name1(30) ')' INTO lv_name1.
*          ls_label-name2 = lv_name1.
*        ELSE.
*          ls_label-lifnr3 = lv_lifnr.
*          CONCATENATE '(' lv_name1(30) ')' INTO lv_name1.
*          ls_label-name3 = lv_name1.
*        ENDIF.
*      ENDIF.
      IF lv_name1 = ls_label-name1 OR
         lv_name1 = ls_label-name2 OR
         lv_name1 = ls_label-name3.
      ELSE.
        IF ls_label-name1 IS INITIAL.
          CONCATENATE '(' lv_name1(30) ')' INTO lv_name1.
          ls_label-name1 = lv_name1.
        ELSEIF ls_label-name2 IS INITIAL.
          CONCATENATE '(' lv_name1(30) ')' INTO lv_name1.
          ls_label-name2 = lv_name1.
        ELSE.
          CONCATENATE '(' lv_name1(30) ')' INTO lv_name1.
          ls_label-name3 = lv_name1.
        ENDIF.
      ENDIF.
    ENDLOOP.

    PERFORM f_uom_conversion USING '' gv_nmein gs_rawmat-meins
                                   gv_tara
                             CHANGING gv_tara.
    WRITE gv_tara TO ls_label-tara UNIT gs_rawmat-meins.
    PERFORM f_conv_uom USING gs_rawmat-meins ''
                       CHANGING ls_label-tara ls_label-tmein.

    PERFORM f_uom_conversion USING '' gv_nmein gs_rawmat-meins
                                   gv_bruto
                             CHANGING gv_bruto.
    WRITE gv_bruto TO ls_label-bruto UNIT gs_rawmat-meins.
    PERFORM f_conv_uom USING gs_rawmat-meins ''
                       CHANGING ls_label-bruto ls_label-bmein.

    PERFORM f_uom_conversion USING '' gv_nmein gs_rawmat-meins
                                   gv_netto
                             CHANGING gv_netto.
    WRITE gv_netto TO lv_netto UNIT gs_rawmat-meins.
    CONDENSE lv_netto.
    ls_label-netto  = lv_netto.
    PERFORM f_conv_uom USING gs_rawmat-meins 'X'
                       CHANGING lv_netto ls_label-nmein.

    CONCATENATE gs_weight-fgmat gs_weight-aufnr gs_weight-vornr
                gs_weight-posnr gs_weight-rmmat lv_netto
                INTO ls_label-qrcode
                SEPARATED BY ';'.

    APPEND ls_label TO gt_label.
    CLEAR ls_label.
  ENDIF.
ENDFORM.                    " F_PREPARE_PRINT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form .
  DATA : lv_formname TYPE tdsfname,
         lv_funcname TYPE tdsfname,
         ctrl_param  LIKE ssfctrlop,
         output_opt  TYPE ssfcompop,
         ls_label    TYPE ztspppst004,
         default     TYPE bapidefaul,
         return      TYPE STANDARD TABLE OF bapiret2,
         lv_ldest    TYPE t329d-ldest.

  lv_formname = 'ZTSPPPF002'.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      defaults = default
    TABLES
      return   = return.

  PERFORM f_get_print_dest USING gs_weight-equnr
                           CHANGING gv_print_dest.

  IF gv_print_dest IS NOT INITIAL.
    lv_ldest = gv_print_dest.
  ELSE.
    lv_ldest = default-spld.
  ENDIF.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  LOOP AT gt_label INTO ls_label.
    AT FIRST.
      ctrl_param-no_close = 'X'.
    ENDAT.

    AT LAST.
      ctrl_param-no_close = space.
    ENDAT.

    ctrl_param-no_dialog  = 'X'.

    output_opt-tdnewid    = 'X'.
    output_opt-tdimmed    = 'X'.
    output_opt-tddelete   = ''.
    output_opt-tddest     = lv_ldest.

    ls_label-reprint      = gv_reprint.

    CASE gs_head-werks.
      WHEN '0101'.
        ls_label-company  = 'TSP - Cikarang Plant 1'.
      WHEN '0102'.
        ls_label-company  = 'TSP - Cikarang Plant 2'.
    ENDCASE.

    CALL FUNCTION lv_funcname
      EXPORTING
        control_parameters = ctrl_param
        output_options     = output_opt
        user_settings      = space
        gs_weight          = ls_label
      TABLES
        gt_batch           = gt_batch
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    ctrl_param-no_open = 'X'.
  ENDLOOP.

  CLEAR : gt_label[], gv_weight, gs_weight-message.
ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATA
*&---------------------------------------------------------------------*
FORM f_modify_data TABLES   ft_iresb     STRUCTURE resb
                            ft_uresb     STRUCTURE resb
                            ft_onr00     STRUCTURE onr00
                            ft_jest      STRUCTURE jest
                            ft_jsto      STRUCTURE jsto
                   CHANGING fc_print.

  DATA : ls_003    LIKE LINE OF gt_003,
         ls_rawmat LIKE LINE OF gt_rawmat,
         lv_enmng  TYPE resb-enmng,
         lv_rspos  TYPE resb-rspos,
         ls_item   LIKE LINE OF gt_item,
         lt_add    TYPE STANDARD TABLE OF zppresb_add,
         ls_add    TYPE zppresb_add,
         ls_label  LIKE LINE OF gt_label,
         lv_count  TYPE i.

  IF fc_print IS INITIAL.
    LOOP AT gt_rawmat INTO ls_rawmat.
      CLEAR ls_item.
      READ TABLE gt_item INTO ls_item
                         WITH KEY rsnum = ls_rawmat-rsnum.
      lv_rspos = ls_item-rspos.

      ADD 1 TO lv_count.
      ADD 1 TO lv_rspos.

      IF gs_weight-bdmng IS NOT INITIAL.
        PERFORM f_matnr_pc USING '3' ls_rawmat-enmng ls_rawmat-enmng2 ls_rawmat-bdmng
                           CHANGING ls_rawmat-enmng.
*        ls_rawmat-enmng = ls_rawmat-bdmng.
      ENDIF.

      PERFORM f_update_resb TABLES ft_uresb
                            USING ls_rawmat-rsnum ls_rawmat-rspos ls_rawmat-enmng
                                  ls_rawmat-meins.

      PERFORM f_add_resb TABLES ft_onr00 ft_iresb ft_jest ft_jsto
                         USING ls_rawmat-rsnum ls_rawmat-rspos ls_rawmat-enmng
                               ls_rawmat-meins ls_rawmat-charg lv_rspos lv_count.
    ENDLOOP.
  ENDIF.

  READ TABLE gt_label INTO ls_label INDEX 1.
  IF sy-subrc = 0.
    ls_add-aufnr        = ls_label-aufnr.
    ls_add-matnr        = ls_label-matnr.
    ls_add-werks        = gs_head-werks.
    ls_add-equnr        = gs_weight-equnr.
    ls_add-shtxt        = ls_label-shtxt.
    ls_add-posnr        = ls_label-posnr.
    ls_add-ltxa1        = ls_label-ltxa1.
    ls_add-operator     = ls_label-operator.
    ls_add-pengawas     = ls_label-pengawas.
    ls_add-wbooth       = ls_label-wb.
    ls_add-tara         = gv_tara.
    ls_add-meins        = gs_rawmat-meins.
    ls_add-istad        = ls_label-istad.
    ls_add-istau        = ls_label-istau.
    ls_add-datum        = ls_label-datum.
    ls_add-uzeit        = ls_label-uzeit.

    READ TABLE gt_resb INTO DATA(ls_resb)
                       WITH KEY rsnum = ls_rawmat-rsnum
                                rspos = ls_rawmat-rspos.
    READ TABLE gt_afvc INTO DATA(ls_afvc) WITH KEY aufpl = ls_resb-aufpl
                                                   vornr = ls_resb-vornr.

    ls_add-vornr = ls_resb-vornr.
    ls_add-sortf = ls_resb-sortf.
    ls_add-phseq = ls_afvc-phseq.

    APPEND ls_add TO lt_add.
    CLEAR ls_add.
  ENDIF.

  CALL FUNCTION 'ZTSPPPFM001'
    TABLES
      it_add                   = lt_add
      it_iresb                 = ft_iresb
      it_uresb                 = ft_uresb
      it_onr00                 = ft_onr00
      it_jest                  = ft_jest
      it_jsto                  = ft_jsto
    EXCEPTIONS
      error_insert_resb        = 1
      error_update_resb        = 2
      error_insert_onr00       = 3
      error_insert_zppresb_add = 4
      error_insert_jest        = 5
      error_insert_jsto        = 6
      OTHERS                   = 7.

  IF sy-subrc <> 0.
    ROLLBACK WORK.
    gs_weight-message = 'Proses print gagal'.
    gv_print = '4'.
  ELSE.
    COMMIT WORK AND WAIT.
    gv_print = '1'.
    PERFORM f_print_form.
    gv_reprint  = 'X'.
    CLEAR : ft_iresb[], ft_uresb[], ft_onr00[], ft_jest[], ft_jsto[].
    PERFORM f_clear_data USING 'PRINT'.
    PERFORM f_refresh_resb.
  ENDIF.
ENDFORM.                    " F_MODIFY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CONV_UOM
*&---------------------------------------------------------------------*
FORM f_conv_uom  USING    fu_meins fu_concatenate
                 CHANGING fc_value fc_meins.

  DATA : lv_meins(5),
         lv_short(5).

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_meins
    IMPORTING
      output         = lv_meins
      short_text     = lv_short
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.

  CONDENSE fc_value NO-GAPS.
  fc_meins = lv_meins.

  IF fu_concatenate IS NOT INITIAL.
    CONCATENATE fc_value lv_meins INTO fc_value
    SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_CONV_UOM

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_RESB
*&---------------------------------------------------------------------*
FORM f_update_resb  TABLES   ft_resb    STRUCTURE resb
                    USING    fu_rsnum fu_rspos fu_enmng fu_meins.
  DATA : lv_bdmng TYPE resb-bdmng,
         lv_vmeng TYPE resb-vmeng,
         lv_nomng TYPE resb-nomng,
         lv_erfmg TYPE resb-erfmg,
         ls_resb  LIKE LINE OF gt_resb,
         ls_002   LIKE LINE OF gt_002,
         ls_xresb LIKE LINE OF gt_xresb,
         ls_marm  LIKE LINE OF gt_marm.

  READ TABLE gt_resb INTO ls_resb
                     WITH KEY rsnum = fu_rsnum
                              rspos = fu_rspos.
  IF sy-subrc = 0.
    IF ls_resb-nomng IS INITIAL.
      ls_resb-nomng  = ls_resb-bdmng.
    ENDIF.

    READ TABLE gt_marm INTO ls_marm
                       WITH KEY meinh = fu_meins.
    IF sy-subrc = 0.
      lv_bdmng  = ( fu_enmng * ls_marm-umrez ) / ls_marm-umren.
    ENDIF.
*    PERFORM f_uom_conversion USING ls_resb-matnr fu_meins ls_resb-meins
*                                   fu_enmng
*                             CHANGING lv_bdmng.

    ls_resb-bdmng  = ls_resb-bdmng - lv_bdmng.
    ls_resb-erfmg  = ls_resb-erfmg - fu_enmng.
    ls_resb-vmeng  = ls_resb-vmeng - lv_bdmng.
    ls_resb-splkz  = '1'.

**    READ TABLE gt_002 INTO ls_002
**                      WITH KEY matnr = ls_resb-matnr.
**    IF sy-subrc = 0.
**      IF ls_002-factor IS NOT INITIAL.
    ls_resb-kzear = 'X'.
**      ENDIF.
**    ENDIF.

    MODIFY gt_resb FROM ls_resb
                   TRANSPORTING nomng bdmng erfmg vmeng splkz kzear
                   WHERE rsnum = fu_rsnum
                     AND rspos = fu_rspos.

*    ls_xresb-vmeng  = 0.
*    MODIFY gt_xresb FROM ls_xresb
*                   TRANSPORTING vmeng
*                   WHERE rsnum = fu_rsnum
*                     AND rspos = fu_rspos.

    APPEND ls_resb TO ft_resb.

*    COMMIT WORK AND WAIT.
  ENDIF.
ENDFORM.                    " F_UPDATE_RESB

*&---------------------------------------------------------------------*
*&      Form  F_ADD_RESB
*&---------------------------------------------------------------------*
FORM f_add_resb  TABLES   ft_onr00  STRUCTURE onr00
                          ft_resb   STRUCTURE resb
                          ft_jest   STRUCTURE jest
                          ft_jsto   STRUCTURE jsto
                 USING    fu_rsnum fu_rspos fu_enmng fu_meins
                          fu_charg fu_nwpos fu_count.
  DATA : ls_resb    LIKE LINE OF gt_resb,
         ls_item    LIKE LINE OF gt_item,
         lv_old(22),
         lv_new(22),
         lv_bdmng   TYPE resb-bdmng,
         ls_marm    LIKE LINE OF gt_marm,
         ls_onr00   TYPE onr00,
         lv_rspos   TYPE resb-rspos,
         ls_jest    TYPE jest,
         ls_jsto    TYPE jsto.

  SELECT MAX( rspos ) INTO lv_rspos
    FROM resb WHERE rsnum = fu_rsnum.

  lv_rspos = lv_rspos + fu_count.
*    ADD 1 TO lv_rspos.

  CLEAR ls_resb.
  READ TABLE gt_resb INTO ls_resb
                     WITH KEY rsnum = fu_rsnum
                              rspos = fu_rspos.
  IF sy-subrc = 0.
    READ TABLE gt_marm INTO ls_marm
                       WITH KEY meinh = fu_meins.
    IF sy-subrc = 0.
      lv_bdmng  = ( fu_enmng * ls_marm-umrez ) / ls_marm-umren.
    ENDIF.

    ls_resb-rspos     = lv_rspos. "fu_nwpos.
    ls_resb-nomng     = ls_resb-nomng - ls_resb-bdmng - lv_bdmng.
    ls_resb-bdmng     = lv_bdmng.
    ls_resb-erfmg     = fu_enmng.
    ls_resb-enmng     = 0.
    ls_resb-vmeng     = lv_bdmng.
    CONCATENATE fu_rsnum fu_rspos INTO lv_old.
    CONCATENATE fu_rsnum lv_rspos INTO lv_new.
    REPLACE ALL OCCURRENCES OF REGEX lv_old IN ls_resb-objnr WITH lv_new.

    ls_onr00-objnr = ls_resb-objnr.
    APPEND ls_onr00 TO ft_onr00.

    ls_jest-objnr  = ls_resb-objnr.
    ls_jest-stat   = 'I0001'.
    ls_jest-inact	 = 'X'.
    ls_jest-chgnr  = '2'.
    APPEND ls_jest TO ft_jest.
    ls_jest-objnr  = ls_resb-objnr.
    ls_jest-stat   = 'I0002'.
    ls_jest-inact	 = space.
    ls_jest-chgnr  = '1'.
    APPEND ls_jest TO ft_jest.

    ls_jsto-objnr  = ls_resb-objnr.
    ls_jsto-obtyp  = 'OKP'.
    ls_jsto-stsma	 = space.
    ls_jsto-chgkz	 = 'X'.
    ls_jsto-chgnr  = '1'.
    APPEND ls_jsto TO ft_jsto.

    ls_resb-splkz     = '2'.
    ls_resb-charg     = fu_charg.
    ls_resb-splrv     = fu_rspos.
    CLEAR : ls_resb-stvkn, ls_resb-stlty, ls_resb-stlnr,
            ls_resb-stlkn, ls_resb-stpoz, ls_resb-kzear.

    APPEND ls_resb TO ft_resb.

    ls_item-rspos = lv_rspos.
    MODIFY gt_item FROM ls_item
                         TRANSPORTING rspos
                         WHERE aufnr = ls_resb-aufnr
                           AND rsnum = ls_resb-rsnum.
  ENDIF.
ENDFORM.                    " F_ADD_RESB

*&---------------------------------------------------------------------*
*&      Form  F_GET_DESCRIPTION
*&---------------------------------------------------------------------*
FORM f_get_description  USING    fu_rsnum fu_rspos fu_vornr
                        CHANGING fc_ltxa1.
  DATA : ls_resb LIKE LINE OF gt_resb,
         ls_afvc LIKE LINE OF gt_afvc.

  READ TABLE gt_resb INTO ls_resb
                     WITH KEY rsnum = fu_rsnum
                              rspos = fu_rspos.
  IF sy-subrc = 0.
    READ TABLE gt_afvc INTO ls_afvc
                       WITH KEY aufpl = ls_resb-aufpl
                                aplzl = ls_resb-aplzl
                                vornr = fu_vornr.
    IF sy-subrc = 0.
      fc_ltxa1  = ls_afvc-ltxa1.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DESCRIPTION

*&---------------------------------------------------------------------*
*&      Form  F_PRINTER_CHECK
*&---------------------------------------------------------------------*
FORM f_printer_check .
  DATA : ls_tsp03d TYPE tsp03d,
         ls_tsp06a TYPE tsp06a,
         default   TYPE bapidefaul,
         return    TYPE STANDARD TABLE OF bapiret2,
         lv_ldest  TYPE t329d-ldest.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      defaults = default
    TABLES
      return   = return.

  PERFORM f_get_print_dest USING gs_weight-equnr
                           CHANGING gv_print_dest.

  IF gv_print_dest IS NOT INITIAL.
    lv_ldest = gv_print_dest.
  ELSE.
    lv_ldest = default-spld.
  ENDIF.

  SELECT SINGLE *
    FROM tsp03d
    INTO CORRESPONDING FIELDS OF ls_tsp03d
    WHERE padest = lv_ldest.
  IF sy-subrc = 0.
    SELECT SINGLE *
      FROM tsp06a
      INTO CORRESPONDING FIELDS OF ls_tsp06a
      WHERE ptype = ls_tsp03d-patype
        AND paper = 'Z_A7'.
    IF sy-subrc <> 0.
      CONCATENATE 'Printer' ls_tsp03d-name 'tidak support untuk A7'
      INTO gs_weight-message
      SEPARATED BY space.
      CLEAR gs_weight-material.
    ENDIF.
  ELSE.
    gs_weight-message = 'Printer belum dimaintain'.
    CLEAR gs_weight-material.
  ENDIF.
ENDFORM.                    " F_PRINTER_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_GET_STOCK
*&---------------------------------------------------------------------*
FORM f_get_stock .
  DATA : lt_resb    TYPE STANDARD TABLE OF resb.

  lt_resb[] = gt_resb[].
  SORT lt_resb BY matnr werks lgort.
  DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING matnr werks lgort.
  IF lt_resb[] IS NOT INITIAL.
    SELECT *
      FROM mard
      INTO CORRESPONDING FIELDS OF TABLE gt_mard
      FOR ALL ENTRIES IN lt_resb
      WHERE matnr = lt_resb-matnr
        AND werks = lt_resb-werks
        AND lgort = lt_resb-lgort
      ORDER BY PRIMARY KEY.
  ENDIF.
ENDFORM.                    " F_GET_STOCK

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_NETTO
*&---------------------------------------------------------------------*
FORM f_validasi_netto  USING    fu_matnr fu_enmng fu_meins fu_netto
                                fu_nmein fu_calc.
  DATA : lv_bmng1 TYPE resb-bdmng,
         lv_bmng2 TYPE resb-bdmng.

  IF fu_nmein  = fu_meins.
    lv_bmng1  = fu_enmng.
    lv_bmng2  = fu_netto.
  ELSE.
    lv_bmng1  = fu_enmng.
    PERFORM f_uom_conversion USING fu_matnr fu_nmein fu_meins fu_netto
                             CHANGING lv_bmng2.
  ENDIF.

  IF fu_calc IS NOT INITIAL.
    gv_bruto = fu_enmng + lv_bmng2. "lv_bmng1 + lv_bmng2.
  ELSE.
    IF lv_bmng1 = lv_bmng2.
      gv_weight = 'X'.
      CLEAR : gs_weight-message.
*    ELSEIF sy-uname = 'PPIFA'.
*      gv_weight = 'X'.
*      CLEAR : gs_weight-message.
    ELSEIF gv_nweig = 'X'.
      gv_weight = 'X'.
      CLEAR : gs_weight-message.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDASI_NETTO

*&---------------------------------------------------------------------*
*&      Form  F_UOM_CONVERSION
*&---------------------------------------------------------------------*
FORM f_uom_conversion  USING    fu_matnr fu_nmein fu_meins fu_enmng
                       CHANGING fc_bdmng.
  IF fu_matnr IS INITIAL.
    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        input                = fu_enmng
        unit_in              = fu_nmein
        unit_out             = fu_meins
      IMPORTING
        output               = fc_bdmng
      EXCEPTIONS
        conversion_not_found = 1
        division_by_zero     = 2
        input_invalid        = 3
        output_invalid       = 4
        overflow             = 5
        type_invalid         = 6
        units_missing        = 7
        unit_in_not_found    = 8
        unit_out_not_found   = 9
        OTHERS               = 10.
  ELSE.
    CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
      EXPORTING
        input                = fu_enmng
        matnr                = fu_matnr
        meinh                = fu_nmein
        meins                = fu_meins
      IMPORTING
        output               = fc_bdmng
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
  ENDIF.
ENDFORM.                    " F_UOM_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_FACTOR
*&---------------------------------------------------------------------*
FORM f_material_factor  USING    fu_matnr fu_charg fu_werks
                        CHANGING fc_meanval.
  DATA : lv_meanval  TYPE bapi2045d2-mean_value,
         lv_text     TYPE bapi2045l2-txt_oper,
         lv_inspoper TYPE bapi2045l2-inspoper.

  CLEAR fc_meanval.

  lv_text     = 'Faktorisasi pada Kadar'.
  lv_inspoper = '0010'.

  CALL FUNCTION 'ZQMMATNR_FACTOR'
    EXPORTING
      i_matnr      = fu_matnr
      i_charg      = fu_charg
      i_werks      = fu_werks
      i_text       = lv_text
      i_inspoper   = lv_inspoper
    IMPORTING
      e_mean_value = lv_meanval.

  TRANSLATE lv_meanval USING '. '.
  TRANSLATE lv_meanval USING ',.'.
  CONDENSE lv_meanval.
  IF lv_meanval IS INITIAL.
    fc_meanval = 1.
  ELSE.
    fc_meanval = lv_meanval.
  ENDIF.
ENDFORM.                    " F_MATERIAL_FACTOR

*&---------------------------------------------------------------------*
*&      Form  F_NEXT_ORDER
*&---------------------------------------------------------------------*
FORM f_next_order  CHANGING fc_aufnr.
  DATA : ls_order  LIKE LINE OF gt_order,
         ls_xorder LIKE LINE OF gt_xorder.

  DATA : lv_posnr   TYPE afpo-posnr.

  CLEAR ls_order.
  READ TABLE gt_order INTO ls_order
                      WITH KEY aufnr = fc_aufnr.
  IF sy-subrc = 0.
    lv_posnr = ls_order-posnr + 1.
  ENDIF.

  READ TABLE gt_order INTO ls_order
                      WITH KEY posnr = lv_posnr.
  IF sy-subrc = 0.
    fc_aufnr = ls_order-aufnr.
  ELSE.
    lv_posnr = 1.
    READ TABLE gt_order INTO ls_order
                        WITH KEY posnr = lv_posnr.
    IF sy-subrc = 0.
      fc_aufnr = ls_order-aufnr.
    ENDIF.
  ENDIF.

  PERFORM f_unlock_table.
ENDFORM.                    " F_NEXT_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_NEXT_OPERATION
*&---------------------------------------------------------------------*
FORM f_next_operation  USING fu_matnr fu_flag
                       CHANGING fc_vornr fc_posnr.
  DATA : lt_xresb      TYPE STANDARD TABLE OF resb,
         ls_xresb      LIKE LINE OF lt_xresb,
         ls_xoperation LIKE LINE OF gt_xoperation.

  IF fu_flag IS INITIAL.
    lt_xresb[] = gt_xresb[].
    SORT lt_xresb BY aufnr matnr vornr.
    DELETE lt_xresb WHERE vmeng = 0.
    DELETE lt_xresb WHERE charg IS NOT INITIAL.
    DELETE ADJACENT DUPLICATES FROM lt_xresb COMPARING aufnr matnr vornr.
    LOOP AT lt_xresb INTO ls_xresb WHERE aufnr = gs_weight-aufnr
                                     AND matnr = fu_matnr
                                     AND vmeng <> 0.
      READ TABLE gt_xoperation INTO ls_xoperation
                               WITH KEY aufnr = ls_xresb-aufnr
                                        matnr = ls_xresb-matnr
                                        vornr = ls_xresb-vornr.
      IF sy-subrc <> 0.
        fc_vornr  = ls_xresb-vornr.
        fc_posnr  = ls_xresb-posnr.
        EXIT.
      ENDIF.
    ENDLOOP.
  ELSE.
  ENDIF.
ENDFORM.                    " F_NEXT_OPERATION

*&---------------------------------------------------------------------*
*&      Form  F_REFRESH_RESB
*&---------------------------------------------------------------------*
FORM f_refresh_resb .
  CLEAR : gt_resb[], gt_xresb[].

  SELECT *
    FROM resb
    INTO CORRESPONDING FIELDS OF TABLE gt_resb
    FOR ALL ENTRIES IN gt_order
    WHERE aufnr = gt_order-aufnr
      AND kzear = space
      AND xloek = space.

  gt_xresb[]  = gt_resb[].
  DELETE gt_xresb WHERE wempf <> 'W'.
ENDFORM.                    " F_REFRESH_RESB

*&---------------------------------------------------------------------*
*&      Form  F_WITH_PASSWORD
*&---------------------------------------------------------------------*
FORM f_with_password .
  IF gv_pass IS NOT INITIAL.
    gs_weight-operator = gv_operator.
    gs_weight-pengawas = gv_pengawas.

    IF gs_weight-message IS NOT INITIAL AND
       sy-ucomm = '&PRINT'.
    ELSE.
      PERFORM f_next_entry.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_WITH_PASSWORD

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM f_display_data  USING    fu_sign.
  DATA : lv_lines   TYPE i.

  DESCRIBE TABLE gt_order LINES lv_lines.
  CASE fu_sign.
    WHEN '+'.
      n1 = n1 + 30.
      IF n1 > lv_lines.
        n1 = lv_lines.
      ENDIF.
    WHEN '-'.
      n1 = n1 - 30.
      IF n1 < 0.
        n1 = 30.
      ENDIF.
      c  = c - 30.
  ENDCASE.
ENDFORM.                    " F_DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_LOCK_ENTRY
*&---------------------------------------------------------------------*
FORM f_check_lock_entry  USING    fu_value
                         CHANGING fc_subrc fc_lgort.
  DATA : enq      TYPE STANDARD TABLE OF seqg3,
         ls_enq   LIKE LINE OF enq,
         lv_gtarg TYPE seqg3-gtarg.

  DATA : ls_component   LIKE LINE OF gt_component.

  IF fu_value = 'MCHB'.
    READ TABLE gt_component INTO ls_component
                            WITH KEY matnr = gv_matnr
                                     werks = gs_head-werks.
    IF sy-subrc = 0.
      fc_lgort  = ls_component-lgort.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gname                 = fu_value
      guname                = space
    TABLES
      enq                   = enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.
  IF enq[] IS NOT INITIAL.
    fc_subrc = 4.
    READ TABLE enq INTO ls_enq INDEX 1.
    IF sy-subrc = 0.
      CASE fu_value.
        WHEN 'AUFK'.
          IF ls_enq-guname = sy-uname.
            CLEAR fc_subrc.
          ELSE.
            CONCATENATE sy-mandt gs_weight-aufnr INTO lv_gtarg.
            IF ls_enq-gtarg = lv_gtarg.
              CONCATENATE 'Order' gs_weight-aufnr 'lock by' ls_enq-guname
              INTO gs_weight-message
              SEPARATED BY space.
            ELSE.
              CLEAR fc_subrc.
            ENDIF.
          ENDIF.

        WHEN 'MCHB'.
          lv_gtarg(3)     = sy-mandt.
          lv_gtarg+3(18)  = gv_matnr.
          lv_gtarg+21(4)  = gs_head-werks.
          lv_gtarg+25(4)  = fc_lgort.
          lv_gtarg+29(10) = gv_charg.
          IF ls_enq-gtarg = lv_gtarg.
            CONCATENATE 'Batch' gv_charg 'lock by' ls_enq-guname
            INTO gs_weight-message
            SEPARATED BY space.
          ELSE.
            CLEAR fc_subrc.
          ENDIF.

        WHEN 'MCH1'.
          lv_gtarg(3)     = sy-mandt.
          lv_gtarg+3(18)  = gv_matnr.
          lv_gtarg+21(10) = gv_charg.
          IF ls_enq-gtarg = lv_gtarg.
            CONCATENATE 'Batch' gv_charg 'lock by' ls_enq-guname
            INTO gs_weight-message
            SEPARATED BY space.
          ELSE.
            CLEAR fc_subrc.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_LOCK_ENTRY

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_lock_table  USING    fu_tabname fu_lgort.
  CASE fu_tabname.
    WHEN 'AUFK'.
      CALL FUNCTION 'ENQUEUE_ESORDER'
        EXPORTING
          aufnr          = gs_weight-aufnr
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.

    WHEN 'MCHB'.
      CALL FUNCTION 'ENQUEUE_EZKMM_MCHB'
        EXPORTING
          matnr          = gv_matnr
          werks          = gs_head-werks
          lgort          = fu_lgort
          charg          = gv_charg
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.

    WHEN 'MCH1'.
      CALL FUNCTION 'ENQUEUE_EMMCH1E'
        EXPORTING
          matnr          = gv_matnr
          charg          = gv_charg
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
  ENDCASE.
ENDFORM.                    " F_LOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_unlock_table .
  CALL FUNCTION 'DEQUEUE_ALL'.
ENDFORM.                    " F_UNLOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_REQUIRED_QTY
*&---------------------------------------------------------------------*
FORM f_modify_required_qty  USING    fu_werks fu_matnr1 fu_matnr2 fu_aufnr
                                     fu_posnr
                            CHANGING fc_bdmng.
  DATA : ls_resb     LIKE LINE OF gt_resb,
         lv_bdmng1   TYPE p DECIMALS 1,
         lv_bdmng2   TYPE p DECIMALS 2,
         lv_decimals.

  IF gs_head-werks = fu_werks AND
    fu_matnr1 = fu_matnr2.
    READ TABLE gt_resb INTO ls_resb
                       WITH KEY aufnr = fu_aufnr
                                matnr = fu_matnr1
                                posnr = fu_posnr.
    IF sy-subrc = 0.
      CASE ls_resb-erfme.
        WHEN 'KG'.
          lv_decimals = 2.
          PERFORM f_round USING lv_decimals fc_bdmng ''
                          CHANGING lv_bdmng2.
          fc_bdmng = lv_bdmng2.
        WHEN OTHERS.
          lv_decimals = 1.
          PERFORM f_round USING lv_decimals fc_bdmng ''
                          CHANGING lv_bdmng1.
          fc_bdmng = lv_bdmng1.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_REQUIRED_QTY

*&---------------------------------------------------------------------*
*&      Form  F_ROUND
*&---------------------------------------------------------------------*
FORM f_round  USING    fu_decimals fu_bdmng fu_sign
              CHANGING fc_bdmng.
  CALL FUNCTION 'ROUND'
    EXPORTING
      decimals      = fu_decimals
      input         = fu_bdmng
      sign          = fu_sign
    IMPORTING
      output        = fc_bdmng
    EXCEPTIONS
      input_invalid = 1
      overflow      = 2
      type_invalid  = 3
      OTHERS        = 4.
ENDFORM.                    " F_ROUND

*&---------------------------------------------------------------------*
*&      Form  F_GET_EXCLUDING_MATERIAL
*&---------------------------------------------------------------------*
FORM f_get_excluding_material .
  CLEAR : gt_006[].

  SELECT *
    FROM ztspppdt006
    INTO CORRESPONDING FIELDS OF TABLE gt_006
    WHERE werks = gs_head-werks
    ORDER BY PRIMARY KEY.
ENDFORM.                    " F_GET_EXCLUDING_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_BOM_QTY
*&---------------------------------------------------------------------*
FORM f_modify_bom_qty  USING    fu_werks fu_matnr1 fu_meins fu_matnr2
                                fu_aufnr fu_posnr
                       CHANGING fc_bdmng fc_meins.
  DATA : ls_resb     LIKE LINE OF gt_resb,
         ls_stpo     LIKE LINE OF gt_stpo,
         lv_bdmng1   TYPE p DECIMALS 1,
         lv_bdmng2   TYPE p DECIMALS 2,
         lv_decimals.

  CLEAR : fc_bdmng, fc_meins.

  IF gs_head-werks = fu_werks AND
    fu_matnr1 = fu_matnr2.
    READ TABLE gt_resb INTO ls_resb
                       WITH KEY aufnr = fu_aufnr
                                matnr = fu_matnr1
                                posnr = fu_posnr.
    IF sy-subrc = 0.
      IF ls_resb-erfme <> fu_meins.
        READ TABLE gt_stpo INTO ls_stpo
                           WITH KEY stlty = ls_resb-stlty
                                    stlnr = ls_resb-stlnr
                                    stlkn = ls_resb-stlkn
                                    stpoz = ls_resb-stpoz.
        IF sy-subrc = 0.
          fc_bdmng = ls_stpo-menge.
          fc_meins = ls_stpo-meins.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_BOM_QTY

*&---------------------------------------------------------------------*
*&      Form  F_EXCEPTION_MATNR
*&---------------------------------------------------------------------*
FORM f_exception_matnr  USING    fu_excty.
  DATA : ls_006    LIKE LINE OF gt_006,
         ls_rawmat LIKE LINE OF gt_rawmat.

  LOOP AT gt_006 INTO ls_006 WHERE excty = fu_excty.
    CASE fu_excty.
      WHEN 'B'.
        PERFORM f_modify_bom_qty USING ls_006-werks ls_006-matnr ls_006-meins gs_weight-rmmat
                                       gs_weight-aufnr gs_weight-posnr
                                 CHANGING gs_weight-bdmng gs_weight-vrkme.
        IF gs_weight-bdmng IS NOT INITIAL.
          EXIT.
        ENDIF.

      WHEN 'P'.
        IF ls_006-werks = gs_head-werks AND
          ls_006-matnr = gv_matnr.
          PERFORM f_modify_pc_qty USING ls_006-werks ls_006-matnr ls_006-meins ls_006-menge
                                        ls_006-sign ls_006-decimals
                                        gs_rawmat-bdmng gs_weight-rmmat gv_charg
                                        gs_weight-posnr
                                  CHANGING gs_weight-bdmng gs_weight-vrkme.
          IF gs_weight-bdmng IS NOT INITIAL.
            READ TABLE gt_rawmat INTO ls_rawmat
                                 WITH KEY matnr = gs_weight-rmmat
                                          charg = gv_charg.
            IF sy-subrc = 0.
              IF ls_rawmat-bdmng2 IS INITIAL.
                ls_rawmat-bdmng2  = gs_weight-bdmng.
                MODIFY gt_rawmat FROM ls_rawmat
                                 TRANSPORTING bdmng2
                                 WHERE matnr = gs_weight-rmmat
                                   AND charg = gv_charg.
              ENDIF.
            ENDIF.
            EXIT.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_EXCEPTION_MATNR

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_PC_QTY
*&---------------------------------------------------------------------*
FORM f_modify_pc_qty  USING    fu_werks fu_matnr fu_meins fu_menge fu_sign
                               fu_decimals fu_bdmng fu_rmmat
                               fu_charg fu_posnr
                      CHANGING fc_bdmng fc_vrkme.

  DATA : ls_rawmat    LIKE LINE OF gt_rawmat.
  DATA : lv_pc(30),
         lv_kg(30),
         lv_bdmng  TYPE resb-bdmng,
         lv_bdmng2 TYPE p DECIMALS 5,
         lv_qty    TYPE resb-enmng,
         lv_enmng  TYPE resb-enmng.

  DATA : lv_meanval  TYPE bapi2045d2-mean_value,
         lv_text     TYPE bapi2045l2-txt_oper,
         lv_inspoper TYPE bapi2045l2-inspoper.

  PERFORM f_qty_conversion USING fu_rmmat fu_werks fu_charg 'QTY_CONVERSION' ''
                           CHANGING lv_pc.

  lv_text     = 'Berat Rata – Rata'.
  lv_inspoper = '9999'.   "'0080'.

  PERFORM f_change_inspoper USING fu_matnr fu_charg fu_werks
                            CHANGING lv_text lv_inspoper.


  CALL FUNCTION 'ZQMMATNR_FACTOR'
    EXPORTING
      i_matnr      = fu_matnr
      i_charg      = fu_charg
      i_werks      = fu_werks
      i_text       = lv_text
      i_inspoper   = lv_inspoper
    IMPORTING
      e_mean_value = lv_meanval.

  TRANSLATE lv_meanval USING '. '.
  TRANSLATE lv_meanval USING ',.'.
  CONDENSE lv_meanval.
  IF lv_meanval IS INITIAL.
    fc_bdmng = 1.
  ELSE.
    fc_bdmng      = lv_meanval.
*    gv_meanval2   = lv_meanval.
    lv_qty        = lv_meanval.
    WRITE lv_qty TO gv_meanval2 DECIMALS 2.
    TRANSLATE gv_meanval2 USING '. '.
    TRANSLATE gv_meanval2 USING ',.'.
    CONDENSE gv_meanval2.
    ls_rawmat-meanval = gv_meanval2.
    ls_rawmat-meantyp = 'X'.
    MODIFY gt_rawmat FROM ls_rawmat TRANSPORTING meanval meantyp
      WHERE matnr = fu_matnr
        AND charg = fu_charg.
  ENDIF.

  lv_bdmng2 = ( fc_bdmng * fu_bdmng ) / 1000000.
  PERFORM f_round USING 2 lv_bdmng2 '-'
                  CHANGING lv_bdmng.

  READ TABLE gt_rawmat INTO ls_rawmat
                       WITH KEY enmng = 0.
  IF sy-subrc = 0.
    LOOP AT gt_rawmat INTO ls_rawmat.
      ADD ls_rawmat-enmng TO lv_enmng.
    ENDLOOP.
  ENDIF.

  fc_bdmng  = lv_bdmng + lv_enmng.
  fc_vrkme  = fu_meins.
ENDFORM.                    " F_MODIFY_PC_QTY

*&---------------------------------------------------------------------*
*&      Form  F_MATNR_PC
*&---------------------------------------------------------------------*
FORM f_matnr_pc  USING    fu_proc fu_enmng fu_enmng1 fu_bdmng
                 CHANGING fc_enmng.
  DATA : ls_006    LIKE LINE OF gt_006,
         ls_rawmat LIKE LINE OF gt_rawmat.
  DATA : lv_excty TYPE ztspppdt006-excty,
         lv_enmng TYPE p DECIMALS 5.

  lv_excty  = 'P'.

  CLEAR ls_006.
  READ TABLE gt_006 INTO ls_006
                    WITH KEY werks = gs_head-werks
                             matnr = gv_matnr
                             excty = lv_excty.
  IF sy-subrc = 0.
    CASE fu_proc.
      WHEN '1'.
        TRY .
            lv_enmng  = ( fu_enmng * 1000000 ) / gv_meanval2.
          CATCH cx_sy_zerodivide.
        ENDTRY.
        PERFORM f_round USING '0' lv_enmng '+'
                        CHANGING fc_enmng.
      WHEN '2'.
        fc_enmng  = fu_enmng1.
      WHEN '3'.
        fc_enmng  = fu_enmng1.
      WHEN '4'.
        READ TABLE gt_rawmat INTO ls_rawmat
                             WITH KEY matnr = gv_matnr
                                      charg = gv_charg.
        IF sy-subrc = 0.
          fc_enmng  = ls_rawmat-bdmng2.
        ENDIF.
    ENDCASE.
  ELSE.
    CASE fu_proc.
      WHEN '2'.
        fc_enmng  = fu_enmng.
      WHEN '3'.
        fc_enmng  = fu_bdmng.
      WHEN '4'.
        fc_enmng  = fu_enmng.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_CEK_MATNR_PC

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_INSPOPER
*&---------------------------------------------------------------------*
FORM f_change_inspoper  USING    fu_matnr
                                 fu_charg
                                 fu_werks
                        CHANGING fc_text
                                 fc_inspoper.
  DATA : lt_qals  TYPE STANDARD TABLE OF qals,
         ls_qals  LIKE LINE OF lt_qals,
         lr_qherk TYPE RANGE OF qherk,
         ls_qherk LIKE LINE OF lr_qherk,
         lr_stat  TYPE RANGE OF j_status,
         ls_stat  LIKE LINE OF lr_stat,
         lt_jest  TYPE STANDARD TABLE OF jest,
         ls_jest  LIKE LINE OF lt_jest.

  DATA : inspoper_list TYPE STANDARD TABLE OF bapi2045l2,
         ls_list       LIKE LINE OF inspoper_list.

  ls_qherk-low    = '01'.
  ls_qherk-sign   = 'I'.
  ls_qherk-option = 'EQ'.
  APPEND ls_qherk TO lr_qherk.
  CLEAR ls_qherk.
  ls_qherk-low    = '09'.
  ls_qherk-sign   = 'I'.
  ls_qherk-option = 'EQ'.
  APPEND ls_qherk TO lr_qherk.
  CLEAR ls_qherk.

  ls_stat-low     = 'I0224'.
  ls_stat-sign    = 'I'.
  ls_stat-option  = 'EQ'.
  APPEND ls_stat TO lr_stat.
  CLEAR ls_stat.
  ls_stat-low     = 'I0043'.
  ls_stat-sign    = 'I'.
  ls_stat-option  = 'EQ'.
  APPEND ls_stat TO lr_stat.
  CLEAR ls_stat.

  SELECT *
    FROM qals
    INTO CORRESPONDING FIELDS OF TABLE lt_qals
    WHERE matnr    = fu_matnr
      AND charg    = fu_charg
      AND werk     = fu_werks
      AND herkunft IN lr_qherk
    ORDER BY PRIMARY KEY.

  IF lt_qals[] IS NOT INITIAL.
    SELECT *
      FROM jest
      INTO CORRESPONDING FIELDS OF TABLE lt_jest
      FOR ALL ENTRIES IN lt_qals
        WHERE objnr = lt_qals-objnr
          AND stat  IN lr_stat
          AND inact = space
      ORDER BY PRIMARY KEY.
  ENDIF.

  LOOP AT lt_qals INTO ls_qals.
    READ TABLE lt_jest INTO ls_jest
                       WITH KEY objnr = ls_qals-objnr.
    IF sy-subrc = 0.
      DELETE TABLE lt_qals FROM ls_qals.
    ENDIF.
  ENDLOOP.

  SORT lt_qals BY herkunft enstehdat DESCENDING entstezeit DESCENDING.

  CLEAR ls_qals.
  READ TABLE lt_qals INTO ls_qals
                     WITH KEY herkunft = '01'.

  IF ls_qals IS NOT INITIAL.
    CALL FUNCTION 'BAPI_INSPLOT_GETOPERATIONS'
      EXPORTING
        number        = ls_qals-prueflos
      TABLES
        inspoper_list = inspoper_list.

    LOOP AT inspoper_list INTO ls_list.
      IF ls_list-txt_oper(10) = fc_text(10).
        fc_text     = ls_list-txt_oper.
        fc_inspoper = ls_list-inspoper.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF..
ENDFORM.                    " F_CHANGE_INSPOPER

*&---------------------------------------------------------------------*
*&      Form  F_GET_SANITASI
*&---------------------------------------------------------------------*
FORM f_get_sanitasi .
  DATA: lv_name     LIKE thead-tdname,
        lt_lines    TYPE STANDARD TABLE OF tline,
        ls_lines    LIKE LINE OF lt_lines,
        lv_posnr    TYPE resb-rspos,
        ls_sanitasi LIKE LINE OF gt_sanitasi.

  CLEAR: gt_sanitasi,gs_sanitasi.
  IF gv_tools IS INITIAL.
    lv_name = 'ZTSPPPE001'.
  ELSE.
    lv_name = 'ZTSPPPE001A'.
  ENDIF.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ST'
      language                = sy-langu
      name                    = lv_name
      object                  = 'TEXT'
    TABLES
      lines                   = lt_lines
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
    LOOP AT lt_lines INTO ls_lines.
      ADD 1 TO lv_posnr.
      ls_sanitasi-posnr   = lv_posnr.
      ls_sanitasi-matdes   = ls_lines-tdline.
      APPEND ls_sanitasi TO gt_sanitasi.
      CLEAR ls_sanitasi.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_SANITASI

*&---------------------------------------------------------------------*
*&      Form  F_NEXT_SANITASI
*&---------------------------------------------------------------------*
FORM f_next_sanitasi .
  IF gs_head-select IS NOT INITIAL.
    READ TABLE gt_sanitasi INTO gs_sanitasi
                           WITH KEY posnr = gs_head-select.
    IF sy-subrc = 0.
      IF gv_tools IS INITIAL.
        gs_weights-matdes   = gs_sanitasi-matdes.
      ELSE.
        gs_weights-santol   = gs_sanitasi-matdes.
      ENDIF.
      gs_weights-operator = gv_operator.

      CALL SCREEN 105.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_NEXT_SANITASI

*&---------------------------------------------------------------------*
*&      Form  F_NEXT_0105
*&---------------------------------------------------------------------*
FORM f_next_0105 .
  IF gs_weights-equnr IS NOT INITIAL.
    gs_weight-equnr = gs_weights-equnr.

    SELECT SINGLE werks INTO gs_weight-werks
      FROM ztnpppdt002 WHERE equnr = gs_weight-equnr.

    PERFORM f_get_equipment.

    gs_weights-message = gs_weight-message.
    gs_weights-shtxt   = gs_weight-shtxt.

    CLEAR: gs_weight-equnr,gs_weight-message,gs_weight-shtxt,
           gv_remark,gv_uri_addr,gv_eqfnr.
  ENDIF.
ENDFORM.                    " F_NEXT_0105

*&---------------------------------------------------------------------*
*&      Form  F_GET_LAST_MATERIAL
*&---------------------------------------------------------------------*
FORM f_get_last_material .
  DATA: BEGIN OF ls_key1,
          werks TYPE werks_d,
          equnr TYPE equnr,
          afind TYPE zafind,
        END OF ls_key1.

  DATA: BEGIN OF ls_key2,
          werks TYPE werks_d,
          equnr TYPE equnr,
          datum TYPE datum,
        END OF ls_key2.

  DATA: lt_ztspppdt007 TYPE STANDARD TABLE OF ztspppdt007,
*        ls_ztspppdt007 LIKE LINE OF lt_ztspppdt007,
        lt_zppresb_add TYPE STANDARD TABLE OF zppresb_add,
*        ls_zppresb_add LIKE LINE OF lt_zppresb_add,
        lv_timestamp1  TYPE tzntstmps,
        lv_timestamp2  TYPE tzntstmps.

  SELECT SINGLE werks INTO gs_weights-werks
    FROM ztnpppdt002 WHERE equnr = gs_weights-equnr.

  SELECT SINGLE werks equnr MAX( afind )
    INTO (ls_key1-werks, ls_key1-equnr, ls_key1-afind)
    FROM ztspppdt007
    WHERE werks = gs_weights-werks
      AND equnr = gs_weights-equnr
    GROUP BY werks equnr.
  IF sy-subrc = 0.
    SELECT * INTO TABLE lt_ztspppdt007
      FROM ztspppdt007 WHERE werks = ls_key1-werks
                         AND afind = ls_key1-afind
                         AND equnr = ls_key1-equnr
                         AND lgort = space
      ORDER BY PRIMARY KEY.
    IF sy-subrc = 0.
      SORT lt_ztspppdt007 BY afind DESCENDING afinu DESCENDING.
      READ TABLE lt_ztspppdt007 INTO gs_ztspppdt007 INDEX 1.
    ENDIF.
  ENDIF.

  SELECT SINGLE werks equnr MAX( datum )
    INTO (ls_key2-werks, ls_key2-equnr, ls_key2-datum)
    FROM zppresb_add
    WHERE werks = gs_weights-werks
      AND equnr = gs_weights-equnr
    GROUP BY werks equnr.
  IF sy-subrc = 0.
    SELECT * INTO TABLE lt_zppresb_add
      FROM zppresb_add WHERE werks = ls_key2-werks
                         AND equnr = ls_key2-equnr
                         AND datum = ls_key2-datum
      ORDER BY PRIMARY KEY.
    IF sy-subrc = 0.
      SORT lt_zppresb_add BY datum DESCENDING uzeit DESCENDING.
      READ TABLE lt_zppresb_add INTO gs_zppresb_add INDEX 1.
    ENDIF.
  ENDIF.

  PERFORM f_get_timestamp USING gs_ztspppdt007-afind
                                gs_ztspppdt007-afinu
                          CHANGING lv_timestamp1.

  PERFORM f_get_timestamp USING gs_zppresb_add-datum
                                gs_zppresb_add-uzeit
                          CHANGING lv_timestamp2.

  IF lv_timestamp1 GT lv_timestamp2.
    IF gs_ztspppdt007-aufnr IS NOT INITIAL AND
       gs_ztspppdt007-charg IS INITIAL.
      SELECT SINGLE charg INTO gs_ztspppdt007-charg
        FROM afpo WHERE aufnr = gs_ztspppdt007-aufnr.
    ENDIF.
    IF gs_ztspppdt007-matnr IS INITIAL .
*      CONCATENATE gs_ztspppdt007-maktx gs_ztspppdt007-charg
*        INTO gs_weights-lastmat SEPARATED BY '/'.
      gs_weights-lastmat = gs_ztspppdt007-maktx.
      gs_weights-lastbat = gs_ztspppdt007-charg.
      gs_weights-aufnr   = gs_ztspppdt007-aufnr.
    ELSE.
*      CONCATENATE gs_ztspppdt007-matnr gs_ztspppdt007-charg
*        INTO gs_weights-lastmat SEPARATED BY '/'.
      gs_weights-lastmat = gs_ztspppdt007-matnr.
      gs_weights-lastbat = gs_ztspppdt007-charg.
      gs_weights-aufnr   = gs_ztspppdt007-aufnr.
    ENDIF.
  ELSE.
    PERFORM f_get_resb_lastmat.
  ENDIF.
ENDFORM.                    " F_GET_LAST_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_GET_TIMESTAMP
*&---------------------------------------------------------------------*
FORM f_get_timestamp  USING    fu_date
                               fu_time
                      CHANGING fc_timestamp.
  CALL FUNCTION 'ABI_TIMESTAMP_CONVERT_INTO'
    EXPORTING
      iv_date          = fu_date
      iv_time          = fu_time
    IMPORTING
      ev_timestamp     = fc_timestamp
    EXCEPTIONS
      conversion_error = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " F_GET_TIMESTAMP

*&---------------------------------------------------------------------*
*&      Form  F_GET_TIMESTAMP_DURATION
*&---------------------------------------------------------------------*
FORM f_get_timestamp_duration  USING    fu_timestamp_in
                                        fu_duration
                                        fu_unit
                                        fu_oper
                               CHANGING fc_timestamp_out.
  CASE fu_oper.
    WHEN 'ADD'.
      CALL FUNCTION 'TIMESTAMP_DURATION_ADD'
        EXPORTING
          timestamp_in    = fu_timestamp_in
          duration        = fu_duration
          unit            = fu_unit
        IMPORTING
          timestamp_out   = fc_timestamp_out
        EXCEPTIONS
          timestamp_error = 1
          OTHERS          = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

    WHEN 'SUB'.
      CALL FUNCTION 'TIMESTAMP_DURATION_SUB'
        EXPORTING
          timestamp_in    = fu_timestamp_in
          duration        = fu_duration
          unit            = fu_unit
        IMPORTING
          timestamp_out   = fc_timestamp_out
        EXCEPTIONS
          timestamp_error = 1
          OTHERS          = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_TIMESTAMP_DURATION

*&---------------------------------------------------------------------*
*&      Form  F_GET_RESB_LASTMAT
*&---------------------------------------------------------------------*
FORM f_get_resb_lastmat .
  DATA: lt_resb TYPE STANDARD TABLE OF resb,
        ls_resb LIKE LINE OF lt_resb.

  SELECT rsnum rspos rsart matnr werks lgort charg aufnr posnr
    INTO CORRESPONDING FIELDS OF TABLE lt_resb
    FROM resb WHERE aufnr = gs_zppresb_add-aufnr
                AND posnr = gs_zppresb_add-posnr
                AND matnr = gs_zppresb_add-matnr
    ORDER BY PRIMARY KEY.
  IF sy-subrc = 0.
    SORT lt_resb BY rspos DESCENDING.
    READ TABLE lt_resb INTO ls_resb INDEX 1.
*    CONCATENATE ls_resb-matnr ls_resb-charg
*      INTO gs_weights-lastmat SEPARATED BY '/'.
    gs_weights-lastmat = ls_resb-matnr.
    gs_weights-lastbat = ls_resb-charg.
    gs_weights-aufnr   = gs_zppresb_add-aufnr.
    gs_weights-ltxa1   = gs_zppresb_add-ltxa1.
  ENDIF.
ENDFORM.                    " F_GET_RESB_LASTMAT

*&---------------------------------------------------------------------*
*&      Form  F_CALC_VALIDITY
*&---------------------------------------------------------------------*
FORM f_calc_validity .
  DATA: lv_timestamp_in  TYPE tzntstmps,
        lv_timestamp_out TYPE tzntstmps.

  PERFORM f_get_timestamp USING gs_weights-findat
                                gs_weights-fintim
                          CHANGING lv_timestamp_in.

  PERFORM f_get_timestamp_duration USING    lv_timestamp_in
                                            '72' 'H' 'ADD'
                                   CHANGING lv_timestamp_out.

  CALL FUNCTION 'ABI_TIMESTAMP_CONVERT_FROM'
    EXPORTING
      iv_timestamp     = lv_timestamp_out
    IMPORTING
      o_date           = gs_weights-valdat
      o_time           = gs_weights-valtim
    EXCEPTIONS
      conversion_error = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " F_CALC_VALIDITY

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_SANITASI
*&---------------------------------------------------------------------*
FORM f_print_sanitasi .
  PERFORM f_prepare_save_table.
  PERFORM f_print_form_sanitasi.
  gv_operator = gs_weight-operator = gs_weights-operator.
  CLEAR: gs_weights,gt_sanitasi,gs_sanitasi,gt_ztspppdt009,gs_ztspppdt009,
         gs_ztspppdt007,gs_zppresb_add,gv_wuser,gv_sanitasi,gv_tools,
         gv_wname,gv_wnrp,gv_wpass,gv_wcheck,gv_message.
  PERFORM f_clear_data USING 'PRINT'.
ENDFORM.                    " F_PRINT_SANITASI

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_SAVE_TABLE
*&---------------------------------------------------------------------*
FORM f_prepare_save_table .
  gs_ztspppdt009-werks    = gs_weights-werks.
  gs_ztspppdt009-afind    = gs_weights-findat.
  gs_ztspppdt009-afinu    = gs_weights-fintim.
  gs_ztspppdt009-equnr    = gs_weights-equnr.
  gs_ztspppdt009-shtxt    = gs_weights-shtxt.
  gs_ztspppdt009-wbooth   = gs_weights-wb.
  gs_ztspppdt009-matnr    = gs_weights-lastmat.
*  gs_ztspppdt009-maktx    = gs_weights-lastmat.
  gs_ztspppdt009-charg    = gs_weights-lastbat.
  gs_ztspppdt009-astad    = gs_weights-strdat.
  gs_ztspppdt009-astau    = gs_weights-strtim.
  gs_ztspppdt009-avald    = gs_weights-valdat.
  gs_ztspppdt009-avalu    = gs_weights-valtim.
  gs_ztspppdt009-operator = gs_weights-operator.
  gs_ztspppdt009-pengawas = gs_weights-pengawas.
  gs_ztspppdt009-aufnr    = gs_weights-aufnr.
  gs_ztspppdt009-ltxa1    = gs_weights-ltxa1.
  gs_ztspppdt009-santx    = gs_weights-matdes.
  gs_ztspppdt009-santl    = gs_weights-santol.

  SELECT SINGLE maktx INTO gs_ztspppdt009-maktx
    FROM makt WHERE matnr = gs_weights-lastmat.
  IF sy-subrc NE 0.
    gs_ztspppdt009-maktx    = gs_weights-lastmat.
*    SHIFT gs_ztspppdt009-charg LEFT DELETING LEADING '0'.
  ENDIF.

  APPEND gs_ztspppdt009 TO gt_ztspppdt009.
ENDFORM.                    " F_PREPARE_SAVE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM_SANITASI
*&---------------------------------------------------------------------*
FORM f_print_form_sanitasi .
  DATA : lv_formname  TYPE tdsfname,
         lv_funcname  TYPE tdsfname,
         lv_weekday   LIKE  dtresr-weekday,
         ctrl_param   LIKE ssfctrlop,
         output_opt   TYPE ssfcompop,
         ls_label     TYPE ztspppst004,
         default      TYPE bapidefaul,
         return       TYPE STANDARD TABLE OF bapiret2,
         lv_ldest     TYPE t329d-ldest,
         lv_tvarv_val TYPE tvarv_val.

  SELECT SINGLE low INTO lv_tvarv_val
    FROM tvarvc WHERE name = 'SANITASI'.

  lv_formname = 'ZTSPPPF008'.

  CALL FUNCTION 'DATE_TO_DAY'
    EXPORTING
      date    = gs_ztspppdt009-avald
    IMPORTING
      weekday = lv_weekday.

  PERFORM f_name_of_day USING    'ID'
                        CHANGING lv_weekday.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      defaults = default
    TABLES
      return   = return.

  PERFORM f_get_print_dest USING gs_weights-equnr
                           CHANGING gv_print_dest.

  IF gv_print_dest IS NOT INITIAL.
    lv_ldest = gv_print_dest.
  ELSE.
    lv_ldest = default-spld.
  ENDIF.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF gs_ztspppdt009-santx = lv_tvarv_val.
    "# 1
    ctrl_param-no_close   = space.
    ctrl_param-no_dialog  = 'X'.

    output_opt-tdnewid    = 'X'.
    output_opt-tdimmed    = 'X'.
    output_opt-tddelete   = ''.
    output_opt-tddest     = lv_ldest.

    CALL FUNCTION lv_funcname
      EXPORTING
        control_parameters = ctrl_param
        output_options     = output_opt
        user_settings      = space
        gs_sanitasi        = gs_ztspppdt009
        gv_day             = lv_weekday
        gv_type            = '1'
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

  ELSE.
    "# 1
    ctrl_param-no_close   = space.  "'X'.
    ctrl_param-no_dialog  = 'X'.

    output_opt-tdnewid    = 'X'.
    output_opt-tdimmed    = 'X'.
    output_opt-tddelete   = ''.
    output_opt-tddest     = lv_ldest.

    CALL FUNCTION lv_funcname
      EXPORTING
        control_parameters = ctrl_param
        output_options     = output_opt
        user_settings      = space
        gs_sanitasi        = gs_ztspppdt009
        gv_day             = lv_weekday
        gv_type            = '1'
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    "# 2
    ctrl_param-no_open    = space.  "'X'.
    ctrl_param-no_close   = space.

    CALL FUNCTION lv_funcname
      EXPORTING
        control_parameters = ctrl_param
        output_options     = output_opt
        user_settings      = space
        gs_sanitasi        = gs_ztspppdt009
        gv_day             = lv_weekday
        gv_type            = '2'
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
  ENDIF.

  IF sy-subrc = 0.
    PERFORM f_modify_ztspppdt009.
  ENDIF.
ENDFORM.                    " F_PRINT_FORM_SANITASI

*&---------------------------------------------------------------------*
*&      Form  F_GET_PRINT_DEST
*&---------------------------------------------------------------------*
FORM f_get_print_dest  USING    fu_equnr
                       CHANGING fu_print_dest.
  DATA : e_equi_header TYPE alm_me_tob_header,
         return        TYPE STANDARD TABLE OF bapiret2,
         ls_return     LIKE LINE OF return.

  CALL FUNCTION 'ALM_ME_EQUIPMENT_GETDETAIL'
    EXPORTING
      i_equipment    = fu_equnr
    IMPORTING
      e_equi_header  = e_equi_header
    TABLES
      return         = return
    EXCEPTIONS
      not_successful = 1
      OTHERS         = 2.

  READ TABLE return INTO ls_return
                    WITH KEY type = 'E'.
  IF sy-subrc = 0.
  ELSE.
    SELECT SINGLE print_dest
      FROM adr10
      INTO gv_print_dest
      WHERE addrnumber = e_equi_header-adrnr.
  ENDIF.
ENDFORM.                    " F_GET_PRINT_DEST

*&---------------------------------------------------------------------*
*&      Form  F_NAME_OF_DAY
*&---------------------------------------------------------------------*
FORM f_name_of_day  USING    fu_langu
                    CHANGING fc_weekday.
  DATA: lv_weekday(10).

  lv_weekday = fc_weekday.
  TRANSLATE lv_weekday TO UPPER CASE.

  CASE lv_weekday.
    WHEN 'SUNDAY'.
      fc_weekday = 'Minggu'.
    WHEN 'MONDAY'.
      fc_weekday = 'Senin'.
    WHEN 'TUESDAY'.
      fc_weekday = 'Selasa'.
    WHEN 'WEDNESDAY'.
      fc_weekday = 'Rabu'.
    WHEN 'THURSDAY'.
      fc_weekday = 'Kamis'.
    WHEN 'FRIDAY'.
      fc_weekday = 'Jumat'.
    WHEN 'SATURDAY' OR 'SAT.'.
      fc_weekday = 'Sabtu'.
  ENDCASE.
ENDFORM.                    " F_NAME_OF_DAY

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ZTSPPPDT009
*&---------------------------------------------------------------------*
FORM f_modify_ztspppdt009 .
  MODIFY ztspppdt009 FROM gs_ztspppdt009.
ENDFORM.                    " F_MODIFY_ZTSPPPDT009

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_SANITASI
*&---------------------------------------------------------------------*
FORM f_check_sanitasi .
  DATA: lv_timestamp1    TYPE tzntstmps,
        lv_timestamp2    TYPE tzntstmps,
        lv_timestamp_out TYPE tzntstmps.

*  break tds_dev01.
  CLEAR gv_err_sanitasi.
  PERFORM f_get_last_sanitasi.
  PERFORM f_get_last_material_timbang.

  CLEAR: lv_timestamp1,lv_timestamp2.

  "Get tanggal terakhir penimbangan
  PERFORM f_get_timestamp USING    gs_weight-matdat
                                   gs_weight-mattim
                          CHANGING lv_timestamp1.

  "Get tanggal terakhir sanitasi
  PERFORM f_get_timestamp USING    gs_weight-findat
                                   gs_weight-fintim
                          CHANGING lv_timestamp2.

  "Cek apakah ada penimbangan setelah sanitasi terakhir
  IF lv_timestamp1 GE lv_timestamp2.

    "Cek material terakhir penimbangan dg material scan
    IF gs_weight-lastmat NE gv_matnr.
      gv_err_sanitasi = 'Mohon lakukan sanitasi terlebih dahulu'.

    ELSE.
      CLEAR: lv_timestamp1,lv_timestamp2.
      "Get tanggal terakhir penimbangan
      PERFORM f_get_timestamp USING    gs_weight-matdat
                                       gs_weight-mattim
                              CHANGING lv_timestamp1.

      "Get tanggal scan material
      PERFORM f_get_timestamp USING    gs_weight-scandt
                                       gs_weight-scantm
                              CHANGING lv_timestamp2.

      "Get durasi waktu scan ditambah 2 jam
      PERFORM f_get_timestamp_duration USING    lv_timestamp1
                                                '2' 'H' 'ADD'
                                       CHANGING lv_timestamp_out.

      "Cek apakah terakhir penimbangan sudah lebih dari 2 jam
      IF lv_timestamp_out LT lv_timestamp2.
        CONCATENATE 'Penimbangan terakhir sudah lebih dari 2 jam,'
                    'Mohon lakukan sanitasi kembali terlebih dahulu'
                    INTO gv_err_sanitasi SEPARATED BY space.
      ENDIF.
    ENDIF.

  ELSE.
    CLEAR: lv_timestamp1,lv_timestamp2.
    "Get tanggal valid
    PERFORM f_get_timestamp USING    gs_weight-valdat
                                     gs_weight-valtim
                            CHANGING lv_timestamp1.

    "Get tanggal scan material
    PERFORM f_get_timestamp USING    gs_weight-scandt
                                     gs_weight-scantm
                            CHANGING lv_timestamp2.

    "Cek apakah tanggal scan sdh lewat dr tanggal valid
    IF lv_timestamp2 GT lv_timestamp1.
      gv_err_sanitasi = 'Lakukan sanitasi ulang terlebih dahulu'.

    ELSE.
    ENDIF.
  ENDIF.

  IF gv_err_sanitasi IS NOT INITIAL.
    CLEAR gs_weight-material.
  ENDIF.
ENDFORM.                    " F_CHECK_SANITASI

*&---------------------------------------------------------------------*
*&      Form  F_GET_LAST_SANITASI
*&---------------------------------------------------------------------*
FORM f_get_last_sanitasi .
  DATA: BEGIN OF ls_key1,
          werks TYPE werks_d,
          equnr TYPE equnr,
          afind TYPE zafind,
          afinu TYPE zafinu,
        END OF ls_key1.
  DATA: ls_key2 LIKE ls_key1.

  SELECT SINGLE werks equnr MAX( afind )
    INTO (ls_key1-werks, ls_key1-equnr, ls_key1-afind)
    FROM ztspppdt009
    WHERE werks = gs_weight-werks
      AND equnr = gs_weight-equnr
    GROUP BY werks equnr.
  IF sy-subrc = 0.
    SELECT SINGLE werks equnr afind MAX( afinu )
      INTO (ls_key2-werks, ls_key2-equnr, ls_key2-afind, ls_key2-afinu)
      FROM ztspppdt009
      WHERE werks = ls_key1-werks
        AND equnr = ls_key1-equnr
        AND afind = ls_key1-afind
      GROUP BY werks equnr afind.
    IF sy-subrc = 0.
      gs_weight-findat = ls_key2-afind.
      gs_weight-fintim = ls_key2-afinu.
      SELECT SINGLE avald avalu
        INTO (gs_weight-valdat, gs_weight-valtim)
        FROM ztspppdt009
        WHERE werks = ls_key1-werks
          AND afind = gs_weight-findat
          AND afinu = gs_weight-fintim
          AND equnr = ls_key1-equnr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_LAST_SANITASI


*&---------------------------------------------------------------------*
*&      Form  F_GET_LAST_MATERIAL_TIMBANG
*&---------------------------------------------------------------------*
FORM f_get_last_material_timbang .
  DATA: BEGIN OF ls_key1,
          werks TYPE werks_d,
          equnr TYPE equnr,
          afind TYPE zafind,
        END OF ls_key1.

  DATA: BEGIN OF ls_key2,
          werks TYPE werks_d,
          equnr TYPE equnr,
          datum TYPE datum,
        END OF ls_key2.

  DATA: lt_ztspppdt007 TYPE STANDARD TABLE OF ztspppdt007,
        lt_zppresb_add TYPE STANDARD TABLE OF zppresb_add,
        lv_timestamp1  TYPE tzntstmps,
        lv_timestamp2  TYPE tzntstmps.

  SELECT SINGLE werks equnr MAX( afind )
    INTO (ls_key1-werks, ls_key1-equnr, ls_key1-afind)
    FROM ztspppdt007
    WHERE werks = gs_weight-werks
      AND equnr = gs_weight-equnr
    GROUP BY werks equnr.
  IF sy-subrc = 0.
    SELECT * INTO TABLE lt_ztspppdt007
      FROM ztspppdt007 WHERE werks = ls_key1-werks
                         AND equnr = ls_key1-equnr
                         AND afind GE ls_key1-afind
                         AND lgort = space
      ORDER BY PRIMARY KEY.
    IF sy-subrc = 0.
      SORT lt_ztspppdt007 BY afind DESCENDING afinu DESCENDING.
      READ TABLE lt_ztspppdt007 INTO gs_ztspppdt007 INDEX 1.
    ENDIF.
  ENDIF.

  SELECT SINGLE werks equnr MAX( datum )
    INTO (ls_key2-werks, ls_key2-equnr, ls_key2-datum)
    FROM zppresb_add
    WHERE werks = gs_weight-werks
      AND equnr = gs_weight-equnr
    GROUP BY werks equnr.
  IF sy-subrc = 0.
    SELECT * INTO TABLE lt_zppresb_add
      FROM zppresb_add WHERE werks = ls_key2-werks
                         AND equnr = ls_key2-equnr
                         AND datum = ls_key2-datum
      ORDER BY PRIMARY KEY.
    IF sy-subrc = 0.
      SORT lt_zppresb_add BY datum DESCENDING uzeit DESCENDING.
      READ TABLE lt_zppresb_add INTO gs_zppresb_add INDEX 1.
    ENDIF.
  ENDIF.

  PERFORM f_get_timestamp USING gs_ztspppdt007-afind
                                gs_ztspppdt007-afinu
                          CHANGING lv_timestamp1.

  PERFORM f_get_timestamp USING gs_zppresb_add-datum
                                gs_zppresb_add-uzeit
                          CHANGING lv_timestamp2.

  IF lv_timestamp1 GT lv_timestamp2.
    IF gs_ztspppdt007-matnr IS INITIAL .
      gs_weight-lastmat = gs_ztspppdt007-maktx.
    ELSE.
      gs_weight-lastmat = gs_ztspppdt007-matnr.
    ENDIF.
    gs_weight-lastbat = gs_ztspppdt007-charg.
    gs_weight-matdat  = gs_ztspppdt007-afind.
    gs_weight-mattim  = gs_ztspppdt007-afinu.
  ELSE.
    PERFORM f_get_resb_lastmat_timbang.
  ENDIF.
ENDFORM.                    " F_GET_LAST_MATERIAL_TIMBANG

*&---------------------------------------------------------------------*
*&      Form  F_GET_RESB_LASTMAT_TIMBANG
*&---------------------------------------------------------------------*
FORM f_get_resb_lastmat_timbang .
  DATA: lt_resb TYPE STANDARD TABLE OF resb,
        ls_resb LIKE LINE OF lt_resb.

  SELECT rsnum rspos rsart matnr werks lgort charg aufnr posnr
    INTO CORRESPONDING FIELDS OF TABLE lt_resb
    FROM resb WHERE aufnr = gs_zppresb_add-aufnr
                AND posnr = gs_zppresb_add-posnr
                AND matnr = gs_zppresb_add-matnr.
  IF sy-subrc = 0.
    SORT lt_resb BY rspos DESCENDING.
    READ TABLE lt_resb INTO ls_resb INDEX 1.
    gs_weight-lastmat = ls_resb-matnr.
    gs_weight-lastbat = ls_resb-charg.
    gs_weight-matdat  = gs_zppresb_add-datum.
    gs_weight-mattim  = gs_zppresb_add-uzeit.
  ENDIF.
ENDFORM.                    " F_GET_RESB_LASTMAT_TIMBANG

*&---------------------------------------------------------------------*
*&      Form  F_CEK_MINMAX_TIMBANG
*&---------------------------------------------------------------------*
FORM f_cek_minmax_timbang  USING    fu_werks
                                    fu_equnr
                                    fu_nmein
                                    fu_bruto
                           CHANGING fc_message
                                    fc_minmax.
  DATA: ls_ztspppdt010 TYPE ztspppdt010,
        lv_bruto       TYPE resb-bdmng.

  fc_minmax = 'X'.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF ls_ztspppdt010
    FROM ztspppdt010 WHERE werks = fu_werks
                       AND equnr = fu_equnr.
  IF sy-subrc = 0.
    IF ls_ztspppdt010-meins NE fu_nmein.
      PERFORM f_uom_conversion USING    '' fu_nmein ls_ztspppdt010-meins
                                        fu_bruto
                               CHANGING lv_bruto.
    ELSE.
      lv_bruto = fu_bruto.
    ENDIF.

    IF lv_bruto GE ls_ztspppdt010-wgtmin.
      CLEAR fc_minmax.      "OK
    ELSE.
      fc_message = 'Bruto harus lebih besar daripada minimal penimbangan timbangan'.
    ENDIF.

  ELSE.
    CLEAR fc_minmax.          "OK
  ENDIF.
ENDFORM.                    " F_CEK_MINMAX_TIMBANG

*&---------------------------------------------------------------------*
*&      Form  F_GET_VENDOR
*&---------------------------------------------------------------------*
FORM f_get_vendor  USING    fu_matnr
                            fu_charg
                   CHANGING fc_lifnr
                            fc_name1.
*  SELECT SINGLE a~lifnr a~name1
*    INTO (fc_lifnr, fc_name1)
*    FROM lfa1 AS a JOIN mch1 AS b ON a~lifnr = b~lifnr
*    WHERE b~matnr = fu_matnr
*      AND b~charg = fu_charg.

  DATA : cob    TYPE STANDARD TABLE OF clbatch,
         ls_cob LIKE LINE OF cob.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      matnr              = fu_matnr
      charg              = fu_charg
      werks              = gs_head-werks
      get_classification = 'X'
    TABLES
      char_of_batch      = cob
    EXCEPTIONS
      no_material        = 1
      no_batch           = 2
      no_plant           = 3
      material_not_found = 4
      plant_not_found    = 5
      no_authority       = 6
      batch_not_exist    = 7
      lock_on_batch      = 8
      OTHERS             = 9.

  IF sy-subrc = 0.
    fc_name1 = VALUE #( cob[ atnam = 'ZMF' ]-atwtb OPTIONAL ).
  ENDIF.
ENDFORM.                    " F_GET_VENDOR
