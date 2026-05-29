*----------------------------------------------------------------------*
*              Print of an order confirmation by SAPscript
*----------------------------------------------------------------------*
REPORT rvador01 LINE-COUNT 100 MESSAGE-ID vn.

TABLES: vbak,
        tvst,
        adrc,
        komk,                          "Communicationarea for conditions
        komp,                          "Communicationarea for conditions
        komvd,                         "Communicationarea for conditions
        vbco3,                         "Communicationarea for view
        vbdka,                         "Headerview
        vbdpa,                         "Itemview
        vbdpau,                        "Subitemnumbers
        conf_out,                      "Configuration data
        sadr,                          "Addresses
        tvag,                          "Reason for rejection
        vedka,                         "Servicecontract head data
        vedpa,                         "Servicecontract position data
        vedkn,                         "Servicecontract head notice data
        vedpn,                         "Servicecontract pos. notice data
        riserls,                       "Serialnumbers
        komser,                        "Serialnumbers for print
        tvbur,                         "Sales office
        tvko,                          "Sales organisation
        adrs,                          "Communicationarea for Address
        fpltdr,                        "billing schedules
        knvk,                          "PARTNER FUNCTION
        vbpa,
        pa0001,

        wtad_addis_in_so_print,        "additional
        wtad_buying_print_extra_text.  "texts belonging to additional
INCLUDE rvadtabl.
INCLUDE rvdirekt.
INCLUDE vedadata.

* data for access to central address maintenance
INCLUDE sdzavdat.

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
TYPE-POOLS: addi.

DATA price_print_mode(1) TYPE c.       "Print-mode
DATA: retcode   LIKE sy-subrc.         "Returncode
DATA: repeat(1) TYPE c.
DATA: xscreen(1) TYPE c.               "Output on printer or screen
DATA: BEGIN OF steu,                   "Controldata for output
        vdkex(1) TYPE c,
        vdpex(1) TYPE c,
        kbkex(1) TYPE c,
        kbpex(1) TYPE c,
      END OF steu.
DATA: va_parnr(4), va_vrtnr(4), va_person(20).


DATA: BEGIN OF tvbdpa OCCURS 0.        "Internal table for items
        INCLUDE STRUCTURE vbdpa.
DATA: END OF tvbdpa.

DATA: BEGIN OF tvbak OCCURS 50.
        INCLUDE STRUCTURE vbak.
DATA: END OF tvbak.


DATA: BEGIN OF tkomv OCCURS 50.
        INCLUDE STRUCTURE komv.
DATA: END OF tkomv.

DATA: BEGIN OF tkomvd OCCURS 50.
        INCLUDE STRUCTURE komvd.
DATA: END OF tkomvd.

DATA: BEGIN OF tvbdpau OCCURS 5.
        INCLUDE STRUCTURE vbdpau.
DATA: END   OF tvbdpau.

DATA: BEGIN OF tkomcon OCCURS 50.
        INCLUDE STRUCTURE conf_out.
DATA: END   OF tkomcon.

DATA: BEGIN OF tkomservh OCCURS 1.
        INCLUDE STRUCTURE vedka.
DATA: END   OF tkomservh.

DATA: BEGIN OF tkomservp OCCURS 5.
        INCLUDE STRUCTURE vedpa.
DATA: END   OF tkomservp.

DATA: BEGIN OF tkomservhn OCCURS 5.
        INCLUDE STRUCTURE vedkn.
DATA: END   OF tkomservhn.

DATA: BEGIN OF tkomservpn OCCURS 5.
        INCLUDE STRUCTURE vedpn.
DATA: END   OF tkomservpn.

DATA: BEGIN OF tkomser OCCURS 5.
        INCLUDE STRUCTURE riserls.
DATA: END   OF tkomser.

DATA: BEGIN OF tkomser_print OCCURS 5.
        INCLUDE STRUCTURE komser.
DATA: END   OF tkomser_print.

DATA: BEGIN OF tfpltdr OCCURS 5.
        INCLUDE STRUCTURE fpltdr.
DATA: END   OF tfpltdr.

DATA: taddi_print TYPE addi_so_print_itab WITH HEADER LINE.
DATA: v_company(30),
      v_address(30),
      v_name1 LIKE kna1-name1,
      v_name2 LIKE kna1-name2,
      v_name3 LIKE kna1-name3,
      v_name4 LIKE kna1-name4,
      v_city(20).

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DATA: pr_kappl(01)   TYPE c VALUE 'V'. "Application for pricing

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

*&---------------------------------------------------------------------*
*&      Form  entry
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RETURN_CODE  text
*      -->US_SCREEN    text
*----------------------------------------------------------------------*
FORM entry USING return_code us_screen.

  CLEAR retcode.
  xscreen = us_screen.
  PERFORM processing.
  IF retcode NE 0.
    return_code = 1.
  ELSE.
    return_code = 0.
  ENDIF.

ENDFORM.                    "ENTRY

*---------------------------------------------------------------------*
*       FORM PROCESSING                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM processing.

  PERFORM get_data.
  CHECK retcode = 0.
  PERFORM form_open USING xscreen vbdka-land1.
  CHECK retcode = 0.
  PERFORM form_title_print.
  CHECK retcode = 0.
  PERFORM validity_print.
  CHECK retcode = 0.
  PERFORM header_data_print.
  CHECK retcode = 0.
  PERFORM header_serv_print.
  CHECK retcode = 0.
  PERFORM header_notice_print.
  CHECK retcode = 0.
  PERFORM header_inter_print.
  CHECK retcode = 0.
  PERFORM header_text_print.
  CHECK retcode = 0.
  PERFORM item_print.
  CHECK retcode = 0.
  PERFORM end_print.
  CHECK retcode = 0.
  PERFORM form_close.
  CHECK retcode = 0.

ENDFORM.                    "PROCESSING

***********************************************************************
*       S U B R O U T I N E S                                         *
***********************************************************************

*---------------------------------------------------------------------*
*       FORM ALTERNATIVE_ITEM                                         *
*---------------------------------------------------------------------*
*       A text is printed, if the item is an alternative item.        *
*---------------------------------------------------------------------*

FORM alternative_item.

  CHECK vbdpa-grpos CN '0'.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ALTERNATIVE_ITEM'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "ALTERNATIVE_ITEM

*---------------------------------------------------------------------*
*       FORM CHECK_REPEAT                                             *
*---------------------------------------------------------------------*
*       A text is printed, if it is a repeat print for the document.  *
*---------------------------------------------------------------------*

FORM check_repeat.

  CLEAR repeat.
  SELECT * INTO *nast FROM nast WHERE kappl = nast-kappl
                                AND   objky = nast-objky
                                AND   kschl = nast-kschl
                                AND   spras = nast-spras
                                AND   parnr = nast-parnr
                                AND   parvw = nast-parvw
                                AND   nacha BETWEEN '1' AND '4'.
    CHECK *nast-vstat = '1'.
    repeat = 'X'.
    EXIT.
  ENDSELECT.

ENDFORM.                    "CHECK_REPEAT

*---------------------------------------------------------------------*
*       FORM DELIVERY_DATE                                            *
*---------------------------------------------------------------------*
*       If the delivery date in the item is different to the header   *
*       date and there are no scheduled quantities, the delivery date *
*       is printed in the item block.                                 *
*---------------------------------------------------------------------*

FORM delivery_date.

  IF vbdka-lfdat =  space AND
     vbdpa-lfdat NE space AND
     vbdpa-etenr_da = space.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'ITEM_DELIVERY_DATE'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

ENDFORM.                    "DELIVERY_DATE

*---------------------------------------------------------------------*
*       FORM DIFFERENT_CONSIGNEE                                      *
*---------------------------------------------------------------------*
*       If the consignee in the item is different to the header con-  *
*       signee, it is printed by this routine.                        *
*---------------------------------------------------------------------*

