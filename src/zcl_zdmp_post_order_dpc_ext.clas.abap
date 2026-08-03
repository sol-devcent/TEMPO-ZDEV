class ZCL_ZDMP_POST_ORDER_DPC_EXT definition
  public
  inheriting from ZCL_ZDMP_POST_ORDER_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_ENTITY
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZDMP_POST_ORDER_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    DATA: ls_deep        TYPE zcl_zdmp_post_order_mpc_ext=>ts_deep,
          lt_ztspppdt012 TYPE TABLE OF ztspppdt012.

    DATA: lv_msg      TYPE bapi_msg,
          obj_msg_con TYPE REF TO /iwbep/if_message_container.

    CASE iv_entity_set_name.
      WHEN 'OrderSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_deep.
          CATCH /iwbep/cx_mgw_tech_exception .
        ENDTRY.

        IF ls_deep IS NOT INITIAL.

          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          LOOP AT ls_deep-ordtooprnav INTO DATA(ls_operation).
            "Cek data
            IF ls_operation-rooms IS INITIAL.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Line ERROR'
                  iv_add_to_response_header = abap_true.
              EXIT.
            ELSEIF ls_operation-dates IS INITIAL OR
                   ls_operation-times IS INITIAL.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Date/Time Start ERROR'
                  iv_add_to_response_header = abap_true.
              EXIT.
            ELSEIF ls_operation-datef IS INITIAL OR
                   ls_operation-timef IS INITIAL.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Date/Time Finish ERROR'
                  iv_add_to_response_header = abap_true.
              EXIT.
            ELSE.
              IF ls_deep-oprdesc = 'CB' AND ls_operation-actwh IS NOT INITIAL.
                SELECT SINGLE * INTO @DATA(ls_ztspppdt012)
                  FROM ztspppdt012 WHERE aufpl = @ls_operation-aufpl
                                     AND aplzl = @ls_operation-aplzl
                                     AND stats = @ls_operation-stats
                                     AND vornr = @ls_operation-vornr
                                     AND actwh = @ls_operation-actwh.
                IF sy-subrc = 0.
                  APPEND INITIAL LINE TO lt_ztspppdt012 ASSIGNING FIELD-SYMBOL(<fs_ztspppdt012>).
                  MOVE-CORRESPONDING ls_ztspppdt012 TO <fs_ztspppdt012>.
                  <fs_ztspppdt012>-datef = ls_operation-datef.
                  <fs_ztspppdt012>-timef = ls_operation-timef.
                ELSE.
                  APPEND INITIAL LINE TO lt_ztspppdt012 ASSIGNING <fs_ztspppdt012>.
                  <fs_ztspppdt012>-aufpl = ls_operation-aufpl.
                  <fs_ztspppdt012>-aplzl = ls_operation-aplzl.
                  <fs_ztspppdt012>-stats = ls_operation-stats.
                  <fs_ztspppdt012>-aufnr = ls_deep-aufnr.
                  <fs_ztspppdt012>-vornr = ls_operation-vornr.
                  <fs_ztspppdt012>-rooms = ls_operation-rooms.
                  <fs_ztspppdt012>-dates = ls_operation-dates.
                  <fs_ztspppdt012>-times = ls_operation-times.
                  <fs_ztspppdt012>-datef = ls_operation-datef.
                  <fs_ztspppdt012>-timef = ls_operation-timef.
                  <fs_ztspppdt012>-operator = ls_operation-operator.
                  <fs_ztspppdt012>-pengawas = ls_operation-pengawas.
*                <fs_ztspppdt012>-actwh = ls_operation-actwh.
                ENDIF.

              ELSE.
                SELECT SINGLE vornr INTO @DATA(lv_vornr)
                  FROM ztspppdt012 WHERE aufpl = @ls_operation-aufpl
                                     AND aplzl = @ls_operation-aplzl
                                     AND stats = @ls_operation-stats
                                     AND actwh = @ls_operation-actwh.

                IF sy-subrc = 0.
                  CALL METHOD obj_msg_con->add_message_text_only
                    EXPORTING
                      iv_msg_type               = 'E'
                      iv_msg_text               = 'Handover sudah dilakukan'
                      iv_add_to_response_header = abap_true.

                  EXIT.
                ELSE.
                  APPEND INITIAL LINE TO lt_ztspppdt012 ASSIGNING <fs_ztspppdt012>.
                  <fs_ztspppdt012>-aufpl = ls_operation-aufpl.
                  <fs_ztspppdt012>-aplzl = ls_operation-aplzl.
                  <fs_ztspppdt012>-stats = ls_operation-stats.
                  <fs_ztspppdt012>-aufnr = ls_deep-aufnr.
                  <fs_ztspppdt012>-vornr = ls_operation-vornr.
