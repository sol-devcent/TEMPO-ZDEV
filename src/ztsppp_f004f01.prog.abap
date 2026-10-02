*----------------------------------------------------------------------*
*   INCLUDE ZTNPQM_F001F01
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
  PERFORM f_print_form.
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
*  CLEAR : t_qclabel[], t_out[], gs_001.
*
*  SELECT SINGLE *
*    FROM ztnpqmdt001
*    INTO gs_001
*    WHERE sysid   = sy-sysid
*      AND bname   = sy-uname.
*
*  IF sy-subrc = 0.
*    gv_host  = gs_001-rfchost.
*  ENDIF.
*
*  SELECT SINGLE flag
*    FROM zproject
*    INTO gv_flag
*    WHERE name = 'ZTNPQM_F001'.
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
  DATA: lt_grlabel LIKE gt_grlabel OCCURS 0 WITH HEADER LINE.

  SELECT mkpf~mblnr mkpf~mjahr mkpf~bldat mkpf~budat
         mseg~zeile mseg~werks mseg~charg mseg~matnr
         mseg~ebeln mseg~menge mseg~meins mseg~lifnr
         mseg~aufnr mseg~lgnum mseg~lgort mseg~vfdat
         mseg~hsdat
    FROM mkpf JOIN mseg ON  mkpf~mblnr = mseg~mblnr
                        AND mkpf~mjahr = mseg~mjahr
    INTO CORRESPONDING FIELDS OF TABLE gt_grlabel
    WHERE mkpf~mblnr = pa_mblnr
      AND mkpf~mjahr = pa_mjahr.

  lt_grlabel[]  = gt_grlabel[].
  SORT lt_grlabel BY werks.
  DELETE ADJACENT DUPLICATES FROM lt_grlabel COMPARING werks.
  IF lt_grlabel[] IS NOT INITIAL.
    SELECT werks name1
      FROM t001w
      INTO TABLE gt_t001w
      FOR ALL ENTRIES IN lt_grlabel
      WHERE werks = lt_grlabel-werks.
  ENDIF.

  lt_grlabel[]  = gt_grlabel[].
  SORT lt_grlabel BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_grlabel COMPARING matnr.
  IF lt_grlabel[] IS NOT INITIAL.
    SELECT matnr mtart
      INTO CORRESPONDING FIELDS OF TABLE gt_mara
      FROM mara FOR ALL ENTRIES IN lt_grlabel
      WHERE matnr = lt_grlabel-matnr.

    SELECT matnr maktx
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FROM makt FOR ALL ENTRIES IN lt_grlabel
      WHERE matnr = lt_grlabel-matnr
        AND spras = sy-langu.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_marm
      FROM marm FOR ALL ENTRIES IN lt_grlabel
      WHERE matnr = lt_grlabel-matnr
        AND meinh = 'DR'.

    SELECT *
      FROM zppdt001
      INTO CORRESPONDING FIELDS OF TABLE gt_001
      FOR ALL ENTRIES IN lt_grlabel
      WHERE werks = lt_grlabel-werks
        AND matnr = lt_grlabel-matnr.
  ENDIF.

*  lt_grlabel[]  = gt_grlabel[].
*  SORT lt_grlabel BY matnr charg.
*  DELETE ADJACENT DUPLICATES FROM lt_grlabel COMPARING matnr charg.
*  IF lt_grlabel[] IS NOT INITIAL.
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_mch1
*      FROM mch1 FOR ALL ENTRIES IN lt_grlabel
*      WHERE matnr = lt_grlabel-matnr
*        AND charg = lt_grlabel-charg
*        AND lvorm = space.
*  ENDIF.

