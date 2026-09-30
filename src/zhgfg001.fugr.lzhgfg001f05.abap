*----------------------------------------------------------------------*
***INCLUDE LZHGFG001F05.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_PUTAWAY
*&---------------------------------------------------------------------*
FORM f_get_putaway  USING    fu_lgnum fu_prueflos fu_lznum fu_menge
                    CHANGING fc_putaway   TYPE zhgwmst001
                             fc_type fc_message.
  TYPES : BEGIN OF ty_to,
            lgnum TYPE ltak-lgnum,
            tanum TYPE ltak-tanum,
            matnr TYPE ltbp-matnr,
            werks TYPE ltbp-werks,
            charg TYPE ltbp-charg,
            lznum TYPE ltak-lznum,
            pquit TYPE ltap-pquit,
            meins TYPE ltap-meins,
            vsolm TYPE ltap-vsolm,
            nltyp TYPE ltap-nltyp,
            nlpla TYPE ltap-nlpla,
          END OF ty_to.

  DATA : ls_qals  TYPE qals,
         lt_mkpf  TYPE STANDARD TABLE OF mkpf,
         ls_ltap  TYPE ltap,
         ls_xltap TYPE ltap,
         ls_lagp  TYPE lagp,
         ls_to    TYPE ty_to.

  DATA : ls_mchb      TYPE mchb,
         ls_mkpf      TYPE mkpf,
         ls_lrf_wkqu  TYPE lrf_wkqu,
         ls_trite     TYPE l03b_trite,
         lt_ltap_conf TYPE STANDARD TABLE OF ltap_conf,
         ls_ltap_conf LIKE LINE OF lt_ltap_conf.

  DATA : lv_lhmg1        TYPE mlgn-lhmg1,
         lv_meins        TYPE mara-meins,
         lv_bktxt        TYPE mkpf-bktxt,
         lv_subrc        TYPE sy-subrc,
         lv_tbnum        TYPE ltbk-tbnum,
         lv_quantity(20),
         lv_menge        TYPE ltap-vsolm,
         lv_stock        TYPE mchb-clabs,
         lv_lines(3)     TYPE n,
         lv_tanum        TYPE ltak-tanum,
         lv_quknz        TYPE rl03t-quknz.

  fc_putaway-warehouse_number = fu_lgnum.
  fc_putaway-inspection_lot   = fu_prueflos.
  fc_putaway-pallet_number    = fu_lznum.

  SELECT SINGLE *
    FROM lrf_wkqu
    INTO CORRESPONDING FIELDS OF ls_lrf_wkqu
    WHERE lgnum = fu_lgnum
      AND bname = sy-uname.

  SELECT SINGLE *
    FROM ltap
    INTO CORRESPONDING FIELDS OF ls_ltap
    WHERE lgnum = fu_lgnum
      AND qplos = fu_prueflos.

  SELECT SINGLE werks
    FROM t320
    INTO fc_putaway-plant
    WHERE lgnum = fu_lgnum.

  SELECT SINGLE *
    FROM qals
    INTO CORRESPONDING FIELDS OF ls_qals
    WHERE prueflos = fu_prueflos.

  SELECT *
    FROM mkpf
    INTO CORRESPONDING FIELDS OF TABLE lt_mkpf
    WHERE xblnr = ls_qals-aufnr.

  CONCATENATE fu_prueflos fu_lznum INTO lv_bktxt.

  CASE ls_lrf_wkqu-mmenu.
    WHEN 'ZPMOVER'.
      DESCRIBE TABLE lt_mkpf LINES lv_lines.
      CONCATENATE fc_putaway-pallet_number '/' lv_lines
      INTO fc_putaway-pallet_number.

      SELECT SINGLE *
        FROM mkpf
        INTO CORRESPONDING FIELDS OF ls_mkpf
        WHERE bktxt = lv_bktxt.
      IF sy-subrc = 0.
        lv_subrc = 1.
      ELSE.
        SELECT SINGLE *
          FROM mchb
          INTO CORRESPONDING FIELDS OF ls_mchb
          WHERE matnr = ls_qals-matnr
            AND werks = fc_putaway-plant
            AND lgort = '2000'
            AND charg = ls_qals-charg.

        lv_quantity = fu_menge.
        TRANSLATE lv_quantity USING '. '.
        TRANSLATE lv_quantity USING ',.'.
        CONDENSE lv_quantity NO-GAPS.
        lv_menge = lv_quantity.
        lv_stock = ls_mchb-clabs + ls_mchb-ceinm.
        IF lv_stock = 0.
          lv_subrc = 5.
        ELSEIF lv_stock < lv_menge.
          lv_subrc = 4.
        ELSE.
          PERFORM f_get_destination USING fu_lgnum ls_qals-matnr
                                    CHANGING fc_putaway-destination_storage_type
                                             fc_putaway-destination_storage_bin.
        ENDIF.
      ENDIF.

    WHEN 'ZRCTRUCK'.
      fc_putaway-pallet_number = fu_lznum.

      SELECT SINGLE *
        FROM mkpf
        INTO CORRESPONDING FIELDS OF ls_mkpf
        WHERE bktxt = lv_bktxt.
      IF sy-subrc <> 0.
        lv_subrc = 7.
      ELSE.
        PERFORM f_get_tr USING 'GET' fu_lgnum ls_mkpf-mblnr ls_mkpf-mjahr
                         CHANGING ls_trite lv_tbnum lv_subrc.
        IF lv_subrc = 4.
          CLEAR lv_subrc.
        ELSE.
          SELECT SINGLE *
            FROM ltak JOIN ltap ON ltak~lgnum = ltap~lgnum
                                AND ltak~tanum = ltap~tanum
            INTO CORRESPONDING FIELDS OF ls_to
            WHERE ltak~lgnum = fu_lgnum
              AND ltap~matnr = ls_qals-matnr
              AND ltap~werks = fc_putaway-plant
              AND ltap~charg = ls_qals-charg
              AND ltak~lznum = fu_lznum.
          IF sy-subrc = 0.
            IF ls_to-pquit = 'X'.
              lv_subrc = 6.
            ELSE.
              SELECT SINGLE *
                FROM lagp
                INTO CORRESPONDING FIELDS OF ls_lagp
                WHERE lgnum = fu_lgnum
                  AND lgtyp = ls_ltap-nltyp
                  AND lgpla = ls_ltap-nlpla.
              IF ls_lagp-skzue = 'X'.
                lv_subrc = 3.
              ELSE.
                MOVE-CORRESPONDING ls_to TO ls_ltap.
                lv_menge      = ls_to-vsolm.
                lv_meins      = ls_to-meins.
              ENDIF.
            ENDIF.
          ELSE.
            lv_subrc = 2.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.

  IF lv_subrc = 0 OR
    lv_subrc = 2.
    SELECT SINGLE umrez INTO @DATA(lv_umrez)
      FROM marm WHERE matnr = @ls_qals-matnr
                  AND meinh = 'KAR'.

    fc_putaway-material_number           = ls_qals-matnr.
    fc_putaway-material_description      = ls_qals-ktextmat.
    fc_putaway-batch                     = ls_qals-charg.
    IF lv_meins IS INITIAL.
      lv_meins = ls_qals-mengeneinh.
    ENDIF.