*                <fs_ztspppdt012>-werks = ls_deep-werks.
*                <fs_ztspppdt012>-ltxa1 = ls_operation-ltxa1.
                  <fs_ztspppdt012>-rooms = ls_operation-rooms.
                  <fs_ztspppdt012>-dates = ls_operation-dates.
                  <fs_ztspppdt012>-times = ls_operation-times.
                  <fs_ztspppdt012>-datef = ls_operation-datef.
                  <fs_ztspppdt012>-timef = ls_operation-timef.
                  <fs_ztspppdt012>-operator = ls_operation-operator.
                  <fs_ztspppdt012>-pengawas = ls_operation-pengawas.
*                <fs_ztspppdt012>-actwh = ls_operation-actwh.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.

          IF lt_ztspppdt012[] IS NOT INITIAL.
            IF ls_operation-actwh IS NOT INITIAL.
              ls_ztspppdt012 = lt_ztspppdt012[ 1 ].
              ls_ztspppdt012-actwh = ls_operation-actwh.
              MODIFY lt_ztspppdt012 FROM ls_ztspppdt012
                  TRANSPORTING actwh WHERE actwh IS INITIAL.
            ENDIF.

            "Insert Table
*            INSERT ztspppdt012 FROM TABLE lt_ztspppdt012.
            MODIFY ztspppdt012 FROM TABLE lt_ztspppdt012.
            IF sy-subrc = 0.
              CLEAR ls_deep.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'S'
                  iv_msg_text               = 'Update Successful'
                  iv_add_to_response_header = abap_true.

            ELSE.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Update Failed'
                  iv_add_to_response_header = abap_true.
            ENDIF.

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
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_entity.
    DATA: ls_material     TYPE zcl_zdmp_post_order_mpc_ext=>ts_material,
          ls_materialflag TYPE zcl_zdmp_post_order_mpc_ext=>ts_materialflag,
          ls_handoverflag TYPE zcl_zdmp_post_order_mpc_ext=>ts_handoverflag,
          lt_ztspppdt012  TYPE TABLE OF ztspppdt012.

    DATA: lv_aufnr     TYPE aufnr,
          lv_aufnr_ori TYPE aufnr,
          lv_wadah     TYPE zwadah,
          lv_twadah    TYPE ztwadah.

    DATA: lv_msg      TYPE bapi_msg,
          obj_msg_con TYPE REF TO /iwbep/if_message_container.

    CASE iv_entity_set_name.
      WHEN 'HandoverFlagSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_handoverflag.
          CATCH /iwbep/cx_mgw_tech_exception .
        ENDTRY.
        IF ls_handoverflag IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          SPLIT ls_handoverflag-cntr AT '/' INTO lv_wadah lv_twadah.
          lv_aufnr = |{ ls_handoverflag-aufnr ALPHA = IN }|.
          lv_aufnr_ori = |{ ls_handoverflag-aufnr_ori ALPHA = IN }|.
          lv_wadah = |{ lv_wadah ALPHA = IN }|.
          lv_twadah = |{ lv_twadah ALPHA = IN }|.

          IF lv_aufnr NE lv_aufnr_ori.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Process Order Invalid'
                iv_add_to_response_header = abap_true.
            EXIT.
          ENDIF.

          UPDATE ztspppdt014 SET flgho = 'X'
                             WHERE aufnr = lv_aufnr               "ls_handoverflag-aufnr
                               AND vornr = ls_handoverflag-vornr
                               AND actwh = ls_handoverflag-actwh
                               AND wadah = lv_wadah.
          IF sy-subrc = 0.
            CLEAR ls_handoverflag.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'S'
                iv_msg_text               = 'Update Successful'
                iv_add_to_response_header = abap_true.
          ELSE.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Update Failed'
                iv_add_to_response_header = abap_true.
          ENDIF.

          TRY.
              CALL METHOD me->copy_data_to_ref
                EXPORTING
                  is_data = ls_handoverflag
                CHANGING
                  cr_data = er_entity.
            CATCH cx_root.
          ENDTRY.
        ENDIF.

      WHEN 'MaterialSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_material.
          CATCH /iwbep/cx_mgw_tech_exception .
        ENDTRY.

        IF ls_material IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          SELECT SINGLE * INTO @DATA(ls_afvc)
            FROM afvc WHERE aufpl = @ls_material-aufpl
                        AND vornr = @ls_material-vornr
                        AND steus = 'ZP01'.

          IF sy-subrc = 0.
            ls_afvc-phseq(1) = 'W'.

            SELECT SINGLE * INTO @DATA(ls_afvc2)
              FROM afvc WHERE aufpl = @ls_material-aufpl
                          AND vornr = @ls_material-vornr_wh
                          AND phseq = @ls_afvc-phseq
                          AND steus = 'ZP01'.

            IF sy-subrc = 0.
              CASE ls_material-oprdesc.
                WHEN 'DECOCT'.
                  SELECT SINGLE * INTO @DATA(ls_resb)
                    FROM resb WHERE aufpl = @ls_afvc2-aufpl
                                AND vornr = @ls_afvc2-vornr
                                AND sortf = 'D'.
                  IF sy-subrc NE 0.
                    CLEAR ls_afvc2.
                  ENDIF.
                WHEN OTHERS.
              ENDCASE.

              IF ls_afvc2 IS INITIAL.
                CALL METHOD obj_msg_con->add_message_text_only
                  EXPORTING
                    iv_msg_type               = 'E'
                    iv_msg_text               = 'Operation Weighing does not exist'
                    iv_add_to_response_header = abap_true.
                EXIT.
              ELSE.
                SELECT SINGLE * INTO @DATA(ls_ztspppdt012)
                  FROM ztspppdt012 WHERE aufpl = @ls_material-aufpl
                                     AND aplzl = @ls_afvc-aplzl
                                     AND stats = @ls_material-stats
                                     AND vornr = @ls_material-vornr
                                     AND actwh IN ('    ','0000').

                IF sy-subrc = 0.
                  "Prepare Update ZPPRESB_ADD (Weighing)
                  SELECT * INTO TABLE @DATA(lt_resb2)
                    FROM resb WHERE aufpl = @ls_afvc2-aufpl
                                AND vornr = @ls_afvc2-vornr
                                AND splkz IN (' ','1').
                  IF sy-subrc = 0.
                    IF ls_material-oprdesc = 'DECOCT'.
                      DELETE lt_resb2 WHERE sortf NE 'D'.
                    ELSE.
                      DELETE lt_resb2 WHERE sortf = 'D'.
                    ENDIF.

                    IF lt_resb2[] IS NOT INITIAL.
                      SELECT * INTO TABLE @DATA(lt_zppresb_add)
                        FROM zppresb_add FOR ALL ENTRIES IN @lt_resb2
                        WHERE aufnr = @lt_resb2-aufnr
                          AND matnr = @lt_resb2-matnr
                          AND posnr = @lt_resb2-posnr.
                      IF sy-subrc = 0.
                        IF ls_material-oprdesc = 'DECOCT'.
                          DELETE lt_zppresb_add WHERE sortf NE 'D'.
                        ELSE.
                          DELETE lt_zppresb_add WHERE sortf = 'D'.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  ENDIF.

                  "Prepare Update ZTSPPPDT011 (Fullpack)
                  SELECT * INTO TABLE @DATA(lt_resb3)
                    FROM resb WHERE aufpl = @ls_afvc2-aufpl
                                AND vornr = @ls_afvc2-vornr
                                AND splkz = '2'
                                AND wempf = ' '.
                  IF sy-subrc = 0.
                    SELECT * INTO TABLE @DATA(lt_ztspppdt011)
                      FROM ztspppdt011 FOR ALL ENTRIES IN @lt_resb3
                      WHERE rsnum = @lt_resb3-rsnum
                        AND rspos = @lt_resb3-rspos.
                  ENDIF.

                  SELECT SINGLE * INTO ls_ztspppdt012
                    FROM ztspppdt012 WHERE aufpl = ls_material-aufpl
                                       AND aplzl = ls_afvc-aplzl
                                       AND stats = ls_material-stats
                                       AND vornr = ls_material-vornr
                                       AND actwh = ls_material-vornr_wh.
                  IF sy-subrc = 0.