FORM different_consignee.

  CHECK vbdka-name1_we NE vbdpa-name1_we
    OR  vbdka-name2_we NE vbdpa-name2_we
    OR  vbdka-name3_we NE vbdpa-name3_we
    OR  vbdka-name4_we NE vbdpa-name4_we.
  CHECK vbdpa-name1_we NE space
    OR  vbdpa-name2_we NE space
    OR  vbdpa-name3_we NE space
    OR  vbdpa-name4_we NE space.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_CONSIGNEE'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "DIFFERENT_CONSIGNEE

*---------------------------------------------------------------------*
*       FORM DIFFERENT_REFERENCE_NO                                   *
*---------------------------------------------------------------------*
*       If the reference number in the item is different to the header*
*       reference number, it is printed by this routine.              *
*---------------------------------------------------------------------*

FORM different_reference_no.

  CHECK vbdpa-vbeln_vang NE vbdka-vbeln_vang
    OR  vbdpa-vbtyp_vang NE vbdka-vbtyp_vang.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_REFERENCE_NO'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "DIFFERENT_REFERENCE_NO

*---------------------------------------------------------------------*
*       FORM DIFFERENT_TERMS                                          *
*---------------------------------------------------------------------*
*       If the terms in the item are different to the header terms,   *
*       they are printed by this routine.                             *
*---------------------------------------------------------------------*
FORM different_terms.

  DATA: us_vposn   LIKE vedpa-vposn.
  DATA: us_text(1) TYPE c.             "Flag for Noticetext was printed

  IF vbdpa-zterm NE vbdka-zterm AND
     vbdpa-zterm NE space.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'ITEM_TERMS_OF_PAYMENT'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.
  IF vbdpa-inco1 NE space.
    IF vbdpa-inco1 NE vbdka-inco1 OR
       vbdpa-inco2 NE vbdka-inco2.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_TERMS_OF_DELIVERY'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDIF.
  ENDIF.

* Print different validity-data for the position
  READ TABLE tkomservp WITH KEY vbdpa-posnr.
  IF sy-subrc EQ 0.
    vedpa = tkomservp.
    IF vedpa-vbegdat NE space       AND
       vedpa-venddat NE space       AND
       NOT vedpa-vbegdat IS INITIAL AND
       NOT vedpa-venddat IS INITIAL.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_TERMS_OF_SERV1'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ELSEIF vedpa-vbegdat NE space AND
           NOT vedpa-vbegdat IS INITIAL.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_TERMS_OF_SERV2'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ELSE.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_TERMS_OF_SERV3'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDIF.
  ENDIF.

* Notice-rules for the positions.
  MOVE vbdpa-posnr TO us_vposn.
  CLEAR us_text.
  LOOP AT tkomservpn WHERE vposn = us_vposn.
    vedpn = tkomservpn.
    IF us_text IS INITIAL.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_TERMS_OF_NOTTXT'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
      us_text = charx.
    ENDIF.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'ITEM_TERMS_OF_NOTICE'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDLOOP.
  IF NOT us_text IS INITIAL.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'EMPTY_LINE'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

ENDFORM.                    "DIFFERENT_TERMS

*---------------------------------------------------------------------*
*       FORM END_PRINT                                                *
*---------------------------------------------------------------------*
*                                                                     *
*---------------------------------------------------------------------*

FORM end_print.

  PERFORM get_header_prices.

  CALL FUNCTION 'CONTROL_FORM'
    EXPORTING
      command = 'PROTECT'.

  PERFORM header_price_print.

  IF NOT price_print_mode EQ chara.
* Pricing data init
    CALL FUNCTION 'RV_PRICE_PRINT_GET_BUFFER'
      EXPORTING
        i_init   = charx
      TABLES
        t_tkomv  = tkomv
        t_tkomvd = tkomvd.

  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'END_VALUES'.
  CALL FUNCTION 'CONTROL_FORM'
    EXPORTING
      command = 'ENDPROTECT'.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'SUPPLEMENT_TEXT'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "END_PRINT

*---------------------------------------------------------------------*
*       FORM FORM_CLOSE                                               *
*---------------------------------------------------------------------*
*       End of printing the form                                      *
*---------------------------------------------------------------------*

FORM form_close.

  DATA da_clear_vbeln(1) TYPE c.

* bei Druckansicht im Anlegen gibt es noch keine Belegnummer - für die
* Anzeige temporäre Belegnummer übergeben und danach zurücknehmen, damit
* Folgeverarbeitung noch funktioniert
  IF vbdka-vbeln IS INITIAL.
    da_clear_vbeln = charx.
    vbdka-vbeln = '$000000001'.
  ENDIF.

  CALL FUNCTION 'CLOSE_FORM'
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
    retcode = 1.
  ENDIF.
  SET COUNTRY space.

  IF da_clear_vbeln EQ charx.
    CLEAR vbdka-vbeln.
  ENDIF.

ENDFORM.                    "FORM_CLOSE

*---------------------------------------------------------------------*
*       FORM FORM_OPEN                                                *
*---------------------------------------------------------------------*
*       Start of printing the form                                    *
*---------------------------------------------------------------------*
*  -->  US_SCREEN  Output on screen                                   *
*                  ' ' = printer                                      *
*                  'X' = screen                                       *
*  -->  US_COUNTRY County for telecommunication and SET COUNTRY       *
*---------------------------------------------------------------------*

FORM form_open USING us_screen us_country.

  INCLUDE rvadopfo.

ENDFORM.                    "FORM_OPEN

*---------------------------------------------------------------------*
*       FORM FORM_TITLE_PRINT                                         *
*---------------------------------------------------------------------*
*       Printing of the form title depending of the field VBTYP       *
*---------------------------------------------------------------------*

FORM form_title_print.

  CASE vbdka-vbtyp.
    WHEN 'A'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_A'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'B'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_B'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'C'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_C'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'E'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_E'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'F'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_F'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'G'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_F'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'H'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_H'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'K'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_K'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'L'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_L'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN OTHERS.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_OTHERS'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
  ENDCASE.
  IF repeat NE space.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'REPEAT'
        window  = 'REPEAT'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

ENDFORM.                    "FORM_TITLE_PRINT

*---------------------------------------------------------------------*
*       FORM GET_DATA                                                 *
*---------------------------------------------------------------------*
*       General provision of data for the form                        *
*---------------------------------------------------------------------*

FORM get_data.
  DATA: l_parnr LIKE vbpa-kunnr,
        l_vrtnr LIKE vbpa-pernr,
        l_person LIKE pa0001-sname.

  DATA: us_veda_vbeln     LIKE veda-vbeln.
  DATA: us_veda_posnr_low LIKE veda-vposn.

  DATA: da_mess LIKE vbfs OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'RV_PRICE_PRINT_GET_MODE'
    IMPORTING
      e_print_mode = price_print_mode.

  IF price_print_mode EQ chara.
    CALL FUNCTION 'RV_PRICE_PRINT_REFRESH'
      TABLES
        tkomv = tkomv.
  ENDIF.

  CLEAR komk.
  CLEAR komp.

  vbco3-mandt = sy-mandt.
  vbco3-spras = nast-spras.
  vbco3-vbeln = nast-objky.
  vbco3-kunde = nast-parnr.
  vbco3-parvw = nast-parvw.

  CALL FUNCTION 'RV_DOCUMENT_PRINT_VIEW'
    EXPORTING
      comwa                       = vbco3
    IMPORTING
      kopf                        = vbdka
    TABLES
      pos                         = tvbdpa
      mess                        = da_mess
    EXCEPTIONS
      fehler_bei_datenbeschaffung = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
    retcode = 1.
    EXIT.
  ELSE.
    LOOP AT da_mess.
      sy-msgid = da_mess-msgid.
      sy-msgno = da_mess-msgno.
      sy-msgty = da_mess-msgty.
      sy-msgv1 = da_mess-msgv1.
      sy-msgv2 = da_mess-msgv2.
      sy-msgv3 = da_mess-msgv3.
      sy-msgv4 = da_mess-msgv4.
      PERFORM protocol_update.
    ENDLOOP.
  ENDIF.

