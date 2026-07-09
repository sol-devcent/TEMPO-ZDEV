*&---------------------------------------------------------------------*
*&  Include           ZCOR032_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_length.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-length  = fu_length.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

FORM f_selection_screen_output .
  CASE 'X'.
    WHEN r1.
      PERFORM f_modify_screen USING : 'PFI' '0' '' '' ''.
*                                      'SPE' '0' '' '' ''.
*                                      'PKU' '0' '' '' '',
*                                      'PST' '0' '' '' '',

    WHEN r2.
      PERFORM f_modify_screen USING :
                                      'PBU' '0' '' '' '',
                                      'GJA' '0' '' '' '',
                                      'SPE' '0' '' '' '',
                                      'SKN' '0' '' '' '',
                                      'ART' '0' '' '' '',
                                      'PFI' '0' '' '' ''.
    WHEN r3.
      PERFORM f_modify_screen USING : 'SPE' '0' '' '' '',
                                      'SKN' '0' '' '' '',
                                      'ART' '0' '' '' '',
                                      'GJA' '0' '' '' '',
                                      'PBU' '0' '' '' ''.
*                                      'PKU' '0' '' '' '',
*                                      'PST' '0' '' '' ''.
  ENDCASE.
ENDFORM.

FORM f_get_data.
  DATA: lv_subrc TYPE sy-subrc.
  IF p_bukrs = '8020' OR p_bukrs = '8070'.
    SELECT a~artnr, a~perio, a~prctr, "g~maktx
     e~ktext,
     wwpgr,
     kndnr,
     b~name1,
*         f~ddtext,
     rec_waers,
     SUM( vv801 ) AS vv801,
     SUM( vv811 ) AS vv811,
*     SUM( vv801 ) - SUM( vv811 ) AS net_sales,
     SUM( a~vvd11 + a~vvd12 + a~vvd13 + a~vvd14 + a~vvd15 + a~vvd16 ) AS cogs,
     SUM( a~vv809 ) AS vv809
     INTO TABLE @DATA(it_data_8020_8070)
*     INTO CORRESPONDING FIELDS OF TABLE @it_detl
     FROM ce18010 AS a
*         INNER JOIN makt AS g ON a~artnr = g~matnr
     LEFT OUTER JOIN kna1 AS b ON a~kndnr = b~kunnr
*         INNER JOIN zcodt017 AS c ON  a~kndnr = c~kunnr
*         INNER JOIN dd07t AS f ON c~status = f~domvalue_l AND f~domname = 'ZCONSOL'
     INNER JOIN cepc AS d ON a~prctr = d~prctr
     INNER JOIN cepct AS e ON d~prctr = e~prctr AND e~spras = 'E'
     WHERE a~perio IN @s_perio AND
     a~bukrs = @p_bukrs AND
     a~kndnr IN @s_kndnr
     GROUP BY  a~artnr, a~perio, a~prctr, e~ktext, wwpgr, kndnr, b~name1, rec_waers. "f~ddtext

    IF it_data_8020_8070[] IS NOT INITIAL.
      LOOP AT it_data_8020_8070 INTO DATA(ls_data_8020_8070).
        MOVE-CORRESPONDING ls_data_8020_8070 TO wa_detl.
        wa_detl-net_sales = ls_data_8020_8070-vv801 - ls_data_8020_8070-vv811.
        APPEND wa_detl TO it_detl.
        CLEAR: wa_detl.
      ENDLOOP.
    ENDIF.
  ELSEIF p_bukrs = '8220' OR p_bukrs = '8210' OR p_bukrs = '8390'.
    SELECT a~bukrs, a~gjahr, a~artnr, a~perio, a~prctr, a~rbeln, "g~maktx
      e~ktext,
      wwpgr,
      kndnr,
      b~name1,
*               f~ddtext,
      rec_waers,
      SUM( vv801 ) AS vv801,
      SUM( vv811 ) AS vv811,
      SUM( vv819 ) AS vv819,
      SUM( vv807 ) AS vv807,
      a~vrgar,
*           SUM( vv801 ) - SUM( vv811 ) AS net_sales,
      SUM( a~vvd11 + a~vvd12 + a~vvd13 + a~vvd14 + a~vvd15 + a~vvd16 ) AS cogs,
      SUM( a~vv809 ) AS vv809
      INTO TABLE @DATA(it_data_8220_8210_8390)
*           INTO CORRESPONDING FIELDS OF TABLE @it_detl
      FROM ce18010 AS a
*               INNER JOIN makt AS g ON a~artnr = g~matnr
      LEFT OUTER JOIN kna1 AS b ON a~kndnr = b~kunnr
*               INNER JOIN zcodt017 AS c ON  a~kndnr = c~kunnr
*               INNER JOIN dd07t AS f ON c~status = f~domvalue_l AND f~domname = 'ZCONSOL'
      INNER JOIN cepc AS d ON a~prctr = d~prctr
      INNER JOIN cepct AS e ON d~prctr = e~prctr AND e~spras = 'E'
      WHERE a~perio IN @s_perio AND
      a~bukrs = @p_bukrs AND
      a~kndnr IN @s_kndnr
      GROUP BY a~bukrs, a~gjahr, a~artnr, a~perio, a~prctr, a~rbeln, e~ktext, wwpgr, kndnr, b~name1, rec_waers, a~vrgar. "f~ddtext


    IF it_data_8220_8210_8390[] IS NOT INITIAL.