*  lt_grlabel[]  = gt_grlabel[].
*  SORT lt_grlabel BY matnr lifnr.
*  DELETE ADJACENT DUPLICATES FROM lt_grlabel COMPARING matnr lifnr.
*  IF lt_grlabel[] IS NOT INITIAL.
*    SELECT *
*      FROM zwmpalvnd
*      INTO CORRESPONDING FIELDS OF TABLE gt_zwmpalvnd
*      FOR ALL ENTRIES IN lt_grlabel
*      WHERE matnr = lt_grlabel-matnr
*        AND lifnr = lt_grlabel-lifnr.
*  ENDIF.
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
FORM f_process_data.
  DATA: lt_grlabel LIKE gt_grlabel OCCURS 0,
        lv_zeile TYPE mblpo,
        lv_loop  TYPE int4.

  FIELD-SYMBOLS: <fs_grlabel2> LIKE gt_grlabel.

  LOOP AT gt_grlabel ASSIGNING <fs_grlabel>.
    CLEAR: gt_t001w,gt_mara,gt_makt,gt_marm,lv_zeile, gs_001.
    READ TABLE gt_t001w WITH KEY werks = <fs_grlabel>-werks.
    READ TABLE gt_mara  WITH KEY matnr = <fs_grlabel>-matnr.
    READ TABLE gt_makt  WITH KEY matnr = <fs_grlabel>-matnr.
    READ TABLE gt_marm  WITH KEY matnr = <fs_grlabel>-matnr.
    READ TABLE gt_001 INTO gs_001
                      WITH KEY werks = <fs_grlabel>-werks
                               matnr = <fs_grlabel>-matnr.

    <fs_grlabel>-name1 = gt_t001w-name1.
    <fs_grlabel>-mtart = gt_mara-mtart.
    <fs_grlabel>-maktx = gt_makt-maktx.
    <fs_grlabel>-umrez = gt_marm-umrez.

    WRITE: <fs_grlabel>-menge TO <fs_grlabel>-menget UNIT <fs_grlabel>-meins.
    CONDENSE: <fs_grlabel>-menget.

    CASE <fs_grlabel>-werks.
      WHEN '0101'.
        <fs_grlabel>-name1 = 'TSP - Cikarang Plant 1'.
      WHEN '0102'.
        <fs_grlabel>-name1 = 'TSP - Cikarang Plant 2'.
      WHEN '0901'.
        <fs_grlabel>-name1 = 'SFF- Supra Ferbindo Farma'.
    ENDCASE.

    ADD 1 TO lv_zeile.
    <fs_grlabel>-zeile = lv_zeile.

    PERFORM f_new_hitung_counter USING <fs_grlabel>-meins <fs_grlabel>-menge
                                 CHANGING <fs_grlabel>-cntr.

*    PERFORM f_hitung_counter USING <fs_grlabel>-menge
*                                   <fs_grlabel>-umrez
*                             CHANGING <fs_grlabel>-cntr.

    IF <fs_grlabel>-cntr GT 1.
      lv_loop = <fs_grlabel>-cntr - 1.
      DO lv_loop TIMES.
        ADD 1 TO lv_zeile.
        APPEND <fs_grlabel> TO lt_grlabel ASSIGNING <fs_grlabel2>.
        <fs_grlabel2>-zeile = lv_zeile.
      ENDDO.
    ENDIF.
  ENDLOOP.

  IF lt_grlabel[] IS NOT INITIAL.
    APPEND LINES OF lt_grlabel TO gt_grlabel.
    SORT gt_grlabel BY mblnr mjahr zeile.
  ENDIF.
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
  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.
  DATA: lv_cntr1(4),
        lv_cntr2(4).

  IF d_frm_subrc IS INITIAL.
    d_output_opt-tdimmed  = nast-dimme.
    d_output_opt-tddelete = nast-delet.
    d_output_opt-tdcopies = nast-anzal.

    d_ctrl_param-no_close = ' '.
    d_ctrl_param-no_open = ' '.

    LOOP AT gt_grlabel INTO gw_qclabel.
      AT FIRST.
        d_ctrl_param-no_close = 'X'.
      ENDAT.

      AT LAST.
        d_ctrl_param-no_close = space.
      ENDAT.

      CLEAR: lv_cntr1,lv_cntr2.
      WRITE gw_qclabel-zeile TO lv_cntr1 NO-ZERO.
      WRITE gw_qclabel-cntr  TO lv_cntr2.
      CONDENSE: lv_cntr1,lv_cntr2.
      CONCATENATE lv_cntr1 lv_cntr2 INTO gw_qclabel-jumlah
        SEPARATED BY ' / '.

      CONCATENATE gw_qclabel-matnr gw_qclabel-charg
                  gw_qclabel-menget gw_qclabel-jumlah
                  INTO gw_qclabel-barcode
                  SEPARATED BY ';'.

      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          t_qclabel          = gw_qclabel.

      d_ctrl_param-no_open = 'X'.
    ENDLOOP.
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
  REFRESH: gt_grlabel,gt_marm,gt_mkpf,gt_mseg,gt_t001w,gt_mara,gt_makt,
           gt_marm,gt_mch1.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_GET_MANUFACTURER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_manufacturer  USING    fu_matnr
                                  fu_charg
                                  fu_werks
                         CHANGING fc_mfrpn
                                  fc_licha.
  DATA: lv_mcha LIKE mcha,
        lv_classname LIKE klah-class,
        lt_batch LIKE clbatch OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      matnr              = fu_matnr
      charg              = fu_charg
      werks              = fu_werks
      get_classification = 'X'
    IMPORTING
      ymcha              = lv_mcha
      classname          = lv_classname
    TABLES
      char_of_batch      = lt_batch
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
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR lt_batch.
    READ TABLE lt_batch WITH KEY atnam = 'ZMF'.
    fc_mfrpn = lt_batch-atwtb.

    fc_licha = lv_mcha-licha.
  ENDIF.

