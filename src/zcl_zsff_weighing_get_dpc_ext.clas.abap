class ZCL_ZSFF_WEIGHING_GET_DPC_EXT definition
  public
  inheriting from ZCL_ZSFF_WEIGHING_GET_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZSFF_WEIGHING_GET_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entityset.
    DATA: lt_storloc      TYPE TABLE OF zcl_zsff_weighing_get_mpc_ext=>ts_storloc,
          lt_sisastock    TYPE TABLE OF zcl_zsff_weighing_get_mpc_ext=>ts_sisastock,
          lt_material     TYPE TABLE OF zcl_zsff_weighing_get_mpc_ext=>ts_material,
          lt_plant        TYPE TABLE OF zcl_zsff_weighing_get_mpc_ext=>ts_plant,
          lt_user         TYPE TABLE OF zcl_zsff_weighing_get_mpc_ext=>ts_user,
          lt_order        TYPE TABLE OF zcl_zsff_weighing_get_mpc_ext=>ts_order,
          lt_labelstaging TYPE TABLE OF zcl_zsff_weighing_get_mpc_ext=>ts_labelstaging,
          lt_equipment    TYPE TABLE OF zcl_zsff_weighing_get_mpc_ext=>ts_equipment2.

    DATA: obj_msg_con TYPE REF TO /iwbep/if_message_container,
          lv_msg      TYPE bapi_msg.

    DATA: lr_werks   TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_lgort   TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_nrp     TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_title   TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_strdate TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_plnbez  TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_order   TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_qrcode  TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_rmscan  TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_equnr   TYPE STANDARD TABLE OF /iwbep/s_cod_select_option.

    DATA: lv_equnr  TYPE equi-equnr,
          lv_aufnr  TYPE aufnr,
          lv_matnr  TYPE matnr,
          lv_charg  TYPE charg_d,
          lv_qrcode TYPE char100,
          lv_id     TYPE tdid VALUE 'INTV',
          lv_name   TYPE tdobname,
          lv_object TYPE tdobject VALUE 'EQUI',
          lt_lines  TYPE TABLE OF tline.

    DATA: defaults  TYPE bapidefaul,
          parameter	TYPE STANDARD TABLE OF bapiparam,
          return    TYPE STANDARD TABLE OF bapiret2.

    CASE iv_entity_set_name.
      WHEN 'StorLocSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          IF line_exists( it_filter_select_options[ property = 'PlantNo' ] ).
            lr_werks = it_filter_select_options[ property = 'PlantNo' ]-select_options.

            SELECT werks lgort lgobe INTO TABLE lt_storloc
              FROM t001l WHERE werks IN lr_werks
                           AND lgort LIKE '2%'.

            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_storloc
              CHANGING
                cr_data = er_entityset.
          ENDIF.
        ENDIF.

      WHEN 'MaterialSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          IF line_exists( it_filter_select_options[ property = 'PlantNo' ] ).
            lr_werks = it_filter_select_options[ property = 'PlantNo' ]-select_options.

            SELECT a~werks a~matnr b~maktx a~fevor INTO TABLE lt_material
              FROM marc AS a INNER JOIN makt AS b ON b~matnr = a~matnr AND
                                                     b~spras = sy-langu
                             INNER JOIN mara AS c ON c~matnr = a~matnr AND
                                                     c~mtart IN ('ZPHA','ZCGB','ZSFG')
              WHERE werks IN lr_werks
                AND a~lvorm = space.

            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_material
              CHANGING
                cr_data = er_entityset.
          ENDIF.
        ENDIF.

      WHEN 'PlantSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          IF line_exists( it_filter_select_options[ property = 'PlantNo' ] ).
            lr_werks = it_filter_select_options[ property = 'PlantNo' ]-select_options.

            SELECT werks name1 INTO TABLE lt_plant
              FROM t001w WHERE werks IN lr_werks.

            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_plant
              CHANGING
                cr_data = er_entityset.
          ENDIF.
        ENDIF.

      WHEN 'UserSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          IF line_exists( it_filter_select_options[ property = 'Nrp' ] ).
            lr_nrp = it_filter_select_options[ property = 'Nrp' ]-select_options.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'Title' ] ).
            lr_title = it_filter_select_options[ property = 'Title' ]-select_options.
          ENDIF.

          SELECT znrp ztitle werks INTO TABLE lt_user
            FROM zsffppdt001 WHERE znrp IN lr_nrp
                               AND ztitle IN lr_title.

          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_user
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN 'OrderSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          IF line_exists( it_filter_select_options[ property = 'StartDate' ] ).
            lr_strdate = it_filter_select_options[ property = 'StartDate' ]-select_options.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'Material' ] ).
            lr_plnbez  = it_filter_select_options[ property = 'Material' ]-select_options.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'Plant' ] ).
            lr_werks   = it_filter_select_options[ property = 'Plant' ]-select_options.
          ENDIF.

          SELECT SINGLE maktx INTO @DATA(lv_maktx)
            FROM makt WHERE matnr IN @lr_plnbez
                        AND spras = @sy-langu.

          "Get Order
          SELECT * INTO TABLE @DATA(lt_cdsv02)
            FROM zdmp_cdsv02
            WHERE strdate IN @lr_strdate
              AND plnbez  IN @lr_plnbez
              AND werks   IN @lr_werks.

          IF sy-subrc = 0.
            SELECT DISTINCT * INTO TABLE @DATA(lt_resb)
              FROM resb FOR ALL ENTRIES IN @lt_cdsv02
              WHERE aufnr = @lt_cdsv02-aufnr.

            IF sy-subrc = 0.
              SORT lt_resb BY rsnum rspos.
              DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING rsnum.
            ENDIF.

            LOOP AT lt_cdsv02 INTO DATA(wa_cdsv02).
              APPEND INITIAL LINE TO lt_order ASSIGNING FIELD-SYMBOL(<fs_order>).
              MOVE-CORRESPONDING wa_cdsv02 TO <fs_order>.
              <fs_order>-aufnr = |{ <fs_order>-aufnr ALPHA = OUT }|.
              <fs_order>-maktx = lv_maktx.
              <fs_order>-aufpl = VALUE #( lt_resb[ aufnr = wa_cdsv02-aufnr ]-aufpl OPTIONAL ).
              <fs_order>-aplzl = VALUE #( lt_resb[ aufnr = wa_cdsv02-aufnr ]-aplzl OPTIONAL ).
            ENDLOOP.

            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_order
              CHANGING
                cr_data = er_entityset.
          ENDIF.
        ENDIF.

      WHEN 'EquipmentSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          IF line_exists( it_filter_select_options[ property = 'Plant' ] ).
            lr_werks = it_filter_select_options[ property = 'Plant' ]-select_options.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'EquipmentNo' ] ).
            lr_equnr = it_filter_select_options[ property = 'EquipmentNo' ]-select_options.
          ENDIF.

          ASSIGN lr_equnr[ 1 ]-low TO FIELD-SYMBOL(<fs_low>).
          lv_equnr = <fs_low>.
          lv_equnr = |{ lv_equnr ALPHA = IN }|.
          <fs_low> = lv_equnr.

          SELECT * INTO TABLE @DATA(lt_equi)
            FROM equi_addr WHERE equnr IN @lr_equnr
                             AND swerk IN @lr_werks
                             AND msgrp = 'WEIGHING'.

          IF sy-subrc NE 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Equipment Number Invalid'
                iv_add_to_response_header = abap_true.

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ELSE.
            SELECT SINGLE tidnr INTO @DATA(lv_tidnr)
              FROM equz WHERE equnr IN @lr_equnr
                          AND tidnr EQ 'BRUTO'.
            IF sy-subrc = 0.
              lv_tidnr = 'X'.
            ELSE.
              CLEAR lv_tidnr.
            ENDIF.

            SELECT addrnumber, uri_srch INTO TABLE @DATA(lt_adr12)
              FROM adr12 FOR ALL ENTRIES IN @lt_equi
              WHERE addrnumber = @lt_equi-addrnumber.

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
              <fs_equipment>-bruto    = lv_tidnr.

              lv_equnr = |{ ls_equi-equnr ALPHA = IN }|.
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
                    WRITE ls_lines-tdline TO <fs_equipment>-remark.
                    <fs_equipment>-remark = ls_lines-tdline.
                  ELSE.
                    IF ls_lines-tdformat = space OR ls_lines-tdformat = '='.
                      CONCATENATE <fs_equipment>-remark ls_lines-tdline
                        INTO <fs_equipment>-remark.
                    ENDIF.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDLOOP.

            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_equipment
              CHANGING
                cr_data = er_entityset.
          ENDIF.
        ENDIF.

      WHEN 'LabelStagingSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          IF line_exists( it_filter_select_options[ property = 'OrderNo' ] ).
            lr_order = it_filter_select_options[ property = 'OrderNo' ]-select_options.
            lv_aufnr = VALUE #( lr_order[ 1 ]-low ).
            SHIFT lv_aufnr LEFT DELETING LEADING '0'.
            DATA(lv_aufnr_ori) = |{ lv_aufnr ALPHA = IN }|.
          ENDIF.

