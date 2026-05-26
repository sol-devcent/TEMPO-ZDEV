*----------------------------------------------------------------------*
*   INCLUDE ZTNPQM_F001F01
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_process_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_report.
  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  PERFORM f_process_data.
  IF gv_error IS INITIAL.
    IF p_tdform = 'ZTNPQM_SF002'.
      PERFORM f_print_data.
    ELSE.
      IF gv_flag IS INITIAL.
        IF gv_8 IS INITIAL.
          PERFORM f_print_data.
        ELSE.
          PERFORM f_split_8.
          PERFORM f_print_data_8.
        ENDIF.
      ELSE.
        PERFORM f_print_qr_form.
      ENDIF.
    ENDIF.
  ELSE.
    CASE gv_error.
      WHEN 2.
        MESSAGE s000(zab) WITH 'Material document was canceled'
        DISPLAY LIKE 'E'.
      WHEN OTHERS.
        MESSAGE s000(zab) WITH 'Pallet convert not found, maintain in ZWME001/MM02'
        DISPLAY LIKE 'E'.
    ENDCASE.
  ENDIF.
*  PERFORM f_print_form.
  PERFORM f_free_memory.
ENDFORM.                    " f_process_report
*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data.
  CLEAR : t_qclabel[], t_out[], gs_001.

  SELECT SINGLE *
    FROM ztnpqmdt001
    INTO gs_001
    WHERE sysid   = sy-sysid
      AND bname   = sy-uname.

  IF sy-subrc = 0.
    gv_host  = gs_001-rfchost.
  ENDIF.

  SELECT SINGLE flag
    FROM zproject
    INTO gv_flag
    WHERE name = 'ZTNPQM_F001'.
ENDFORM.                    " f_init_data
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA: BEGIN OF lt_qclabel OCCURS 0.
          INCLUDE STRUCTURE ztnpqmst001.
        DATA: END OF lt_qclabel.
  DATA : ls_qals LIKE LINE OF gt_qals,
         ls_ekko LIKE LINE OF gt_ekko,
         lt_mlgn TYPE STANDARD TABLE OF mlgn,
         ls_mlgn LIKE LINE OF lt_mlgn.

  SELECT mkpf~mblnr mkpf~mjahr mkpf~bldat mkpf~budat
         mseg~zeile mseg~werks mseg~charg mseg~matnr
         mseg~ebeln mseg~menge mseg~meins mseg~lifnr
         mseg~aufnr mseg~lgnum mseg~lgort mseg~tbnum
    FROM mkpf JOIN mseg ON  mkpf~mblnr = mseg~mblnr
                        AND mkpf~mjahr = mseg~mjahr
    INTO CORRESPONDING FIELDS OF TABLE t_qclabel
    WHERE mkpf~mblnr = pa_mblnr
      AND mkpf~mjahr = pa_mjahr
    ORDER BY mkpf~mblnr mkpf~mjahr mseg~zeile.

  lt_qclabel[]  = t_qclabel[].
  SORT lt_qclabel BY matnr lgnum.
  DELETE ADJACENT DUPLICATES FROM lt_qclabel COMPARING matnr lgnum.
  IF lt_qclabel[] IS NOT INITIAL.
    SELECT *
      FROM mlgn
      INTO CORRESPONDING FIELDS OF TABLE lt_mlgn
      FOR ALL ENTRIES IN lt_qclabel
      WHERE matnr = lt_qclabel-matnr
        AND lgnum = lt_qclabel-lgnum
      ORDER BY PRIMARY KEY.
  ENDIF.

  IF t_qclabel[] IS NOT INITIAL.
    SELECT *
      FROM ekko
      INTO CORRESPONDING FIELDS OF TABLE gt_ekko
      FOR ALL ENTRIES IN t_qclabel
      WHERE ebeln = t_qclabel-ebeln
        AND bsart = 'ZUB'
      ORDER BY PRIMARY KEY.

    SELECT werk prueflos matnr charg ktextmat mblnr
           mjahr zeile losmenge stat35 mengeneinh ktextlos
           lmenge01 lmenge04 gebeh anzgeb
      FROM qals
      INTO CORRESPONDING FIELDS OF TABLE gt_qals
      FOR ALL ENTRIES IN t_qclabel
      WHERE mblnr = t_qclabel-mblnr
        AND zeile = t_qclabel-zeile
        AND mjahr = t_qclabel-mjahr
      ORDER BY PRIMARY KEY.

    LOOP AT t_qclabel.
      READ TABLE lt_mlgn INTO ls_mlgn
                         WITH KEY matnr = t_qclabel-matnr
                                  lgnum = t_qclabel-lgnum.
      IF sy-subrc = 0.
        t_qclabel-ltkze = ls_mlgn-ltkze.
      ENDIF.

      READ TABLE gt_qals INTO ls_qals
                         WITH KEY mblnr = t_qclabel-mblnr
                                  zeile = t_qclabel-zeile
                                  mjahr = t_qclabel-mjahr.
      IF sy-subrc = 0.
        t_qclabel-gebeh   = ls_qals-gebeh.
        t_qclabel-anzgeb  = ls_qals-anzgeb.
      ENDIF.

      IF t_qclabel-lifnr IS INITIAL.
        CLEAR ls_ekko.
        READ TABLE gt_ekko INTO ls_ekko
                           WITH KEY ebeln = t_qclabel-ebeln.
        IF sy-subrc = 0.
          SELECT SINGLE lifnr
            FROM t001w
            INTO t_qclabel-lifnr
            WHERE werks = ls_ekko-reswk.
        ENDIF.
      ENDIF.
      MODIFY t_qclabel TRANSPORTING gebeh anzgeb lifnr ltkze.
    ENDLOOP.
  ENDIF.

  lt_qclabel[]  = t_qclabel[].
  SORT lt_qclabel BY werks.
  DELETE ADJACENT DUPLICATES FROM lt_qclabel COMPARING werks.
  IF lt_qclabel[] IS NOT INITIAL.
    SELECT werks name1
      FROM t001w
      INTO TABLE t_t001w
      FOR ALL ENTRIES IN lt_qclabel
      WHERE werks = lt_qclabel-werks
      ORDER BY PRIMARY KEY.
  ENDIF.

  lt_qclabel[]  = t_qclabel[].
  SORT lt_qclabel BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_qclabel COMPARING matnr.
  IF lt_qclabel[] IS NOT INITIAL.
    SELECT mara~matnr mara~mtart makt~maktx mara~tempb
      FROM mara JOIN makt ON mara~matnr = makt~matnr
      INTO TABLE t_mara
      FOR ALL ENTRIES IN lt_qclabel
      WHERE mara~matnr = lt_qclabel-matnr
        AND makt~spras = sy-langu.
    SORT t_mara BY matnr.

    SELECT *
      FROM marm
      INTO CORRESPONDING FIELDS OF TABLE t_marm
      FOR ALL ENTRIES IN lt_qclabel
      WHERE matnr = lt_qclabel-matnr
      ORDER BY PRIMARY KEY.
  ENDIF.

  lt_qclabel[]  = t_qclabel[].
  SORT lt_qclabel BY matnr charg.
  DELETE ADJACENT DUPLICATES FROM lt_qclabel COMPARING matnr charg.
  IF lt_qclabel[] IS NOT INITIAL.
    SELECT *
      FROM mch1
      INTO CORRESPONDING FIELDS OF TABLE t_mch1
      FOR ALL ENTRIES IN lt_qclabel
      WHERE matnr = lt_qclabel-matnr
        AND charg = lt_qclabel-charg
        AND lvorm = space
      ORDER BY PRIMARY KEY.
  ENDIF.

  lt_qclabel[]  = t_qclabel[].
  SORT lt_qclabel BY matnr lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_qclabel COMPARING matnr lifnr.
  IF lt_qclabel[] IS NOT INITIAL.
    SELECT *
      FROM zwmpalvnd
      INTO CORRESPONDING FIELDS OF TABLE gt_zwmpalvnd
      FOR ALL ENTRIES IN lt_qclabel
      WHERE matnr = lt_qclabel-matnr
        AND lifnr = lt_qclabel-lifnr
      ORDER BY PRIMARY KEY.
  ENDIF.

  lt_qclabel[]  = t_qclabel[].
  SORT lt_qclabel BY lgnum tbnum.
  DELETE ADJACENT DUPLICATES FROM lt_qclabel COMPARING lgnum tbnum.
  IF lt_qclabel[] IS NOT INITIAL.
    SELECT lgnum tanum bwart
      INTO CORRESPONDING FIELDS OF TABLE gt_ltak
      FROM ltak FOR ALL ENTRIES IN lt_qclabel
      WHERE lgnum = lt_qclabel-lgnum
        AND tbnum = lt_qclabel-tbnum
      ORDER BY PRIMARY KEY.
    IF sy-subrc = 0.
      SELECT lgnum tanum tapos wenum matnr werks charg vsolm vistm
             meins nlpla
        INTO CORRESPONDING FIELDS OF TABLE gt_ltap
        FROM ltap FOR ALL ENTRIES IN gt_ltak
        WHERE lgnum = gt_ltak-lgnum
          AND tanum = gt_ltak-tanum
          AND vorga NE 'ST'
        ORDER BY PRIMARY KEY.
    ENDIF.
  ENDIF.

  lt_qclabel[]  = t_qclabel[].
  SORT lt_qclabel BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM lt_qclabel COMPARING matnr werks.
  IF lt_qclabel[] IS NOT INITIAL.
    SELECT * INTO TABLE gt_ztnpqmdt002
      FROM ztnpqmdt002 FOR ALL ENTRIES IN lt_qclabel
      WHERE matnr = lt_qclabel-matnr
        AND werks = lt_qclabel-werks
      ORDER BY PRIMARY KEY.
  ENDIF.

  PERFORM f_pallet_count.

