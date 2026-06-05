*----------------------------------------------------------------------*
***INCLUDE ZGHFI_E001_F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .

  CASE 'X'.
    WHEN p_rad1.
      PERFORM f_modify_screen USING : 'ER' '0' '' '' '',
                                      'BTM' '0' '' '' '',
                                      'FI' '0' '' '' ''.
    WHEN p_rad2.
      PERFORM f_modify_screen USING : 'PTT' '0' '' '' '',
                                      'TX' '0' '' '' '',
                                      'BTM' '0' '' '' '',
                                      'FI' '0' '' '' ''.
    WHEN p_rad4.
      PERFORM f_modify_screen USING : 'PTT' '0' '' '' '',
                                      'TX' '0' '' '' '',
                                      'ER' '0' '' '' '',
                                      'FX' '0' '' '' '',
                                      'FI' '0' '' '' '',
                                      'BTM' '1' '' '' '1'.
    WHEN p_rad5.
      PERFORM f_modify_screen USING : 'ER' '0' '' '' '',
                                      'TX' '0' '' '' '',
                                      'BTM' '0' '' '' '',
                                      'FI' '0' '' '' ''.
    WHEN p_rad3.
      PERFORM f_modify_screen USING : 'PTT' '0' '' '' '',
                                      'TX' '0' '' '' '',
                                      'ER' '0' '' '' '',
                                      'FX' '0' '' '' '',
                                      'BTM' '0' '' '' '',
                                      'DLV' '0' '' '' '',
                                      'FI' '1' '' '' '1'.

  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000


*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_required.
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

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN



************************************************************************
*           FILL_XML_TABLE                                             *
************************************************************************
FORM fill_xml_table.
  IF out_string IS NOT INITIAL.
    gs_zcoretax0003-namafile = gv_namafile.
    gs_zcoretax0003-nourut = gs_zcoretax0003-nourut + 1.
    gs_zcoretax0003-value = out_string.
    APPEND gs_zcoretax0003 TO gt_zcoretax0003.
    CONCATENATE g_string  out_string INTO g_string.
    CLEAR out_string.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_data .
  CLEAR: gt_zcoretax0001[], gt_zcoretax0002[].
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zcoretax0001 FROM zcoretax0001 WHERE status NE 'D'.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zcoretax0002 FROM zcoretax0002.
  IF gt_zcoretax0002[] IS INITIAL OR gt_zcoretax0001[] IS INITIAL.
    gv_error = 'E'.
    gv_message = 'Table zcoretax0001 dan zcoretax0002 belum di maintance '.
    MESSAGE e000(zab) WITH gv_message.
    LEAVE PROGRAM.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_XML
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_xml .
  DATA: lt_zcoretax0001 TYPE STANDARD TABLE OF zcoretax0001.
  DATA: ls_zcoretax0001 TYPE zcoretax0001.
  SORT gt_zcoretax0001 BY noparent nochild.
  lt_zcoretax0001[] = gt_zcoretax0001[].
  DELETE ADJACENT DUPLICATES FROM lt_zcoretax0001 COMPARING noparent.
  CLEAR: gv_ctr.
  LOOP AT lt_zcoretax0001 INTO ls_zcoretax0001.
    IF ls_zcoretax0001-parent = 'GoodService'.
      IF gv_line > 1.
        "        gv_line = gv_line - 1.
        DO gv_line TIMES.
          IF ls_zcoretax0001-status = 'E'.
            EXIT.
          ENDIF.
          ADD 1 TO gv_ctr.
          PERFORM prepare_nodes USING ls_zcoretax0001 'P' CHANGING  out_string.
          PERFORM fill_xml_table.
          SORT gt_zcoretax0001 BY noparent nochild.
          LOOP AT gt_zcoretax0001 INTO gs_zcoretax0001 WHERE parent = ls_zcoretax0001-parent.
            IF ls_zcoretax0001-status NE 'E'.
              PERFORM prepare_nodes USING gs_zcoretax0001 'C' CHANGING  out_string.
              PERFORM fill_xml_table.
            ENDIF.
          ENDLOOP.
          ls_zcoretax0001-status = 'E'.
          PERFORM prepare_nodes USING ls_zcoretax0001 'P' CHANGING  out_string.
          PERFORM fill_xml_table.
          CLEAR: ls_zcoretax0001-status.
        ENDDO.
      ELSE.
        gv_ctr = 1.
        PERFORM prepare_nodes USING ls_zcoretax0001 'P' CHANGING  out_string.
        PERFORM fill_xml_table.
        LOOP AT gt_zcoretax0001 INTO gs_zcoretax0001 WHERE parent = ls_zcoretax0001-parent.
          IF ls_zcoretax0001-status NE 'E'.
            PERFORM prepare_nodes USING gs_zcoretax0001 'C' CHANGING  out_string.
            PERFORM fill_xml_table.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ELSE.
      PERFORM prepare_nodes USING ls_zcoretax0001 'P' CHANGING  out_string.
      PERFORM fill_xml_table.
      LOOP AT gt_zcoretax0001 INTO gs_zcoretax0001 WHERE parent = ls_zcoretax0001-parent.
        IF ls_zcoretax0001-status NE 'E'.
          PERFORM prepare_nodes USING gs_zcoretax0001 'C' CHANGING  out_string.
          PERFORM fill_xml_table.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.


ENDFORM.

************************************************************************
*           TRANSFER_XML_TABLE                                         *
************************************************************************
FORM transfer_xml_table.
  "  DATA: iv_lines TYPE i.
  IF g_string IS NOT INITIAL.
    APPEND g_string TO g_string_table.
    CLEAR g_string.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PREPARE_NODES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ZCORETAX0001_PARENT  text
*      -->P_OUT_STRING  text
*----------------------------------------------------------------------*
FORM prepare_nodes  USING    p_parent p_type
                    CHANGING  p_string.
  DATA: ls_zcoretax0001 TYPE zcoretax0001.
  DATA: lv_nodes TYPE zcoretax0002-name.
  ls_zcoretax0001 = p_parent.
  IF p_type = 'P'.
    lv_nodes = ls_zcoretax0001-parent.
    IF ls_zcoretax0001-status = 'E'.
      CONCATENATE '</' lv_nodes '>'   INTO p_string.
      RETURN.
    ENDIF.
    IF ls_zcoretax0001-status = 'A' AND lv_nodes NE 'ListOfTaxInvoice'.
      CONCATENATE '<' lv_nodes '>'   INTO p_string.
      RETURN.
    ENDIF.
  ELSE.
    lv_nodes = ls_zcoretax0001-child.
    IF ls_zcoretax0001-status = 'A'.
      CLEAR: p_string.
      RETURN.
    ENDIF.
  ENDIF.
  IF lv_nodes EQ 'ListOfTaxInvoice'.
    RETURN.
  ENDIF.
  SORT gt_zcoretax0002 BY name.
  IF ls_zcoretax0001-parent = 'GoodService' AND p_type = 'C'.
    READ TABLE gt_zcoretax0002 INTO gs_zcoretax0002 WITH KEY name = lv_nodes status = gv_ctr.
  ELSE.
    READ TABLE gt_zcoretax0002 INTO gs_zcoretax0002 WITH KEY name = lv_nodes.
  ENDIF.
  IF sy-subrc EQ 0.
    IF gs_zcoretax0002-kind = 'HEADER'.
      CLEAR: p_string.
    ELSEIF gs_zcoretax0002-kind = 'HEAD1'.
      CLEAR: p_string.
    ELSEIF gs_zcoretax0002-kind = 'HEAD2'.
      CLEAR: p_string.
    ELSEIF gs_zcoretax0002-kind = 'HARDCODE'.
      CONCATENATE '<' gs_zcoretax0002-name '>'  gs_zcoretax0002-value '</' gs_zcoretax0002-name '>' INTO p_string.
    ELSEIF gs_zcoretax0002-kind = 'FORMULA'.
      CONCATENATE '<' gs_zcoretax0002-name '>'  gs_zcoretax0002-value '</' gs_zcoretax0002-name '>' INTO p_string.
    ELSEIF gs_zcoretax0002-kind = 'ARRAY'.
      CONCATENATE '<' gs_zcoretax0002-name '>'   INTO p_string.
    ELSE.
      IF gs_zcoretax0002-value IS NOT INITIAL.
        CONCATENATE '<' gs_zcoretax0002-name '>'  gs_zcoretax0002-value '</' gs_zcoretax0002-name '>' INTO p_string.
      ELSE.
        CONCATENATE '<' gs_zcoretax0002-name '/>'   INTO p_string.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_TABLE_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_table_itab .
  DATA: lv_ctr TYPE i.
  DATA: lv_tabname TYPE tabname.
  DATA: lt_zcoretax0001 TYPE STANDARD TABLE OF zcoretax0001.
  DATA: ls_zcoretax0001 TYPE zcoretax0001.
  lt_zcoretax0001[] = gt_zcoretax0001[].
  DELETE lt_zcoretax0001[] WHERE status NE 'A'.
  CLEAR: lv_ctr.
  SORT lt_zcoretax0001 BY noparent.
  LOOP AT lt_zcoretax0001 INTO ls_zcoretax0001.
    CLEAR: gt_lvc_fieldcat[], wa_lvc_fieldcat.
    ADD 1 TO lv_ctr.
    LOOP AT gt_zcoretax0001 INTO gs_zcoretax0001 WHERE parent = ls_zcoretax0001-child.
      IF gs_zcoretax0001-child IS NOT INITIAL.
        wa_lvc_fieldcat-fieldname = gs_zcoretax0001-child.
        wa_lvc_fieldcat-datatype = 'CHAR'.
        wa_lvc_fieldcat-intlen = 40.
        APPEND wa_lvc_fieldcat TO gt_lvc_fieldcat.
      ENDIF.
    ENDLOOP.
    IF gt_lvc_fieldcat[] IS NOT INITIAL.
      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_lvc_fieldcat
          i_length_in_byte          = 'X'
        IMPORTING
          ep_table                  = gt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc EQ 0.
        CASE lv_ctr.
          WHEN 1.
            ASSIGN gt_dyn_table->* TO <fs_tab1>.
            CREATE DATA gs_line LIKE LINE OF <fs_tab1>.
            ASSIGN gs_line->* TO <fs_line1>.
          WHEN 2.
            ASSIGN gt_dyn_table->* TO <fs_tab2>.
            CREATE DATA gs_line LIKE LINE OF <fs_tab2>.
            ASSIGN gs_line->* TO <fs_line2>.
          WHEN 3.
            ASSIGN gt_dyn_table->* TO <fs_tab3>.
            CREATE DATA gs_line LIKE LINE OF <fs_tab3>.
            ASSIGN gs_line->* TO <fs_line3>.
          WHEN 4.
            ASSIGN gt_dyn_table->* TO <fs_tab4>.
            CREATE DATA gs_line LIKE LINE OF <fs_tab4>.
            ASSIGN gs_line->* TO <fs_line4>.
          WHEN 5.
            ASSIGN gt_dyn_table->* TO <fs_tab5>.
            CREATE DATA gs_line LIKE LINE OF <fs_tab5>.
            ASSIGN gs_line->* TO <fs_line5>.
        ENDCASE.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_data USING ps_itab.
  FIELD-SYMBOLS <fs> TYPE any.
  DATA: ls_header TYPE ty_header_xml.
  DATA: lv_text(200).
  DATA: lv_fieldname(20).
  DATA: lv_price(15), lv_qty(15), lv_diskon(15), lv_netwr(15), lv_taxbase(15).
  DATA: lv_ctr  TYPE i, lv_line TYPE i.
  DATA: lt_zcoretax0002 TYPE STANDARD TABLE OF zcoretax0002.
  DATA: lv_vkbur(4), lv_kunnr(10), lv_bill(10), lv_do(15).
  DATA: lv_value TYPE vbrp-netwr.
  DATA: lv_text1024 TYPE text1024.
  ls_header = ps_itab.

  CLEAR: lv_line.
  LOOP AT gt_detail_xml INTO gs_detail_xml WHERE vbeln =  ls_header-vbeln.
    ADD 1 TO lv_line.
    "    lv_vkbur = gs_vbrk-vkbur.
  ENDLOOP.
  lv_vkbur = ls_header-vkbur.
  lv_kunnr = ls_header-kunrg.
  lv_bill = ls_header-vbeln.
  lv_do = ls_header-zuonr.
  gv_line = lv_line.
  LOOP AT gt_zcoretax0002 INTO gs_zcoretax0002 WHERE nodesparent = 'GoodService'.
    gs_zcoretax0002-status = '1'.
    MODIFY gt_zcoretax0002 FROM gs_zcoretax0002 TRANSPORTING status.
  ENDLOOP.
  IF lv_line > 1.
    lt_zcoretax0002[] = gt_zcoretax0002[].
    DELETE lt_zcoretax0002[] WHERE nodesparent NE 'GoodService'.
    lv_line = lv_line - 1.
    lv_ctr = 1.
    DO  lv_line TIMES.
      ADD 1 TO lv_ctr.
      LOOP AT lt_zcoretax0002 INTO gs_zcoretax0002 WHERE nodesparent = 'GoodService'.
        gs_zcoretax0002-status = lv_ctr.
        APPEND gs_zcoretax0002  TO gt_zcoretax0002.
      ENDLOOP.
    ENDDO.
  ENDIF.

  PERFORM f_filldata USING 'TaxInvoiceDate'      '2' ls_header-taxinvoicedate      lv_ctr. "lv_text lv_ctr.
  PERFORM f_filldata USING 'TaxInvoiceOpt'       '2' ls_header-taxinvoiceopt       lv_ctr. "'Normal' lv_ctr.
  PERFORM f_filldata USING 'TrxCode'             '2' ls_header-trxcode             lv_ctr. "'04' lv_ctr.
  PERFORM f_filldata USING 'AddInfo'             '2' ls_header-addinfo             lv_ctr. "'04' lv_ctr.
  PERFORM f_filldata USING 'CustomDoc'           '2' ls_header-customdoc           lv_ctr. "'04' lv_ctr.
  PERFORM f_filldata USING 'CustomDocMonthYear'  '2' ls_header-customdocmonthyear  lv_ctr. "'04' lv_ctr.

  PERFORM f_filldata USING 'RefDesc'             '2' ls_header-refdesc             lv_ctr. "lv_text lv_ctr .
  PERFORM f_filldata USING 'SellerIDTKU'         '2' ls_header-selleridtku         lv_ctr..
  PERFORM f_filldata USING 'BuyerTin'            '2' ls_header-buyertin            lv_ctr..
  PERFORM f_filldata USING 'BuyerDocument'       '2' ls_header-buyerdocument       lv_ctr. "stceg lv_ctr..
  PERFORM f_filldata USING 'BuyerCountry'        '2' ls_header-buyercountry        lv_ctr.
  PERFORM f_filldata USING 'BuyerDocumentNumber' '2' ls_header-buyerdocumentnumber lv_ctr. "ls_header-stcd1 lv_ctr..
  PERFORM f_filldata USING 'BuyerName'           '2' ls_header-buyername           lv_ctr. "ls_header-name_co lv_ctr..
  PERFORM f_filldata USING 'BuyerAdress'         '2' ls_header-buyeradress         lv_ctr. "lv_text lv_ctr..
  PERFORM f_filldata USING 'BuyerIDTKU'          '2' ls_header-buyeridtku          lv_ctr..

  lv_ctr = 1.
  LOOP AT gt_detail_xml INTO gs_detail_xml WHERE vbeln =  ls_header-vbeln..
    gs_zcoretax0004-nourut = lv_ctr.
    gs_zcoretax0004-price  = gs_detail_xml-vprice / 100.
    gs_zcoretax0004-qty    = gs_detail_xml-vqty.
    gs_zcoretax0004-totaldiskon  = gs_detail_xml-vtotaldiscount / 100.
    gs_zcoretax0004-taxbase      = gs_detail_xml-vtaxbase / 100.
    gs_zcoretax0004-othertaxbase = gs_detail_xml-vothertaxbase / 100.
    gs_zcoretax0004-vat          = gs_detail_xml-vvat / 100.
    gs_zcoretax0004-aenam = sy-uname.
    gs_zcoretax0004-aedat = sy-datum.
    gs_zcoretax0004-aezet = sy-uzeit.
    gs_zcoretax0004-netwr = gs_detail_xml-netwr.
    APPEND gs_zcoretax0004 TO gt_zcoretax0004.
    MODIFY zcoretax0004 FROM gs_zcoretax0004.
    IF gs_detail_xml-opt IS INITIAL.
      gs_detail_xml-opt = 'A'.
    ENDIF.
    IF p_rad3 = 'X'.
      IF p_jasa = 'X'.
        gs_detail_xml-opt = 'B'.
        gs_detail_xml-unit = 'UM.0033'.
      ENDIF.
    ENDIF.
    PERFORM f_filldata USING  'Opt'           '4' gs_detail_xml-opt           lv_ctr..
    PERFORM f_filldata USING  'Code'          '4' '000000'                    lv_ctr..
    PERFORM f_filldata USING  'Name'          '4' gs_detail_xml-name          lv_ctr..
    PERFORM f_filldata USING  'Unit'          '4' gs_detail_xml-unit          lv_ctr. "'UM.0018' lv_ctr. "'UM.0018' lv_ctr..gs_vbrk-meins
    PERFORM f_filldata USING  'Price'         '4' gs_detail_xml-price         lv_ctr. "lv_price lv_ctr..
    PERFORM f_filldata USING  'Qty'           '4' gs_detail_xml-qty           lv_ctr. "lv_qty lv_ctr.
    PERFORM f_filldata USING  'TotalDiscount' '4' gs_detail_xml-totaldiscount lv_ctr. "lv_diskon lv_ctr.
    PERFORM f_filldata USING  'TaxBase'       '4' gs_detail_xml-taxbase       lv_ctr. "lv_netwr lv_ctr..
    PERFORM f_filldata USING  'OtherTaxBase'  '4' gs_detail_xml-othertaxbase  lv_ctr. "lv_taxbase lv_ctr..
    PERFORM f_filldata USING  'VATRate'       '4' gs_detail_xml-vatrate       lv_ctr. " '12' lv_ctr..
    PERFORM f_filldata USING  'VAT'           '4' gs_detail_xml-vat           lv_ctr. "lv_taxbase lv_ctr.
    PERFORM f_filldata USING  'STLGRate'      '4' '0'                   lv_ctr.
    PERFORM f_filldata USING  'STLG'          '4' '0'                   lv_ctr.

    "    APPEND <fs_line4> TO <fs_tab4>.
    ADD 1 TO lv_ctr.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_FILLDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0769   text
