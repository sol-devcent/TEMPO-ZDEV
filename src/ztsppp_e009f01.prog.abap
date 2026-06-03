*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E009F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  SET PF-STATUS 'PFSTATUS' EXCLUDING fcode.
  SET TITLEBAR 'TITLE'.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_PBO
*&---------------------------------------------------------------------*
FORM f_pbo .
  IF gs_head-netto IS INITIAL.
    PERFORM f_modify_screen USING : 'PRI' '0' '' '' ''.
  ELSE.
    IF gs_rwork IS NOT INITIAL.
      IF gv_netto NE gs_rwork-netto.
        PERFORM f_modify_screen USING : 'PRI' '0' '' '' ''.
      ENDIF.
    ENDIF.
  ENDIF.

  IF gs_head-matnr IS INITIAL.
    IF gv_others IS INITIAL.
      PERFORM f_modify_screen USING : 'RAW' '0' '' '' ''.
    ENDIF.
  ELSE.
    IF gs_head-message IS NOT INITIAL.
      IF gv_minmax IS INITIAL.
        PERFORM f_modify_screen USING : 'RAW' '0' '' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'PRI' '0' '' '' ''.
      ENDIF.
    ENDIF.
  ENDIF.

  IF gs_head-gstrp IS INITIAL.
    PERFORM f_modify_screen USING : 'TIM' '0' '' '' ''.
  ENDIF.

  IF gs_head-werks = '0101' OR gs_head-werks = '0102'.
    IF gs_head-equnr IS NOT INITIAL.
      PERFORM f_modify_screen USING : 'OTH' '1' '' '' ''.
    ELSE.
      PERFORM f_modify_screen USING : 'OTH' '0' '' '' ''.
    ENDIF.
  ELSE.
    PERFORM f_modify_screen USING : 'OTH' '0' '' '' ''.
  ENDIF.

  IF gs_head-werks IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-WERKS' ''.
  ELSEIF gs_head-operator IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-OPERATOR' ''.
  ELSEIF gs_head-pengawas IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-PENGAWAS' ''.
  ELSEIF gs_head-wb IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-WB' ''.
  ELSEIF gs_head-gstrp IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-EQUNR' ''.
  ELSEIF gs_head-cmatnr IS INITIAL.
    IF gs_head-matnr IS INITIAL.
      PERFORM f_cursor_position USING 'GS_HEAD-CMATNR' ''.
    ENDIF.
  ENDIF.

  IF gs_head-werks IS NOT INITIAL.
    PERFORM f_modify_screen USING : '001' '' '0' '' ''.
  ENDIF.

  IF gs_head-operator IS NOT INITIAL.
    PERFORM f_modify_screen USING : '002' '' '0' '' ''.
  ENDIF.

  IF gs_head-pengawas IS NOT INITIAL.
    PERFORM f_modify_screen USING : '003' '' '0' '' ''.
  ENDIF.

  IF gs_head-wb IS NOT INITIAL.
    PERFORM f_modify_screen USING : '004' '' '0' '' ''.
  ENDIF.

  IF gs_head-gstrp IS NOT INITIAL.
    PERFORM f_modify_screen USING : '005' '' '0' '' ''.
  ENDIF.

  IF gv_others = 'X' AND
     gv_rework IS INITIAL AND
     gv_ibupro IS INITIAL.
    PERFORM f_modify_screen USING : 'CMA' '0' '' '' ''.
    PERFORM f_modify_screen USING : 'BAT' '' '1' '' ''.
  ELSE.
    IF gs_head-matnr IS INITIAL.
      PERFORM f_modify_screen USING : 'BAT' '0' '' '' ''.
    ELSE.
      PERFORM f_modify_screen USING : 'BAT' '' '0' '' ''.
    ENDIF.
    IF gv_ibupro = 'X' AND gs_head-bruto IS NOT INITIAL.
      PERFORM f_modify_screen2 USING : 'GS_HEAD-TARA' '1' '1' '' ''.
    ENDIF.
  ENDIF.

  IF gv_ibupro = 'X'.
    PERFORM f_modify_screen2 USING : 'CHARG' '0' '' '' ''.
    PERFORM f_modify_screen2 USING : 'GS_HEAD-CHARG' '0' '' '' ''.
    PERFORM f_modify_screen2 USING : 'GS_HEAD-ERFME' '0' '' '' ''.
  ENDIF.

  DELETE gt_rawmat WHERE charg IS INITIAL
                     AND erfmg IS INITIAL.
  IF gt_rawmat[] IS INITIAL.
    PERFORM f_modify_screen USING : 'RA2' '0' '' '' ''.
  ELSEIF ( gv_others = 'X' AND gs_head-maktx(6) NE 'Granul' ).
    IF gv_rework IS INITIAL AND gv_ibupro IS INITIAL.
      PERFORM f_modify_screen USING : 'RA2' '0' '' '' ''.
    ENDIF.
  ENDIF.

  IF gt_rawmat[] IS INITIAL.
    APPEND INITIAL LINE TO gt_rawmat.
  ENDIF.
  DESCRIBE TABLE gt_rawmat LINES n2.

  CASE sy-dynnr.
    WHEN '0901'.
      DESCRIBE TABLE gt_others LINES n2.
      gs_head-from  = 1.
      CONDENSE gs_head-from NO-GAPS.
      gs_head-to    = n2.
      CONDENSE gs_head-to NO-GAPS.

      IF gs_head-zdesc NE 'GRANUL REWORK' OR
         gs_head-vornr IS INITIAL.
        PERFORM f_modify_screen USING : 'VOR' '0' '' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'VOR' '' '0' '' ''.
      ENDIF.

      IF gs_head-select IS INITIAL.
        PERFORM f_cursor_position USING 'GS_HEAD-SELECT' ''.
      ELSEIF gs_head-aufnr IS INITIAL.
        PERFORM f_cursor_position USING 'GS_HEAD-AUFNR' ''.
      ELSEIF gs_head-vornr IS INITIAL.
        PERFORM f_cursor_position USING 'GS_HEAD-VORNR' ''.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_PBO

