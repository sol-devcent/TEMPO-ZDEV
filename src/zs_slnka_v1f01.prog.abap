*&---------------------------------------------------------------------*
*&  Include           ZS_SLNKA_V1F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM get_data .
*** Select Reason for rejection
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE t_abgru
    FROM zsd_abgru
    WHERE vkorg = p_vkorg.
  IF sy-subrc = 0.
    t_abgru-abgru = '99'.
    MODIFY t_abgru TRANSPORTING abgru WHERE abgru = space.
    SORT t_abgru BY abgru.
  ENDIF.

*** Select Document Quotation ***
  SELECT DISTINCT a~vbeln
    FROM vbak AS a JOIN vbap AS b ON a~vbeln = b~vbeln
                   JOIN knvv AS c ON a~vkorg = c~vkorg AND
                                     a~vtweg = c~vtweg AND
                                     a~spart = c~spart AND
                                     a~knkli = c~kunnr
    INTO TABLE i_quot
    WHERE a~kkber = gv_kkber AND
          a~vkorg = p_vkorg  AND
          a~vkbur IN s_vkbur AND
          a~auart IN s_auart AND
          a~vbeln IN s_quotn AND
          a~knkli IN s_knkli AND
          a~erdat IN s_erdat AND
          a~audat IN s_quotd AND
          b~matkl IN s_matkl AND
          b~matnr IN s_matnr AND
          c~kdgrp IN s_kdgrp AND
          c~kvgr3 IN s_kvgr3 AND
          c~kvgr4 IN s_kvgr4.

  CHECK NOT i_quot[] IS INITIAL.

*** Select Document Sales (SO) ***
  SELECT vbeln vgbel FROM vbak INTO TABLE i_sales
    FOR ALL ENTRIES IN i_quot
    WHERE vgbel = i_quot-vbeln AND
          vbeln IN s_vbeln.

  IF s_vbeln[] IS NOT INITIAL.
    PERFORM f_check_quotation.
  ENDIF.

  SELECT a~vkbur a~knkli a~vbeln a~erdat
         a~erzet a~submi a~bstnk a~bstdk
         a~ernam
         b~posnr b~matnr b~pstyv b~kwmeng
         b~kzwi1 b~abgru b~matkl b~kdmat
         c~maktx
         d~name1 d~kdgrp d~katr1 d~bzirk d~kukla
    INTO CORRESPONDING FIELDS OF TABLE i_detquot
    FROM vbak AS a JOIN vbap AS b ON a~vbeln = b~vbeln
                   JOIN makt AS c ON b~matnr = c~matnr AND
                                     c~spras = sy-langu
                   JOIN kna1vv AS d ON d~kunnr = a~knkli AND
                                       d~vkorg = p_vkorg
    FOR ALL ENTRIES IN i_quot
    WHERE a~vbeln = i_quot-vbeln AND
          b~matkl IN s_matkl     AND
          b~matnr IN s_matnr.

*** Select Routelist
  IF radio6 = 'X'.
    SELECT DISTINCT vbeln parvw a~kunnr a~adrnr b~name1
      INTO CORRESPONDING FIELDS OF TABLE i_vbpa
      FROM vbpa AS a JOIN kna1 AS b ON b~kunnr = a~kunnr
      FOR ALL ENTRIES IN i_quot
      WHERE vbeln = i_quot-vbeln
        AND parvw = 'ZS'.
  ENDIF.

  CHECK NOT i_sales[] IS INITIAL.

  SELECT DISTINCT vbeln FROM lips INTO TABLE i_delv
    FOR ALL ENTRIES IN i_sales
    WHERE vgbel = i_sales-vbeln.

*** Select Item Sales ***
  SELECT a~vbeln a~erdat a~vgbel
         b~posnr b~matnr b~pstyv b~kwmeng
         b~kzwi1 b~abgru b~vgpos
         c~maktx
    INTO CORRESPONDING FIELDS OF TABLE i_detsales
    FROM vbak AS a JOIN vbap AS b ON a~vbeln = b~vbeln
                   JOIN makt AS c ON b~matnr = c~matnr AND
                                     c~spras = sy-langu
    FOR ALL ENTRIES IN i_sales
    WHERE a~vbeln = i_sales-vbeln
      AND b~matkl IN s_matkl
      AND ( b~matnr IN s_matnr
       OR   b~matwa IN s_matnr ).

  CHECK NOT i_delv[] IS INITIAL.

  SELECT vbeln crdat
    FROM zmm_cust_rec
    INTO CORRESPONDING FIELDS OF TABLE t_cust
    FOR ALL ENTRIES IN i_delv
    WHERE vbeln EQ i_delv-vbeln.

*** Select Item Delivery ***
  SELECT a~vbeln a~wadat_ist a~erdat
         b~posnr b~matnr b~lfimg b~kzwi1
         b~vgbel b~vgpos
         c~maktx
    INTO CORRESPONDING FIELDS OF TABLE i_detdelv
    FROM likp AS a JOIN lips AS b ON a~vbeln = b~vbeln
                   JOIN makt AS c ON b~matnr = c~matnr AND
                                     c~spras = sy-langu
    FOR ALL ENTRIES IN i_sales
    WHERE b~vgbel = i_sales-vbeln
      AND b~posnr LT 900000
      AND b~matkl IN s_matkl
      AND ( b~matnr IN s_matnr
       OR   b~matwa IN s_matnr ).

  SELECT * INTO TABLE i_tvkbt
    FROM tvkbt WHERE spras EQ sy-langu
                 AND vkbur IN s_vkbur.

  SELECT * INTO TABLE i_tkukt
    FROM tkukt WHERE spras EQ sy-langu.
ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_QUOTATION
*&---------------------------------------------------------------------*
FORM f_check_quotation .
  LOOP AT i_quot.
    READ TABLE i_sales WITH KEY vgbel = i_quot-vbeln.
    IF sy-subrc NE 0.
      DELETE i_quot.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHECK_QUOTATION

*&---------------------------------------------------------------------*
*&      Form  F_CRT_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_crt_dyn_int_table USING fu_flag.
  DATA : lv_fieldname   TYPE lvc_fname,
         lv_coltext     TYPE lvc_txtcol.

  DATA : ls_dyn_fcat    TYPE lvc_s_fcat.
  DATA : ls_fieldcat    TYPE slis_fieldcat_alv.

  PERFORM f_dyn_fieldcatg USING :
    'SORT' '' '' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SORT1' '' '' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SORT2' '' '' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SORT3' '' '' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SORT4' '' '' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SORT5' '' '' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SORT6' '' '' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SORT7' '' '' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SORT8' '' '' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'INFO' '' '' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WAERS' 'VBAP' 'WAERK' 'X' '' '' '' '' '' '' '' '' '' '' ''
    '' '' '' ''.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_dyn_fieldcatg USING :
        'VKBUR' 'VBAK' 'VKBUR' '' '5' 'SOff' '' '' '' '' '' '' '' ''
        '' '' '' 'X' '',
        'VKBVV' 'KNVV' 'VKBUR' '' '6' 'SubHub' '' '' '' '' '' ''
        '' '' '' '' '' 'X' '',
        'KNKLI' 'VBAK' 'KNKLI' '' '12' 'Customer' '' '' '' '' '' '' '' '' ''
        '' '' 'X' '',
        'NAME1' 'KNA1' 'NAME1' '' '25' 'Customer Name' '' '' '' '' '' '' '' ''
        '' '' '' 'X' '',
        'KVGR4' 'KNVV' 'KVGR4' '' '4' 'Grp4' '' '' '' '' '' '' '' ''
        '' '' '' 'X' '',
        'VBELN' 'VBAK' 'VBELN' '' '10' 'Quo Number' '' '' '' '' '' ''
        '' '' '' '' '' 'X' '',
        'BSTDK' 'VBAK' 'BSTDK' '' '10' 'Quo Date' '' '' '' '' '' '' ''
        '' '' '' '' 'X' '',
        'MATNR' 'VBAP' 'MATNR' '' '9' 'PO Matnr' '' '' '' '' '' '' ''
        '' '' '' '' 'X' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '25' 'PO Material Description'
        '' '' '' '' '' '' '' '' '' '' '' 'X' '',
        'KWMENG' 'VBAP' 'KWMENG' '' '15' 'PO Qty' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'KZWI1' 'VBAP' 'KZWI1' '' '15' 'PO Amount' '' '' '' '' ''
        'WAERS' '' '' '' '' '' '' '',
        'DLNUM' 'LIPS' 'VBELN' '' '10' 'DO Number' '' '' '' '' '' '' ''
        '' '' '' '' '' '',
        'DLDAT' 'LIPS' 'ERDAT' '' '10' 'DO Date' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'CRDAT' 'ZMM_CUST_REC' 'CRDAT' '' '10' 'Rec Date'
        '' '' '' '' '' '' '' '' '' '' '' '' '',
        'DLMAT' 'LIPS' 'MATNR' '' '9' 'DO Matnr' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'DLMATX' 'MAKT' 'MAKTX' '' '25' 'DO Material Description'
        '' '' '' '' '' '' '' '' '' '' '' '' '',
        'DLQTY' 'LIPS' 'LFIMG' ''  '15'  'DO Qty' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'DLVAL' 'LIPS' 'KZWI1' ''  '15' 'DO Amount' '' '' '' '' ''
        'WAERS' '' '' '' '' '' '' '',
        'PERCEN' '' '' '' '6' 'Level %' '' '' '' '' '' '' '' '' '' '' ''
        '' ''.
    WHEN radio2.
      PERFORM f_dyn_fieldcatg USING :
        'VKBUR' 'VBAK' 'VKBUR' '' '10' 'SOff' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'VKBVV' 'KNVV' 'VKBUR' '' '10' 'SOff KNVV' '' '' '' '' '' '' '' '' ''
        '' '' 'X' '',
        'KNKLI' 'VBAK' 'KNKLI' 'X' '12' 'Customer' '' '' '' '' '' '' '' '' ''
        '' '' 'X' '',
        'NAME1' 'KNA1' 'NAME1' 'X' '25' 'Customer Name' '' '' '' '' '' '' '' ''
        '' '' '' 'X' '',
        'KVGR4' 'KNVV' 'KVGR4' 'X' '4' 'Grp4' '' '' '' '' '' '' '' ''
        '' '' '' 'X' '',
        'PRINC' '' '' '' '10' 'Principal' '' '' '' '' '' '' '' '' '' '' '' 'X'
        '',
        'MATKL' 'VBAP' 'MATKL' '' '10' 'Mat Group' '' '' '' '' '' '' '' '' ''
        '' '' 'X' '',
        'MATNR' 'VBAP' 'MATNR' '' '9' 'Material' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '25' 'Material Description' '' '' '' '' ''
        '' '' '' '' '' '' 'X' '',
        'KWMENG' 'VBAP' 'KWMENG' '' '15' 'PO Qty' '' '' '' '' '' '' '' '' ''
        '' '' '' '',
        'KZWI1' 'VBAP' 'KZWI1' '' '15' 'PO Amount' '' '' '' '' '' 'WAERS'
        '' '' '' '' '' '' '',
        'DLQTY' 'LIPS' 'LFIMG' ''  '15'  'DO Qty' '' '' '' '' '' '' '' '' ''
        '' '' '' '',
        'DLVAL' 'LIPS' 'KZWI1' ''  '15' 'DO Amount' '' '' '' '' '' 'WAERS' ''
        '' '' '' '' '' ''.
    WHEN radio3.
      PERFORM f_dyn_fieldcatg USING :
        'VKBUR' 'VBAK' 'VKBUR' '' '10' 'SOff' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'VKBVV' 'KNVV' 'VKBUR' '' '10' 'SOff KNVV' '' '' '' '' '' '' '' '' ''
        '' '' 'X' '',
        'KNKLI' 'VBAK' 'KNKLI' '' '12' 'Customer' '' '' '' '' '' '' '' '' ''
        '' '' 'X' '',
        'NAME1' 'KNA1' 'NAME1' '' '25' 'Customer Name' '' '' '' '' '' '' '' ''
        '' '' '' 'X' '',
        'KVGR4' 'KNVV' 'KVGR4' '' '4' 'Grp4' '' '' '' '' '' '' '' ''
        '' '' '' 'X' '',
        'PRINC' '' '' '' '10' 'Principal' '' '' '' '' '' '' '' '' '' '' '' 'X'
        '',
        'MATKL' 'VBAP' 'MATKL' '' '10' 'Mat Group' '' '' '' '' '' '' '' '' ''
        '' '' 'X' '',
        'MATNR' 'VBAP' 'MATNR' '' '9' 'Material' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '25' 'Material Description' '' '' '' '' '' ''
        '' '' '' '' '' 'X' '',
        'KWMENG' 'VBAP' 'KWMENG' '' '15' 'PO Qty' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'KZWI1' 'VBAP' 'KZWI1' '' '15' 'PO Amount' '' '' '' '' '' 'WAERS' '' ''
        '' '' '' '' '',
        'DLQTY' 'LIPS' 'LFIMG' ''  '15'  'DO Qty' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'DLVAL' 'LIPS' 'KZWI1' ''  '15' 'DO Amount' '' '' '' '' '' 'WAERS' ''
        '' '' '' '' '' ''.
    WHEN radio4.
      PERFORM f_dyn_fieldcatg USING :
        'PRINC' '' '' '' '10' 'Principal' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
        'MATKL' 'VBAP' 'MATKL' '' '10' 'Mat Group' '' '' '' '' '' '' '' '' ''
        '' '' 'X' '',
        'MATNR' 'VBAP' 'MATNR' '' '9' 'Material' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '25' 'Material Description' '' '' '' '' ''
        '' '' '' '' '' '' 'X' '',
        'KWMENG' 'VBAP' 'KWMENG' '' '15' 'PO Qty' '' '' '' '' '' '' '' '' ''
        '' '' '' '',
        'KZWI1' 'VBAP' 'KZWI1' '' '15' 'PO Amount' '' '' '' '' '' 'WAERS' ''
        '' '' '' '' '' '',
        'DLQTY' 'LIPS' 'LFIMG' ''  '15'  'DO Qty' '' '' '' '' '' '' '' '' ''
        '' '' '' '',
        'DLVAL' 'LIPS' 'KZWI1' ''  '15' 'DO Amount' '' '' '' '' '' 'WAERS' ''
        '' '' '' '' '' ''.
    WHEN radio5.
      IF p_summ5 IS NOT INITIAL.
        PERFORM f_dyn_fieldcatg USING :
          'VKBUR' 'VBAK' 'VKBUR' '' '10' 'SOff' '' '' '' '' '' '' '' '' ''
          '' '' 'X' '',
          'KUKLA' 'KNA1' 'KUKLA' '' '10' 'Channel' '' '' '' '' '' '' '' ''
          '' '' '' 'X' '',
          'VTEXT' 'TKUKT' 'VTEXT' '' '15' 'Channel Desc.' '' '' '' '' '' ''
          '' '' '' '' '' 'X' '',
          'VKBVV' 'KNVV' 'VKBUR' '' '10' 'SOff KNVV' '' '' '' '' '' '' ''
          '' '' '' '' 'X' '',
          'KNKLI' 'VBAK' 'KNKLI' '' '10' 'Customer' '' '' '' '' '' '' ''
          '' '' '' '' 'X' '',
          'NAME1' 'KNA1' 'NAME1' '' '25' 'Customer Name' '' '' '' '' ''
          '' '' '' '' '' '' 'X' '',
          'KVGR4' 'KNVV' 'KVGR4' '' '4' 'Grp4' '' '' '' '' ''
          '' '' '' '' '' '' 'X' '',
          'KWMENG' '' '' '' '15' 'PO Qty' 'X' '' '0' '' '' '' '' '' '' ''
          'P' '' '',
          'KZWI1' 'VBAP' 'KZWI1' '' '15' 'PO Amount' 'X' '' '' '' '' 'WAERS'
          '' '' '' '' '' '' '',
          'PODOC' '' '' '' '10' 'PO Doc' 'X' '' '' '' '' '' '' '' '' '' 'P' ''
          '',
          'POLIN' '' '' '' '10' 'Line PO' 'X' '' '' '' '' '' '' '' '' '' 'P' ''
          '',
          'DLQTY' '' '' ''  '15'  'DO Qty' 'X' '' '0' '' '' '' '' '' '' ''
          'P' '' '',
          'DLVAL' 'LIPS' 'KZWI1' ''  '15' 'DO Amount' 'X' '' '' '' '' 'WAERS'
          '' '' '' '' '' '' '',
          'DODOC' '' '' '' '10' 'DO Doc' 'X' '' '' '' '' '' '' '' '' '' 'P' ''
          '',
          'DOLIN' '' '' '' '10' 'Line DO' 'X' '' '' '' '' '' '' '' '' '' 'P' ''
          '',
          'SLQTY' '' '' '' '10' 'SL Qty(%)' 'X' '' '2' '' '' '' '' '' '' '' 'P'
          '' '',
          'SLVAL' '' '' '' '10' 'SL Amt(%)' 'X' '' '2' '' '' '' '' '' '' '' 'P'
          '' '',
          'SLLIN' '' '' '' '10' 'SL Line(%)' 'X' '' '2' '' '' '' '' '' '' '' 'P'
          '' '',
          'SLDOC' '' '' '' '10' 'SL Doc(%)' 'X' '' '2' '' '' '' '' '' '' '' 'P'
          '' ''.
      ELSE.
        PERFORM f_dyn_fieldcatg USING :
          'VBELN' 'VBAK' 'VBELN' '' '12' 'Quo Number' '' '' '' '' '' '' '' '' ''
          '' '' 'X' '',
          'BSTDK' 'VBAK' 'BSTDK' '' '10' 'Quo Date' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'MATNR' 'VBAP' 'MATNR' '' '9' 'PO Matnr' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'MAKTX' 'MAKT' 'MAKTX' '' '25' 'PO Material Description'
          '' '' '' '' '' '' '' '' '' '' '' 'X' '',
          'KWMENG' 'VBAP' 'KWMENG' '' '15' 'PO Qty' '' '' '' '' '' '' '' '' '' ''
          '' '' '',
          'KZWI1' 'VBAP' 'KZWI1' '' '15' 'PO Amount' '' '' '' '' '' 'WAERS' '' ''
          '' '' '' '' '',
          'DLNUM' 'LIPS' 'VBELN' '' '10' 'DO Number' '' '' '' '' '' '' '' '' '' ''
          '' '' '',
          'DLDAT' 'LIPS' 'ERDAT' '' '10' 'DO Date' '' '' '' '' '' '' '' '' '' ''
          '' '' '',
          'CRDAT' 'ZMM_CUST_REC' 'CRDAT' '' '10' 'Rec Date'
          '' '' '' '' '' '' '' '' '' '' '' '' '',
          'DLMAT' 'LIPS' 'MATNR' '' '9' 'DO Matnr' '' '' '' '' '' '' '' '' '' ''
          '' '' '',
          'DLMATX' 'MAKT' 'MAKTX' '' '25' 'DO Material Description'
          '' '' '' '' '' '' '' '' '' '' '' '' '',
          'DLQTY' 'LIPS' 'LFIMG' ''  '15'  'DO Qty' '' '' '' '' '' '' '' '' '' ''
          '' '' '',
          'DLVAL' 'LIPS' 'KZWI1' ''  '15' 'DO Amount' '' '' '' '' '' 'WAERS' ''
          '' '' '' '' '' '',
          'PERCEN' '' '' '' '6' 'Level %' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'LINE' '' '' '' '6' 'Line %' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'DOCU' '' '' '' '6' 'Doc. %' '' '' '' '' '' '' '' '' '' '' '' '' ''.
      ENDIF.
    WHEN radio6.
      IF p_summ6 IS NOT INITIAL.
        PERFORM f_dyn_fieldcatg USING :
          'VKBUR' 'VBAK' 'VKBUR' '' '10' 'SOff' '' '' '' '' '' '' '' '' '' ''
          '' 'X' '',
          'KUKLA' 'KNA1' 'KUKLA' '' '10' 'Channel' '' '' '' '' '' '' '' '' ''
          '' '' 'X' '',
          'VTEXT' 'TKUKT' 'VTEXT' '' '15' 'Channel Desc.' '' '' '' '' '' '' ''
          '' '' '' '' 'X' '',
          'VKBVV' 'KNVV' 'VKBUR' '' '10' 'SOff KNVV' '' '' '' '' '' '' '' '' ''
          '' '' 'X' '',
          'KUNRL' 'KNA1' 'KUNNR' '' '10' 'Routelist' '' '' '' '' '' '' '' '' ''
          '' '' 'X' '',
          'NAMRL' 'KNA1' 'NAME1' '' '25' 'RouteList Desc.' '' '' '' '' '' '' ''
          '' '' '' '' 'X' '',
          'KWMENG' '' '' '' '15' 'PO Qty' 'X' '' '0' '' '' '' '' '' '' '' 'P'
          '' '',
          'KZWI1' 'VBAP' 'KZWI1' '' '15' 'PO Amount' 'X' '' '' '' '' 'WAERS' ''
          '' '' '' '' '' '',
          'PODOC' '' '' '' '10' 'PO Doc' 'X' '' '' '' '' '' '' '' '' '' 'P'
          '' '',
          'POLIN' '' '' '' '10' 'Line PO' 'X' '' '' '' '' '' '' '' '' '' 'P'
          '' '',
          'DLQTY' '' '' ''  '15'  'DO Qty' 'X' '' '0' '' '' '' '' '' '' '' 'P'
          '' '',
          'DLVAL' 'LIPS' 'KZWI1' ''  '15' 'DO Amount' 'X' '' '' '' '' 'WAERS'
          '' '' '' '' '' '' '',
          'DODOC' '' '' '' '10' 'DO Doc' 'X' '' '' '' '' '' '' '' '' '' 'P'
          '' '',
          'DOLIN' '' '' '' '10' 'Line DO' 'X' '' '' '' '' '' '' '' '' '' 'P'
          '' '',
          'SLQTY' '' '' '' '10' 'SL Qty(%)' 'X' '' '2' '' '' '' '' '' '' ''
          'P' '' '',
          'SLVAL' '' '' '' '10' 'SL Amt(%)' 'X' '' '2' '' '' '' '' '' '' ''
          'P' '' '',
          'SLLIN' '' '' '' '10' 'SL Line(%)' 'X' '' '2' '' '' '' '' '' '' ''
          'P' '' '',
          'SLDOC' '' '' '' '10' 'SL Doc(%)' 'X' '' '2' '' '' '' '' '' '' ''
          'P' '' ''.
      ELSE.
        PERFORM f_dyn_fieldcatg USING :
          'VBELN' 'VBAK' 'VBELN' '' '12' 'Quo Number' '' '' '' '' '' '' '' ''
          '' '' '' 'X' '',
          'BSTDK' 'VBAK' 'BSTDK' '' '10' 'Quo Date' '' '' '' '' '' '' '' '' ''
          '' '' 'X' '',
          'MATNR' 'VBAP' 'MATNR' '' '9' 'PO Matnr' '' '' '' '' '' '' '' '' ''
          '' '' 'X' '',
          'MAKTX' 'MAKT' 'MAKTX' '' '25' 'PO Material Description'
          '' '' '' '' '' '' '' '' '' '' '' 'X' '',
          'KWMENG' 'VBAP' 'KWMENG' '' '15' 'PO Qty' '' '' '' '' '' '' '' '' ''
          '' '' '' '',
          'KZWI1' 'VBAP' 'KZWI1' '' '15' 'PO Amount' '' '' '' '' '' 'WAERS' ''
          '' '' '' '' '' '',
          'DLNUM' 'LIPS' 'VBELN' '' '10' 'DO Number' '' '' '' '' '' '' '' '' ''
          '' '' '' '',
          'DLDAT' 'LIPS' 'ERDAT' '' '10' 'DO Date' '' '' '' '' '' '' '' '' ''
          '' '' '' '',
          'CRDAT' 'ZMM_CUST_REC' 'CRDAT' '' '10' 'Rec Date'
          '' '' '' '' '' '' '' '' '' '' '' '' '',
          'DLMAT' 'LIPS' 'MATNR' '' '9' 'DO Matnr' '' '' '' '' '' '' '' '' ''
          '' '' '' '',
          'DLMATX' 'MAKT' 'MAKTX' '' '25' 'DO Material Description'
          '' '' '' '' '' '' '' '' '' '' '' '' '',
          'DLQTY' 'LIPS' 'LFIMG' ''  '15'  'DO Qty' '' '' '' '' '' '' '' '' ''
          '' '' '' '',
          'DLVAL' 'LIPS' 'KZWI1' ''  '15' 'DO Amount' '' '' '' '' '' 'WAERS'
          '' '' '' '' '' '' '',
          'PERCEN' '' '' '' '6' 'Level %' '' '' '' '' '' '' '' '' '' '' ''
          '' '',
          'LINE' '' '' '' '6' 'Line %' '' '' '' '' '' '' '' '' '' '' ''
          '' '',
          'DOCU' '' '' '' '6' 'Doc. %' '' '' '' '' '' '' '' '' '' '' ''
          '' ''.
      ENDIF.
    WHEN radio7.
      PERFORM f_dyn_fieldcatg USING :
        'VKBUR' 'VBAK' 'VKBUR' '' '10' 'SOff' '' '' '' '' '' '' '' '' '' ''
        '' 'X' '',
        'VKBVV' 'KNVV' 'VKBUR' '' '10' 'SOff KNVV' '' '' '' '' '' '' '' '' ''
        '' '' 'X' '',
        'VBELN' 'VBAK' 'VBELN' '' '10' 'Quo Number' '' '' '' '' '' ''
        '' '' '' '' '' 'X' '',
        'BSTDK' 'VBAK' 'BSTDK' '' '10' 'Quo Date' '' '' '' '' '' '' ''
        '' '' '' '' 'X' '',
        'KNKLI' 'VBAK' 'KNKLI' '' '12' 'Customer' '' '' '' '' '' '' '' '' ''
        '' '' '' '',
        'NAME1' 'KNA1' 'NAME1' '' '25' 'Customer Name' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'KVGR4' 'KNVV' 'KVGR4' '' '4' 'Grp4' '' '' '' '' '' '' '' ''
        '' '' '' '' '',
        'PRINC' '' '' '' '10' 'Principal' '' '' '' '' '' '' '' '' '' '' '' ''
        '',
        'MATKL' 'VBAP' 'MATKL' '' '10' 'Mat Group' '' '' '' '' '' '' '' '' ''
        '' '' '' '',
        'MATNR' 'VBAP' 'MATNR' '' '9' 'Material' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '25' 'Material Description' '' '' '' '' ''
        '' '' '' '' '' '' '' '',
        'KWMENG' 'VBAP' 'KWMENG' '' '15' 'PO Qty' '' '' '' '' '' '' '' '' ''
        '' '' '' '',
        'KZWI1' 'VBAP' 'KZWI1' '' '15' 'PO Amount' '' '' '' '' '' 'WAERS'
        '' '' '' '' '' '' '',
        'DLQTY' 'LIPS' 'LFIMG' ''  '15'  'DO Qty' '' '' '' '' '' '' '' '' ''
        '' '' '' '',
        'DLVAL' 'LIPS' 'KZWI1' ''  '15' 'DO Amount' '' '' '' '' '' 'WAERS' ''
        '' '' '' '' '' ''.
  ENDCASE.

  IF fu_flag IS NOT INITIAL.
    IF p_val IS NOT INITIAL.
      PERFORM f_dyn_fieldcatg USING :
        'LEAD1' 'VBAP' 'KZWI1' '' '15' 'Lead <= 2' '' '' '2' '' '' 'WAERS'
        '' '' '' '' '' '' '',
        'LEAD2' 'VBAP' 'KZWI1' '' '15' 'Lead = 3-4' '' '' '2' '' '' 'WAERS'
        '' '' '' '' '' '' '',
        'LEAD3' 'VBAP' 'KZWI1' '' '15' 'Lead >= 5' '' '' '2' '' '' 'WAERS'
        '' '' '' '' '' '' '',
        'UNVAL' 'VBAP' 'KZWI1' '' '15' 'Undlv Amount' '' '' '2' '' '' 'WAERS'
        '' '' '' '' '' '' ''.
    ELSE.
      PERFORM f_dyn_fieldcatg USING :
        'LEAD1Q' '' '' '' '15' 'Lead <= 2' '' '' '' '' '' '' '' '' '' '' ''
        '' '',
        'LEAD2Q' '' '' '' '15' 'Lead = 3-4' '' '' '' '' '' '' '' '' '' '' ''
        '' '',
        'LEAD3Q' '' '' '' '15' 'Lead >= 5' '' '' '' '' '' '' '' '' '' '' ''
        '' '',
        'UNQTY' '' '' '' '15' 'Undl Qty' '' '' '' '' '' '' '' '' '' '' ''
        '' ''.
    ENDIF.

    LOOP AT t_abgru.
      IF p_val IS NOT INITIAL.
        CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldname.
        PERFORM f_dyn_fieldcatg USING :
          lv_fieldname 'VBAP' 'KZWI1' '' '15' t_abgru-bezei '' '' '' '' '' 'WAERS'
          '' '' '' '' '' '' ''.
      ELSE.
        CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldname.
        PERFORM f_dyn_fieldcatg USING :
          lv_fieldname '' '' '' '15' t_abgru-bezei '' '' '' '' '' ''
          '' '' '' '' '' '' ''.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      i_style_table             = 'X'
      it_fieldcatalog           = gt_dyn_fcat
