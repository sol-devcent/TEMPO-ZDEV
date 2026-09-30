*----------------------------------------------------------------------*
***INCLUDE LZHGFG001F10.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PID_YEARLY
*&---------------------------------------------------------------------*
FORM f_pid_yearly  USING    fu_werks fu_ivnum
                   CHANGING fs_pidyear    TYPE zhgwmst015
                            fc_type fc_message.
  DATA : ls_ikpf  TYPE ikpf,
         ls_iseg  TYPE iseg,
         lv_ivnum TYPE ztspmmdt006-ivnum.

  PERFORM f_alpha_conversion USING fu_ivnum
                             CHANGING lv_ivnum.

  fs_pidyear-plant      = fu_werks.
  fs_pidyear-pid_number = lv_ivnum.

  SELECT SINGLE *
    FROM ikpf
    INTO CORRESPONDING FIELDS OF ls_ikpf
    WHERE iblnr = lv_ivnum
      AND werks = fu_werks.

  IF sy-subrc = 0.
    IF ls_ikpf-lstat IS NOT INITIAL.
      fs_pidyear-type       = 'E'.
      fs_pidyear-message    = 'PID deleted'.
    ELSEIF ls_ikpf-budat <> '00000000'.
      fs_pidyear-type       = 'E'.
      fs_pidyear-message    = 'PID already posting'.
    ELSEIF ls_ikpf-zstat = 'X'.
      fs_pidyear-type       = 'E'.
      fs_pidyear-message    = 'PID already counted'.
    ELSE.
      fs_pidyear-pid_year =  ls_ikpf-gjahr.
      SELECT SINGLE *
        FROM iseg
        INTO CORRESPONDING FIELDS OF ls_iseg
        WHERE iblnr = lv_ivnum
          AND werks = fu_werks.
      IF sy-subrc = 0.
        fs_pidyear-storage_location = ls_iseg-lgort.
        fs_pidyear-code_stcat       = ls_iseg-bstar.
        fs_pidyear-type       = 'S'.
        fs_pidyear-message    = 'GET data PID'.
      ENDIF.
    ENDIF.
  ELSE.
    fs_pidyear-type       = 'E'.
    fs_pidyear-message    = 'PID tidak active'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PIDITEM_YEARLY
*&---------------------------------------------------------------------*
FORM f_piditem_yearly  TABLES   ft_pidyear STRUCTURE zhgwmst016
                       USING    fu_werks fu_ivnum
                       CHANGING fc_type fc_message.
  DATA : lt_iseg    TYPE STANDARD TABLE OF iseg,
         lt_xiseg   TYPE STANDARD TABLE OF iseg,
         ls_iseg    LIKE LINE OF lt_iseg,
         ls_xiseg   LIKE LINE OF lt_xiseg,
         ls_pidyear TYPE zhgwmst016,
         lt_makt    TYPE STANDARD TABLE OF makt,
         ls_makt    LIKE LINE OF lt_makt.

  DATA : lv_menge(20),
         lv_ivnum     TYPE ztspmmdt006-ivnum,
         lv_uzeit(8).

  PERFORM f_alpha_conversion USING fu_ivnum
                             CHANGING lv_ivnum.

  SELECT *
    FROM iseg
    INTO CORRESPONDING FIELDS OF TABLE lt_iseg
    WHERE iblnr = lv_ivnum
      AND werks = fu_werks.

  lt_xiseg[] = lt_iseg[].
  SORT lt_xiseg BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_xiseg COMPARING matnr.
  IF lt_xiseg[] IS NOT INITIAL.
    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE lt_makt
      FOR ALL ENTRIES IN lt_xiseg
      WHERE matnr = lt_xiseg-matnr
        AND spras = sy-langu.
  ENDIF.

  LOOP AT lt_iseg INTO ls_iseg.
    ls_pidyear-item_no               = ls_iseg-zeili.
    ls_pidyear-material_number       = ls_iseg-matnr.
    CLEAR ls_makt.
    READ TABLE lt_makt INTO ls_makt
                       WITH KEY matnr = ls_iseg-matnr.
    IF sy-subrc = 0.
      ls_pidyear-material_description = ls_makt-maktx.
    ENDIF.
    ls_pidyear-batch    = ls_iseg-charg.
    PERFORM f_conversion USING 'OUTPUT'	ls_iseg-menge ls_iseg-meins
                         CHANGING lv_menge ls_pidyear-uom.
    IF ls_iseg-wsti_countdate IS NOT INITIAL.
      WRITE ls_iseg-wsti_counttime TO lv_uzeit USING EDIT MASK '__:__:__' .
      CONCATENATE ls_iseg-wsti_countdate lv_uzeit
      INTO ls_pidyear-counted_date
      SEPARATED BY space.
      ls_pidyear-quantity = lv_menge.
    ENDIF.
    APPEND ls_pidyear TO ft_pidyear.
    CLEAR ls_pidyear.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_POST_PID_YEARLY
