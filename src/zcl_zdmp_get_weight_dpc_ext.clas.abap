class ZCL_ZDMP_GET_WEIGHT_DPC_EXT definition
  public
  inheriting from ZCL_ZDMP_GET_WEIGHT_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZDMP_GET_WEIGHT_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entityset.
    DATA: lt_weight         TYPE STANDARD TABLE OF zcl_zdmp_get_weight_mpc_ext=>ts_weight,
          lt_equipment      TYPE STANDARD TABLE OF zcl_zdmp_get_weight_mpc_ext=>ts_equipment,
          lt_expired        TYPE STANDARD TABLE OF zcl_zdmp_get_weight_mpc_ext=>ts_expired,
          lt_hasiltimbang   TYPE STANDARD TABLE OF zcl_zdmp_get_weight_mpc_ext=>ts_hasiltimbang_a,
          ls_hasiltimbang   LIKE LINE OF lt_hasiltimbang,
          lt_hasiltimbang_2 TYPE STANDARD TABLE OF zcl_zdmp_get_weight_mpc_ext=>ts_hasiltimbang_b,
          ls_hasiltimbang_2 LIKE LINE OF lt_hasiltimbang_2.

    DATA: lt_adr12 TYPE TABLE OF adr12.

    DATA: ls_header TYPE alm_me_tob_header,
          lt_return TYPE STANDARD TABLE OF bapiret2.

    DATA : status        TYPE extcmdexex-status,
           exitcode	     TYPE extcmdexex-exitcode,
           commandname   TYPE sxpgcolist-name,
           add_param     TYPE sxpgcolist-parameters,
           iserveroutput TYPE STANDARD TABLE OF btcxpm.

    DATA: lv_uri_length TYPE adr12-uri_length,
          lv_uri_addr   TYPE adr12-uri_addr,
          lv_uri        TYPE ad_uri,
          lv_equnr      TYPE equi-equnr,
          lv_id         TYPE tdid VALUE 'INTV',
          lv_name       TYPE tdobname,
          lv_object     TYPE tdobject VALUE 'EQUI',
          lt_lines      TYPE TABLE OF tline.

    DATA: lv_aufnr  TYPE resb-aufnr,
          lv_vornr  TYPE resb-vornr,
          lv_twadah TYPE ztwadah,
          lv_count  TYPE zwadah,
          lv_cwadah TYPE char20.

    DATA: lr_aufnr  TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_vornr  TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_actwh  TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_tdname TYPE STANDARD TABLE OF /iwbep/s_cod_select_option.

    CASE iv_entity_set_name.
      WHEN 'EquipmentSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          LOOP AT it_filter_select_options INTO DATA(wa_filter).
            CASE wa_filter-property.
              WHEN 'Plant'.
                DATA(lv_swerk) = wa_filter-select_options[ 1 ]-low.
              WHEN OTHERS.
            ENDCASE.
          ENDLOOP.
        ENDIF.

        IF lv_swerk IS NOT INITIAL.
          SELECT * INTO TABLE @DATA(lt_equi)
            FROM equi_addr WHERE swerk = @lv_swerk
                             AND msgrp = 'DUMPING'.

          IF sy-subrc = 0.
            SELECT addrnumber uri_srch
              INTO CORRESPONDING FIELDS OF TABLE lt_adr12
              FROM adr12 FOR ALL ENTRIES IN lt_equi
              WHERE addrnumber = lt_equi-addrnumber.

            SELECT DISTINCT * INTO TABLE @DATA(lt_adrt)
              FROM adrt FOR ALL ENTRIES IN @lt_equi
              WHERE addrnumber = @lt_equi-addrnumber.

            LOOP AT lt_equi INTO DATA(ls_equi).
              SHIFT ls_equi-equnr LEFT DELETING LEADING '0'.
              READ TABLE lt_adr12 INTO DATA(ls_adr12)
                                  WITH KEY addrnumber = ls_equi-addrnumber.
              READ TABLE lt_adrt INTO DATA(ls_adrt)
                                 WITH KEY addrnumber = ls_equi-addrnumber
                                          comm_type  = 'URI'.
              READ TABLE lt_adrt INTO DATA(ls_adrt2)
                                 WITH KEY addrnumber = ls_equi-addrnumber
                                          comm_type  = 'PRT'.
              APPEND INITIAL LINE TO lt_equipment ASSIGNING FIELD-SYMBOL(<fs_equipment>).
              <fs_equipment>-equnr    = ls_equi-equnr.
              <fs_equipment>-eqktx    = ls_equi-eqktx.
              <fs_equipment>-swerk    = ls_equi-swerk.
              <fs_equipment>-uri_addr = ls_adr12-uri_srch.
