*----------------------------------------------------------------------*
***INCLUDE LZTIAM_IDOCF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_TYPE_GOODSMVT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_type_goodsmvt .
* check basis idoc type
  break absuk.
  IF control_record_in-idoctp NP 'ZMBGMCR*'.
    MESSAGE e029(e0) WITH control_record_in-idoctp ' '
            'ZTIAM_OUTPUT_MGBMCR' RAISING error_message_received.
  ENDIF.

ENDFORM.                    " F_CHECK_TYPE_GOODSMVT

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_DOCUMENT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_MBLNR  text
*----------------------------------------------------------------------*
FORM f_get_material_document_data  USING pv_mblnr
                                         pv_mjahr.
  DATA: lv_bukrs TYPE bukrs.
  WAIT UP TO 5 SECONDS.
* select header of material document
  SELECT SINGLE mblnr mjahr bldat budat aedat usnam xblnr bktxt
 FROM mkpf INTO CORRESPONDING FIELDS OF wa_mkpf
    WHERE mblnr EQ pv_mblnr
      AND mjahr EQ pv_mjahr.

* select detail of material document
  SELECT mblnr mjahr zeile bwart werks lgort erfmg erfme ebeln ebelp
        pargb anln1 anln2 sgtxt lfbnr lfpos bukrs ablad smbln smblp
    FROM mseg INTO CORRESPONDING FIELDS OF TABLE gt_mseg
    WHERE mblnr EQ pv_mblnr
      AND mjahr EQ pv_mjahr.
*      AND xauto EQ space.     "Insertion by SAP_DEV02(Tiara)  #DEVK932646     04.09.2012

  IF gt_mseg[] IS NOT INITIAL.
    SELECT * FROM anla INTO CORRESPONDING FIELDS OF TABLE gt_anla
      FOR ALL ENTRIES IN gt_mseg
      WHERE bukrs EQ gt_mseg-bukrs AND
            anln1 EQ gt_mseg-anln1 AND
            anln2 EQ gt_mseg-anln2.
    SELECT * FROM anlb INTO CORRESPONDING FIELDS OF TABLE gt_anlb
      FOR ALL ENTRIES IN gt_mseg
      WHERE bukrs EQ gt_mseg-bukrs AND
            anln1 EQ gt_mseg-anln1 AND
            anln2 EQ gt_mseg-anln2.

    SELECT * FROM anlc INTO CORRESPONDING FIELDS OF TABLE gt_anlc
      FOR ALL ENTRIES IN gt_mseg
      WHERE bukrs EQ gt_mseg-bukrs AND
            anln1 EQ gt_mseg-anln1 AND
            anln2 EQ gt_mseg-anln2.
    IF gt_anla[] IS INITIAL OR gt_anlb[] IS INITIAL.
      SELECT * FROM ekkn INTO CORRESPONDING FIELDS OF TABLE gt_ekkn
        FOR ALL ENTRIES IN gt_mseg
        WHERE ebeln EQ gt_mseg-ebeln AND
              ebelp EQ gt_mseg-ebelp.

      READ TABLE gt_mseg INDEX 1.
      IF gt_ekkn[] IS NOT INITIAL.
        LOOP AT gt_ekkn.
          gt_ekkn-bukrs = gt_mseg-bukrs.
          MODIFY gt_ekkn TRANSPORTING bukrs.
        ENDLOOP.