*      SELECT * INTO TABLE @DATA(it_vbrp) FROM vbrp
*        FOR ALL ENTRIES IN @it_data_8220_8210_8390
*        WHERE vbeln = @it_data_8220_8210_8390-rbeln.
*
*      SELECT * INTO TABLE @DATA(it_vbrk) FROM vbrk
*        FOR ALL ENTRIES IN @it_vbrp
*        WHERE vbeln = @it_vbrp-vbeln.

*      SELECT * INTO TABLE @DATA(it_bseg) FROM bseg
*        FOR ALL ENTRIES IN @it_data_8220_8210_8390
*        WHERE bukrs IN ( '8220', '8210' )
*        AND hkont IN ( '0655110520', '0651110200' )
*        AND gjahr = @s_perio+3(4)
*        AND belnr =  @it_data_8220_8210_8390-rbeln.

      CASE p_bukrs.
        WHEN '8220' OR '8210'.
          DATA(lt_itab_tmp) = it_data_8220_8210_8390[].
          DELETE lt_itab_tmp WHERE vrgar NE 'F'.
          SELECT bukrs, belnr, gjahr, buzei, matnr, dmbtr
            INTO TABLE @DATA(it_bseg)
            FROM bseg FOR ALL ENTRIES IN @lt_itab_tmp
            WHERE bukrs = @lt_itab_tmp-bukrs
              AND belnr = @lt_itab_tmp-rbeln
              AND gjahr = @lt_itab_tmp-gjahr
              AND matnr = @lt_itab_tmp-artnr
              AND hkont IN ( '0655110520', '0651110200' )
            ORDER BY PRIMARY KEY.
        WHEN OTHERS.
      ENDCASE.

      LOOP AT it_data_8220_8210_8390 INTO DATA(ls_data_8220_8210_8390).
        wa_detl-artnr = ls_data_8220_8210_8390-artnr.
        wa_detl-perio = ls_data_8220_8210_8390-perio.
        wa_detl-prctr = ls_data_8220_8210_8390-prctr.
        wa_detl-ktext = ls_data_8220_8210_8390-ktext.
        wa_detl-wwpgr = ls_data_8220_8210_8390-wwpgr.
        wa_detl-kndnr = ls_data_8220_8210_8390-kndnr.
        wa_detl-name1 = ls_data_8220_8210_8390-name1.
        wa_detl-cogs = ls_data_8220_8210_8390-cogs.
        wa_detl-rec_waers = ls_data_8220_8210_8390-rec_waers.
*        wa_detl-vv809 = ls_data_8220_8210_8390-vv809.
*        MOVE-CORRESPONDING ls_data_8220_8210_8390 TO wa_detl.
        IF ls_data_8220_8210_8390-vrgar = 'F' AND
           ( p_bukrs = '8220' OR p_bukrs = '8210' ).
          wa_detl-net_sales = ls_data_8220_8210_8390-vv801 - ( ls_data_8220_8210_8390-vv811 * -1 ) - ls_data_8220_8210_8390-vv819 - ls_data_8220_8210_8390-vv807.
          READ TABLE it_bseg INTO DATA(wa_bseg) WITH KEY belnr = ls_data_8220_8210_8390-rbeln matnr = ls_data_8220_8210_8390-artnr.
          IF sy-subrc = 0.
            DATA(lv_net_sales) = REDUCE dmbtr( INIT val = 0 FOR wa IN it_bseg WHERE ( belnr = ls_data_8220_8210_8390-rbeln AND
                                                                                      matnr = ls_data_8220_8210_8390-artnr )
                                               NEXT val = val + wa-dmbtr ).
*            wa_detl-net_sales =  ( wa_detl-net_sales * 100 ) + ( ( wa_bseg-dmbtr * 100 ) / ( 111 / 100 ) ).
            wa_detl-net_sales =  ( wa_detl-net_sales * 100 ) + ( ( lv_net_sales * 100 ) / ( 111 / 100 ) ).
            wa_detl-net_sales =  wa_detl-net_sales / 100.
          ENDIF.
*          IF p_bukrs = '8220' OR p_bukrs = '8210'.
*            READ TABLE it_vbrp INTO DATA(wa_vbrp) WITH KEY vbeln = ls_data_8220_8210_8390-rbeln.
*            IF sy-subrc = 0.
*              DATA(kzwi4) = wa_vbrp-kzwi4 * 100 / ( 111 / 100 ).
*              wa_detl-net_sales = ( wa_detl-net_sales * 100 ) - kzwi4.
*              wa_detl-net_sales = wa_detl-net_sales / 100.
*            ENDIF.
*          ENDIF.
        ELSEIF ls_data_8220_8210_8390-vrgar <> 'F'.
          wa_detl-net_sales = ls_data_8220_8210_8390-vv801 - ls_data_8220_8210_8390-vv811 - ls_data_8220_8210_8390-vv819 - ls_data_8220_8210_8390-vv807.
        ENDIF.
        APPEND wa_detl TO it_detl.
        CLEAR: wa_detl.
      ENDLOOP.