****
* Tambahan untuk output type kirim data json ke API TDN Midleware
*   VBDKA-vkorg = '8380'.
*   VBDKA-vkbur = '3800'
*   VBDKA-kunnr
*  Sebelum kirim cek dulu di table ZTDNSDDT014
  DATA: ld_bstkd LIKE vbkd-bstkd.
  DATA: gs_ztdnsddt014 TYPE ztdnsddt014.
  DATA: BEGIN OF order,
           kode_mp(10),
           kode_shop(10),
           no_order(35),
           no_so(10),
           tgl_so(10),
           no_dn(10),
           tgl_dn(10),
           no_ship(10),
           tgl_ship(10),
           no_bill(10),
           tgl_bill(10),
           ship_to(10),
           message(100),
           status(1),
       END  OF order.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        gv_json             TYPE string.

  "  TABLES: ztdnsddt014.
******* Diremark karna pada perform f_post_data(ztdnit_i001) ( untuk programnya tidak pernah dinaikan ke PRD ) - 28 02 2024
*******  IF vbdka-vkorg = '8380' AND vbdka-vkbur = '3800'.
*******    SELECT SINGLE bstkd INTO ld_bstkd FROM vbkd WHERE vbeln = vbdka-vbeln.
*******    IF sy-subrc EQ 0.
*******      SELECT SINGLE * INTO gs_ztdnsddt014 FROM ztdnsddt014 WHERE kdacct = 'SHOPEE' AND bstkd = ld_bstkd.
*******      IF sy-subrc EQ 0.
*******        order-kode_mp = gs_ztdnsddt014-kode_mp.
*******        order-kode_shop = gs_ztdnsddt014-kode_shop.
*******        order-no_order = gs_ztdnsddt014-bstkd.
*******        order-no_so = vbdka-vbeln.
*******        order-tgl_so = vbdka-audat.
*******        CLEAR: order-message, gs_ztdnsddt014-zmessage.
*******        order-status = 'S'.
*******        gs_ztdnsddt014-vbeln = vbdka-vbeln.
*******        gs_ztdnsddt014-status = '53'.
*******        MODIFY ztdnsddt014 FROM gs_ztdnsddt014.
*******        CREATE OBJECT cl_json_data
*******          EXPORTING
*******            DATA = order.
*******        cl_json_data->serialize( ).
*******        gv_json = cl_json_data->get_data( ).
*******        PERFORM f_post_data(ztdnit_i001) USING gv_json 'TORDER'.
*******      ENDIF.
*******    ENDIF.
*******  ENDIF.


* fill address key --> necessary for emails
  addr_key-addrnumber = vbdka-adrnr.
  addr_key-persnumber = vbdka-adrnp.
  addr_key-addr_type  = vbdka-address_type.

* Fetch servicecontract-data and notice-data for head and position.
  us_veda_vbeln     = vbdka-vbeln.
  us_veda_posnr_low = posnr_low.
  CALL FUNCTION 'SD_VEDA_GET_PRINT_DATA'
    EXPORTING
      i_document_number = us_veda_vbeln
      i_language        = sy-langu
      i_posnr_low       = us_veda_posnr_low
    TABLES
      print_data_pos    = tkomservp
      print_data_head   = tkomservh
      print_notice_pos  = tkomservpn
      print_notice_head = tkomservhn.

  PERFORM get_controll_data.

  PERFORM sender.
  PERFORM check_repeat.
  PERFORM tvbdpau_create.
***********************************SALESMAN CODE***********************


  SELECT SINGLE kunnr INTO l_parnr FROM vbpa
                WHERE vbeln EQ vbdka-vbeln AND
                               parvw EQ 'ZS'.
  SELECT SINGLE pernr INTO l_vrtnr FROM vbpa
            WHERE vbeln EQ vbdka-vbeln AND
                           parvw EQ 'VE'.


  SELECT SINGLE sname INTO l_person FROM pa0001
  WHERE pernr EQ l_vrtnr.
  WRITE l_parnr+6(4) TO va_parnr.
  WRITE l_vrtnr+4(4) TO va_vrtnr.
  va_person = l_person.


*ELECT SINGLE FROM VBPA


ENDFORM.                    "GET_DATA

*---------------------------------------------------------------------*
*       FORM GET_ITEM_BILLING_SCHEDULES                               *
*---------------------------------------------------------------------*
*       In this routine the billing schedules are fetched from the    *
*       database.                                                     *
*---------------------------------------------------------------------*

FORM get_item_billing_schedules.

  REFRESH tfpltdr.
  CHECK NOT vbdpa-fplnr IS INITIAL.

  CALL FUNCTION 'BILLING_SCHED_PRINTVIEW_READ'
    EXPORTING
      i_fplnr    = vbdpa-fplnr
      i_language = nast-spras
      i_vbeln    = vbdka-vbeln
    TABLES
      zfpltdr    = tfpltdr.

ENDFORM.                    "GET_ITEM_BILLING_SCHEDULES

*&---------------------------------------------------------------------*
*&      Form  ITEM_BILLING_SCHEDULES_PRINT
*&---------------------------------------------------------------------*
*       This routine prints the billing shedules of a salesdocument    *
*       position.                                                      *
*----------------------------------------------------------------------*
FORM  item_billing_schedules_print.

  DATA: first_line(1) TYPE c.

  first_line = charx.
  LOOP AT tfpltdr.
    fpltdr = tfpltdr.
*   Output of the following printlines
    IF NOT fpltdr-perio IS INITIAL.
*     periodische Fakturen
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_BILLING_SCHEDULE_PERIODIC'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
*     bei periodischen nur eine Zeile
      EXIT.
    ELSEIF fpltdr-fareg CA '14'.
*     prozentuale Teilfakturierung
      IF NOT first_line IS INITIAL.
        CLEAR first_line.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_BILLING_SCHEDULE_PERCENT_HEADER'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ELSE.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_BILLING_SCHEDULE_PERCENT'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    ELSEIF fpltdr-fareg CA '235'.
*     wertmäßige  Teilfakturierung
      IF NOT first_line IS INITIAL.
        CLEAR first_line.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_BILLING_SCHEDULE_VALUE_HEADER'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ELSE.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_BILLING_SCHEDULE_VALUE'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    ELSEIF fpltdr-fareg CA '3'.
*     Schlußrechnung
    ENDIF.
  ENDLOOP.
ENDFORM.                    "ITEM_BILLING_SCHEDULES_PRINT
*eject

*&---------------------------------------------------------------------*
*&      FORM  GET_ITEM_ADDIS
*&---------------------------------------------------------------------*
*       Additionals data are fetched from database
*----------------------------------------------------------------------*
FORM get_item_addis.

  CLEAR: taddi_print.

  CALL FUNCTION 'WTAD_ADDIS_IN_SO_PRINT'
       EXPORTING
            fi_vbeln              = vbdka-vbeln
            fi_posnr              = vbdpa-posnr
*           FI_LANGUAGE           = SY-LANGU
       TABLES
            fet_addis_in_so_print = taddi_print
       EXCEPTIONS
            addis_not_active      = 1
            no_addis_for_so_item  = 2
            OTHERS                = 3.

ENDFORM.                               " GET_ITEM_ADDIS

*---------------------------------------------------------------------*
*       FORM GET_ITEM_CHARACTERISTICS                                 *
*---------------------------------------------------------------------*
*       In this routine the configuration data item is fetched from   *
*       the database.                                                 *
*---------------------------------------------------------------------*

FORM get_item_characteristics.

  DATA da_t_cabn LIKE cabn OCCURS 10 WITH HEADER LINE.
  DATA: BEGIN OF da_key,
          mandt LIKE cabn-mandt,
          atinn LIKE cabn-atinn,
        END   OF da_key.

  REFRESH tkomcon.
  CHECK NOT vbdpa-cuobj IS INITIAL AND
            vbdpa-attyp NE var_typ.

  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      instance      = vbdpa-cuobj
      language      = nast-spras
      print_sales   = charx
    TABLES
      configuration = tkomcon
    EXCEPTIONS
      OTHERS        = 4.

  RANGES : da_in_cabn FOR da_t_cabn-atinn.