ENDFORM.                    " F_GET_MANUFACTURER

*&---------------------------------------------------------------------*
*&      Form  F_GET_PRODUCTION_DATE
*&---------------------------------------------------------------------*
FORM f_get_production_date  USING    fu_mblnr
                            CHANGING fc_hsdat.
  SELECT SINGLE hsdat
    FROM mseg
    INTO fc_hsdat
    WHERE mblnr EQ fu_mblnr.
ENDFORM.                    " F_GET_PRODUCTION_DATE

*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_MATERIAL_UNIT
*&---------------------------------------------------------------------*
FORM f_convert_material_unit  USING    fu_matnr
                                       fu_in
                                       fu_out
                                       fu_menge
                              CHANGING fc_qtypallet.
  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      i_matnr  = fu_matnr
      i_in_me  = fu_in
      i_out_me = fu_out
      i_menge  = fu_menge
    IMPORTING
      e_menge  = fc_qtypallet.
ENDFORM.                    " F_CONVERT_MATERIAL_UNIT

*&---------------------------------------------------------------------*
*&      Form  F_ROUND
*&---------------------------------------------------------------------*
FORM f_round  USING    fu_qtypallet
                       fu_sign
              CHANGING fc_qtyint.
  CALL FUNCTION 'ROUND'
    EXPORTING
*      DECIMALS            = 0
      input               = fu_qtypallet
      sign                = fu_sign
    IMPORTING
      output              = fc_qtyint.
ENDFORM.                    " F_ROUND

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_QUANTITY
*&---------------------------------------------------------------------*
FORM f_calculate_quantity  USING    fu_meinh fu_menge fu_matnr fu_lifnr
                                    fu_lgnum fu_lgort fu_atnam fu_werks
                                    fu_charg
                           CHANGING fc_sisa fc_times fc_menge.
