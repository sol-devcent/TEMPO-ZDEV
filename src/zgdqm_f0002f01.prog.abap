*----------------------------------------------------------------------*
*   INCLUDE ZTNPQMF002F01
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
  CHECK va_lines NE 0.
  PERFORM f_process_data.
  IF gv_error IS INITIAL.
    IF p_tdform = 'ZTNPQM_SF004'.
      PERFORM f_print_form.
    ELSE.
      IF gv_flag IS INITIAL.
        PERFORM f_print_form.
      ELSE.
        PERFORM f_print_qr_form.
      ENDIF.
    ENDIF.
  ELSE.
    CASE gv_error.
      WHEN 1.
        MESSAGE s000(zab) WITH
        'Container No. or Qty conversion data is not found'
        DISPLAY LIKE 'E'.
    ENDCASE.
  ENDIF.
*  PERFORM f_print_form.
  PERFORM f_free_memory.
ENDFORM.                    " f_process_report
*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
FORM f_init_data.
  CLEAR : i_sf0030[], gs_001.

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
    WHERE name = 'ZTNPQM_F002'.

  PERFORM f_get_qprs USING so_pruef-low
                     CHANGING pa_wadah.
ENDFORM.                    " f_init_data
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
FORM f_get_data.
  DATA l_name1_plant LIKE t001w-name1.
  DATA lv_atinn      TYPE ausp-atinn.
  DATA lv_convq(30).
  DATA lv_hsdat      TYPE mch1-hsdat.

  DATA: BEGIN OF lt_30 OCCURS 0.
          INCLUDE STRUCTURE zgdqmst0030.
  DATA: plnnr   TYPE qals-plnnr,
        plnal   TYPE qals-plnal.
  DATA: END OF lt_30.

  DATA : ls_ausp    LIKE LINE OF t_ausp.

  DATA : ls_t320    LIKE LINE OF gt_t320.

* Get plant name.
  SELECT SINGLE name1
    FROM t001w
    INTO l_name1_plant
    WHERE werks EQ pa_werk.

* Get Data From QALS
  SELECT werk prueflos matnr charg ktextmat mblnr
         mjahr losmenge stat35 mengeneinh ktextlos lmengeist
         lmenge01 lmenge03 lmenge04 anzgeb gebeh plnnr plnal
         prbnaverf lagortchrg lgnum
    FROM qals
    INTO CORRESPONDING FIELDS OF TABLE i_sf0030
    WHERE prueflos IN so_pruef AND
          werk     EQ pa_werk  AND
          matnr    IN so_matnr AND
          charg    IN so_charg AND
          stat35   NE space.

  IF i_sf0030[] IS NOT INITIAL.
    SELECT *
      FROM t320
      INTO CORRESPONDING FIELDS OF TABLE gt_t320
      FOR ALL ENTRIES IN i_sf0030
      WHERE werks = i_sf0030-werk
        AND lgort = i_sf0030-lagortchrg.
  ENDIF.

  lt_30[] = i_sf0030[].
  SORT lt_30 BY plnnr plnal.
  DELETE ADJACENT DUPLICATES FROM lt_30 COMPARING plnnr plnal.
  IF lt_30[] IS NOT INITIAL.
    SELECT *
      FROM plko
      INTO CORRESPONDING FIELDS OF TABLE t_plko
      FOR ALL ENTRIES IN lt_30
      WHERE plnnr = lt_30-plnnr
        AND plnal = lt_30-plnal.
  ENDIF.

  LOOP AT i_sf0030.
    i_sf0030-werk_desc = l_name1_plant.

    READ TABLE gt_t320 INTO ls_t320 INDEX 1.
    IF sy-subrc = 0.
      i_sf0030-lgnum = ls_t320-lgnum.
    ENDIF.

    SELECT SINGLE ltkze
      FROM mlgn
      INTO i_sf0030-ltkze
      WHERE matnr = i_sf0030-matnr
        AND lgnum = i_sf0030-lgnum.

    SELECT SINGLE vcode vbewertung vdatum vname
      FROM qave
      INTO (i_sf0030-vcode, i_sf0030-vbewertung,
            i_sf0030-vdatum, i_sf0030-uname)
      WHERE prueflos EQ i_sf0030-prueflos.

    SELECT SINGLE qndat licha lifnr vfdat cuobj_bm hsdat
      FROM mch1
      INTO (i_sf0030-qndat, i_sf0030-licha, i_sf0030-lifnr,
            i_sf0030-vfdat, i_sf0030-cuobj_bm, lv_hsdat)
      WHERE matnr EQ i_sf0030-matnr AND
            charg EQ i_sf0030-charg.

    CLEAR lv_atinn.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        input  = 'QTY_CONVERSION'
      IMPORTING
        output = lv_atinn.

    SELECT *
      FROM ausp
      INTO CORRESPONDING FIELDS OF TABLE t_ausp
      WHERE objek = i_sf0030-cuobj_bm
        AND atinn = lv_atinn.

    SELECT *
      FROM qprs
      INTO CORRESPONDING FIELDS OF TABLE t_qprs
      WHERE plos2  = i_sf0030-prueflos.
*        AND pnver  = i_sf0030-prbnaverf.

    SELECT *
      FROM qapp
      INTO CORRESPONDING FIELDS OF TABLE t_qapp
      WHERE prueflos = i_sf0030-prueflos.

    SELECT *
      FROM marm
      INTO CORRESPONDING FIELDS OF TABLE t_marm
      WHERE matnr = i_sf0030-matnr.

    SELECT SINGLE name1
      FROM lfa1
      INTO i_sf0030-lifnr_desc
      WHERE lifnr EQ i_sf0030-lifnr.

    SELECT SINGLE bldat
      FROM mkpf
      INTO i_sf0030-bldat
      WHERE mblnr EQ i_sf0030-mblnr AND
            mjahr EQ i_sf0030-mjahr.

    IF lv_hsdat IS NOT INITIAL.
      i_sf0030-bldat = lv_hsdat.
    ENDIF.

    CASE 'X'.
      WHEN p_a.
        i_sf0030-vbewertung = 'A'.
