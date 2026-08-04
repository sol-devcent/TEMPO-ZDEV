class ZCL_ZDMP_POST_WEIGHT_DPC_EXT definition
  public
  inheriting from ZCL_ZDMP_POST_WEIGHT_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZDMP_POST_WEIGHT_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    DATA: ls_yield      TYPE zcl_zdmp_post_weight_mpc_ext=>ts_yield2,
          ls_yield_deep TYPE zcl_zdmp_post_weight_mpc_ext=>ts_yield_deep,
          lt_lines      TYPE STANDARD TABLE OF tline.

    DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
          lv_json      TYPE string.

    DATA: lv_msg      TYPE bapi_msg,
          obj_msg_con TYPE REF TO /iwbep/if_message_container.

    CASE iv_entity_set_name.
      WHEN 'YieldSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_yield_deep.
          CATCH /iwbep/cx_mgw_tech_exception .
        ENDTRY.

        IF ls_yield_deep IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          MOVE-CORRESPONDING ls_yield_deep TO ls_yield.
*          ls_yield-ltxa1 = VALUE #( ls_yield_deep-yieldtolinesnav[ 1 ]-tdline OPTIONAL ).

          IF ls_yield_deep-yieldtolinesnav[] IS NOT INITIAL.
            lt_lines = CORRESPONDING #( ls_yield_deep-yieldtolinesnav MAPPING tdline = tdline ).
*            lt_lines[ 1 ]-tdformat = '*'.

*            ls_yield-ltxa1 = REDUCE #( INIT text TYPE tdline FOR line IN lt_lines
*                                       NEXT text = text && line-tdline && line-tdformat ).
            LOOP AT lt_lines ASSIGNING FIELD-SYMBOL(<fs_lines>).
              <fs_lines>-tdformat = '*'.
              IF ls_yield-ltxa1 IS INITIAL.
                ls_yield-ltxa1 = <fs_lines>-tdline.
              ELSE.
                CONCATENATE ls_yield-ltxa1 <fs_lines>-tdline
                  INTO ls_yield-ltxa1 SEPARATED BY space.
              ENDIF.
            ENDLOOP.
          ENDIF.

* Check UoM
          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
            EXPORTING
              input          = ls_yield-meins
            IMPORTING
              output         = ls_yield-meins
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Invalid UoM'
                iv_add_to_response_header = abap_true.
            EXIT.
          ENDIF.

* Check data double
          SELECT SINGLE aufpl, aplzl, stats, vornr, actwh, aufnr
            INTO @DATA(ls_ztspppdt012)
            FROM ztspppdt012 WHERE aufpl = @ls_yield-aufpl
                               AND aplzl = @ls_yield-aplzl
                               AND stats = @ls_yield-stats
                               AND vornr = @ls_yield-vornr
                               AND actwh = @space.
          IF sy-subrc = 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Confirmation already done'
                iv_add_to_response_header = abap_true.
            EXIT.
          ENDIF.