ENDFORM.                    " f_get_data
*&---------------------------------------------------------------------*
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.

ENDFORM.                    " f_validate_data
*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
FORM f_process_data.
  TYPES : BEGIN OF ty_matnr,
            matnr   TYPE mara-matnr,
            charg   TYPE mch1-charg,
            sisa    TYPE mseg-menge,
            menge   TYPE mseg-menge,
            times   TYPE int4,
            label   TYPE int4,
            anzgeb  TYPE qals-anzgeb,
            gebeh   TYPE qals-gebeh,
            kemasan TYPE mseg-menge,
            atwrt   TYPE ausp-atwrt,
          END OF ty_matnr.

  DATA : ymcha     LIKE mcha,
         classname LIKE klah-class,
         cob       TYPE STANDARD TABLE OF clbatch INITIAL SIZE 0,
         ls_cob    LIKE LINE OF cob.

  DATA : lv_times   TYPE int4,
         lv_count   TYPE int4,
         lv_count2  TYPE int4,
         lv_x       TYPE int4,
         lv_tt(10),
         lv_ct(10),
         ls_qals    LIKE LINE OF gt_qals,
         ls_marm    LIKE LINE OF t_marm,
         ls_mch1    LIKE LINE OF t_mch1,
         lv_sisa    TYPE mseg-menge,
         lv_menge   TYPE mseg-menge,
         lv_carton  TYPE mseg-menge,
         ls_qclabel LIKE LINE OF t_qclabel,
         ls_out     LIKE LINE OF t_out,
         lv_meins   TYPE mara-meins.

  DATA : lt_matnr  TYPE STANDARD TABLE OF ty_matnr INITIAL SIZE 0,
         lt_hazcom TYPE TABLE OF ztspmdhazcom WITH HEADER LINE,
         ls_matnr  LIKE LINE OF lt_matnr,
         ls_matnr2 LIKE LINE OF lt_matnr.

  DATA : ls_ausp      TYPE ausp,
         lv_objek(50),
         lv_atinn     TYPE ausp-atinn,
         h(10), f(10), r(10),
         lv_hazcom    TYPE char30,
         lv_flstr(22),
         lv_pack1(20),
         lv_pack2(20).

  LOOP AT t_qclabel.
    READ TABLE t_mara WITH KEY matnr  = t_qclabel-matnr.

    CASE t_mara-mtart.
      WHEN 'ZRM' OR 'ZPM'.
        PERFORM f_calculate_quantity USING 'PAL' t_qclabel-menge
                                           t_qclabel-matnr t_qclabel-lifnr
                                           t_qclabel-lgnum t_qclabel-lgort
                                           'ZPALVND' t_qclabel-werks
                                           t_qclabel-charg
                                     CHANGING ls_matnr-sisa ls_matnr-times
                                              ls_matnr-menge.
      WHEN OTHERS.
        p_tdform    = c_smartform_name2.
        PERFORM f_calculate_quantity USING 'PAL' t_qclabel-menge
                                           t_qclabel-matnr t_qclabel-lifnr
                                           t_qclabel-lgnum t_qclabel-lgort
                                           'ZPALVND' t_qclabel-werks
                                           t_qclabel-charg
                                     CHANGING ls_matnr-sisa ls_matnr-times
                                              ls_matnr-menge.
    ENDCASE.
    ls_matnr-matnr  = t_qclabel-matnr.
    ls_matnr-anzgeb = t_qclabel-anzgeb.
    ls_matnr-gebeh  = t_qclabel-gebeh.

    IF t_qclabel-matnr = 'R0357' AND
      ( t_qclabel-lgort = '1011' OR t_qclabel-lgort = '1021' ).
      lv_x  = 1.
    ELSEIF t_qclabel-matnr = 'R2307' AND t_qclabel-lgort = '1022'.
      lv_x  = 1.
    ELSEIF t_qclabel-werks = '0101'.
      p_tdform = 'ZTSPQM_SF001A7_8QR'.  "'ZTSPQM_SF001A7QR'.
      lv_x  = 2.
      gv_8  = 'X'.
    ELSEIF t_qclabel-werks = '0102'.
      p_tdform = 'ZTSPQM_SF001A7_8QR'. "'ZTSPQM_SF001A7QR'.
      lv_x  = 2.
      gv_8  = 'X'.
    ELSE.
      lv_x  = 4.
    ENDIF.

    CLEAR gt_ztnpqmdt002.
    READ TABLE gt_ztnpqmdt002 WITH KEY matnr = t_qclabel-matnr
                                       werks = t_qclabel-werks.
    IF sy-subrc = 0 AND gt_ztnpqmdt002-cntind = 'X'.
      CLEAR ls_qals.
      READ TABLE gt_qals INTO ls_qals
                         WITH KEY mblnr = t_qclabel-mblnr
                                  zeile = t_qclabel-zeile
                                  mjahr = t_qclabel-mjahr.
      IF ls_matnr-times IS INITIAL.
        lv_x  = ls_qals-anzgeb.
      ELSE.
        lv_x     = ls_qals-anzgeb DIV ls_matnr-times.
        lv_sisa  = ls_qals-anzgeb MOD ls_matnr-times.
        IF lv_sisa IS NOT INITIAL.
          ADD 1 TO lv_x.
        ENDIF.
      ENDIF.
    ENDIF.

    IF t_qclabel-werks = '0401' AND t_mara-mtart = 'ZPM'.
      p_tdform    = 'ZTNPQM_SF001QRPM'.

      CLEAR ls_qals.
      READ TABLE gt_qals INTO ls_qals
                         WITH KEY mblnr = t_qclabel-mblnr
                                  zeile = t_qclabel-zeile
                                  mjahr = t_qclabel-mjahr.
      IF ls_qals-gebeh = 'PAK' OR
         ls_qals-gebeh = 'ROL'.
        IF ls_matnr-times IS INITIAL.
          lv_x  = ls_qals-anzgeb.
        ELSE.
          lv_x     = ls_qals-anzgeb DIV ls_matnr-times.
          lv_sisa  = ls_qals-anzgeb MOD ls_matnr-times.
          IF lv_sisa IS NOT INITIAL.
            ADD 1 TO lv_x.
          ENDIF.
        ENDIF.
      ELSEIF ls_qals-ktextmat(2) = 'FB' OR
             ls_qals-ktextmat(11) = 'FOLDING BOX'.
        lv_x  = 8.
      ENDIF.
    ENDIF.

    CLEAR lv_atinn.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        input  = 'QTY_CONVERSION'
      IMPORTING
        output = lv_atinn.

    CLEAR ls_mch1.
    READ TABLE t_mch1 INTO ls_mch1
                      WITH KEY matnr = t_qclabel-matnr
                               charg = t_qclabel-charg.
    CLEAR ls_ausp.
    SELECT SINGLE *
      FROM ausp
      INTO CORRESPONDING FIELDS OF ls_ausp
      WHERE objek = ls_mch1-cuobj_bm
        AND atinn = lv_atinn.

    IF t_qclabel-werks = '0101' OR
      t_qclabel-werks = '0102'.
      PERFORM f_modify_manufacturing USING t_qclabel-matnr
                                           t_qclabel-charg
                                           ls_mch1-cuobj_bm
                                     CHANGING ls_matnr-atwrt.
    ENDIF.

    CALL FUNCTION 'FLTP_CHAR_CONVERSION'
      EXPORTING
        input = ls_ausp-atflv