*      -->P_0770   text
*----------------------------------------------------------------------*
FORM f_filldata  USING    p_fieldname
                          p_urut
                          p_value
                          p_ctr.
  FIELD-SYMBOLS <fs>.
  FIELD-SYMBOLS <fs1> TYPE any.
  DATA: lv_fieldname(50).
  lv_fieldname = p_fieldname.

  "  ASSIGN gt_zcoretax0002->* TO <fs1>.

  SORT gt_zcoretax0002 BY name.
  IF p_urut = '4'.
    READ TABLE gt_zcoretax0002 ASSIGNING <fs1> WITH KEY name = lv_fieldname
                                                       status = p_ctr.
  ELSE.
    READ TABLE gt_zcoretax0002 ASSIGNING <fs1> WITH KEY name = lv_fieldname.
  ENDIF.
  IF sy-subrc EQ 0.
    CASE p_urut.
      WHEN '2'.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_line2> TO <fs>.
      WHEN '4'.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_line4> TO <fs>.
    ENDCASE.
    <fs> = p_value.
    ASSIGN COMPONENT 'VALUE' OF STRUCTURE <fs1> TO <fs>.
    <fs> = p_value.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data .
  "  DATA: lr_zcoretax0007 TYPE STANDARD TABLE OF zcoretax0007.
  DATA: BEGIN OF lt_bschl OCCURS 0,
          chkont(20),
          lr_zcoretax0007 TYPE STANDARD TABLE OF zcoretax0007,
          hkont           TYPE bseg-hkont,
          bschl           TYPE bseg-bschl,
        END OF lt_bschl.
  DATA: lt_lips TYPE STANDARD TABLE OF ty_lips.
  DATA: lt_detail_nontrade TYPE STANDARD TABLE OF ty_detail_nontrade.

  DATA: lt_header_zb7 TYPE STANDARD TABLE OF ty_header.
  DATA: lt_header_01 TYPE STANDARD TABLE OF ty_header.
  DATA: ls_header TYPE ty_header.
  DATA: lt_zmm_cust_rec TYPE STANDARD TABLE OF zmm_cust_rec WITH HEADER LINE.
  DATA: lt_likp TYPE STANDARD TABLE OF likp WITH HEADER LINE.
  DATA: BEGIN OF lt_header_knvv OCCURS 0,
          bukrs TYPE vbrk-bukrs,
          vbeln TYPE vbrk-vbeln,
          fkart TYPE vbrk-fkart,
          vkbur TYPE knvv-vkbur,
        END OF lt_header_knvv.
  DATA: ls_zcoretax0010 TYPE zcoretax0010.

  RANGES: lr_hkont FOR bseg-hkont.
  RANGES: lr1_hkont FOR bseg-hkont.
  RANGES: lr2_hkont FOR bseg-hkont. " khusus no trade split
  RANGES: lr_kunnr FOR kna1-kunnr.

  DATA : lr_shkzg TYPE RANGE OF shkzg,
         ls_shkzg LIKE LINE OF lr_shkzg,
         lr_fkart TYPE RANGE OF fkart,
         ls_fkart LIKE LINE OF lr_fkart.

  SELECT SINGLE * INTO gs_zgdtxdt0005 FROM zgdtxdt0005 WHERE bukrs = p_bukrs AND brnch = p_bukrs.
  IF sy-subrc NE 0 OR gs_zgdtxdt0005-nitku IS INITIAL.
    gv_error = 'E'.
    gv_message = 'Mohon cek Table ZGDTXDT0005 - NITKU'.
    MESSAGE e000(zab) WITH gv_message.
  ENDIF.
  CLEAR: gt_8220h[], gt_header[], gt_vttk[].

  CASE 'X'.
    WHEN p_rad1 OR p_rad5.
      IF p_bukrs EQ '8020' OR p_bukrs EQ '8070' .
        CLEAR: gt_header[].
        SELECT bukrs  fkdat kunrg  a~vbeln fkart zuonr a~netwr
               c~cityc  stcd1   stcd3   stcd5   stcd6    c~stceg    name_co
               str_suppl1 str_suppl2 str_suppl3 location   b~vkbur vgbel  vbtyp c~gform vattrn b~werks
               knumv fksto
           INTO CORRESPONDING FIELDS OF TABLE gt_header
          FROM vbrk AS a JOIN vbrp AS b ON a~vbeln = b~vbeln
                         JOIN kna1 AS c ON a~kunrg = c~kunnr
                         JOIN adrc AS d ON d~addrnumber = c~adrnr
                         JOIN zfvattrn AS e ON e~vkorg = a~vkorg AND
                                               e~vkbur = b~vkbur AND
                                               e~gform = c~gform
"                         JOIN zmm_cust_rec AS f ON f~vbeln = b~vgbel
          WHERE a~vbeln IN s_vbeln AND
                fkdat IN s_fkdat AND
                bukrs = p_bukrs AND
                b~vkbur IN s_vkbur
               AND ( vbtyp = 'M'  OR vbtyp = 'O' OR  vbtyp = '5' OR vbtyp = '6' OR vbtyp = 'P' )
"               AND ( fkart NE 'ZIV' AND fkart NE 'ZI02' )
               AND kunrg IN s_kunrg
               AND vgbel IN s_vgbel
               AND fkdat IN s_fkdat
               "AND txdat IN s_txdat
               AND fksto NE 'X'.
**        SELECT bukrs  fkdat kunrg  a~vbeln fkart zuonr a~netwr
**               c~cityc  stcd1   stcd3   stcd5   stcd6    c~stceg    name_co
**               str_suppl1 str_suppl2 str_suppl3 location   b~vkbur vgbel  vbtyp c~gform vattrn b~werks
**           APPENDING CORRESPONDING FIELDS OF TABLE gt_header
**          FROM vbrk AS a JOIN vbrp AS b ON a~vbeln = b~vbeln
**                         JOIN kna1 AS c ON a~kunrg = c~kunnr
**                         JOIN adrc AS d ON d~addrnumber = c~adrnr
**
**                         JOIN zfvattrn AS e ON e~vkorg = a~vkorg AND
**                                               e~vkbur = b~vkbur AND
**                                               e~gform = c~gform
**                         "JOIN zmm_cust_rec AS f ON f~vbeln = b~vgbel
**          WHERE a~vbeln IN s_vbeln AND
**                fkdat IN s_fkdat AND
**                bukrs = p_bukrs AND
**                b~vkbur IN s_vkbur
**               AND ( vbtyp = 'M'  OR vbtyp = 'O' OR  vbtyp = '5' OR vbtyp = '6' OR vbtyp = 'P' )
**               AND ( fkart EQ 'ZIV' OR fkart EQ 'ZI02' )
**               AND kunrg IN s_kunrg
**               AND vgbel IN s_vgbel
**               AND fkdat IN s_fkdat
**               AND fksto NE 'X'.
        "AND txdat IN s_txdat.
        SORT gt_header BY bukrs vkbur fkdat  kunrg vbeln zuonr vgbel netwr.
        DELETE ADJACENT DUPLICATES FROM gt_header COMPARING bukrs vkbur fkdat  kunrg vbeln zuonr vgbel.
        IF gt_header[] IS NOT INITIAL.
          lt_header_zb7[] = gt_header[].
          DELETE lt_header_zb7[] WHERE fkart(3) NE 'ZB7'.
          IF lt_header_zb7[] IS NOT INITIAL.
            FIELD-SYMBOLS: <fs1> TYPE any, <fs> TYPE any.
            SELECT bukrs  vbeln fkart vkbur
               INTO CORRESPONDING FIELDS OF TABLE lt_header_knvv
              FROM vbrk AS a JOIN knvv AS b ON a~kunrg = b~kunnr
                                           AND a~bukrs = b~vkorg
               FOR ALL ENTRIES IN lt_header_zb7
                  WHERE vbeln = lt_header_zb7-vbeln
                    AND bukrs = lt_header_zb7-bukrs
                    AND fkart = lt_header_zb7-fkart.
            IF lt_header_knvv[] IS NOT INITIAL.
              SORT lt_header_knvv BY bukrs vbeln fkart.
              LOOP AT lt_header_knvv.
                SORT gt_header BY bukrs vbeln fkart.
                READ TABLE gt_header ASSIGNING <fs>
                      WITH KEY bukrs = lt_header_knvv-bukrs
                               vbeln = lt_header_knvv-vbeln
                               fkart = lt_header_knvv-fkart
                      BINARY SEARCH.
                IF sy-subrc EQ 0.
                  ASSIGN COMPONENT 'VKBUR' OF STRUCTURE <fs> TO <fs1>.
                  <fs1> =  lt_header_knvv-vkbur.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
        IF gt_header[] IS NOT INITIAL AND p_val = 'X'.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zcoretax0005_done FROM zcoretax0005
            FOR ALL ENTRIES IN gt_header
            WHERE bukrs = p_bukrs
              AND belnr = gt_header-vbeln.
          IF gt_zcoretax0005_done[] IS NOT INITIAL.
            LOOP AT gt_zcoretax0005_done INTO gs_zcoretax0005.
              DELETE gt_header[] WHERE vbeln = gs_zcoretax0005-belnr.
            ENDLOOP.
          ENDIF.
        ENDIF.
        lt_header_01[] = gt_header[].
        SORT lt_header_01 BY vgbel.
        DELETE lt_header_01[] WHERE vgbel IS INITIAL.
        DELETE ADJACENT DUPLICATES FROM lt_header_01 COMPARING vgbel.
        IF lt_header_01[] IS NOT INITIAL.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zmm_cust_rec FROM zmm_cust_rec
            FOR ALL ENTRIES IN lt_header_01
            WHERE vbeln = lt_header_01-vgbel.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_likp FROM likp
            FOR ALL ENTRIES IN lt_header_01
            WHERE vbeln = lt_header_01-vgbel.
          SORT gt_header BY bukrs vbeln vgbel.
          LOOP AT gt_header INTO ls_header.
            SORT lt_zmm_cust_rec BY vbeln.
            READ TABLE lt_zmm_cust_rec WITH KEY vbeln = ls_header-vgbel
            BINARY SEARCH.
            IF sy-subrc EQ 0.
              ls_header-txdat = lt_zmm_cust_rec-txdat.
            ELSE.
              SORT lt_likp BY vbeln.
              READ TABLE lt_likp WITH KEY vbeln = ls_header-vgbel
              BINARY SEARCH.
              IF sy-subrc EQ 0.
                ls_header-txdat = lt_likp-wadat_ist.
              ENDIF.
            ENDIF.
            MODIFY gt_header FROM ls_header TRANSPORTING txdat.
          ENDLOOP.
        ENDIF.
      ELSEIF p_bukrs EQ '8800' .
        CLEAR: gt_header[].
        SELECT bukrs  fkdat kunrg  a~vbeln fkart zuonr a~netwr
               c~cityc  stcd1   stcd3   stcd5   stcd6    c~stceg    name_co
               str_suppl1 str_suppl2 str_suppl3 location   b~vkbur vgbel vbtyp c~gform vattrn b~werks
               knumv fksto
           INTO CORRESPONDING FIELDS OF TABLE gt_header
          FROM vbrk AS a JOIN vbrp AS b ON a~vbeln = b~vbeln
                         JOIN kna1 AS c ON a~kunrg = c~kunnr
                         JOIN adrc AS d ON d~addrnumber = c~adrnr
                     "    JOIN zmm_cust_rec AS f ON f~vbeln = b~vgbel
                         JOIN zfvattrn AS e ON e~vkorg = a~vkorg AND
                                               "e~vkbur = b~vkbur AND
                                               e~gform = c~gform
          WHERE a~vbeln IN s_vbeln AND
                fkdat IN s_fkdat AND
                bukrs = p_bukrs AND
                b~vkbur IN s_vkbur
               AND ( vbtyp = 'M'  OR vbtyp = 'O' OR  vbtyp = '5' OR vbtyp = '6' OR vbtyp = 'P')
               AND kunrg IN s_kunrg
               AND vgbel IN s_vgbel
               AND fkdat IN s_fkdat
               AND fksto NE 'X'.
        SORT gt_header BY bukrs vkbur fkdat  kunrg vbeln netwr.
        DELETE ADJACENT DUPLICATES FROM gt_header COMPARING bukrs vkbur fkdat  kunrg vbeln.
        IF gt_header[] IS NOT INITIAL AND p_val = 'X'..
          SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zcoretax0005_done FROM zcoretax0005
            FOR ALL ENTRIES IN gt_header
            WHERE bukrs = p_bukrs
              AND belnr = gt_header-vbeln.
          IF gt_zcoretax0005_done[] IS NOT INITIAL.
            LOOP AT gt_zcoretax0005_done INTO gs_zcoretax0005.
              DELETE gt_header[] WHERE vbeln = gs_zcoretax0005-belnr.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ELSE.
        ls_fkart-low    = 'ZR03'.
        ls_fkart-sign   = 'E'.
        ls_fkart-option = 'EQ'.
        APPEND ls_fkart TO lr_fkart.
        ls_fkart-low    = 'ZR04'.
        APPEND ls_fkart TO lr_fkart.
        ls_fkart-low    = 'ZR06'.
        APPEND ls_fkart TO lr_fkart.

        CLEAR: gt_header[].
        SELECT bukrs  fkdat kunrg  a~vbeln fkart zuonr a~netwr
               c~cityc  stcd1   stcd3   stcd5   stcd6    c~stceg    name_co
               str_suppl1 str_suppl2 str_suppl3 location   b~vkbur vgbel  vbtyp c~gform vattrn b~werks
               knumv fksto
           INTO CORRESPONDING FIELDS OF TABLE gt_header
          FROM vbrk AS a JOIN vbrp AS b ON a~vbeln = b~vbeln
                         JOIN kna1 AS c ON a~kunrg = c~kunnr
                         JOIN adrc AS d ON d~addrnumber = c~adrnr
                         JOIN zfvattrn AS e ON e~vkorg = a~vkorg AND
                                              " e~vkbur = b~vkbur AND
                                               e~gform = c~gform
          WHERE a~vbeln IN s_vbeln AND
                fkdat IN s_fkdat AND
                bukrs = p_bukrs AND
                b~vkbur IN s_vkbur
               AND ( vbtyp = 'M'  OR vbtyp = 'O' OR  vbtyp = '5' OR vbtyp = '6' OR vbtyp = 'P')
               AND kunrg IN s_kunrg
               AND fkart IN lr_fkart
               AND fksto = space.

        SORT gt_header BY bukrs vkbur fkdat  kunrg vbeln netwr.
        DELETE ADJACENT DUPLICATES FROM gt_header COMPARING bukrs vkbur fkdat  kunrg vbeln.
        IF gt_header[] IS NOT INITIAL AND p_val = 'X'..
          SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zcoretax0005_done FROM zcoretax0005
            FOR ALL ENTRIES IN gt_header
            WHERE bukrs = p_bukrs
              AND belnr = gt_header-vbeln.
          IF gt_zcoretax0005_done[] IS NOT INITIAL.
            LOOP AT gt_zcoretax0005_done INTO gs_zcoretax0005.
              DELETE gt_header[] WHERE vbeln = gs_zcoretax0005-belnr.
            ENDLOOP.
          ENDIF.
        ENDIF.
        IF gt_header[] IS NOT INITIAL.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_bseg
            FROM bseg
            FOR ALL ENTRIES IN gt_header
            WHERE bukrs = p_bukrs AND
                  belnr = gt_header-vbeln AND
                  gjahr = gt_header-fkdat(4) AND
                  hkont IN r_hkont.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_bseg1
            FROM bseg
            FOR ALL ENTRIES IN gt_header
            WHERE bukrs = p_bukrs AND
                  belnr = gt_header-vbeln AND
                  gjahr = gt_header-fkdat(4) AND
                  hkont = '0611110000'.
        ENDIF.
      ENDIF.
      IF gt_header[] IS NOT INITIAL.
        CLEAR: gt_vbrk[].
        SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vbrk
          FROM vbrp AS b JOIN makt AS e ON e~matnr = b~matnr
                                       AND e~spras = 'E'
          FOR ALL ENTRIES IN gt_header
          WHERE vbeln = gt_header-vbeln
            AND vkbur IN s_vkbur.
        "group by vkbur vbeln matnr maktx meins.
      ENDIF.
    WHEN p_rad2.
      IF p_bukrs = '8220' .
        CLEAR: gt_8220h[], gt_header[].
        SELECT bukrs bbill bidat zzkdctr zzkunn2 d~name1
             b~cityc  stcd1   stcd3   stcd5   stcd6    b~stceg
            street str_suppl1 str_suppl2 str_suppl3 city1  b~gform vattrn
          INTO CORRESPONDING FIELDS OF TABLE gt_8220h
          FROM zdg2fidt0008 AS a JOIN kna1 AS b ON a~zzkunn2 = b~kunnr
                                JOIN adrc AS d ON d~addrnumber = b~adrnr
                       JOIN zfvattrn AS e ON e~vkorg = p_bukrs AND
                                             e~gform = 'A1'
          WHERE bukrs = p_bukrs AND
                bidat IN s_fkdat AND
                bbill IN s_bbill AND
                zzkdctr IN s_kdctr.
      ELSE.
        SELECT bukrs bbill bidat zzkdctr zzkunn2 d~name1
             b~cityc  stcd1   stcd3   stcd5   stcd6    b~stceg
            street str_suppl1 str_suppl2 str_suppl3 city1  b~gform vattrn
          INTO CORRESPONDING FIELDS OF TABLE gt_8220h
          FROM zdg3fidt0008 AS a JOIN kna1 AS b ON a~zzkunn2 = b~kunnr
                                JOIN adrc AS d ON d~addrnumber = b~adrnr
                       JOIN zfvattrn AS e ON e~vkorg = p_bukrs AND
                                             e~gform = 'A1'
          WHERE bukrs = p_bukrs AND
                bidat IN s_fkdat AND
                bbill IN s_bbill AND
                zzkdctr IN s_kdctr.
      ENDIF.
      IF gt_8220h[] IS NOT INITIAL.
        IF p_bukrs = '8220'.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_8220d
           FROM zdg2fidt0009
           FOR ALL ENTRIES IN  gt_8220h
            WHERE bukrs = gt_8220h-bukrs AND
                  bbill = gt_8220h-bbill AND
                  bidat = gt_8220h-bidat.
        ELSE.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_8220d
           FROM zdg3fidt0009
           FOR ALL ENTRIES IN  gt_8220h
            WHERE bukrs = gt_8220h-bukrs AND
                  bbill = gt_8220h-bbill AND
                  bidat = gt_8220h-bidat.
        ENDIF.
      ENDIF.
    WHEN p_rad3.
      "      DATA: gt_bkpf TYPE STANDARD TABLE OF bkpf.
      CLEAR: lr1_hkont[].
      CLEAR: lr2_hkont[], lr2_hkont.
      CLEAR: lr_shkzg.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zcoretax0010 FROM zcoretax0010 WHERE coretype = 'NT' AND bukrs = p_bukrs.
      IF gt_zcoretax0010[] IS NOT INITIAL.
        lr2_hkont-sign = 'I'.
        lr2_hkont-option = 'EQ'.
        LOOP AT gt_zcoretax0010 INTO ls_zcoretax0010.
          lr2_hkont-low = ls_zcoretax0010-hkont.
          APPEND lr2_hkont.

          ls_shkzg-low    = ls_zcoretax0010-shkzg.
          ls_shkzg-sign   = 'I'.
          ls_shkzg-option = 'EQ'.
          APPEND ls_shkzg TO lr_shkzg.
          CLEAR ls_shkzg.
        ENDLOOP.
      ENDIF.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zcoretax0007 FROM zcoretax0007 WHERE bukrs = p_bukrs.
      IF gt_zcoretax0007[] IS NOT INITIAL.
        LOOP AT gt_zcoretax0007 INTO gs_zcoretax0007.
          lr1_hkont-sign  = gs_zcoretax0007-sign.
          lr1_hkont-option = gs_zcoretax0007-zoption.
          lr1_hkont-low = gs_zcoretax0007-low.
          lr1_hkont-high = gs_zcoretax0007-high.
          APPEND lr1_hkont.
          IF gs_zcoretax0007-bschl IS NOT INITIAL.
            APPEND gs_zcoretax0007 TO lt_bschl-lr_zcoretax0007.
            lt_bschl-chkont = gs_zcoretax0007-low.
            lt_bschl-bschl = gs_zcoretax0007-bschl.
            APPEND lt_bschl.
          ENDIF.
        ENDLOOP.
      ELSE.
      ENDIF.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zgdtxdt0104 FROM zgdtxdt0104 WHERE bukrs = p_bukrs.
      IF gt_zgdtxdt0104[] IS NOT INITIAL.
        lr_hkont-sign = 'I'.
        lr_hkont-option = 'EQ'.
        LOOP AT gt_zgdtxdt0104 INTO gs_zgdtxdt0104.
          lr_hkont-low = gs_zgdtxdt0104-hkont.
          APPEND lr_hkont.
        ENDLOOP.
        DELETE ADJACENT DUPLICATES FROM lr_hkont COMPARING low.
        SELECT a~bukrs a~belnr a~gjahr a~blart a~budat gsber b~kunnr
               c~cityc c~stcd1 c~stcd3 c~stcd5 c~stcd6 c~stceg c~gform
               d~name_co d~str_suppl1 d~str_suppl2 d~str_suppl3 d~location
            INTO CORRESPONDING FIELDS OF TABLE gt_nontrade
          FROM bkpf AS a JOIN bseg AS b ON b~bukrs = a~bukrs
                                       AND b~belnr = a~belnr
                                       AND b~gjahr = a~gjahr
                         JOIN kna1 AS c ON c~kunnr = b~kunnr
                         JOIN adrc AS d ON d~addrnumber = c~adrnr
          FOR ALL ENTRIES IN gt_zgdtxdt0104
          WHERE a~blart = gt_zgdtxdt0104-blart
           AND a~bukrs = p_bukrs
           AND a~budat IN s_budat
          AND b~kunnr NE space
          AND a~belnr IN s_belnr
          AND bstat EQ space
          AND stblg EQ space.

        SELECT a~bukrs a~belnr a~gjahr a~blart a~budat "b~kunnr
