*----------------------------------------------------------------------*
***INCLUDE LZTIAM_IDOCF02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_JSON_PRTIAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_STR  text
*      <--P_GS_EBAN  text
*----------------------------------------------------------------------*
FORM f_convert_json_prtiam  USING    p_str
                            CHANGING p_eban.
  DATA:   lv_json_data     TYPE string. ",
  lv_json_data = p_str.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = p_eban ).


ENDFORM.                    " F_CONVERT_JSON_PRTIAM
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_PR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_EBAN  text
*----------------------------------------------------------------------*
FORM f_proses_pr  USING p_eban TYPE tpr CHANGING p_return p_message.
  DATA: l_gl_account TYPE numc10, l_sakto(10), zbukrs1(4)..
  DATA: i_ebkn TYPE t_ebkn OCCURS 0,
        wa_ebkn TYPE t_ebkn,
        i_zeban TYPE t_zeban OCCURS 0,
        wa_zeban TYPE t_zeban.
  DATA: BEGIN OF t_bukrs OCCURS 0,
          bukrs1(4),
          bukrs2(4),
        END OF t_bukrs.

  DATA: ls_eban TYPE t_pr.
  DATA: gt_tvarvc TYPE STANDARD TABLE OF tvarvc.
  DATA: gs_tvarvc TYPE tvarvc.
  SELECT * INTO TABLE gt_tvarvc FROM tvarvc WHERE name = 'ZTIAM_IT003'.
  IF sy-subrc EQ 0.
    LOOP AT gt_tvarvc INTO gs_tvarvc.
      CONDENSE: gs_tvarvc-low, gs_tvarvc-high.
      t_bukrs-bukrs1 = gs_tvarvc-low.
      t_bukrs-bukrs2 = gs_tvarvc-high.
      APPEND t_bukrs.
    ENDLOOP.
  ENDIF.
  gv_sw = '1'.
  REFRESH:   t_e1bpmereqheader, t_e1bpmereqheaderx ,t_e1bpmereqitem , t_e1bpmereqitemx , t_e1bpmereqitemimp ,
          t_e1bpmereqaccount, t_e1bpmereqaccountx, t_e1bpmereqheadtext, t_e1bpmereqitemtext, t_e1preqcr1.
  CLEAR:   t_e1bpmereqheader, t_e1bpmereqheaderx ,t_e1bpmereqitem , t_e1bpmereqitemx , t_e1bpmereqitemimp ,
          t_e1bpmereqaccount, t_e1bpmereqaccountx, t_e1bpmereqheadtext, t_e1bpmereqitemtext, t_e1preqcr1.
  "SORT i_tpr BY banfn bnfpo.

  LOOP AT p_eban-result INTO ls_eban.
    CONDENSE: ls_eban-bnfpo, ls_eban-banfn.
    CONDENSE: ls_eban-menge, ls_eban-peinh, ls_eban-preis.
    ON CHANGE OF ls_eban-banfn.
      IF gv_sw = '1'.
        gv_sw = '2'.
      ELSE.
        PERFORM f_proses_idoc CHANGING p_return p_message.
      ENDIF.
      REFRESH: t_e1bpmereqheader, t_e1bpmereqheaderx ,t_e1bpmereqitem , t_e1bpmereqitemx , t_e1bpmereqitemimp,
               t_e1bpmereqaccount, t_e1bpmereqaccountx, t_e1bpmereqheadtext, t_e1bpmereqitemtext, t_e1preqcr1.
      CLEAR:   t_e1bpmereqheader, t_e1bpmereqheaderx ,t_e1bpmereqitem , t_e1bpmereqitemx , t_e1bpmereqitemimp,
               t_e1bpmereqaccount, t_e1bpmereqaccountx, t_e1bpmereqheadtext, t_e1bpmereqitemtext, t_e1preqcr1, gv_banfn.
    ENDON.
    gv_banfn = ls_eban-banfn.
    gv_filename = ls_eban-banfn. "'Event.txt'.
    CONCATENATE '/tiam/inbound/' gv_filename INTO gv_fullfile.
    "    gs_edi_dc40-refint = gv_filename.
    "IF sy-tabix = 1.
    t_e1bpmereqheader-preq_no    = ls_eban-banfn.
    t_e1bpmereqheader-pr_type = ls_eban-bsart.
    APPEND t_e1bpmereqheader.

    t_e1bpmereqheaderx-preq_no    = 'X'. "wa_tpr-BANFN.
    t_e1bpmereqheaderx-pr_type = 'X'. "wa_tpr-BSART.
    APPEND t_e1bpmereqheaderx.
    "ENDIF.

    t_e1bpmereqitemimp-preq_item = ls_eban-bnfpo.
    t_e1bpmereqitemimp-pur_group = ls_eban-ekgrp.
    t_e1bpmereqitemimp-short_text = ls_eban-txz01.
    t_e1bpmereqitemimp-preq_name = ls_eban-aenam.
    IF ls_eban-matnr IS NOT INITIAL.
      t_e1bpmereqitemimp-material = ls_eban-matnr.
    ENDIF.
    CONDENSE: ls_eban-zwerks, ls_eban-werks.
    IF ls_eban-zwerks IS NOT INITIAL.
      IF ls_eban-zwerks <> ls_eban-werks.
        zbukrs1 = ls_eban-zbukrs.
        READ TABLE t_bukrs WITH KEY bukrs1 = zbukrs1 BINARY SEARCH.
        IF sy-subrc EQ 0.
          t_e1bpmereqitemimp-preq_name = t_bukrs-bukrs2.
        ELSE.
          t_e1bpmereqitemimp-preq_name = ls_eban-zbukrs.
        ENDIF.
        t_e1bpmereqitemimp-trackingno = ls_eban-werks.
        t_e1bpmereqitem-preq_name = ls_eban-zbukrs.
        t_e1bpmereqitem-trackingno = ls_eban-werks.
        t_e1bpmereqitemx-preq_name = 'X'.
        t_e1bpmereqitemx-trackingno = 'X'.
      ENDIF.
      ls_eban-werks = ls_eban-zwerks.
    ENDIF.
    t_e1bpmereqitemimp-plant    = ls_eban-werks. "'0202'.
    t_e1bpmereqitemimp-matl_group = ls_eban-matkl.
    t_e1bpmereqitemimp-quantity = ls_eban-menge.
    CONDENSE ls_eban-meins.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = ls_eban-meins
      IMPORTING
        output         = t_e1bpmereqitemimp-unit
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF t_e1bpmereqitemimp-unit IS INITIAL.
      t_e1bpmereqitemimp-unit = ls_eban-meins.
    ENDIF.
    CONCATENATE ls_eban-badat(4) ls_eban-badat+5(2) ls_eban-badat+8(2)
       INTO  t_e1bpmereqitemimp-preq_date.
    IF ls_eban-matnr IS NOT INITIAL.
      t_e1bpmereqitemimp-material = ls_eban-matnr.
    ENDIF.
    CONCATENATE ls_eban-lfdat(4) ls_eban-lfdat+5(2) ls_eban-lfdat+8(2)
       INTO t_e1bpmereqitemimp-deliv_date. "lv_lfdat.
    t_e1bpmereqitemimp-preq_price = ls_eban-peinh. "ls_eban-preis.
    t_e1bpmereqitemimp-acctasscat = ls_eban-knttp. "'A'. "default hrs 'A' ls_eban-knttp.
    t_e1bpmereqitemimp-gr_ind = 'X'. "default hrs 'X' ls_eban-wepos.
    t_e1bpmereqitemimp-ir_ind = 'X'. "default hrs 'X'ls_eban-repos.
    t_e1bpmereqitemimp-purch_org = ls_eban-ekorg.
    APPEND t_e1bpmereqitemimp.
    t_e1bpmereqitemx-preq_item = ls_eban-bnfpo. "'00010'. "ls_eban-bnfpo.
    t_e1bpmereqitemx-pur_group = 'X'. "ls_eban-ekgrp.
    t_e1bpmereqitemx-short_text = 'X'. "ls_eban-txz01.
    t_e1bpmereqitemx-plant = 'X'. "ls_eban-werks.
    t_e1bpmereqitemx-matl_group = 'X'. "ls_eban-matkl.
    t_e1bpmereqitemx-quantity = 'X'. "ls_eban-menge.
    t_e1bpmereqitemx-unit = 'X'. "ls_eban-meins.
    t_e1bpmereqitemx-preq_date = 'X'. "ls_eban-badat.
    t_e1bpmereqitemx-deliv_date  = 'X'. "ls_eban-lfdat
    t_e1bpmereqitemx-preq_price = 'X'. "ls_eban-preis.
    t_e1bpmereqitemx-acctasscat = 'X'. "ls_eban-knttp.
    t_e1bpmereqitemx-purch_org = 'X'. "ls_eban-ekorg.
    t_e1bpmereqitemx-gr_ind = 'X'. "ls_eban-wepos.
    t_e1bpmereqitemx-ir_ind = 'X'. "ls_eban-repos.
    t_e1bpmereqitemx-distrib = 'X'.
    t_e1bpmereqitemx-part_inv = 'X'.
    IF ls_eban-matnr IS NOT INITIAL.
      t_e1bpmereqitemx-material = 'X'.
    ENDIF.
    APPEND t_e1bpmereqitemx.

    t_e1bpmereqitem-preq_item = ls_eban-bnfpo.
    t_e1bpmereqitem-doc_type = ls_eban-bsart.
    t_e1bpmereqitem-pur_group = ls_eban-ekgrp.
    t_e1bpmereqitem-created_by = ls_eban-ernam.
    t_e1bpmereqitem-short_text = ls_eban-txz01.
    t_e1bpmereqitem-plant = ls_eban-werks.
    t_e1bpmereqitem-matl_group = ls_eban-matkl.
    t_e1bpmereqitem-quantity = ls_eban-menge.
    CONDENSE ls_eban-meins.
    IF ls_eban-meins = 'PC'.
      ls_eban-meins = 'ST'.
    ENDIF.
    "    t_e1bpmereqitemimp-unit = ls_eban-meins.
    t_e1bpmereqitem-unit = t_e1bpmereqitemimp-unit. "ls_eban-meins.

    CONCATENATE ls_eban-badat(4) ls_eban-badat+5(2) ls_eban-badat+8(2)
       INTO  t_e1bpmereqitem-preq_date. " = sy-datum. "ls_eban-badat.

    CONCATENATE ls_eban-lfdat(4) ls_eban-lfdat+5(2) ls_eban-lfdat+8(2)
       INTO t_e1bpmereqitem-deliv_date. "lv_lfdat.

    t_e1bpmereqitem-preq_price = ls_eban-peinh.
    t_e1bpmereqitem-acctasscat = ls_eban-knttp. "'A'. "ls_eban-knttp.
    t_e1bpmereqitem-gr_ind = 'X'. "ls_eban-wepos.
    t_e1bpmereqitem-ir_ind = 'X'. "ls_eban-repos.
    t_e1bpmereqitem-purch_org = ls_eban-ekorg.
    t_e1bpmereqitem-distrib = '1'.
    t_e1bpmereqitem-part_inv = '2'.

    APPEND t_e1bpmereqitem.
    LOOP AT ls_eban-ebkn INTO wa_ebkn  WHERE  banfn = ls_eban-banfn AND bnfpo  = ls_eban-bnfpo.
      CONDENSE: wa_ebkn-bnfpo, wa_ebkn-zebkn.
      CONDENSE: wa_ebkn-bnfpo, wa_ebkn-zebkn, wa_ebkn-menge, wa_ebkn-anln1, wa_ebkn-anln2, wa_ebkn-ablad.

      t_e1bpmereqaccount-preq_item = wa_ebkn-bnfpo.
      t_e1bpmereqaccount-serial_no = wa_ebkn-zebkn.
      CONCATENATE wa_ebkn-erdat(4) wa_ebkn-erdat+5(2) wa_ebkn-erdat+8(2) INTO
        t_e1bpmereqaccount-creat_date. " = sy-datum. "wa_ebkn-erdat.
      t_e1bpmereqaccount-quantity = wa_ebkn-menge.
      IF ls_eban-zwerks = '1601'.
        wa_ebkn-sakto = '0899999999'.
      ENDIF.
      IF wa_ebkn-anln1 IS NOT INITIAL.
        IF ls_eban-zwerks = '1601'.
          wa_ebkn-anln1 = '299200000001'.
          wa_ebkn-anln2 = '0000'.
        ENDIF.
        t_e1bpmereqaccount-asset_no = wa_ebkn-anln1.
        t_e1bpmereqaccountx-asset_no = 'X'. "'132100000401'. "wa_ebkn-anln1.
      ENDIF.
      IF ls_eban-zwerks = '1601' AND ls_eban-knttp = 'K'.
        wa_ebkn-kostl = '0001600901'.
      ENDIF.
      IF wa_ebkn-anln2 IS NOT INITIAL.
        t_e1bpmereqaccount-sub_number = wa_ebkn-anln2.
        t_e1bpmereqaccountx-sub_number = 'X'. "wa_ebkn-anln2.
      ENDIF.
      IF wa_ebkn-ablad IS NOT INITIAL.
        t_e1bpmereqaccount-unload_pt = wa_ebkn-ablad. "'RFA/8020/07/2020/0001 '.
        t_e1bpmereqaccountx-unload_pt = 'X'.
      ENDIF.
      IF wa_ebkn-kostl IS NOT INITIAL.
        t_e1bpmereqaccount-costcenter = wa_ebkn-kostl.
        t_e1bpmereqaccountx-costcenter = 'X'.
      ENDIF.
      IF wa_ebkn-sakto IS NOT INITIAL.
        CONDENSE: wa_ebkn-sakto.
        CLEAR: l_gl_account, l_sakto.
        l_sakto = wa_ebkn-sakto.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_ebkn-sakto
          IMPORTING
            output = l_gl_account.
        t_e1bpmereqaccount-gl_account = l_gl_account.
        t_e1bpmereqaccountx-gl_account = 'X'.
      ENDIF.
      APPEND t_e1bpmereqaccount.

      t_e1bpmereqaccountx-preq_item = wa_ebkn-bnfpo.
      t_e1bpmereqaccountx-serial_no = wa_ebkn-zebkn.
      IF t_e1bpmereqaccount-creat_date IS NOT INITIAL.
        t_e1bpmereqaccountx-creat_date = 'X'. "wa_ebkn-erdat.
      ENDIF.
      t_e1bpmereqaccountx-quantity = 'X'. "10. "wa_ebkn-menge.
      APPEND t_e1bpmereqaccountx.
      CLEAR: wa_ebkn.
    ENDLOOP.
    LOOP AT ls_eban-zeban INTO wa_zeban WHERE  banfn = ls_eban-banfn AND bnfpo  = ls_eban-bnfpo.
      CONDENSE: wa_zeban-bnfpo, wa_zeban-urut.
      CONCATENATE '0' wa_zeban-urut INTO wa_zeban-urut.
      CONDENSE: wa_zeban-bnfpo, wa_zeban-urut.

      c_segnam        = 'E1BPMEREQITEMTEXT'.
      t_e1bpmereqitemtext-preq_no  = ls_eban-banfn.
      t_e1bpmereqitemtext-preq_item  = wa_zeban-bnfpo.
      t_e1bpmereqitemtext-text_id  = 'B04'. "wa_zeban-TDID.
      IF sy-tabix = 1.
        t_e1bpmereqitemtext-text_form  = '*'.
      ELSE.
        t_e1bpmereqitemtext-text_form  = '/'.
      ENDIF.
      t_e1bpmereqitemtext-text_line  = wa_zeban-txt. "wa_zeban-TDLINE.
      CLEAR: wa_zeban.
      APPEND t_e1bpmereqitemtext.
    ENDLOOP.
    CLEAR: ls_eban-ebkn[], ls_eban-zeban[].
    CLEAR: ls_eban-ebkn, ls_eban-zeban, ls_eban.
  ENDLOOP.
  IF gv_sw = '1'.
    gv_sw = '2'.
  ELSE.
    PERFORM f_proses_idoc CHANGING p_return p_message.
  ENDIF.