*&---------------------------------------------------------------------*
*&      Form  F_PAI
*&---------------------------------------------------------------------*
FORM f_pai .
  DATA: ls_others LIKE LINE OF gt_others.

  CASE sy-dynnr.
    WHEN '0901'.
      IF gs_head-select IS NOT INITIAL.
        CLEAR gs_head-message.
        READ TABLE gt_others INTO ls_others
                             WITH KEY posnr = gs_head-select.
        IF sy-subrc = 0.
          CASE gs_head-werks.
            WHEN '0101'.
              IF ls_others-maktx = 'Rework' OR
                 ls_others-maktx = 'Sampling Fullpack'.
                gv_rework = 'X'.
                gs_head-othdesc = ls_others-maktx.
                gs_head-othmat  = ls_others-matnr.
              ELSEIF ls_others-maktx = 'Hasil Ayak Ibuprofen'.
                gv_ibupro = 'X'.
                gs_head-othdesc = ls_others-maktx.
                gs_head-othmat  = ls_others-matnr.
              ELSE.
                CLEAR: gv_rework,gv_ibupro.
                gs_head-matnr  = gs_head-aufnr.
                gs_head-maktx  = ls_others-maktx.
                gs_head-othdesc = 'MIS'.
              ENDIF.
            WHEN '0102'.
              gv_rework = 'X'.
              gs_head-othdesc = ls_others-maktx.
              gs_head-othmat  = ls_others-matnr.
          ENDCASE.

          gs_head-zdesc = ls_others-maktx(13).
          TRANSLATE gs_head-zdesc TO UPPER CASE.
          IF gs_head-zdesc = 'GRANUL REWORK'.
          ELSE.
            CLEAR gs_head-zdesc.
          ENDIF.
        ENDIF.

*        IF gs_head-maktx(6) = 'Granul'.
        IF gv_others = 'X' AND gs_head-aufnr IS NOT INITIAL.
          SELECT SINGLE matnr charg
            INTO (gs_head-plnbez,gs_head-fcharg)
            FROM afpo WHERE aufnr = gs_head-aufnr
                        AND pwerk = gs_head-werks.

          IF sy-subrc = 0.
            IF gs_head-message = 'Process Order Salah'.
              CLEAR gs_head-message.
            ENDIF.

            PERFORM f_cek_granul.

            CLEAR gs_head-message.
            SELECT SINGLE maktx INTO gs_head-fmaktx
              FROM makt WHERE matnr = gs_head-plnbez
                          AND spras = sy-langu.
          ELSE.
            gs_head-message = 'Process Order Salah'.
          ENDIF.
        ELSE.
          CLEAR: gs_rwork,gs_head-charg,gs_head-aufnr,gs_head-fmaktx.
        ENDIF.

        DATA(lv_maktx) = gs_head-maktx.
        TRANSLATE lv_maktx TO UPPER CASE.
        CONDENSE lv_maktx.

        SELECT * INTO TABLE @DATA(lt_ztspppdt016)
          FROM ztspppdt016 WHERE werks = @gs_head-werks.

        LOOP AT lt_ztspppdt016 INTO DATA(ls_ztspppdt016).
          DATA(lv_material) = ls_ztspppdt016-material.
          TRANSLATE lv_material TO UPPER CASE.
          CONDENSE lv_material.

          IF lv_material = lv_maktx.
            gs_head-vornr = ls_ztspppdt016-vornr.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_PAI

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm   TYPE sy-ucomm.
  DATA : lv_nrp(30),
         lv_name(30),
         lv_equnr      TYPE equi-equnr,
         lv_netto1(15), lv_netto2(5),
         lv_vmeng      TYPE resb-vmeng,
         ls_002        LIKE LINE OF gt_002,
         ls_others     LIKE LINE OF gt_others.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&NEXT'.
      CASE sy-dynnr.
        WHEN '0103'.
          LEAVE TO SCREEN 0.

        WHEN '0900'.
          CLEAR gs_head-message.

          IF gs_head-operator IS NOT INITIAL.
            SPLIT gs_head-operator AT ';' INTO lv_nrp lv_name.
            IF lv_name IS NOT INITIAL.
              SPLIT lv_name AT space INTO gs_head-operator lv_name.
              CONDENSE gs_head-operator.
            ENDIF.
          ENDIF.

          IF gs_head-pengawas IS NOT INITIAL.
            SPLIT gs_head-pengawas AT ';' INTO lv_nrp lv_name.
            IF lv_name IS NOT INITIAL.
              SPLIT lv_name AT space INTO gs_head-pengawas lv_name.
              CONDENSE gs_head-operator.
            ENDIF.
          ENDIF.

          IF gs_head-equnr IS NOT INITIAL.
            PERFORM f_get_timbangan.
          ENDIF.

          IF gs_head-cmatnr IS NOT INITIAL.