*          SELECT DISTINCT aufnr, vornr, werks, aufpl, aplzl
          SELECT DISTINCT a~aufnr, a~vornr, a~werks, a~aufpl, a~aplzl,
                          b~usr01, c~ltxa1, d~plnbez, d~strdate, d~charg,
                          e~maktx,
                          CASE
                            WHEN b~usr01 NE ' ' THEN 'D'
                            ELSE ' '
                          END AS decoct
            INTO TABLE @DATA(lt_label)
            FROM resb AS a JOIN zdmp_cdsv02 AS d ON d~aufnr = a~aufnr AND
                                                    d~werks = a~werks
                           JOIN makt AS e ON e~matnr = d~plnbez AND
                                             e~spras = @sy-langu
                           JOIN afvu AS b ON b~aufpl = a~aufpl AND
                                             b~aplzl = a~aplzl
                           JOIN afvc AS c ON c~aufpl = a~aufpl AND
                                             c~aplzl = a~aplzl AND
                                             c~phflg = 'X'     AND
                                             c~phseq LIKE 'W%' AND
                                             c~steus = 'ZP01'
            WHERE a~aufnr = @lv_aufnr OR a~aufnr = @lv_aufnr_ori
            ORDER BY a~aufnr, a~vornr.

          IF sy-subrc = 0.
            CALL FUNCTION 'BAPI_USER_GET_DETAIL'
              EXPORTING
                username  = sy-uname
              IMPORTING
                defaults  = defaults
              TABLES
                parameter = parameter
                return    = return.
            IF sy-subrc = 0.
              DATA(lv_ipno) = VALUE #( parameter[ parid = 'PRI' ]-parva OPTIONAL ).
            ENDIF.

            LOOP AT lt_label INTO DATA(ls_label).
              APPEND INITIAL LINE TO lt_labelstaging ASSIGNING FIELD-SYMBOL(<fs_labelstaging>).
              MOVE-CORRESPONDING ls_label TO <fs_labelstaging>.
              CONCATENATE ls_label-plnbez ls_label-aufnr ls_label-charg ls_label-vornr
                INTO <fs_labelstaging>-qrcode SEPARATED BY ';'.
              WRITE sy-datum TO <fs_labelstaging>-datum.
              <fs_labelstaging>-ipno = lv_ipno.

              IF ls_label-usr01 IS NOT INITIAL.
                APPEND INITIAL LINE TO lt_labelstaging ASSIGNING <fs_labelstaging>.
                MOVE-CORRESPONDING ls_label TO <fs_labelstaging>.
                <fs_labelstaging>-ltxa1 = ls_label-usr01.
                CONCATENATE ls_label-plnbez ls_label-aufnr ls_label-charg ls_label-vornr ls_label-decoct
                  INTO <fs_labelstaging>-qrcode SEPARATED BY ';'.
                WRITE sy-datum TO <fs_labelstaging>-datum.
              ENDIF.
            ENDLOOP.
          ENDIF.

          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_labelstaging
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN 'SisaStockSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          IF line_exists( it_filter_select_options[ property = 'PlantNo' ] ).
            lr_werks = it_filter_select_options[ property = 'PlantNo' ]-select_options.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'StorLocNo' ] ).
            lr_lgort = it_filter_select_options[ property = 'StorLocNo' ]-select_options.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'RMScan' ] ).
            lr_rmscan = it_filter_select_options[ property = 'RMScan' ]-select_options.
          ENDIF.

          DATA(lv_werks)  = VALUE #( lr_werks[ 1 ]-low OPTIONAL ).
          DATA(lv_lgort)  = VALUE #( lr_lgort[ 1 ]-low OPTIONAL ).
          DATA(lv_rmscan) = VALUE #( lr_rmscan[ 1 ]-low OPTIONAL ).
          SPLIT lv_rmscan AT ';' INTO: lv_matnr lv_charg.

          SELECT SINGLE a~matnr, a~werks, a~lgort, a~charg, a~clabs,
                        b~lgobe, c~meins, d~maktx
            INTO @DATA(ls_sisastock)
            FROM mchb AS a JOIN t001l AS b ON b~werks = a~werks AND
                                              b~lgort = a~lgort
                           JOIN mara AS c ON c~matnr = a~matnr
                           JOIN makt AS d ON d~matnr = a~matnr AND
                                             d~spras = @sy-langu
            WHERE a~matnr = @lv_matnr
              AND a~werks = @lv_werks
              AND a~lgort = @lv_lgort
              AND a~charg = @lv_charg.

            SELECT SUM( bdmng ) INTO @DATA(lv_bdmng)
              FROM resb WHERE matnr = @lv_matnr
                          AND werks = @lv_werks
                          AND charg = @lv_charg
                          AND lgort = @lv_lgort
                          AND kzear = @space
                          AND splkz = '2'
                          AND wempf IN ('T','W').

              ls_sisastock-clabs = ls_sisastock-clabs - lv_bdmng.

              APPEND INITIAL LINE TO lt_sisastock ASSIGNING FIELD-SYMBOL(<fs_sisastock>).
              <fs_sisastock>-werks = ls_sisastock-werks.
              <fs_sisastock>-lgort = ls_sisastock-lgort.
              <fs_sisastock>-lgobe = ls_sisastock-lgobe.
              <fs_sisastock>-rmscn = lv_rmscan.
              <fs_sisastock>-matnr = ls_sisastock-matnr.
              <fs_sisastock>-maktx = ls_sisastock-maktx.
              <fs_sisastock>-charg = ls_sisastock-charg.
              WRITE ls_sisastock-clabs TO <fs_sisastock>-clabs UNIT ls_sisastock-meins.
              CONDENSE <fs_sisastock>-clabs.
              <fs_sisastock>-meins = ls_sisastock-meins.

* Send API
              CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
                EXPORTING
                  is_data = lt_sisastock
                CHANGING
                  cr_data = er_entityset.
            ENDIF.

        ENDCASE.
      ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.
    DATA: lt_fp_materialscan      TYPE TABLE OF zcl_zsff_weighing_get_mpc_ext=>ts_fp_mat_scan,
          ls_fp_materialscan      LIKE LINE OF lt_fp_materialscan,
          ls_fp_material_scan_dtl TYPE zcl_zsff_weighing_get_mpc_ext=>ts_fp_material_scan_dtl.

    DATA: lt_wh_materialscan      TYPE TABLE OF zcl_zsff_weighing_get_mpc_ext=>ts_wh_mat_scan,
          ls_wh_materialscan      LIKE LINE OF lt_wh_materialscan,
          ls_wh_material_scan_dtl TYPE zcl_zsff_weighing_get_mpc_ext=>ts_wh_material_scan_dtl.

    DATA: lt_pgi_order     TYPE TABLE OF zcl_zsff_weighing_get_mpc_ext=>ts_pgi_order_scan,
          ls_pgi_order     LIKE LINE OF lt_pgi_order,
          ls_pgi_order_dtl TYPE zcl_zsff_weighing_get_mpc_ext=>ts_pgi_order_dtl.

    DATA: lt_pgi_matflag     TYPE TABLE OF zcl_zsff_weighing_get_mpc_ext=>ts_pgi_matflag,
          ls_pgi_matflag     LIKE LINE OF lt_pgi_matflag,
          ls_pgi_matflag_dtl TYPE zcl_zsff_weighing_get_mpc_ext=>ts_pgi_materialflag_dtl.

    DATA: lt_reprint     TYPE TABLE OF zcl_zsff_weighing_get_mpc_ext=>ts_reprint_out,
          ls_reprint     LIKE LINE OF lt_reprint,
          ls_reprint_dtl TYPE zcl_zsff_weighing_get_mpc_ext=>ts_reprint_dtl.

    DATA: lt_fp_reprint     TYPE TABLE OF zcl_zsff_weighing_get_mpc_ext=>ts_fp_reprint_out,
          ls_fp_reprint     LIKE LINE OF lt_fp_reprint,
          ls_fp_reprint_dtl TYPE zcl_zsff_weighing_get_mpc_ext=>ts_fp_reprint_dtl.

    DATA: lt_wh_reprint     TYPE TABLE OF zcl_zsff_weighing_get_mpc_ext=>ts_wh_reprint_out,
          ls_wh_reprint     LIKE LINE OF lt_wh_reprint,
          ls_wh_reprint_dtl TYPE zcl_zsff_weighing_get_mpc_ext=>ts_wh_reprint_dtl,
          ls_wh_reprint_vnd TYPE zcl_zsff_weighing_get_mpc_ext=>ts_wh_reprint_vnd.

    DATA: lr_werks  TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_aufnr  TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_vornr  TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_posnr  TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_oprtyp TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_rmscan TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_equnr  TYPE STANDARD TABLE OF /iwbep/s_cod_select_option.

    DATA: lv_aufnr     TYPE aufnr,
          lv_aufnr_hdr TYPE aufnr,
          lv_werks     TYPE werks_d,
          lv_matnr     TYPE matnr,
          lv_equnr     TYPE equnr,
          lv_charg     TYPE charg_d,
          lv_packs     TYPE bdmng,
          lv_vfdat     TYPE vfdat,
          lv_stock     TYPE labst,
          lv_packt     TYPE labst,
          lv_meanval   TYPE qmean_val,
          lv_text      TYPE bapi2045l2-txt_oper,
          lv_inspoper  TYPE bapi2045l2-inspoper,
          lv_factor    TYPE bapi2045d2-mean_value,
          lv_factor2   TYPE bapi2045d2-mean_value,
          lv_sisa      TYPE bdmng,
          lv_clabs_o   TYPE bdmng,
          lv_ordqty_o  TYPE bdmng,
          lv_packs_o   TYPE bdmng,
          lv_bdmng_o   TYPE bdmng,
          lv_bdmng     TYPE bdmng,
          lv_bdmng1    TYPE p DECIMALS 3,
          lv_bdmng2    TYPE p DECIMALS 2,
          lv_bruto     TYPE erfmg,
          lv_erfmg     TYPE erfmg,
          lv_erfmgtot  TYPE erfmg,
          lv_date(10), lv_time(10),
          lt_cob       TYPE STANDARD TABLE OF clbatch.

    DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
          lv_json      TYPE string,
          lv_jsonret   TYPE string,
          lv_msgtyp    TYPE bapi_mtype,
          lv_message   TYPE bapi_msg.

    DATA: defaults  TYPE bapidefaul,
          parameter	TYPE STANDARD TABLE OF bapiparam,
          return    TYPE STANDARD TABLE OF bapiret2.

    DATA: obj_msg_con TYPE REF TO /iwbep/if_message_container,
          lv_msg      TYPE bapi_msg.

    CASE iv_entity_set_name.
      WHEN 'FP_Material_scanSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          IF line_exists( it_filter_select_options[ property = 'Plant' ] ).
            lr_werks = it_filter_select_options[ property = 'Plant' ]-select_options.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'OrderNo' ] ).
            lr_aufnr = it_filter_select_options[ property = 'OrderNo' ]-select_options.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'RMScan' ] ).
            lr_rmscan = it_filter_select_options[ property = 'RMScan' ]-select_options.
          ENDIF.

          lv_werks = VALUE #( lr_werks[ 1 ]-low OPTIONAL ).
          lv_aufnr = VALUE #( lr_aufnr[ 1 ]-low OPTIONAL ).
          DATA(lv_rmscan) = VALUE #( lr_rmscan[ 1 ]-low OPTIONAL ).

          lv_aufnr = |{ lv_aufnr ALPHA = IN }|.
          SPLIT lv_rmscan AT ';' INTO: lv_matnr lv_charg.

