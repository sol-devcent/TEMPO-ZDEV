class ZCL_ZDMP_GET_ORDER_DPC_EXT definition
  public
  inheriting from ZCL_ZDMP_GET_ORDER_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZDMP_GET_ORDER_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entityset.
    DATA: lt_order TYPE TABLE OF zcl_zdmp_get_order_mpc_ext=>ts_order,
          wa_order LIKE LINE OF lt_order.

    DATA: lt_operation TYPE TABLE OF zcl_zdmp_get_order_mpc_ext=>ts_operation,
          wa_operation LIKE LINE OF lt_operation.

    DATA: lt_wadah TYPE TABLE OF zcl_zdmp_get_order_mpc_ext=>ts_wadah,
          wa_wadah LIKE LINE OF lt_wadah.

    DATA: lt_material TYPE TABLE OF zcl_zdmp_get_order_mpc_ext=>ts_material,
          wa_material LIKE LINE OF lt_material.

    DATA: lt_weighingact TYPE TABLE OF zcl_zdmp_get_order_mpc_ext=>ts_weighingact,
          wa_weighingact LIKE LINE OF lt_weighingact.

    DATA: lv_msg      TYPE bapi_msg,
          obj_msg_con TYPE REF TO /iwbep/if_message_container.

    DATA: lt_location TYPE TABLE OF zcl_zdmp_get_order_mpc_ext=>ts_location.

    DATA: lv_aufpl   TYPE co_aufpl,
          lv_vornr   TYPE vornr,
          lv_strdate TYPE datum,
          lv_werks   TYPE werks_d,
          lv_plnbez  TYPE matnr,
          lv_aufnr   TYPE aufnr,
          lv_oprdesc TYPE char20,
          lv_phseq   TYPE phseq,
          lv_phseq1  TYPE phseq,
          lv_phseq2  TYPE phseq,
          lv_phseq3  TYPE phseq,
          lv_maktx   TYPE maktx,
          lv_stats   TYPE char4,
          lv_potx2   TYPE potx2,
          lv_charg   TYPE charg_d.

    DATA: lr_strdate TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_plnbez  TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_werks   TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_oprdesc TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_charg   TYPE STANDARD TABLE OF /iwbep/s_cod_select_option.

    DATA: lv_id     TYPE tdid VALUE 'AVOT',
          lv_name   TYPE tdobname,
          lv_object TYPE tdobject VALUE 'AUFK',
          lt_lines  TYPE TABLE OF tline.

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
          IF line_exists( it_filter_select_options[ property = 'BatchFG' ] ).
            lr_charg   = it_filter_select_options[ property = 'BatchFG' ]-select_options.
*            LOOP AT lr_charg ASSIGNING FIELD-SYMBOL(<fs_charg>).
*              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*                EXPORTING
*                  input  = <fs_charg>-low
*                IMPORTING
*                  output = lv_charg.
*              IF sy-subrc = 0.
*                <fs_charg>-low = lv_charg.
*              ENDIF.
*            ENDLOOP.
          ENDIF.

          SELECT SINGLE maktx INTO lv_maktx
            FROM makt WHERE matnr IN lr_plnbez
                        AND spras = sy-langu.

          "Get Order
          SELECT * INTO TABLE @DATA(lt_cdsv02)
            FROM zdmp_cdsv02
*            WHERE strdate = @lv_strdate
*              AND plnbez  = @lv_plnbez
*              AND werks   = @lv_werks.
            WHERE strdate IN @lr_strdate
              AND plnbez  IN @lr_plnbez
              AND werks   IN @lr_werks
              AND charg   IN @lr_charg.

          IF sy-subrc = 0.
            SELECT DISTINCT * INTO TABLE @DATA(lt_resb)
              FROM resb FOR ALL ENTRIES IN @lt_cdsv02
              WHERE aufnr = @lt_cdsv02-aufnr.

            IF sy-subrc = 0.
              SORT lt_resb BY rsnum rspos.
              DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING rsnum.
            ENDIF.

            LOOP AT lt_cdsv02 INTO DATA(wa_cdsv02).
              MOVE-CORRESPONDING wa_cdsv02 TO wa_order.
              wa_order-oprdesc = lr_oprdesc[ 1 ]-low.
              wa_order-maktx   = lv_maktx.

              READ TABLE lt_resb INTO DATA(wa_resb)
                                 WITH KEY aufnr = wa_cdsv02-aufnr.
              IF sy-subrc = 0.
                wa_order-aufpl = wa_resb-aufpl.
                wa_order-aplzl = wa_resb-aplzl.
              ENDIF.

              APPEND wa_order TO lt_order.
              CLEAR wa_order.
            ENDLOOP.

            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_order
              CHANGING
                cr_data = er_entityset.
          ENDIF.
        ENDIF.

      WHEN 'OperationSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          LOOP AT it_filter_select_options INTO DATA(wa_filter).
            CASE wa_filter-property.
              WHEN 'RoutingNo'.
                READ TABLE wa_filter-select_options INTO DATA(wa_filter_so) INDEX 1.
                lv_aufpl = wa_filter_so-low.
              WHEN 'OperationType'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_oprdesc = wa_filter_so-low.
              WHEN 'OperationApps'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                DATA(lr_stats) = wa_filter-select_options.
            ENDCASE.
          ENDLOOP.

          SELECT * INTO TABLE @DATA(lt_afvc)
            FROM afvc WHERE aufpl = @lv_aufpl
                        AND steus = 'ZP01'
            ORDER BY PRIMARY KEY.

          IF sy-subrc = 0.
            CASE lv_oprdesc.
              WHEN 'CB'.
                DELETE lt_afvc WHERE phseq(1) NE 'G'.
              WHEN 'CK'.
                DELETE lt_afvc WHERE phseq(1) NE 'D'.
              WHEN 'DECOCT'.
                DELETE lt_afvc WHERE phseq(1) NE 'E'.
              WHEN 'LIQUID MIXING'.
                DELETE lt_afvc WHERE phseq(1) NE 'L'.
              WHEN 'SEMI SOLID MIXING'.
                DELETE lt_afvc WHERE phseq(1) NE 'O'.
            ENDCASE.

            IF lt_afvc[] IS NOT INITIAL.
              DATA(lv_plant) = lt_afvc[ 1 ]-werks.

              SELECT SINGLE plnbez INTO lv_plnbez
                FROM caufv WHERE aufpl = lv_aufpl.

              SELECT SINGLE * INTO @DATA(ls_ztspppdt013)
                FROM ztspppdt013 WHERE werks = @lv_plant
                                   AND plnbez = @lv_plnbez.

              SELECT * INTO TABLE @DATA(lt_ztspppdt012)
                FROM ztspppdt012 FOR ALL ENTRIES IN @lt_afvc
                WHERE aufpl = @lt_afvc-aufpl
                  AND aplzl = @lt_afvc-aplzl
                  AND stats IN @lr_stats
                ORDER BY PRIMARY KEY.
              IF sy-subrc = 0.
                SORT lt_ztspppdt012 BY aufpl aplzl stats DESCENDING.
                DELETE ADJACENT DUPLICATES FROM lt_ztspppdt012 COMPARING aufpl aplzl.

                SELECT aufpl, aplzl, stats, vornr, actwh, aufnr, rooms
                  INTO TABLE @DATA(lt_laststs)
                  FROM ztspppdt012 FOR ALL ENTRIES IN @lt_ztspppdt012
                  WHERE aufpl = @lt_ztspppdt012-aufpl
                    AND aplzl = @lt_ztspppdt012-aplzl
                    AND vornr = @lt_ztspppdt012-vornr.
                IF sy-subrc = 0.
                  SORT lt_laststs BY aufpl aplzl vornr stats DESCENDING.
                  DELETE ADJACENT DUPLICATES FROM lt_laststs
                    COMPARING aufpl aplzl vornr.
                ENDIF.
              ENDIF.
            ENDIF.

            LOOP AT lt_afvc INTO DATA(wa_afvc).
              MOVE-CORRESPONDING wa_afvc TO wa_operation.
              wa_operation-oprdesc = lv_oprdesc.
              READ TABLE lt_ztspppdt012 INTO DATA(wa_ztspppdt012)
                                        WITH KEY aufpl = wa_afvc-aufpl
                                                 aplzl = wa_afvc-aplzl.
              IF sy-subrc = 0.
                lv_stats = wa_ztspppdt012-stats.
                SHIFT lv_stats LEFT DELETING LEADING '0'.
                CONDENSE lv_stats.
                wa_operation-stats = lv_stats.

                CLEAR lv_stats.
                lv_stats = lt_laststs[ aufpl = wa_operation-aufpl
                                       aplzl = wa_operation-aplzl
                                       vornr = wa_operation-vornr ]-stats.
                SHIFT lv_stats LEFT DELETING LEADING '0'.
                CONDENSE lv_stats.

                IF wa_operation-stats = lv_stats AND wa_operation-stats NE '40'.
                  CLEAR wa_operation-laststs.
                ELSE.
                  wa_operation-laststs = lv_stats.
                ENDIF.
              ELSE.
                IF lv_plant = '0102'.
                  wa_operation-stats = '20'.
                ELSE.
                  IF ls_ztspppdt013 IS INITIAL.
                    wa_operation-stats = '20'.
                  ENDIF.
                ENDIF.
              ENDIF.

              IF wa_operation-stats IN lr_stats.
                CLEAR lv_name.
                CONCATENATE wa_afvc-mandt wa_afvc-aufpl wa_afvc-aplzl
                  INTO lv_name.
                CALL FUNCTION 'READ_TEXT'
                  EXPORTING
                    id                      = lv_id
                    language                = sy-langu
                    name                    = lv_name
                    object                  = lv_object
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
                  wa_operation-ltxa2 = lt_lines[ 2 ]-tdline.
                  wa_operation-tdname = lv_name.
                ENDIF.

                APPEND wa_operation TO lt_operation.
                CLEAR wa_operation.
              ENDIF.
            ENDLOOP.

            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_operation
              CHANGING
                cr_data = er_entityset.
          ENDIF.
        ENDIF.

      WHEN 'OprConfSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          LOOP AT it_filter_select_options INTO wa_filter.
            CASE wa_filter-property.
              WHEN 'RoutingNo'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_aufpl = wa_filter_so-low.
              WHEN 'OperationType'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_oprdesc = wa_filter_so-low.
              WHEN 'OperationApps'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lr_stats = wa_filter-select_options.
            ENDCASE.
          ENDLOOP.

          SELECT * INTO TABLE lt_afvc
            FROM afvc WHERE aufpl = lv_aufpl
                        AND steus = 'ZP01'
            ORDER BY PRIMARY KEY.

          IF sy-subrc = 0.
            CASE lv_oprdesc.
              WHEN 'CB'.
                DELETE lt_afvc WHERE phseq(1) NE 'G'.
              WHEN 'CK'.
                DELETE lt_afvc WHERE phseq(1) NE 'D'.
              WHEN 'DECOCT'.
                DELETE lt_afvc WHERE phseq(1) NE 'E'.
              WHEN 'LIQUID MIXING'.
                DELETE lt_afvc WHERE phseq(1) NE 'L'.
              WHEN 'SEMI SOLID MIXING'.
                DELETE lt_afvc WHERE phseq(1) NE 'O'.
            ENDCASE.

            IF lt_afvc[] IS NOT INITIAL.
              lv_plant = lt_afvc[ 1 ]-werks.

              SELECT SINGLE aufnr plnbez INTO (lv_aufnr, lv_plnbez)
                FROM caufv WHERE aufpl = lv_aufpl.

              SELECT * INTO TABLE lt_ztspppdt012
                FROM ztspppdt012 FOR ALL ENTRIES IN lt_afvc
                WHERE aufpl = lt_afvc-aufpl
                  AND aplzl = lt_afvc-aplzl
                  AND stats IN lr_stats
                  AND ( actwh NE space AND actwh NE '0000' )
                ORDER BY PRIMARY KEY.
              IF sy-subrc = 0.
                SORT lt_ztspppdt012 BY aufpl aplzl stats DESCENDING.
                DELETE ADJACENT DUPLICATES FROM lt_ztspppdt012 COMPARING aufpl aplzl.

                SELECT * INTO TABLE @DATA(lt_ztspppdt014)
                  FROM ztspppdt014 FOR ALL ENTRIES IN @lt_ztspppdt012
                  WHERE aufnr = @lv_aufnr
                    AND vornr = @lt_ztspppdt012-vornr
