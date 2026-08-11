*----------------------------------------------------------------------*
***INCLUDE LZSFF_WEIGHTF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FULLPACK_PGI
*&---------------------------------------------------------------------*
FORM f_fullpack_pgi  TABLES   ft_pgi   STRUCTURE zsffst001_tmp
                     USING    fu_data
                     CHANGING fc_data
                              fc_msgtyp
                              fc_message.
  DATA: lt_pgi         TYPE STANDARD TABLE OF zsffst001,
        lt_pgi_ori     TYPE STANDARD TABLE OF zsffst001,
        lt_resb_insert TYPE STANDARD TABLE OF resb,
        lv_mblnr       TYPE mblnr,
        lv_mjahr       TYPE mjahr.

  LOOP AT ft_pgi INTO DATA(ls_pgi).
    REPLACE ALL OCCURRENCES OF '.' IN ls_pgi-clabs WITH space.
    REPLACE ALL OCCURRENCES OF ',' IN ls_pgi-clabs WITH '.'.
    REPLACE ALL OCCURRENCES OF '.' IN ls_pgi-bdmng WITH space.
    REPLACE ALL OCCURRENCES OF ',' IN ls_pgi-bdmng WITH '.'.
    CONDENSE: ls_pgi-clabs,ls_pgi-bdmng.

    APPEND INITIAL LINE TO lt_pgi ASSIGNING FIELD-SYMBOL(<fs_pgi>).
    MOVE-CORRESPONDING ls_pgi TO <fs_pgi>.
  ENDLOOP.

  lt_pgi_ori[] = lt_pgi[].

  PERFORM f_add_lines_resb TABLES   lt_pgi
                           USING    fu_data
                           CHANGING fc_msgtyp
                                    fc_message.
  IF fc_msgtyp IS INITIAL.
    PERFORM f_post_goods_issue TABLES   lt_pgi
                               USING    fu_data
                               CHANGING lv_mblnr
                                        lv_mjahr
                                        fc_data
                                        fc_msgtyp
                                        fc_message.
    IF lv_mblnr IS NOT INITIAL.
      lt_resb_insert[] = gt_resb_insert[].
      PERFORM f_update_resb TABLES   lt_pgi_ori
                            USING    fu_data
                            CHANGING lv_mblnr
                                     lv_mjahr
                                     fc_msgtyp
                                     fc_message.

      PERFORM f_collect_label TABLES   lt_pgi
                              USING    lv_mblnr lv_mjahr fu_data
                              CHANGING fc_data.

      PERFORM f_write_zsffppdt002 TABLES lt_pgi lt_resb_insert
                                  USING  lv_mblnr lv_mjahr fc_data.

      PERFORM f_reformat USING fc_data.

      CLEAR ft_pgi[].
      LOOP AT lt_pgi INTO DATA(ls_pgi_2).
        APPEND INITIAL LINE TO ft_pgi ASSIGNING FIELD-SYMBOL(<fs_pgi_2>).
        MOVE-CORRESPONDING ls_pgi_2 TO <fs_pgi_2>.
        WRITE: ls_pgi_2-clabs TO <fs_pgi_2>-clabs UNIT ls_pgi_2-meins,
               ls_pgi_2-bdmng TO <fs_pgi_2>-bdmng UNIT ls_pgi_2-meins,
               ls_pgi_2-erfmg TO <fs_pgi_2>-erfmg UNIT ls_pgi_2-erfme.
        CONDENSE: <fs_pgi_2>-clabs,<fs_pgi_2>-bdmng,<fs_pgi_2>-erfmg.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ADD_LINES_RESB
*&---------------------------------------------------------------------*
FORM f_add_lines_resb  TABLES   ft_pgi STRUCTURE zsffst001
                       USING    fu_data
                       CHANGING fc_msgtyp
                                fc_message.
  DATA: lv_json_data TYPE string,
        ls_fp_pgi    TYPE ts_fp_pgi.

  DATA: lv_aplzl LIKE resb-aplzl,
        lv_enmng LIKE resb-enmng.

  lv_json_data = fu_data.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_fp_pgi ).

  DATA(lv_rsnum) = VALUE #( ft_pgi[ 1 ]-rsnum OPTIONAL ).

  SELECT MAX( rspos ) INTO @DATA(lv_rspos)
    FROM resb WHERE rsnum = @lv_rsnum.

  IF sy-subrc NE 0.
    fc_msgtyp = 'E'.
    fc_message = 'Reservation Number Invalid'.

  ELSE.
    LOOP AT ft_pgi INTO DATA(ls_pgi).
      IF ls_pgi-erfmg IS INITIAL.
        CONTINUE.
      ENDIF.

      SELECT SINGLE * INTO @DATA(ls_resb)
        FROM resb WHERE rsnum = @ls_pgi-rsnum
                    AND rspos = @ls_pgi-rspos
                    AND splkz IN (' ','1').

      IF sy-subrc = 0.
        SELECT * INTO TABLE @DATA(lt_jest_tmp)
          FROM jest WHERE objnr = @ls_resb-objnr.
        SELECT * INTO TABLE @DATA(lt_jsto_tmp)
          FROM jsto WHERE objnr = @ls_resb-objnr.

        ADD 1 TO lv_rspos.
        lv_aplzl = ls_resb-rspos.
        lv_enmng = ls_fp_pgi-packs * ls_pgi-erfmg.

        "Collect itab RESB for Insert
        ls_resb-rspos = lv_rspos.
        ls_resb-charg = ls_fp_pgi-charg.
        ls_resb-bdmng = ls_resb-vmeng = lv_enmng.
        ls_resb-splkz = '2'.
        ls_resb-splrv = lv_aplzl.

        IF ls_resb-erfme = ls_resb-meins.
          ls_resb-erfmg = lv_enmng.
        ELSE.
          PERFORM f_uom_conversion USING ls_resb-matnr
                                         ls_resb-meins
                                         ls_resb-erfme
                                         ls_resb-bdmng
                                   CHANGING ls_resb-erfmg.
        ENDIF.

        CLEAR: ls_resb-stvkn,ls_resb-nomng,ls_resb-enmng,ls_resb-enwrt,ls_resb-wempf.
        CONCATENATE ls_resb-objnr(2) ls_resb-rsnum ls_resb-rspos INTO ls_resb-objnr.
        APPEND ls_resb TO gt_resb_insert.

        "Collect itab ONR00 for Insert
        gs_onr00-objnr = ls_resb-objnr.
        APPEND gs_onr00 TO gt_onr00.

        "Collect itab JEST for Insert
        LOOP AT lt_jest_tmp INTO DATA(ls_jest_tmp).
          MOVE-CORRESPONDING ls_jest_tmp TO gs_jest.
          gs_jest-objnr = ls_resb-objnr.
          APPEND gs_jest TO gt_jest.
        ENDLOOP.

        "Collect itab JSTO for Insert
        LOOP AT lt_jsto_tmp INTO DATA(ls_jsto_tmp).
          MOVE-CORRESPONDING ls_jsto_tmp TO gs_jsto.
          gs_jsto-objnr = ls_resb-objnr.
          APPEND gs_jsto TO gt_jsto.
        ENDLOOP.

        "Modify Itab
        ls_pgi-rspos = ls_resb-rspos.
        MODIFY ft_pgi FROM ls_pgi TRANSPORTING rspos.
      ENDIF.
    ENDLOOP.

    "Insert & Update RESB
    IF gt_resb_insert[] IS INITIAL.
      fc_msgtyp = 'E'.
      fc_message = 'No Data Process...'.

    ELSE.
      CALL FUNCTION 'ZTSPPPFM001'
        TABLES
          it_add                   = gt_add
          it_iresb                 = gt_resb_insert
          it_uresb                 = gt_resb_update
          it_onr00                 = gt_onr00
          it_jest                  = gt_jest
          it_jsto                  = gt_jsto
        EXCEPTIONS
          error_insert_resb        = 1
          error_update_resb        = 2
          error_insert_onro        = 3
          error_insert_zppresb_add = 4
          error_insert_jest        = 5
          error_insert_jsto        = 6.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_UOM_CONVERSION