* Beschreibung der Merkmale wegen Objektmerkmalen auf sdcom-vkond holen
  CLEAR da_in_cabn. REFRESH da_in_cabn.
  LOOP AT tkomcon.
    da_in_cabn-option = 'EQ'.
    da_in_cabn-sign   = 'I'.
    da_in_cabn-low    = tkomcon-atinn.
    APPEND da_in_cabn.
  ENDLOOP.

  CLEAR da_t_cabn. REFRESH da_t_cabn.
  CALL FUNCTION 'CLSE_SELECT_CABN'
*    EXPORTING
*         KEY_DATE                     = SY-DATUM
*         BYPASSING_BUFFER             = ' '
*         WITH_PREPARED_PATTERN        = ' '
*         I_AENNR                      = ' '
*    IMPORTING
*         AMBIGUOUS_OBJ_CHARACTERISTIC =
     TABLES
          in_cabn                      = da_in_cabn
          t_cabn                       = da_t_cabn
     EXCEPTIONS
          no_entry_found               = 1
          OTHERS                       = 2.

* Preisfindungsmerkmale / Merkmale auf VCSD_UPDATE herausnehmen
  SORT da_t_cabn.
  LOOP AT tkomcon.
    da_key-mandt = sy-mandt.
    da_key-atinn = tkomcon-atinn.
    READ TABLE da_t_cabn WITH KEY da_key BINARY SEARCH.
    IF sy-subrc <> 0 OR
       ( ( da_t_cabn-attab = 'SDCOM' AND
          da_t_cabn-atfel = 'VKOND'       ) OR
        ( da_t_cabn-attab = 'VCSD_UPDATE' ) ) .
      DELETE tkomcon.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "GET_ITEM_CHARACTERISTICS

*---------------------------------------------------------------------*
*       FORM GET_ITEM_PRICES                                          *
*---------------------------------------------------------------------*
*       In this routine the price data for the item is fetched from   *
*       the database.                                                 *
*---------------------------------------------------------------------*

FORM get_item_prices.

  CLEAR: komp,
         tkomv.

  IF komk-knumv NE vbdka-knumv OR
     komk-knumv IS INITIAL.
    CLEAR komk.
    komk-mandt = sy-mandt.
    komk-kalsm = vbdka-kalsm.
    komk-kappl = pr_kappl.
    komk-waerk = vbdka-waerk.
    komk-knumv = vbdka-knumv.
    komk-knuma = vbdka-knuma.
    komk-vbtyp = vbdka-vbtyp.
    komk-land1 = vbdka-land1.
    komk-vkorg = vbdka-vkorg.
    komk-vtweg = vbdka-vtweg.
    komk-spart = vbdka-spart.
    komk-bukrs = vbdka-bukrs_vf.
    komk-hwaer = vbdka-waers.
    komk-prsdt = vbdka-erdat.
    komk-kurst = vbdka-kurst.
    komk-kurrf = vbdka-kurrf.
    komk-kurrf_dat = vbdka-kurrf_dat.
  ENDIF.
  komp-kposn = vbdpa-posnr.
  komp-kursk = vbdpa-kursk.
  komp-kursk_dat = vbdpa-kursk_dat.
  IF vbdka-vbtyp CA 'HKNOT6'.
    IF vbdpa-shkzg CA ' A'.
      komp-shkzg = 'X'.
    ENDIF.
  ELSE.
    IF vbdpa-shkzg CA 'BX'.
      komp-shkzg = 'X'.
    ENDIF.
  ENDIF.

  IF price_print_mode EQ chara.
    CALL FUNCTION 'RV_PRICE_PRINT_ITEM'
      EXPORTING
        comm_head_i = komk
        comm_item_i = komp
        language    = nast-spras
      IMPORTING
        comm_head_e = komk
        comm_item_e = komp
      TABLES
        tkomv       = tkomv
        tkomvd      = tkomvd.
  ELSE.
    CALL FUNCTION 'RV_PRICE_PRINT_ITEM_BUFFER'
      EXPORTING
        comm_head_i = komk
        comm_item_i = komp
        language    = nast-spras
      IMPORTING
        comm_head_e = komk
        comm_item_e = komp
      TABLES
        tkomv       = tkomv
        tkomvd      = tkomvd.
  ENDIF.

ENDFORM.                    "GET_ITEM_PRICES

*---------------------------------------------------------------------*
*       FORM GET_HEADER_PRICES                                        *
*---------------------------------------------------------------------*
*       In this routine the price data for the header is fetched from *
*       the database.                                                 *
*---------------------------------------------------------------------*

FORM get_header_prices.

  LOOP AT tvbdpa.

    CALL FUNCTION 'SD_TAX_CODE_MAINTAIN'
      EXPORTING
        key_knumv           = vbdka-knumv
        key_kposn           = tvbdpa-posnr
        i_application       = ' '
        i_pricing_procedure = vbdka-kalsm
      TABLES
        xkomv               = tkomv.


  ENDLOOP.

  IF price_print_mode EQ chara.
    CALL FUNCTION 'RV_PRICE_PRINT_HEAD'
      EXPORTING
        comm_head_i = komk
        language    = nast-spras
      IMPORTING
        comm_head_e = komk
      TABLES
        tkomv       = tkomv
        tkomvd      = tkomvd.
  ELSE.
    CALL FUNCTION 'RV_PRICE_PRINT_HEAD_BUFFER'
      EXPORTING
        comm_head_i = komk
        language    = nast-spras
      IMPORTING
        comm_head_e = komk
      TABLES
        tkomv       = tkomv
        tkomvd      = tkomvd.
  ENDIF.

ENDFORM.                    "GET_HEADER_PRICES

*&---------------------------------------------------------------------*
*&      Form  HEADER_DATA_PRINT
*&---------------------------------------------------------------------*
*       Printing of header data like terms, weights ....               *
*----------------------------------------------------------------------*

FORM header_data_print.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER_DATA'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                               " HEADER_DATA_PRINT

*---------------------------------------------------------------------*
*       FORM HEADER_PRICE_PRINT                                       *
*---------------------------------------------------------------------*
*       Printout of the header prices                                 *
*---------------------------------------------------------------------*

FORM header_price_print.

  LOOP AT tkomvd.

    AT FIRST.
      IF komk-supos NE 0.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_SUM'.
      ELSE.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'UNDER_LINE'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    ENDAT.

    komvd = tkomvd.
    IF komvd-koaid = 'D'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TAX_LINE'.
    ELSE.
      IF NOT komvd-kntyp EQ 'f'.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'SUM_LINE'.
      ENDIF.
    ENDIF.
  ENDLOOP.



  DESCRIBE TABLE tkomvd LINES sy-tfill.
  IF sy-tfill = 0.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'UNDER_LINE'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.

  ENDIF.
ENDFORM.                    "HEADER_PRICE_PRINT

*---------------------------------------------------------------------*
*       FORM HEADER_TEXT_PRINT                                        *
*---------------------------------------------------------------------*
*       Printout of the headertexts                                   *
*---------------------------------------------------------------------*

FORM header_text_print.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER_TEXT'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "HEADER_TEXT_PRINT

*---------------------------------------------------------------------*
*       FORM ITEM_BILLING_CORRECTION_HEADER                          *
*---------------------------------------------------------------------*
*       In the case of a billing correction, the header of the item   *
*       debit memo / credit memo position, is printed by this routine *
*---------------------------------------------------------------------*

FORM item_billing_correction_header USING us_ganf us_lanf.


  CHECK vbdka-vbklt EQ vbklt_rech_korr.

  IF vbdka-vbtyp = vbtyp_ganf.