*      LOOP AT it_data_8220_8210_8390 INTO DATA(ls_data_8220_8210_8390).
*        MOVE-CORRESPONDING ls_data_8220_8210_8390 TO wa_detl.
*        COLLECT wa_detl INTO it_detl.
*      ENDLOOP.
    ENDIF.
  ELSE.
    SELECT a~artnr, a~perio, a~prctr, "g~maktx
    e~ktext,
    wwpgr,
    kndnr,
    b~name1,
*    f~ddtext,
    rec_waers,
    SUM( vv801 ) AS net_sales,
    SUM( a~vvd11 + a~vvd12 + a~vvd13 + a~vvd14 + a~vvd15 + a~vvd16 ) AS cogs,
    SUM( a~vv809 ) AS vv809
    INTO CORRESPONDING FIELDS OF TABLE @it_detl
    FROM ce18010 AS a
*    INNER JOIN makt AS g ON a~artnr = g~matnr
    LEFT OUTER JOIN kna1 AS b ON a~kndnr = b~kunnr
*    INNER JOIN zcodt017 AS c ON  a~kndnr = c~kunnr
*    INNER JOIN dd07t AS f ON c~status = f~domvalue_l AND f~domname = 'ZCONSOL'
    INNER JOIN cepc AS d ON a~prctr = d~prctr
    INNER JOIN cepct AS e ON d~prctr = e~prctr AND e~spras = 'E'
    WHERE a~perio IN @s_perio AND
    a~bukrs = @p_bukrs AND
    a~kndnr IN @s_kndnr
    GROUP BY  a~artnr, a~perio, a~prctr, e~ktext, wwpgr, kndnr, b~name1, rec_waers. "f~ddtext
  ENDIF.

*  SELECT a~artnr, a~perio, a~prctr, "g~maktx
*    e~ktext,
*    wwpgr,
*    kndnr,
*    b~name1,
**    f~ddtext,
*    rec_waers,
*    SUM( vv801 ) AS net_sales,
*    SUM( a~vvd11 + a~vvd12 + a~vvd13 + a~vvd14 + a~vvd15 + a~vvd16 ) AS cogs,
*    SUM( a~vv809 ) AS vv809
*    INTO CORRESPONDING FIELDS OF TABLE @it_detl
*    FROM ce18010 AS a
**    INNER JOIN makt AS g ON a~artnr = g~matnr
*    LEFT OUTER JOIN kna1 AS b ON a~kndnr = b~kunnr
**    INNER JOIN zcodt017 AS c ON  a~kndnr = c~kunnr
**    INNER JOIN dd07t AS f ON c~status = f~domvalue_l AND f~domname = 'ZCONSOL'
*    INNER JOIN cepc AS d ON a~prctr = d~prctr
*    INNER JOIN cepct AS e ON d~prctr = e~prctr AND e~spras = 'E'
*    WHERE a~perio IN @s_perio AND
*    a~bukrs = @p_bukrs AND
*    a~kndnr IN @s_kndnr
*    GROUP BY  a~artnr, a~perio, a~prctr, e~ktext, wwpgr, kndnr, b~name1, rec_waers. "f~ddtext
*

  IF it_detl IS NOT INITIAL.
    SELECT kunnr, perio1, perio2, ddtext INTO TABLE @DATA(it_ddtext) FROM zcodt017 AS a
  INNER JOIN dd07t AS b ON  a~status = b~domvalue_l AND b~domname = 'ZCONSOL'
  FOR ALL ENTRIES IN @it_detl WHERE
  a~kunnr = @it_detl-kndnr.

    SELECT matnr, maktx INTO TABLE @DATA(it_maktx) FROM makt AS a FOR ALL ENTRIES IN
      @it_detl WHERE matnr = @it_detl-artnr.

    SORT it_ddtext BY perio1 perio2.
    SORT it_detl BY perio artnr kndnr.

    DATA: net_sales_sum TYPE rke2_vv801,
          cogs_sum      TYPE rke2_vvd11,
          temp_artnr    TYPE artnr,
          temp_kndnr    TYPE kunde_pa.
    TYPES: BEGIN OF ty_num_art_knd,
             artnr TYPE artnr,
             kndnr TYPE kunde_pa,
             count TYPE i,
           END OF ty_num_art_knd.
    DATA: it_num TYPE TABLE OF ty_num_art_knd,
          wa_num TYPE ty_num_art_knd.
    LOOP AT it_detl ASSIGNING FIELD-SYMBOL(<fs_detl>).
      IF temp_artnr <> <fs_detl>-artnr OR temp_kndnr <> <fs_detl>-kndnr.
        CLEAR: net_sales_sum, wa_num, cogs_sum.
        temp_artnr = <fs_detl>-artnr.
        temp_kndnr = <fs_detl>-kndnr.
      ENDIF.
      ADD <fs_detl>-net_sales TO net_sales_sum.
      <fs_detl>-net_sales = net_sales_sum.
      wa_num-artnr = temp_artnr.
      wa_num-kndnr = temp_kndnr.
      ADD 1 TO wa_num-count.
      APPEND wa_num TO it_num.
      IF <fs_detl>-cogs = 0.