*{   REPLACE        P01K910270                                        1
*\        SELECT * FROM anla INTO CORRESPONDING FIELDS OF TABLE gt_anla
*\          FOR ALL ENTRIES IN gt_ekkn
*\          WHERE "bukrs EQ gt_mseg-bukrs AND
*\                anln1 EQ gt_ekkn-anln1 AND
*\                anln2 EQ gt_ekkn-anln2.
*\        SELECT * FROM anlb INTO CORRESPONDING FIELDS OF TABLE gt_anlb
*\          FOR ALL ENTRIES IN gt_ekkn
*\          WHERE "bukrs EQ gt_mseg-bukrs AND
*\                anln1 EQ gt_ekkn-anln1 AND
*\                anln2 EQ gt_ekkn-anln2.
*\
*\        SELECT * FROM anlc INTO CORRESPONDING FIELDS OF TABLE gt_anlc
*\          FOR ALL ENTRIES IN gt_ekkn
*\          WHERE "bukrs EQ gt_mseg-bukrs AND
*\                anln1 EQ gt_ekkn-anln1 AND
*\                anln2 EQ gt_ekkn-anln2.
        "Start SOH: Shell SCI Adjustment 20240221 KRS
        SELECT * FROM anla INTO CORRESPONDING FIELDS OF TABLE gt_anla
          FOR ALL ENTRIES IN gt_ekkn
          WHERE "bukrs EQ gt_mseg-bukrs AND
                anln1 EQ gt_ekkn-anln1 AND
                anln2 EQ gt_ekkn-anln2
          ORDER BY PRIMARY KEY.
        SELECT * FROM anlb INTO CORRESPONDING FIELDS OF TABLE gt_anlb
          FOR ALL ENTRIES IN gt_ekkn
          WHERE "bukrs EQ gt_mseg-bukrs AND
                anln1 EQ gt_ekkn-anln1 AND
                anln2 EQ gt_ekkn-anln2
          ORDER BY PRIMARY KEY.

        SELECT * FROM anlc INTO CORRESPONDING FIELDS OF TABLE gt_anlc
          FOR ALL ENTRIES IN gt_ekkn
          WHERE "bukrs EQ gt_mseg-bukrs AND
                anln1 EQ gt_ekkn-anln1 AND
                anln2 EQ gt_ekkn-anln2
          ORDER BY PRIMARY KEY..
        "End SOH: Shell SCI Adjustment 20240221 KRS
*}   REPLACE
      ENDIF.
    ENDIF.
    SELECT ebeln ebelp gjahr belnr buzei bewtp bwart budat menge wrbtr waers elikz werks ernam wesbs
       FROM ekbe INTO CORRESPONDING FIELDS OF TABLE gt_ekbe
      FOR ALL ENTRIES IN gt_mseg
       WHERE ebeln EQ gt_mseg-ebeln AND
             ebelp EQ gt_mseg-ebelp AND
             gjahr EQ gt_mseg-mjahr AND
             belnr EQ gt_mseg-mblnr.
    SORT gt_anlb BY bukrs anln1 anln2 afabe.
    DELETE ADJACENT DUPLICATES FROM gt_anlb COMPARING ALL FIELDS.
    DELETE ADJACENT DUPLICATES FROM gt_anla COMPARING ALL FIELDS.
    DELETE ADJACENT DUPLICATES FROM gt_anlc COMPARING ALL FIELDS.
  ELSE.
    MESSAGE e014(zedi) RAISING material_document_not_found.
  ENDIF.