ENDFORM.                    " F_PROSES_PR
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_IDOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_idoc CHANGING p_return p_message.
  TABLES: ztiammmdt001.
  DATA: wa_ztiammmdt001 TYPE ztiammmdt001.
  DATA: gt_ztiammmdt001 TYPE STANDARD TABLE OF ztiammmdt001.
  DATA: lv_banfn TYPE banfn.
  DATA: lv_str TYPE string.
  DATA: lv_status(1).
  DATA: lt_edids TYPE STANDARD TABLE OF edids.
  DATA: ls_edids TYPE edids.
  DATA: ls_edidc TYPE edidc.

  REFRESH: gt_edidd, gt_edi_dc40.
  CLEAR: wa_edidd, gt_edidd, lv_banfn, p_return.
  SELECT SINGLE * INTO gs_ztiamitdt001  FROM ztiamitdt001
    WHERE zproject = 'TIAM' AND
          mestyp = c_mestyp AND
          idoctp = c_idoctp.
  gs_edi_dc40-tabnam = 'EDI_DC40'.
  gs_edi_dc40-mandt = sy-mandt.
  gs_edi_dc40-rcvpor = gs_ztiamitdt001-rcvpor. "Receiver Port
  gs_edi_dc40-rcvprt = c_rcvprt. "Partner type of receiver
  gs_edi_dc40-rcvprn = gs_ztiamitdt001-rcvprn. "Partner number of receiver
  gs_edi_dc40-mestyp = gs_ztiamitdt001-mestyp. "Message type
  gs_edi_dc40-idoctyp = gs_ztiamitdt001-idoctp. "Basic IDOC type
  gs_edi_dc40-sndprt = c_sndprt. "Sender Partner type
  gs_edi_dc40-sndprn = gs_ztiamitdt001-sndprn. "Sender Partner Number
  gs_edi_dc40-sndpor = gs_ztiamitdt001-sndpor. "Sender Port
  gs_edi_dc40-direct = '2'.
  gs_edi_dc40-refint = gv_filename.
  APPEND gs_edi_dc40 TO gt_edi_dc40.

  CLEAR wa_edidd.
  c_segnam        = 'E1PREQCR1'.
  t_e1preqcr1-testrun = ' '.
  wa_edidd-segnam  = c_segnam.
  wa_edidd-mandt  = sy-mandt.
  wa_edidd-psgnum = 0.
  wa_edidd-hlevel = 1 .
  wa_edidd-sdata   = t_e1preqcr1.
  APPEND wa_edidd TO gt_edidd.
  LOOP AT t_e1bpmereqheader.
    lv_banfn = t_e1bpmereqheader-preq_no.
    CLEAR wa_edidd.
    c_segnam        = 'E1BPMEREQHEADER'.
    wa_edidd-segnam  = c_segnam.
    wa_edidd-mandt  = sy-mandt.
    wa_edidd-psgnum = 1.
    wa_edidd-hlevel = 2.
    wa_edidd-segnum = 1.
    wa_edidd-sdata   = t_e1bpmereqheader.
    APPEND wa_edidd TO gt_edidd.
    CLEAR wa_edidd.
    c_segnam        = 'E1BPMEREQHEADERX'.

    wa_edidd-segnam  = c_segnam.
    wa_edidd-mandt  = sy-mandt.
    wa_edidd-psgnum = 1.
    wa_edidd-hlevel = 2.
    wa_edidd-segnum = 2.
    wa_edidd-sdata   = t_e1bpmereqheaderx.
    APPEND wa_edidd TO gt_edidd.
    EXIT.
  ENDLOOP.
  LOOP AT t_e1bpmereqitemimp.
    CLEAR wa_edidd.
    c_segnam        = 'E1BPMEREQITEMIMP'.
    wa_edidd-segnam  = c_segnam.
    wa_edidd-mandt  = sy-mandt.
    wa_edidd-psgnum = 1.
    wa_edidd-hlevel = 2.
    wa_edidd-segnum = 3.
    wa_edidd-sdata   = t_e1bpmereqitemimp.
    APPEND wa_edidd TO gt_edidd.

  ENDLOOP.
  LOOP AT t_e1bpmereqitemx.
    CLEAR wa_edidd.
    c_segnam        = 'E1BPMEREQITEMX'.
    wa_edidd-segnam  = c_segnam.
    wa_edidd-mandt  = sy-mandt.
    wa_edidd-psgnum = 1.
    wa_edidd-hlevel = 2.
    wa_edidd-segnum = 4.
    wa_edidd-sdata   = t_e1bpmereqitemx.
    APPEND wa_edidd TO gt_edidd.

  ENDLOOP.

  LOOP AT t_e1bpmereqitem.
    CLEAR wa_edidd.
    c_segnam        = 'E1BPMEREQITEM'.

    wa_edidd-segnam  = c_segnam.
    wa_edidd-mandt  = sy-mandt.
    wa_edidd-psgnum = 1.
    wa_edidd-hlevel = 2.
    wa_edidd-segnum = 5.
    wa_edidd-sdata   = t_e1bpmereqitem.
    APPEND wa_edidd TO gt_edidd.

  ENDLOOP.
  LOOP AT t_e1bpmereqaccount.
    CLEAR wa_edidd.
    c_segnam        = 'E1BPMEREQACCOUNT'.

    wa_edidd-segnam  = c_segnam.
    wa_edidd-mandt  = sy-mandt.
    wa_edidd-psgnum = 1.
    wa_edidd-hlevel = 2.
    "    wa_edidd-segnum = l_ctr.
    wa_edidd-sdata   = t_e1bpmereqaccount.
    APPEND wa_edidd TO gt_edidd.

  ENDLOOP.

  LOOP AT t_e1bpmereqaccountx.
    CLEAR wa_edidd.
    c_segnam        = 'E1BPMEREQACCOUNTX'.

    wa_edidd-segnam  = c_segnam.
    wa_edidd-mandt  = sy-mandt.
    wa_edidd-psgnum = 1.
    wa_edidd-hlevel = 2.
    "    wa_edidd-segnum = l_ctr.
    wa_edidd-sdata   = t_e1bpmereqaccountx.
    APPEND wa_edidd TO gt_edidd.

  ENDLOOP.

  LOOP AT t_e1bpmereqitemtext.
    CLEAR wa_edidd.
    c_segnam        = 'E1BPMEREQITEMTEXT'.
    wa_edidd-segnam  = c_segnam.
    wa_edidd-mandt  = sy-mandt.
    wa_edidd-psgnum = 1.
    wa_edidd-hlevel = 2.
    wa_edidd-sdata   = t_e1bpmereqitemtext.
    APPEND wa_edidd TO gt_edidd.
  ENDLOOP.

  PERFORM f_create_text_file.
  wa_ztiammmdt001-zbanfn = lv_banfn.
  wa_ztiammmdt001-erdat = sy-datum.
  wa_ztiammmdt001-erzet = sy-uzeit.
  wa_ztiammmdt001-ernam = sy-uname.
  MODIFY ztiammmdt001 FROM wa_ztiammmdt001.
  COMMIT WORK AND WAIT.

  CALL FUNCTION 'EDI_DATA_INCOMING'
    EXPORTING
      pathname = gv_fullfile
      port     = gs_ztiamitdt001-sndpor.

  WAIT UP TO 15 SECONDS.

  IF sy-msgv1 IS INITIAL.
    lv_status = 'E'.
  ELSE.
    wa_edidc-docnum = sy-msgv1.
    gv_docnum =  sy-msgv1..
    CALL FUNCTION 'IDOC_GET_MESSAGE_ATTRIBUTE'
      EXPORTING
        idoc_number  = gv_docnum "sy-msgv1
      IMPORTING
        idoc_message = idoc_message.
    SKIP 2.
    wa_ztiammmdt001-docnum = gv_docnum.
    CONCATENATE wa_edidc-docnum sy-vline idoc_message INTO  wa_ztiammmdt001-zmess.
    wa_ztiammmdt001-docnum = gv_docnum.
    MODIFY ztiammmdt001 FROM wa_ztiammmdt001.
    COMMIT WORK AND WAIT.

    SELECT SINGLE * INTO ls_edidc FROM edidc WHERE docnum = gv_docnum. " AND status = '53'.
    IF sy-subrc EQ 0.
      CASE ls_edidc-status.
        WHEN '53'.
          wa_ztiammmdt001-status = 'S'.
          p_message = 'Success'. "lv_str'.
          p_return = 0.
          PERFORM p_post_prtiam USING gv_banfn 'S' CHANGING lv_str.
        WHEN '51'.
          p_message = gv_docnum. "'Mohon cek Idoc'.
          wa_ztiammmdt001-status = 'E'.
          p_return = 4.
        WHEN OTHERS.
          wa_ztiammmdt001-status = 'I'.
          p_message = 'Cek Idoc'.
      ENDCASE.
      MODIFY ztiammmdt001 FROM wa_ztiammmdt001.
      COMMIT WORK AND WAIT.
      lv_status = wa_ztiammmdt001-status.
    ELSE.
      wa_ztiammmdt001-status = 'E'.
      p_message = 'Gagal Create Idoc'.
    ENDIF.
  ENDIF.
  REFRESH: gt_edidd.
  CLEAR: wa_edidd, gt_edidd.
  REFRESH:   t_e1bpmereqheader, t_e1bpmereqheaderx ,t_e1bpmereqitem , t_e1bpmereqitemx , t_e1bpmereqitemimp ,
          t_e1bpmereqaccount, t_e1bpmereqaccountx, t_e1bpmereqheadtext, t_e1bpmereqitemtext, t_e1preqcr1.
  CLEAR:   t_e1bpmereqheader, t_e1bpmereqheaderx ,t_e1bpmereqitem , t_e1bpmereqitemx , t_e1bpmereqitemimp ,
          t_e1bpmereqaccount, t_e1bpmereqaccountx, t_e1bpmereqheadtext, t_e1bpmereqitemtext, t_e1preqcr1.
