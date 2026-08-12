class ZCL_ZSFF_WEIGHING_POST_DPC_EXT definition
  public
  inheriting from ZCL_ZSFF_WEIGHING_POST_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.

  methods CLEARWEIGHTSET_CREATE_ENTITY
    redefinition .
  methods USERSET_CREATE_ENTITY
    redefinition .
  methods WH_PGISET_CREATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZSFF_WEIGHING_POST_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    DATA: ls_deep TYPE zcl_zsff_weighing_post_mpc_ext=>ts_fp_pgi_deep,
          ls_hdr  TYPE zcl_zsff_weighing_post_mpc_ext=>ts_fp_pgi,
          lt_dtl  TYPE STANDARD TABLE OF zcl_zsff_weighing_post_mpc_ext=>ts_fp_pgi_dtl.

    DATA: ls_wh_deep TYPE zcl_zsff_weighing_post_mpc_ext=>ts_wh_getweight_deep,
          ls_wh_hdr  TYPE zcl_zsff_weighing_post_mpc_ext=>ts_wh_getweight,
          lt_wh_dtl  TYPE STANDARD TABLE OF zcl_zsff_weighing_post_mpc_ext=>ts_wh_getweight_dtl,
          lt_wh_dtl2 TYPE STANDARD TABLE OF zcl_zsff_weighing_post_mpc_ext=>ts_wh_getweight_dtl.

    DATA: ls_wh_print_deep TYPE zcl_zsff_weighing_post_mpc_ext=>ts_wh_print_deep,
          ls_wh_print_hdr  TYPE zcl_zsff_weighing_post_mpc_ext=>ts_wh_print,
          lt_wh_print_dtl  TYPE STANDARD TABLE OF zcl_zsff_weighing_post_mpc_ext=>ts_wh_print_dtl,
          lt_wh_print_vnd  TYPE STANDARD TABLE OF zcl_zsff_weighing_post_mpc_ext=>ts_wh_print_vnd.

    DATA: obj_msg_con  TYPE REF TO /iwbep/if_message_container,
          cl_json_data TYPE REF TO zcl_trex_json_serializer,
          lv_json      TYPE string,
          lv_jsonret   TYPE string.

    DATA: lv_packs    TYPE bdmng,
          lv_packt    TYPE bdmng,
          lv_reqqty   TYPE bdmng,
          lv_clabs    TYPE labst,
          lv_erfmg    TYPE erfmg,
          lv_erfmg_2  TYPE erfmg,
          lv_erfmgtot TYPE erfmg,
          lv_bdmng    TYPE bdmng,
          lv_equnr    TYPE equnr,
          lv_factor   TYPE bapi2045d2-mean_value,
          lv_text     TYPE bapi2045l2-txt_oper,
          lv_inspoper TYPE bapi2045l2-inspoper,
          lv_date(10), lv_time(10).

    DATA: lv_mblnr           TYPE mblnr,
          lv_mjahr           TYPE mjahr,
          lv_msgtyp          TYPE bapi_mtype,
          lv_message         TYPE bapi_msg,
          lv_tara            TYPE zsffppdt004-tara,
          lt_zsffppdt003_upd TYPE STANDARD TABLE OF zsffppdt003,
          lt_fp_pgi          TYPE STANDARD TABLE OF zsffst001_tmp,
          lt_wh_print        TYPE STANDARD TABLE OF zsffst003,
          lt_wh_vendor       TYPE STANDARD TABLE OF zsffst004.

    CASE iv_entity_set_name.
      WHEN 'FP_PGISet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_deep.
          CATCH /iwbep/cx_mgw_tech_exception .
        ENDTRY.

        IF ls_deep IS NOT INITIAL.
          obj_msg_con = me->mo_context->get_message_container( ).

          MOVE-CORRESPONDING ls_deep TO ls_hdr.
          lt_dtl[] = ls_deep-fp_pginav[].
          DATA(lv_lgort) = VALUE #( lt_dtl[ 1 ]-lgort OPTIONAL ).

          SELECT SUM( clabs ) INTO lv_clabs
            FROM mchb WHERE matnr = ls_hdr-matnr
                        AND werks = ls_hdr-werks
                        AND lgort = lv_lgort
                        AND charg = ls_hdr-charg.

          lv_packs = ls_deep-packs.
          lv_packt = ls_deep-packt.
          lv_reqqty = lv_packs * lv_packt.

          IF lv_clabs LT lv_reqqty.
            obj_msg_con->add_message_text_only(
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Stock not available'
                iv_add_to_response_header = abap_true ).

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ENDIF.

          CREATE OBJECT cl_json_data
            EXPORTING
              data = ls_hdr.
          cl_json_data->serialize( ).
          lv_json = cl_json_data->get_data( ).

          LOOP AT lt_dtl INTO DATA(ls_dtl).
            APPEND INITIAL LINE TO lt_fp_pgi ASSIGNING FIELD-SYMBOL(<fs_fp_pgi>).
            MOVE-CORRESPONDING ls_dtl TO <fs_fp_pgi>.
          ENDLOOP.

          CALL FUNCTION 'ZSFF_WEIGHT'
            EXPORTING
              pi_process = 'PF_PGI'
              pi_data    = lv_json
            IMPORTING
              pe_data    = lv_jsonret
              pe_msgtyp  = lv_msgtyp
              pe_message = lv_message
            TABLES
              pt_fp_pgi  = lt_fp_pgi.

          obj_msg_con->add_message_text_only(
            EXPORTING
              iv_msg_type               = lv_msgtyp
              iv_msg_text               = lv_message
              iv_add_to_response_header = abap_true ).

          IF lv_msgtyp = 'E'.
            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
