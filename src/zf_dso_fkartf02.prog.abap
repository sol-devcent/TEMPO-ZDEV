*----------------------------------------------------------------------*
***INCLUDE ZF_DSO_FKARTF02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_NEW_PROSES1
*&---------------------------------------------------------------------*
FORM f_new_proses1 .
  DATA : lt_itab1 TYPE STANDARD TABLE OF ty_itab,
         ls_itab1 LIKE LINE OF lt_itab1,
         lt_itab2 TYPE STANDARD TABLE OF ty_itab,
         ls_itab2 LIKE LINE OF lt_itab2.

  DATA : lv_text(50),
         lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr.

  APPEND LINES OF i_itab TO lt_itab2.
  APPEND LINES OF i_itab3 TO lt_itab2.
  SORT lt_itab2 BY bukrs vkbur fkart.
  DELETE ADJACENT DUPLICATES FROM lt_itab2 COMPARING bukrs vkbur fkart.
  lt_itab1[] = lt_itab2[].
  SORT lt_itab1 BY bukrs vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_itab1 COMPARING bukrs vkbur.

  v_title2 = 'Day Sales Outstanding Per Branch'.
  v_current_page = 1.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Billing Type'.
  CLEAR : va_nou, va_text, wa_total, wa_subtotal.

  LOOP AT lt_itab1 INTO ls_itab1.
    SELECT SINGLE *
      FROM tvkbt
      WHERE spras EQ sy-langu
        AND vkbur EQ ls_itab1-vkbur.

    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    CONCATENATE ls_itab1-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY ' - '.
    WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    PERFORM f_write_kosong.

    CLEAR ls_itab2.
    LOOP AT lt_itab2 INTO ls_itab2 WHERE bukrs = ls_itab1-bukrs
                                     AND vkbur = ls_itab1-vkbur.
      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      CLEAR : lv_text, gt_tvfkt.
      READ TABLE gt_tvfkt WITH KEY fkart = ls_itab2-fkart.
      CONCATENATE ls_itab2-fkart gt_tvfkt-vtext
            INTO lv_text SEPARATED BY '-'.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) lv_text NO-GAP. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

      PERFORM f_calculate_data1 USING ls_itab2-bukrs ls_itab2-vkbur
                                      ls_itab2-fkart
                                CHANGING lv_avrsales lv_outstanding
                                         lv_dso.

      WRITE AT c1(w3) lv_avrsales NO-GAP. c1 = c1 + w3.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w3) lv_outstanding NO-GAP. c1 = c1 + w3.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w3) lv_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    ENDLOOP.

    wa_subtotal-avrsales = wa_subtotal-avrsales / jml_hari.

    CONCATENATE 'Sub Total' va_text INTO lv_text SEPARATED BY space.
    PERFORM f_write_subtotal USING lv_text 'Billing Type' 'X' 'X' wa_subtotal.
    CLEAR: wa_subtotal, va_nou.
  ENDLOOP.

  wa_total-avrsales = wa_total-avrsales / jml_hari.

  PERFORM f_write_total USING 'Billing Type'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_DATA1
*&---------------------------------------------------------------------*
FORM f_calculate_data1  USING    fu_bukrs fu_vkbur fu_fkart
                        CHANGING fc_avrsales fc_outstanding fc_dso.
  DATA : ls_itab    LIKE LINE OF i_itab.

  DATA : lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr,
         lv_dmbtr       TYPE p.

  CLEAR : fc_avrsales, fc_outstanding, fc_dso.

  LOOP AT i_itab INTO ls_itab WHERE bukrs = fu_bukrs
                                AND vkbur = fu_vkbur
                                AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_avrsales.
  ENDLOOP.

  CLEAR : lv_dmbtr, ls_itab.
  LOOP AT i_itab3 INTO ls_itab WHERE bukrs = fu_bukrs
                                 AND vkbur = fu_vkbur
                                 AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_outstanding.
  ENDLOOP.

  ADD lv_avrsales TO wa_subtotal-avrsales.
  ADD lv_outstanding TO wa_subtotal-outstanding.
  ADD lv_avrsales TO wa_total-avrsales.
  ADD lv_outstanding TO wa_total-outstanding.

  fc_avrsales    = lv_avrsales / jml_hari.
  fc_outstanding = lv_outstanding.
  TRY .
      fc_dso         = fc_outstanding / fc_avrsales.
    CATCH cx_sy_zerodivide.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEW_PROSES2
*&---------------------------------------------------------------------*
FORM f_new_proses2 .
  DATA : lt_itab1 TYPE STANDARD TABLE OF ty_itab,
         ls_itab1 LIKE LINE OF lt_itab1,
         lt_itab2 TYPE STANDARD TABLE OF ty_itab,
         ls_itab2 LIKE LINE OF lt_itab2,
         lt_itab3 TYPE STANDARD TABLE OF ty_itab,
         ls_itab3 LIKE LINE OF lt_itab3.

  DATA : lv_text1(50),
         lv_text2(50),
         lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr.

  APPEND LINES OF i_itab TO lt_itab3.
  APPEND LINES OF i_itab3 TO lt_itab3.
  SORT lt_itab3 BY bukrs vkbur kdgrp fkart.
  DELETE ADJACENT DUPLICATES FROM lt_itab3 COMPARING bukrs vkbur kdgrp fkart.
  lt_itab2[] = lt_itab3[].
  SORT lt_itab2 BY bukrs vkbur kdgrp.
  DELETE ADJACENT DUPLICATES FROM lt_itab2 COMPARING bukrs vkbur kdgrp.
  lt_itab1[] = lt_itab2[].
  SORT lt_itab1 BY bukrs vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_itab1 COMPARING bukrs vkbur.

  v_title2 = 'Day Sales Outstanding Per Customer Group'.
  v_current_page = 1.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Customer Group'.
  CLEAR : va_nou, va_text, wa_total, wa_subtotal.

  LOOP AT lt_itab1 INTO ls_itab1.
    SELECT SINGLE *
      FROM tvkbt
      WHERE spras EQ sy-langu
        AND vkbur EQ ls_itab1-vkbur.

    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    CONCATENATE ls_itab1-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY ' - '.
    WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w6.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    PERFORM f_write_kosong.

    CLEAR ls_itab2.
    LOOP AT lt_itab2 INTO ls_itab2 WHERE bukrs = ls_itab1-bukrs
                                     AND vkbur = ls_itab1-vkbur.
      CLEAR ls_itab3.
      LOOP AT lt_itab3 INTO ls_itab3 WHERE bukrs = ls_itab2-bukrs
                                       AND vkbur = ls_itab2-vkbur
                                       AND kdgrp = ls_itab2-kdgrp.

        ADD 1 TO va_nou.
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CLEAR : lv_text1, lv_text2, gt_tvfkt.

        SELECT SINGLE *
          FROM t151t
          WHERE spras EQ sy-langu
            AND kdgrp EQ ls_itab3-kdgrp.
        IF sy-subrc NE 0.
          t151t-ktext = 'Others'.
        ENDIF.
        CONCATENATE ls_itab3-kdgrp t151t-ktext
            INTO lv_text1 SEPARATED BY '-'.

        READ TABLE gt_tvfkt WITH KEY fkart = ls_itab3-fkart.
        CONCATENATE ls_itab3-fkart gt_tvfkt-vtext
              INTO lv_text2 SEPARATED BY '-'.
        WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w2) lv_text1 NO-GAP. c1 = c1 + w2.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w4) lv_text2 NO-GAP. c1 = c1 + w4.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

        PERFORM f_calculate_data2 USING ls_itab3-bukrs ls_itab3-vkbur
                                        ls_itab3-kdgrp ls_itab3-fkart
                                  CHANGING lv_avrsales lv_outstanding
                                           lv_dso.

        WRITE AT c1(w3) lv_avrsales NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_outstanding NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      ENDLOOP.

      wa_subtotal1-avrsales = wa_subtotal1-avrsales / jml_hari.

      PERFORM f_write_subtotal USING '      Sub Total' '' 'X' 'X' wa_subtotal1.
      CLEAR : wa_subtotal1, va_nou.
    ENDLOOP.

    wa_subtotal-avrsales = wa_subtotal-avrsales / jml_hari.

    CONCATENATE 'Sub Total' va_text INTO lv_text1 SEPARATED BY space.
    PERFORM f_write_subtotal USING lv_text1 '' 'X' '' wa_subtotal.
    CLEAR: wa_subtotal, va_nou.
  ENDLOOP.

  wa_total-avrsales = wa_total-avrsales / jml_hari.

  PERFORM f_write_total USING ''.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_DATA2