*        <fs_detl>-cogs = <fs_detl>-vv809.
*        SELECT a~vv809 INTO @DATA(lv_vv809) FROM ce18010 AS a
*         FOR ALL ENTRIES IN @it_detl WHERE a~perio = @it_detl-perio AND a~kndnr = @it_detl-kndnr AND a~bukrs = @p_bukrs AND a~prctr = @it_detl-prctr.
*          ENDSELECT.
*          <fs_detl>-cogs = lv_vv809.

      ENDIF.
      ADD <fs_detl>-cogs TO cogs_sum.
      <fs_detl>-cogs = cogs_sum.
*      <fs_detl>-vv809 = cogs_sum.
      IF p_bukrs = '8020' OR p_bukrs = '8070' OR p_bukrs = '8220' OR p_bukrs = '8210' OR p_bukrs = '8390'.
        READ TABLE it_ddtext INTO DATA(wa_ddtext) WITH KEY kunnr = <fs_detl>-kndnr.
        IF sy-subrc = 0.
*          IF wa_ddtext-kunnr = <fs_detl>-kndnr AND wa_ddtext-perio1 <= <fs_detl>-perio AND wa_ddtext-perio2 >= <fs_detl>-perio.
          <fs_detl>-ddtext = wa_ddtext-ddtext.
        ELSE.
          <fs_detl>-ddtext = 'Third Party'.
        ENDIF.
*      ENDLOOP.
*        <fs_detl>-ddtext = 'Third Party'.
      ELSE.
        LOOP AT it_ddtext INTO wa_ddtext.
          IF wa_ddtext-kunnr = <fs_detl>-kndnr AND wa_ddtext-perio1 <= <fs_detl>-perio AND wa_ddtext-perio2 >= <fs_detl>-perio.
            <fs_detl>-ddtext = wa_ddtext-ddtext.
          ENDIF.
        ENDLOOP.
      ENDIF.
      <fs_detl>-gross_profit = <fs_detl>-net_sales - <fs_detl>-cogs.
      IF <fs_detl>-net_sales NE 0.
        <fs_detl>-margin = <fs_detl>-gross_profit / <fs_detl>-net_sales * 100.
      ELSE.
        <fs_detl>-margin = 0.
      ENDIF.
      READ TABLE it_maktx INTO DATA(wa_maktx) WITH KEY matnr = <fs_detl>-artnr.
      IF sy-subrc = 0.
        <fs_detl>-maktx = wa_maktx-maktx.
      ENDIF.
      IF p_bukrs = '8020' OR p_bukrs = '8070' OR p_bukrs = '8220' OR p_bukrs = '8210' OR p_bukrs = '8390'.
      ELSE.
        READ TABLE it_ddtext INTO DATA(wa_dd) WITH KEY kunnr = <fs_detl>-kndnr.
        IF sy-subrc <> 0.
          TRY.
              DELETE it_detl.
            CATCH cx_sy_open_sql_db.
              lv_subrc = 4.
          ENDTRY.

          IF lv_subrc = 0.
            COMMIT WORK AND WAIT.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.
*      IF <fs_detl>-net_sales = 0 AND <fs_detl>-cogs = 0.
*        TRY.
*            DELETE it_detl.
*          CATCH cx_sy_open_sql_db.
*            lv_subrc = 4.
*        ENDTRY.
*
*        IF lv_subrc = 0.
*          COMMIT WORK AND WAIT.
*          CONTINUE.
*        ENDIF.
*      ENDIF.
      CLEAR: wa_dd, wa_maktx.
    ENDLOOP.
    SORT it_num DESCENDING BY artnr kndnr count.
    DELETE ADJACENT DUPLICATES FROM it_num COMPARING artnr kndnr.
    DATA: count TYPE i.
    CLEAR: temp_artnr, temp_kndnr.
    LOOP AT it_detl INTO wa_detl.
      IF temp_artnr <> wa_detl-artnr OR temp_kndnr <> wa_detl-kndnr.
        CLEAR: count.
        temp_artnr = wa_detl-artnr.
        temp_kndnr = wa_detl-kndnr.
      ENDIF.
      ADD 1 TO count.
      READ TABLE it_num INTO wa_num WITH KEY artnr = wa_detl-artnr kndnr = wa_detl-kndnr count = count.
      IF sy-subrc <> 0.
        DELETE it_detl.
      ENDIF.
    ENDLOOP.
    CLEAR: temp_artnr, temp_kndnr.
    SORT it_detl BY artnr perio kndnr.

  ENDIF.

ENDFORM.