*              <fs_equipment>-remark   = ls_adrt-remark.
              <fs_equipment>-ipprnt   = ls_adrt2-remark.

              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_equi-equnr
                IMPORTING
                  output = lv_equnr.

              lv_name = lv_equnr.
              CALL FUNCTION 'READ_TEXT'
                EXPORTING
                  id       = lv_id
                  language = sy-langu
                  name     = lv_name
                  object   = lv_object
                TABLES
                  lines    = lt_lines.

              IF sy-subrc = 0.
                LOOP AT lt_lines INTO DATA(ls_lines).
                  IF <fs_equipment>-remark IS INITIAL.
                    <fs_equipment>-remark = ls_lines-tdline.
                  ELSE.
                    IF ls_lines-tdformat = space OR ls_lines-tdformat = '='.
                      CONCATENATE <fs_equipment>-remark ls_lines-tdline
                        INTO <fs_equipment>-remark.
                    ENDIF.
                  ENDIF.
                ENDLOOP.
              ENDIF.
              CLEAR: ls_adrt,ls_adr12,ls_adrt2.
            ENDLOOP.

            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_equipment
              CHANGING
                cr_data = er_entityset.
          ENDIF.
        ENDIF.

      WHEN 'WeightSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          LOOP AT it_filter_select_options INTO wa_filter.
            CASE wa_filter-property.
              WHEN 'EquipmentNo'.
                DATA(lv_equip) = wa_filter-select_options[ 1 ]-low.
              WHEN OTHERS.
            ENDCASE.
          ENDLOOP.
        ENDIF.

        IF lv_equip IS NOT INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_equip
            IMPORTING
              output = lv_equnr.

          CALL FUNCTION 'ALM_ME_EQUIPMENT_GETDETAIL'
            EXPORTING
              i_equipment    = lv_equnr
            IMPORTING
              e_equi_header  = ls_header
            TABLES
              return         = lt_return
            EXCEPTIONS
              not_successful = 1
              OTHERS         = 2.

          IF sy-subrc = 0.
            READ TABLE lt_return WITH KEY type = 'E'
                                 TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
              sy-subrc = 4.
            ELSE.
              DATA(lv_eqfnr) = ls_header-eqfnr.
              SELECT SINGLE remark INTO @DATA(lv_remark)
                FROM adrt WHERE addrnumber = @ls_header-adrnr
                            AND comm_type  = 'URI'.
              SELECT SINGLE uri_length uri_addr
                INTO (lv_uri_length, lv_uri_addr)
                FROM adr12 WHERE addrnumber = ls_header-adrnr.

              commandname  = lv_remark.
              CONCATENATE lv_uri_addr 'all' lv_eqfnr INTO add_param SEPARATED BY space.

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
                LOOP AT iserveroutput INTO DATA(ls_iserveroutput).
                  APPEND INITIAL LINE TO lt_weight ASSIGNING FIELD-SYMBOL(<fs_weight>).
                  <fs_weight>-equnr = lv_equip.
                  <fs_weight>-bobot = ls_iserveroutput-message.
                ENDLOOP.

                CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
                  EXPORTING
                    is_data = lt_weight
                  CHANGING
                    cr_data = er_entityset.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN 'ExpiredSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          LOOP AT it_filter_select_options INTO wa_filter.
            CASE wa_filter-property.
              WHEN 'OrderNo'.
                READ TABLE wa_filter-select_options INTO DATA(wa_filter_so) INDEX 1.
                lv_aufnr = wa_filter_so-low.
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = lv_aufnr
                  IMPORTING
                    output = lv_aufnr.
              WHEN 'ActivityNo'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_vornr = wa_filter_so-low.
            ENDCASE.
          ENDLOOP.

          SELECT SINGLE * INTO @DATA(ls_resb)
            FROM resb WHERE aufnr = @lv_aufnr.
          IF sy-subrc = 0.
            SELECT SINGLE * INTO @DATA(ls_afvc)
              FROM afvc WHERE aufpl = @ls_resb-aufpl
                          AND vornr = @lv_vornr.
            IF sy-subrc = 0.
              SELECT SINGLE objid, arbpl INTO @DATA(ls_crhd)
                FROM crhd WHERE objid = @ls_afvc-arbid.

              SELECT SINGLE objid, ktext INTO @DATA(ls_crtx)
                FROM crtx WHERE objid = @ls_afvc-arbid.

              SELECT SINGLE * INTO @DATA(ls_plpo)
                FROM plpo WHERE plnty = @ls_afvc-plnty
                            AND plnnr = @ls_afvc-plnnr
                            AND plnkn = @ls_afvc-plnkn.
              IF sy-subrc = 0.
                CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
                  EXPORTING
                    input  = ls_plpo-use04
                  IMPORTING
                    output = ls_plpo-use04.

                APPEND INITIAL LINE TO lt_expired ASSIGNING FIELD-SYMBOL(<fs_expired>).
                <fs_expired>-aufnr = ls_resb-aufnr.
                <fs_expired>-vornr = ls_afvc-vornr.
                <fs_expired>-unit  = ls_plpo-use04.
                <fs_expired>-arbpl = ls_crhd-arbpl.
                <fs_expired>-ktext = ls_crtx-ktext.
                IF ls_plpo-usr04 IS INITIAL.
                  <fs_expired>-value = '0'.
                ELSE.
                  WRITE ls_plpo-usr04 TO <fs_expired>-value UNIT ls_plpo-use04.
                ENDIF.
                IF <fs_expired>-value CA ','.
                  SPLIT <fs_expired>-value AT ',' INTO: DATA(value1) DATA(value2).
                  <fs_expired>-value = value1.
                ENDIF.
                CONDENSE <fs_expired>-value.
              ENDIF.
            ENDIF.

            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_expired
              CHANGING
                cr_data = er_entityset.
          ENDIF.
        ENDIF.

      WHEN 'HasilTimbangSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          IF line_exists( it_filter_select_options[ property = 'OrderNo' ] ).
            lr_aufnr = it_filter_select_options[ property = 'OrderNo' ]-select_options.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lr_aufnr[ 1 ]-low
              IMPORTING
                output = lv_aufnr.
            lr_aufnr[ 1 ]-low = lv_aufnr.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'ActivityNo' ] ).
            lr_vornr  = it_filter_select_options[ property = 'ActivityNo' ]-select_options.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'ActivityWh' ] ).
            lr_actwh   = it_filter_select_options[ property = 'ActivityWh' ]-select_options.
          ENDIF.

          SELECT * INTO TABLE @DATA(lt_ztspppdt014)
            FROM ztspppdt014 WHERE aufnr IN @lr_aufnr
                               AND vornr IN @lr_vornr
                               AND actwh IN @lr_actwh
            ORDER BY PRIMARY KEY.

          IF sy-subrc = 0.
            LOOP AT lt_ztspppdt014 ASSIGNING FIELD-SYMBOL(<fs_ztspppdt014>).
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = <fs_ztspppdt014>-equnr
                IMPORTING
                  output = <fs_ztspppdt014>-equnr.
            ENDLOOP.

            SELECT equnr, eqktx INTO TABLE @DATA(lt_equi_addr)
              FROM equi_addr FOR ALL ENTRIES IN @lt_ztspppdt014
              WHERE equnr = @lt_ztspppdt014-equnr.

            SELECT objid, arbpl INTO TABLE @DATA(lt_crhd)
              FROM crhd FOR ALL ENTRIES IN @lt_ztspppdt014
              WHERE arbpl =  @lt_ztspppdt014-arbpl.

            IF sy-subrc = 0.
              SELECT objid, ktext INTO TABLE @DATA(lt_crtx)
                FROM crtx FOR ALL ENTRIES IN @lt_crhd
                WHERE objid = @lt_crhd-objid.
            ENDIF.

            SELECT DISTINCT aufnr, vornr, a~aufpl, a~aplzl, usr00
              INTO TABLE @DATA(lt_resb2)
              FROM resb AS a JOIN afvu AS b ON a~aufpl = b~aufpl AND
                                               a~aplzl = b~aplzl
              FOR ALL ENTRIES IN @lt_ztspppdt014
              WHERE aufnr = @lt_ztspppdt014-aufnr
                AND vornr = @lt_ztspppdt014-actwh.

            IF sy-subrc = 0.
              DATA(lv_aufpl) = lt_resb2[ 1 ]-aufpl.
              SELECT SINGLE * INTO ls_afvc
                FROM afvc WHERE aufpl = lv_aufpl
                            AND vornr IN lr_vornr.  "= lv_vornr.

