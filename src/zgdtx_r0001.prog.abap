*&---------------------------------------------------------------------*
*& Title:        Buku Pembelian/ Import                                *
*&---------------------------------------------------------------------*
*& SAP Application Module : TX
*&---------------------------------------------------------------------*

REPORT zgdtx_r0001 NO STANDARD PAGE HEADING LINE-SIZE 300.

*-----------------------------------------------------------------------
* include programs
*-----------------------------------------------------------------------
* Authorization checking macros
INCLUDE zabp_atz.

INCLUDE zgdtxnr0001top.

*------------------------------------------------------------------
* Selection-screen
*------------------------------------------------------------------
SELECTION-SCREEN : BEGIN OF BLOCK dat1 WITH FRAME TITLE text-d01.

PARAMETERS : p_bukrs LIKE zgdtxdt0012-bukrs OBLIGATORY
                                            MEMORY ID buk,
             p_brnch LIKE zgdtxdt0012-brnch OBLIGATORY
                                            MEMORY ID zbr.
SELECT-OPTIONS: s_busln FOR zgdtxdt0012-busln NO-DISPLAY,
                s_form FOR zgdtxdt0012-form
*                       NO-EXTENSION
                       NO INTERVALS.
SELECTION-SCREEN END OF BLOCK dat1.

SELECTION-SCREEN : BEGIN OF BLOCK dat2 WITH FRAME TITLE text-d02.

*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN POSITION 01.
*PARAMETERS  p_masatx RADIOBUTTON GROUP rad1 USER-COMMAND proses.
*SELECTION-SCREEN COMMENT 05(15) text-002 FOR FIELD p_masatx.
*SELECTION-SCREEN POSITION 22.
PARAMETERS: p_mtxin LIKE zgdtxdt0012-masatx OBLIGATORY,
            p_vari LIKE disvariant-variant.
*SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 01.
PARAMETERS: p_espt AS CHECKBOX  USER-COMMAND spt.   "added for Tempo for
                                                    "ESPT Download
*PARAMETERS  p_budat RADIOBUTTON GROUP rad1.
SELECTION-SCREEN COMMENT 05(12) text-900 FOR FIELD p_espt.
SELECTION-SCREEN POSITION 18.
SELECTION-SCREEN COMMENT 18(14) text-901.
PARAMETERS: p_korek DEFAULT '0'.
*SELECT-OPTIONS s_mdatin FOR zGDTXdt0012-budat.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK dat2.

PARAMETERS p_down AS CHECKBOX MODIF ID dow.
PARAMETERS p_down11 AS CHECKBOX MODIF ID dow.

*SELECTION-SCREEN  BEGIN OF BLOCK dat2 WITH FRAME TITLE text-005.
*PARAMETERS :
*  p_print  LIKE nast-ldest   DEFAULT 'epson',
*  p_lyout  LIKE tsp1d-papart DEFAULT 'Z_65_255_17CPI' OBLIGATORY.
*SELECTION-SCREEN END OF BLOCK dat2.


*-----------------------------------------------------------------------
* Events on selection screens
*-----------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
*  PERFORM f_select_period.
  PERFORM f_screen_download.

AT SELECTION-SCREEN ON p_bukrs.
  macro_atz_single_bukrs p_bukrs c_atz_display.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f_f4_for_variant_alv USING p_vari.

*-----------------------------------------------------------------------
* include programs
*-----------------------------------------------------------------------
  INCLUDE zgdtxnr0001f01.

*-----------------------------------------------------------------------
* Start of selection
*-----------------------------------------------------------------------
START-OF-SELECTION.
**Validate Correction number
  SELECT SINGLE * FROM zgdtxdt0004
                  WHERE bukrs = p_bukrs AND
                        brnch = p_brnch AND
                        masatx = p_mtxin.
  IF sy-subrc = 0.
    IF zgdtxdt0004-closedat IS INITIAL AND p_korek <> '0'.
      MESSAGE i000(zab) WITH 'Tax period must be closed first'
                             'for correction number > 0'.
      STOP.
    ENDIF.
  ELSE.
    MESSAGE i000(zab) WITH 'Tax period does not exist'.
    STOP.
  ENDIF.

  PERFORM f_get_data.
  PERFORM f_write_data.

  IF NOT p_down IS INITIAL.
    PERFORM f_download.
  ENDIF.

  IF NOT p_down11 IS INITIAL.
    PERFORM f_download11.
  ENDIF.


*Text elements
*-------------
* ID02     Period



*Selection texts
*---------------
*SP_BRNCH         Branch
*SP_BUKRS         Company Code
*SP_MTXIN         Tax Period
*SP_VARI          ALV Variant
*SS_FORM          Form