* Get RESB
          SELECT rsnum, rspos, rsart, xloek, kzear, aufnr, a~wempf, a~aufpl, a~vornr,
                 posnr, splkz, a~matnr, a~werks, a~lgort, a~charg, nomng, vmeng, bdmng,
                 erfmg, erfme, baugr, b~clabs, c~meins, c~mtart, d~maktx, e~ltxa1
            INTO TABLE @DATA(gt_fp_resb)
            FROM resb AS a JOIN mchb AS b ON b~matnr = a~matnr AND
                                             b~werks = a~werks AND
                                             b~lgort = a~lgort AND
                                             b~charg = @lv_charg
                           JOIN mara AS c ON c~matnr = a~matnr
                           JOIN makt AS d ON d~matnr = a~matnr AND
                                             d~spras = @sy-langu
                           JOIN afvc AS e ON e~aufpl = a~aufpl AND
                                             e~vornr = a~vornr
            WHERE a~matnr = @lv_matnr
              AND a~werks = @lv_werks
              AND aufnr = @lv_aufnr
              AND splkz NE '2'
              AND xloek = @space
              AND kzear = @space
            ORDER BY kzear, rsnum, rspos.

          IF sy-subrc NE 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'RM scan Invalid'
                iv_add_to_response_header = abap_true.

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ENDIF.

*Get PACKSIZE
          CALL FUNCTION 'VB_BATCH_GET_DETAIL'
            EXPORTING
              matnr              = lv_matnr
              charg              = lv_charg
              werks              = lv_werks
              get_classification = 'X'
            TABLES
              char_of_batch      = lt_cob
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
          IF sy-subrc NE 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Batch Invalid'
                iv_add_to_response_header = abap_true.

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ELSE.
            "PACKSIZE
            IF line_exists( lt_cob[ atnam = 'QTY_CONVERSION' ] ).
              DATA(lv_atwtb) = VALUE #( lt_cob[ atnam = 'QTY_CONVERSION' ]-atwtb ).
              TRANSLATE lv_atwtb USING '. '.
              TRANSLATE lv_atwtb USING ',.'.
              CONDENSE lv_atwtb NO-GAPS.
              lv_packs = lv_atwtb.
            ELSE.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Packsize does not exists'
                  iv_add_to_response_header = abap_true.

              RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                  message_container = obj_msg_con.
            ENDIF.

            "Expired Date
            IF line_exists( lt_cob[ atnam = 'LOBM_VFDAT' ] ).
              lv_atwtb = VALUE #( lt_cob[ atnam = 'LOBM_VFDAT' ]-atwtb ).
              lv_vfdat = |{ lv_atwtb+6(4) }| && |{ lv_atwtb+3(2) }| && |{ lv_atwtb(2) }|.

              IF lv_vfdat LT sy-datum.
                CALL METHOD obj_msg_con->add_message_text_only
                  EXPORTING
                    iv_msg_type               = 'E'
                    iv_msg_text               = 'Batch is expirate'
                    iv_add_to_response_header = abap_true.

                RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                  EXPORTING
                    message_container = obj_msg_con.
              ENDIF.
            ELSE.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Expirate date does not exists'
                  iv_add_to_response_header = abap_true.

              RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                  message_container = obj_msg_con.
            ENDIF.
          ENDIF.

          DATA(lv_lgort) = VALUE #( gt_fp_resb[ 1 ]-lgort OPTIONAL ).
          SELECT meins, SUM( bdmng ) AS quantity INTO TABLE @DATA(lt_totalqty)
            FROM resb WHERE matnr = @lv_matnr
                        AND werks = @lv_werks
                        AND lgort = @lv_lgort
                        AND charg = @lv_charg
                        AND xloek = @space
                        AND kzear = @space
            GROUP BY meins.

          DATA(lv_erfme) = VALUE #( gt_fp_resb[ 1 ]-erfme ).
          DATA(lv_meins) = VALUE #( gt_fp_resb[ 1 ]-meins ).
          DATA(lv_clabs) = VALUE #( gt_fp_resb[ 1 ]-clabs ).
          DATA(lv_ordqty) = REDUCE bdmng( INIT x TYPE bdmng FOR wa_total IN lt_totalqty
                                             NEXT x = x + wa_total-quantity ).

          "Conversion to order unit
          CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
            EXPORTING
              input                = lv_clabs
              matnr                = lv_matnr
              meinh                = lv_erfme
              meins                = lv_meins
            IMPORTING
              output               = lv_clabs_o
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

          CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
            EXPORTING
              input                = lv_ordqty
              matnr                = lv_matnr
              meinh                = lv_erfme
              meins                = lv_meins
            IMPORTING
              output               = lv_ordqty_o
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

          CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
            EXPORTING
              input                = lv_packs
              matnr                = lv_matnr
              meinh                = lv_erfme
              meins                = lv_meins
            IMPORTING
              output               = lv_packs_o
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

          lv_clabs = lv_clabs - lv_ordqty.

          IF lv_clabs LT lv_packs.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Stock kurang dari packsize'
                iv_add_to_response_header = abap_true.

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ENDIF.

*Get MEAN VALUE
          CALL FUNCTION 'ZPP_GET_MEANVAL'
            EXPORTING
              pi_werks   = lv_werks
              pi_matnr   = lv_matnr
              pi_charg   = lv_charg
            IMPORTING
              pe_meanval = lv_meanval.

          DATA(wa_fp_resb) = VALUE #( gt_fp_resb[ 1 ] ).
          MOVE-CORRESPONDING wa_fp_resb TO ls_fp_materialscan.
          ls_fp_materialscan-rmscn = lv_rmscan.
          ls_fp_materialscan-charg = lv_charg.
          WRITE lv_packs TO ls_fp_materialscan-packs DECIMALS 0.
          CONDENSE ls_fp_materialscan-packs.

*Get COLLECT ITAB OUT
          LOOP AT gt_fp_resb INTO wa_fp_resb.
            IF wa_fp_resb-bdmng IS INITIAL AND
               wa_fp_resb-erfmg IS INITIAL AND
               wa_fp_resb-vmeng IS INITIAL.
              CONTINUE.
            ENDIF.

            IF wa_fp_resb-bdmng LT lv_packs.
              CONTINUE.
            ENDIF.

            CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
              EXPORTING
                input                = wa_fp_resb-bdmng
                matnr                = lv_matnr
                meinh                = lv_erfme
                meins                = lv_meins
              IMPORTING
                output               = lv_bdmng_o
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

            MOVE-CORRESPONDING wa_fp_resb TO ls_fp_material_scan_dtl.
            ls_fp_material_scan_dtl-meanv = lv_meanval.

            IF lv_clabs LT wa_fp_resb-bdmng.
              IF lv_stock IS INITIAL.
                lv_erfmg = lv_clabs DIV lv_packs.
              ELSE.
                lv_erfmg = lv_stock DIV lv_packs.
              ENDIF.
            ELSE.
              lv_erfmg = wa_fp_resb-bdmng DIV lv_packs.
            ENDIF.

            IF lv_stock IS NOT INITIAL AND lv_stock LT lv_packs.
              lv_erfmg = 0.
            ENDIF.

            ADD lv_erfmg TO lv_packt.
            DATA(lv_packs2) = lv_packs * lv_erfmg.

            IF lv_stock IS INITIAL.
              lv_stock = lv_clabs.
            ELSE.
              lv_stock = lv_stock - lv_packs2.
            ENDIF.

            lv_bdmng = wa_fp_resb-bdmng.

            WRITE: lv_bdmng TO ls_fp_material_scan_dtl-bdmng UNIT ls_fp_material_scan_dtl-meins,
                   lv_erfmg TO ls_fp_material_scan_dtl-erfmg DECIMALS 0,
                   lv_stock TO ls_fp_material_scan_dtl-clabs UNIT ls_fp_material_scan_dtl-meins.
            CONDENSE: ls_fp_material_scan_dtl-bdmng,ls_fp_material_scan_dtl-erfmg,
                      ls_fp_material_scan_dtl-clabs.

            APPEND ls_fp_material_scan_dtl TO ls_fp_materialscan-fp_materialscannav.
            CLEAR ls_fp_material_scan_dtl.

            lv_stock = lv_stock - lv_packs2.
          ENDLOOP.

          WRITE lv_packt TO ls_fp_materialscan-packt DECIMALS 0.
          CONDENSE ls_fp_materialscan-packt.

          IF ls_fp_materialscan-fp_materialscannav[] IS INITIAL.
            lv_msg = |Fullpack for material| & | | & |{ lv_matnr }| & | | &
                     |Batch| & | | & |{ lv_charg }| & | | &
                     |Already Process|.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = lv_msg
                iv_add_to_response_header = abap_true.

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ELSE.
            APPEND ls_fp_materialscan TO lt_fp_materialscan.
          ENDIF.