*                    AND actwh = @lt_ztspppdt012-actwh
                  ORDER BY PRIMARY KEY.
              ENDIF.
            ENDIF.

            SORT lt_ztspppdt014 BY aufnr vornr wadah DESCENDING.

            LOOP AT lt_afvc INTO wa_afvc.
              MOVE-CORRESPONDING wa_afvc TO wa_operation.
              wa_operation-oprdesc = lv_oprdesc.
              READ TABLE lt_ztspppdt012 INTO wa_ztspppdt012
                                        WITH KEY aufpl = wa_afvc-aufpl
                                                 aplzl = wa_afvc-aplzl.
              IF sy-subrc = 0.
                lv_stats = wa_ztspppdt012-stats.
                SHIFT lv_stats LEFT DELETING LEADING '0'.
                CONDENSE lv_stats.
                wa_operation-stats = lv_stats.

                READ TABLE lt_ztspppdt014 INTO DATA(wa_ztspppdt014)
                                          WITH KEY aufnr = lv_aufnr
                                                   vornr = wa_ztspppdt012-vornr.
*                                                   actwh = wa_ztspppdt012-actwh.
                IF sy-subrc = 0.
                  IF wa_ztspppdt014-wadah NE wa_ztspppdt014-twadah.
                    CLEAR wa_operation.
                    CONTINUE.
                  ENDIF.
                ELSE.
                  CLEAR wa_operation.
                  CONTINUE.
                ENDIF.

              ELSE.
                CLEAR wa_operation.
                CONTINUE.
              ENDIF.

              IF wa_operation-stats IN lr_stats.
                APPEND wa_operation TO lt_operation.
                CLEAR wa_operation.
              ENDIF.
            ENDLOOP.

            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
              EXPORTING
                is_data = lt_operation
              CHANGING
                cr_data = er_entityset.
          ENDIF.
        ENDIF.

      WHEN 'wadahSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          LOOP AT it_filter_select_options INTO wa_filter.
            CASE wa_filter-property.
              WHEN 'RoutingNo'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_aufpl = wa_filter_so-low.
              WHEN 'ActivityNo'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_vornr = wa_filter_so-low.
              WHEN 'ControlRecipe'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_phseq = wa_filter_so-low.
              WHEN 'OperationType'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_oprdesc = wa_filter_so-low.
            ENDCASE.
          ENDLOOP.

          lv_phseq2 = lv_phseq.
          lv_phseq(1) = 'W'.

          SELECT a~aufpl, a~aplzl, a~vornr, a~ltxa1, a~phseq,
                 b~usr00, b~usr01
            INTO TABLE @DATA(lt_afvc_wadah)
            FROM afvc AS a JOIN afvu AS b ON a~aufpl = b~aufpl AND
                                             a~aplzl = b~aplzl
            WHERE a~aufpl = @lv_aufpl
              AND a~phseq = @lv_phseq
            ORDER BY a~aufpl, a~aplzl, a~vornr.

          IF sy-subrc = 0.
            SELECT * INTO TABLE @DATA(lt_resb_wadah)
              FROM resb FOR ALL ENTRIES IN @lt_afvc_wadah
              WHERE aufpl = @lt_afvc_wadah-aufpl
                AND vornr = @lt_afvc_wadah-vornr
                AND ( splkz = ' ' OR splkz = '1' )
              ORDER BY PRIMARY KEY.

            IF sy-subrc = 0.
              CASE lv_oprdesc.
                WHEN 'DECOCT'.
                  DELETE lt_resb_wadah WHERE sortf NE 'D'.
                WHEN OTHERS.
                  DELETE lt_resb_wadah WHERE sortf EQ 'D'.
              ENDCASE.

              lv_aufnr = lt_resb_wadah[ 1 ]-aufnr.

              SELECT SINGLE plnbez INTO lv_plnbez
                FROM afko WHERE aufnr = lv_aufnr.

              LOOP AT lt_afvc_wadah INTO DATA(wa_afvc_wadah).

                READ TABLE lt_resb_wadah INTO DATA(wa_resb_wadah)
                                         WITH KEY aufpl = wa_afvc_wadah-aufpl
                                                  vornr = wa_afvc_wadah-vornr.

                IF sy-subrc = 0.
                  wa_wadah-aufpl  = wa_afvc_wadah-aufpl.
                  wa_wadah-aplzl  = wa_afvc_wadah-aplzl.
                  wa_wadah-plnbez = lv_plnbez.
                  wa_wadah-aufnr  = wa_resb_wadah-aufnr.
                  wa_wadah-vornr  = wa_afvc_wadah-vornr.
                  wa_wadah-ltxa1  = wa_afvc_wadah-ltxa1.
                  wa_wadah-phseq  = wa_afvc_wadah-phseq.
                  wa_wadah-phseq2 = lv_phseq2.
                  wa_wadah-sortf  = wa_resb_wadah-sortf.
                  wa_wadah-oprdesc = lv_oprdesc.
                  IF wa_wadah-oprdesc = 'DECOCT'.
                    wa_wadah-ltxa1  = wa_afvc_wadah-usr01.
                  ENDIF.
                  APPEND wa_wadah TO lt_wadah.
                  CLEAR wa_wadah.
                ENDIF.
              ENDLOOP.

              CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
                EXPORTING
                  is_data = lt_wadah
                CHANGING
                  cr_data = er_entityset.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN 'MaterialSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          LOOP AT it_filter_select_options INTO wa_filter.
            CASE wa_filter-property.
              WHEN 'RoutingNo'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_aufpl = wa_filter_so-low.
              WHEN 'ActivityNo'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_vornr = wa_filter_so-low.
              WHEN 'OperationType'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_oprdesc = wa_filter_so-low.
            ENDCASE.
          ENDLOOP.

          SELECT * INTO TABLE @DATA(lt_resb_material)
            FROM resb WHERE aufpl = @lv_aufpl
                        AND vornr = @lv_vornr
                        AND splkz = '2'
            ORDER BY PRIMARY KEY.

          IF sy-subrc = 0.
            CASE lv_oprdesc.
              WHEN 'DECOCT'.
                DELETE lt_resb_material WHERE sortf NE 'D'.
              WHEN OTHERS.
                DELETE lt_resb_material WHERE sortf EQ 'D'.
            ENDCASE.

            IF lt_resb_material[] IS NOT INITIAL.
              SELECT aufnr, matnr, posnr, scanfl, scandt, scantm
                INTO TABLE @DATA(lt_zppresb_add)
                FROM zppresb_add FOR ALL ENTRIES IN @lt_resb_material
                WHERE aufnr = @lt_resb_material-aufnr
                  AND matnr = @lt_resb_material-matnr
                  AND posnr = @lt_resb_material-posnr
                ORDER BY PRIMARY KEY.

              SELECT * INTO TABLE @DATA(lt_ztspppdt011)
                FROM ztspppdt011 FOR ALL ENTRIES IN @lt_resb_material
                WHERE rsnum = @lt_resb_material-rsnum
                  AND rspos = @lt_resb_material-rspos
                ORDER BY PRIMARY KEY.

              SELECT * INTO TABLE @DATA(lt_makt)
                FROM makt FOR ALL ENTRIES IN @lt_resb_material
                WHERE matnr = @lt_resb_material-matnr
                  AND spras = @sy-langu
                ORDER BY PRIMARY KEY.

              SELECT mblnr, mjahr, zeile, bwart, matnr, werks, lgort,
                     charg, aufnr, rsnum, rspos, smbln, sjahr, smblp
                INTO TABLE @DATA(lt_mseg)
                FROM mseg FOR ALL ENTRIES IN @lt_resb_material
                WHERE rsnum = @lt_resb_material-rsnum
                  AND rspos = @lt_resb_material-rspos
                  AND bwart IN ('261','262')
                ORDER BY PRIMARY KEY.
              IF sy-subrc = 0.
                LOOP AT lt_mseg INTO DATA(ls_mseg) WHERE bwart = '262'.
                  DELETE lt_mseg WHERE mblnr = ls_mseg-smbln
                                   AND mjahr = ls_mseg-sjahr
                                   AND zeile = ls_mseg-smblp.
                ENDLOOP.
              ENDIF.

              "Exclude Cangkang Kapsul
              SELECT * INTO TABLE @DATA(lt_ztspppdt006)
                FROM ztspppdt006 WHERE excty = 'P'.

              LOOP AT lt_resb_material INTO DATA(wa_resb_material).
                IF line_exists( lt_ztspppdt006[ matnr = wa_resb_material-matnr ] ).
                  CONTINUE.
                ENDIF.

                IF wa_resb_material-potx2 IS INITIAL.
                  wa_resb_material-potx2 = '0'.
                ENDIF.

                IF wa_resb_material-potx2 GT lv_potx2.
                  lv_potx2 = wa_resb_material-potx2.
                ENDIF.

                IF wa_resb_material-wempf = 'T'.
                  wa_resb_material-wempf = 'W'.
                ENDIF.

                IF wa_resb_material-wempf = 'W'.
                  DATA(lv_wempf) = wa_resb_material-wempf.
                ELSE.
                  lv_wempf = 'F'.
                ENDIF.

                READ TABLE lt_material ASSIGNING FIELD-SYMBOL(<fs_material>)
                                       WITH KEY aufpl = wa_resb_material-aufpl
                                                vornr = wa_resb_material-vornr
                                                posnr = wa_resb_material-posnr
                                                wempf = lv_wempf.

                IF sy-subrc = 0 AND wa_resb_material-wempf = 'W'.
                  ADD wa_resb_material-erfmg TO <fs_material>-erfmg.

                ELSE.
                  IF wa_resb_material-wempf = 'W' OR wa_resb_material-wempf = 'T'.
                    APPEND INITIAL LINE TO lt_material ASSIGNING <fs_material>.
                    MOVE-CORRESPONDING wa_resb_material TO <fs_material>.
                    CLEAR <fs_material>-charg.
                    <fs_material>-oprdesc = lv_oprdesc.