ENDFORM.                    " F_PROSES_IDOC
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_TEXT_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_text_file .
  DATA : l_version LIKE edisdef-version,
         l_filename(125) TYPE c,
         l_filename_dest(125) TYPE c,
         l_filedestination(125) TYPE c,
         l_text(1000) TYPE c,
         l_extension(5) TYPE c.
  DATA: tot_rec(4), rec_i TYPE i.

  SPLIT gv_fullfile AT '.' INTO l_filename l_extension.
****  l_filename = 'path dan nama file'.

  CONCATENATE  l_filename '_IDOC' '.' 'EDI'  INTO l_filedestination.

  OPEN DATASET l_filedestination FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
  CLEAR: l_text, tot_rec.

  LOOP AT  gt_edi_dc40 INTO gs_edi_dc40.
    l_text = gs_edi_dc40.
    rec_i = 524.
    TRANSFER l_text TO l_filedestination LENGTH rec_i.
  ENDLOOP.
  CLEAR: l_text.
*  tot_rec =
  DESCRIBE TABLE gt_edidd LINES tot_rec.
  LOOP AT gt_edidd INTO wa_edidd.
    SELECT MAX( DISTINCT  version  ) expleng
          INTO (l_version, tot_rec)
          FROM edisdef
      WHERE segtyp = wa_edidd-segnam
      GROUP BY segtyp version expleng.
      "      GROUP BY version segdef expleng.
    ENDSELECT.
    rec_i = tot_rec.
    rec_i = rec_i + 63.
    l_text = wa_edidd.
    TRANSFER l_text TO l_filedestination LENGTH rec_i.
    CLEAR: l_text.
  ENDLOOP.
  CLOSE DATASET l_filedestination.
  PERFORM f_changefilemode USING l_filedestination.
  gv_inputpath  = gv_fullfile. "Insertion by SAP_DEV02(Tiara)  #DEVK932762  07.09.2012
  gv_fullfile   = l_filedestination.

