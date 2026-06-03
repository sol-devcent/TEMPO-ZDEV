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
  IF gs_head-matnr IS INITIAL.
    IF gv_others IS INITIAL.
      PERFORM f_modify_screen USING : 'RAW' '0' '' '' ''.
      PERFORM f_modify_screen USING : 'TAR' '0' '' '' ''.
      PERFORM f_modify_screen USING : 'WEI' '' '0' '' ''.
      PERFORM f_modify_screen USING : 'PRT' '' '0' '' ''.
    ENDIF.
  ELSE.
    IF gs_head-lgort IS INITIAL.
      gs_head-message = 'Storage Loc. Harus diisi'.
      PERFORM f_cursor_position USING 'GS_HEAD-LGORT' ''.
    ENDIF.
    IF gs_head-message IS NOT INITIAL.
      IF gv_minmax IS INITIAL.
        PERFORM f_modify_screen USING : 'RAW' '0' '' '' ''.
        PERFORM f_modify_screen USING : 'TAR' '0' '' '' ''.
        PERFORM f_modify_screen USING : 'WEI' '' '0' '' ''.
        PERFORM f_modify_screen USING : 'PRT' '' '0' '' ''.
      ELSE.
*        PERFORM f_modify_screen USING : 'RAW' '0' '' '' ''.
*        PERFORM f_modify_screen USING : 'TAR' '0' '' '' ''.
*        PERFORM f_modify_screen USING : 'WEI' '' '0' '' ''.
        PERFORM f_modify_screen USING : 'PRT' '' '0' '' ''.
      ENDIF.
    ENDIF.
  ENDIF.

  IF gs_head-gstrp IS INITIAL.
    PERFORM f_modify_screen USING : 'TIM' '0' '' '' ''.
  ENDIF.

  IF gs_rawmat-tara IS INITIAL.
    PERFORM f_modify_screen USING : 'PRT' '' '0' '' ''.
  ENDIF.

*  IF gs_head-werks = '0101'.
*    IF gs_head-equnr IS NOT INITIAL.
*      PERFORM f_modify_screen USING : 'OTH' '1' '' '' ''.
*    ELSE.
*      PERFORM f_modify_screen USING : 'OTH' '0' '' '' ''.
*    ENDIF.
*  ELSE.
*    PERFORM f_modify_screen USING : 'OTH' '0' '' '' ''.
*  ENDIF.
  PERFORM f_modify_screen USING : 'OTH' '0' '' '' ''.

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
  ELSEIF gs_head-lgort IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-LGORT' ''.
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

  IF gs_head-lgort IS NOT INITIAL.
    IF er_lgort IS INITIAL.
      PERFORM f_modify_screen USING : '006' '' '0' '' ''.
    ENDIF.
  ENDIF.

  IF gs_rawmat-bruto IS INITIAL.
    PERFORM f_modify_screen USING : 'TAR' '1' '0' '' ''.
  ELSE.
    PERFORM f_modify_screen USING : 'TAR' '1' '1' '' ''.
  ENDIF.

  IF gs_head-matnr IS INITIAL.
    PERFORM f_modify_screen USING : 'STK' '0' '' '' ''.
  ENDIF.

  IF gv_ucomm = '&WEIGHT'.
    SET CURSOR FIELD 'GS_RAWMAT-TARA'.
    CLEAR gv_ucomm.
  ENDIF.

  CASE gv_subrc.
    WHEN 1.
      gs_head-message = 'Pack belum dimaintain'.
    WHEN 2.
      gs_head-message = 'Batch tidak ada'.
    WHEN OTHERS.
  ENDCASE.

  CASE sy-dynnr.
    WHEN '0901'.
      DESCRIBE TABLE gt_others LINES n2.
      gs_head-from  = 1.
      CONDENSE gs_head-from NO-GAPS.
      gs_head-to    = n2.
      CONDENSE gs_head-to NO-GAPS.
      CLEAR gs_head-select.
      PERFORM f_cursor_position USING 'GS_HEAD-SELECT' ''.
  ENDCASE.
ENDFORM.                    " F_PBO