ENDFORM.                    " F_GET_MATERIAL_DOCUMENT_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_DATA_RECORD_MGBMCR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_generate_data_record_mgbmcr .
  DATA: lv_segnam     TYPE edi4segnam,
        lv_isocode    TYPE isocd_unit.
  DATA: lv_sw(1).
  DATA: lv_text1(15), lv_text2(17).

  REFRESH gt_edidd_o[].

  CLEAR wa_edidd_o.
  lv_segnam                         = 'E1MBGMCR'.
  wa_edidd_o-segnam                 = lv_segnam.
  wa_edidd_o-mandt                  = sy-mandt.
  wa_edidd_o-sdata                  = wa_mgbmcr.
  APPEND wa_edidd_o TO gt_edidd_o.

  CLEAR wa_edidd_o.
  lv_segnam                         = 'ZMKPF'.
  wa_zmkpf-mblnr   =  wa_mkpf-mblnr.
  wa_zmkpf-mjahr   =  wa_mkpf-mjahr.
  wa_zmkpf-bldat   =  wa_mkpf-bldat.
  wa_zmkpf-budat   =  wa_mkpf-budat.
  wa_zmkpf-aedat   =  wa_mkpf-aedat.
  wa_zmkpf-usnam   =  wa_mkpf-usnam.
  wa_zmkpf-xblnr   =  wa_mkpf-xblnr.
  wa_zmkpf-bktxt   =  wa_mkpf-bktxt.
  wa_edidd_o-segnam                   = lv_segnam.
  wa_edidd_o-mandt                    = sy-mandt.
  wa_edidd_o-sdata                    = wa_zmkpf.
  APPEND wa_edidd_o TO gt_edidd_o.
  CLEAR: lv_sw.
  LOOP AT gt_mseg.
    CLEAR wa_edidd_o.
    lv_segnam                         = 'ZMSEG'.
    wa_zmseg-mblnr   =  gt_mseg-mblnr.
    wa_zmseg-mjahr   =  gt_mseg-mjahr.
    wa_zmseg-zeile   =  gt_mseg-zeile.
    wa_zmseg-bwart   =  gt_mseg-bwart.
    wa_zmseg-werks   =  gt_mseg-werks.
    wa_zmseg-lgort   =  gt_mseg-lgort.
    wa_zmseg-erfmg   =  gt_mseg-erfmg.
    wa_zmseg-erfme   =  gt_mseg-erfme.
    wa_zmseg-ebeln   =  gt_mseg-ebeln.
    wa_zmseg-ebelp   =  gt_mseg-ebelp.
    wa_zmseg-pargb   =  gt_mseg-pargb.
    wa_zmseg-anln1   =  gt_mseg-anln1.
    wa_zmseg-anln2   =  gt_mseg-anln2.
    wa_zmseg-sgtxt   =  gt_mseg-sgtxt.
    IF gt_mseg-bwart EQ '105'.
      wa_zmseg-smbln   =  gt_mseg-lfbnr.
      wa_zmseg-smblp   =  gt_mseg-lfpos.
    ELSE. "IF gt_mseg-bwart EQ '106' or gt_mseg-bwart EQ '104'.
      wa_zmseg-smbln   =  gt_mseg-smbln.
      wa_zmseg-smblp   =  gt_mseg-smblp.
    ENDIF.
    wa_zmseg-bukrs   =  gt_mseg-bukrs.
    wa_zmseg-ablad   =  gt_mseg-ablad.
    "IF gt_mseg-smbln IS NOT INITIAL.
    "  wa_zmseg-lfbnr   =  gt_mseg-smbln.
    "ENDIF.
    wa_edidd_o-segnam                   = lv_segnam.
    wa_edidd_o-mandt                    = sy-mandt.
    wa_edidd_o-sdata                    = wa_zmseg.
    APPEND wa_edidd_o TO gt_edidd_o.
    IF gt_mseg-bwart EQ '105' OR gt_mseg-bwart EQ '106'.
      lv_sw = 'X'.
    ENDIF.
    CLEAR: gt_mseg, wa_zmseg.

  ENDLOOP.

  LOOP AT gt_ekbe.
    CLEAR wa_edidd_o.
    lv_segnam                         = 'ZEKBE'.
    wa_zekbe-ebeln   =  gt_ekbe-ebeln.
    wa_zekbe-ebelp   =  gt_ekbe-ebelp.
    wa_zekbe-gjahr   =  gt_ekbe-gjahr.
    wa_zekbe-belnr   =  gt_ekbe-belnr.
    wa_zekbe-buzei   =  gt_ekbe-buzei.
    wa_zekbe-bewtp   =  gt_ekbe-bewtp.
    wa_zekbe-bwart   =  gt_ekbe-bwart.
    wa_zekbe-budat   =  gt_ekbe-budat.
    IF gt_ekbe-bwart = '103' OR gt_ekbe-bwart = '104'.
      wa_zekbe-menge   =  gt_ekbe-wesbs.
    ELSE.
      wa_zekbe-menge   =  gt_ekbe-menge.
    ENDIF.
    wa_zekbe-wrbtr   =  gt_ekbe-wrbtr.
    wa_zekbe-waers   =  gt_ekbe-waers.
    wa_zekbe-elikz   =  gt_ekbe-elikz.
    wa_zekbe-werks   =  gt_ekbe-werks.
    wa_zekbe-ernam   =  gt_ekbe-ernam.
    wa_edidd_o-segnam                   = lv_segnam.
    wa_edidd_o-mandt                    = sy-mandt.
    wa_edidd_o-sdata                    = wa_zekbe.
    APPEND wa_edidd_o TO gt_edidd_o.
    CLEAR: gt_ekbe, wa_zekbe.

  ENDLOOP.
  IF lv_sw = 'X'.
    LOOP AT gt_anla.
      CLEAR wa_edidd_o.
      lv_segnam                         = 'ZANLA'.
      wa_zanla-bukrs   =     gt_anla-bukrs.
      wa_zanla-anln1   =     gt_anla-anln1.
      wa_zanla-anln2   =     gt_anla-anln2.
      wa_zanla-anlkl   =     gt_anla-anlkl.
      wa_zanla-ernam   =     gt_anla-ernam.
      wa_zanla-erdat   =     gt_anla-erdat.
      wa_zanla-aenam   =     gt_anla-aenam.
      wa_zanla-aedat   =     gt_anla-aedat.
      wa_zanla-zujhr   =     gt_anla-zujhr.
      wa_zanla-zuper   =     gt_anla-zuper.
      wa_zanla-zugdt   =     gt_anla-zugdt.
      wa_zanla-aktiv   =     gt_anla-aktiv.
      wa_zanla-aneqk   =     gt_anla-aneqk.
      wa_zanla-lifnr   =     gt_anla-lifnr.
      wa_zanla-vbund   =     gt_anla-vbund.
      wa_zanla-eigkz   =     gt_anla-eigkz.
      wa_zanla-meins   =     gt_anla-meins.
      wa_zanla-menge   =     gt_anla-menge.
      wa_zanla-xafabch =     gt_anla-xafabch.
      wa_edidd_o-segnam                   = lv_segnam.
      wa_edidd_o-mandt                    = sy-mandt.
      wa_edidd_o-sdata                    = wa_zanla.
      APPEND wa_edidd_o TO gt_edidd_o.
      CLEAR: gt_anla, wa_zanla.

    ENDLOOP.
    LOOP AT gt_anlb.
      CLEAR wa_edidd_o.
      lv_segnam                         = 'ZANLB'.
      wa_zanlb-bukrs   =     gt_anlb-bukrs.
      wa_zanlb-anln1   =     gt_anlb-anln1.
      wa_zanlb-anln2   =     gt_anlb-anln2.
      wa_zanlb-afabe   =     gt_anlb-afabe.
      wa_zanlb-ernam   =     gt_anlb-ernam.
      wa_zanlb-erdat   =     gt_anlb-erdat.
      wa_zanlb-aenam   =     gt_anlb-aenam.
      wa_zanlb-aedat   =     gt_anlb-aedat.
      wa_zanlb-afabg   =     gt_anlb-afabg.
      wa_zanlb-safbg   =     gt_anlb-safbg.
      wa_zanlb-lgjan   =     gt_anlb-lgjan.
      wa_zanlb-perfy   =     gt_anlb-perfy.
      wa_zanlb-inbda   =     gt_anlb-inbda.
      wa_edidd_o-segnam                   = lv_segnam.
      wa_edidd_o-mandt                    = sy-mandt.
      wa_edidd_o-sdata                    = wa_zanlb.
      APPEND wa_edidd_o TO gt_edidd_o.
      CLEAR: gt_anlb, wa_zanlb.

    ENDLOOP.

    LOOP AT gt_anlc.
      CLEAR: wa_edidd_o, lv_text1.
      lv_segnam                         = 'ZANLC'.
      wa_zanlc-bukrs   =     gt_anlc-bukrs.
      wa_zanlc-anln1   =     gt_anlc-anln1.
      wa_zanlc-anln2   =     gt_anlc-anln2.
      wa_zanlc-gjahr   =     gt_anlc-gjahr.
      wa_zanlc-afabe   =     gt_anlc-afabe.
      wa_zanlc-afblpe  =     gt_anlc-afblpe.
      WRITE gt_anlc-nafap TO lv_text1 CURRENCY 'IDR' NO-GROUPING.
      PERFORM f_convert_nilai USING lv_text1 CHANGING wa_zanlc-nafap.
      WRITE gt_anlc-safap TO lv_text1 CURRENCY 'IDR' NO-GROUPING.
      PERFORM f_convert_nilai USING lv_text1 CHANGING wa_zanlc-safap. "lv_text2.
      WRITE gt_anlc-nafag TO lv_text1 CURRENCY 'IDR' NO-GROUPING.
      PERFORM f_convert_nilai USING lv_text1 CHANGING wa_zanlc-nafag. "lv_text2.
      WRITE gt_anlc-answl TO lv_text1 CURRENCY 'IDR' NO-GROUPING.
      PERFORM f_convert_nilai USING lv_text1 CHANGING wa_zanlc-answl. "lv_text2.
      wa_edidd_o-segnam                   = lv_segnam.
      wa_edidd_o-mandt                    = sy-mandt.
      wa_edidd_o-sdata                    = wa_zanlc.
      APPEND wa_edidd_o TO gt_edidd_o.
      CLEAR: gt_anlc, wa_zanlc.
    ENDLOOP.
  ENDIF.
  REFRESH int_edidd[].
  IF gt_edidd_o IS NOT INITIAL.
    int_edidd[] = gt_edidd_o[].
  ENDIF.