*            CLEAR : gs_head-tara, gs_head-bruto, gs_head-netto, gs_head-erfme,
            CLEAR : gs_rawmat.

            IF gv_ibupro  = 'X'.
              CLEAR: lv_vmeng,lv_netto1,lv_netto2.
              SPLIT gs_head-cmatnr AT ';' INTO gs_head-qrfgmat gs_head-qraufnr
                                               gs_head-qrvornr gs_head-qrposnr
                                               gs_head-qrrmmat gs_head-qrnetto
                                               gs_head-qrpage  gs_head-qrtype
                                               gs_head-charg   gs_head-mblnr.

              CONDENSE gs_head-qrnetto.
              SPLIT gs_head-qrnetto AT space INTO lv_netto1 lv_netto2.
              TRANSLATE: lv_netto1  USING '. ',
                         lv_netto1  USING ',.'.
              CONDENSE lv_netto1.
              lv_vmeng = lv_netto1.

              gs_head-matnr = gs_head-qrrmmat.

              IF gs_head-qrtype IS INITIAL.
                SELECT SINGLE charg INTO gs_head-charg
                  FROM resb WHERE aufnr = gs_head-qraufnr
                              AND posnr = gs_head-qrposnr
                              AND wempf IN ('W','T')
                              AND splkz = '2'.
*                            AND vmeng = lv_vmeng.
              ELSE.
*                SELECT SINGLE charg INTO gs_head-charg
*                  FROM resb WHERE aufnr = gs_head-qraufnr
*                              AND posnr = gs_head-qrposnr
*                              AND wempf = space
*                              AND splkz = '2'.
**                            AND vmeng = lv_vmeng.
                PERFORM f_conversion_exit_alpha
                    USING     ''
                    CHANGING  gs_head-charg.
              ENDIF.
            ELSE.
              SPLIT gs_head-cmatnr AT ';' INTO gs_head-matnr gs_head-charg.
            ENDIF.

            CLEAR gs_head-cmatnr.
            SELECT SINGLE maktx
              FROM makt
              INTO gs_head-maktx
              WHERE matnr = gs_head-matnr
                AND spras = sy-langu.

            IF gv_others IS INITIAL.
              READ TABLE gt_002 INTO ls_002
                                WITH KEY matnr = gs_head-matnr.
              IF sy-subrc <> 0.
                PERFORM f_conversion_exit_alpha USING gs_head-equnr
                                                CHANGING lv_equnr.
                CONCATENATE 'Material' gs_head-matnr 'tidak bisa ditimbang di' lv_equnr
                INTO gs_head-message
                SEPARATED BY space.

              ELSE.
                gv_astad = sy-datum.
                gv_astau = sy-uzeit.
              ENDIF.
            ENDIF.
          ENDIF.

        WHEN '0901'.
          IF gs_head-select IS NOT INITIAL.
            READ TABLE gt_others INTO ls_others
                                 WITH KEY posnr = gs_head-select.
            IF sy-subrc = 0.
              gv_astad = sy-datum.
              gv_astau = sy-uzeit.

*              IF gs_head-maktx = 'Rework' OR
*                 gs_head-maktx = 'Sampling Fullpack'.
*                gv_rework = 'X'.
*                gs_head-othdesc = ls_others-maktx.
*              ELSE.
*                CLEAR gv_rework.
*                gs_head-matnr  = gs_head-aufnr.
*                gs_head-maktx  = ls_others-maktx.
*              ENDIF.
              IF gs_head-message IS INITIAL.
                IF gs_head-zdesc = 'GRANUL REWORK'.
                  IF gs_head-aufnr IS NOT INITIAL AND
                     gs_head-vornr IS NOT INITIAL.
                    LEAVE TO SCREEN 0.
                  ENDIF.
                ELSE.
                  LEAVE TO SCREEN 0.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
      ENDCASE.

    WHEN '&OTHERS'.
      CLEAR: c11,n11,n21.
      gv_others = 'X'.
      PERFORM f_get_material_others.
      CALL SCREEN 901.

    WHEN '&WEIGHT'.
      PERFORM f_get_weight USING 'X'.

    WHEN '&PRINT'.
      PERFORM f_cek_minmax_timbang(ztsppp_e001)
                                   USING    gs_head-werks
                                            gs_head-equnr
                                            gv_nmein
                                            gv_brutos
                                   CHANGING gs_head-message
                                            gv_minmax.
      IF gv_minmax IS INITIAL.
        PERFORM f_print_form.
      ENDIF.

    WHEN '&PGUP'.
      PERFORM f_display_data USING '-'.

    WHEN '&PGDN'.
      PERFORM f_display_data USING '+'.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

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
*&      Form  F_MODIFY_SCREEN2
*&---------------------------------------------------------------------*
FORM f_modify_screen2 USING    fu_name fu_active fu_input fu_invisible
                               fu_length.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-name = fu_name.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-name = fu_name.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-name = fu_name.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-name = fu_name.
        screen-length  = fu_length.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN2