*&---------------------------------------------------------------------*
FORM f_post_pid_yearly  TABLES   ft_piditem STRUCTURE zhgwmst016
                        USING    p_json
                        CHANGING fc_type fc_message.

  DATA : lv_json_data TYPE string,
         ls_data      TYPE ty_pidyearly,
         lt_piditem   TYPE STANDARD TABLE OF zhgwmst016,
         ls_piditem   LIKE LINE OF lt_piditem,
         items        TYPE STANDARD TABLE OF bapi_physinv_count_items,
         return       TYPE STANDARD TABLE OF bapiret2,
         ls_items     LIKE LINE OF items,
         ls_return    LIKE LINE OF return.

  DATA : physinventory TYPE ikpf-iblnr,
         fiscalyear    TYPE ikpf-gjahr,
         count_date    TYPE iikpf-zldat,
         lv_uzeit      TYPE sy-uzeit,
         countdate     TYPE sy-datum,
         counttime     TYPE sy-uzeit.

  DATA : lv_menge TYPE mseg-menge,
         lv_ivnum TYPE ztspmmdt006-ivnum,
         lv_subrc TYPE sy-subrc.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_data ).

  lt_piditem[] = ls_data-nav_pidyr[].

  PERFORM f_alpha_conversion USING ls_data-pid_number
                             CHANGING lv_ivnum.

  physinventory = lv_ivnum.
  fiscalyear    = ls_data-pid_year.
  READ TABLE lt_piditem INTO ls_piditem INDEX 1.
  IF sy-subrc = 0.
    PERFORM f_datetime USING ls_piditem-counted_date
                       CHANGING count_date lv_uzeit.
  ENDIF.

  LOOP AT lt_piditem INTO ls_piditem.
    ls_items-item        = ls_piditem-item_no.
    ls_items-material    = ls_piditem-material_number.
    ls_items-batch       = ls_piditem-batch.
    TRANSLATE ls_piditem-quantity USING ',.'.
    ls_items-entry_qnt   = ls_piditem-quantity.
    PERFORM f_conversion USING 'INPUT' '' ls_piditem-uom
                         CHANGING lv_menge ls_items-entry_uom.
    IF ls_piditem-quantity = 0.
      ls_items-zero_count  = 'X'.
    ENDIF.
    APPEND ls_items TO items.
    CLEAR ls_items.

    PERFORM f_datetime USING ls_piditem-counted_date
                       CHANGING countdate counttime.

    TRY.
        UPDATE iseg SET wsti_countdate = countdate
                        wsti_counttime = counttime
                    WHERE iblnr = physinventory
                      AND gjahr = ls_data-pid_year
                      AND zeili = ls_piditem-item_no.
      CATCH cx_sy_open_sql_db.
        lv_subrc = 4.
    ENDTRY.

    IF lv_subrc = 0.
      COMMIT WORK AND WAIT.
    ENDIF.
    CLEAR lv_subrc.
  ENDLOOP.

  CALL FUNCTION 'BAPI_MATPHYSINV_COUNT'
    EXPORTING
      physinventory = physinventory
      fiscalyear    = fiscalyear
      count_date    = count_date
    TABLES
      items         = items
      return        = return.

  CLEAR ls_return.
  READ TABLE return INTO ls_return
                    WITH KEY type = 'E'.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    fc_type    = 'E'.
    fc_message = 'PID Yearly count error'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    fc_type    = 'S'.
    fc_message = 'PID Yearly count success'.

    PERFORM f_modify_table TABLES lt_piditem
                           USING lv_ivnum ls_data-pid_year
                                 ls_data-storage_location
                                 ls_data-printer.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TABLE