"               d~cityc d~stcd1 d~stcd3 d~stcd5 d~stcd6 d~stceg d~gform
               d~name_co d~str_suppl1 d~str_suppl2 d~str_suppl3 d~location
            APPENDING CORRESPONDING FIELDS OF TABLE gt_nontrade
          FROM bkpf AS a JOIN bsec AS b ON b~bukrs = a~bukrs
                                       AND b~belnr = a~belnr
                                       AND b~gjahr = a~gjahr
"                         JOIN kna1 AS c ON c~kunnr = b~kunnr
                         JOIN adrc AS d ON d~addrnumber = b~adrnr
          FOR ALL ENTRIES IN gt_zgdtxdt0104
          WHERE a~blart = gt_zgdtxdt0104-blart
           AND a~bukrs = p_bukrs
           AND a~budat IN s_budat
          "AND b~kunnr NE space
          AND bstat EQ space
          AND stblg EQ space.
        IF gt_nontrade[] IS NOT INITIAL AND p_val = 'X'.
          DATA: lv_masatx(6).
          CONCATENATE p_perio(4) '%' INTO lv_masatx.
          CONDENSE lv_masatx.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zcoretax0005_done FROM zcoretax0005
            FOR ALL ENTRIES IN gt_nontrade
            WHERE bukrs = p_bukrs
              AND belnr = gt_nontrade-belnr.
          "              AND masatx(4) = gt_nontrade-gjahr.
          IF gt_zcoretax0005_done[] IS NOT INITIAL.
            LOOP AT gt_zcoretax0005_done INTO gs_zcoretax0005.
              DELETE gt_nontrade[] WHERE belnr = gs_zcoretax0005-belnr AND gjahr = gs_zcoretax0005-masatx(4).
            ENDLOOP.
          ENDIF.
        ENDIF.
        IF gt_nontrade[] IS NOT INITIAL.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_detail_nontrade1 FROM bseg
            FOR ALL ENTRIES IN gt_nontrade
            WHERE bukrs = gt_nontrade-bukrs
              AND belnr = gt_nontrade-belnr
              AND gjahr = gt_nontrade-gjahr
              AND hkont IN lr_hkont.
          lt_detail_nontrade[] = gt_detail_nontrade1[].
          SORT lt_detail_nontrade BY bukrs belnr gjahr.
          DELETE ADJACENT DUPLICATES FROM lt_detail_nontrade COMPARING bukrs belnr gjahr.
          IF lt_detail_nontrade[] IS NOT INITIAL.
            IF gt_zcoretax0010[] IS NOT INITIAL.
              "***  Ambil data untuk split non trade
              SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_detail_nontrade5 FROM bseg
                FOR ALL ENTRIES IN lt_detail_nontrade
                WHERE bukrs = lt_detail_nontrade-bukrs
                  AND belnr = lt_detail_nontrade-belnr
                  AND gjahr = lt_detail_nontrade-gjahr
                  AND hkont IN lr2_hkont
                  AND shkzg IN lr_shkzg.
            ENDIF.
            " ambil data asset
            SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_detail_nontrade4 FROM bseg
              FOR ALL ENTRIES IN lt_detail_nontrade
              WHERE bukrs = lt_detail_nontrade-bukrs
                AND belnr = lt_detail_nontrade-belnr
                AND gjahr = lt_detail_nontrade-gjahr
                "AND hkont NOT IN lr_hkont
               AND koart = 'A'
               AND bschl = '75'.
            SORT gt_detail_nontrade4 BY bukrs belnr gjahr koart bschl.
            DELETE ADJACENT DUPLICATES FROM gt_detail_nontrade4 COMPARING bukrs belnr gjahr koart bschl.
            " ambil nilai customer
            SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_detail_nontrade FROM bseg
              FOR ALL ENTRIES IN lt_detail_nontrade
              WHERE bukrs = lt_detail_nontrade-bukrs
                AND belnr = lt_detail_nontrade-belnr
                AND gjahr = lt_detail_nontrade-gjahr
                AND hkont NOT IN lr_hkont
               AND koart = 'D'.

            IF gt_zcoretax0007[] IS NOT INITIAL.
              SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_detail_nontrade2 FROM bseg
                FOR ALL ENTRIES IN lt_detail_nontrade
                WHERE bukrs = lt_detail_nontrade-bukrs
                  AND belnr = lt_detail_nontrade-belnr
                  AND gjahr = lt_detail_nontrade-gjahr
                  AND hkont NOT IN lr_hkont
                  AND hkont IN lr1_hkont.
              DATA: ls_zcoretax0007  TYPE  zcoretax0007.
              IF lt_bschl[] IS NOT INITIAL.
                LOOP AT lt_bschl.
                  CLEAR: lr1_hkont[].
                  LOOP AT lt_bschl-lr_zcoretax0007 INTO ls_zcoretax0007 WHERE low = lt_bschl-chkont.
                    lr1_hkont-sign  = ls_zcoretax0007-sign.
                    lr1_hkont-option = ls_zcoretax0007-zoption.
                    lr1_hkont-low = ls_zcoretax0007-low.
                    lr1_hkont-high = ls_zcoretax0007-high.
                    APPEND lr1_hkont.
                  ENDLOOP.
                  IF lr1_hkont[] IS NOT INITIAL.
                    DELETE gt_detail_nontrade2[] WHERE hkont IN lr1_hkont AND bschl NE  lt_bschl-bschl.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDIF.

**          SELECT * APPENDING CORRESPONDING FIELDS OF TABLE gt_detail_nontrade FROM bsid
**            FOR ALL ENTRIES IN gt_nontrade
**            WHERE bukrs = gt_nontrade-bukrs
**              AND belnr = gt_nontrade-belnr
**              AND gjahr = gt_nontrade-gjahr
**              AND hkont IN lr_hkont..
**          SELECT * APPENDING CORRESPONDING FIELDS OF TABLE gt_detail_nontrade FROM bsad
**            FOR ALL ENTRIES IN gt_nontrade
**            WHERE bukrs = gt_nontrade-bukrs
**              AND belnr = gt_nontrade-belnr
**              AND gjahr = gt_nontrade-gjahr
**            AND hkont IN lr_hkont..
          "              AND hkont IN lr_hkont.
        ENDIF.
      ENDIF.

    WHEN p_rad4.
      IF p_bukrs = '8020' OR p_bukrs = '8220'.
        lr_kunnr-sign = 'I'.
        lr_kunnr-option = 'EQ'.
        lr_kunnr-low = '0011400294'.
        APPEND lr_kunnr.
        lr_kunnr-sign = 'I'.
        lr_kunnr-option = 'EQ'.
        lr_kunnr-low = '0011400275'.
        APPEND lr_kunnr.
        lr_kunnr-sign = 'I'.
        lr_kunnr-option = 'EQ'.
        lr_kunnr-low = '0011400274'.
        APPEND lr_kunnr.
        lr_kunnr-sign = 'I'.
        lr_kunnr-option = 'EQ'.
        lr_kunnr-low = '0011400273'.
        APPEND lr_kunnr.
        CLEAR: gt_8220h[], gt_header[], gt_vttk[].

        IF p_bukrs = '8020'.
          SELECT a~tknum a~erdat b~tpnum b~vbeln c~kunnr name_co cityc stcd1 stcd3 stcd5 stcd6 stceg "gfrom vattrn
                   str_suppl1 str_suppl2 str_suppl3 location  d~gform vattrn
            INTO CORRESPONDING FIELDS OF TABLE gt_vttk
            FROM vttk AS a JOIN vttp AS b ON a~tknum = b~tknum
                           JOIN likp AS c ON c~vbeln = b~vbeln
                           JOIN kna1 AS d ON d~kunnr = c~kunnr
                           JOIN adrc AS e ON e~addrnumber = d~adrnr
                           JOIN zfvattrn AS f ON f~vkorg = p_bukrs AND
                                                 f~gform = 'A1'
            WHERE c~kunnr = 'TBA0246'
                AND a~erdat IN s_erdat
                AND a~tknum IN s_tknum.
          "        IF gt_vttk[] IS INITIAL.
          SORT gt_vttk BY tknum vbeln kunnr.
          DELETE ADJACENT DUPLICATES FROM gt_vttk COMPARING tknum vbeln kunnr.
        ENDIF.
        IF p_bukrs = '8220'.
          SELECT a~tknum a~erdat b~tpnum b~vbeln c~kunnr name_co cityc stcd1 stcd3 stcd5 stcd6 stceg "gfrom vattrn
                   str_suppl1 str_suppl2 str_suppl3 location  d~gform vattrn
            INTO CORRESPONDING FIELDS OF TABLE gt_vttk
            FROM vttk AS a JOIN vttp AS b ON a~tknum = b~tknum
                           JOIN likp AS c ON c~vbeln = b~vbeln
                           JOIN kna1 AS d ON d~kunnr = c~kunnr
                           JOIN adrc AS e ON e~addrnumber = d~adrnr
                           JOIN zfvattrn AS f ON f~vkorg = p_bukrs AND
                                                 f~gform = 'A1'
            WHERE c~kunnr IN lr_kunnr AND
                a~erdat IN s_erdat
                AND a~tknum IN s_tknum.
          SORT gt_vttk BY tknum vbeln kunnr.
          DELETE ADJACENT DUPLICATES FROM gt_vttk COMPARING tknum vbeln kunnr.
        ENDIF.
        IF gt_vttk[] IS NOT INITIAL AND p_val = 'X'.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zcoretax0005_done FROM zcoretax0005
            FOR ALL ENTRIES IN gt_vttk
            WHERE bukrs = p_bukrs
              AND belnr = gt_vttk-tknum.
          IF gt_zcoretax0005_done[] IS NOT INITIAL.
            LOOP AT gt_zcoretax0005_done INTO gs_zcoretax0005.
              DELETE gt_vttk[] WHERE tknum = gs_zcoretax0005-belnr.
            ENDLOOP.
          ENDIF.
        ENDIF.
        IF gt_vttk[] IS NOT INITIAL.
          IF p_bukrs = '8020'.
            SELECT i~tknum i~erdat a~vbeln a~posnr a~matnr a~lfimg maktx stawn a~werks
              INTO CORRESPONDING FIELDS OF TABLE gt_lips
              FROM lips AS a JOIN makt AS e ON e~matnr = a~matnr
                                           AND e~spras = 'E'
                             JOIN marc AS f ON f~matnr = a~matnr
                                           AND f~werks = '0246'
                             JOIN vttp AS g ON a~vbeln = g~vbeln
                             JOIN vttk AS i ON g~tknum = i~tknum

              FOR ALL ENTRIES IN gt_vttk
              WHERE a~vbeln =  gt_vttk-vbeln
                AND i~tknum = gt_vttk-tknum
                AND lfimg NE 0.
          ELSE.
            SELECT i~tknum i~erdat a~vbeln a~posnr a~matnr a~lfimg maktx stawn a~werks j~mvgr5
              INTO CORRESPONDING FIELDS OF TABLE gt_lips
              FROM lips AS a JOIN makt AS e ON e~matnr = a~matnr
                                           AND e~spras = 'E'
                             JOIN marc AS f ON f~matnr = a~matnr
                                           AND f~werks = '2200'
                             JOIN vttp AS g ON a~vbeln = g~vbeln
                             JOIN vttk AS i ON g~tknum = i~tknum
                             JOIN mvke AS j ON j~matnr = a~matnr
                                           AND j~vkorg = p_bukrs
                                           AND j~vtweg = '00'

              FOR ALL ENTRIES IN gt_vttk
              WHERE a~vbeln =  gt_vttk-vbeln
                AND i~tknum = gt_vttk-tknum
                AND lfimg NE 0.
          ENDIF.
          lt_lips[] = gt_lips[].
          SORT lt_lips BY matnr.
          DELETE ADJACENT DUPLICATES FROM lt_lips COMPARING matnr.
          IF lt_lips[] IS NOT INITIAL.
            IF p_bukrs = '8020'.
              SELECT b~matnr b~lifnr b~knumh c~kbetr c~kpein b~datab b~datbi
                INTO CORRESPONDING FIELDS OF TABLE gt_a017
                FROM a017 AS b JOIN konp AS c ON c~knumh = b~knumh
                               JOIN eina AS f ON f~matnr = b~matnr
                                             AND f~lifnr = b~lifnr
                FOR ALL ENTRIES IN lt_lips
                WHERE b~matnr = lt_lips-matnr
                  AND b~kappl = 'M'
                  AND b~kschl = 'ZHJP'
                  AND b~ekorg = 'SOM'
                  AND b~werks = '0200'
                  AND b~esokz = '0'
                  AND f~loekz NE 'X'
                  AND b~datbi >= lt_lips-erdat
                  AND b~datab <= lt_lips-erdat.
            ELSE.
              SELECT b~matnr  b~knumh c~kbetr c~kpein b~datab b~datbi
                INTO CORRESPONDING FIELDS OF TABLE gt_a934
                FROM a934 AS b JOIN konp AS c ON c~knumh = b~knumh
                FOR ALL ENTRIES IN lt_lips
                WHERE b~matnr = lt_lips-matnr
                  AND b~kappl = 'V'
                  AND b~kschl = 'ZHET'
                  AND b~vkorg = p_bukrs
                  AND auart_sd = space
                  AND b~datbi >= lt_lips-erdat
                  AND b~datab <= lt_lips-erdat.
            ENDIF.
          ENDIF.
          SORT gt_lips BY vbeln posnr matnr lfimg.
          DELETE ADJACENT DUPLICATES FROM gt_lips COMPARING vbeln posnr matnr lfimg.
        ENDIF.
      ELSEIF p_bukrs = '8220'.
      ELSE.
        MESSAGE i000(zab) WITH 'Mohon dicek kembali pilihannya'.
        LEAVE TO SCREEN 0.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
  SELECT SINGLE * INTO CORRESPONDING FIELDS OF gs_zfnoefaktur FROM zfnoefaktur
    WHERE bukrs = p_bukrs AND zfakty = 'FKX'.
  IF sy-subrc EQ 0.
    gs_zfnoefaktur-znomor = gs_zfnoefaktur-znomor + 1.
    CONDENSE: gs_zfnoefaktur-zfakty, gs_zfnoefaktur-znomor.
    CONCATENATE gs_zfnoefaktur-zfakty gs_zfnoefaktur-znomor '.XML' INTO gv_namafile.
    CONCATENATE gs_zfnoefaktur-zfakty gs_zfnoefaktur-znomor INTO gv_namafileptt.
  ELSE.
    gs_zfnoefaktur-znomor = 1.
    gs_zfnoefaktur-zfakty = 'FKX'.
    gs_zfnoefaktur-folder = 'C:\coretax\fkx\'.
    gs_zfnoefaktur-bukrs = p_bukrs.
    gs_zfnoefaktur-masatx = sy-datum(6).
    CONDENSE: gs_zfnoefaktur-zfakty, gs_zfnoefaktur-znomor.
    CONCATENATE gs_zfnoefaktur-zfakty gs_zfnoefaktur-znomor '.XML' INTO gv_namafile.
    CONCATENATE gs_zfnoefaktur-zfakty gs_zfnoefaktur-znomor INTO gv_namafileptt.
  ENDIF.
  p_name = gv_namafile.