*        i_sf0030-losmenge   = i_sf0030-lmenge01.
        SELECT SINGLE * FROM mseg WHERE
          mblnr = p_mblnr AND
          mjahr = p_mjahr AND
          bwart = '321'.
        IF sy-subrc EQ 0.
          i_sf0030-losmenge   = mseg-erfmg.
        ENDIF.

      WHEN p_r.
        i_sf0030-vbewertung = 'R'.
*        i_sf0030-losmenge   = i_sf0030-lmenge04.
        SELECT SINGLE * FROM mseg WHERE
          mblnr = p_mblnr AND
          mjahr = p_mjahr AND
          bwart = '350'.
        IF sy-subrc EQ 0.
          i_sf0030-losmenge   = mseg-erfmg.
        ENDIF.
    ENDCASE.

    PERFORM f_get_batch_classification USING i_sf0030-matnr i_sf0030-werk
                                             i_sf0030-charg
                                       CHANGING i_sf0030-qtyconv.

    PERFORM f_manufacturing USING 'ZMF' i_sf0030-cuobj_bm
                            CHANGING i_sf0030-atwrt.

    MODIFY i_sf0030 TRANSPORTING ltkze qndat licha lifnr werk_desc atwrt
                                 lifnr_desc bldat vcode vbewertung
                                 vdatum losmenge vfdat qtyconv uname lgnum.
  ENDLOOP.
ENDFORM.                    " f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
FORM f_validate_data.
  DATA : lt_30    TYPE STANDARD TABLE OF zgdqmst0030,
         lt_mara  TYPE STANDARD TABLE OF mara,
         ls_mara  LIKE LINE OF lt_mara.

  lt_30[] = i_sf0030[].
  SORT lt_30 BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_30 COMPARING matnr.

  IF lt_30[] IS NOT INITIAL.
    SELECT *
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE lt_mara
      FOR ALL ENTRIES IN lt_30
      WHERE matnr = lt_30-matnr.

    READ TABLE lt_mara INTO ls_mara INDEX 1.
    IF sy-subrc = 0.
      gv_mtart = ls_mara-mtart.
      gv_tempb = ls_mara-tempb.

      CASE ls_mara-mtart.
        WHEN 'ZRM'.
          IF gv_flag IS INITIAL.
            p_tdform = 'ZTNPQM_SF003QR'.
          ELSE.
            p_tdform = 'ZTNPQM_SF003'.
          ENDIF.
        WHEN 'ZPM'.
          IF gv_flag IS INITIAL.
            p_tdform = 'ZTNPQM_SF003QR'.
          ELSE.
            p_tdform = 'ZTNPQM_SF003'.
          ENDIF.
        WHEN OTHERS.
          p_tdform = 'ZTNPQM_SF004'.
      ENDCASE.
    ENDIF.
  ENDIF.

  DESCRIBE TABLE i_sf0030 LINES va_lines.
  IF va_lines IS INITIAL.
    MESSAGE i000(zqm) WITH 'No record found'.
  ENDIF.
ENDFORM.                    " f_validate_data
*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  TYPES : BEGIN OF ty_1,
            x   TYPE p DECIMALS 4,
          END OF ty_1.

  DATA ls_30      LIKE LINE OF gt_30.
  DATA ls_plko    LIKE LINE OF t_plko.
  DATA : lv_times       TYPE int4,
         lv_sisa        TYPE mseg-menge,
         lv_menge       TYPE mseg-menge,
         lv_carton      TYPE mseg-menge,
         lv_count       TYPE int4,
         lv_sample      TYPE int4,
         lv_tt(10),
         lv_ct(10),
         lv_vfdat(10),
         lv_meins       TYPE mara-meins,
         ls_ausp        LIKE LINE OF t_ausp,
         ls_qprs        LIKE LINE OF t_qprs,
         lv_flstr(22),
         lv_kemasan     TYPE mseg-menge,
         lv_kemas       TYPE mseg-menge,
         ls_marm        LIKE LINE OF t_marm,
         lv_subrc       TYPE sy-subrc,
         lv_gebeh       LIKE qals-gebeh,
         lv_x           TYPE p DECIMALS 4,
         lv_y           TYPE p DECIMALS 0,
         lv_z           TYPE p DECIMALS 0,
         lv_div         TYPE p,
         lv_mod         TYPE p.

  DATA : lt_1       TYPE STANDARD TABLE OF ty_1 INITIAL SIZE 0,
         ls_1       LIKE LINE OF lt_1,
         status     TYPE STANDARD TABLE OF jstat INITIAL SIZE 0,
         ls_status  LIKE LINE OF status.

  CLEAR wa_sf0030.
  CLEAR wa_sf0031.

  LOOP AT i_sf0030 INTO wa_sf0030.
    wa_sf0031-uname       = wa_sf0030-uname. "sy-uname.
    wa_sf0031-werk        = wa_sf0030-werk.
    wa_sf0031-werk_desc   = wa_sf0030-werk_desc.
    wa_sf0031-prueflos    = wa_sf0030-prueflos.
    wa_sf0031-matnr       = wa_sf0030-matnr.
    wa_sf0031-charg       = wa_sf0030-charg.
    wa_sf0031-ktextmat    = wa_sf0030-ktextmat.
    wa_sf0031-ktextlos    = wa_sf0030-ktextlos.
    wa_sf0031-stat35      = wa_sf0030-stat35.
    wa_sf0031-vcode       = wa_sf0030-vcode.
    wa_sf0031-mblnr       = wa_sf0030-mblnr.
    wa_sf0031-mjahr       = wa_sf0030-mjahr.
    wa_sf0031-bldat       = wa_sf0030-bldat.
    wa_sf0031-gebeh       = wa_sf0030-gebeh.