*&---------------------------------------------------------------------*
*&      Form  F_PAI
*&---------------------------------------------------------------------*
FORM f_pai .
  IF gs_head-cmatnr IS NOT INITIAL.
    SPLIT gs_head-cmatnr AT ';' INTO gs_head-matnr gs_head-charg.
    PERFORM f_get_open_stock.
  ENDIF.
  IF gs_rawmat-tara IS NOT INITIAL.
    PERFORM f_recalc_netto.
    CLEAR gt_rawmat[].
*    CONDENSE: gs_rawmat-netto,
*              gs_rawmat-tara,
*              gs_rawmat-bruto.
    APPEND gs_rawmat TO gt_rawmat.
  ENDIF.
ENDFORM.                    " F_PAI

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm   TYPE sy-ucomm.
  DATA : lv_nrp(30),
         lv_name(30),
         lv_equnr   TYPE equi-equnr,
         lv_lgort   TYPE t001l-lgort,
         ls_002     LIKE LINE OF gt_002,
         ls_others  LIKE LINE OF gt_others.

  lv_ucomm = ok_code.
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

          IF gs_head-lgort IS NOT INITIAL.
            IF gs_head-lgort(1) = '2'.
              CLEAR er_lgort.
              SELECT SINGLE lgort INTO lv_lgort
                FROM t001l WHERE werks = gs_head-werks
                             AND lgort = gs_head-lgort.
              IF sy-subrc = 0.
                CLEAR er_lgort.
              ELSE.
                er_lgort = 'X'.
                gs_head-message = 'Storage Location does not exist'.
              ENDIF.
            ELSE.
              er_lgort = 'X'.
              gs_head-message = 'Storage Location must be 2*'.
            ENDIF.
          ENDIF.

          IF gs_head-cmatnr IS NOT INITIAL.
            CLEAR : gs_rawmat-tara, gs_rawmat-bruto, gs_rawmat-netto, gs_rawmat-erfme,
                    gt_rawmat[].
            SPLIT gs_head-cmatnr AT ';' INTO gs_head-matnr gs_rawmat-charg.
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
              gs_head-maktx  = ls_others-maktx.
              LEAVE TO SCREEN 0.
            ENDIF.
          ENDIF.
      ENDCASE.

    WHEN '&OTHERS'.
      gv_others = 'X'.
      PERFORM f_get_material_others.
      CALL SCREEN 901.

    WHEN '&WEIGHT'.
      gv_ucomm = lv_ucomm.
      PERFORM f_get_weight USING 'X'.

    WHEN '&PRINT'.
      PERFORM f_cek_minmax_timbang(ztsppp_e001)
                                   USING    gs_head-werks
                                            gs_head-equnr
                                            gv_nmein
                                            gv_bruto
                                   CHANGING gs_head-message
                                            gv_minmax.
      IF gv_minmax IS INITIAL.
        PERFORM f_print_form.
      ELSE.
      ENDIF.
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
*&      Form  F_CURSOR_POSITION
*&---------------------------------------------------------------------*
FORM f_cursor_position  USING    fu_field fu_pos.
  SET CURSOR FIELD fu_field LINE fu_pos.
ENDFORM.                    " F_CURSOR_POSITION

*&---------------------------------------------------------------------*
*&      Form  F_GET_WEIGHT
*&---------------------------------------------------------------------*
FORM f_get_weight USING fu_weight.
  DATA : status           TYPE extcmdexex-status,
         exitcode	        TYPE extcmdexex-exitcode.

  DATA : iserveroutput    TYPE STANDARD TABLE OF btcxpm,
         ls_iserveroutput LIKE LINE OF iserveroutput,
         lt_char          TYPE STANDARD TABLE OF string.

  DATA : lv_char          TYPE zchar1500,
         commandname      TYPE sxpgcolist-name,
         add_param        TYPE sxpgcolist-parameters.

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

  CLEAR: gv_bruto,gv_tara,gv_netto,
         gs_rawmat-bruto,gs_rawmat-tara,gs_rawmat-netto.

  READ TABLE lt_char INTO gv_bruto INDEX 1.
  READ TABLE lt_char INTO gs_rawmat-erfme INDEX 4.
  TRANSLATE gs_rawmat-erfme TO UPPER CASE.
  WRITE gv_bruto TO gs_rawmat-bruto UNIT gs_rawmat-erfme.
  CONDENSE gs_rawmat-bruto. "NO-GAPS.
  gv_nmein = gs_rawmat-erfme.

  gv_netto = gv_bruto - gv_tara.
  WRITE gv_netto TO gs_rawmat-netto UNIT gs_rawmat-erfme.
  CONDENSE gs_rawmat-netto. "NO-GAPS.