*&---------------------------------------------------------------------*
*&      Form  F_CURSOR_POSITION
*&---------------------------------------------------------------------*
FORM f_cursor_position  USING    fu_field fu_pos.
  SET CURSOR FIELD fu_field LINE fu_pos.
ENDFORM.                    " F_CURSOR_POSITION

*&---------------------------------------------------------------------*
*&      Form  F_GET_WEIGHT
*&---------------------------------------------------------------------*
FORM f_get_weight USING fu_weight.
  DATA : status   TYPE extcmdexex-status,
         exitcode	TYPE extcmdexex-exitcode.

  DATA : iserveroutput    TYPE STANDARD TABLE OF btcxpm,
         ls_iserveroutput LIKE LINE OF iserveroutput,
         lt_char          TYPE STANDARD TABLE OF string.

  DATA : lv_char     TYPE zchar1500,
         lv_netto    TYPE resb-bdmng,
         commandname TYPE sxpgcolist-name,
         add_param   TYPE sxpgcolist-parameters.

  DATA : lt_resb   TYPE TABLE OF resb WITH HEADER LINE.

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
          sy-uname = 'PPIFA' OR sy-uname = 'PPMRA'.
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

  IF gv_ibupro = 'X'.
    CLEAR: gv_tara,gv_taras,gs_head-tara.
    CLEAR: gv_netto,gv_nettos,gs_head-netto.
    CLEAR: lv_netto,gv_netto,gs_head-erfme.
    READ TABLE lt_char INTO gv_brutos INDEX 1.
    READ TABLE lt_char INTO gs_head-erfme INDEX 4.
    TRANSLATE gs_head-erfme TO UPPER CASE.
    WRITE gv_brutos TO gs_head-bruto UNIT gs_head-erfme.
    CONDENSE gs_head-bruto NO-GAPS.
    gv_nmein = gs_head-erfme.

    gv_netto  = gv_bruto - gv_tara.
    gv_nettos = gv_brutos - gv_taras.
    WRITE gv_taras  TO gs_head-tara  UNIT gs_head-erfme RIGHT-JUSTIFIED.
    WRITE gv_nettos TO gs_head-netto UNIT gs_head-erfme.
    CONDENSE: gs_head-netto.

    IF gs_head-qrtype IS INITIAL.
      SELECT rsnum rspos rsart matnr werks lgort charg erfmg erfme
        INTO CORRESPONDING FIELDS OF TABLE lt_resb
        FROM resb WHERE aufnr = gs_head-qraufnr
                    AND posnr = gs_head-qrposnr
                    AND wempf IN ('W', 'T')
                    AND splkz = '2'.
    ELSE.
      SELECT rsnum rspos rsart matnr werks lgort charg erfmg erfme
        INTO CORRESPONDING FIELDS OF TABLE lt_resb
        FROM resb WHERE aufnr = gs_head-qraufnr
                    AND posnr = gs_head-qrposnr
                    AND matnr = gs_head-qrrmmat
                    AND charg = gs_head-charg
                    AND wempf = space
                    AND splkz = '2'.
    ENDIF.

    CLEAR: gs_rawmat,gt_rawmat.
    LOOP AT lt_resb.
      gs_rawmat-charg = lt_resb-charg.
      IF gs_head-qrtype IS INITIAL.
        gs_rawmat-erfmg = lt_resb-erfmg.
      ELSE.
        gs_rawmat-erfmg = gv_brutos.
      ENDIF.
      gs_rawmat-erfme = lt_resb-erfme.
      COLLECT gs_rawmat INTO gt_rawmat.
      CLEAR gs_rawmat.
    ENDLOOP.

  ELSE.
    IF gs_head-tara IS INITIAL.
      CLEAR: gv_tara,gs_head-erfme.
      READ TABLE lt_char INTO gv_tara INDEX 1.
*    READ TABLE lt_char INTO gs_rawmat-erfme INDEX 4.
      READ TABLE lt_char INTO gs_head-erfme INDEX 4.
      TRANSLATE gs_head-erfme TO UPPER CASE.
*    WRITE gv_tara TO gs_rawmat-tara UNIT gs_rawmat-erfme.
      WRITE gv_tara TO gs_head-tara UNIT gs_head-erfme.
      CONDENSE gs_head-tara NO-GAPS.

      ADD gv_tara TO gv_taras.

    ELSE.
      CLEAR: lv_netto,gv_netto,gs_head-erfme.
      READ TABLE lt_char INTO gv_netto INDEX 1.
      READ TABLE lt_char INTO gs_head-erfme INDEX 4.
      TRANSLATE gs_head-erfme TO UPPER CASE.
      gv_nmein = gs_head-erfme.