ENDFORM.


FORM f_print_data .
  IF gt_header_xml[] IS NOT INITIAL.
    PERFORM f_alv TABLES gt_header_xml gt_detail_xml.
  ELSE.
    gv_error = 'E'.
    gv_message = 'Tidak ada data mohon cek pilihannya'.
    MESSAGE i000(zab) WITH gv_message.
  ENDIF.

*  CALL SCREEN 100.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg USING    VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_scrtext_s)
                          VALUE(fu_scrtext_m)
                          VALUE(fu_scrtext_l)

*                          value(fu_dosum)
*                          value(fu_hotsp)
*                          value(fu_dec)
*                          value(fu_waers)
*                          value(fu_meins)
*                          value(fu_meins_f)
                          VALUE(fu_checkbox)
                          VALUE(fu_waers)
                          VALUE(fu_input)
*                          value(fu_emphasize)
*                          value(fu_hotspot)
                          "VALUE(fu_edit)
                          VALUE(fu_just). ""just(1)        type c,        " (R)ight (L)eft (C)ent.
  .
*                          value(fu_no_zero).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname   = fu_reftb.
  ld_fieldcat-ref_fieldname = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-reptext_ddic  = fu_fltxt.

  ld_fieldcat-seltext_l  = fu_scrtext_l.
  ld_fieldcat-seltext_m  = fu_scrtext_m.
  ld_fieldcat-seltext_s  = fu_scrtext_s.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-just = fu_just.

*  ld_fieldcat-do_sum            = fu_dosum.
*  ld_fieldcat-hotspot           = fu_hotsp.
*  ld_fieldcat-decimals_o        = fu_dec.
  ld_fieldcat-currency          = fu_waers.
*  ld_fieldcat-quantity          = fu_meins.
*  ld_fieldcat-qfieldname        = fu_meins_f.
*  ld_fieldcat-cfieldname        = fu_waers_f.
*  ld_fieldcat-emphasize         = fu_emphasize.
*  ld_fieldcat-hotspot           = fu_hotspot.
*  ld_fieldcat-edit              = fu_edit.
*  ld_fieldcat-no_zero           = fu_no_zero.

  APPEND ld_fieldcat TO  t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report ft_report1..
  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING 'GT_HEADER_XML' : "ft_report:
    'BUKRS'       'VBRK' 'BUKRS'      '' '' 'Company'           'Company'   'Company'    'Company'  '' '' '' '',
    'VBELN'       'VBRK' 'VBELN'      '' '' 'Document'          'Document'  'Document'   ''  '' '' '' '',
    'TAXINVOICEDATE'  '' '' '' '10' 'TaxDate' 'TaxDate' 'TaxDate' 'TaxDate' '' '' '' '',
    'KUNRG'       'VBRK' 'KUNRG'      '' '' 'Customer'             'Customer'   'Customer'      'Customer' '' '' '' '',
    'BUYERNAME'   'ADRC' 'NAME_CO' '' '40' 'BuyerName' 'BuyerName' 'BuyerName' 'BuyerName' '' '' '' '',
    'REFDESC'   '' '' '' '60' 'RefDesc' 'RefDesc' 'RefDesc' 'RefDesc' '' '' '' '',
    'BUYERTIN'   '' '' '' '25' 'BuyerTin' 'BuyerTin' 'BuyerTint' 'BuyerTin' '' '' '' '',
    'BUYERDOCUMENT'   '' '' '' '25' 'BuyerDocument' 'BuyerDocument' 'BuyerDocument' 'BuyerDocument' '' '' '' '',
    'BUYERADRESS'   '' '' '' '80' 'BuyerAdress' 'BuyerAdress' 'BuyerAdress' 'BuyerAdress' '' '' '' '',
    'ICON'  '' '' '' '5' 'Icon' 'Icon' 'Icon' 'Icon' '' '' '' '',
    'MESS_ERROR'  '' '' '' '150' 'Message' 'Message' 'Message' 'Message' '' '' '' ''.

  PERFORM f_fieldcatg USING 'GT_DETAIL_XML' : "ft_report1:
    'MATNR'       'VBRP' 'MATNR'    '' '' ''  ''  ''  ''  '' '' '' '',
    'NAME'       'MAKT' 'MAKTX'    '' '50' ''  ''  ''  ''  '' '' '' '',
    'PRICE'   '' '' '' '15' 'PRICE' 'PRICE' 'PRICE' 'PRICE' '' '' '' 'R',
    'QTY'   '' '' '' '15' 'Qty' 'Qty' 'Qty' 'Qty' '' '' '' 'R',
    'TOTALDISCOUNT'   '' '' '' '15' 'TOTALDISCOUNT' 'TOTALDISCOUNT' 'TOTALDISCOUNT' 'TOTALDISCOUNT' '' '' '' 'R',
    'TAXBASE'   '' '' '' '15' 'TaxBase' 'TaxBase' 'TaxBase' 'TaxBase' '' '' '' 'R',
    'OTHERTAXBASE'   '' '' '' '15' 'OTHERTAXBASE' 'OTHERTAXBASE' 'OTHERTAXBASE' 'OTHERTAXBASE' '' '' '' 'R',
    'VAT'   '' '' '' '15' 'VAT' 'VAT' 'VAT' 'VAT' '' '' '' 'R',

    'VVAT'   'VBRK' 'NETWR' '' '15' 'VAT-Hitung' 'VAT-Hitung' 'VAT-Hitung' 'VAT-Hitung' '' '' '' '',
    'VTAXBASE'   'VBRK' 'NETWR' '' '15' 'DPP-Hitung' 'DPP-Hitung' 'DPP-Hitung' 'DPP-Hitung' '' '' '' '',



    'ICON'  '' '' '' '5' 'Icon' 'Icon' 'Icon' 'Icon' '' '' '' '',
    'MESSAGE_ERROR'  '' '' '' '150' 'Message' 'Message' 'Message' 'Message' '' '' '' ''.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'GT_HEADER_XML'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'GT_DETAIL_XML'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.



ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV_DATA
*&---------------------------------------------------------------------*
FORM f_clear_alv_data.
  CLEAR:t_alv_fieldcat,
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

  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.
ENDFORM.                    " F_CLEAR_ALV_DATA

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM F_GUI_MESSAGE
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "F_GUI_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
FORM f_alv_variant_exist USING     fu_vari
                         CHANGING  fc_alv_variant STRUCTURE disvariant.
  IF NOT fu_vari IS INITIAL.
    MOVE fu_vari TO fc_alv_variant-variant.
    fc_alv_variant-report = d_repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = fc_alv_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      IF NOT sy-msgid IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR fc_alv_variant.
    fc_alv_variant-report = sy-repid.
  ENDIF.
ENDFORM.                    " F_ALV_VARIANT_EXIST

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&EXECUTE'.
      PERFORM f_proses_data.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND


*&---------------------------------------------------------------------*
*&      Form  F_ALV
*&---------------------------------------------------------------------*
FORM f_alv TABLES ft_report ft_report2.
  DATA: lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report ft_report2.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_keyinfo     USING   d_alv_keyinfo.
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.

  PERFORM f_build_event       TABLES  t_alv_event[].

  "lv_func    = 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
      it_sort                  = t_alv_isort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      i_tabname_header         = 'GT_HEADER_XML'
      i_tabname_item           = 'GT_DETAIL_XML'
      is_keyinfo               = d_alv_keyinfo
      is_print                 = d_print
    TABLES
      t_outtab_header          = ft_report
      t_outtab_item            = ft_report2
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.


**  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
**    EXPORTING
**      i_callback_program       = d_repid
**      i_callback_pf_status_set = 'F_SET_PF_STATUS'
**      i_callback_user_command  = 'F_USER_COMMAND'
***     i_grid_title             = lv_title
**      is_layout                = d_layout
**      it_fieldcat              = t_alv_fieldcat[]
**      it_sort                  = t_alv_isort[]
**      i_default                = 'X'
**      i_save                   = 'A'
**      is_variant               = d_alv_variant
**      it_events                = t_alv_event[]
**      it_event_exit            = t_event_exit[]
**      is_print                 = d_print
**    TABLES
**      t_outtab                 = ft_report
**    EXCEPTIONS
**      program_error            = 1
**      OTHERS                   = 2.
ENDFORM.                    "F_ALV

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    "F_BUILD_EVENT

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT_EXIT
*---------------------------------------------------------------------*
FORM f_build_event_exit.
  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
ENDFORM.                    "F_BUILD_EVENT_EXIT

*---------------------------------------------------------------------*
*       FORM F_BUILD_LAYOUT
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
  fu_layout-box_fieldname      = 'CHKBX'.

*  fu_layout-box_fieldname      = 'CHECK'.
ENDFORM.                    "F_BUILD_LAYOUT

*---------------------------------------------------------------------*
*       FORM F_BUILD_PRINT
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "F_BUILD_PRINT

*---------------------------------------------------------------------*
*       FORM F_BUILD_SORTFIELD
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'VBELN'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

**  CLEAR ld_sort.
**  ld_sort-fieldname = 'FKDAT'.
**  ld_sort-up        = 'X'.
**  APPEND ld_sort TO fu_sort.

ENDFORM.                    "F_BUILD_SORTFIELD

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
ENDFORM.                    "F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_data .
  DATA: lv_filename TYPE edi_path-pthnam.
  DATA: gv_json      TYPE string.
  DATA: l_len TYPE i.
  DATA:        l_ctr TYPE i.
  DATA: msg(100).
  DATA: lv_msg(150).
  DATA: lt_header TYPE STANDARD TABLE OF ty_header_xml.
  CLEAR: lt_header[].
  IF gt_header_xml[] IS NOT INITIAL.
    LOOP AT gt_header_xml INTO gs_header_xml WHERE chkbx = 'X'.
      APPEND gs_header_xml TO lt_header.

      gs_zcoretax0005-bukrs = p_bukrs.
      gs_zcoretax0005-type =  gs_zfnoefaktur-zfakty.
      gs_zcoretax0005-masatx = p_perio. "gs_header_xml-fkdat(6).
      gs_zcoretax0005-vkbur = gs_header_xml-vkbur.
      gs_zcoretax0005-zuonr = gs_header_xml-zuonr. "vgbel
      gs_zcoretax0005-belnr = gs_header_xml-vbeln.
      "      gs_zcoretax0005-prefix = gs_zfnoefaktur-folder.
      gs_zcoretax0005-files = gv_namafile.
      "      gs_zcoretax0005-NONR
      gs_zcoretax0005-buyertin = gs_header_xml-buyertin.
      gs_zcoretax0005-buyerdocument = gs_header_xml-buyerdocument.
      gs_zcoretax0005-erdat = sy-datum.
      gs_zcoretax0005-erzet = sy-uzeit.
      gs_zcoretax0005-ernam = sy-uname.
      MODIFY zcoretax0005 FROM gs_zcoretax0005.

    ENDLOOP.

    PERFORM f_prepare_xml_header.
    DATA: lv_urut TYPE i.
    SORT lt_header BY bukrs vkbur vbeln.
    IF p_bukrs = '8020' OR p_bukrs = '8070'.
      IF s_vbeln[] IS NOT INITIAL.
        CLEAR: lv_urut.
        LOOP AT s_vbeln.
          ADD 1 TO lv_urut.
          LOOP AT lt_header INTO gs_header_xml WHERE vbeln = s_vbeln-low.
            gs_header_xml-nourut = lv_urut.
            MODIFY lt_header FROM gs_header_xml TRANSPORTING nourut.
          ENDLOOP.
        ENDLOOP.
        SORT lt_header BY nourut.
      ENDIF.
    ENDIF.
    LOOP AT lt_header INTO gs_header_xml.
      gs_zcoretax0004-bukrs = p_bukrs.
      gs_zcoretax0004-namafile = gv_namafile.
      gs_zcoretax0004-vbeln  = gs_header_xml-vbeln.
      gs_zcoretax0004-waers = 'IDR'.
      PERFORM init_data.
      PERFORM f_prepare_data USING gs_header_xml.
      PERFORM f_prepare_xml.
    ENDLOOP.

    IF g_string IS NOT INITIAL.
      SORT gt_zcoretax0002 BY kind.
      READ TABLE gt_zcoretax0002 INTO gs_zcoretax0002 WITH KEY kind = 'HEAD2'.
      IF sy-subrc EQ 0.
        CONCATENATE '</' gs_zcoretax0002-name '>' INTO out_string.
        PERFORM fill_xml_table.
      ENDIF.
      SORT gt_zcoretax0002 BY kind.
      READ TABLE gt_zcoretax0002 INTO gs_zcoretax0002 WITH KEY kind = 'HEADER'.
      IF sy-subrc EQ 0.
        CONCATENATE '</' gs_zcoretax0002-name '>' INTO out_string.
        PERFORM fill_xml_table.
      ENDIF.

      FIELD-SYMBOLS: <out> TYPE string.
      DATA: lt_download TYPE STANDARD TABLE OF zstdown.
      DATA: ls_download TYPE zstdown.
      LOOP AT gt_zcoretax0003 INTO gs_zcoretax0003.
        gs_zcoretax0003-bukrs = p_bukrs.
        gs_zcoretax0003-ernam = sy-uname.
        gs_zcoretax0003-erdat = sy-datum.
        gs_zcoretax0003-erzet = sy-uzeit.
        MODIFY zcoretax0003 FROM gs_zcoretax0003.
        ls_download-fieldline = gs_zcoretax0003-value.
        APPEND ls_download TO lt_download.
      ENDLOOP.
      "      LOOP AT gt_zcoretax0004 into gs_zcoretax0004.

      "      ENDLOOP.
      MODIFY zfnoefaktur FROM gs_zfnoefaktur.

      IF p_file = 'X'.
        DATA: lv_file TYPE string.
        IF lt_download[] IS NOT INITIAL.
          CONCATENATE gs_zfnoefaktur-folder gv_namafile INTO lv_file.
          PERFORM f_download TABLES lt_download
                             USING  lv_file
                             CHANGING sy-subrc.
          IF sy-subrc EQ 0.
            CONCATENATE 'File:' lv_file  INTO lv_msg SEPARATED BY space.
            MESSAGE i000(zab) WITH lv_msg.
          ENDIF.

        ENDIF.

      ELSE.
        CONCATENATE p_path p_name INTO lv_filename.
        "      lv_filename = '/outbound/clipper/test01.xml'.
        OPEN DATASET lv_filename FOR OUTPUT IN LEGACY BINARY MODE MESSAGE msg.

        PERFORM transfer_xml_table.
* write string_output to file
        TRY.
            LOOP AT g_string_table ASSIGNING <out>.
              TRANSFER <out> TO lv_filename.
            ENDLOOP.
        ENDTRY.
        CLOSE DATASET lv_filename.
        lv_msg = lv_filename .
        MESSAGE i000(zab) WITH lv_msg.

      ENDIF.
    ENDIF.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_KEYINFO
*&---------------------------------------------------------------------*
FORM f_build_keyinfo  USING    fu_keyinfo TYPE slis_keyinfo_alv.
  fu_keyinfo-header01 = 'VBELN'.
  fu_keyinfo-item01   = 'VBELN'.