*&---------------------------------------------------------------------*
FORM f_uom_conversion  USING    fu_matnr
                                fu_meins
                                fu_erfme
                                fu_menge
                       CHANGING fu_erfmg.
  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
    EXPORTING
      input                = fu_menge
      matnr                = fu_matnr
      meinh                = fu_erfme
      meins                = fu_meins
    IMPORTING
      output               = fu_erfmg
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
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_POST_GOODS_ISSUE
*&---------------------------------------------------------------------*
FORM f_post_goods_issue  TABLES   ft_pgi   STRUCTURE zsffst001
                         USING    fu_data
                         CHANGING fc_mblnr
                                  fc_mjahr
                                  fc_data
                                  fc_msgtyp
                                  fc_message.
  DATA: lv_json_data TYPE string,
        ls_fp_pgi    TYPE ts_fp_pgi.

  DATA: goodsmvt_header  TYPE bapi2017_gm_head_01,
        goodsmvt_code    TYPE bapi2017_gm_code,
        goodsmvt_headret TYPE bapi2017_gm_head_ret,
        goodsmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
        ls_item          LIKE LINE OF goodsmvt_item,
        return           TYPE STANDARD TABLE OF bapiret2,
        ls_return        LIKE LINE OF return.

  lv_json_data = fu_data.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_fp_pgi ).

  SELECT aufnr, posnr, matnr INTO TABLE @DATA(lt_afpo)
    FROM afpo WHERE aufnr = @ls_fp_pgi-aufnr.

  goodsmvt_code = '03'.

  goodsmvt_header-pstng_date        = sy-datum.
  goodsmvt_header-doc_date          = sy-datum.
*  CONCATENATE gs_head-wb gs_head-operator gs_head-pengawas
*    INTO goodsmvt_header-header_txt SEPARATED BY ';'.
  goodsmvt_header-ver_gr_gi_slip    = '1'.
  goodsmvt_header-ver_gr_gi_slipx   = 'X'.

  LOOP AT ft_pgi INTO DATA(ls_pgi).
    IF ls_pgi-erfmg IS INITIAL.
      CONTINUE.
    ENDIF.

    ls_item-material    = ls_fp_pgi-matnr.
    ls_item-plant       = ls_fp_pgi-werks.
    ls_item-stge_loc    = ls_pgi-lgort.
    ls_item-batch       = ls_fp_pgi-charg.
    ls_item-entry_uom   = ls_pgi-erfme.
    ls_item-orderid     = ls_pgi-aufnr.
    ls_item-order_itno  = ls_pgi-posnr.
    ls_item-reserv_no   = ls_pgi-rsnum.
    ls_item-res_item    = ls_pgi-rspos.
    ls_item-move_type   = '261'.
    ls_item-order_itno  = VALUE #( lt_afpo[ aufnr = ls_pgi-aufnr
                                            matnr = ls_pgi-baugr ]-posnr OPTIONAL ).

*    IF NOT lt_afpo[] IS INITIAL.
*      READ TABLE lt_afpo INTO DATA(ls_afpo) WITH KEY aufnr = ls_pgi-aufnr
*                                               matnr = ls_pgi-baugr.
*      IF sy-subrc = 0.
*        ls_item-order_itno = ls_afpo-posnr.
*      ENDIF.
*    ENDIF.

    IF ls_pgi-erfme = ls_pgi-meins.
      ls_item-entry_qnt = ls_pgi-erfmg * ls_fp_pgi-packs.
    ELSE.
      ls_item-quantity         = ls_pgi-erfmg * ls_fp_pgi-packs.
      ls_item-base_uom         = ls_pgi-meins.
      PERFORM f_uom_conversion USING ls_item-material
                                     ls_item-base_uom
                                     ls_item-entry_uom
                                     ls_item-quantity
                               CHANGING ls_item-entry_qnt.
    ENDIF.

    APPEND ls_item TO goodsmvt_item.
    CLEAR ls_item.
  ENDLOOP.

  IF goodsmvt_item[] IS INITIAL.
    fc_msgtyp = 'E'.
    fc_message = 'No Data Process...'.

  ELSE.
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = goodsmvt_header
        goodsmvt_code    = goodsmvt_code
      IMPORTING
        goodsmvt_headret = goodsmvt_headret
        materialdocument = fc_mblnr
        matdocumentyear  = fc_mjahr
      TABLES
        goodsmvt_item    = goodsmvt_item
        return           = return.

    IF fc_mblnr IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      fc_msgtyp = 'S'.
      CONCATENATE 'Document' fc_mblnr 'created' INTO fc_message
      SEPARATED BY space.

    ELSE.
      READ TABLE return INTO ls_return WITH KEY type = 'E'.
      IF sy-subrc = 0.
        fc_msgtyp = 'E'.
        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            msgid               = ls_return-id
            msgnr               = ls_return-number
            msgv1               = ls_return-message_v1
            msgv2               = ls_return-message_v2
            msgv3               = ls_return-message_v3
            msgv4               = ls_return-message_v4
          IMPORTING
            message_text_output = fc_message.
      ENDIF.