*                    CALL METHOD obj_msg_con->add_message_text_only
*                      EXPORTING
*                        iv_msg_type               = 'E'
*                        iv_msg_text               = 'Data already exist'
*                        iv_add_to_response_header = abap_true.
*                    EXIT.
                    "Update Table
                    UPDATE ztspppdt012 SET datef = ls_material-datef
                                           timef = ls_material-timef
                                       WHERE aufpl = ls_material-aufpl
                                         AND aplzl = ls_afvc-aplzl
                                         AND stats = ls_material-stats
                                         AND vornr = ls_material-vornr
                                         AND actwh = ls_material-vornr_wh.
                    IF sy-subrc = 0.
                      CLEAR ls_material.
                      CALL METHOD obj_msg_con->add_message_text_only
                        EXPORTING
                          iv_msg_type               = 'S'
                          iv_msg_text               = 'Data Updated'
                          iv_add_to_response_header = abap_true.
                    ENDIF.

                  ELSE.
                    "Prepare Insert Table ZTSPPPDT012
                    APPEND INITIAL LINE TO lt_ztspppdt012 ASSIGNING FIELD-SYMBOL(<fs_ztspppdt012>).
                    MOVE-CORRESPONDING ls_ztspppdt012 TO <fs_ztspppdt012>.
                    <fs_ztspppdt012>-actwh    = ls_material-vornr_wh.
                    <fs_ztspppdt012>-dates    = ls_material-dates.
                    <fs_ztspppdt012>-times    = ls_material-times.
                    <fs_ztspppdt012>-datef    = ls_material-datef.
                    <fs_ztspppdt012>-timef    = ls_material-timef.
                    <fs_ztspppdt012>-operator = ls_material-operator.
                    <fs_ztspppdt012>-pengawas = ls_material-pengawas.

                    "Check table
                    SELECT SINGLE aufpl, aplzl, stats, vornr, actwh INTO @DATA(ls_ztspppdt012_tmp)
                      FROM ztspppdt012 WHERE aufpl = @<fs_ztspppdt012>-aufpl
                                         AND aplzl = @<fs_ztspppdt012>-aplzl
                                         AND stats = @<fs_ztspppdt012>-stats
                                         AND vornr = @<fs_ztspppdt012>-vornr
                                         AND actwh = @<fs_ztspppdt012>-actwh.
                    IF sy-subrc = 0.
                      CALL METHOD obj_msg_con->add_message_text_only
                        EXPORTING
                          iv_msg_type               = 'E'
                          iv_msg_text               = 'Duplicate keys in ZTSPPPDT012'
                          iv_add_to_response_header = abap_true.
                    ELSE.
                      IF lt_ztspppdt012[] IS NOT INITIAL.
                        "Insert Table
                        TRY.
                            INSERT ztspppdt012 FROM TABLE lt_ztspppdt012.
                          CATCH cx_sy_open_sql_db.

                        ENDTRY.

                        IF sy-subrc = 0.
                          CLEAR ls_material.
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
                  ENDIF.

                  TRY.
                      CALL METHOD me->copy_data_to_ref
                        EXPORTING
                          is_data = ls_material
                        CHANGING
                          cr_data = er_entity.
                    CATCH cx_root.
                  ENDTRY.

                ELSE.
                  CLEAR lv_msg.
                  lv_msg = |Handover { ls_afvc-ltxa1 } belum dilakukan|.
                  CALL METHOD obj_msg_con->add_message_text_only
                    EXPORTING
                      iv_msg_type               = 'E'
                      iv_msg_text               = lv_msg  "'Status does not exist'
                      iv_add_to_response_header = abap_true.
                  EXIT.
                ENDIF.
              ENDIF.

            ELSE.
              CALL METHOD obj_msg_con->add_message_text_only
                EXPORTING
                  iv_msg_type               = 'E'
                  iv_msg_text               = 'Operation Weighing does not exist'
                  iv_add_to_response_header = abap_true.
              EXIT.
            ENDIF.

          ELSE.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Operation does not exist'
                iv_add_to_response_header = abap_true.
            EXIT.
          ENDIF.
        ENDIF.

      WHEN 'MaterialFlagSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_materialflag.
          CATCH /iwbep/cx_mgw_tech_exception .
        ENDTRY.

        IF ls_materialflag IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = ls_materialflag-aufnr
            IMPORTING
              output = ls_materialflag-aufnr.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = ls_materialflag-aufnr_ori
            IMPORTING
              output = ls_materialflag-aufnr_ori.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = ls_materialflag-charg
            IMPORTING
              output = ls_materialflag-charg.

          IF ls_materialflag-aufnr NE ls_materialflag-aufnr_ori.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Process Order Invalid'
                iv_add_to_response_header = abap_true.
            EXIT.
          ENDIF.

          CASE ls_materialflag-wempf.
            WHEN 'G'.
              SPLIT ls_materialflag-potx2 AT ';' INTO: lv_aufnr
                                                       DATA(lv_vornr)
                                                       DATA(lv_astad)
                                                       DATA(lv_astau)
                                                       DATA(lv_wempf).
              lv_aufnr = |{ lv_aufnr ALPHA = IN }|.

              SELECT SINGLE scanfl INTO @DATA(lv_scanfl)
                FROM ztspppdt007 WHERE aufnr = @lv_aufnr
                                   AND vornr = @lv_vornr
                                   AND astad = @lv_astad
                                   AND astau = @lv_astau.
              IF sy-subrc = 0.
                UPDATE ztspppdt007 SET scanfl = 'X'
                                       scandt = sy-datum
                                       scantm = sy-uzeit
                  WHERE aufnr = lv_aufnr
                    AND vornr = lv_vornr
                    AND astad = lv_astad
                    AND astau = lv_astau
                    AND scanfl = space.
                IF sy-subrc NE 0.
                  CALL METHOD obj_msg_con->add_message_text_only
                    EXPORTING
                      iv_msg_type               = 'E'
                      iv_msg_text               = 'Data Weighing already scan'
                      iv_add_to_response_header = abap_true.
                  EXIT.
                ENDIF.
              ELSE.
                CALL METHOD obj_msg_con->add_message_text_only
                  EXPORTING
                    iv_msg_type               = 'E'
                    iv_msg_text               = 'Data Weighing does not exist'
                    iv_add_to_response_header = abap_true.
                EXIT.
              ENDIF.

            WHEN 'W'.
              SELECT SINGLE scanfl INTO lv_scanfl
                FROM zppresb_add WHERE aufnr = ls_materialflag-aufnr
                                   AND matnr = ls_materialflag-matnr
                                   AND posnr = ls_materialflag-posnr.
              IF sy-subrc = 0.
                UPDATE zppresb_add SET scanfl = 'X'
                                       scandt = sy-datum
                                       scantm = sy-uzeit
                  WHERE aufnr = ls_materialflag-aufnr
                    AND matnr = ls_materialflag-matnr
                    AND posnr = ls_materialflag-posnr
                    AND scanfl = space.
                IF sy-subrc NE 0.
                  CALL METHOD obj_msg_con->add_message_text_only
                    EXPORTING
                      iv_msg_type               = 'E'
                      iv_msg_text               = 'Data Weighing already scan'
                      iv_add_to_response_header = abap_true.
                  EXIT.
                ENDIF.
              ELSE.
                CALL METHOD obj_msg_con->add_message_text_only
                  EXPORTING
                    iv_msg_type               = 'E'
                    iv_msg_text               = 'Data Weighing does not exist'
                    iv_add_to_response_header = abap_true.
                EXIT.
              ENDIF.

            WHEN 'F'.
              SELECT SINGLE a~rsnum a~rspos a~rsart a~matnr a~werks a~lgort
                            a~charg a~aufnr a~vornr a~aufpl a~aplzl a~splkz
                INTO CORRESPONDING FIELDS OF ls_resb
                FROM resb AS a JOIN mseg AS b ON a~rsnum = b~rsnum AND
                                                 a~rspos = b~rspos
                WHERE a~aufnr = ls_materialflag-aufnr
                  AND a~vornr = ls_materialflag-vornr
                  AND a~posnr = ls_materialflag-posnr
                  AND a~charg = ls_materialflag-charg
                  AND a~wempf = space
                  AND a~splkz = '2'
                  AND b~mblnr = ls_materialflag-mblnr.
              IF sy-subrc = 0.
                SELECT SINGLE scanfl INTO lv_scanfl
                  FROM ztspppdt011 WHERE rsnum = ls_resb-rsnum
                                     AND rspos = ls_resb-rspos
                                     AND rsart = ls_resb-rsart
                                     AND zeile = ls_materialflag-zeile.
                IF sy-subrc = 0.
                  UPDATE ztspppdt011 SET scanfl = 'X'
                                         scandt = sy-datum
                                         scantm = sy-uzeit
                    WHERE rsnum = ls_resb-rsnum
                      AND rspos = ls_resb-rspos
                      AND rsart = ls_resb-rsart
                      AND zeile = ls_materialflag-zeile
                      AND scanfl = space.
                  IF sy-subrc NE 0.
                    CALL METHOD obj_msg_con->add_message_text_only
                      EXPORTING
                        iv_msg_type               = 'E'
                        iv_msg_text               = 'Data Fullpack already scan'
                        iv_add_to_response_header = abap_true.
                    EXIT.
                  ENDIF.
                ELSE.
                  CALL METHOD obj_msg_con->add_message_text_only
                    EXPORTING
                      iv_msg_type               = 'E'
                      iv_msg_text               = 'Data Fullpack does not exist'
                      iv_add_to_response_header = abap_true.
                  EXIT.
                ENDIF.
              ELSE.
                CALL METHOD obj_msg_con->add_message_text_only
                  EXPORTING
                    iv_msg_type               = 'E'
                    iv_msg_text               = 'Data Reservation does not exist'
                    iv_add_to_response_header = abap_true.
                EXIT.
              ENDIF.

            WHEN OTHERS.
              SELECT SINGLE scanfl INTO lv_scanfl
                FROM ztspppdt014 WHERE aufnr = ls_materialflag-aufnr
                                   AND vornr = ls_materialflag-vornr
                                   AND actwh = ls_materialflag-actwh
                                   AND wadah = ls_materialflag-wadah.
              IF sy-subrc = 0.
                UPDATE ztspppdt014 SET scanfl = 'X'
                                       scandt = sy-datum
                                       scantm = sy-uzeit
                  WHERE aufnr = ls_materialflag-aufnr
                    AND vornr = ls_materialflag-vornr
                    AND actwh = ls_materialflag-actwh
                    AND wadah = ls_materialflag-wadah
                    AND scanfl = space.
                IF sy-subrc = 0.
                  CLEAR ls_materialflag.
                  CALL METHOD obj_msg_con->add_message_text_only
                    EXPORTING
                      iv_msg_type               = 'S'
                      iv_msg_text               = 'Update Successful'
                      iv_add_to_response_header = abap_true.

                ELSE.
                  CALL METHOD obj_msg_con->add_message_text_only
                    EXPORTING
                      iv_msg_type               = 'E'
                      iv_msg_text               = 'Data Hasil Timbang already scan'
                      iv_add_to_response_header = abap_true.
                  EXIT.
                ENDIF.
              ELSE.
                CALL METHOD obj_msg_con->add_message_text_only
                  EXPORTING
                    iv_msg_type               = 'E'
                    iv_msg_text               = 'Data Hasil does not exist'
                    iv_add_to_response_header = abap_true.
                EXIT.
              ENDIF.
          ENDCASE.

          TRY.
              CALL METHOD me->copy_data_to_ref
                EXPORTING
                  is_data = ls_materialflag
                CHANGING
                  cr_data = er_entity.
            CATCH cx_root.
          ENDTRY.
        ENDIF.


        "NOT USE
      WHEN 'MaterialFlag2Set'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_materialflag.
          CATCH /iwbep/cx_mgw_tech_exception .
        ENDTRY.

        IF ls_materialflag IS NOT INITIAL.
          obj_msg_con = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = ls_materialflag-aufnr
            IMPORTING
              output = ls_materialflag-aufnr.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = ls_materialflag-charg
            IMPORTING
              output = ls_materialflag-charg.

          "Collect Item Flag
          SELECT rsnum, rspos, rsart, vornr, sortf, wempf,
                 aufnr, posnr, matnr, potx2, ' ' AS scanfl
            INTO TABLE @DATA(lt_resb_fl)
            FROM resb WHERE aufnr = @ls_materialflag-aufnr
                        AND vornr = @ls_materialflag-vornr
                        AND splkz = '2'
            ORDER BY PRIMARY KEY.

          IF sy-subrc = 0.
            SELECT aufnr, matnr, posnr, vornr, sortf, scanfl
              INTO TABLE @DATA(lt_weight)
              FROM zppresb_add FOR ALL ENTRIES IN @lt_resb_fl
              WHERE aufnr = @lt_resb_fl-aufnr
                AND matnr = @lt_resb_fl-matnr
                AND posnr = @lt_resb_fl-posnr
              ORDER BY PRIMARY KEY.

            SELECT rsnum, rspos, rsart, zeile, aufnr, posnr, vornr, scanfl
              INTO TABLE @DATA(lt_fullpack)
              FROM ztspppdt011 FOR ALL ENTRIES IN @lt_resb_fl
              WHERE rsnum = @lt_resb_fl-rsnum
                AND rspos = @lt_resb_fl-rspos
                AND rsart = @lt_resb_fl-rsart
              ORDER BY PRIMARY KEY.

            LOOP AT lt_resb_fl ASSIGNING FIELD-SYMBOL(<fs_resb_fl>).
              CASE <fs_resb_fl>-wempf.
                WHEN 'T' OR 'W'.
                  <fs_resb_fl>-scanfl = VALUE #( lt_weight[ aufnr = <fs_resb_fl>-aufnr
                                                            matnr = <fs_resb_fl>-matnr
                                                            posnr = <fs_resb_fl>-posnr ]-scanfl OPTIONAL ).
                WHEN OTHERS.
                  IF line_exists( lt_fullpack[ rsnum = <fs_resb_fl>-rsnum
                                               rspos = <fs_resb_fl>-rspos
                                               rsart = <fs_resb_fl>-rsart ] ).
                    <fs_resb_fl>-scanfl = VALUE #( lt_fullpack[ rsnum = <fs_resb_fl>-rsnum
                                                                rspos = <fs_resb_fl>-rspos
                                                                rsart = <fs_resb_fl>-rsart
                                                                scanfl = ' ' ]-scanfl OPTIONAL ).
                    IF sy-subrc NE 0.
                      <fs_resb_fl>-scanfl = VALUE #( lt_fullpack[ rsnum = <fs_resb_fl>-rsnum
                                                                  rspos = <fs_resb_fl>-rspos
                                                                  rsart = <fs_resb_fl>-rsart ]-scanfl OPTIONAL ).
                    ENDIF.
                  ENDIF.
              ENDCASE.
            ENDLOOP.
          ENDIF.

          "Cek Priority
          DATA(lv_current_prior) = VALUE #( lt_resb_fl[ aufnr = ls_materialflag-aufnr
                                                        matnr = ls_materialflag-matnr
                                                        posnr = ls_materialflag-posnr ]-potx2 OPTIONAL ).

          SORT lt_resb_fl BY scanfl potx2.
          DATA(ls_resb_fl) = VALUE #( lt_resb_fl[ 1 ] OPTIONAL ).

          IF lv_current_prior GT ls_resb_fl-potx2 AND ls_resb_fl-scanfl IS INITIAL.
            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'E'
                iv_msg_text               = 'Prioritas salah'
                iv_add_to_response_header = abap_true.
            EXIT.

          ELSE.