*    WRITE gv_netto TO gs_rawmat-netto UNIT gs_rawmat-erfme.
*    WRITE gv_netto TO gs_head-netto UNIT gs_head-erfme.
*    gv_bruto = gv_netto + gv_tara.
*    WRITE gv_bruto TO gs_rawmat-bruto UNIT gs_rawmat-erfme.
*    WRITE gv_bruto TO gs_rawmat-bruto UNIT gs_head-erfme.
*    CONDENSE gs_rawmat-netto NO-GAPS.
*    CONDENSE gs_rawmat-bruto NO-GAPS.
*    APPEND gs_rawmat TO gt_rawmat.

      lv_netto  = gv_netto - gv_nettos.
      gv_nettos = gv_nettos + lv_netto.
      gv_brutos = gv_nettos + gv_taras.
      WRITE gv_nettos TO gs_head-netto UNIT gs_head-erfme.
      WRITE gv_brutos TO gs_head-bruto UNIT gs_head-erfme.
      CONDENSE gs_head-netto NO-GAPS.
      CONDENSE gs_head-bruto NO-GAPS.

      CLEAR gs_rawmat.
      gs_rawmat-charg = gs_head-charg.
      gs_rawmat-erfmg = lv_netto.
      gs_rawmat-erfme = gs_head-erfme.
*    APPEND gs_rawmat TO gt_rawmat.
      COLLECT gs_rawmat INTO gt_rawmat.
      CLEAR gs_rawmat.
    ENDIF.
  ENDIF.

  IF gv_minmax IS NOT INITIAL AND
     gs_head-message IS NOT INITIAL.
    CLEAR gs_head-message.
  ENDIF.
ENDFORM.                    " F_GET_WEIGHT

*&---------------------------------------------------------------------*
*&      Form  F_GET_TIMBANGAN
*&---------------------------------------------------------------------*
FORM f_get_timbangan .
  PERFORM f_conversion_exit_alpha USING ''
                                  CHANGING gs_head-equnr.
  PERFORM f_get_equipment.
ENDFORM.                    " F_GET_TIMBANGAN

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
    WHERE equnr = gs_head-equnr.
  IF sy-subrc = 0.
    CALL FUNCTION 'ALM_ME_EQUIPMENT_GETDETAIL'
      EXPORTING
        i_equipment    = gs_head-equnr
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
      PERFORM f_conversion_exit_alpha USING gs_head-equnr
                                      CHANGING lv_equnr.
      CONCATENATE 'Timbangan belum terdaftar' lv_equnr
      INTO gs_head-message
      SEPARATED BY space.
      CLEAR gs_head-equnr.
    ELSE.
      IF gs_head-werks <> e_equi_header-swerk.
        CONCATENATE 'Timbangan bukan untuk Plant' gs_head-werks
        INTO gs_head-message
        SEPARATED BY space.
        CLEAR gs_head-equnr.
      ELSE.
        gs_head-shtxt   = e_equi_header-shtxt.
        gs_head-gstrp   = sy-datum.
        SELECT SINGLE print_dest
          FROM adr10
          INTO gv_print_dest
          WHERE addrnumber = e_equi_header-adrnr.

        SELECT SINGLE remark
          FROM adrt
          INTO gv_remark
          WHERE addrnumber = e_equi_header-adrnr
            AND comm_type  = 'URI'.

*{   REPLACE        P01K910720                                        1
*\        SELECT SINGLE uri_addr
*\          FROM adr12
*\          INTO gv_uri_addr
*\          WHERE addrnumber = e_equi_header-adrnr.
        ""Start SOH: Shell Remediation Adjustment 20240319 KRS
        DATA lv_uri_length TYPE adr12-uri_length.
        CLEAR: lv_uri_length, gv_uri_addr.
        SELECT SINGLE uri_length uri_addr
          FROM adr12
          INTO (lv_uri_length, gv_uri_addr)
          WHERE addrnumber = e_equi_header-adrnr.
        ""End SOH: Shell Remediation Adjustment 20240319 KRS
*}   REPLACE

        gv_eqfnr  = e_equi_header-eqfnr.
      ENDIF.
    ENDIF.
  ELSE.
    PERFORM f_conversion_exit_alpha USING gs_head-equnr
                                    CHANGING lv_equnr.
    CONCATENATE 'Timbangan belum terdaftar' lv_equnr
    INTO gs_head-message
    SEPARATED BY space.
    CLEAR gs_head-equnr.
  ENDIF.