*    fc_putaway-destination_storage_type  = ls_ltap-nltyp.
*    fc_putaway-destination_storage_bin   = ls_ltap-nlpla.

    WRITE lv_umrez TO fc_putaway-umrez.
    CONDENSE fc_putaway-umrez.

    PERFORM f_conversion USING 'OUTPUT' lv_menge lv_meins
                         CHANGING fc_putaway-quantity fc_putaway-uom.

    fc_putaway-quantity = fu_menge.

    SELECT SINGLE lhmg1
      FROM mlgn
      INTO lv_lhmg1
      WHERE matnr = ls_qals-matnr
        AND lgnum = fu_lgnum.

    PERFORM f_conversion USING 'OUTPUT' lv_lhmg1 ls_qals-mengeneinh
                         CHANGING fc_putaway-le_quantity lv_meins.

*    IF ls_ltap IS NOT INITIAL.
*      IF ls_ltap-pquit = 'X'.
*        lv_subrc = 2.
*      ELSE.
*        SELECT SINGLE *
*          FROM lagp
*          INTO CORRESPONDING FIELDS OF ls_lagp
*          WHERE lgnum = fu_lgnum
*            AND lgtyp = ls_ltap-nltyp
*            AND lgpla = ls_ltap-nlpla.
*        IF ls_lagp-skzue = 'X'.
*          lv_subrc = 3.
*        ENDIF.
*      ENDIF.
*    ENDIF.
  ENDIF.

  IF ls_lrf_wkqu-mmenu = 'ZRCTRUCK'.
    IF lv_subrc = 0.