*                    READ TABLE lt_makt INTO DATA(wa_makt) WITH KEY matnr = <fs_material>-matnr.
*                    <fs_material>-maktx = wa_makt-maktx.
                    <fs_material>-maktx = lt_makt[ matnr = <fs_material>-matnr ]-maktx.
                    <fs_material>-scanfl = VALUE #( lt_zppresb_add[ aufnr = wa_resb_material-aufnr
                                                                    matnr = wa_resb_material-matnr
                                                                    posnr = wa_resb_material-posnr ]-scanfl
                                                                    OPTIONAL ).
                    <fs_material>-scandt = VALUE #( lt_zppresb_add[ aufnr = wa_resb_material-aufnr
                                                                    matnr = wa_resb_material-matnr
                                                                    posnr = wa_resb_material-posnr ]-scandt
                                                                    OPTIONAL ).
                    <fs_material>-scantm = VALUE #( lt_zppresb_add[ aufnr = wa_resb_material-aufnr
                                                                    matnr = wa_resb_material-matnr
                                                                    posnr = wa_resb_material-posnr ]-scantm
                                                                    OPTIONAL ).

                  ELSE.
*                    DATA(lv_count) = REDUCE i( INIT i = 0 FOR wa IN lt_ztspppdt011
*                                     WHERE ( rsnum = wa_resb_material-rsnum AND
*                                             rspos = wa_resb_material-rspos )
*                                     NEXT i = i + 1 ).
*                    READ TABLE lt_ztspppdt011 INTO DATA(wa_ztspppdt011) INDEX 1.

                    DATA(lv_mblnr) = VALUE #( lt_mseg[ rsnum = wa_resb_material-rsnum
                                                       rspos = wa_resb_material-rspos ]-mblnr OPTIONAL ).
                    DATA(lv_mjahr) = VALUE #( lt_mseg[ rsnum = wa_resb_material-rsnum
                                                       rspos = wa_resb_material-rspos ]-mjahr OPTIONAL ).

                    READ TABLE lt_ztspppdt011 INTO DATA(wa_ztspppdt011)
                                              WITH KEY matnr = wa_resb_material-matnr
                                                       charg = wa_resb_material-charg.
                    IF sy-subrc = 0.
                      SELECT MAX( zeile ) INTO @DATA(lv_count)
                        FROM ztspppdt011 WHERE rsnum = @wa_resb_material-rsnum
                                           AND matnr = @wa_resb_material-matnr
                                           AND charg = @wa_resb_material-charg
                                           AND mblnr = @lv_mblnr
                                           AND mjahr = @lv_mjahr.
*                                           AND erdat = @wa_ztspppdt011-erdat
*                                           AND ertim = @wa_ztspppdt011-ertim.
                      IF sy-subrc = 0.
                        IF lv_count IS INITIAL.
                          lv_count = 1.
                        ENDIF.
                        SHIFT lv_count LEFT DELETING LEADING '0'.
                        CONDENSE lv_count.
                      ENDIF.
                    ENDIF.

                    LOOP AT lt_ztspppdt011 INTO wa_ztspppdt011
                                            WHERE rsnum = wa_resb_material-rsnum
                                              AND rspos = wa_resb_material-rspos.
                      APPEND INITIAL LINE TO lt_material ASSIGNING <fs_material>.
                      MOVE-CORRESPONDING wa_resb_material TO <fs_material>.
                      <fs_material>-erfmg = wa_ztspppdt011-erfmg.
                      <fs_material>-erfme = wa_ztspppdt011-erfme.
                      <fs_material>-oprdesc = lv_oprdesc.
