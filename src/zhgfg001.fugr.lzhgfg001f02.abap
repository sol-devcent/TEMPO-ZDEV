*----------------------------------------------------------------------*
***INCLUDE LZHGFG001F02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_POST_PUTAWAY
*&---------------------------------------------------------------------*
FORM f_post_putaway  TABLES   ft_to   STRUCTURE zhgwmst002
                     USING    p_json
                     CHANGING fc_type fc_message.
  DATA : lv_json_data TYPE string,
         ls_data      TYPE ty_putaway,
         lt_to        TYPE STANDARD TABLE OF zhgwmst002,
         ls_to        LIKE LINE OF lt_to.

  DATA : lv_werks TYPE t320-werks,
         lv_subrc TYPE sy-subrc.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_data ).

  SELECT SINGLE werks
    FROM t320
    INTO lv_werks
    WHERE lgnum = ls_data-warehouse_number.

  lt_to[] = ls_data-nav_to[].
  LOOP AT lt_to INTO ls_to.
    IF ls_to-material_document IS INITIAL AND
      ls_to-to_number IS INITIAL.
      PERFORM f_create_goods_movement USING "ls_qals
                                            lv_werks ls_data-material_number ls_to-batch
                                            ls_data-warehouse_number ls_to-quantity ls_to-uom
                                            ls_to-inspection_lot ls_to-pallet_number
                                      CHANGING ls_to-material_document ls_to-material_year
                                               lv_subrc.
    ENDIF.

    CASE lv_subrc.
      WHEN 0.
        ls_to-type      = 'S'.
        fc_type         = 'S'.
        ls_to-message   = 'Material document created'.
      WHEN 4.
        ls_to-type      = 'E'.
        fc_type         = 'E'.
        ls_to-message   = 'Lock by another'.
      WHEN OTHERS.
        ls_to-type      = 'E'.
        fc_type         = 'E'.
        ls_to-message   = 'Stock transfer error'.
    ENDCASE.

    APPEND ls_to TO ft_to.
    CLEAR : ls_to, lv_subrc.
  ENDLOOP.

  IF fc_type    = 'E'.
    fc_message  = 'Stock transfer error'.
  ELSE.
    fc_type     = 'S'.
    fc_message  = 'Material document created'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_READ_STATUS
*&---------------------------------------------------------------------*
FORM f_read_status  TABLES   ft_qals    STRUCTURE qals
                             ft_jest    STRUCTURE jest
                    USING    fu_prueflos
                    CHANGING fs_qals    TYPE qals
                             fc_subrc.
  DATA : ls_jest TYPE jest.

  CLEAR fs_qals.
  READ TABLE ft_qals INTO fs_qals
                     WITH KEY prueflos = fu_prueflos.
  IF sy-subrc = 0.
    READ TABLE ft_jest INTO ls_jest
                       WITH KEY objnr = fs_qals-objnr.
    fc_subrc = sy-subrc.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CALL_QAC2
