*&---------------------------------------------------------------------*
*& Program Name     : ZGDPP_E0005                                      *
*& Module Name      : PP                                               *
*& Author           : xxxxxx xxx , xxxxx xxxxx                         *
*& Functional       :                                                  *
*& Create Date      : dd/mm/yyyy                                       *
*& Program Type     : Report/Enhancement                               *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : xxxxxxxxxx xx xxxxxx xxxxxxx xxxx xxxx xxxxx     *
*&                    xxxx xx xxxxxxx xxxx xx xx xx xxxxxxxxx          *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zgdpp_e0005
               NO STANDARD PAGE HEADING
               LINE-SIZE 255.
*              ZFU.                 "Message class for Finish Unit
*              ZSP.                 "Spare Parts
*              ZPE.                 "Production and Engineering
*              ZFA.                 "Finance
*              ZAB.                 "ABAP and Tools

*------------------standard common includes----------------------------*
* Authorization checking macros
INCLUDE zabp_atz.

* Upload and download flat file macors
INCLUDE zabp_udf.

* common report header and other functions
INCLUDE zabp_header.

* other common functions
INCLUDE zabp_frm.

* ALV common functions
INCLUDE zabp_alv_common.

* BDC Include
INCLUDE zabp_bdc.
*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zgdppe0005top.
*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.

PARAMETERS:
  p_werks  LIKE caufv-werks OBLIGATORY.

SELECT-OPTIONS:
  s_auart  FOR caufv-auart OBLIGATORY,
  s_plnbez FOR caufv-plnbez,
  s_aufnr FOR caufv-aufnr,
  s_ftrmi FOR caufv-ftrmi OBLIGATORY,
  s_budat FOR afru-budat OBLIGATORY.

SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-002.

*PARAMETERS: p_chk1 AS CHECKBOX DEFAULT 'X',
*            p_chk2 AS CHECKBOX DEFAULT 'X',
*            p_chk3 AS CHECKBOX DEFAULT 'X',
*            p_chk4 AS CHECKBOX DEFAULT 'X',
*            p_chk5 AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK data1.

SELECTION-SCREEN SKIP 1.

PARAMETERS: p_vari  LIKE disvariant-variant, " ALV Variant
            p_test  AS CHECKBOX DEFAULT 'X', "test run
            p_back  AS CHECKBOX.        "background exec (skip report)

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_werks.
  DATA: l_werks.
  SELECT SINGLE werks
    FROM t001w
    INTO l_werks
    WHERE werks EQ p_werks.
  IF sy-subrc NE 0.
    MESSAGE e000(zab) WITH 'Entry does not exist'.
  ENDIF.

*-Authorization
  macro_atz_single_werks p_werks c_atz_display.

AT SELECTION-SCREEN ON s_auart.
  DATA: BEGIN OF lt_auart OCCURS 10000,
          auart LIKE t399x-auart,
        END OF lt_auart.
  CHECK NOT s_auart[] IS INITIAL.
  SELECT auart
    FROM t399x
    INTO TABLE lt_auart
    WHERE auart IN s_auart AND
          werks EQ p_werks.
  IF sy-subrc NE 0.
    MESSAGE e000(zab) WITH
    'Order type not found in the specified Plant'.
  ELSE.
    READ TABLE lt_auart WITH KEY auart = 'ZI08'.
    IF sy-subrc = 0.
      MESSAGE e000(zab) WITH
      'Repack order can not update Manufacturing Date'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON s_plnbez.
  DATA: BEGIN OF lt_matnr OCCURS 10000,
          matnr LIKE mara-matnr,
        END OF lt_matnr.
  CHECK NOT s_plnbez[] IS INITIAL.
  SELECT matnr
    FROM marc
    INTO TABLE lt_matnr
    WHERE matnr IN s_plnbez AND
          werks EQ p_werks.
  IF sy-subrc NE 0.
    MESSAGE e000(zab) WITH
    'Material not found in the specified Plant'.
  ENDIF.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
* for alv variant
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f_f4_for_variant_alv USING p_vari.
*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  IF p_back IS INITIAL.
    PERFORM f_print_data.
  ELSE.
    PERFORM f_post_entries.
  ENDIF.
  PERFORM f_free_memory.
*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zgdppe0005f01.
*------------------common includes for the program---------------------*



*Selection texts
*---------------
*SP_CHK1          CBU Delivery
*SP_CHK2          Trimming Off
*SP_CHK4          Welding Off
*SP_DATE          Month
*SS_WERKS         Plant