*      PERFORM f_get_tr USING 'GET' fu_lgnum ls_mkpf-mblnr ls_mkpf-mjahr
*                       CHANGING ls_trite lv_tbnum lv_subrc.
*      IF lv_subrc = 4.
*        CLEAR lv_subrc.
*      ELSE.
      SELECT SINGLE *
        FROM ltak JOIN ltap ON ltak~lgnum = ltap~lgnum
                            AND ltak~tanum = ltap~tanum
        INTO CORRESPONDING FIELDS OF ls_xltap
        WHERE ltak~lgnum = fu_lgnum
          AND ltak~tbnum = lv_tbnum
          AND ltap~pvqui = space.
      IF sy-subrc = 0.
        fc_putaway-destination_storage_type = ls_xltap-nltyp.
        fc_putaway-destination_storage_bin  = ls_xltap-nlpla.
        MOVE-CORRESPONDING ls_xltap TO ls_ltap_conf.
        ls_ltap_conf-squit  = 'X'.
        APPEND ls_ltap_conf TO lt_ltap_conf.
        lv_quknz = '1'.
        PERFORM f_confirm_to TABLES lt_ltap_conf
                             USING fu_lgnum ls_ltap_conf-tanum
                                   '' lv_quknz
                             CHANGING lv_subrc.
        IF lv_subrc <> 0.
          lv_subrc = 99.
          fc_putaway-type = 'E'.
          CALL FUNCTION 'ZWMSFM002'
            EXPORTING
              pi_subrc    = lv_subrc
              pi_function = 'L_TO_CREATE_TR'
            IMPORTING
              pe_message  = fc_putaway-message.
        ELSE.
          TRY .
              UPDATE ltap SET edatu = sy-datum
                              ezeit = sy-uzeit
                              ename = sy-uname
                          WHERE lgnum = fu_lgnum
                            AND tanum = ls_ltap_conf-tanum.
            CATCH cx_sy_open_sql_db.
          ENDTRY.
          COMMIT WORK AND WAIT.
        ENDIF.
      ELSE.
        CLEAR lv_subrc.
        fc_putaway-destination_storage_type = ls_ltap-nltyp.
        fc_putaway-destination_storage_bin  = ls_ltap-nlpla.
      ENDIF.
    ENDIF.

    IF lv_subrc = 2.
      CLEAR lv_subrc.
      PERFORM f_create_to USING ls_trite
                                fu_lgnum ls_mkpf-mblnr
                                fc_putaway-pallet_number
                                ls_qals-charg fc_putaway-quantity
                                fc_putaway-uom lv_tbnum ls_trite-tbpos
                          CHANGING lv_tanum lv_subrc.
      IF lv_tanum IS NOT INITIAL.
        SELECT SINGLE *
          FROM ltak JOIN ltap ON ltak~lgnum = ltap~lgnum
                              AND ltak~tanum = ltap~tanum
          INTO CORRESPONDING FIELDS OF ls_xltap
          WHERE ltak~lgnum = fu_lgnum
            AND ltak~tanum = lv_tanum.
        IF sy-subrc = 0.
          fc_putaway-destination_storage_type = ls_xltap-nltyp.
          fc_putaway-destination_storage_bin  = ls_xltap-nlpla.
          MOVE-CORRESPONDING ls_xltap TO ls_ltap_conf.
          ls_ltap_conf-squit  = 'X'.
          APPEND ls_ltap_conf TO lt_ltap_conf.
          lv_quknz = '1'.
          PERFORM f_confirm_to TABLES lt_ltap_conf
                               USING fu_lgnum ls_ltap_conf-tanum
                                     '' lv_quknz
                               CHANGING lv_subrc.
          IF lv_subrc <> 0.
            lv_subrc = 99.
            fc_putaway-type = 'E'.
            CALL FUNCTION 'ZWMSFM002'
              EXPORTING
                pi_subrc    = lv_subrc
                pi_function = 'L_TO_CONFIRM'
              IMPORTING
                pe_message  = fc_putaway-message.
          ELSE.
            TRY .
                UPDATE ltap SET edatu = sy-datum
                                ezeit = sy-uzeit
                                ename = sy-uname
                            WHERE lgnum = fu_lgnum
                              AND tanum = lv_tanum.
              CATCH cx_sy_open_sql_db.
            ENDTRY.
            COMMIT WORK AND WAIT.
          ENDIF.
        ENDIF.
      ELSE.
        lv_subrc = 99.
        fc_putaway-type = 'E'.
        CALL FUNCTION 'ZWMSFM002'
          EXPORTING
            pi_subrc    = lv_subrc
            pi_function = 'L_TO_CREATE_TR'
          IMPORTING
            pe_message  = fc_putaway-message.
      ENDIF.