* Begin remark unicode coversion - DEVK966054
* 18.03.2020 - sol chirka
      i_length_in_byte          = 'X'
* End insert Unicode conversion - DEVK966054
    IMPORTING
      ep_table                  = gt_dyn_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.

  IF sy-subrc EQ 0.
    ASSIGN gt_dyn_table->* TO <fs_output>.
    CREATE DATA gs_line LIKE LINE OF <fs_output>.
    ASSIGN gs_line->* TO <fs_line>.
  ENDIF.

  CLEAR ls_dyn_fcat.
  LOOP AT gt_dyn_fcat INTO ls_dyn_fcat.
    MOVE-CORRESPONDING ls_dyn_fcat TO ls_fieldcat.
    ls_fieldcat-seltext_l         = ls_dyn_fcat-coltext.
    ls_fieldcat-seltext_m         = ls_dyn_fcat-coltext.
    ls_fieldcat-seltext_s         = ls_dyn_fcat-coltext.
    ls_fieldcat-reptext_ddic      = ls_dyn_fcat-coltext.
    APPEND ls_fieldcat TO fieldcat.
  ENDLOOP.
ENDFORM.                    " F_CRT_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_dyn_fieldcatg  USING    value(fu_fname)
                               value(fu_reftable)
                               value(fu_reffield)
                               value(fu_noout)
                               value(fu_outln)
                               value(fu_fltxt)
                               value(fu_dosum)
                               value(fu_hotsp)
                               value(fu_dec)
                               value(fu_waers)
                               value(fu_meins)
                               value(fu_waers_f)
                               value(fu_meins_f)
                               value(fu_checkbox)
                               value(fu_input)
                               value(fu_emphasize)
                               value(fu_inttype)
                               value(fu_fix)
                               value(fu_nosign).

  DATA: lw_dyn_fcat  TYPE  lvc_s_fcat.

  ADD 1 TO gv_pos.

  CLEAR: lw_dyn_fcat.
  lw_dyn_fcat-fieldname         = fu_fname.
  lw_dyn_fcat-ref_table         = fu_reftable.
  lw_dyn_fcat-ref_field         = fu_reffield.
  lw_dyn_fcat-no_out            = fu_noout.
  lw_dyn_fcat-outputlen         = fu_outln.
  lw_dyn_fcat-coltext           = fu_fltxt.
  lw_dyn_fcat-no_out            = fu_noout.
  lw_dyn_fcat-do_sum            = fu_dosum.
  lw_dyn_fcat-hotspot           = fu_hotsp.
  lw_dyn_fcat-decimals          = fu_dec.
  lw_dyn_fcat-currency          = fu_waers.
  lw_dyn_fcat-quantity          = fu_meins.
  lw_dyn_fcat-qfieldname        = fu_meins_f.
  lw_dyn_fcat-cfieldname        = fu_waers_f.
  lw_dyn_fcat-checkbox          = fu_checkbox.
  lw_dyn_fcat-emphasize         = fu_emphasize.
  lw_dyn_fcat-col_pos           = gv_pos.
  lw_dyn_fcat-inttype           = fu_inttype.
  lw_dyn_fcat-fix_column        = fu_fix.
  lw_dyn_fcat-no_sign           = fu_nosign.
  APPEND lw_dyn_fcat TO gt_dyn_fcat.
  CLEAR lw_dyn_fcat.
ENDFORM.                    " F_DYN_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_OUTPUT_ALV
*&---------------------------------------------------------------------*
FORM f_output_alv .
  DATA : lv_func(22).

  PERFORM f_clear_alv_data.
  PERFORM f_build_layout      USING d_layout.
  PERFORM f_build_sortfield   USING sortcat[].
  PERFORM f_build_event       TABLES evtab[].

  CASE 'X'.
    WHEN radio5.
      IF p_summ5 IS NOT INITIAL.
        lv_func    = 'REUSE_ALV_GRID_DISPLAY'.
        PERFORM comment_build USING t_list_top_of_page[]
                                    'by Sales Office, Customer, Quotation'.
      ELSE.
        lv_func    = 'REUSE_ALV_LIST_DISPLAY'.
      ENDIF.
    WHEN radio6.
      IF p_summ6 IS NOT INITIAL.
        lv_func    = 'REUSE_ALV_GRID_DISPLAY'.
        PERFORM comment_build USING t_list_top_of_page[]
                                    'by Sales Office, Route List, Quotation'.
      ELSE.
        lv_func    = 'REUSE_ALV_LIST_DISPLAY'.
      ENDIF.
    WHEN OTHERS.
      lv_func    = 'REUSE_ALV_LIST_DISPLAY'.
  ENDCASE.

  CALL FUNCTION lv_func
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = e_user_command
      is_variant               = disvariant
      is_layout                = d_layout
      it_fieldcat              = fieldcat[]
      it_events                = evtab[]
      is_print                 = d_print
      it_sort                  = sortcat[]
      i_save                   = 'A'
      i_default                = 'X'
    IMPORTING
      e_exit_caused_by_caller  = g_exit_caused_by_caller
      es_exit_caused_by_user   = gs_exit_caused_by_user
    TABLES
      t_outtab                 = <fs_output>
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_OUTPUT_ALV

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV_DATA
*&---------------------------------------------------------------------*
FORM f_clear_alv_data .
  CLEAR : t_alv_fieldcat,
          t_alv_event,
          t_events,
          t_alv_isort,
          t_alv_filter,
          t_event_exit,
          d_alv_isort,
          d_alv_variant,
          d_alv_list_scroll,
          d_alv_sort_postn,
          d_alv_keyinfo,
          d_alv_fieldcat,
          d_alv_formname,
          d_alv_ucomm,
          d_alv_print,
          d_alv_repid,
          d_alv_tabix,
          d_alv_subrc,
          d_alv_screen_start_column,
          d_alv_screen_start_line,
          d_alv_screen_end_column,
          d_alv_screen_end_line,
          d_alv_layout,
          d_layout,
          d_repid,
          d_print.

  REFRESH : t_alv_fieldcat,
            t_alv_event,
            t_events,
            t_alv_isort,
            t_alv_filter,
            t_event_exit.

  d_repid = sy-repid.
ENDFORM.                    " F_CLEAR_ALV_DATA

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout  USING    fu_layout TYPE slis_layout_alv.

  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-info_fieldname     = 'INFO'.
  fu_layout-no_colhead         = space.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT
*&---------------------------------------------------------------------*
FORM f_build_event  TABLES   ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    " F_BUILD_EVENT

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
    WHEN '&IC1'.
      IF fu_selfield-fieldname = 'VBELN'.
        SET PARAMETER ID 'AUN' FIELD fu_selfield-value.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  CASE 'X'.
    WHEN radio5.
      IF p_summ5 IS NOT INITIAL.
        SET PF-STATUS 'STANDARD'.
      ENDIF.
    WHEN radio6.
      IF p_summ6 IS NOT INITIAL.
        SET PF-STATUS 'STANDARD'.
      ENDIF.
    WHEN radio7.
      SET PF-STATUS 'RADIO7'.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_SET_PF_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD
*&---------------------------------------------------------------------*
FORM f_build_sortfield  USING    fu_sort TYPE slis_t_sortinfo_alv.

  DATA: ld_sort TYPE slis_sortinfo_alv.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_data_sort USING : 'SORT' 'X' 'UL' '' '',
                                  'SORT6' 'X' 'UL' '' '',
                                  'SORT5' 'X' 'UL' '' '',
                                  'SORT4' 'X' 'UL' '' '',
                                  'SORT3' 'X' 'UL' '' '',
                                  'SORT2' 'X' 'UL' '' '',
                                  'SORT1' 'X' '' '' ''.
    WHEN radio2.
      PERFORM f_data_sort USING : 'SORT' 'X' 'UL' '' '',
                                  'SORT8' 'X' 'UL' '' '',
                                  'SORT7' 'X' 'UL' '' '',
                                  'SORT6' 'X' 'UL' '' '',
                                  'SORT5' 'X' 'UL' '' '',
                                  'SORT4' 'X' 'UL' '' '',
                                  'SORT3' 'X' 'UL' '' '',
                                  'SORT2' 'X' 'UL' '' '',
                                  'SORT1' 'X' 'UL' '' ''.
    WHEN radio3.
      PERFORM f_data_sort USING : 'SORT' 'X' 'UL' '' '',
                                  'SORT8' 'X' 'UL' '' '',
                                  'SORT7' 'X' 'UL' '' '',
                                  'SORT6' 'X' 'UL' '' '',
                                  'SORT5' 'X' 'UL' '' '',
                                  'SORT4' 'X' 'UL' '' '',
                                  'SORT3' 'X' 'UL' '' '',
                                  'SORT2' 'X' 'UL' '' '',
                                  'SORT1' 'X' 'UL' '' ''.
    WHEN radio4.
      PERFORM f_data_sort USING : 'SORT' 'X' 'UL' '' '',
                                  'SORT8' 'X' 'UL' '' '',
                                  'SORT7' 'X' 'UL' '' '',
                                  'SORT6' 'X' 'UL' '' '',
                                  'SORT5' 'X' 'UL' '' '',
                                  'SORT4' 'X' 'UL' '' '',
                                  'SORT3' 'X' 'UL' '' '',
                                  'SORT2' 'X' 'UL' '' '',
                                  'SORT1' 'X' 'UL' '' ''.
    WHEN radio5.
      IF p_summ5 IS INITIAL.
        PERFORM f_data_sort USING : 'SORT' 'X' 'UL' '' '',
                                    'SORT6' 'X' 'UL' '' '',
                                    'SORT5' 'X' 'UL' '' '',
                                    'SORT4' 'X' 'UL' '' '',
                                    'SORT3' 'X' 'UL' '' '',
                                    'SORT2' 'X' 'UL' '' '',
                                    'SORT1' 'X' '' '' ''.
      ELSE.
        PERFORM f_data_sort USING : 'KNKLI' 'X' '' '' '03',
                                    'KUKLA' 'X' '' 'X' '02',
                                    'VKBUR' 'X' '' 'X' '01'.
      ENDIF.

    WHEN radio6.
      IF p_summ6 IS INITIAL.
        PERFORM f_data_sort USING : 'SORT' 'X' 'UL' '' '',
                                    'SORT6' 'X' 'UL' '' '',
                                    'SORT5' 'X' 'UL' '' '',
                                    'SORT4' 'X' 'UL' '' '',
                                    'SORT3' 'X' 'UL' '' '',
                                    'SORT2' 'X' 'UL' '' '',
                                    'SORT1' 'X' '' '' ''.
      ELSE.
        PERFORM f_data_sort USING : 'KUNRL' 'X' '' '' '03',
                                    'KUKLA' 'X' '' 'X' '02',
                                    'VKBUR' 'X' '' 'X' '01'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_BUILD_SORTFIELD

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.
  DATA : lv_line1   TYPE tline-tdline,
         lv_line2   TYPE tline-tdline,
         lv_line3   TYPE tline-tdline.
  DATA : lv_low(10),
         lv_high(10).

  CASE 'X'.
    WHEN radio1.
      CONCATENATE sy-title 'by Sales Office, Customer, Quotation'
      INTO sy-title SEPARATED BY space.
    WHEN radio2.
      CONCATENATE sy-title
      'by Sales Office, Customer, Principal, Material Group, Material '
      INTO sy-title SEPARATED BY space.
    WHEN radio3.
      CONCATENATE sy-title
      'by Sales Office, Principal, Material Group, Material '
      INTO sy-title SEPARATED BY space.
    WHEN radio4.
      CONCATENATE sy-title
      'by Principal, Material Group, Material '
      INTO sy-title SEPARATED BY space.
    WHEN radio5.
      IF p_summ5 IS INITIAL.
        CONCATENATE sy-title 'by Sales Office, Customer, Quotation'
        INTO sy-title SEPARATED BY space.
      ENDIF.
    WHEN radio6.
      IF p_summ6 IS INITIAL.
        CONCATENATE sy-title 'by Sales Office, Route List, Quotation'
        INTO sy-title SEPARATED BY space.
      ENDIF.
  ENDCASE.

  IF p_val = 'X'.
    lv_line3  = 'By Value'.
  ELSE.
    lv_line3  = 'By Quantity'.
  ENDIF.

  IF s_erdat-high IS INITIAL.
    WRITE s_erdat-low TO lv_low DD/MM/YYYY.
    CONCATENATE 'Period : ' lv_low INTO lv_line2
    SEPARATED BY space.
  ELSE.
    WRITE s_erdat-low TO lv_low DD/MM/YYYY.
    WRITE s_erdat-high TO lv_high DD/MM/YYYY.
    CONCATENATE 'Period : ' lv_low 'to' lv_high INTO lv_line2
    SEPARATED BY space.
  ENDIF.

  CASE 'X'.
    WHEN radio5.
      IF p_summ5 IS NOT INITIAL.
        CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
          EXPORTING
            it_list_commentary = t_list_top_of_page.

        PERFORM f_modify_subtotal.
      ELSE.
        PERFORM f_hdr_uline.
        PERFORM f_hdr_line1 USING sy-title.
        PERFORM f_hdr_line2 USING lv_line2.
        PERFORM f_hdr_line3 USING lv_line3.
        PERFORM f_hdr_uline.
      ENDIF.

    WHEN radio6.
      IF p_summ6 IS NOT INITIAL.
        CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
          EXPORTING
            it_list_commentary = t_list_top_of_page.

        PERFORM f_modify_subtotal.
      ELSE.
        PERFORM f_hdr_uline.
        PERFORM f_hdr_line1 USING sy-title.
        PERFORM f_hdr_line2 USING lv_line2.
        PERFORM f_hdr_line3 USING lv_line3.
        PERFORM f_hdr_uline.
      ENDIF.

    WHEN OTHERS.
      PERFORM f_hdr_uline.
      PERFORM f_hdr_line1 USING sy-title.
      PERFORM f_hdr_line2 USING lv_line2.
      PERFORM f_hdr_line3 USING lv_line3.
      PERFORM f_hdr_uline.
  ENDCASE.
ENDFORM.                    "F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_STOCK_OUTS
*&---------------------------------------------------------------------*
FORM f_check_stock_outs .
  DATA : ls_subttl   TYPE ty_subttl,
         lv_index    LIKE sy-tabix,
         lv_abgru    LIKE vbap-abgru,
         lv_stkout   LIKE vbap-kzwi1.

  SORT i_detquot BY vkbur knkli vbeln matnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.

  LOOP AT i_detquot.
    lv_index = sy-tabix.
    CLEAR : i_detsales, i_detdelv, ls_subttl, lv_abgru, lv_stkout.

    lv_abgru = i_detquot-abgru.

    READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                   posnr = i_detquot-posnr
                          BINARY SEARCH.
    IF sy-subrc = 0.
      lv_abgru = i_detsales-abgru.
    ENDIF.

    READ TABLE i_detdelv WITH KEY vgbel = i_detsales-vbeln
                                  vgpos = i_detsales-posnr
                         BINARY SEARCH.
    IF sy-subrc = 0.
      ls_subttl-unqty = i_detquot-kwmeng - i_detsales-kwmeng.
      ls_subttl-unval = i_detquot-kzwi1 - i_detsales-kzwi1.
    ELSE.
      IF i_detsales-vbeln IS INITIAL.
        ls_subttl-unqty = i_detquot-kwmeng.
        ls_subttl-unval = i_detquot-kzwi1.
      ENDIF.
    ENDIF.

    IF ls_subttl-unqty NE 0 AND
      i_detdelv-vbeln IS NOT INITIAL.
      lv_abgru = '00'.
    ENDIF.

    IF lv_abgru = '00'.
      lv_stkout = ls_subttl-unval.
    ENDIF.

    IF lv_stkout IS INITIAL.
      DELETE i_detquot INDEX lv_index .
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHECK_STOCK_OUTS

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA_RADIO1
*&---------------------------------------------------------------------*
FORM f_proses_data_radio1 .
  DATA : lt_detquot1  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot2  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot3  LIKE i_detquot OCCURS 0 WITH HEADER LINE.

  DATA : lv_abgru     TYPE vbap-abgru,
         lv_percen    TYPE p DECIMALS 2,
         lv_leadt     TYPE i,
         lv_fieldnm(20),
         lv_maktx     TYPE makt-maktx.

  DATA : ls_sort      TYPE ty_sort,
         ls_knvv      LIKE LINE OF i_knvv.

  DATA : ls_line 	    TYPE REF TO data.

  DATA : ls_subttl1   TYPE ty_subttl,
         ls_subttl2   TYPE ty_subttl,
         ls_subttl3   TYPE ty_subttl,
         ls_subttl4   TYPE ty_subttl,
         ls_split     TYPE ty_subttl.

  SORT i_detquot BY vkbur knkli vbeln matnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.

  lt_detquot1[] = i_detquot[].
  SORT lt_detquot1 BY vkbur knkli vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_detquot1 COMPARING vkbur knkli vbeln.
  lt_detquot2[] = lt_detquot1[].
  SORT lt_detquot2 BY vkbur knkli.
  DELETE ADJACENT DUPLICATES FROM lt_detquot2 COMPARING vkbur knkli.
  lt_detquot3[] = lt_detquot2[].
  SORT lt_detquot3 BY vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_detquot3 COMPARING vkbur.

  CREATE DATA ls_line LIKE LINE OF <fs_output>.
  ASSIGN ls_line->* TO <fs_subttl5>.

  CREATE DATA ls_line LIKE LINE OF <fs_output>.
  ASSIGN ls_line->* TO <fs_subttl4>.
  ls_sort-sort = 1.
  LOOP AT lt_detquot3.
    CREATE DATA ls_line LIKE LINE OF <fs_output>.
    ASSIGN ls_line->* TO <fs_subttl3>.
    ADD 1 TO ls_sort-sort5.
    ADD 1 TO ls_sort-sort6.
    LOOP AT lt_detquot2 WHERE vkbur = lt_detquot3-vkbur.
      CREATE DATA ls_line LIKE LINE OF <fs_output>.
      ASSIGN ls_line->* TO <fs_subttl2>.
      ADD 1 TO ls_sort-sort3.
      ADD 1 TO ls_sort-sort4.
      LOOP AT lt_detquot1 WHERE vkbur = lt_detquot2-vkbur
                            AND knkli = lt_detquot2-knkli.

        CREATE DATA ls_line LIKE LINE OF <fs_output>.
        ASSIGN ls_line->* TO <fs_subttl1>.
        ADD 1 TO ls_sort-sort2.

        LOOP AT i_detquot WHERE vkbur = lt_detquot1-vkbur
                            AND knkli = lt_detquot1-knkli
                            AND vbeln = lt_detquot1-vbeln.

          ADD 1 TO ls_sort-sort1.
          lv_abgru  = i_detquot-abgru.

          PERFORM f_hidden_column USING ls_sort '' 'IDR'.

          CLEAR ls_knvv.
          READ TABLE i_knvv INTO ls_knvv WITH KEY kunnr = i_detquot-knkli.

          PERFORM f_po_column USING i_detquot-vkbur ls_knvv-vkbur
                                    i_detquot-vbeln i_detquot-bstdk
                                    i_detquot-matnr i_detquot-maktx
                                    i_detquot-kwmeng i_detquot-kzwi1
                                    i_detquot-knkli i_detquot-name1 '' ''
                                    ls_knvv-kvgr4.

          ADD i_detquot-kwmeng TO ls_subttl1-poqty.
          ADD i_detquot-kzwi1 TO ls_subttl1-poval.

          CLEAR i_detsales.
          READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                         vgpos = i_detquot-posnr
                                BINARY SEARCH.