ENDFORM.                    " F_GENERATE_DATA_RECORD_MGBMCR

***&---------------------------------------------------------------------*
***&      Form  F_CONVERT_UOM_TO_ISO
***&---------------------------------------------------------------------*
***       text
***----------------------------------------------------------------------*
**FORM f_convert_uom_to_iso  USING    pv_input
**                                    pv_output.
**  DATA: lv_msehi  TYPE msehi.
**
**  MOVE pv_input TO lv_msehi.
**
**  CALL FUNCTION 'ZDGFMMM_CONV_UOM_TO_ISO'
**    EXPORTING
**      i_msehi                = lv_msehi
**    IMPORTING
**      i_isocode              = pv_output
**    EXCEPTIONS
**      isocode_unit_not_found = 1
**      OTHERS                 = 2.
**  IF sy-subrc <> 0.
*** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
***         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
**  ENDIF.
**
**ENDFORM.                    " F_CONVERT_UOM_TO_ISO

*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_CTRL_DATA_PRC_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_generate_ctrl_data_prc_code .
  gs_edi_dc40-tabnam  = 'EDI_DC40'.
  gs_edi_dc40-mandt   = sy-mandt.

  gs_edi_dc40-rcvpor  = control_record_in-rcvpor.       "Receiver Port
  gs_edi_dc40-rcvprt  = control_record_in-rcvprt.       "Partner type of receiver
  gs_edi_dc40-rcvprn  = control_record_in-rcvprn.       "Partner number of receiver

  gs_edi_dc40-mestyp  = c_mestyp_imm02.                 "Message type
  gs_edi_dc40-idoctyp = c_idoctyp_imm02.                "Basic IDOC type

  gs_edi_dc40-sndprt  = c_sndprt.                       "Sender Partner type
  gs_edi_dc40-sndprn  = control_record_in-sndprn.       "Sender Partner Number
  gs_edi_dc40-sndpor  = control_record_in-sndpor.       "Sender Port