*Begin remark Unicode conversion - DEVK966143
*24.03.2020 - SOL_FELIX
*       ivalue = 'X'
*End remark Unicode conversion - DEVK966143
*Begin insert Unicode conversion - DEVK966143
*24.03.2020 - SOL_FELIX
        ivalu = 'X'
*End insert Unicode conversion - DEVK966143
        decim = 3
      IMPORTING
        flstr = lv_flstr.
    TRANSLATE lv_flstr USING ',.'.
    CONDENSE lv_flstr NO-GAPS.
    ls_matnr-kemasan  = lv_flstr.

    ls_matnr-charg  = t_qclabel-charg.
    ls_matnr-label  = lv_x.

    IF gt_ztnpqmdt002-cntind = 'X'.
      ls_matnr-label = ls_matnr-menge / ls_matnr-kemasan.
    ENDIF.

    APPEND ls_matnr TO lt_matnr.
    CLEAR ls_matnr.
  ENDLOOP.

  IF gv_error IS INITIAL.
    LOOP AT t_qclabel.
      CLEAR: lt_hazcom,lv_hazcom,h,f,r.
      SELECT SINGLE * INTO CORRESPONDING FIELDS OF lt_hazcom
        FROM ztspmdhazcom WHERE matnr = t_qclabel-matnr
                            AND werks = t_qclabel-werks.
      IF sy-subrc = 0.
        CONCATENATE 'H =' lt_hazcom-health INTO h SEPARATED BY space.
        CONCATENATE 'F =' lt_hazcom-fire   INTO f SEPARATED BY space.
        CONCATENATE 'R =' lt_hazcom-reactivity INTO r SEPARATED BY space.
        CONCATENATE h f r  INTO lv_hazcom SEPARATED BY ' ; '.
      ENDIF.

      CLEAR gt_ztnpqmdt002.
      READ TABLE gt_ztnpqmdt002 WITH KEY matnr = t_qclabel-matnr
                                         werks = t_qclabel-werks.
      READ TABLE t_t001w WITH KEY werks  = t_qclabel-werks.
      IF sy-subrc = 0.
        t_qclabel-name1   = t_t001w-name1.
        IF t_qclabel-werks = '0401'.
          t_qclabel-name1   = 'PT. TEMPO NATURAL PRODUCTS'.
        ENDIF.
      ENDIF.
      READ TABLE t_mara WITH KEY matnr  = t_qclabel-matnr.
      IF sy-subrc = 0.
        t_qclabel-maktx   = t_mara-maktx.
        t_qclabel-mtart   = t_mara-mtart.
        t_qclabel-tempb   = t_mara-tempb.
      ENDIF.

      CALL FUNCTION 'VB_BATCH_GET_DETAIL'
        EXPORTING
          matnr              = t_qclabel-matnr
          charg              = t_qclabel-charg
          werks              = t_qclabel-werks
          get_classification = 'X'
        IMPORTING
          ymcha              = ymcha
          classname          = classname
        TABLES
          char_of_batch      = cob
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

      t_qclabel-licha   = ymcha-licha.
      READ TABLE cob INTO ls_cob WITH KEY atnam = 'ZMF'.
      IF sy-subrc = 0.
        t_qclabel-atwtb   = ls_cob-atwtb.
      ENDIF.

      CASE t_qclabel-mtart .
        WHEN 'ZRM' OR 'ZPM'.
        WHEN OTHERS.
          READ TABLE t_mch1 INTO ls_mch1
                            WITH KEY matnr = t_qclabel-matnr
                                     charg = t_qclabel-charg.
          IF sy-subrc = 0.
            t_qclabel-vfdat = ls_mch1-vfdat.
          ENDIF.
      ENDCASE.

      CONCATENATE t_qclabel-matnr t_qclabel-charg
      INTO t_qclabel-barcode
      SEPARATED BY ';'.

      WRITE t_qclabel-menge TO t_qclabel-qtygr UNIT t_qclabel-meins.
      CONDENSE t_qclabel-qtygr NO-GAPS.

      CLEAR lv_meins.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = t_qclabel-meins
        IMPORTING
          output         = lv_meins
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

      CONCATENATE t_qclabel-qtygr lv_meins INTO t_qclabel-qtygr
      SEPARATED BY space.

      IF t_qclabel-werks = '0401' AND
         ( t_mara-mtart = 'ZRM' OR t_mara-mtart = 'ZPM' ).
        t_qclabel-bldat = t_qclabel-budat.