*               textid            = /iwbep/cx_mgw_busi_exception=>business_error
                message_container = obj_msg_con.

          ELSE.
            CLEAR: ls_hdr,lt_dtl.

            zcl_json=>deserialize(
              EXPORTING
                json   = lv_jsonret
              CHANGING
                data   = ls_hdr ).

            LOOP AT lt_fp_pgi ASSIGNING <fs_fp_pgi>.
              APPEND INITIAL LINE TO lt_dtl ASSIGNING FIELD-SYMBOL(<fs_dtl>).
              MOVE-CORRESPONDING <fs_fp_pgi> TO <fs_dtl>.
            ENDLOOP.

            ls_hdr-wdesc = 'SFF - Supra Ferbindo Farma'.
            WRITE sy-datum TO ls_hdr-datum.

            MOVE-CORRESPONDING ls_hdr TO ls_deep.
            ls_deep-fp_pginav[] = lt_dtl[].

            TRY.
                CALL METHOD me->copy_data_to_ref
                  EXPORTING
                    is_data = ls_deep
                  CHANGING
                    cr_data = er_deep_entity.
              CATCH cx_root.
            ENDTRY.
          ENDIF.
        ENDIF.

      WHEN 'WH_GetWeightSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_wh_deep.
          CATCH /iwbep/cx_mgw_tech_exception .
        ENDTRY.

        IF ls_wh_deep IS NOT INITIAL.
          obj_msg_con = me->mo_context->get_message_container( ).

          MOVE-CORRESPONDING ls_wh_deep TO ls_wh_hdr.
          lt_wh_dtl[] = ls_wh_deep-wh_getweightnav[].

          DATA(lv_aufnr_out) = ls_wh_hdr-aufnr.
          SHIFT lv_aufnr_out LEFT DELETING LEADING '0' .
          DATA(lv_aufnr_in) = |{ lv_aufnr_out ALPHA = IN }|.

          SELECT * INTO TABLE @DATA(lt_zsffppdt003)
            FROM zsffppdt003 FOR ALL ENTRIES IN @lt_wh_dtl