* Posting COR6N & insert ZTPPPDT012
          CREATE OBJECT cl_json_data
            EXPORTING
              data = ls_yield.
          cl_json_data->serialize( ).
          lv_json = cl_json_data->get_data( ).

          CALL FUNCTION 'ZDMPFM001'
            EXPORTING
              pi_process = 'POST_COR6N'
              pi_data    = lv_json
            IMPORTING
              pe_message = lv_msg
            TABLES
              lines      = lt_lines.

          IF sy-subrc = 0.
            IF lv_msg(5) = 'ERROR' .
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = lv_msg      "'Posting ERROR'
                  iv_add_to_response_header = abap_true.

            ELSE.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'S'
                  iv_msg_text               = lv_msg
                  iv_add_to_response_header = abap_true.

              CALL METHOD me->copy_data_to_ref
                EXPORTING
                  is_data = ls_yield
                CHANGING
                  cr_data = er_deep_entity.
            ENDIF.
          ELSE.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Posting ERROR'
                iv_add_to_response_header = abap_true.
            EXIT.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_entity.
    DATA: ls_weighing    TYPE zcl_zdmp_post_weight_mpc_ext=>ts_weighing,
          ls_yield       TYPE zcl_zdmp_post_weight_mpc_ext=>ts_yield,
          lt_ztspppdt014 TYPE TABLE OF ztspppdt014,
          lt_ztspppdt015 TYPE TABLE OF ztspppdt015.

    DATA: lv_second  TYPE int4.

    DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
          lv_json      TYPE string.

    DATA: lv_msg      TYPE bapi_msg,
          obj_msg_con TYPE REF TO /iwbep/if_message_container.

    CASE iv_entity_set_name.
      WHEN 'WeighingSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_weighing.
          CATCH /iwbep/cx_mgw_tech_exception .
        ENDTRY.

        IF ls_weighing IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          IF ls_weighing-actwh IS INITIAL.
            CLEAR lv_msg.
            lv_msg = | Mixing operation | & |{ ls_weighing-vornr }| & | belum di Complete|.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = lv_msg      "'Activity Wh is Initial'
                iv_add_to_response_header = abap_true.
            EXIT.
          ENDIF.

          IF ls_weighing-bruto LE 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Bruto Quantity is Initial'
                iv_add_to_response_header = abap_true.
            EXIT.
          ENDIF.

          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
            EXPORTING
              input          = ls_weighing-meins
            IMPORTING
              output         = ls_weighing-meins
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Unit Weighing Invalid'
                iv_add_to_response_header = abap_true.
            EXIT.
          ENDIF.

          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
            EXPORTING
              input          = ls_weighing-moime
            IMPORTING
              output         = ls_weighing-moime
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Unit Moisture Invalid'
                iv_add_to_response_header = abap_true.
            EXIT.
          ENDIF.

          IF ls_weighing-lotnr IS NOT INITIAL.
            SELECT SINGLE a~aufpl, a~aplzl, a~vornr, a~actwh, a~aufnr,
                          b~phseq, b~steus, ltxa1
              INTO @DATA(lw_ztspppdt012)
              FROM ztspppdt012 AS a JOIN afvc AS b ON a~aufpl = b~aufpl AND
                                                      a~aplzl = b~aplzl
              WHERE a~aufnr = @ls_weighing-aufnr
                AND a~vornr = @ls_weighing-vornr
                AND b~steus = 'ZP01'.
            IF sy-subrc = 0.
              lw_ztspppdt012-phseq(1) = 'W'.
              SELECT aufpl, aplzl, vornr, rueck, phseq, steus, ltxa1, arbid
                INTO TABLE @DATA(lt_afvc)
                FROM afvc WHERE aufpl = @lw_ztspppdt012-aufpl
                            AND phseq = @lw_ztspppdt012-phseq
                            AND steus = 'ZP01'.
              IF sy-subrc = 0.
                LOOP AT lt_afvc INTO DATA(lw_afvc).
                  IF lw_afvc-ltxa1 CA '123456789'.
                    IF lw_afvc-ltxa1+sy-fdpos(1) = ls_weighing-lotnr.
                      ls_weighing-actwh = lw_afvc-vornr.
                      EXIT.
                    ENDIF.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDIF.

          IF ls_weighing-tdname IS INITIAL.
            APPEND INITIAL LINE TO lt_ztspppdt014 ASSIGNING FIELD-SYMBOL(<lt_ztspppdt014>).
            MOVE-CORRESPONDING ls_weighing TO <lt_ztspppdt014>.

            "Check table
            SELECT SINGLE aufnr, vornr, actwh, wadah INTO @DATA(ls_ztspppdt014_tmp)
              FROM ztspppdt014 WHERE aufnr = @<lt_ztspppdt014>-aufnr
                                 AND vornr = @<lt_ztspppdt014>-vornr
                                 AND actwh = @<lt_ztspppdt014>-actwh
                                 AND wadah = @<lt_ztspppdt014>-wadah.

            IF sy-subrc = 0.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Duplicated keys in ztspppdt014'
                  iv_add_to_response_header = abap_true.
            ELSE.
              TRY.
                  INSERT ztspppdt014 FROM TABLE lt_ztspppdt014.
                CATCH cx_sy_open_sql_db.

              ENDTRY.

              IF sy-subrc = 0.
                CALL METHOD obj_msg_con->add_message_text_only
                  EXPORTING
                    iv_msg_type               = 'S'
                    iv_msg_text               = 'Insert Successful'
                    iv_add_to_response_header = abap_true.
              ELSE.
                CALL METHOD obj_msg_con->add_message_text_only
                  EXPORTING
                    iv_msg_type               = 'E'
                    iv_msg_text               = 'Insert Failed'
                    iv_add_to_response_header = abap_true.
              ENDIF.
            ENDIF.

          ELSE.
            APPEND INITIAL LINE TO lt_ztspppdt015 ASSIGNING FIELD-SYMBOL(<lt_ztspppdt015>).
            MOVE-CORRESPONDING ls_weighing TO <lt_ztspppdt015>.


            "Check table
            SELECT SINGLE aufnr, vornr, actwh, wadah, tdname INTO @DATA(ls_ztspppdt015_tmp)
              FROM ztspppdt015 WHERE aufnr = @<lt_ztspppdt015>-aufnr
                                 AND vornr = @<lt_ztspppdt015>-vornr
                                 AND actwh = @<lt_ztspppdt015>-actwh
                                 AND wadah = @<lt_ztspppdt015>-wadah
                                 AND tdname = @<lt_ztspppdt015>-tdname.

            IF sy-subrc = 0.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Duplicated keys in ztspppdt015'
                  iv_add_to_response_header = abap_true.
            ELSE.
              TRY.
                  INSERT ztspppdt015 FROM TABLE lt_ztspppdt015.
                CATCH cx_sy_open_sql_db.

              ENDTRY.

              IF sy-subrc = 0.
                CALL METHOD obj_msg_con->add_message_text_only
                  EXPORTING
                    iv_msg_type               = 'S'
                    iv_msg_text               = 'Insert Successful'
                    iv_add_to_response_header = abap_true.
              ELSE.
                CALL METHOD obj_msg_con->add_message_text_only
                  EXPORTING
                    iv_msg_type               = 'E'
                    iv_msg_text               = 'Insert Failed'
                    iv_add_to_response_header = abap_true.
              ENDIF.
            ENDIF.
          ENDIF.