ENDFORM.                    " F_GET_EQUIPMENT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form .
  DATA : lv_formname TYPE tdsfname,
         lv_funcname TYPE tdsfname,
         ctrl_param  LIKE ssfctrlop,
         output_opt  TYPE ssfcompop,
         ls_rawmat   TYPE ztspppst004,
         default     TYPE bapidefaul,
         return      TYPE STANDARD TABLE OF bapiret2,
         lt_rawmat   TYPE STANDARD TABLE OF ztspppst004,
         lv_ldest    TYPE t329d-ldest,
         lt_hazcom   TYPE TABLE OF ztspmdhazcom WITH HEADER LINE,
         h(10), f(10), r(10),
         lv_hazcom   TYPE char30,
         lv_matnr    TYPE ztspmdhazcom-matnr.

  IF gv_others = 'X'.
    IF gv_rework = 'X' OR gv_ibupro = 'X'.
      lv_matnr = gs_head-matnr.
    ELSE.
      lv_matnr = gs_head-maktx.
      TRANSLATE lv_matnr TO UPPER CASE.
    ENDIF.
  ELSE.
    lv_matnr = gs_head-matnr.
  ENDIF.

  CLEAR: lt_hazcom,lv_hazcom,h,f,r.
  SELECT SINGLE * INTO CORRESPONDING FIELDS OF lt_hazcom
    FROM ztspmdhazcom WHERE matnr = lv_matnr
                        AND werks = gs_head-werks.
  IF sy-subrc = 0.
    CONCATENATE 'H =' lt_hazcom-health INTO h SEPARATED BY space.
    CONCATENATE 'F =' lt_hazcom-fire   INTO f SEPARATED BY space.
    CONCATENATE 'R =' lt_hazcom-reactivity INTO r SEPARATED BY space.
    CONCATENATE h f r  INTO lv_hazcom SEPARATED BY ' ; '.
    gs_head-hazcom = lv_hazcom.
  ENDIF.

  IF gs_head-aufnr IS NOT INITIAL AND
     gv_rework IS INITIAL AND
     gv_ibupro IS INITIAL.
    CLEAR gs_head-matnr.
  ENDIF.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      defaults = default
    TABLES
      return   = return.

  IF gv_print_dest IS NOT INITIAL.
    lv_ldest = gv_print_dest.
  ELSE.
    lv_ldest = default-spld.
  ENDIF.

*  IF gs_head-maktx(6) = 'Granul' AND
*     gs_rwork IS NOT INITIAL.
  IF gv_others = 'X'.
    IF gv_rework = 'X' OR gv_ibupro = 'X'.
      lv_formname = 'ZTSPPPF007N'.
    ELSE.
      lv_formname = 'ZTSPPPF007'.
    ENDIF.
  ELSE.
    lv_formname = 'ZTSPPPF005'.
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

*  LOOP AT gt_rawmat INTO ls_rawmat.
*    AT FIRST.
*      ctrl_param-no_close = 'X'.
*    ENDAT.

*    AT LAST.
  ctrl_param-no_close = space.
*    ENDAT.

  ctrl_param-no_dialog  = 'X'.

  output_opt-tdnewid    = 'X'.
  output_opt-tdimmed    = 'X'.
  output_opt-tddelete   = ''.
  output_opt-tddest     = lv_ldest.

  CASE gs_head-werks.
    WHEN '0101'.
      gs_head-company  = 'TSP - Cikarang Plant 1'.
    WHEN '0102'.
      gs_head-company  = 'TSP - Cikarang Plant 2'.
  ENDCASE.

  IF gv_others = 'X'.
    gs_head-nmein = gs_head-tmein = gs_head-bmein = gs_head-erfme.
    gs_head-datum = gv_astad.
    gs_head-uzeit = gv_astau.

*    IF gs_head-maktx(6) = 'Granul' AND
*       gs_rwork IS NOT INITIAL.
    IF gv_others = 'X'.
      LOOP AT gt_rawmat INTO gs_rawmat.
        IF gs_head-qrtype = 'F'.
          gs_rawmat-erfmg = gs_head-netto.
        ENDIF.
        WRITE: gs_rawmat-erfmg TO gs_rawmat-netto UNIT gs_rawmat-erfme,
               gs_rawmat-erfme TO gs_rawmat-nmein.
        CONDENSE: gs_rawmat-netto.
        IF gv_ibupro  = 'X'.
          CLEAR: gs_rawmat-netto, gs_rawmat-nmein.
        ENDIF.
        MODIFY gt_rawmat FROM gs_rawmat
          TRANSPORTING erfmg netto nmein.
      ENDLOOP.
    ENDIF.

    IF gs_head-maktx(6) = 'Granul' OR
       ( gv_others = 'X' AND gv_rework  = 'X' ) OR
       ( gv_others = 'X' AND gv_ibupro  = 'X' ).
      lt_rawmat[] = gt_rawmat[].
    ENDIF.

    IF gs_head-zdesc = 'GRANUL REWORK'.
      gs_head-qrcode = |{ gs_head-aufnr };{ gs_head-vornr };{ gs_head-datum };{ gs_head-uzeit };G|.
    ENDIF.

    CALL FUNCTION lv_funcname
      EXPORTING
        control_parameters = ctrl_param
        output_options     = output_opt
        user_settings      = space
        gs_weight          = gs_head
      TABLES
        gt_batch           = lt_rawmat
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

*    ctrl_param-no_open = 'X'.
*  ENDLOOP.

  ELSE.
    gs_head-title = 'MIS'.

    CALL FUNCTION lv_funcname
      EXPORTING
        control_parameters = ctrl_param
        output_options     = output_opt
        user_settings      = space
        gs_head            = gs_head
      TABLES
        gt_rawmat          = gt_rawmat
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