*    wa_sf0031-losmenge    = wa_sf0030-losmenge / lv_times.
    wa_sf0031-mengeneinh  = wa_sf0030-mengeneinh.
    wa_sf0031-qndat       = wa_sf0030-qndat.
    wa_sf0031-licha       = wa_sf0030-licha.
    wa_sf0031-atwrt       = wa_sf0030-atwrt.
    wa_sf0031-lifnr       = wa_sf0030-lifnr.
    wa_sf0031-vfdat       = wa_sf0030-vfdat.
    wa_sf0031-lifnr_desc  = wa_sf0030-lifnr_desc.
    wa_sf0031-vbewertung  = wa_sf0030-vbewertung.
    wa_sf0031-vdatum      = wa_sf0030-vdatum.
    wa_sf0031-lmenge01    = wa_sf0030-lmenge01.
    wa_sf0031-lmenge04    = wa_sf0030-lmenge04.
    wa_sf0031-mtart       = gv_mtart.
    wa_sf0031-lagortchrg  = wa_sf0030-lagortchrg.

    wa_sf0031-lgnum       = wa_sf0030-lgnum.
    wa_sf0031-ltkze       = wa_sf0030-ltkze.

    wa_sf0031-tbtxt       = gv_tbtxt.

    LOOP AT t_qprs INTO ls_qprs WHERE matnr = wa_sf0030-matnr.
      CALL FUNCTION 'STATUS_READ'
        EXPORTING
          objnr            = ls_qprs-objnr
          only_active      = 'X'
        TABLES
          status           = status
        EXCEPTIONS
          object_not_found = 1
          OTHERS           = 2.

      READ TABLE status INTO ls_status WITH KEY stat = 'I0076'.
      IF sy-subrc = 0.
        DELETE TABLE t_qprs FROM ls_qprs.
        CONTINUE.
      ENDIF.

      IF ls_qprs-meinh <> wa_sf0030-mengeneinh.
        PERFORM f_modify_qty USING wa_sf0030-matnr
                             CHANGING ls_qprs-menge ls_qprs-meinh.
        MODIFY TABLE t_qprs FROM ls_qprs.
      ENDIF.
      CLEAR ls_qprs.
    ENDLOOP.

    CLEAR lv_count.

    CASE gv_mtart.
      WHEN 'ZRM' OR 'ZPM'.
        PERFORM f_calculate_quantity USING 'PAL' wa_sf0030-lmengeist
                                     CHANGING lv_sisa lv_times lv_menge.

        lv_times  = wa_sf0030-anzgeb.

        IF wa_sf0030-gebeh NE 'ROL' AND wa_sf0030-gebeh IS NOT INITIAL.
          lv_x = SQRT( lv_times ) + 1.
          CALL FUNCTION 'ROUND'
            EXPORTING
              input         = lv_x
              sign          = '+'
            IMPORTING
              output        = lv_y
            EXCEPTIONS
              input_invalid = 1
              overflow      = 2
              type_invalid  = 3
              OTHERS        = 4.

          lv_div  = wa_sf0030-lmenge03 DIV lv_y.
          lv_mod  = wa_sf0030-lmenge03 MOD lv_y.
          DO lv_y TIMES.
            ADD 1 TO lv_count.
            CASE gv_mtart.
              WHEN 'ZPM'.
                IF lv_count <= lv_mod.
                  ls_1-x  = lv_div + 1.
                ELSE.
                  ls_1-x  = lv_div.
                ENDIF.
              WHEN 'ZRM'.
*                IF lv_count <= lv_mod.
                IF lv_count < lv_mod.
                  ls_1-x  = lv_div + 1.
                ELSE.
                  ls_1-x  = lv_div.
                ENDIF.
            ENDCASE.
            APPEND ls_1 TO lt_1.
            CLEAR ls_1.
          ENDDO.
          SORT lt_1 BY x.
          lv_z = lv_times - lv_y.
        ELSEIF gv_mtart = 'ZPM' AND
          wa_sf0030-gebeh = 'ROL'.
          DESCRIBE TABLE t_qapp LINES lv_y.
          lv_x    = wa_sf0030-lmenge03 / lv_y.
          DO lv_y TIMES.
            ls_1-x  = lv_x.
            APPEND ls_1 TO lt_1.
            CLEAR ls_1.
          ENDDO.
          SORT lt_1 BY x.
          lv_z = lv_times - lv_y.
        ENDIF.

      WHEN OTHERS.
        PERFORM f_calculate_quantity USING 'PAL' wa_sf0030-lmengeist
                                     CHANGING lv_sisa lv_times lv_menge.
    ENDCASE.

    IF wa_sf0030-werk = '0101' OR
      wa_sf0030-werk = '0102'.
      PERFORM f_get_kemasan USING wa_sf0030-vbewertung wa_sf0030-mengeneinh
                                  wa_sf0030-anzgeb wa_sf0030-lmengeist
                                  wa_sf0030-lmenge01 wa_sf0030-lmenge04
                                  wa_sf0030-gebeh
                            CHANGING lv_times wa_sf0031-qtypr lv_kemas.

      PERFORM f_ex_sample USING wa_sf0030-lmenge03 pa_wadah lv_kemas
                                wa_sf0030-mengeneinh
                          CHANGING wa_sf0031-qexsmpl.
    ENDIF.

    CLEAR lv_count.

    IF lv_times IS INITIAL.
      lv_times = '1'.
    ENDIF.

    DESCRIBE TABLE t_qprs LINES lv_sample.
    lv_sample = lv_times - lv_sample.

    DO lv_times TIMES.
      ADD 1 TO lv_count.
      lv_tt = lv_times.
      CONDENSE lv_tt.
      lv_ct = lv_count.
      CONDENSE lv_ct.

      CONCATENATE lv_ct '/' lv_tt INTO wa_sf0031-jumlah.
      CONDENSE wa_sf0031-jumlah NO-GAPS.
      wa_sf0031-pallet   = lv_ct.
      CONDENSE wa_sf0031-pallet NO-GAPS.

      CASE gv_mtart.
        WHEN 'ZRM' OR 'ZPM' OR 'ZSFG'.
          CLEAR lv_flstr.
          READ TABLE t_ausp INTO ls_ausp INDEX 1.
          IF sy-subrc = 0.
            CALL FUNCTION 'FLTP_CHAR_CONVERSION'
              EXPORTING
                input  = ls_ausp-atflv
*Begin remark Unicode conversion - DEVK966143
*24.03.2020 - SOL_FELIX
*               ivalue = 'X'
*End remark Unicode conversion - DEVK966143
*Begin insert Unicode conversion - DEVK966143
*24.03.2020 - SOL_FELIX
                ivalu = 'X'