*        PERFORM f_get_production_date USING t_qclabel-mblnr
*                                      CHANGING t_qclabel-bldat.
      ENDIF.

      MODIFY t_qclabel TRANSPORTING name1 maktx mtart licha atwtb barcode
                                    qtygr bldat tempb.

      ls_out = t_qclabel.

      CLEAR : ls_matnr, lv_times, lv_sisa, lv_menge, lv_count.
      READ TABLE lt_matnr INTO ls_matnr
                          WITH KEY matnr = ls_out-matnr
                                   charg = ls_out-charg.
      IF sy-subrc = 0.
        IF t_qclabel-werks = '0401' AND t_mara-mtart = 'ZPM'.
          ls_matnr-anzgeb = t_qclabel-menge DIV ls_matnr-kemasan.
          t_qclabel-sisa  = t_qclabel-menge MOD ls_matnr-kemasan.
          IF t_qclabel-sisa IS NOT INITIAL.
            WRITE t_qclabel-sisa TO t_qclabel-sisatxt UNIT t_qclabel-meins.
            CONDENSE t_qclabel-sisatxt.
            CONCATENATE t_qclabel-sisatxt lv_meins INTO t_qclabel-sisatxt
            SEPARATED BY space.
            ls_out-sisatxt = t_qclabel-sisatxt.
          ENDIF.
        ENDIF.

        lv_times      = ls_matnr-times.
        lv_x          = ls_matnr-label.
        lv_sisa       = ls_matnr-sisa.
        lv_menge      = ls_matnr-menge.
        ls_out-atwrt  = ls_matnr-atwrt.
        WRITE ls_matnr-anzgeb TO lv_pack1 UNIT t_qclabel-meins.
        CONDENSE lv_pack1.
        WRITE ls_matnr-kemasan TO lv_pack2 UNIT t_qclabel-meins.
        CONDENSE lv_pack2.
        CONCATENATE lv_pack1 '@' lv_pack2 lv_meins INTO ls_out-packing
        SEPARATED BY space.

*        IF t_qclabel-sisatxt IS NOT INITIAL.
*          CONCATENATE ls_out-packing t_qclabel-sisatxt INTO ls_out-packing
*          SEPARATED BY '         '.
*        ENDIF.
      ENDIF.
*      CLEAR t_qclabel.

      IF lv_times IS INITIAL.
        lv_times = '1'.
      ENDIF.

      CLEAR: ls_matnr2,lv_count2.
      READ TABLE lt_matnr INTO ls_matnr2
                          WITH KEY matnr = ls_out-matnr
                                   charg = ls_out-charg.

      DO lv_times TIMES.
        ADD 1 TO lv_count.
        lv_tt = lv_times.
        CONDENSE lv_tt.
        lv_ct = lv_count.
        CONDENSE lv_ct.

        CONCATENATE lv_ct '/' lv_tt INTO ls_out-jumlah.
        CONDENSE ls_out-jumlah NO-GAPS.
        ls_out-pallet   = lv_ct.
        CONDENSE ls_out-pallet NO-GAPS.

        PERFORM f_get_sbin USING t_qclabel-mtart
                                 t_qclabel-mblnr
                                 t_qclabel-lgnum
                                 t_qclabel-tbnum
                                 t_qclabel-werks
                                 t_qclabel-matnr
                                 lv_menge
                                 lv_times
                                 lv_sisa
                                 lv_count
                           CHANGING ls_out-nlpla.

        DO lv_x TIMES.

          ADD 1 TO lv_count2.

          IF ls_matnr2-gebeh = 'PAK' OR ls_matnr2-gebeh = 'ROL' OR
             gt_ztnpqmdt002-cntind = 'X'.
            IF lv_count2 GT ls_matnr2-anzgeb.
              EXIT.
            ENDIF.
          ENDIF.

          CASE lv_count.
            WHEN '1'.
              ls_out-menge = lv_menge.
            WHEN lv_times.
              IF lv_sisa IS INITIAL.
                ls_out-menge = lv_menge.
              ELSE.
                ls_out-menge = lv_sisa.
              ENDIF.
            WHEN OTHERS.
              ls_out-menge = lv_menge.
          ENDCASE.

          WRITE ls_out-menge TO ls_out-menget UNIT ls_out-meins.
          CONDENSE ls_out-menget NO-GAPS.

          CLEAR lv_meins.
          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
            EXPORTING
              input          = ls_out-meins
            IMPORTING
              output         = lv_meins
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.

          CONCATENATE ls_out-menget lv_meins INTO ls_out-menget
          SEPARATED BY space.

          PERFORM f_calculate_quantity USING 'KAR' ls_out-menge
                                             ls_out-matnr ls_out-lifnr
                                             t_qclabel-lgnum t_qclabel-lgort '' '' ''
                                       CHANGING lv_sisa lv_times lv_carton.
          WRITE lv_carton TO ls_out-cartont UNIT 'KAR'.
          CONDENSE ls_out-cartont NO-GAPS.
          CONCATENATE ls_out-cartont 'CAR' INTO ls_out-cartont
          SEPARATED BY space.

          ls_out-hazcom = lv_hazcom.

