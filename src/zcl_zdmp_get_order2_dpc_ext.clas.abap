class ZCL_ZDMP_GET_ORDER2_DPC_EXT definition
  public
  inheriting from ZCL_ZDMP_GET_ORDER2_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZDMP_GET_ORDER2_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entityset.
    DATA: lr_strdate TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_plnbez  TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_werks   TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_oprdesc TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_charg   TYPE STANDARD TABLE OF /iwbep/s_cod_select_option.

    CASE iv_entity_set_name.
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
          IF line_exists( it_filter_select_options[ property = 'OperationType' ] ).
            lr_oprdesc = it_filter_select_options[ property = 'OperationType' ]-select_options.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'Batch' ] ).
            lr_charg   = it_filter_select_options[ property = 'Batch' ]-select_options.
          ENDIF.
        ENDIF.

        SELECT SINGLE maktx INTO @DATA(lv_maktx)
          FROM makt WHERE matnr IN @lr_strdate
                      AND spras = @sy-langu.

        "Get Order
        SELECT * INTO TABLE @DATA(lt_cdsv02)
          FROM zdmp_cdsv02
          WHERE strdate IN @lr_strdate
            AND plnbez  IN @lr_plnbez
            AND werks   IN @lr_werks
            AND charg   IN @lr_charg.

        IF sy-subrc = 0.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.
    DATA: lt_wadah    TYPE TABLE OF zcl_zdmp_get_order2_mpc_ext=>ts_deep_wadah,
          lw_material TYPE zcl_zdmp_get_order2_mpc_ext=>ts_material.

    CASE iv_entity_set_name.
      WHEN 'wadahSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          LOOP AT it_filter_select_options INTO DATA(wa_filter).
            CASE wa_filter-property.
              WHEN 'RoutingNo'.
                DATA(lv_aufpl) = wa_filter-select_options[ 1 ]-low.
              WHEN 'ActivityNo'.
                DATA(lv_vornr) = wa_filter-select_options[ 1 ]-low.
              WHEN 'OperationType'.
                DATA(lv_oprdesc) = wa_filter-select_options[ 1 ]-low.
            ENDCASE.
          ENDLOOP.

          SELECT SINGLE aufpl, aplzl, plnfl, plnkn, plnal, plnty, plnnr,
                        zaehl, vornr, rueck, phseq, steus, ltxa1, arbid,
                        werks
            INTO @DATA(lw_afvc)
            FROM afvc WHERE aufpl = @lv_aufpl
                        AND vornr = @lv_vornr
                        AND steus = 'ZP01'.

          IF sy-subrc = 0.
            SELECT SINGLE * INTO @DATA(lw_ztspppdt012)
              FROM ztspppdt012 WHERE aufpl = @lw_afvc-aufpl
                                 AND aplzl = @lw_afvc-aplzl
                                 AND stats IN ('0031','0040')
                                 AND vornr = @lw_afvc-vornr.

            IF sy-subrc = 0.
              SELECT SINGLE plnbez INTO @DATA(lv_plnbez)
                FROM afko WHERE aufnr = @lw_ztspppdt012-aufnr.

              SELECT * INTO TABLE @DATA(lt_ztspppdt014)
                FROM ztspppdt014 WHERE aufnr = @lw_ztspppdt012-aufnr
                                   AND vornr = @lw_ztspppdt012-vornr
                ORDER BY PRIMARY KEY.

              IF sy-subrc = 0.
                APPEND INITIAL LINE TO lt_wadah ASSIGNING FIELD-SYMBOL(<fs_wadah>).
                <fs_wadah>-aufpl    = lw_afvc-aufpl.
                <fs_wadah>-aplzl    = lw_afvc-aplzl.
                <fs_wadah>-plnbez   = lv_plnbez.
                <fs_wadah>-aufnr    = lw_ztspppdt012-aufnr.
                <fs_wadah>-vornr    = lw_afvc-vornr.
                <fs_wadah>-ltxa1    = lw_afvc-ltxa1.
                <fs_wadah>-phseq    = lw_afvc-phseq.
                <fs_wadah>-oprdesc  = lv_oprdesc.

                LOOP AT lt_ztspppdt014 INTO DATA(lw_ztspppdt014).
                  SHIFT lw_ztspppdt014-wadah LEFT DELETING LEADING '0'.
                  SHIFT lw_ztspppdt014-twadah LEFT DELETING LEADING '0'.
                  CONDENSE: lw_ztspppdt014-wadah,lw_ztspppdt014-twadah.
                  lw_material-aufpl = <fs_wadah>-aufpl.
                  lw_material-vornr = <fs_wadah>-vornr.
                  lw_material-vornr_wh = lw_ztspppdt014-actwh.
                  lw_material-flgho = lw_ztspppdt014-flgho.
                  lw_material-maktx = <fs_wadah>-ltxa1.
                  lw_material-oprdesc = <fs_wadah>-oprdesc.
                  lw_material-erfmg = lw_ztspppdt014-netto.
                  lw_material-erfme = lw_ztspppdt014-meins.
                  CONCATENATE lw_ztspppdt014-wadah lw_ztspppdt014-twadah
                    INTO lw_material-cntr SEPARATED BY '/'.

                  IF lw_ztspppdt014-lotnr IS NOT INITIAL.
                    SHIFT lw_ztspppdt014-lotnr LEFT DELETING LEADING '0'.
                    CONDENSE lw_ztspppdt014-lotnr.
                    CONCATENATE lw_material-maktx 'Lot' lw_ztspppdt014-lotnr
                      INTO lw_material-maktx SEPARATED BY space.
                  ENDIF.

                  APPEND lw_material TO <fs_wadah>-wadtomatnav.
                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDIF.

          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_wadah
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