*          CLEAR ls_weighing.
          TRY.
              CALL METHOD me->copy_data_to_ref
                EXPORTING
                  is_data = ls_weighing
                CHANGING
                  cr_data = er_entity.
            CATCH cx_root.
          ENDTRY.
        ENDIF.

      WHEN 'YieldSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_yield.
          CATCH /iwbep/cx_mgw_tech_exception .
        ENDTRY.

        IF ls_yield IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
            EXPORTING
              input          = ls_yield-meins
            IMPORTING
              output         = ls_yield-meins
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Invalid UoM'
                iv_add_to_response_header = abap_true.
            EXIT.
          ENDIF.

* Check data double
          SELECT SINGLE aufpl, aplzl, stats, vornr, actwh, aufnr
            INTO @DATA(ls_ztspppdt012)
            FROM ztspppdt012 WHERE aufpl = @ls_yield-aufpl
                               AND aplzl = @ls_yield-aplzl
                               AND stats = @ls_yield-stats
                               AND vornr = @ls_yield-vornr
                               AND actwh = @space.
          IF sy-subrc = 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Confirmation already done'
                iv_add_to_response_header = abap_true.
            EXIT.
          ENDIF.

* Get Machine Hour
*          CREATE OBJECT cl_json_data
*            EXPORTING
*              data = ls_yield.
*          cl_json_data->serialize( ).
*          lv_json = cl_json_data->get_data( ).
*
*          CALL FUNCTION 'ZDMPFM001'
*            EXPORTING
*              pi_process = 'GET_HOUR'
*              pi_data    = lv_json
*            IMPORTING
*              pe_second  = lv_second.
*          IF sy-subrc = 0.
*            ls_yield-mhour = ls_yield-lhour = lv_second / 3600.
*          ELSE.
*            CALL METHOD obj_msg_con->add_message_text_only
*              EXPORTING
*                iv_msg_type               = 'E'
*                iv_msg_text               = 'Get Hour Error'
*                iv_add_to_response_header = abap_true.
*            EXIT.
*          ENDIF.