*&---------------------------------------------------------------------*
FORM f_call_qac2 USING fu_prueflos
                 CHANGING fs_trite    TYPE l03b_trite
                          fc_mblnr fc_mjahr fc_tbnum fc_subrc.
  TYPES : BEGIN OF ty_ltbk,
            lgnum TYPE ltbk-lgnum,
            tbnum TYPE ltbk-tbnum,
            tbpos TYPE ltbp-tbpos,
            mblnr TYPE ltbk-mblnr,
            mjahr TYPE ltbk-mjahr,
          END OF ty_ltbk.

  DATA : lt_ltbk TYPE STANDARD TABLE OF ty_ltbk,
         ls_ltbk LIKE LINE OF lt_ltbk.

  DATA : lv_mode   TYPE char1,
         lv_update TYPE char1,
         lv_lgort  TYPE qals-lagortchrg,
         lv_bwart  TYPE ltbk-bwart.

  lv_mode   = 'N'.
  lv_update = 'S'.
  lv_lgort  = '3000'.
  lv_bwart  = '323'.

  SELECT ltbk~lgnum ltbk~tbnum ltbp~tbpos ltbk~mblnr ltbk~mjahr
        FROM ltbk JOIN ltbp ON ltbk~lgnum = ltbp~lgnum
                            AND ltbk~tbnum = ltbp~tbnum
        INTO CORRESPONDING FIELDS OF TABLE lt_ltbk
        WHERE ltbk~bwart = lv_bwart
          AND ltbp~qplos = fu_prueflos
          AND ltbp~elikz = space.
  IF sy-subrc = 0.
    SORT lt_ltbk BY mblnr DESCENDING.
    READ TABLE lt_ltbk INTO ls_ltbk INDEX 1.
    IF sy-subrc = 0.
      fc_mblnr       = ls_ltbk-mblnr.
      fc_mjahr       = ls_ltbk-mjahr.
      fc_tbnum       = ls_ltbk-tbnum.
      fs_trite-tbpos = ls_ltbk-tbpos.
    ENDIF.
  ELSE.
    CLEAR: t_bdcdata,t_bdcdata[],t_bdcmsg,t_bdcmsg[].
    PERFORM f_dynpro USING:
           'X' 'SAPLQPL1'      '0100',
           ' ' 'BDC_CURSOR'      'QALS-PRUEFLOS',
           ' ' 'BDC_OKCODE'     '/00',
           ' ' 'QALS-PRUEFLOS'  fu_prueflos,

           'X' 'SAPLQPL1'       '0300',
           ' ' 'BDC_CURSOR'     'RMQEA-UMLLGORT',
           ' ' 'BDC_OKCODE'     '=BU',
           ' ' 'RMQEA-UMLLGORT' lv_lgort.

    CALL TRANSACTION 'QAC2' USING t_bdcdata
                            MODE lv_mode
                            UPDATE lv_update
                            MESSAGES INTO t_bdcmsg[].

    IF sy-subrc = 0.
      SELECT ltbk~lgnum ltbk~tbnum ltbp~tbpos ltbk~mblnr ltbk~mjahr
        FROM ltbk JOIN ltbp ON ltbk~lgnum = ltbp~lgnum
                            AND ltbk~tbnum = ltbp~tbnum
        INTO CORRESPONDING FIELDS OF TABLE lt_ltbk
        WHERE ltbk~bwart = lv_bwart
          AND ltbp~qplos = fu_prueflos
          AND ltbp~elikz = space.

      SORT lt_ltbk BY mblnr DESCENDING.
      READ TABLE lt_ltbk INTO ls_ltbk INDEX 1.
      IF sy-subrc = 0.
        fc_mblnr       = ls_ltbk-mblnr.
        fc_mjahr       = ls_ltbk-mjahr.
        fc_tbnum       = ls_ltbk-tbnum.
        fs_trite-tbpos = ls_ltbk-tbpos.
      ENDIF.
    ENDIF.
  ENDIF.
  IF fc_tbnum IS INITIAL.
    fc_subrc = 4.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DYNPRO
*&---------------------------------------------------------------------*
FORM f_dynpro USING dynbegin name value.
  IF dynbegin =  'X'.
    CLEAR:  t_bdcdata.
    MOVE: name  TO t_bdcdata-program,
          value TO t_bdcdata-dynpro ,
          'X'   TO t_bdcdata-dynbegin.
    APPEND t_bdcdata.
  ELSE.
    CLEAR:  t_bdcdata.
    MOVE: name    TO t_bdcdata-fnam,
          value   TO t_bdcdata-fval.
    APPEND t_bdcdata.
  ENDIF.