FORM f_print_data.
  DATA: ls_layout TYPE slis_layout_alv.
  ls_layout-colwidth_optimize = 'X'.

  DATA: g_repid   TYPE sy-repid.
  g_repid = sy-repid.

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv.
  CLEAR: lt_fieldcat.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZCOR32_STRUCT'
    CHANGING
      ct_fieldcat      = lt_fieldcat.

  LOOP AT lt_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fieldcat>).
    CLEAR: <fs_fieldcat>-key.
    CASE <fs_fieldcat>-fieldname.
      WHEN 'PERIO'.
        <fs_fieldcat>-key = 'X'.
        <fs_fieldcat>-fix_column = 'X'.
        <fs_fieldcat>-seltext_s = 'Period'.
        <fs_fieldcat>-seltext_m = 'Period'.
        <fs_fieldcat>-seltext_l = 'Period'.
        <fs_fieldcat>-reptext_ddic = 'Period'.
      WHEN 'ARTNR'.
        <fs_fieldcat>-key = 'X'.
        <fs_fieldcat>-fix_column = 'X'.
        <fs_fieldcat>-seltext_s = 'Material'.
        <fs_fieldcat>-seltext_m = 'Material'.
        <fs_fieldcat>-seltext_l = 'Material'.
        <fs_fieldcat>-reptext_ddic = 'Material'.
      WHEN 'MAKTX'.
        <fs_fieldcat>-key = 'X'.
        <fs_fieldcat>-fix_column = 'X'.
        <fs_fieldcat>-seltext_s = 'Material Description'.
        <fs_fieldcat>-seltext_m = 'Material Description'.
        <fs_fieldcat>-seltext_l = 'Material Description'.
        <fs_fieldcat>-reptext_ddic = 'Material Description'.
      WHEN 'PRCTR'.
        <fs_fieldcat>-seltext_s = 'Profit Center'.
        <fs_fieldcat>-seltext_m = 'Profit Center'.
        <fs_fieldcat>-seltext_l = 'Profit Center'.
        <fs_fieldcat>-reptext_ddic = 'Profit Center'.
      WHEN 'KTEXT'.
        <fs_fieldcat>-seltext_s = 'Profit Center Description'.
        <fs_fieldcat>-seltext_m = 'Profit Center Description'.
        <fs_fieldcat>-seltext_l = 'Profit Center Description'.
        <fs_fieldcat>-reptext_ddic = 'Profit Center Description'.
      WHEN 'WWPGR'.
        <fs_fieldcat>-seltext_s = 'CCHC Category'.
        <fs_fieldcat>-seltext_m = 'CCHC Category'.
        <fs_fieldcat>-seltext_l = 'CCHC Category'.
        <fs_fieldcat>-reptext_ddic = 'CCHC Category'.
      WHEN 'KNDNR'.
        <fs_fieldcat>-seltext_s = 'Customer'.
        <fs_fieldcat>-seltext_m = 'Customer'.
        <fs_fieldcat>-seltext_l = 'Customer'.
        <fs_fieldcat>-reptext_ddic = 'Customer'.
        <fs_fieldcat>-outputlen = '10'.
      WHEN 'NAME1'.
        <fs_fieldcat>-seltext_s = 'Customer Description'.
        <fs_fieldcat>-seltext_m = 'Customer Description'.
        <fs_fieldcat>-seltext_l = 'Customer Description'.
        <fs_fieldcat>-reptext_ddic = 'Customer Description'.
      WHEN 'DDTEXT'.
        <fs_fieldcat>-seltext_s = 'Customer Status'.
        <fs_fieldcat>-seltext_m = 'Customer Status'.
        <fs_fieldcat>-seltext_l = 'Customer Status'.
        <fs_fieldcat>-reptext_ddic = 'Customer Status'.
        <fs_fieldcat>-outputlen = '20'.
      WHEN 'NET_SALES'.
        <fs_fieldcat>-seltext_s = 'Net Sales'.
        <fs_fieldcat>-seltext_m = 'Net Sales'.
        <fs_fieldcat>-seltext_l = 'Net Sales'.
        <fs_fieldcat>-reptext_ddic = 'Net Sales'.
        <fs_fieldcat>-cfieldname = 'REC_WAERS'.
*        <fs_fieldcat>-do_sum = 'X'.
*        <fs_fieldcat>-datatype = 'CURR'.
        <fs_fieldcat>-ref_tabname = 'ZCOR32_STRUCT'.
      WHEN 'COGS'.
*        <fs_fieldcat>-seltext_s = 'Cogs'.
*        <fs_fieldcat>-seltext_m = 'Cogs'.
*        <fs_fieldcat>-seltext_l = 'Cogs'.
*        <fs_fieldcat>-reptext_ddic = 'Cogs'.
        <fs_fieldcat>-cfieldname = 'REC_WAERS'.
*        <fs_fieldcat>-do_sum = 'X'.
*        <fs_fieldcat>-datatype = 'CURR'.
        <fs_fieldcat>-ref_tabname = 'ZCOR32_STRUCT'.
      WHEN 'GROSS_PROFIT'.
        <fs_fieldcat>-seltext_s = 'Gross Profit'.
        <fs_fieldcat>-seltext_m = 'Gross Profit'.
        <fs_fieldcat>-seltext_l = 'Gross Profit'.
        <fs_fieldcat>-reptext_ddic = 'Gross Profit'.
        <fs_fieldcat>-cfieldname = 'REC_WAERS'.