*          IF sy-subrc <> 0.
*            IF i_detquot-erdat >= '20201001' AND
*              p_vkorg = '8020'.
*              CLEAR i_detsales.
*              READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
*                                             posnr = i_detquot-posnr.
*            ENDIF.
*          ENDIF.

          CLEAR i_detdelv.
          READ TABLE i_detdelv WITH KEY vgbel = i_detsales-vbeln
                                        vgpos = i_detsales-posnr
                               BINARY SEARCH.

          CLEAR t_cust.
          READ TABLE t_cust WITH KEY vbeln = i_detdelv-vbeln.

          IF i_detdelv-vbeln IS NOT INITIAL.
            PERFORM f_do_column USING i_detdelv-vbeln i_detdelv-erdat
                                      t_cust-crdat i_detdelv-matnr
                                      i_detdelv-maktx i_detsales-kwmeng
                                      i_detsales-kzwi1.

            ADD i_detsales-kwmeng TO ls_subttl1-doqty.
            ADD i_detsales-kzwi1 TO ls_subttl1-doval.

            IF p_val = 'X'.
              IF i_detquot-kzwi1 IS INITIAL.
                lv_percen = 0.
              ELSE.
                lv_percen = ( i_detsales-kzwi1 / i_detquot-kzwi1 ) * 100.
              ENDIF.
            ELSE.
              IF i_detquot-kzwi1 IS INITIAL.
                lv_percen = 0.
              ELSE.
                lv_percen = ( i_detsales-kwmeng / i_detquot-kwmeng  ) * 100.
              ENDIF.
            ENDIF.

            PERFORM f_percen_column USING lv_percen '' ''.

            IF t_cust-crdat IS INITIAL.
              ls_split-6q = i_detsales-kwmeng.
              ls_split-6v = i_detsales-kzwi1.
            ELSE.
              lv_leadt = t_cust-crdat - i_detquot-bstdk.
              IF lv_leadt LE 2.
                ls_split-1q = i_detsales-kwmeng.
                ls_split-1v = i_detsales-kzwi1.
              ELSEIF lv_leadt GE 3 AND lv_leadt LE 4.
                ls_split-2q = i_detsales-kwmeng.
                ls_split-2v = i_detsales-kzwi1.
              ELSEIF lv_leadt GE 5.
                ls_split-3q = i_detsales-kwmeng.
                ls_split-3v = i_detsales-kzwi1.
              ENDIF.
            ENDIF.

            ls_split-unqty  = i_detquot-kwmeng - i_detsales-kwmeng.
            ls_split-unval  = i_detquot-kzwi1 - i_detsales-kzwi1.

            IF ls_split-unqty < 0 OR
                ls_split-unval < 0.
              CLEAR : ls_split-unqty, ls_split-unval.
            ENDIF.
          ELSE.
            IF i_detsales-vbeln IS INITIAL.
              ls_split-unqty  = i_detquot-kwmeng.
              ls_split-unval  = i_detquot-kzwi1.
            ELSE.
              IF lv_abgru IS NOT INITIAL.
                ls_split-unqty  = i_detquot-kwmeng.
                ls_split-unval  = i_detquot-kzwi1.
              ENDIF.
            ENDIF.
          ENDIF.

          IF p_val = 'X'.
            PERFORM f_value_column USING 'IDR' ls_split-1v ls_split-2v
                                         ls_split-3v ls_split-unval ''.
            ADD ls_split-1v TO ls_subttl1-1v.
            ADD ls_split-2v TO ls_subttl1-2v.
            ADD ls_split-3v TO ls_subttl1-3v.
            ADD ls_split-unval TO ls_subttl1-unval.
          ELSE.
            PERFORM f_quantity_column USING '0' ls_split-1q ls_split-2q
                                            ls_split-3q ls_split-unqty.
            ADD ls_split-1q TO ls_subttl1-1q.
            ADD ls_split-2q TO ls_subttl1-2q.
            ADD ls_split-3q TO ls_subttl1-3q.
            ADD ls_split-unqty TO ls_subttl1-unqty.
          ENDIF.

          IF lv_abgru IS INITIAL.
            lv_abgru = '99'.
          ENDIF.

          LOOP AT t_abgru.
            IF p_val = 'X'.
              CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
              ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
              ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl1> TO <fs_st1>.
              IF lv_abgru = t_abgru-abgru.
                <fs> = ls_split-unval.
                ADD ls_split-unval TO <fs_st1>.
              ENDIF.
            ELSE.
              CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
              ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
              ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl1> TO <fs_st1>.
              IF lv_abgru = t_abgru-abgru.
                WRITE ls_split-unqty TO <fs> DECIMALS 0.
*                <fs> = ls_split-unqty.
                ADD ls_split-unqty TO <fs_st1>.
              ENDIF.
            ENDIF.
          ENDLOOP.

          APPEND <fs_line> TO <fs_output>.
          CLEAR : <fs_line>.
          CLEAR : lv_abgru, ls_split.
        ENDLOOP.

        ADD 1 TO ls_sort-sort1.
        ADD 1 TO ls_sort-sort2.

        CONCATENATE '*    Total PO' lt_detquot1-vbeln INTO lv_maktx
        SEPARATED BY space.

        PERFORM f_subtotal1 USING lv_maktx 'C30' 'X' ls_subttl1
                            CHANGING ls_sort.

        PERFORM f_percen1 USING 'C30' 'X' ls_subttl1 '2'
                          CHANGING ls_sort.

        PERFORM f_calculate USING '1' ls_subttl1
                            CHANGING ls_subttl2.

        CLEAR : ls_subttl1.
      ENDLOOP.

      ADD 1 TO ls_sort-sort3.

      CONCATENATE '**   Total' lt_detquot2-knkli INTO lv_maktx
      SEPARATED BY space.

      PERFORM f_subtotal2 USING lv_maktx 'C31' 'X' ls_subttl2
                          CHANGING ls_sort.

      PERFORM f_percen2 USING 'C31' 'X' ls_subttl2 '2'
                        CHANGING ls_sort.

      PERFORM f_calculate USING '2' ls_subttl2
                          CHANGING ls_subttl3.

      CLEAR : ls_subttl2.
    ENDLOOP.

    ADD 1 TO ls_sort-sort5.

    CONCATENATE '***  Total Sloff' lt_detquot3-vkbur INTO lv_maktx
    SEPARATED BY space.

    PERFORM f_subtotal3 USING lv_maktx 'C70' 'X' ls_subttl3
                        CHANGING ls_sort.

    PERFORM f_percen3 USING 'C70' 'X' ls_subttl3 '2'
                      CHANGING ls_sort.

    PERFORM f_calculate USING '3' ls_subttl3
                        CHANGING ls_subttl4.

    CLEAR : ls_subttl3.
  ENDLOOP.

  ls_sort-sort = 2.

  lv_maktx = '**** Grand Total'.

  PERFORM f_subtotal4 USING lv_maktx 'C71' 'X' ls_subttl4
                      CHANGING ls_sort.

  PERFORM f_percen4 USING 'C71' 'X' ls_subttl4 '2'
                    CHANGING ls_sort.
ENDFORM.                    " F_PROSES_DATA_RADIO1

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA_RADIO2
*&---------------------------------------------------------------------*
FORM f_proses_data_radio2 .
  DATA : lt_detquot1  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot2  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot3  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot4  LIKE i_detquot OCCURS 0 WITH HEADER LINE.

  DATA : lv_abgru     TYPE vbap-abgru,
         lv_leadt     TYPE i,
         lv_fieldnm(20),
         lv_maktx     TYPE makt-maktx.

  DATA : ls_line 	    TYPE REF TO data,
         ls_knvv      LIKE LINE OF i_knvv.

  DATA : ls_sort      TYPE ty_sort.

  DATA : ls_subttl    TYPE ty_subttl,
         ls_subttl1   TYPE ty_subttl,
         ls_subttl2   TYPE ty_subttl,
         ls_subttl3   TYPE ty_subttl,
         ls_subttl4   TYPE ty_subttl,
         ls_subttl5   TYPE ty_subttl.

  DATA : ls_total     TYPE ty_subttl.
  DATA : lv_kwmeng    TYPE vbap-kwmeng,
         lv_kzwi1     TYPE vbap-kzwi1.

  SORT i_detquot BY vkbur knkli princ matkl matnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.

  lt_detquot1[] = i_detquot[].
  SORT lt_detquot1 BY vkbur princ matkl matnr.
  DELETE ADJACENT DUPLICATES FROM lt_detquot1
  COMPARING vkbur princ matkl matnr.
  lt_detquot2[] = lt_detquot1[].
  SORT lt_detquot2 BY vkbur princ matkl.
  DELETE ADJACENT DUPLICATES FROM lt_detquot2
  COMPARING vkbur princ matkl.
  lt_detquot3[] = lt_detquot2[].
  SORT lt_detquot3 BY vkbur princ.
  DELETE ADJACENT DUPLICATES FROM lt_detquot3
  COMPARING vkbur princ.
  lt_detquot4[] = lt_detquot3[].
  SORT lt_detquot4 BY vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_detquot4
  COMPARING vkbur.

  CREATE DATA ls_line LIKE LINE OF <fs_output>.
  ASSIGN ls_line->* TO <fs_subttl6>.

  CREATE DATA ls_line LIKE LINE OF <fs_output>.
  ASSIGN ls_line->* TO <fs_subttl5>.
  CREATE DATA ls_line LIKE LINE OF <fs_output>.
  ASSIGN ls_line->* TO <fs_subttl4>.
  ls_sort-sort = 1.

  LOOP AT lt_detquot4.
    CREATE DATA ls_line LIKE LINE OF <fs_output>.
    ASSIGN ls_line->* TO <fs_subttl3>.
    ADD 1 TO ls_sort-sort6.
    ADD 1 TO ls_sort-sort5.
    LOOP AT lt_detquot3 WHERE vkbur = lt_detquot4-vkbur.
      CREATE DATA ls_line LIKE LINE OF <fs_output>.
      ASSIGN ls_line->* TO <fs_subttl2>.
      ADD 1 TO ls_sort-sort3.
      ADD 1 TO ls_sort-sort4.
      LOOP AT lt_detquot2 WHERE vkbur = lt_detquot3-vkbur
                            AND princ = lt_detquot3-princ.
        CREATE DATA ls_line LIKE LINE OF <fs_output>.
        ASSIGN ls_line->* TO <fs_subttl1>.

        ADD 1 TO ls_sort-sort1.
        ADD 1 TO ls_sort-sort2.

        LOOP AT lt_detquot1 WHERE vkbur = lt_detquot2-vkbur
                              AND princ = lt_detquot2-princ
                              AND matkl = lt_detquot2-matkl.
          CREATE DATA ls_line LIKE LINE OF <fs_output>.
          ASSIGN ls_line->* TO <fs_sub>.

          CLEAR ls_subttl.
          LOOP AT i_detquot WHERE vkbur = lt_detquot1-vkbur
                              AND princ = lt_detquot1-princ
                              AND matkl = lt_detquot1-matkl
                              AND matnr = lt_detquot1-matnr.
            lv_abgru  = i_detquot-abgru.

            PERFORM f_hidden_column USING ls_sort '' 'IDR'.

            ADD i_detquot-kwmeng TO ls_subttl-poqty.
            ADD i_detquot-kzwi1 TO ls_subttl-poval.

            CLEAR ls_knvv.
            READ TABLE i_knvv INTO ls_knvv WITH KEY kunnr = i_detquot-knkli.

            PERFORM f_po_column USING i_detquot-vkbur ls_knvv-vkbur '' ''
                                      i_detquot-matnr i_detquot-maktx
                                      ls_subttl-poqty ls_subttl-poval
                                      i_detquot-knkli i_detquot-name1
                                      i_detquot-princ i_detquot-matkl
                                      ls_knvv-kvgr4.

            CLEAR i_detsales.
            READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                           vgpos = i_detquot-posnr
                                  BINARY SEARCH.
            IF sy-subrc <> 0.
              IF i_detquot-erdat >= '20201001' AND
                p_vkorg = '8020'.
                CLEAR i_detsales.
                READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                               posnr = i_detquot-posnr.
              ENDIF.
            ENDIF.

            CLEAR i_detdelv.
            READ TABLE i_detdelv WITH KEY vgbel = i_detsales-vbeln
                                          vgpos = i_detsales-posnr
                                 BINARY SEARCH.

            CLEAR t_cust.
            READ TABLE t_cust WITH KEY vbeln = i_detdelv-vbeln.

            IF i_detdelv-vbeln IS NOT INITIAL.
              ADD i_detsales-kwmeng TO ls_subttl-doqty.
              ADD i_detsales-kzwi1 TO ls_subttl-doval.

              PERFORM f_do_column USING '' '' '' '' ''
                                        ls_subttl-doqty ls_subttl-doval.

              IF t_cust-crdat IS INITIAL.
                ADD i_detsales-kwmeng TO ls_subttl-6q.
                ADD i_detsales-kzwi1 TO ls_subttl-6v.
              ELSE.
                lv_leadt = t_cust-crdat - i_detquot-bstdk.
                IF lv_leadt LE 2.
                  ADD i_detsales-kwmeng TO ls_subttl-1q.
                  ADD i_detsales-kzwi1 TO ls_subttl-1v.
                ELSEIF lv_leadt GE 3 AND lv_leadt LE 4.
                  ADD i_detsales-kwmeng TO ls_subttl-2q.
                  ADD i_detsales-kzwi1 TO ls_subttl-2v.
                ELSEIF lv_leadt GE 5.
                  ADD i_detsales-kwmeng TO ls_subttl-3q.
                  ADD i_detsales-kzwi1 TO ls_subttl-3v.
                ENDIF.
              ENDIF.

              CLEAR : lv_kwmeng, lv_kzwi1.
              lv_kwmeng = i_detquot-kwmeng - i_detsales-kwmeng.
              lv_kzwi1  = i_detquot-kzwi1 - i_detsales-kzwi1.

              PERFORM f_undelivered_calc USING lv_kwmeng lv_kzwi1
                                               ls_subttl-unqty i_detquot-kwmeng
                                               i_detsales-kwmeng
                                               ls_subttl-unval i_detquot-kzwi1
                                               i_detsales-kzwi1
                                        CHANGING ls_subttl-unqty ls_subttl-unval.

*              IF lv_kwmeng > 0.
*              ls_subttl-unqty  = ls_subttl-unqty + ( i_detquot-kwmeng - i_detsales-kwmeng ).
*              ls_subttl-unval  = ls_subttl-unval + ( i_detquot-kzwi1 - i_detsales-kzwi1 ).
*              ENDIF.

              IF lv_kwmeng < 0 OR
                lv_kzwi1 < 0.
                CLEAR : lv_kwmeng, lv_kzwi1.
              ENDIF.
            ELSE.
              IF i_detsales-vbeln IS INITIAL.
                ADD i_detquot-kwmeng TO ls_subttl-unqty.
                ADD i_detquot-kzwi1 TO ls_subttl-unval.
                lv_kwmeng = i_detquot-kwmeng.
                lv_kzwi1  = i_detquot-kzwi1.
              ELSE.
                IF lv_abgru IS NOT INITIAL.
                  ADD i_detquot-kwmeng TO ls_subttl-unqty.
                  ADD i_detquot-kzwi1 TO ls_subttl-unval.
                  lv_kwmeng = i_detquot-kwmeng.
                  lv_kzwi1  = i_detquot-kzwi1.
                ENDIF.
              ENDIF.
            ENDIF.

            IF p_val = 'X'.
              PERFORM f_value_column USING 'IDR' ls_subttl-1v ls_subttl-2v
                                           ls_subttl-3v ls_subttl-unval ''.
            ELSE.
              PERFORM f_quantity_column USING '0' ls_subttl-1q ls_subttl-2q
                                              ls_subttl-3q ls_subttl-unqty.
            ENDIF.

            IF lv_abgru IS INITIAL.
              lv_abgru = '99'.
            ENDIF.

            LOOP AT t_abgru.
              IF p_val = 'X'.
                CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
                ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
                IF lv_abgru = t_abgru-abgru.
                  IF lv_kzwi1 IS NOT INITIAL.
*                    ADD i_detquot-kzwi1 TO <fs>.
                    ADD lv_kzwi1 TO <fs>.
                    ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_sub> TO <fs_s>.
                    <fs_s> = <fs>.
                  ENDIF.
                ENDIF.
              ELSE.
                CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
                ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
                IF lv_abgru = t_abgru-abgru.
                  IF lv_kwmeng IS NOT INITIAL.
*                    ADD i_detquot-kwmeng TO <fs>.
                    ADD lv_kwmeng TO <fs>.
                    ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_sub> TO <fs_s>.
                    <fs_s> = <fs>.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDLOOP.

          IF p_total2 IS INITIAL.
            APPEND <fs_line> TO <fs_output>.
          ENDIF.
          CLEAR : <fs_line>.

          PERFORM f_calculate USING '0' ls_subttl
                              CHANGING ls_subttl1.

          CLEAR : lv_abgru, ls_subttl, ls_total.
        ENDLOOP.

        ADD 1 TO ls_sort-sort2.

        CONCATENATE '*    Total' lt_detquot2-matkl INTO lv_maktx
        SEPARATED BY space.

        PERFORM f_subtotal1 USING lv_maktx 'C30' 'X' ls_subttl1
                            CHANGING ls_sort.

        PERFORM f_percen1 USING 'C30' 'X' ls_subttl1 '2'
                          CHANGING ls_sort.

        PERFORM f_calculate USING '1' ls_subttl1
                            CHANGING ls_subttl2.

        CLEAR : ls_subttl1.
      ENDLOOP.

      ADD 1 TO ls_sort-sort4.

      CONCATENATE '**   Total' lt_detquot3-princ INTO lv_maktx
      SEPARATED BY space.

      PERFORM f_subtotal2 USING lv_maktx 'C31' 'X' ls_subttl2
                          CHANGING ls_sort.

      PERFORM f_percen2 USING 'C31' 'X' ls_subttl2 '2'
                        CHANGING ls_sort.

      PERFORM f_calculate USING '2' ls_subttl2
                          CHANGING ls_subttl3.

      CLEAR : ls_subttl2.
    ENDLOOP.

    ADD 1 TO ls_sort-sort6.

    CONCATENATE '***  Total' lt_detquot4-vkbur INTO lv_maktx
    SEPARATED BY space.

    PERFORM f_subtotal3 USING lv_maktx 'C70' 'X' ls_subttl3
                        CHANGING ls_sort.

    PERFORM f_percen3 USING 'C70' 'X' ls_subttl3 '2'
                      CHANGING ls_sort.

    PERFORM f_calculate USING '3' ls_subttl3
                        CHANGING ls_subttl4.

    CLEAR : ls_subttl3.
  ENDLOOP.

  ls_sort-sort = 2.

  lv_maktx = '**** Grand Total'.

  PERFORM f_subtotal4 USING lv_maktx 'C71' 'X' ls_subttl4
                      CHANGING ls_sort.

  PERFORM f_percen4 USING 'C71' 'X' ls_subttl4 '2'
                    CHANGING ls_sort.