* Back to condition before PGI
      CLEAR: gt_add[],gt_resb_update[].
      CALL FUNCTION 'ZTSPPPFM002'
        TABLES
          it_add                   = gt_add
          it_dresb                 = gt_resb_insert
          it_uresb                 = gt_resb_update
          it_onr00                 = gt_onr00
          it_jest                  = gt_jest
          it_jsto                  = gt_jsto
        EXCEPTIONS
          error_delete_resb        = 1
          error_update_resb        = 2
          error_delete_onr00       = 3
          error_delete_jest        = 4
          error_delete_jsto        = 5
          error_delete_zppresb_add = 6.
      IF sy-subrc <> 0.
        ROLLBACK WORK.
      ELSE.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_RESB
*&---------------------------------------------------------------------*
FORM f_update_resb  TABLES   ft_pgi STRUCTURE zsffst001
                    USING    fu_data
                    CHANGING fc_mblnr
                             fc_mjahr
                             fc_msgtyp
                             fc_message.
  DATA: lv_json_data TYPE string,
        ls_fp_pgi    TYPE ts_fp_pgi.

  DATA: lv_enmng LIKE resb-enmng,
        ls_xresb LIKE resb.

  lv_json_data = fu_data.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_fp_pgi ).

  LOOP AT ft_pgi INTO DATA(ls_pgi).
    IF ls_pgi-erfmg IS INITIAL.
      CONTINUE.
    ENDIF.

    CLEAR: lv_enmng,ls_xresb.

    lv_enmng = ls_fp_pgi-packs * ls_pgi-erfmg.

    SELECT SINGLE * INTO ls_xresb
      FROM resb WHERE rsnum = ls_pgi-rsnum
                  AND rspos = ls_pgi-rspos
                  AND splkz IN (' ','1').

    IF sy-subrc = 0.
      IF ls_xresb-splkz = ' '.
        ls_xresb-nomng = ls_xresb-bdmng.
        ls_xresb-bdmng = ls_xresb-nomng - lv_enmng.
      ELSEIF ls_xresb-splkz = '1'.
        ls_xresb-bdmng = ls_xresb-bdmng - lv_enmng.
      ENDIF.

      ls_xresb-splkz = '1'.
      ls_xresb-erfmg = ls_xresb-vmeng = ls_xresb-bdmng.
      CLEAR ls_xresb-enmng.

      IF ls_xresb-erfme NE ls_xresb-meins.
        PERFORM f_uom_conversion USING ls_xresb-matnr
                                       ls_xresb-meins
                                       ls_xresb-erfme
                                       ls_xresb-bdmng
                                 CHANGING ls_xresb-erfmg.
      ENDIF.

* Update RESB untuk confirm quantity
      CLEAR: gt_resb_update[],gt_add,gt_resb_insert,gt_onr00,gt_jest,gt_jsto.
      APPEND ls_xresb TO gt_resb_update.

      CALL FUNCTION 'ZTSPPPFM001'
        TABLES
          it_add                   = gt_add
          it_iresb                 = gt_resb_insert
          it_uresb                 = gt_resb_update
          it_onr00                 = gt_onr00
          it_jest                  = gt_jest
          it_jsto                  = gt_jsto
        EXCEPTIONS
          error_insert_resb        = 1
          error_update_resb        = 2
          error_insert_onro        = 3
          error_insert_zppresb_add = 4
          error_insert_jest        = 5
          error_insert_jsto        = 6.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_LABEL