*End insert Unicode conversion - DEVK966143
                decim  = 3
              IMPORTING
                flstr  = lv_flstr.
            TRANSLATE lv_flstr USING ',.'.
            CONDENSE lv_flstr NO-GAPS.
            lv_kemasan  = lv_flstr.
          ELSE.
            READ TABLE t_marm INTO ls_marm WITH KEY meinh = wa_sf0030-gebeh.
            IF sy-subrc = 0.
              lv_kemasan  = ls_marm-umrez / ls_marm-umren.
            ELSE.
              IF wa_sf0030-anzgeb IS NOT INITIAL.
                lv_kemasan = wa_sf0030-lmengeist / wa_sf0030-anzgeb.
              ELSE.
                gv_error   = 1.
              ENDIF.
            ENDIF.
          ENDIF.

          CLEAR lv_subrc.
          IF wa_sf0030-matnr = 'R0357' AND
            wa_sf0030-werk = '0401'.
            READ TABLE t_plko INTO ls_plko
                              WITH KEY plnnr = wa_sf0030-plnnr
                                       plnal = wa_sf0030-plnal.
            IF sy-subrc = 0.
              IF ls_plko-vagrp = '1'.
                IF lv_count = lv_times.
                  lv_sisa = wa_sf0030-lmengeist MOD lv_kemasan.
                  IF lv_sisa IS NOT INITIAL.
                    lv_kemasan = lv_sisa.
                  ENDIF.
                ENDIF.
                lv_kemasan = lv_kemasan - wa_sf0030-lmenge03 / wa_sf0030-anzgeb.
                lv_subrc = 4.
              ENDIF.
            ENDIF.
          ENDIF.

          IF lv_subrc IS INITIAL AND gv_error IS INITIAL.
            CASE gv_mtart.
              WHEN 'ZRM'.
                IF pa_werk = '0401'.
                  PERFORM f_hitung_kemasan USING wa_sf0030-lmengeist wa_sf0030-anzgeb
                                                 lv_count lv_sample lv_times
                                           CHANGING lv_sisa lv_kemasan.
                ENDIF.

              WHEN 'ZPM'.
                IF wa_sf0030-gebeh = 'ROL'.
                  IF lv_count > lv_z.
                    IF lt_1[] IS NOT INITIAL.
                      CLEAR ls_1.
                      READ TABLE lt_1 INTO ls_1 INDEX 1.
                      IF sy-subrc = 0.
                        lv_kemasan  = lv_kemasan - ls_1-x.
                        DELETE lt_1 INDEX 1.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ELSE.
                  IF lv_count > lv_z.
                    IF lt_1[] IS NOT INITIAL.
                      CLEAR ls_1.
                      READ TABLE lt_1 INTO ls_1 INDEX 1.
                      IF sy-subrc = 0.
                        lv_kemasan  = lv_kemasan - ls_1-x.
                        DELETE lt_1 INDEX 1.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              WHEN OTHERS.
            ENDCASE.
          ENDIF.
      ENDCASE.

      wa_sf0031-losmenge =  wa_sf0030-losmenge.
      wa_sf0031-lmengeist = wa_sf0030-lmengeist.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = wa_sf0031-mengeneinh
        IMPORTING
          output         = lv_meins
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

      WRITE wa_sf0031-lmengeist TO wa_sf0031-menget UNIT wa_sf0031-mengeneinh.
      CONDENSE wa_sf0031-menget NO-GAPS.

      CONCATENATE wa_sf0031-menget lv_meins INTO wa_sf0031-menget
      SEPARATED BY space.

      IF wa_sf0030-matnr = 'R0357' AND
        wa_sf0030-werk = '0401'.
        CLEAR ls_plko.
        READ TABLE t_plko INTO ls_plko
                          WITH KEY plnnr = wa_sf0030-plnnr
                                   plnal = wa_sf0030-plnal.
        IF ls_plko-qprziehver IS NOT INITIAL.
          IF lv_count > lv_z.
            IF lt_1[] IS NOT INITIAL.
              CLEAR ls_1.
              READ TABLE lt_1 INTO ls_1 INDEX 1.
              IF sy-subrc = 0.
                lv_kemasan  = lv_kemasan - ls_1-x.
                DELETE lt_1 INDEX 1.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      WRITE lv_kemasan TO wa_sf0031-kemasan UNIT wa_sf0031-mengeneinh.
      CONDENSE wa_sf0031-kemasan NO-GAPS.
      CONCATENATE wa_sf0031-kemasan lv_meins INTO wa_sf0031-kemasan
      SEPARATED BY space.

      PERFORM f_calculate_quantity USING 'KAR' wa_sf0031-lmengeist
                                   CHANGING lv_sisa lv_times lv_carton.
      WRITE lv_carton TO wa_sf0031-cartont UNIT 'KAR'.
      CONDENSE wa_sf0031-cartont NO-GAPS.
      CONCATENATE wa_sf0031-cartont 'CAR' INTO wa_sf0031-cartont
      SEPARATED BY space.

      CONCATENATE wa_sf0030-matnr wa_sf0030-charg
      INTO wa_sf0031-barcode
      SEPARATED BY ';'.

      IF wa_sf0031-vbewertung = 'R'.
        WRITE wa_sf0031-lmenge04 TO wa_sf0031-reject UNIT wa_sf0031-mengeneinh.
        CONDENSE wa_sf0031-reject NO-GAPS.
        CONCATENATE wa_sf0031-reject lv_meins INTO wa_sf0031-reject
        SEPARATED BY space.
      ENDIF.

      WRITE wa_sf0031-lmengeist TO wa_sf0031-menget UNIT wa_sf0031-mengeneinh.
      CONDENSE wa_sf0031-menget NO-GAPS.

      APPEND wa_sf0031 TO gt_30.