*            WHERE aufnr = @ls_wh_hdr-aufnr
            WHERE ( aufnr = @lv_aufnr_in OR aufnr = @lv_aufnr_out )
              AND vornr = @ls_wh_hdr-vornr
              AND posnr = @ls_wh_hdr-posnr
              AND matnr = @ls_wh_hdr-matnr
              AND charg NE @lt_wh_dtl-charg
            ORDER BY PRIMARY KEY.
          IF sy-subrc = 0.
            LOOP AT lt_zsffppdt003 INTO DATA(ls_zsffppdt003).
              SELECT SUM( clabs ) INTO lv_clabs
                FROM mchb WHERE matnr = ls_wh_hdr-matnr
                            AND werks = ls_wh_hdr-werks
                            AND lgort = ls_wh_hdr-lgort
                            AND charg = ls_zsffppdt003-charg.
              IF sy-subrc = 0.
                SELECT SUM( bdmng ) AS sum_bdmng, SUM( erfmg ) AS sum_erfmg
                  INTO @DATA(ls_sum)
                  FROM resb WHERE matnr = @ls_wh_hdr-matnr
                              AND werks = @ls_wh_hdr-werks
                              AND charg = @ls_zsffppdt003-charg
                              AND lgort = @ls_wh_hdr-lgort
                              AND kzear = @space
                              AND splkz = '2'
                              AND wempf IN ('T','W').

                lv_clabs = lv_clabs - ls_sum-sum_bdmng.

                IF ls_zsffppdt003-meins NE ls_zsffppdt003-erfme.
                  IF ls_zsffppdt003-meins = 'L'.
                    CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
                      EXPORTING
                        input                = lv_clabs
                        matnr                = ls_zsffppdt003-matnr
                        meinh                = ls_zsffppdt003-erfme
                        meins                = ls_zsffppdt003-meins
                      IMPORTING
                        output               = lv_clabs
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
                  ELSE.
                    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
                      EXPORTING
                        input    = lv_clabs
                        unit_in  = ls_zsffppdt003-meins
                        unit_out = ls_zsffppdt003-erfme
                      IMPORTING
                        output   = lv_clabs.
                  ENDIF.
                ENDIF.
              ENDIF.

              ADD ls_zsffppdt003-erfmg TO lv_erfmgtot.

              APPEND INITIAL LINE TO lt_wh_dtl2 ASSIGNING FIELD-SYMBOL(<fs_wh_dtl2>).
              MOVE-CORRESPONDING ls_zsffppdt003 TO <fs_wh_dtl2>.
              <fs_wh_dtl2>-aufnr = ls_zsffppdt003-aufnr.
              <fs_wh_dtl2>-charg = ls_zsffppdt003-charg.
              <fs_wh_dtl2>-meins = ls_zsffppdt003-meins.
              <fs_wh_dtl2>-erfme = ls_zsffppdt003-erfme.
              WRITE lv_clabs TO <fs_wh_dtl2>-clabs UNIT ls_zsffppdt003-erfme.
              WRITE ls_zsffppdt003-bdmng TO <fs_wh_dtl2>-bdmng UNIT ls_zsffppdt003-erfme.
              WRITE ls_zsffppdt003-erfmg TO <fs_wh_dtl2>-erfmg UNIT ls_zsffppdt003-erfme.
              CONDENSE: <fs_wh_dtl2>-clabs,<fs_wh_dtl2>-bdmng,<fs_wh_dtl2>-erfmg.

              DATA(lv_zeile) = ls_zsffppdt003-zeile.

              IF ls_zsffppdt003-factor IS NOT INITIAL.
                UPDATE zsffppdt003 SET bdmng = ls_zsffppdt003-factor
                                       factor = 0
                                   WHERE aufnr = ls_zsffppdt003-aufnr
                                     AND vornr = ls_zsffppdt003-vornr
                                     AND posnr = ls_zsffppdt003-posnr
                                     AND zeile = ls_zsffppdt003-zeile
                                     AND matnr = ls_zsffppdt003-matnr
                                     AND charg = ls_zsffppdt003-charg.
                COMMIT WORK AND WAIT.
              ENDIF.
            ENDLOOP.
          ENDIF.

          LOOP AT lt_wh_dtl ASSIGNING FIELD-SYMBOL(<fs_wh_dtl>).
            IF <fs_wh_dtl>-erfmg IS INITIAL OR <fs_wh_dtl>-erfme IS INITIAL OR
               <fs_wh_dtl>-weime IS INITIAL.
              obj_msg_con->add_message_text_only(
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Entry Qty/Unit is initial'
                  iv_add_to_response_header = abap_true ).

              RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                  message_container = obj_msg_con.
            ENDIF.

            "Check Numeric Field
            DATA: string_out TYPE char20,
                  htype      TYPE dd01v-datatype.
            DATA(lv_erfmg_chk) = <fs_wh_dtl>-erfmg.
            REPLACE ALL OCCURRENCES OF '.' IN lv_erfmg_chk WITH space.
            REPLACE ALL OCCURRENCES OF ',' IN lv_erfmg_chk WITH space.
            CONDENSE lv_erfmg_chk.
            CALL FUNCTION 'NUMERIC_CHECK'
              EXPORTING
                string_in  = lv_erfmg_chk
              IMPORTING
                string_out = string_out
                htype      = htype.
            IF htype = 'CHAR'.
              obj_msg_con->add_message_text_only(
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Qty entry is Char'
                  iv_add_to_response_header = abap_true ).
              RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                  message_container = obj_msg_con.
            ENDIF.

            DATA(lv_clabs_tmp) = <fs_wh_dtl>-clabs.
            DATA(lv_bdmng_tmp) = <fs_wh_dtl>-bdmng.
            DATA(lv_erfmg_tmp) = <fs_wh_dtl>-erfmg.
            TRANSLATE <fs_wh_dtl>-weime TO UPPER CASE.
            REPLACE ALL OCCURRENCES OF '.' IN lv_clabs_tmp WITH space.
            REPLACE ALL OCCURRENCES OF ',' IN lv_clabs_tmp WITH '.'.
            REPLACE ALL OCCURRENCES OF '.' IN lv_bdmng_tmp WITH space.
            REPLACE ALL OCCURRENCES OF ',' IN lv_bdmng_tmp WITH '.'.
            REPLACE ALL OCCURRENCES OF ',' IN lv_erfmg_tmp WITH space.
            CONDENSE: lv_clabs_tmp,lv_bdmng_tmp,lv_erfmg_tmp.

            lv_clabs = lv_clabs_tmp.
            lv_bdmng = lv_bdmng_tmp.
            lv_erfmg = lv_erfmg_tmp.

            IF <fs_wh_dtl>-weime NE <fs_wh_dtl>-erfme.
              CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
                EXPORTING
                  input                = lv_erfmg
                  unit_in              = <fs_wh_dtl>-weime
                  unit_out             = <fs_wh_dtl>-erfme
                IMPORTING
                  output               = lv_erfmg
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
              IF sy-subrc NE 0.
                obj_msg_con->add_message_text_only(
                  EXPORTING
                    iv_msg_type               = 'E'
                    iv_msg_text               = 'Conversion ERROR'
                    iv_add_to_response_header = abap_true ).

                RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                  EXPORTING