*&---------------------------------------------------------------------*
FORM f_collect_label  TABLES   ft_pgi    STRUCTURE zsffst001
                      USING    fu_mblnr fu_mjahr fu_data
                      CHANGING fc_data.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        lv_json_data TYPE string,
        ls_fp_pgi    TYPE ts_fp_pgi.

  DATA: lt_label         TYPE STANDARD TABLE OF zsffst001,
        lv_count         TYPE i,
        lv_count_txt(20), lv_total_txt(20), lv_charg(10).

  DATA: defaults  LIKE  bapidefaul,
        parameter	TYPE STANDARD TABLE OF bapiparam,
        return    TYPE STANDARD TABLE OF bapiret2.

  lv_json_data = fu_data.
  zcl_json=>deserialize(
    EXPORTING
      json   = lv_json_data
    CHANGING
      data   = ls_fp_pgi ).

  SELECT SINGLE aufnr, werks, plnbez, strdate, objnr, charg, maktx
    INTO @DATA(ls_cdsv02)
    FROM zdmp_cdsv02 AS a JOIN makt AS b ON a~plnbez = b~matnr
    WHERE aufnr = @ls_fp_pgi-aufnr.

  ls_fp_pgi-plnbez = ls_cdsv02-plnbez.
  ls_fp_pgi-fmaktx = ls_cdsv02-maktx.
  ls_fp_pgi-fcharg = ls_cdsv02-charg.
  ls_fp_pgi-mblnr  = fu_mblnr.
  ls_fp_pgi-mjahr  = fu_mjahr.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username  = sy-uname
    IMPORTING
      defaults  = defaults
    TABLES
      parameter = parameter
      return    = return.
  IF sy-subrc = 0.
    ls_fp_pgi-ipno = VALUE #( parameter[ parid = 'PRI' ]-parva OPTIONAL ).
  ENDIF.

  SELECT SINGLE * INTO @DATA(ls_hazcom)
    FROM ztspmdhazcom WHERE matnr = @ls_fp_pgi-matnr
                        AND werks = @ls_fp_pgi-werks.
  IF sy-subrc = 0.
    ls_fp_pgi-hazcom = |H =| & | | & |{ ls_hazcom-health }| & | | &
                       |F =| & | | & |{ ls_hazcom-fire }| & | | &
                       |R =| & | | & |{ ls_hazcom-reactivity }|.
  ENDIF.

  SELECT SINGLE a~name1 INTO ls_fp_pgi-name1
    FROM lfa1 AS a JOIN mch1 AS b ON a~lifnr = b~lifnr
    WHERE b~matnr = ls_fp_pgi-matnr
      AND b~charg = ls_fp_pgi-charg.
  IF sy-subrc = 0 AND ls_fp_pgi-name1 IS NOT INITIAL.
    ls_fp_pgi-name1 = |(| & |{ ls_fp_pgi-name1(30) }| & |)|.
  ENDIF.

  LOOP AT ft_pgi INTO DATA(ls_pgi).
    DO ls_pgi-erfmg TIMES.
      APPEND INITIAL LINE TO lt_label ASSIGNING FIELD-SYMBOL(<fs_label>).
      MOVE-CORRESPONDING ls_pgi TO <fs_label>.

      WRITE ls_fp_pgi-packs TO <fs_label>-erfmgt UNIT <fs_label>-erfme.
      CONDENSE <fs_label>-erfmgt NO-GAPS.
      <fs_label>-erfme = |{ <fs_label>-erfme ALPHA = OUT }|.
      CONCATENATE <fs_label>-erfmgt <fs_label>-erfme
        INTO <fs_label>-erfmgt SEPARATED BY space.

      ADD 1 TO lv_count.
      WRITE lv_count TO lv_count_txt DECIMALS 0.
      CONDENSE lv_count_txt.
      WRITE ls_fp_pgi-packt TO lv_total_txt DECIMALS 0.
      CONDENSE lv_total_txt.
      CONCATENATE lv_count_txt '/' lv_total_txt INTO <fs_label>-counter.

      lv_charg = ls_fp_pgi-charg.
      SHIFT lv_charg LEFT DELETING LEADING '0'.
      CONCATENATE ls_fp_pgi-plnbez ls_fp_pgi-aufnr <fs_label>-vornr
                  <fs_label>-posnr  ls_fp_pgi-matnr <fs_label>-erfmgt
                  <fs_label>-counter 'F' lv_charg fu_mblnr
        INTO <fs_label>-qrcode SEPARATED BY ';'.
    ENDDO.
  ENDLOOP.

  IF lt_label[] IS NOT INITIAL.
    ft_pgi[] = lt_label[].
  ENDIF.

  CREATE OBJECT cl_json_data
    EXPORTING
      data = ls_fp_pgi.
  cl_json_data->serialize( ).
  fc_data = cl_json_data->get_data( ).
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_ZsffPPDT002
*&---------------------------------------------------------------------*
FORM f_write_zsffppdt002  TABLES   ft_pgi         STRUCTURE zsffst001
                                   ft_resb_insert STRUCTURE resb
                          USING    fu_mblnr fu_mjahr fu_data.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        lv_json_data TYPE string,
        ls_fp_pgi    TYPE ts_fp_pgi.

  DATA: lt_zsffppdt002 TYPE STANDARD TABLE OF zsffppdt002,
        lv_counter     TYPE zeile,
        lv_total       TYPE zeile.

  DATA: oref       TYPE REF TO cx_root,
        lv_message TYPE char100.

  lv_json_data = fu_data.
  zcl_json=>deserialize(
    EXPORTING
      json   = lv_json_data
    CHANGING
      data   = ls_fp_pgi ).

  SORT: gt_resb_insert BY rsnum rspos,
        ft_pgi BY rsnum rspos.

  LOOP AT ft_resb_insert INTO DATA(ls_resb).
    LOOP AT ft_pgi INTO DATA(ls_pgi) WHERE rsnum = ls_resb-rsnum
                                       AND rspos = ls_resb-rspos.
      SPLIT ls_pgi-counter AT '/' INTO lv_counter lv_total.

      APPEND INITIAL LINE TO lt_zsffppdt002 ASSIGNING FIELD-SYMBOL(<fs_zsffppdt002>).
      <fs_zsffppdt002>-rsnum      = ls_resb-rsnum.
      <fs_zsffppdt002>-rspos      = ls_resb-rspos.
      <fs_zsffppdt002>-rsart      = ls_resb-rsart.
      <fs_zsffppdt002>-zeile      = lv_counter.
      <fs_zsffppdt002>-aufnr      = ls_resb-aufnr.
      <fs_zsffppdt002>-posnr      = ls_resb-posnr.
      <fs_zsffppdt002>-matnr      = ls_resb-matnr.
      <fs_zsffppdt002>-werks      = ls_resb-werks.
      <fs_zsffppdt002>-lgort      = ls_resb-lgort.
      <fs_zsffppdt002>-charg      = ls_resb-charg.
      <fs_zsffppdt002>-erfmg      = ls_fp_pgi-packs.
      <fs_zsffppdt002>-erfme      = ls_resb-erfme.
      <fs_zsffppdt002>-sortf      = ls_resb-sortf.
      <fs_zsffppdt002>-vornr      = ls_resb-vornr.
      <fs_zsffppdt002>-ltxa1      = ls_pgi-ltxa1.
*      <fs_ZsffPPDT002>-phseq      = lw_afvc-phseq.
*      <fs_ZsffPPDT002>-wbooth     = gs_head-wb.
      <fs_zsffppdt002>-operator   = ls_fp_pgi-operator.
      <fs_zsffppdt002>-pengawas   = ls_fp_pgi-pengawas.
      <fs_zsffppdt002>-erdat      = sy-datum.
      <fs_zsffppdt002>-ertim      = sy-uzeit.
      <fs_zsffppdt002>-mblnr      = fu_mblnr.
      <fs_zsffppdt002>-mjahr      = fu_mjahr.
    ENDLOOP.
  ENDLOOP.

  IF lt_zsffppdt002[] IS NOT INITIAL.
    TRY.
        INSERT zsffppdt002 FROM TABLE lt_zsffppdt002.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_REFORMAT
*&---------------------------------------------------------------------*
FORM f_reformat  USING    fu_data.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        lv_json_data TYPE string,
        ls_fp_pgi    TYPE ts_fp_pgi,
        ls_fp_pgi2   TYPE ts_fp_pgi2.

  lv_json_data = fu_data.
  zcl_json=>deserialize(
    EXPORTING
      json   = lv_json_data
    CHANGING
      data   = ls_fp_pgi ).

  MOVE-CORRESPONDING ls_fp_pgi TO ls_fp_pgi2.
  WRITE: ls_fp_pgi-packs TO ls_fp_pgi2-packs DECIMALS 0,
         ls_fp_pgi-packt TO ls_fp_pgi2-packt DECIMALS 0.
  CONDENSE: ls_fp_pgi2-packs,ls_fp_pgi2-packt.

  CREATE OBJECT cl_json_data
    EXPORTING
      data = ls_fp_pgi2.
  cl_json_data->serialize( ).
  fu_data = cl_json_data->get_data( ).
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_WH_PRINT
*&---------------------------------------------------------------------*
FORM f_wh_print  TABLES   ft_wh_print STRUCTURE zsffst003
                          ft_wh_print_vnd STRUCTURE zsffst004
                 USING    fu_data
                 CHANGING fc_data
                          fc_msgtyp
                          fc_message.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        lv_json_data TYPE string,
        ls_wh_print  TYPE ts_wh_print.

  lv_json_data = fu_data.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_wh_print ).