*      ENDDO.
    ENDDO.
  ENDLOOP.

  LOOP AT gt_30 INTO wa_sf0031.
    WRITE wa_sf0031-vfdat TO lv_vfdat DD/MM/YYYY.
    CASE gv_mtart.
      WHEN 'ZRM' OR 'ZPM'.
        CONCATENATE wa_sf0031-matnr wa_sf0031-charg
                    wa_sf0031-kemasan
        INTO wa_sf0031-barcode
        SEPARATED BY ';'.
        wa_sf0031-headln2 = 'BAGIAN PENGENDALIAN MUTU'.
      WHEN OTHERS.
        CONCATENATE wa_sf0031-matnr wa_sf0031-charg
                    lv_vfdat
        INTO wa_sf0031-barcode
        SEPARATED BY ';'.
        wa_sf0031-headln2 = 'BAGIAN PEMASTIAN MUTU'.
    ENDCASE.

    IF wa_sf0031-werk = '0401'.
      wa_sf0031-plant_name = 'PT. TNP'.
    ELSE.
      SELECT SINGLE name1
        FROM t001w
        INTO wa_sf0031-plant_name
        WHERE werks = wa_sf0031-werk.
    ENDIF.
    MODIFY gt_30 FROM wa_sf0031 TRANSPORTING barcode headln2 plant_name.
    CLEAR wa_sf0031.
  ENDLOOP.

  READ TABLE gt_30 INTO wa_sf0031 INDEX 1.
  IF wa_sf0031-werk = '0101' OR
    wa_sf0031-werk = '0102'.
*    p_tdform  = 'ZTSPQM_SF003A7QR'.
    p_tdform  = 'ZTSPQM_SF002QR '.
  ENDIF.
ENDFORM.                    " f_process_data
*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
FORM f_print_form.
  DATA : lv_funcmod     TYPE rs38l_fnam,
         lv_output_opt  TYPE ssfcompop,
         ls_qclabel     TYPE zgdqmst0030,
         ls_qclabel_tmp TYPE zgdqmst0030,
         lv_count       TYPE int4,
         lv_loop        TYPE int4,
         ls_zqmdt001    TYPE zqmdt001,
         lv_padevgrp    TYPE tsp03d,
         ls_ztspmdhazcom TYPE ztspmdhazcom,
         h(10), f(10), a(10),
         lv_hazcom      TYPE char30,
         ls_spoolids    LIKE LINE OF d_job_output_info-spoolids.

  DATA: lv_loops  TYPE int4,
        lv_mods   TYPE int4,
        lv_form   TYPE int4,
        lv_wind   TYPE int4.

  CLEAR : lv_loop, lv_count, ls_qclabel_tmp, ls_ztspmdhazcom,
          lv_hazcom,h,f,a.
  DESCRIBE TABLE gt_30 LINES lv_loop.
  READ TABLE gt_30 INTO ls_qclabel_tmp INDEX 1.

  SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_ztspmdhazcom
    FROM ztspmdhazcom WHERE matnr = ls_qclabel_tmp-matnr
                        AND werks = ls_qclabel_tmp-werk.
  IF sy-subrc = 0.
    CONCATENATE 'H =' ls_ztspmdhazcom-health INTO h SEPARATED BY space.
    CONCATENATE 'F =' ls_ztspmdhazcom-fire   INTO f SEPARATED BY space.
    CONCATENATE 'R =' ls_ztspmdhazcom-reactivity INTO a SEPARATED BY space.
    CONCATENATE h f a  INTO lv_hazcom SEPARATED BY ' ; '.
  ENDIF.

  SELECT SINGLE *
    FROM zqmdt001
    INTO CORRESPONDING FIELDS OF ls_zqmdt001
    WHERE bname = sy-uname.

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
    IF ls_zqmdt001-print_dest IS NOT INITIAL.
      lv_output_opt-tddest    = ls_zqmdt001-print_dest.
      lv_output_opt-tdnewid   = ls_zqmdt001-tdnewid.
      lv_output_opt-tdimmed   = ls_zqmdt001-tdimmed.
      lv_output_opt-tddelete  = ls_zqmdt001-tddelete.
    ELSE.
      lv_output_opt-tddest    = nast-ldest.
    ENDIF.

    IF p_tdform = 'ZTNPQM_SF004'.
      SELECT SINGLE padevgrp
        FROM tsp03d
        INTO lv_padevgrp
        WHERE padest  = lv_output_opt-tddest.
      IF lv_padevgrp = 'ZA6'.
        p_tdform = 'ZTNPQM_SF004A6'.
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
      ENDIF.
    ENDIF.

    CLEAR: lv_loops,lv_mods,lv_form,lv_wind,lv_count.
    lv_loops = lv_loop DIV 8.
    lv_mods  = lv_loop MOD 8.

    DO lv_loops TIMES.
      CLEAR: lv_wind,ls_qclabel.

      ADD 1 TO lv_form.
      MOVE-CORRESPONDING ls_qclabel_tmp TO ls_qclabel.
      ls_qclabel-hazcom = lv_hazcom.

      DO 8 TIMES.
        ADD 1 TO lv_wind.
        ADD 1 TO lv_count.

        IF lv_count = 1.
          lv_output_opt-tdnewid   = 'X'.
        ENDIF.

        IF lv_count = lv_loop.
          d_ctrl_param-no_close  = space.
        ELSE.
          d_ctrl_param-no_close  = 'X'.
        ENDIF.

        PERFORM f_get_label_8 USING lv_loop
                                    lv_loops
                                    lv_mods
                                    lv_form
                                    lv_wind
                                    lv_count
                              CHANGING ls_qclabel.

        IF lv_wind = 8.
          CALL FUNCTION lv_funcmod
            EXPORTING
              control_parameters = d_ctrl_param
              output_options     = lv_output_opt
              user_settings      = space
              wa_sf0030          = ls_qclabel
            IMPORTING
              job_output_info    = d_job_output_info.

          d_ctrl_param-no_open = 'X'.
        ENDIF.
      ENDDO.
    ENDDO.

    IF lv_mods IS NOT INITIAL.
      ADD 1 TO lv_loops.
      ADD 1 TO lv_form.

      CLEAR: lv_wind,ls_qclabel.
      MOVE-CORRESPONDING ls_qclabel_tmp TO ls_qclabel.
      ls_qclabel-hazcom = lv_hazcom.

      DO lv_mods TIMES.
        ADD 1 TO lv_wind.
        ADD 1 TO lv_count.

        IF lv_count = 1.
          lv_output_opt-tdnewid   = 'X'.
        ENDIF.

        IF lv_count = lv_loop.
          d_ctrl_param-no_close  = space.
        ELSE.
          d_ctrl_param-no_close  = 'X'.
        ENDIF.

        PERFORM f_get_label_8 USING lv_loop
                                    lv_loops
                                    lv_mods
                                    lv_form
                                    lv_wind
                                    lv_count
                              CHANGING ls_qclabel.

        IF lv_wind = lv_mods.
          CALL FUNCTION lv_funcmod
            EXPORTING
              control_parameters = d_ctrl_param
              output_options     = lv_output_opt
              user_settings      = space
              wa_sf0030          = ls_qclabel
            IMPORTING
              job_output_info    = d_job_output_info.

          d_ctrl_param-no_open = 'X'.
        ENDIF.
      ENDDO.
    ENDIF.