*    ENDIF.
*      ENDIF.
    ENDIF.
  ENDIF.

  CASE lv_subrc.
    WHEN 0.
      fc_putaway-type     = 'S'.
      fc_putaway-message  = 'GET Data'.
    WHEN 1.
      fc_putaway-type     = 'E'.
      fc_putaway-message  = 'Pallet sudah pernah discan'.
    WHEN 2.
      fc_putaway-type     = 'E'.
      fc_putaway-message  = 'TO already confirm'.
    WHEN 3.
      fc_putaway-type     = 'E'.
      fc_putaway-message  = 'Storage bin blocked'.
    WHEN 4.
      fc_putaway-type     = 'E'.
      fc_putaway-message  = 'Stock belum release'.
    WHEN 5.
      fc_putaway-type     = 'E'.
      fc_putaway-message  = 'Pallet sudah di scan'.
    WHEN 6.
      fc_putaway-type     = 'E'.
      CONCATENATE 'TO sudah diconfirm di' ls_to-nlpla
      INTO fc_putaway-message  "  = 'TO sudah diconfirm'.
      SEPARATED BY space.
    WHEN 7.
      fc_putaway-type     = 'E'.
      fc_putaway-message  = 'Belum scan Pallet Mover'.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_DESTINATION
*&---------------------------------------------------------------------*
FORM f_get_destination  USING    fu_lgnum fu_matnr
                        CHANGING fc_nltyp fc_nlpla.

  TYPES : BEGIN OF ty_bin,
            lgpla TYPE string,
          END OF ty_bin.

  DATA : ls_mlgn  TYPE mlgn,
         ls_t334t TYPE t334t,
         lr_lgtyp TYPE RANGE OF lgtyp,
         ls_lgtyp LIKE LINE OF lr_lgtyp,
         lt_t334b TYPE STANDARD TABLE OF t334b,
         ls_t334b LIKE LINE OF lt_t334b,
         lr_lgber TYPE RANGE OF lgber,
         ls_lgber LIKE LINE OF lr_lgber,
         lt_bin   TYPE STANDARD TABLE OF ty_bin,
         ls_bin   LIKE LINE OF lt_bin,
         lt_lagp  TYPE STANDARD TABLE OF lagp,
         ls_lagp  LIKE LINE OF lt_lagp.

  DATA : lv_lgbkz         TYPE mlgn-lgbkz,
         lv_ltkze         TYPE mlgn-ltkze,
         lv_fieldname(30),
         lv_count(2),
         lv_lgpla         TYPE lagp-lgpla.

  FIELD-SYMBOLS <fs>  TYPE any.

  SELECT SINGLE lgbkz ltkze
    FROM mlgn
    INTO ( lv_lgbkz, lv_ltkze )
    WHERE matnr = fu_matnr
      AND lgnum = fu_lgnum.

  SELECT SINGLE *
    FROM t334t
    INTO CORRESPONDING FIELDS OF ls_t334t
    WHERE lgnum = fu_lgnum
      AND kzear = 'E'
      AND lgtkz = lv_ltkze
      AND bestq = space.

  lv_count = '0'.
  DO 30 TIMES.
    IF lv_count < 10.
      CONCATENATE 'LS_T334T-LGTY' lv_count INTO lv_fieldname.
    ELSE.
      CONCATENATE 'LS_T334T-LGT' lv_count INTO lv_fieldname.
    ENDIF.
    ASSIGN (lv_fieldname) TO <fs>.
    IF <fs> IS INITIAL.
      EXIT.
    ENDIF.
    ls_lgtyp-low    = <fs>.
    ls_lgtyp-sign   = 'I'.
    ls_lgtyp-option = 'EQ'.
    APPEND ls_lgtyp TO lr_lgtyp.
    CLEAR ls_lgtyp.
    ADD 1 TO lv_count.
  ENDDO.

  SELECT *
    FROM t334b
    INTO CORRESPONDING FIELDS OF TABLE lt_t334b
    WHERE lgnum = fu_lgnum
      AND lgtyp IN lr_lgtyp
      AND lgbkz = lv_lgbkz.

  CLEAR lv_fieldname.
  LOOP AT lt_t334b INTO ls_t334b.
    lv_count = '0'.
    DO 30 TIMES.
      IF lv_count < 10.
        CONCATENATE 'LS_T334B-LGBE' lv_count INTO lv_fieldname.
      ELSE.
        CONCATENATE 'LS_T334B-LGB' lv_count INTO lv_fieldname.
      ENDIF.
      ASSIGN (lv_fieldname) TO <fs>.
      IF <fs> IS INITIAL.
        EXIT.
      ENDIF.
      ls_lgber-low    = <fs>.
      ls_lgber-sign   = 'I'.
      ls_lgber-option = 'EQ'.
      APPEND ls_lgber TO lr_lgber.
      CLEAR ls_lgber.
      ADD 1 TO lv_count.
    ENDDO.
  ENDLOOP.

  SELECT *
    FROM lagp
    INTO CORRESPONDING FIELDS OF TABLE lt_lagp
    WHERE lgnum = fu_lgnum
      AND lgtyp IN lr_lgtyp
      AND lgber IN lr_lgber.

  SORT lt_lagp BY lgpla.
  LOOP AT lt_lagp INTO ls_lagp.
    SPLIT ls_lagp-lgpla AT '-' INTO ls_bin-lgpla lv_lgpla.
    COLLECT ls_bin INTO lt_bin.
    CLEAR ls_bin.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM lt_bin COMPARING lgpla.
  CLEAR lv_count.
  LOOP AT lt_bin INTO ls_bin.
    IF lv_count = 0.
      lv_count = 1.
      fc_nlpla = ls_bin-lgpla.
    ELSE.
      CONCATENATE fc_nlpla ',' ls_bin-lgpla INTO fc_nlpla.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_DETAILDM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PI_LGNUM  text