*                      READ TABLE lt_makt INTO wa_makt WITH KEY matnr = <fs_material>-matnr.
*                      <fs_material>-maktx = wa_makt-maktx.
                      <fs_material>-maktx = lt_makt[ matnr = <fs_material>-matnr ]-maktx.
                      <fs_material>-wempf = 'F'.
                      <fs_material>-scanfl = wa_ztspppdt011-scanfl.
                      <fs_material>-scandt = wa_ztspppdt011-scandt.
                      <fs_material>-scantm = wa_ztspppdt011-scantm.
                      <fs_material>-mblnr  = wa_ztspppdt011-mblnr.

                      DATA(lv_zeile) = wa_ztspppdt011-zeile.
                      SHIFT lv_zeile LEFT DELETING LEADING '0'.
                      CONDENSE lv_zeile.

                      CONCATENATE lv_zeile lv_count INTO <fs_material>-cntr SEPARATED BY '/'.
                    ENDLOOP.
                  ENDIF.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.

          "Get data dumping
          CASE lv_oprdesc.
            WHEN 'CK'.
              SELECT a~aufpl, a~aplzl, a~stats, a~vornr, a~aufnr, a~rooms,
                     a~dates, a~times, a~datef, a~timef, a~operator, a~pengawas,
                     b~actwh, b~wadah, b~twadah, b~netto, b~meins, b~lotnr, b~scanfl,
                     b~scandt, b~scantm,
                     c~plnty, c~plnnr, c~plnkn, c~ltxa1, c~phseq, c~werks
                INTO TABLE @DATA(lt_dumping)
                FROM ztspppdt012 AS a JOIN ztspppdt014 AS b ON a~aufnr = b~aufnr AND
                                                               a~vornr = b~vornr
                                      JOIN afvc AS c ON a~aufpl = c~aufpl AND
                                                        a~aplzl = c~aplzl
                WHERE a~aufpl = @lv_aufpl
                  AND a~stats IN ('0031','0040')
                ORDER BY a~aufpl, a~aplzl, a~stats, a~vornr, b~actwh, b~wadah.

            WHEN OTHERS.
              SELECT DISTINCT * INTO TABLE @DATA(lt_012)
                FROM ztspppdt012 WHERE aufpl = @lv_aufpl
                                   AND stats IN ('0031','0040')
                ORDER BY PRIMARY KEY.

              IF sy-subrc = 0.
                SORT lt_012 BY aufpl aplzl vornr.
                DELETE ADJACENT DUPLICATES FROM lt_012 COMPARING aufpl aplzl vornr.

                SELECT DISTINCT aufpl, aplzl, plnty, plnnr, plnkn, ltxa1, phseq, werks
                  INTO TABLE @DATA(lt_afvc2)
                  FROM afvc FOR ALL ENTRIES IN @lt_012
                  WHERE aufpl = @lt_012-aufpl
                    AND aplzl = @lt_012-aplzl
                  ORDER BY PRIMARY KEY.

                DATA(lv_ordno) = lt_012[ 1 ]-aufnr.
                SELECT * INTO TABLE @DATA(lt_014)
                  FROM ztspppdt014 WHERE aufnr = @lv_ordno
                                     AND actwh = @lv_vornr
                  ORDER BY PRIMARY KEY.

                LOOP AT lt_012 INTO DATA(lw_012).
                  LOOP AT lt_014 INTO DATA(lw_014) WHERE aufnr = lw_012-aufnr
                                                     AND vornr = lw_012-vornr.
                    APPEND INITIAL LINE TO lt_dumping ASSIGNING FIELD-SYMBOL(<fs_dumping>).
                    <fs_dumping>-aufpl      = lw_012-aufpl.
                    <fs_dumping>-aplzl      = lw_012-aplzl.
                    <fs_dumping>-stats      = lw_012-stats.
                    <fs_dumping>-vornr      = lw_012-vornr.
                    <fs_dumping>-aufnr      = lw_012-aufnr.
                    <fs_dumping>-rooms      = lw_012-rooms.
                    <fs_dumping>-dates      = lw_012-dates.
                    <fs_dumping>-times      = lw_012-times.
                    <fs_dumping>-datef      = lw_012-datef.
                    <fs_dumping>-timef      = lw_012-timef.
                    <fs_dumping>-operator   = lw_012-operator.
                    <fs_dumping>-pengawas   = lw_012-pengawas.
                    <fs_dumping>-actwh      = lw_014-actwh.
                    <fs_dumping>-wadah      = lw_014-wadah.
                    <fs_dumping>-twadah     = lw_014-twadah.
                    <fs_dumping>-netto      = lw_014-netto.
                    <fs_dumping>-meins      = lw_014-meins.
                    <fs_dumping>-lotnr      = lw_014-lotnr.
                    <fs_dumping>-scanfl     = lw_014-scanfl.
                    <fs_dumping>-scandt     = lw_014-scandt.
                    <fs_dumping>-scantm     = lw_014-scantm.
                    <fs_dumping>-plnty      = VALUE #( lt_afvc2[ aufpl = lw_012-aufpl aplzl = lw_012-aplzl ]-plnty OPTIONAL ).
                    <fs_dumping>-plnnr      = VALUE #( lt_afvc2[ aufpl = lw_012-aufpl aplzl = lw_012-aplzl ]-plnnr OPTIONAL ).
                    <fs_dumping>-plnkn      = VALUE #( lt_afvc2[ aufpl = lw_012-aufpl aplzl = lw_012-aplzl ]-plnkn OPTIONAL ).
                    <fs_dumping>-ltxa1      = VALUE #( lt_afvc2[ aufpl = lw_012-aufpl aplzl = lw_012-aplzl ]-ltxa1 OPTIONAL ).
                    <fs_dumping>-phseq      = VALUE #( lt_afvc2[ aufpl = lw_012-aufpl aplzl = lw_012-aplzl ]-phseq OPTIONAL ).
                    <fs_dumping>-werks      = VALUE #( lt_afvc2[ aufpl = lw_012-aufpl aplzl = lw_012-aplzl ]-werks OPTIONAL ).
                  ENDLOOP.
                ENDLOOP.
              ENDIF.
          ENDCASE.

          IF lt_dumping[] IS NOT INITIAL.
            DATA(lt_dumping_tmp) = lt_dumping.
            SORT lt_dumping_tmp BY vornr.
            DELETE ADJACENT DUPLICATES FROM lt_dumping_tmp COMPARING vornr.

            SELECT SINGLE phseq INTO @DATA(lv_phseq_tmp)
              FROM afvc WHERE aufpl = @lv_aufpl
                          AND vornr = @lv_vornr.

            IF sy-subrc = 0.
              DATA(lv_phseq_tmp2) = lv_phseq_tmp.
              lv_phseq_tmp2(1) = '%'.
              SELECT DISTINCT plnty, plnnr, plnkn, vornr, phseq, usr03
                INTO TABLE @DATA(lt_plpo_tmp)
                FROM plpo FOR ALL ENTRIES IN @lt_dumping_tmp
                WHERE plnty = @lt_dumping_tmp-plnty
                  AND plnnr = @lt_dumping_tmp-plnnr
                  AND phseq LIKE @lv_phseq_tmp2
                  AND phseq NE @lv_phseq_tmp.

              IF sy-subrc = 0.
                DELETE lt_plpo_tmp WHERE usr03 IS INITIAL.
                DATA(lw_plpo_tmp) = lt_plpo_tmp[ 1 ].
                CLEAR: lv_phseq1,lv_phseq2,lv_phseq3.
                SPLIT lw_plpo_tmp-usr03 AT ';' INTO lv_phseq1 lv_phseq2 lv_phseq3.
                DELETE lt_dumping_tmp WHERE phseq NE lv_phseq1 AND
                                            phseq NE lv_phseq2 AND
                                            phseq NE lv_phseq3.

                IF lt_dumping_tmp[] IS INITIAL.
                  CLEAR lt_dumping.
                ELSE.
                  DATA(lr_vornr) = VALUE rseloption( FOR wa_dump IN lt_dumping_tmp
                                                   ( sign = 'I' option = 'EQ' low = wa_dump-vornr ) ).
                  DELETE lt_dumping WHERE vornr NOT IN lr_vornr.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

          IF lt_dumping[] IS NOT INITIAL.
            LOOP AT lt_dumping INTO DATA(lw_dumping).
              APPEND INITIAL LINE TO lt_material ASSIGNING <fs_material>.
              <fs_material>-aufpl = lw_dumping-aufpl.
              <fs_material>-vornr = lv_vornr.
              <fs_material>-erfmg = lw_dumping-netto.
              <fs_material>-erfme = lw_dumping-meins.
              <fs_material>-maktx = lw_dumping-ltxa1.
              <fs_material>-actdmp = lw_dumping-vornr.
              <fs_material>-scanfl = lw_dumping-scanfl.
              <fs_material>-scandt = lw_dumping-scandt.
              <fs_material>-scantm = lw_dumping-scantm.
              <fs_material>-vornr_wh = lw_dumping-actwh.
              <fs_material>-oprdesc = lv_oprdesc.

              IF lw_dumping-werks = '0101'.
                CASE <fs_material>-oprdesc.
                  WHEN 'CK'.
                    <fs_material>-potx2 = '0'.
                  WHEN 'CB'.
                    <fs_material>-potx2 = lv_potx2 + 1.
                ENDCASE.
              ELSE.
                <fs_material>-potx2 = '0'.
              ENDIF.
              CONDENSE <fs_material>-potx2.

              IF lw_dumping-lotnr IS NOT INITIAL.
                SHIFT lw_dumping-lotnr LEFT DELETING LEADING '0'.
                CONDENSE lw_dumping-lotnr.
                CONCATENATE <fs_material>-maktx 'Lot' lw_dumping-lotnr INTO <fs_material>-maktx
                  SEPARATED BY space.
              ENDIF.

              SHIFT lw_dumping-wadah LEFT DELETING LEADING '0'.
              SHIFT lw_dumping-twadah LEFT DELETING LEADING '0'.
              CONDENSE: lw_dumping-wadah, lw_dumping-twadah.

              CONCATENATE lw_dumping-wadah lw_dumping-twadah INTO <fs_material>-cntr SEPARATED BY '/'.
            ENDLOOP.
          ENDIF.

          lv_werks = VALUE #( lt_resb_material[ 1 ]-werks OPTIONAL ).
          lv_aufnr = VALUE #( lt_resb_material[ 1 ]-aufnr OPTIONAL ).
          DATA(lv_granul) = 'Granul%'.
          SELECT * INTO TABLE @DATA(lt_ztspppdt007)
            FROM ztspppdt007 WHERE werks = @lv_werks
                               AND aufnr = @lv_aufnr
                               AND vornr = @lv_vornr
                               AND maktx LIKE @lv_granul.
          LOOP AT lt_ztspppdt007 INTO DATA(ls_ztspppdt007).
            lv_maktx = ls_ztspppdt007-maktx(13).
            TRANSLATE lv_maktx TO UPPER CASE.
            IF lv_maktx NE 'GRANUL REWORK'.
              CONTINUE.
            ENDIF.
            APPEND INITIAL LINE TO lt_material ASSIGNING <fs_material>.
            <fs_material>-aufpl = lv_aufpl.
            <fs_material>-vornr = lv_vornr.
            <fs_material>-erfmg = ls_ztspppdt007-netto.
            <fs_material>-erfme = ls_ztspppdt007-meins.
            <fs_material>-maktx = ls_ztspppdt007-maktx.
            <fs_material>-potx2 = |{ ls_ztspppdt007-aufnr };{ ls_ztspppdt007-vornr };{ ls_ztspppdt007-astad };{ ls_ztspppdt007-astau };G|.
*            <fs_material>-actdmp = lw_dumping-vornr.
            <fs_material>-scanfl = ls_ztspppdt007-scanfl.
            <fs_material>-scandt = ls_ztspppdt007-scandt.
            <fs_material>-scantm = ls_ztspppdt007-scantm.
*            <fs_material>-vornr_wh = lw_dumping-actwh.
*            <fs_material>-oprdesc = lv_oprdesc.
          ENDLOOP.

          DATA: lv_lines TYPE i.

* Cek hasil timbang
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          IF line_exists( lt_material[ scanfl = space ] ).
          ELSEIF lv_oprdesc = 'CK' OR lv_oprdesc = 'CB'.
            SELECT SINGLE plnty, plnnr, phseq
              INTO @DATA(ls_afvc_tmp)
              FROM afvc WHERE aufpl = @lv_aufpl
                          AND vornr = @lv_vornr.
            IF sy-subrc = 0.
              lv_phseq_tmp2 = ls_afvc_tmp-phseq.
              lv_phseq_tmp2(1) = '%'.
              SELECT DISTINCT a~plnty a~plnnr a~plnkn a~vornr a~phseq usr03
                INTO TABLE lt_plpo_tmp
                FROM plpo AS a JOIN afvc AS b ON b~plnty = a~plnty AND
                                                 b~plnnr = a~plnnr AND
                                                 b~plnkn = a~plnkn AND
                                                 b~zaehl = a~zaehl
                WHERE a~plnty = ls_afvc_tmp-plnty
                  AND a~plnnr = ls_afvc_tmp-plnnr
                  AND a~phseq LIKE lv_phseq_tmp2
*                  AND a~phseq NE ls_afvc_tmp-phseq
                  AND b~steus = 'ZP01'.
              IF sy-subrc = 0.