*   Gutschriftsanforderung
    IF vbdpa-shkzg = charx.
      IF us_ganf IS INITIAL.
        MOVE charx TO us_ganf.
        MOVE space TO us_lanf.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'CORRECTION_TEXT_K'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    ELSE.
      IF us_lanf IS INITIAL.
        MOVE charx TO us_lanf.
        MOVE space TO us_ganf.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'CORRECTION_TEXT_L'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF vbdka-vbtyp = vbtyp_lanf.
*   Lastschriftssanforderung
    IF vbdpa-shkzg = space.
      IF us_lanf IS INITIAL.
        MOVE charx TO us_lanf.
        MOVE space TO us_ganf.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'CORRECTION_TEXT_L'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    ELSE.
      IF us_ganf IS INITIAL.
        MOVE charx TO us_ganf.
        MOVE space TO us_lanf.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'CORRECTION_TEXT_K'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "ITEM_BILLING_CORRECTION_HEADER
*&---------------------------------------------------------------------*
*&      Form  ITEM_ADDIS_PRINT
*&---------------------------------------------------------------------*
*       Printout of item additionals
*----------------------------------------------------------------------*
FORM item_addis_print.

  LOOP AT taddi_print.
    MOVE-CORRESPONDING taddi_print TO wtad_addis_in_so_print.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'ITEM_ADDI_SO_INFO'
      EXCEPTIONS
        OTHERS  = 1.
    LOOP AT taddi_print-addi_so_extra_text_info
            INTO wtad_buying_print_extra_text.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_ADDI_EXTRA_TEXT'
        EXCEPTIONS
          OTHERS  = 1.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                               " ITEM_ADDIS_PRINT
*---------------------------------------------------------------------*
*       FORM ITEM_CHARACERISTICS_PRINT                                *
*---------------------------------------------------------------------*
*       Printout of the item characteristics -> configuration         *
*---------------------------------------------------------------------*

FORM item_characteristics_print.

  LOOP AT tkomcon.
    conf_out = tkomcon.
    IF sy-tabix = 1.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_CONFIGURATION_HEADER'
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ELSE.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_CONFIGURATION'
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "ITEM_CHARACTERISTICS_PRINT

*---------------------------------------------------------------------*
*       FORM ITEM_DELIVERY_CONFIRMATION                               *
*---------------------------------------------------------------------*
*       If the delivery date is not confirmed, a text is printed      *
*---------------------------------------------------------------------*

FORM item_delivery_confirmation.

  CHECK vbdka-vbtyp NE vbtyp_ganf AND vbdka-vbtyp NE vbtyp_lanf.
  CHECK vbdpa-lfdat = space.
  CHECK vbdpa-kwmeng NE 0.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_DELIVERY_CONFIRMATION'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "ITEM_DELIVERY_CONFIRMATION
*---------------------------------------------------------------------*
*       FORM ITEM_AGREED_DELIVERY_TIME                                *
*---------------------------------------------------------------------*
*       If an agreed delivery time and the corresponding text is      *
*       available on item level, the text is printed                  *
*---------------------------------------------------------------------*

FORM item_agreed_delivery_time.

  CHECK vbdka-vbtyp EQ 'B' OR vbdka-vbtyp EQ 'G'.
  CHECK vbdpa-delco NE space AND vbdpa-delco_bez NE space.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_AGREED_DELIVERY_TIME'
    EXCEPTIONS
      element = 1
      window  = 2.

  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "ITEM_AGREED_DELIVERY_TIME

*---------------------------------------------------------------------*
*       FORM ITEM_PRICE_PRINT                                         *
*---------------------------------------------------------------------*
*       Printout of the item prices                                   *
*---------------------------------------------------------------------*

FORM item_price_print.

  DATA: ld_kschl LIKE komvd-kschl,
        ld_kbetr(6),
        ld_kwert LIKE komvd-kwert,
        ld_vtext LIKE komvd-vtext,
        ld_zgrpack LIKE zspaket_disc-zgrpack,
        ld_konda LIKE komk-konda,
        ld_prsdt    TYPE date.

  DATA : lv_kschl(2).

  DATA: lv_fieldname  TYPE string.
  FIELD-SYMBOLS <fs>  TYPE ANY.

  LOOP AT tkomvd.
    komvd = tkomvd.
    IF
*      ADDED
      komvd-kschl EQ 'ZD14' OR
      komvd-kschl EQ 'ZD15' OR

       komvd-kschl EQ 'ZA01' OR
       komvd-kschl EQ 'ZA02' OR
       komvd-kschl EQ 'ZB01' OR
       komvd-kschl EQ 'ZB02' OR
       komvd-kschl EQ 'ZC01' OR
       komvd-kschl EQ 'ZC02' OR
       komvd-kschl EQ 'ZC03' OR
       komvd-kschl EQ 'ZC04' OR
       komvd-kschl EQ 'ZD01' OR
       komvd-kschl EQ 'ZD02' OR
       komvd-kschl EQ 'ZD03' OR
       komvd-kschl EQ 'ZD05' OR
       komvd-kschl EQ 'ZD06' OR
       komvd-kschl EQ 'ZD08' OR
       komvd-kschl EQ 'ZD09' OR
       komvd-kschl EQ 'ZDDC' OR
       komvd-kschl EQ 'ZE01' OR
       komvd-kschl EQ 'ZE02' OR
       komvd-kschl EQ 'ZE03' OR
       komvd-kschl EQ 'ZE04' OR
       komvd-kschl EQ 'ZE05' OR
       komvd-kschl EQ 'ZE06' OR
       komvd-kschl EQ 'ZE07' OR
       komvd-kschl EQ 'ZE08' OR
       komvd-kschl EQ 'ZE09' OR
       komvd-kschl EQ 'ZE10' OR
       komvd-kschl EQ 'ZF01' OR
       komvd-kschl EQ 'ZF02' OR
       komvd-kschl EQ 'ZF03' OR
       komvd-kschl EQ 'ZF04' OR
       komvd-kschl EQ 'ZF06' OR
       komvd-kschl EQ 'ZF07' OR
       komvd-kschl EQ 'ZF08' OR
       komvd-kschl EQ 'ZF09' OR
       komvd-kschl EQ 'ZF10' OR
*      ADDED
      komvd-kschl EQ 'ZF11' OR
      komvd-kschl EQ 'ZF12' OR

       komvd-kschl EQ 'ZF05' OR
       komvd-kschl EQ 'ZV01' OR
       komvd-kschl EQ 'ZN01' OR
       komvd-kschl EQ 'ZDA1' OR
       komvd-kschl EQ 'ZFA1' OR
       komvd-kschl EQ 'ZA0Z' OR
       komvd-kschl EQ 'ZB0Z' OR
       komvd-kschl EQ 'ZC0Z' OR
       komvd-kschl EQ 'ZD0Z' OR
*       KOMVD-KSCHL EQ 'ZD2Z' OR
       komvd-kschl EQ 'ZDDZ' OR
       komvd-kschl EQ 'ZDD2' OR
       komvd-kschl EQ 'ZDF2' OR
       komvd-kschl EQ 'ZE0Z' OR
       komvd-kschl EQ 'ZF0Z' OR
       komvd-kschl EQ 'ZV0Z' OR
       komvd-kschl EQ 'ZN0Z' OR
       komvd-kschl EQ 'ZD10' OR
       komvd-kschl EQ 'ZD11' OR
       komvd-kschl EQ 'ZD12' OR
       komvd-kschl EQ 'ZE11' OR
       komvd-kschl EQ 'ZE12' OR
       komvd-kschl EQ 'ZE13' OR
       komvd-kschl EQ 'ZE14' OR
       komvd-kschl EQ 'ZE15' OR
       komvd-kschl EQ 'ZE16' OR
       komvd-kschl EQ 'ZE17' OR
       komvd-kschl EQ 'ZE18' OR
       komvd-kschl EQ 'ZE19' OR
       komvd-kschl EQ 'ZE20' OR
       komvd-kschl EQ space AND komvd-stunr EQ '030'.

      IF sy-tabix = 1 AND
       ( komvd-koaid = charb OR
         komvd-kschl = space ).
        ld_kwert = komvd-kwert.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_LINE_PRICE_QUANTITY'.
      ELSE.
        IF  komvd-kntyp NE 'f' .

          IF komvd-kschl = 'ZD06'.
            komvd-koein = '%'.
            komvd-koei1 = '%'.
            komvd-kbetr = komvd-kwert * 10000 / ld_kwert.
            CLEAR: komvd-kpein,komvd-kmein.