*&---------------------------------------------------------------------*
FORM f_calculate_data2  USING    fu_bukrs fu_vkbur fu_kdgrp fu_fkart
                        CHANGING fc_avrsales fc_outstanding fc_dso.
  DATA : ls_itab    LIKE LINE OF i_itab.

  DATA : lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr,
         lv_dmbtr       TYPE p.

  CLEAR : fc_avrsales, fc_outstanding, fc_dso.

  LOOP AT i_itab INTO ls_itab WHERE bukrs = fu_bukrs
                                AND vkbur = fu_vkbur
                                AND kdgrp = fu_kdgrp
                                AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_avrsales.
  ENDLOOP.

  CLEAR : lv_dmbtr, ls_itab.
  LOOP AT i_itab3 INTO ls_itab WHERE bukrs = fu_bukrs
                                 AND vkbur = fu_vkbur
                                 AND kdgrp = fu_kdgrp
                                 AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_outstanding.
  ENDLOOP.

  ADD lv_avrsales TO wa_subtotal-avrsales.
  ADD lv_outstanding TO wa_subtotal-outstanding.
  ADD lv_avrsales TO wa_subtotal1-avrsales.
  ADD lv_outstanding TO wa_subtotal1-outstanding.
  ADD lv_avrsales TO wa_total-avrsales.
  ADD lv_outstanding TO wa_total-outstanding.

  fc_avrsales    = lv_avrsales / jml_hari.
  fc_outstanding = lv_outstanding.
  TRY .
      fc_dso         = fc_outstanding / fc_avrsales.
    CATCH cx_sy_zerodivide.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEW_PROSES3
*&---------------------------------------------------------------------*
FORM f_new_proses3 .
  DATA : lt_itab1 TYPE STANDARD TABLE OF ty_itab,
         ls_itab1 LIKE LINE OF lt_itab1,
         lt_itab2 TYPE STANDARD TABLE OF ty_itab,
         ls_itab2 LIKE LINE OF lt_itab2,
         lt_itab3 TYPE STANDARD TABLE OF ty_itab,
         ls_itab3 LIKE LINE OF lt_itab3.

  DATA : lv_text1(50),
         lv_text2(50),
         lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr,
         lv_sname       TYPE pa0001-sname,
         lv_ename       TYPE pa0001-ename.

  APPEND LINES OF i_itab TO lt_itab3.
  APPEND LINES OF i_itab3 TO lt_itab3.
  SORT lt_itab3 BY bukrs vkbur xref2 fkart.
  DELETE ADJACENT DUPLICATES FROM lt_itab3 COMPARING bukrs vkbur xref2 fkart.
  lt_itab2[] = lt_itab3[].
  SORT lt_itab2 BY bukrs vkbur xref2.
  DELETE ADJACENT DUPLICATES FROM lt_itab2 COMPARING bukrs vkbur xref2.
  lt_itab1[] = lt_itab2[].
  SORT lt_itab1 BY bukrs vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_itab1 COMPARING bukrs vkbur.

  v_title2 = 'Day Sales Outstanding Per Salesman'.
  v_current_page = 1.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Salesman'.
  CLEAR : va_nou, va_text, wa_total, wa_subtotal.

  LOOP AT lt_itab1 INTO ls_itab1.
    SELECT SINGLE *
      FROM tvkbt
      WHERE spras EQ sy-langu
        AND vkbur EQ ls_itab1-vkbur.

    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    CONCATENATE ls_itab1-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY ' - '.
    WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w6.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    PERFORM f_write_kosong.

    CLEAR ls_itab2.
    LOOP AT lt_itab2 INTO ls_itab2 WHERE bukrs = ls_itab1-bukrs
                                     AND vkbur = ls_itab1-vkbur.
      CLEAR ls_itab3.
      LOOP AT lt_itab3 INTO ls_itab3 WHERE bukrs = ls_itab2-bukrs
                                       AND vkbur = ls_itab2-vkbur
                                       AND xref2 = ls_itab2-xref2.

        ADD 1 TO va_nou.
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CLEAR : lv_text1, lv_text2, gt_tvfkt.

        SELECT SINGLE sname ename
          FROM pa0001
          INTO (lv_sname, lv_ename)
          WHERE pernr EQ ls_itab3-xref2.
        IF sy-subrc NE 0.
          lv_sname = 'Others'.
          lv_ename = 'Others'.
        ENDIF.
        CONCATENATE ls_itab3-xref2 lv_sname lv_ename
            INTO lv_text1 SEPARATED BY space.

        READ TABLE gt_tvfkt WITH KEY fkart = ls_itab3-fkart.
        CONCATENATE ls_itab3-fkart gt_tvfkt-vtext
              INTO lv_text2 SEPARATED BY '-'.
        WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w2) lv_text1 NO-GAP. c1 = c1 + w2.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w4) lv_text2 NO-GAP. c1 = c1 + w4.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

        PERFORM f_calculate_data3 USING ls_itab3-bukrs ls_itab3-vkbur
                                        ls_itab3-xref2 ls_itab3-fkart
                                  CHANGING lv_avrsales lv_outstanding
                                           lv_dso.

        WRITE AT c1(w3) lv_avrsales NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_outstanding NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      ENDLOOP.

      wa_subtotal1-avrsales = wa_subtotal1-avrsales / jml_hari.

      PERFORM f_write_subtotal USING '      Sub Total' '' 'X' 'X' wa_subtotal1.
      CLEAR : wa_subtotal1, va_nou.
    ENDLOOP.

    wa_subtotal-avrsales = wa_subtotal-avrsales / jml_hari.

    CONCATENATE 'Sub Total' va_text INTO lv_text1 SEPARATED BY space.
    PERFORM f_write_subtotal USING lv_text1 '' 'X' '' wa_subtotal.
    CLEAR: wa_subtotal, va_nou.
  ENDLOOP.

  wa_total-avrsales = wa_total-avrsales / jml_hari.

  PERFORM f_write_total USING ''.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_DATA3