*  gs_edi_dc40-rcvpfc  = c_rcvprt.       "Partner type of receiver
  gs_edi_dc40-direct  = '2'.
  gs_edi_dc40-refint  = gv_filename.
  APPEND gs_edi_dc40 TO gt_edi_dc40.
ENDFORM.                    " F_GENERATE_CTRL_DATA_PRC_CODE

*&---------------------------------------------------------------------*
*&      Form  F_GET_IDOCTYPE_COMPLETE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_idoctype_complete USING pv_idoctyp
                                   pv_cimtyp.

  DATA: lv_release LIKE sy-saprl,
         lv_version LIKE edi_verrec-version.

  IF pv_idoctyp EQ c_idoctyp_imm02.
    CALL FUNCTION 'IDOCTYPE_READ_COMPLETE'
      EXPORTING
        pi_idoctyp         = pv_idoctyp
        pi_cimtyp          = pv_cimtyp
        pi_release         = '' "lv_release
        pi_version         = '3' "lv_version
      IMPORTING
        pe_header          = wa_idoctype_hdr
      TABLES
        pt_segments        = gt_segment
      EXCEPTIONS
        object_unknown     = 1
        segment_unknown    = 2
        relation_not_found = 3
        OTHERS             = 4.

  ELSE.
    CALL FUNCTION 'IDOCTYPE_READ_COMPLETE'
      EXPORTING
        pi_idoctyp         = pv_idoctyp
        pi_cimtyp          = pv_cimtyp
      IMPORTING
        pe_header          = wa_idoctype_hdr
      TABLES
        pt_segments        = gt_segment
      EXCEPTIONS
        object_unknown     = 1
        segment_unknown    = 2
        relation_not_found = 3
        OTHERS             = 4.
  ENDIF.

  IF sy-subrc <> 0.
    MESSAGE e013(zedi) RAISING idoc_type_not_found WITH pv_idoctyp.
  ENDIF.


  IF sy-subrc <> 0.
    MESSAGE e013(zedi) RAISING idoc_type_not_found WITH pv_idoctyp.
  ENDIF.