*                lv_lines = lines( lt_plpo_tmp ).
*                IF lv_lines GT 1.
                CASE lv_oprdesc.
                  WHEN 'CK'.
                    DATA(lv_phseq_tmp3) = ls_afvc_tmp-phseq.
                    lv_phseq_tmp3(1) = 'G'.
                    IF NOT line_exists( lt_plpo_tmp[ phseq = lv_phseq_tmp3 ] ).
                      lv_phseq_tmp3(1) = 'D'.
                    ENDIF.
                  WHEN 'CB'.
                    lv_phseq_tmp3 = ls_afvc_tmp-phseq.
                    lv_phseq_tmp3(1) = 'G'.
                ENDCASE.

                IF line_exists( lt_plpo_tmp[ phseq = lv_phseq_tmp3 ] ).
                  DATA(lv_phseq_tmp4) = ls_afvc_tmp-phseq.
                  lv_phseq_tmp4 = VALUE #( lt_plpo_tmp[ phseq = lv_phseq_tmp3 ]-usr03 OPTIONAL ).
                  IF lv_phseq_tmp4 IS NOT INITIAL.
*                    lv_phseq_tmp4 = VALUE #( lt_plpo_tmp[ phseq = lv_phseq_tmp3 ]-phseq OPTIONAL ).
*                  ENDIF.

                    SELECT SINGLE vornr INTO @DATA(lv_vornr_tmp)
                      FROM plpo WHERE plnty = @ls_afvc_tmp-plnty
                                  AND plnnr = @ls_afvc_tmp-plnnr
                                  AND phseq = @lv_phseq_tmp4
                                  AND steus = 'ZP01'.

*                  DATA(ls_plpo_tmp) = lt_plpo_tmp[ phseq = lv_phseq_tmp4 ].
                    DATA(lv_aufnr_tmp) = VALUE #( lt_resb_material[ 1 ]-aufnr OPTIONAL ).
                    SELECT * INTO TABLE lt_ztspppdt014
                      FROM ztspppdt014 WHERE aufnr = lv_aufnr_tmp
                                         AND vornr = lv_vornr_tmp.       "ls_plpo_tmp-vornr.
*                                         AND actwh = lv_vornr.
                    IF sy-subrc = 0.
                    ELSE.
                      CALL METHOD obj_msg_con->add_message_text_only
                        EXPORTING
                          iv_msg_type               = 'E'
                          iv_msg_text               = 'Hasil proses sebelumnya belum ditimbang'
                          iv_add_to_response_header = abap_true.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

          SORT lt_material BY potx2 matnr.

          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_material
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN 'WeighingActSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          LOOP AT it_filter_select_options INTO wa_filter.
            CASE wa_filter-property.
              WHEN 'RoutingNo'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_aufpl = wa_filter_so-low.
              WHEN 'InternalCntr'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                DATA(lv_aplzl) = wa_filter_so-low.
              WHEN 'ActivityNo'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_vornr = wa_filter_so-low.
              WHEN 'OperationType'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_oprdesc = wa_filter_so-low.
              WHEN 'OperationApps'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lr_stats = wa_filter-select_options.
            ENDCASE.
          ENDLOOP.

          SELECT * INTO TABLE lt_ztspppdt012
            FROM ztspppdt012 WHERE aufpl  = lv_aufpl
                               AND aplzl  = lv_aplzl
                               AND vornr  = lv_vornr
                               AND stats IN lr_stats
                               AND ( actwh NE space AND actwh NE '0000' ).

          IF sy-subrc = 0.
            SELECT * INTO TABLE lt_afvc
              FROM afvc FOR ALL ENTRIES IN lt_ztspppdt012
              WHERE aufpl = lt_ztspppdt012-aufpl
                AND vornr = lt_ztspppdt012-actwh.

            IF sy-subrc = 0.
              SELECT * INTO TABLE @DATA(lt_plpo)
                FROM plpo FOR ALL ENTRIES IN @lt_afvc
                WHERE plnty = @lt_afvc-plnty
                  AND plnnr = @lt_afvc-plnnr
                  AND plnkn = @lt_afvc-plnkn.

              LOOP AT lt_ztspppdt012 INTO DATA(ls_ztspppdt012).
                SHIFT ls_ztspppdt012-stats LEFT DELETING LEADING '0'.
                CONDENSE ls_ztspppdt012-stats.

                READ TABLE lt_afvc INTO DATA(ls_afvc)
                                   WITH KEY aufpl = ls_ztspppdt012-aufpl
                                            vornr = ls_ztspppdt012-actwh.
                IF sy-subrc = 0.
                  IF ls_afvc-phseq(1) NE 'W'.
                    DELETE lt_afvc WHERE aufpl = ls_ztspppdt012-aufpl
                                     AND vornr = ls_ztspppdt012-actwh.
                    CONTINUE.
                  ENDIF.
                ELSE.
                  CONTINUE.
                ENDIF.

                READ TABLE lt_plpo INTO DATA(ls_plpo)
                                   WITH KEY plnty = ls_afvc-plnty
                                            plnnr = ls_afvc-plnnr
                                            plnkn = ls_afvc-plnkn.

                APPEND INITIAL LINE TO lt_weighingact ASSIGNING FIELD-SYMBOL(<fs_weighingact>).
                <fs_weighingact>-aufpl     = ls_ztspppdt012-aufpl.
                <fs_weighingact>-aplzl     = ls_ztspppdt012-aplzl.
                <fs_weighingact>-vornr     = ls_ztspppdt012-vornr.
                <fs_weighingact>-vornr_wh  = ls_ztspppdt012-actwh.
                <fs_weighingact>-phseq     = ls_afvc-phseq.
                <fs_weighingact>-oprdesc   = lv_oprdesc.
                <fs_weighingact>-stats     = ls_ztspppdt012-stats.
                CASE lv_oprdesc.
                  WHEN 'DECOCT'.
                    <fs_weighingact>-ltxa1 = ls_plpo-usr01.
                  WHEN OTHERS.
                    <fs_weighingact>-ltxa1 = ls_plpo-usr00.
                ENDCASE.

                IF <fs_weighingact>-ltxa1 CA '123456789'.
                  <fs_weighingact>-lot = <fs_weighingact>-ltxa1+sy-fdpos(1).
                ELSE.
                ENDIF.

                CLEAR: ls_afvc,ls_plpo.
              ENDLOOP.
            ENDIF.
          ENDIF.

          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          SELECT SINGLE phseq INTO lv_phseq
            FROM afvc WHERE aufpl = lv_aufpl
                        AND aplzl = lv_aplzl.
          IF sy-subrc = 0.
            lv_phseq(1) = 'W'.
            SELECT aufpl, aplzl, vornr, ltxa1
              INTO TABLE @DATA(lt_afvc_cek)
              FROM afvc WHERE aufpl = @lv_aufpl
                          AND phseq = @lv_phseq.
            IF sy-subrc = 0.
              CLEAR lv_msg.
              SORT lt_afvc_cek BY aufpl vornr.
              LOOP AT lt_afvc_cek INTO DATA(ls_afvc_cek).
                IF line_exists( lt_ztspppdt012[ aufpl = ls_afvc_cek-aufpl
                                                actwh = ls_afvc_cek-vornr ] ).
                ELSE.
                  IF lv_msg IS INITIAL.
                    lv_msg = |Activity | & |{ ls_afvc_cek-vornr }|.
                  ELSE.
                    lv_msg = |{ lv_msg }| & |, | & |{ ls_afvc_cek-vornr }|.
                  ENDIF.
                ENDIF.
              ENDLOOP.

              IF lv_msg IS NOT INITIAL.
                lv_msg = |{ lv_msg }| & | Belum Complete Mixing|.
                CALL METHOD obj_msg_con->add_message_text_only
                  EXPORTING
                    iv_msg_type               = 'E'
                    iv_msg_text               = lv_msg
                    iv_add_to_response_header = abap_true.
              ENDIF.
            ENDIF.
          ENDIF.

          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_weighingact
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN 'LocationSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          LOOP AT it_filter_select_options INTO wa_filter.
            CASE wa_filter-property.
              WHEN 'RoutingNo'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_aufpl = wa_filter_so-low.
              WHEN 'InternalCntr'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_aplzl = wa_filter_so-low.
              WHEN 'ActivityNo'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_vornr = wa_filter_so-low.
            ENDCASE.
          ENDLOOP.

          SELECT MAX( stats ) INTO lv_stats
            FROM ztspppdt012 WHERE aufpl = lv_aufpl
                               AND aplzl = lv_aplzl
                               AND vornr = lv_vornr
                               AND stats IN ('0010','0020').

          IF sy-subrc = 0.
            SELECT SINGLE * INTO ls_ztspppdt012
              FROM ztspppdt012 WHERE aufpl = lv_aufpl
                                 AND aplzl = lv_aplzl
                                 AND vornr = lv_vornr
                                 AND stats = lv_stats.


            IF sy-subrc = 0.
              SELECT SINGLE aufpl, aplzl, plnfl, plnkn, plnal,
                            plnnr, zaehl, vornr, rueck, phseq,
                            steus, ltxa1, arbid, werks, plnty
                INTO @DATA(ls_afvc1)
                FROM afvc WHERE aufpl = @lv_aufpl
                            AND aplzl = @lv_aplzl
                            AND steus = 'ZP01'.

              IF sy-subrc = 0.
                SELECT SINGLE plnty, plnnr, plnkn, zaehl, pvzkn,
                              phflg, phseq, vornr, ltxa1, usr03
                  INTO @DATA(ls_plpo1)
                  FROM plpo WHERE plnty = @ls_afvc1-plnty
                              AND plnnr = @ls_afvc1-plnnr
                              AND plnkn = @ls_afvc1-plnkn
                              AND zaehl = @ls_afvc1-zaehl
                              AND steus = 'ZP01'.

                IF sy-subrc = 0 AND ls_plpo1-usr03 IS NOT INITIAL.
                  SPLIT ls_plpo1-usr03 AT ';' INTO lv_phseq1 lv_phseq2 lv_phseq3.

                  SELECT aufpl, aplzl, plnfl, plnkn, plnal,
                         plnnr, zaehl, vornr, rueck, phseq,
                         steus, ltxa1, arbid, werks, plnty
                    INTO TABLE @DATA(lt_afvc3)
                    FROM afvc WHERE aufpl = @lv_aufpl
                                AND plnty = @ls_plpo1-plnty
                                AND plnnr = @ls_plpo1-plnnr
                                AND phseq IN (@lv_phseq1, @lv_phseq2, @lv_phseq3)
                                AND steus = 'ZP01'.
                  IF sy-subrc = 0.
                    SELECT * INTO TABLE @DATA(lt_ztspppdt012_2)
                      FROM ztspppdt012 FOR ALL ENTRIES IN @lt_afvc3
                      WHERE aufpl = @lt_afvc3-aufpl
                        AND aplzl = @lt_afvc3-aplzl
                        AND vornr = @lt_afvc3-vornr
                        AND stats IN ('0031', '0040').

                    IF sy-subrc = 0.
                      SORT lt_ztspppdt012_2 BY aufpl aplzl vornr stats DESCENDING actwh DESCENDING.
                      DELETE ADJACENT DUPLICATES FROM lt_ztspppdt012_2 COMPARING aufpl aplzl vornr.

                      LOOP AT lt_afvc3 INTO DATA(ls_afvc2).
                        LOOP AT lt_ztspppdt012_2 INTO DATA(ls_ztspppdt012_2)
                                                 WHERE aufpl = ls_afvc2-aufpl AND
                                                       aplzl = ls_afvc2-aplzl AND
                                                       vornr = ls_afvc2-vornr.