*          PERFORM f_get_sbin USING t_qclabel-mtart
*                                   t_qclabel-mblnr
*                                   t_qclabel-lgnum
*                                   t_qclabel-tbnum
*                                   t_qclabel-werks
*                                   ls_out-menge
*                             CHANGING ls_out-nlpla.

          APPEND ls_out TO t_out.
        ENDDO.
      ENDDO.
      CLEAR t_qclabel.
    ENDLOOP.

    LOOP AT t_out.
      CASE t_out-lgnum.
        WHEN '011'.
          IF t_out-tempb IS INITIAL.
            CASE t_out-ltkze.
              WHEN 'UR1' OR 'UR4'.
                t_out-tempb  = '03'.
              WHEN 'R3A' OR 'R3B' OR 'R3C' OR 'UR3'.
                t_out-tempb  = '02'.
              WHEN 'UR2' OR 'UR5'.
                t_out-tempb  = '01'.
            ENDCASE.
          ENDIF.
        WHEN '012'.
          IF t_out-ltkze = 'UR5'.
            CLEAR t_out-tempb.
          ENDIF.

          IF t_out-tempb IS INITIAL.
            CASE t_out-ltkze.
              WHEN 'R1C' OR 'UR1' OR 'UR6'.
                t_out-tempb  = '03'.
              WHEN 'KR2' OR 'R2C' OR 'UR2'.
                t_out-tempb  = '02'.
              WHEN 'UR7'.
                t_out-tempb  = '01'.
            ENDCASE.
          ENDIF.
      ENDCASE.

      SELECT SINGLE tbtxt
        FROM t143t
        INTO t_out-tempkond
        WHERE spras = sy-langu
          AND tempb = t_out-tempb.

      IF t_out-mtart = 'ZRM'.
        IF t_out-tempkond IS INITIAL.
          t_out-tempkond = 'Cold Room (8°C-15°C)'.
        ENDIF.
      ENDIF.

      t_out-pallet    = t_out-pallet + gv_add.
      CONCATENATE t_out-matnr t_out-charg t_out-jumlah t_out-mblnr
      t_out-menget
      INTO t_out-barcode
      SEPARATED BY ';'.
      MODIFY t_out TRANSPORTING tempkond barcode pallet.
      CLEAR t_out.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_process_data
*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_form.
  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  IF d_frm_subrc IS INITIAL.
    d_output_opt-tdimmed  = nast-dimme.
    d_output_opt-tddelete = nast-delet.
    d_output_opt-tdcopies = nast-anzal.

    d_ctrl_param-no_close = ' '.
    d_ctrl_param-no_open = ' '.

    LOOP AT t_out INTO wa_qclabel.
      AT FIRST.
        d_ctrl_param-no_close = 'X'.
      ENDAT.

      AT LAST.
        d_ctrl_param-no_close = space.
      ENDAT.

      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          t_qclabel          = wa_qclabel.

      d_ctrl_param-no_open = 'X'.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_print_form
*&---------------------------------------------------------------------*
*&      Form  f_free_memory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
  CLEAR:  t_qclabel, t_qclabel[], gt_zwmpalvnd[], gt_zwmpalvnd,
          t_marm[], t_marm, t_out[], t_out, wa_qclabel, gv_error,
          gt_ltak[],gt_ltap[],gt_ltapsv[].
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_GET_MANUFACTURER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_manufacturer  USING    fu_matnr
                                  fu_charg
                                  fu_werks
                         CHANGING fc_mfrpn
                                  fc_licha.
  DATA: lv_mcha      LIKE mcha,
        lv_classname LIKE klah-class,
        lt_batch     LIKE clbatch OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      matnr              = fu_matnr
      charg              = fu_charg
      werks              = fu_werks
      get_classification = 'X'
    IMPORTING
      ymcha              = lv_mcha
      classname          = lv_classname
    TABLES
      char_of_batch      = lt_batch
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
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR lt_batch.
    READ TABLE lt_batch WITH KEY atnam = 'ZMF'.
    fc_mfrpn = lt_batch-atwtb.

    fc_licha = lv_mcha-licha.
  ENDIF.

ENDFORM.                    " F_GET_MANUFACTURER

*&---------------------------------------------------------------------*
*&      Form  F_GET_PRODUCTION_DATE
*&---------------------------------------------------------------------*
FORM f_get_production_date  USING    fu_mblnr
                            CHANGING fc_hsdat.
  SELECT SINGLE hsdat
    FROM mseg
    INTO fc_hsdat
    WHERE mblnr EQ fu_mblnr.
ENDFORM.                    " F_GET_PRODUCTION_DATE

*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_MATERIAL_UNIT
*&---------------------------------------------------------------------*
FORM f_convert_material_unit  USING    fu_matnr
                                       fu_in
                                       fu_out
                                       fu_menge
                              CHANGING fc_qtypallet.
  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      i_matnr  = fu_matnr
      i_in_me  = fu_in
      i_out_me = fu_out
      i_menge  = fu_menge
    IMPORTING
      e_menge  = fc_qtypallet.
ENDFORM.                    " F_CONVERT_MATERIAL_UNIT

*&---------------------------------------------------------------------*
*&      Form  F_ROUND
*&---------------------------------------------------------------------*
FORM f_round  USING    fu_qtypallet
                       fu_sign
              CHANGING fc_qtyint.
  CALL FUNCTION 'ROUND'
    EXPORTING
*     DECIMALS            = 0
      input  = fu_qtypallet
      sign   = fu_sign
    IMPORTING
      output = fc_qtyint.