*                   textid            = /iwbep/cx_mgw_busi_exception=>business_error
                    message_container = obj_msg_con.
              ENDIF.
            ENDIF.

            lv_erfmg = lv_erfmg - lv_erfmgtot.

            WRITE lv_erfmg TO <fs_wh_dtl>-erfmg UNIT <fs_wh_dtl>-erfme.
            CONDENSE <fs_wh_dtl>-erfmg.
            CLEAR <fs_wh_dtl>-weime.

            IF lv_clabs LT lv_erfmg.  "lv_erfmg_2.
              obj_msg_con->add_message_text_only(
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Jumlah timbang melebihi stok'
                  iv_add_to_response_header = abap_true ).

              RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
*                 textid            = /iwbep/cx_mgw_busi_exception=>business_error
                  message_container = obj_msg_con.
            ENDIF.

            ls_wh_hdr-aufnr = |{ ls_wh_hdr-aufnr ALPHA = IN }|.
            APPEND INITIAL LINE TO lt_zsffppdt003_upd ASSIGNING FIELD-SYMBOL(<fs_zsffppdt003>).
            MOVE-CORRESPONDING ls_wh_hdr TO <fs_zsffppdt003>.
            <fs_zsffppdt003>-charg = <fs_wh_dtl>-charg.
            <fs_zsffppdt003>-bdmng = lv_bdmng.
            <fs_zsffppdt003>-meins = <fs_wh_dtl>-meins.
            <fs_zsffppdt003>-erfmg = lv_erfmg.
            <fs_zsffppdt003>-erfme = <fs_wh_dtl>-erfme.
            <fs_zsffppdt003>-zeile = lv_zeile + 1.

            DATA(ls_wh_dtl) = <fs_wh_dtl>.
          ENDLOOP.

          IF lt_wh_dtl2[]  IS NOT INITIAL.
            CLEAR lt_wh_dtl.
            APPEND LINES OF lt_wh_dtl2 TO lt_wh_dtl.
            APPEND ls_wh_dtl TO lt_wh_dtl.
          ENDIF.

          IF lt_zsffppdt003_upd[] IS NOT INITIAL.
            MODIFY zsffppdt003 FROM TABLE lt_zsffppdt003_upd.
          ENDIF.

          IF lv_erfmg = lv_bdmng.
            ls_wh_hdr-print = 'P'.
          ENDIF.

          MOVE-CORRESPONDING ls_wh_hdr TO ls_wh_deep.
          ls_wh_deep-wh_getweightnav[] = lt_wh_dtl[].

          TRY.
              CALL METHOD me->copy_data_to_ref
                EXPORTING
                  is_data = ls_wh_deep
                CHANGING
                  cr_data = er_deep_entity.
            CATCH cx_root.
          ENDTRY.
        ENDIF.

      WHEN 'WH_PrintSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_wh_print_deep.
          CATCH /iwbep/cx_mgw_tech_exception .
        ENDTRY.

        IF ls_wh_print_deep IS NOT INITIAL.
          obj_msg_con = me->mo_context->get_message_container( ).

          MOVE-CORRESPONDING ls_wh_print_deep TO ls_wh_print_hdr.
          lt_wh_print_dtl[]  = ls_wh_print_deep-wh_printnav[].
          lt_wh_print_vnd[]  = ls_wh_print_deep-wh_printtovndnav[].
          DATA(lv_equnr_ori) = ls_wh_print_hdr-equnr.
          lv_equnr    = |{ lv_equnr_ori ALPHA = IN }|.
          lv_text     = 'Faktorisasi pada Kadar'.
          lv_inspoper = '0010'.

          lv_tara = abs( ls_wh_print_hdr-tara ).
          WRITE lv_tara TO ls_wh_print_hdr-tara.
          REPLACE ALL OCCURRENCES OF '.' IN ls_wh_print_hdr-tara WITH space.
          REPLACE ALL OCCURRENCES OF ',' IN ls_wh_print_hdr-tara WITH '.'.
          CONDENSE ls_wh_print_hdr-tara.

          CREATE OBJECT cl_json_data
            EXPORTING
              data = ls_wh_print_hdr.
          cl_json_data->serialize( ).
          lv_json = cl_json_data->get_data( ).

          LOOP AT lt_wh_print_dtl INTO DATA(ls_wh_print_dtl).
            APPEND INITIAL LINE TO lt_wh_print ASSIGNING FIELD-SYMBOL(<fs_wh_print>).
            MOVE-CORRESPONDING ls_wh_print_dtl TO <fs_wh_print>.
          ENDLOOP.

          LOOP AT lt_wh_print_vnd INTO DATA(ls_wh_print_vnd).
            APPEND INITIAL LINE TO lt_wh_vendor ASSIGNING FIELD-SYMBOL(<fs_wh_vendor>).
            MOVE-CORRESPONDING ls_wh_print_vnd TO <fs_wh_vendor>.
          ENDLOOP.

          CALL FUNCTION 'ZSFF_WEIGHT'
            EXPORTING
              pi_process      = 'WH_PRINT'
              pi_data         = lv_json
            IMPORTING
              pe_data         = lv_jsonret
              pe_msgtyp       = lv_msgtyp
              pe_message      = lv_message
            TABLES
              pt_wh_print     = lt_wh_print
              pt_wh_print_vnd = lt_wh_vendor.

          obj_msg_con->add_message_text_only(
            EXPORTING
              iv_msg_type               = lv_msgtyp
              iv_msg_text               = lv_message
              iv_add_to_response_header = abap_true ).

          IF lv_msgtyp = 'E'.
            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