ENDFORM.                    " F_BUILD_KEYINFO

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD
*&---------------------------------------------------------------------*
FORM f_download  TABLES   ft_download
                 USING    fu_filename
                 CHANGING fc_subrc.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = fu_filename
      filetype                = 'ASC'
      codepage                = '4110'
    TABLES
      data_tab                = ft_download
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.

  fc_subrc  = sy-subrc.
ENDFORM.                    " F_DOWNLOAD
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_XML_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_xml_header .

  CLEAR: g_string, out_string.

*** Prepare Header dari XML yg hanya ditulis sekali disetiap format xml yg dibentuk
  SORT gt_zcoretax0002 BY kind.
  READ TABLE gt_zcoretax0002 INTO gs_zcoretax0002 WITH KEY kind = 'TITLE'.
  IF sy-subrc EQ 0.
    out_string = gs_zcoretax0002-value.
  ENDIF.
  PERFORM fill_xml_table.
  READ TABLE gt_zcoretax0002 INTO gs_zcoretax0002 WITH KEY kind = 'HEADER'.
  IF sy-subrc EQ 0.
    out_string = gs_zcoretax0002-value.
  ENDIF.
  PERFORM fill_xml_table.

  REPLACE ALL OCCURRENCES OF '.' IN gs_zgdtxdt0005-pkpnpwp WITH '' .
  REPLACE ALL OCCURRENCES OF '-' IN gs_zgdtxdt0005-pkpnpwp WITH '' .
  CONCATENATE '0' gs_zgdtxdt0005-pkpnpwp INTO gs_zgdtxdt0005-pkpnpwp.
  SORT gt_zcoretax0002 BY kind.
  READ TABLE gt_zcoretax0002 INTO gs_zcoretax0002 WITH KEY kind = 'HEAD1'.
  IF sy-subrc EQ 0.
    IF gs_zgdtxdt0005-pkpnpwp IS NOT INITIAL.
      CONCATENATE '<' gs_zcoretax0002-name '>' gs_zgdtxdt0005-pkpnpwp '</' gs_zcoretax0002-name '>' INTO out_string.
    ELSE.
      CONCATENATE '<' gs_zcoretax0002-name '/>'  INTO out_string.
    ENDIF.
  ENDIF.
  PERFORM fill_xml_table.
  SORT gt_zcoretax0002 BY kind.
  READ TABLE gt_zcoretax0002 INTO gs_zcoretax0002 WITH KEY kind = 'HEAD2'.
  IF sy-subrc EQ 0.
    CONCATENATE '<' gs_zcoretax0002-name '>' INTO out_string.
  ENDIF.
  PERFORM fill_xml_table.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_data_itab.

  TYPES: BEGIN OF ty_konv,
           vbeln TYPE vbrp-vbeln,
           posnr TYPE vbrp-posnr,
           knumv TYPE konv-knumv,
           kposn TYPE konv-kposn,
           kschl TYPE konv-kschl, "ZERD
           kwert TYPE konv-kwert,
         END OF ty_konv.
  DATA: lt_konv_zerd TYPE STANDARD TABLE OF  ty_konv WITH HEADER LINE.
  DATA: lt_konv_zhsc TYPE STANDARD TABLE OF  ty_konv WITH HEADER LINE.
  DATA: lt_konv_zrp1 TYPE STANDARD TABLE OF  ty_konv WITH HEADER LINE.
  DATA: lv_batas         TYPE netwr, "p DECIMALS 4,
        lv_price         TYPE netwr, "p DECIMALS 4, "vbrk-netwr,
        lv_totaldiscount TYPE netwr, "p DECIMALS 4, "vbrk-netwr,
        lv_taxbase       TYPE netwr, "p DECIMALS 4, "vbrk-netwr,
        lv_netwr         TYPE netwr, "
        lv_selisih       TYPE netwr, "p DECIMALS 4, "vbrk-netwr,
        lv_othertaxbase  TYPE netwr, "p DECIMALS 4, "vbrk-netwr,
        lv_vat           TYPE p DECIMALS 0. "vbrk-netwr.
  DATA: lv_qty2 TYPE p DECIMALS 2,
        lv_qty  TYPE p DECIMALS 0.
  DATA: lv_text1024 TYPE text1024.
  DATA: lv_len   TYPE i, lv_sw(1).
  DATA: gs_header TYPE ty_header.
  DATA: lt_bseg TYPE STANDARD TABLE OF ty_bseg WITH HEADER LINE.
  DATA: lt_zcoretax0008 TYPE STANDARD TABLE OF zcoretax0008. " WITH HEADER LINE.
  DATA: ls_zcoretax0008 TYPE zcoretax0008.
  DATA: lv_opt TYPE char1.
  DATA: lv_unit TYPE char15.
  DATA: lv_remark TYPE char40.
  RANGES: lr_knumv FOR vbrk-knumv.
  IF p_bukrs EQ '8220'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_konv_zerd
      FROM vbrk AS a JOIN vbrp AS b ON a~vbeln = b~vbeln
                 JOIN konv AS c ON c~knumv = a~knumv
                               AND c~kposn = b~posnr
      FOR ALL ENTRIES IN gt_header
      WHERE a~vbeln = gt_header-vbeln
        AND c~knumv = gt_header-knumv
        AND  ( kschl = 'ZERD' OR kschl = 'ZERV' OR kschl = 'ZERX' ).
  ENDIF.
  IF p_bukrs EQ '8010' OR p_bukrs EQ '8090' OR p_bukrs EQ '8040'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_konv_zhsc
      FROM vbrk AS a JOIN vbrp AS b ON a~vbeln = b~vbeln
                 JOIN konv AS c ON c~knumv = a~knumv
                               AND c~kposn = b~posnr
      FOR ALL ENTRIES IN gt_header
      WHERE a~vbeln = gt_header-vbeln
        AND c~knumv = gt_header-knumv
        AND   kschl = 'ZHSC'.
  ENDIF.
  IF p_bukrs EQ '8230'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_konv_zrp1
      FROM vbrk AS a JOIN vbrp AS b ON a~vbeln = b~vbeln
                 JOIN konv AS c ON c~knumv = a~knumv
                               AND c~kposn = b~posnr
      FOR ALL ENTRIES IN gt_header
      WHERE a~vbeln = gt_header-vbeln
        AND c~knumv = gt_header-knumv
        AND  ( kschl = 'ZRP1' OR kschl = 'ZRD1' ).
  ENDIF.
  LOOP AT gt_vbrk INTO gs_vbrk .
    MOVE-CORRESPONDING gs_vbrk  TO gt_item.
    IF p_bukrs EQ '8010' OR p_bukrs EQ '8090' OR p_bukrs EQ '8040'.
      SORT lt_konv_zhsc BY vbeln kposn.
      READ TABLE lt_konv_zhsc WITH KEY vbeln = gs_vbrk-vbeln
                                       kposn = gs_vbrk-posnr
                                       BINARY SEARCH.
      IF sy-subrc EQ 0.
        gt_item-netwr = lt_konv_zhsc-kwert.
      ENDIF.
    ENDIF.
    IF p_bukrs EQ '8230'.
      SORT lt_konv_zrp1 BY vbeln kposn kschl.
      READ TABLE lt_konv_zrp1 WITH KEY vbeln = gs_vbrk-vbeln
                                       kposn = gs_vbrk-posnr
                                       kschl = 'ZRP1'
                                       BINARY SEARCH.
      IF sy-subrc EQ 0.
        gt_item-netwr = lt_konv_zrp1-kwert.
      ENDIF.
      SORT lt_konv_zrp1 BY vbeln kposn kschl.
      READ TABLE lt_konv_zrp1 WITH KEY vbeln = gs_vbrk-vbeln
                                       kposn = gs_vbrk-posnr
                                       kschl = 'ZRD1'
                                       BINARY SEARCH.
      IF sy-subrc EQ 0.
        gt_item-netwr = gt_item-netwr + lt_konv_zrp1-kwert.
      ENDIF.
    ENDIF.
    IF p_bukrs NE '8220'.
      CLEAR gt_item-posnr.
    ENDIF.
    COLLECT gt_item.
  ENDLOOP.
  gt_vbrk[] = gt_item[].
  LOOP AT gt_bseg INTO gs_bseg.
    MOVE-CORRESPONDING gs_bseg TO lt_bseg.
    COLLECT lt_bseg.
  ENDLOOP.
  gt_bseg[] = lt_bseg[].
  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zcoretax0008 FROM zcoretax0008
    WHERE bukrs = p_bukrs.

  REPLACE ALL OCCURRENCES OF '.' IN gs_zgdtxdt0005-nitku WITH '' .
  REPLACE ALL OCCURRENCES OF '-' IN gs_zgdtxdt0005-nitku WITH '' .
  LOOP AT gt_header INTO gs_header.
    CLEAR: gv_error, gv_message, lv_sw, lv_opt, lv_unit, lv_remark.

    MOVE-CORRESPONDING gs_header TO gs_header_xml.
    IF gs_header-txdat IS INITIAL.
      gs_header-txdat = gs_header-fkdat.
    ELSE.
      gs_header-fkdat =  gs_header-txdat.
    ENDIF.
    gs_header_xml-fkdat = gs_header-txdat.
    CONCATENATE gs_header-txdat(4) '-' gs_header-txdat+4(2) '-' gs_header-txdat+6(2) INTO gs_header_xml-taxinvoicedate.
    gs_header_xml-taxinvoiceopt = 'Normal'.
    IF gs_header-vattrn IS INITIAL.
      gs_header_xml-trxcode = '04'.
    ELSE.
      gs_header_xml-trxcode = gs_header-vattrn. "'04'.
    ENDIF.
    IF p_check = 'X'.
      IF gs_header-vattrn = '01'.
        gs_header_xml-trxcode = '04'.
      ENDIF.
    ENDIF.
    IF p_bukrs = '8800'.
      gs_header_xml-trxcode = '05'.
    ENDIF.
    gs_header_xml-vkbur = gs_header-vkbur.
    gs_header_xml-bukrs = gs_header-bukrs.
    IF p_bukrs = '8020' OR p_bukrs = '8070' OR p_bukrs = '8800'.
      CONCATENATE gs_header-vkbur gv_namafileptt  gs_header-vbeln gs_header-vgbel gs_header-kunrg "gv_namafile
         INTO gs_header_xml-refdesc SEPARATED BY space.
    ELSE.
      IF gs_header-bukrs = '8330'.
        "        gs_header-vkbur = gs_header-werks.
        gs_header_xml-vkbur = gs_header-vkbur = gs_header-werks.
      ENDIF.
      IF gs_header-vkbur IS NOT INITIAL.
        CONCATENATE gs_header-vkbur gs_header-kunrg gs_header-vbeln gs_header-vgbel gv_namafile
           INTO gs_header_xml-refdesc SEPARATED BY space.
      ELSE.
        CONCATENATE gs_header-bukrs gs_header-kunrg gs_header-vbeln gs_header-vgbel gv_namafile
           INTO gs_header_xml-refdesc SEPARATED BY space.
      ENDIF.
    ENDIF.
    gs_header_xml-selleridtku = gs_zgdtxdt0005-nitku.
    REPLACE ALL OCCURRENCES OF '.' IN gs_header-stcd1 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN gs_header-stcd1 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN gs_header-stcd6 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN gs_header-stcd6 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN gs_header-stcd3 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN gs_header-stcd3 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN gs_header-stcd5 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN gs_header-stcd5 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN gs_header-stceg WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN gs_header-stceg WITH '' .
    CONDENSE gs_header-stceg.
    lv_len = strlen( gs_header-stceg ).
    IF lv_len < 16.
      IF gs_header-stceg IS NOT INITIAL.
        CONCATENATE '0' gs_header-stceg INTO gs_header-stceg.
      ENDIF.
    ENDIF.
    IF gs_header-cityc = 'T0'.
      IF gs_header-stcd6 IS INITIAL.
        gs_header-stceg = 'Other ID'.
        gs_header-stcd6 = '0000000000000000'.
        gs_header_xml-buyerdocumentnumber = '0000000000000000'.
        gv_error = 'W'.
        gv_message = 'NITKU Buyer belum ada'.
        gs_header_xml-error = 'W'.
        gs_header_xml-icon = icon_yellow_light.
        gs_header_xml-mess_error = gv_message.
      ELSE.
        gs_header-stceg = 'National ID'.
        gs_header_xml-buyerdocumentnumber = gs_header-stcd6.
      ENDIF.
      gs_header_xml-buyertin  = '0000000000000000'. "gs_header-stcd1.
    ELSE.
      gs_header-stceg = 'TIN'.
      gs_header_xml-buyertin  = gs_header-stcd6.
      CLEAR: gs_header-stcd6, gs_header_xml-buyerdocumentnumber.
      IF gs_header_xml-buyertin IS INITIAL.
        gv_error = 'E'.
        gv_message = 'Buyer TIN belum ada, mohon cek master data'.
        gs_header_xml-icon = icon_red_light.
        gs_header_xml-error = 'E'.
        gs_header_xml-mess_error = gv_message.
      ENDIF.
    ENDIF.
    gs_header_xml-buyerdocument = gs_header-stceg.
    gs_header_xml-buyercountry = 'IDN'.
    "    gs_header_xml-buyerdocumentnumber = gs_header-stcd6.
    gs_header_xml-buyername = gs_header-name_co.
    gs_header_xml-buyeridtku = gs_header-stcd5.
    CONCATENATE gs_header-str_suppl1 gs_header-str_suppl2 gs_header-str_suppl3 gs_header-location
         INTO gs_header_xml-buyeradress SEPARATED BY  space.
    lv_text1024 = gs_header_xml-buyeradress.
    CALL FUNCTION 'ZTDSIT_F0004'
      EXPORTING
        ztextin  = lv_text1024
      IMPORTING
        ztextout = lv_text1024.
    gs_header_xml-buyeradress = lv_text1024.
    gs_header_xml-buyeridtku = gs_header-stcd5.
    gs_header_xml-vbeln = gs_header-vbeln.
    gs_header_xml-zuonr = gs_header-zuonr.
    gs_header_xml-bukrs =  gs_header-bukrs.

    IF lt_zcoretax0008[] IS NOT INITIAL.
      SORT  lt_zcoretax0008 BY bukrs fkart.
      READ TABLE lt_zcoretax0008 INTO ls_zcoretax0008
      WITH KEY bukrs = gs_header-bukrs
               fkart = gs_header-fkart.
      IF sy-subrc EQ 0.
        lv_opt =  ls_zcoretax0008-opt.
        lv_unit = ls_zcoretax0008-satuan.
        lv_remark = ls_zcoretax0008-remark.
      ENDIF.
    ENDIF.

    CLEAR: gs_header_xml-total_taxbase, gs_header_xml-total_vat, gs_header_xml-total_diskon.
    LOOP AT gt_vbrk INTO gs_vbrk WHERE vbeln = gs_header-vbeln.
      CLEAR: lv_totaldiscount, lv_vat, lv_price, lv_taxbase, lv_othertaxbase, lv_netwr, lv_batas, lv_qty2, lv_qty.
      MOVE-CORRESPONDING gs_vbrk TO gs_detail_xml.
      lv_netwr = abs( gs_vbrk-netwr  ) * 100.
*** penganti untuk netwr khusus untuk PLI ( 8330 ) - FKART = 'ZP01'  ambil dari VBRP-KZWI1
***                             untuk kmm ( 8360 ) - FKART = 'ZKM1'  ambil dari VBRP-KZWI4
      IF gs_header-fkart = 'ZP01'.
        lv_netwr = abs( gs_vbrk-kzwi1  ) * 100.
      ELSEIF gs_header-fkart = 'ZKM1'.
        lv_netwr = abs( gs_vbrk-kzwi4  ) * 100.
**      ELSEIF gs_header-fkart = 'ZI05'.
**        lv_netwr = gs_vbrk-netwr / ( 98 / 100 ) .
**        lv_netwr = abs( lv_netwr ) * 100.
      ELSEIF gs_header-fkart = 'ZTN5'.
        lv_netwr = abs( gs_vbrk-kzwi3 ) * 100.
      ENDIF.
      IF gs_header-bukrs = '8160'.
        lv_netwr = abs( gs_vbrk-kzwi3  ) * 100.
      ENDIF.
** Harga Satuan (Price), Tax, Taxbase (DPP) dihitung ulang kembali
      IF p_bukrs = '8020' OR p_bukrs = '8070'.
        lv_totaldiscount = abs( gs_vbrk-kzwi2 + gs_vbrk-kzwi3 + gs_vbrk-kzwi4 ) * 100. " + gs_vbrk-kzwi6 ).
        lv_totaldiscount =  lv_totaldiscount * 100 / 111 .
      ELSE.
        "        lv_totaldiscount = abs( gs_vbrk-kzwi2 ) * 100.
        SORT gt_bseg BY belnr matnr.
        READ TABLE gt_bseg INTO gs_bseg WITH KEY belnr = gs_header-vbeln
                                                 matnr = gs_vbrk-matnr.
        IF sy-subrc EQ 0.
          lv_totaldiscount = abs( gs_bseg-dmbtr ) * 100.
          IF p_bukrs = '8220'  OR p_bukrs = '8210' OR p_bukrs = '8380'.
            lv_totaldiscount =  lv_totaldiscount / ( 111 / 100 ).
          ENDIF.
        ENDIF.
      ENDIF.
      IF p_bukrs = '8800'.
        lv_qty2 = gs_vbrk-fkimg.
      ELSE.
        lv_qty = gs_vbrk-fkimg.
        lv_qty2 = lv_qty.
      ENDIF.
      IF lv_qty2 = 0.
        gv_message = 'ada item yg qty = 0'.
        gs_header_xml-icon = icon_red_light.
        gs_detail_xml-icon = icon_red_light.
        gs_header_xml-error = 'E'.
        gs_header_xml-mess_error = gv_message.
        gs_detail_xml-message_error = gv_message.
      ENDIF.
      IF p_bukrs = '8220'. " AND lv_netwr = 0.