ENDFORM.                    " F_PROSES_DATA_RADIO2

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA_RADIO3
*&---------------------------------------------------------------------*
FORM f_proses_data_radio3 .
  DATA : lt_detquot1  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot2  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot3  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot4  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot5  LIKE i_detquot OCCURS 0 WITH HEADER LINE.

  DATA : lv_abgru     TYPE vbap-abgru,
         lv_leadt     TYPE i,
         lv_fieldnm(20),
         lv_maktx     TYPE makt-maktx.

  DATA : ls_line 	    TYPE REF TO data,
         ls_knvv      LIKE LINE OF i_knvv.

  DATA : ls_sort      TYPE ty_sort.

  DATA : ls_subttl    TYPE ty_subttl,
         ls_subttl1   TYPE ty_subttl,
         ls_subttl2   TYPE ty_subttl,
         ls_subttl3   TYPE ty_subttl,
         ls_subttl4   TYPE ty_subttl,
         ls_subttl5   TYPE ty_subttl.

  DATA : lv_kwmeng    TYPE vbap-kwmeng,
         lv_kzwi1     TYPE vbap-kzwi1.

  SORT i_detquot BY vkbur knkli princ matkl matnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.

  lt_detquot1[] = i_detquot[].
  SORT lt_detquot1 BY vkbur knkli princ matkl matnr.
  DELETE ADJACENT DUPLICATES FROM lt_detquot1
  COMPARING vkbur knkli princ matkl matnr.
  lt_detquot2[] = lt_detquot1[].
  SORT lt_detquot2 BY vkbur knkli princ matkl.
  DELETE ADJACENT DUPLICATES FROM lt_detquot2
  COMPARING vkbur knkli princ matkl.
  lt_detquot3[] = lt_detquot2[].
  SORT lt_detquot3 BY vkbur knkli princ.
  DELETE ADJACENT DUPLICATES FROM lt_detquot3
  COMPARING vkbur knkli princ.
  lt_detquot4[] = lt_detquot3[].
  SORT lt_detquot4 BY vkbur knkli.
  DELETE ADJACENT DUPLICATES FROM lt_detquot4
  COMPARING vkbur knkli.
  lt_detquot5[] = lt_detquot4[].
  SORT lt_detquot5 BY vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_detquot5
  COMPARING vkbur.

  CREATE DATA ls_line LIKE LINE OF <fs_output>.
  ASSIGN ls_line->* TO <fs_subttl5>.
  ls_sort-sort = 1.

  LOOP AT lt_detquot5.
    CREATE DATA ls_line LIKE LINE OF <fs_output>.
    ASSIGN ls_line->* TO <fs_subttl4>.
    ADD 1 TO ls_sort-sort8.
    ADD 1 TO ls_sort-sort7.

    LOOP AT lt_detquot4 WHERE vkbur = lt_detquot5-vkbur.
      CREATE DATA ls_line LIKE LINE OF <fs_output>.
      ASSIGN ls_line->* TO <fs_subttl3>.
      ADD 1 TO ls_sort-sort6.
      ADD 1 TO ls_sort-sort5.

      LOOP AT lt_detquot3 WHERE vkbur = lt_detquot4-vkbur
                            AND knkli = lt_detquot4-knkli.
        CREATE DATA ls_line LIKE LINE OF <fs_output>.
        ASSIGN ls_line->* TO <fs_subttl2>.
        ADD 1 TO ls_sort-sort3.
        ADD 1 TO ls_sort-sort4.

        LOOP AT lt_detquot2 WHERE vkbur = lt_detquot3-vkbur
                              AND knkli = lt_detquot3-knkli
                              AND princ = lt_detquot3-princ.
          CREATE DATA ls_line LIKE LINE OF <fs_output>.
          ASSIGN ls_line->* TO <fs_subttl1>.
          ADD 1 TO ls_sort-sort1.
          ADD 1 TO ls_sort-sort2.

          LOOP AT lt_detquot1 WHERE vkbur = lt_detquot2-vkbur
                                AND knkli = lt_detquot2-knkli
                                AND princ = lt_detquot2-princ
                                AND matkl = lt_detquot2-matkl.
            CREATE DATA ls_line LIKE LINE OF <fs_output>.
            ASSIGN ls_line->* TO <fs_sub>.

            CLEAR ls_subttl.
            LOOP AT i_detquot WHERE vkbur = lt_detquot1-vkbur
                                AND knkli = lt_detquot1-knkli
                                AND princ = lt_detquot1-princ
                                AND matkl = lt_detquot1-matkl
                                AND matnr = lt_detquot1-matnr.
              lv_abgru  = i_detquot-abgru.

              PERFORM f_hidden_column USING ls_sort '' 'IDR'.

              ADD i_detquot-kwmeng TO ls_subttl-poqty.
              ADD i_detquot-kzwi1 TO ls_subttl-poval.

              CLEAR ls_knvv.
              READ TABLE i_knvv INTO ls_knvv WITH KEY kunnr = i_detquot-knkli.

              PERFORM f_po_column USING i_detquot-vkbur ls_knvv-vkbur '' ''
                                        i_detquot-matnr i_detquot-maktx
                                        ls_subttl-poqty ls_subttl-poval
                                        i_detquot-knkli i_detquot-name1
                                        i_detquot-princ i_detquot-matkl
                                        ls_knvv-kvgr4.

              CLEAR i_detsales.
              READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                             vgpos = i_detquot-posnr
                                    BINARY SEARCH.
              IF sy-subrc <> 0.
                IF i_detquot-erdat >= '20201001' AND
                  p_vkorg = '8020'.
                  CLEAR i_detsales.
                  READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                                 posnr = i_detquot-posnr.
                ENDIF.
              ENDIF.

              CLEAR i_detdelv.
              READ TABLE i_detdelv WITH KEY vgbel = i_detsales-vbeln
                                            vgpos = i_detsales-posnr
                                   BINARY SEARCH.

              CLEAR t_cust.
              READ TABLE t_cust WITH KEY vbeln = i_detdelv-vbeln.

              IF i_detdelv-vbeln IS NOT INITIAL.
                ADD i_detsales-kwmeng TO ls_subttl-doqty.
                ADD i_detsales-kzwi1 TO ls_subttl-doval.

                PERFORM f_do_column USING '' '' '' '' ''
                                          ls_subttl-doqty ls_subttl-doval.

                IF t_cust-crdat IS INITIAL.
                  ADD i_detsales-kwmeng TO ls_subttl-6q.
                  ADD i_detsales-kzwi1 TO ls_subttl-6v.
                ELSE.
                  lv_leadt = t_cust-crdat - i_detquot-bstdk.
                  IF lv_leadt LE 2.
                    ADD i_detsales-kwmeng TO ls_subttl-1q.
                    ADD i_detsales-kzwi1 TO ls_subttl-1v.
                  ELSEIF lv_leadt GE 3 AND lv_leadt LE 4.
                    ADD i_detsales-kwmeng TO ls_subttl-2q.
                    ADD i_detsales-kzwi1 TO ls_subttl-2v.
                  ELSEIF lv_leadt GE 5.
                    ADD i_detsales-kwmeng TO ls_subttl-3q.
                    ADD i_detsales-kzwi1 TO ls_subttl-3v.
                  ENDIF.
                ENDIF.

                CLEAR : lv_kwmeng, lv_kzwi1.
                lv_kwmeng = i_detquot-kwmeng - i_detsales-kwmeng.
                lv_kzwi1  = i_detquot-kzwi1 - i_detsales-kzwi1.

                PERFORM f_undelivered_calc USING lv_kwmeng lv_kzwi1
                                                 ls_subttl-unqty i_detquot-kwmeng
                                                 i_detsales-kwmeng
                                                 ls_subttl-unval i_detquot-kzwi1
                                                 i_detsales-kzwi1
                                          CHANGING ls_subttl-unqty ls_subttl-unval.

*                IF lv_kwmeng > 0.
*                ls_subttl-unqty  = ls_subttl-unqty + ( i_detquot-kwmeng - i_detsales-kwmeng ).
*                ls_subttl-unval  = ls_subttl-unval + ( i_detquot-kzwi1 - i_detsales-kzwi1 ).
*                ENDIF.

                IF lv_kwmeng < 0 OR
                  lv_kzwi1 < 0.
                  CLEAR : lv_kwmeng, lv_kzwi1.
                ENDIF.
              ELSE.
                IF i_detsales-vbeln IS INITIAL.
                  ADD i_detquot-kwmeng TO ls_subttl-unqty.
                  ADD i_detquot-kzwi1 TO ls_subttl-unval.
                  lv_kzwi1  = i_detquot-kzwi1.
                  lv_kwmeng = i_detquot-kwmeng.
                ELSE.
                  IF lv_abgru IS NOT INITIAL.
                    ADD i_detquot-kwmeng TO ls_subttl-unqty.
                    ADD i_detquot-kzwi1 TO ls_subttl-unval.
                    lv_kzwi1  = i_detquot-kzwi1.
                    lv_kwmeng = i_detquot-kwmeng.
                  ENDIF.
                ENDIF.
              ENDIF.

              IF p_val = 'X'.
                PERFORM f_value_column USING 'IDR' ls_subttl-1v ls_subttl-2v
                                             ls_subttl-3v ls_subttl-unval ''.
              ELSE.
                PERFORM f_quantity_column USING '0' ls_subttl-1q ls_subttl-2q
                                                ls_subttl-3q ls_subttl-unqty.
              ENDIF.

              IF lv_abgru IS INITIAL.
                lv_abgru = '99'.
              ENDIF.

              LOOP AT t_abgru.
                IF p_val = 'X'.
                  CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
                  ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
                  IF lv_abgru = t_abgru-abgru.
                    IF lv_kzwi1 IS NOT INITIAL.
*                      ADD i_detquot-kzwi1 TO <fs>.
                      ADD lv_kzwi1 TO <fs>.
                      ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_sub> TO <fs_s>.
                      <fs_s> = <fs>.
                    ENDIF.
                  ENDIF.
                ELSE.
                  CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
                  ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
                  IF lv_abgru = t_abgru-abgru.
                    IF lv_kwmeng IS NOT INITIAL.
*                      ADD i_detquot-kwmeng TO <fs>.
                      ADD lv_kwmeng TO <fs>.
                      ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_sub> TO <fs_s>.
                      <fs_s> = <fs>.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDLOOP.
            ENDLOOP.

            IF p_total3 IS INITIAL.
              APPEND <fs_line> TO <fs_output>.
            ENDIF.
            CLEAR : <fs_line>.

            PERFORM f_calculate USING '0' ls_subttl
                                CHANGING ls_subttl1.

            CLEAR : lv_abgru, ls_subttl.
          ENDLOOP.

          ADD 1 TO ls_sort-sort2.

          CONCATENATE '*    Total' lt_detquot2-matkl INTO lv_maktx
          SEPARATED BY space.

          PERFORM f_subtotal1 USING lv_maktx 'C30' 'X' ls_subttl1
                              CHANGING ls_sort.

          PERFORM f_percen1 USING 'C30' 'X' ls_subttl1 '2'
                            CHANGING ls_sort.

          PERFORM f_calculate USING '1' ls_subttl1
                              CHANGING ls_subttl2.

          CLEAR : ls_subttl1.
        ENDLOOP.

        ADD 1 TO ls_sort-sort4.

        CONCATENATE '**   Total' lt_detquot3-princ INTO lv_maktx
        SEPARATED BY space.

        PERFORM f_subtotal2 USING lv_maktx 'C31' 'X' ls_subttl2
                            CHANGING ls_sort.

        PERFORM f_percen2 USING 'C31' 'X' ls_subttl2 '2'
                          CHANGING ls_sort.

        PERFORM f_calculate USING '2' ls_subttl2
                            CHANGING ls_subttl3.

        CLEAR : ls_subttl2.
      ENDLOOP.

      ADD 1 TO ls_sort-sort6.

      CONCATENATE '***  Total' lt_detquot4-knkli INTO lv_maktx
      SEPARATED BY space.

      PERFORM f_subtotal3 USING lv_maktx 'C50' 'X' ls_subttl3
                          CHANGING ls_sort.

      PERFORM f_percen3 USING 'C50' 'X' ls_subttl3 '2'
                        CHANGING ls_sort.

      PERFORM f_calculate USING '3' ls_subttl3
                          CHANGING ls_subttl4.

      CLEAR : ls_subttl3.
    ENDLOOP.

    ADD 1 TO ls_sort-sort8.

    CONCATENATE '**** Total' lt_detquot5-vkbur INTO lv_maktx
    SEPARATED BY space.

    PERFORM f_subtotal4 USING lv_maktx 'C51' 'X' ls_subttl4
                        CHANGING ls_sort.

    PERFORM f_percen4 USING 'C51' 'X' ls_subttl4 '2'
                      CHANGING ls_sort.

    PERFORM f_calculate USING '4' ls_subttl4
                        CHANGING ls_subttl5.

    CLEAR : ls_subttl4.
  ENDLOOP.

  ls_sort-sort = 2.

  lv_maktx = '**** Grand Total'.

  PERFORM f_subtotal5 USING lv_maktx 'C71' 'X' ls_subttl5
                      CHANGING ls_sort.

  PERFORM f_percen5 USING 'C71' 'X' ls_subttl5 '2'
                    CHANGING ls_sort.
ENDFORM.                    " F_PROSES_DATA_RADIO3

*&---------------------------------------------------------------------*
*&      Form  F_SUBTOTAL1
*&---------------------------------------------------------------------*
FORM f_subtotal1  USING    fu_maktx fu_info fu_flag
                           fs_subttl  TYPE ty_subttl
                  CHANGING fs_sort  TYPE ty_sort.
  DATA : lv_fieldnm(20),
         lv_kzwi1   TYPE vbap-kzwi1,
         lv_kwmeng  TYPE vbap-kwmeng.

  PERFORM f_hidden_column USING fs_sort fu_info 'IDR'.

  PERFORM f_po_column USING '' '' '' '' '' fu_maktx
                            fs_subttl-poqty fs_subttl-poval '' '' '' '' ''.

  PERFORM f_do_column USING '' '' '' '' '' fs_subttl-doqty
                            fs_subttl-doval.

  IF fu_flag IS NOT INITIAL.
    IF p_val = 'X'.
      PERFORM f_value_column USING 'IDR' fs_subttl-1v fs_subttl-2v
                                   fs_subttl-3v fs_subttl-unval ''.
    ELSE.
      PERFORM f_quantity_column USING '0' fs_subttl-1q fs_subttl-2q
                                      fs_subttl-3q fs_subttl-unqty.
    ENDIF.

    LOOP AT t_abgru.
      IF p_val = 'X'.
        CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl1> TO <fs_st1>.
        lv_kzwi1  = <fs_st1>.
        <fs> = lv_kzwi1.
      ELSE.
        CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl1> TO <fs_st1>.
        lv_kwmeng = <fs_st1>.
        <fs> = lv_kwmeng.
        WRITE lv_kwmeng TO <fs> DECIMALS 0.
      ENDIF.
    ENDLOOP.
  ENDIF.

  ASSIGN COMPONENT 'PERCEN' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    <fs> = ''.
  ENDIF.
  ASSIGN COMPONENT 'LINE' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    <fs> = ''.
  ENDIF.
  ASSIGN COMPONENT 'DOCU' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    <fs> = ''.
  ENDIF.

  APPEND <fs_line> TO <fs_output>.
  CLEAR : <fs_line>.
ENDFORM.                    " F_SUBTOTAL1

*&---------------------------------------------------------------------*
*&      Form  F_PERCEN1
*&---------------------------------------------------------------------*
FORM f_percen1  USING    fu_info fu_flag
                         fs_subttl  TYPE ty_subttl
                         fu_decim
                CHANGING fs_sort  TYPE ty_sort.
  DATA : lv_maktx     TYPE makt-maktx,
         lv_fieldnm(20).

  DATA : ls_prc     TYPE ty_percen,
         lv_percen  TYPE p DECIMALS 2.

  PERFORM f_hidden_column USING fs_sort fu_info ''.

  lv_maktx  = '           Percentage(%)'.

  PERFORM f_po_column USING '' '' '' '' '' lv_maktx '' '' '' '' '' '' ''.

  ASSIGN COMPONENT 'WAERS' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = ''.

  PERFORM f_percen_calculate USING fs_subttl
                             CHANGING ls_prc.

  PERFORM f_percen_column USING ls_prc-percen ls_prc-line ls_prc-docu.

  IF fu_flag IS NOT INITIAL.
    IF p_val = 'X'.
      PERFORM f_value_column USING '' ls_prc-1v ls_prc-2v
                                   ls_prc-3v ls_prc-unval '%'.
    ELSE.
      PERFORM f_quantity_column USING fu_decim ls_prc-1q ls_prc-2q
                                      ls_prc-3q ls_prc-unqty.
    ENDIF.

    LOOP AT t_abgru.
      IF p_val = 'X'.
        CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl1> TO <fs_st1>.
        IF fs_subttl-poval IS NOT INITIAL.
          lv_percen = ( <fs_st1> / fs_subttl-poval ) * 100.
        ELSE.
          CLEAR lv_percen.
        ENDIF.
        <fs> = lv_percen.
      ELSE.
        CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl1> TO <fs_st1>.
        IF fs_subttl-poqty IS NOT INITIAL.
          lv_percen = ( <fs_st1> / fs_subttl-poqty ) * 100.
        ELSE.
          CLEAR lv_percen.
        ENDIF.
        IF fu_decim IS INITIAL.
          <fs> = lv_percen.
        ELSE.
          WRITE lv_percen TO <fs> DECIMALS fu_decim.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  APPEND <fs_line> TO <fs_output>.
  CLEAR : <fs_line>.
ENDFORM.                                                    " F_PERCEN1

*&---------------------------------------------------------------------*
*&      Form  F_PERCEN_CALCULATE
*&---------------------------------------------------------------------*
FORM f_percen_calculate  USING    fs_subttl   TYPE ty_subttl
                         CHANGING fs_prc  TYPE ty_percen.

  IF fs_subttl-polin IS NOT INITIAL.
    fs_prc-line = ( fs_subttl-dolin / fs_subttl-polin ) * 100.
  ELSE.
    CLEAR fs_prc-line.
  ENDIF.

  IF fs_subttl-podoc IS NOT INITIAL.
    fs_prc-docu = ( fs_subttl-dodoc / fs_subttl-podoc ) * 100.
  ELSE.
    CLEAR fs_prc-docu.
  ENDIF.

  IF p_val = 'X'.
    IF fs_subttl-poval IS NOT INITIAL.
      fs_prc-1v = ( fs_subttl-1v / fs_subttl-poval ) * 100.
      fs_prc-2v = ( fs_subttl-2v / fs_subttl-poval ) * 100.
      fs_prc-3v = ( fs_subttl-3v / fs_subttl-poval ) * 100.
      fs_prc-6v = ( fs_subttl-6v / fs_subttl-poval ) * 100.
      fs_prc-unval = ( fs_subttl-unval / fs_subttl-poval ) * 100.
      fs_prc-percen = ( fs_subttl-doval / fs_subttl-poval ) * 100.
    ELSE.
      CLEAR : fs_prc-1v, fs_prc-2v, fs_prc-3v, fs_prc-6v,
              fs_prc-unval, fs_prc-percen.
    ENDIF.
  ELSE.
    IF fs_subttl-poqty IS NOT INITIAL.
      fs_prc-1q = ( fs_subttl-1q / fs_subttl-poqty ) * 100.
      fs_prc-2q = ( fs_subttl-2q / fs_subttl-poqty ) * 100.
      fs_prc-3q = ( fs_subttl-3q / fs_subttl-poqty ) * 100.
      fs_prc-6q = ( fs_subttl-6q / fs_subttl-poqty ) * 100.
      fs_prc-unqty = ( fs_subttl-unqty / fs_subttl-poqty ) * 100.
      fs_prc-percen = ( fs_subttl-doqty / fs_subttl-poqty ) * 100.
    ELSE.
      CLEAR : fs_prc-1q, fs_prc-2q, fs_prc-3q, fs_prc-6q,
              fs_prc-unqty, fs_prc-percen.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PERCEN_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_SUBTOTAL2
*&---------------------------------------------------------------------*
FORM f_subtotal2  USING    fu_maktx fu_info fu_flag
                           fs_subttl  TYPE ty_subttl
                  CHANGING fs_sort  TYPE ty_sort.

  DATA : lv_fieldnm(20),
         lv_kzwi1     TYPE vbap-kzwi1,
         lv_kwmeng    TYPE vbap-kwmeng.

  PERFORM f_hidden_column USING fs_sort fu_info 'IDR'.

  PERFORM f_po_column USING '' '' '' '' '' fu_maktx
                            fs_subttl-poqty fs_subttl-poval '' '' '' '' ''.

  PERFORM f_do_column USING '' '' '' '' '' fs_subttl-doqty
                            fs_subttl-doval.

  IF fu_flag IS NOT INITIAL.
    IF p_val = 'X'.
      PERFORM f_value_column USING 'IDR' fs_subttl-1v fs_subttl-2v
                                   fs_subttl-3v fs_subttl-unval ''.
    ELSE.
      PERFORM f_quantity_column USING '0' fs_subttl-1q fs_subttl-2q
                                      fs_subttl-3q fs_subttl-unqty.
    ENDIF.

    LOOP AT t_abgru.
      IF p_val = 'X'.
        CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl2> TO <fs_st2>.
        lv_kzwi1  = <fs_st2>.
        <fs> = lv_kzwi1.
      ELSE.
        CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl2> TO <fs_st2>.
        lv_kwmeng = <fs_st2>.
        <fs> = lv_kwmeng.
        WRITE lv_kwmeng TO <fs> DECIMALS 0.
      ENDIF.
    ENDLOOP.
  ENDIF.

  ASSIGN COMPONENT 'PERCEN' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    <fs> = ''.
  ENDIF.
  ASSIGN COMPONENT 'LINE' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    <fs> = ''.
  ENDIF.
  ASSIGN COMPONENT 'DOCU' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    <fs> = ''.
  ENDIF.

  APPEND <fs_line> TO <fs_output>.
  CLEAR : <fs_line>.
ENDFORM.                    " F_SUBTOTAL2

*&---------------------------------------------------------------------*
*&      Form  F_PERCEN2
*&---------------------------------------------------------------------*
FORM f_percen2  USING    fu_info fu_flag
                         fs_subttl  TYPE ty_subttl
                         fu_decim
                CHANGING fs_sort  TYPE ty_sort.
  DATA : lv_maktx     TYPE makt-maktx,
         lv_fieldnm(20).

  DATA : ls_prc     TYPE ty_percen,
         lv_percen  TYPE p DECIMALS 2.

  PERFORM f_hidden_column USING fs_sort fu_info ''.

  lv_maktx  = '           Percentage(%)'.

  PERFORM f_po_column USING '' '' '' '' '' lv_maktx '' '' '' '' '' '' ''.

  ASSIGN COMPONENT 'WAERS' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = ''.

  PERFORM f_percen_calculate USING fs_subttl
                             CHANGING ls_prc.

  PERFORM f_percen_column USING ls_prc-percen ls_prc-line ls_prc-docu.

  IF fu_flag IS NOT INITIAL.
    IF p_val = 'X'.
      PERFORM f_value_column USING '' ls_prc-1v ls_prc-2v
                                   ls_prc-3v ls_prc-unval '%'.
    ELSE.
      PERFORM f_quantity_column USING fu_decim ls_prc-1q ls_prc-2q
                                      ls_prc-3q ls_prc-unqty.
    ENDIF.

    LOOP AT t_abgru.
      IF p_val = 'X'.
        CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl2> TO <fs_st2>.
        IF fs_subttl-poval IS NOT INITIAL.
          lv_percen = ( <fs_st2> / fs_subttl-poval ) * 100.
        ELSE.
          CLEAR lv_percen.
        ENDIF.
        <fs>  = lv_percen.
      ELSE.
        CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl2> TO <fs_st2>.
        IF fs_subttl-poqty IS NOT INITIAL.
          lv_percen = ( <fs_st2> / fs_subttl-poqty ) * 100.
        ELSE.
          CLEAR lv_percen.
        ENDIF.
        IF fu_decim IS INITIAL.
          <fs>  = lv_percen.
        ELSE.
          WRITE lv_percen TO <fs> DECIMALS fu_decim.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  APPEND <fs_line> TO <fs_output>.
  CLEAR : <fs_line>.
ENDFORM.                                                    " F_PERCEN2

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE
*&---------------------------------------------------------------------*
FORM f_calculate  USING    fu_proc
                           fs_subttl1   TYPE ty_subttl
                  CHANGING fs_subttl2   TYPE ty_subttl.

  DATA : lv_fieldnm(20).

  ADD fs_subttl1-poqty TO fs_subttl2-poqty.
  ADD fs_subttl1-poval TO fs_subttl2-poval.
  ADD fs_subttl1-doqty TO fs_subttl2-doqty.
  ADD fs_subttl1-doval TO fs_subttl2-doval.
  ADD fs_subttl1-unqty TO fs_subttl2-unqty.
  ADD fs_subttl1-unval TO fs_subttl2-unval.
  ADD fs_subttl1-polin TO fs_subttl2-polin.
  ADD fs_subttl1-dolin TO fs_subttl2-dolin.
  ADD fs_subttl1-podoc TO fs_subttl2-podoc.
  ADD fs_subttl1-dodoc TO fs_subttl2-dodoc.
  ADD fs_subttl1-1q TO fs_subttl2-1q.
  ADD fs_subttl1-1v TO fs_subttl2-1v.
  ADD fs_subttl1-2q TO fs_subttl2-2q.
  ADD fs_subttl1-2v TO fs_subttl2-2v.
  ADD fs_subttl1-3q TO fs_subttl2-3q.
  ADD fs_subttl1-3v TO fs_subttl2-3v.
  ADD fs_subttl1-6q TO fs_subttl2-6q.
  ADD fs_subttl1-6v TO fs_subttl2-6v.

  LOOP AT t_abgru.
    CASE fu_proc.
      WHEN '0'.
        IF p_val = 'X'.
          CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_sub> TO <fs_s>.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl1> TO <fs_st1>.
          ADD <fs_s> TO <fs_st1>.
        ELSE.
          CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_sub> TO <fs_s>.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl1> TO <fs_st1>.
          ADD <fs_s> TO <fs_st1>.
        ENDIF.
      WHEN '1'.
        IF p_val = 'X'.
          CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl1> TO <fs_st1>.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl2> TO <fs_st2>.
          ADD <fs_st1> TO <fs_st2>.
        ELSE.
          CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl1> TO <fs_st1>.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl2> TO <fs_st2>.
          ADD <fs_st1> TO <fs_st2>.
        ENDIF.
      WHEN '2'.
        IF p_val = 'X'.
          CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl2> TO <fs_st2>.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl3> TO <fs_st3>.
          ADD <fs_st2> TO <fs_st3>.
        ELSE.
          CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl2> TO <fs_st2>.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl3> TO <fs_st3>.
          ADD <fs_st2> TO <fs_st3>.
        ENDIF.
      WHEN '3'.
        IF p_val = 'X'.
          CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl3> TO <fs_st3>.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl4> TO <fs_st4>.
          ADD <fs_st3> TO <fs_st4>.
        ELSE.
          CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl3> TO <fs_st3>.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl4> TO <fs_st4>.
          ADD <fs_st3> TO <fs_st4>.
        ENDIF.
      WHEN '4'.
        IF p_val = 'X'.
          CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl4> TO <fs_st4>.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl5> TO <fs_st5>.
          ADD <fs_st4> TO <fs_st5>.
        ELSE.
          CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl4> TO <fs_st4>.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl5> TO <fs_st5>.
          ADD <fs_st4> TO <fs_st5>.
        ENDIF.
      WHEN '5'.
        IF p_val = 'X'.
          CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl5> TO <fs_st5>.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl6> TO <fs_st6>.
          ADD <fs_st5> TO <fs_st6>.
        ELSE.
          CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl5> TO <fs_st5>.
          ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl6> TO <fs_st6>.
          ADD <fs_st5> TO <fs_st6>.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_HIDDEN_COLUMN