*&---------------------------------------------------------------------*
FORM f_calculate_data3  USING    fu_bukrs fu_vkbur fu_xref2 fu_fkart
                        CHANGING fc_avrsales fc_outstanding fc_dso.
  DATA : ls_itab    LIKE LINE OF i_itab.

  DATA : lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr,
         lv_dmbtr       TYPE p.

  CLEAR : fc_avrsales, fc_outstanding, fc_dso.

  LOOP AT i_itab INTO ls_itab WHERE bukrs = fu_bukrs
                                AND vkbur = fu_vkbur
                                AND xref2 = fu_xref2
                                AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_avrsales.
  ENDLOOP.

  CLEAR : lv_dmbtr, ls_itab.
  LOOP AT i_itab3 INTO ls_itab WHERE bukrs = fu_bukrs
                                 AND vkbur = fu_vkbur
                                 AND xref2 = fu_xref2
                                 AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_outstanding.
  ENDLOOP.

  ADD lv_avrsales TO wa_subtotal-avrsales.
  ADD lv_outstanding TO wa_subtotal-outstanding.
  ADD lv_avrsales TO wa_subtotal1-avrsales.
  ADD lv_outstanding TO wa_subtotal1-outstanding.
  ADD lv_avrsales TO wa_total-avrsales.
  ADD lv_outstanding TO wa_total-outstanding.

  fc_avrsales    = lv_avrsales / jml_hari.
  fc_outstanding = lv_outstanding.
  TRY .
      fc_dso         = fc_outstanding / fc_avrsales.
    CATCH cx_sy_zerodivide.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEW_PROSES4
*&---------------------------------------------------------------------*
FORM f_new_proses4 .
  DATA : lt_itab1 TYPE STANDARD TABLE OF ty_itab,
         ls_itab1 LIKE LINE OF lt_itab1,
         lt_itab2 TYPE STANDARD TABLE OF ty_itab,
         ls_itab2 LIKE LINE OF lt_itab2,
         lt_itab3 TYPE STANDARD TABLE OF ty_itab,
         ls_itab3 LIKE LINE OF lt_itab3.

  DATA : lv_text1(50),
         lv_text2(50),
         lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr.

  APPEND LINES OF i_itab TO lt_itab3.
  APPEND LINES OF i_itab3 TO lt_itab3.
  SORT lt_itab3 BY bukrs vkbur kunnr fkart.
  DELETE ADJACENT DUPLICATES FROM lt_itab3 COMPARING bukrs vkbur kunnr fkart.
  lt_itab2[] = lt_itab3[].
  SORT lt_itab2 BY bukrs vkbur kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_itab2 COMPARING bukrs vkbur kunnr.
  lt_itab1[] = lt_itab2[].
  SORT lt_itab1 BY bukrs vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_itab1 COMPARING bukrs vkbur.

  v_title2 = 'Day Sales Outstanding Per Customer'.
  v_current_page = 1.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Customer'.
  CLEAR : va_nou, va_text, wa_total, wa_subtotal.

  LOOP AT lt_itab1 INTO ls_itab1.
    SELECT SINGLE *
      FROM tvkbt
      WHERE spras EQ sy-langu
        AND vkbur EQ ls_itab1-vkbur.

    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    CONCATENATE ls_itab1-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY ' - '.
    WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w6.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    PERFORM f_write_kosong.

    CLEAR ls_itab2.
    LOOP AT lt_itab2 INTO ls_itab2 WHERE bukrs = ls_itab1-bukrs
                                     AND vkbur = ls_itab1-vkbur.
      CLEAR ls_itab3.
      LOOP AT lt_itab3 INTO ls_itab3 WHERE bukrs = ls_itab2-bukrs
                                       AND vkbur = ls_itab2-vkbur
                                       AND kunnr = ls_itab2-kunnr.

        ADD 1 TO va_nou.
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CLEAR : lv_text1, lv_text2, gt_tvfkt.

        SELECT SINGLE *
          FROM kna1
          WHERE spras EQ sy-langu
            AND kunnr EQ ls_itab3-kunnr.
        CONCATENATE ls_itab3-kunnr kna1-name1
            INTO lv_text1 SEPARATED BY '-'.

        READ TABLE gt_tvfkt WITH KEY fkart = ls_itab3-fkart.
        CONCATENATE ls_itab3-fkart gt_tvfkt-vtext
              INTO lv_text2 SEPARATED BY '-'.
        WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w2) lv_text1 NO-GAP. c1 = c1 + w2.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w4) lv_text2 NO-GAP. c1 = c1 + w4.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

        PERFORM f_calculate_data4 USING ls_itab3-bukrs ls_itab3-vkbur
                                        ls_itab3-kunnr ls_itab3-fkart
                                  CHANGING lv_avrsales lv_outstanding
                                           lv_dso.

        WRITE AT c1(w3) lv_avrsales NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_outstanding NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      ENDLOOP.

      wa_subtotal1-avrsales = wa_subtotal1-avrsales / jml_hari.

      PERFORM f_write_subtotal USING '      Sub Total' '' 'X' 'X' wa_subtotal1.
      CLEAR : wa_subtotal1, va_nou.
    ENDLOOP.

    wa_subtotal-avrsales = wa_subtotal-avrsales / jml_hari.

    CONCATENATE 'Sub Total' va_text INTO lv_text1 SEPARATED BY space.
    PERFORM f_write_subtotal USING lv_text1 '' 'X' '' wa_subtotal.
    CLEAR: wa_subtotal, va_nou.
  ENDLOOP.

  wa_total-avrsales = wa_total-avrsales / jml_hari.

  PERFORM f_write_total USING ''.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_DATA4
*&---------------------------------------------------------------------*
FORM f_calculate_data4  USING    fu_bukrs fu_vkbur fu_kunnr fu_fkart
                        CHANGING fc_avrsales fc_outstanding fc_dso.
  DATA : ls_itab    LIKE LINE OF i_itab.

  DATA : lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr,
         lv_dmbtr       TYPE p.

  CLEAR : fc_avrsales, fc_outstanding, fc_dso.

  LOOP AT i_itab INTO ls_itab WHERE bukrs = fu_bukrs
                                AND vkbur = fu_vkbur
                                AND kunnr = fu_kunnr
                                AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_avrsales.
  ENDLOOP.

  CLEAR : lv_dmbtr, ls_itab.
  LOOP AT i_itab3 INTO ls_itab WHERE bukrs = fu_bukrs
                                 AND vkbur = fu_vkbur
                                 AND kunnr = fu_kunnr
                                 AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_outstanding.
  ENDLOOP.

  ADD lv_avrsales TO wa_subtotal-avrsales.
  ADD lv_outstanding TO wa_subtotal-outstanding.
  ADD lv_avrsales TO wa_subtotal1-avrsales.
  ADD lv_outstanding TO wa_subtotal1-outstanding.
  ADD lv_avrsales TO wa_total-avrsales.
  ADD lv_outstanding TO wa_total-outstanding.

  fc_avrsales    = lv_avrsales / jml_hari.
  fc_outstanding = lv_outstanding.
  TRY .
      fc_dso         = fc_outstanding / fc_avrsales.
    CATCH cx_sy_zerodivide.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEW_PROSES5
