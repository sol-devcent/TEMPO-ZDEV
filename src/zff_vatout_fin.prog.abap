************************************************************************
*                                                                      *
*  PROGRAM NAME  :  ZFF_VATOUT_FIN BY SAPSCRIPT                        *
*  PROGRAM DESC  :  VAT PRINT DOCUMENT                                 *
*  CREATED BY    :  BUDI PRAMONO                                       *
*  CREATED ON    :  11/04/2002 (DMY)                                   *
*  VERSION       :  4.6C                                               *
*                                                                      *
************************************************************************
*                                                                      *
*  MODIFICATION LOG :                                                  *
*                                                                      *
*& CRNO#          DATE         AUTHOR         DESCRIPTION              *
*& DEVK935895     19.08.2013                  Modifikasi untuk SUT     *
*&                                            Project                  *
*                                                                      *
************************************************************************
REPORT zff_vatout_fin
MESSAGE-ID zf LINE-SIZE 186.

*---------------------------------------------------------------------*
* DEFINITION OF TABLES                                                *
*---------------------------------------------------------------------*
TABLES : bsis,          "Accounting: Secondary Index for G/L Accounts
         bsid,        "Accounting: Secondary Index for Customers
         bsad,    "Acct: Secondary Index for Customers (Cleared Items)
         kna1,        "General Data in Customer Master
         t001,        "Company Codes
         adrc,        "Addresses (central address admin.)
         tvbur,       "Organizational Unit: Sales Offices
         zftax,       "Company Code Tax Master Data
         zfvato,      "VAT-Out PRINT DOCUMENT
         zfvatnr,     "VAT-Out LAST SERIAL NUMBER
         zfvatnm,     "VAT-Out SIGN AUTORIZE
         sscrfields.  "Fields on selection screens

DATA : gs_dpp   TYPE zproject.

*---------------------------------------------------------------------*
* DEFINITION OF TYPES                                                 *
*---------------------------------------------------------------------*
INCLUDE zff_vatout_fin_t.

*---------------------------------------------------------------------*
* DEFINITION OF PARAMETER & SELECTION                                 *
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-002.
PARAMETERS : p_vkorg LIKE t001-bukrs OBLIGATORY DEFAULT '8020',
             p_vkbur LIKE tgsb-gsber OBLIGATORY DEFAULT '0200',
             p_gjahr LIKE bsid-gjahr OBLIGATORY DEFAULT sy-datum(4),
             p_belnr LIKE bsid-belnr.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-008.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_prnt RADIOBUTTON GROUP grp1 DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(30) TEXT-003 FOR FIELD p_prnt.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_reprnt RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(30) TEXT-004 FOR FIELD p_reprnt.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_revise RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(30) TEXT-009 FOR FIELD p_revise.
SELECTION-SCREEN END OF LINE.
*  SELECTION-SCREEN BEGIN OF LINE.
*    PARAMETERS : P_CANCL RADIOBUTTON GROUP GRP1.
*    SELECTION-SCREEN : COMMENT 5(30) TEXT-005.
*  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_mnumb NO-DISPLAY. "RADIOBUTTON GROUP grp1.
*SELECTION-SCREEN : COMMENT 5(30) text-006.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_msign RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(30) TEXT-007 FOR FIELD p_msign.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF BLOCK block3 WITH FRAME TITLE TEXT-010.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_claim RADIOBUTTON GROUP grp2 DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(30) TEXT-011 FOR FIELD p_claim.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_jual RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(30) TEXT-012 FOR FIELD p_jual.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block3.

SELECTION-SCREEN BEGIN OF SCREEN 500 AS WINDOW
                                     TITLE TEXT-033.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 4(9) TEXT-035.