*    ctrl_param-no_open = 'X'.
*  ENDLOOP.
  ENDIF.

  PERFORM f_write_history.

  CLEAR : gs_head-matnr, gs_head-maktx, gs_head-message, gt_rawmat[],
          gs_head-aufnr,gs_head-select,gs_rawmat,gv_others,gs_rwork,gv_nmein,
          gs_head-tara,gs_head-bruto,gs_head-netto,gs_head-charg,gs_head-fcharg,
          gv_tara,gv_bruto,gv_netto,gv_taras,gv_brutos,gv_nettos,gv_others,
          gv_minmax,gv_rework,gv_ibupro.

ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_OTHERS
*&---------------------------------------------------------------------*
FORM f_get_material_others .
  DATA : lt_lines  TYPE STANDARD TABLE OF tline,
         ls_lines  LIKE LINE OF lt_lines,
         lv_posnr  TYPE resb-rspos,
         lv_name   LIKE thead-tdname,
         ls_others LIKE LINE OF gt_others.

  CASE gs_head-werks.
    WHEN '0101'.
      lv_name = 'ZTSPPPE009'.
    WHEN '0102'.
      lv_name = 'ZTSPPPE009A'.
  ENDCASE.

  CLEAR : gt_others[].

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ST'
      language                = sy-langu
      name                    = lv_name     "'ZTSPPPE009'
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
*      IF gs_head-werks = '0102'.
*        IF ls_lines-tdline = 'Rework' OR
*           ls_lines-tdline = 'Sampling Fullpack'.
*        ELSE.
*          CONTINUE.
*        ENDIF.
*      ENDIF.
      ADD 1 TO lv_posnr.
      ls_others-posnr   = lv_posnr.
      ls_others-maktx   = ls_lines-tdline.
      APPEND ls_others TO gt_others.
      CLEAR ls_others.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_MATERIAL_OTHERS

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_HISTORY
*&---------------------------------------------------------------------*
FORM f_write_history .
  DATA: lt_ztspppdt007d TYPE STANDARD TABLE OF ztspppdt007d,
        ls_ztspppdt007  TYPE ztspppdt007,
        ls_ztspppdt007d TYPE ztspppdt007d,
        lv_posnr        TYPE zposnr.

  " Collect ztspppdt007
  REPLACE ALL OCCURRENCES OF '.' IN gs_head-bruto WITH space.
  REPLACE ALL OCCURRENCES OF ',' IN gs_head-bruto WITH '.'.
  REPLACE ALL OCCURRENCES OF '.' IN gs_head-tara WITH space.
  REPLACE ALL OCCURRENCES OF ',' IN gs_head-tara WITH '.'.
  REPLACE ALL OCCURRENCES OF '.' IN gs_head-netto WITH space.
  REPLACE ALL OCCURRENCES OF ',' IN gs_head-netto WITH '.'.
  CONDENSE: gs_head-bruto,gs_head-tara,gs_head-netto.

  ls_ztspppdt007-werks    = gs_head-werks.
  ls_ztspppdt007-afind    = sy-datum.
  ls_ztspppdt007-afinu    = sy-uzeit.
*  ls_ztspppdt007-matnr    = gs_head-matnr.
  ls_ztspppdt007-maktx    = gs_head-maktx.
  ls_ztspppdt007-charg    = gs_head-charg.
  ls_ztspppdt007-wbooth   = gs_head-wb.
  ls_ztspppdt007-equnr    = gs_head-equnr.
  ls_ztspppdt007-shtxt    = gs_head-shtxt.
  ls_ztspppdt007-astad    = gv_astad.
  ls_ztspppdt007-astau    = gv_astau.
  ls_ztspppdt007-bruto    = gs_head-bruto.
  ls_ztspppdt007-tara     = gs_head-tara.
  ls_ztspppdt007-netto    = gs_head-netto.
  ls_ztspppdt007-meins    = gs_head-erfme.
*  ls_ztspppdt007-LGORT
  ls_ztspppdt007-operator = gs_head-operator.
  ls_ztspppdt007-pengawas = gs_head-pengawas.
  ls_ztspppdt007-wgttxt   = gs_head-othdesc.
  ls_ztspppdt007-vornr    = gs_head-vornr.

  IF gs_head-aufnr IS INITIAL.
    ls_ztspppdt007-matnr = gs_head-matnr.
    CLEAR ls_ztspppdt007-aufnr.
  ELSE.
    ls_ztspppdt007-aufnr = gs_head-aufnr.
    CLEAR ls_ztspppdt007-matnr.
  ENDIF.

  IF gs_head-maktx(6) = 'Granul'.
    ls_ztspppdt007-phseq = 'W1'.
  ENDIF.

  IF gv_rework = 'X' OR gv_ibupro = 'X'.
    ls_ztspppdt007-matnr  = gs_head-matnr.
  ENDIF.

  " Collect ztspppdt007d
  LOOP AT gt_rawmat INTO gs_rawmat.
    ADD 1 TO lv_posnr.
    ls_ztspppdt007d-werks = ls_ztspppdt007-werks.
    ls_ztspppdt007d-afind = ls_ztspppdt007-afind.
    ls_ztspppdt007d-afinu = ls_ztspppdt007-afinu.
    ls_ztspppdt007d-posnr = lv_posnr.
    ls_ztspppdt007d-charg = gs_rawmat-charg.
    ls_ztspppdt007d-netto = gs_rawmat-erfmg.
    ls_ztspppdt007d-meins = gs_rawmat-erfme.
    APPEND ls_ztspppdt007d TO lt_ztspppdt007d.
  ENDLOOP.

  MODIFY ztspppdt007 FROM ls_ztspppdt007.
  MODIFY ztspppdt007d FROM TABLE lt_ztspppdt007d.