*  REPLACE ALL OCCURRENCES OF '.' IN ls_wh_print-netto WITH space.
*  REPLACE ALL OCCURRENCES OF ',' IN ls_wh_print-netto WITH '.'.
*  REPLACE ALL OCCURRENCES OF '.' IN ls_wh_print-tara WITH space.
*  REPLACE ALL OCCURRENCES OF ',' IN ls_wh_print-tara WITH '.'.
*  REPLACE ALL OCCURRENCES OF '.' IN ls_wh_print-bruto WITH space.
*  REPLACE ALL OCCURRENCES OF ',' IN ls_wh_print-bruto WITH '.'.
  REPLACE ALL OCCURRENCES OF ',' IN ls_wh_print-netto WITH space.
  REPLACE ALL OCCURRENCES OF ',' IN ls_wh_print-tara WITH space.
  REPLACE ALL OCCURRENCES OF ',' IN ls_wh_print-bruto WITH space.
  CONDENSE: ls_wh_print-netto,ls_wh_print-tara,ls_wh_print-bruto.
  TRANSLATE ls_wh_print-erfme TO UPPER CASE.

  PERFORM f_wh_add_lines_resb USING    ls_wh_print
                              CHANGING fc_msgtyp
                                       fc_message.

  IF fc_msgtyp NE 'E'.
    SELECT SINGLE maktx INTO ls_wh_print-maktx
      FROM makt WHERE matnr = ls_wh_print-matnr.

    SELECT SINGLE maktx INTO ls_wh_print-fmaktx
      FROM makt WHERE matnr = ls_wh_print-plnbez.

    PERFORM f_get_hazcom USING ls_wh_print-matnr ls_wh_print-werks
                         CHANGING ls_wh_print-hazcom.

    PERFORM f_get_weight TABLES   ft_wh_print
                         USING    ls_wh_print-aufnr ls_wh_print-vornr
                                  ls_wh_print-posnr ls_wh_print-werks
                         CHANGING ls_wh_print-netto ls_wh_print-tara
                                  ls_wh_print-bruto ls_wh_print-erfme.

    PERFORM f_get_vendor TABLES ft_wh_print ft_wh_print_vnd
                         USING ls_wh_print-matnr.

    CONCATENATE ls_wh_print-plnbez ls_wh_print-aufnr ls_wh_print-vornr
                ls_wh_print-posnr ls_wh_print-matnr ls_wh_print-netto
                INTO ls_wh_print-qrcode SEPARATED BY ';'.

    CREATE OBJECT cl_json_data
      EXPORTING
        data = ls_wh_print.
    cl_json_data->serialize( ).
    fc_data = cl_json_data->get_data( ).
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_HAZCOM
*&---------------------------------------------------------------------*
FORM f_get_hazcom  USING    fu_matnr
                            fu_werks
                   CHANGING fc_hazcom.
  SELECT SINGLE * INTO @DATA(ls_hazcom)
    FROM ztspmdhazcom WHERE matnr = @fu_matnr
                        AND werks = @fu_werks.
  IF sy-subrc = 0.
    fc_hazcom = |H =| & | | & |{ ls_hazcom-health }| & | | &
                |F =| & | | & |{ ls_hazcom-fire }| & | | &
                |R =| & | | & |{ ls_hazcom-reactivity }|.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_VENDOR
*&---------------------------------------------------------------------*
FORM f_get_vendor  TABLES   ft_wh_print STRUCTURE zsffst003
                            ft_wh_print_vnd STRUCTURE zsffst004
                   USING    fs_matnr.
  SELECT a~lifnr a~name1 INTO TABLE ft_wh_print_vnd
    FROM lfa1 AS a JOIN mch1 AS b ON a~lifnr = b~lifnr
    FOR ALL ENTRIES IN ft_wh_print
    WHERE matnr = fs_matnr
      AND charg = ft_wh_print-charg.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_WEIGHT
*&---------------------------------------------------------------------*
FORM f_get_weight  TABLES   ft_wh_print STRUCTURE zsffst003
                   USING    fu_aufnr fu_vornr fu_posnr fu_werks
                   CHANGING fc_netto fc_tara fc_bruto fc_erfme.
  DATA: lv_tara  TYPE erfmg,
        lv_netto TYPE erfmg,
        lv_bruto TYPE erfmg,
        lv_erfme TYPE erfme.

  IF gt_zsffppdt003[] IS NOT INITIAL.
    LOOP AT gt_zsffppdt003 INTO DATA(ls_zsffppdt003).
      APPEND INITIAL LINE TO ft_wh_print ASSIGNING FIELD-SYMBOL(<fs_wh_print>).
      MOVE-CORRESPONDING ls_zsffppdt003 TO <fs_wh_print>.
      <fs_wh_print>-weime = ls_zsffppdt003-erfme.
      WRITE ls_zsffppdt003-erfmg TO <fs_wh_print>-erfmg UNIT ls_zsffppdt003-erfme.
      CONDENSE <fs_wh_print>-erfmg.
    ENDLOOP.

    lv_netto = REDUCE erfmg( INIT x TYPE erfmg FOR wa_zsffppdt003 IN gt_zsffppdt003
                             NEXT x = x + wa_zsffppdt003-erfmg ).
    lv_erfme = VALUE #( gt_zsffppdt003[ 1 ]-erfme ).

    lv_tara = fc_tara.
    IF fc_erfme NE lv_erfme.
      CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
        EXPORTING
          input                = lv_tara
          unit_in              = fc_erfme
          unit_out             = lv_erfme
        IMPORTING
          output               = lv_tara
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

    lv_bruto = lv_netto + lv_tara.
    WRITE lv_tara TO fc_tara UNIT lv_erfme.
    WRITE lv_netto TO fc_netto UNIT lv_erfme.
    WRITE lv_bruto TO fc_bruto UNIT lv_erfme.
    fc_erfme = lv_erfme.
    CONDENSE: fc_netto,fc_tara,fc_bruto.