*               textid            = /iwbep/cx_mgw_busi_exception=>business_error
                message_container = obj_msg_con.

          ELSE.
            CLEAR: ls_wh_print_hdr,lt_wh_print_dtl,lt_wh_print_vnd.

            zcl_json=>deserialize(
              EXPORTING
                json   = lv_jsonret
              CHANGING
                data   = ls_wh_print_hdr ).

            SELECT SINGLE factor INTO @DATA(lv_flag_factor)
              FROM ztnpppdt002 WHERE ( equnr = @lv_equnr OR equnr = @lv_equnr_ori )
                                 AND matnr = @ls_wh_print_hdr-matnr
                                 AND factor = 'X'.
            IF sy-subrc NE 0.
              CLEAR lv_flag_factor.
            ENDIF.

            LOOP AT lt_wh_print ASSIGNING <fs_wh_print>.
              APPEND INITIAL LINE TO lt_wh_print_dtl ASSIGNING FIELD-SYMBOL(<fs_wh_print_dtl>).
              MOVE-CORRESPONDING <fs_wh_print> TO <fs_wh_print_dtl>.

              IF lv_flag_factor = 'X'.
                CLEAR lv_factor.
                CALL FUNCTION 'ZQMMATNR_FACTOR'
                  EXPORTING
                    i_matnr      = ls_wh_print_hdr-matnr
                    i_charg      = <fs_wh_print_dtl>-charg
                    i_werks      = ls_wh_print_hdr-werks
                    i_text       = lv_text
                    i_inspoper   = lv_inspoper
                  IMPORTING
                    e_mean_value = lv_factor.
                IF lv_factor IS NOT INITIAL.
                  CONDENSE lv_factor.
                  <fs_wh_print_dtl>-meanv = |( F = | & |{ lv_factor }| & | )|.
                ENDIF.
              ENDIF.
            ENDLOOP.

            LOOP AT lt_wh_vendor ASSIGNING <fs_wh_vendor>.
              APPEND INITIAL LINE TO lt_wh_print_vnd ASSIGNING FIELD-SYMBOL(<fs_wh_print_vnd>).
              MOVE-CORRESPONDING <fs_wh_vendor> TO <fs_wh_print_vnd>.
            ENDLOOP.