*            CASE ls_materialflag-wempf.
*              WHEN 'W'.
*                SELECT SINGLE scanfl INTO lv_scanfl
*                  FROM zppresb_add WHERE aufnr = ls_materialflag-aufnr
*                                     AND matnr = ls_materialflag-matnr
*                                     AND posnr = ls_materialflag-posnr.
*                IF sy-subrc = 0.
*                  UPDATE zppresb_add SET scanfl = 'X'
*                                         scandt = sy-datum
*                                         scantm = sy-uzeit
*                    WHERE aufnr = ls_materialflag-aufnr
*                      AND matnr = ls_materialflag-matnr
*                      AND posnr = ls_materialflag-posnr
*                      AND scanfl = space.
*                  IF sy-subrc NE 0.
*                    CALL METHOD obj_msg_con->add_message_text_only
*                      EXPORTING
*                        iv_msg_type               = 'E'
*                        iv_msg_text               = 'Data Weighing already scan'
*                        iv_add_to_response_header = abap_true.
*                    EXIT.
*                  ENDIF.
*                ELSE.
*                  CALL METHOD obj_msg_con->add_message_text_only
*                    EXPORTING
*                      iv_msg_type               = 'E'
*                      iv_msg_text               = 'Data Weighing does not exist'
*                      iv_add_to_response_header = abap_true.
*                  EXIT.
*                ENDIF.
*
*              WHEN 'F'.
*                SELECT SINGLE rsnum rspos rsart matnr werks lgort
*                              charg aufnr vornr aufpl aplzl splkz
*                  INTO CORRESPONDING FIELDS OF ls_resb
*                  FROM resb WHERE aufnr = ls_materialflag-aufnr
*                              AND vornr = ls_materialflag-vornr
*                              AND posnr = ls_materialflag-posnr
*                              AND charg = ls_materialflag-charg
*                              AND wempf = space
*                              AND splkz = '2'.
*                IF sy-subrc = 0.
*                  SELECT SINGLE scanfl INTO lv_scanfl
*                    FROM ztspppdt011 WHERE rsnum = ls_resb-rsnum
*                                       AND rspos = ls_resb-rspos
*                                       AND rsart = ls_resb-rsart
*                                       AND zeile = ls_materialflag-zeile.
*                  IF sy-subrc = 0.
*                    UPDATE ztspppdt011 SET scanfl = 'X'
*                                           scandt = sy-datum
*                                           scantm = sy-uzeit
*                      WHERE rsnum = ls_resb-rsnum
*                        AND rspos = ls_resb-rspos
*                        AND rsart = ls_resb-rsart
*                        AND zeile = ls_materialflag-zeile
*                        AND scanfl = space.
*                    IF sy-subrc NE 0.
*                      CALL METHOD obj_msg_con->add_message_text_only
*                        EXPORTING
*                          iv_msg_type               = 'E'
*                          iv_msg_text               = 'Data Fullpack already scan'
*                          iv_add_to_response_header = abap_true.
*                      EXIT.
*                    ENDIF.
*                  ELSE.
*                    CALL METHOD obj_msg_con->add_message_text_only
*                      EXPORTING
*                        iv_msg_type               = 'E'
*                        iv_msg_text               = 'Data Fullpack does not exist'
*                        iv_add_to_response_header = abap_true.
*                    EXIT.
*                  ENDIF.
*                ELSE.
*                  CALL METHOD obj_msg_con->add_message_text_only
*                    EXPORTING
*                      iv_msg_type               = 'E'
*                      iv_msg_text               = 'Data Reservation does not exist'
*                      iv_add_to_response_header = abap_true.
*                  EXIT.
*                ENDIF.
*
*              WHEN OTHERS.
*                SELECT SINGLE scanfl INTO lv_scanfl
*                  FROM ztspppdt014 WHERE aufnr = ls_materialflag-aufnr
*                                     AND vornr = ls_materialflag-vornr
*                                     AND actwh = ls_materialflag-actwh
*                                     AND wadah = ls_materialflag-wadah.
*                IF sy-subrc = 0.
*                  UPDATE ztspppdt014 SET scanfl = 'X'
*                                         scandt = sy-datum
*                                         scantm = sy-uzeit
*                    WHERE aufnr = ls_materialflag-aufnr
*                      AND vornr = ls_materialflag-vornr
*                      AND actwh = ls_materialflag-actwh
*                      AND wadah = ls_materialflag-wadah
*                      AND scanfl = space.
*                  IF sy-subrc NE 0.
*                    CALL METHOD obj_msg_con->add_message_text_only
*                      EXPORTING
*                        iv_msg_type               = 'E'
*                        iv_msg_text               = 'Data Hasil Timbang already scan'
*                        iv_add_to_response_header = abap_true.
*                    EXIT.
*                  ENDIF.
*                ELSE.
*                  CALL METHOD obj_msg_con->add_message_text_only
*                    EXPORTING
*                      iv_msg_type               = 'E'
*                      iv_msg_text               = 'Data Hasil does not exist'
*                      iv_add_to_response_header = abap_true.
*                  EXIT.
*                ENDIF.
*            ENDCASE.

            lv_msg = 'SUCCESS'.
            CLEAR ls_materialflag.

            CALL METHOD obj_msg_con->add_message_text_only
              EXPORTING
                iv_msg_type               = 'S'
                iv_msg_text               = lv_msg
                iv_add_to_response_header = abap_true.
          ENDIF.

          TRY.
              CALL METHOD me->copy_data_to_ref
                EXPORTING
                  is_data = ls_materialflag
                CHANGING
                  cr_data = er_entity.
            CATCH cx_root.
          ENDTRY.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