*              SELECT SINGLE usr00 INTO @DATA(lv_usr00)
*                FROM afvu WHERE aufpl = @ls_resb2-aufpl
*                            AND aplzl = @ls_resb2-aplzl.
            ENDIF.

            LOOP AT lt_ztspppdt014 INTO DATA(ls_ztspppdt014).
              READ TABLE lt_resb2 INTO DATA(ls_resb2)
                                  WITH KEY aufnr = ls_ztspppdt014-aufnr
                                           vornr = ls_ztspppdt014-actwh.
              READ TABLE lt_equi_addr INTO DATA(ls_equi_addr)
                                      WITH KEY equnr = ls_ztspppdt014-equnr.
              READ TABLE lt_crhd INTO ls_crhd
                                 WITH KEY arbpl =  ls_ztspppdt014-arbpl.
              IF sy-subrc = 0.
                READ TABLE lt_crtx INTO ls_crtx
                                   WITH KEY objid = ls_crhd-objid.
              ENDIF.

              APPEND INITIAL LINE TO lt_hasiltimbang ASSIGNING FIELD-SYMBOL(<fs_hasiltimbang>).
              MOVE-CORRESPONDING ls_ztspppdt014 TO <fs_hasiltimbang>.
              <fs_hasiltimbang>-eqktx = ls_equi_addr-eqktx.
              <fs_hasiltimbang>-ktext = ls_crtx-ktext.
              <fs_hasiltimbang>-ltxa1 = ls_afvc-ltxa1.
              <fs_hasiltimbang>-usr00 = ls_resb2-usr00.

              IF ls_ztspppdt014-expdt IS INITIAL.
                CLEAR <fs_hasiltimbang>-expdt.
              ENDIF.
              IF ls_ztspppdt014-exptm IS INITIAL.
                CLEAR <fs_hasiltimbang>-exptm.
              ENDIF.

              IF <fs_hasiltimbang>-usr00 CA '123456789'.
                <fs_hasiltimbang>-lot = <fs_hasiltimbang>-usr00+sy-fdpos(1).
              ENDIF.
            ENDLOOP.

            lv_twadah = VALUE #( lt_hasiltimbang[ 1 ]-twadah OPTIONAL ).
            DO lv_twadah TIMES.
              ADD 1 TO lv_count.
              IF line_exists( lt_hasiltimbang[ wadah = lv_count ] ).
              ELSE.
                IF lv_cwadah IS INITIAL .
                  lv_cwadah = lv_count.
                ELSE.
                  lv_cwadah = |{ lv_cwadah }| & |;| & |{ lv_count }|.
                ENDIF.
              ENDIF.
            ENDDO.

            IF lv_cwadah IS NOT INITIAL.
              ls_hasiltimbang-cwadah = lv_cwadah.
              MODIFY lt_hasiltimbang FROM ls_hasiltimbang
                TRANSPORTING cwadah WHERE cwadah = space.
            ENDIF.
          ENDIF.

          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_hasiltimbang
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN 'HasilTimbang2Set'.
        IF it_filter_select_options[] IS NOT INITIAL.
          IF line_exists( it_filter_select_options[ property = 'OrderNo' ] ).
            lr_aufnr = it_filter_select_options[ property = 'OrderNo' ]-select_options.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lr_aufnr[ 1 ]-low
              IMPORTING
                output = lv_aufnr.
            lr_aufnr[ 1 ]-low = lv_aufnr.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'ActivityNo' ] ).
            lr_vornr  = it_filter_select_options[ property = 'ActivityNo' ]-select_options.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'ActivityWh' ] ).
            lr_actwh   = it_filter_select_options[ property = 'ActivityWh' ]-select_options.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'ObjectName' ] ).
            lr_tdname  = it_filter_select_options[ property = 'ObjectName' ]-select_options.
          ENDIF.

          SELECT * INTO TABLE @DATA(lt_ztspppdt015)
            FROM ztspppdt015 WHERE aufnr IN @lr_aufnr
                               AND vornr IN @lr_vornr
                               AND actwh IN @lr_actwh
                               AND tdname IN @lr_tdname
            ORDER BY PRIMARY KEY.

          IF sy-subrc = 0.
            LOOP AT lt_ztspppdt015 ASSIGNING FIELD-SYMBOL(<fs_ztspppdt015>).
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = <fs_ztspppdt015>-equnr
                IMPORTING
                  output = <fs_ztspppdt015>-equnr.
            ENDLOOP.

            SELECT equnr eqktx INTO TABLE lt_equi_addr
              FROM equi_addr FOR ALL ENTRIES IN lt_ztspppdt015
              WHERE equnr = lt_ztspppdt015-equnr.

            SELECT objid arbpl INTO TABLE lt_crhd
              FROM crhd FOR ALL ENTRIES IN lt_ztspppdt015
              WHERE arbpl = lt_ztspppdt015-arbpl.

            IF sy-subrc = 0.
              SELECT objid ktext INTO TABLE lt_crtx
                FROM crtx FOR ALL ENTRIES IN lt_crhd
                WHERE objid = lt_crhd-objid.
            ENDIF.

            SELECT DISTINCT aufnr vornr a~aufpl a~aplzl usr00
              INTO TABLE lt_resb2
              FROM resb AS a JOIN afvu AS b ON a~aufpl = b~aufpl AND
                                               a~aplzl = b~aplzl
              FOR ALL ENTRIES IN lt_ztspppdt015
              WHERE aufnr = lt_ztspppdt015-aufnr
                AND vornr = lt_ztspppdt015-actwh.

            IF sy-subrc = 0.
              lv_aufpl = lt_resb2[ 1 ]-aufpl.
              SELECT SINGLE * INTO ls_afvc
                FROM afvc WHERE aufpl = lv_aufpl
                            AND vornr IN lr_vornr.  "= lv_vornr.