*        <fs_fieldcat>-do_sum = 'X'.
*        <fs_fieldcat>-datatype = 'CURR'.
        <fs_fieldcat>-ref_tabname = 'ZCOR32_STRUCT'.
      WHEN 'MARGIN'.
        <fs_fieldcat>-seltext_s = 'Margin %'.
        <fs_fieldcat>-seltext_m = 'Margin %'.
        <fs_fieldcat>-seltext_l = 'Margin %'.
        <fs_fieldcat>-reptext_ddic = 'Margin %'.
        CLEAR: <fs_fieldcat>-cfieldname.
*        <fs_fieldcat>-cfieldname = 'REC_WAERS'.
*        <fs_fieldcat>-do_sum = 'X'.
*        <fs_fieldcat>-datatype = 'CURR'.
*        <fs_fieldcat>-ref_tabname = 'zcor032_struct'.
      WHEN 'REC_WAERS'.
        <fs_fieldcat>-seltext_s = 'Currency'.
        <fs_fieldcat>-seltext_m = 'Currency'.
        <fs_fieldcat>-seltext_l = 'Currency'.
        <fs_fieldcat>-reptext_ddic = 'Currency'.
    ENDCASE.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
      i_callback_top_of_page   = 'TOP-OF-PAGE'
      is_layout                = ls_layout
      it_fieldcat              = lt_fieldcat
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      i_default                = 'X'
      i_save                   = 'A'
*     i_structure_name         = 'zco_e011_detl'
    TABLES
      t_outtab                 = it_detl.
ENDFORM.

**&---------------------------------------------------------------------*
**&      Form  TOP-OF-PAGE
**&---------------------------------------------------------------------*
FORM top-of-page.
  DATA: lt_header     TYPE slis_t_listheader,
        ls_header     TYPE slis_listheader,
        lt_line       LIKE ls_header-info,
        lv_lines      TYPE i,
        lv_linesc(10) TYPE c.

**&—– Alv report header —–*
  ls_header-typ = 'S'.
*  ls_header-info = p_bukrs."'PT. BARCLAY PRODUCTS'.
  CONCATENATE 'COMPANY CODE: ' p_bukrs INTO ls_header-info.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.
*
*  ls_header-typ = 'H'.
*  ls_header-info = 'EXPENSE CONTROL SHEET'.
*  APPEND ls_header TO lt_header.
*  CLEAR ls_header.
*
  ls_header-typ = 'S'.
*  ls_header-key = 'PERIOD: '.
  DATA: period TYPE string.
  CONCATENATE s_perio-low+4(3) '.' s_perio-low(4) ' - ' s_perio-high+4(3) '.' s_perio-high(4) INTO period.
  CONCATENATE 'PERIOD: ' period INTO ls_header-info SEPARATED BY ' '. "ls_zco_e011_header-period ls_zco_e011_header-gjahr INTO ls_header-info SEPARATED BY space.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.
**
*  ls_header-typ = 'S'.
*  ls_header-key = 'Profit Center: '.
*  ls_header-info = profit_center.
**  CONCATENATE ls_zco_e011_header-prctr ls_zco_e011_header-ktext1 INTO ls_header-info SEPARATED BY space.
*  APPEND ls_header TO lt_header.
*  CLEAR ls_header.
*
*  ls_header-typ = 'S'.
*  ls_header-key = 'Order: '.
*  ls_header-info = order.
**  CONCATENATE ls_zco_e011_header-rkaufnr ls_zco_e011_header-ktext2 INTO ls_header-info SEPARATED BY space.
*  APPEND ls_header TO lt_header.
*  CLEAR ls_header.
*
*  ls_header-typ = 'S'.
*  ls_header-key = 'SEC: '.
*  ls_header-info = sec.
**  CONCATENATE ls_zco_e011_header-wwsec ls_zco_e011_header-bezek INTO ls_header-info SEPARATED BY space.
*  APPEND ls_header TO lt_header.
*  CLEAR ls_header.
*
*  ls_header-typ = 'S'.
*  ls_header-key = 'Original Budget: '.
*  ls_header-info = ls_zco_e011_header-original_budget.
*  APPEND ls_header TO lt_header.
*  CLEAR ls_header.
*
*  ls_header-typ = 'S'.
*  ls_header-key = 'Spent Budget: '.
*  ls_header-info = ls_zco_e011_header-spent_budget.
*  APPEND ls_header TO lt_header.
*  CLEAR ls_header.
*
*  ls_header-typ = 'S'.
*  ls_header-key = 'Budget Available: '.
*  ls_header-info = ls_zco_e011_header-budget_avail.
*  APPEND ls_header TO lt_header.
*  CLEAR ls_header.
***&—– Pass data and field catalog to ALV function module —–*

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.

ENDFORM. "top-of-page
*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  DATA: lt_exclude TYPE TABLE OF sy-ucomm.

  sy-lsind = 0.
  APPEND '&EXECUTE' TO lt_exclude.
  SET PF-STATUS 'STANDARD' EXCLUDING lt_exclude.
ENDFORM.                    " F_SET_PF_STATUS
*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&EXECUTE'.
  ENDCASE.

ENDFORM.                    "F_USER_COMMAND

