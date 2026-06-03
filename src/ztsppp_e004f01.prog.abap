*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E004F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  SET PF-STATUS 'PFSTATUS'.
  SET TITLEBAR 'TITLE'.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm   TYPE sy-ucomm.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&WEIGHT'.
      PERFORM f_get_weight.

    WHEN '&PRINT'.
      PERFORM f_print_form.

    WHEN OTHERS.
      CASE sy-dynnr.
        WHEN '0403'.
          LEAVE TO SCREEN 0.
        WHEN OTHERS.
          PERFORM f_get_timbangan.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_GET_TIMBANGAN
*&---------------------------------------------------------------------*
FORM f_get_timbangan .
  IF gv_equnr IS NOT INITIAL.
    CLEAR gv_message.
    PERFORM f_conversion_exit_alpha USING ''
                                    CHANGING gv_equnr.
    PERFORM f_get_equipment.
  ENDIF.
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

  CALL FUNCTION 'ALM_ME_EQUIPMENT_GETDETAIL'
    EXPORTING
      i_equipment    = gv_equnr
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
    PERFORM f_conversion_exit_alpha USING gv_equnr
                                    CHANGING lv_equnr.
    CONCATENATE 'Timbangan belum terdaftar' lv_equnr
    INTO gv_message
    SEPARATED BY space.
  ELSE.
    CASE e_equi_header-iwerk.
      WHEN '0101'.
        gs_label-company  = 'TSP - Cikarang Plant 1'.
      WHEN '0102'.
        gs_label-company  = 'TSP - Cikarang Plant 2'.
    ENDCASE.

    gs_label-eqktx   = e_equi_header-shtxt.
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
*\    SELECT SINGLE uri_addr
*\      FROM adr12
*\      INTO gv_uri_addr
*\      WHERE addrnumber = e_equi_header-adrnr.
    "Start SOH: Shell Remediation Adjustment 20240319 KRS
    DATA lv_uri_length TYPE adr12-uri_length.
    CLEAR: lv_uri_length, gv_uri_addr.
    SELECT SINGLE uri_length uri_addr
      FROM adr12
      INTO (lv_uri_length, gv_uri_addr)
      WHERE addrnumber = e_equi_header-adrnr.
    "End SOH: Shell Remediation Adjustment 20240319 KRS
*}   REPLACE

    gv_eqfnr    = e_equi_header-eqfnr.
  ENDIF.

  gs_label-equnr    = gv_equnr.
  CLEAR gv_equnr.
ENDFORM.                    " F_GET_EQUIPMENT