*                          IF ls_ztspppdt012_2-stats = '0040'.
*                            SELECT SINGLE stats INTO @DATA(lv_stat_003)
*                              FROM ztspppdt012 WHERE aufpl = @ls_ztspppdt012-aufpl
*                                                 AND aplzl = @ls_ztspppdt012-aplzl
*                                                 AND vornr = @ls_ztspppdt012-vornr
*                                                 AND stats LIKE '003%'.
*                            IF sy-subrc = 0.
*                              SELECT SINGLE stats INTO @DATA(lv_stat_compare1)
*                                FROM ztspppdt012 WHERE aufpl = @ls_ztspppdt012-aufpl
*                                                   AND aplzl = @ls_ztspppdt012-aplzl
*                                                   AND vornr = @ls_ztspppdt012-vornr
*                                                   AND stats LIKE '003%'
*                                                   AND actwh = @space.
*
*                              SELECT SINGLE stats INTO @DATA(lv_stat_compare2)
*                                FROM ztspppdt012 WHERE aufpl = @ls_ztspppdt012-aufpl
*                                                   AND aplzl = @ls_ztspppdt012-aplzl
*                                                   AND vornr = @ls_ztspppdt012-vornr
*                                                   AND stats LIKE '003%'
*                                                   AND actwh = @ls_ztspppdt012_2-vornr.
*                            ELSE.
*                              lv_stat_compare1 = ls_ztspppdt012-stats.
*                              lv_stat_compare2 = ls_ztspppdt012_2-stats.
*                            ENDIF.
*                          ELSE.
*                          lv_stat_compare1 = ls_ztspppdt012-stats.
*                          lv_stat_compare2 = ls_ztspppdt012_2-stats.
*                          ENDIF.

*                          IF lv_stat_compare1 NE lv_stat_compare2.
                          IF sy-tabix = 1.
                            "#1
                            APPEND INITIAL LINE TO lt_location ASSIGNING FIELD-SYMBOL(<fs_location>).
                            MOVE-CORRESPONDING ls_ztspppdt012 TO <fs_location>.
                            <fs_location>-ltxa1 = ls_afvc1-ltxa1.
                            CONCATENATE 'Staging' <fs_location>-rooms INTO <fs_location>-rooms
                              SEPARATED BY space.
                          ENDIF.

                          "#2
                          APPEND INITIAL LINE TO lt_location ASSIGNING <fs_location>.
                          MOVE-CORRESPONDING ls_ztspppdt012_2 TO <fs_location>.
                          <fs_location>-ltxa1 = ls_afvc2-ltxa1.
                          CONCATENATE 'Staging' <fs_location>-rooms INTO <fs_location>-rooms
                            SEPARATED BY space.
*                          ENDIF.
                        ENDLOOP.
                      ENDLOOP.
                    ENDIF.
                  ENDIF.
                ENDIF.

                CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
                  EXPORTING
                    is_data = lt_location
                  CHANGING
                    cr_data = er_entityset.
              ENDIF.
            ELSE.
              CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
                EXPORTING
                  is_data = lt_location
                CHANGING
                  cr_data = er_entityset.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.
    DATA: lt_deep_entity TYPE TABLE OF zcl_zdmp_get_order_mpc_ext=>ts_deep_entity,
          wa_deep_entity LIKE LINE OF lt_deep_entity.

    DATA: lt_deep_2 TYPE TABLE OF zcl_zdmp_get_order_mpc_ext=>ts_deep_2,
          wa_deep_2 LIKE LINE OF lt_deep_2.

    DATA: lt_wadah TYPE TABLE OF zcl_zdmp_get_order_mpc_ext=>ts_deep_wadah,
          wa_wadah LIKE LINE OF lt_wadah.

    DATA: wa_operation     TYPE zcl_zdmp_get_order_mpc_ext=>ts_deep_operation,
          wa_material      TYPE zcl_zdmp_get_order_mpc_ext=>ts_material,
          wa_operationdesc TYPE zcl_zdmp_get_order_mpc_ext=>ts_operationdesc.

    DATA: lv_strdate TYPE datum,
          lv_werks   TYPE werks_d,
          lv_plnbez  TYPE matnr,
          lv_oprdesc TYPE char20,
          lv_aufpl   TYPE co_aufpl,
          lv_vornr   TYPE vornr,
          lv_phseq   TYPE phseq,
          lv_maktx   TYPE maktx,
          lv_charg   TYPE charg_d.

    DATA: lr_strdate TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_plnbez  TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_werks   TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_oprdesc TYPE STANDARD TABLE OF /iwbep/s_cod_select_option,
          lr_charg   TYPE STANDARD TABLE OF /iwbep/s_cod_select_option.

    CASE iv_entity_set_name.
      WHEN 'OrderSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          LOOP AT it_filter_select_options INTO DATA(wa_filter).
            CASE wa_filter-property.
              WHEN 'StartDate'.
                READ TABLE wa_filter-select_options INTO DATA(wa_filter_so) INDEX 1.
                lv_strdate = wa_filter_so-low.
              WHEN 'Material'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_plnbez = wa_filter_so-low.
              WHEN 'Plant'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_werks = wa_filter_so-low.
              WHEN 'OperationType'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_oprdesc = wa_filter_so-low.
            ENDCASE.
          ENDLOOP.

          SELECT SINGLE maktx INTO lv_maktx
            FROM makt WHERE matnr = lv_plnbez
                        AND spras = sy-langu.

          "Get Order
          SELECT * INTO TABLE @DATA(lt_cdsv02)
            FROM zdmp_cdsv02
            WHERE strdate = @lv_strdate
              AND plnbez  = @lv_plnbez
              AND werks   = @lv_werks.

          IF sy-subrc = 0.
            SELECT DISTINCT * INTO TABLE @DATA(lt_resb)
              FROM resb FOR ALL ENTRIES IN @lt_cdsv02
              WHERE aufnr = @lt_cdsv02-aufnr
              ORDER BY PRIMARY KEY.

            IF sy-subrc = 0.
              SORT lt_resb BY rsnum rspos.
              DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING rsnum.

              SELECT * INTO TABLE @DATA(lt_afvc)
                FROM afvc FOR ALL ENTRIES IN @lt_resb
                WHERE aufpl = @lt_resb-aufpl
                  AND steus = 'ZP01'
                ORDER BY PRIMARY KEY.

              CASE lv_oprdesc.
                WHEN 'CB'.
                  DELETE lt_afvc WHERE phseq(1) NE 'G'.
                WHEN 'CK'.
                  DELETE lt_afvc WHERE phseq(1) NE 'D'.
                WHEN 'DECOCT'.
                  DELETE lt_afvc WHERE phseq(1) NE 'E'.
                WHEN 'LIQUID MIXING'.
                  DELETE lt_afvc WHERE phseq(1) NE 'L'.
                WHEN 'SEMI SOLID MIXING'.
                  DELETE lt_afvc WHERE phseq(1) NE 'O'.
              ENDCASE.
            ENDIF.
          ENDIF.

          "Get Wadah
          DATA: lt_afvc2 TYPE STANDARD TABLE OF afvc.

          lt_afvc2[] = lt_afvc[].
          IF lt_afvc2[] IS NOT INITIAL.
            LOOP AT lt_afvc2 ASSIGNING FIELD-SYMBOL(<fs_afvc2>).
              CONCATENATE 'W' <fs_afvc2>-phseq+1(1) INTO <fs_afvc2>-phseq.
            ENDLOOP.

            SELECT * INTO TABLE @DATA(lt_afvc_wadah)
              FROM afvc FOR ALL ENTRIES IN @lt_afvc2
              WHERE aufpl = @lt_afvc2-aufpl
                AND phseq = @lt_afvc2-phseq
              ORDER BY PRIMARY KEY.

            IF sy-subrc = 0.
              SELECT * INTO TABLE @DATA(lt_resb2)
                FROM resb FOR ALL ENTRIES IN @lt_afvc_wadah
                WHERE aufpl = @lt_afvc_wadah-aufpl
                  AND vornr = @lt_afvc_wadah-vornr
                  AND ( splkz = ' ' OR splkz = '1' )
                ORDER BY PRIMARY KEY.

              IF sy-subrc = 0.
                CASE lv_oprdesc.
                  WHEN 'DECOCT'.
                    DELETE lt_resb2 WHERE sortf NE 'D'.
                  WHEN OTHERS.
                    DELETE lt_resb2 WHERE sortf EQ 'D'.
                ENDCASE.
              ENDIF.
            ENDIF.
          ENDIF.

          "Get Material
          IF lt_resb2[] IS NOT INITIAL.
            SELECT * INTO TABLE @DATA(lt_resb_material)
              FROM resb FOR ALL ENTRIES IN @lt_resb2
              WHERE aufpl = @lt_resb2-aufpl
                AND vornr = @lt_resb2-vornr
                AND splkz = '2'
                AND ( wempf = ' ' OR wempf = 'F' )
              ORDER BY PRIMARY KEY.

            IF sy-subrc = 0.
              CASE lv_oprdesc.
                WHEN 'DECOCT'.
                  DELETE lt_resb_material WHERE sortf NE 'D'.
                WHEN OTHERS.
                  DELETE lt_resb_material WHERE sortf EQ 'D'.
              ENDCASE.

              IF lt_resb_material[] IS NOT INITIAL.
                SELECT * INTO TABLE @DATA(lt_ztspppdt011)
                  FROM ztspppdt011 FOR ALL ENTRIES IN @lt_resb_material
                  WHERE rsnum = @lt_resb_material-rsnum
                    AND rspos = @lt_resb_material-rspos
                  ORDER BY PRIMARY KEY.

                SELECT * INTO TABLE @DATA(lt_makt)
                  FROM makt FOR ALL ENTRIES IN @lt_resb_material
                  WHERE matnr = @lt_resb_material-matnr
                    AND spras = @sy-langu
                  ORDER BY PRIMARY KEY.
              ENDIF.
            ENDIF.
          ENDIF.


          "Collect deep entity
          LOOP AT lt_cdsv02 INTO DATA(wa_cdsv02).
            MOVE-CORRESPONDING wa_cdsv02 TO wa_deep_entity.
            wa_deep_entity-oprdesc = lv_oprdesc.
            wa_deep_entity-maktx   = lv_maktx.

            READ TABLE lt_resb INTO DATA(wa_resb)
                               WITH KEY aufnr = wa_cdsv02-aufnr.
            IF sy-subrc = 0.
              wa_deep_entity-aufpl = wa_resb-aufpl.
              wa_deep_entity-aplzl = wa_resb-aplzl.
            ENDIF.

            LOOP AT lt_afvc INTO DATA(wa_afvc) WHERE aufpl = wa_deep_entity-aufpl.