ENDFORM.                    " F_ROUND

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_QUANTITY
*&---------------------------------------------------------------------*
FORM f_calculate_quantity  USING    fu_meinh fu_menge fu_matnr fu_lifnr
                                    fu_lgnum fu_lgort fu_atnam fu_werks
                                    fu_charg
                           CHANGING fc_sisa fc_times fc_menge.
  DATA : ls_marm      LIKE LINE OF t_marm,
         ls_zwmpalvnd LIKE LINE OF gt_zwmpalvnd,
         lv_menge     TYPE p DECIMALS 4,
         lv_leqty     TYPE p DECIMALS 3.

  IF fu_lgnum = '011' OR
    fu_lgnum = '012'.
    IF fu_atnam IS NOT INITIAL.
      PERFORM f_get_vendor_batch USING fu_matnr fu_charg fu_werks fu_atnam
                                 CHANGING lv_leqty.
    ENDIF.
  ENDIF.

  IF fu_meinh = 'KAR'.
    READ TABLE t_marm INTO ls_marm WITH KEY meinh = fu_meinh.
    IF sy-subrc = 0.
      lv_menge  = ( fu_menge / ls_marm-umrez ) / ls_marm-umren.
      CALL FUNCTION 'ROUND'
        EXPORTING
          input         = lv_menge
          sign          = '+'
        IMPORTING
          output        = fc_menge
        EXCEPTIONS
          input_invalid = 1
          overflow      = 2
          type_invalid  = 3
          OTHERS        = 4.
    ENDIF.
  ELSE.
    READ TABLE gt_zwmpalvnd INTO ls_zwmpalvnd
                            WITH KEY lgnum = fu_lgnum
                                     matnr = fu_matnr
                                     lifnr = fu_lifnr.
    IF sy-subrc = 0.
      IF lv_leqty IS NOT INITIAL.
        ls_zwmpalvnd-leqty = lv_leqty.
      ENDIF.
      fc_sisa   = fu_menge MOD ls_zwmpalvnd-leqty.
      IF fc_sisa IS NOT INITIAL.
        fc_times      = ( fu_menge DIV ls_zwmpalvnd-leqty ) + 1.
      ELSE.
        fc_times      = fu_menge DIV ls_zwmpalvnd-leqty.
      ENDIF.
      fc_menge  = ( ls_zwmpalvnd-leqty ).
    ELSE.
      IF fu_matnr = 'R0357' AND
        ( fu_lgort = '1011' OR fu_lgort = '1021' ).
        fc_menge = fu_menge.
      ELSEIF fu_matnr = 'R2307' AND fu_lgort = '1022'.
        fc_menge = fu_menge.
      ELSE.
        READ TABLE t_marm INTO ls_marm WITH KEY matnr = fu_matnr
                                                meinh = fu_meinh.
        IF sy-subrc = 0.
          IF lv_leqty IS INITIAL.
            fc_sisa   = fu_menge MOD ( ls_marm-umrez / ls_marm-umren ).
            IF fc_sisa IS NOT INITIAL.
              fc_times      = ( fu_menge DIV ( ls_marm-umrez / ls_marm-umren ) ) + 1.
            ELSE.
              fc_times      = ( fu_menge DIV ( ls_marm-umrez / ls_marm-umren ) ).
            ENDIF.
            fc_menge  = ( ls_marm-umrez / ls_marm-umren ).
          ELSE.
            fc_sisa   = fu_menge MOD lv_leqty.
            IF fc_sisa IS NOT INITIAL.
              fc_times      = ( fu_menge DIV lv_leqty ) + 1.
            ELSE.
              fc_times      = fu_menge DIV lv_leqty.
            ENDIF.
            fc_menge  = ( lv_leqty ).
          ENDIF.
        ELSE.
          IF fu_lgnum = '011' OR
            fu_lgnum = '012'.
            IF lv_leqty IS INITIAL.
              gv_error  = 1.
            ELSE.
              fc_sisa   = fu_menge MOD lv_leqty.
              IF fc_sisa IS NOT INITIAL.
                fc_times      = ( fu_menge DIV lv_leqty ) + 1.
              ELSE.
                fc_times      = fu_menge DIV lv_leqty.
              ENDIF.
              fc_menge  = ( lv_leqty ).
            ENDIF.
          ELSE.
            gv_error  = 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF fu_menge < fc_menge.
    fc_menge = fu_menge.
  ENDIF.
ENDFORM.                    " F_CALCULATE_QUANTITY

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_QR_FORM
*&---------------------------------------------------------------------*
FORM f_print_qr_form .
  DATA : lt_out   TYPE STANDARD TABLE OF ztnpqmst001,
         ls_out   LIKE LINE OF lt_out,
         ls_xout  LIKE LINE OF lt_out,
         lv_lines TYPE i,
         lv_count TYPE i,
         fr       TYPE i,
         to       TYPE i.

  CALL FUNCTION 'RFC_MODIFY_R3_DESTINATION'
    EXPORTING
      destination                = gs_001-destination
      action                     = 'M'
      systemnr                   = gs_001-rfcservice
      server                     = gv_host
      language                   = sy-langu
      client                     = gs_001-rfcclient
      user                       = gs_001-rfcuser
      password                   = gs_001-password
    EXCEPTIONS
      authority_not_available    = 1
      destination_already_exist  = 2
      destination_not_exist      = 3
      destination_enqueue_reject = 4
      information_failure        = 5
      trfc_entry_invalid         = 6
      internal_failure           = 7
      snc_information_failure    = 8
      snc_internal_failure       = 9
      destination_is_locked      = 10
      OTHERS                     = 11.
  IF sy-subrc = 0.
    DESCRIBE TABLE t_out LINES lv_lines.
    lv_lines  = ( lv_lines DIV 250 ) + 1.

    DO lv_lines TIMES.
      CLEAR lt_out[].
      fr = lv_count + 1.
      to = lv_count + 250.
      LOOP AT t_out INTO ls_out FROM fr TO to.
        ADD 1 TO lv_count.
        ls_xout = ls_out.
        APPEND ls_xout TO lt_out.
        CLEAR ls_xout.
      ENDLOOP.

      CALL FUNCTION 'ZRFC_ZTNPQM_SF001'
        DESTINATION gs_001-destination
        EXPORTING
          pi_cntrlpara = d_ctrl_param
          pi_outputopt = d_output_opt
          pi_tdsfname  = p_tdform
          pi_rspolname = gs_001-name
          pi_qclabel   = wa_qclabel
          pi_packsize  = 'X'
        TABLES
          pt_qclabel   = lt_out.
    ENDDO.
  ENDIF.
ENDFORM.                    " F_PRINT_QR_FORM