**        SORT lt_konv_zerd BY vbeln kposn.
**        READ TABLE  lt_konv_zerd WITH KEY vbeln = gs_vbrk-vbeln
**                                          kposn = gs_vbrk-posnr
**                                          BINARY SEARCH.
**        IF sy-subrc EQ 0.
**          lv_totaldiscount =  abs( lt_konv_zerd-kwert ) * 100.
**        ENDIF.
        CLEAR: lv_totaldiscount.
        LOOP AT lt_konv_zerd WHERE vbeln = gs_vbrk-vbeln AND kposn = gs_vbrk-posnr.
          lv_totaldiscount =  lv_totaldiscount + lt_konv_zerd-kwert .
        ENDLOOP.
        lv_totaldiscount = abs( lv_totaldiscount  * 100 ).
      ENDIF.
      TRY .
          lv_price = ( lv_netwr + lv_totaldiscount ) / lv_qty2. "gs_vbrk-fkimg.
        CATCH cx_sy_zerodivide.
      ENDTRY.
      lv_taxbase = ( lv_price * lv_qty2 ) - lv_totaldiscount.
      IF lv_taxbase <> lv_netwr.
        lv_selisih = lv_taxbase - lv_netwr.
        lv_batas = abs( lv_selisih ).
        IF lv_batas > 100.
          WRITE lv_batas TO gs_detail_xml-message_error DECIMALS 0 NO-GROUPING NO-GAP.
          CONDENSE gs_detail_xml-message_error.
          CONCATENATE 'Selisih sebesar Rp. ' gs_detail_xml-message_error INTO gs_detail_xml-message_error SEPARATED BY space.
          gs_detail_xml-icon = icon_yellow_light.
          gs_header_xml-error = 'E'.
        ENDIF.
        IF lv_totaldiscount IS NOT INITIAL.
          lv_totaldiscount =  abs( lv_totaldiscount + lv_selisih ).
          lv_taxbase = abs( ( lv_price * lv_qty2 ) - lv_totaldiscount ).
        ELSE.
        ENDIF.
      ENDIF.
      lv_othertaxbase = lv_taxbase.

      IF p_bukrs = '8800'.
        lv_vat = abs( lv_taxbase * 11 / 1000 ).
        gs_vbrk-vatrate = '1.1'.
      ELSE.
        lv_vat = abs( lv_taxbase * 11 / 100 ).
        IF p_check = 'X'.
          gs_vbrk-vatrate = '12'.
          lv_othertaxbase = lv_taxbase * 11 / 12.
*          lv_othertaxbase = lv_vat * 100 / 12.
*          lv_vat = lv_othertaxbase * 12 / 100.
        ELSE.
          gs_vbrk-vatrate = '11'.
        ENDIF.
      ENDIF.
      "      PERFORM f_hitung_05 CHANGING lv_vat.
      IF gs_header-vbtyp = 'O' OR gs_header-vbtyp = '6'.  "Khusus proses yg Retur ( dikalikan -1 )
        lv_vat = abs( lv_vat ) * -1.
        lv_othertaxbase = abs( lv_othertaxbase )  * -1.
        lv_totaldiscount = abs( lv_totaldiscount ) * -1.
        lv_price = abs( lv_price ) * -1.
        lv_taxbase = abs( lv_taxbase ) * -1.
      ENDIF.

      gs_header_xml-total_taxbase = gs_header_xml-total_taxbase + lv_taxbase.
      gs_header_xml-total_vat = gs_header_xml-total_vat + lv_vat.
      gs_header_xml-total_diskon = gs_header_xml-total_diskon + lv_totaldiscount.

      gs_vbrk-vprice          = lv_price.
      gs_vbrk-vqty            = gs_vbrk-fkimg.
      gs_vbrk-vtotaldiscount  = lv_totaldiscount.
      gs_vbrk-vtaxbase        = lv_taxbase.
      gs_vbrk-vothertaxbase   = lv_othertaxbase.
      gs_vbrk-vvat            = lv_vat.

      WRITE lv_taxbase TO gs_vbrk-taxbase DECIMALS 2 NO-GROUPING NO-GAP.
      WRITE lv_price TO gs_vbrk-price DECIMALS 2 NO-GROUPING NO-GAP.
      WRITE lv_othertaxbase TO gs_vbrk-othertaxbase DECIMALS 2 NO-GROUPING NO-GAP.
      WRITE lv_vat TO gs_vbrk-vat DECIMALS 0 NO-GROUPING NO-GAP.
      "        WRITE gs_vbrk-fkimg TO gs_vbrk-qty DECIMALS 2 NO-GROUPING NO-GAP.
      IF p_bukrs = '8800'.
        WRITE lv_qty2 TO gs_vbrk-qty DECIMALS 2 NO-GROUPING NO-GAP.
      ELSE.
        WRITE lv_qty2 TO gs_vbrk-qty DECIMALS 0 NO-GROUPING NO-GAP.
      ENDIF.
      WRITE lv_totaldiscount TO gs_vbrk-totaldiscount DECIMALS 2 NO-GROUPING NO-GAP.
      CONDENSE: gs_vbrk-taxbase, gs_vbrk-price, gs_vbrk-othertaxbase,
                gs_vbrk-totaldiscount, gs_vbrk-qty, gs_vbrk-vat.

      REPLACE ALL OCCURRENCES OF ',' IN gs_vbrk-qty WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_vbrk-taxbase WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_vbrk-price WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_vbrk-othertaxbase WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_vbrk-vat WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_vbrk-totaldiscount WITH '.' .

      IF p_bukrs = '8800'.
        gs_vbrk-unit = 'UM.0033'.
      ELSE.
        gs_vbrk-unit = 'UM.0018'.
      ENDIF.
      IF p_bukrs = '8800'.
        lv_text1024 = gs_vbrk-arktx.
      ELSE.
        lv_text1024 = gs_vbrk-maktx.
      ENDIF.
      CALL FUNCTION 'ZTDSIT_F0004'
        EXPORTING
          ztextin  = lv_text1024
        IMPORTING
          ztextout = lv_text1024.
      gs_vbrk-name = lv_text1024.
      "      gs_vbrk-name = gs_vbrk-maktx.

      PERFORM f_modify_unit USING p_bukrs gs_vbrk-meins
                            CHANGING gs_vbrk-unit.

      MODIFY gt_vbrk FROM gs_vbrk.
      MOVE-CORRESPONDING gs_vbrk TO gs_detail_xml.
      IF p_bukrs = '8800'.
        gs_detail_xml-opt = 'B'.
      ELSE.
        gs_detail_xml-opt = 'A'.
      ENDIF.
      IF lv_opt IS NOT INITIAL.
        gs_detail_xml-opt =  lv_opt.
      ENDIF.
      IF lv_unit IS NOT INITIAL.
        gs_detail_xml-unit = lv_unit.
      ENDIF.
      IF lv_remark IS NOT INITIAL.
        CONCATENATE lv_remark gs_detail_xml-name INTO gs_detail_xml-name SEPARATED BY space.
      ENDIF.
      APPEND gs_detail_xml TO gt_detail_xml.
      CLEAR: gs_detail_xml.
      lv_sw = '1'.
    ENDLOOP.
    IF gs_header-gform = 'A3'.
      IF   gs_header_xml-total_taxbase >= 2000000.
        gs_header_xml-trxcode = '02'.
      ELSE.
        gs_header_xml-trxcode = '04'.
      ENDIF.
    ENDIF.
    IF gs_header-gform = 'A4'.
      lv_taxbase = gs_header_xml-total_taxbase + gs_header_xml-total_vat.
      IF lv_taxbase > 10000000.
        gs_header_xml-trxcode = '03'.
      ELSE.
        gs_header_xml-trxcode = '04'.
      ENDIF.
    ENDIF.
    IF gs_header_xml-fkdat IS INITIAL.
      gs_header_xml-fkdat = gs_header-txdat.
    ENDIF.
    "    MOVE-CORRESPONDING gs_header TO gs_header_xml.
    IF lv_sw = '1'.
      APPEND gs_header_xml TO gt_header_xml.
    ENDIF.
    MODIFY gt_header FROM gs_header.
    CLEAR: gs_header_xml, lv_sw.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA_8220
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_data_8220 .
  DATA: lv_price         TYPE vbrk-netwr, "p DECIMALS 4, "
        lv_totaldiscount TYPE vbrk-netwr, "p DECIMALS 4, "
        lv_taxbase       TYPE vbrk-netwr, "p DECIMALS 4, "
        lv_selisih       TYPE vbrk-netwr, "p DECIMALS 4, "
        lv_othertaxbase  TYPE vbrk-netwr, "p DECIMALS 4, "
        lv_vat           TYPE p DECIMALS 0. "vbrk-netwr.
  DATA: lv_text1024 TYPE text1024.
  DATA: lv_text(50).
  DATA: lv_len   TYPE i, lv_sw(1).
  DATA: lt_bseg TYPE STANDARD TABLE OF ty_bseg WITH HEADER LINE.

  REPLACE ALL OCCURRENCES OF '.' IN gs_zgdtxdt0005-nitku WITH '' .
  REPLACE ALL OCCURRENCES OF '-' IN gs_zgdtxdt0005-nitku WITH '' .
  LOOP AT gt_8220h INTO gs_8220h.
    CLEAR: gv_error, gv_message, lv_sw.

    MOVE-CORRESPONDING gs_8220h TO gs_header_xml.
    gs_header_xml-kunrg = gs_8220h-zzkunn2.
    gs_header_xml-vbeln = gs_8220h-bbill.
    gs_header_xml-fkdat = gs_8220h-bidat.
    CONCATENATE gs_8220h-bidat(4) '-' gs_8220h-bidat+4(2) '-' gs_8220h-bidat+6(2) INTO gs_header_xml-taxinvoicedate.
    gs_header_xml-taxinvoiceopt = 'Normal'.
    IF gs_8220h-vattrn IS INITIAL.
      gs_header_xml-trxcode = '04'.
    ELSE.
      gs_header_xml-trxcode = gs_8220h-vattrn. "'04'.
    ENDIF.
    IF p_check = 'X'.
      gs_header_xml-trxcode = '04'.
    ENDIF.
    IF p_bukrs = '8220'.
      gs_header_xml-vkbur = '2200'.
      CONCATENATE p_perio+4(2) p_perio+2(2) gs_8220h-bbill+2(6) INTO lv_text.
    ELSE.
      gs_header_xml-vkbur = '2100'.
      CONCATENATE 'KI' p_perio+4(2) p_perio+2(2) gs_8220h-bbill+4(4) INTO lv_text.
    ENDIF.
    gs_header_xml-vbeln = lv_text.

    CONCATENATE gs_header_xml-vkbur gs_8220h-zzkunn2 lv_text gv_namafile
         INTO gs_header_xml-refdesc SEPARATED BY space.
    gs_header_xml-selleridtku = gs_zgdtxdt0005-nitku.

    REPLACE ALL OCCURRENCES OF '.' IN gs_8220h-stcd1 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN gs_8220h-stcd1 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN gs_8220h-stcd6 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN gs_8220h-stcd6 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN gs_8220h-stcd3 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN gs_8220h-stcd3 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN gs_8220h-stcd5 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN gs_8220h-stcd5 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN gs_8220h-stceg WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN gs_8220h-stceg WITH '' .
    CONDENSE gs_8220h-stceg.
    lv_len = strlen( gs_8220h-stceg ).
    IF lv_len < 16.
      IF gs_8220h-stceg IS NOT INITIAL.
        CONCATENATE '0' gs_8220h-stceg INTO gs_8220h-stceg.
      ENDIF.
    ENDIF.
    IF gs_8220h-cityc = 'T0'.
      IF gs_8220h-stcd6 IS INITIAL.
        gs_8220h-stcd6 = '0000000000000000'.
        gs_8220h-stceg = 'Other ID'.
        gv_error = 'W'.
        gv_message = 'NITKU Buyer belum ada'.
        gs_header_xml-error = 'W'.
        gs_header_xml-icon = icon_yellow_light.
        gs_header_xml-mess_error = gv_message.
      ELSE.
        gs_8220h-stceg = 'National ID'.
      ENDIF.
      gs_header_xml-buyertin  = gs_8220h-stcd1.
      gs_header_xml-buyerdocumentnumber = gs_8220h-stcd6.
    ELSE.
      gs_8220h-stceg = 'TIN'.
      gs_header_xml-buyertin  = gs_8220h-stcd6.
      CLEAR: gs_8220h-stcd6, gs_header_xml-buyerdocumentnumber.
      IF gs_header_xml-buyertin IS INITIAL.
        gv_error = 'E'.
        gv_message = 'Buyer TIN belum ada, mohon cek master data'.
        gs_header_xml-icon = icon_red_light.
        gs_header_xml-error = 'E'.
        gs_header_xml-mess_error = gv_message.
      ENDIF.
    ENDIF.
    gs_header_xml-buyerdocument = gs_8220h-stceg.
    gs_header_xml-buyercountry = 'IDN'.
    "    gs_header_xml-buyerdocumentnumber = gs_8220h-stcd1.
    gs_header_xml-buyername = gs_8220h-name1.
    gs_header_xml-buyeridtku = gs_8220h-stcd5.
    CONCATENATE gs_8220h-street gs_8220h-str_suppl1 gs_8220h-str_suppl2 gs_8220h-str_suppl3 gs_8220h-city1
         INTO gs_header_xml-buyeradress SEPARATED BY space..

    lv_text1024 = gs_header_xml-buyeradress.
    CALL FUNCTION 'ZTDSIT_F0004'
      EXPORTING
        ztextin  = lv_text1024
      IMPORTING
        ztextout = lv_text1024.
    gs_header_xml-buyeradress = lv_text1024.

    gs_header_xml-buyeridtku = gs_8220h-stcd5.
    LOOP AT gt_8220d INTO gs_8220d WHERE bbill = gs_8220h-bbill AND bidat = gs_8220h-bidat.
      CLEAR: lv_totaldiscount, lv_vat, lv_price, lv_taxbase, lv_othertaxbase.

      MOVE-CORRESPONDING gs_8220d TO gs_detail_xml.
      gs_detail_xml-matnr = gs_8220d-matnr.
      gs_detail_xml-vbeln = gs_header_xml-vbeln.
      CLEAR: lv_totaldiscount, lv_vat, lv_price, lv_taxbase, lv_othertaxbase.