ENDFORM.                               " F_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_TO
*&---------------------------------------------------------------------*
FORM f_create_to  USING "fs_qals   TYPE qals
                        fs_trite  TYPE l03b_trite
                        fu_lgnum fu_matnr fu_lznum fu_charg fu_anfme
                        fu_altme fu_tbnum fu_tbpos
                  CHANGING fc_tanum fc_subrc.

  DATA : it_trite TYPE l03b_trite_t,
         lt_ltak  TYPE STANDARD TABLE OF ltak_vb,
         ls_ltak  LIKE LINE OF lt_ltak.

  DATA : lv_anfme      TYPE mseg-menge,
         lv_anfme1(20),
         lv_nlqnr      TYPE ltap-nlqnr.

  IF fs_trite-tbpos IS INITIAL AND
    fu_tbpos IS NOT INITIAL.
    fs_trite-tbpos  = fu_tbpos.
  ENDIF.
  fs_trite-charg  = fu_charg.

  lv_anfme1 = fu_anfme.
  TRANSLATE lv_anfme1 USING '. '.
  TRANSLATE lv_anfme1 USING ',.'.
  CONDENSE lv_anfme1 NO-GAPS.
  fs_trite-anfme  = lv_anfme1.

  IF fu_altme IS INITIAL.
    SELECT SINGLE meins
      FROM mara
      INTO fs_trite-altme
      WHERE matnr = fu_matnr.
  ELSE.
    PERFORM f_conversion USING 'INPUT' '' fu_altme
                         CHANGING lv_anfme fs_trite-altme.
  ENDIF.

  APPEND fs_trite TO it_trite.

  CALL FUNCTION 'L_TO_CREATE_TR'
    EXPORTING
      i_lgnum                        = fu_lgnum
      i_tbnum                        = fu_tbnum
      it_trite                       = it_trite
    IMPORTING
      e_tanum                        = fc_tanum
    TABLES
      t_ltak                         = lt_ltak
    EXCEPTIONS
      foreign_lock                   = 1
      qm_relevant                    = 2
      tr_completed                   = 3
      xfeld_wrong                    = 4
      ldest_wrong                    = 5
      drukz_wrong                    = 6
      tr_wrong                       = 7
      squit_forbidden                = 8
      no_to_created                  = 9
      update_without_commit          = 10
      no_authority                   = 11
      preallocated_stock             = 12
      partial_transfer_req_forbidden = 13
      input_error                    = 14
      OTHERS                         = 15.

  fc_subrc = sy-subrc.

  COMMIT WORK AND WAIT.

  IF sy-subrc = 0.
    IF fc_tanum IS NOT INITIAL.
      SELECT SINGLE nlqnr
        FROM ltap
        INTO lv_nlqnr
        WHERE lgnum = fu_lgnum
          AND tanum = fc_tanum.
    ENDIF.

    LOOP AT lt_ltak INTO ls_ltak.
      TRY.
          UPDATE ltak SET lznum = fu_lznum
                      WHERE lgnum = ls_ltak-lgnum
                        AND tanum = ls_ltak-tanum.
        CATCH cx_sy_open_sql_db.
      ENDTRY.

      COMMIT WORK AND WAIT.

      TRY.
          UPDATE ltap SET zeugn = fu_lznum
                      WHERE lgnum = ls_ltak-lgnum
                        AND tanum = ls_ltak-tanum.
        CATCH cx_sy_open_sql_db.
      ENDTRY.

      COMMIT WORK AND WAIT.

      TRY.
          UPDATE lqua SET zeugn = fu_lznum
                      WHERE lgnum = ls_ltak-lgnum
                        AND lqnum = lv_nlqnr.
        CATCH cx_sy_open_sql_db.
      ENDTRY.

      COMMIT WORK AND WAIT.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_GOODS_MOVEMENT