ENDFORM.                    " F_GET_IDOCTYPE_COMPLETE
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_NILAI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_PARAM1  text
*      <--P_P_PARAM2  text
*----------------------------------------------------------------------*
FORM f_convert_nilai  USING    p_param1
                      CHANGING p_param2.
  DATA: lv_len TYPE i.

  CONDENSE: p_param1, p_param2.
  lv_len = STRLEN( p_param1 ).
  IF p_param1 CA '-'. " AND NOT p_param1 CO ' '.
    TRANSLATE p_param1 USING '- '.
    MOVE p_param1+0(lv_len) TO p_param2+1(lv_len).
    MOVE '-' TO p_param2(1).
  ELSE.
    p_param2 = p_param1.
  ENDIF.
  CONDENSE: p_param1, p_param2.

ENDFORM.                    " F_CONVERT_NILAI
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_type_invoice .

  IF control_record_in-idoctp NP 'ZMIRO*'.
    MESSAGE e029(e0) WITH control_record_in-idoctp ' '
            'ZTIAM_OUTPUT_MIRO' RAISING error_message_received.
  ENDIF.

ENDFORM.                    " F_CHECK_TYPE_INVOICE

*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_DATA_RECORD_INVOICE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_generate_data_record_invoice. " USING pv_belnr
  "    pv_gjahr.
  DATA: lv_segnam     TYPE edi4segnam.
  DATA: lv_text1(15).
  REFRESH gt_edidd_o[].

  LOOP AT gt_ekbe.
    CLEAR wa_edidd_o.
    lv_segnam                         = 'ZEKBE'.
    wa_zekbe-ebeln   =  gt_ekbe-ebeln.
    wa_zekbe-ebelp   =  gt_ekbe-ebelp.
    wa_zekbe-gjahr   =  gt_ekbe-gjahr.
    wa_zekbe-belnr   =  gt_ekbe-belnr.
    wa_zekbe-buzei   =  gt_ekbe-buzei.
    wa_zekbe-bewtp   =  gt_ekbe-bewtp.
    wa_zekbe-bwart   =  gt_ekbe-bwart.
    wa_zekbe-budat   =  gt_ekbe-budat.
    "IF gt_ekbe-bwart = '103' OR gt_ekbe-bwart = '104'.
    "  WRITE gt_ekbe-wesbs TO wa_zekbe-menge DECIMALS 0 NO-GROUPING.
    "wa_zekbe-menge   =  gt_ekbe-wesbs.
    "ELSE.
    WRITE gt_ekbe-menge TO wa_zekbe-menge DECIMALS 0 NO-GROUPING.
    "wa_zekbe-menge   =  gt_ekbe-menge.
    "ENDIF.
    wa_zekbe-wrbtr   =  gt_ekbe-wrbtr.
    WRITE gt_ekbe-wrbtr TO lv_text1 CURRENCY 'IDR' NO-GROUPING DECIMALS 0.
    PERFORM f_convert_nilai USING lv_text1 CHANGING wa_zekbe-wrbtr. "lv_text2.

    wa_zekbe-waers   =  gt_ekbe-waers.
    wa_zekbe-elikz   =  gt_ekbe-elikz.
    wa_zekbe-werks   =  gt_ekbe-werks.
    wa_zekbe-ernam   =  gt_ekbe-ernam.
    wa_zekbe-lfbnr   =  gt_ekbe-lfbnr.
    wa_zekbe-rebzg   =  gv_rebzg.
    wa_edidd_o-segnam                   = lv_segnam.
    wa_edidd_o-mandt                    = sy-mandt.
    wa_edidd_o-sdata                    = wa_zekbe.
    APPEND wa_edidd_o TO gt_edidd_o.
    CLEAR: gt_ekbe, wa_zekbe.
  ENDLOOP.