*&---------------------------------------------------------------------*
FORM f_new_proses5 .
  DATA : lt_itab1 TYPE STANDARD TABLE OF ty_itab,
         ls_itab1 LIKE LINE OF lt_itab1,
         lt_itab2 TYPE STANDARD TABLE OF ty_itab,
         ls_itab2 LIKE LINE OF lt_itab2,
         lt_itab3 TYPE STANDARD TABLE OF ty_itab,
         ls_itab3 LIKE LINE OF lt_itab3.

  DATA : lv_text1(50),
         lv_text2(50),
         lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr.

  APPEND LINES OF i_itab TO lt_itab3.
  APPEND LINES OF i_itab3 TO lt_itab3.
  SORT lt_itab3 BY bukrs vkbur brsch fkart.
  DELETE ADJACENT DUPLICATES FROM lt_itab3 COMPARING bukrs vkbur brsch fkart.
  lt_itab2[] = lt_itab3[].
  SORT lt_itab2 BY bukrs vkbur brsch.
  DELETE ADJACENT DUPLICATES FROM lt_itab2 COMPARING bukrs vkbur brsch.
  lt_itab1[] = lt_itab2[].
  SORT lt_itab1 BY bukrs vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_itab1 COMPARING bukrs vkbur.

  v_title2 = 'Day Sales Outstanding Per Industry Code'.
  v_current_page = 1.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Industry Code'.
  CLEAR : va_nou, va_text, wa_total, wa_subtotal.

  LOOP AT lt_itab1 INTO ls_itab1.
    SELECT SINGLE *
      FROM tvkbt
      WHERE spras EQ sy-langu
        AND vkbur EQ ls_itab1-vkbur.

    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    CONCATENATE ls_itab1-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY ' - '.
    WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w6.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    PERFORM f_write_kosong.

    CLEAR ls_itab2.
    LOOP AT lt_itab2 INTO ls_itab2 WHERE bukrs = ls_itab1-bukrs
                                     AND vkbur = ls_itab1-vkbur.
      CLEAR ls_itab3.
      LOOP AT lt_itab3 INTO ls_itab3 WHERE bukrs = ls_itab2-bukrs
                                       AND vkbur = ls_itab2-vkbur
                                       AND brsch = ls_itab2-brsch.

        ADD 1 TO va_nou.
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CLEAR : lv_text1, lv_text2, gt_tvfkt.

        SELECT SINGLE *
          FROM t016t
          WHERE spras EQ sy-langu
            AND brsch EQ ls_itab3-brsch.
        IF sy-subrc NE 0.
          t016t-brtxt = 'Others'.
        ENDIF.
        CONCATENATE ls_itab3-brsch t016t-brtxt
            INTO lv_text1 SEPARATED BY '-'.

        READ TABLE gt_tvfkt WITH KEY fkart = ls_itab3-fkart.
        CONCATENATE ls_itab3-fkart gt_tvfkt-vtext
              INTO lv_text2 SEPARATED BY '-'.
        WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w2) lv_text1 NO-GAP. c1 = c1 + w2.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w4) lv_text2 NO-GAP. c1 = c1 + w4.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

        PERFORM f_calculate_data5 USING ls_itab3-bukrs ls_itab3-vkbur
                                        ls_itab3-brsch ls_itab3-fkart
                                  CHANGING lv_avrsales lv_outstanding
                                           lv_dso.

        WRITE AT c1(w3) lv_avrsales NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_outstanding NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      ENDLOOP.

      wa_subtotal1-avrsales = wa_subtotal1-avrsales / jml_hari.

      PERFORM f_write_subtotal USING '      Sub Total' '' 'X' 'X' wa_subtotal1.
      CLEAR : wa_subtotal1, va_nou.
    ENDLOOP.

    wa_subtotal-avrsales = wa_subtotal-avrsales / jml_hari.

    CONCATENATE 'Sub Total' va_text INTO lv_text1 SEPARATED BY space.
    PERFORM f_write_subtotal USING lv_text1 '' 'X' '' wa_subtotal.
    CLEAR: wa_subtotal, va_nou.
  ENDLOOP.

  wa_total-avrsales = wa_total-avrsales / jml_hari.

  PERFORM f_write_total USING ''.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_DATA5
*&---------------------------------------------------------------------*
FORM f_calculate_data5  USING    fu_bukrs fu_vkbur fu_brsch fu_fkart
                        CHANGING fc_avrsales fc_outstanding fc_dso.
  DATA : ls_itab    LIKE LINE OF i_itab.

  DATA : lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr,
         lv_dmbtr       TYPE p.

  CLEAR : fc_avrsales, fc_outstanding, fc_dso.

  LOOP AT i_itab INTO ls_itab WHERE bukrs = fu_bukrs
                                AND vkbur = fu_vkbur
                                AND brsch = fu_brsch
                                AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_avrsales.
  ENDLOOP.

  CLEAR : lv_dmbtr, ls_itab.
  LOOP AT i_itab3 INTO ls_itab WHERE bukrs = fu_bukrs
                                 AND vkbur = fu_vkbur
                                 AND brsch = fu_brsch
                                 AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_outstanding.
  ENDLOOP.

  ADD lv_avrsales TO wa_subtotal-avrsales.
  ADD lv_outstanding TO wa_subtotal-outstanding.
  ADD lv_avrsales TO wa_subtotal1-avrsales.
  ADD lv_outstanding TO wa_subtotal1-outstanding.
  ADD lv_avrsales TO wa_total-avrsales.
  ADD lv_outstanding TO wa_total-outstanding.

  fc_avrsales    = lv_avrsales / jml_hari.
  fc_outstanding = lv_outstanding.
  TRY .
      fc_dso         = fc_outstanding / fc_avrsales.
    CATCH cx_sy_zerodivide.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEW_PROSES6
*&---------------------------------------------------------------------*
FORM f_new_proses6 .
  DATA : lt_itab1 TYPE STANDARD TABLE OF ty_itab,
         ls_itab1 LIKE LINE OF lt_itab1,
         lt_itab2 TYPE STANDARD TABLE OF ty_itab,
         ls_itab2 LIKE LINE OF lt_itab2.

  DATA : lv_text1(50),
         lv_text2(50),
         lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr.

  APPEND LINES OF i_itab TO lt_itab2.
  APPEND LINES OF i_itab3 TO lt_itab2.
  SORT lt_itab2 BY bukrs kdgrp fkart.
  DELETE ADJACENT DUPLICATES FROM lt_itab2 COMPARING bukrs kdgrp fkart.
  lt_itab1[] = lt_itab2[].
  SORT lt_itab1 BY bukrs kdgrp.
  DELETE ADJACENT DUPLICATES FROM lt_itab1 COMPARING bukrs kdgrp.

  v_title2 = 'Day Sales Outstanding Per Customer Group Nasional'.
  v_current_page = 1.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Customer Group'.
  CLEAR : va_nou, va_text, wa_total, wa_subtotal.

  LOOP AT lt_itab1 INTO ls_itab1.
    CLEAR ls_itab2.
    LOOP AT lt_itab2 INTO ls_itab2 WHERE bukrs = ls_itab1-bukrs
                                     AND kdgrp = ls_itab1-kdgrp.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      CLEAR : lv_text1, lv_text2, gt_tvfkt.

      SELECT SINGLE *
        FROM t151t
        WHERE spras EQ sy-langu
          AND kdgrp EQ ls_itab2-kdgrp.
      IF sy-subrc NE 0.
        t151t-ktext = 'Others'.
      ENDIF.
      CONCATENATE ls_itab2-kdgrp t151t-ktext
          INTO lv_text1 SEPARATED BY '-'.

      READ TABLE gt_tvfkt WITH KEY fkart = ls_itab2-fkart.
      CONCATENATE ls_itab2-fkart gt_tvfkt-vtext
            INTO lv_text2 SEPARATED BY '-'.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) lv_text1 NO-GAP. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w4) lv_text2 NO-GAP. c1 = c1 + w4.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

      PERFORM f_calculate_data6 USING ls_itab2-bukrs ls_itab2-kdgrp ls_itab2-fkart
                                CHANGING lv_avrsales lv_outstanding
                                         lv_dso.

      WRITE AT c1(w3) lv_avrsales NO-GAP. c1 = c1 + w3.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w3) lv_outstanding NO-GAP. c1 = c1 + w3.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w3) lv_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    ENDLOOP.

    wa_subtotal-avrsales = wa_subtotal-avrsales / jml_hari.

    CONCATENATE 'Sub Total' va_text INTO lv_text1 SEPARATED BY space.
    PERFORM f_write_subtotal USING lv_text1 '' 'X' 'X' wa_subtotal.
    CLEAR: wa_subtotal, va_nou.
  ENDLOOP.

  wa_total-avrsales = wa_total-avrsales / jml_hari.

  PERFORM f_write_total USING ''.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_DATA6