*    LOOP AT gt_30 INTO ls_qclabel.
*      ADD 1 TO lv_count.
*
*      IF lv_count = 1.
*        lv_output_opt-tdnewid   = 'X'.
*      ENDIF.
*
*      IF lv_count = lv_loop.
*        d_ctrl_param-no_close  = space.
*      ELSE.
*        d_ctrl_param-no_close  = 'X'.
*      ENDIF.
*
*      IF lv_count <= pa_wadah.
*        ls_qclabel-wadah  = 'X'.
*        IF ls_qclabel-werk = '0101' OR
*          ls_qclabel-werk = '0102'.
*          CONCATENATE ls_qclabel-matnr ls_qclabel-charg
*                      ls_qclabel-qexsmpl ls_qclabel-jumlah
*          INTO ls_qclabel-barcode
*          SEPARATED BY ';'.
*        ENDIF.
*      ELSE.
*        IF ls_qclabel-werk = '0101' OR
*          ls_qclabel-werk = '0102'.
*          CONCATENATE ls_qclabel-matnr ls_qclabel-charg
*                      ls_qclabel-kemasan ls_qclabel-jumlah
*          INTO ls_qclabel-barcode
*          SEPARATED BY ';'.
*        ENDIF.
*      ENDIF.
*
*      CALL FUNCTION lv_funcmod
*        EXPORTING
*          control_parameters = d_ctrl_param
*          output_options     = lv_output_opt
*          user_settings      = space
*          wa_sf0030          = ls_qclabel
*        IMPORTING
*          job_output_info    = d_job_output_info.
*
*      d_ctrl_param-no_open = 'X'.
*    ENDLOOP.
  ENDIF.

  IF d_job_output_info-spoolids[] IS NOT INITIAL.
    PERFORM f_change_qprs.
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

ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_GET_BATCH_CLASSIFICATION
*&---------------------------------------------------------------------*
FORM f_get_batch_classification USING fu_matnr fu_werk fu_charg
                                CHANGING fc_qtyconv.
  DATA : t_val_tab    TYPE STANDARD TABLE OF api_vali,
         ls_val_tab   LIKE LINE OF t_val_tab,
         ls_30        LIKE LINE OF gt_30.

  CALL FUNCTION 'QC01_BATCH_VALUES_READ'
    EXPORTING
      i_val_matnr    = fu_matnr
      i_val_werks    = fu_werk
      i_val_charge   = fu_charg
    TABLES
      t_val_tab      = t_val_tab
    EXCEPTIONS
      no_class       = 1
      internal_error = 2
      no_values      = 3
      no_chars       = 4
      OTHERS         = 5.

  IF sy-subrc = 0.
    READ TABLE t_val_tab INTO ls_val_tab
                         WITH KEY atnam = 'QTY_CONVERSION'.
    IF sy-subrc = 0.
      CALL FUNCTION 'MOVE_CHAR_TO_NUM'
        EXPORTING
          chr             = ls_val_tab-atwtb
        IMPORTING
          num             = fc_qtyconv
        EXCEPTIONS
          convt_no_number = 1
          convt_overflow  = 2
          OTHERS          = 3.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_BATCH_CLASSIFICATION

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_QUANTITY
*&---------------------------------------------------------------------*
FORM f_calculate_quantity  USING    fu_meinh fu_menge
                           CHANGING fc_sisa fc_times fc_menge.
  DATA : ls_marm    LIKE LINE OF t_marm,
         lv_menge   TYPE p DECIMALS 4.

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
    READ TABLE t_marm INTO ls_marm WITH KEY meinh = fu_meinh.
    IF sy-subrc = 0.
      fc_sisa          = fu_menge MOD ( ls_marm-umrez / ls_marm-umren ).
      IF fc_sisa IS NOT INITIAL.
        fc_times      = ( fu_menge DIV ( ls_marm-umrez / ls_marm-umren ) ) + 1.
      ELSE.
        fc_times      = fu_menge / ( ls_marm-umrez / ls_marm-umren ).
      ENDIF.
      fc_menge  = ( ls_marm-umrez / ls_marm-umren ).
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
  DATA : lt_out     TYPE STANDARD TABLE OF zgdqmst0030,
         ls_out     LIKE LINE OF lt_out,
         ls_xout    LIKE LINE OF lt_out,
         lv_lines   TYPE i,
         lv_count   TYPE i,
         fr         TYPE i,
         to         TYPE i.

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
    DESCRIBE TABLE gt_30 LINES lv_lines.
    lv_lines  = ( lv_lines DIV 250 ) + 1.

    DO lv_lines TIMES.
      CLEAR lt_out[].
      fr = lv_count + 1.
      to = lv_count + 250.
      LOOP AT gt_30 INTO ls_out FROM fr TO to.
        ADD 1 TO lv_count.
        ls_xout = ls_out.
        APPEND ls_xout TO lt_out.
        CLEAR ls_xout.
      ENDLOOP.

      CALL FUNCTION 'ZRFC_ZTNPQM_SF002'
        DESTINATION gs_001-destination
        EXPORTING
          pi_cntrlpara = d_ctrl_param
          pi_outputopt = d_output_opt
          pi_tdsfname  = p_tdform
          pi_rspolname = gs_001-name
          pi_qclabel   = wa_sf0031
          pi_packsize  = 'X'
        TABLES
          pt_qclabel   = lt_out.
    ENDDO.
  ENDIF.