*      -->P_PI_CHARG  text
*      -->P_PI_MATNR  text
*      -->P_PI_MENGE  text
*      <--P_PE_TYPE  text
*      <--P_PE_MESSAGE  text  f_get_dn
*----------------------------------------------------------------------*
FORM f_get_detaildn  TABLES   pt_listdn   STRUCTURE zhgwmst017
                     USING    p_lgnum
                              p_charg
                              p_matnr
                              p_lznum
                              p_vltyp
                              p_vlpla
                     CHANGING p_type
                              p_message.
  DATA: lv_lznum TYPE ltak-lznum.
  DATA: BEGIN OF lt_listdn OCCURS 0,
          vbeln TYPE lips-vbeln,
          kunnr TYPE likp-kunnr,
          name1 TYPE kna1-name1,
          meins TYPE ltap-meins,
          vsolm TYPE ltap-vsolm,
        END OF lt_listdn.
  DATA: lv_len TYPE i.
  DATA: lv_tanum TYPE ltak-tanum.
  DATA: lt_marm TYPE STANDARD TABLE OF marm.
  DATA: ls_marm LIKE LINE OF lt_marm.
  RANGES: lr_vltyp FOR ltap-vltyp, lr_vlpla FOR ltap-vlpla.
  CLEAR: lr_vltyp[], lr_vlpla[], lr_vltyp, lr_vlpla.
  IF p_vltyp IS NOT INITIAL.
    lr_vltyp-sign = 'I'.
    lr_vltyp-option = 'EQ'.
    lr_vltyp-low = p_vltyp.
    APPEND lr_vltyp.
  ENDIF.
  IF p_vlpla IS NOT INITIAL.
    lr_vlpla-sign = 'I'.
    lr_vlpla-option = 'EQ'.
    lr_vlpla-low = p_vlpla.
    APPEND lr_vlpla.
  ENDIF.

  lv_lznum = p_lznum.
  CONDENSE lv_lznum.
  lv_len = strlen( lv_lznum ).
  IF lv_len = 10.
    lv_tanum = lv_lznum.
    "    SELECT * INTO CORRESPONDING FIELDS OF TABLE @lt_listdn
    SELECT c~vbeln b~kunnr name1  meins SUM( vsolm ) INTO  TABLE lt_listdn
      FROM ltak AS a JOIN likp AS b ON a~vbeln = b~vbeln
          JOIN ltap AS c ON c~tanum = a~tanum
                        AND c~lgnum = a~lgnum
          JOIN kna1 AS d ON b~kunnr = d~kunnr
      WHERE a~tanum = lv_tanum
        AND a~lgnum = p_lgnum
        AND matnr = p_matnr
        AND charg = p_charg
        AND vltyp IN lr_vltyp
        AND vlpla IN lr_vlpla GROUP BY c~vbeln b~kunnr name1 meins.
  ELSE.
    SELECT c~vbeln b~kunnr name1  meins SUM( vsolm ) INTO  TABLE lt_listdn
      FROM ltak AS a JOIN likp AS b ON a~vbeln = b~vbeln
          JOIN ltap AS c ON c~tanum = a~tanum
                        AND c~lgnum = a~lgnum
          JOIN kna1 AS d ON b~kunnr = d~kunnr
      WHERE a~lznum = lv_lznum
        AND a~lgnum = p_lgnum
        AND matnr = p_matnr
        AND charg = p_charg
        AND vltyp IN lr_vltyp
        AND vlpla IN lr_vlpla GROUP BY c~vbeln b~kunnr name1 meins.
  ENDIF.
  DELETE ADJACENT DUPLICATES FROM lt_listdn COMPARING ALL FIELDS.
  IF lt_listdn[] IS INITIAL.
    pt_listdn-type = 'E'.
    pt_listdn-message = 'Tidak ada data'.
    APPEND pt_listdn.
  ELSE.
    SELECT SINGLE * INTO ls_marm FROM marm
      WHERE matnr = p_matnr
        AND meinh = 'KAR'.
    SORT lt_marm BY matnr meinh.
    "    DELETE ADJACENT DUPLICATES FROM lt_marm COMPARING matnr meinh.
    DELETE lt_listdn[] WHERE vsolm = 0.
    LOOP AT lt_listdn.
      pt_listdn-delivery_number = lt_listdn-vbeln.
      pt_listdn-customer_number = lt_listdn-kunnr.
      pt_listdn-customer_name = lt_listdn-name1.
      PERFORM f_conversion USING 'OUTPUT' lt_listdn-vsolm lt_listdn-meins
                          CHANGING pt_listdn-quantity_satuan pt_listdn-uom_satuan.
      CONDENSE: pt_listdn-uom_satuan, pt_listdn-quantity_satuan.
      IF ls_marm-matnr IS NOT INITIAL.
        pt_listdn-uom_packing = 'CAR'.
        WRITE ls_marm-umrez TO pt_listdn-conversi_carton DECIMALS 0 NO-GROUPING NO-GAP.
        CONDENSE pt_listdn-conversi_carton.
      ENDIF.
      pt_listdn-type = 'S'.
      pt_listdn-message = 'Get Data'.
      APPEND pt_listdn.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_DETAILDM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PI_LGNUM  text