*    fc_netto = |{ fc_netto }| && | | && |{ lv_erfme }|.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_WH_ADD_LINES_RESB
*&---------------------------------------------------------------------*
FORM f_wh_add_lines_resb  USING    fu_wh_print STRUCTURE gs_wh_print
                          CHANGING fc_msgtyp
                                   fc_message.
  DATA: lv_aplzl    LIKE resb-aplzl,
        lv_enmng    LIKE resb-enmng,
        lv_date(10), lv_time(10).

  SELECT * INTO TABLE gt_zsffppdt003
    FROM zsffppdt003 WHERE aufnr = fu_wh_print-aufnr
                       AND vornr = fu_wh_print-vornr
                       AND posnr = fu_wh_print-posnr.
  IF sy-subrc NE 0.
    fc_msgtyp  = 'E'.
    fc_message = 'No Data Weighing'.

  ELSE.
    SELECT MAX( rspos ) INTO @DATA(lv_rspos)
      FROM resb WHERE rsnum = @fu_wh_print-rsnum.
    IF sy-subrc NE 0.
      fc_msgtyp  = 'E'.
      fc_message = 'Reservation Number Invalid'.

    ELSE.
      SELECT SINGLE * INTO @DATA(ls_resb_upd)
        FROM resb WHERE rsnum = @fu_wh_print-rsnum
                    AND rspos = @fu_wh_print-rspos
                    AND splkz IN (' ','1').
      IF sy-subrc NE 0.
        fc_msgtyp  = 'E'.
        fc_message = 'Reservation Item Invalid'.

      ELSE.
        SELECT SINGLE phseq INTO @DATA(lv_phseq)
          FROM afvc WHERE aufpl = @ls_resb_upd-aufpl
                      AND vornr = @ls_resb_upd-vornr.
        SELECT * INTO TABLE @DATA(lt_jest_tmp)
          FROM jest WHERE objnr = @ls_resb_upd-objnr.
        SELECT * INTO TABLE @DATA(lt_jsto_tmp)
          FROM jsto WHERE objnr = @ls_resb_upd-objnr.

        DATA(lr_charg) = VALUE rseloption( FOR wa_zsffppdt003 IN gt_zsffppdt003
                                         ( sign = 'I'
                                           option = 'EQ'
                                           low = wa_zsffppdt003-charg ) ).

        SELECT a~matnr, a~werks, a~lgort, a~charg, b~meins,
               SUM( a~clabs ) AS stock
          INTO TABLE @DATA(lt_stock)
          FROM mchb AS a JOIN mara AS b ON b~matnr = a~matnr
          WHERE a~matnr = @ls_resb_upd-matnr
            AND a~werks = @ls_resb_upd-werks
            AND a~lgort = @ls_resb_upd-lgort
            AND a~charg IN @lr_charg
          GROUP BY a~matnr, a~werks, a~lgort, a~charg, b~meins.

        SELECT matnr, werks, lgort, charg, meins,
               SUM( bdmng ) AS revers
          INTO TABLE @DATA(lt_revers)
          FROM resb
          WHERE matnr = @ls_resb_upd-matnr
            AND werks = @ls_resb_upd-werks
            AND lgort = @ls_resb_upd-lgort
            AND charg IN @lr_charg
*            AND xloek = @space
            AND kzear = @space
            AND splkz = '2'
            AND wempf IN ('T','W')
          GROUP BY matnr, werks, lgort, charg, meins, erfme.

        LOOP AT gt_zsffppdt003 INTO DATA(ls_zsffppdt003).
* Check Stock
          DATA(lv_stock) = REDUCE labst( INIT x TYPE labst FOR wa_stock IN lt_stock
                                                           WHERE ( matnr = ls_zsffppdt003-matnr AND
                                                                   charg = ls_zsffppdt003-charg AND
                                                                   werks = ls_zsffppdt003-werks )
                                         NEXT x = x + wa_stock-stock ).
          DATA(lv_revers) = REDUCE erfmg( INIT x TYPE erfmg FOR wa_revers IN lt_revers
                                                           WHERE ( matnr = ls_zsffppdt003-matnr AND
                                                                   charg = ls_zsffppdt003-charg AND
                                                                   werks = ls_zsffppdt003-werks )
                                         NEXT x = x + wa_revers-revers ).
          DATA(lv_erfmg) = ls_zsffppdt003-erfmg.

          IF ls_zsffppdt003-erfme NE ls_resb_upd-meins.
            PERFORM f_unit_conversion_simple USING ls_zsffppdt003-erfme
                                                   ls_zsffppdt003-matnr
                                                   ls_resb_upd-meins
                                             CHANGING lv_erfmg.