ENDFORM.                    " F_PRINT_QR_FORM

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_QTY
*&---------------------------------------------------------------------*
FORM f_modify_qty  USING    fu_matnr
                   CHANGING fc_menge fc_meinh.
  DATA : ls_marm  LIKE LINE OF t_marm.

  READ TABLE t_marm INTO ls_marm
                    WITH KEY matnr = fu_matnr
                             meinh = fc_meinh.
  IF sy-subrc = 0.
    fc_menge  = fc_menge * ls_marm-umrez / ls_marm-umren.
  ENDIF.
ENDFORM.                    " F_MODIFY_QTY

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_KEMASAN
*&---------------------------------------------------------------------*
FORM f_hitung_kemasan  USING    fu_lmengeist fu_anzgeb fu_count fu_sample
                                fu_times
                       CHANGING fc_sisa fc_kemasan.

  DATA : ls_qprs    LIKE LINE OF t_qprs.

  IF fu_count > fu_sample.
    IF fu_count = fu_times.
      fc_sisa = fu_lmengeist MOD fc_kemasan.
      fc_kemasan = fc_sisa.
    ENDIF.
    READ TABLE t_qprs INTO ls_qprs INDEX 1.
    IF fc_sisa IS INITIAL.
      fc_kemasan  = ( fu_lmengeist / fu_anzgeb ) - ls_qprs-menge.
    ELSE.
      fc_kemasan  = fc_kemasan - ls_qprs-menge.
    ENDIF.
    DELETE TABLE t_qprs FROM ls_qprs.
  ELSE.
    IF fu_count = fu_times.
      fc_sisa = fu_lmengeist MOD fc_kemasan.
      IF fc_sisa <> 0.
        fc_kemasan = fc_sisa.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_HITUNG_KEMASAN

*&---------------------------------------------------------------------*
*&      Form  F_MANUFACTURING
*&---------------------------------------------------------------------*
FORM f_manufacturing  USING    fu_value fu_cuobj_bm
                      CHANGING fc_atwrt.
  DATA lv_atinn      TYPE ausp-atinn.

  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      input  = fu_value
    IMPORTING
      output = lv_atinn.

  SELECT SINGLE atwrt
    FROM ausp
    INTO fc_atwrt
    WHERE objek = fu_cuobj_bm
      AND atinn = lv_atinn
      AND klart = '023'.
ENDFORM.                    " F_MANUFACTURING

*&---------------------------------------------------------------------*
*&      Form  F_GET_KEMASAN
*&---------------------------------------------------------------------*
FORM f_get_kemasan  USING    fu_vbewertung fu_mengeneinh fu_anzgeb fu_lmengeist
                             fu_lmenge01 fu_lmenge04 fu_gebeh
                    CHANGING fc_times fc_qtypr fc_kemasan.
  DATA : ls_ausp        LIKE LINE OF t_ausp,
         ls_marm        LIKE LINE OF t_marm,
         lv_flstr(22),
         lv_kemasan     TYPE mseg-menge,
         lv_times       TYPE p DECIMALS 4,
         lv_round       TYPE p DECIMALS 0,
         lv_meins(5),
         lv_qtypr(20).

  READ TABLE t_ausp INTO ls_ausp INDEX 1.
  IF sy-subrc = 0.
    CALL FUNCTION 'FLTP_CHAR_CONVERSION'
      EXPORTING
        input = ls_ausp-atflv
        ivalu = 'X'
        decim = 3
      IMPORTING
        flstr = lv_flstr.
    TRANSLATE lv_flstr USING ',.'.
    CONDENSE lv_flstr NO-GAPS.
    lv_kemasan  = lv_flstr.
  ELSE.
    READ TABLE t_marm INTO ls_marm WITH KEY meinh = fu_gebeh.
    IF sy-subrc = 0.
      lv_kemasan  = ls_marm-umrez / ls_marm-umren.
    ELSE.
      IF fu_anzgeb IS NOT INITIAL.
        lv_kemasan = fu_lmengeist / fu_anzgeb.
      ENDIF.
    ENDIF.
  ENDIF.

  IF lv_kemasan IS NOT INITIAL.
    CASE fu_vbewertung.
      WHEN 'A'.
        lv_times  = fu_lmenge01 / lv_kemasan.
      WHEN 'R'.
        lv_times  = fu_lmenge04 / lv_kemasan.
    ENDCASE.

    CALL FUNCTION 'ROUND'
      EXPORTING
        input         = lv_times
        sign          = '+'
      IMPORTING
        output        = lv_round
      EXCEPTIONS
        input_invalid = 1
        overflow      = 2
        type_invalid  = 3
        OTHERS        = 4.

    WRITE lv_round TO lv_qtypr DECIMALS 0.
    WRITE lv_kemasan TO fc_qtypr UNIT fu_mengeneinh.
    fc_kemasan = lv_kemasan.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input          = fu_mengeneinh
      IMPORTING
        output         = lv_meins
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.

    CONDENSE fc_qtypr.
    CONDENSE lv_qtypr.
    CONCATENATE lv_qtypr '@' fc_qtypr lv_meins INTO fc_qtypr
    SEPARATED BY space.

    CALL FUNCTION 'ROUND'
      EXPORTING
        input         = lv_times
        sign          = '+'
      IMPORTING
        output        = fc_times
      EXCEPTIONS
        input_invalid = 1
        overflow      = 2
        type_invalid  = 3
        OTHERS        = 4.
  ENDIF.
ENDFORM.                    " F_GET_KEMASAN

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_QPRS
*&---------------------------------------------------------------------*
FORM f_change_qprs .
  DATA : lt_qprs    TYPE STANDARD TABLE OF qprs,
         ls_qprs    LIKE LINE OF lt_qprs.

  SELECT *
    FROM qprs
    INTO CORRESPONDING FIELDS OF TABLE lt_qprs
    WHERE plos2 IN so_pruef.

  READ TABLE lt_qprs INTO ls_qprs INDEX 1.
  IF sy-subrc = 0.
    UPDATE qprs SET ktext = pa_wadah
                WHERE phynr = ls_qprs-phynr.
  ENDIF.