*             ELSE.
*               KOMVD-KBETR = KOMVD-KBETR / 10.
          ENDIF.

* Req. by Popo 12/02/2013
* Read ZSPAKET_DISC
*             CONCATENATE KOMVD-KSCHL+1(1) KOMVD-KSCHL+3(1) INTO LD_KSCHL.  "Pindah ke bawah
*             KOMVD-KSCHL = LD_KSCHL.

          IF komvd-kschl BETWEEN 'ZE01' AND 'ZE20' OR
             komvd-kschl = 'ZC01'.

            CLEAR: ld_vtext,ld_zgrpack,ld_prsdt.
*               IF komvd-kschl = 'ZE01'.
*            lv_fieldname = '(SAPMV45A)tkomp-zgrpack'.
*            ASSIGN (lv_fieldname) TO <fs>.
*            ld_zgrpack = <fs>.
*               ENDIF.

            lv_fieldname = '(SAPMV45A)tkomk-prsdt'.
            ASSIGN (lv_fieldname) TO <fs>.
            ld_prsdt = <fs>.

            lv_fieldname = '(SAPMV45A)tkomk-konda'.
            ASSIGN (lv_fieldname) TO <fs>.
            ld_konda = <fs>.

            ld_vtext = komvd-vtext.
*            SELECT SINGLE descr INTO komvd-vtext
*              FROM zspaket_disc
*              WHERE vkorg = vbdka-vkorg AND
*                    kschl = komvd-kschl AND
*                    konda = ''          AND
*                    zgrpack = ld_zgrpack AND
*                    ( datab LE ld_prsdt AND datbi GE ld_prsdt ).

            DATA: ld_mvgr2 LIKE zspaket-mvgr2.
            IF komvd-kschl = 'ZC01' OR komvd-kschl = 'ZE01'.
              SELECT SINGLE mvgr2 INTO ld_mvgr2
                FROM zspaket
                WHERE vkorg = vbdka-vkorg
                  AND matnr = vbdpa-matnr
                  AND ( datab LE ld_prsdt AND datbi GE ld_prsdt )
                  AND mvgr2 LIKE '5%'.
              IF sy-subrc = 0.
                ld_zgrpack = ld_mvgr2+1(1).
              ELSE.
                ld_zgrpack = '0'.
              ENDIF.
            ENDIF.

            CASE komvd-kschl.
              WHEN 'ZC01'.
                SELECT SINGLE descr INTO komvd-vtext
                  FROM zspaket_disc
                  WHERE vkorg = vbdka-vkorg AND
                        kschl = komvd-kschl AND
                        konda = ld_konda    AND
                        zgrpack = ld_zgrpack AND
                        ( datab LE ld_prsdt AND datbi GE ld_prsdt ).
              WHEN 'ZE01'.
                SELECT SINGLE descr INTO komvd-vtext
                  FROM zspaket_disc
                  WHERE vkorg = vbdka-vkorg AND
                        kschl = komvd-kschl AND
                        zgrpack = ld_zgrpack AND
                        ( datab LE ld_prsdt AND datbi GE ld_prsdt ).
              WHEN OTHERS.
                SELECT SINGLE descr INTO komvd-vtext
                  FROM zspaket_disc
                  WHERE vkorg = vbdka-vkorg AND
                        kschl = komvd-kschl AND
                        ( datab LE ld_prsdt AND datbi GE ld_prsdt ).
            ENDCASE.

            IF sy-subrc IS NOT INITIAL.
              CLEAR komvd-vtext.
            ENDIF.
          ELSE.
            CLEAR komvd-vtext.
          ENDIF.

          IF komvd-vtext IS INITIAL.
            lv_kschl  = komvd-kschl+2(2).
            SHIFT lv_kschl LEFT DELETING LEADING '0'.
            CONCATENATE komvd-kschl+1(1) lv_kschl INTO ld_kschl.
            komvd-kschl = ld_kschl.
            CLEAR komvd-vtext.
            komvd-vtext = ld_kschl.
          ENDIF.
* End req. by Popo 12/02/2013

          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'ITEM_LINE_PRICE_TEXT'.
        ELSE.
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'ITEM_LINE_REBATE_IN_KIND'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "ITEM_PRICE_PRINT

*---------------------------------------------------------------------*
*       FORM ITEM_PRINT                                               *
*---------------------------------------------------------------------*
*       Printout of the items                                         *
*---------------------------------------------------------------------*

FORM item_print.

  DATA: da_subrc LIKE sy-subrc,
        da_dragr LIKE tvag-dragr.
  DATA: da_ganf(1) TYPE c,      "Print flag for billing correction
        da_lanf(1) TYPE c.      "Print flag for billing correction

  CALL FUNCTION 'WRITE_FORM'           "First header
       EXPORTING  element = 'ITEM_HEADER'
       EXCEPTIONS OTHERS  = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
  CALL FUNCTION 'WRITE_FORM'           "Activate header
       EXPORTING  element = 'ITEM_HEADER'
                  type    = 'TOP'
       EXCEPTIONS OTHERS  = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

  LOOP AT tvbdpa.
    vbdpa = tvbdpa.
    IF tvbdpa-pstyv NE 'ZT9O'.
      IF vbdpa-dragr EQ space.           "Print rejected item?
        IF vbdpa-posnr_neu NE space.     "Item
          PERFORM item_billing_correction_header USING da_ganf da_lanf.
          PERFORM get_item_serials.
          PERFORM get_item_characteristics.
          PERFORM get_item_billing_schedules.
          PERFORM get_item_prices.
          PERFORM get_item_addis.
          CALL FUNCTION 'CONTROL_FORM'
            EXPORTING
              command = 'ENDPROTECT'.
          CALL FUNCTION 'CONTROL_FORM'
            EXPORTING
              command = 'PROTECT'.
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'ITEM_LINE'.
          PERFORM item_rejected.
          PERFORM item_price_print.
          PERFORM item_text_z002.
          CALL FUNCTION 'CONTROL_FORM'
            EXPORTING
              command = 'ENDPROTECT'.
          PERFORM item_text_print.
          PERFORM item_serials_print.
          PERFORM item_characteristics_print.
          PERFORM item_addis_print.
          PERFORM item_reference_billing.
          PERFORM alternative_item.
          PERFORM delivery_date.
          PERFORM item_delivery_confirmation.
          PERFORM item_agreed_delivery_time.
          PERFORM item_billing_schedules_print.
          PERFORM different_reference_no.
          PERFORM different_terms.
          PERFORM different_consignee.
          PERFORM schedule_header.
          PERFORM main_item.
        ELSE.
          PERFORM schedule_print.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'WRITE_FORM'           "Deactivate Header
       EXPORTING  element  = 'ITEM_HEADER'
                  function = 'DELETE'
                  type     = 'TOP'
       EXCEPTIONS OTHERS   = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "ITEM_PRINT
*---------------------------------------------------------------------*
*       FORM ITEM_REFERENCE_BILLING                                  *
*---------------------------------------------------------------------*
*       If the reference number of the billing is printed by this     *
*       routine. In case (debit memo / credit memo)                   *
*---------------------------------------------------------------------*

FORM item_reference_billing.

  CHECK vbdka-vbklt EQ vbklt_rech_korr.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_REFERENCE_BILLING'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "ITEM_REFERENCE_BILLING


*---------------------------------------------------------------------*
*       FORM ITEM_REJECTED                                            *
*---------------------------------------------------------------------*
*       A text is printed, if the item is rejected                    *
*---------------------------------------------------------------------*

FORM item_rejected.

  CHECK NOT vbdpa-abgru IS INITIAL.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_REJECTED'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "ITEM_REJECTED