*      -->P_PI_CHARG  text
*      -->P_PI_MATNR  text
*      -->P_PI_MENGE  text
*      <--P_PE_TYPE  text
*      <--P_PE_MESSAGE  text  f_get_dn
*----------------------------------------------------------------------*
FORM f_get_dn  TABLES   pt_listitem   STRUCTURE zhgwmst018
                     USING    p_lgnum
                              p_tanum
                     CHANGING p_type
                              p_message.
  DATA: lv_vbeln TYPE ltak-vbeln.
  DATA: BEGIN OF lt_listitem OCCURS 0,
          matnr TYPE ltap-matnr,
          maktx TYPE ltap-maktx,
          charg TYPE ltap-charg,
          meins TYPE ltap-meins,
          nista TYPE ltap-nista,
        END OF lt_listitem.
  DATA: lt_marm TYPE STANDARD TABLE OF marm.
  DATA: ls_marm LIKE LINE OF lt_marm.
  lv_vbeln = p_tanum.
  CONDENSE lv_vbeln.
  SELECT matnr maktx charg  meins SUM( nista ) INTO  TABLE lt_listitem
    FROM ltak AS a JOIN ltap AS b ON b~tanum = a~tanum
                      AND b~lgnum = a~lgnum
    WHERE b~vbeln = lv_vbeln
      AND a~lgnum = p_lgnum
      GROUP BY matnr maktx charg meins.

  DELETE ADJACENT DUPLICATES FROM lt_listitem COMPARING ALL FIELDS.
  IF lt_listitem[] IS INITIAL.
    pt_listitem-type = 'E'.
    pt_listitem-message = 'Tidak ada data'.
    APPEND pt_listitem.
  ELSE.
    SELECT * INTO TABLE lt_marm FROM marm FOR ALL ENTRIES IN lt_listitem
      WHERE matnr = lt_listitem-matnr
        AND meinh = 'KAR'.
    SORT lt_marm BY matnr meinh.
    DELETE ADJACENT DUPLICATES FROM lt_marm COMPARING matnr meinh.
    DELETE lt_listitem[] WHERE nista = 0.
    LOOP AT lt_listitem.
      pt_listitem-material_number = lt_listitem-matnr.
      pt_listitem-material_description = lt_listitem-maktx.
      pt_listitem-batch = lt_listitem-charg.
      PERFORM f_conversion USING 'OUTPUT' lt_listitem-nista lt_listitem-meins
                          CHANGING pt_listitem-quantity_satuan pt_listitem-uom_satuan.
      CONDENSE: pt_listitem-uom_satuan, pt_listitem-quantity_satuan.
      SORT lt_marm BY matnr meinh.
      READ TABLE lt_marm INTO ls_marm WITH KEY matnr = lt_listitem-matnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        pt_listitem-uom_packing = 'CAR'.
        WRITE ls_marm-umrez TO pt_listitem-conversi_carton DECIMALS 0 NO-GROUPING NO-GAP.
        CONDENSE pt_listitem-conversi_carton.
      ENDIF.
      pt_listitem-type = 'S'.
      pt_listitem-message = 'Get Data'.
      APPEND pt_listitem.
    ENDLOOP.
  ENDIF.
ENDFORM.