*&---------------------------------------------------------------------*
FORM f_calculate_data6  USING    fu_bukrs fu_kdgrp fu_fkart
                        CHANGING fc_avrsales fc_outstanding fc_dso.
  DATA : ls_itab    LIKE LINE OF i_itab.

  DATA : lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr,
         lv_dmbtr       TYPE p.

  CLEAR : fc_avrsales, fc_outstanding, fc_dso.

  LOOP AT i_itab INTO ls_itab WHERE bukrs = fu_bukrs
                                AND kdgrp = fu_kdgrp
                                AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_avrsales.
  ENDLOOP.

  CLEAR : lv_dmbtr, ls_itab.
  LOOP AT i_itab3 INTO ls_itab WHERE bukrs = fu_bukrs
                                 AND kdgrp = fu_kdgrp
                                 AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_outstanding.
  ENDLOOP.

  ADD lv_avrsales TO wa_subtotal-avrsales.
  ADD lv_outstanding TO wa_subtotal-outstanding.
  ADD lv_avrsales TO wa_subtotal1-avrsales.
  ADD lv_outstanding TO wa_subtotal1-outstanding.
  ADD lv_avrsales TO wa_total-avrsales.
  ADD lv_outstanding TO wa_total-outstanding.

  fc_avrsales    = lv_avrsales / jml_hari.
  fc_outstanding = lv_outstanding.
  TRY .
      fc_dso         = fc_outstanding / fc_avrsales.
    CATCH cx_sy_zerodivide.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEW_PROSES9
*&---------------------------------------------------------------------*
FORM f_new_proses9 .
  DATA : lt_itab1 TYPE STANDARD TABLE OF ty_itab,
         ls_itab1 LIKE LINE OF lt_itab1.

  DATA : lv_text(50),
         lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr.

  APPEND LINES OF i_itab TO lt_itab1.
  APPEND LINES OF i_itab3 TO lt_itab1.
  SORT lt_itab1 BY bukrs fkart.
  DELETE ADJACENT DUPLICATES FROM lt_itab1 COMPARING bukrs fkart.

  v_title2 = 'Day Sales Outstanding Per Billing Type Nasional'.
  v_current_page = 1.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Billing Type'.
  CLEAR : va_nou, va_text, wa_total, wa_subtotal.

  LOOP AT lt_itab1 INTO ls_itab1.
    ADD 1 TO va_nou.
    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    CLEAR : lv_text, gt_tvfkt.
    READ TABLE gt_tvfkt WITH KEY fkart = ls_itab1-fkart.
    CONCATENATE ls_itab1-fkart gt_tvfkt-vtext
          INTO lv_text SEPARATED BY '-'.
    WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w2) lv_text NO-GAP. c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

    PERFORM f_calculate_data9 USING ls_itab1-bukrs ls_itab1-fkart
                              CHANGING lv_avrsales lv_outstanding
                                       lv_dso.

    WRITE AT c1(w3) lv_avrsales NO-GAP. c1 = c1 + w3.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w3) lv_outstanding NO-GAP. c1 = c1 + w3.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w3) lv_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  ENDLOOP.

  wa_total-avrsales = wa_total-avrsales / jml_hari.

  PERFORM f_write_total USING 'Billing Type'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_DATA9
*&---------------------------------------------------------------------*
FORM f_calculate_data9  USING    fu_bukrs fu_fkart
                        CHANGING fc_avrsales fc_outstanding fc_dso.
  DATA : ls_itab    LIKE LINE OF i_itab.

  DATA : lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr,
         lv_dmbtr       TYPE p.

  CLEAR : fc_avrsales, fc_outstanding, fc_dso.

  LOOP AT i_itab INTO ls_itab WHERE bukrs = fu_bukrs
                                AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_avrsales.
  ENDLOOP.

  CLEAR : lv_dmbtr, ls_itab.
  LOOP AT i_itab3 INTO ls_itab WHERE bukrs = fu_bukrs
                                 AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_outstanding.
  ENDLOOP.

  ADD lv_avrsales TO wa_subtotal-avrsales.
  ADD lv_outstanding TO wa_subtotal-outstanding.
  ADD lv_avrsales TO wa_subtotal1-avrsales.
  ADD lv_outstanding TO wa_subtotal1-outstanding.
  ADD lv_avrsales TO wa_total-avrsales.
  ADD lv_outstanding TO wa_total-outstanding.

  fc_avrsales    = lv_avrsales / jml_hari.
  fc_outstanding = lv_outstanding.
  TRY .
      fc_dso         = fc_outstanding / fc_avrsales.
    CATCH cx_sy_zerodivide.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEW_PROSES7
*&---------------------------------------------------------------------*
FORM f_new_proses7 .
  DATA : lt_itab1 TYPE STANDARD TABLE OF ty_itab,
         lt_itab2 TYPE STANDARD TABLE OF ty_itab,
         ls_itab1 LIKE LINE OF lt_itab1.

  APPEND LINES OF i_itab TO lt_itab2.
  APPEND LINES OF i_itab3 TO lt_itab2.
  lt_itab1[] = lt_itab2[].
  SORT lt_itab1 BY bukrs vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_itab1 COMPARING bukrs vkbur.

  v_title2 = 'Day Sales Outstanding Per Channel'.
  v_current_page = 1.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Channel'.
  CLEAR : va_nou, va_text, wa_total, wa_subtotal.

  LOOP AT lt_itab1 INTO ls_itab1.
    SELECT SINGLE *
      FROM tvkbt
      WHERE spras EQ sy-langu
        AND vkbur EQ ls_itab1-vkbur.

    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    CONCATENATE ls_itab1-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY ' - '.
    WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w6.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    PERFORM f_write_kosong.

    IF va_channel IS INITIAL.
      PERFORM f_proses7_kdgrp TABLES lt_itab2
                              USING ls_itab1.
    ELSE.
      PERFORM f_proses7_brsch TABLES lt_itab2
                              USING ls_itab1.
    ENDIF.
  ENDLOOP.

  wa_total-avrsales = wa_total-avrsales / jml_hari.

  PERFORM f_write_total USING ''.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES7_KDGRP