** Harga Satuan (Price), Tax, Taxbase (DPP) dihitung ulang kembali
      lv_totaldiscount = gs_8220d-hargasatuan *  gs_8220d-zzqty . " + gs_vbrk-kzwi6 ).
      lv_totaldiscount = abs( lv_totaldiscount ).
      lv_totaldiscount = lv_totaldiscount - gs_8220d-jumlah . " + gs_vbrk-kzwi6 ).
      lv_totaldiscount = abs( lv_totaldiscount ).
      lv_price = gs_8220d-hargasatuan .
      lv_taxbase = ( gs_8220d-jumlah ) .
      lv_othertaxbase = lv_taxbase.

      lv_taxbase = lv_taxbase * 100.
      lv_totaldiscount = lv_totaldiscount * 100.
      lv_price = lv_price * 100.

      lv_othertaxbase = lv_taxbase." * ( 11 / 12 ).
      lv_vat = abs( gs_8220d-zzppn * 100 ).
      "      PERFORM f_hitung_05 CHANGING lv_vat.
      gs_detail_xml-vatrate = '11'.
      IF p_check = 'X'.
        gs_detail_xml-vatrate = '12'.
        lv_othertaxbase = lv_taxbase * 11 / 12.
        lv_vat = lv_othertaxbase * 12 / 100.
      ELSE.
      ENDIF.
      gs_detail_xml-netwr = lv_taxbase / 100.
      gs_detail_xml-vprice          = lv_price.
      gs_detail_xml-vqty            = gs_8220d-zzqty.
      gs_detail_xml-vtotaldiscount  = lv_totaldiscount.
      gs_detail_xml-vtaxbase        = lv_taxbase.
      gs_detail_xml-vothertaxbase   = lv_othertaxbase.
      gs_detail_xml-vvat            = lv_vat.


      WRITE lv_taxbase TO gs_detail_xml-taxbase DECIMALS 2 NO-GROUPING NO-GAP.
      WRITE lv_price TO gs_detail_xml-price DECIMALS 2 NO-GROUPING NO-GAP.
      WRITE lv_othertaxbase TO gs_detail_xml-othertaxbase DECIMALS 2 NO-GROUPING NO-GAP.
      WRITE lv_vat TO gs_detail_xml-vat DECIMALS 0 NO-GROUPING NO-GAP.
      WRITE gs_8220d-zzqty TO gs_detail_xml-qty DECIMALS 0 NO-GROUPING NO-GAP.
      WRITE lv_totaldiscount TO gs_detail_xml-totaldiscount DECIMALS 2 NO-GROUPING NO-GAP.
      CONDENSE: gs_detail_xml-taxbase, gs_detail_xml-price, gs_detail_xml-othertaxbase,
                gs_detail_xml-totaldiscount, gs_detail_xml-qty, gs_detail_xml-vat.

      REPLACE ALL OCCURRENCES OF ',' IN gs_detail_xml-taxbase WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_detail_xml-price WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_detail_xml-othertaxbase WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_detail_xml-vat WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_detail_xml-totaldiscount WITH '.' .

      gs_detail_xml-unit = 'UM.0018'.
      lv_text1024 = gs_8220d-maktx.
      CALL FUNCTION 'ZTDSIT_F0004'
        EXPORTING
          ztextin  = lv_text1024
        IMPORTING
          ztextout = lv_text1024.
      gs_detail_xml-name = lv_text1024.
      gs_detail_xml-maktx = lv_text1024.
      "      MODIFY gt_vbrk FROM gs_vbrk.
      "     MOVE-CORRESPONDING gs_vbrk TO gs_detail_xml.
      APPEND gs_detail_xml TO gt_detail_xml.
      CLEAR: gs_detail_xml.
      lv_sw = '1'.
    ENDLOOP.
    "    MOVE-CORRESPONDING gs_header TO gs_header_xml.
    IF lv_sw = '1'.
      APPEND gs_header_xml TO gt_header_xml.
    ENDIF.
    CLEAR: gs_header_xml, lv_sw.
    "    MODIFY gt_header FROM gs_header.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA_SHIPMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_data_shipment .
  DATA: lv_price         TYPE vbrk-netwr, "p DECIMALS 4, "
        lv_totaldiscount TYPE vbrk-netwr, "p DECIMALS 4, "
        lv_taxbase       TYPE vbrk-netwr, "p DECIMALS 4, "
        lv_selisih       TYPE vbrk-netwr, "p DECIMALS 4, "
        lv_othertaxbase  TYPE vbrk-netwr, "p DECIMALS 4, "
        lv_vat           TYPE p DECIMALS 4. "vbrk-netwr.
  DATA: lv_text1024 TYPE text1024.
  DATA: lv_text(50).
  DATA: lv_len TYPE i.
  DATA: lt_lips TYPE STANDARD TABLE OF ty_lips WITH HEADER LINE.
  DATA: lt_vttk TYPE STANDARD TABLE OF ty_vttk. " WITH HEADER LINE.
  DATA: lv_hscode(15).
  DATA: lt_zcoretax0012 TYPE STANDARD TABLE OF zcoretax0012.
  DATA: ls_zcoretax0012 LIKE LINE OF lt_zcoretax0012.
  "  sort gt_lips  by
  IF p_bukrs = '8220'.
    SELECT * INTO TABLE lt_zcoretax0012 FROM zcoretax0012 WHERE bukrs = p_bukrs.
  ENDIF.


  SORT gt_vttk BY vbeln.
  SORT gt_lips BY vbeln.
  LOOP AT gt_vttk INTO gs_vttk.
    LOOP AT gt_lips INTO gs_lips WHERE vbeln = gs_vttk-vbeln.
      gs_lips-tknum = gs_vttk-tknum.
      CLEAR: gs_lips-vbeln, gs_lips-posnr.
      MODIFY gt_lips FROM gs_lips.
    ENDLOOP.
  ENDLOOP.
  SORT gt_lips BY tknum matnr.
  LOOP AT gt_lips INTO gs_lips. " INTO gs_lips.
    MOVE-CORRESPONDING gs_lips TO lt_lips.
    CLEAR: lt_lips-vbeln.
    COLLECT lt_lips.
  ENDLOOP.
  gt_lips[] = lt_lips[].
  SORT gt_lips BY matnr.
  SORT gt_a017 BY matnr.
  DATA: ls_a017 TYPE ty_a017.
  DATA: lv_err(1), lv_sw(1).
  DATA: ls_a934 TYPE ty_a934.
  LOOP AT gt_lips INTO gs_lips.
    SORT gt_a017 BY matnr datab.
    CLEAR: lv_err.
    LOOP AT gt_a017 INTO ls_a017 WHERE matnr = gs_lips-matnr.
      gs_lips-kbetr = ls_a017-kbetr.
      gs_lips-kpein = ls_a017-kpein.
      lv_err = '1'.
    ENDLOOP.
    IF lv_err NE '1'.
      CLEAR: lv_err.
      LOOP AT gt_a934 INTO ls_a934 WHERE matnr = gs_lips-matnr.
        gs_lips-kbetr = ls_a934-kbetr.
        gs_lips-kpein = ls_a934-kpein.
        lv_err = '1'.
      ENDLOOP.
    ENDIF.
    MODIFY gt_lips FROM gs_lips.
    CLEAR: gs_lips.
  ENDLOOP.
  SORT gt_vttk BY tknum.
  DELETE ADJACENT DUPLICATES FROM gt_vttk COMPARING tknum.
  LOOP AT gt_vttk INTO gs_vttk.
    CLEAR: lv_len.
    LOOP AT gt_lips INTO gs_lips WHERE tknum = gs_vttk-tknum.
      ADD 1 TO lv_len.
      EXIT.
    ENDLOOP.
    IF lv_len NE 0.
      APPEND gs_vttk TO  lt_vttk.
    ENDIF.
  ENDLOOP.
  gt_vttk[] = lt_vttk[].
  REPLACE ALL OCCURRENCES OF '.' IN gs_zgdtxdt0005-nitku WITH '' .
  REPLACE ALL OCCURRENCES OF '-' IN gs_zgdtxdt0005-nitku WITH '' .
  SORT gt_vttk BY tknum.
  SORT gt_lips BY tknum matnr.
  LOOP AT gt_vttk INTO gs_vttk.
    CLEAR: gv_error, gv_message, lv_sw.
    MOVE-CORRESPONDING gs_vttk TO gs_header_xml.
    gs_header_xml-bukrs = p_bukrs.
    gs_header_xml-kunrg = gs_vttk-kunnr.
    gs_header_xml-vbeln = gs_vttk-tknum.
    gs_header_xml-fkdat = gs_vttk-erdat.
    CONCATENATE gs_vttk-erdat(4) '-' gs_vttk-erdat+4(2) '-' gs_vttk-erdat+6(2) INTO gs_header_xml-taxinvoicedate.
    gs_header_xml-taxinvoiceopt = 'Normal'.
    gs_header_xml-trxcode = '07'.
    gs_header_xml-addinfo = '18'.
    IF p_bukrs = '8020'.
      gs_header_xml-vkbur = '0246'.
      CONCATENATE '0246' gv_namafileptt gs_vttk-tknum gs_vttk-kunnr   INTO gs_header_xml-refdesc SEPARATED BY space.
    ELSE.
      gs_header_xml-vkbur = '2200'.
      CONCATENATE '2200' gs_vttk-tknum gv_namafile INTO gs_header_xml-refdesc SEPARATED BY space.
    ENDIF.
    gs_header_xml-selleridtku = gs_zgdtxdt0005-nitku.
    REPLACE ALL OCCURRENCES OF '.' IN gs_vttk-stcd1 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN gs_vttk-stcd1 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN gs_vttk-stcd6 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN gs_vttk-stcd6 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN gs_vttk-stcd3 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN gs_vttk-stcd3 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN gs_vttk-stcd5 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN gs_vttk-stcd5 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN gs_vttk-stceg WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN gs_vttk-stceg WITH '' .
    CONDENSE gs_vttk-stceg.
    lv_len = strlen( gs_vttk-stceg ).
    IF lv_len < 16.
      IF gs_vttk-stceg IS NOT INITIAL.
        CONCATENATE '0' gs_vttk-stceg INTO gs_vttk-stceg.
      ENDIF.
    ENDIF.
    IF gs_vttk-cityc = 'T0'.
      IF gs_vttk-stcd6 IS INITIAL.
        gs_vttk-stcd6 = '0000000000000000'.
        gs_vttk-stceg = 'Other ID'.
        gv_error = 'W'.
        gv_message = 'NITKU Buyer belum ada'.
        gs_header_xml-error = 'W'.
        gs_header_xml-icon = icon_yellow_light.
        gs_header_xml-mess_error = gv_message.
      ELSE.
        gs_vttk-stceg = 'National ID'.
      ENDIF.
      gs_header_xml-buyertin  = gs_vttk-stcd1.
      gs_header_xml-buyerdocumentnumber = gs_vttk-stcd6.
    ELSE.
      gs_vttk-stceg = 'TIN'.
      gs_header_xml-buyertin  = gs_vttk-stcd6.
      CLEAR: gs_vttk-stcd6, gs_header_xml-buyerdocumentnumber.
      IF gs_header_xml-buyertin IS INITIAL.
        gv_error = 'E'.
        gv_message = 'Buyer TIN belum ada, mohon cek master data'.
        gs_header_xml-icon = icon_red_light.
        gs_header_xml-error = 'E'.
        gs_header_xml-mess_error = gv_message.
      ENDIF.
    ENDIF.
    gs_header_xml-buyerdocument = gs_vttk-stceg.
    gs_header_xml-buyercountry = 'IDN'.
    "    gs_header_xml-buyerdocumentnumber = gs_header-stcd6.
    gs_header_xml-buyername = gs_vttk-name_co.
    gs_header_xml-buyeridtku = gs_vttk-stcd5.
    CONCATENATE gs_vttk-str_suppl1 gs_vttk-str_suppl2 gs_vttk-str_suppl3 gs_vttk-location
         INTO gs_header_xml-buyeradress SEPARATED BY space..
    lv_text1024 = gs_header_xml-buyeradress.
    CALL FUNCTION 'ZTDSIT_F0004'
      EXPORTING
        ztextin  = lv_text1024
      IMPORTING
        ztextout = lv_text1024.
    gs_header_xml-buyeradress = lv_text1024.

    IF p_bukrs = '8220'.
      gs_header_xml-buyertin  = '013417753215001'.
      gs_header_xml-buyername = 'PT ERES REVCO'.
      gs_header_xml-buyeradress = 'KOMPLEK LOBINDO JL YOS SUDARSO NO 01 KAMPUNG SERAYA BATU AMPAR KOTA BATAM KEPULAUAN RIAU'.
      gs_header_xml-buyeridtku = '0013417753062000000013'.
    ENDIF.
    LOOP AT gt_lips INTO gs_lips WHERE tknum = gs_vttk-tknum.
      CLEAR: lv_totaldiscount, lv_vat, lv_price, lv_taxbase, lv_othertaxbase.
      MOVE-CORRESPONDING gs_lips TO gs_detail_xml.
      gs_detail_xml-matnr = gs_lips-matnr.
      gs_detail_xml-vbeln = gs_lips-tknum.
      CLEAR: lv_totaldiscount, lv_vat, lv_price, lv_taxbase, lv_othertaxbase.
      lv_price = ( gs_lips-kbetr / gs_lips-kpein ) * 100.
      IF p_bukrs = '8220'.
        PERFORM f_tax_calc USING gs_vttk-erdat p_perio lv_price 'G'
                         CHANGING lv_price.
      ENDIF.
      lv_taxbase =  lv_price * gs_lips-lfimg.
      lv_othertaxbase = lv_taxbase.
      lv_vat = lv_othertaxbase * 11 / 100.
      PERFORM f_hitung_05 CHANGING lv_vat.

      gs_detail_xml-vatrate = '11'.
      IF p_check = 'X'.
        gs_detail_xml-vatrate = '12'.
        lv_othertaxbase = lv_vat * 100 / 12.
      ELSE.
      ENDIF.

      gs_detail_xml-netwr = lv_taxbase / 100.
      gs_detail_xml-vprice          = lv_price.
      gs_detail_xml-vqty            = gs_lips-lfimg.
      gs_detail_xml-vtotaldiscount  = lv_totaldiscount.
      gs_detail_xml-vtaxbase        = lv_taxbase.
      gs_detail_xml-vothertaxbase   = lv_othertaxbase.
      gs_detail_xml-vvat            = lv_vat.

      WRITE lv_taxbase TO gs_detail_xml-taxbase DECIMALS 2 NO-GROUPING NO-GAP.
      WRITE lv_price TO gs_detail_xml-price DECIMALS 2 NO-GROUPING NO-GAP.
      WRITE lv_othertaxbase TO gs_detail_xml-othertaxbase DECIMALS 2 NO-GROUPING NO-GAP.
      WRITE lv_vat TO gs_detail_xml-vat DECIMALS 0 NO-GROUPING NO-GAP.
      WRITE gs_lips-lfimg TO gs_detail_xml-qty DECIMALS 0 NO-GROUPING NO-GAP.
      WRITE lv_totaldiscount TO gs_detail_xml-totaldiscount DECIMALS 2 NO-GROUPING NO-GAP.
      CONDENSE: gs_detail_xml-taxbase, gs_detail_xml-price, gs_detail_xml-othertaxbase,
                gs_detail_xml-totaldiscount, gs_detail_xml-qty, gs_detail_xml-vat.
      REPLACE ALL OCCURRENCES OF ',' IN gs_detail_xml-taxbase WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_detail_xml-price WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_detail_xml-othertaxbase WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_detail_xml-vat WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_detail_xml-totaldiscount WITH '.' .

      gs_detail_xml-unit = 'UM.0018'.
      lv_text1024 = gs_lips-maktx.
      CALL FUNCTION 'ZTDSIT_F0004'
        EXPORTING
          ztextin  = lv_text1024
        IMPORTING
          ztextout = lv_text1024.

      IF p_bukrs = '8020'.
        CONCATENATE gs_lips-stawn lv_text1024  INTO lv_text1024 SEPARATED BY ' - '.
      ELSE.
        CLEAR: lv_hscode.
        IF lt_zcoretax0012[] IS NOT INITIAL.
          SORT lt_zcoretax0012 BY bukrs mvgr5.
          READ TABLE lt_zcoretax0012 INTO ls_zcoretax0012
               WITH KEY bukrs = p_bukrs
                        mvgr5 = gs_lips-mvgr5
               BINARY SEARCH.
          IF sy-subrc EQ 0.
            lv_hscode = ls_zcoretax0012-hscode.
          ELSE.
            CLEAR: lv_hscode.
            gv_error = 'E'.
            gv_message = 'HS Code tidak ditemukan ditable ZCORETAX0012'.
            gs_header_xml-icon = icon_red_light.
            gs_header_xml-error = 'E'.
            gs_header_xml-mess_error = gv_message.
            gs_detail_xml-message_error = gv_message.
            gs_detail_xml-icon   = icon_red_light.
          ENDIF.
        ELSE.
          CLEAR: lv_hscode.
          gv_error = 'E'.
          gv_message = 'HS Code belum dimaintance di table ZCORETAX0012'.
          gs_header_xml-icon = icon_red_light.
          gs_header_xml-error = 'E'.
          gs_header_xml-mess_error = gv_message.
          gs_detail_xml-message_error = gv_message.
          gs_detail_xml-icon   = icon_red_light.
        ENDIF.
        CONDENSE lv_hscode.
        CONCATENATE lv_hscode lv_text1024  INTO lv_text1024 SEPARATED BY ' - '.
      ENDIF.
      gs_detail_xml-name = lv_text1024.
      gs_detail_xml-maktx = lv_text1024.
      APPEND gs_detail_xml TO gt_detail_xml.
      CLEAR: gs_lips.
      lv_sw = '1'.
    ENDLOOP.
    "    MOVE-CORRESPONDING gs_header TO gs_header_xml.
    IF lv_sw = '1'.
      APPEND gs_header_xml TO gt_header_xml.
    ENDIF.
    CLEAR: gs_vttk, gs_header_xml, lv_sw.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_05
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_VAT  text
*----------------------------------------------------------------------*
FORM f_hitung_05  CHANGING p_vat.
  DATA: lv_vat TYPE p DECIMALS 4.

  DATA: lv_value1 TYPE p DECIMALS 4.
  DATA: lv_value2 TYPE p DECIMALS 4.
  DATA: lv_bulat TYPE p DECIMALS 0.
  DATA: lv_hitung TYPE p DECIMALS 4.

  lv_vat = p_vat.
  lv_hitung = abs( 5 / 10 ).
  lv_bulat = lv_vat.
  lv_value1 = abs( lv_bulat - lv_vat ).
  IF lv_value1 = lv_hitung.
    lv_vat = lv_vat - lv_value1.
  ENDIF.
  p_vat = lv_vat.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA_FI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_data_fi .
  DATA: lt_nontrade TYPE STANDARD TABLE OF ty_nontrade WITH HEADER LINE.
  DATA: lt_detail_nontrade TYPE STANDARD TABLE OF ty_detail_nontrade WITH HEADER LINE..
  DATA: ls_nontrade TYPE  ty_nontrade.
  DATA: ls_detail_nontrade TYPE ty_detail_nontrade.
  DATA: ls_detail_nontrade1 TYPE ty_detail_nontrade.
  DATA: ls_detail_nontrade2 TYPE ty_detail_nontrade.
  DATA: lv_price         TYPE vbrk-netwr, "p DECIMALS 4, "
        lv_totaldiscount TYPE vbrk-netwr, "p DECIMALS 4, "
        lv_taxbase       TYPE vbrk-netwr, "p DECIMALS 4, "
        lv_selisih       TYPE vbrk-netwr, "p DECIMALS 4, "
        lv_othertaxbase  TYPE vbrk-netwr, "p DECIMALS 4, "
        lv_vat           TYPE p DECIMALS 0. "vbrk-netwr.
  DATA: lv_text1024 TYPE text1024.
  DATA: lv_text(50).
  DATA: lv_len TYPE i.
  DATA: lv_sw(1).
  DATA: lt_lips TYPE STANDARD TABLE OF ty_lips WITH HEADER LINE.
  DATA: lt_vttk TYPE STANDARD TABLE OF ty_vttk. " WITH HEADER LINE.
  DATA: BEGIN OF lt_zrevtr001 OCCURS 0,
          invno   TYPE zrevtr001-invno,
          linno   TYPE zrevtr001-linno,
          postdoc TYPE zrevtr001-postdoc,
          revtyp  TYPE zrevtr001-revtyp,
          ratetyp TYPE zrevtr001-ratetyp,
          ratetxt TYPE zratetr001-ratetxt,
        END OF  lt_zrevtr001.


***** DMBTR Customer
  CLEAR: lt_detail_nontrade[].
  LOOP AT gt_detail_nontrade INTO ls_detail_nontrade.
    CLEAR: ls_detail_nontrade-buzei.
    MOVE-CORRESPONDING ls_detail_nontrade TO lt_detail_nontrade.
    COLLECT lt_detail_nontrade.
  ENDLOOP.
  gt_detail_nontrade[] = lt_detail_nontrade[].