*FORM f_insert_data.
*  DATA: wa_zcodt017 TYPE zcodt017,
*        lv_subrc    TYPE sy-subrc.
*
*  wa_zcodt017 = VALUE zcodt017( bukrs = p_bukrs
*                       kunnr = p_kunnr
*                       status = p_stat
*                       ).
*  TRY.
*      INSERT zcodt017 FROM wa_zcodt017.
*    CATCH cx_sy_open_sql_db.
*      lv_subrc = 4.
*  ENDTRY.
*  IF lv_subrc = 0.
*    COMMIT WORK AND WAIT.
*    MESSAGE 'Successfully maintained data' TYPE 'S'.
*  ENDIF.
*
*ENDFORM.

FORM f_upload_data.
  DATA: lv_subrc    TYPE sy-subrc.
  IF p_file IS NOT INITIAL.
    CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING
        filename                = p_file
        i_begin_col             = 1
        i_begin_row             = 2
        i_end_col               = 10
        i_end_row               = 99999
      TABLES
        intern                  = intern
      EXCEPTIONS
        inconsistent_parameters = 1
        upload_ole              = 2
        OTHERS                  = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here

    ELSE.
      LOOP AT intern INTO DATA(wa_intern).
        CASE wa_intern-col.
*          WHEN '001'.
*            APPEND INITIAL LINE TO it_zcodt017 ASSIGNING FIELD-SYMBOL(<fs_zcodt017>).
*            <fs_zcodt017>-bukrs = wa_intern-value.
          WHEN '001'.
            APPEND INITIAL LINE TO it_zcodt017 ASSIGNING FIELD-SYMBOL(<fs_zcodt017>).
            <fs_zcodt017>-kunnr = wa_intern-value.
          WHEN '002'.
            <fs_zcodt017>-status = wa_intern-value.
          WHEN '003'.
            <fs_zcodt017>-perio1 = wa_intern-value.
          WHEN '004'.
            <fs_zcodt017>-perio2 = wa_intern-value.
        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF it_zcodt017 IS NOT INITIAL.
    TRY.
        INSERT zcodt017 FROM TABLE it_zcodt017.
      CATCH cx_sy_open_sql_db.
        lv_subrc = 4.
    ENDTRY.
    IF lv_subrc = 0.
      COMMIT WORK AND WAIT.
      MESSAGE 'Successfully uploaded data' TYPE 'S'.
    ENDIF.
  ELSE.
    MESSAGE 'No data' TYPE 'E'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_TABLE_MAINTENANCE
*&---------------------------------------------------------------------*
FORM f_table_maintenance .
  DATA : sellist      TYPE STANDARD TABLE OF vimsellist.

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action                       = 'U'
      view_name                    = 'ZCODT017'
    TABLES
      dba_sellist                  = sellist
    EXCEPTIONS
      client_reference             = 1
      foreign_lock                 = 2
      invalid_action               = 3
      no_clientindependent_auth    = 4
      no_database_function         = 5
      no_editor_function           = 6
      no_show_auth                 = 7
      no_tvdir_entry               = 8
      no_upd_auth                  = 9
      only_show_allowed            = 10
      system_failure               = 11
      unknown_field_in_dba_sellist = 12
      view_not_found               = 13
      maintenance_prohibited       = 14
      OTHERS                       = 15.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DATE
*&---------------------------------------------------------------------*
FORM f_change_date  CHANGING fc_datbi
                             fc_datab.
  DATA(ls_perio) = s_perio[ 1 ].
  fc_datbi = |{ ls_perio-high(4) }{ ls_perio-high+5(2) }01 |.
  fc_datab = |{ ls_perio-low(4) }{ ls_perio-low+5(2) }01 |.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = fc_datbi
    IMPORTING
      last_day_of_month = fc_datbi.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  CASE 'X'.
    WHEN r1.
      IF p_bukrs IS INITIAL.
        PERFORM f_error_message USING 'PBU' 'Filename required entries'.
      ENDIF.
      IF s_perio[] IS INITIAL.
        PERFORM f_error_message USING 'SPE' 'Filename required entries'.
      ENDIF.
    WHEN r2.
    WHEN r3.
      IF p_file IS INITIAL.
        PERFORM f_error_message USING 'PFI' 'Filename required entries'.
      ENDIF.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF lv_mess IS NOT INITIAL.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_INIT_PERIOD
*&---------------------------------------------------------------------*
FORM f_init_period .
  CLEAR s_perio[].
  s_perio-low = |{ sy-datum(4) }001|.
  s_perio-high = |{ sy-datum(4) }0{ sy-datum+4(2) }|.
  s_perio-sign = 'I'.
  s_perio-option = 'BT'.
  APPEND s_perio.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_CDS
*&---------------------------------------------------------------------*
FORM f_get_data_cds .
*  DATA(lo_amdp) = NEW zcdsco_cl001( ).
  DATA(lo_amdp) = NEW zcdsco_cl002( ).

* Append exclude material
  APPEND VALUE #( sign = 'E' option = 'CP' low = 'I*' ) TO s_artnr.
  APPEND VALUE #( sign = 'E' option = 'CP' low = 'R*' ) TO s_artnr.
  APPEND VALUE #( sign = 'E' option = 'CP' low = 'P*' ) TO s_artnr.