*---------------------------------------------------------------------*
*       FORM MAIN_ITEM                                                *
*---------------------------------------------------------------------*
*       A text is printed, if the item is a main item                 *
*---------------------------------------------------------------------*

FORM main_item.

  LOOP AT tvbdpau INTO vbdpau
                  WHERE posnr EQ vbdpa-posnr.
    IF vbdpau-uposb IS INITIAL.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ONE_SUBITEM'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ELSE.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'SEVERAL_SUBITEMS'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "MAIN_ITEM

*---------------------------------------------------------------------*
*       FORM ITEM_TEXT_PRINT                                          *
*---------------------------------------------------------------------*
*       Printout of the item texts                                    *
*---------------------------------------------------------------------*

FORM item_text_print.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_TEXT'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "ITEM_TEXT_PRINT

*---------------------------------------------------------------------*
*       FORM PROTOCOL_UPDATE                                          *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*

FORM protocol_update.

  CHECK xscreen = space.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                    "PROTOCOL_UPDATE

*---------------------------------------------------------------------*
*       FORM SCHEDULE_HEADER                                          *
*---------------------------------------------------------------------*
*       If there are schedules in the item, then here is printed the  *
*       header for the schedules.                                     *
*---------------------------------------------------------------------*

FORM schedule_header.

  CHECK vbdpa-etenr_da NE space.
  CALL FUNCTION 'CONTROL_FORM'
    EXPORTING
      command = 'PROTECT'.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_SCHEDULE_HEADER'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "SCHEDULE_HEADER

*---------------------------------------------------------------------*
*       FORM SCHEDULE_PRINT                                           *
*---------------------------------------------------------------------*
*       This routine prints the schedules for an item.                *
*---------------------------------------------------------------------*

FORM schedule_print.

  CHECK vbdpa-lfrel EQ 'X'.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_SCHEDULE_PRINT'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "SCHEDULE_PRINT

*---------------------------------------------------------------------*
*       FORM SENDER                                                   *
*---------------------------------------------------------------------*
*       This routine determines the address of the sender (Table VKO) *
*---------------------------------------------------------------------*

FORM sender.

  SELECT SINGLE * FROM tvko  WHERE vkorg = vbdka-vkorg.
  IF sy-subrc NE 0.
    syst-msgid = 'VN'.
    syst-msgno = '203'.
    syst-msgty = 'E'.
    syst-msgv1 = 'TVKO'.
    syst-msgv2 = syst-subrc.
    PERFORM protocol_update.
    EXIT.
  ENDIF.
*  IF  VBDKA-VKORG = '8020'.
*      select single * from tVKO where vkorg = vbdka-vkorg.
*           select SINGLE * from adrc where ADDRNUMBER = tvko-adrnr.
*           MOVE ADRC-NAME1 TO V_COMPANY.
*           MOVE ADRC-NAME2 TO V_ADDRESS.
*           MOVE ADRC-NAME3 TO V_CITY.
*      V_COMPANY = 'PT.TEMPO JAKARTA'.
*      V_ADDRESS = 'JL HR RASUNA SAID KAV 3/4'.
*      V_CITY    = 'JAKARTA'.
*  ELSEIF VBDKA-VKORG = '8030'.
*      V_COMPANY = 'PT. EURINDO COMBINED'.
*      V_ADDRESS = 'JL HR RASUNA SAID KAV 11'..
*      V_CITY    = 'JAKARTA'.
*  ENDIF.

  CLEAR gv_fb_addr_get_selection.
  gv_fb_addr_get_selection-addrnumber = tvko-adrnr.         "SADR40A
  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = gv_fb_addr_get_selection
      address_group     = 'CA01'
    IMPORTING
      sadr              = sadr
    EXCEPTIONS
      OTHERS            = 01.
  IF sy-subrc NE 0.
    CLEAR sadr.
  ENDIF.                                                    "SADR40A
  vbdka-sland = sadr-land1.
  IF sy-subrc NE 0.
    syst-msgid = 'VN'.
    syst-msgno = '203'.
    syst-msgty = 'E'.
    syst-msgv1 = 'SADR'.
    syst-msgv2 = syst-subrc.
    PERFORM protocol_update.
  ENDIF.
  SELECT SINGLE * FROM tvbur  WHERE vkbur = vbdka-vkbur.
  IF sy-subrc NE 0.
    syst-msgid = 'VN'.
    syst-msgno = '203'.
    syst-msgty = 'E'.
    syst-msgv1 = 'TVBUR'.
    syst-msgv2 = syst-subrc.
    PERFORM protocol_update.
  ENDIF.

  SELECT SINGLE * FROM tvbur WHERE vkbur = vbdka-vkbur.
  SELECT SINGLE * FROM adrc WHERE addrnumber = tvbur-adrnr.
  MOVE adrc-name1 TO v_company.
  MOVE adrc-street TO v_address.
  MOVE adrc-city1 TO v_city.
  SELECT SINGLE name1 name2 name3 name4 INTO
               (v_name1, v_name2, v_name3, v_name4) FROM kna1
  WHERE kunnr EQ vbco3-kunde.

ENDFORM.                    "SENDER

*---------------------------------------------------------------------*
*       FORM TVBDPAU_CREATE                                           *
*---------------------------------------------------------------------*
*       This routine is creating a table which includes the subitem-  *
*       numbers                                                       *
*---------------------------------------------------------------------*

FORM tvbdpau_create.

  CLEAR tvbdpau.
  REFRESH tvbdpau.
  LOOP AT tvbdpa.
    IF tvbdpa-uepos IS INITIAL OR
       tvbdpa-uepos NE tvbdpau-posnr.
* Append work area to internal table TVBDPAU
      IF tvbdpau-uposv > 0.
        APPEND tvbdpau.
        CLEAR tvbdpau.
      ENDIF.
* Start filling new work area
      tvbdpau-posnr = tvbdpa-posnr.

      IF NOT tvbdpa-uepos IS INITIAL AND
         tvbdpa-uepos NE tvbdpau-posnr.
        tvbdpau-posnr = tvbdpa-uepos.
        tvbdpau-uepvw = tvbdpa-uepvw.
        tvbdpau-uposv = tvbdpa-posnr.
      ENDIF.

    ELSE.
      IF tvbdpau-uposv IS INITIAL OR
         tvbdpau-uposv > tvbdpa-posnr.
        tvbdpau-uposv = tvbdpa-posnr.
      ENDIF.
      IF tvbdpau-uposb < tvbdpa-posnr AND
         tvbdpau-uposv < tvbdpa-posnr.
        tvbdpau-uposb = tvbdpa-posnr.
      ENDIF.
      tvbdpau-uepvw = tvbdpa-uepvw.    "UPOS-Verwendung
    ENDIF.
  ENDLOOP.
  IF tvbdpau-uposv > 0.
    APPEND tvbdpau.
  ENDIF.
  SORT tvbdpau.

ENDFORM.                    "TVBDPAU_CREATE

*---------------------------------------------------------------------*
*       FORM VALIDITY_PRINT                                           *
*---------------------------------------------------------------------*
*       This routine is printing the period of validity for offers    *
*       and contracts                                                 *
*---------------------------------------------------------------------*

FORM validity_print.

  CHECK steu-vdkex EQ space.
  CASE vbdka-vbtyp.
    WHEN 'B'.
      IF vbdka-angdt CN '0' OR
         vbdka-bnddt CN '0'.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'VALIDITY_OFFER'
            window  = 'VALIDITY'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    WHEN 'E'.
      IF vbdka-guebg CN '0' OR
         vbdka-gueen CN '0'.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'VALIDITY_CONTRACT'
            window  = 'VALIDITY'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    WHEN 'F'.
      IF vbdka-guebg CN '0' OR
         vbdka-gueen CN '0'.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'VALIDITY_CONTRACT'
            window  = 'VALIDITY'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    WHEN 'G'.
      IF vbdka-guebg CN '0' OR
         vbdka-gueen CN '0'.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'VALIDITY_CONTRACT'
            window  = 'VALIDITY'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
  ENDCASE.