*  IF gs_rawmat-tara IS INITIAL.
*    READ TABLE lt_char INTO gv_tara INDEX 1.
*    READ TABLE lt_char INTO gs_rawmat-erfme INDEX 4.
*    TRANSLATE gs_rawmat-erfme TO UPPER CASE.
*    WRITE gv_tara TO gs_rawmat-tara UNIT gs_rawmat-erfme.
*    CONDENSE gs_rawmat-tara NO-GAPS.
*  ELSE.
*    READ TABLE lt_char INTO gv_netto INDEX 1.
*    READ TABLE lt_char INTO gs_rawmat-erfme INDEX 4.
*    TRANSLATE gs_rawmat-erfme TO UPPER CASE.
*    WRITE gv_netto TO gs_rawmat-netto UNIT gs_rawmat-erfme.
*    gv_bruto = gv_netto + gv_tara.
*    WRITE gv_bruto TO gs_rawmat-bruto UNIT gs_rawmat-erfme.
*    CONDENSE gs_rawmat-netto NO-GAPS.
*    CONDENSE gs_rawmat-bruto NO-GAPS.
*    APPEND gs_rawmat TO gt_rawmat.
*  ENDIF.
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
  DATA : e_equi_header    TYPE alm_me_tob_header,
         return           TYPE STANDARD TABLE OF bapiret2.

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
  DATA : lv_formname         TYPE tdsfname,
         lv_funcname         TYPE tdsfname,
         ctrl_param          LIKE ssfctrlop,
         output_opt          TYPE ssfcompop,
         ls_rawmat           TYPE ztspppst004,
         default             TYPE bapidefaul,
         return              TYPE STANDARD TABLE OF bapiret2,
         lv_ldest            TYPE t329d-ldest,
         lt_hazcom           TYPE TABLE OF ztspmdhazcom WITH HEADER LINE,
         h(10), f(10), r(10),
         lv_hazcom           TYPE char30.

  gs_head-title = 'SISA STOK'.

  CASE gs_head-werks.
    WHEN '0101'.
      gs_head-company  = 'TSP - Cikarang Plant 1'.
    WHEN '0102'.
      gs_head-company  = 'TSP - Cikarang Plant 2'.
    WHEN OTHERS.
  ENDCASE.

  CLEAR: lt_hazcom,lv_hazcom,h,f,r.
  SELECT SINGLE * INTO CORRESPONDING FIELDS OF lt_hazcom
    FROM ztspmdhazcom WHERE matnr = gs_head-matnr
                        AND werks = gs_head-werks.
  IF sy-subrc = 0.
    CONCATENATE 'H =' lt_hazcom-health INTO h SEPARATED BY space.
    CONCATENATE 'F =' lt_hazcom-fire   INTO f SEPARATED BY space.
    CONCATENATE 'R =' lt_hazcom-reactivity INTO r SEPARATED BY space.
    CONCATENATE h f r  INTO lv_hazcom SEPARATED BY ' ; '.
    gs_head-hazcom = lv_hazcom.
  ENDIF.

  lv_formname = 'ZTSPPPF005'.

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

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  LOOP AT gt_rawmat INTO ls_rawmat.
    CONDENSE: ls_rawmat-netto,
              ls_rawmat-tara,
              ls_rawmat-bruto.
    MODIFY gt_rawmat FROM ls_rawmat TRANSPORTING netto tara bruto.
  ENDLOOP.

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

  PERFORM f_write_history.

  CLEAR : gs_head-matnr, gs_head-maktx, gs_head-message, gt_rawmat[],
          gs_head-select,gs_head-tara,gs_head-bruto,gs_head-netto,
          gv_tara,gv_bruto,gv_netto,gs_rawmat-tara.
ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_OTHERS
*&---------------------------------------------------------------------*
FORM f_get_material_others .
  DATA : lt_lines   TYPE STANDARD TABLE OF tline,
         ls_lines   LIKE LINE OF lt_lines,
         lv_posnr   TYPE resb-rspos,
         ls_others  LIKE LINE OF gt_others.

  CLEAR : gt_others[].

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ST'
      language                = sy-langu
      name                    = 'ZTSPPPE009'
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
      ls_others-posnr   = lv_posnr.
      ls_others-maktx   = ls_lines-tdline.
      APPEND ls_others TO gt_others.
      CLEAR ls_others.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_MATERIAL_OTHERS