*&---------------------------------------------------------------------*
FORM f_hidden_column  USING    fs_sort TYPE ty_sort
                               fu_info fu_waers.

  ASSIGN COMPONENT 'SORT' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fs_sort-sort.
  ASSIGN COMPONENT 'SORT1' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fs_sort-sort1.
  ASSIGN COMPONENT 'SORT2' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fs_sort-sort2.
  ASSIGN COMPONENT 'SORT3' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fs_sort-sort3.
  ASSIGN COMPONENT 'SORT4' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fs_sort-sort4.
  ASSIGN COMPONENT 'SORT5' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fs_sort-sort5.
  ASSIGN COMPONENT 'SORT6' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fs_sort-sort6.
  ASSIGN COMPONENT 'SORT7' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fs_sort-sort7.
  ASSIGN COMPONENT 'SORT8' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fs_sort-sort8.

  ASSIGN COMPONENT 'INFO' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fu_info.
  ASSIGN COMPONENT 'WAERS' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fu_waers.
ENDFORM.                    " F_HIDDEN_COLUMN

*&---------------------------------------------------------------------*
*&      Form  F_SUBTOTAL3
*&---------------------------------------------------------------------*
FORM f_subtotal3  USING    fu_maktx fu_info fu_flag
                           fs_subttl  TYPE ty_subttl
                  CHANGING fs_sort  TYPE ty_sort.
  DATA : lv_fieldnm(20),
         lv_kzwi1     TYPE vbap-kzwi1,
         lv_kwmeng    TYPE vbap-kwmeng.

  PERFORM f_hidden_column USING fs_sort fu_info 'IDR'.

  PERFORM f_po_column USING '' '' '' '' '' fu_maktx
                            fs_subttl-poqty fs_subttl-poval '' '' '' '' ''.

  PERFORM f_do_column USING '' '' '' '' '' fs_subttl-doqty
                            fs_subttl-doval.

  IF fu_flag IS NOT INITIAL.
    IF p_val = 'X'.
      PERFORM f_value_column USING 'IDR' fs_subttl-1v fs_subttl-2v
                                   fs_subttl-3v fs_subttl-unval ''.
    ELSE.
      PERFORM f_quantity_column USING '0' fs_subttl-1q fs_subttl-2q
                                      fs_subttl-3q fs_subttl-unqty.
    ENDIF.

    LOOP AT t_abgru.
      IF p_val = 'X'.
        CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl3> TO <fs_st3>.
        lv_kzwi1  = <fs_st3>.
        <fs> = lv_kzwi1.
      ELSE.
        CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl3> TO <fs_st3>.
        lv_kwmeng = <fs_st3>.
        <fs> = lv_kwmeng.
        WRITE lv_kwmeng TO <fs> DECIMALS 0.
      ENDIF.
    ENDLOOP.
  ENDIF.

  ASSIGN COMPONENT 'PERCEN' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    <fs> = ''.
  ENDIF.
  ASSIGN COMPONENT 'LINE' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    <fs> = ''.
  ENDIF.
  ASSIGN COMPONENT 'DOCU' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    <fs> = ''.
  ENDIF.

  APPEND <fs_line> TO <fs_output>.
  CLEAR : <fs_line>.
ENDFORM.                    " F_SUBTOTAL3

*&---------------------------------------------------------------------*
*&      Form  F_PERCEN3
*&---------------------------------------------------------------------*
FORM f_percen3  USING    fu_info fu_flag
                         fs_subttl  TYPE ty_subttl
                         fu_decim
                CHANGING fs_sort  TYPE ty_sort.
  DATA : lv_maktx     TYPE makt-maktx,
         lv_fieldnm(20).

  DATA : ls_prc     TYPE ty_percen,
         lv_percen  TYPE p DECIMALS 2.

  PERFORM f_hidden_column USING fs_sort fu_info ''.

  lv_maktx  = '           Percentage(%)'.

  PERFORM f_po_column USING '' '' '' '' '' lv_maktx '' '' '' '' '' '' ''.

  ASSIGN COMPONENT 'WAERS' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = ''.

  PERFORM f_percen_calculate USING fs_subttl
                             CHANGING ls_prc.

  PERFORM f_percen_column USING ls_prc-percen ls_prc-line ls_prc-docu.

  IF fu_flag IS NOT INITIAL.
    IF p_val = 'X'.
      PERFORM f_value_column USING '' ls_prc-1v ls_prc-2v
                                   ls_prc-3v ls_prc-unval '%'.
    ELSE.
      PERFORM f_quantity_column USING fu_decim ls_prc-1q ls_prc-2q
                                      ls_prc-3q ls_prc-unqty.
    ENDIF.

    LOOP AT t_abgru.
      IF p_val = 'X'.
        CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl3> TO <fs_st3>.
        IF fs_subttl-poval IS NOT INITIAL.
          lv_percen = ( <fs_st3> / fs_subttl-poval ) * 100.
        ELSE.
          CLEAR lv_percen.
        ENDIF.
        <fs>  = lv_percen.
      ELSE.
        CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl3> TO <fs_st3>.
        IF fs_subttl-poqty IS NOT INITIAL.
          lv_percen = ( <fs_st3> / fs_subttl-poqty ) * 100.
        ELSE.
          CLEAR lv_percen.
        ENDIF.
        IF fu_decim IS INITIAL.
          <fs>  = lv_percen.
        ELSE.
          WRITE lv_percen TO <fs> DECIMALS fu_decim.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  APPEND <fs_line> TO <fs_output>.
  CLEAR : <fs_line>.
ENDFORM.                                                    " F_PERCEN3

*&---------------------------------------------------------------------*
*&      Form  F_SUBTOTAL4
*&---------------------------------------------------------------------*
FORM f_subtotal4  USING    fu_maktx fu_info fu_flag
                           fs_subttl  TYPE ty_subttl
                  CHANGING fs_sort  TYPE ty_sort.
  DATA : lv_fieldnm(20),
         lv_kzwi1     TYPE vbap-kzwi1,
         lv_kwmeng    TYPE vbap-kwmeng.

  PERFORM f_hidden_column USING fs_sort fu_info 'IDR'.

  PERFORM f_po_column USING '' '' '' '' '' fu_maktx
                            fs_subttl-poqty fs_subttl-poval '' '' '' '' ''.

  PERFORM f_do_column USING '' '' '' '' '' fs_subttl-doqty
                            fs_subttl-doval.

  IF fu_flag IS NOT INITIAL.
    IF p_val = 'X'.
      PERFORM f_value_column USING 'IDR' fs_subttl-1v fs_subttl-2v
                                   fs_subttl-3v fs_subttl-unval ''.
    ELSE.
      PERFORM f_quantity_column USING '0' fs_subttl-1q fs_subttl-2q
                                      fs_subttl-3q fs_subttl-unqty.
    ENDIF.

    LOOP AT t_abgru.
      IF p_val = 'X'.
        CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl4> TO <fs_st4>.
        lv_kzwi1  = <fs_st4>.
        <fs> = lv_kzwi1.
      ELSE.
        CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl4> TO <fs_st4>.
        lv_kwmeng = <fs_st4>.
        <fs> = lv_kwmeng.
        WRITE lv_kwmeng TO <fs> DECIMALS 0.
      ENDIF.
    ENDLOOP.
  ENDIF.

  ASSIGN COMPONENT 'PERCEN' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    <fs> = ''.
  ENDIF.
  ASSIGN COMPONENT 'LINE' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    <fs> = ''.
  ENDIF.
  ASSIGN COMPONENT 'DOCU' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    <fs> = ''.
  ENDIF.

  APPEND <fs_line> TO <fs_output>.
  CLEAR : <fs_line>.
ENDFORM.                    " F_SUBTOTAL4

*&---------------------------------------------------------------------*
*&      Form  F_PERCEN4
*&---------------------------------------------------------------------*
FORM f_percen4  USING    fu_info fu_flag
                         fs_subttl  TYPE ty_subttl
                         fu_decim
                CHANGING fs_sort  TYPE ty_sort.
  DATA : lv_maktx     TYPE makt-maktx,
         lv_fieldnm(20).

  DATA : ls_prc     TYPE ty_percen,
         lv_percen  TYPE p DECIMALS 2.

  PERFORM f_hidden_column USING fs_sort fu_info ''.

  lv_maktx  = '           Percentage(%)'.

  PERFORM f_po_column USING '' '' '' '' '' lv_maktx '' '' '' '' '' '' ''.

  ASSIGN COMPONENT 'WAERS' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = ''.

  PERFORM f_percen_calculate USING fs_subttl
                             CHANGING ls_prc.

  PERFORM f_percen_column USING ls_prc-percen ls_prc-line ls_prc-docu.

  IF fu_flag IS NOT INITIAL.
    IF p_val = 'X'.
      PERFORM f_value_column USING '' ls_prc-1v ls_prc-2v
                                   ls_prc-3v ls_prc-unval '%'.
    ELSE.
      PERFORM f_quantity_column USING fu_decim ls_prc-1q ls_prc-2q
                                      ls_prc-3q ls_prc-unqty.
    ENDIF.

    LOOP AT t_abgru.
      IF p_val = 'X'.
        CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl4> TO <fs_st4>.
        IF fs_subttl-poval IS NOT INITIAL.
          lv_percen = ( <fs_st4> / fs_subttl-poval ) * 100.
        ELSE.
          CLEAR lv_percen.
        ENDIF.
        <fs>  = lv_percen.
      ELSE.
        CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl4> TO <fs_st4>.
        IF fs_subttl-poqty IS NOT INITIAL.
          lv_percen = ( <fs_st4> / fs_subttl-poqty ) * 100.
        ELSE.
          CLEAR lv_percen.
        ENDIF.
        IF fu_decim IS INITIAL.
          <fs>  = lv_percen.
        ELSE.
          WRITE lv_percen TO <fs> DECIMALS fu_decim.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  APPEND <fs_line> TO <fs_output>.
  CLEAR : <fs_line>.
ENDFORM.                                                    " F_PERCEN4

*&---------------------------------------------------------------------*
*&      Form  F_SUBTOTAL5
*&---------------------------------------------------------------------*
FORM f_subtotal5  USING    fu_maktx fu_info fu_flag
                           fs_subttl  TYPE ty_subttl
                  CHANGING fs_sort  TYPE ty_sort.
  DATA : lv_fieldnm(20),
         lv_kzwi1     TYPE vbap-kzwi1,
         lv_kwmeng    TYPE vbap-kwmeng.

  PERFORM f_hidden_column USING fs_sort fu_info 'IDR'.

  PERFORM f_po_column USING '' '' '' '' '' fu_maktx
                            fs_subttl-poqty fs_subttl-poval '' '' '' '' ''.

  PERFORM f_do_column USING '' '' '' '' '' fs_subttl-doqty
                            fs_subttl-doval.

  IF fu_flag IS NOT INITIAL.
    IF p_val = 'X'.
      PERFORM f_value_column USING 'IDR' fs_subttl-1v fs_subttl-2v
                                   fs_subttl-3v fs_subttl-unval ''.
    ELSE.
      PERFORM f_quantity_column USING '0' fs_subttl-1q fs_subttl-2q
                                      fs_subttl-3q fs_subttl-unqty.
    ENDIF.

    LOOP AT t_abgru.
      IF p_val = 'X'.
        CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl5> TO <fs_st5>.
        lv_kzwi1  = <fs_st5>.
        <fs> = lv_kzwi1.
      ELSE.
        CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl5> TO <fs_st5>.
        lv_kwmeng = <fs_st5>.
        <fs> = lv_kwmeng.
        WRITE lv_kwmeng TO <fs> DECIMALS 0.
      ENDIF.
    ENDLOOP.
  ENDIF.

  ASSIGN COMPONENT 'PERCEN' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    <fs> = ''.
  ENDIF.
  ASSIGN COMPONENT 'LINE' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    <fs> = ''.
  ENDIF.
  ASSIGN COMPONENT 'DOCU' OF STRUCTURE <fs_line> TO <fs>.
  IF sy-subrc = 0.
    <fs> = ''.
  ENDIF.

  APPEND <fs_line> TO <fs_output>.
  CLEAR : <fs_line>.
ENDFORM.                    " F_SUBTOTAL5

*&---------------------------------------------------------------------*
*&      Form  F_PERCEN5
*&---------------------------------------------------------------------*
FORM f_percen5  USING    fu_info fu_flag
                         fs_subttl  TYPE ty_subttl
                         fu_decim
                CHANGING fs_sort  TYPE ty_sort.
  DATA : lv_maktx     TYPE makt-maktx,
         lv_fieldnm(20).

  DATA : ls_prc     TYPE ty_percen,
         lv_percen  TYPE p DECIMALS 2.

  PERFORM f_hidden_column USING fs_sort fu_info ''.

  lv_maktx  = '           Percentage(%)'.

  PERFORM f_po_column USING '' '' '' '' '' lv_maktx '' '' '' '' '' '' ''.

  ASSIGN COMPONENT 'WAERS' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = ''.

  PERFORM f_percen_calculate USING fs_subttl
                             CHANGING ls_prc.

  PERFORM f_percen_column USING ls_prc-percen ls_prc-line ls_prc-docu.

  IF fu_flag IS NOT INITIAL.
    IF p_val = 'X'.
      PERFORM f_value_column USING '' ls_prc-1v ls_prc-2v
                                   ls_prc-3v ls_prc-unval '%'.
    ELSE.
      PERFORM f_quantity_column USING fu_decim ls_prc-1q ls_prc-2q
                                      ls_prc-3q ls_prc-unqty.
    ENDIF.

    LOOP AT t_abgru.
      IF p_val = 'X'.
        CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl5> TO <fs_st5>.
        IF fs_subttl-poval IS NOT INITIAL.
          lv_percen = ( <fs_st5> / fs_subttl-poval ) * 100.
        ELSE.
          CLEAR lv_percen.
        ENDIF.
        <fs>  = lv_percen.
      ELSE.
        CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl5> TO <fs_st5>.
        IF fs_subttl-poqty IS NOT INITIAL.
          lv_percen = ( <fs_st5> / fs_subttl-poqty ) * 100.
        ELSE.
          CLEAR lv_percen.
        ENDIF.
        IF fu_decim IS INITIAL.
          <fs>  = lv_percen.
        ELSE.
          WRITE lv_percen TO <fs> DECIMALS fu_decim.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  APPEND <fs_line> TO <fs_output>.
  CLEAR : <fs_line>.
ENDFORM.                                                    " F_PERCEN5

*&---------------------------------------------------------------------*
*&      Form  F_PO_COLUMN
*&---------------------------------------------------------------------*
FORM f_po_column  USING    fu_vkbur fu_vkbvv fu_vbeln fu_bstdk fu_matnr
                           fu_maktx fu_kwmeng fu_kzwi1 fu_knkli
                           fu_name1 fu_princ fu_matkl fu_kvgr4.
  CASE 'X'.
    WHEN radio1.
      ASSIGN COMPONENT 'VKBUR' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_vkbur.
      ASSIGN COMPONENT 'VKBVV' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_vkbvv.
      ASSIGN COMPONENT 'KNKLI' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_knkli.
      ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_name1.
      ASSIGN COMPONENT 'KVGR4' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kvgr4.
      ASSIGN COMPONENT 'VBELN' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_vbeln.
      ASSIGN COMPONENT 'BSTDK' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_bstdk.
      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_matnr.
      ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_maktx.
      ASSIGN COMPONENT 'KWMENG' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kwmeng.
      ASSIGN COMPONENT 'KZWI1' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kzwi1.

    WHEN radio2.
      ASSIGN COMPONENT 'VKBUR' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_vkbur.
      ASSIGN COMPONENT 'VKBVV' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_vkbvv.
      ASSIGN COMPONENT 'KNKLI' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_knkli.
      ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_name1.
      ASSIGN COMPONENT 'KVGR4' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kvgr4.
      ASSIGN COMPONENT 'PRINC' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_princ.
      ASSIGN COMPONENT 'MATKL' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_matkl.
      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_matnr.
      ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_maktx.
      ASSIGN COMPONENT 'KWMENG' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kwmeng.
      ASSIGN COMPONENT 'KZWI1' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kzwi1.

    WHEN radio3.
      ASSIGN COMPONENT 'VKBUR' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_vkbur.
      ASSIGN COMPONENT 'VKBVV' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_vkbvv.
      ASSIGN COMPONENT 'KNKLI' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_knkli.
      ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_name1.
      ASSIGN COMPONENT 'KVGR4' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kvgr4.
      ASSIGN COMPONENT 'PRINC' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_princ.
      ASSIGN COMPONENT 'MATKL' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_matkl.
      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_matnr.
      ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_maktx.
      ASSIGN COMPONENT 'KWMENG' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kwmeng.
      ASSIGN COMPONENT 'KZWI1' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kzwi1.

    WHEN radio4.
      ASSIGN COMPONENT 'PRINC' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_princ.
      ASSIGN COMPONENT 'MATKL' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_matkl.
      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_matnr.
      ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_maktx.
      ASSIGN COMPONENT 'KWMENG' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kwmeng.
      ASSIGN COMPONENT 'KZWI1' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kzwi1.

    WHEN radio5.
      IF p_summ5 IS INITIAL.
        ASSIGN COMPONENT 'VBELN' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_vbeln.
        ASSIGN COMPONENT 'BSTDK' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_bstdk.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_matnr.
        ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_maktx.
        ASSIGN COMPONENT 'KWMENG' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kwmeng.
        ASSIGN COMPONENT 'KZWI1' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kzwi1.
      ELSE.
        ASSIGN COMPONENT 'KWMENG' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kwmeng.
        ASSIGN COMPONENT 'KZWI1' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kzwi1.
      ENDIF.

    WHEN radio6.
      IF p_summ6 IS INITIAL.
        ASSIGN COMPONENT 'VBELN' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_vbeln.
        ASSIGN COMPONENT 'BSTDK' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_bstdk.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_matnr.
        ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_maktx.
        ASSIGN COMPONENT 'KWMENG' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kwmeng.
        ASSIGN COMPONENT 'KZWI1' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kzwi1.
      ELSE.
        ASSIGN COMPONENT 'KWMENG' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kwmeng.
        ASSIGN COMPONENT 'KZWI1' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kzwi1.
      ENDIF.

    WHEN radio7.
      ASSIGN COMPONENT 'VKBUR' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_vkbur.
      ASSIGN COMPONENT 'VKBVV' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_vkbvv.
      ASSIGN COMPONENT 'KNKLI' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_knkli.
      ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_name1.
      ASSIGN COMPONENT 'KVGR4' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kvgr4.
      ASSIGN COMPONENT 'VBELN' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_vbeln.
      ASSIGN COMPONENT 'BSTDK' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_bstdk.
      ASSIGN COMPONENT 'PRINC' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_princ.
      ASSIGN COMPONENT 'MATKL' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_matkl.
      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_matnr.
      ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_maktx.
      ASSIGN COMPONENT 'KWMENG' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kwmeng.
      ASSIGN COMPONENT 'KZWI1' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kzwi1.
  ENDCASE.
ENDFORM.                    " F_PO_COLUMN

*&---------------------------------------------------------------------*
*&      Form  F_DO_COLUMN
*&---------------------------------------------------------------------*
FORM f_do_column  USING    fu_vbeln fu_erdat fu_crdat fu_matnr fu_maktx
                           fu_kwmeng fu_kzwi1.
  CASE 'X'.
    WHEN radio1.
      ASSIGN COMPONENT 'DLNUM' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_vbeln.
      ASSIGN COMPONENT 'DLDAT' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_erdat.
      ASSIGN COMPONENT 'CRDAT' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_crdat.
      ASSIGN COMPONENT 'DLMAT' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_matnr.
      ASSIGN COMPONENT 'DLMATX' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_maktx.
      ASSIGN COMPONENT 'DLQTY' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kwmeng.
      ASSIGN COMPONENT 'DLVAL' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kzwi1.

    WHEN radio2 OR radio7.
      ASSIGN COMPONENT 'DLQTY' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kwmeng.
      ASSIGN COMPONENT 'DLVAL' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kzwi1.

    WHEN radio3.
      ASSIGN COMPONENT 'DLQTY' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kwmeng.
      ASSIGN COMPONENT 'DLVAL' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kzwi1.

    WHEN radio4.
      ASSIGN COMPONENT 'DLQTY' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kwmeng.
      ASSIGN COMPONENT 'DLVAL' OF STRUCTURE <fs_line> TO <fs>.
      <fs> = fu_kzwi1.

    WHEN radio5.
      IF p_summ5 IS INITIAL.
        ASSIGN COMPONENT 'DLNUM' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_vbeln.
        ASSIGN COMPONENT 'DLDAT' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_erdat.
        ASSIGN COMPONENT 'CRDAT' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_crdat.
        ASSIGN COMPONENT 'DLMAT' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_matnr.
        ASSIGN COMPONENT 'DLMATX' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_maktx.
        ASSIGN COMPONENT 'DLQTY' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kwmeng.
        ASSIGN COMPONENT 'DLVAL' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kzwi1.
      ELSE.
        ASSIGN COMPONENT 'DLQTY' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kwmeng.
        ASSIGN COMPONENT 'DLVAL' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kzwi1.
      ENDIF.

    WHEN radio6.
      IF p_summ6 IS INITIAL.
        ASSIGN COMPONENT 'DLNUM' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_vbeln.
        ASSIGN COMPONENT 'DLDAT' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_erdat.
        ASSIGN COMPONENT 'CRDAT' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_crdat.
        ASSIGN COMPONENT 'DLMAT' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_matnr.
        ASSIGN COMPONENT 'DLMATX' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_maktx.
        ASSIGN COMPONENT 'DLQTY' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kwmeng.
        ASSIGN COMPONENT 'DLVAL' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kzwi1.
      ELSE.
        ASSIGN COMPONENT 'DLQTY' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kwmeng.
        ASSIGN COMPONENT 'DLVAL' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kzwi1.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_DO_COLUMN

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_COLUMN
*&---------------------------------------------------------------------*
FORM f_value_column  USING    fu_waers fu_1v fu_2v fu_3v fu_unval fu_percn.
  DATA : lt_char(20).

  ASSIGN COMPONENT 'LEAD1' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fu_1v.
  ASSIGN COMPONENT 'LEAD2' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fu_2v.
  ASSIGN COMPONENT 'LEAD3' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fu_3v.
  ASSIGN COMPONENT 'UNVAL' OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fu_unval.