ENDFORM.                    "VALIDITY_PRINT

*&---------------------------------------------------------------------*
*&      Form  HEADER_NOTICE_PRINT
*&---------------------------------------------------------------------*
*       This routine prints the notice-rules of the contract-header.   *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header_notice_print.

  DATA: us_text(1) TYPE c.             "Kz. falls Text für Kündigungsbed.

* Kündigungsbedingungen auf Kopfebene.
  CLEAR us_text.
  LOOP AT tkomservhn.
    vedkn = tkomservhn.
    IF us_text IS INITIAL.
*     For the first time a headertext is printed.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'HEADER_TERMS_OF_NOTTXT'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
      us_text = charx.
    ENDIF.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'HEADER_TERMS_OF_NOTICE'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDLOOP.
* If notice-rules exists a empty line is printed.
  IF NOT us_text IS INITIAL.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'EMPTY_LINE'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

ENDFORM.                               " HEADER_NOTICE_PRINT
*eject

*&---------------------------------------------------------------------*
*&      Form  GET_ITEM_SERIALS
*&---------------------------------------------------------------------*
*       This routine give back the serialnumbers of salesdocument      *
*       position. The numbers are processed as print-lines in the      *
*       table KOMSER_PRINT.                                            *
*----------------------------------------------------------------------*
*  -->  US_VBELN  Salesdocument
*  -->  US_POSNR  Position of the salesdocument
*----------------------------------------------------------------------*
FORM get_item_serials.

  DATA: key_data LIKE rserob,
        sernos LIKE rserob OCCURS 0 WITH HEADER LINE.

  key_data-taser = 'SER02'.
  key_data-sdaufnr = vbdka-vbeln.
  key_data-posnr = vbdpa-posnr.
  IF key_data-sdaufnr IS INITIAL AND NOT
     key_data-posnr IS INITIAL.
* beim Anlegen ist Belegnummer leer - deshalb Dummy-Belegnummer
    key_data-sdaufnr = char$.
  ENDIF.

* Read the Serialnumbers of a Position.
  REFRESH: tkomser,
           tkomser_print.
  CALL FUNCTION 'GET_SERNOS_OF_DOCUMENT'
    EXPORTING
      key_data            = key_data
    TABLES
      sernos              = sernos
    EXCEPTIONS
      key_parameter_error = 1
      no_supported_access = 2
      no_data_found       = 3
      OTHERS              = 4.
  IF sy-subrc NE 0 AND
     sy-subrc NE 3.
    PERFORM protocol_update.
  ENDIF.

  CHECK sy-subrc EQ 0.
* Serialnummern übergeben
  tkomser-vbeln = sernos-sdaufnr.
  tkomser-posnr = sernos-posnr.
  LOOP AT sernos.
    tkomser-sernr = sernos-sernr.
    APPEND tkomser.
  ENDLOOP.

* Process the stringtable for Printing.
  CALL FUNCTION 'PROCESS_SERIALS_FOR_PRINT'
    EXPORTING
      i_boundary_left             = '(_'
      i_boundary_right            = '_)'
      i_sep_char_strings          = ',_'
      i_sep_char_interval         = '_-_'
      i_use_interval              = 'X'
      i_boundary_method           = 'C'
      i_line_length               = 50
      i_no_zero                   = 'X'
      i_alphabet                  = sy-abcde
      i_digits                    = '0123456789'
      i_special_chars             = '-'
      i_with_second_digit         = ' '
    TABLES
      serials                     = tkomser
      serials_print               = tkomser_print
    EXCEPTIONS
      boundary_missing            = 01
      interval_separation_missing = 02
      length_to_small             = 03
      internal_error              = 04
      wrong_method                = 05
      wrong_serial                = 06
      two_equal_serials           = 07
      serial_with_wrong_char      = 08
      serial_separation_missing   = 09.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.


ENDFORM.                               " GET_ITEM_SERIALS
*eject


*&---------------------------------------------------------------------*
*&      Form  ITEM_SERIALS_PRINT
*&---------------------------------------------------------------------*
*       This routine prints the serialnumbers of a salesdocument       *
*       position.                                                      *
*----------------------------------------------------------------------*
FORM item_serials_print.

  DATA: first_line(1) TYPE c.

  first_line = charx.
  LOOP AT tkomser_print.
    komser = tkomser_print.
    IF NOT first_line IS INITIAL.
*     Output of the Headerline
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_SERIAL_HEADER'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
      CLEAR first_line.
    ELSE.
*     Output of the following printlines
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_SERIAL'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDIF.
  ENDLOOP.
* If serialnumbers exists a empty line is printed.
  IF first_line IS INITIAL.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'EMPTY_LINE'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

ENDFORM.                               " ITEM_SERIALS_PRINT
*eject


*&---------------------------------------------------------------------*
*&      Form  HEADER_INTER_PRINT
*&---------------------------------------------------------------------*
*       Prints the message that if other condition for the positions   *
*       exists they are printed there.                                 *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header_inter_print.

  CHECK NOT steu-vdkex IS INITIAL.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER_TERMS_OF_TXTEND'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                               " HEADER_INTER_PRINT

*&---------------------------------------------------------------------*
*&      Form  GET_CONTROLL_DATA
*&---------------------------------------------------------------------*
*       Checks if servicedata for the header exists.                   *
*       Checks if servicedata for the position exists.                 *
*       Checks if noticedata for the header exists.                    *
*       Checks if noticedata for the position exists.                  *
*----------------------------------------------------------------------*
FORM get_controll_data.

  DATA: lines TYPE i.

* Exists servicedata for the header?
  DESCRIBE TABLE tkomservh LINES lines.
  IF lines GT 0.
    steu-vdkex = 'X'.
  ENDIF.

* Exists servicedata for the position?
  DESCRIBE TABLE tkomservp LINES lines.
  IF lines GT 0.
    steu-vdpex = 'X'.
  ENDIF.

* Exists noticedata for the header?
  DESCRIBE TABLE tkomservhn LINES lines.
  IF lines GT 0.
    steu-kbkex = 'X'.
  ENDIF.

* Exists noticedata for the position?
  DESCRIBE TABLE tkomservpn LINES lines.
  IF lines GT 0.
    steu-kbpex = 'X'.
  ENDIF.

ENDFORM.                               " GET_CONTROLL_DATA
*eject


*&---------------------------------------------------------------------*
*&      Form  HEADER_SERV_PRINT
*&---------------------------------------------------------------------*
*       Output of the validity of a service-contract.                  *
*----------------------------------------------------------------------*
FORM header_serv_print.

  CHECK NOT steu-vdkex IS INITIAL.
  READ TABLE tkomservh INDEX 1.
  MOVE tkomservh TO vedka.

* Output of the validity.
  IF NOT vedka-venddat IS INITIAL OR
     vedka-venddat EQ space.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'HEADER_TERMS_OF_SERV1'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ELSEIF vedka-vbegdat NE space AND
         NOT vedka-vbegdat IS INITIAL.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'HEADER_TERMS_OF_SERV2'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ELSE.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'HEADER_TERMS_OF_SERV3'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

ENDFORM.                               " HEADER_SERV_PRINT

*&---------------------------------------------------------------------*
*&      Form  ITEM_TEXT_Z002
*&---------------------------------------------------------------------*
FORM item_text_z002 .
  DATA: lt_tline LIKE tline OCCURS 0 WITH HEADER LINE.

  IF vbdka-vbtyp = charc OR
    vbdka-vbtyp = charh.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = 'Z002'
        language                = sy-langu
        name                    = vbdpa-tdname
        object                  = 'VBBP'
      TABLES
        lines                   = lt_tline
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc = 0.
      READ TABLE lt_tline INDEX 1.
      komvd-vtext = lt_tline-tdline.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_TEXT_Z002'.
    ELSE.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.
ENDFORM.                    " ITEM_TEXT_Z002