* Send API
          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_fp_materialscan
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN 'WH_Material_scanSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          IF line_exists( it_filter_select_options[ property = 'Plant' ] ).
            lr_werks = it_filter_select_options[ property = 'Plant' ]-select_options.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'OrderNo' ] ).
            lr_aufnr = it_filter_select_options[ property = 'OrderNo' ]-select_options.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'RMScan' ] ).
            lr_rmscan = it_filter_select_options[ property = 'RMScan' ]-select_options.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'EquipmentNo' ] ).
            lr_equnr = it_filter_select_options[ property = 'EquipmentNo' ]-select_options.
          ENDIF.

          lv_werks = VALUE #( lr_werks[ 1 ]-low OPTIONAL ).
          DATA(lv_equnr_ori) = VALUE #( lr_equnr[ 1 ]-low OPTIONAL ).
          lv_equnr = |{ lv_equnr_ori ALPHA = IN }|.
          DATA(lv_aufnr_ori) = VALUE #( lr_aufnr[ 1 ]-low OPTIONAL ).
          lv_aufnr = |{ lv_aufnr_ori ALPHA = IN }|.
          lv_rmscan = VALUE #( lr_rmscan[ 1 ]-low OPTIONAL ).
          SPLIT lv_rmscan AT ';' INTO: lv_matnr lv_charg.

* Cek ZTNPPPDT002
          SELECT SINGLE * INTO @DATA(ls_ztnpppdt002)
            FROM ztnpppdt002 WHERE ( equnr = @lv_equnr OR equnr = @lv_equnr_ori )
                               AND matnr = @lv_matnr.
          IF sy-subrc NE 0.
            lv_equnr = |{ lv_equnr ALPHA = OUT }|.
            lv_msg = |Material| & | | & |{ lv_matnr }| & | | &
                     |tidak dapat ditimbang di| & | | & |{ lv_equnr }|.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = lv_msg
                iv_add_to_response_header = abap_true.

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ENDIF.

* Get RESB
          SELECT rsnum, rspos, rsart, xloek, kzear, aufnr, a~wempf, a~aufpl, a~vornr,
                 posnr, splkz, a~matnr, a~werks, a~lgort, a~charg, nomng, vmeng, bdmng,
                 enmng, erfmg, erfme, baugr, b~clabs, c~meins, c~mtart, d~maktx, e~ltxa1
            INTO TABLE @DATA(gt_wh_resb)
            FROM resb AS a JOIN mchb AS b ON b~matnr = a~matnr AND
                                             b~werks = a~werks AND
                                             b~lgort = a~lgort AND
                                             b~charg = @lv_charg
                           JOIN mara AS c ON c~matnr = a~matnr
                           JOIN makt AS d ON d~matnr = a~matnr AND
                                             d~spras = @sy-langu
                           JOIN afvc AS e ON e~aufpl = a~aufpl AND
                                             e~vornr = a~vornr
            WHERE a~matnr = @lv_matnr
              AND a~werks = @lv_werks
              AND aufnr = @lv_aufnr
              AND splkz NE '2'
              AND xloek = @space
              AND kzear = @space
            ORDER BY kzear, rsnum, rspos.

          "RM scan Invalid
          IF sy-subrc NE 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'RM scan Invalid'
                iv_add_to_response_header = abap_true.

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ENDIF.

          DELETE gt_wh_resb WHERE bdmng IS INITIAL.
          SORT gt_wh_resb BY vornr posnr.

          IF gt_wh_resb[] IS INITIAL.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Order does not exists'
                iv_add_to_response_header = abap_true.

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ENDIF.

          DATA(wa_wh_resb) = VALUE #( gt_wh_resb[ 1 ] ).

          SELECT SUM( bdmng ) AS sum_bdmng, SUM( erfmg ) AS sum_erfmg
            INTO @DATA(ls_sum)
            FROM resb WHERE matnr = @lv_matnr
                        AND werks = @lv_werks
                        AND charg = @lv_charg
                        AND lgort = @wa_wh_resb-lgort
                        AND kzear = @space
                        AND splkz = '2'
                        AND wempf IN ('T','W').

          wa_wh_resb-clabs = wa_wh_resb-clabs - ls_sum-sum_bdmng.

          "Stock not available
*          IF wa_wh_resb-clabs LT wa_wh_resb-bdmng.
*            CALL METHOD obj_msg_con->add_message_text_only
*              EXPORTING
*                iv_msg_type               = 'E'
*                iv_msg_text               = 'Stock not available'
*                iv_add_to_response_header = abap_true.
*
*            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*              EXPORTING
*                message_container = obj_msg_con.
*          ENDIF.

          SELECT a~aufnr, a~vornr, a~posnr, a~zeile, a~matnr, a~charg,
                 a~werks, a~bdmng, a~erfmg, a~erfme, a~meins, a~factor,
                 b~clabs
            INTO TABLE @DATA(lt_zsffppdt003)
            FROM zsffppdt003 AS a JOIN mchb AS b ON b~matnr = a~matnr AND
                                                    b~werks = a~werks AND
                                                    b~lgort = @wa_wh_resb-lgort AND
                                                    b~charg = a~charg
            WHERE ( aufnr = @lv_aufnr OR aufnr = @lv_aufnr_ori )
              AND vornr = @wa_wh_resb-vornr
              AND posnr = @wa_wh_resb-posnr.

          "RM scan Already Exists
          IF line_exists( lt_zsffppdt003[ matnr = lv_matnr
                                          charg = lv_charg ] ).
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'RM scan Already Exists'
                iv_add_to_response_header = abap_true.

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ENDIF.

          CALL FUNCTION 'VB_BATCH_GET_DETAIL'
            EXPORTING
              matnr              = lv_matnr
              charg              = lv_charg
              werks              = lv_werks
              get_classification = 'X'
            TABLES
              char_of_batch      = lt_cob
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

          "Batch Invalid
          IF sy-subrc NE 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Batch Invalid'
                iv_add_to_response_header = abap_true.

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.

          ELSE.
            "Expired Date Validation
            IF line_exists( lt_cob[ atnam = 'LOBM_VFDAT' ] ).
              lv_atwtb = VALUE #( lt_cob[ atnam = 'LOBM_VFDAT' ]-atwtb ).
              lv_vfdat = |{ lv_atwtb+6(4) }| && |{ lv_atwtb+3(2) }| && |{ lv_atwtb(2) }|.

              IF lv_vfdat LT sy-datum.
                CALL METHOD obj_msg_con->add_message_text_only
                  EXPORTING
                    iv_msg_type               = 'E'
                    iv_msg_text               = 'Batch is expirate'
                    iv_add_to_response_header = abap_true.

                RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                  EXPORTING
                    message_container = obj_msg_con.
              ENDIF.
            ELSE.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Expirate date does not exists'
                  iv_add_to_response_header = abap_true.

              RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                  message_container = obj_msg_con.
            ENDIF.
          ENDIF.

*Get MEAN VALUE
          CALL FUNCTION 'ZPP_GET_MEANVAL'
            EXPORTING
              pi_werks   = lv_werks
              pi_matnr   = lv_matnr
              pi_charg   = lv_charg
            IMPORTING
              pe_meanval = lv_meanval.

*Get Faktorisasi
          IF ls_ztnpppdt002-factor = 'X'.
            lv_text     = 'Faktorisasi pada Kadar'.
            lv_inspoper = '0010'.

            CALL FUNCTION 'ZQMMATNR_FACTOR'
              EXPORTING
                i_matnr      = lv_matnr
                i_charg      = lv_charg
                i_werks      = lv_werks
                i_text       = lv_text
                i_inspoper   = lv_inspoper
              IMPORTING
                e_mean_value = lv_factor.

            IF lv_factor IS INITIAL.
              lv_factor = 1.
            ELSE.
              TRANSLATE lv_factor USING '. '.
              TRANSLATE lv_factor USING ',.'.
              CONDENSE lv_factor.
            ENDIF.
          ELSE.
            lv_factor = 1.
          ENDIF.