**** DMBTR Nilai lainnya
  CLEAR: lt_detail_nontrade[].
  LOOP AT gt_detail_nontrade2 INTO ls_detail_nontrade.
    CLEAR: ls_detail_nontrade-buzei, ls_detail_nontrade-hkont.
    MOVE-CORRESPONDING ls_detail_nontrade TO lt_detail_nontrade.
    COLLECT lt_detail_nontrade.
  ENDLOOP.
  gt_detail_nontrade2[] = lt_detail_nontrade[].

**** DMBTR nilai taxnya (VAT)
  CLEAR: lt_detail_nontrade[].
  LOOP AT gt_detail_nontrade1 INTO ls_detail_nontrade.
    CLEAR: ls_detail_nontrade-buzei, ls_detail_nontrade-hkont.
    MOVE-CORRESPONDING ls_detail_nontrade TO lt_detail_nontrade.
    COLLECT lt_detail_nontrade.
  ENDLOOP.
  gt_detail_nontrade1[] = lt_detail_nontrade[].
  IF gt_detail_nontrade5[] IS NOT INITIAL. " AND p_bukrs = '8140'.
    IF p_bukrs = '8140'.
      SELECT a~invno linno postdoc a~revtyp a~ratetyp b~ratetxt
        INTO CORRESPONDING FIELDS OF TABLE lt_zrevtr001
        FROM zrevtr001 AS a JOIN zratetr001 AS b ON a~bukrs = b~bukrs
                                                AND a~gjahr = b~gjahr
                                                AND a~revtyp = b~revtyp
                                                AND a~ratetyp = b~ratetyp
        FOR ALL ENTRIES IN gt_detail_nontrade5
        WHERE a~bukrs = p_bukrs
           AND a~invno = gt_detail_nontrade5-sgtxt
           AND postdoc = gt_detail_nontrade5-belnr
           AND postyear = gt_detail_nontrade5-gjahr.
    ELSEIF p_bukrs = '8160'.
      SELECT a~invno, linno, postdoc_tnt AS postdoc, a~revtyp, a~ratetyp, b~ratetxt
        INTO CORRESPONDING FIELDS OF TABLE @lt_zrevtr001
        FROM zrevtr001 AS a JOIN zratetr001 AS b ON a~bukrs = '8140'
                                                AND a~gjahr = b~gjahr
                                                AND a~revtyp = '04'
                                                AND a~ratetyp = b~ratetyp
        FOR ALL ENTRIES IN @gt_detail_nontrade5
        WHERE a~bukrs = '8140'
           AND a~invno = @gt_detail_nontrade5-sgtxt
           AND postdoc_tnt = @gt_detail_nontrade5-belnr
           AND postyear_tnt = @gt_detail_nontrade5-gjahr.
    ENDIF.
  ENDIF.
  DATA: lv_text1 TYPE zrevtr001-linno,
        lv_text2 TYPE zrevtr001-ratetyp.
  CLEAR: lt_detail_nontrade[].
  SORT gt_detail_nontrade5 BY bukrs gjahr belnr.
  LOOP AT gt_detail_nontrade5 INTO ls_detail_nontrade.
    CLEAR: ls_detail_nontrade-buzei.
    LOOP AT lt_zrevtr001 WHERE postdoc = ls_detail_nontrade-belnr AND invno = ls_detail_nontrade-sgtxt.
      SPLIT ls_detail_nontrade-zuonr AT '-' INTO lv_text1 lv_text2.
      CONDENSE: lv_text1, lv_text2.
      IF lt_zrevtr001-linno = lv_text1 AND lt_zrevtr001-ratetyp = lv_text2.
        ls_detail_nontrade-sgtxt = lt_zrevtr001-ratetxt.
        ls_detail_nontrade-name = lt_zrevtr001-ratetxt.
      ENDIF.
    ENDLOOP.
    MOVE-CORRESPONDING ls_detail_nontrade TO lt_detail_nontrade.
    CLEAR: lt_detail_nontrade-zuonr.
    COLLECT lt_detail_nontrade.
  ENDLOOP.
  gt_detail_nontrade5[] = lt_detail_nontrade[].

  IF gt_detail_nontrade5[] IS NOT INITIAL.
    gt_detail_nontrade[] = gt_detail_nontrade5[].
    LOOP AT gt_detail_nontrade INTO ls_detail_nontrade.
      ls_detail_nontrade-taxbase = ls_detail_nontrade-dmbtr.
***      IF p_bukrs NE '8020' AND p_bukrs = '8070'.
***        PERFORM f_tax_calc USING '' p_perio ls_detail_nontrade-taxbase 'E'
***                         CHANGING ls_detail_nontrade-vat.
***      ENDIF.
      MODIFY gt_detail_nontrade FROM ls_detail_nontrade TRANSPORTING taxbase vat. " name.
      CLEAR: ls_detail_nontrade.
    ENDLOOP.
  ENDIF..
  LOOP AT gt_detail_nontrade INTO ls_detail_nontrade.
    ls_detail_nontrade-taxbase = ls_detail_nontrade-dmbtr.
    IF ls_detail_nontrade-name IS INITIAL.
      ls_detail_nontrade-name = ls_detail_nontrade-sgtxt.
    ENDIF.
    LOOP AT gt_detail_nontrade1 INTO ls_detail_nontrade1 WHERE belnr = ls_detail_nontrade-belnr AND gjahr = ls_detail_nontrade-gjahr.
      IF p_bukrs = '8140' OR p_bukrs = '8160'.
        ls_detail_nontrade-taxbase = ls_detail_nontrade-taxbase.
        ls_detail_nontrade-vat = ls_detail_nontrade-taxbase * ( 11 / 100 ).
      ELSE.
        ls_detail_nontrade-taxbase = ls_detail_nontrade-taxbase - ls_detail_nontrade1-dmbtr.
        ls_detail_nontrade-vat = ls_detail_nontrade-vat + ls_detail_nontrade1-dmbtr.
      ENDIF.
    ENDLOOP.
    LOOP AT gt_detail_nontrade2 INTO ls_detail_nontrade2 WHERE belnr = ls_detail_nontrade-belnr AND gjahr = ls_detail_nontrade-gjahr.
      IF ls_detail_nontrade2-shkzg = 'S'.
        ls_detail_nontrade-taxbase = ls_detail_nontrade-taxbase + ls_detail_nontrade2-dmbtr.
      ELSE.
        ls_detail_nontrade-taxbase = ls_detail_nontrade-taxbase - ls_detail_nontrade2-dmbtr.
      ENDIF.
    ENDLOOP.
    MODIFY gt_detail_nontrade FROM ls_detail_nontrade TRANSPORTING taxbase vat name.
    CLEAR: ls_detail_nontrade.
  ENDLOOP.
  "  ENDIF.

  REPLACE ALL OCCURRENCES OF '.' IN gs_zgdtxdt0005-nitku WITH '' .
  REPLACE ALL OCCURRENCES OF '-' IN gs_zgdtxdt0005-nitku WITH '' .

  LOOP AT gt_nontrade INTO ls_nontrade.
    CLEAR: lv_sw, gv_error, gv_message.
    MOVE-CORRESPONDING ls_nontrade TO gs_header_xml.
    gs_header_xml-fkdat = ls_nontrade-budat.
    CONCATENATE gs_header_xml-fkdat(4) '-' gs_header_xml-fkdat+4(2) '-' gs_header_xml-fkdat+6(2) INTO gs_header_xml-taxinvoicedate.
    gs_header_xml-taxinvoiceopt = 'Normal'.
    gs_header_xml-trxcode = '04'.
    SORT gt_detail_nontrade4 BY bukrs belnr gjahr.
    READ TABLE gt_detail_nontrade4 INTO ls_detail_nontrade
    WITH KEY bukrs = ls_nontrade-bukrs
             belnr = ls_nontrade-belnr
             gjahr = ls_nontrade-gjahr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF ls_detail_nontrade-koart = 'A' AND ls_detail_nontrade-bschl = '75'.
        gs_header_xml-trxcode = '09'.
      ENDIF.
    ENDIF.
    CLEAR: ls_detail_nontrade.
    gs_header_xml-vkbur = ls_nontrade-gsber.
    gs_header_xml-bukrs = ls_nontrade-bukrs.
    IF p_bukrs = '8020' OR p_bukrs = '8070'.
      CONCATENATE gs_header_xml-vkbur gv_namafileptt  ls_nontrade-belnr  ls_nontrade-kunnr
         INTO gs_header_xml-refdesc SEPARATED BY space.
    ELSE.
      CONCATENATE gs_header_xml-vkbur gv_namafile ls_nontrade-belnr ls_nontrade-kunnr
         INTO gs_header_xml-refdesc SEPARATED BY space.
    ENDIF.
    gs_header_xml-selleridtku = gs_zgdtxdt0005-nitku.
    REPLACE ALL OCCURRENCES OF '.' IN ls_nontrade-stcd1 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN ls_nontrade-stcd1 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN ls_nontrade-stcd6 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN ls_nontrade-stcd6 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN ls_nontrade-stcd3 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN ls_nontrade-stcd3 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN ls_nontrade-stcd5 WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN ls_nontrade-stcd5 WITH '' .
    REPLACE ALL OCCURRENCES OF '.' IN ls_nontrade-stceg WITH '' .
    REPLACE ALL OCCURRENCES OF '-' IN ls_nontrade-stceg WITH '' .
    CONDENSE ls_nontrade-stceg.
    lv_len = strlen( ls_nontrade-stceg ).
    IF lv_len < 16.
      IF ls_nontrade-stceg IS NOT INITIAL.
        CONCATENATE '0' ls_nontrade-stceg INTO ls_nontrade-stceg.
      ENDIF.
    ENDIF.
    IF ls_nontrade-cityc = 'T0'.
      IF ls_nontrade-stcd6 IS INITIAL.
        ls_nontrade-stceg = 'Other ID'.
        ls_nontrade-stcd6 = '0000000000000000'.
        gs_header_xml-buyerdocumentnumber = '0000000000000000'.
        gv_error = 'W'.
        gv_message = 'NITKU Buyer belum ada'.
        gs_header_xml-error = 'W'.
        gs_header_xml-icon = icon_yellow_light.
        gs_header_xml-mess_error = gv_message.
      ELSE.
        ls_nontrade-stceg = 'National ID'.
        gs_header_xml-buyerdocumentnumber = ls_nontrade-stcd6.
      ENDIF.
      gs_header_xml-buyertin  = '0000000000000000'. "gs_header-stcd1.
    ELSE.
      ls_nontrade-stceg = 'TIN'.
      gs_header_xml-buyertin  = ls_nontrade-stcd6.
      CLEAR: ls_nontrade-stcd6, gs_header_xml-buyerdocumentnumber.
      IF gs_header_xml-buyertin IS INITIAL.
        gv_error = 'E'.
        gv_message = 'Buyer TIN belum ada, mohon cek master data'.
        gs_header_xml-icon = icon_red_light.
        gs_header_xml-error = 'E'.
        gs_header_xml-mess_error = gv_message.
      ENDIF.
    ENDIF.
    gs_header_xml-buyerdocument = ls_nontrade-stceg.
    gs_header_xml-buyercountry = 'IDN'.
    "    gs_header_xml-buyerdocumentnumber = gs_header-stcd6.
    gs_header_xml-buyername = ls_nontrade-name_co.
    gs_header_xml-buyeridtku = ls_nontrade-stcd5.
    CONCATENATE ls_nontrade-str_suppl1 ls_nontrade-str_suppl2 ls_nontrade-str_suppl3 ls_nontrade-location
         INTO gs_header_xml-buyeradress SEPARATED BY  space.

    lv_text1024 = gs_header_xml-buyeradress.
    CALL FUNCTION 'ZTDSIT_F0004'
      EXPORTING
        ztextin  = lv_text1024
      IMPORTING
        ztextout = lv_text1024.
    gs_header_xml-buyeradress = lv_text1024.


    gs_header_xml-buyeridtku = ls_nontrade-stcd5.
    gs_header_xml-vbeln = ls_nontrade-belnr.
    "    gs_header_xml-zuonr = ls_nontrade-zuonr.
    gs_header_xml-bukrs =  ls_nontrade-bukrs.
    CLEAR: gs_header_xml-total_taxbase, gs_header_xml-total_vat, gs_header_xml-total_diskon.


    LOOP AT gt_detail_nontrade INTO ls_detail_nontrade WHERE belnr = ls_nontrade-belnr AND gjahr = ls_nontrade-gjahr.
      CLEAR: lv_totaldiscount, lv_vat, lv_price, lv_taxbase, lv_othertaxbase.

      MOVE-CORRESPONDING ls_detail_nontrade TO gs_detail_xml.
      IF gs_header_xml-vkbur IS INITIAL.
        gs_header_xml-vkbur = ls_detail_nontrade-gsber.
        CONCATENATE gs_header_xml-vkbur ls_nontrade-kunnr ls_nontrade-belnr  gv_namafile
           INTO gs_header_xml-refdesc SEPARATED BY space.
      ENDIF.
      gs_detail_xml-vbeln = gs_header_xml-vbeln.

      CLEAR: lv_totaldiscount, lv_vat, lv_price, lv_taxbase, lv_othertaxbase.

      "      lv_vat = abs( ls_detail_nontrade-wrbtr ).
      IF p_bukrs NE '8020' AND p_bukrs = '8070'.
        PERFORM f_tax_calc USING ls_nontrade-budat p_perio ls_detail_nontrade-taxbase 'E'
                         CHANGING ls_detail_nontrade-vat.
      ENDIF.

      lv_taxbase = abs( ls_detail_nontrade-taxbase )..
      lv_price = lv_taxbase.

      lv_taxbase = lv_taxbase * 100.
      lv_totaldiscount = lv_totaldiscount * 100.
      lv_price = lv_price * 100.
      lv_othertaxbase = lv_taxbase. " * ( 11 / 12 ).
      lv_vat = ls_detail_nontrade-vat * 100.

      lv_vat = abs( lv_vat ).
      "      PERFORM f_hitung_05 CHANGING lv_vat.
      gs_detail_xml-vatrate = '11'.
      IF p_check = 'X'.
        gs_detail_xml-vatrate = '12'.
        lv_othertaxbase = lv_taxbase * 11 / 12.
      ELSE.
      ENDIF.
      gs_detail_xml-netwr = lv_taxbase / 100.
      gs_detail_xml-vprice          = lv_price.
      gs_detail_xml-vqty            = 1.
      gs_detail_xml-vtotaldiscount  = lv_totaldiscount.
      gs_detail_xml-vtaxbase        = lv_taxbase.
      gs_detail_xml-vothertaxbase   = lv_othertaxbase.
      gs_detail_xml-vvat            = lv_vat.

      gs_detail_xml-qty = 1.
      WRITE lv_taxbase TO gs_detail_xml-taxbase DECIMALS 2 NO-GROUPING NO-GAP.
      WRITE lv_price TO gs_detail_xml-price DECIMALS 2 NO-GROUPING NO-GAP.
      WRITE lv_othertaxbase TO gs_detail_xml-othertaxbase DECIMALS 2 NO-GROUPING NO-GAP.
      WRITE lv_vat TO gs_detail_xml-vat DECIMALS 0 NO-GROUPING NO-GAP.
      WRITE lv_totaldiscount TO gs_detail_xml-totaldiscount DECIMALS 2 NO-GROUPING NO-GAP.
      CONDENSE: gs_detail_xml-taxbase, gs_detail_xml-price, gs_detail_xml-othertaxbase,
                gs_detail_xml-totaldiscount, gs_detail_xml-qty, gs_detail_xml-vat.

      REPLACE ALL OCCURRENCES OF ',' IN gs_detail_xml-taxbase WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_detail_xml-price WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_detail_xml-othertaxbase WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_detail_xml-vat WITH '.' .
      REPLACE ALL OCCURRENCES OF ',' IN gs_detail_xml-totaldiscount WITH '.' .

      gs_detail_xml-unit = 'UM.0018'.
      IF ls_detail_nontrade-name IS NOT INITIAL.
        lv_text1024 = ls_detail_nontrade-name.
      ELSE.
        lv_text1024 = ls_detail_nontrade-sgtxt.
      ENDIF.
      CALL FUNCTION 'ZTDSIT_F0004'
        EXPORTING
          ztextin  = lv_text1024
        IMPORTING
          ztextout = lv_text1024.
      gs_detail_xml-name = lv_text1024.
      gs_detail_xml-maktx = lv_text1024.
      APPEND gs_detail_xml TO gt_detail_xml.
      CLEAR: gs_detail_xml.
      lv_sw ='1'.
    ENDLOOP.
    IF lv_sw ='1'.
      APPEND gs_header_xml TO gt_header_xml.
    ENDIF.
    CLEAR:gs_header_xml, lv_sw.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_TAX_CALC
*&---------------------------------------------------------------------*
FORM f_tax_calc  USING    fu_datum fu_mastx fu_wrbtr fu_calty
                 CHANGING fc_wrbtr.
  DATA : lv_wrbtr TYPE netwr_ak,
         lv_datum TYPE sy-datum.

  lv_wrbtr  = fu_wrbtr.
  lv_datum  = fu_datum.

  CALL FUNCTION 'Z_PPN11'
    EXPORTING
      pi_wrbtr = lv_wrbtr
      pi_calty = fu_calty
      pi_datum = lv_datum
      pi_mastx = fu_mastx
    IMPORTING
      po_wrbtr = lv_wrbtr.

  fc_wrbtr  = lv_wrbtr.
ENDFORM.                    " F_TAX_CALC

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_UNIT
*&---------------------------------------------------------------------*
FORM f_modify_unit  USING    fu_bukrs fu_meins
                    CHANGING fc_unit.
  IF fc_unit = 'UM.0018'.
    CASE fu_bukrs.
      WHEN '8160'.
        SELECT SINGLE unit_coretax INTO fc_unit
          FROM zcoretax0013 WHERE meins = fu_meins.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.
ENDFORM.