* Change select option to syntax AMDP
  DATA(lv_flt_kndnr) = cl_shdb_seltab=>combine_seltabs(
      it_named_seltabs = VALUE #( ( name = 'KNDNR' dref = REF #( s_kndnr[] ) ) ) ).

  DATA(lv_flt_artnr) = cl_shdb_seltab=>combine_seltabs(
      it_named_seltabs = VALUE #( ( name = 'ARTNR' dref = REF #( s_artnr[] ) ) ) ).

* Call AMDP
  lo_amdp->get_copa_data(
    EXPORTING
      iv_client     = sy-mandt
      iv_bukrs      = p_bukrs
      iv_perio_from = s_perio-low
      iv_perio_to   = s_perio-high
      iv_flt_kndnr  = lv_flt_kndnr
      iv_flt_artnr  = lv_flt_artnr
    IMPORTING
      et_result = DATA(lt_data)
  ).

  IF lt_data[] IS NOT INITIAL.
    DATA(lv_perio1) = s_perio-low.        "| { p_gjahr }001 |.
    DATA(lv_perio2) = s_perio-high.       "| { p_gjahr }012 |.
*    IF p_gjahr = sy-datum(4).
*      lv_perio2 = | { sy-datum(4) }0{ sy-datum+4(2) } |.
*    ENDIF.

*    DELETE lt_data WHERE kndnr NOT IN s_kndnr.

    DATA(lt_cust) = lt_data[].
    SORT lt_cust BY kndnr.
    DELETE ADJACENT DUPLICATES FROM lt_cust COMPARING kndnr.
    IF lt_cust[] IS NOT INITIAL.
      SELECT b~kunnr, b~perio1, b~perio2, b~status, c~ddtext
        INTO TABLE @DATA(lt_zcodt017)
        FROM zcodt017 AS b JOIN dd07t AS c ON c~domname = 'ZCONSOL' AND
                                              c~ddlanguage = @sy-langu AND
                                              c~domvalue_l = b~status
        FOR ALL ENTRIES IN @lt_cust
        WHERE b~kunnr = @lt_cust-kndnr
          AND ( b~perio1 LE @lv_perio1 OR b~perio1 BETWEEN @lv_perio1 AND @lv_perio2 )
          AND ( b~perio2 GE @lv_perio2 OR b~perio2 BETWEEN @lv_perio1 AND @lv_perio2 ).
    ENDIF.

    LOOP AT lt_data INTO DATA(ls_data).
*      CASE p_bukrs.
*        WHEN '8020'.
*          IF ( ls_data-vv801 < 0 AND ls_data-vv811 > 0 ) OR
*             ( ls_data-vv801 > 0 AND ls_data-vv811 < 0 ).
*            ls_data-net_sales = ls_data-vv801 + ls_data-vv811.
*          ENDIF.
*        WHEN OTHERS.
*      ENDCASE.

      IF line_exists( lt_zcodt017[ kunnr = ls_data-kndnr ] ).
        DATA(lv_ddtext) = VALUE #( lt_zcodt017[ kunnr = ls_data-kndnr ]-ddtext OPTIONAL ).
      ELSE.
        lv_ddtext = 'Third Party'.
      ENDIF.

      APPEND INITIAL LINE TO it_detl ASSIGNING FIELD-SYMBOL(<fs_detl>).
      <fs_detl>-artnr         = ls_data-artnr.
      <fs_detl>-maktx         = ls_data-maktx.
      <fs_detl>-perio         = |{ ls_data-perio WIDTH = 7 ALIGN = RIGHT PAD = '0' }|.
      <fs_detl>-prctr         = ls_data-prctr.
      <fs_detl>-ktext         = ls_data-ktext.
      <fs_detl>-wwpgr         = ls_data-wwpgr.
      <fs_detl>-kndnr         = ls_data-kndnr.
      <fs_detl>-name1         = ls_data-name1.
      <fs_detl>-ddtext        = lv_ddtext.
      <fs_detl>-rec_waers     = ls_data-rec_waers.
      <fs_detl>-net_sales     = ls_data-net_sales.
*      <fs_detl>-cogs          = ls_data-vvcogs.

      CASE p_bukrs.
        WHEN '8010' OR '8040' OR '8090' OR '8230' OR '8190' OR '8330' OR '8360'.
          <fs_detl>-cogs = ls_data-vvd11 + ls_data-vvd12 + ls_data-vvd13 +
                           ls_data-vvd14 + ls_data-vvd15 + ls_data-vvd16.
        WHEN OTHERS.
          <fs_detl>-cogs = ls_data-vv809.
      ENDCASE.

      <fs_detl>-gross_profit  = <fs_detl>-net_sales - <fs_detl>-cogs.

      IF <fs_detl>-net_sales NE 0.
        <fs_detl>-margin = <fs_detl>-gross_profit / <fs_detl>-net_sales * 100.
      ELSE.
        <fs_detl>-margin = 0.
      ENDIF.
    ENDLOOP.

  ELSE.
    MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
ENDFORM.