*Recalc. req. qty w/ factorisasi #LastRecord
          IF lt_zsffppdt003[] IS NOT INITIAL.
            DESCRIBE TABLE lt_zsffppdt003 LINES DATA(lv_lines03).
            ASSIGN lt_zsffppdt003[ lv_lines03 ] TO FIELD-SYMBOL(<fs_zsffppdt003_upd>).

            SELECT SINGLE factor INTO @DATA(lv_flag_factor)
              FROM ztnpppdt002 WHERE ( equnr = @lv_equnr OR equnr = @lv_equnr_ori )
                                 AND matnr = @<fs_zsffppdt003_upd>-matnr
                                 AND factor = 'X'.
            IF sy-subrc = 0.
              CLEAR lv_factor2.
              CALL FUNCTION 'ZQMMATNR_FACTOR'
                EXPORTING
                  i_matnr      = <fs_zsffppdt003_upd>-matnr
                  i_charg      = <fs_zsffppdt003_upd>-charg
                  i_werks      = <fs_zsffppdt003_upd>-werks
                  i_text       = lv_text
                  i_inspoper   = lv_inspoper
                IMPORTING
                  e_mean_value = lv_factor2.

              IF lv_factor2 IS NOT INITIAL.
                TRANSLATE lv_factor2 USING '. '.
                TRANSLATE lv_factor2 USING ',.'.
                CONDENSE lv_factor2.
              ENDIF.
              lv_sisa = ( <fs_zsffppdt003_upd>-bdmng - <fs_zsffppdt003_upd>-erfmg ) / lv_factor2.
            ELSE.
              lv_sisa = <fs_zsffppdt003_upd>-bdmng - <fs_zsffppdt003_upd>-erfmg.
            ENDIF.
          ENDIF.

          IF wa_wh_resb-meins NE wa_wh_resb-erfme.
            IF wa_wh_resb-meins = 'L'.
              CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
                EXPORTING
                  input                = wa_wh_resb-clabs
                  matnr                = wa_wh_resb-matnr
                  meinh                = wa_wh_resb-erfme
                  meins                = wa_wh_resb-meins
                IMPORTING
                  output               = wa_wh_resb-clabs
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

              CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
                EXPORTING
                  input                = wa_wh_resb-bdmng
                  matnr                = wa_wh_resb-matnr
                  meinh                = wa_wh_resb-erfme
                  meins                = wa_wh_resb-meins
                IMPORTING
                  output               = wa_wh_resb-bdmng
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
                  input    = wa_wh_resb-clabs
                  unit_in  = wa_wh_resb-meins
                  unit_out = wa_wh_resb-erfme
                IMPORTING
                  output   = wa_wh_resb-clabs.

              CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
                EXPORTING
                  input    = wa_wh_resb-bdmng
                  unit_in  = wa_wh_resb-meins
                  unit_out = wa_wh_resb-erfme
                IMPORTING
                  output   = wa_wh_resb-bdmng.
            ENDIF.
          ENDIF.

          IF lt_zsffppdt003[] IS INITIAL.
            wa_wh_resb-bdmng = wa_wh_resb-erfmg * lv_factor.
          ELSE.
            wa_wh_resb-bdmng = lv_sisa * lv_factor.
          ENDIF.

          IF ls_ztnpppdt002-factor = 'X'.
            CASE wa_wh_resb-erfme.
              WHEN 'KG'.
                lv_bdmng2 = wa_wh_resb-bdmng.
                lv_bdmng = lv_bdmng2.
              WHEN 'G'.
                lv_bdmng1 = wa_wh_resb-bdmng.
                lv_bdmng = lv_bdmng1.
            ENDCASE.
            wa_wh_resb-bdmng = lv_bdmng.

* Recalc. Req. Qty #1stRecord & Update ZSFFPPDT003
            IF lt_zsffppdt003[] IS NOT INITIAL.
              lv_erfmgtot = REDUCE erfmg( INIT x TYPE erfmg FOR wa_zsffppdt003 IN lt_zsffppdt003
                                          NEXT x = x + wa_zsffppdt003-erfmg ).
              ASSIGN lt_zsffppdt003[ 1 ] TO <fs_zsffppdt003_upd>.
              <fs_zsffppdt003_upd>-bdmng = lv_erfmgtot + lv_bdmng.
              UPDATE zsffppdt003 SET factor = <fs_zsffppdt003_upd>-bdmng
                                 WHERE aufnr = <fs_zsffppdt003_upd>-aufnr
                                   AND vornr = <fs_zsffppdt003_upd>-vornr
                                   AND posnr = <fs_zsffppdt003_upd>-posnr
                                   AND zeile = <fs_zsffppdt003_upd>-zeile
                                   AND matnr = <fs_zsffppdt003_upd>-matnr
                                   AND charg = <fs_zsffppdt003_upd>-charg.
            ENDIF.
          ENDIF.

* Collect Itab
          MOVE-CORRESPONDING wa_wh_resb TO ls_wh_materialscan.
*          ls_wh_materialscan-rmbatch = lv_charg.
          ls_wh_materialscan-rmscn = lv_rmscan.
          ls_wh_materialscan-plnbez = wa_wh_resb-baugr.

          SELECT SINGLE charg INTO ls_wh_materialscan-fgbatch
            FROM afpo WHERE aufnr = ls_wh_materialscan-aufnr.

          "Append itab detail from zsffppdt003
          LOOP AT lt_zsffppdt003 INTO DATA(ls_zsffppdt003).
            SELECT SUM( bdmng ) AS sum_bdmng SUM( erfmg ) AS sum_erfmg
              INTO ls_sum
              FROM resb WHERE matnr = ls_zsffppdt003-matnr
                          AND werks = ls_zsffppdt003-werks
                          AND charg = ls_zsffppdt003-charg
                          AND lgort = wa_wh_resb-lgort
                          AND kzear = space
                          AND splkz = '2'
                          AND wempf IN ('T','W').
            ls_zsffppdt003-clabs = ls_zsffppdt003-clabs - ls_sum-sum_bdmng.

            IF ls_zsffppdt003-erfme NE ls_zsffppdt003-meins.
              IF wa_wh_resb-meins = 'L'.
                CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
                  EXPORTING
                    input                = ls_zsffppdt003-clabs
                    matnr                = ls_zsffppdt003-matnr
                    meinh                = ls_zsffppdt003-erfme
                    meins                = ls_zsffppdt003-meins
                  IMPORTING
                    output               = ls_zsffppdt003-clabs
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
                    input                = ls_zsffppdt003-clabs
                    unit_in              = ls_zsffppdt003-meins
                    unit_out             = ls_zsffppdt003-erfme
                  IMPORTING
                    output               = ls_zsffppdt003-clabs
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
              ENDIF.
            ENDIF.

* Append Itab Detail
*            ADD ls_zsffppdt003-erfmg TO lv_erfmgtot.
            ls_wh_material_scan_dtl-aufnr = ls_zsffppdt003-aufnr.
            ls_wh_material_scan_dtl-charg = ls_zsffppdt003-charg.
            WRITE ls_zsffppdt003-clabs TO ls_wh_material_scan_dtl-clabs UNIT ls_zsffppdt003-meins.
            WRITE ls_zsffppdt003-bdmng TO ls_wh_material_scan_dtl-bdmng UNIT ls_zsffppdt003-erfme.
            ls_wh_material_scan_dtl-meins = ls_zsffppdt003-meins.
            WRITE ls_zsffppdt003-erfmg TO ls_wh_material_scan_dtl-erfmg UNIT ls_zsffppdt003-erfme.
            ls_wh_material_scan_dtl-erfme = ls_zsffppdt003-erfme.
            ls_wh_material_scan_dtl-meanv = lv_meanval.
            CONDENSE: ls_wh_material_scan_dtl-clabs,
                      ls_wh_material_scan_dtl-bdmng,
                      ls_wh_material_scan_dtl-erfmg.

            SELECT SINGLE factor INTO (lv_flag_factor)
              FROM ztnpppdt002 WHERE ( equnr = lv_equnr OR equnr = lv_equnr_ori )
                                 AND matnr = ls_zsffppdt003-matnr
                                 AND factor = 'X'.
            IF sy-subrc = 0.
              CLEAR lv_factor2.
              CALL FUNCTION 'ZQMMATNR_FACTOR'
                EXPORTING
                  i_matnr      = ls_zsffppdt003-matnr
                  i_charg      = ls_zsffppdt003-charg
                  i_werks      = ls_zsffppdt003-werks
                  i_text       = lv_text
                  i_inspoper   = lv_inspoper
                IMPORTING
                  e_mean_value = lv_factor2.
              IF lv_factor2 IS NOT INITIAL.
                CONDENSE lv_factor2.
                ls_wh_material_scan_dtl-meanv = |( F = | & |{ lv_factor2 }| & | )|.
              ENDIF.
            ENDIF.

            APPEND ls_wh_material_scan_dtl TO ls_wh_materialscan-wh_materialscannav.
            CLEAR ls_wh_material_scan_dtl.
          ENDLOOP.

* Append Itab Detail
          MOVE-CORRESPONDING wa_wh_resb TO ls_wh_material_scan_dtl.
          ls_wh_material_scan_dtl-charg = lv_charg.
          ls_wh_material_scan_dtl-meanv = lv_meanval.
          WRITE wa_wh_resb-clabs TO ls_wh_material_scan_dtl-clabs UNIT ls_wh_material_scan_dtl-erfme.
          WRITE wa_wh_resb-bdmng TO ls_wh_material_scan_dtl-bdmng UNIT ls_wh_material_scan_dtl-erfme.
          ls_wh_material_scan_dtl-erfmg = '0'.
          CONDENSE: ls_wh_material_scan_dtl-clabs,
                    ls_wh_material_scan_dtl-bdmng,
                    ls_wh_material_scan_dtl-erfmg.

          IF ls_ztnpppdt002-factor = 'X'.
            TRANSLATE lv_factor USING '.,'.
            ls_wh_material_scan_dtl-meanv = |( F = | & |{ lv_factor }| & | )|.
          ENDIF.

          APPEND ls_wh_material_scan_dtl TO ls_wh_materialscan-wh_materialscannav.
          CLEAR ls_wh_material_scan_dtl.


          IF ls_wh_materialscan-wh_materialscannav[] IS INITIAL.
            lv_msg = |Weighing for material| & | | & |{ lv_matnr }| & | | &
                     |Batch| & | | & |{ lv_charg }| & | | &
                     |Already Process|.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = lv_msg
                iv_add_to_response_header = abap_true.

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ELSE.
            APPEND ls_wh_materialscan TO lt_wh_materialscan.

            "Write to ZSFFPPDT005
            CREATE OBJECT cl_json_data
              EXPORTING
                data = ls_wh_materialscan.
            cl_json_data->serialize( ).
            lv_json = cl_json_data->get_data( ).

            CALL FUNCTION 'ZSFF_WEIGHT'
              EXPORTING
                pi_process = 'STR_DATE'
                pi_data    = lv_json
              IMPORTING
                pe_data    = lv_jsonret
                pe_msgtyp  = lv_msgtyp
                pe_message = lv_message.
          ENDIF.