ENDFORM.                    " F_CREATE_TEXT_FILE

*&---------------------------------------------------------------------*
*&      Form  F_CHANGEFILEMODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_FILEDESTINATION  text
*----------------------------------------------------------------------*
FORM f_changefilemode USING p_file TYPE c.
  DATA : BEGIN OF tabl OCCURS 10,
             line(200),
         END OF tabl,
         l_command(125) TYPE c.

*   change file mod to 777
  CONCATENATE 'chmod 777' p_file INTO l_command SEPARATED BY ' '.
  CALL 'SYSTEM' ID 'COMMAND' FIELD l_command
                ID 'TAB' FIELD tabl-*sys*.
ENDFORM.                    " F_CHANGEFILEMODE
*&---------------------------------------------------------------------*
*&      Form  P_POST_PRTIAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_BANFN  text
*      -->P_P_PROSES  text
*      <--P_LV_STR  text
*----------------------------------------------------------------------*
FORM p_post_prtiam  USING p_banfn p_status

                    CHANGING p_str.
  DATA: lv_proses(15).
  DATA: lv_json TYPE string.
  lv_proses = 'TIAM_PRCREATE'.
  CONCATENATE '{ "ZAPPR":"' p_status '", "BANFN":"' p_banfn '" }' INTO  lv_json.
  PERFORM f_post_data_json(ztdsit_i001) USING lv_json lv_proses sy-subrc p_str.

ENDFORM.                    " P_POST_PRTIAM