*  DATA : ls_marm        LIKE LINE OF t_marm,
*         ls_zwmpalvnd   LIKE LINE OF gt_zwmpalvnd,
*         lv_menge       TYPE p DECIMALS 4,
*         lv_leqty       TYPE p DECIMALS 3.
*
*  IF fu_lgnum = '011' OR
*    fu_lgnum = '012'.
*    IF fu_atnam IS NOT INITIAL.
*      PERFORM f_get_vendor_batch USING fu_matnr fu_charg fu_werks fu_atnam
*                                 CHANGING lv_leqty.
*    ENDIF.
*  ENDIF.
*
*  IF fu_meinh = 'KAR'.
*    READ TABLE t_marm INTO ls_marm WITH KEY meinh = fu_meinh.
*    IF sy-subrc = 0.
*      lv_menge  = ( fu_menge / ls_marm-umrez ) / ls_marm-umren.
*      CALL FUNCTION 'ROUND'
*        EXPORTING
*          input         = lv_menge
*          sign          = '+'
*        IMPORTING
*          output        = fc_menge
*        EXCEPTIONS
*          input_invalid = 1
*          overflow      = 2
*          type_invalid  = 3
*          OTHERS        = 4.
*    ENDIF.
*  ELSE.
*    READ TABLE gt_zwmpalvnd INTO ls_zwmpalvnd
*                            WITH KEY lgnum = fu_lgnum
*                                     matnr = fu_matnr
*                                     lifnr = fu_lifnr.
*    IF sy-subrc = 0.
*      IF lv_leqty IS NOT INITIAL.
*        ls_zwmpalvnd-leqty = lv_leqty.
*      ENDIF.
*      fc_sisa   = fu_menge MOD ls_zwmpalvnd-leqty.
*      IF fc_sisa IS NOT INITIAL.
*        fc_times      = ( fu_menge DIV ls_zwmpalvnd-leqty ) + 1.
*      ELSE.
*        fc_times      = fu_menge DIV ls_zwmpalvnd-leqty.
*      ENDIF.
*      fc_menge  = ( ls_zwmpalvnd-leqty ).
*    ELSE.
*      IF fu_matnr = 'R0357' AND
*        ( fu_lgort = '1011' OR fu_lgort = '1021' ).
*        fc_menge = fu_menge.
*      ELSE.
*        READ TABLE t_marm INTO ls_marm WITH KEY meinh = fu_meinh.
*        IF sy-subrc = 0.
*          IF lv_leqty IS INITIAL.
*            fc_sisa   = fu_menge MOD ( ls_marm-umrez / ls_marm-umren ).
*            IF fc_sisa IS NOT INITIAL.
*              fc_times      = ( fu_menge DIV ( ls_marm-umrez / ls_marm-umren ) ) + 1.
*            ELSE.
*              fc_times      = ( fu_menge DIV ( ls_marm-umrez / ls_marm-umren ) ).
*            ENDIF.
*            fc_menge  = ( ls_marm-umrez / ls_marm-umren ).
*          ELSE.
*            fc_sisa   = fu_menge MOD lv_leqty.
*            IF fc_sisa IS NOT INITIAL.
*              fc_times      = ( fu_menge DIV lv_leqty ) + 1.
*            ELSE.
*              fc_times      = fu_menge DIV lv_leqty.
*            ENDIF.
*            fc_menge  = ( lv_leqty ).
*          ENDIF.
*        ELSE.
*          IF fu_lgnum = '011' OR
*            fu_lgnum = '012'.
*            IF lv_leqty IS INITIAL.
*              gv_error  = 1.
*            ELSE.
*              fc_sisa   = fu_menge MOD lv_leqty.
*              IF fc_sisa IS NOT INITIAL.
*                fc_times      = ( fu_menge DIV lv_leqty ) + 1.
*              ELSE.
*                fc_times      = fu_menge DIV lv_leqty.
*              ENDIF.
*              fc_menge  = ( lv_leqty ).
*            ENDIF.
*          ELSE.
*            gv_error  = 1.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*
*  IF fu_menge < fc_menge.
*    fc_menge = fu_menge.
*  ENDIF.
ENDFORM.                    " F_CALCULATE_QUANTITY

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_QR_FORM
*&---------------------------------------------------------------------*
FORM f_print_qr_form .
*  DATA : lt_out     TYPE STANDARD TABLE OF ztnpqmst001,
*         ls_out     LIKE LINE OF lt_out,
*         ls_xout    LIKE LINE OF lt_out,
*         lv_lines   TYPE i,
*         lv_count   TYPE i,
*         fr         TYPE i,
*         to         TYPE i.
*
*  CALL FUNCTION 'RFC_MODIFY_R3_DESTINATION'
*    EXPORTING
*      destination                = gs_001-destination
*      action                     = 'M'
*      systemnr                   = gs_001-rfcservice
*      server                     = gv_host
*      language                   = sy-langu
*      client                     = gs_001-rfcclient
*      user                       = gs_001-rfcuser
*      password                   = gs_001-password
*    EXCEPTIONS
*      authority_not_available    = 1
*      destination_already_exist  = 2
*      destination_not_exist      = 3
*      destination_enqueue_reject = 4
*      information_failure        = 5
*      trfc_entry_invalid         = 6
*      internal_failure           = 7
*      snc_information_failure    = 8
*      snc_internal_failure       = 9
*      destination_is_locked      = 10
*      OTHERS                     = 11.
*  IF sy-subrc = 0.
*    DESCRIBE TABLE t_out LINES lv_lines.
*    lv_lines  = ( lv_lines DIV 250 ) + 1.
*
*    DO lv_lines TIMES.
*      CLEAR lt_out[].
*      fr = lv_count + 1.
*      to = lv_count + 250.
*      LOOP AT t_out INTO ls_out FROM fr TO to.
*        ADD 1 TO lv_count.
*        ls_xout = ls_out.
*        APPEND ls_xout TO lt_out.
*        CLEAR ls_xout.
*      ENDLOOP.
*
*      CALL FUNCTION 'ZRFC_ZTNPQM_SF001'
*        DESTINATION gs_001-destination
*        EXPORTING
*          pi_cntrlpara = d_ctrl_param
*          pi_outputopt = d_output_opt
*          pi_tdsfname  = p_tdform
*          pi_rspolname = gs_001-name
*          pi_qclabel   = wa_qclabel
*          pi_packsize  = 'X'
*        TABLES
*          pt_qclabel   = lt_out.
*    ENDDO.
*  ENDIF.
ENDFORM.                    " F_PRINT_QR_FORM

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  DATA : lv_funcmod     TYPE rs38l_fnam,
         lv_output_opt  TYPE ssfcompop,
         ls_qclabel     TYPE ztnpqmst001,
         lv_count       TYPE int_1,
         lv_loop        TYPE int_1.

  CLEAR : lv_loop, lv_count.