*&---------------------------------------------------------------------*
*&      Form  F_PALLET_COUNT
*&---------------------------------------------------------------------*
FORM f_pallet_count .
  DATA : lt_mseg      TYPE STANDARD TABLE OF mseg INITIAL SIZE 0,
         lt_mseg_cncl TYPE STANDARD TABLE OF mseg INITIAL SIZE 0,
         ls_mseg      LIKE LINE OF lt_mseg.

  DATA : lv_sisa  TYPE mseg-menge,
         lv_menge TYPE mseg-menge,
         lv_times TYPE int4.

  CLEAR gv_add.
  READ TABLE t_qclabel INDEX 1.
  SELECT *
    FROM aufm
    INTO CORRESPONDING FIELDS OF TABLE t_aufm
    WHERE aufnr = t_qclabel-aufnr
    ORDER BY PRIMARY KEY.

  IF t_aufm[] IS NOT INITIAL.
    SELECT *
      FROM mseg
      INTO CORRESPONDING FIELDS OF TABLE lt_mseg
      FOR ALL ENTRIES IN t_aufm
      WHERE mblnr = t_aufm-mblnr
        AND mjahr = t_aufm-mjahr
        AND zeile = t_aufm-zeile
        AND bwart IN ('101', '102')
      ORDER BY PRIMARY KEY.

    lt_mseg_cncl[] = lt_mseg[].

    DELETE lt_mseg_cncl WHERE smbln EQ space.
    SORT : lt_mseg_cncl BY smbln,
           lt_mseg BY mblnr.
    DELETE lt_mseg WHERE mblnr > pa_mblnr.
    LOOP AT lt_mseg INTO ls_mseg.
      READ TABLE lt_mseg_cncl WITH KEY smbln = ls_mseg-mblnr
                                       sjahr = ls_mseg-mjahr
                                       smblp = ls_mseg-zeile
                              BINARY SEARCH TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        DELETE TABLE lt_mseg FROM ls_mseg.
      ENDIF.
    ENDLOOP.
    DELETE lt_mseg WHERE bwart NE '101'.

    IF lt_mseg[] IS INITIAL.
      gv_error = 2.
      CLEAR : t_qclabel[].
    ELSE.
      LOOP AT lt_mseg INTO ls_mseg.
        IF ls_mseg-mblnr = pa_mblnr AND
          ls_mseg-mjahr = pa_mjahr.
          CONTINUE.
        ENDIF.
        PERFORM f_calculate_quantity USING 'PAL' ls_mseg-menge
                                     ls_mseg-matnr '' ls_mseg-lgnum
                                     ls_mseg-lgort
                                     'ZPALVND' ls_mseg-werks ls_mseg-charg
                               CHANGING lv_sisa lv_times
                                        lv_menge.
        ADD lv_times TO gv_add.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PALLET_COUNT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  DATA : lv_funcmod    TYPE rs38l_fnam,
         lv_output_opt TYPE ssfcompop,
         lv_count      TYPE i,
         lv_loop       TYPE i.

  CLEAR : lv_loop, lv_count.
  DESCRIBE TABLE t_out LINES lv_loop.

  "Get FM smartforms
  SET PARAMETER ID 'SSFNAME' FIELD p_tdform.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = p_tdform
    IMPORTING
      fm_name            = lv_funcmod
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  "Get Printer name
  IF sy-subrc = 0.
    MOVE-CORRESPONDING d_output_opt TO lv_output_opt.
    lv_output_opt-tddest    = nast-ldest.

    LOOP AT t_out.
      ADD 1 TO lv_count.

      IF lv_count = 1.
        lv_output_opt-tdnewid   = 'X'.
      ENDIF.

      lv_output_opt-tdimmed   = 'X'.

      IF lv_count = lv_loop.
        d_ctrl_param-no_close  = space.
      ELSE.
        d_ctrl_param-no_close  = 'X'.
      ENDIF.

      CALL FUNCTION lv_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = lv_output_opt
          user_settings      = space
          t_qclabel          = t_out.

      d_ctrl_param-no_open  = 'X'.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_MANUFACTURING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_MATNR_ATWRT  text
*----------------------------------------------------------------------*
FORM f_modify_manufacturing  USING    fu_matnr fu_charg fu_cuobj_bm
                             CHANGING fc_atwrt.
  DATA : lv_atinn   TYPE ausp-atinn.

  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      input  = 'ZMF'
    IMPORTING
      output = lv_atinn.

  SELECT SINGLE atwrt
    FROM ausp
    INTO fc_atwrt
    WHERE objek  EQ fu_cuobj_bm
      AND atinn  EQ lv_atinn
      AND klart  EQ '023'.
ENDFORM.                    " F_MODIFY_MANUFACTURING

*&---------------------------------------------------------------------*
*&      Form  F_GET_VENDOR_BATCH
*&---------------------------------------------------------------------*
FORM f_get_vendor_batch USING fu_matnr fu_charg fu_werks fu_atnam
                        CHANGING fc_atwtb.

  DATA : ymcha     TYPE mcha,
         classname TYPE klah-class,
         cob       TYPE STANDARD TABLE OF clbatch,
         ls_cob    LIKE LINE OF cob.

  CLEAR fc_atwtb.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      matnr              = fu_matnr
      charg              = fu_charg
      werks              = fu_werks
      get_classification = 'X'
    IMPORTING
      ymcha              = ymcha
      classname          = classname
    TABLES
      char_of_batch      = cob
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

  READ TABLE cob INTO ls_cob WITH KEY atnam = fu_atnam.
  IF sy-subrc = 0.
    TRANSLATE ls_cob-atwtb USING '. '.
    TRANSLATE ls_cob-atwtb USING ',.'.
    CONDENSE ls_cob-atwtb NO-GAPS.
    fc_atwtb  = ls_cob-atwtb.
  ENDIF.