*&---------------------------------------------------------------------*
FORM f_create_goods_movement  USING    "fs_qals   TYPE qals
                                       fu_werks fu_matnr fu_charg
                                       fu_lgnum fu_anfme fu_altme fu_prueflos
                                       fu_pallet
                              CHANGING fc_mblnr fc_mjahr fc_subrc.
  DATA : goodsmvt_header TYPE bapi2017_gm_head_01,
         goodsmvt_code   TYPE bapi2017_gm_code,
         goodsmvt_item   TYPE STANDARD TABLE OF bapi2017_gm_item_create,
         ls_item         LIKE LINE OF goodsmvt_item,
         return          TYPE STANDARD TABLE OF bapiret2,
         ls_return       LIKE LINE OF return.

  DATA : lv_anfme      TYPE mseg-menge,
         lv_anfme1(20).

  goodsmvt_code              = '04'.
  goodsmvt_header-doc_date   = sy-datum.
  goodsmvt_header-pstng_date = sy-datum.
  goodsmvt_header-pr_uname   = sy-uname.
  CONCATENATE fu_prueflos fu_pallet INTO goodsmvt_header-header_txt.

  ls_item-material           = fu_matnr.   "fs_qals-matnr.
  ls_item-plant              = fu_werks.   "fs_qals-werk.
  ls_item-stge_loc           = '2000'.   "fs_qals-lagortchrg.
  ls_item-move_stloc         = '3000'.
  ls_item-move_type          = '311'.

  lv_anfme1 = fu_anfme.
  TRANSLATE lv_anfme1 USING '. '.
  TRANSLATE lv_anfme1 USING ',.'.
  CONDENSE lv_anfme1 NO-GAPS.
  ls_item-entry_qnt          = lv_anfme1.

  PERFORM f_conversion USING 'INPUT' '' fu_altme
                       CHANGING lv_anfme ls_item-entry_uom.
  ls_item-batch              = fu_charg.    "fs_qals-charg.
  APPEND ls_item TO goodsmvt_item.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = goodsmvt_header
      goodsmvt_code    = goodsmvt_code
    IMPORTING
      materialdocument = fc_mblnr
      matdocumentyear  = fc_mjahr
    TABLES
      goodsmvt_item    = goodsmvt_item
      return           = return.

  IF fc_mblnr IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ELSE.
    PERFORM f_read_error_message TABLES return
                                 USING 'E' 'M3' '682' '4'
                                 CHANGING fc_subrc.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_TO
*&---------------------------------------------------------------------*
FORM f_get_data_to  USING    fu_lgnum
                    CHANGING fs_trite  TYPE l03b_trite
                             fs_to    TYPE zhgwmst002.

  DATA : ls_trite     TYPE l03b_trite.

  SELECT SINGLE matnr nlber nlpla nltyp vlpla vltyp
    FROM ltap
    INTO (fs_to-material_number, fs_trite-nlber, fs_to-destination_storage_bin,
          fs_to-destination_storage_type,
          fs_to-source_storage_bin, fs_to-source_storage_type)
    WHERE lgnum = fu_lgnum
      AND tanum = fs_to-to_number.

  SELECT SINGLE maktx
    FROM makt
    INTO fs_to-material_description
    WHERE matnr = fs_to-material_number
      AND spras = sy-langu.

  fs_trite-nlpla = fs_to-destination_storage_bin.
  fs_trite-nltyp = fs_to-destination_storage_type.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_TR
*&---------------------------------------------------------------------*
FORM f_get_tr  USING    fu_process fu_lgnum fu_mblnr fu_mjahr
               CHANGING fs_trite    TYPE l03b_trite
                        fc_tbnum fc_subrc.

  CASE fu_process.
    WHEN 'GET'.
      SELECT SINGLE ltbk~tbnum ltbp~tbpos
        FROM ltbk JOIN ltbp ON ltbk~lgnum = ltbp~lgnum
                            AND ltbk~tbnum = ltbp~tbnum
        INTO ( fc_tbnum, fs_trite-tbpos )
        WHERE ltbk~lgnum = fu_lgnum
          AND ltbk~mblnr = fu_mblnr
          AND ltbk~mjahr = fu_mjahr.
    WHEN 'POST'.
      SELECT SINGLE ltbk~tbnum ltbp~tbpos
        FROM ltbk JOIN ltbp ON ltbk~lgnum = ltbp~lgnum
                            AND ltbk~tbnum = ltbp~tbnum
        INTO ( fc_tbnum, fs_trite-tbpos )
        WHERE ltbk~lgnum = fu_lgnum
          AND ltbk~mblnr = fu_mblnr
          AND ltbk~mjahr = fu_mjahr
          AND ltbk~statu <> 'E'.
  ENDCASE.

  IF fc_tbnum IS INITIAL.
    fc_subrc = 4.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_GOODS_MOVEMENT