* Posting COR6N & insert ZTPPPDT012
          CREATE OBJECT cl_json_data
            EXPORTING
              data = ls_yield.
          cl_json_data->serialize( ).
          lv_json = cl_json_data->get_data( ).

          CALL FUNCTION 'ZDMPFM001'
            EXPORTING
              pi_process = 'POST_COR6N'
              pi_data    = lv_json
            IMPORTING
              pe_message = lv_msg.

          IF sy-subrc = 0.
            IF lv_msg(5) = 'ERROR' .
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = lv_msg      "'Posting ERROR'
                  iv_add_to_response_header = abap_true.

            ELSE.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'S'
                  iv_msg_text               = lv_msg
                  iv_add_to_response_header = abap_true.

              CALL METHOD me->copy_data_to_ref
                EXPORTING
                  is_data = ls_yield
                CHANGING
                  cr_data = er_entity.
            ENDIF.
          ELSE.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Posting ERROR'
                iv_add_to_response_header = abap_true.
            EXIT.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entityset.
    DATA: lt_yield TYPE TABLE OF zcl_zdmp_post_weight_mpc_ext=>ts_yield,
          ls_yield LIKE LINE OF lt_yield.

    DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
          lv_json      TYPE string.

    DATA: lv_second  TYPE int4.

    CASE iv_entity_set_name.
      WHEN 'YieldSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          LOOP AT it_filter_select_options INTO DATA(ls_filter).
            CASE ls_filter-property.
              WHEN 'RoutingNo'.
                DATA(lv_aufpl) = ls_filter-select_options[ 1 ]-low.
              WHEN 'InternalCntr'.
                DATA(lv_aplzl) = ls_filter-select_options[ 1 ]-low.
              WHEN 'ActivityNo'.
                DATA(lv_vornr) = ls_filter-select_options[ 1 ]-low.
            ENDCASE.
          ENDLOOP.

          SELECT SINGLE aufpl, aplzl, bmsch, vgw02, vgw03, vgw04
            INTO @DATA(ls_afvv)
            FROM afvv WHERE aufpl = @lv_aufpl
                        AND aplzl = @lv_aplzl.

          SELECT SINGLE aufnr INTO @DATA(lv_aufnr)
            FROM resb WHERE aufpl = @lv_aufpl.

          IF sy-subrc = 0.
            SELECT SINGLE phseq INTO @DATA(lv_phseq)
              FROM afvc WHERE aufpl = @lv_aufpl
                          AND vornr = @lv_vornr
                          AND steus = 'ZP01'.
            IF sy-subrc = 0.
              lv_phseq(1) = 'W'.
              SELECT aufpl, aplzl, vornr, phseq, steus, ltxa1
                INTO TABLE @DATA(lt_afvc)
                FROM afvc WHERE aufpl = @lv_aufpl
                            AND phseq = @lv_phseq
                            AND steus = 'ZP01'.
            ENDIF.

            SELECT  meins, SUM( netto ) AS total_netto
              INTO TABLE @DATA(lt_total)
              FROM ztspppdt014 WHERE aufnr = @lv_aufnr
                                 AND vornr = @lv_vornr
              GROUP BY meins.

            SELECT * INTO TABLE @DATA(lt_ztspppdt012)
              FROM ztspppdt012 FOR ALL ENTRIES IN @lt_afvc
              WHERE aufpl = @lv_aufpl
                AND aplzl = @lv_aplzl
                AND vornr = @lv_vornr
                AND actwh = @lt_afvc-vornr
                AND stats LIKE '003%'.
            IF sy-subrc = 0.
              SORT lt_ztspppdt012 BY dates times.
            ENDIF.

            SELECT aufnr, vornr, datef, timef
              INTO TABLE @DATA(lt_ztspppdt014)
              FROM ztspppdt014 WHERE aufnr = @lv_aufnr
                                 AND vornr = @lv_vornr.
            IF sy-subrc = 0.
              SORT lt_ztspppdt014 BY datef DESCENDING timef DESCENDING.
              DATA(lv_datef) = VALUE #( lt_ztspppdt014[ 1 ]-datef OPTIONAL ).
              DATA(lv_timef) = VALUE #( lt_ztspppdt014[ 1 ]-timef OPTIONAL ).
            ENDIF.

            "Calcuation Machine & Labor Hour
            ls_yield = VALUE #( aufpl      = lv_aufpl
                                aplzl      = lv_aplzl
                                aufnr      = lv_aufnr
                                vornr      = lv_vornr
                                yield      = lt_total[ 1 ]-total_netto
                                meins      = lt_total[ 1 ]-meins
                                dates_opr  = lt_ztspppdt012[ 1 ]-dates
                                times_opr  = lt_ztspppdt012[ 1 ]-times ).

            CREATE OBJECT cl_json_data
              EXPORTING
                data = ls_yield.

            cl_json_data->serialize( ).
            lv_json = cl_json_data->get_data( ).

            CALL FUNCTION 'ZDMPFM001'
              EXPORTING
                pi_process = 'GET_HOUR'
                pi_data    = lv_json
              IMPORTING
                pe_second  = lv_second.
            IF sy-subrc = 0.
              ls_yield-mhour = ls_yield-lhour = lv_second / 3600.
            ENDIF.

            APPEND INITIAL LINE TO lt_yield ASSIGNING FIELD-SYMBOL(<fs_yield>).
            <fs_yield>-aufpl      = lv_aufpl.
            <fs_yield>-aplzl      = lv_aplzl.
            <fs_yield>-aufnr      = lv_aufnr.
            <fs_yield>-vornr      = lv_vornr.
            <fs_yield>-yield      = lt_total[ 1 ]-total_netto.
            <fs_yield>-meins      = lt_total[ 1 ]-meins.
            <fs_yield>-dates_opr  = lt_ztspppdt012[ 1 ]-dates.
            <fs_yield>-times_opr  = lt_ztspppdt012[ 1 ]-times.
            <fs_yield>-mhour      = ls_yield-mhour.
            <fs_yield>-lhour      = ls_yield-lhour.
            <fs_yield>-labor      = ls_afvv-vgw04.
            <fs_yield>-bmsch      = ls_afvv-bmsch.
            <fs_yield>-vgw02      = ls_afvv-vgw02.
            <fs_yield>-vgw03      = ls_afvv-vgw02 * ls_afvv-vgw04.
            <fs_yield>-vgw04      = ls_afvv-vgw04.
            <fs_yield>-datestop   = lv_datef.
            <fs_yield>-timestop   = lv_timef.

            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_yield
              CHANGING
                cr_data = er_entityset.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