ENDFORM.                    " F_GET_VENDOR_BATCH

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_8
*&---------------------------------------------------------------------*
FORM f_split_8 .
  DATA : ls_qclabel8 LIKE LINE OF t_qclabel8,
         ls_qclabel  LIKE LINE OF t_out.

  DATA : lv_field(30),
         lv_count     TYPE i,
         lv_pos.

  FIELD-SYMBOLS <fs>   TYPE any.

  CLEAR t_qclabel8[].

  LOOP AT t_out INTO ls_qclabel.
    ADD 1 TO lv_count.
    IF lv_count > 8.
      lv_count = 1.
    ENDIF.

    lv_pos  = lv_count.

    CONCATENATE 'LS_QCLABEL8-NAME1' lv_pos INTO lv_field.
    ASSIGN (lv_field) TO <fs>.
    <fs> = ls_qclabel-name1.

    CONCATENATE 'LS_QCLABEL8-MATNR' lv_pos INTO lv_field.
    ASSIGN (lv_field) TO <fs>.
    <fs> = ls_qclabel-matnr.

    CONCATENATE 'LS_QCLABEL8-MAKTX' lv_pos INTO lv_field.
    ASSIGN (lv_field) TO <fs>.
    <fs> = ls_qclabel-maktx.

    CONCATENATE 'LS_QCLABEL8-CHARG' lv_pos INTO lv_field.
    ASSIGN (lv_field) TO <fs>.
    <fs> = ls_qclabel-charg.

    CONCATENATE 'LS_QCLABEL8-LICHA' lv_pos INTO lv_field.
    ASSIGN (lv_field) TO <fs>.
    <fs> = ls_qclabel-licha.

    CONCATENATE 'LS_QCLABEL8-MBLNR' lv_pos INTO lv_field.
    ASSIGN (lv_field) TO <fs>.
    <fs> = ls_qclabel-mblnr.

    CONCATENATE 'LS_QCLABEL8-BLDAT' lv_pos INTO lv_field.
    ASSIGN (lv_field) TO <fs>.
    <fs> = ls_qclabel-bldat.

    CONCATENATE 'LS_QCLABEL8-MENGET' lv_pos INTO lv_field.
    ASSIGN (lv_field) TO <fs>.
    <fs> = ls_qclabel-menget.

    CONCATENATE 'LS_QCLABEL8-QTYGR' lv_pos INTO lv_field.
    ASSIGN (lv_field) TO <fs>.
    <fs> = ls_qclabel-qtygr.

    CONCATENATE 'LS_QCLABEL8-PACKING' lv_pos INTO lv_field.
    ASSIGN (lv_field) TO <fs>.
    <fs> = ls_qclabel-packing.

    CONCATENATE 'LS_QCLABEL8-ATWRT' lv_pos INTO lv_field.
    ASSIGN (lv_field) TO <fs>.
    <fs> = ls_qclabel-atwrt.

    CONCATENATE 'LS_QCLABEL8-BARCODE' lv_pos INTO lv_field.
    ASSIGN (lv_field) TO <fs>.
    <fs> = ls_qclabel-barcode.

    CONCATENATE 'LS_QCLABEL8-JUMLAH' lv_pos INTO lv_field.
    ASSIGN (lv_field) TO <fs>.
    <fs> = ls_qclabel-jumlah.

    CONCATENATE 'LS_QCLABEL8-TEMPKOND' lv_pos INTO lv_field.
    ASSIGN (lv_field) TO <fs>.
    <fs> = ls_qclabel-tempkond.

    IF lv_count = 8.
      ls_qclabel8-hazcom = ls_qclabel-hazcom.
      APPEND ls_qclabel8 TO t_qclabel8.
      CLEAR ls_qclabel8.
    ENDIF.
  ENDLOOP.

  IF lv_count < 8.
    ls_qclabel8-hazcom = ls_qclabel-hazcom.
    APPEND ls_qclabel8 TO t_qclabel8.
    CLEAR ls_qclabel8.
  ENDIF.
ENDFORM.                    " F_SPLIT_8

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA_8
*&---------------------------------------------------------------------*
FORM f_print_data_8 .
  DATA : lv_funcmod    TYPE rs38l_fnam,
         lv_output_opt TYPE ssfcompop,
         ls_qclabel    TYPE ztnpqmst001,
         ls_qclabel8   TYPE ztnpqmst001_8,
         lv_count      TYPE i,
         lv_loop       TYPE i.

  CLEAR : lv_loop, lv_count.
  DESCRIBE TABLE t_qclabel8 LINES lv_loop.

  "Get FM smartforms
  SET PARAMETER ID 'SSFNAME' FIELD p_tdform.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = p_tdform
    IMPORTING
      fm_name            = lv_funcmod
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  "Get Printer name
  IF sy-subrc = 0.
    MOVE-CORRESPONDING d_output_opt TO lv_output_opt.
    lv_output_opt-tddest    = nast-ldest.

    LOOP AT t_qclabel8 INTO ls_qclabel8.
      ADD 1 TO lv_count.

      IF lv_count = 1.
        lv_output_opt-tdnewid   = 'X'.
      ENDIF.

      lv_output_opt-tdimmed   = 'X'.

      IF lv_count = lv_loop.
        d_ctrl_param-no_close  = space.
      ELSE.
        d_ctrl_param-no_close  = 'X'.
      ENDIF.

      CALL FUNCTION lv_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = lv_output_opt
          user_settings      = space
          t_qclabel          = ls_qclabel8.

      d_ctrl_param-no_open  = 'X'.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PRINT_DATA_8

*&---------------------------------------------------------------------*
*&      Form  F_GET_SBIN
*&---------------------------------------------------------------------*
FORM f_get_sbin  USING    fu_mtart fu_mblnr fu_lgnum fu_tbnum fu_werks
                          fu_matnr fu_menge fu_times fu_sisa fu_count
                 CHANGING fc_nlpla.
  IF fu_werks = '0401'.
    CASE fu_mtart.
      WHEN 'ZPM'.
        IF fu_count = fu_times AND fu_sisa IS NOT INITIAL.
          CLEAR gt_ltap.
          READ TABLE gt_ltap WITH KEY wenum = fu_mblnr
                                      matnr = fu_matnr
                                      vsolm = fu_sisa.
          IF sy-subrc = 0.
            fc_nlpla = gt_ltap-nlpla.
            APPEND INITIAL LINE TO gt_ltapsv ASSIGNING <fs_ltapsv>.
            <fs_ltapsv> = gt_ltap.
          ENDIF.
        ELSE.

          CLEAR gt_ltap.
          LOOP AT gt_ltap WHERE wenum = fu_mblnr
                            AND matnr = fu_matnr
                            AND vsolm = fu_menge.
            READ TABLE gt_ltapsv WITH KEY lgnum = gt_ltap-lgnum
                                          tanum = gt_ltap-tanum
                                          tapos = gt_ltap-tapos.
            IF sy-subrc = 0.
              CONTINUE.
            ELSE.
              fc_nlpla = gt_ltap-nlpla.
              APPEND INITIAL LINE TO gt_ltapsv ASSIGNING <fs_ltapsv>.
              <fs_ltapsv> = gt_ltap.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_GET_SBIN