*  DESCRIBE TABLE t_out LINES lv_loop.

  "Get FM smartforms
  SET PARAMETER ID 'SSFNAME' FIELD p_tdform.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = p_tdform
    IMPORTING
      fm_name            = lv_funcmod
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  "Get Printer name
  IF sy-subrc = 0.
    MOVE-CORRESPONDING d_output_opt TO lv_output_opt.
    lv_output_opt-tddest    = nast-ldest.

    LOOP AT gt_grlabel.
      ADD 1 TO lv_count.

      IF lv_count = 1.
        lv_output_opt-tdnewid   = 'X'.
      ENDIF.

      lv_output_opt-tdimmed   = 'X'.

      IF lv_count = lv_loop.
        d_ctrl_param-no_close  = space.
      ELSE.
        d_ctrl_param-no_close  = 'X'.
      ENDIF.

      CALL FUNCTION lv_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = lv_output_opt
          user_settings      = space
          t_qclabel          = gt_grlabel.

      d_ctrl_param-no_open  = 'X'.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_MANUFACTURING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_MATNR_ATWRT  text
*----------------------------------------------------------------------*
FORM f_modify_manufacturing  USING    fu_matnr fu_charg fu_cuobj_bm
                             CHANGING fc_atwrt.
*  DATA : lv_atinn   TYPE ausp-atinn.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*    EXPORTING
*      input  = 'ZMF'
*    IMPORTING
*      output = lv_atinn.
*
*  SELECT SINGLE atwrt
*    FROM ausp
*    INTO fc_atwrt
*    WHERE objek  EQ fu_cuobj_bm
*      AND atinn  EQ lv_atinn
*      AND klart  EQ '023'.
ENDFORM.                    " F_MODIFY_MANUFACTURING

*&---------------------------------------------------------------------*
*&      Form  F_GET_VENDOR_BATCH
*&---------------------------------------------------------------------*
FORM f_get_vendor_batch USING fu_matnr fu_charg fu_werks fu_atnam
                        CHANGING fc_atwtb.

  DATA : ymcha        TYPE mcha,
         classname    TYPE klah-class,
         cob          TYPE STANDARD TABLE OF clbatch,
         ls_cob       LIKE LINE OF cob.

  CLEAR fc_atwtb.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      matnr              = fu_matnr
      charg              = fu_charg
      werks              = fu_werks
      get_classification = 'X'
    IMPORTING
      ymcha              = ymcha
      classname          = classname
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

  READ TABLE cob INTO ls_cob WITH KEY atnam = fu_atnam.
  IF sy-subrc = 0.
    TRANSLATE ls_cob-atwtb USING '. '.
    TRANSLATE ls_cob-atwtb USING ',.'.
    CONDENSE ls_cob-atwtb NO-GAPS.
    fc_atwtb  = ls_cob-atwtb.
  ENDIF.
ENDFORM.                    " F_GET_VENDOR_BATCH

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_COUNTER
*&---------------------------------------------------------------------*
FORM f_hitung_counter  USING    fu_menge
                                fu_umrez
                       CHANGING fu_cntr.
  DATA: lv_sisa TYPE int3.

  IF fu_umrez > 0.
    lv_sisa = fu_menge MOD fu_umrez.
    fu_cntr = fu_menge DIV fu_umrez.
    IF lv_sisa IS NOT INITIAL.
      ADD 1 TO fu_cntr.
    ENDIF.
  ELSE.
    ADD 1 TO fu_cntr.
  ENDIF.
ENDFORM.                    " F_HITUNG_COUNTER

*&---------------------------------------------------------------------*
*&      Form  F_NEW_HITUNG_COUNTER
*&---------------------------------------------------------------------*
FORM f_new_hitung_counter  USING    fu_meins fu_menge
                           CHANGING fc_cntr.

  DATA : lv_menge   TYPE mseg-menge,
         lv_sisa    TYPE int3,
         lv_umrez   TYPE mseg-menge.

  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
    EXPORTING
      input                = fu_menge
      unit_in              = fu_meins
      unit_out             = gs_001-meins
    IMPORTING
      output               = lv_menge
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

  lv_umrez  = gs_001-umrez / gs_001-umren.

  IF lv_umrez > 0.
    lv_sisa = lv_menge MOD lv_umrez.
    fc_cntr = lv_menge DIV lv_umrez.
    IF lv_sisa IS NOT INITIAL.
      ADD 1 TO fc_cntr.
    ENDIF.
  ELSE.
    ADD 1 TO fc_cntr.
  ENDIF.
ENDFORM.                    " F_NEW_HITUNG_COUNTER