*&---------------------------------------------------------------------*
FORM f_proses7_kdgrp  TABLES   ft_itab  LIKE i_itab
                      USING    fs_itab  TYPE ty_itab.
  DATA : lt_itab1 TYPE STANDARD TABLE OF ty_itab,
         ls_itab1 LIKE LINE OF lt_itab1.

  DATA : lt_channel1 TYPE STANDARD TABLE OF zfchanel,
         ls_channel1 LIKE LINE OF lt_channel1,
         lt_channel2 TYPE STANDARD TABLE OF zfchanel,
         ls_channel2 LIKE LINE OF lt_channel2.

  DATA : lv_text1(50),
         lv_text2(50),
         lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr.

  lt_itab1[] = ft_itab[].
  SORT lt_itab1 BY bukrs vkbur channel kdgrp fkart.
  DELETE ADJACENT DUPLICATES FROM lt_itab1 COMPARING bukrs vkbur channel kdgrp fkart.

  lt_channel2[] = i_zfchanel[].
  LOOP AT lt_itab1 INTO ls_itab1.
    MOVE-CORRESPONDING ls_itab1 TO ls_channel2.
    APPEND ls_channel2 TO lt_channel2.
    CLEAR ls_channel2.
  ENDLOOP.
  SORT lt_channel2 BY bukrs vkbur channel kdgrp.
  DELETE ADJACENT DUPLICATES FROM lt_channel2 COMPARING bukrs vkbur channel kdgrp.
  lt_channel1[] = lt_channel2[].
  DELETE ADJACENT DUPLICATES FROM lt_channel1 COMPARING bukrs vkbur channel.

  LOOP AT lt_channel1 INTO ls_channel1 WHERE vkbur = fs_itab-vkbur.
    LOOP AT lt_channel2 INTO ls_channel2 WHERE vkbur   = ls_channel1-vkbur
                                           AND channel = ls_channel1-channel.
      SELECT SINGLE *
        FROM t151t
        WHERE spras EQ sy-langu
          AND kdgrp EQ ls_channel2-kdgrp.
      IF sy-subrc NE 0.
        t151t-ktext = 'Others'.
      ENDIF.
      CONCATENATE ls_channel2-kdgrp t151t-ktext
          INTO lv_text1 SEPARATED BY '-'.

      CLEAR ls_itab1.
      READ TABLE lt_itab1 INTO ls_itab1
                          WITH KEY vkbur   = ls_channel2-vkbur
                                   channel = ls_channel2-channel
                                   kdgrp   = ls_channel2-kdgrp
                          TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        LOOP AT lt_itab1 INTO ls_itab1 WHERE vkbur   = ls_channel2-vkbur
                                         AND channel = ls_channel2-channel
                                         AND kdgrp   = ls_channel2-kdgrp.
          ADD 1 TO va_nou.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          CLEAR : lv_text1, lv_text2, gt_tvfkt.

          CONCATENATE ls_channel2-kdgrp t151t-ktext
              INTO lv_text1 SEPARATED BY '-'.
          CONCATENATE ls_channel2-channel lv_text1 INTO lv_text1
          SEPARATED BY space.
          READ TABLE gt_tvfkt WITH KEY fkart = ls_itab1-fkart.
          CONCATENATE ls_itab1-fkart gt_tvfkt-vtext
                INTO lv_text2 SEPARATED BY '-'.
          WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) lv_text1 NO-GAP. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w4) lv_text2 NO-GAP. c1 = c1 + w4.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

          PERFORM f_calculate_data7 USING ls_itab1-bukrs ls_itab1-vkbur ls_itab1-channel
                                          ls_itab1-kdgrp '' ls_itab1-fkart 'KDGRP'
                                    CHANGING lv_avrsales lv_outstanding
                                             lv_dso.

          WRITE AT c1(w3) lv_avrsales NO-GAP. c1 = c1 + w3.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w3) lv_outstanding NO-GAP. c1 = c1 + w3.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w3) lv_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        ENDLOOP.
      ELSE.
        ADD 1 TO va_nou.
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CLEAR : lv_text1, lv_text2, gt_tvfkt,
                lv_avrsales, lv_outstanding, lv_dso.
        CONCATENATE ls_channel2-kdgrp t151t-ktext
            INTO lv_text1 SEPARATED BY '-'.
        CONCATENATE ls_channel2-channel lv_text1 INTO lv_text1
        SEPARATED BY space.
        WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w2) lv_text1 NO-GAP. c1 = c1 + w2.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w4) lv_text2 NO-GAP. c1 = c1 + w4.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_avrsales NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_outstanding NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      ENDIF.

      wa_subtotal2-avrsales = wa_subtotal2-avrsales / jml_hari.

      CONCATENATE 'Sub Total' ls_channel2-channel ls_channel2-kdgrp t151t-ktext
      INTO lv_text1 SEPARATED BY space.
      PERFORM f_write_subtotal USING lv_text1 '' '' 'X' wa_subtotal2.
      PERFORM f_write_kosong1.
      CLEAR: wa_subtotal2, va_nou.
    ENDLOOP.

    wa_subtotal1-avrsales = wa_subtotal1-avrsales / jml_hari.

    CONCATENATE 'Sub Total' ls_channel1-channel INTO lv_text1 SEPARATED BY space.
    PERFORM f_write_subtotal USING lv_text1 '' '' 'X' wa_subtotal1.
    PERFORM f_write_kosong1.
    CLEAR: wa_subtotal1, va_nou.
  ENDLOOP.

  wa_subtotal-avrsales = wa_subtotal-avrsales / jml_hari.

  CONCATENATE 'Sub Total' va_text INTO lv_text1 SEPARATED BY space.
  PERFORM f_write_subtotal USING lv_text1 '' 'X' 'X' wa_subtotal.
  CLEAR: wa_subtotal, va_nou.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROSES7_BRSCH