*            PERFORM f_unit_conversion_simple USING ls_zsffppdt003-erfme
*                                                   ls_zsffppdt003-matnr
*                                                   ls_resb_upd-meins
*                                             CHANGING lv_revers.
          ENDIF.

          lv_stock = lv_stock - lv_revers.

          IF lv_stock LT lv_erfmg.
            fc_msgtyp   = 'E'.
            fc_message  = 'Stock not available'.
            EXIT. "FROM STEP-LOOP.
          ENDIF.

          ADD 1 TO lv_rspos.
          lv_aplzl = ls_resb_upd-rspos.
          lv_enmng = ls_zsffppdt003-erfmg.

          IF ls_zsffppdt003-erfme NE ls_resb_upd-meins.
            PERFORM f_unit_conversion_simple USING ls_zsffppdt003-erfme
                                                   ls_resb_upd-matnr
                                                   ls_resb_upd-meins
                                             CHANGING lv_enmng.
          ENDIF.

          "Collect itab RESB for Insert
          DATA(ls_resb) = ls_resb_upd.
          ls_resb-rspos = lv_rspos.
          ls_resb-charg = ls_zsffppdt003-charg.
          ls_resb-bdmng = ls_resb-vmeng = lv_enmng.
          ls_resb-erfmg = ls_zsffppdt003-erfmg.
          ls_resb-splkz = '2'.
          ls_resb-wempf = 'W'.
          ls_resb-splrv = lv_aplzl.
          CLEAR: ls_resb-stvkn,ls_resb-nomng,ls_resb-enmng,ls_resb-enwrt.
          CONCATENATE ls_resb-objnr(2) ls_resb-rsnum ls_resb-rspos INTO ls_resb-objnr.
          APPEND ls_resb TO gt_resb_insert.

          "Collect itab ONR00 for Insert
          gs_onr00-objnr = ls_resb-objnr.
          APPEND gs_onr00 TO gt_onr00.

          "Collect itab JEST for Insert
          LOOP AT lt_jest_tmp INTO DATA(ls_jest_tmp).
            MOVE-CORRESPONDING ls_jest_tmp TO gs_jest.
            gs_jest-objnr = ls_resb-objnr.
            APPEND gs_jest TO gt_jest.
          ENDLOOP.

          "Collect itab JSTO for Insert
          LOOP AT lt_jsto_tmp INTO DATA(ls_jsto_tmp).
            MOVE-CORRESPONDING ls_jsto_tmp TO gs_jsto.
            gs_jsto-objnr = ls_resb-objnr.
            APPEND gs_jsto TO gt_jsto.
          ENDLOOP.
        ENDLOOP.

        IF fc_msgtyp IS INITIAL.
          "Collect itab zsffppdt004
          fu_wh_print-aufnr = |{ fu_wh_print-aufnr ALPHA = IN }|.

          SELECT SINGLE * INTO @DATA(ls_zsffppdt005)
            FROM zsffppdt005 WHERE aufnr = @fu_wh_print-aufnr
                               AND matnr = @fu_wh_print-matnr
                               AND posnr = @fu_wh_print-posnr.

          APPEND INITIAL LINE TO gt_zsffppdt004 ASSIGNING FIELD-SYMBOL(<fs_zsffppdt004>).
          <fs_zsffppdt004>-aufnr        = fu_wh_print-aufnr.
          <fs_zsffppdt004>-matnr        = fu_wh_print-matnr.
          <fs_zsffppdt004>-werks        = fu_wh_print-werks.
          <fs_zsffppdt004>-equnr        = fu_wh_print-equnr.
          <fs_zsffppdt004>-shtxt        = fu_wh_print-eqktx.
          <fs_zsffppdt004>-posnr        = fu_wh_print-posnr.
          <fs_zsffppdt004>-ltxa1        = fu_wh_print-ltxa1.
          <fs_zsffppdt004>-operator     = fu_wh_print-operator.
          <fs_zsffppdt004>-pengawas     = fu_wh_print-pengawas.
          <fs_zsffppdt004>-wbooth       = fu_wh_print-wb.
          <fs_zsffppdt004>-tara         = fu_wh_print-tara.
          <fs_zsffppdt004>-meins        = ls_resb_upd-erfme.
          <fs_zsffppdt004>-istad        = ls_zsffppdt005-istad.
          <fs_zsffppdt004>-istau        = ls_zsffppdt005-istau.
          <fs_zsffppdt004>-datum        = sy-datum.
          <fs_zsffppdt004>-uzeit        = sy-uzeit.
          <fs_zsffppdt004>-vornr        = fu_wh_print-vornr.
          <fs_zsffppdt004>-sortf        = ls_resb-sortf.
          <fs_zsffppdt004>-phseq        = lv_phseq.

          WRITE: <fs_zsffppdt004>-datum TO lv_date,
                 <fs_zsffppdt004>-uzeit TO lv_time.
          fu_wh_print-datum = |{ lv_date }| & | | & |{ lv_time }|.

          IF fu_wh_print-erfme NE <fs_zsffppdt004>-meins.
            PERFORM f_unit_conversion_simple USING fu_wh_print-erfme
                                                   <fs_zsffppdt004>-matnr
                                                   <fs_zsffppdt004>-meins
                                             CHANGING <fs_zsffppdt004>-tara.
          ENDIF.

          "Collect itab RESB UPDATE
          DATA(lv_netto) = REDUCE erfmg( INIT x TYPE erfmg FOR wa_zsffppdt003 IN gt_zsffppdt003
                                   NEXT x = x + wa_zsffppdt003-erfmg ).
          DATA(lv_erfme) = VALUE #( gt_zsffppdt003[ 1 ]-erfme ).
          DATA(lv_meins) = VALUE #( gt_zsffppdt003[ 1 ]-meins ).

          IF ls_resb_upd-nomng IS INITIAL.
            ls_resb_upd-nomng  = ls_resb_upd-bdmng.
          ENDIF.

          ls_resb_upd-erfmg  = ls_resb_upd-erfmg - lv_netto.

          IF lv_erfme NE ls_resb_upd-meins.
            PERFORM f_unit_conversion_simple USING lv_erfme
                                                   ls_resb_upd-matnr
                                                   ls_resb_upd-meins
                                             CHANGING lv_netto.
          ENDIF.

          ls_resb_upd-bdmng  = ls_resb_upd-bdmng - lv_netto.
          ls_resb_upd-vmeng  = ls_resb_upd-vmeng - lv_netto.
          ls_resb_upd-splkz  = '1'.
          ls_resb_upd-kzear = 'X'.
          APPEND ls_resb_upd TO gt_resb_update.

          "Insert & Update RESB
          IF gt_resb_insert[] IS INITIAL.
            fc_msgtyp = 'E'.
            fc_message = 'No Data Process...'.
          ELSE.
            CALL FUNCTION 'ZTSPPPFM001'
              TABLES
                it_add                   = gt_add
                it_iresb                 = gt_resb_insert
                it_uresb                 = gt_resb_update
                it_onr00                 = gt_onr00
                it_jest                  = gt_jest
                it_jsto                  = gt_jsto
                it_zsffppdt004           = gt_zsffppdt004
              EXCEPTIONS
                error_insert_resb        = 1
                error_update_resb        = 2
                error_insert_onro        = 3
                error_insert_zppresb_add = 4
                error_insert_jest        = 5
                error_insert_jsto        = 6
                error_insert_zsffppdt004 = 7.
            IF sy-subrc = 0.
              COMMIT WORK AND WAIT.
              DELETE zsffppdt003 FROM TABLE gt_zsffppdt003.
              fc_msgtyp = 'S'.
              fc_message = 'Insert RESB Success...'.
            ELSE.
              ROLLBACK WORK.
              fc_msgtyp = 'E'.
              fc_message = 'Insert RESB ERROR...'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION_SIMPLE