***
***  CLEAR wa_edidd_o.
***  lv_segnam                         = 'E1EDK01'.
***  CONCATENATE pv_belnr pv_gjahr INTO wa_eiedk01-belnr.
***  wa_eiedk01-bsart = ivhdr-doc_type.
***  wa_edidd_o-segnam                 = lv_segnam.
***  wa_edidd_o-mandt                  = sy-mandt.
***  wa_edidd_o-sdata                  = wa_eiedk01.
***  APPEND wa_edidd_o TO gt_edidd_o.
***
***  CLEAR wa_edidd_o.
***  lv_segnam                         = 'E1EDKA1'.
***  wa_e1edka1-parvw = 'LF'.
***  wa_e1edka1-lifnr = ivhdr-diff_inv.
***  wa_edidd_o-segnam                 = lv_segnam.
***  wa_edidd_o-mandt                  = sy-mandt.
***  wa_edidd_o-sdata                  = wa_e1edka1.
***  APPEND wa_edidd_o TO gt_edidd_o.
***
***  CLEAR wa_edidd_o.
***  lv_segnam                         = 'E1EDK02'.
***  wa_e1edk02-qualf = '009'.
***  wa_e1edk02-belnr = ivhdr-ref_doc_no.
***  wa_e1edk02-datum = ivhdr-doc_date.
***  wa_edidd_o-segnam                 = lv_segnam.
***  wa_edidd_o-mandt                  = sy-mandt.
***  wa_edidd_o-sdata                  = wa_e1edk02.
***  APPEND wa_edidd_o TO gt_edidd_o.
***
***  CLEAR wa_edidd_o.
***  lv_segnam                         = 'E1EDK03'.
***  wa_e1edk03-iddat = '015'.
***  wa_e1edk03-datum = ivhdr-pstng_date.
***  wa_edidd_o-segnam                 = lv_segnam.
***  wa_edidd_o-mandt                  = sy-mandt.
***  wa_edidd_o-sdata                  = wa_e1edk03.
***  APPEND wa_edidd_o TO gt_edidd_o.
***
***  LOOP AT ivitm INTO wa_ivitm.
***    CLEAR wa_e1edp01.
***    CLEAR wa_edidd_o.
***
***    lv_segnam                         = 'E1EDP01'.
***    wa_e1edp01-posex = wa_ivitm-invoice_doc_item.
***    wa_e1edp01-menge = wa_ivitm-quantity.
***    wa_e1edp01-menee = wa_ivitm-po_unit.
***
***    READ TABLE ivacc INTO wa_ivacc WITH KEY invoice_doc_item = wa_ivitm-invoice_doc_item.
***    wa_e1edp01-werks = wa_ivacc-bus_area.
***    wa_edidd_o-segnam                 = lv_segnam.
***    wa_edidd_o-mandt                  = sy-mandt.
***    wa_edidd_o-sdata                  = wa_e1edp01.
***    APPEND wa_edidd_o TO gt_edidd_o.
***
***    CLEAR wa_edidd_o.
***    lv_segnam                         = 'E1EDP02'.
***    wa_e1edp02-qualf = '013'.
***    wa_e1edp02-belnr = wa_ivitm-po_number.
***    wa_e1edp02-zeile = wa_ivitm-po_item.
***    wa_edidd_o-segnam                 = lv_segnam.
***    wa_edidd_o-mandt                  = sy-mandt.
***    wa_edidd_o-sdata                  = wa_e1edp02.
***    APPEND wa_edidd_o TO gt_edidd_o.
***
***    CLEAR wa_edidd_o.
***    lv_segnam                         = 'E1EDP02'.
***    wa_e1edp02-qualf = '011'.
***    wa_e1edp02-belnr = wa_ivitm-ref_doc.
***    wa_e1edp02-zeile = wa_ivitm-ref_doc_it.
***    wa_edidd_o-segnam                 = lv_segnam.
***    wa_edidd_o-mandt                  = sy-mandt.
***    wa_edidd_o-sdata                  = wa_e1edp02.
***    APPEND wa_edidd_o TO gt_edidd_o.
***
***  ENDLOOP.

  REFRESH int_edidd[].
  IF gt_edidd_o IS NOT INITIAL.
    int_edidd[] = gt_edidd_o[].
  ENDIF.

ENDFORM.                    " F_GENERATE_DATA_RECORD_INVOICE