* Send API
          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_wh_materialscan
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN 'PGI_OrderSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          IF line_exists( it_filter_select_options[ property = 'QRCode' ] ).
            lr_aufnr = it_filter_select_options[ property = 'QRCode' ]-select_options.
            DATA(lv_qrcode) = VALUE #( lr_aufnr[ 1 ]-low ).
            SPLIT lv_qrcode AT ';' INTO: DATA(lv_plnbez)
                                         lv_aufnr
                                         lv_charg
                                         DATA(lv_vornr)
                                         DATA(lv_decoct).
          ENDIF.

          SELECT SINGLE aufnr, werks, plnbez, charg, maktx
            INTO @DATA(ls_cdsv02)
            FROM zdmp_cdsv02 AS a JOIN makt AS b ON b~matnr = a~plnbez  AND
                                                    b~spras = @sy-langu
            WHERE aufnr = @lv_aufnr.
          IF sy-subrc NE 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Order Number Invalid'
                iv_add_to_response_header = abap_true.

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.

          ELSE.
            SELECT aufnr, vornr, posnr, a~matnr, charg, sortf, maktx,
                   CASE
                   	WHEN wempf = 'T' THEN 'X'
                    ELSE ' '
                   END AS flags
              INTO TABLE @DATA(lt_order_dtl)
              FROM resb AS a JOIN makt AS b ON b~matnr = a~matnr AND
                                               b~spras = @sy-langu
              WHERE aufnr = @lv_aufnr
                AND vornr = @lv_vornr
                AND kzear = @space
                AND sortf = @lv_decoct
                AND bdmng NE 0
            ORDER BY aufnr, vornr, posnr.

            IF sy-subrc NE 0.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Order already PGI'
                  iv_add_to_response_header = abap_true.

              RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                  message_container = obj_msg_con.
            ENDIF.
          ENDIF.

*Collet ITAB
          MOVE-CORRESPONDING ls_cdsv02 TO ls_pgi_order.
          ls_pgi_order-matnr_fg = ls_cdsv02-plnbez.
          ls_pgi_order-maktx_fg = ls_cdsv02-maktx.
          ls_pgi_order-charg_fg = ls_cdsv02-charg.
          ls_pgi_order-qrcode = lv_qrcode.
          ls_pgi_order-vornr  = lv_vornr.
          IF lv_decoct = 'D'.
            ls_pgi_order-oprtyp = 'Decoct'.
          ELSE.
            CLEAR ls_pgi_order-oprtyp.
          ENDIF.

          LOOP AT lt_order_dtl INTO DATA(ls_order_dtl).
            MOVE-CORRESPONDING ls_order_dtl TO ls_pgi_order_dtl.
            ls_pgi_order_dtl-matnr_rm = ls_order_dtl-matnr.
            ls_pgi_order_dtl-maktx_rm = ls_order_dtl-maktx.
            ls_pgi_order_dtl-charg_rm = ls_order_dtl-charg.
            APPEND ls_pgi_order_dtl TO ls_pgi_order-pgi_ordernav.
          ENDLOOP.

          IF line_exists( lt_order_dtl[ flags = ' ' ] ).
          ELSE.
            ls_pgi_order-pgi = 'X'.
          ENDIF.

          APPEND ls_pgi_order TO lt_pgi_order.

* Send API
          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_pgi_order
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN 'PGI_MaterialFlagSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          IF line_exists( it_filter_select_options[ property = 'QRCode' ] ).
            lr_aufnr = it_filter_select_options[ property = 'QRCode' ]-select_options.
            lv_qrcode = VALUE #( lr_aufnr[ 1 ]-low ).
            SPLIT lv_qrcode AT ';' INTO: lv_plnbez
                                         lv_aufnr
                                         lv_vornr
                                         DATA(lv_posnr)
                                         lv_matnr
                                         DATA(lv_weight).
            lv_aufnr = |{ lv_aufnr ALPHA = IN }|.
          ENDIF.

          IF line_exists( it_filter_select_options[ property = 'OprType' ] ).
            lr_oprtyp = it_filter_select_options[ property = 'OprType' ]-select_options.
            DATA(lv_oprtyp) = VALUE #( lr_oprtyp[ 1 ]-low ).
            IF lv_oprtyp = 'Decoct'.
              lv_decoct = 'D'.
            ELSE.
              CLEAR lv_decoct.
            ENDIF.
          ENDIF.

          IF line_exists( it_filter_select_options[ property = 'OrderNo' ] ).
            lr_aufnr = it_filter_select_options[ property = 'OrderNo' ]-select_options.
            lv_aufnr_hdr = VALUE #( lr_aufnr[ 1 ]-low ).
            lv_aufnr_hdr = |{ lv_aufnr_hdr ALPHA = IN }|.
          ENDIF.

          IF line_exists( it_filter_select_options[ property = 'Activity' ] ).
            lr_vornr = it_filter_select_options[ property = 'Activity' ]-select_options.
            DATA(lv_vornr_hdr) = VALUE #( lr_vornr[ 1 ]-low ).
          ENDIF.

* Cek Order Header VS Detail
          IF lv_aufnr NE lv_aufnr_hdr OR lv_vornr NE lv_vornr_hdr.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Order does not match'
                iv_add_to_response_header = abap_true.
            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ENDIF.

* Cek Order
          SELECT SINGLE aufnr werks plnbez charg maktx
            INTO ls_cdsv02
            FROM zdmp_cdsv02 AS a JOIN makt AS b ON b~matnr = a~plnbez  AND
                                                    b~spras = sy-langu
            WHERE aufnr = lv_aufnr.
          IF sy-subrc NE 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Order Number Invalid'
                iv_add_to_response_header = abap_true.
            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ENDIF.

* Cek Material
          SELECT SINGLE wempf INTO @DATA(lv_wempf)
            FROM resb WHERE aufnr = @lv_aufnr
                        AND vornr = @lv_vornr
                        AND posnr = @lv_posnr
                        AND matnr = @lv_matnr
                        AND sortf = @lv_decoct
                        AND kzear = @space.
          IF sy-subrc NE 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Material does not exists'
                iv_add_to_response_header = abap_true.
            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.
          ENDIF.

          CASE lv_wempf.
            WHEN 'W'.
              UPDATE resb SET wempf = 'T' WHERE aufnr = lv_aufnr
                                            AND vornr = lv_vornr
                                            AND posnr = lv_posnr
                                            AND matnr = lv_matnr
                                            AND sortf = lv_decoct
                                            AND kzear = space
                                            AND wempf = lv_wempf.
              IF sy-subrc NE 0.
                CALL METHOD obj_msg_con->add_message_text_only
                  EXPORTING
                    iv_msg_type               = 'E'
                    iv_msg_text               = 'Reservation Number Invalid'
                    iv_add_to_response_header = abap_true.

                RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                  EXPORTING
                    message_container = obj_msg_con.

              ELSE.
                COMMIT WORK AND WAIT.

                SELECT aufnr, vornr, posnr, a~matnr, charg, sortf, maktx,
                       CASE
                       	WHEN wempf = 'T' THEN 'X'
                        ELSE ' '
                       END AS flags
                  INTO TABLE @DATA(lt_matflag_dtl)
                  FROM resb AS a JOIN makt AS b ON b~matnr = a~matnr AND
                                                   b~spras = @sy-langu
                  WHERE aufnr = @lv_aufnr
                    AND vornr = @lv_vornr
                    AND kzear = @space
                    AND sortf = @lv_decoct
                    AND vmeng NE 0
                ORDER BY aufnr, vornr, posnr.

*Collet ITAB
                MOVE-CORRESPONDING ls_cdsv02 TO ls_pgi_matflag.
                ls_pgi_matflag-matnr_fg = ls_cdsv02-plnbez.
                ls_pgi_matflag-maktx_fg = ls_cdsv02-maktx.
                ls_pgi_matflag-charg_fg = ls_cdsv02-charg.
                ls_pgi_matflag-vornr    = lv_vornr_hdr.
                ls_pgi_matflag-oprtyp   = lv_oprtyp.
                ls_pgi_matflag-qrcode   = lv_qrcode.

                LOOP AT lt_matflag_dtl INTO DATA(ls_matflag_dtl).
                  MOVE-CORRESPONDING ls_matflag_dtl TO ls_pgi_matflag_dtl.
                  ls_pgi_matflag_dtl-matnr_rm = ls_matflag_dtl-matnr.
                  ls_pgi_matflag_dtl-maktx_rm = ls_matflag_dtl-maktx.
                  ls_pgi_matflag_dtl-charg_rm = ls_matflag_dtl-charg.
                  APPEND ls_pgi_matflag_dtl TO ls_pgi_matflag-pgi_materialflagnav.
                ENDLOOP.

                IF line_exists( lt_matflag_dtl[ flags = ' ' ] ).
                ELSE.
                  ls_pgi_matflag-pgi = 'X'.
                ENDIF.

                APPEND ls_pgi_matflag TO lt_pgi_matflag.
              ENDIF.

            WHEN 'T'.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Material Already Scan'
                  iv_add_to_response_header = abap_true.
              RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                  message_container = obj_msg_con.

            WHEN OTHERS.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Material belum ditimbang'
                  iv_add_to_response_header = abap_true.
              RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                  message_container = obj_msg_con.
          ENDCASE.