ENDFORM.                    " F_VALUE_COLUMN

*&---------------------------------------------------------------------*
*&      Form  F_QUANTITY_COLUMN
*&---------------------------------------------------------------------*
FORM f_quantity_column  USING    fu_decim fu_1q fu_2q fu_3q fu_unqty.
  IF fu_decim IS INITIAL.
    ASSIGN COMPONENT 'LEAD1Q' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = fu_1q.
    ASSIGN COMPONENT 'LEAD2Q' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = fu_2q.
    ASSIGN COMPONENT 'LEAD3Q' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = fu_3q.
    ASSIGN COMPONENT 'UNQTY' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = fu_unqty.
  ELSE.
    ASSIGN COMPONENT 'LEAD1Q' OF STRUCTURE <fs_line> TO <fs>.
    WRITE fu_1q TO <fs> DECIMALS fu_decim.
    ASSIGN COMPONENT 'LEAD2Q' OF STRUCTURE <fs_line> TO <fs>.
    WRITE fu_2q TO <fs> DECIMALS fu_decim.
    ASSIGN COMPONENT 'LEAD3Q' OF STRUCTURE <fs_line> TO <fs>.
    WRITE fu_3q TO <fs> DECIMALS fu_decim.
    ASSIGN COMPONENT 'UNQTY' OF STRUCTURE <fs_line> TO <fs>.
    WRITE fu_unqty TO <fs> DECIMALS fu_decim.
  ENDIF.
ENDFORM.                    " F_QUANTITY_COLUMN

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATA
*&---------------------------------------------------------------------*
FORM f_modify_data .
  DATA : lt_detquot   LIKE i_detquot OCCURS 0.
  DATA : lt_detsales  LIKE i_detsales OCCURS 0.
  DATA : lt_vbuk      TYPE STANDARD TABLE OF vbuk INITIAL SIZE 0,
         ls_vbuk      LIKE LINE OF lt_vbuk.

  SORT i_detquot BY vkbur knkli vbeln posnr matnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.

  lt_detsales[] = i_detsales[].
  SORT lt_detsales[] BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_detsales COMPARING vbeln.
  IF lt_detsales[] IS NOT INITIAL.
    SELECT vbeln lfstk
      FROM vbuk
      INTO CORRESPONDING FIELDS OF TABLE lt_vbuk
      FOR ALL ENTRIES IN lt_detsales
      WHERE vbeln = lt_detsales-vbeln
        AND lfstk = 'C'.
  ENDIF.

  LOOP AT i_detquot.
    i_detquot-princ  = i_detquot-matkl(3).
    i_detquot-prin1  = i_detquot-matkl+3(3).
    i_detquot-prin2  = i_detquot-matkl+6(3).

    LOOP AT i_detsales WHERE vgbel = i_detquot-vbeln
                         AND vgpos = i_detquot-posnr.
      IF i_detsales-abgru IS NOT INITIAL.
        i_detquot-abgru = i_detsales-abgru.
      ENDIF.

*      CLEAR ls_vbuk.
*      READ TABLE lt_vbuk INTO ls_vbuk
*                         WITH KEY vbeln = i_detsales-vbeln.
*      IF sy-subrc <> 0.
*        DELETE i_detsales.
*      ENDIF.
    ENDLOOP.

    CASE 'X'.
      WHEN radio5.
        IF p_summ5 IS NOT INITIAL.
          READ TABLE i_tkukt WITH KEY kukla = i_detquot-kukla.
          IF sy-subrc = 0.
            i_detquot-vtext  = i_tkukt-vtext.
          ENDIF.
        ENDIF.

      WHEN radio6.
        IF p_summ6 IS NOT INITIAL.
          READ TABLE i_tkukt WITH KEY kukla = i_detquot-kukla.
          IF sy-subrc = 0.
            i_detquot-vtext  = i_tkukt-vtext.
          ENDIF.
        ENDIF.

        READ TABLE i_vbpa WITH KEY vbeln = i_detquot-vbeln.
        IF sy-subrc = 0.
          i_detquot-kunrl = i_vbpa-kunnr.
          i_detquot-namrl = i_vbpa-name1.
        ENDIF.
    ENDCASE.
    MODIFY i_detquot TRANSPORTING princ prin1 prin2 kunrl namrl vtext abgru.
    CLEAR i_detquot.
  ENDLOOP.

  CASE 'X'.
    WHEN radio5.
      IF p_summ5 IS NOT INITIAL.
        gt_sum05[]  = i_detquot[].
        SORT gt_sum05 BY vkbur kukla knkli.
        DELETE ADJACENT DUPLICATES FROM gt_sum05 COMPARING vkbur kukla knkli.
        IF gt_sum05[] IS NOT INITIAL.
          SELECT *
            FROM knvv
            INTO CORRESPONDING FIELDS OF TABLE i_knvv
            FOR ALL ENTRIES IN gt_sum05
            WHERE kunnr = gt_sum05-knkli
              AND vkorg = p_vkorg.
        ENDIF.
      ENDIF.
    WHEN radio6.
      IF p_summ6 IS NOT INITIAL.
        gt_sum06[]  = i_detquot[].
        SORT gt_sum06 BY vkbur kukla kunrl.
        DELETE ADJACENT DUPLICATES FROM gt_sum06 COMPARING vkbur kukla kunrl.
        IF gt_sum06[] IS NOT INITIAL.
          SELECT *
            FROM knvv
            INTO CORRESPONDING FIELDS OF TABLE i_knvv
            FOR ALL ENTRIES IN gt_sum06
            WHERE kunnr = gt_sum06-kunrl
              AND vkorg = p_vkorg.
        ENDIF.
      ENDIF.
  ENDCASE.

  IF i_knvv[] IS INITIAL.
    lt_detquot[] = i_detquot[].
    SORT lt_detquot BY vkbur knkli.
    DELETE ADJACENT DUPLICATES FROM lt_detquot COMPARING vkbur knkli.
    IF lt_detquot[] IS NOT INITIAL.
      SELECT *
        FROM knvv
        INTO CORRESPONDING FIELDS OF TABLE i_knvv
        FOR ALL ENTRIES IN lt_detquot
        WHERE kunnr = lt_detquot-knkli
          AND vkorg = p_vkorg.
    ENDIF.
  ENDIF.

  lt_detquot[] = i_detquot[].
  SORT lt_detquot BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_detquot COMPARING matnr.
  IF lt_detquot[] IS NOT INITIAL.
    SELECT *
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE i_mara
      FOR ALL ENTRIES IN lt_detquot
      WHERE matnr = lt_detquot-matnr.
  ENDIF.
ENDFORM.                    " F_MODIFY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DATA_SORT
*&---------------------------------------------------------------------*
FORM f_data_sort  USING    fu_fieldname fu_up fu_group fu_subtot
                           fu_spos.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-spos      = fu_spos.
  ld_sort-fieldname = fu_fieldname.
  ld_sort-up        = fu_up.
  ld_sort-group     = fu_group.
  ld_sort-subtot    = fu_subtot.
  APPEND ld_sort TO sortcat.
ENDFORM.                    " F_DATA_SORT

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA_RADIO4
*&---------------------------------------------------------------------*
FORM f_proses_data_radio4 .
  DATA : lt_detquot1  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot2  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot3  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot4  LIKE i_detquot OCCURS 0 WITH HEADER LINE.

  DATA : lv_abgru     TYPE vbap-abgru,
         lv_leadt     TYPE i,
         lv_fieldnm(20),
         lv_maktx     TYPE makt-maktx.

  DATA : ls_line 	    TYPE REF TO data.

  DATA : ls_sort      TYPE ty_sort.

  DATA : ls_subttl    TYPE ty_subttl,
         ls_subttl1   TYPE ty_subttl,
         ls_subttl2   TYPE ty_subttl,
         ls_subttl3   TYPE ty_subttl,
         ls_subttl4   TYPE ty_subttl,
         ls_subttl5   TYPE ty_subttl.

  DATA : lv_kwmeng    TYPE vbap-kwmeng,
         lv_kzwi1     TYPE vbap-kzwi1.

  SORT i_detquot BY vkbur knkli princ matkl matnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.

  lt_detquot1[] = i_detquot[].
  SORT lt_detquot1 BY princ matkl matnr.
  DELETE ADJACENT DUPLICATES FROM lt_detquot1
  COMPARING princ matkl matnr.
  lt_detquot2[] = lt_detquot1[].
  SORT lt_detquot2 BY princ matkl.
  DELETE ADJACENT DUPLICATES FROM lt_detquot2
  COMPARING princ matkl.
  lt_detquot3[] = lt_detquot2[].
  SORT lt_detquot3 BY princ.
  DELETE ADJACENT DUPLICATES FROM lt_detquot3
  COMPARING princ.

  CREATE DATA ls_line LIKE LINE OF <fs_output>.
  ASSIGN ls_line->* TO <fs_subttl3>.
  ls_sort-sort = 1.

  LOOP AT lt_detquot3.
    CREATE DATA ls_line LIKE LINE OF <fs_output>.
    ASSIGN ls_line->* TO <fs_subttl2>.
    ADD 1 TO ls_sort-sort3.
    ADD 1 TO ls_sort-sort4.

    LOOP AT lt_detquot2 WHERE princ = lt_detquot3-princ.
      CREATE DATA ls_line LIKE LINE OF <fs_output>.
      ASSIGN ls_line->* TO <fs_subttl1>.
      ADD 1 TO ls_sort-sort1.
      ADD 1 TO ls_sort-sort2.

      LOOP AT lt_detquot1 WHERE princ = lt_detquot2-princ
                            AND matkl = lt_detquot2-matkl.
        CREATE DATA ls_line LIKE LINE OF <fs_output>.
        ASSIGN ls_line->* TO <fs_sub>.

        CLEAR ls_subttl.
        LOOP AT i_detquot WHERE princ = lt_detquot1-princ
                            AND matkl = lt_detquot1-matkl
                            AND matnr = lt_detquot1-matnr.
          lv_abgru  = i_detquot-abgru.

          PERFORM f_hidden_column USING ls_sort '' 'IDR'.

          ADD i_detquot-kwmeng TO ls_subttl-poqty.
          ADD i_detquot-kzwi1 TO ls_subttl-poval.

          PERFORM f_po_column USING '' '' '' ''
                                    i_detquot-matnr i_detquot-maktx
                                    ls_subttl-poqty ls_subttl-poval
                                    '' ''
                                    i_detquot-princ i_detquot-matkl ''.

          CLEAR i_detsales.
          READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                         vgpos = i_detquot-posnr
                                BINARY SEARCH.
          IF sy-subrc <> 0.
            IF i_detquot-erdat >= '20201001' AND
              p_vkorg = '8020'.
              CLEAR i_detsales.
              READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                             posnr = i_detquot-posnr.
            ENDIF.
          ENDIF.

          CLEAR i_detdelv.
          READ TABLE i_detdelv WITH KEY vgbel = i_detsales-vbeln
                                        vgpos = i_detsales-posnr
                               BINARY SEARCH.

          CLEAR t_cust.
          READ TABLE t_cust WITH KEY vbeln = i_detdelv-vbeln.

          IF i_detdelv-vbeln IS NOT INITIAL.
            ADD i_detsales-kwmeng TO ls_subttl-doqty.
            ADD i_detsales-kzwi1 TO ls_subttl-doval.

            PERFORM f_do_column USING '' '' '' '' ''
                                      ls_subttl-doqty ls_subttl-doval.

            IF t_cust-crdat IS INITIAL.
              ADD i_detsales-kwmeng TO ls_subttl-6q.
              ADD i_detsales-kzwi1 TO ls_subttl-6v.
            ELSE.
              lv_leadt = t_cust-crdat - i_detquot-bstdk.
              IF lv_leadt LE 2.
                ADD i_detsales-kwmeng TO ls_subttl-1q.
                ADD i_detsales-kzwi1 TO ls_subttl-1v.
              ELSEIF lv_leadt GE 3 AND lv_leadt LE 4.
                ADD i_detsales-kwmeng TO ls_subttl-2q.
                ADD i_detsales-kzwi1 TO ls_subttl-2v.
              ELSEIF lv_leadt GE 5.
                ADD i_detsales-kwmeng TO ls_subttl-3q.
                ADD i_detsales-kzwi1 TO ls_subttl-3v.
              ENDIF.
            ENDIF.

            CLEAR : lv_kwmeng, lv_kzwi1.
            lv_kwmeng = i_detquot-kwmeng - i_detsales-kwmeng.
            lv_kzwi1  = i_detquot-kzwi1 - i_detsales-kzwi1.

            PERFORM f_undelivered_calc USING lv_kwmeng lv_kzwi1
                                             ls_subttl-unqty i_detquot-kwmeng
                                             i_detsales-kwmeng
                                             ls_subttl-unval i_detquot-kzwi1
                                             i_detsales-kzwi1
                                      CHANGING ls_subttl-unqty ls_subttl-unval.

*            IF lv_kwmeng > 0.
*            ls_subttl-unqty  = ls_subttl-unqty + ( i_detquot-kwmeng - i_detsales-kwmeng ).
*            ls_subttl-unval  = ls_subttl-unval + ( i_detquot-kzwi1 - i_detsales-kzwi1 ).
*            ENDIF.

            IF lv_kwmeng < 0 OR
              lv_kzwi1 < 0.
              CLEAR : lv_kwmeng, lv_kzwi1.
            ENDIF.
          ELSE.
            IF i_detsales-vbeln IS INITIAL.
              ADD i_detquot-kwmeng TO ls_subttl-unqty.
              ADD i_detquot-kzwi1 TO ls_subttl-unval.
              lv_kzwi1  = i_detquot-kzwi1.
              lv_kwmeng = i_detquot-kwmeng.
            ELSE.
              IF lv_abgru IS NOT INITIAL.
                ADD i_detquot-kwmeng TO ls_subttl-unqty.
                ADD i_detquot-kzwi1 TO ls_subttl-unval.
                lv_kzwi1  = i_detquot-kzwi1.
                lv_kwmeng = i_detquot-kwmeng.
              ENDIF.
            ENDIF.
          ENDIF.

          IF p_val = 'X'.
            PERFORM f_value_column USING 'IDR' ls_subttl-1v ls_subttl-2v
                                         ls_subttl-3v ls_subttl-unval ''.
          ELSE.
            PERFORM f_quantity_column USING '0' ls_subttl-1q ls_subttl-2q
                                            ls_subttl-3q ls_subttl-unqty.
          ENDIF.

          IF lv_abgru IS INITIAL.
            lv_abgru = '99'.
          ENDIF.

          LOOP AT t_abgru.
            IF p_val = 'X'.
              CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
              ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
              IF lv_abgru = t_abgru-abgru.
                IF lv_kzwi1 IS NOT INITIAL.
*                  ADD i_detquot-kzwi1 TO <fs>.
                  ADD lv_kzwi1 TO <fs>.
                  ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_sub> TO <fs_s>.
                  <fs_s> = <fs>.
                ENDIF.
              ENDIF.
            ELSE.
              CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
              ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
              IF lv_abgru = t_abgru-abgru.
                IF lv_kwmeng IS NOT INITIAL.
*                  ADD i_detquot-kwmeng TO <fs>.
                  ADD lv_kwmeng TO <fs>.
                  ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_sub> TO <fs_s>.
                  <fs_s> = <fs>.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDLOOP.

        IF p_total4 IS INITIAL.
          APPEND <fs_line> TO <fs_output>.
        ENDIF.

        CLEAR : <fs_line>.

        PERFORM f_calculate USING '0' ls_subttl
                            CHANGING ls_subttl1.

        CLEAR : lv_abgru, ls_subttl.
      ENDLOOP.

      ADD 1 TO ls_sort-sort2.

      CONCATENATE '*    Total' lt_detquot2-matkl INTO lv_maktx
      SEPARATED BY space.

      PERFORM f_subtotal1 USING lv_maktx 'C30' 'X' ls_subttl1
                          CHANGING ls_sort.

      PERFORM f_percen1 USING 'C30' 'X' ls_subttl1 '2'
                        CHANGING ls_sort.

      PERFORM f_calculate USING '1' ls_subttl1
                          CHANGING ls_subttl2.

      CLEAR : ls_subttl1.
    ENDLOOP.

    ADD 1 TO ls_sort-sort4.

    CONCATENATE '**   Total' lt_detquot3-princ INTO lv_maktx
    SEPARATED BY space.

    PERFORM f_subtotal2 USING lv_maktx 'C31' 'X' ls_subttl2
                        CHANGING ls_sort.

    PERFORM f_percen2 USING 'C31' 'X' ls_subttl2 '2'
                      CHANGING ls_sort.

    PERFORM f_calculate USING '2' ls_subttl2
                        CHANGING ls_subttl3.

    CLEAR : ls_subttl2.
  ENDLOOP.

  ls_sort-sort = 2.

  lv_maktx = '**** Grand Total'.

  PERFORM f_subtotal3 USING lv_maktx 'C71' 'X' ls_subttl3
                      CHANGING ls_sort.

  PERFORM f_percen3 USING 'C71' 'X' ls_subttl3 '2'
                    CHANGING ls_sort.
ENDFORM.                    " F_PROSES_DATA_RADIO4

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA_RADIO5
*&---------------------------------------------------------------------*
FORM f_proses_data_radio5 .
  DATA : lt_detquot1  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot2  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot3  LIKE i_detquot OCCURS 0 WITH HEADER LINE.

  DATA : lv_abgru     TYPE vbap-abgru,
         lv_percen    TYPE p DECIMALS 2,
         lv_line      TYPE p DECIMALS 2 VALUE 100,
         lv_docu      TYPE p DECIMALS 2 VALUE 100,
         lv_leadt     TYPE i,
         lv_fieldnm(20),
         lv_maktx     TYPE makt-maktx.

  DATA : lt_cntpodo   TYPE STANDARD TABLE OF ty_cntpodo,
         ls_cntpodo   LIKE LINE OF lt_cntpodo.

  DATA : ls_sort      TYPE ty_sort.

  DATA : ls_line 	    TYPE REF TO data.

  DATA : ls_subttl1   TYPE ty_subttl,
         ls_subttl2   TYPE ty_subttl,
         ls_subttl3   TYPE ty_subttl,
         ls_subttl4   TYPE ty_subttl.

  SORT i_detquot BY vkbur knkli vbeln matnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.

  lt_detquot1[] = i_detquot[].
  SORT lt_detquot1 BY vkbur knkli vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_detquot1 COMPARING vkbur knkli vbeln.
  lt_detquot2[] = lt_detquot1[].
  SORT lt_detquot2 BY vkbur knkli.
  DELETE ADJACENT DUPLICATES FROM lt_detquot2 COMPARING vkbur knkli.
  lt_detquot3[] = lt_detquot2[].
  SORT lt_detquot3 BY vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_detquot3 COMPARING vkbur.

  CREATE DATA ls_line LIKE LINE OF <fs_output>.
  ASSIGN ls_line->* TO <fs_subttl4>.
  ls_sort-sort = 1.

  LOOP AT lt_detquot3.
    CREATE DATA ls_line LIKE LINE OF <fs_output>.
    ASSIGN ls_line->* TO <fs_subttl3>.
    ADD 1 TO ls_sort-sort5.
    ADD 1 TO ls_sort-sort6.

    LOOP AT lt_detquot2 WHERE vkbur = lt_detquot3-vkbur.
      CREATE DATA ls_line LIKE LINE OF <fs_output>.
      ASSIGN ls_line->* TO <fs_subttl2>.
      ADD 1 TO ls_sort-sort3.
      ADD 1 TO ls_sort-sort4.

      LOOP AT lt_detquot1 WHERE vkbur = lt_detquot2-vkbur
                            AND knkli = lt_detquot2-knkli.
        CREATE DATA ls_line LIKE LINE OF <fs_output>.
        ASSIGN ls_line->* TO <fs_subttl1>.
        ADD 1 TO ls_sort-sort2.
        ADD 1 TO ls_subttl1-podoc.

        LOOP AT i_detquot WHERE vkbur = lt_detquot1-vkbur
                            AND knkli = lt_detquot1-knkli
                            AND vbeln = lt_detquot1-vbeln.
          ADD 1 TO ls_sort-sort1.
          lv_abgru  = i_detquot-abgru.

          PERFORM f_hidden_column USING ls_sort '' 'IDR'.

          PERFORM f_po_column USING '' '' i_detquot-vbeln
                                    i_detquot-bstdk i_detquot-matnr
                                    i_detquot-maktx i_detquot-kwmeng
                                    i_detquot-kzwi1 '' '' '' '' ''.

          ADD 1 TO ls_subttl1-polin.
          ADD i_detquot-kwmeng TO ls_subttl1-poqty.
          ADD i_detquot-kzwi1 TO ls_subttl1-poval.

          CLEAR i_detsales.
          READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                         vgpos = i_detquot-posnr
                                BINARY SEARCH.
          IF sy-subrc <> 0.
            IF i_detquot-erdat >= '20201001' AND
              p_vkorg = '8020'.
              CLEAR i_detsales.
              READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                             posnr = i_detquot-posnr.
            ENDIF.
          ENDIF.

          CLEAR i_detdelv.
          READ TABLE i_detdelv WITH KEY vgbel = i_detsales-vbeln
                                        vgpos = i_detsales-posnr
                               BINARY SEARCH.

          CLEAR t_cust.
          READ TABLE t_cust WITH KEY vbeln = i_detdelv-vbeln.

          IF i_detdelv-vbeln IS NOT INITIAL.
            PERFORM f_do_column USING i_detdelv-vbeln i_detdelv-erdat
                                      t_cust-crdat i_detdelv-matnr
                                      i_detdelv-maktx i_detsales-kwmeng
                                      i_detsales-kzwi1.

            ADD i_detsales-kwmeng TO ls_subttl1-doqty.
            ADD i_detsales-kzwi1 TO ls_subttl1-doval.
            ADD 1 TO ls_subttl1-dolin.

            IF p_val = 'X'.
              IF i_detquot-kzwi1 IS INITIAL.
                lv_percen = 0.
              ELSE.
                lv_percen = ( i_detsales-kzwi1 / i_detquot-kzwi1 ) * 100.
              ENDIF.
            ELSE.
              IF i_detquot-kzwi1 IS INITIAL.
                lv_percen = 0.
              ELSE.
                lv_percen = ( i_detsales-kwmeng / i_detquot-kwmeng  ) * 100.
              ENDIF.
            ENDIF.

            PERFORM f_percen_column USING lv_percen lv_line lv_docu.
          ELSE.
            READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln.
            READ TABLE i_detdelv WITH KEY vgbel = i_detsales-vbeln.
            IF sy-subrc = 0.
              PERFORM f_percen_column USING '' '' lv_docu.
            ENDIF.
          ENDIF.

          READ TABLE lt_cntpodo INTO ls_cntpodo
                                WITH KEY vkbur = i_detquot-vkbur
                                         vbeln = i_detdelv-vbeln
                                TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            CONTINUE.
          ELSE.
            ls_cntpodo-vkbur  = i_detquot-vkbur.
            ls_cntpodo-vbeln  = i_detdelv-vbeln.
            IF i_detdelv-vbeln IS NOT INITIAL.
              COLLECT ls_cntpodo INTO lt_cntpodo.
              ADD 1 TO ls_subttl1-dodoc.
            ENDIF.
          ENDIF.

          APPEND <fs_line> TO <fs_output>.
          CLEAR : <fs_line>.
          CLEAR : lv_abgru.
        ENDLOOP.

        ADD 1 TO ls_sort-sort1.
        ADD 1 TO ls_sort-sort2.

        CONCATENATE '*    Total PO' lt_detquot1-vbeln INTO lv_maktx
        SEPARATED BY space.

        PERFORM f_subtotal1 USING lv_maktx 'C30' '' ls_subttl1
                            CHANGING ls_sort.

        PERFORM f_percen1 USING 'C30' '' ls_subttl1 '2'
                          CHANGING ls_sort.

        PERFORM f_calculate USING '0' ls_subttl1
                            CHANGING ls_subttl2.

        CLEAR : ls_subttl1.
      ENDLOOP.

      ADD 1 TO ls_sort-sort3.

      CONCATENATE '**   Total' lt_detquot2-knkli INTO lv_maktx
      SEPARATED BY space.

      PERFORM f_subtotal2 USING lv_maktx 'C31' '' ls_subttl2
                          CHANGING ls_sort.
      PERFORM f_percen2 USING 'C31' '' ls_subttl2 '2'
                        CHANGING ls_sort.

      PERFORM f_calculate USING '0' ls_subttl2
                          CHANGING ls_subttl3.

      CLEAR : ls_subttl2.
    ENDLOOP.

    ADD 1 TO ls_sort-sort5.

    CONCATENATE '***  Total Sloff' lt_detquot3-vkbur INTO lv_maktx
    SEPARATED BY space.

    PERFORM f_subtotal3 USING lv_maktx 'C70' '' ls_subttl3
                        CHANGING ls_sort.

    PERFORM f_percen3 USING 'C70' '' ls_subttl3 '2'
                      CHANGING ls_sort.

    PERFORM f_calculate USING '0'ls_subttl3
                        CHANGING ls_subttl4.

    CLEAR : ls_subttl3.
  ENDLOOP.

  ls_sort-sort = 2.

  lv_maktx = '**** Grand Total'.

  PERFORM f_subtotal4 USING lv_maktx 'C71' '' ls_subttl4
                      CHANGING ls_sort.

  PERFORM f_percen4 USING 'C71' '' ls_subttl4 '2'
                    CHANGING ls_sort.