*&---------------------------------------------------------------------*
FORM f_unit_conversion_simple  USING    fu_unit_in
                                        fu_matnr
                                        fu_unit_out
                               CHANGING fc_qty.
  DATA: lv_qty   TYPE erfmg,
        lv_umren TYPE marm-umren,
        lv_umrez TYPE marm-umrez.

  IF fu_unit_out = 'L'.
    CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
      EXPORTING
        input                = fc_qty
        matnr                = fu_matnr
        meinh                = fu_unit_in
        meins                = fu_unit_out
      IMPORTING
        output               = lv_qty
        umren                = lv_umren
        umrez                = lv_umrez
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
    IF sy-subrc = 0.
      fc_qty = fc_qty * lv_umrez / lv_umren.
    ENDIF.
  ELSE.
    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        input                = fc_qty
        unit_in              = fu_unit_in
        unit_out             = fu_unit_out
      IMPORTING
        output               = fc_qty
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
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_WH_PGI
*&---------------------------------------------------------------------*
FORM f_wh_pgi  USING    fu_data
               CHANGING fc_data
                        fc_msgtyp
                        fc_message.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        lv_json_data TYPE string,
        ls_wh_pgi    TYPE ts_wh_pgi,
        lv_sortf     TYPE resb-sortf.

  DATA : goodsmvt_header  TYPE bapi2017_gm_head_01,
         goodsmvt_code    TYPE bapi2017_gm_code,
         goodsmvt_headret TYPE bapi2017_gm_head_ret,
         goodsmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
         return           TYPE STANDARD TABLE OF bapiret2,
         materialdocument TYPE mseg-mblnr,
         matdocumentyear  TYPE mseg-mjahr.

  lv_json_data = fu_data.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_wh_pgi ).

  IF ls_wh_pgi-oprtyp IS INITIAL.
    lv_sortf = ' '.
  ELSE.
    lv_sortf = 'D'.
  ENDIF.

  SELECT rsnum, rspos, rsart, sortf, kzear, vornr, posnr, splkz, wempf,
         aufnr, matnr, werks, lgort, charg, meins, erfmg, erfme
    INTO TABLE @DATA(lt_resb)
    FROM resb WHERE aufnr = @ls_wh_pgi-aufnr
                AND vornr = @ls_wh_pgi-vornr
                AND sortf = @lv_sortf
                AND kzear = @space
                AND wempf = 'T'
                AND vmeng NE 0.

  goodsmvt_code = '03'.

  goodsmvt_header-pstng_date      = sy-datum.
  goodsmvt_header-doc_date        = sy-datum.
  goodsmvt_header-header_txt      = ls_wh_pgi-aufnr.
  goodsmvt_header-ver_gr_gi_slip  = '1'.
  goodsmvt_header-ver_gr_gi_slipx = 'X'.

  LOOP AT lt_resb INTO DATA(ls_resb).
    IF ls_resb-erfme NE ls_resb-meins.
      PERFORM f_unit_conversion_simple USING ls_resb-erfme
                                             ls_resb-matnr
                                             ls_resb-meins
                                       CHANGING ls_resb-erfmg.
    ENDIF.

    APPEND INITIAL LINE TO goodsmvt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
    <fs_item>-material    = ls_resb-matnr.
    <fs_item>-plant       = ls_resb-werks.
    <fs_item>-stge_loc    = ls_resb-lgort.
    <fs_item>-batch       = ls_resb-charg.
    <fs_item>-entry_uom   = ls_resb-meins.
    <fs_item>-orderid     = ls_resb-aufnr.
    <fs_item>-reserv_no   = ls_resb-rsnum.
    <fs_item>-res_item    = ls_resb-rspos.
    <fs_item>-move_type   = '261'.
    <fs_item>-entry_qnt   = ls_resb-erfmg.
  ENDLOOP.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = goodsmvt_header
      goodsmvt_code    = goodsmvt_code
    IMPORTING
      goodsmvt_headret = goodsmvt_headret
      materialdocument = materialdocument
      matdocumentyear  = matdocumentyear
    TABLES
      goodsmvt_item    = goodsmvt_item
      return           = return.

  IF materialdocument IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    fc_msgtyp = 'S'.
    CONCATENATE 'Document' materialdocument 'created' INTO fc_message
    SEPARATED BY space.

    ls_wh_pgi-mblnr = materialdocument.

  ELSE.
    READ TABLE return INTO DATA(ls_return) WITH KEY type = 'E'.
    IF sy-subrc = 0.
      fc_msgtyp = 'E'.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = ls_return-id
          msgnr               = ls_return-number
          msgv1               = ls_return-message_v1
          msgv2               = ls_return-message_v2
          msgv3               = ls_return-message_v3
          msgv4               = ls_return-message_v4
        IMPORTING
          message_text_output = fc_message.
    ENDIF.
  ENDIF.

  CREATE OBJECT cl_json_data
    EXPORTING
      data = ls_wh_pgi.
  cl_json_data->serialize( ).
  fc_data = cl_json_data->get_data( ).
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_STR_DATE
*&---------------------------------------------------------------------*
FORM f_str_date  USING    fu_data
                 CHANGING fc_data
                          fc_msgtyp
                          fc_message.
  DATA: cl_json_data   TYPE REF TO zcl_trex_json_serializer,
        lv_json_data   TYPE string,
        ls_wh_mat_scan TYPE ts_wh_mat_scan.

  DATA: lv_timestamp1 TYPE tzntstmps,
        lv_timestamp2 TYPE tzntstmps.

  lv_json_data = fu_data.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_wh_mat_scan ).

  SELECT SINGLE * INTO @DATA(ls_zsffppdt003)
    FROM zsffppdt003 WHERE aufnr = @ls_wh_mat_scan-aufnr
                       AND matnr = @ls_wh_mat_scan-matnr
                       AND posnr = @ls_wh_mat_scan-posnr.
  IF sy-subrc NE 0.
    SELECT SINGLE * INTO @DATA(ls_zsffppdt005)
      FROM zsffppdt005 WHERE aufnr = @ls_wh_mat_scan-aufnr
                         AND matnr = @ls_wh_mat_scan-matnr
                         AND posnr = @ls_wh_mat_scan-posnr.
    IF sy-subrc = 0.
      UPDATE zsffppdt005 SET istad = sy-datum
                             istau = sy-uzeit
                         WHERE aufnr = ls_wh_mat_scan-aufnr
                           AND matnr = ls_wh_mat_scan-matnr
                           AND posnr = ls_wh_mat_scan-posnr.
    ELSE.
      ls_zsffppdt005-aufnr = ls_wh_mat_scan-aufnr.
      ls_zsffppdt005-matnr = ls_wh_mat_scan-matnr.
      ls_zsffppdt005-posnr = ls_wh_mat_scan-posnr.
      ls_zsffppdt005-istad = sy-datum.
      ls_zsffppdt005-istau = sy-uzeit.
      INSERT zsffppdt005 FROM ls_zsffppdt005.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_TIMESTAMP
*&---------------------------------------------------------------------*
FORM f_get_timestamp  USING    fu_date
                               fu_time
                      CHANGING fc_timestamp.
  CALL FUNCTION 'ABI_TIMESTAMP_CONVERT_INTO'
    EXPORTING
      iv_date          = fu_date
      iv_time          = fu_time
    IMPORTING
      ev_timestamp     = fc_timestamp
    EXCEPTIONS
      conversion_error = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " F_GET_TIMESTAMP