*&---------------------------------------------------------------------*
FORM f_proses7_brsch  TABLES   ft_itab  LIKE i_itab
                      USING    fs_itab  TYPE ty_itab.
  DATA : lt_itab1 TYPE STANDARD TABLE OF ty_itab,
         ls_itab1 LIKE LINE OF lt_itab1.

  DATA : lt_channel1 TYPE STANDARD TABLE OF zfchanel,
         ls_channel1 LIKE LINE OF lt_channel1,
         lt_channel2 TYPE STANDARD TABLE OF zfchanel,
         ls_channel2 LIKE LINE OF lt_channel2.

  DATA : lv_text1(50),
         lv_text2(50),
         lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr.

  lt_itab1[] = ft_itab[].
  SORT lt_itab1 BY bukrs vkbur channel brsch fkart.
  DELETE ADJACENT DUPLICATES FROM lt_itab1 COMPARING bukrs vkbur channel brsch fkart.

  lt_channel2[] = i_zfchanel[].
  LOOP AT lt_itab1 INTO ls_itab1.
    MOVE-CORRESPONDING ls_itab1 TO ls_channel2.
    APPEND ls_channel2 TO lt_channel2.
    CLEAR ls_channel2.
  ENDLOOP.
  SORT lt_channel2 BY bukrs vkbur channel brsch.
  DELETE ADJACENT DUPLICATES FROM lt_channel2 COMPARING bukrs vkbur channel brsch.
  lt_channel1[] = lt_channel2[].
  DELETE ADJACENT DUPLICATES FROM lt_channel1 COMPARING bukrs vkbur channel.

  LOOP AT lt_channel1 INTO ls_channel1 WHERE vkbur = fs_itab-vkbur.
    LOOP AT lt_channel2 INTO ls_channel2 WHERE vkbur   = ls_channel1-vkbur
                                           AND channel = ls_channel1-channel.
      SELECT SINGLE *
        FROM t016t
        WHERE spras EQ sy-langu
          AND brsch EQ ls_channel2-brsch.
      IF sy-subrc NE 0.
        t016t-brtxt = 'Others'.
      ENDIF.
      CONCATENATE ls_channel2-brsch t016t-brtxt
          INTO lv_text1 SEPARATED BY '-'.

      CLEAR ls_itab1.
      READ TABLE lt_itab1 INTO ls_itab1
                          WITH KEY vkbur   = ls_channel2-vkbur
                                   channel = ls_channel2-channel
                                   brsch   = ls_channel2-brsch
                          TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        LOOP AT lt_itab1 INTO ls_itab1 WHERE vkbur   = ls_channel2-vkbur
                                         AND channel = ls_channel2-channel
                                         AND brsch   = ls_channel2-brsch.
          ADD 1 TO va_nou.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          CLEAR : lv_text1, lv_text2, gt_tvfkt.

          CONCATENATE ls_channel2-brsch t016t-brtxt
              INTO lv_text1 SEPARATED BY '-'.
          CONCATENATE ls_channel2-channel lv_text1 INTO lv_text1
          SEPARATED BY space.
          READ TABLE gt_tvfkt WITH KEY fkart = ls_itab1-fkart.
          CONCATENATE ls_itab1-fkart gt_tvfkt-vtext
                INTO lv_text2 SEPARATED BY '-'.
          WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) lv_text1 NO-GAP. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w4) lv_text2 NO-GAP. c1 = c1 + w4.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

          PERFORM f_calculate_data7 USING ls_itab1-bukrs ls_itab1-vkbur ls_itab1-channel
                                          '' ls_itab1-brsch ls_itab1-fkart 'BRSCH'
                                    CHANGING lv_avrsales lv_outstanding
                                             lv_dso.

          WRITE AT c1(w3) lv_avrsales NO-GAP. c1 = c1 + w3.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w3) lv_outstanding NO-GAP. c1 = c1 + w3.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w3) lv_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        ENDLOOP.
      ELSE.
        ADD 1 TO va_nou.
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CLEAR : lv_text1, lv_text2, gt_tvfkt,
                lv_avrsales, lv_outstanding, lv_dso.
        CONCATENATE ls_channel2-brsch t016t-brtxt
            INTO lv_text1 SEPARATED BY '-'.
        CONCATENATE ls_channel2-channel lv_text1 INTO lv_text1
        SEPARATED BY space.
        WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w2) lv_text1 NO-GAP. c1 = c1 + w2.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w4) lv_text2 NO-GAP. c1 = c1 + w4.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_avrsales NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_outstanding NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      ENDIF.

      wa_subtotal2-avrsales = wa_subtotal2-avrsales / jml_hari.

      CONCATENATE 'Sub Total' ls_channel2-channel ls_channel2-brsch t016t-brtxt
      INTO lv_text1 SEPARATED BY space.
      PERFORM f_write_subtotal USING lv_text1 '' '' 'X' wa_subtotal2.
      PERFORM f_write_kosong1.
      CLEAR: wa_subtotal2, va_nou.
    ENDLOOP.

    wa_subtotal1-avrsales = wa_subtotal1-avrsales / jml_hari.

    CONCATENATE 'Sub Total' ls_channel1-channel INTO lv_text1 SEPARATED BY space.
    PERFORM f_write_subtotal USING lv_text1 '' '' 'X' wa_subtotal1.
    PERFORM f_write_kosong1.
    CLEAR: wa_subtotal1, va_nou.
  ENDLOOP.

  wa_subtotal-avrsales = wa_subtotal-avrsales / jml_hari.

  CONCATENATE 'Sub Total' va_text INTO lv_text1 SEPARATED BY space.
  PERFORM f_write_subtotal USING lv_text1 '' 'X' 'X' wa_subtotal.
  CLEAR: wa_subtotal, va_nou.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_DATA7
*&---------------------------------------------------------------------*
FORM f_calculate_data7  USING    fu_bukrs fu_vkbur fu_channel fu_kdgrp
                                 fu_brsch fu_fkart fu_sort
                        CHANGING fc_avrsales fc_outstanding fc_dso.
  DATA : ls_itab    LIKE LINE OF i_itab.

  DATA : lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr,
         lv_dmbtr       TYPE p.

  CLEAR : fc_avrsales, fc_outstanding, fc_dso.

  CASE fu_sort.
    WHEN 'KDGRP'.
      LOOP AT i_itab INTO ls_itab WHERE bukrs   = fu_bukrs
                                    AND vkbur   = fu_vkbur
                                    AND channel = fu_channel
                                    AND kdgrp   = fu_kdgrp
                                    AND fkart   = fu_fkart.
        IF ls_itab-shkzg = 'H'.
          lv_dmbtr = ls_itab-dmbtr * -100.
        ELSE.
          lv_dmbtr = ls_itab-dmbtr * 100.
        ENDIF.
        ADD lv_dmbtr TO lv_avrsales.
      ENDLOOP.

      CLEAR : lv_dmbtr, ls_itab.
      LOOP AT i_itab3 INTO ls_itab WHERE bukrs   = fu_bukrs
                                     AND vkbur   = fu_vkbur
                                     AND channel = fu_channel
                                     AND kdgrp   = fu_kdgrp
                                     AND fkart   = fu_fkart.
        IF ls_itab-shkzg = 'H'.
          lv_dmbtr = ls_itab-dmbtr * -100.
        ELSE.
          lv_dmbtr = ls_itab-dmbtr * 100.
        ENDIF.
        ADD lv_dmbtr TO lv_outstanding.
      ENDLOOP.
    WHEN 'BRSCH'.
      LOOP AT i_itab INTO ls_itab WHERE bukrs   = fu_bukrs
                                    AND vkbur   = fu_vkbur
                                    AND channel = fu_channel
                                    AND brsch   = fu_brsch
                                    AND fkart   = fu_fkart.
        IF ls_itab-shkzg = 'H'.
          lv_dmbtr = ls_itab-dmbtr * -100.
        ELSE.
          lv_dmbtr = ls_itab-dmbtr * 100.
        ENDIF.
        ADD lv_dmbtr TO lv_avrsales.
      ENDLOOP.

      CLEAR : lv_dmbtr, ls_itab.
      LOOP AT i_itab3 INTO ls_itab WHERE bukrs   = fu_bukrs
                                     AND vkbur   = fu_vkbur
                                     AND channel = fu_channel
                                     AND brsch   = fu_brsch
                                     AND fkart   = fu_fkart.
        IF ls_itab-shkzg = 'H'.
          lv_dmbtr = ls_itab-dmbtr * -100.
        ELSE.
          lv_dmbtr = ls_itab-dmbtr * 100.
        ENDIF.
        ADD lv_dmbtr TO lv_outstanding.
      ENDLOOP.
  ENDCASE.

  ADD lv_avrsales TO wa_subtotal-avrsales.
  ADD lv_outstanding TO wa_subtotal-outstanding.
  ADD lv_avrsales TO wa_subtotal1-avrsales.
  ADD lv_outstanding TO wa_subtotal1-outstanding.
  ADD lv_avrsales TO wa_subtotal2-avrsales.
  ADD lv_outstanding TO wa_subtotal2-outstanding.
  ADD lv_avrsales TO wa_total-avrsales.
  ADD lv_outstanding TO wa_total-outstanding.

  fc_avrsales    = lv_avrsales / jml_hari.
  fc_outstanding = lv_outstanding.
  TRY .
      fc_dso         = fc_outstanding / fc_avrsales.
    CATCH cx_sy_zerodivide.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEW_PROSES8