*&---------------------------------------------------------------------*
FORM f_modify_table  TABLES   ft_piditem    STRUCTURE zhgwmst016
                     USING    fu_iblnr fu_gjahr fu_lgort fu_printer.
  DATA : lt_iseg    TYPE STANDARD TABLE OF iseg,
         lt_xiseg   TYPE STANDARD TABLE OF iseg,
         lt_x006    TYPE STANDARD TABLE OF ztspmmdt006,
         lt_006     TYPE STANDARD TABLE OF ztspmmdt006,
         ls_iseg    LIKE LINE OF lt_iseg,
         ls_xiseg   LIKE LINE OF lt_xiseg,
         ls_x006    LIKE LINE OF lt_x006,
         ls_006     LIKE LINE OF lt_006,
         lt_item    TYPE STANDARD TABLE OF zhgwmst014,
         ls_piditem TYPE zhgwmst016,
         ls_item    TYPE zhgwmst014.

  DATA : lv_subrc TYPE sy-subrc,
         lv_bstar TYPE iseg-bstar.

  IF ft_piditem[] IS NOT INITIAL.
    LOOP AT ft_piditem INTO ls_piditem.
      MOVE-CORRESPONDING ls_piditem TO ls_item.
      APPEND ls_item TO lt_item.
      ls_xiseg-iblnr  = fu_iblnr.
      ls_xiseg-gjahr  = fu_gjahr.
      ls_xiseg-zeili  = ls_piditem-item_no.
      APPEND ls_xiseg TO lt_xiseg.
      CLEAR ls_xiseg.
    ENDLOOP.

    SELECT *
      FROM iseg
      INTO CORRESPONDING FIELDS OF TABLE lt_iseg
      FOR ALL ENTRIES IN lt_xiseg
      WHERE iblnr = lt_xiseg-iblnr
        AND gjahr = lt_xiseg-gjahr
        AND zeili = lt_xiseg-zeili.

    IF lt_iseg[] IS NOT INITIAL.
      SELECT *
        FROM ztspmmdt006
        INTO CORRESPONDING FIELDS OF TABLE lt_x006
        FOR ALL ENTRIES IN lt_iseg
        WHERE werks = lt_iseg-werks
          AND lgort = lt_iseg-lgort
          AND ivnum = fu_iblnr.
    ENDIF.

    LOOP AT lt_iseg INTO ls_iseg.
      CLEAR ls_x006.
      READ TABLE lt_x006 INTO ls_x006
                         WITH KEY ivnum = ls_iseg-iblnr
                                  ivpos = ls_iseg-zeili.
      IF sy-subrc <> 0.
        ls_006-werks    = ls_iseg-werks.
        ls_006-lgort    = ls_iseg-lgort.
        ls_006-ivnum    = ls_iseg-iblnr.
        ls_006-ivpos    = ls_iseg-zeili.
        ls_006-matnr    = ls_iseg-matnr.
        ls_006-charg    = ls_iseg-charg.
        ls_006-meins    = ls_iseg-meins.
        ls_006-menge    = ls_iseg-menge.
        ls_006-kznul    = ls_iseg-xnull.
        lv_bstar  = ls_iseg-bstar.
        CASE ls_iseg-bstar.
          WHEN '1'.
            ls_006-labst    = ls_iseg-buchm.
          WHEN '2'.
            ls_006-cinsm    = ls_iseg-buchm.
          WHEN '3'.
            ls_006-cspem    = ls_iseg-buchm.
          WHEN '4'.
            ls_006-cspem    = ls_iseg-buchm.
        ENDCASE.
        ls_006-stktyp   = ls_iseg-bstar.
        ls_006-qdatu    = ls_iseg-wsti_countdate.
        ls_006-qzeit    = ls_iseg-wsti_counttime.
        ls_006-qname    = ls_iseg-usnaz.
        APPEND ls_006 TO lt_006.
        CLEAR ls_006.
      ENDIF.
    ENDLOOP.

    IF lt_006[] IS NOT INITIAL.
      TRY.
          INSERT ztspmmdt006 FROM TABLE lt_006.
        CATCH cx_sy_open_sql_db.
          lv_subrc = 4.
      ENDTRY.
    ENDIF.

    IF lv_subrc = 0.
      COMMIT WORK AND WAIT.
      PERFORM f_cetak_form TABLES lt_item
                           USING 'YEARLY' fu_lgort lv_bstar
                                 fu_printer.
    ENDIF.
  ENDIF.
ENDFORM.