*&---------------------------------------------------------------------*
*&      Form  F_GET_OPEN_STOCK
*&---------------------------------------------------------------------*
FORM f_get_open_stock .
  DATA: lt_resb   TYPE TABLE OF resb WITH HEADER LINE,
        lv_meins  TYPE meins,
        lv_erfmg  LIKE resb-erfmg,
        lv_mtart  TYPE mara-mtart.

  CLEAR: gs_head-meins,gs_head-clabs,gs_head-stock,gs_head-packq.
  CLEAR: gv_subrc.

  SELECT SINGLE meins mtart
    INTO (gs_head-meins,lv_mtart)
    FROM mara WHERE matnr = gs_head-matnr.

  SELECT SINGLE clabs INTO gs_head-clabs
    FROM mchb WHERE matnr = gs_head-matnr
                AND werks = gs_head-werks
                AND lgort = gs_head-lgort
                AND charg = gs_head-charg.

  SELECT rsnum rspos aufnr posnr matnr charg erfmg erfme
    INTO CORRESPONDING FIELDS OF TABLE lt_resb
    FROM resb WHERE matnr = gs_head-matnr
                AND charg = gs_head-charg
                AND lgort = gs_head-lgort
                AND splkz = '2'
                AND xloek = space
                AND kzear = space.

  LOOP AT lt_resb.
    IF lt_resb-erfme NE gs_head-meins.
      PERFORM f_uom_conversion USING lt_resb-erfmg
                                     lt_resb-erfme
                                     gs_head-meins
                               CHANGING lt_resb-erfmg.
    ENDIF.
    ADD lt_resb-erfmg TO lv_erfmg.
  ENDLOOP.

  SUBTRACT lv_erfmg FROM gs_head-clabs.

  IF lv_mtart = 'ZRM' OR lv_mtart = 'ZPM'.
    PERFORM f_get_sisa_stock USING gs_head-matnr
                                   gs_head-charg
                                   gs_head-werks
                             CHANGING gs_head-clabs
                                      gs_head-packq.
  ENDIF.

  IF gs_head-meins = 'ST'.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input  = gs_head-meins
      IMPORTING
        output = lv_meins.
  ELSE.
    lv_meins = gs_head-meins.
  ENDIF.

  WRITE gs_head-clabs TO gs_head-stock UNIT gs_head-meins.
  CONDENSE gs_head-stock.
*  CONCATENATE gs_head-stock gs_head-meins INTO gs_head-stock
  CONCATENATE gs_head-stock lv_meins INTO gs_head-stock
      SEPARATED BY space.
ENDFORM.                    " F_GET_OPEN_STOCK

*&---------------------------------------------------------------------*
*&      Form  F_UOM_CONVERSION
*&---------------------------------------------------------------------*
FORM f_uom_conversion  USING    fu_erfmg
                                fu_erfme
                                fu_meins
                       CHANGING fc_erfmg.
  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
    EXPORTING
      input                = fu_erfmg
      unit_in              = fu_erfme
      unit_out             = fu_meins
    IMPORTING
      output               = fc_erfmg
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
ENDFORM.                    " F_UOM_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_RECALC_NETTO
*&---------------------------------------------------------------------*
FORM f_recalc_netto .
  TRANSLATE: gs_rawmat-tara  USING '. ',
             gs_rawmat-tara  USING ',.'.

  gv_tara  = gs_rawmat-tara.
  gv_netto = gv_bruto - gv_tara.
  gs_rawmat-erfmg = gv_netto.