ENDFORM.                    " F_PROSES_DATA_RADIO5

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_SUMMDATA_RADIO5
*&---------------------------------------------------------------------*
FORM f_proses_summdata_radio5 .
  DATA : lt_detquot1  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detdelv1  LIKE i_detdelv OCCURS 0 WITH HEADER LINE.

  DATA : lv_percen    TYPE p DECIMALS 2.
  DATA : ls_sum05     LIKE LINE OF i_detquot,
         ls_knvv      LIKE LINE OF i_knvv.
  DATA : ls_subttl    TYPE ty_subttl.
  DATA : ls_sort      TYPE ty_sort.
  DATA : lt_cntpodo   TYPE STANDARD TABLE OF ty_cntpodo,
         ls_cntpodo   LIKE LINE OF lt_cntpodo.

  SORT i_detquot BY vkbur knkli vbeln posnr matnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.

  lt_detquot1[] = i_detquot[].
  SORT lt_detquot1 BY vkbur kukla knkli vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_detquot1 COMPARING vkbur kukla knkli vbeln.
  lt_detdelv1[] = i_detdelv[].
  SORT lt_detdelv1 BY vgbel.
  DELETE ADJACENT DUPLICATES FROM lt_detdelv1 COMPARING vgbel.

  LOOP AT gt_sum05 INTO ls_sum05.
    CLEAR ls_knvv.
    READ TABLE i_knvv INTO ls_knvv WITH KEY kunnr = ls_sum05-knkli.

    LOOP AT i_detquot WHERE vkbur = ls_sum05-vkbur
                        AND kukla = ls_sum05-kukla
                        AND knkli = ls_sum05-knkli.

      PERFORM f_hidden_column USING ls_sort '' 'IDR'.

      PERFORM f_summary_column USING i_detquot-vkbur i_detquot-kukla
                                     i_detquot-vtext ls_knvv-vkbur
                                     i_detquot-knkli i_detquot-name1.

      ADD i_detquot-kwmeng TO ls_subttl-poqty.
      ADD i_detquot-kzwi1 TO ls_subttl-poval.

      PERFORM f_po_column USING '' '' '' '' '' '' ls_subttl-poqty
                                ls_subttl-poval '' '' '' '' ''.

      ADD 1 TO ls_subttl-polin.

      CLEAR i_detsales.
      READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                     vgpos = i_detquot-posnr
                            BINARY SEARCH.
      IF sy-subrc <> 0.
        IF i_detquot-erdat >= '20201001' AND
          p_vkorg = '8020'.
          CLEAR i_detsales.
          READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                         posnr = i_detquot-posnr.
        ENDIF.
      ENDIF.

      CLEAR i_detdelv.
      READ TABLE i_detdelv WITH KEY vgbel = i_detsales-vbeln
                                    vgpos = i_detsales-posnr
                           BINARY SEARCH.

      CLEAR t_cust.
      READ TABLE t_cust WITH KEY vbeln = i_detdelv-vbeln.

      IF i_detdelv-vbeln IS NOT INITIAL.
        ADD i_detsales-kwmeng TO ls_subttl-doqty.
        ADD i_detsales-kzwi1 TO ls_subttl-doval.
        ADD 1 TO ls_subttl-dolin.
        PERFORM f_do_column USING '' '' '' '' '' ls_subttl-doqty
                                  ls_subttl-doval.
      ENDIF.

      READ TABLE lt_cntpodo INTO ls_cntpodo
                            WITH KEY vkbur = i_detquot-vkbur
                                     vbeln = i_detdelv-vbeln
                            TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        CONTINUE.
      ELSE.
        ls_cntpodo-vkbur  = i_detquot-vkbur.
        ls_cntpodo-vbeln  = i_detdelv-vbeln.
        IF i_detdelv-vbeln IS NOT INITIAL.
          COLLECT ls_cntpodo INTO lt_cntpodo.
          ADD 1 TO ls_subttl-dodoc.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_detquot1 WHERE vkbur = ls_sum05-vkbur
                          AND kukla = ls_sum05-kukla
                          AND knkli = ls_sum05-knkli.
      ADD 1 TO ls_subttl-podoc.
    ENDLOOP.

    ASSIGN COMPONENT 'PODOC' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-podoc.
    ASSIGN COMPONENT 'POLIN' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-polin.
    ASSIGN COMPONENT 'DODOC' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-dodoc.
    ASSIGN COMPONENT 'DOLIN' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-dolin.

    PERFORM f_sl_calculate USING ls_subttl-doqty ls_subttl-poqty
                                 ls_subttl-doval ls_subttl-poval
                                 ls_subttl-dolin ls_subttl-polin
                                 ls_subttl-dodoc ls_subttl-podoc
                           CHANGING ls_subttl-slqty ls_subttl-slval
                                    ls_subttl-sllin ls_subttl-sldoc.

    ASSIGN COMPONENT 'SLQTY' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-slqty.
    ASSIGN COMPONENT 'SLVAL' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-slval.
    ASSIGN COMPONENT 'SLLIN' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-sllin.
    ASSIGN COMPONENT 'SLDOC' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-sldoc.

    APPEND <fs_line> TO <fs_output>.
    CLEAR : <fs_line>, ls_subttl.
  ENDLOOP.
ENDFORM.                    " F_PROSES_SUMMDATA_RADIO5

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA_RADIO6
*&---------------------------------------------------------------------*
FORM f_proses_data_radio6 .
  DATA : lt_detquot1  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot2  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detquot3  LIKE i_detquot OCCURS 0 WITH HEADER LINE.

  DATA : lv_abgru     TYPE vbap-abgru,
         lv_percen    TYPE p DECIMALS 2,
         lv_line      TYPE p DECIMALS 2 VALUE 100,
         lv_docu      TYPE p DECIMALS 2 VALUE 100,
         lv_leadt     TYPE i,
         lv_fieldnm(20),
         lv_maktx     TYPE makt-maktx.

  DATA : ls_sort      TYPE ty_sort.

  DATA : ls_line 	    TYPE REF TO data.

  DATA : ls_subttl1   TYPE ty_subttl,
         ls_subttl2   TYPE ty_subttl,
         ls_subttl3   TYPE ty_subttl,
         ls_subttl4   TYPE ty_subttl.

  DATA : lt_cntpodo   TYPE STANDARD TABLE OF ty_cntpodo,
         ls_cntpodo   LIKE LINE OF lt_cntpodo.

  SORT i_detquot BY vkbur kunrl vbeln matnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.

  lt_detquot1[] = i_detquot[].
  SORT lt_detquot1 BY vkbur kunrl vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_detquot1 COMPARING vkbur kunrl vbeln.
  lt_detquot2[] = lt_detquot1[].
  SORT lt_detquot2 BY vkbur kunrl.
  DELETE ADJACENT DUPLICATES FROM lt_detquot2 COMPARING vkbur kunrl.
  lt_detquot3[] = lt_detquot2[].
  SORT lt_detquot3 BY vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_detquot3 COMPARING vkbur.

  CREATE DATA ls_line LIKE LINE OF <fs_output>.
  ASSIGN ls_line->* TO <fs_subttl4>.
  ls_sort-sort = 1.

  LOOP AT lt_detquot3.
    CREATE DATA ls_line LIKE LINE OF <fs_output>.
    ASSIGN ls_line->* TO <fs_subttl3>.
    ADD 1 TO ls_sort-sort5.
    ADD 1 TO ls_sort-sort6.

    LOOP AT lt_detquot2 WHERE vkbur = lt_detquot3-vkbur.
      CREATE DATA ls_line LIKE LINE OF <fs_output>.
      ASSIGN ls_line->* TO <fs_subttl2>.
      ADD 1 TO ls_sort-sort3.
      ADD 1 TO ls_sort-sort4.

      LOOP AT lt_detquot1 WHERE vkbur = lt_detquot2-vkbur
                            AND kunrl = lt_detquot2-kunrl.
        CREATE DATA ls_line LIKE LINE OF <fs_output>.
        ASSIGN ls_line->* TO <fs_subttl1>.
        ADD 1 TO ls_sort-sort2.
        ADD 1 TO ls_subttl1-podoc.

        LOOP AT i_detquot WHERE vkbur = lt_detquot1-vkbur
                            AND kunrl = lt_detquot1-kunrl
                            AND vbeln = lt_detquot1-vbeln.
          ADD 1 TO ls_sort-sort1.
          lv_abgru  = i_detquot-abgru.

          PERFORM f_hidden_column USING ls_sort '' 'IDR'.

          PERFORM f_po_column USING '' '' i_detquot-vbeln
                                    i_detquot-bstdk i_detquot-matnr
                                    i_detquot-maktx i_detquot-kwmeng
                                    i_detquot-kzwi1 '' '' '' '' ''.

          ADD 1 TO ls_subttl1-polin.
          ADD i_detquot-kwmeng TO ls_subttl1-poqty.
          ADD i_detquot-kzwi1 TO ls_subttl1-poval.

          CLEAR i_detsales.
          READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                         vgpos = i_detquot-posnr
                                BINARY SEARCH.
          IF sy-subrc <> 0.
            IF i_detquot-erdat >= '20201001' AND
              p_vkorg = '8020'.
              CLEAR i_detsales.
              READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                             posnr = i_detquot-posnr.
            ENDIF.
          ENDIF.

          CLEAR i_detdelv.
          READ TABLE i_detdelv WITH KEY vgbel = i_detsales-vbeln
                                        vgpos = i_detsales-posnr
                               BINARY SEARCH.

          CLEAR t_cust.
          READ TABLE t_cust WITH KEY vbeln = i_detdelv-vbeln.

          IF i_detdelv-vbeln IS NOT INITIAL.
            PERFORM f_do_column USING i_detdelv-vbeln i_detdelv-erdat
                                      t_cust-crdat i_detdelv-matnr
                                      i_detdelv-maktx i_detsales-kwmeng
                                      i_detsales-kzwi1.

            ADD i_detsales-kwmeng TO ls_subttl1-doqty.
            ADD i_detsales-kzwi1 TO ls_subttl1-doval.
            ADD 1 TO ls_subttl1-dolin.

            IF p_val = 'X'.
              IF i_detquot-kzwi1 IS INITIAL.
                lv_percen = 0.
              ELSE.
                lv_percen = ( i_detsales-kzwi1 / i_detquot-kzwi1 ) * 100.
              ENDIF.
            ELSE.
              IF i_detquot-kzwi1 IS INITIAL.
                lv_percen = 0.
              ELSE.
                lv_percen = ( i_detsales-kwmeng / i_detquot-kwmeng  ) * 100.
              ENDIF.
            ENDIF.

            PERFORM f_percen_column USING lv_percen lv_line lv_docu.
          ELSE.
            READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln.
            READ TABLE i_detdelv WITH KEY vgbel = i_detsales-vbeln.
            IF sy-subrc = 0.
              PERFORM f_percen_column USING '' '' lv_docu.
            ENDIF.
          ENDIF.

          READ TABLE lt_cntpodo INTO ls_cntpodo
                                WITH KEY vkbur = i_detquot-vkbur
                                         vbeln = i_detdelv-vbeln
                                TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            CONTINUE.
          ELSE.
            ls_cntpodo-vkbur  = i_detquot-vkbur.
            ls_cntpodo-vbeln  = i_detdelv-vbeln.
            IF i_detdelv-vbeln IS NOT INITIAL.
              COLLECT ls_cntpodo INTO lt_cntpodo.
              ADD 1 TO ls_subttl1-dodoc.
            ENDIF.
          ENDIF.

          APPEND <fs_line> TO <fs_output>.
          CLEAR : <fs_line>.
          CLEAR : lv_abgru.
        ENDLOOP.

        ADD 1 TO ls_sort-sort1.
        ADD 1 TO ls_sort-sort2.

        CONCATENATE '*    Total PO' lt_detquot1-vbeln INTO lv_maktx
        SEPARATED BY space.

        PERFORM f_subtotal1 USING lv_maktx 'C30' '' ls_subttl1
                            CHANGING ls_sort.

        PERFORM f_percen1 USING 'C30' '' ls_subttl1 '2'
                          CHANGING ls_sort.

        PERFORM f_calculate USING '0' ls_subttl1
                            CHANGING ls_subttl2.

        CLEAR : ls_subttl1.
      ENDLOOP.

      ADD 1 TO ls_sort-sort3.

      CONCATENATE '**   Total' lt_detquot2-kunrl INTO lv_maktx
      SEPARATED BY space.

      PERFORM f_subtotal2 USING lv_maktx 'C31' '' ls_subttl2
                          CHANGING ls_sort.
      PERFORM f_percen2 USING 'C31' '' ls_subttl2 '2'
                        CHANGING ls_sort.

      PERFORM f_calculate USING '0' ls_subttl2
                          CHANGING ls_subttl3.

      CLEAR : ls_subttl2.
    ENDLOOP.

    ADD 1 TO ls_sort-sort5.

    CONCATENATE '***  Total Sloff' lt_detquot3-vkbur INTO lv_maktx
    SEPARATED BY space.

    PERFORM f_subtotal3 USING lv_maktx 'C70' '' ls_subttl3
                        CHANGING ls_sort.

    PERFORM f_percen3 USING 'C70' '' ls_subttl3 '2'
                      CHANGING ls_sort.

    PERFORM f_calculate USING '0' ls_subttl3
                        CHANGING ls_subttl4.

    CLEAR : ls_subttl3.
  ENDLOOP.

  ls_sort-sort = 2.

  lv_maktx = '**** Grand Total'.

  PERFORM f_subtotal4 USING lv_maktx 'C71' '' ls_subttl4
                      CHANGING ls_sort.

  PERFORM f_percen4 USING 'C71' '' ls_subttl4 '2'
                    CHANGING ls_sort.
ENDFORM.                    " F_PROSES_DATA_RADIO6

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_SUMMDATA_RADIO6
*&---------------------------------------------------------------------*
FORM f_proses_summdata_radio6 .
  DATA : lt_detquot1  LIKE i_detquot OCCURS 0 WITH HEADER LINE,
         lt_detdelv1  LIKE i_detdelv OCCURS 0 WITH HEADER LINE.

  DATA : lv_percen    TYPE p DECIMALS 2.
  DATA : ls_sum06     LIKE LINE OF i_detquot,
         ls_knvv      LIKE LINE OF i_knvv.
  DATA : ls_subttl    TYPE ty_subttl.
  DATA : ls_sort      TYPE ty_sort.
  DATA : lt_cntpodo   TYPE STANDARD TABLE OF ty_cntpodo,
         ls_cntpodo   LIKE LINE OF lt_cntpodo.

  SORT i_detquot BY vkbur kunrl vbeln matnr.
  SORT i_detsales BY vgbel vgpos matnr.
  SORT i_detdelv  BY vgbel vgpos matnr.

  lt_detquot1[] = i_detquot[].
  SORT lt_detquot1 BY vkbur kukla kunrl vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_detquot1 COMPARING vkbur kukla kunrl vbeln.
  lt_detdelv1[] = i_detdelv[].
  SORT lt_detdelv1 BY vgbel.
  DELETE ADJACENT DUPLICATES FROM lt_detdelv1 COMPARING vgbel.

  LOOP AT gt_sum06 INTO ls_sum06.
    CLEAR ls_knvv.
    READ TABLE i_knvv INTO ls_knvv WITH KEY kunnr = ls_sum06-kunrl.

    LOOP AT i_detquot WHERE vkbur = ls_sum06-vkbur
                        AND kukla = ls_sum06-kukla
                        AND kunrl = ls_sum06-kunrl.

      PERFORM f_hidden_column USING ls_sort '' 'IDR'.

      PERFORM f_summary_column USING i_detquot-vkbur i_detquot-kukla
                                     i_detquot-vtext ls_knvv-vkbur
                                     i_detquot-kunrl i_detquot-namrl.

      ADD i_detquot-kwmeng TO ls_subttl-poqty.
      ADD i_detquot-kzwi1 TO ls_subttl-poval.

      PERFORM f_po_column USING '' '' '' '' '' '' ls_subttl-poqty
                                ls_subttl-poval '' '' '' '' ''.

      ADD 1 TO ls_subttl-polin.

      CLEAR i_detsales.
      READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                     vgpos = i_detquot-posnr
                            BINARY SEARCH.
      IF sy-subrc <> 0.
        IF i_detquot-erdat >= '20201001' AND
          p_vkorg = '8020'.
          CLEAR i_detsales.
          READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                         posnr = i_detquot-posnr.
        ENDIF.
      ENDIF.

      CLEAR i_detdelv.
      READ TABLE i_detdelv WITH KEY vgbel = i_detsales-vbeln
                                    vgpos = i_detsales-posnr
                           BINARY SEARCH.

      CLEAR t_cust.
      READ TABLE t_cust WITH KEY vbeln = i_detdelv-vbeln.

      IF i_detdelv-vbeln IS NOT INITIAL.
        ADD i_detsales-kwmeng TO ls_subttl-doqty.
        ADD i_detsales-kzwi1 TO ls_subttl-doval.
        ADD 1 TO ls_subttl-dolin.
        PERFORM f_do_column USING '' '' '' '' '' ls_subttl-doqty
                                  ls_subttl-doval.
      ENDIF.

      READ TABLE lt_cntpodo INTO ls_cntpodo
                            WITH KEY vkbur = i_detquot-vkbur
                                     vbeln = i_detdelv-vbeln
                            TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        CONTINUE.
      ELSE.
        ls_cntpodo-vkbur  = i_detquot-vkbur.
        ls_cntpodo-vbeln  = i_detdelv-vbeln.
        IF i_detdelv-vbeln IS NOT INITIAL.
          COLLECT ls_cntpodo INTO lt_cntpodo.
          ADD 1 TO ls_subttl-dodoc.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_detquot1 WHERE vkbur = ls_sum06-vkbur
                          AND kukla = ls_sum06-kukla
                          AND kunrl = ls_sum06-kunrl.
      ADD 1 TO ls_subttl-podoc.
    ENDLOOP.


    ASSIGN COMPONENT 'PODOC' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-podoc.
    ASSIGN COMPONENT 'POLIN' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-polin.
    ASSIGN COMPONENT 'DODOC' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-dodoc.
    ASSIGN COMPONENT 'DOLIN' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-dolin.

    PERFORM f_sl_calculate USING ls_subttl-doqty ls_subttl-poqty
                                 ls_subttl-doval ls_subttl-poval
                                 ls_subttl-dolin ls_subttl-polin
                                 ls_subttl-dodoc ls_subttl-podoc
                           CHANGING ls_subttl-slqty ls_subttl-slval
                                    ls_subttl-sllin ls_subttl-sldoc.

    ASSIGN COMPONENT 'SLQTY' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-slqty.
    ASSIGN COMPONENT 'SLVAL' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-slval.
    ASSIGN COMPONENT 'SLLIN' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-sllin.
    ASSIGN COMPONENT 'SLDOC' OF STRUCTURE <fs_line> TO <fs>.
    <fs> = ls_subttl-sldoc.

    APPEND <fs_line> TO <fs_output>.
    CLEAR : <fs_line>, ls_subttl.
  ENDLOOP.
ENDFORM.                    " F_PROSES_SUMMDATA_RADIO6

*&---------------------------------------------------------------------*
*&      Form  F_SUMMARY_COLUMN
*&---------------------------------------------------------------------*
FORM f_summary_column  USING    fu_vkbur fu_kukla fu_vtext fu_vkbvv
                                fu_kunnr fu_name1.
  CASE 'X'.
    WHEN radio5.
      IF p_summ5 IS NOT INITIAL.
        ASSIGN COMPONENT 'VKBUR' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_vkbur.
        ASSIGN COMPONENT 'KUKLA' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kukla.
        ASSIGN COMPONENT 'VTEXT' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_vtext.
        ASSIGN COMPONENT 'VKBVV' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_vkbvv.
        ASSIGN COMPONENT 'KNKLI' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kunnr.
        ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_name1.
      ENDIF.

    WHEN radio6.
      IF p_summ6 IS NOT INITIAL.
        ASSIGN COMPONENT 'VKBUR' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_vkbur.
        ASSIGN COMPONENT 'KUKLA' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kukla.
        ASSIGN COMPONENT 'VTEXT' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_vtext.
        ASSIGN COMPONENT 'VKBVV' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_vkbvv.
        ASSIGN COMPONENT 'KUNRL' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_kunnr.
        ASSIGN COMPONENT 'NAMRL' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_name1.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_SUMMARY_COLUMN

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SUBTOTAL
*&---------------------------------------------------------------------*
FORM f_modify_subtotal .
  DATA : lo_grid      TYPE REF TO  cl_gui_alv_grid.
  DATA : lt_total00   TYPE REF TO data,
         lt_total01   TYPE REF TO data,
         lt_total02   TYPE REF TO data.

  IF lo_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = lo_grid.
  ENDIF.

  CALL METHOD lo_grid->get_subtotals
    IMPORTING
      ep_collect00 = lt_total00
      ep_collect01 = lt_total01
      ep_collect02 = lt_total02.

  ASSIGN lt_total00->* TO <fs_subttl>.
  PERFORM f_assign_subtotal.
  ASSIGN lt_total01->* TO <fs_subttl>.
  PERFORM f_assign_subtotal.
  ASSIGN lt_total02->* TO <fs_subttl>.
  PERFORM f_assign_subtotal.

  CALL METHOD lo_grid->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'.
ENDFORM.                    " F_MODIFY_SUBTOTAL