*                                               AND aplzl = wa_deep_entity-aplzl.

              READ TABLE lt_afvc2 INTO DATA(wa_afvc2)
                                  WITH KEY aufpl = wa_afvc-aufpl
                                           aplzl = wa_afvc-aplzl.

              LOOP AT lt_afvc_wadah INTO DATA(wa_afvc_wadah)
                                    WHERE aufpl = wa_afvc2-aufpl
                                      AND phseq = wa_afvc2-phseq.

                READ TABLE lt_resb2 INTO DATA(wa_resb2)
                                    WITH KEY aufpl = wa_afvc_wadah-aufpl
                                             vornr = wa_afvc_wadah-vornr.

                IF sy-subrc = 0.

                  LOOP AT lt_resb_material INTO DATA(wa_resb_material)
                                           WHERE aufpl = wa_resb2-aufpl
                                             AND vornr = wa_resb2-vornr.

                    DATA(lv_count) = REDUCE i( INIT i = 0 FOR wa IN lt_ztspppdt011
                                     WHERE ( rsnum = wa_resb_material-rsnum AND
                                             rspos = wa_resb_material-rspos )
                                     NEXT i = i + 1 ).

                    LOOP AT lt_ztspppdt011 INTO DATA(wa_ztspppdt011)
                                           WHERE rsnum = wa_resb_material-rsnum
                                             AND rspos = wa_resb_material-rspos.
                      READ TABLE lt_makt INTO DATA(wa_makt) WITH KEY matnr = wa_resb_material-matnr.

                      DATA(lv_zeile) = wa_ztspppdt011-zeile.
                      SHIFT lv_zeile LEFT DELETING LEADING '0'.
                      CONDENSE lv_zeile.

                      DATA lv_cntr(10).
                      WRITE lv_count TO lv_cntr.
                      CONDENSE lv_cntr.

                      "Collect Material
                      MOVE-CORRESPONDING wa_resb_material TO wa_material.
                      wa_material-oprdesc = lv_oprdesc.
                      wa_material-maktx = wa_makt-maktx.
                      wa_material-erfmg = wa_ztspppdt011-erfmg.
                      wa_material-erfme = wa_ztspppdt011-erfme.
                      wa_material-wempf = 'F'.
                      CONCATENATE lv_zeile lv_cntr INTO wa_material-cntr SEPARATED BY '/'.
                      APPEND wa_material TO wa_wadah-wadtomatnav.
                      CLEAR wa_material.
                    ENDLOOP.
                  ENDLOOP.

                  "Collect Wadah
                  wa_wadah-aufpl  = wa_afvc_wadah-aufpl.
                  wa_wadah-aplzl  = wa_afvc_wadah-aplzl.
                  wa_wadah-plnbez = wa_deep_entity-plnbez.
                  wa_wadah-aufnr  = wa_deep_entity-aufnr.
                  wa_wadah-vornr  = wa_afvc_wadah-vornr.
                  wa_wadah-phseq  = wa_afvc_wadah-phseq.
                  wa_wadah-sortf  = wa_resb2-sortf.
                  wa_wadah-oprdesc = lv_oprdesc.
                  APPEND wa_wadah TO wa_operation-oprtowadnav.
                  CLEAR wa_wadah.
                ENDIF.
              ENDLOOP.

              "Collect Operation
              MOVE-CORRESPONDING wa_afvc TO wa_operation.
              wa_operation-oprdesc = lv_oprdesc.
              APPEND wa_operation TO wa_deep_entity-ordtooprnav.
              CLEAR wa_operation.
            ENDLOOP.

            "Collect Deep Entity
            APPEND wa_deep_entity TO lt_deep_entity.
            CLEAR wa_deep_entity.
          ENDLOOP.

          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_deep_entity
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN 'wadahSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
          LOOP AT it_filter_select_options INTO wa_filter.
            CASE wa_filter-property.
              WHEN 'RoutingNo'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_aufpl = wa_filter_so-low.
              WHEN 'ActivityNo'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_vornr = wa_filter_so-low.
              WHEN 'ControlRecipe'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_phseq = wa_filter_so-low.
              WHEN 'OperationType'.
                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
                lv_oprdesc = wa_filter_so-low.
            ENDCASE.
          ENDLOOP.

          DATA(lv_phseq2) = lv_phseq.
          lv_phseq(1) = 'W'.

          SELECT a~aufpl, a~aplzl, a~vornr, a~ltxa1, a~phseq,
                 b~usr00, b~usr01
            INTO TABLE @DATA(lt_afvc_wadah2)
            FROM afvc AS a JOIN afvu AS b ON a~aufpl = b~aufpl AND
                                             a~aplzl = b~aplzl
            WHERE a~aufpl = @lv_aufpl
              AND a~phseq = @lv_phseq
            ORDER BY a~aufpl, a~aplzl, a~vornr.

          IF sy-subrc = 0.
            SELECT * INTO TABLE @DATA(lt_resb_wadah)
              FROM resb FOR ALL ENTRIES IN @lt_afvc_wadah2
              WHERE aufpl = @lt_afvc_wadah2-aufpl
                AND vornr = @lt_afvc_wadah2-vornr
                AND ( splkz = ' ' OR splkz = '1' )
              ORDER BY PRIMARY KEY.

            IF sy-subrc = 0.
              CASE lv_oprdesc.
                WHEN 'DECOCT'.
                  DELETE lt_resb_wadah WHERE sortf NE 'D'.
                WHEN OTHERS.
                  DELETE lt_resb_wadah WHERE sortf EQ 'D'.
              ENDCASE.

              "Get Material
              IF lt_resb_wadah[] IS NOT INITIAL.
                SELECT * INTO TABLE lt_resb_material
                  FROM resb FOR ALL ENTRIES IN lt_resb_wadah
                  WHERE aufpl = lt_resb_wadah-aufpl
                    AND vornr = lt_resb_wadah-vornr
                    AND splkz = '2'
                    AND ( wempf = ' ' OR wempf = 'F' )
                  ORDER BY PRIMARY KEY.

                IF sy-subrc = 0.
                  CASE lv_oprdesc.
                    WHEN 'DECOCT'.
                      DELETE lt_resb_material WHERE sortf NE 'D'.
                    WHEN OTHERS.
                      DELETE lt_resb_material WHERE sortf EQ 'D'.
                  ENDCASE.

                  IF lt_resb_material[] IS NOT INITIAL.
                    SELECT * INTO TABLE lt_ztspppdt011
                      FROM ztspppdt011 FOR ALL ENTRIES IN lt_resb_material
                      WHERE rsnum = lt_resb_material-rsnum
                        AND rspos = lt_resb_material-rspos
                      ORDER BY PRIMARY KEY.

                    SELECT * INTO TABLE lt_makt
                      FROM makt FOR ALL ENTRIES IN lt_resb_material
                      WHERE matnr = lt_resb_material-matnr
                        AND spras = sy-langu
                      ORDER BY PRIMARY KEY.

                    SELECT mblnr, mjahr, zeile, bwart, matnr, werks, lgort,
                           charg, aufnr, rsnum, rspos, smbln, sjahr, smblp
                      INTO TABLE @DATA(lt_mseg)
                      FROM mseg FOR ALL ENTRIES IN @lt_resb_material
                      WHERE rsnum = @lt_resb_material-rsnum
                        AND rspos = @lt_resb_material-rspos
                        AND bwart IN ('261','262')
                      ORDER BY PRIMARY KEY.
                    IF sy-subrc = 0.
                      LOOP AT lt_mseg INTO DATA(ls_mseg) WHERE bwart = '262'.
                        DELETE lt_mseg WHERE mblnr = ls_mseg-smbln
                                         AND mjahr = ls_mseg-sjahr
                                         AND zeile = ls_mseg-smblp.
                      ENDLOOP.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.

              "Exclude Cangkang Kapsul
              SELECT * INTO TABLE @DATA(lt_ztspppdt006)
                FROM ztspppdt006 WHERE excty = 'P'.

              DATA(lv_aufnr) = lt_resb_wadah[ 1 ]-aufnr.

              SELECT SINGLE plnbez INTO lv_plnbez
                FROM afko WHERE aufnr = lv_aufnr.

              LOOP AT lt_afvc_wadah2 INTO DATA(wa_afvc_wadah2).

                READ TABLE lt_resb_wadah INTO DATA(wa_resb_wadah)
                                         WITH KEY aufpl = wa_afvc_wadah2-aufpl
                                                  vornr = wa_afvc_wadah2-vornr.

                IF sy-subrc = 0.

                  LOOP AT lt_resb_material INTO wa_resb_material
                                           WHERE aufpl = wa_resb_wadah-aufpl
                                             AND vornr = wa_resb_wadah-vornr.

                    IF line_exists( lt_ztspppdt006[ matnr = wa_resb_material-matnr ] ).
                      CONTINUE.
                    ENDIF.