*&---------------------------------------------------------------------*
*&      Form  F_GET_INVOICE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_BELNR  text
*      -->P_LV_GJAHR  text
*----------------------------------------------------------------------*
FORM f_get_invoice_data  USING    pv_belnr LIKE bapi_incinv_fld-inv_doc_no
                                  pv_gjahr LIKE  bapi_incinv_fld-fisc_year.
  DATA: lv_belnr LIKE ekbe-belnr.
  DATA: lv_gjahr LIKE ekbe-gjahr.
  DATA: lv_ebeln LIKE bseg-ebeln.
  DATA:
      s_headerdata        LIKE bapi_incinv_detail_header,
      s_addressdata       LIKE bapi_incinv_detail_addressdata,
      tab_itemdata        LIKE bapi_incinv_detail_item OCCURS 0 WITH HEADER LINE,
      tab_return          LIKE bapiret2 OCCURS 0.
  DATA: lv_bukrs LIKE bsis-bukrs,
        lv_hkont LIKE bsis-hkont,
        lv_zuonr LIKE bsis-zuonr,
        lv_blart LIKE bsis-blart.


  CONDENSE: pv_belnr,  pv_gjahr.
  lv_belnr = pv_belnr.
  lv_gjahr = pv_gjahr.

  CALL FUNCTION 'BAPI_INCOMINGINVOICE_GETDETAIL'
    EXPORTING
      invoicedocnumber = lv_belnr
      fiscalyear       = lv_gjahr
    IMPORTING
      headerdata       = s_headerdata
      addressdata      = s_addressdata
    TABLES
      itemdata         = tab_itemdata
      return           = tab_return
    EXCEPTIONS
      OTHERS           = 01.

  IF sy-subrc EQ 0.
    lv_ebeln = s_headerdata-diff_inv.
    lv_bukrs = s_headerdata-comp_code.
    lv_blart = s_headerdata-doc_type.
    gv_rebzg = s_headerdata-reversal_doc.
    LOOP AT tab_itemdata.
      lv_ebeln = tab_itemdata-po_number.
    ENDLOOP.
  ENDIF.

  IF lv_blart = 'RC'.
    SELECT SINGLE rebzg INTO gv_rebzg FROM bseg
         WHERE bukrs = lv_bukrs AND
               belnr = lv_belnr AND
               gjahr = lv_gjahr AND
               bschl = '21'  AND
               rebzg NE space.
  ENDIF.
  IF lv_ebeln IS NOT INITIAL.
    SELECT ebeln ebelp gjahr belnr buzei bewtp bwart budat menge wrbtr waers elikz werks ernam wesbs lfbnr shkzg
       FROM ekbe INTO CORRESPONDING FIELDS OF TABLE gt_ekbe
       WHERE ebeln EQ lv_ebeln AND
             gjahr EQ lv_gjahr AND
             belnr EQ lv_belnr AND
             bewtp EQ 'Q'.
  ENDIF.

ENDFORM.                    " F_GET_INVOICE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GEN_CTRL_DATA_PRC_CODE_INV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_gen_ctrl_data_prc_code_inv .
  gs_edi_dc40-tabnam  = 'EDI_DC40'.
  gs_edi_dc40-mandt   = sy-mandt.

  gs_edi_dc40-rcvpor  = control_record_in-rcvpor.       "Receiver Port
  gs_edi_dc40-rcvprt  = control_record_in-rcvprt.       "Partner type of receiver
  gs_edi_dc40-rcvprn  = control_record_in-rcvprn.       "Partner number of receiver

  gs_edi_dc40-mestyp  = c_mestyp_inv02.                 "Message type
  gs_edi_dc40-idoctyp = c_idoctyp_inv02.                "Basic IDOC type

  gs_edi_dc40-sndprt  = c_sndprt.                       "Sender Partner type
  gs_edi_dc40-sndprn  = control_record_in-sndprn.       "Sender Partner Number
  gs_edi_dc40-sndpor  = control_record_in-sndpor.       "Sender Port

*  gs_edi_dc40-rcvpfc  = c_rcvprt.       "Partner type of receiver
  gs_edi_dc40-direct  = '2'.
  gs_edi_dc40-refint  = gv_filename.
  APPEND gs_edi_dc40 TO gt_edi_dc40.
ENDFORM.                    " F_GEN_CTRL_DATA_PRC_CODE_INV