ENDFORM.                    " F_CHANGE_QPRS

*&---------------------------------------------------------------------*
*&      Form  F_EX_SAMPLE
*&---------------------------------------------------------------------*
FORM f_ex_sample  USING    fu_lmenge03 fu_wadah fu_kemas fu_meins
                  CHANGING fc_qexsmpl.
  DATA : lv_kemas   TYPE mseg-menge.

  IF fu_wadah IS NOT INITIAL.
    lv_kemas  = fu_kemas - ( fu_lmenge03 / fu_wadah ).
    WRITE lv_kemas TO fc_qexsmpl UNIT fu_meins.
    CONDENSE fc_qexsmpl.
    CONCATENATE fc_qexsmpl fu_meins INTO fc_qexsmpl
    SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_EX_SAMPLE

*&---------------------------------------------------------------------*
*&      Form  F_GET_QPRS
*&---------------------------------------------------------------------*
FORM f_get_qprs  USING    fu_prueflos
                 CHANGING fc_wadah.
  DATA : lv_ktext   TYPE qprs-ktext.

  IF fu_prueflos IS NOT INITIAL.
    SELECT SINGLE ktext
      FROM qprs
      INTO lv_ktext
      WHERE plos2 = fu_prueflos.

    IF lv_ktext = '00' OR
      lv_ktext IS INITIAL.
      fc_wadah = pa_wadah.
    ELSE.
      fc_wadah = lv_ktext.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_QPRS

*&---------------------------------------------------------------------*
*&      Form  F_GET_LABEL_8
*&---------------------------------------------------------------------*
FORM f_get_label_8  USING    fu_lines
                             fu_loops
                             fu_mods
                             fu_form
                             fu_wind
                             fu_count
                    CHANGING fc_qclabel STRUCTURE zgdqmst0030.
  DATA: lv_field1   TYPE char30,
        lv_field2   TYPE char30,
        lv_field3   TYPE char30,
        lv_field4   TYPE char30,
        lv_countc   TYPE char10,
        lv_linesc   TYPE char10,
        lv_windc    TYPE char10,
        lv_s        TYPE char1,
        lv_barcode  TYPE char50,
        lv_jumlah   TYPE char20,
        lv_tempkond(100).

  FIELD-SYMBOLS: <fs_field1> TYPE ANY,
                 <fs_field2> TYPE ANY,
                 <fs_field3> TYPE ANY,
                 <fs_field4> TYPE ANY.

  lv_countc = fu_count.
  CONDENSE lv_countc.
  lv_linesc = fu_lines.
  CONDENSE lv_linesc.
  CONCATENATE lv_countc lv_linesc INTO lv_jumlah SEPARATED BY '/'.

  IF fu_count <= pa_wadah.
    fc_qclabel-wadah  = 'X'.
    IF fc_qclabel-werk = '0101' OR fc_qclabel-werk = '0102'.
      CONCATENATE fc_qclabel-matnr fc_qclabel-charg
                  fc_qclabel-qexsmpl lv_jumlah  "fc_qclabel-jumlah
      INTO fc_qclabel-barcode
      SEPARATED BY ';'.
      lv_s = 'S'.
    ENDIF.
  ELSE.
    IF fc_qclabel-werk = '0101' OR fc_qclabel-werk = '0102'.
      CONCATENATE fc_qclabel-matnr fc_qclabel-charg
                  fc_qclabel-kemasan lv_jumlah  "fc_qclabel-jumlah
      INTO fc_qclabel-barcode
      SEPARATED BY ';'.
      lv_s = ' '.
    ENDIF.
  ENDIF.

  lv_windc = fu_wind.
  CONDENSE lv_windc.
  CONCATENATE 'fc_qclabel-s'          lv_windc INTO lv_field1.
  CONCATENATE 'fc_qclabel-barcode'    lv_windc INTO lv_field2.
  CONCATENATE 'fc_qclabel-jumlah'     lv_windc INTO lv_field3.
  CONCATENATE 'fc_qclabel-tempkond'   lv_windc INTO lv_field4.

  ASSIGN (lv_field1) TO <fs_field1>.
  ASSIGN (lv_field2) TO <fs_field2>.
  ASSIGN (lv_field3) TO <fs_field3>.
  ASSIGN (lv_field4) TO <fs_field4>.

  <fs_field1> = lv_s.
  <fs_field3> = lv_jumlah.
  <fs_field2> = fc_qclabel-barcode.
  <fs_field3> = lv_jumlah.

  CASE fc_qclabel-lgnum.
    WHEN '011'.
      IF gv_tempb IS INITIAL.
        CASE fc_qclabel-ltkze.
          WHEN 'UR1' OR 'UR4'.
            gv_tempb = '03'.
          WHEN 'R3A' OR 'R3B' OR 'R3C' OR 'UR3'.
            gv_tempb = '02'.
          WHEN 'UR2' OR 'UR5'.
            gv_tempb = '01'.
        ENDCASE.
      ENDIF.

    WHEN '012'.
      IF fc_qclabel-ltkze = 'UR5'.
        CLEAR gv_tempb.
      ENDIF.

      IF gv_tempb IS INITIAL.
        CASE fc_qclabel-ltkze.
          WHEN 'R1C' OR 'UR1' OR 'UR6'.
            gv_tempb = '03'.
          WHEN 'KR2' OR 'R2C' OR 'UR2'.
            gv_tempb = '02'.
          WHEN 'UR7'.
            gv_tempb = '01'.
        ENDCASE.
      ENDIF.
  ENDCASE.

  SELECT SINGLE tbtxt
    FROM t143t
    INTO gv_tbtxt
    WHERE spras = sy-langu
      AND tempb = gv_tempb.
  IF gv_tbtxt IS NOT INITIAL.
    <fs_field4> = gv_tbtxt.
  ELSE.
    IF fc_qclabel-mtart = 'ZRM'.
      <fs_field4> = 'Cold Room (8°C-15°C)'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_LABEL_8