*  gs_rawmat-erfme = gs_head-meins.

  WRITE: gv_bruto TO gs_rawmat-bruto UNIT gs_head-meins RIGHT-JUSTIFIED,
         gv_tara  TO gs_rawmat-tara  UNIT gs_head-meins RIGHT-JUSTIFIED NO-SIGN,
         gv_netto TO gs_rawmat-netto UNIT gs_head-meins RIGHT-JUSTIFIED.
*  CONDENSE: gs_rawmat-bruto,gs_rawmat-tara NO-GAPS,gs_rawmat-netto.

  gs_head-bruto = gs_rawmat-bruto.
  gs_head-tara  = gs_rawmat-tara.
  gs_head-netto = gs_rawmat-netto.
  gs_head-erfme = gv_nmein.       "gs_head-meins.
  CONDENSE: gs_head-bruto,gs_head-tara,gs_head-netto.
ENDFORM.                    " F_RECALC_NETTO

*&---------------------------------------------------------------------*
*&      Form  F_GET_SISA_STOCK
*&---------------------------------------------------------------------*
FORM f_get_sisa_stock  USING    fu_matnr
                                fu_charg
                                fu_werks
                       CHANGING fc_clabs
                                fc_packq.
  DATA: cob     TYPE STANDARD TABLE OF clbatch,
        ls_cob  LIKE LINE OF cob.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      matnr              = fu_matnr
      charg              = fu_charg
      werks              = fu_werks
      get_classification = 'X'
*    IMPORTING
*      ymcha              = gs_mcha
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
      fc_packq = ls_cob-atwtb.
      fc_clabs = fc_clabs MOD fc_packq.
    ELSE.
      CLEAR fc_clabs.
      gv_subrc = 1.
    ENDIF.
  ELSE.
    CLEAR fc_clabs.
    gv_subrc = 2.
  ENDIF.
ENDFORM.                    " F_GET_SISA_STOCK

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_HISTORY
*&---------------------------------------------------------------------*
FORM f_write_history .
  DATA: lt_ztspppdt007d TYPE STANDARD TABLE OF ztspppdt007d,
        ls_ztspppdt007  TYPE ztspppdt007,
        ls_ztspppdt007d TYPE ztspppdt007d.

  REPLACE ALL OCCURRENCES OF '.' IN gs_head-bruto WITH space.
  REPLACE ALL OCCURRENCES OF ',' IN gs_head-bruto WITH '.'.
  REPLACE ALL OCCURRENCES OF '.' IN gs_head-tara WITH space.
  REPLACE ALL OCCURRENCES OF ',' IN gs_head-tara WITH '.'.
  REPLACE ALL OCCURRENCES OF '.' IN gs_head-netto WITH space.
  REPLACE ALL OCCURRENCES OF ',' IN gs_head-netto WITH '.'.
  REPLACE ALL OCCURRENCES OF '.' IN gs_rawmat-netto WITH space.
  REPLACE ALL OCCURRENCES OF ',' IN gs_rawmat-netto WITH '.'.
  CONDENSE: gs_head-bruto,gs_head-tara,gs_head-netto,gs_rawmat-netto.

  ls_ztspppdt007-werks    = gs_head-werks.
  ls_ztspppdt007-afind    = sy-datum.
  ls_ztspppdt007-afinu    = sy-uzeit.
  ls_ztspppdt007-matnr    = gs_head-matnr.
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
  ls_ztspppdt007-lgort    = gs_head-lgort.
  ls_ztspppdt007-operator = gs_head-operator.
  ls_ztspppdt007-pengawas = gs_head-pengawas.
  ls_ztspppdt007-wgttxt   = 'Timbang Sisa Stok'.

  ls_ztspppdt007d-werks = ls_ztspppdt007-werks.
  ls_ztspppdt007d-afind = ls_ztspppdt007-afind.
  ls_ztspppdt007d-afinu = ls_ztspppdt007-afinu.
  ls_ztspppdt007d-posnr = '000001'.
  ls_ztspppdt007d-charg = gs_rawmat-charg.
  ls_ztspppdt007d-netto = gs_rawmat-netto.
  ls_ztspppdt007d-meins = gs_rawmat-erfme.

  MODIFY ztspppdt007 FROM ls_ztspppdt007.
  MODIFY ztspppdt007d FROM ls_ztspppdt007d.
ENDFORM.                    " F_WRITE_HISTORY