*            WRITE sy-datum TO lv_date.
*            WRITE sy-uzeit TO lv_time.
            ls_wh_print_hdr-wdesc = 'SFF - Supra Ferbindo Farma'.
*            ls_wh_print_hdr-datum = |{ lv_date }| & | | & |{ lv_time }|.

            MOVE-CORRESPONDING ls_wh_print_hdr TO ls_wh_print_deep.
            ls_wh_print_deep-wh_printtovndnav[] = lt_wh_print_vnd[].
            ls_wh_print_deep-wh_printnav[] = lt_wh_print_dtl[].

            TRY.
                CALL METHOD me->copy_data_to_ref
                  EXPORTING
                    is_data = ls_wh_print_deep
                  CHANGING
                    cr_data = er_deep_entity.
              CATCH cx_root.
            ENDTRY.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.


  METHOD clearweightset_create_entity.
    DATA: ls_clearweight TYPE zcl_zsff_weighing_post_mpc_ext=>ts_clearweight.

    DATA: lv_msg      TYPE bapi_msg,
          obj_msg_con TYPE REF TO /iwbep/if_message_container.

    TRY.
        CALL METHOD io_data_provider->read_entry_data
          IMPORTING
            es_data = ls_clearweight.
      CATCH /iwbep/cx_mgw_tech_exception .
    ENDTRY.

    IF ls_clearweight IS NOT INITIAL.
      obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

      DATA(lv_aufnr) = ls_clearweight-aufnr.
      SHIFT lv_aufnr LEFT DELETING LEADING '0' .
      DATA(lv_aufnr_in) = |{ lv_aufnr ALPHA = IN }|.

      SELECT * INTO TABLE @DATA(lt_zsffppdt003)
        FROM zsffppdt003 WHERE ( aufnr = @lv_aufnr OR aufnr = @lv_aufnr_in )
                           AND vornr = @ls_clearweight-vornr
                           AND posnr = @ls_clearweight-posnr.

      IF sy-subrc = 0.
        DELETE zsffppdt003 FROM TABLE lt_zsffppdt003.

        IF sy-subrc = 0.
          obj_msg_con->add_message_text_only(
            EXPORTING
              iv_msg_type               = 'S'
              iv_msg_text               = 'Successfuly Data Clear'
              iv_add_to_response_header = abap_true ).

          CLEAR ls_clearweight.
          er_entity = ls_clearweight.

        ELSE.
          obj_msg_con->add_message_text_only(
            EXPORTING
              iv_msg_type               = 'E'
              iv_msg_text               = 'ERROR Data Clear'
              iv_add_to_response_header = abap_true ).

          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
            EXPORTING
              message_container = obj_msg_con.
        ENDIF.

      ELSE.
        obj_msg_con->add_message_text_only(
          EXPORTING
            iv_msg_type               = 'E'
            iv_msg_text               = 'Data Invalid'
            iv_add_to_response_header = abap_true ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            message_container = obj_msg_con.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD userset_create_entity.
    DATA: ls_user TYPE zcl_zsff_weighing_post_mpc_ext=>ts_user.

    DATA: lv_msg      TYPE bapi_msg,
          obj_msg_con TYPE REF TO /iwbep/if_message_container.

    DATA: lv_password TYPE char30,
          gv_encoded  TYPE dbcon_pwd.

    TRY.
        CALL METHOD io_data_provider->read_entry_data
          IMPORTING
            es_data = ls_user.
      CATCH /iwbep/cx_mgw_tech_exception .
    ENDTRY.

    IF ls_user IS NOT INITIAL.
      obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

      SELECT SINGLE zpassword INTO @DATA(lv_pswd)
        FROM zsffppdt001 WHERE znrp   = @ls_user-znrp
                           AND ztitle = @ls_user-ztitletx
                           AND werks  = @ls_user-werks.

      IF sy-subrc = 0.
        lv_password = ls_user-zpassword.
        CALL FUNCTION 'DB_CRYPTO_PASSWORD'
          EXPORTING
            clear_text_password          = lv_password
          IMPORTING
            encoded_password             = gv_encoded
          EXCEPTIONS
            crypt_output_buffer_to_small = 1
            crypt_internal_error         = 2
            crypt_truncation_error       = 3
            crypt_conversion_error       = 4
            internal_error               = 5
            OTHERS                       = 6.

        IF sy-subrc = 0.
          IF gv_encoded(40) = lv_pswd.
            obj_msg_con->add_message_text_only(
              EXPORTING
                iv_msg_type               = 'S'
                iv_msg_text               = 'Password Correct'
                iv_add_to_response_header = abap_true ).

            CLEAR ls_user.
            ls_user-message = 'Password Correct'.
            er_entity = ls_user.

          ELSE.
            obj_msg_con->add_message_text_only(
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Password Invalid'
                iv_add_to_response_header = abap_true ).

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ENDIF.

        ELSE.
          obj_msg_con->add_message_text_only(
            EXPORTING
              iv_msg_type               = 'E'
              iv_msg_text               = 'Encrypt ERROR'
              iv_add_to_response_header = abap_true ).

          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
            EXPORTING
              message_container = obj_msg_con.
        ENDIF.

      ELSE.
        obj_msg_con->add_message_text_only(
          EXPORTING
            iv_msg_type               = 'E'
            iv_msg_text               = 'User not available'
            iv_add_to_response_header = abap_true ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            message_container = obj_msg_con.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD wh_pgiset_create_entity.
    DATA: ls_wh_pgi TYPE zcl_zsff_weighing_post_mpc_ext=>ts_wh_pgi.

    DATA: obj_msg_con  TYPE REF TO /iwbep/if_message_container,
          cl_json_data TYPE REF TO zcl_trex_json_serializer,
          lv_json      TYPE string,
          lv_jsonret   TYPE string,
          lv_msgtyp    TYPE bapi_mtype,
          lv_message   TYPE bapi_msg.

    DATA: lv_sortf  TYPE resb-sortf.

    TRY.
        CALL METHOD io_data_provider->read_entry_data
          IMPORTING
            es_data = ls_wh_pgi.
      CATCH /iwbep/cx_mgw_tech_exception .
    ENDTRY.

    IF ls_wh_pgi IS NOT INITIAL.
      obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

      IF ls_wh_pgi-oprtyp IS INITIAL.
        lv_sortf = ' '.
      ELSE.
        lv_sortf = 'D'.
      ENDIF.

      SELECT SINGLE erfmg INTO @DATA(lv_erfmg)
        FROM resb WHERE aufnr = @ls_wh_pgi-aufnr
                    AND vornr = @ls_wh_pgi-vornr
                    AND sortf = @lv_sortf
                    AND kzear = @space.
      IF sy-subrc NE 0.
        obj_msg_con->add_message_text_only(
          EXPORTING
            iv_msg_type               = 'E'
            iv_msg_text               = 'Order does not exists'
            iv_add_to_response_header = abap_true ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            message_container = obj_msg_con.
      ENDIF.

      CREATE OBJECT cl_json_data
        EXPORTING
          data = ls_wh_pgi.
      cl_json_data->serialize( ).
      lv_json = cl_json_data->get_data( ).

      CALL FUNCTION 'ZSFF_WEIGHT'
        EXPORTING
          pi_process = 'WH_PGI'
          pi_data    = lv_json
        IMPORTING
          pe_data    = lv_jsonret
          pe_msgtyp  = lv_msgtyp
          pe_message = lv_message.

      obj_msg_con->add_message_text_only(
        EXPORTING
          iv_msg_type               = lv_msgtyp
          iv_msg_text               = lv_message
          iv_add_to_response_header = abap_true ).

      IF lv_msgtyp = 'E'.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            message_container = obj_msg_con.

      ELSE.
        zcl_json=>deserialize(
          EXPORTING
            json   = lv_jsonret
          CHANGING
            data   = ls_wh_pgi ).
        er_entity = ls_wh_pgi.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