ENDFORM.                    " F_WRITE_HISTORY

*&---------------------------------------------------------------------*
*&      Form  F_CEK_GRANUL
*&---------------------------------------------------------------------*
FORM f_cek_granul .
  DATA: lt_ztspppdt008 TYPE STANDARD TABLE OF ztspppdt008,
        ls_ztspppdt008 LIKE LINE OF lt_ztspppdt008.

  SELECT * INTO TABLE lt_ztspppdt008
    FROM ztspppdt008 WHERE werks = gs_head-werks.

  LOOP AT lt_ztspppdt008 INTO ls_ztspppdt008.
    IF gs_head-maktx(6) = 'Granul' AND
       gs_head-maktx CS ls_ztspppdt008-rwork.
      gs_rwork = ls_ztspppdt008.
      EXIT.
    ELSE.
      CLEAR gs_rwork.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CEK_GRANUL

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_AUFNR
*&---------------------------------------------------------------------*
FORM f_validate_aufnr .
  SELECT SINGLE matnr charg
    INTO (gs_head-plnbez,gs_head-fcharg)
    FROM afpo WHERE aufnr = gs_head-aufnr
                AND pwerk = gs_head-werks.

  IF sy-subrc = 0.
    IF gs_head-message = 'Process Order Salah'.
      CLEAR gs_head-message.
    ENDIF.
  ELSE.
    gs_head-message = 'Process Order Salah'.
  ENDIF.
ENDFORM.                    " F_VALIDATE_AUFNR

*&---------------------------------------------------------------------*
*&      Form  F_GET_TARA
*&---------------------------------------------------------------------*
FORM f_get_tara .
  DATA: lv_netto      TYPE resb-bdmng,
        lv_tara       TYPE resb-bdmng,
        lv_bruto      TYPE resb-bdmng,
        lv_char18(18),
        lt_resb       TYPE TABLE OF resb WITH HEADER LINE.

  IF gs_head-tara IS NOT INITIAL AND gv_ibupro = 'X'.
    TRANSLATE: gs_head-bruto  USING '. ',
               gs_head-bruto  USING ',.',
               gs_head-tara   USING '. ',
               gs_head-tara   USING ',.'.
    CONDENSE: gs_head-bruto, gs_head-tara.

    lv_bruto = gs_head-bruto.
    lv_tara  = gs_head-tara.
    lv_netto = lv_bruto - lv_tara.

    WRITE lv_bruto TO gs_head-bruto UNIT gs_head-erfme.
    WRITE lv_tara  TO lv_char18     UNIT gs_head-erfme.
*    WRITE lv_tara  TO gs_head-tara  UNIT gs_head-erfme.   "RIGHT-JUSTIFIED.
    gs_head-tara = lv_char18.
    WRITE lv_netto TO gs_head-netto UNIT gs_head-erfme.
    CONDENSE: gs_head-bruto, gs_head-netto.

*    SELECT rsnum rspos rsart matnr werks lgort charg erfmg erfme
*      INTO CORRESPONDING FIELDS OF TABLE lt_resb
*      FROM resb WHERE aufnr = gs_head-qraufnr
*                  AND posnr = gs_head-qrposnr
*                  AND wempf = 'W'
*                  AND splkz = '2'.
*
*    CLEAR: gs_rawmat,gt_rawmat.
*    LOOP AT lt_resb.
*      gs_rawmat-charg = lt_resb-charg.
*      gs_rawmat-erfmg = lt_resb-erfmg.
*      gs_rawmat-erfme = lt_resb-erfme.
*      COLLECT gs_rawmat INTO gt_rawmat.
*      CLEAR gs_rawmat.
*    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_TARA

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM f_display_data  USING    fu_sign.
  DATA : lv_lines   TYPE i.

  DESCRIBE TABLE gt_others LINES lv_lines.
  CASE fu_sign.
    WHEN '+'.
      IF  n11 IS INITIAL.
        n11 = 1.
      ENDIF.
      c11 = n11 = n11 + 20.
      IF n11 > lv_lines.
        c11 = n11 = lv_lines.
      ENDIF.

    WHEN '-'.
      c11 = n11 = n11 - 20.
      IF n11 < 0.
        c11 = n11 = 20.
      ENDIF.
*      c11  = c11 - 20.
  ENDCASE.
ENDFORM.                    " F_DISPLAY_DATA
