*----------------------------------------------------------------------*
***INCLUDE LZHGFG001F08.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_SW
*&---------------------------------------------------------------------*
FORM f_get_material_sw  USING    fu_werks fu_matnr fu_charg fu_lgort fu_stcat
                        CHANGING fs_materialsw    TYPE zhgwmst013
                                 fc_type fc_message.
  DATA : ls_mchb TYPE mchb,
         lt_iseg TYPE STANDARD TABLE OF iseg,
         ls_iseg LIKE LINE OF lt_iseg.

  DATA : lv_meins TYPE mara-meins,
         lv_bdmng TYPE resb-bdmng.

  SELECT SINGLE *
    FROM mchb
    INTO CORRESPONDING FIELDS OF ls_mchb
    WHERE matnr = fu_matnr
      AND werks = fu_werks
      AND lgort = fu_lgort
      AND charg = fu_charg.
  IF sy-subrc <> 0.
    fs_materialsw-type     = 'E'.
    fs_materialsw-message  = 'Aktive PID yearly'.
  ELSE.
    SELECT *
      FROM iseg
      INTO CORRESPONDING FIELDS OF TABLE lt_iseg
      WHERE matnr = fu_matnr
        AND werks = fu_werks
        AND lgort = fu_lgort
        AND charg = fu_charg.

    IF lt_iseg[] IS INITIAL.
      fs_materialsw-type     = 'S'.
      fs_materialsw-message  = 'GET Data'.
    ELSE.
      READ TABLE lt_iseg INTO ls_iseg
                         WITH KEY budat = space.
      IF sy-subrc = 0.
        fs_materialsw-type     = 'E'.
        fs_materialsw-message  = 'Aktive PID yearly'.
      ELSE.
        fs_materialsw-type     = 'S'.
        fs_materialsw-message  = 'GET Data'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF fs_materialsw-type = 'S'.
    fs_materialsw-material_number  = fu_matnr.
    fs_materialsw-plant            = fu_werks.
    fs_materialsw-batch            = fu_charg.
    fs_materialsw-storage_location = fu_lgort.
    fs_materialsw-stock_category   = fu_stcat.

    SELECT SINGLE maktx
      FROM makt
      INTO fs_materialsw-material_description
      WHERE matnr = fu_matnr
        AND spras = sy-langu.

    SELECT SINGLE meins
      FROM mara
      INTO lv_meins
      WHERE matnr = fu_matnr.

    CASE fu_stcat.
      WHEN 'UU'.
        SELECT SUM( bdmng )
          FROM resb
          INTO lv_bdmng
          WHERE werks = fu_werks
            AND lgort = fu_lgort
            AND charg = fu_charg
            AND xloek = space
            AND kzear = space
            AND xwaok = 'X'.

        ls_mchb-clabs = ls_mchb-clabs - lv_bdmng.
        PERFORM f_conversion USING 'OUTPUT'	ls_mchb-clabs lv_meins
                             CHANGING fs_materialsw-actual_quantity fs_materialsw-uom.

      WHEN 'QI'.
        PERFORM f_conversion USING 'OUTPUT'	ls_mchb-cinsm lv_meins
                             CHANGING fs_materialsw-actual_quantity fs_materialsw-uom.
      WHEN 'BLOCKED'.
        PERFORM f_conversion USING 'OUTPUT'	ls_mchb-cinsm lv_meins
                             CHANGING fs_materialsw-actual_quantity fs_materialsw-uom.
    ENDCASE.
  ENDIF.

ENDFORM.