*&---------------------------------------------------------------------*
FORM f_new_proses8 .
  DATA : lt_itab1 TYPE STANDARD TABLE OF ty_itab,
         ls_itab1 LIKE LINE OF lt_itab1,
         lt_itab2 TYPE STANDARD TABLE OF ty_itab,
         ls_itab2 LIKE LINE OF lt_itab2,
         lt_itab3 TYPE STANDARD TABLE OF ty_itab,
         ls_itab3 LIKE LINE OF lt_itab3.

  DATA : lv_text1(50),
         lv_text2(50),
         lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr.

  APPEND LINES OF i_itab TO lt_itab3.
  APPEND LINES OF i_itab3 TO lt_itab3.
  SORT lt_itab3 BY bukrs vkbur kvgr3 fkart.
  DELETE ADJACENT DUPLICATES FROM lt_itab3 COMPARING bukrs vkbur kvgr3 fkart.
  lt_itab2[] = lt_itab3[].
  SORT lt_itab2 BY bukrs vkbur kvgr3.
  DELETE ADJACENT DUPLICATES FROM lt_itab2 COMPARING bukrs vkbur kvgr3.
  lt_itab1[] = lt_itab2[].
  SORT lt_itab1 BY bukrs vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_itab1 COMPARING bukrs vkbur.

  v_title2 = 'Day Sales Outstanding Per Customer Group'.
  v_current_page = 1.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Customer Group'.
  CLEAR : va_nou, va_text, wa_total, wa_subtotal.

  LOOP AT lt_itab1 INTO ls_itab1.
    SELECT SINGLE *
      FROM tvkbt
      WHERE spras EQ sy-langu
        AND vkbur EQ ls_itab1-vkbur.

    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    CONCATENATE ls_itab1-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY ' - '.
    WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w6.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    PERFORM f_write_kosong.

    CLEAR ls_itab2.
    LOOP AT lt_itab2 INTO ls_itab2 WHERE bukrs = ls_itab1-bukrs
                                     AND vkbur = ls_itab1-vkbur.
      CLEAR ls_itab3.
      LOOP AT lt_itab3 INTO ls_itab3 WHERE bukrs = ls_itab2-bukrs
                                       AND vkbur = ls_itab2-vkbur
                                       AND kvgr3 = ls_itab2-kvgr3.

        ADD 1 TO va_nou.
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CLEAR : lv_text1, lv_text2, gt_tvfkt.

        SELECT SINGLE *
          FROM tvv3t
          WHERE spras EQ sy-langu
            AND kvgr3 EQ ls_itab3-kvgr3.
        IF sy-subrc NE 0.
          t151t-ktext = 'Others'.
        ENDIF.
        CONCATENATE ls_itab3-kvgr3 tvv3t-bezei
            INTO lv_text1 SEPARATED BY '-'.

        READ TABLE gt_tvfkt WITH KEY fkart = ls_itab3-fkart.
        CONCATENATE ls_itab3-fkart gt_tvfkt-vtext
              INTO lv_text2 SEPARATED BY '-'.
        WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w2) lv_text1 NO-GAP. c1 = c1 + w2.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w4) lv_text2 NO-GAP. c1 = c1 + w4.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

        PERFORM f_calculate_data8 USING ls_itab3-bukrs ls_itab3-vkbur
                                        ls_itab3-kvgr3 ls_itab3-fkart
                                  CHANGING lv_avrsales lv_outstanding
                                           lv_dso.

        WRITE AT c1(w3) lv_avrsales NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_outstanding NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w3) lv_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      ENDLOOP.

      wa_subtotal1-avrsales = wa_subtotal1-avrsales / jml_hari.

      PERFORM f_write_subtotal USING '      Sub Total' '' 'X' 'X' wa_subtotal1.
      CLEAR : wa_subtotal1, va_nou.
    ENDLOOP.

    wa_subtotal-avrsales = wa_subtotal-avrsales / jml_hari.

    CONCATENATE 'Sub Total' va_text INTO lv_text1 SEPARATED BY space.
    PERFORM f_write_subtotal USING lv_text1 '' 'X' '' wa_subtotal.
    CLEAR: wa_subtotal, va_nou.
  ENDLOOP.

  wa_total-avrsales = wa_total-avrsales / jml_hari.

  PERFORM f_write_total USING ''.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_DATA8
*&---------------------------------------------------------------------*
FORM f_calculate_data8  USING    fu_bukrs fu_vkbur fu_kvgr3 fu_fkart
                        CHANGING fc_avrsales
                                 fc_outstanding
                                 fc_dso.
  DATA : ls_itab    LIKE LINE OF i_itab.

  DATA : lv_avrsales    TYPE p,
         lv_outstanding TYPE p,
         lv_dso         TYPE bsid-dmbtr,
         lv_dmbtr       TYPE p.

  CLEAR : fc_avrsales, fc_outstanding, fc_dso.

  LOOP AT i_itab INTO ls_itab WHERE bukrs = fu_bukrs
                                AND vkbur = fu_vkbur
                                AND kvgr3 = fu_kvgr3
                                AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_avrsales.
  ENDLOOP.

  CLEAR : lv_dmbtr, ls_itab.
  LOOP AT i_itab3 INTO ls_itab WHERE bukrs = fu_bukrs
                                 AND vkbur = fu_vkbur
                                 AND kvgr3 = fu_kvgr3
                                 AND fkart = fu_fkart.
    IF ls_itab-shkzg = 'H'.
      lv_dmbtr = ls_itab-dmbtr * -100.
    ELSE.
      lv_dmbtr = ls_itab-dmbtr * 100.
    ENDIF.
    ADD lv_dmbtr TO lv_outstanding.
  ENDLOOP.

  ADD lv_avrsales TO wa_subtotal-avrsales.
  ADD lv_outstanding TO wa_subtotal-outstanding.
  ADD lv_avrsales TO wa_subtotal1-avrsales.
  ADD lv_outstanding TO wa_subtotal1-outstanding.
  ADD lv_avrsales TO wa_total-avrsales.
  ADD lv_outstanding TO wa_total-outstanding.

  fc_avrsales    = lv_avrsales / jml_hari.
  fc_outstanding = lv_outstanding.
  TRY .
      fc_dso         = fc_outstanding / fc_avrsales.
    CATCH cx_sy_zerodivide.
  ENDTRY.
ENDFORM.