*                    lv_count = REDUCE i( INIT i = 0 FOR wa IN lt_ztspppdt011
*                                     WHERE ( rsnum = wa_resb_material-rsnum AND
*                                             rspos = wa_resb_material-rspos )
*                                     NEXT i = i + 1 ).
*                    READ TABLE lt_ztspppdt011 INTO wa_ztspppdt011 INDEX 1.

                    DATA(lv_mblnr) = VALUE #( lt_mseg[ rsnum = wa_resb_material-rsnum
                                                       rspos = wa_resb_material-rspos ]-mblnr OPTIONAL ).
                    DATA(lv_mjahr) = VALUE #( lt_mseg[ rsnum = wa_resb_material-rsnum
                                                       rspos = wa_resb_material-rspos ]-mjahr OPTIONAL ).

                    READ TABLE lt_ztspppdt011 INTO wa_ztspppdt011 WITH KEY matnr = wa_resb_material-matnr
                                                                           charg = wa_resb_material-charg.
                    IF sy-subrc = 0.
                      SELECT MAX( zeile ) INTO @DATA(lv_max)
                        FROM ztspppdt011 WHERE rsnum = @wa_resb_material-rsnum
                                           AND matnr = @wa_resb_material-matnr
                                           AND charg = @wa_resb_material-charg
                                           AND mblnr = @lv_mblnr
                                           AND mjahr = @lv_mjahr.
*                                           AND erdat = @wa_ztspppdt011-erdat
*                                           AND ertim = @wa_ztspppdt011-ertim.
                      IF sy-subrc = 0.
                        IF  lv_max IS INITIAL.
                          lv_max = 1.
                        ENDIF.
                        SHIFT lv_max LEFT DELETING LEADING '0'.
                        CONDENSE lv_max.
                      ENDIF.
                    ENDIF.

                    LOOP AT lt_ztspppdt011 INTO wa_ztspppdt011
                                           WHERE rsnum = wa_resb_material-rsnum
                                             AND rspos = wa_resb_material-rspos.
                      READ TABLE lt_makt INTO wa_makt WITH KEY matnr = wa_resb_material-matnr.

                      lv_zeile = wa_ztspppdt011-zeile.
                      SHIFT lv_zeile LEFT DELETING LEADING '0'.
                      CONDENSE lv_zeile.

*                      WRITE lv_count TO lv_cntr.
*                      CONDENSE lv_cntr.

                      "Collect Material
                      MOVE-CORRESPONDING wa_resb_material TO wa_material.
                      wa_material-oprdesc = lv_oprdesc.
                      wa_material-maktx = wa_makt-maktx.
                      wa_material-erfmg = wa_ztspppdt011-erfmg.
                      wa_material-erfme = wa_ztspppdt011-erfme.
                      wa_material-mblnr = wa_ztspppdt011-mblnr.
                      wa_material-wempf = 'F'.
                      CONCATENATE lv_zeile lv_max INTO wa_material-cntr SEPARATED BY '/'.
                      APPEND wa_material TO wa_wadah-wadtomatnav.
                      CLEAR wa_material.
                    ENDLOOP.
                  ENDLOOP.

                  wa_wadah-aufpl  = wa_afvc_wadah2-aufpl.
                  wa_wadah-aplzl  = wa_afvc_wadah2-aplzl.
                  wa_wadah-plnbez = lv_plnbez.
                  wa_wadah-aufnr  = wa_resb_wadah-aufnr.
                  wa_wadah-vornr  = wa_afvc_wadah2-vornr.
                  wa_wadah-ltxa1  = wa_afvc_wadah2-ltxa1.
                  wa_wadah-phseq  = wa_afvc_wadah2-phseq.
                  wa_wadah-phseq2 = lv_phseq2.
                  wa_wadah-sortf  = wa_resb_wadah-sortf.
                  wa_wadah-oprdesc = lv_oprdesc.
                  IF wa_wadah-oprdesc = 'DECOCT'.
                    wa_wadah-ltxa1  = wa_afvc_wadah2-usr01.
                  ENDIF.
                  APPEND wa_wadah TO lt_wadah.
                  CLEAR wa_wadah.
                ENDIF.
              ENDLOOP.

              CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
                EXPORTING
                  is_data = lt_wadah
                CHANGING
                  cr_data = er_entityset.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN 'OperationTypeSet'.
        IF it_filter_select_options[] IS NOT INITIAL.
*          LOOP AT it_filter_select_options INTO wa_filter.
*            CASE wa_filter-property.
*              WHEN 'StartDate'.
*                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
*                lv_strdate = wa_filter_so-low.
*              WHEN 'Material'.
*                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
*                lv_plnbez = wa_filter_so-low.
*              WHEN 'Plant'.
*                READ TABLE wa_filter-select_options INTO wa_filter_so INDEX 1.
*                lv_werks = wa_filter_so-low.
*            ENDCASE.
*          ENDLOOP.
          IF line_exists( it_filter_select_options[ property = 'StartDate' ] ).
            lr_strdate = it_filter_select_options[ property = 'StartDate' ]-select_options.
            wa_deep_2-strdate = lr_strdate[ 1 ]-low.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'Material' ] ).
            lr_plnbez  = it_filter_select_options[ property = 'Material' ]-select_options.
            wa_deep_2-plnbez = lr_plnbez[ 1 ]-low.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'Plant' ] ).
            lr_werks   = it_filter_select_options[ property = 'Plant' ]-select_options.
            wa_deep_2-werks = lr_werks[ 1 ]-low.
          ENDIF.
          IF line_exists( it_filter_select_options[ property = 'BatchFG' ] ).
            lr_charg   = it_filter_select_options[ property = 'BatchFG' ]-select_options.
*            LOOP AT lr_charg ASSIGNING FIELD-SYMBOL(<fs_charg>).
*              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*                EXPORTING
*                  input  = <fs_charg>-low
*                IMPORTING
*                  output = lv_charg.
*              IF sy-subrc = 0.
*                <fs_charg>-low = lv_charg.
*              ENDIF.
*            ENDLOOP.
            wa_deep_2-charg   = lr_charg[ 1 ]-low.
          ENDIF.

          SELECT SINGLE maktx INTO lv_maktx
            FROM makt WHERE matnr IN lr_plnbez  "= lv_plnbez
                        AND spras = sy-langu.

          "Get Order
          SELECT * INTO TABLE lt_cdsv02
            FROM zdmp_cdsv02
            WHERE strdate IN lr_strdate   "= lv_strdate
              AND plnbez  IN lr_plnbez    "= lv_plnbez
              AND werks   IN lr_werks     "= lv_werks.
              AND charg   IN lr_charg.

          IF sy-subrc = 0.
            SELECT DISTINCT * INTO TABLE lt_resb
              FROM resb FOR ALL ENTRIES IN lt_cdsv02
              WHERE aufnr = lt_cdsv02-aufnr
              ORDER BY PRIMARY KEY.

            IF sy-subrc = 0.
              SORT lt_resb BY rsnum rspos.
              DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING rsnum.

              SELECT * INTO TABLE lt_afvc
                FROM afvc FOR ALL ENTRIES IN lt_resb
                WHERE aufpl = lt_resb-aufpl
                  AND steus = 'ZP01'
                ORDER BY PRIMARY KEY.
            ENDIF.
          ENDIF.

          "Collect deep 2
          LOOP AT lt_afvc INTO wa_afvc.
            CASE wa_afvc-phseq(1).
              WHEN 'D'.
                wa_operationdesc-oprdesc = 'CK'.
              WHEN 'E'.
                wa_operationdesc-oprdesc = 'DECOCT'.
              WHEN 'G'.
                wa_operationdesc-oprdesc = 'CB'.
              WHEN 'L'.
                wa_operationdesc-oprdesc = 'LIQUID MIXING'.
              WHEN 'O'.
                wa_operationdesc-oprdesc = 'SEMI SOLID MIXING'.
              WHEN OTHERS.
                CONTINUE.
            ENDCASE.
            wa_operationdesc-werks = wa_deep_2-werks.
            COLLECT wa_operationdesc INTO wa_deep_2-oprtyptodescnav.
            CLEAR wa_operationdesc.
          ENDLOOP.

          "Collect Deep Entity
          wa_deep_2-maktx   = lv_maktx.
          APPEND wa_deep_2 TO lt_deep_2.
          CLEAR wa_deep_2.

          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
            EXPORTING
              is_data = lt_deep_2
            CHANGING
              cr_data = er_entityset.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