SELECTION-SCREEN POSITION 14.
PARAMETER : pa_belnr(10) MODIF ID dsc.
SELECTION-SCREEN POSITION 78.
PARAMETER : pa_sts(6) MODIF ID dsc.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 4(10) TEXT-037.
SELECTION-SCREEN POSITION 14.
PARAMETER : pa_dudat LIKE bsid-zfbdt MODIF ID dsc.
SELECTION-SCREEN COMMENT 29(10) TEXT-036.
SELECTION-SCREEN POSITION 40.
*      PARAMETER : PA_WRBTX(19). "MODIF ID DSC.
PARAMETER : pa_wrbtx(12) TYPE p DECIMALS 0.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 10(11) TEXT-030.
SELECTION-SCREEN COMMENT 53(8) TEXT-031.
SELECTION-SCREEN COMMENT 63(5) TEXT-038.
SELECTION-SCREEN COMMENT 77(5) TEXT-032.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(2) text1 MODIF ID dsa.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod1(50) MODIF ID dsb.
SELECTION-SCREEN POSITION 51.
PARAMETER : qty1(4) TYPE p DECIMALS 2 MODIF ID dsb.
SELECTION-SCREEN POSITION 63.
PARAMETER : uom1(4) MODIF ID dsb.
SELECTION-SCREEN POSITION 69.
PARAMETER : price1(15) TYPE p DECIMALS 0 MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod1a(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod1b(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod1c(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(2) text2 MODIF ID dsa.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod2(50) MODIF ID dsb.
SELECTION-SCREEN POSITION 51.
PARAMETER : qty2(4) TYPE p DECIMALS 2 MODIF ID dsb.
SELECTION-SCREEN POSITION 63.
PARAMETER : uom2(4) MODIF ID dsb.
SELECTION-SCREEN POSITION 69.
PARAMETER : price2(15) TYPE p DECIMALS 0 MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod2a(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod2b(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod2c(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(2) text3 MODIF ID dsa.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod3(50) MODIF ID dsb.
SELECTION-SCREEN POSITION 51.
PARAMETER : qty3(4) TYPE p DECIMALS 2 MODIF ID dsb.
SELECTION-SCREEN POSITION 63.
PARAMETER : uom3(4) MODIF ID dsb.
SELECTION-SCREEN POSITION 69.
PARAMETER : price3(15) TYPE p DECIMALS 0 MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod3a(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod3b(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod3c(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(2) text4 MODIF ID dsa.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod4(50) MODIF ID dsb.
SELECTION-SCREEN POSITION 51.
PARAMETER : qty4(4) TYPE p DECIMALS 2 MODIF ID dsb.
SELECTION-SCREEN POSITION 63.
PARAMETER : uom4(4) MODIF ID dsb.
SELECTION-SCREEN POSITION 69.
PARAMETER : price4(15) TYPE p DECIMALS 0 MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod4a(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod4b(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod4c(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(2) text5 MODIF ID dsa.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod5(50) MODIF ID dsb.
SELECTION-SCREEN POSITION 51.
PARAMETER : qty5(4) TYPE p DECIMALS 2 MODIF ID dsb.
SELECTION-SCREEN POSITION 63.
PARAMETER : uom5(4) MODIF ID dsb.
SELECTION-SCREEN POSITION 69.
PARAMETER : price5(15) TYPE p DECIMALS 0 MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod5a(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod5b(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod5c(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(2) text6 MODIF ID dsa.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod6(50) MODIF ID dsb.
SELECTION-SCREEN POSITION 51.
PARAMETER : qty6(4) TYPE p DECIMALS 2 MODIF ID dsb.
SELECTION-SCREEN POSITION 63.
PARAMETER : uom6(4) MODIF ID dsb.
SELECTION-SCREEN POSITION 69.
PARAMETER : price6(15) TYPE p DECIMALS 0 MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod6a(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod6b(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod6c(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(2) text7 MODIF ID dsa.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod7(50) MODIF ID dsb.
SELECTION-SCREEN POSITION 51.
PARAMETER : qty7(4) TYPE p DECIMALS 2 MODIF ID dsb.
SELECTION-SCREEN POSITION 63.
PARAMETER : uom7(4) MODIF ID dsb.
SELECTION-SCREEN POSITION 69.
PARAMETER : price7(15) TYPE p DECIMALS 0 MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod7a(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod7b(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod7c(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(2) text8 MODIF ID dsa.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod8(50) MODIF ID dsb.
SELECTION-SCREEN POSITION 51.
PARAMETER : qty8(4) TYPE p DECIMALS 2 MODIF ID dsb.
SELECTION-SCREEN POSITION 63.
PARAMETER : uom8(4) MODIF ID dsb.
SELECTION-SCREEN POSITION 69.
PARAMETER : price8(15) TYPE p DECIMALS 0 MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod8a(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod8b(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod8c(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(2) text9 MODIF ID dsa.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod9(50) MODIF ID dsb.
SELECTION-SCREEN POSITION 51.
PARAMETER : qty9(4) TYPE p DECIMALS 2 MODIF ID dsb.
SELECTION-SCREEN POSITION 63.
PARAMETER : uom9(4) MODIF ID dsb.
SELECTION-SCREEN POSITION 69.
PARAMETER : price9(15) TYPE p DECIMALS 0 MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod9a(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod9b(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod9c(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(2) text10 MODIF ID dsa.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod10(50) MODIF ID dsb.
SELECTION-SCREEN POSITION 51.
PARAMETER : qty10(4) TYPE p DECIMALS 2 MODIF ID dsb.
SELECTION-SCREEN POSITION 63.
PARAMETER : uom10(4) MODIF ID dsb.
SELECTION-SCREEN POSITION 69.
PARAMETER : price10(15) TYPE p DECIMALS 0 MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod10a(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod10b(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod10c(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(2) text11 MODIF ID dsa.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod11(50) MODIF ID dsb.
SELECTION-SCREEN POSITION 51.
PARAMETER : qty11(4) TYPE p DECIMALS 2 MODIF ID dsb.
SELECTION-SCREEN POSITION 63.
PARAMETER : uom11(4) MODIF ID dsb.
SELECTION-SCREEN POSITION 69.
PARAMETER : price11(15) TYPE p DECIMALS 0 MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod11a(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod11b(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod11c(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(2) text12 MODIF ID dsa.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod12(50) MODIF ID dsb.
SELECTION-SCREEN POSITION 51.
PARAMETER : qty12(4) TYPE p DECIMALS 2 MODIF ID dsb.
SELECTION-SCREEN POSITION 63.
PARAMETER : uom12(4) MODIF ID dsb.
SELECTION-SCREEN POSITION 69.
PARAMETER : price12(15) TYPE p DECIMALS 0 MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod12a(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod12b(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod12c(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(2) text13 MODIF ID dsa.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod13(50) MODIF ID dsb.
SELECTION-SCREEN POSITION 51.
PARAMETER : qty13(4) TYPE p DECIMALS 2 MODIF ID dsb.
SELECTION-SCREEN POSITION 63.
PARAMETER : uom13(4) MODIF ID dsb.
SELECTION-SCREEN POSITION 69.
PARAMETER : price13(15) TYPE p DECIMALS 0 MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod13a(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod13b(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod13c(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(2) text14 MODIF ID dsa.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod14(50) MODIF ID dsb.
SELECTION-SCREEN POSITION 51.
PARAMETER : qty14(4) TYPE p DECIMALS 2 MODIF ID dsb.
SELECTION-SCREEN POSITION 63.
PARAMETER : uom14(4) MODIF ID dsb.
SELECTION-SCREEN POSITION 69.
PARAMETER : price14(15) TYPE p DECIMALS 0 MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod14a(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod14b(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod14c(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(2) text15 MODIF ID dsa.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod15(50) MODIF ID dsb.
SELECTION-SCREEN POSITION 51.
PARAMETER : qty15(4) TYPE p DECIMALS 2 MODIF ID dsb.
SELECTION-SCREEN POSITION 63.
PARAMETER : uom15(4) MODIF ID dsb.
SELECTION-SCREEN POSITION 69.
PARAMETER : price15(15) TYPE p DECIMALS 0 MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod15a(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod15b(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETER : prod15c(50) MODIF ID dsb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  48(11) TEXT-034 MODIF ID dsa.
SELECTION-SCREEN POSITION 63.
PARAMETER : total(21) MODIF ID dsc.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF SCREEN 500.

*
* VALIDATE FOR SELECTION
*------------------------
AT SELECTION-SCREEN ON p_vkorg.
*  IF p_vkorg NE '8010' AND p_vkorg NE '8020' AND
*     p_vkorg NE '8030' AND p_vkorg NE '8070'.
*    MESSAGE e000(zf) WITH
*      'SaOrg must be entry (8010, 8020, 8030, 8070)'.
*  ENDIF.

AT SELECTION-SCREEN ON p_vkbur.
  IF p_vkbur NP '01*' AND p_vkorg = '8010'.
    MESSAGE e000(zf) WITH 'Sales Office must be entry "01xx"'.
  ENDIF.
  IF ( p_vkbur NE '0200' AND p_vkbur NE '02TM' ) AND p_vkorg = '8020'.
    MESSAGE e000(zf) WITH 'Sales Office must be entry "0200/02TM"'.
  ENDIF.
  IF p_vkbur NP '03*' AND p_vkorg = '8030'.
    MESSAGE e000(zf) WITH 'Sales Office must be entry "03xx"'.
  ENDIF.
  IF p_vkbur NP '07*' AND p_vkorg = '8070'.
    MESSAGE e000(zf) WITH 'Sales Office must be entry "07xx"'.
  ENDIF.
  IF p_vkbur = space.
    IF p_mnumb = 'X' OR p_msign = 'X'.
      MESSAGE e003.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
*    IF P_REPRNT = 'X'.
*      IF SCREEN-GROUP1 = 'DSB'.
*        SCREEN-INPUT = '0'.
*      ENDIF.
*    ENDIF.
    IF screen-group1 = 'DSC'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

*&---------------------------------------------------------------------*
*&      INCLUDE
*&---------------------------------------------------------------------*
  INCLUDE zff_vatout_fin_o01.

  INCLUDE zff_vatout_fin_o02.

  INCLUDE zff_vatout_fin_i01.

  INCLUDE zff_vatout_fin_i02.

  INCLUDE zff_vatout_fin_o11.

  INCLUDE zff_vatout_fin_i12.

  INCLUDE zff_vatout_fin_o21.

  INCLUDE zff_vatout_fin_i22.

*---------------------------------------------------------------------*
* INITIALIZATION                                                      *
*---------------------------------------------------------------------*
INITIALIZATION.
  v_datum = sy-datum.
  sw = '0'.
  text1 = '01'.
  text2 = '02'.
  text3 = '03'.
  text4 = '04'.
  text5 = '05'.
  text6 = '06'.
  text7 = '07'.
  text8 = '08'.
  text9 = '09'.
  text10 = '10'.
  text11 = '11'.
  text12 = '12'.
  text13 = '13'.
  text14 = '14'.
  text15 = '15'.

  DATA: lv_parva(40).

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'BUK'.

  IF sy-subrc EQ 0.
    p_vkorg  = lv_parva.
  ENDIF.

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'VKB'.

  IF sy-subrc EQ 0.
    p_vkbur  = lv_parva.
  ENDIF.

*---------------------------------------------------------------------*
* START-OF-SELECTION                                                  *
*---------------------------------------------------------------------*
START-OF-SELECTION.

  SELECT SINGLE *
    FROM zproject
    INTO CORRESPONDING FIELDS OF gs_dpp
    WHERE name = 'DPP12'.

  PERFORM cek_lock.

  IF p_prnt = 'X' OR p_reprnt = 'X'.

    PERFORM f_geting_data.
    IF v_recno = 0.
      MESSAGE i001.
    ENDIF.
    IF v_vatno GT v_vatto.
      MESSAGE i007.
      EXIT.
    ENDIF.
    CHECK v_recno NE 0.
    CHECK v_vatno LE v_vatto.
    CLEAR: va_belnr, va_wrbtx.
*    SET PF-STATUS '100'.
    va_belnr = wa_vat1-belnr.
    WRITE wa_vat1-wrbtx TO va_wrbtx DECIMALS 0.
    pa_belnr = va_belnr.
*    PA_WRBTX = VA_WRBTX.
    pa_wrbtx = wa_vat1-wrbtx.
    pa_dudat = wa_vat1-dudat.
    pa_sts = 'Entry'.

    IF p_prnt = 'X'.
      PERFORM f_init_screen.
      CALL SELECTION-SCREEN 500 STARTING AT 25 3
                                ENDING AT 110 22.
      CHECK sy-subrc = 0.
      IF p_vkorg = '8030'.
        PERFORM f_open_form_ec.
        PERFORM f_write_form_ec.
        PERFORM f_close_form_ec.
      ELSEIF p_vkorg = '8020' OR p_vkorg = '8380'.
        PERFORM f_open_form.
        PERFORM f_write_form.
        PERFORM f_close_form.
      ELSEIF p_vkorg = '8070'.
        PERFORM f_open_formsut.
        PERFORM f_write_form.
        PERFORM f_close_form.
      ENDIF.
      IF xresult-tdspoolid NE 0.
        PERFORM f_write_file.
      ENDIF.
    ENDIF.

    IF p_reprnt = 'X'.
      IF p_vkorg = '8030'.
        PERFORM f_open_form_ec.
        PERFORM f_write_form_ec.
        PERFORM f_close_form_ec.
      ELSEIF p_vkorg = '8020' OR p_vkorg = '8380'.
        PERFORM f_open_form.
        PERFORM f_write_form.
        PERFORM f_close_form.
      ELSEIF p_vkorg = '8070'.
        PERFORM f_open_formsut.
        PERFORM f_write_form.
        PERFORM f_close_form.
      ENDIF.
      IF xresult-tdspoolid NE 0.
        PERFORM f_write_file.
      ENDIF.
    ENDIF.

  ELSE.
*
* Revise Detail Document
*------------------------
    IF p_revise = 'X'.
      PERFORM f_geting_data.
      IF v_recno = 0.
        MESSAGE i001.
      ENDIF.
      CHECK v_recno NE 0.
      va_belnr = wa_vat1-belnr.
      WRITE wa_vat1-wrbtx TO va_wrbtx DECIMALS 0.
      pa_belnr = va_belnr.
*      PA_WRBTX = VA_WRBTX.
      pa_wrbtx = wa_vat1-wrbtx.
      pa_dudat = wa_vat1-dudat.
      pa_sts = 'Revise'.
      PERFORM f_init_screen.
      PERFORM f_read_text.
      CALL SELECTION-SCREEN 500 STARTING AT 25 3
                                ENDING AT 110 22.
      IF sy-subrc = 0.
        value_tot = value_tot / 100.
        IF pa_dudat > gs_dpp-datab.
          value_tot = value_tot * 11 / 12.
        ENDIF.
        UPDATE zfvato SET netwr = value_tot
                      WHERE vkorg = p_vkorg AND
                            vkbur = p_vkbur AND
                            vbeln = p_belnr AND
                            gjahr = p_gjahr.
      ENDIF.

    ELSE.
*
* CANCEL PRINT VAT
*-----------------
*    IF P_CANCL = 'X'.
*      PERFORM F_GETING_DATA_CANCL.
*      IF SY-SUBRC = 0.
*        CALL SCREEN 100.
*      ELSE.
*        MESSAGE I001.
*      ENDIF.
*    ELSE.
*
* MAINTENANCE VAT SERIAL NUMBER
*------------------------------
      IF p_mnumb = 'X'.
        PERFORM f_geting_data_mnumb.
        CALL SCREEN 200.
      ELSE.
*
* MAINTENANCE SIGN AUTORIZE
*--------------------------
        IF p_msign = 'X'.
          PERFORM f_geting_data_msign.
          CALL SCREEN 300.
        ENDIF.
      ENDIF.
*    ENDIF.
    ENDIF.
  ENDIF.

END-OF-SELECTION.

*---------------------------------------------------------------------*
* AT SELECTION-SCREEN                                                 *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN.

  PERFORM f_init_massage.
  IF prod1 NE space AND price1 EQ 0.
    "( QTY1 EQ 0 OR PRICE1 EQ 0 ).
    msg1 = text1.
  ENDIF.
  IF prod2 NE space AND price2 EQ 0.
    "( QTY2 EQ 0 OR PRICE2 EQ 0 ).
    msg2 = text2.
  ENDIF.
  IF prod3 NE space AND price3 EQ 0.
    "( QTY3 EQ 0 OR PRICE3 EQ 0 ).
    msg3 = text3.
  ENDIF.
  IF prod4 NE space AND price4 EQ 0.
    "( QTY4 EQ 0 OR PRICE4 EQ 0 ).
    msg4 = text4.
  ENDIF.
  IF prod5 NE space AND price5 EQ 0.
    "( QTY5 EQ 0 OR PRICE5 EQ 0 ).
    msg5 = text5.
  ENDIF.
  IF prod6 NE space AND price6 EQ 0.
    "( QTY6 EQ 0 OR PRICE6 EQ 0 ).
    msg6 = text6.
  ENDIF.
  IF prod7 NE space AND price7 EQ 0.
    "( QTY7 EQ 0 OR PRICE7 EQ 0 ).
    msg7 = text7.
  ENDIF.
  IF prod8 NE space AND price8 EQ 0.
    "( QTY8 EQ 0 OR PRICE8 EQ 0 ).
    msg8 = text8.
  ENDIF.
  IF prod9 NE space AND price9 EQ 0.
    "( QTY9 EQ 0 OR PRICE9 EQ 0 ).
    msg9 = text9.
  ENDIF.
  IF prod10 NE space AND price10 EQ 0.
    "( QTY10 EQ 0 OR PRICE10 EQ 0 ).
    msg10 = text10.
  ENDIF.
  IF prod11 NE space AND price11 EQ 0.
    "( QTY11 EQ 0 OR PRICE11 EQ 0 ).
    msg11 = text11.
  ENDIF.
  IF prod12 NE space AND price12 EQ 0.
    "( QTY12 EQ 0 OR PRICE12 EQ 0 ).
    msg12 = text12.
  ENDIF.
  IF prod13 NE space AND price13 EQ 0.
    "( QTY13 EQ 0 OR PRICE13 EQ 0 ).
    msg13 = text13.
  ENDIF.
  IF prod14 NE space AND price14 EQ 0.
    "( QTY14 EQ 0 OR PRICE14 EQ 0 ).
    msg14 = text14.
  ENDIF.
  IF prod15 NE space AND price15 EQ 0.
    "( QTY15 EQ 0 OR PRICE15 EQ 0 ).
    msg15 = text15.
  ENDIF.

  IF qty1 = 0.
    value1 = price1.
  ELSE.
    value1 = qty1 * price1.
  ENDIF.
  IF qty2 = 0.
    value2 = price2.
  ELSE.
    value2 = qty2 * price2.
  ENDIF.
  IF qty3 = 0.
    value3 = price3.
  ELSE.
    value3 = qty3 * price3.
  ENDIF.
  IF qty4 = 0.
    value4 = price4.
  ELSE.
    value4 = qty4 * price4.
  ENDIF.
  IF qty5 = 0.
    value5 = price5.
  ELSE.
    value5 = qty5 * price5.
  ENDIF.
  IF qty6 = 0.
    value6 = price6.
  ELSE.
    value6 = qty6 * price6.
  ENDIF.
  IF qty7 = 0.
    value7 = price7.
  ELSE.
    value7 = qty7 * price7.
  ENDIF.
  IF qty8 = 0.
    value8 = price8.
  ELSE.
    value8 = qty8 * price8.
  ENDIF.
  IF qty9 = 0.
    value9 = price9.
  ELSE.
    value9 = qty9 * price9.
  ENDIF.
  IF qty10 = 0.
    value10 = price10.
  ELSE.
    value10 = qty10 * price10.
  ENDIF.
  IF qty11 = 0.
    value11 = price11.
  ELSE.
    value11 = qty11 * price11.
  ENDIF.
  IF qty12 = 0.
    value12 = price12.
  ELSE.
    value12 = qty12 * price12.
  ENDIF.
  IF qty13 = 0.
    value13 = price13.
  ELSE.
    value13 = qty13 * price13.
  ENDIF.
  IF qty14 = 0.
    value14 = price14.
  ELSE.
    value14 = qty14 * price14.
  ENDIF.
  IF qty15 = 0.
    value15 = price15.
  ELSE.
    value15 = qty15 * price15.
  ENDIF.
  value_tot = value1 + value2 + value3 + value4 + value5 +
              value6 + value7 + value8 + value9 + value10 +
              value11 + value12 + value13 + value14 + value15.
  WRITE value_tot TO va_total DECIMALS 0.
  total = va_total.

  CASE sscrfields-ucomm.

    WHEN 'CRET'.  "Execute

*      IF P_PRNT = 'X'.
      REFRESH i_vat05.
      CLEAR wa_vat5.
      IF prod1 NE space AND
         "QTY1  NE 0     AND
         price1 NE 0.
        wa_vat5-no = text1.
        wa_vat5-prod = prod1.
        wa_vat5-uom = uom1.
        WRITE qty1 TO wa_vat5-qty USING EDIT MASK '_____________'.
        WRITE price1 TO wa_vat5-price USING EDIT MASK
                                      '_______________'.
        APPEND wa_vat5 TO i_vat05.
        PERFORM f_append_itab USING text1.
      ENDIF.
      IF prod2 NE space AND
         "QTY2  NE 0     AND
         price2 NE 0.
        wa_vat5-no = text2.
        wa_vat5-prod = prod2.
        wa_vat5-uom = uom2.
        WRITE qty2 TO wa_vat5-qty USING EDIT MASK '_____________'.
        WRITE price2 TO wa_vat5-price USING EDIT MASK
                                      '_______________'.
        APPEND wa_vat5 TO i_vat05.
        PERFORM f_append_itab USING text2.
      ENDIF.
      IF prod3 NE space AND
         "QTY3  NE 0     AND
         price3 NE 0.
        wa_vat5-no = text3.
        wa_vat5-prod = prod3.
        wa_vat5-uom = uom3.
        WRITE qty3 TO wa_vat5-qty USING EDIT MASK '_____________'.
        WRITE price3 TO wa_vat5-price USING EDIT MASK
                                      '_______________'.
        APPEND wa_vat5 TO i_vat05.
        PERFORM f_append_itab USING text3.
      ENDIF.
      IF prod4 NE space AND
         "QTY4  NE 0     AND
         price4 NE 0.
        wa_vat5-no = text4.
        wa_vat5-prod = prod4.
        wa_vat5-uom = uom4.
        WRITE qty4 TO wa_vat5-qty USING EDIT MASK '_____________'.
        WRITE price4 TO wa_vat5-price USING EDIT MASK
                                      '_______________'.
        APPEND wa_vat5 TO i_vat05.
        PERFORM f_append_itab USING text4.
      ENDIF.
      IF prod5 NE space AND
         "QTY5  NE 0     AND
         price5 NE 0.
        wa_vat5-no = text5.
        wa_vat5-prod = prod5.
        wa_vat5-uom = uom5.
        WRITE qty5 TO wa_vat5-qty USING EDIT MASK '_____________'.
        WRITE price5 TO wa_vat5-price USING EDIT MASK
                                      '_______________'.
        APPEND wa_vat5 TO i_vat05.
        PERFORM f_append_itab USING text5.
      ENDIF.
      IF prod6 NE space AND
         "QTY6  NE 0     AND
         price6 NE 0.
        wa_vat5-no = text6.
        wa_vat5-prod = prod6.
        wa_vat5-uom = uom6.
        WRITE qty6 TO wa_vat5-qty USING EDIT MASK '_____________'.
        WRITE price6 TO wa_vat5-price USING EDIT MASK
                                      '_______________'.
        APPEND wa_vat5 TO i_vat05.
        PERFORM f_append_itab USING text6.
      ENDIF.
      IF prod7 NE space AND
         "QTY7  NE 0     AND
         price7 NE 0.
        wa_vat5-no = text7.
        wa_vat5-prod = prod7.
        wa_vat5-uom = uom7.
        WRITE qty7 TO wa_vat5-qty USING EDIT MASK '_____________'.
        WRITE price7 TO wa_vat5-price USING EDIT MASK
                                      '_______________'.
        APPEND wa_vat5 TO i_vat05.
        PERFORM f_append_itab USING text7.
      ENDIF.
      IF prod8 NE space AND
         "QTY8  NE 0     AND
         price8 NE 0.
        wa_vat5-no = text8.
        wa_vat5-prod = prod8.
        wa_vat5-uom = uom8.
        WRITE qty8 TO wa_vat5-qty USING EDIT MASK '_____________'.
        WRITE price8 TO wa_vat5-price USING EDIT MASK
                                      '_______________'.
        APPEND wa_vat5 TO i_vat05.
        PERFORM f_append_itab USING text8.
      ENDIF.
      IF prod9 NE space AND
         "QTY9  NE 0     AND
         price9 NE 0.
        wa_vat5-no = text9.
        wa_vat5-prod = prod9.
        wa_vat5-uom = uom9.
        WRITE qty9 TO wa_vat5-qty USING EDIT MASK '_____________'.
        WRITE price9 TO wa_vat5-price USING EDIT MASK
                                      '_______________'.
        APPEND wa_vat5 TO i_vat05.
        PERFORM f_append_itab USING text9.
      ENDIF.
      IF prod10 NE space AND
         "QTY10  NE 0     AND
         price10 NE 0.
        wa_vat5-no = text10.
        wa_vat5-prod = prod10.
        wa_vat5-uom = uom10.
        WRITE qty10 TO wa_vat5-qty USING EDIT MASK '_____________'.
        WRITE price10 TO wa_vat5-price USING EDIT MASK
                                       '_______________'.
        APPEND wa_vat5 TO i_vat05.
        PERFORM f_append_itab USING text10.
      ENDIF.
      IF prod11 NE space AND
         "QTY11  NE 0     AND
         price11 NE 0.
        wa_vat5-no = text11.
        wa_vat5-prod = prod11.
        wa_vat5-uom = uom11.
        WRITE qty11 TO wa_vat5-qty USING EDIT MASK '_____________'.
        WRITE price11 TO wa_vat5-price USING EDIT MASK
                                       '_______________'.
        APPEND wa_vat5 TO i_vat05.
        PERFORM f_append_itab USING text11.
      ENDIF.
      IF prod12 NE space AND
         "QTY12  NE 0     AND
         price12 NE 0.
        wa_vat5-no = text12.
        wa_vat5-prod = prod12.
        wa_vat5-uom = uom12.
        WRITE qty12 TO wa_vat5-qty USING EDIT MASK '_____________'.
        WRITE price12 TO wa_vat5-price USING EDIT MASK
                                       '_______________'.
        APPEND wa_vat5 TO i_vat05.
        PERFORM f_append_itab USING text12.
      ENDIF.
      IF prod13 NE space AND
         "QTY13  NE 0     AND
         price13 NE 0.
        wa_vat5-no = text13.
        wa_vat5-prod = prod13.
        wa_vat5-uom = uom13.
        WRITE qty13 TO wa_vat5-qty USING EDIT MASK '_____________'.
        WRITE price13 TO wa_vat5-price USING EDIT MASK
                                       '_______________'.
        APPEND wa_vat5 TO i_vat05.
        PERFORM f_append_itab USING text13.
      ENDIF.
      IF prod14 NE space AND
         "QTY14  NE 0     AND
         price14 NE 0.
        wa_vat5-no = text14.
        wa_vat5-prod = prod14.
        wa_vat5-uom = uom14.
        WRITE qty14 TO wa_vat5-qty USING EDIT MASK '_____________'.
        WRITE price14 TO wa_vat5-price USING EDIT MASK
                                       '_______________'.
        APPEND wa_vat5 TO i_vat05.
        PERFORM f_append_itab USING text14.
      ENDIF.
      IF prod15 NE space AND
         "QTY15  NE 0     AND
         price15 NE 0.
        wa_vat5-no = text15.
        wa_vat5-prod = prod15.
        wa_vat5-uom = uom15.
        WRITE qty15 TO wa_vat5-qty USING EDIT MASK '_____________'.
        WRITE price15 TO wa_vat5-price USING EDIT MASK
                                       '_______________'.
        APPEND wa_vat5 TO i_vat05.
        PERFORM f_append_itab USING text15.
      ENDIF.

      IF msg1 NE space OR msg2 NE space OR msg3 NE space OR
         msg4 NE space OR msg5 NE space OR msg6 NE space OR
         msg7 NE space OR msg8 NE space OR msg9 NE space OR
         msg10 NE space OR msg11 NE space OR msg12 NE space OR
         msg13 NE space OR msg14 NE space OR msg15 NE space.
        CONCATENATE 'Error at lines :'
                    msg1 msg2 msg3 msg4 msg5 msg6 msg7 msg8
                    msg9 msg10 msg11 msg12 msg13 msg14 msg15
                    INTO msglin SEPARATED BY space.
        MESSAGE e000(zf) WITH msglin.
      ELSE.
*          IF VALUE_TOT NE WA_VAT1-WRBTX.
        IF value_tot NE pa_wrbtx.
          MESSAGE e000(zf) WITH
                  'Total Entry tidak sama dengan Tax Base'.
        ELSE.
          PERFORM f_tax_calc USING wa_vat1-budat value_tot 'F'
                             CHANGING v_tax.

*          v_tax = value_tot * 10 / 100.

          v_var = abs( v_tax - wa_vat1-wrbt1 ).
          IF v_var GT 2.
            MESSAGE e000(zf) WITH
                    'Nilai PPN =' wa_vat1-wrbt1 'Entry Tax Base Salah'.
          ELSE.
            CLEAR wa_vat5.
            LOOP AT i_vat05 INTO wa_vat5.
              IF wa_vat5-price IS INITIAL.
                CONTINUE.
              ENDIF.
              CASE wa_vat5-no.
                WHEN '01'.
                  WRITE value1 TO wa_vat5-value USING EDIT MASK
                                        '________________'.
                  MODIFY i_vat05 FROM wa_vat5.
                WHEN '02'.
                  WRITE value2 TO wa_vat5-value USING EDIT MASK
                                        '________________'.
                  MODIFY i_vat05 FROM wa_vat5.
                WHEN '03'.
                  WRITE value3 TO wa_vat5-value USING EDIT MASK
                                        '________________'.
                  MODIFY i_vat05 FROM wa_vat5.
                WHEN '04'.
                  WRITE value4 TO wa_vat5-value USING EDIT MASK
                                        '________________'.
                  MODIFY i_vat05 FROM wa_vat5.
                WHEN '05'.
                  WRITE value5 TO wa_vat5-value USING EDIT MASK
                                        '________________'.
                  MODIFY i_vat05 FROM wa_vat5.
                WHEN '06'.
                  WRITE value6 TO wa_vat5-value USING EDIT MASK
                                        '________________'.
                  MODIFY i_vat05 FROM wa_vat5.
                WHEN '07'.
                  WRITE value7 TO wa_vat5-value USING EDIT MASK
                                        '________________'.
                  MODIFY i_vat05 FROM wa_vat5.
                WHEN '08'.
                  WRITE value8 TO wa_vat5-value USING EDIT MASK
                                        '________________'.
                  MODIFY i_vat05 FROM wa_vat5.
                WHEN '09'.
                  WRITE value9 TO wa_vat5-value USING EDIT MASK
                                        '________________'.
                  MODIFY i_vat05 FROM wa_vat5.
                WHEN '10'.
                  WRITE value10 TO wa_vat5-value USING EDIT MASK
                                         '________________'.
                  MODIFY i_vat05 FROM wa_vat5.
                WHEN '11'.
                  WRITE value11 TO wa_vat5-value USING EDIT MASK
                                         '________________'.
                  MODIFY i_vat05 FROM wa_vat5.
                WHEN '12'.
                  WRITE value12 TO wa_vat5-value USING EDIT MASK
                                         '________________'.
                  MODIFY i_vat05 FROM wa_vat5.
                WHEN '13'.
                  WRITE value13 TO wa_vat5-value USING EDIT MASK
                                         '________________'.
                  MODIFY i_vat05 FROM wa_vat5.
                WHEN '14'.
                  WRITE value14 TO wa_vat5-value USING EDIT MASK
                                         '________________'.
                  MODIFY i_vat05 FROM wa_vat5.
                WHEN '15'.
                  WRITE value15 TO wa_vat5-value USING EDIT MASK
                                         '________________'.
                  MODIFY i_vat05 FROM wa_vat5.
              ENDCASE.
            ENDLOOP.

            REFRESH i_sels1.
            APPEND INITIAL LINE TO i_sels1.
            APPEND LINES OF i_vat05 TO i_sels1.
            DELETE i_sels1 WHERE tdformat = space.

            va_head-tdname   = va_hname.
            va_head-tdobject = 'BELEG'.
            va_head-tdid     = '0004'.
            va_head-tdspras  = 'E'.
            CALL FUNCTION 'SAVE_TEXT'
              EXPORTING
                header          = va_head
                savemode_direct = 'X'
              TABLES
                lines           = i_sels1
              EXCEPTIONS
                id              = 1
                language        = 2
                name            = 3
                object          = 4.
            CASE sy-subrc.
              WHEN 1.
                MESSAGE i000(zf) WITH 'ID Error'.
              WHEN 2.
                MESSAGE i000(zf) WITH 'LANGUAGE Error'.
              WHEN 3.
                MESSAGE i000(zf) WITH 'NAME Error'.
              WHEN 4.
                MESSAGE i000(zf) WITH 'OBJECT Error'.
            ENDCASE.
          ENDIF.
        ENDIF.
      ENDIF.

*      ENDIF.

    WHEN 'SPOS'.  "Save
    WHEN 'NONE'.  "Check'
      IF msg1 NE space OR msg2 NE space OR msg3 NE space OR
         msg4 NE space OR msg5 NE space OR msg6 NE space OR
         msg7 NE space OR msg8 NE space OR msg9 NE space OR
         msg10 NE space OR msg11 NE space OR msg12 NE space OR
         msg13 NE space OR msg14 NE space OR msg15 NE space.
        CONCATENATE 'Error at lines :'
                    msg1 msg2 msg3 msg4 msg5 msg6 msg7 msg8
                    msg9 msg10 msg11 msg12 msg13 msg14 msg15
                    INTO msglin SEPARATED BY space.
        MESSAGE e000(zf) WITH msglin.
      ELSE.
*          IF VALUE_TOT NE WA_VAT1-WRBTX.
        IF value_tot NE pa_wrbtx.
          MESSAGE e000(zf) WITH
                  'Total Entry tidak sama dengan Tax Base'.
        ELSE.
          PERFORM f_tax_calc USING wa_vat1-budat value_tot 'F'
                             CHANGING v_tax.

*          v_tax = value_tot * 10 / 100.

          v_var = abs( v_tax - wa_vat1-wrbt1 ).
          IF v_var GT 2.
            MESSAGE e000(zf) WITH
                    'Nilai PPN =' wa_vat1-wrbt1 'Entry Tax Base Salah'.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN 'CCAN'.  "Cancel
    WHEN 'ONLI'.  "First time
  ENDCASE.



*&---------------------------------------------------------------------*
*&      Form  F_GETING_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_geting_data.

  DATA : v_vkbur     LIKE vbak-vkbur,
         l_vattrn    LIKE zfvattrn-vattrn,
         ld_dat1st   TYPE d,
         ld_dat2nd   TYPE d,
         l_vatpr(20),
         ld_vatpr    LIKE zfvatnr-vatpr,
         ld_length   TYPE i,
         ld_variant  TYPE i.

  DATA : lr_datum TYPE RANGE OF datum,
         wa_dudat LIKE LINE OF lr_datum.

  REFRESH: i_vat01, i_vat02.
  CLEAR:  wa_vat1, wa_vat2, wa_vat3, wa_vat4, v_recno,
          ld_vatpr,ld_length,ld_variant.

  IF p_prnt = 'X'.

    IF p_vkorg = '8020'.
      SELECT * FROM zfvatnr
        INTO CORRESPONDING FIELDS OF wa_vat3
        WHERE vkorg = p_vkorg AND
              vkbur IN ('0200', '02TM').
      ENDSELECT.
    ELSEIF p_vkorg = '8070'.
      SELECT * FROM zfvatnr
        INTO CORRESPONDING FIELDS OF wa_vat3
        WHERE vkorg = p_vkorg.
      ENDSELECT.
    ELSE.
      SELECT * FROM zfvatnr
        INTO CORRESPONDING FIELDS OF wa_vat3
        WHERE vkorg = p_vkorg AND
              vkbur = p_vkbur.
      ENDSELECT.
    ENDIF.

    PERFORM release_lock.

    IF sy-subrc NE 0.
      PERFORM f_geting_data_mnumb.
      CALL SCREEN 200.
      IF p_vkorg = '8020'.
        SELECT * FROM zfvatnr
          INTO CORRESPONDING FIELDS OF wa_vat3
          WHERE vkorg = p_vkorg AND
                vkbur IN ('0200', '02TM').
        ENDSELECT.
      ELSEIF p_vkorg = '8070'.
        SELECT * FROM zfvatnr
          INTO CORRESPONDING FIELDS OF wa_vat3
          WHERE vkorg = p_vkorg.
        ENDSELECT.
      ELSE.
        SELECT * FROM zfvatnr
          INTO CORRESPONDING FIELDS OF wa_vat3
          WHERE vkorg = p_vkorg AND
                vkbur = p_vkbur.
        ENDSELECT.
      ENDIF.
      PERFORM release_lock.
    ENDIF.
    v_vatto = wa_vat3-vatto.
    v_vatno = wa_vat3-vatno.
    v_vatpr = wa_vat3-vatpr.
    v_vatdt = v_datum.

    SELECT a~zfbdt b~bukrs b~blart b~xblnr b~belnr
           b~budat b~gjahr b~gsber b~wrbtr b~sgtxt
           b~kunnr b~zuonr b~bldat
      FROM bsis AS a JOIN bsid AS b ON
                          a~bukrs = b~bukrs AND
                          a~belnr = b~belnr AND
                          a~gjahr = b~gjahr
      INTO CORRESPONDING FIELDS OF TABLE i_vat01
      WHERE a~hkont = '0315300100' AND
            a~blart NE 'RV'        AND
            a~bukrs = p_vkorg      AND
*            B~GSBER = P_VKBUR      AND
            a~belnr = p_belnr      AND
            a~gjahr = p_gjahr.
    IF sy-subrc NE 0.
      SELECT a~zfbdt b~bukrs b~blart b~xblnr b~belnr
             b~budat b~gjahr b~gsber b~wrbtr b~sgtxt
             b~kunnr b~zuonr b~bldat
        FROM bsis AS a JOIN bsad AS b ON
                            a~bukrs = b~bukrs AND
                            a~belnr = b~belnr AND
                            a~gjahr = b~gjahr
        INTO CORRESPONDING FIELDS OF TABLE i_vat01
        WHERE a~hkont = '0315300100' AND
              a~blart NE 'RV'        AND
              a~bukrs = p_vkorg      AND
*                B~GSBER = P_VKBUR      AND
              a~belnr = p_belnr      AND
              a~gjahr = p_gjahr.
    ENDIF.

    LOOP AT i_vat01 INTO wa_vat1.

***********************************
*  Validate Data Double
***********************************
      SELECT *
        FROM zfvato
        WHERE vkorg = p_vkorg AND
              vkbur = p_vkbur AND
              vbeln = wa_vat1-belnr AND
              gjahr = wa_vat1-gjahr AND
              vtart = 'FI'.
      ENDSELECT.

      IF sy-subrc = 0.

        DELETE i_vat01
          WHERE bukrs = zfvato-vkorg AND
                gsber = zfvato-vkbur AND
                belnr = zfvato-vbeln AND
                gjahr = zfvato-gjahr.

      ELSE.

        SELECT SINGLE stras ort01 cityc pstlz
                      stceg adrnr gform stkza
          FROM kna1
          INTO CORRESPONDING FIELDS OF wa_vat1
          WHERE kunnr = wa_vat1-kunnr.

        SELECT wrbtr
          FROM bsis
          INTO CORRESPONDING FIELDS OF wa_vat2
          WHERE bukrs = wa_vat1-bukrs AND
                hkont = '0315300100'  AND
                belnr = wa_vat1-belnr AND
                gjahr = wa_vat1-gjahr.
          CLEAR wa_vat1-wrbt1.
          wa_vat1-wrbt1 = wa_vat2-wrbtr.
          MODIFY i_vat01 FROM wa_vat1.
        ENDSELECT.

        SELECT  name1 street house_num1 city1 city2
                post_code1 name_co str_suppl1 str_suppl2
                FROM adrc
                INTO (wa_vat1-fname1, wa_vat1-fstreet,
                      wa_vat1-fhouse_num1, wa_vat1-fcity1, wa_vat1-fcity2,
                      wa_vat1-fpost_code1, wa_vat1-name_co,
                      wa_vat1-str_suppl1, wa_vat1-str_suppl2)
                WHERE addrnumber = wa_vat1-adrnr.
        ENDSELECT.

        wa_vat1-vatdt = v_vatdt.

        SELECT SINGLE vatnm vattl object1
          FROM zfvatnm
          INTO CORRESPONDING FIELDS OF wa_vat4
          WHERE vkorg = wa_vat1-bukrs AND
                vkbur = p_vkbur.
        IF sy-subrc = 0.
          wa_vat1-vatnm = wa_vat4-vatnm.
          wa_vat1-vattl = wa_vat4-vattl.
          wa_vat1-object = wa_vat4-object1.
        ELSE.
          PERFORM f_geting_data_msign.
          CALL SCREEN 300.
          CLEAR wa_vat4.
          SELECT SINGLE vatnm vattl object1
            FROM zfvatnm
            INTO CORRESPONDING FIELDS OF wa_vat4
            WHERE vkorg = wa_vat1-bukrs AND
                  vkbur = p_vkbur.
          wa_vat1-vatnm = wa_vat4-vatnm.
          wa_vat1-vattl = wa_vat4-vattl.
          wa_vat1-object = wa_vat4-object1.
        ENDIF.

        IF p_vkorg = '8020' OR
           p_vkorg = '8070' OR
           p_vkorg = '8380'.
          CLEAR wa_vat1-gsber.
*          wa_vat1-gsber = '0200'.
          wa_vat1-gsber = p_vkbur.
        ENDIF.

        CLEAR wa_vat1-dudat.
        wa_vat1-dudat = wa_vat1-zfbdt.
        CLEAR wa_vat1-wrbtx.
        wa_vat1-wrbtr = wa_vat1-wrbtr * 100.
        wa_vat1-wrbt1 = wa_vat1-wrbt1 * 100.
        wa_vat1-wrbtx = wa_vat1-wrbtr - wa_vat1-wrbt1.
        CONCATENATE wa_vat1-bukrs wa_vat1-belnr wa_vat1-gjahr INTO
                    va_hname.

** Jika tgl pajak beda bulan dg tgl posting
**  maka tgl pajak = tgl akhir bulan
        IF wa_vat1-cityc = 'T0'.
          IF wa_vat1-dudat(6) NE wa_vat1-budat(6).
            CLEAR: ld_dat1st, ld_dat2nd.
            CALL FUNCTION 'HR_JP_MONTH_BEGIN_END_DATE'
              EXPORTING
                iv_date             = wa_vat1-budat
              IMPORTING
                ev_month_begin_date = ld_dat1st
                ev_month_end_date   = ld_dat2nd.
            wa_vat1-dudat = ld_dat2nd.
          ENDIF.
        ENDIF.
**

* Get VAT Number
*        IF wa_vat1-cityc = 'T0'.
*          CLEAR: wa_vat1-vatno, wa_vat1-vatpr.
*        ELSE.
        IF wa_vat1-dudat GE '20070101'.
          PERFORM f_get_flag_zproject.  "For project name PAJAK2013
          CLEAR: v_vatno,v_vatto,v_vatcd,v_vatold,v_posnr,v_vatpr1.
          SELECT SINGLE vatno vatto vatcd vatold posnr vatpr FROM zfvatnr
            INTO (v_vatno, v_vatto, v_vatcd, v_vatold, v_posnr, v_vatpr1)
            WHERE vkorg = p_vkorg AND
                  vkbur = '000'   AND
                  gjahr = wa_vat1-dudat(4).
          SELECT SINGLE bschl INTO l_vattrn
            FROM bsis
            WHERE bukrs = p_vkorg AND
                  bschl = '75'    AND
                  gjahr = wa_vat1-gjahr AND
                  belnr = wa_vat1-belnr AND
                  hkont LIKE '02%'.
          IF sy-subrc = 0.
            l_vattrn = '09'.
          ELSE.
            SELECT SINGLE vattrn FROM zfvattrn
              INTO l_vattrn
              WHERE vkorg = p_vkorg  AND
                    vkbur LIKE '02%' AND
                    gform = wa_vat1-gform.
            IF sy-subrc NE 0.
              l_vattrn = '01'.
            ENDIF.
          ENDIF.

          IF wa_vat1-dudat > gs_dpp-datab.
            IF l_vattrn = '01'.
              l_vattrn = '04'.
            ENDIF.
          ENDIF.

*  Rev. by Budi 15/03/2013 Req. by SJT
          IF v_flg_pajak2013 IS NOT INITIAL AND
             v_dat_pajak2013 LE wa_vat1-dudat.

            IF v_vatno GE v_vatto.
              ADD 10 TO v_posnr.
              SELECT SINGLE * FROM zfvatnr_dtl
                INTO CORRESPONDING FIELDS OF wa_zfvatnr_dtl
                WHERE vkorg = p_vkorg AND
                      vkbur = '000'   AND
                      gjahr = wa_vat1-dudat(4) AND
                      posnr = v_posnr.
              IF sy-subrc = 0.
                IF wa_zfvatnr_dtl-validfr IS NOT INITIAL AND
                  wa_zfvatnr_dtl-validto IS NOT INITIAL.
                  wa_dudat-low      = wa_zfvatnr_dtl-validfr.
                  wa_dudat-high     = wa_zfvatnr_dtl-validto.
                  wa_dudat-sign     = 'I'.
                  wa_dudat-option   = 'BT'.
                  APPEND wa_dudat TO lr_datum.
                ELSE.
                  MESSAGE i007.
                  EXIT.
                ENDIF.

                IF wa_vat1-dudat IN lr_datum.
                ELSE.
                  MESSAGE i007.
                  EXIT.
                ENDIF.

                v_vatto = wa_zfvatnr_dtl-vatto.
                v_vatno = wa_zfvatnr_dtl-vatfr.
                ld_vatpr = wa_zfvatnr_dtl-vatpr.
              ELSE.
                MESSAGE i007.
                EXIT.
              ENDIF.
              wa_vat1-vatno = v_vatno.
              wa_vat1-vatold = v_vatold.
*                CONCATENATE l_vattrn '0' v_vatcd wa_vat1-dudat+2(2) v_vatno
*                    INTO l_vatpr.
            ELSE.
              ADD 1 TO v_vatno.
              wa_vat1-vatno = v_vatno.
              wa_vat1-vatold = v_vatold.
              ld_vatpr = v_vatpr1.
*                CONCATENATE l_vattrn '0' v_vatcd wa_vat1-dudat+2(2) v_vatno
*                    INTO l_vatpr.
            ENDIF.

            IF ld_vatpr IS NOT INITIAL.
              ld_length = strlen( ld_vatpr ).
              ld_variant = 8 - ld_length.
              CONCATENATE l_vattrn '0' v_vatcd wa_vat1-dudat+2(2)
                          ld_vatpr v_vatno+ld_length(ld_variant) INTO l_vatpr.
            ELSE.
              CONCATENATE l_vattrn '0' v_vatcd wa_vat1-dudat+2(2)
                          v_vatno INTO l_vatpr.
            ENDIF.

          ELSE.
*              ADD 1 TO v_vatno.
            IF v_vatold = 9999999.
              CLEAR v_vatold.
            ENDIF.
            ADD 1 TO v_vatold.
            wa_vat1-vatno = v_vatno.
            wa_vat1-vatold = v_vatold.
            CONCATENATE l_vattrn '0' '000' wa_vat1-dudat+2(2) v_vatold
                INTO l_vatpr.
          ENDIF.
*            IF v_vatno = 9999999.
*              CLEAR v_vatno.
*            ENDIF.
*            ADD 1 TO v_vatno.
*            wa_vat1-vatno = v_vatno.
*            CONCATENATE l_vattrn '0' '000' wa_vat1-dudat+2(2) v_vatno
*                INTO l_vatpr.
*  End Rev. by Budi 15/03/2013 Req. by SJT

          WRITE l_vatpr TO wa_vat1-vatpr
                         USING EDIT MASK '___.___-__.________'.
        ELSE.
          IF v_vatno = 9999999.
            CLEAR v_vatno.
          ENDIF.
          ADD 1 TO v_vatno.
          wa_vat1-vatno = v_vatno.
*        WA_VAT1-VATPR = V_VATPR.
          CONCATENATE v_vatpr v_vatno INTO wa_vat1-vatpr.
        ENDIF.
*        ENDIF.

        MODIFY i_vat01 FROM wa_vat1.
        ADD 1 TO v_recno.

      ENDIF.

    ENDLOOP.

  ENDIF.

  IF p_reprnt = 'X' OR p_revise = 'X'.

    SELECT vkorg blart xblnr vbeln budat gjahr vkbur
           wrbtr sgtxt kunrg stras ort01 cityc pstlz
           stceg wrbt1 dudat vatno vatpr vatdt vatnm
           vattl zuonr bldat fname1 fstreet fhouse_num1
           fcity1 fpost_code1 name_co str_suppl1 str_suppl2
           netwr mwsbk
      FROM zfvato
      INTO (wa_vat1-bukrs, wa_vat1-blart, wa_vat1-xblnr,
           wa_vat1-belnr, wa_vat1-budat, wa_vat1-gjahr,
           wa_vat1-gsber, wa_vat1-wrbtr, wa_vat1-sgtxt,
           wa_vat1-kunnr, wa_vat1-stras, wa_vat1-ort01,
           wa_vat1-cityc, wa_vat1-pstlz, wa_vat1-stceg,
           wa_vat1-wrbt1, wa_vat1-dudat, wa_vat1-vatno,
           wa_vat1-vatpr, wa_vat1-vatdt, wa_vat1-vatnm,
           wa_vat1-vattl, wa_vat1-zuonr, wa_vat1-bldat,
           wa_vat1-fname1, wa_vat1-fstreet, wa_vat1-fhouse_num1,
           wa_vat1-fcity1, wa_vat1-fpost_code1, wa_vat1-name_co,
           wa_vat1-str_suppl1, wa_vat1-str_suppl2,
           wa_vat1-wrbtx, wa_vat1-mwsbk)
      WHERE vkorg = p_vkorg  AND
            vkbur = p_vkbur  AND
            vbeln = p_belnr  AND
            gjahr = p_gjahr  AND
            flag1 NE 'C'     AND
            vtart = 'FI'.

      SELECT SINGLE object1
        FROM zfvatnm
        INTO wa_vat1-object
        WHERE vkorg = wa_vat1-bukrs AND
              vkbur = p_vkbur.

      SELECT SINGLE stras ort01 cityc pstlz
                    stceg adrnr stkza
        FROM kna1
        INTO CORRESPONDING FIELDS OF wa_vat1
        WHERE kunnr = wa_vat1-kunnr.

      SELECT SINGLE name1 street house_num1 city1 city2
              post_code1 name_co str_suppl1 str_suppl2
              FROM adrc
              INTO (wa_vat1-fname1, wa_vat1-fstreet,
                    wa_vat1-fhouse_num1, wa_vat1-fcity1, wa_vat1-fcity2,
                    wa_vat1-fpost_code1, wa_vat1-name_co,
                    wa_vat1-str_suppl1, wa_vat1-str_suppl2)
              WHERE addrnumber = wa_vat1-adrnr.

      CLEAR wa_vat1-wrbtx.
      wa_vat1-wrbtr = wa_vat1-wrbtr * 100.
      wa_vat1-wrbt1 = wa_vat1-wrbt1 * 100.
      wa_vat1-wrbtx = wa_vat1-wrbtr - wa_vat1-wrbt1.
      CONCATENATE wa_vat1-bukrs wa_vat1-belnr wa_vat1-gjahr INTO
                  va_hname.
      ADD 1 TO v_recno.
      APPEND wa_vat1 TO i_vat01.

    ENDSELECT.

  ENDIF.

ENDFORM.                  " F_GETING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_form.

  CLEAR: wa_vat1, wa_vat2, vcount.
  SORT i_vat01 BY bukrs gsber belnr.
  LOOP AT i_vat01 INTO wa_vat1.
    CLEAR : oseq, osubtotal, osubtotal_l, osdisc, ovdisc ,opdisc, ototal,
                  vcount_dtl, otot_value, otot_disc, otax_base, otax_amt.
    ADD 1 TO vcount.
    PERFORM f_print_header.
    PERFORM f_print_sign.
    PERFORM f_print_footer.
    PERFORM f_print_detail.
    PERFORM f_print_summary.
*    PERFORM F_PRINT_SIGN.
*    PERFORM F_PRINT_FOOTER.
    IF vcount NE v_recno.
      PERFORM f_skip.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_WRITE_FORM

*&---------------------------------------------------------------------*
*&      Form  F_OPEN_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_open_form.

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      form          = 'ZF_VATOUT_FIN'
    IMPORTING
      result        = vresult
    EXCEPTIONS
      canceled      = 1
      device        = 2
      form          = 3
      options       = 4
      unclosed      = 5
      mail_options  = 6
      archive_error = 7
      OTHERS        = 8.

ENDFORM.                    " F_OPEN_FORM

*&---------------------------------------------------------------------*
*&      Form  F_OPEN_FORMSUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_open_formsut.

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      form          = 'ZF_VATOUT_FINSUT'
    IMPORTING
      result        = vresult
    EXCEPTIONS
      canceled      = 1
      device        = 2
      form          = 3
      options       = 4
      unclosed      = 5
      mail_options  = 6
      archive_error = 7
      OTHERS        = 8.

ENDFORM.                    " F_OPEN_FORMSUT

*&---------------------------------------------------------------------*
*&      Form  F_CLOSE_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_close_form.

  CALL FUNCTION 'CLOSE_FORM'
    IMPORTING
      result   = xresult
    EXCEPTIONS
      unopened = 1.

ENDFORM.                    " F_CLOSE_FORM

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_header.

  ofname1 = wa_vat1-fname1.
  ofstreet = wa_vat1-fstreet.
  ofhouse_num1 = wa_vat1-fhouse_num1.
  ofcity1 = wa_vat1-fcity1.
  ofcity2 = wa_vat1-fcity2.
  opost_code1 = wa_vat1-fpost_code1.
  ostceg = wa_vat1-stceg.
  IF wa_vat1-dudat GE '20070101'.
    ovatpr = wa_vat1-vatpr.
    IF wa_vat1-stkza IS INITIAL.
      onppkp = 'N.P.P.K.P :'.
    ELSE.
      CONCATENATE 'N.P.P.K.P :' ostceg INTO onppkp SEPARATED BY space.
    ENDIF.
  ELSE.
    CONCATENATE wa_vat1-vatpr+0(10) wa_vat1-vatpr+11(7) INTO ovatpr.
  ENDIF.
*  IF wa_vat1-cityc = 'T0'.
*    CLEAR: ostceg, ovatpr, onppkp.
*    CONCATENATE p_belnr '/' p_vkorg INTO ovatpr.
*  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'SERIAL'
    EXCEPTIONS
      OTHERS = 1.
*CALL FUNCTION 'WRITE_FORM'
*     EXPORTING
*         WINDOW = 'INFO1'
*     EXCEPTIONS
*         OTHERS  = 1.
*  IF wa_vat1-cityc = 'T0'.
*    CALL FUNCTION 'WRITE_FORM'
*         EXPORTING
*              element = 'NONNPWP'
*              window  = 'INFO'
*         EXCEPTIONS
*              OTHERS  = 1.
*  ELSEIF wa_vat1-cityc = 'T1'.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'NPWP'
      window  = 'INFO'
    EXCEPTIONS
      OTHERS  = 1.
*  CALL FUNCTION 'WRITE_FORM'
*       EXPORTING
*           ELEMENT = 'SPACE'
*           WINDOW = 'MAIN'
*       EXCEPTIONS
*           OTHERS  = 1.
*  ENDIF.

ENDFORM.                    " F_PRINT_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_detail.

  DATA : l_seq TYPE i.

  CALL FUNCTION 'READ_TEXT_INLINE'
    EXPORTING
      id             = '0004'
      inline_count   = 15
      language       = 'E'
      name           = va_hname
      object         = 'BELEG'
    TABLES
      inlines        = t_itab1
      lines          = i_sels1
    EXCEPTIONS
      id             = 1
      language       = 2
      name           = 3
      not_found      = 4
      object         = 5
      refrence_check = 6
      OTHERS         = 7.
  CHECK sy-subrc = 0.
  CLEAR: wa_sels, wa_vat2, o_rec, o_count.
  DESCRIBE TABLE i_sels1 LINES o_rec.
  LOOP AT i_sels1 INTO wa_sels.
    AT NEW tdformat.
      ADD 1 TO l_seq.
      oseq = l_seq.
    ENDAT.
    oprod = wa_sels-tdline+0(50).
    oqty = wa_sels-tdline+50(13).
    oqty = oqty / 100.
*    OPRICE = WA_SELS-TDLINE+63(15).
    ovalue = wa_sels-tdline+78(16).
    ouom = wa_sels-tdline+94(4).
    ototal = ototal + ovalue.
    ADD ovalue TO osubtotal.
    IF oseq IS INITIAL.
      osubtotal_l = osubtotal.
    ELSE.
      osubtotal_l = osubtotal - ovalue.
    ENDIF.
    ADD 1 TO o_count.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'ITEM_LINE'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.

    CLEAR oseq.

  ENDLOOP.

ENDFORM.                    " F_PRINT_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_SUMMARY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_summary.

*OTOTAL = WA_VAT1-WRBTX.
  otot_value = ototal.
  otax_base = ototal.
*OTAX_BASE = ( 100 / 110 ) * OTOTAL.
*OTAX_AMT = ( 10 / 100 ) * OTAX_BASE.WA_VAT1-WRBT1
  otax_amt = wa_vat1-wrbt1.

*CALL FUNCTION 'WRITE_FORM'
*     EXPORTING
*         ELEMENT = 'TOTAL'
*         WINDOW = 'MAIN'
*     EXCEPTIONS
*         OTHERS  = 1.

*  IF wa_vat1-cityc = 'T1'.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'NPWP'
      window  = 'SUM'
    EXCEPTIONS
      OTHERS  = 1.
*  ELSEIF wa_vat1-cityc = 'T0'.
*    CALL FUNCTION 'WRITE_FORM'
*         EXPORTING
*              element = 'NONNPWP'
*              window  = 'SUM'
*         EXCEPTIONS
*              OTHERS  = 1.
*  ENDIF.

*  IF wa_vat1-cityc = 'T1'.
  IF p_claim = 'X'.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'KLAIMNPWP'
        window  = 'SUM_TEXT'
      EXCEPTIONS
        OTHERS  = 1.
  ELSEIF p_jual = 'X'.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'JUALNPWP'
        window  = 'SUM_TEXT'
      EXCEPTIONS
        OTHERS  = 1.
  ENDIF.
*  ELSEIF wa_vat1-cityc = 'T0'.
*    IF p_claim = 'X'.
*      CALL FUNCTION 'WRITE_FORM'
*           EXPORTING
*                element = 'KLAIM'
*                window  = 'SUM_TEXT'
*           EXCEPTIONS
*                OTHERS  = 1.
*    ELSEIF p_jual = 'X'.
*      CALL FUNCTION 'WRITE_FORM'
*           EXPORTING
*                element = 'JUAL'
*                window  = 'SUM_TEXT'
*           EXCEPTIONS
*                OTHERS  = 1.
*    ENDIF.
*  ENDIF.

ENDFORM.                    " F_PRINT_SUMMARY

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_SIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_sign.

  odudat = wa_vat1-dudat.
  osign_name = wa_vat1-vatnm.
  osign_title = wa_vat1-vattl.
  oobject = wa_vat1-object.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'SIGN'
    EXCEPTIONS
      OTHERS = 1.

*  IF wa_vat1-cityc = 'T0'.
*    CALL FUNCTION 'WRITE_FORM'
*         EXPORTING
*              element = 'NONNPWP'
*              window  = 'GRAPH1'
*         EXCEPTIONS
*              OTHERS = 1.
*  ENDIF.
ENDFORM.                    " F_PRINT_SIGN

*&---------------------------------------------------------------------*
*&      Form  F_SKIP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_skip.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'SKIP'
      window  = 'MAIN'
    EXCEPTIONS
      OTHERS  = 1.

ENDFORM.                    " F_SKIP

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_file.

  IF p_prnt = 'X'.
    LOOP AT i_vat01 INTO wa_vat1.
      zfvato-mandt = sy-mandt.
      zfvato-vtart = 'FI'.
      zfvato-vkorg = wa_vat1-bukrs.
      zfvato-vkbur = wa_vat1-gsber.
      zfvato-gsber = wa_vat1-gsber.
      zfvato-blart = wa_vat1-blart.
      zfvato-xblnr = wa_vat1-xblnr.
      zfvato-vbeln = wa_vat1-belnr.
      zfvato-zuonr = wa_vat1-zuonr.
      zfvato-bldat = wa_vat1-bldat.
      zfvato-budat = wa_vat1-budat.
      zfvato-fkdat = wa_vat1-budat.
      zfvato-gjahr = wa_vat1-gjahr.
      zfvato-wrbtr = wa_vat1-wrbtr / 100.
      zfvato-sgtxt = wa_vat1-sgtxt.
      zfvato-kunrg = wa_vat1-kunnr.
      zfvato-name_co = wa_vat1-fname1.
      zfvato-str_suppl1 = wa_vat1-fstreet.
      zfvato-str_suppl2 = wa_vat1-fcity1.
      zfvato-stras = wa_vat1-stras.
      zfvato-ort01 = wa_vat1-ort01.
      zfvato-cityc = wa_vat1-cityc.
      zfvato-pstlz = wa_vat1-pstlz.
      zfvato-stceg = wa_vat1-stceg.
      zfvato-wrbt1 = wa_vat1-wrbt1 / 100.
*    ZFVATO-NETWR = WA_VAT1-WRBTX / 100.

      IF zfvato-budat > gs_dpp-datab.
        zfvato-netwr = ( value_tot / 100 ) * 11 / 12.
      ELSE.
        zfvato-netwr = value_tot / 100.
      ENDIF.

*    ZFVATO-MWSBK = ( 10 / 100 ) * ZFVATO-NETWR.
      zfvato-mwsbk = zfvato-wrbt1.
      zfvato-dudat = wa_vat1-dudat.
      zfvato-dueyr = wa_vat1-dudat+0(4).
      zfvato-duemm = wa_vat1-dudat+4(2).
      zfvato-adrnr = wa_vat1-adrnr.
      zfvato-fname1 = wa_vat1-fname1.
      zfvato-fstreet = wa_vat1-fstreet.
      zfvato-fhouse_num1 = wa_vat1-fhouse_num1.
      zfvato-fcity1 = wa_vat1-fcity1.
      zfvato-fpost_code1 = wa_vat1-fpost_code1.
      zfvato-vatno = wa_vat1-vatno.
      zfvato-vatpr = wa_vat1-vatpr.
      zfvato-vatdt = wa_vat1-vatdt.
      zfvato-vatnm = wa_vat1-vatnm.
      zfvato-vattl = wa_vat1-vattl.
      zfvato-waerk = 'IDR'.
      MODIFY zfvato.
    ENDLOOP.

*    IF wa_vat1-cityc = 'T1'.
    IF wa_vat1-dudat GE '20070101'.
      IF wa_zfvatnr_dtl IS NOT INITIAL.
        UPDATE zfvatnr SET vatno = v_vatno
                           vatold = v_vatold
                           vatfr = wa_zfvatnr_dtl-vatfr
                           vatto = wa_zfvatnr_dtl-vatto
                           vatpr = wa_zfvatnr_dtl-vatpr
                           vatdt = wa_zfvatnr_dtl-vatdt
                           vatcd = wa_zfvatnr_dtl-vatcd
                           posnr = wa_zfvatnr_dtl-posnr
          WHERE vkorg = p_vkorg AND
                vkbur = '000'   AND
                gjahr = wa_vat1-dudat(4).
      ELSE.
        UPDATE zfvatnr SET vatno = v_vatno
                           vatold = v_vatold
          WHERE vkorg = p_vkorg AND
                vkbur = '000'   AND
                gjahr = wa_vat1-dudat(4).
      ENDIF.
    ELSE.
      UPDATE zfvatnr SET vatno = v_vatno
        WHERE vkorg = p_vkorg AND
              vkbur = p_vkbur.
    ENDIF.
*    ENDIF.
    PERFORM release_lock.
  ENDIF.
  IF p_reprnt = 'X'.
    LOOP AT i_vat01 INTO wa_vat1.
      UPDATE zfvato SET stras = wa_vat1-stras
                        ort01 = wa_vat1-ort01
                        pstlz = wa_vat1-stras
                        stceg = wa_vat1-stceg
                        adrnr = wa_vat1-adrnr
                        fstreet = wa_vat1-fstreet
                        fhouse_num1 = wa_vat1-fhouse_num1
                        fcity1 = wa_vat1-fcity1
                        fpost_code1 = wa_vat1-fpost_code1
                        name_co = wa_vat1-fname1
                        str_suppl1 = wa_vat1-fstreet
                        str_suppl2 = wa_vat1-fcity1
                  WHERE vkorg = wa_vat1-bukrs AND
                        vkbur = wa_vat1-gsber AND
                        vatno = wa_vat1-vatno.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_WRITE_FILE

*&---------------------------------------------------------------------*
*&      Form  F_GETING_DATA_CANCL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_geting_data_cancl.

  SELECT *
    FROM zfvato
    INTO CORRESPONDING FIELDS OF TABLE i_vatalv
    WHERE vkorg = p_vkorg  AND
          vkbur = p_vkbur  AND
          vbeln = p_belnr  AND
          gjahr = p_gjahr  AND
          flag1 NE 'C'     AND
          vtart = 'FI'.

ENDFORM.                    " F_GETING_DATA_CANCL

*&---------------------------------------------------------------------*
*&      Form  F_GETING_DATA_MNUMB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_geting_data_mnumb.

  CLEAR wa_vat3.
  s2vkorg = p_vkorg.
*  IF p_vkorg = '8020'.
*    s2vkbur = '0200'.
*  ELSE.
  s2vkbur = p_vkbur.
*  ENDIF.
  SELECT SINGLE vtext FROM tvkot
    INTO s2vkorgt
    WHERE vkorg = s2vkorg AND
          ( spras = 'E' OR spras = 'EN' ).

  SELECT SINGLE bezei FROM tvkbt
    INTO s2vkburt
    WHERE vkbur = s2vkbur AND
          ( spras = 'E' OR spras = 'EN' ).

  IF p_vkorg EQ '8070'.
    SELECT SINGLE * FROM zfvatnr
      INTO CORRESPONDING FIELDS OF wa_vat3
      WHERE vkorg = p_vkorg.
  ELSE.
    SELECT SINGLE * FROM zfvatnr
      INTO CORRESPONDING FIELDS OF wa_vat3
      WHERE vkorg = p_vkorg AND
            vkbur = p_vkbur.
  ENDIF.

  PERFORM release_lock.

  IF sy-subrc = 0.
    vflag1 = 1.
  ENDIF.
  s2vatno = wa_vat3-vatno.
  s2vatfr = wa_vat3-vatfr.
  s2vatto = wa_vat3-vatto.
  s2vatpr = wa_vat3-vatpr.
  s2vatdt = wa_vat3-vatdt.
  s2gjahr = wa_vat3-gjahr.

ENDFORM.                    " F_GETING_DATA_MNUMB

*&---------------------------------------------------------------------*
*&      Form  F_GETING_DATA_MSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_geting_data_msign.

  CLEAR wa_vat4.
  s2vkorg = p_vkorg.
*  IF p_vkorg = '8020'.
*    s2vkbur = '0200'.
*  ELSE.
  s2vkbur = p_vkbur.
*  ENDIF.
  SELECT SINGLE vtext FROM tvkot
    INTO s2vkorgt
    WHERE vkorg = s2vkorg AND
          ( spras = 'E' OR spras = 'EN' ).
  SELECT SINGLE bezei FROM tvkbt
    INTO s2vkburt
    WHERE vkbur = s2vkbur AND
          ( spras = 'E' OR spras = 'EN' ).
  SELECT * FROM zfvatnm
    INTO CORRESPONDING FIELDS OF wa_vat4
    WHERE vkorg = p_vkorg AND
          vkbur = p_vkbur AND
          vtart = 'FI'.
  ENDSELECT.
  s3vkorg = p_vkorg.
  s3vkbur = p_vkbur.
  s3vatnm = wa_vat4-vatnm.
  s3vattl = wa_vat4-vattl.
  s3object = wa_vat4-object1.

ENDFORM.                    " F_GETING_DATA_MSIGN

*&---------------------------------------------------------------------*
*&      Form  F_INIT_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_screen.
  CLEAR: prod1, qty1, price1, value1, msg1,
         prod2, qty2, price2, value2, msg2,
         prod3, qty3, price3, value3, msg3,
         prod4, qty4, price4, value4, msg4,
         prod5, qty5, price5, value5, msg5,
         prod6, qty6, price6, value6, msg6,
         prod7, qty7, price7, value7, msg7,
         prod8, qty8, price8, value8, msg8,
         prod9, qty9, price9, value9, msg9,
         prod10, qty10, price10, value10, msg10,
         prod11, qty11, price11, value11, msg11,
         prod12, qty12, price12, value12, msg12,
         prod13, qty13, price13, value13, msg13,
         prod14, qty14, price14, value14, msg14,
         prod15, qty15, price15, value15, msg15,
         value_tot, msglin, v_tax, v_var.
ENDFORM.                    " F_INIT_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_INIT_MASSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_massage.
  CLEAR: value1, msg1,
         value2, msg2,
         value3, msg3,
         value4, msg4,
         value5, msg5,
         value6, msg6,
         value7, msg7,
         value8, msg8,
         value9, msg9,
         value10, msg10,
         value11, msg11,
         value12, msg12,
         value13, msg13,
         value14, msg14,
         value15, msg15,
         value_tot, msglin.
ENDFORM.                    " F_INIT_MASSAGE

*&---------------------------------------------------------------------*
*&      Form  F_READ_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_read_text.

  CALL FUNCTION 'READ_TEXT_INLINE'
    EXPORTING
      id             = '0004'
      inline_count   = 15
      language       = 'E'
      name           = va_hname
      object         = 'BELEG'
    TABLES
      inlines        = t_itab1
      lines          = i_sels1
    EXCEPTIONS
      id             = 1
      language       = 2
      name           = 3
      not_found      = 4
      object         = 5
      refrence_check = 6
      OTHERS         = 7.
  CHECK sy-subrc = 0.
  CLEAR: wa_sels, wa_vat2, vcount.
  LOOP AT i_sels1 INTO wa_sels.
    AT NEW tdformat.
      CLEAR vcount.
    ENDAT.
    ADD 1 TO vcount.
    CASE wa_sels-tdformat.
      WHEN '01'.
        CASE vcount.
          WHEN 1.
            prod1 = wa_sels-tdline+0(50).
            qty1 = wa_sels-tdline+50(13).
            qty1 = qty1 / 100.
            price1 = wa_sels-tdline+63(15).
            value1 = wa_sels-tdline+78(16).
            uom1 = wa_sels-tdline+94(4).
          WHEN 2.
            prod1a = wa_sels-tdline+0(50).
          WHEN 3.
            prod1b = wa_sels-tdline+0(50).
          WHEN 4.
            prod1c = wa_sels-tdline+0(50).
        ENDCASE.
      WHEN '02'.
        CASE vcount.
          WHEN 1.
            prod2 = wa_sels-tdline+0(50).
            qty2 = wa_sels-tdline+50(13).
            qty2 = qty2 / 100.
            price2 = wa_sels-tdline+63(15).
            value2 = wa_sels-tdline+78(16).
            uom2 = wa_sels-tdline+94(4).
          WHEN 2.
            prod2a = wa_sels-tdline+0(50).
          WHEN 3.
            prod2b = wa_sels-tdline+0(50).
          WHEN 4.
            prod2c = wa_sels-tdline+0(50).
        ENDCASE.
      WHEN '03'.
        CASE vcount.
          WHEN 1.
            prod3 = wa_sels-tdline+0(50).
            qty3 = wa_sels-tdline+50(13).
            qty3 = qty3 / 100.
            price3 = wa_sels-tdline+63(15).
            value3 = wa_sels-tdline+78(16).
            uom3 = wa_sels-tdline+94(4).
          WHEN 2.
            prod3a = wa_sels-tdline+0(50).
          WHEN 3.
            prod3b = wa_sels-tdline+0(50).
          WHEN 4.
            prod3c = wa_sels-tdline+0(50).
        ENDCASE.
      WHEN '04'.
        CASE vcount.
          WHEN 1.
            prod4 = wa_sels-tdline+0(50).
            qty4 = wa_sels-tdline+50(13).
            qty4 = qty4 / 100.
            price4 = wa_sels-tdline+63(15).
            value4 = wa_sels-tdline+78(16).
            uom4 = wa_sels-tdline+94(4).
          WHEN 2.
            prod4a = wa_sels-tdline+0(50).
          WHEN 3.
            prod4b = wa_sels-tdline+0(50).
          WHEN 4.
            prod4c = wa_sels-tdline+0(50).
        ENDCASE.
      WHEN '05'.
        CASE vcount.
          WHEN 1.
            prod5 = wa_sels-tdline+0(50).
            qty5 = wa_sels-tdline+50(13).
            qty5 = qty5 / 100.
            price5 = wa_sels-tdline+63(15).
            value5 = wa_sels-tdline+78(16).
            uom5 = wa_sels-tdline+94(4).
          WHEN 2.
            prod5a = wa_sels-tdline+0(50).
          WHEN 3.
            prod5b = wa_sels-tdline+0(50).
          WHEN 4.
            prod5c = wa_sels-tdline+0(50).
        ENDCASE.
      WHEN '06'.
        CASE vcount.
          WHEN 1.
            prod6 = wa_sels-tdline+0(50).
            qty6 = wa_sels-tdline+50(13).
            qty6 = qty6 / 100.
            price6 = wa_sels-tdline+63(15).
            value6 = wa_sels-tdline+78(16).
            uom6 = wa_sels-tdline+94(4).
          WHEN 2.
            prod6a = wa_sels-tdline+0(50).
          WHEN 3.
            prod6b = wa_sels-tdline+0(50).
          WHEN 4.
            prod6c = wa_sels-tdline+0(50).
        ENDCASE.
      WHEN '07'.
        CASE vcount.
          WHEN 1.
            prod7 = wa_sels-tdline+0(50).
            qty7 = wa_sels-tdline+50(13).
            qty7 = qty7 / 100.
            price7 = wa_sels-tdline+63(15).
            value7 = wa_sels-tdline+78(16).
            uom7 = wa_sels-tdline+94(4).
          WHEN 2.
            prod7a = wa_sels-tdline+0(50).
          WHEN 3.
            prod7b = wa_sels-tdline+0(50).
          WHEN 4.
            prod7c = wa_sels-tdline+0(50).
        ENDCASE.
      WHEN '08'.
        CASE vcount.
          WHEN 1.
            prod8 = wa_sels-tdline+0(50).
            qty8 = wa_sels-tdline+50(13).
            qty8 = qty8 / 100.
            price8 = wa_sels-tdline+63(15).
            value8 = wa_sels-tdline+78(16).
            uom8 = wa_sels-tdline+94(4).
          WHEN 2.
            prod8a = wa_sels-tdline+0(50).
          WHEN 3.
            prod8b = wa_sels-tdline+0(50).
          WHEN 4.
            prod8c = wa_sels-tdline+0(50).
        ENDCASE.
      WHEN '09'.
        CASE vcount.
          WHEN 1.
            prod9 = wa_sels-tdline+0(50).
            qty9 = wa_sels-tdline+50(13).
            qty9 = qty9 / 100.
            price9 = wa_sels-tdline+63(15).
            value9 = wa_sels-tdline+78(16).
            uom9 = wa_sels-tdline+94(4).
          WHEN 2.
            prod9a = wa_sels-tdline+0(50).
          WHEN 3.
            prod9b = wa_sels-tdline+0(50).
          WHEN 4.
            prod9c = wa_sels-tdline+0(50).
        ENDCASE.
      WHEN '10'.
        CASE vcount.
          WHEN 1.
            prod10 = wa_sels-tdline+0(50).
            qty10 = wa_sels-tdline+50(13).
            qty10 = qty10 / 100.
            price10 = wa_sels-tdline+63(15).
            value10 = wa_sels-tdline+78(16).
            uom10 = wa_sels-tdline+94(4).
          WHEN 2.
            prod10a = wa_sels-tdline+0(50).
          WHEN 3.
            prod10b = wa_sels-tdline+0(50).
          WHEN 4.
            prod10c = wa_sels-tdline+0(50).
        ENDCASE.
      WHEN '11'.
        CASE vcount.
          WHEN 1.
            prod11 = wa_sels-tdline+0(50).
            qty11 = wa_sels-tdline+50(13).
            qty11 = qty11 / 100.
            price11 = wa_sels-tdline+63(15).
            value11 = wa_sels-tdline+78(16).
            uom11 = wa_sels-tdline+94(4).
          WHEN 2.
            prod11a = wa_sels-tdline+0(50).
          WHEN 3.
            prod11b = wa_sels-tdline+0(50).
          WHEN 4.
            prod11c = wa_sels-tdline+0(50).
        ENDCASE.
      WHEN '12'.
        CASE vcount.
          WHEN 1.
            prod12 = wa_sels-tdline+0(50).
            qty12 = wa_sels-tdline+50(13).
            qty12 = qty12 / 100.
            price12 = wa_sels-tdline+63(15).
            value12 = wa_sels-tdline+78(16).
            uom12 = wa_sels-tdline+94(4).
          WHEN 2.
            prod12a = wa_sels-tdline+0(50).
          WHEN 3.
            prod12b = wa_sels-tdline+0(50).
          WHEN 4.
            prod12c = wa_sels-tdline+0(50).
        ENDCASE.
      WHEN '13'.
        CASE vcount.
          WHEN 1.
            prod13 = wa_sels-tdline+0(50).
            qty13 = wa_sels-tdline+50(13).
            qty13 = qty13 / 100.
            price13 = wa_sels-tdline+63(15).
            value13 = wa_sels-tdline+78(16).
            uom13 = wa_sels-tdline+94(4).
          WHEN 2.
            prod13a = wa_sels-tdline+0(50).
          WHEN 3.
            prod13b = wa_sels-tdline+0(50).
          WHEN 4.
            prod13c = wa_sels-tdline+0(50).
        ENDCASE.
      WHEN '14'.
        CASE vcount.
          WHEN 1.
            prod14 = wa_sels-tdline+0(50).
            qty14 = wa_sels-tdline+50(13).
            qty14 = qty14 / 100.
            price14 = wa_sels-tdline+63(15).
            value14 = wa_sels-tdline+78(16).
            uom14 = wa_sels-tdline+94(4).
          WHEN 2.
            prod14a = wa_sels-tdline+0(50).
          WHEN 3.
            prod14b = wa_sels-tdline+0(50).
          WHEN 4.
            prod14c = wa_sels-tdline+0(50).
        ENDCASE.
      WHEN '15'.
        CASE vcount.
          WHEN 1.
            prod15 = wa_sels-tdline+0(50).
            qty15 = wa_sels-tdline+50(13).
            qty15 = qty15 / 100.
            price15 = wa_sels-tdline+63(15).
            value15 = wa_sels-tdline+78(16).
            uom15 = wa_sels-tdline+94(4).
          WHEN 2.
            prod15a = wa_sels-tdline+0(50).
          WHEN 3.
            prod15b = wa_sels-tdline+0(50).
          WHEN 4.
            prod15c = wa_sels-tdline+0(50).
        ENDCASE.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " F_READ_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_OPEN_FORM_EC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_open_form_ec.

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      form          = 'ZF_VATOUT_FINEC'
    IMPORTING
      result        = vresult
    EXCEPTIONS
      canceled      = 1
      device        = 2
      form          = 3
      options       = 4
      unclosed      = 5
      mail_options  = 6
      archive_error = 7
      OTHERS        = 8.

ENDFORM.                    " F_OPEN_FORM_EC

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_FORM_EC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_form_ec.

  CLEAR: wa_vat1, wa_vat2, vcount.
  SORT i_vat01 BY bukrs gsber belnr.
  LOOP AT i_vat01 INTO wa_vat1.
    CLEAR : oseq, osubtotal, osubtotal_l, osdisc, ovdisc ,opdisc, ototal,
                  vcount_dtl, otot_value, otot_disc, otax_base, otax_amt.
    CLEAR : obutxt,ostret, ocity1, ohousenum1, ocnpwp, opkpdt.
    ADD 1 TO vcount.
    SELECT SINGLE butxt
      FROM t001
      INTO obutxt
      WHERE bukrs = p_vkorg.
    SELECT SINGLE a~street a~city1 a~house_num1
      FROM adrc AS a JOIN
           tvbur AS b ON
           a~addrnumber = b~adrnr
      INTO (ostret, ocity1, ohousenum1)
      WHERE b~vkbur = p_vkbur.
    SELECT SINGLE npwp pkdat
      FROM zftax
      INTO (ocnpwp, opkpdt)
      WHERE bukrs = p_vkorg AND
            gsber = p_vkbur.
    PERFORM f_print_header.
    PERFORM f_print_detail.
    PERFORM f_print_summary.
    PERFORM f_print_sign.
    PERFORM f_print_footer.
    IF vcount NE v_recno.
      PERFORM f_skip.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_WRITE_FORM_EC

*&---------------------------------------------------------------------*
*&      Form  F_CLOSE_FORM_EC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_close_form_ec.

  CALL FUNCTION 'CLOSE_FORM'
    IMPORTING
      result   = xresult
    EXCEPTIONS
      unopened = 1.

ENDFORM.                    " F_CLOSE_FORM_EC
*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FOOTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_footer.

  obln = wa_vat1-bldat+4(2).
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'FOOTER'
    EXCEPTIONS
      OTHERS = 1.

ENDFORM.                    " F_PRINT_FOOTER

*&---------------------------------------------------------------------*
*&      Form  CEK_LOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek_lock.
  CALL FUNCTION 'ENQUEUE_EZ0005'
    EXPORTING
      vkorg          = p_vkorg
      vkbur          = p_vkbur
    EXCEPTIONS
      foreign_lock   = 4
      system_failure = 8.
  IF sy-subrc EQ 4.
    MESSAGE a000(zf) WITH 'Transaction current process by another W-S'.
  ENDIF.

ENDFORM.                    " CEK_LOCK

*&---------------------------------------------------------------------*
*&      Form  RELEASE_LOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM release_lock.
  CALL FUNCTION 'DEQUEUE_EZ0005'
    EXPORTING
      vkorg = p_vkorg
      vkbur = p_vkbur.

ENDFORM.                    " RELEASE_LOCK

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_append_itab USING fu_text.

  CLEAR wa_vat5.
  CASE fu_text.
    WHEN '01'.
      IF NOT prod1a IS INITIAL.
        wa_vat5-no = text1.
        wa_vat5-prod = prod1a.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod1b IS INITIAL.
        wa_vat5-no = text1.
        wa_vat5-prod = prod1b.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod1c IS INITIAL.
        wa_vat5-no = text1.
        wa_vat5-prod = prod1c.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
    WHEN '02'.
      IF NOT prod2a IS INITIAL.
        wa_vat5-no = text2.
        wa_vat5-prod = prod2a.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod2b IS INITIAL.
        wa_vat5-no = text2.
        wa_vat5-prod = prod2b.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod2c IS INITIAL.
        wa_vat5-no = text2.
        wa_vat5-prod = prod2c.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
    WHEN '03'.
      IF NOT prod3a IS INITIAL.
        wa_vat5-no = text3.
        wa_vat5-prod = prod3a.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod3b IS INITIAL.
        wa_vat5-no = text3.
        wa_vat5-prod = prod3b.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod3c IS INITIAL.
        wa_vat5-no = text3.
        wa_vat5-prod = prod3c.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
    WHEN '04'.
      IF NOT prod4a IS INITIAL.
        wa_vat5-no = text4.
        wa_vat5-prod = prod4a.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod4b IS INITIAL.
        wa_vat5-no = text4.
        wa_vat5-prod = prod4b.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod4c IS INITIAL.
        wa_vat5-no = text4.
        wa_vat5-prod = prod4c.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
    WHEN '05'.
      IF NOT prod5a IS INITIAL.
        wa_vat5-no = text5.
        wa_vat5-prod = prod5a.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod5b IS INITIAL.
        wa_vat5-no = text5.
        wa_vat5-prod = prod5b.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod5c IS INITIAL.
        wa_vat5-no = text5.
        wa_vat5-prod = prod5c.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
    WHEN '06'.
      IF NOT prod6a IS INITIAL.
        wa_vat5-no = text6.
        wa_vat5-prod = prod6a.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod6b IS INITIAL.
        wa_vat5-no = text6.
        wa_vat5-prod = prod6b.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod6c IS INITIAL.
        wa_vat5-no = text6.
        wa_vat5-prod = prod6c.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
    WHEN '07'.
      IF NOT prod7a IS INITIAL.
        wa_vat5-no = text7.
        wa_vat5-prod = prod7a.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod7b IS INITIAL.
        wa_vat5-no = text7.
        wa_vat5-prod = prod7b.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod7c IS INITIAL.
        wa_vat5-no = text7.
        wa_vat5-prod = prod7c.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
    WHEN '08'.
      IF NOT prod8a IS INITIAL.
        wa_vat5-no = text8.
        wa_vat5-prod = prod8a.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod8b IS INITIAL.
        wa_vat5-no = text8.
        wa_vat5-prod = prod8b.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod8c IS INITIAL.
        wa_vat5-no = text8.
        wa_vat5-prod = prod8c.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
    WHEN '09'.
      IF NOT prod9a IS INITIAL.
        wa_vat5-no = text9.
        wa_vat5-prod = prod9a.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod9b IS INITIAL.
        wa_vat5-no = text9.
        wa_vat5-prod = prod9b.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod9c IS INITIAL.
        wa_vat5-no = text9.
        wa_vat5-prod = prod9c.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
    WHEN '10'.
      IF NOT prod10a IS INITIAL.
        wa_vat5-no = text10.
        wa_vat5-prod = prod10a.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod10b IS INITIAL.
        wa_vat5-no = text10.
        wa_vat5-prod = prod10b.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod10c IS INITIAL.
        wa_vat5-no = text10.
        wa_vat5-prod = prod10c.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
    WHEN '11'.
      IF NOT prod11a IS INITIAL.
        wa_vat5-no = text11.
        wa_vat5-prod = prod11a.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod11b IS INITIAL.
        wa_vat5-no = text11.
        wa_vat5-prod = prod11b.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod11c IS INITIAL.
        wa_vat5-no = text11.
        wa_vat5-prod = prod11c.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
    WHEN '12'.
      IF NOT prod12a IS INITIAL.
        wa_vat5-no = text12.
        wa_vat5-prod = prod12a.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod12b IS INITIAL.
        wa_vat5-no = text12.
        wa_vat5-prod = prod12b.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod12c IS INITIAL.
        wa_vat5-no = text12.
        wa_vat5-prod = prod12c.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
    WHEN '13'.
      IF NOT prod13a IS INITIAL.
        wa_vat5-no = text13.
        wa_vat5-prod = prod13a.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod13b IS INITIAL.
        wa_vat5-no = text13.
        wa_vat5-prod = prod13b.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod13c IS INITIAL.
        wa_vat5-no = text13.
        wa_vat5-prod = prod13c.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
    WHEN '14'.
      IF NOT prod14a IS INITIAL.
        wa_vat5-no = text14.
        wa_vat5-prod = prod14a.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod14b IS INITIAL.
        wa_vat5-no = text14.
        wa_vat5-prod = prod14b.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod14c IS INITIAL.
        wa_vat5-no = text14.
        wa_vat5-prod = prod14c.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
    WHEN '15'.
      IF NOT prod15a IS INITIAL.
        wa_vat5-no = text15.
        wa_vat5-prod = prod15a.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod15b IS INITIAL.
        wa_vat5-no = text15.
        wa_vat5-prod = prod15b.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
      IF NOT prod15c IS INITIAL.
        wa_vat5-no = text15.
        wa_vat5-prod = prod15c.
        APPEND wa_vat5 TO i_vat05.
      ENDIF.
  ENDCASE.

ENDFORM.                    " F_APPEND_ITAB

*&---------------------------------------------------------------------*
*&      Form  F_GET_FLAG_ZPROJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_flag_zproject .
  CLEAR: v_dat_pajak2013,v_flg_pajak2013.
  SELECT SINGLE datab flag INTO (v_dat_pajak2013, v_flg_pajak2013)
    FROM zproject WHERE name = 'PAJAK2013'.
ENDFORM.                    " F_GET_FLAG_ZPROJECT

*&---------------------------------------------------------------------*
*&      Form  F_TAX_CALC
*&---------------------------------------------------------------------*
FORM f_tax_calc  USING    fu_datum fu_wrbtr fu_calty
                 CHANGING fc_wrbtr.

  DATA: p1_wrbtr TYPE netwr_ak,
        p2_wrbtr TYPE netwr_ak.
  CLEAR: p1_wrbtr, p2_wrbtr.
  p1_wrbtr = fu_wrbtr.
  CALL FUNCTION 'Z_PPN11'
    EXPORTING
      pi_wrbtr = p1_wrbtr
      pi_calty = fu_calty
      pi_datum = fu_datum
    IMPORTING
      po_wrbtr = p2_wrbtr.
  fc_wrbtr = p2_wrbtr.
ENDFORM.                    " F_TAX_CALC