*&---------------------------------------------------------------------*
*&      Form  F_GET_WEIGHT
*&---------------------------------------------------------------------*
FORM f_get_weight .
  DATA : status           TYPE extcmdexex-status,
         exitcode	        TYPE extcmdexex-exitcode.

  DATA : iserveroutput    TYPE STANDARD TABLE OF btcxpm,
         ls_iserveroutput LIKE LINE OF iserveroutput,
         lt_char          TYPE STANDARD TABLE OF string,
         ls_char          LIKE LINE OF lt_char,
         lv_meins         TYPE mara-meins,
         lv_bdmng         TYPE resb-bdmng.

  DATA : lv_char          TYPE zchar1500,
         lv_enmng         TYPE resb-enmng,
         commandname      TYPE sxpgcolist-name,
         add_param        TYPE sxpgcolist-parameters.

  CLEAR gv_message.

  commandname  = gv_remark.
  CONCATENATE gv_uri_addr 'all' gv_eqfnr INTO add_param
  SEPARATED BY space.

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

      IF sy-uname = 'TDS_DEV01' OR sy-uname = 'PPIFA' OR sy-uname = 'PPMRA'.
        gv_char  = lv_char.
        CALL SCREEN 403 STARTING AT 10 10.
        lv_char  = gv_char.
      ENDIF.

      SPLIT lv_char AT '|' INTO TABLE lt_char.
    ENDLOOP.

    CLEAR : ls_char, lv_bdmng.
    READ TABLE lt_char INTO ls_char INDEX 1.
    IF sy-subrc = 0.
      lv_bdmng  = ls_char.
    ENDIF.

    CLEAR : ls_char, lv_meins.
    READ TABLE lt_char INTO ls_char INDEX 4.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = ls_char
      IMPORTING
        output         = lv_meins
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.

    IF gs_label-dat01 IS INITIAL.
      gs_label-kal01  = lv_bdmng.
      gs_label-mei01  = lv_meins.
      gs_label-dat01  = sy-datum.
      gs_label-tim01  = sy-uzeit.
    ELSEIF gs_label-dat02 IS INITIAL OR
           gs_label-kal02 IS INITIAL.
      gs_label-kal02  = lv_bdmng.
      gs_label-mei02  = lv_meins.
      gs_label-dat02  = sy-datum.
      gs_label-tim02  = sy-uzeit.
    ELSEIF gs_label-dat03 IS INITIAL OR
           gs_label-kal03 IS INITIAL.
      gs_label-kal03  = lv_bdmng.
      gs_label-mei03  = lv_meins.
      gs_label-dat03  = sy-datum.
      gs_label-tim03  = sy-uzeit.
    ELSEIF gs_label-dat04 IS INITIAL OR
           gs_label-kal04 IS INITIAL.
      gs_label-kal04  = lv_bdmng.
      gs_label-mei04  = lv_meins.
      gs_label-dat04  = sy-datum.
      gs_label-tim04  = sy-uzeit.
    ELSEIF gs_label-dat05 IS INITIAL OR
           gs_label-kal05 IS INITIAL.
      gs_label-kal05  = lv_bdmng.
      gs_label-mei05  = lv_meins.
      gs_label-dat05  = sy-datum.
      gs_label-tim05  = sy-uzeit.
    ELSEIF gs_label-dat06 IS INITIAL OR
           gs_label-kal06 IS INITIAL.
      gs_label-kal06  = lv_bdmng.
      gs_label-mei06  = lv_meins.
      gs_label-dat06  = sy-datum.
      gs_label-tim06  = sy-uzeit.
    ELSEIF gs_label-dat07 IS INITIAL OR
           gs_label-kal07 IS INITIAL.
      gs_label-kal07  = lv_bdmng.
      gs_label-mei07  = lv_meins.
      gs_label-dat07  = sy-datum.
      gs_label-tim07  = sy-uzeit.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_WEIGHT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form .
  DATA : lv_formname         TYPE tdsfname,
         lv_funcname         TYPE tdsfname,
         ctrl_param          LIKE ssfctrlop,
         output_opt          TYPE ssfcompop,
         ls_label            TYPE ztspppst004,
         default             TYPE bapidefaul,
         return              TYPE STANDARD TABLE OF bapiret2,
         lv_ldest            TYPE t329d-ldest,
         lv_posnr            TYPE resb-posnr.

  DATA : parameter      TYPE STANDARD TABLE OF bapiparam,
         ls_parameter   LIKE LINE OF parameter.

  lv_formname = 'ZTSPPPF004'.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username  = sy-uname
    IMPORTING
      defaults  = default
    TABLES
      parameter = parameter
      return    = return.

  CALL FUNCTION 'CONVERSION_EXIT_SPDEV_INPUT'
    EXPORTING
      input  = gv_print_dest
    IMPORTING
      output = default-spld.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  ctrl_param-no_dialog  = 'X'.

  output_opt-tdnewid    = 'X'.
  output_opt-tdimmed    = 'X'.
  output_opt-tddelete   = ''.
  output_opt-tddest     = default-spld.

  CLEAR gv_message.

  IF gs_label-dat01 IS INITIAL OR
    gs_label-dat02 IS INITIAL OR
    gs_label-dat03 IS INITIAL OR
    gs_label-dat04 IS INITIAL OR
    gs_label-dat05 IS INITIAL OR
    gs_label-dat06 IS INITIAL OR
    gs_label-dat07 IS INITIAL.
    gv_message = 'Proses Kalibrasi belum lengkap'.
  ELSE.
    WRITE gs_label-kal01 TO gs_label-kal01t UNIT gs_label-mei01.
    WRITE gs_label-kal02 TO gs_label-kal02t UNIT gs_label-mei02.
    WRITE gs_label-kal03 TO gs_label-kal03t UNIT gs_label-mei03.
    WRITE gs_label-kal04 TO gs_label-kal04t UNIT gs_label-mei04.
    WRITE gs_label-kal05 TO gs_label-kal05t UNIT gs_label-mei05.
    WRITE gs_label-kal06 TO gs_label-kal06t UNIT gs_label-mei06.
    WRITE gs_label-kal07 TO gs_label-kal07t UNIT gs_label-mei07.

    CONDENSE gs_label-kal01t NO-GAPS.
    CONDENSE gs_label-kal02t NO-GAPS.
    CONDENSE gs_label-kal03t NO-GAPS.
    CONDENSE gs_label-kal04t NO-GAPS.
    CONDENSE gs_label-kal05t NO-GAPS.
    CONDENSE gs_label-kal06t NO-GAPS.
    CONDENSE gs_label-kal07t NO-GAPS.

    PERFORM f_add_itab USING gs_label-dat01 gs_label-tim01
                             gs_label-kal01t gs_label-mei01.
    PERFORM f_add_itab USING gs_label-dat02 gs_label-tim02
                             gs_label-kal02t gs_label-mei02.
    PERFORM f_add_itab USING gs_label-dat03 gs_label-tim03
                             gs_label-kal03t gs_label-mei03.
    PERFORM f_add_itab USING gs_label-dat04 gs_label-tim04
                             gs_label-kal04t gs_label-mei04.
    PERFORM f_add_itab USING gs_label-dat05 gs_label-tim05
                             gs_label-kal05t gs_label-mei05.
    PERFORM f_add_itab USING gs_label-dat06 gs_label-tim06
                             gs_label-kal06t gs_label-mei06.
    PERFORM f_add_itab USING gs_label-dat07 gs_label-tim07
                             gs_label-kal07t gs_label-mei07.

    CALL FUNCTION lv_funcname
      EXPORTING
        control_parameters = ctrl_param
        output_options     = output_opt
        user_settings      = space
        gs_label           = gs_label
      TABLES
        gt_kalib           = gt_kalib
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    CLEAR : gs_label.
  ENDIF.

*  CLEAR : gs_label.
ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_ADD_ITAB
*&---------------------------------------------------------------------*
FORM f_add_itab  USING    fu_dat00 fu_tim00 fu_kal00t fu_mei00.
  DATA : ls_kalib   LIKE LINE OF gt_kalib.

  ADD 1 TO gv_posnr.
  ls_kalib-dat00  = fu_dat00.
  ls_kalib-tim00  = fu_tim00.
  ls_kalib-kal00t = fu_kal00t.
  ls_kalib-mei00  = fu_mei00.
  CONDENSE gv_posnr.
  CONCATENATE 'No.' gv_posnr 'WT' INTO ls_kalib-num00
  SEPARATED BY space.
  APPEND ls_kalib TO gt_kalib.
ENDFORM.                    " F_ADD_ITAB