* Send API
          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_pgi_matflag
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN 'ReprintSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          IF line_exists( it_filter_select_options[ property = 'OrderNo' ] ).
            lr_aufnr = it_filter_select_options[ property = 'OrderNo' ]-select_options.
            lv_aufnr = VALUE #( lr_aufnr[ 1 ]-low OPTIONAL ).
            lv_aufnr = |{ lv_aufnr ALPHA = IN }|.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'BOMItem' ] ).
            lr_posnr = it_filter_select_options[ property = 'BOMItem' ]-select_options.
            lv_posnr = VALUE #( lr_posnr[ 1 ]-low OPTIONAL ).
            lv_posnr = |{ lv_posnr ALPHA = IN }|.
          ENDIF.

          SELECT DISTINCT aufnr, posnr,
                          CASE
                            WHEN wempf = ' ' THEN 'Fullpack'
                            WHEN wempf = 'T' OR wempf = 'W' THEN 'Weighing'
                            ELSE ' '
                          END AS prntyp
            INTO TABLE @DATA(lt_resb_reprint)
            FROM resb WHERE aufnr = @lv_aufnr
                        AND posnr = @lv_posnr
                        AND splkz = '2'.

          IF sy-subrc NE 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Process Order Invalid'
                iv_add_to_response_header = abap_true.
            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.

          ELSE.
            ls_reprint-aufnr = lv_aufnr.
            ls_reprint-posnr = lv_posnr.
            LOOP AT lt_resb_reprint INTO DATA(ls_resb_reprint).
              ls_reprint_dtl-prntyp = ls_resb_reprint-prntyp.
              APPEND ls_reprint_dtl TO ls_reprint-reprintnav.
            ENDLOOP.
            APPEND ls_reprint TO lt_reprint.
          ENDIF.

* Send API
          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_reprint
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN 'FP_ReprintSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          IF line_exists( it_filter_select_options[ property = 'OrderNo' ] ).
            lr_aufnr = it_filter_select_options[ property = 'OrderNo' ]-select_options.
            lv_aufnr = VALUE #( lr_aufnr[ 1 ]-low OPTIONAL ).
            lv_aufnr = |{ lv_aufnr ALPHA = IN }|.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'BOMItem' ] ).
            lr_posnr = it_filter_select_options[ property = 'BOMItem' ]-select_options.
            lv_posnr = VALUE #( lr_posnr[ 1 ]-low OPTIONAL ).
            lv_posnr = |{ lv_posnr ALPHA = IN }|.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'PrintType' ] ).
            lr_oprtyp = it_filter_select_options[ property = 'PrintType' ]-select_options.
            DATA(lv_prntyp) = VALUE #( lr_oprtyp[ 1 ]-low OPTIONAL ).

            CASE lv_prntyp.
              WHEN 'Fullpack'.
                DATA(lr_wempf) = VALUE rseloption( ( sign = 'I' option = 'EQ' low = ' ' ) ).
              WHEN 'Weighing'.
                lr_wempf = VALUE rseloption( ( sign = 'I' option = 'EQ' low = 'T' )
                                             ( sign = 'I' option = 'EQ' low = 'W' ) ).
            ENDCASE.
          ENDIF.

          SELECT rsnum, rspos, rsart, vornr, posnr, splkz, wempf, aufnr,
                 a~matnr, werks, lgort, charg, bdmng, meins, erfmg, erfme,
                 aufpl, aplzl, baugr, maktx
            INTO TABLE @DATA(lt_resb_fp_reprint)
            FROM resb AS a JOIN makt AS b ON b~matnr = a~matnr AND
                                             b~spras = @sy-langu
            WHERE aufnr = @lv_aufnr
              AND posnr = @lv_posnr
              AND wempf IN @lr_wempf
              AND splkz = '2'
            ORDER BY rsnum, rspos, rsart.

          IF sy-subrc NE 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Process Order Invalid'
                iv_add_to_response_header = abap_true.
            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.

          ELSE.
            SELECT * INTO TABLE @DATA(lt_zsffppdt002)
              FROM zsffppdt002 FOR ALL ENTRIES IN @lt_resb_fp_reprint
              WHERE rsnum = @lt_resb_fp_reprint-rsnum
                AND rspos = @lt_resb_fp_reprint-rspos
                AND rsart = @lt_resb_fp_reprint-rsart
              ORDER BY PRIMARY KEY.
            IF sy-subrc NE 0.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Order belum diprint'
                  iv_add_to_response_header = abap_true.
              RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                  message_container = obj_msg_con.

            ELSE.
              SELECT SINGLE aufnr, werks, plnbez, strdate, objnr, charg, maktx
                INTO @DATA(ls_cdsv02_reprint)
                FROM zdmp_cdsv02 AS a JOIN makt AS b ON a~plnbez = b~matnr
                WHERE aufnr = @lv_aufnr.
            ENDIF.

            CALL FUNCTION 'BAPI_USER_GET_DETAIL'
              EXPORTING
                username  = sy-uname
              IMPORTING
                defaults  = defaults
              TABLES
                parameter = parameter
                return    = return.
            IF sy-subrc = 0.
              DATA(lv_ipno) = VALUE #( parameter[ parid = 'PRI' ]-parva OPTIONAL ).
            ENDIF.
          ENDIF.

          DATA(lt_zsffppdt002_filter) = lt_zsffppdt002[].
          SORT lt_zsffppdt002_filter BY aufnr posnr mblnr mjahr.
          DELETE ADJACENT DUPLICATES FROM lt_zsffppdt002_filter COMPARING aufnr posnr mblnr mjahr.

          LOOP AT lt_zsffppdt002_filter INTO DATA(ls_zsffppdt002_filter).
            SELECT MAX( zeile ) INTO @DATA(lv_zeile)
              FROM zsffppdt002 WHERE rsnum = @ls_zsffppdt002_filter-rsnum
                                 AND matnr = @ls_zsffppdt002_filter-matnr
                                 AND charg = @ls_zsffppdt002_filter-charg
                                 AND mblnr = @ls_zsffppdt002_filter-mblnr
                                 AND mjahr = @ls_zsffppdt002_filter-mjahr.
            IF sy-subrc = 0.
              SHIFT lv_zeile LEFT DELETING LEADING '0'.
              CONDENSE lv_zeile.
            ENDIF.

            DATA(ls_resb_fp_reprint) = lt_resb_fp_reprint[ rsnum = ls_zsffppdt002_filter-rsnum
                                                           rspos = ls_zsffppdt002_filter-rspos ].
            ls_fp_reprint-aufnr     = ls_resb_fp_reprint-aufnr.
            ls_fp_reprint-vornr     = ls_resb_fp_reprint-vornr.
            ls_fp_reprint-prntyp    = lv_prntyp.
            ls_fp_reprint-werks     = ls_resb_fp_reprint-werks.
            ls_fp_reprint-wdesc     = 'SFF - Supra Ferbindo Farma'.
            ls_fp_reprint-matnr     = ls_resb_fp_reprint-matnr.
            ls_fp_reprint-posnr     = ls_resb_fp_reprint-posnr.
            ls_fp_reprint-maktx     = ls_resb_fp_reprint-maktx.
            ls_fp_reprint-charg     = ls_resb_fp_reprint-charg.
            ls_fp_reprint-packt     = lv_zeile.
            ls_fp_reprint-operator  = ls_zsffppdt002_filter-operator.
            ls_fp_reprint-pengawas  = ls_zsffppdt002_filter-pengawas.
            ls_fp_reprint-plnbez    = ls_cdsv02_reprint-plnbez.
            ls_fp_reprint-fmaktx    = ls_cdsv02_reprint-maktx.
            ls_fp_reprint-fcharg    = ls_cdsv02_reprint-charg.
            ls_fp_reprint-mblnr     = ls_zsffppdt002_filter-mblnr.
            ls_fp_reprint-mjahr     = ls_zsffppdt002_filter-mjahr.
            ls_fp_reprint-ipno      = lv_ipno.
            WRITE sy-datum TO ls_fp_reprint-datum.
            WRITE ls_zsffppdt002_filter-erfmg TO ls_fp_reprint-packs UNIT ls_zsffppdt002_filter-erfme.
            CONDENSE ls_fp_reprint-packs.

            SELECT SINGLE * INTO @DATA(ls_hazcom)
              FROM ztspmdhazcom WHERE matnr = @ls_fp_reprint-matnr
                                  AND werks = @ls_fp_reprint-werks.
            IF sy-subrc = 0.
              ls_fp_reprint-hazcom = |H =| & | | & |{ ls_hazcom-health }| & | | &
                                     |F =| & | | & |{ ls_hazcom-fire }| & | | &
                                     |R =| & | | & |{ ls_hazcom-reactivity }|.
            ENDIF.

            SELECT SINGLE a~name1 INTO ls_fp_reprint-name1
              FROM lfa1 AS a JOIN mch1 AS b ON a~lifnr = b~lifnr
              WHERE b~matnr = ls_fp_reprint-matnr
                AND b~charg = ls_fp_reprint-charg.
            IF sy-subrc = 0 AND ls_fp_reprint-name1 IS NOT INITIAL.
              ls_fp_reprint-name1 = |(| & |{ ls_fp_reprint-name1(30) }| & |)|.
            ENDIF.

            LOOP AT lt_zsffppdt002 INTO DATA(ls_zsffppdt002)
                                   WHERE rsnum = ls_zsffppdt002_filter-rsnum
                                     AND rspos = ls_zsffppdt002_filter-rspos.
              ls_fp_reprint_dtl-aufnr = ls_zsffppdt002-aufnr.

              CONCATENATE ls_fp_reprint-packs ls_resb_fp_reprint-erfme
                INTO ls_fp_reprint_dtl-erfmgt SEPARATED BY ' '.

              ls_fp_reprint_dtl-counter = ls_zsffppdt002-zeile.
              SHIFT ls_fp_reprint_dtl-counter LEFT DELETING LEADING '0'.
              CONDENSE ls_fp_reprint_dtl-counter.
              CONCATENATE ls_fp_reprint_dtl-counter ls_fp_reprint-packt
                INTO ls_fp_reprint_dtl-counter SEPARATED BY '/'.

              SHIFT ls_resb_fp_reprint-charg LEFT DELETING LEADING '0'.
              CONDENSE ls_resb_fp_reprint-charg.

              SHIFT ls_resb_fp_reprint-aufnr LEFT DELETING LEADING '0'.
              CONDENSE ls_resb_fp_reprint-aufnr.

              CONCATENATE ls_fp_reprint-plnbez ls_resb_fp_reprint-aufnr ls_fp_reprint-vornr
                          ls_fp_reprint-posnr  ls_fp_reprint-matnr ls_fp_reprint_dtl-erfmgt
                          ls_fp_reprint_dtl-counter 'F' ls_resb_fp_reprint-charg ls_fp_reprint-mblnr
                INTO ls_fp_reprint_dtl-qrcode SEPARATED BY ';'.

              APPEND ls_fp_reprint_dtl TO ls_fp_reprint-fp_reprintnav.
              CLEAR ls_fp_reprint_dtl.
            ENDLOOP.

            APPEND ls_fp_reprint TO lt_fp_reprint.
            CLEAR ls_fp_reprint.
          ENDLOOP.