*&---------------------------------------------------------------------*
FORM f_cancel_goods_movement  USING    fu_mblnr fu_mjahr.
  DATA : return   TYPE STANDARD TABLE OF bapiret2.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      materialdocument    = fu_mblnr
      matdocumentyear     = fu_mjahr
      goodsmvt_pstng_date = sy-datum
      goodsmvt_pr_uname   = sy-uname
    TABLES
      return              = return.

  IF return[] IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_READ_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_read_error_message  TABLES   return STRUCTURE bapiret2
                           USING    fu_type fu_id fu_number fu_subrc
                           CHANGING fc_subrc.
  DATA : ls_return    TYPE bapiret2.

  READ TABLE return INTO ls_return
                    WITH KEY type   = fu_type
                             id     = fu_id
                             number = fu_number.
  IF sy-subrc = 0.
    fc_subrc = fu_subrc.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_TR
*&---------------------------------------------------------------------*
FORM f_check_tr  USING    fs_to   TYPE zhgwmst002
                          fu_lgnum fu_matnr
                 CHANGING fc_tbnum fc_tbpos fc_subrc fc_tanum fc_mblnr fc_mjahr.
  TYPES : BEGIN OF ty_tr,
            lgnum TYPE ltbk-lgnum,
            tbnum TYPE ltbk-tbnum,
            tbpos TYPE ltbp-tbpos,
            matnr TYPE ltbp-matnr,
            werks TYPE ltbp-werks,
            charg TYPE ltbp-charg,
            tanum TYPE ltbp-tanum,
            mblnr TYPE mkpf-mblnr,
            mjahr TYPE mkpf-mjahr,
            bktxt TYPE mkpf-bktxt,
          END OF ty_tr.

  DATA : lt_tr    TYPE STANDARD TABLE OF ty_tr,
         lt_xtr   TYPE STANDARD TABLE OF ty_tr,
         ls_tr    LIKE LINE OF lt_tr,
         ls_xtr   LIKE LINE OF lt_xtr,
         ls_xltap TYPE ltap.

  DATA : lv_bktxt   TYPE mkpf-bktxt.

  CONCATENATE fs_to-inspection_lot fs_to-pallet_number INTO lv_bktxt.
  SELECT *
    FROM ltbk JOIN ltbp ON ltbk~lgnum = ltbp~lgnum
                        AND ltbk~tbnum = ltbp~tbnum
              JOIN mkpf ON ltbk~mblnr = mkpf~mblnr
                        AND ltbk~mjahr = mkpf~mjahr
    INTO CORRESPONDING FIELDS OF TABLE lt_tr
    WHERE ltbk~lgnum = fu_lgnum
      AND ltbp~matnr = fu_matnr
      AND ltbp~charg = fs_to-batch
      AND mkpf~bktxt = lv_bktxt.

  IF lt_tr[] IS NOT INITIAL.
    lt_xtr[] = lt_tr[].
    DELETE lt_xtr WHERE tanum IS INITIAL.
    READ TABLE lt_xtr INTO ls_xtr INDEX 1.
    IF sy-subrc = 0.
      SELECT SINGLE *
        FROM ltap
        INTO CORRESPONDING FIELDS OF ls_xltap
        WHERE lgnum = fu_lgnum
          AND tanum = ls_xtr-tanum.
    ENDIF.

    DELETE lt_tr WHERE tanum IS NOT INITIAL.
    IF lt_tr[] IS NOT INITIAL.
      READ TABLE lt_tr INTO ls_tr INDEX 1.
      IF sy-subrc = 0.
        fc_tbnum = ls_tr-tbnum.
        fc_tbpos = ls_tr-tbpos.
      ENDIF.
      fc_subrc = 5.
    ELSE.
      READ TABLE lt_xtr INTO ls_xtr INDEX 1.
      IF sy-subrc = 0.
        fc_tbnum = ls_xtr-tbnum.
        fc_tbpos = ls_xtr-tbpos.
        fc_tanum = ls_xtr-tanum.
        fc_mblnr = ls_xtr-mblnr.
        fc_mjahr = ls_xtr-mjahr.
      ENDIF.
      IF ls_xltap-pvqui IS NOT INITIAL.
        fc_subrc = 6.
      ELSE.
        fc_subrc = 7.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