*&---------------------------------------------------------------------*
*&      Form  F_SL_CALCULATE
*&---------------------------------------------------------------------*
FORM f_sl_calculate  USING    fu_doqty fu_poqty fu_doval fu_poval
                              fu_dolin fu_polin fu_dodoc fu_podoc
                     CHANGING fc_slqty fc_slval fc_sllin fc_sldoc.

  IF fu_poqty IS NOT INITIAL.
    fc_slqty = ( fu_doqty / fu_poqty ) * 100.
  ELSE.
    CLEAR fc_slqty.
  ENDIF.
  IF fu_poval IS NOT INITIAL.
    fc_slval = ( fu_doval / fu_poval ) * 100.
  ELSE.
    CLEAR fc_slval.
  ENDIF.
  IF fu_polin IS NOT INITIAL.
    fc_sllin = ( fu_dolin / fu_polin ) * 100.
  ELSE.
    CLEAR fc_sllin.
  ENDIF.
  IF fu_podoc IS NOT INITIAL.
    fc_sldoc = ( fu_dodoc / fu_podoc ) * 100.
  ELSE.
    CLEAR fc_sldoc.
  ENDIF.
ENDFORM.                    " F_SL_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_ASSIGN_SUBTOTAL
*&---------------------------------------------------------------------*
FORM f_assign_subtotal .
  DATA : ls_line      TYPE ty_summary.

  LOOP AT <fs_subttl> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'KWMENG' OF STRUCTURE <fs_st> TO <fs>.
    ls_line-poqty = <fs>.
    ASSIGN COMPONENT 'DLQTY' OF STRUCTURE <fs_st> TO <fs>.
    ls_line-dlqty = <fs>.
    ASSIGN COMPONENT 'KZWI1' OF STRUCTURE <fs_st> TO <fs>.
    ls_line-poval = <fs>.
    ASSIGN COMPONENT 'DLVAL' OF STRUCTURE <fs_st> TO <fs>.
    ls_line-dlval = <fs>.
    ASSIGN COMPONENT 'DOLIN' OF STRUCTURE <fs_st> TO <fs>.
    ls_line-dolin = <fs>.
    ASSIGN COMPONENT 'DODOC' OF STRUCTURE <fs_st> TO <fs>.
    ls_line-dodoc = <fs>.
    ASSIGN COMPONENT 'POLIN' OF STRUCTURE <fs_st> TO <fs>.
    ls_line-polin = <fs>.
    ASSIGN COMPONENT 'PODOC' OF STRUCTURE <fs_st> TO <fs>.
    ls_line-podoc = <fs>.

    PERFORM f_sl_calculate USING ls_line-dlqty ls_line-poqty
                                 ls_line-dlval ls_line-poval
                                 ls_line-dolin ls_line-polin
                                 ls_line-dodoc ls_line-podoc
                           CHANGING ls_line-slqty ls_line-slval
                                    ls_line-sllin ls_line-sldoc.

    ASSIGN COMPONENT 'SLQTY' OF STRUCTURE <fs_st> TO <fs>.
    <fs> = ls_line-slqty.
    ASSIGN COMPONENT 'SLVAL' OF STRUCTURE <fs_st> TO <fs>.
    <fs> = ls_line-slval.
    ASSIGN COMPONENT 'SLLIN' OF STRUCTURE <fs_st> TO <fs>.
    <fs> = ls_line-sllin.
    ASSIGN COMPONENT 'SLDOC' OF STRUCTURE <fs_st> TO <fs>.
    <fs> = ls_line-sldoc.
  ENDLOOP.
ENDFORM.                    " F_ASSIGN_SUBTOTAL

*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
FORM comment_build  USING    lt_top_of_page TYPE slis_t_listheader
                             fu_title.
  DATA : ls_line TYPE slis_listheader.
  DATA : lv_low(10),
         lv_high(10).

  CONCATENATE 'Service Level' fu_title INTO sy-title SEPARATED BY space.

  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = sy-title.
  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key  = 'Period'.
  IF s_erdat-high IS INITIAL.
    WRITE s_erdat-low TO lv_low DD/MM/YYYY.
    ls_line-info = lv_low.
  ELSE.
    WRITE s_erdat-low TO lv_low DD/MM/YYYY.
    WRITE s_erdat-high TO lv_high DD/MM/YYYY.
    CONCATENATE lv_low 'to' lv_high INTO ls_line-info
    SEPARATED BY space.
  ENDIF.
  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  IF p_val = 'X'.
    ls_line-key  = 'By Value'.
  ELSE.
    ls_line-key  = 'By Quantity'.
  ENDIF.
  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
ENDFORM.                    " COMMENT_BUILD

*&---------------------------------------------------------------------*
*&      Form  F_PERCEN_COLUMN
*&---------------------------------------------------------------------*
FORM f_percen_column  USING    fu_percen fu_line fu_docu.
  IF fu_percen IS NOT INITIAL.
    ASSIGN COMPONENT 'PERCEN' OF STRUCTURE <fs_line> TO <fs>.
    WRITE fu_percen TO <fs> DECIMALS 2.
  ENDIF.
  IF fu_line IS NOT INITIAL.
    ASSIGN COMPONENT 'LINE' OF STRUCTURE <fs_line> TO <fs>.
    WRITE fu_line TO <fs> DECIMALS 2.
  ENDIF.
  IF fu_docu IS NOT INITIAL.
    ASSIGN COMPONENT 'DOCU' OF STRUCTURE <fs_line> TO <fs>.
    WRITE fu_docu TO <fs> DECIMALS 2.
  ENDIF.
ENDFORM.                    " F_PERCEN_COLUMN

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD
*&---------------------------------------------------------------------*
FORM f_download .
  DATA : lt_download    TYPE truxs_t_text_data,
         ls_download    LIKE LINE OF lt_download,
         lv_command(125).

  DATA : lv_path      TYPE char128,
         lv_month(6),
         lv_leadt     TYPE i,
         lv_kwmeng    TYPE vbap-kwmeng,
         lv_kzwi1     TYPE vbap-kzwi1,
         lv_fieldnm(20),
         lv_percen    TYPE p DECIMALS 2.

  DATA : BEGIN OF tabl OCCURS 10,
           line(200),
         END OF tabl.

  DATA : ls_char  TYPE ty_char.

  DATA : ls_knvv  LIKE LINE OF i_knvv.

  DATA : lv_abgru     TYPE vbap-abgru.

  IF s_erdat-high IS NOT INITIAL.
    lv_month = s_erdat-high(6).
  ELSE.
    lv_month = s_erdat-low(6).
  ENDIF.

  SELECT SINGLE low
    FROM tvarvc
    INTO lv_path
    WHERE name = 'ZDSP_PATHSL'.

  IF sy-subrc = 0.
*    CONCATENATE lv_path p_vkorg '_SO_' lv_month '.csv' INTO lv_path.
    CONCATENATE lv_path s_vkbur-low '_SO_' lv_month '.csv' INTO lv_path.

    LOOP AT i_detquot.
      PERFORM f_unit_convert USING i_detquot-kwmeng ''
                             CHANGING ls_char-poqty.
      PERFORM f_curr_convert USING i_detquot-kzwi1 ''
                             CHANGING ls_char-poval.

      CLEAR i_detsales.
      READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                     vgpos = i_detquot-posnr
                            BINARY SEARCH.
      IF sy-subrc <> 0.
        IF i_detquot-erdat >= '20201001' AND
          p_vkorg = '8020'.
          CLEAR i_detsales.
          READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                         posnr = i_detquot-posnr.
        ENDIF.
      ENDIF.

      CLEAR i_detdelv.
      READ TABLE i_detdelv WITH KEY vgbel = i_detsales-vbeln
                                    vgpos = i_detsales-posnr
                           BINARY SEARCH.

      CLEAR t_cust.
      READ TABLE t_cust WITH KEY vbeln = i_detdelv-vbeln.

      CLEAR : lv_kwmeng, lv_kzwi1.
      IF i_detdelv-vbeln IS NOT INITIAL.
        PERFORM f_unit_convert USING i_detsales-kwmeng ''
                               CHANGING ls_char-doqty.
        PERFORM f_curr_convert USING i_detsales-kzwi1 ''
                               CHANGING ls_char-doval.

        IF t_cust-crdat IS INITIAL.
          PERFORM f_unit_convert USING i_detsales-kwmeng ''
                                 CHANGING ls_char-lead6q.
          PERFORM f_curr_convert USING i_detsales-kzwi1 ''
                                 CHANGING ls_char-lead6v.
        ELSE.
          lv_leadt = t_cust-crdat - i_detquot-bstdk.
          IF lv_leadt LE 2.
            PERFORM f_unit_convert USING i_detsales-kwmeng ''
                                   CHANGING ls_char-lead1q.
            PERFORM f_curr_convert USING i_detsales-kzwi1 ''
                                   CHANGING ls_char-lead1v.
          ELSEIF lv_leadt GE 3 AND lv_leadt LE 4.
            PERFORM f_unit_convert USING i_detsales-kwmeng ''
                                   CHANGING ls_char-lead2q.
            PERFORM f_curr_convert USING i_detsales-kzwi1 ''
                                   CHANGING ls_char-lead2v.
          ELSEIF lv_leadt GE 5.
            PERFORM f_unit_convert USING i_detsales-kwmeng ''
                                   CHANGING ls_char-lead3q.
            PERFORM f_curr_convert USING i_detsales-kzwi1 ''
                                   CHANGING ls_char-lead3v.
          ENDIF.
        ENDIF.

*        IF i_detquot-abgru IS NOT INITIAL.
        lv_kwmeng  = i_detquot-kwmeng - i_detsales-kwmeng.
        lv_kzwi1   = i_detquot-kzwi1 - i_detsales-kzwi1.
*        ENDIF.
      ELSE.
        IF i_detsales-vbeln IS INITIAL.
          lv_kwmeng  = i_detquot-kwmeng.
          lv_kzwi1   = i_detquot-kzwi1.
        ELSE.
          IF i_detquot-abgru IS NOT INITIAL.
            lv_kwmeng  = i_detquot-kwmeng.
            lv_kzwi1   = i_detquot-kzwi1.
          ENDIF.
        ENDIF.
      ENDIF.

      PERFORM f_unit_convert USING lv_kwmeng ''
                             CHANGING ls_char-unqty.
      PERFORM f_curr_convert USING lv_kzwi1 ''
                             CHANGING ls_char-unval.

      CLEAR ls_knvv.
      READ TABLE i_knvv INTO ls_knvv WITH KEY kunnr = i_detquot-knkli.

      CONCATENATE lv_month p_vkorg i_detquot-vkbur ls_knvv-vkbur
                  i_detquot-kukla i_detquot-knkli ls_knvv-kvgr4
                  i_detquot-submi i_detquot-vbeln
                  i_detquot-princ i_detquot-matkl i_detquot-matnr
                  i_detquot-bstdk i_detquot-bstnk i_detquot-abgru
                  ls_char-poqty ls_char-poval

                  i_detdelv-vbeln i_detdelv-erdat t_cust-crdat
                  i_detdelv-matnr
                  ls_char-doqty ls_char-doval

                  ls_char-lead1q ls_char-lead1v
                  ls_char-lead2q ls_char-lead2v
                  ls_char-lead3q ls_char-lead3v
                  ls_char-unqty ls_char-unval

      INTO ls_download
      SEPARATED BY '|'.

      IF i_detquot-abgru IS INITIAL.
        i_detquot-abgru = '99'.
      ENDIF.

      LOOP AT t_abgru.
        CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_dline> TO <fs_dfield>.
        IF i_detquot-abgru = t_abgru-abgru.
          <fs_dfield> = ls_char-unqty.
          CONCATENATE ls_download '|' <fs_dfield> INTO ls_download.
        ELSE.
          CONCATENATE ls_download '|' '0' INTO ls_download.
        ENDIF.

        CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_dline> TO <fs_dfield>.
        IF i_detquot-abgru = t_abgru-abgru.
          <fs_dfield> = ls_char-unval.
          CONCATENATE ls_download '|' <fs_dfield> INTO ls_download.
        ELSE.
          CONCATENATE ls_download '|' '0.00' INTO ls_download.
        ENDIF.
      ENDLOOP.


      CONCATENATE ls_download     i_detquot-erdat
                  i_detquot-erzet i_detquot-ernam
                  INTO ls_download SEPARATED BY '|'.

      APPEND ls_download TO lt_download.
      CLEAR : ls_download, ls_char.
    ENDLOOP.

    CALL METHOD zcl_util=>m_delete_file
      EXPORTING
        param_name = lv_path.

    CALL METHOD zcl_util=>m_download_dataset
      EXPORTING
        param_name = lv_path
        pti_data   = lt_download[].

    CONCATENATE 'chmod 666' lv_path INTO lv_command SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD lv_command
                  ID 'TAB' FIELD tabl-*sys*.

  ENDIF.
ENDFORM.                    " F_DOWNLOAD

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERT
*&---------------------------------------------------------------------*
FORM f_unit_convert  USING    fu_value fu_meins
                     CHANGING fc_value.
  CLEAR fc_value.

  IF fu_value > 0.
    WRITE fu_value TO fc_value DECIMALS 0.
    TRANSLATE fc_value USING '. '.
    TRANSLATE fc_value USING ',.'.
    CONDENSE fc_value NO-GAPS.
  ENDIF.
ENDFORM.                    " F_UNIT_CONVERT

*&---------------------------------------------------------------------*
*&      Form  F_CURR_CONVERT
*&---------------------------------------------------------------------*
FORM f_curr_convert  USING    fu_value fu_curr
                     CHANGING fc_value.
  CLEAR fc_value.
  IF fu_value > 0.
    WRITE fu_value TO fc_value.
    TRANSLATE fc_value USING '. '.
    TRANSLATE fc_value USING ',.'.
    CONDENSE fc_value NO-GAPS.
  ENDIF.
ENDFORM.                    " F_CURR_CONVERT

*&---------------------------------------------------------------------*
*&      Form  F_DYN_TAB_DOWNLOAD
*&---------------------------------------------------------------------*
FORM f_dyn_tab_download .
  DATA : lv_fieldname   TYPE lvc_fname.

  LOOP AT t_abgru.
    CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldname.
    PERFORM f_dyn_download_fieldcatg USING :
      lv_fieldname '15' t_abgru-bezei.

    CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldname.
    PERFORM f_dyn_download_fieldcatg USING :
      lv_fieldname '15' t_abgru-bezei.
  ENDLOOP.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      i_style_table             = 'X'
      it_fieldcatalog           = gt_dyn_dfcat
* Begin remark unicode coversion - DEVK966054
* 18.03.2020 - sol chirka
      i_length_in_byte          = 'X'
* End insert Unicode conversion - DEVK966054
    IMPORTING
      ep_table                  = gt_dyn_dtable
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.

  IF sy-subrc EQ 0.
    ASSIGN gt_dyn_dtable->* TO <fs_download>.
    CREATE DATA gs_dline LIKE LINE OF <fs_download>.
    ASSIGN gs_dline->* TO <fs_dline>.
  ENDIF.
ENDFORM.                    " F_DYN_TAB_DOWNLOAD

*&---------------------------------------------------------------------*
*&      Form  F_DYN_DOWNLOAD_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_dyn_download_fieldcatg  USING    value(fu_fname)
                                        value(fu_outln)
                                        value(fu_fltxt).

  DATA lw_dyn_fcat  TYPE  lvc_s_fcat.

  CLEAR: lw_dyn_fcat.
  lw_dyn_fcat-fieldname         = fu_fname.
  lw_dyn_fcat-outputlen         = fu_outln.
  lw_dyn_fcat-coltext           = fu_fltxt.
  APPEND lw_dyn_fcat TO gt_dyn_dfcat.
  CLEAR lw_dyn_fcat.
ENDFORM.                    " F_DYN_DOWNLOAD_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA_RADIO7
*&---------------------------------------------------------------------*
FORM f_proses_data_radio7 .
  DATA : lt_detquot1  LIKE i_detquot OCCURS 0 WITH HEADER LINE.

  DATA : lv_abgru     TYPE vbap-abgru,
         lv_leadt     TYPE i,
         lv_fieldnm(20).

  DATA : ls_subttl    TYPE ty_subttl.

  DATA : ls_sort      TYPE ty_sort.

  DATA : ls_line 	    TYPE REF TO data,
         ls_knvv      LIKE LINE OF i_knvv.

  DATA : lv_kwmeng    TYPE vbap-kwmeng,
         lv_kzwi1     TYPE vbap-kzwi1.

  SORT i_detquot BY vkbur knkli princ matkl matnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.

  lt_detquot1[] = i_detquot[].
  SORT lt_detquot1 BY vkbur princ matkl matnr.
  DELETE ADJACENT DUPLICATES FROM lt_detquot1
  COMPARING vkbur princ matkl matnr.

  CREATE DATA ls_line LIKE LINE OF <fs_output>.
  ASSIGN ls_line->* TO <fs_subttl1>.

  CLEAR ls_subttl.
  LOOP AT i_detquot.
    lv_abgru  = i_detquot-abgru.

    PERFORM f_hidden_column USING ls_sort '' 'IDR'.

    ADD i_detquot-kwmeng TO ls_subttl-poqty.
    ADD i_detquot-kzwi1 TO ls_subttl-poval.

    CLEAR ls_knvv.
    READ TABLE i_knvv INTO ls_knvv WITH KEY kunnr = i_detquot-knkli.

    PERFORM f_po_column USING i_detquot-vkbur ls_knvv-vkbur
                              i_detquot-vbeln i_detquot-bstdk
                              i_detquot-matnr i_detquot-maktx
                              ls_subttl-poqty ls_subttl-poval
                              i_detquot-knkli i_detquot-name1
                              i_detquot-princ i_detquot-matkl
                              ls_knvv-kvgr4.

    CLEAR i_detsales.
    READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                   vgpos = i_detquot-posnr
                          BINARY SEARCH.
    IF sy-subrc <> 0.
      IF i_detquot-erdat >= '20201001' AND
        p_vkorg = '8020'.
        CLEAR i_detsales.
        READ TABLE i_detsales WITH KEY vgbel = i_detquot-vbeln
                                       posnr = i_detquot-posnr.
      ENDIF.
    ENDIF.

    CLEAR i_detdelv.
    READ TABLE i_detdelv WITH KEY vgbel = i_detsales-vbeln
                                  vgpos = i_detsales-posnr
                         BINARY SEARCH.

    CLEAR t_cust.
    READ TABLE t_cust WITH KEY vbeln = i_detdelv-vbeln.

    IF i_detdelv-vbeln IS NOT INITIAL.
      ADD i_detsales-kwmeng TO ls_subttl-doqty.
      ADD i_detsales-kzwi1 TO ls_subttl-doval.

      PERFORM f_do_column USING '' '' '' '' ''
                                ls_subttl-doqty ls_subttl-doval.

      IF t_cust-crdat IS INITIAL.
        ADD i_detsales-kwmeng TO ls_subttl-6q.
        ADD i_detsales-kzwi1 TO ls_subttl-6v.
      ELSE.
        lv_leadt = t_cust-crdat - i_detquot-bstdk.
        IF lv_leadt LE 2.
          ADD i_detsales-kwmeng TO ls_subttl-1q.
          ADD i_detsales-kzwi1 TO ls_subttl-1v.
        ELSEIF lv_leadt GE 3 AND lv_leadt LE 4.
          ADD i_detsales-kwmeng TO ls_subttl-2q.
          ADD i_detsales-kzwi1 TO ls_subttl-2v.
        ELSEIF lv_leadt GE 5.
          ADD i_detsales-kwmeng TO ls_subttl-3q.
          ADD i_detsales-kzwi1 TO ls_subttl-3v.
        ENDIF.
      ENDIF.

      CLEAR : lv_kwmeng, lv_kzwi1.
      lv_kwmeng = i_detquot-kwmeng - i_detsales-kwmeng.
      lv_kzwi1  = i_detquot-kzwi1 - i_detsales-kzwi1.

      PERFORM f_undelivered_calc USING lv_kwmeng lv_kzwi1
                                       ls_subttl-unqty i_detquot-kwmeng
                                       i_detsales-kwmeng
                                       ls_subttl-unval i_detquot-kzwi1
                                       i_detsales-kzwi1
                                CHANGING ls_subttl-unqty ls_subttl-unval.

*      IF lv_kwmeng > 0.
*        ls_subttl-unqty  = ls_subttl-unqty + ( i_detquot-kwmeng - i_detsales-kwmeng ).
*        ls_subttl-unval  = ls_subttl-unval + ( i_detquot-kzwi1 - i_detsales-kzwi1 ).
*      ENDIF.

      IF lv_kwmeng < 0.
        CLEAR : lv_kwmeng, lv_kzwi1.
      ENDIF.
    ELSE.
      IF i_detsales-vbeln IS INITIAL.
        ADD i_detquot-kwmeng TO ls_subttl-unqty.
        ADD i_detquot-kzwi1 TO ls_subttl-unval.
        lv_kwmeng = i_detquot-kwmeng.
        lv_kzwi1  = i_detquot-kzwi1.
      ELSE.
        IF lv_abgru IS NOT INITIAL.
          ADD i_detquot-kwmeng TO ls_subttl-unqty.
          ADD i_detquot-kzwi1 TO ls_subttl-unval.
          lv_kwmeng = i_detquot-kwmeng.
          lv_kzwi1  = i_detquot-kzwi1.
        ENDIF.
      ENDIF.
    ENDIF.

    IF p_val = 'X'.
      PERFORM f_value_column USING 'IDR' ls_subttl-1v ls_subttl-2v
                                   ls_subttl-3v ls_subttl-unval ''.
    ELSE.
      PERFORM f_quantity_column USING '0' ls_subttl-1q ls_subttl-2q
                                      ls_subttl-3q ls_subttl-unqty.
    ENDIF.

    IF lv_abgru IS INITIAL.
      lv_abgru = '99'.
    ENDIF.

    LOOP AT t_abgru.
      IF p_val = 'X'.
        CONCATENATE 'VAL' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        IF lv_abgru = t_abgru-abgru.
          IF lv_kzwi1 IS NOT INITIAL.
            ADD lv_kzwi1 TO <fs>.
            ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl1> TO <fs_st1>.
            <fs_st1> = <fs>.
          ENDIF.
        ENDIF.
      ELSE.
        CONCATENATE 'QTY' t_abgru-abgru INTO lv_fieldnm.
        ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_line> TO <fs>.
        IF lv_abgru = t_abgru-abgru.
          IF lv_kwmeng IS NOT INITIAL.
            ADD lv_kwmeng TO <fs>.
            ASSIGN COMPONENT lv_fieldnm OF STRUCTURE <fs_subttl1> TO <fs_st1>.
            <fs_st1> = <fs>.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
    APPEND <fs_line> TO <fs_output>.
    CLEAR <fs_line>.
    CLEAR : lv_abgru, ls_subttl, lv_kwmeng, lv_kzwi1.
  ENDLOOP.
ENDFORM.                    " F_PROSES_DATA_RADIO7

*&---------------------------------------------------------------------*
*&      Form  F_UNDELIVERED_CALC
*&---------------------------------------------------------------------*
FORM f_undelivered_calc  USING    fu_kwmeng fu_kzwi1
                                  fu_unqty fuq_kwmeng fus_kwmeng
                                  fu_unval fuq_kzwi1 fus_kzwi1
                         CHANGING fc_unqty fc_unval.

  IF fu_kwmeng > 0.
    fc_unqty  = fu_unqty + ( fuq_kwmeng - fus_kwmeng ).
    fc_unval  = fu_unval + ( fuq_kzwi1 - fus_kzwi1 ).
  ELSEIF fu_kzwi1 > 0.
    fc_unval  = fu_unval + ( fuq_kzwi1 - fus_kzwi1 ).
  ENDIF.
ENDFORM.                    " F_UNDELIVERED_CALC