* Send API
          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_fp_reprint
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN 'WH_ReprintSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          IF line_exists( it_filter_select_options[ property = 'OrderNo' ] ).
            lr_aufnr = it_filter_select_options[ property = 'OrderNo' ]-select_options.
            lv_aufnr = VALUE #( lr_aufnr[ 1 ]-low OPTIONAL ).
            lv_aufnr = |{ lv_aufnr ALPHA = IN }|.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'BOMItem' ] ).
            lr_posnr = it_filter_select_options[ property = 'BOMItem' ]-select_options.
            lv_posnr = VALUE #( lr_posnr[ 1 ]-low OPTIONAL ).
            lv_posnr = |{ lv_posnr ALPHA = IN }|.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'PrintType' ] ).
            lr_oprtyp = it_filter_select_options[ property = 'PrintType' ]-select_options.
            lv_prntyp = VALUE #( lr_oprtyp[ 1 ]-low OPTIONAL ).

            CASE lv_prntyp.
              WHEN 'Fullpack'.
                lr_wempf = VALUE rseloption( ( sign = 'I' option = 'EQ' low = ' ' ) ).
              WHEN 'Weighing'.
                lr_wempf = VALUE rseloption( ( sign = 'I' option = 'EQ' low = 'T' )
                                             ( sign = 'I' option = 'EQ' low = 'W' ) ).
            ENDCASE.
          ENDIF.

          SELECT rsnum, rspos, rsart, vornr, posnr, splkz, wempf, aufnr,
                 a~matnr, werks, lgort, charg, bdmng, meins, erfmg, erfme,
                 aufpl, aplzl, baugr, maktx
            INTO TABLE @DATA(lt_resb_wh_reprint)
            FROM resb AS a JOIN makt AS b ON b~matnr = a~matnr AND
                                             b~spras = @sy-langu
            WHERE aufnr = @lv_aufnr
              AND posnr = @lv_posnr
              AND wempf IN @lr_wempf
              AND splkz = '2'
            ORDER BY aufnr, a~matnr, posnr.

          IF sy-subrc NE 0.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Process Order Invalid'
                iv_add_to_response_header = abap_true.
            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                message_container = obj_msg_con.

          ELSE.
            DATA(ls_resb_wh_reprint) = lt_resb_wh_reprint[ 1 ].

            SELECT SINGLE * INTO @DATA(ls_zsffppdt004)
              FROM zsffppdt004
              WHERE ( aufnr = @ls_resb_wh_reprint-aufnr OR
                      aufnr IN @lr_aufnr )
                AND matnr = @ls_resb_wh_reprint-matnr
                AND posnr = @ls_resb_wh_reprint-posnr.
            IF sy-subrc NE 0.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Order belum diprint'
                  iv_add_to_response_header = abap_true.
              RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                  message_container = obj_msg_con.

            ELSE.
              SELECT SINGLE aufnr, werks, plnbez, strdate, objnr, charg, maktx
                INTO @DATA(ls_cdsv02_wh_reprint)
                FROM zdmp_cdsv02 AS a JOIN makt AS b ON a~plnbez = b~matnr
                WHERE aufnr = @lv_aufnr.

              SELECT a~lifnr, a~name1 INTO TABLE @DATA(lt_vendor)
                FROM lfa1 AS a JOIN mch1 AS b ON a~lifnr = b~lifnr
                FOR ALL ENTRIES IN @lt_resb_wh_reprint
                WHERE matnr = @lt_resb_wh_reprint-matnr
                  AND charg = @lt_resb_wh_reprint-charg.
            ENDIF.
          ENDIF.

          lv_equnr = |{ ls_zsffppdt004-equnr ALPHA = IN }|.
          SELECT SINGLE b~remark INTO @DATA(lv_remark)
            FROM equi_addr AS a JOIN adrt AS b ON b~addrnumber = a~addrnumber AND
                                                  b~comm_type  = 'PRT'
            WHERE equnr = @lv_equnr
              AND swerk = @ls_zsffppdt004-werks
              AND msgrp = 'WEIGHING'.

          SELECT SINGLE * INTO ls_hazcom
            FROM ztspmdhazcom WHERE matnr = ls_resb_wh_reprint-matnr
                                AND werks = ls_resb_wh_reprint-werks.

          ls_wh_reprint-aufnr     = ls_resb_wh_reprint-aufnr.
          ls_wh_reprint-werks     = ls_resb_wh_reprint-werks.
          ls_wh_reprint-wdesc     = 'SFF - Supra Ferbindo Farma'.
          ls_wh_reprint-matnr     = ls_resb_wh_reprint-matnr.
          ls_wh_reprint-maktx     = ls_resb_wh_reprint-maktx.
          ls_wh_reprint-vornr     = ls_resb_wh_reprint-vornr.
          ls_wh_reprint-posnr     = ls_resb_wh_reprint-posnr.
          ls_wh_reprint-ltxa1     = ls_zsffppdt004-ltxa1.
          ls_wh_reprint-rsnum     = ls_resb_wh_reprint-rsnum.
          ls_wh_reprint-rspos     = ls_resb_wh_reprint-rspos.
          ls_wh_reprint-wb        = ls_zsffppdt004-wbooth.
          ls_wh_reprint-equnr     = ls_zsffppdt004-equnr.
          ls_wh_reprint-eqktx     = ls_zsffppdt004-shtxt.
          ls_wh_reprint-operator  = ls_zsffppdt004-operator.
          ls_wh_reprint-pengawas  = ls_zsffppdt004-pengawas.
          ls_wh_reprint-plnbez    = ls_cdsv02_wh_reprint-plnbez.
          ls_wh_reprint-fmaktx    = ls_cdsv02_wh_reprint-maktx.
          ls_wh_reprint-fcharg    = ls_cdsv02_wh_reprint-charg.
          ls_wh_reprint-erfme     = ls_resb_wh_reprint-erfme.
          ls_wh_reprint-ipno      = lv_remark.
          ls_wh_reprint-prntyp    = lv_prntyp.

          DATA(lv_netto) = REDUCE erfmg( INIT x TYPE erfmg FOR wa_resb_wh_reprint IN lt_resb_wh_reprint
                                         NEXT x = x + wa_resb_wh_reprint-erfmg ).
          lv_bruto = lv_netto + ls_zsffppdt004-tara.

          WRITE: lv_netto TO ls_wh_reprint-netto UNIT ls_wh_reprint-erfme,
                 lv_bruto TO ls_wh_reprint-bruto UNIT ls_wh_reprint-erfme,
                 ls_zsffppdt004-tara TO ls_wh_reprint-tara UNIT ls_zsffppdt004-meins.
*                 sy-datum TO ls_wh_reprint-datum,
*                 sy-uzeit TO ls_wh_reprint-uzeit.
          CONDENSE: ls_wh_reprint-netto,ls_wh_reprint-bruto,ls_wh_reprint-tara.

          WRITE ls_zsffppdt004-datum TO lv_date.
          WRITE ls_zsffppdt004-uzeit TO lv_time.
          ls_wh_reprint-datum = |{ lv_date }| & | | & |{ lv_time }|.

          ls_wh_reprint-hazcom = |H =| & | | & |{ ls_hazcom-health }| & | | &
                                 |F =| & | | & |{ ls_hazcom-fire }| & | | &
                                 |R =| & | | & |{ ls_hazcom-reactivity }|.

          DATA(lv_netto2) = |{ ls_wh_reprint-netto }| & | | & |{ ls_wh_reprint-erfme }|.
          CONCATENATE ls_wh_reprint-plnbez ls_wh_reprint-aufnr ls_wh_reprint-vornr
                      ls_wh_reprint-posnr ls_wh_reprint-matnr lv_netto2
                      INTO ls_wh_reprint-qrcode SEPARATED BY ';'.

          LOOP AT lt_resb_wh_reprint INTO ls_resb_wh_reprint.
            ls_wh_reprint_dtl-aufnr = ls_resb_wh_reprint-aufnr.
            ls_wh_reprint_dtl-charg = ls_resb_wh_reprint-charg.
            ls_wh_reprint_dtl-weime = ls_resb_wh_reprint-erfme.
            WRITE ls_resb_wh_reprint-erfmg TO ls_wh_reprint_dtl-erfmg UNIT ls_wh_reprint_dtl-weime.
            CONDENSE ls_wh_reprint_dtl-erfmg.
            APPEND ls_wh_reprint_dtl TO ls_wh_reprint-wh_reprintdtlnav.
          ENDLOOP.

          LOOP AT lt_vendor INTO DATA(ls_vendor).
            MOVE-CORRESPONDING ls_vendor TO ls_wh_reprint_vnd.
            APPEND ls_wh_reprint_vnd TO ls_wh_reprint-wh_reprintvndnav.
          ENDLOOP.

          APPEND ls_wh_reprint TO lt_wh_reprint.
          CLEAR ls_wh_reprint.

* Send API
          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_wh_reprint
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