*              SELECT SINGLE usr00 INTO @DATA(lv_usr00)
*                FROM afvu WHERE aufpl = @ls_resb2-aufpl
*                            AND aplzl = @ls_resb2-aplzl.
            ENDIF.

            LOOP AT lt_ztspppdt015 INTO DATA(ls_ztspppdt015).
              READ TABLE lt_resb2 INTO ls_resb2
                                  WITH KEY aufnr = ls_ztspppdt015-aufnr
                                           vornr = ls_ztspppdt015-actwh.
              READ TABLE lt_equi_addr INTO ls_equi_addr
                                      WITH KEY equnr = ls_ztspppdt015-equnr.
              READ TABLE lt_crhd INTO ls_crhd
                                 WITH KEY arbpl =  ls_ztspppdt015-arbpl.
              IF sy-subrc = 0.
                READ TABLE lt_crtx INTO ls_crtx
                                   WITH KEY objid = ls_crhd-objid.
              ENDIF.

              APPEND INITIAL LINE TO lt_hasiltimbang_2 ASSIGNING FIELD-SYMBOL(<fs_hasiltimbang_2>).
              MOVE-CORRESPONDING ls_ztspppdt015 TO <fs_hasiltimbang_2>.
              <fs_hasiltimbang_2>-eqktx = ls_equi_addr-eqktx.
              <fs_hasiltimbang_2>-ktext = ls_crtx-ktext.
              <fs_hasiltimbang_2>-ltxa1 = ls_afvc-ltxa1.
              <fs_hasiltimbang_2>-usr00 = ls_resb2-usr00.

              IF <fs_hasiltimbang_2>-usr00 CA '123456789'.
                <fs_hasiltimbang_2>-lot = <fs_hasiltimbang_2>-usr00+sy-fdpos(1).
              ENDIF.
            ENDLOOP.

            lv_twadah = VALUE #( lt_hasiltimbang_2[ 1 ]-twadah OPTIONAL ).
            DO lv_twadah TIMES.
              ADD 1 TO lv_count.
              IF line_exists( lt_hasiltimbang_2[ wadah = lv_count ] ).
              ELSE.
                IF lv_cwadah IS INITIAL .
                  lv_cwadah = lv_count.
                ELSE.
                  lv_cwadah = |{ lv_cwadah }| & |;| & |{ lv_count }|.
                ENDIF.
              ENDIF.
            ENDDO.

            IF lv_cwadah IS NOT INITIAL.
              ls_hasiltimbang_2-cwadah = lv_cwadah.
              MODIFY lt_hasiltimbang_2 FROM ls_hasiltimbang_2
                TRANSPORTING cwadah WHERE cwadah = space.
            ENDIF.
          ENDIF.

          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_hasiltimbang_2
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
